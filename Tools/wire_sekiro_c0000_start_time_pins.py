import json
import sys
from pathlib import Path


TOOL_DIR = Path(__file__).resolve().parent
if str(TOOL_DIR) not in sys.path:
    sys.path.append(str(TOOL_DIR))

from sekiro_monolith_client import MCPClient, MCPError


PROJECT_ROOT = TOOL_DIR.parent
ABP_PATH = "/Game/Animation/Sekiro/C0000/Blueprints/ABP_Sekiro_C0000_Master"
REPORT_PATH = PROJECT_ROOT / "Saved" / "SekiroImportReports" / "c0000_start_time_wiring_report.json"

STATE_SPECS = [
    {
        "machine_name": "StandMove_SM",
        "graph_name": "StandMoveStart",
        "player_class": "AnimGraphNode_BlendSpacePlayer",
        "variable_name": "StartTime_03",
        "variable_node_pos": (-896, 192),
    },
    {
        "machine_name": "StandMove_SM",
        "graph_name": "StandMoveStartFromFreeFall",
        "player_class": "AnimGraphNode_BlendSpacePlayer",
        "variable_name": "StartTime_03",
        "variable_node_pos": (-896, 192),
    },
    {
        "machine_name": "StandMove_SM",
        "graph_name": "StandMoveStartFromFreeFallShortStiff",
        "player_class": "AnimGraphNode_BlendSpacePlayer",
        "variable_name": "StartTime_03",
        "variable_node_pos": (-896, 192),
    },
    {
        "machine_name": "StandMove_SM",
        "graph_name": "StandMoveStartFromLandGroundPositioningJump",
        "player_class": "AnimGraphNode_BlendSpacePlayer",
        "variable_name": "StartTime_03",
        "variable_node_pos": (-896, 192),
    },
    {
        "machine_name": "StandMove_SM",
        "graph_name": "StandMoveLoop",
        "player_class": "AnimGraphNode_BlendSpacePlayer",
        "variable_name": "StartTime_02",
        "variable_node_pos": (-896, 192),
    },
    {
        "machine_name": "StandMove_SM",
        "graph_name": "StandMoveLoopFromSprint",
        "player_class": "AnimGraphNode_BlendSpacePlayer",
        "variable_name": "StartTime_02",
        "variable_node_pos": (-896, 192),
    },
    {
        "machine_name": "StandMoveLower_SM",
        "graph_name": "StandMoveLowerStart",
        "player_class": "AnimGraphNode_BlendSpacePlayer",
        "variable_name": "StartTime_01",
        "variable_node_pos": (-896, 192),
    },
]


def write_report(report: dict) -> None:
    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")


def run_editor_python(client: MCPClient, command: str) -> dict:
    return client.call(
        "editor_query",
        "run_python",
        {
            "command": command,
            "mode": "execute_file",
            "unattended": True,
        },
    )


def get_graph_data(client: MCPClient, graph_name: str) -> dict:
    return client.call(
        "blueprint_query",
        "get_graph_data",
        {
            "asset_path": ABP_PATH,
            "graph_name": graph_name,
        },
    )


def get_node_by_id(graph_data: dict, node_id: str) -> dict | None:
    for node in graph_data.get("nodes", []):
        if node.get("id") == node_id:
            return node
    return None


def get_player_node(graph_data: dict, player_class: str) -> dict:
    for node in graph_data.get("nodes", []):
        if node.get("class") == player_class:
            return node
    raise RuntimeError(f"Could not find player node '{player_class}' in graph '{graph_data.get('graph_name')}'.")


def get_variable_node(graph_data: dict, variable_name: str) -> dict | None:
    expected_title = f"Get {variable_name}"
    for node in graph_data.get("nodes", []):
        if node.get("class") != "K2Node_VariableGet":
            continue
        if node.get("title") != expected_title:
            continue
        if get_pin(node, variable_name, "output") is None:
            continue
        return node
    return None


def get_pin(node: dict, pin_name: str, direction: str) -> dict | None:
    for pin in node.get("pins", []):
        if pin.get("name") == pin_name and pin.get("direction") == direction:
            return pin
    return None


def get_start_position_pin_name(player_node: dict) -> str:
    for candidate in ("StartPosition", "Start Position"):
        if get_pin(player_node, candidate, "input") is not None:
            return candidate
    for pin in player_node.get("pins", []):
        if pin.get("direction") == "input" and "start" in str(pin.get("name", "")).lower():
            return str(pin["name"])
    raise RuntimeError(f"Could not resolve StartPosition pin on node '{player_node.get('id')}'.")


def is_connected(source_node: dict, source_pin_name: str, target_node_id: str, target_pin_name: str) -> bool:
    pin = get_pin(source_node, source_pin_name, "output")
    if pin is None:
        return False
    target_ref = f"{target_node_id}.{target_pin_name}"
    return target_ref in (pin.get("connected_to") or [])


def ensure_variable_node(
    client: MCPClient,
    machine_name: str,
    graph_name: str,
    variable_name: str,
    position_x: int,
    position_y: int,
) -> dict:
    graph_data = get_graph_data(client, graph_name)
    existing = get_variable_node(graph_data, variable_name)
    if existing is not None:
        return {
            "skipped": True,
            "node_name": existing["id"],
            "message": "variable get already exists",
        }

    return client.call(
        "animation_query",
        "add_variable_get",
        {
            "asset_path": ABP_PATH,
            "graph_name": machine_name,
            "state_name": graph_name,
            "variable_name": variable_name,
            "position_x": position_x,
            "position_y": position_y,
        },
    )


def ensure_connection(
    client: MCPClient,
    machine_name: str,
    graph_name: str,
    source_node_id: str,
    source_pin_name: str,
    target_node_id: str,
    target_pin_name: str,
) -> dict:
    graph_data = get_graph_data(client, graph_name)
    source_node = get_node_by_id(graph_data, source_node_id)
    if source_node is None:
        raise RuntimeError(f"Could not find source node '{source_node_id}' in '{graph_name}'.")

    if is_connected(source_node, source_pin_name, target_node_id, target_pin_name):
        return {
            "skipped": True,
            "message": "connection already exists",
        }

    return client.call(
        "animation_query",
        "connect_anim_graph_pins",
        {
            "asset_path": ABP_PATH,
            "graph_name": machine_name,
            "state_name": graph_name,
            "source_node": source_node_id,
            "source_pin": source_pin_name,
            "target_node": target_node_id,
            "target_pin": target_pin_name,
            "compile": False,
        },
    )


def expose_start_position_pin(client: MCPClient, graph_name: str, player_class: str, player_node_id: str) -> dict:
    command = f"""
import json
import unreal

asset = unreal.load_asset({json.dumps(ABP_PATH, ensure_ascii=False)})
graph = unreal.BlueprintEditorLibrary.find_graph(asset, {json.dumps(graph_name, ensure_ascii=False)})
result = {{
    "graph_name": {json.dumps(graph_name, ensure_ascii=False)},
    "player_class": {json.dumps(player_class, ensure_ascii=False)},
    "player_node_id": {json.dumps(player_node_id, ensure_ascii=False)},
    "updated": False,
    "found_graph": bool(graph),
    "found_node": False,
    "found_pin": False,
}}

if graph:
    node_class = getattr(unreal, {json.dumps(player_class, ensure_ascii=False)}, None)
    if node_class:
        for node in graph.get_graph_nodes_of_class(node_class):
            if node.get_name() != {json.dumps(player_node_id, ensure_ascii=False)}:
                continue
            result["found_node"] = True
            pins = list(node.get_editor_property("show_pin_for_properties"))
            for pin_data in pins:
                if str(pin_data.get_editor_property("property_name")) != "StartPosition":
                    continue
                result["found_pin"] = True
                if not bool(pin_data.get_editor_property("bShowPin")):
                    pin_data.set_editor_property("bShowPin", True)
                    node.set_editor_property("show_pin_for_properties", pins)
                    result["updated"] = True
                break
            break

unreal.BlueprintEditorLibrary.refresh_open_editors_for_blueprint(asset)
print(json.dumps(result, ensure_ascii=False))
"""
    return run_editor_python(client, command)


def reconstruct_player_node(client: MCPClient, graph_name: str, player_node_id: str) -> dict:
    return client.call(
        "animation_query",
        "set_anim_graph_node_property",
        {
            "asset_path": ABP_PATH,
            "graph_name": graph_name,
            "node_id": player_node_id,
            "property_path": "StartPosition",
            "value": "0.0",
        },
    )


def compile_and_save(client: MCPClient) -> dict:
    compile_result = client.call(
        "blueprint_query",
        "compile_blueprint",
        {
            "asset_path": ABP_PATH,
        },
    )

    try:
        save_result = client.call(
            "blueprint_query",
            "save_asset",
            {
                "asset_path": ABP_PATH,
            },
        )
    except MCPError as exc:
        save_result = {
            "fallback": True,
            "warning": str(exc),
            "editor_save": run_editor_python(
                client,
                (
                    "import json\n"
                    "import unreal\n"
                    f"asset = unreal.load_asset({json.dumps(ABP_PATH, ensure_ascii=False)})\n"
                    "saved = unreal.EditorAssetLibrary.save_loaded_asset(asset, only_if_is_dirty=False)\n"
                    "print(json.dumps({'saved': bool(saved)}, ensure_ascii=False))\n"
                ),
            ),
        }

    return {
        "compile": compile_result,
        "save": save_result,
    }


def apply_state_spec(client: MCPClient, spec: dict) -> dict:
    machine_name = spec["machine_name"]
    graph_name = spec["graph_name"]
    graph_data = get_graph_data(client, graph_name)
    player_node = get_player_node(graph_data, spec["player_class"])

    result = {
        "machine_name": machine_name,
        "graph_name": graph_name,
        "player_node_id": player_node["id"],
        "player_class": player_node["class"],
        "variable_name": spec["variable_name"],
    }

    result["expose_start_position"] = expose_start_position_pin(
        client,
        graph_name,
        spec["player_class"],
        player_node["id"],
    )
    result["reconstruct_player_node"] = reconstruct_player_node(client, graph_name, player_node["id"])

    refreshed_graph = get_graph_data(client, graph_name)
    refreshed_player_node = get_node_by_id(refreshed_graph, player_node["id"])
    if refreshed_player_node is None:
        raise RuntimeError(f"Could not reload player node '{player_node['id']}' in graph '{graph_name}'.")

    start_position_pin_name = get_start_position_pin_name(refreshed_player_node)
    result["start_position_pin_name"] = start_position_pin_name

    result["variable_node"] = ensure_variable_node(
        client,
        machine_name,
        graph_name,
        spec["variable_name"],
        spec["variable_node_pos"][0],
        spec["variable_node_pos"][1],
    )

    graph_after_variable = get_graph_data(client, graph_name)
    variable_node = get_variable_node(graph_after_variable, spec["variable_name"])
    if variable_node is None:
        raise RuntimeError(
            f"Could not resolve variable node for '{spec['variable_name']}' in graph '{graph_name}'."
        )

    result["variable_node_id"] = variable_node["id"]
    result["connect_start_time_to_player"] = ensure_connection(
        client,
        machine_name,
        graph_name,
        variable_node["id"],
        spec["variable_name"],
        player_node["id"],
        start_position_pin_name,
    )

    result["graph_snapshot"] = get_graph_data(client, graph_name)
    return result


def main() -> None:
    client = MCPClient()
    report = {
        "asset_path": ABP_PATH,
        "status": "running",
        "states": [],
    }

    try:
        for spec in STATE_SPECS:
            report["states"].append(apply_state_spec(client, spec))

        report.update(compile_and_save(client))
        report["status"] = "success"
        write_report(report)
        print(json.dumps(report, ensure_ascii=False, indent=2))
    except Exception as exc:
        report["status"] = "failed"
        report["error"] = str(exc)
        write_report(report)
        raise


if __name__ == "__main__":
    main()
