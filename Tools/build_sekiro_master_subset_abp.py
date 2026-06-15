import json
import os
import urllib.error
import urllib.request
from pathlib import Path


MCP_URL = "http://127.0.0.1:9316/mcp"
ASSET_PATH = "/Game/Animation/Sekiro/C0000/Blueprints/ABP_Sekiro_C0000_Master"
SKELETON_PATH = "/Game/Animation/Sekiro/C0000/Base/c0000_bindpose_Skeleton"
TOP_LEVEL_MACHINE = "Sekiro_MasterSubset_SM"
OVERWRITE_STATE_GRAPH = "StandMoveOverwrite"
OVERWRITE_LAYER_BONE = "Spine1"
OVERWRITE_LAYER_DEPTH = 255
REPORT_PATH = Path(r"E:\UEProj\Sekiro\SekiroDemo\Saved\SekiroImportReports\c0000_master_animbp_mapping.json")


class MCPError(RuntimeError):
    pass


class MCPClient:
    def __init__(self, url: str):
        self.url = url
        self._next_id = 1

    def call(self, tool_name: str, action: str, params: dict | None = None):
        payload = {
            "jsonrpc": "2.0",
            "id": self._next_id,
            "method": "tools/call",
            "params": {
                "name": tool_name,
                "arguments": {
                    "action": action,
                    "params": params or {},
                },
            },
        }
        self._next_id += 1

        data = json.dumps(payload).encode("utf-8")
        req = urllib.request.Request(
            self.url,
            data=data,
            headers={"Content-Type": "application/json"},
            method="POST",
        )

        try:
            with urllib.request.urlopen(req, timeout=120) as resp:
                raw = json.loads(resp.read().decode("utf-8"))
        except urllib.error.HTTPError as exc:
            raise MCPError(f"HTTP {exc.code}: {exc.read().decode('utf-8', errors='replace')}") from exc
        except urllib.error.URLError as exc:
            raise MCPError(f"Failed to reach Monolith MCP at {self.url}: {exc}") from exc

        if "error" in raw:
            raise MCPError(raw["error"].get("message", json.dumps(raw["error"], ensure_ascii=False)))

        result = raw.get("result", {})
        content = result.get("content", [])
        text = ""
        if content:
            text = content[0].get("text", "")

        if result.get("isError"):
            raise MCPError(text or json.dumps(result, ensure_ascii=False))

        if not text:
            return {}

        try:
            return json.loads(text)
        except json.JSONDecodeError:
            return {"raw_text": text}


def ensure_call(client: MCPClient, tool_name: str, action: str, params: dict, ok_errors: tuple[str, ...] = ()):
    try:
        return client.call(tool_name, action, params)
    except MCPError as exc:
        message = str(exc)
        if any(marker in message for marker in ok_errors):
            return {"skipped": True, "message": message}
        raise


def save_asset_with_fallback(client: MCPClient, asset_path: str) -> dict:
    try:
        return client.call("blueprint_query", "save_asset", {"asset_path": asset_path})
    except Exception as exc:
        save_via_editor = client.call(
            "editor_query",
            "run_python",
            {
                "command": (
                    "import json\n"
                    "import unreal\n"
                    f"asset = unreal.load_asset('{asset_path}')\n"
                    "if not asset:\n"
                    "    raise RuntimeError('Failed to load asset for fallback save.')\n"
                    "saved = unreal.EditorAssetLibrary.save_loaded_asset(asset, only_if_is_dirty=False)\n"
                    "if not saved:\n"
                    f"    saved = unreal.EditorAssetLibrary.save_asset('{asset_path}', only_if_is_dirty=False)\n"
                    "print(json.dumps({\n"
                    f"    'asset_path': '{asset_path}',\n"
                    "    'saved': bool(saved),\n"
                    "}, ensure_ascii=False))\n"
                ),
                "mode": "execute_file",
                "unattended": True,
            },
        )
        return {
            "fallback": True,
            "warning": str(exc),
            "editor_save": save_via_editor,
        }


def find_animgraph_node_id_by_title(client: MCPClient, asset_path: str, title: str) -> str | None:
    summary = client.call(
        "blueprint_query",
        "get_graph_summary",
        {"asset_path": asset_path, "graph_name": "AnimGraph"},
    )
    for node in summary.get("nodes", []):
        if node.get("title") == title:
            return node.get("id")
    return None


def get_graph_data(client: MCPClient, asset_path: str, graph_name: str) -> dict:
    return client.call(
        "blueprint_query",
        "get_graph_data",
        {"asset_path": asset_path, "graph_name": graph_name},
    )


def find_graph_node_by_title(graph_data: dict, title: str) -> dict | None:
    for node in graph_data.get("nodes", []):
        node_title = node.get("title", "")
        if node_title == title or node_title.split("\n", 1)[0] == title:
            return node
    return None


def find_graph_node_by_class(graph_data: dict, class_name: str) -> dict | None:
    for node in graph_data.get("nodes", []):
        if node.get("class") == class_name:
            return node
    return None


def find_graph_node_by_id(graph_data: dict, node_id: str) -> dict | None:
    for node in graph_data.get("nodes", []):
        if node.get("id") == node_id:
            return node
    return None


def find_pin_name(node: dict, direction: str, preferred_names: tuple[str, ...], contains: tuple[str, ...] = ()) -> str:
    pins = node.get("pins", [])
    for name in preferred_names:
        for pin in pins:
            if pin.get("direction") == direction and pin.get("name") == name:
                return name

    lowered_tokens = tuple(token.lower() for token in contains)
    for pin in pins:
        if pin.get("direction") != direction:
            continue
        pin_name = pin.get("name", "")
        lowered_name = pin_name.lower()
        if lowered_tokens and all(token in lowered_name for token in lowered_tokens):
            return pin_name

    raise MCPError(
        f"Could not find a {direction} pin on node '{node.get('id')}' matching "
        f"preferred_names={preferred_names} contains={contains}"
    )


def pin_has_connection(node: dict, pin_name: str, target_node: str, target_pin: str) -> bool:
    target_ref = f"{target_node}.{target_pin}"
    for pin in node.get("pins", []):
        if pin.get("name") == pin_name and pin.get("direction") in {"input", "output"}:
            return target_ref in pin.get("connected_to", [])
    return False


def ensure_graph_connection(
    client: MCPClient,
    asset_path: str,
    graph_name: str,
    state_name: str | None,
    graph_data: dict,
    source_node: str,
    source_pin: str,
    target_node: str,
    target_pin: str,
):
    source = next((node for node in graph_data.get("nodes", []) if node.get("id") == source_node), None)
    if source and pin_has_connection(source, source_pin, target_node, target_pin):
        return {"skipped": True, "message": "connection already exists"}

    params = {
        "asset_path": asset_path,
        "graph_name": graph_name,
        "source_node": source_node,
        "source_pin": source_pin,
        "target_node": target_node,
        "target_pin": target_pin,
        "compile": False,
    }
    if state_name is not None:
        params["state_name"] = state_name

    return ensure_call(client, "animation_query", "connect_anim_graph_pins", params)


def ensure_machine_entry_connection(client: MCPClient, machine_name: str, entry_state_name: str):
    graph_data = get_graph_data(client, ASSET_PATH, machine_name)
    entry_node = find_graph_node_by_class(graph_data, "AnimStateEntryNode")
    state_node = find_graph_node_by_title(graph_data, entry_state_name)

    if not entry_node or not state_node:
        raise MCPError(f"Could not resolve entry wiring nodes for machine '{machine_name}'.")

    if pin_has_connection(entry_node, "Entry", state_node["id"], "In"):
        return {"skipped": True, "message": "entry already connected"}

    return ensure_call(
        client,
        "animation_query",
        "connect_anim_graph_pins",
        {
            "asset_path": ASSET_PATH,
            "graph_name": machine_name,
            "source_node": entry_node["id"],
            "source_pin": "Entry",
            "target_node": state_node["id"],
            "target_pin": "In",
            "compile": True,
        },
    )


def ensure_standmoveoverwrite_layered_output(client: MCPClient, report: dict):
    graph_data = get_graph_data(client, ASSET_PATH, OVERWRITE_STATE_GRAPH)
    lower_node = find_graph_node_by_title(graph_data, "StandMoveLower_SM")
    upper_node = find_graph_node_by_title(graph_data, "StandMoveUpper_SM")
    result_node = find_graph_node_by_class(graph_data, "AnimGraphNode_StateResult")
    layered_node = find_graph_node_by_class(graph_data, "AnimGraphNode_LayeredBoneBlend")

    if not lower_node or not upper_node or not result_node:
        raise MCPError("StandMoveOverwrite graph is missing one or more required nodes.")

    layered_add_result = None
    if not layered_node:
        layered_add_result = client.call(
            "animation_query",
            "add_anim_graph_node",
            {
                "asset_path": ASSET_PATH,
                "graph_name": TOP_LEVEL_MACHINE,
                "state_name": OVERWRITE_STATE_GRAPH,
                "node_type": "LayeredBoneBlend",
                "position_x": 980,
                "position_y": 20,
            },
        )
        graph_data = get_graph_data(client, ASSET_PATH, OVERWRITE_STATE_GRAPH)
        layered_node = find_graph_node_by_class(graph_data, "AnimGraphNode_LayeredBoneBlend")

    if not layered_node:
        raise MCPError("Failed to create or resolve the LayeredBoneBlend node in StandMoveOverwrite.")

    lower_pose_pin = find_pin_name(lower_node, "output", ("Pose",), ("pose",))
    upper_pose_pin = find_pin_name(upper_node, "output", ("Pose",), ("pose",))
    base_pose_pin = find_pin_name(layered_node, "input", ("Base Pose", "BasePose"), ("base", "pose"))
    blend_pose_pin = find_pin_name(
        layered_node,
        "input",
        ("Blend Poses 0", "BlendPose 0", "BlendPose0", "BlendPoses 0"),
        ("blend", "pose", "0"),
    )
    layered_pose_pin = find_pin_name(layered_node, "output", ("Pose",), ("pose",))
    result_pin = find_pin_name(result_node, "input", ("Result",), ("result",))

    layer_setup_text = (
        f"((BranchFilters=((BoneName=\"{OVERWRITE_LAYER_BONE}\",BlendDepth={OVERWRITE_LAYER_DEPTH}))))"
    )
    layer_setup_result = ensure_call(
        client,
        "animation_query",
        "set_anim_graph_node_property",
        {
            "asset_path": ASSET_PATH,
            "graph_name": TOP_LEVEL_MACHINE,
            "state_name": OVERWRITE_STATE_GRAPH,
            "node_id": layered_node["id"],
            "property_path": "LayerSetup",
            "value": layer_setup_text,
        },
    )

    graph_data = get_graph_data(client, ASSET_PATH, OVERWRITE_STATE_GRAPH)
    lower_node = next(node for node in graph_data.get("nodes", []) if node.get("id") == lower_node["id"])
    upper_node = next(node for node in graph_data.get("nodes", []) if node.get("id") == upper_node["id"])
    layered_node = next(node for node in graph_data.get("nodes", []) if node.get("id") == layered_node["id"])
    result_node = next(node for node in graph_data.get("nodes", []) if node.get("id") == result_node["id"])

    connection_results = {
        "lower_to_base": ensure_graph_connection(
            client,
            ASSET_PATH,
            TOP_LEVEL_MACHINE,
            OVERWRITE_STATE_GRAPH,
            graph_data,
            lower_node["id"],
            lower_pose_pin,
            layered_node["id"],
            base_pose_pin,
        ),
        "upper_to_layer": ensure_graph_connection(
            client,
            ASSET_PATH,
            TOP_LEVEL_MACHINE,
            OVERWRITE_STATE_GRAPH,
            graph_data,
            upper_node["id"],
            upper_pose_pin,
            layered_node["id"],
            blend_pose_pin,
        ),
        "layer_to_result": ensure_graph_connection(
            client,
            ASSET_PATH,
            TOP_LEVEL_MACHINE,
            OVERWRITE_STATE_GRAPH,
            graph_data,
            layered_node["id"],
            layered_pose_pin,
            result_node["id"],
            result_pin,
        ),
    }

    report["overwrite_layered_blend"] = {
        "graph_name": OVERWRITE_STATE_GRAPH,
        "layer_bone": OVERWRITE_LAYER_BONE,
        "layer_depth": OVERWRITE_LAYER_DEPTH,
        "layer_setup_text": layer_setup_text,
        "layer_setup_result": layer_setup_result,
        "layered_node_id": layered_node["id"],
        "layered_node_created": layered_add_result is not None,
        "layered_node_add_result": layered_add_result,
        "connections": connection_results,
        "graph_snapshot": get_graph_data(client, ASSET_PATH, OVERWRITE_STATE_GRAPH),
    }


def get_machine_transitions(client: MCPClient, machine_name: str) -> list[dict]:
    result = client.call(
        "animation_query",
        "get_transitions",
        {"asset_path": ASSET_PATH, "machine_name": machine_name},
    )
    return result.get("transitions", [])


def has_transition_pair(transitions: list[dict], from_state: str, to_state: str) -> bool:
    return any(
        transition.get("from") == from_state and transition.get("to") == to_state
        for transition in transitions
    )


def has_transition_rule_variable(
    transitions: list[dict],
    from_state: str,
    to_state: str,
    variable_name: str,
    compare_value: int | None = None,
) -> bool:
    expected_title = f"Get {variable_name}"
    for transition in transitions:
        if transition.get("from") != from_state or transition.get("to") != to_state:
            continue
        rule_nodes = transition.get("rule_nodes", [])
        has_getter = any(node.get("title") == expected_title for node in rule_nodes)
        if not has_getter:
            continue
        if compare_value is None:
            return True
        if len(rule_nodes) >= 3:
            return True
    return False


def summarize_sync_entry_rules(
    client: MCPClient,
    machine_name: str,
    idle_state: str,
    expected_rules: list[dict],
    variable_name: str,
) -> dict:
    transitions = get_machine_transitions(client, machine_name)
    expected_getter_title = f"Get {variable_name}"
    mismatches = []
    matched_count = 0

    for rule in expected_rules:
        transition = next(
            (
                item
                for item in transitions
                if item.get("from") == idle_state and item.get("to") == rule["state"]
            ),
            None,
        )
        if transition is None:
            mismatches.append(
                {
                    "from": idle_state,
                    "to": rule["state"],
                    "state_id": rule["state_id"],
                    "missing": True,
                }
            )
            continue

        rule_titles = [node.get("title") for node in transition.get("rule_nodes", [])]
        has_expected_shape = expected_getter_title in rule_titles and "Equal (Integer)" in rule_titles
        if has_expected_shape:
            matched_count += 1
            continue

        mismatches.append(
            {
                "from": idle_state,
                "to": rule["state"],
                "state_id": rule["state_id"],
                "rule_nodes": rule_titles,
            }
        )

    return {
        "machine_name": machine_name,
        "idle_state": idle_state,
        "variable_name": variable_name,
        "expected_count": len(expected_rules),
        "matched_count": matched_count,
        "ok": matched_count == len(expected_rules) and not mismatches,
        "mismatches": mismatches,
    }


def ensure_machine_transition(
    client: MCPClient,
    machine_name: str,
    from_state: str,
    to_state: str,
    variable_name: str,
    compare_value: int | None = None,
):
    transitions = get_machine_transitions(client, machine_name)

    add_result = {"skipped": True, "message": "transition already exists"}
    if not has_transition_pair(transitions, from_state, to_state):
        add_result = ensure_call(
            client,
            "animation_query",
            "add_transition",
            {
                "asset_path": ASSET_PATH,
                "machine_name": machine_name,
                "from_state": from_state,
                "to_state": to_state,
            },
            ok_errors=("already be connected", "invalid",),
        )
        transitions = get_machine_transitions(client, machine_name)

    if not has_transition_pair(transitions, from_state, to_state):
        return {
            "from": from_state,
            "to": to_state,
            "variable": variable_name,
            "compare_value": compare_value,
            "add_result": add_result,
            "rule_result": {
                "skipped": True,
                "message": "transition unavailable after add attempt (likely unsupported self-transition)",
            },
        }

    rule_params = {
        "asset_path": ASSET_PATH,
        "machine_name": machine_name,
        "from_state": from_state,
        "to_state": to_state,
        "variable_name": variable_name,
        "compile": False,
    }
    if compare_value is not None:
        rule_params["compare_value"] = compare_value

    rule_result = {"skipped": True, "message": f"rule already uses {variable_name}"}
    if compare_value is not None:
        rule_result = ensure_call(client, "animation_query", "set_transition_rule", rule_params)
    elif not has_transition_rule_variable(transitions, from_state, to_state, variable_name, compare_value):
        rule_result = ensure_call(client, "animation_query", "set_transition_rule", rule_params)

    return {
        "from": from_state,
        "to": to_state,
        "variable": variable_name,
        "compare_value": compare_value,
        "add_result": add_result,
        "rule_result": rule_result,
    }


def connect_to_result(client: MCPClient, asset_path: str, source_node: str, graph_name: str, state_name: str | None):
    graph_lookup_name = graph_name if state_name is None else state_name
    graph_data = get_graph_data(client, asset_path, graph_lookup_name)
    source = find_graph_node_by_id(graph_data, source_node)
    if not source:
        raise MCPError(
            f"Could not find source node '{source_node}' in graph '{graph_lookup_name}' while wiring result pose."
        )

    result_node_class = "AnimGraphNode_Root" if state_name is None else "AnimGraphNode_StateResult"
    result_node = find_graph_node_by_class(graph_data, result_node_class)
    if not result_node:
        raise MCPError(f"Could not find result node in graph '{graph_lookup_name}'.")

    source_pin = find_pin_name(source, "output", ("Pose",), ("pose",))
    result_pin = find_pin_name(result_node, "input", ("Result",), ("result",))

    if pin_has_connection(source, source_pin, result_node["id"], result_pin):
        return {"skipped": True, "message": "result pose already connected"}

    params = {
        "asset_path": asset_path,
        "graph_name": graph_name,
        "source_node": source_node,
        "source_pin": source_pin,
        "target_node": result_node["id"],
        "target_pin": result_pin,
        "compile": True,
    }
    if state_name is not None:
        params["state_name"] = state_name

    return ensure_call(
        client,
        "animation_query",
        "connect_anim_graph_pins",
        params,
        ok_errors=("TryCreateConnection failed",),
    )


def find_nested_state_machine_node_id(
    client: MCPClient,
    asset_path: str,
    state_graph_name: str,
    machine_name: str,
) -> str | None:
    graph_data = get_graph_data(client, asset_path, state_graph_name)
    node = find_graph_node_by_title(graph_data, machine_name)
    return node.get("id") if node else None


VARIABLES = [
    {"name": "StateStateId_StandMoveableAction", "type": "int", "default_value": "0", "category": "Sekiro|StateIds", "instance_editable": False},
    {"name": "Req_Event26011_to_EventDummy", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_Event26021_to_EventDummy", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_Event26031_to_EventDummy", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_CoverActionStart", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_CoverEnd", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_CoverIdle", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_CoverLookThrowGrab", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_Event3013", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_Event3014", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_Event3018", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_Event3019", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_Event3026", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_Event3027", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_Event3028", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_Event3029", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_Event3037", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_Event3038", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_Event3039", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_Event3040", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_Event3041", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_Event3042", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_Event3043", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_Event3044", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_Event3045", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_WideshotRightStart", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_WideshotRightStart_mirror", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_Idle", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_Idle_Short", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_a000_00000000_End", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_a000_00000001_End", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_Attack3049", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_Attack3050", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_Attack3051", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_Attack3052", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_Attack3053", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_Attack3079", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_ChargeShotLoop", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_ChargeShotRightEnd", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_DeflectGuardToStand", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_DirDamageLargeBack_Add", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_DirDamageLargeFront_Add", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_DirDamageLargeFrontDown_Add", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_DirDamageLargeFrontUp_Add", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_DirDamageLargeLeft_Add", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_DirDamageLargeRight_Add", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_DirDamageMediumBack_Add", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_Master", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_Move", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_IdleUnique410", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_IdleUnique411", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_IdleUnique412", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_IdleUnique420", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_IdleUnique421", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_IdleUnique422", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_IdleUnique430", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_IdleUnique431", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_IdleUniqueDamage8801", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_IdleUniqueDamage8802", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_ItemInvalid", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_ItemInvalid_Upper", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_ItemPray_Upper", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_LadderAttachBottom", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_LandWaterFreeFall", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_PartBlend_Add11", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_PartBlend_Add13", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_PartBlend_Add14", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_PartBlend_NoAdd11", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_PartBlend_NoAdd3", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_PartBlend_NoAdd4", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_PartBlend_NoAdd5", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_PartBlend_NoAdd6", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_WalkStopLeft", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_WalkUpward", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_AttackBoundParry_Add01", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_W_AttackBoundGuard_Add04", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_AttackBoundGuard_Add04_to_AttackBoundGuard_NoAdd", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_AttackBoundParry_Add02_to_AttackBoundParry_NoAdd", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_AttackBoundParry_Add03_to_AttackBoundParry_NoAdd", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_AttackBoundParry_Add04_to_AttackBoundParry_NoAdd", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_AttackWeakBound_Add03_to_AttackWeakBound_NoAdd", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Req_AttackWeakBound_Add04_to_AttackWeakBound_NoAdd", "type": "bool", "default_value": "false", "category": "Sekiro|Requests", "instance_editable": False},
    {"name": "Return_To_StandMove", "type": "bool", "default_value": "false", "category": "Sekiro|Returns", "instance_editable": False},
    {"name": "Return_To_StandMoveLowerLoop", "type": "bool", "default_value": "false", "category": "Sekiro|Returns", "instance_editable": False},
    {"name": "Return_To_StandMoveableAction_Idle", "type": "bool", "default_value": "false", "category": "Sekiro|Returns", "instance_editable": False},
]


TOP_LEVEL_STATES = [
    {"name": "StandMove", "position_x": 280, "position_y": 40},
    {"name": "StandMoveableAction", "position_x": 760, "position_y": -180},
    {"name": "StandMoveOverwrite", "position_x": 760, "position_y": 220},
]


TOP_LEVEL_TRANSITIONS = [
    {"from": "StandMove", "to": "StandMoveableAction", "var": "Req_W_Attack3049"},
    {"from": "StandMoveableAction", "to": "StandMove", "var": "Return_To_StandMove"},
    {"from": "StandMoveableAction", "to": "StandMoveOverwrite", "var": "Req_W_ChargeShotRightEnd"},
    {"from": "StandMove", "to": "StandMoveOverwrite", "var": "Req_W_ChargeShotRightEnd"},
    {"from": "StandMoveOverwrite", "to": "StandMoveableAction", "var": "Return_To_StandMoveableAction_Idle"},
    {"from": "StandMoveOverwrite", "to": "StandMove", "var": "Return_To_StandMove"},
]


STANDMOVEABLEACTION_SYNC_ENTRY_RULES = [
    {"state": "ItemPillTonic", "state_id": 0, "event": "W_PartBlend_NoAdd11"},
    {"state": "DeflectGuardToStand", "state_id": 120, "event": "W_Attack3050"},
    {"state": "SubWeaponExpand", "state_id": 133, "event": "W_Attack3079"},
    {"state": "GroundSubAttackCombo1Moveable", "state_id": 134, "event": "W_DeflectGuardToStand"},
    {"state": "GroundSubAttackCombo1ReleaseMoveable", "state_id": 135, "event": "W_DirDamageLargeBack_Add"},
    {"state": "GroundSubAttackLockOnMoveable", "state_id": 136, "event": "W_DirDamageLargeFront_Add"},
    {"state": "GroundSubAttackLockOnReleaseMoveable", "state_id": 137, "event": "W_DirDamageLargeFrontDown_Add"},
    {"state": "ItemFailed", "state_id": 138, "event": "W_Event3013"},
    {"state": "ItemGourdDrink", "state_id": 200, "event": "W_IdleUnique411"},
    {"state": "ItemGourdDrinkFailed", "state_id": 201, "event": "W_IdleUnique412"},
    {"state": "ItemGourdDrinkRepeat", "state_id": 210, "event": "W_IdleUnique410"},
    {"state": "ItemGourdDrinkRepeatFailed", "state_id": 211, "event": "W_IdleUnique420"},
    {"state": "ItemAntiHallucinogen", "state_id": 220, "event": "W_IdleUniqueDamage8802"},
    {"state": "ItemPowderMedicineRecoverPoison", "state_id": 221, "event": "W_ItemInvalid_Upper"},
    {"state": "DeflectGuardToStandVariation", "state_id": 121, "event": "W_Master"},
    {"state": "ItemStone", "state_id": 230, "event": "W_IdleUniqueDamage8801"},
    {"state": "ItemPaperDollExchangeWhite", "state_id": 240, "event": "W_PartBlend_Add11"},
    {"state": "SubWeaponExpand2", "state_id": 241, "event": "W_PartBlend_NoAdd3"},
    {"state": "SubWeaponExpand3", "state_id": 242, "event": "W_PartBlend_NoAdd4"},
    {"state": "GroundSubAttackHoldLoop", "state_id": 250, "event": "W_WalkStopLeft"},
    {"state": "ItemAntiGhostBuff", "state_id": 262, "event": "W_ItemInvalid"},
    {"state": "ItemOhagi", "state_id": 260, "event": "W_LandWaterFreeFall"},
    {"state": "ItemKaki", "state_id": 261, "event": "AttackBoundGuard_Add04_to_AttackBoundGuard_NoAdd"},
    {"state": "ItemPottery", "state_id": 263, "event": "AttackWeakBound_Add03_to_AttackWeakBound_NoAdd"},
]


STANDMOVEUPPER_SYNC_ENTRY_RULES = [
    {"state": "ItemPillTonicMove", "state_id": 0, "event": "W_Attack3052"},
    {"state": "DeflectGuardToStandMove", "state_id": 120, "event": "W_Attack3053"},
    {"state": "SubWeaponExpandMove", "state_id": 133, "event": "W_ChargeShotLoop"},
    {"state": "GroundSubAttackCombo1Move", "state_id": 134, "event": "W_DirDamageLargeFrontUp_Add"},
    {"state": "GroundSubAttackCombo1ReleaseMove", "state_id": 135, "event": "W_DirDamageLargeLeft_Add"},
    {"state": "GroundSubAttackLockOnMove", "state_id": 136, "event": "W_DirDamageLargeRight_Add"},
    {"state": "GroundSubAttackLockOnReleaseMove", "state_id": 137, "event": "W_DirDamageMediumBack_Add"},
    {"state": "ItemFailedMove", "state_id": 138, "event": "W_Event3014"},
    {"state": "ItemGourdDrinkMove", "state_id": 200, "event": "W_IdleUnique421"},
    {"state": "ItemGourdDrinkFailedMove", "state_id": 201, "event": "W_IdleUnique430"},
    {"state": "ItemGourdDrinkRepeatMove", "state_id": 210, "event": "W_IdleUnique422"},
    {"state": "ItemGourdDrinkRepeatFailedMove", "state_id": 211, "event": "W_IdleUnique431"},
    {"state": "ItemAntiHallucinogenMove", "state_id": 220, "event": "W_ItemPray_Upper"},
    {"state": "ItemPowderMedicineRecoverPoisonMove", "state_id": 221, "event": "W_LadderAttachBottom"},
    {"state": "DeflectGuardToStandMoveVariation", "state_id": 121, "event": "W_Move"},
    {"state": "ItemStoneMove", "state_id": 230, "event": "W_PartBlend_Add13"},
    {"state": "ItemPaperDollExchangeWhiteMove", "state_id": 240, "event": "W_PartBlend_Add14"},
    {"state": "SubWeaponExpand2Move", "state_id": 241, "event": "W_PartBlend_NoAdd6"},
    {"state": "SubWeaponExpand3Move", "state_id": 242, "event": "W_PartBlend_NoAdd5"},
    {"state": "GroundSubAttackHoldMove", "state_id": 250, "event": "W_WalkUpward"},
    {"state": "ItemOhagiMove", "state_id": 260, "event": "AttackBoundParry_Add02_to_AttackBoundParry_NoAdd"},
    {"state": "ItemKakiMove", "state_id": 261, "event": "AttackBoundParry_Add03_to_AttackBoundParry_NoAdd"},
    {"state": "ItemAntiGhostBuffMove", "state_id": 262, "event": "AttackBoundParry_Add04_to_AttackBoundParry_NoAdd"},
    {"state": "ItemPotteryMove", "state_id": 263, "event": "AttackWeakBound_Add04_to_AttackWeakBound_NoAdd"},
]


STANDMOVEABLEACTION_IDLE_STATE = "StandMoveableActionIdle"
STANDMOVEABLEACTION_ALL_STATE_NAMES = [rule["state"] for rule in STANDMOVEABLEACTION_SYNC_ENTRY_RULES]

STANDMOVEUPPER_IDLE_STATE = "StandMoveUpperIdle"
STANDMOVEUPPER_ALL_STATE_NAMES = [rule["state"] for rule in STANDMOVEUPPER_SYNC_ENTRY_RULES]


def expand_selector_transitions(
    idle_state: str,
    concrete_states: list[str],
    sync_rules: list[dict],
    variable_name: str,
) -> list[dict]:
    # Mirror HKX wildcard selector coverage while keeping a synthetic idle parking state in UE.
    transitions: list[dict] = []
    for from_state in [idle_state, *concrete_states]:
        for rule in sync_rules:
            if from_state == rule["state"]:
                continue

            transitions.append(
                {
                    "from": from_state,
                    "to": rule["state"],
                    "var": variable_name,
                    "compare_value": rule["state_id"],
                    "hkx_event": rule["event"],
                }
            )
    return transitions


def expand_return_to_idle_transitions(from_states: list[str], idle_state: str, variable_name: str) -> list[dict]:
    return [
        {
            "from": from_state,
            "to": idle_state,
            "var": variable_name,
        }
        for from_state in from_states
    ]


def expand_wildcard_transitions(from_states: list[str], transition_rules: list[dict]) -> list[dict]:
    transitions: list[dict] = []
    for from_state in from_states:
        for rule in transition_rules:
            transition = {
                "from": from_state,
                "to": rule["to"],
                "var": rule["var"],
            }
            if rule.get("compare_value") is not None:
                transition["compare_value"] = rule["compare_value"]
            if "hkx_event" in rule:
                transition["hkx_event"] = rule["hkx_event"]
            transitions.append(transition)
    return transitions


STANDMOVE_ALL_STATE_NAMES = [
    "StandMoveLoop",
    "StandMoveStart",
    "StandMoveStartFromFreeFall",
    "StandMoveStartFromFreeFallShortStiff",
    "StandMoveStartFromLandGroundPositioningJump",
    "StandWalkStop",
    "StandRunStop",
    "StandQuickTurnLeft180",
    "StandQuickTurnRight180",
    "StandQuickTurnMoveStartLeft180",
    "StandQuickTurnMoveStartRight180",
    "StandMoveQuickTurnLeft180",
    "StandMoveQuickTurnRight180",
    "StandQuickTurnLeft90",
    "StandQuickTurnRight90",
    "StandMoveStartFromSprint",
    "StandMoveLoopFromSprint",
]


STANDMOVE_WILDCARD_TRANSITION_RULES = [
    {"to": "StandMoveStartFromFreeFall", "var": "Req_Event26031_to_EventDummy", "hkx_event": "Event26031_to_EventDummy"},
    {"to": "StandMoveLoop", "var": "Req_Event26021_to_EventDummy", "hkx_event": "Event26021_to_EventDummy"},
    {"to": "StandMoveStartFromFreeFallShortStiff", "var": "Req_W_CoverEnd", "hkx_event": "W_CoverEnd"},
    {"to": "StandMoveStartFromLandGroundPositioningJump", "var": "Req_W_CoverIdle", "hkx_event": "W_CoverIdle"},
    {"to": "StandMoveStart", "var": "Req_W_Event3018", "hkx_event": "W_Event3018"},
    {"to": "StandWalkStop", "var": "Req_W_Event3026", "hkx_event": "W_Event3026"},
    {"to": "StandRunStop", "var": "Req_W_Event3027", "hkx_event": "W_Event3027"},
    {"to": "StandQuickTurnRight180", "var": "Req_W_Event3028", "hkx_event": "W_Event3028"},
    {"to": "StandQuickTurnLeft180", "var": "Req_W_Event3029", "hkx_event": "W_Event3029"},
    {"to": "StandQuickTurnMoveStartLeft180", "var": "Req_W_Event3042", "hkx_event": "W_Event3042"},
    {"to": "StandQuickTurnMoveStartRight180", "var": "Req_W_Event3043", "hkx_event": "W_Event3043"},
    {"to": "StandMoveQuickTurnLeft180", "var": "Req_W_Event3044", "hkx_event": "W_Event3044"},
    {"to": "StandMoveQuickTurnRight180", "var": "Req_W_Event3045", "hkx_event": "W_Event3045"},
    {"to": "StandQuickTurnLeft90", "var": "Req_W_Idle", "hkx_event": "W_Idle"},
    {"to": "StandQuickTurnRight90", "var": "Req_W_Idle_Short", "hkx_event": "W_Idle_Short"},
    {"to": "StandMoveStartFromSprint", "var": "Req_W_WideshotRightStart_mirror", "hkx_event": "W_WideshotRightStart_mirror"},
    {"to": "StandMoveLoopFromSprint", "var": "Req_a000_00000000_End", "hkx_event": "a000_00000000_End"},
]


STANDMOVE_LOCAL_TRANSITIONS = [
    {"from": "StandMoveStart", "to": "StandMoveLoop", "var": "Req_W_Event3019", "hkx_event": "W_Event3019"},
    {"from": "StandMoveStartFromFreeFall", "to": "StandMoveLoop", "var": "Req_Event26011_to_EventDummy", "hkx_event": "Event26011_to_EventDummy"},
    {"from": "StandMoveStartFromFreeFallShortStiff", "to": "StandMoveLoop", "var": "Req_W_CoverActionStart", "hkx_event": "W_CoverActionStart"},
    {"from": "StandMoveStartFromLandGroundPositioningJump", "to": "StandMoveLoop", "var": "Req_W_CoverLookThrowGrab", "hkx_event": "W_CoverLookThrowGrab"},
    {"from": "StandWalkStop", "to": "StandMoveLoop", "var": "Return_To_StandMove"},
    {"from": "StandRunStop", "to": "StandMoveLoop", "var": "Return_To_StandMove"},
    {"from": "StandQuickTurnLeft180", "to": "StandMoveLoop", "var": "Return_To_StandMove"},
    {"from": "StandQuickTurnRight180", "to": "StandMoveLoop", "var": "Return_To_StandMove"},
    {"from": "StandQuickTurnMoveStartLeft180", "to": "StandMoveLoop", "var": "Req_W_Event3038", "hkx_event": "W_Event3038"},
    {"from": "StandQuickTurnMoveStartRight180", "to": "StandMoveLoop", "var": "Req_W_Event3039", "hkx_event": "W_Event3039"},
    {"from": "StandMoveQuickTurnLeft180", "to": "StandMoveLoop", "var": "Req_W_Event3040", "hkx_event": "W_Event3040"},
    {"from": "StandMoveQuickTurnRight180", "to": "StandMoveLoop", "var": "Req_W_Event3041", "hkx_event": "W_Event3041"},
    {"from": "StandQuickTurnLeft90", "to": "StandMoveLoop", "var": "Return_To_StandMove"},
    {"from": "StandQuickTurnRight90", "to": "StandMoveLoop", "var": "Return_To_StandMove"},
    {"from": "StandMoveStartFromSprint", "to": "StandMoveLoop", "var": "Req_W_WideshotRightStart", "hkx_event": "W_WideshotRightStart"},
    {"from": "StandMoveLoopFromSprint", "to": "StandMoveLoop", "var": "Req_a000_00000001_End", "hkx_event": "a000_00000001_End"},
]


STANDMOVELOWER_ALL_STATE_NAMES = [
    "StandMoveLowerLoop",
    "StandMoveLowerStart",
]


STANDMOVELOWER_WILDCARD_TRANSITION_RULES = [
    {"to": "StandMoveLowerLoop", "var": "Req_W_Attack3051", "hkx_event": "W_Attack3051"},
    {"to": "StandMoveLowerStart", "var": "Req_W_AttackBoundParry_Add01", "hkx_event": "W_AttackBoundParry_Add01"},
]


STANDMOVELOWER_LOCAL_TRANSITIONS = [
    {"from": "StandMoveLowerStart", "to": "StandMoveLowerLoop", "var": "Req_W_AttackBoundGuard_Add04", "hkx_event": "W_AttackBoundGuard_Add04"},
]


MACHINE_SPECS = [
    {
        "parent_machine": TOP_LEVEL_MACHINE,
        "parent_state": "StandMove",
        "machine_name": "StandMove_SM",
        "position_x": 220,
        "position_y": 20,
        "connect_to_result": True,
        "states": [
            {"name": "StandMoveLoop", "anim": "/Game/Animation/Sekiro/C0000/StandMove_SM/a000_000200", "loop": True, "position_x": 200, "position_y": 0},
            {"name": "StandMoveStart", "anim": "/Game/Animation/Sekiro/C0000/StandMove_SM/a000_000100", "loop": False, "position_x": 640, "position_y": -220},
            {"name": "StandMoveStartFromFreeFall", "anim": "/Game/Animation/Sekiro/C0000/StandMove_SM/a000_000110", "loop": False, "position_x": 640, "position_y": -60},
            {"name": "StandMoveStartFromFreeFallShortStiff", "anim": "/Game/Animation/Sekiro/C0000/StandMove_SM/a000_000120", "loop": False, "position_x": 640, "position_y": 100},
            {"name": "StandMoveStartFromLandGroundPositioningJump", "anim": "/Game/Animation/Sekiro/C0000/StandMove_SM/a000_000110", "loop": False, "position_x": 640, "position_y": 740},
            {"name": "StandWalkStop", "anim": "/Game/Animation/Sekiro/C0000/StandMove_SM/a000_000300", "loop": False, "position_x": 640, "position_y": 260},
            {"name": "StandRunStop", "anim": "/Game/Animation/Sekiro/C0000/StandMove_SM/a000_000600", "loop": False, "position_x": 640, "position_y": 420},
            {"name": "StandQuickTurnLeft180", "anim": "/Game/Animation/Sekiro/C0000/StandMove_SM/a000_000012", "loop": False, "position_x": 1040, "position_y": -220},
            {"name": "StandQuickTurnRight180", "anim": "/Game/Animation/Sekiro/C0000/StandMove_SM/a000_000013", "loop": False, "position_x": 1040, "position_y": -60},
            {"name": "StandQuickTurnMoveStartLeft180", "anim": "/Game/Animation/Sekiro/C0000/StandMove_SM/a000_000132", "loop": False, "position_x": 1040, "position_y": 100},
            {"name": "StandQuickTurnMoveStartRight180", "anim": "/Game/Animation/Sekiro/C0000/StandMove_SM/a000_000133", "loop": False, "position_x": 1040, "position_y": 260},
            {"name": "StandMoveQuickTurnLeft180", "anim": "/Game/Animation/Sekiro/C0000/StandMove_SM/a000_000442", "loop": False, "position_x": 1040, "position_y": 420},
            {"name": "StandMoveQuickTurnRight180", "anim": "/Game/Animation/Sekiro/C0000/StandMove_SM/a000_000443", "loop": False, "position_x": 1040, "position_y": 580},
            {"name": "StandQuickTurnLeft90", "anim": "/Game/Animation/Sekiro/C0000/StandMove_SM/a000_000010", "loop": False, "position_x": 1460, "position_y": 100},
            {"name": "StandQuickTurnRight90", "anim": "/Game/Animation/Sekiro/C0000/StandMove_SM/a000_000011", "loop": False, "position_x": 1460, "position_y": 260},
            {"name": "StandMoveStartFromSprint", "anim": "/Game/Animation/Sekiro/C0000/StandMove_SM/a000_000450", "loop": False, "position_x": 1460, "position_y": 420},
            {"name": "StandMoveLoopFromSprint", "anim": "/Game/Animation/Sekiro/C0000/StandMove_SM/a000_000160", "loop": True, "position_x": 1860, "position_y": 420},
        ],
        "transitions": [
            *expand_wildcard_transitions(STANDMOVE_ALL_STATE_NAMES, STANDMOVE_WILDCARD_TRANSITION_RULES),
            *STANDMOVE_LOCAL_TRANSITIONS,
        ],
    },
    {
        "parent_machine": TOP_LEVEL_MACHINE,
        "parent_state": "StandMoveableAction",
        "machine_name": "StandMoveableAction_SM",
        "position_x": 220,
        "position_y": 20,
        "connect_to_result": True,
        "states": [
            {"name": "StandMoveableActionIdle", "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a000_259000", "loop": True, "position_x": 200, "position_y": 0},
            {"name": "ItemPillTonic", "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a000_250300", "loop": False, "position_x": 620, "position_y": -360},
            {"name": "DeflectGuardToStand", "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a050_203010", "loop": False, "position_x": 620, "position_y": -220},
            {"name": "DeflectGuardToStandVariation", "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a050_203015", "loop": False, "position_x": 620, "position_y": -80},
            {"name": "SubWeaponExpand", "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a070_412000", "loop": False, "position_x": 620, "position_y": 60},
            {"name": "SubWeaponExpand2", "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a070_412003", "loop": False, "position_x": 620, "position_y": 200},
            {"name": "SubWeaponExpand3", "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a070_412006", "loop": False, "position_x": 620, "position_y": 340},
            {"name": "GroundSubAttackCombo1Moveable", "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a079_400000", "loop": False, "position_x": 1040, "position_y": -360},
            {"name": "GroundSubAttackCombo1ReleaseMoveable", "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a079_400100", "loop": False, "position_x": 1040, "position_y": -220},
            {"name": "GroundSubAttackLockOnMoveable", "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a079_400600", "loop": False, "position_x": 1040, "position_y": -80},
            {"name": "GroundSubAttackLockOnReleaseMoveable", "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a079_400650", "loop": False, "position_x": 1040, "position_y": 60},
            {"name": "ItemFailed", "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a000_259000", "loop": False, "position_x": 2300, "position_y": -360},
            {"name": "ItemGourdDrink", "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a000_250000", "loop": False, "position_x": 1040, "position_y": 200},
            {"name": "ItemGourdDrinkRepeat", "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a000_250001", "loop": False, "position_x": 1040, "position_y": 340},
            {"name": "ItemGourdDrinkFailed", "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a000_250005", "loop": False, "position_x": 1460, "position_y": -360},
            {"name": "ItemGourdDrinkRepeatFailed", "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a000_250006", "loop": False, "position_x": 1460, "position_y": -220},
            {"name": "ItemAntiHallucinogen", "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a000_251800", "loop": False, "position_x": 1460, "position_y": -80},
            {"name": "ItemPowderMedicineRecoverPoison", "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a000_251600", "loop": False, "position_x": 2300, "position_y": -220},
            {"name": "ItemAntiGhostBuff", "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a000_251300", "loop": False, "position_x": 1460, "position_y": 60},
            {"name": "ItemStone", "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a000_251400", "loop": False, "position_x": 1460, "position_y": 200},
            {"name": "ItemPaperDollExchangeWhite", "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a000_250600", "loop": False, "position_x": 1460, "position_y": 340},
            {"name": "GroundSubAttackHoldLoop", "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a072_400300", "loop": True, "position_x": 2300, "position_y": -80},
            {"name": "ItemOhagi", "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a000_252000", "loop": False, "position_x": 1880, "position_y": -180},
            {"name": "ItemKaki", "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a000_252100", "loop": False, "position_x": 1880, "position_y": -20},
            {"name": "ItemPottery", "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a000_252200", "loop": False, "position_x": 1880, "position_y": 140},
        ],
        "transitions": [
            *expand_selector_transitions(
                STANDMOVEABLEACTION_IDLE_STATE,
                STANDMOVEABLEACTION_ALL_STATE_NAMES,
                STANDMOVEABLEACTION_SYNC_ENTRY_RULES,
                "StateStateId_StandMoveableAction",
            ),
            *expand_return_to_idle_transitions(
                STANDMOVEABLEACTION_ALL_STATE_NAMES,
                STANDMOVEABLEACTION_IDLE_STATE,
                "Return_To_StandMoveableAction_Idle",
            ),
        ],
    },
    {
        "parent_machine": TOP_LEVEL_MACHINE,
        "parent_state": "StandMoveOverwrite",
        "machine_name": "StandMoveLower_SM",
        "position_x": 120,
        "position_y": -120,
        "connect_to_result": False,
        "states": [
            {"name": "StandMoveLowerLoop", "anim": "/Game/Animation/Sekiro/C0000/StandMoveLower_SM/a000_000200", "loop": True, "position_x": 200, "position_y": 0},
            {"name": "StandMoveLowerStart", "anim": "/Game/Animation/Sekiro/C0000/StandMoveLower_SM/a000_000100", "loop": False, "position_x": 620, "position_y": 0},
        ],
        "transitions": [
            *expand_wildcard_transitions(STANDMOVELOWER_ALL_STATE_NAMES, STANDMOVELOWER_WILDCARD_TRANSITION_RULES),
            *STANDMOVELOWER_LOCAL_TRANSITIONS,
        ],
    },
    {
        "parent_machine": TOP_LEVEL_MACHINE,
        "parent_state": "StandMoveOverwrite",
        "machine_name": "StandMoveUpper_SM",
        "position_x": 520,
        "position_y": 180,
        "connect_to_result": False,
        "states": [
            {"name": "StandMoveUpperIdle", "anim": "/Game/Animation/Sekiro/C0000/StandMoveUpper_SM/a000_259000", "loop": True, "position_x": 200, "position_y": 0},
            {"name": "ItemPillTonicMove", "anim": "/Game/Animation/Sekiro/C0000/StandMoveUpper_SM/a000_250300", "loop": False, "position_x": 620, "position_y": -360},
            {"name": "DeflectGuardToStandMove", "anim": "/Game/Animation/Sekiro/C0000/StandMoveUpper_SM/a050_203011", "loop": False, "position_x": 620, "position_y": -220},
            {"name": "DeflectGuardToStandMoveVariation", "anim": "/Game/Animation/Sekiro/C0000/StandMoveUpper_SM/a050_203016", "loop": False, "position_x": 620, "position_y": -80},
            {"name": "SubWeaponExpandMove", "anim": "/Game/Animation/Sekiro/C0000/StandMoveUpper_SM/a070_412001", "loop": False, "position_x": 620, "position_y": 60},
            {"name": "SubWeaponExpand2Move", "anim": "/Game/Animation/Sekiro/C0000/StandMoveUpper_SM/a070_412004", "loop": False, "position_x": 620, "position_y": 200},
            {"name": "SubWeaponExpand3Move", "anim": "/Game/Animation/Sekiro/C0000/StandMoveUpper_SM/a070_412007", "loop": False, "position_x": 620, "position_y": 340},
            {"name": "GroundSubAttackCombo1Move", "anim": "/Game/Animation/Sekiro/C0000/StandMoveUpper_SM/a079_400000", "loop": False, "position_x": 2300, "position_y": -520},
            {"name": "GroundSubAttackCombo1ReleaseMove", "anim": "/Game/Animation/Sekiro/C0000/StandMoveUpper_SM/a079_400100", "loop": False, "position_x": 2300, "position_y": -360},
            {"name": "GroundSubAttackLockOnMove", "anim": "/Game/Animation/Sekiro/C0000/StandMoveUpper_SM/a079_400600", "loop": False, "position_x": 2300, "position_y": -200},
            {"name": "GroundSubAttackLockOnReleaseMove", "anim": "/Game/Animation/Sekiro/C0000/StandMoveUpper_SM/a079_400650", "loop": False, "position_x": 2300, "position_y": -40},
            {"name": "GroundSubAttackHoldMove", "anim": "/Game/Animation/Sekiro/C0000/StandMoveUpper_SM/a072_400300", "loop": True, "position_x": 1040, "position_y": -360},
            {"name": "ItemFailedMove", "anim": "/Game/Animation/Sekiro/C0000/StandMoveUpper_SM/a000_259000", "loop": False, "position_x": 2720, "position_y": -520},
            {"name": "ItemGourdDrinkMove", "anim": "/Game/Animation/Sekiro/C0000/StandMoveUpper_SM/a000_250000", "loop": False, "position_x": 1040, "position_y": -220},
            {"name": "ItemGourdDrinkRepeatMove", "anim": "/Game/Animation/Sekiro/C0000/StandMoveUpper_SM/a000_250001", "loop": False, "position_x": 1040, "position_y": -80},
            {"name": "ItemGourdDrinkFailedMove", "anim": "/Game/Animation/Sekiro/C0000/StandMoveUpper_SM/a000_250005", "loop": False, "position_x": 1040, "position_y": 60},
            {"name": "ItemGourdDrinkRepeatFailedMove", "anim": "/Game/Animation/Sekiro/C0000/StandMoveUpper_SM/a000_250006", "loop": False, "position_x": 1040, "position_y": 200},
            {"name": "ItemAntiHallucinogenMove", "anim": "/Game/Animation/Sekiro/C0000/StandMoveUpper_SM/a000_251800", "loop": False, "position_x": 1040, "position_y": 340},
            {"name": "ItemPowderMedicineRecoverPoisonMove", "anim": "/Game/Animation/Sekiro/C0000/StandMoveUpper_SM/a000_251600", "loop": False, "position_x": 2720, "position_y": -360},
            {"name": "ItemAntiGhostBuffMove", "anim": "/Game/Animation/Sekiro/C0000/StandMoveUpper_SM/a000_251300", "loop": False, "position_x": 1460, "position_y": -220},
            {"name": "ItemStoneMove", "anim": "/Game/Animation/Sekiro/C0000/StandMoveUpper_SM/a000_251400", "loop": False, "position_x": 1460, "position_y": -80},
            {"name": "ItemPaperDollExchangeWhiteMove", "anim": "/Game/Animation/Sekiro/C0000/StandMoveUpper_SM/a000_250600", "loop": False, "position_x": 1460, "position_y": 60},
            {"name": "ItemOhagiMove", "anim": "/Game/Animation/Sekiro/C0000/StandMoveUpper_SM/a000_252000", "loop": False, "position_x": 1460, "position_y": 200},
            {"name": "ItemKakiMove", "anim": "/Game/Animation/Sekiro/C0000/StandMoveUpper_SM/a000_252100", "loop": False, "position_x": 1460, "position_y": 340},
            {"name": "ItemPotteryMove", "anim": "/Game/Animation/Sekiro/C0000/StandMoveUpper_SM/a000_252200", "loop": False, "position_x": 1880, "position_y": 60},
        ],
        "transitions": [
            *expand_selector_transitions(
                STANDMOVEUPPER_IDLE_STATE,
                STANDMOVEUPPER_ALL_STATE_NAMES,
                STANDMOVEUPPER_SYNC_ENTRY_RULES,
                "StateStateId_StandMoveableAction",
            ),
            *expand_return_to_idle_transitions(
                STANDMOVEUPPER_ALL_STATE_NAMES,
                STANDMOVEUPPER_IDLE_STATE,
                "Return_To_StandMove",
            ),
        ],
    },
]


def main():
    client = MCPClient(MCP_URL)

    report = {
        "asset_path": ASSET_PATH,
        "skeleton_path": SKELETON_PATH,
        "variables": [],
        "machines": [],
        "notes": [
            "StandMoveOverwrite uses LayeredBoneBlend to stack StandMoveUpper_SM over StandMoveLower_SM.",
            f"Upper-body branch filtering starts at {OVERWRITE_LAYER_BONE} with depth {OVERWRITE_LAYER_DEPTH}.",
            "Representative animations are assigned for directional selector states where a full BlendSpace reconstruction is not yet authored.",
            "StandMoveUpper_SM and StandMoveableAction_SM keep a synthetic parking idle state in UE because the original HKX machines are wildcard-driven and have no explicit idle state.",
            "StateStateId_StandMoveableAction now drives both synthetic-idle entry and concrete-state selector transitions for StandMoveableAction_SM and StandMoveUpper_SM using HKX-internal stateId values.",
        ],
        "sync_state_rules": {
            "StandMoveableAction_SM": STANDMOVEABLEACTION_SYNC_ENTRY_RULES,
            "StandMoveUpper_SM": STANDMOVEUPPER_SYNC_ENTRY_RULES,
        },
    }

    ensure_call(
        client,
        "animation_query",
        "create_anim_blueprint",
        {
            "asset_path": ASSET_PATH,
            "skeleton_path": SKELETON_PATH,
            "parent_class": "AnimInstance",
        },
        ok_errors=("Asset already exists",),
    )

    for variable in VARIABLES:
        result = ensure_call(
            client,
            "blueprint_query",
            "add_variable",
            {"asset_path": ASSET_PATH, **variable},
            ok_errors=("already exists",),
        )
        report["variables"].append({"name": variable["name"], "result": result})

    top_level_machine = ensure_call(
        client,
        "animation_query",
        "create_state_machine",
        {
            "asset_path": ASSET_PATH,
            "graph_name": "AnimGraph",
            "machine_name": TOP_LEVEL_MACHINE,
            "position_x": 440,
            "position_y": 80,
        },
        ok_errors=("already exists",),
    )

    top_level_machine_node_id = top_level_machine.get("node_id") if isinstance(top_level_machine, dict) else None
    if not top_level_machine_node_id:
        top_level_machine_node_id = find_animgraph_node_id_by_title(client, ASSET_PATH, TOP_LEVEL_MACHINE)
    if top_level_machine_node_id:
        connect_to_result(client, ASSET_PATH, top_level_machine_node_id, "AnimGraph", None)

    for state in TOP_LEVEL_STATES:
        ensure_call(
            client,
            "animation_query",
            "add_state_to_machine",
            {
                "asset_path": ASSET_PATH,
                "machine_name": TOP_LEVEL_MACHINE,
                "state_name": state["name"],
                "position_x": state["position_x"],
                "position_y": state["position_y"],
            },
            ok_errors=("already exists",),
        )

    report["top_level_entry"] = ensure_machine_entry_connection(client, TOP_LEVEL_MACHINE, "StandMove")

    report["top_level_transitions"] = []
    for transition in TOP_LEVEL_TRANSITIONS:
        report["top_level_transitions"].append(
            ensure_machine_transition(
                client,
                TOP_LEVEL_MACHINE,
                transition["from"],
                transition["to"],
                transition["var"],
                transition.get("compare_value"),
            )
        )

    for machine_spec in MACHINE_SPECS:
        machine_result = ensure_call(
            client,
            "animation_query",
            "create_state_machine",
            {
                "asset_path": ASSET_PATH,
                "graph_name": machine_spec["parent_machine"],
                "state_name": machine_spec["parent_state"],
                "machine_name": machine_spec["machine_name"],
                "position_x": machine_spec["position_x"],
                "position_y": machine_spec["position_y"],
            },
            ok_errors=("already exists",),
        )

        node_id = machine_result.get("node_id") if isinstance(machine_result, dict) else None
        if machine_spec["connect_to_result"] and not node_id:
            node_id = find_nested_state_machine_node_id(
                client,
                ASSET_PATH,
                machine_spec["parent_state"],
                machine_spec["machine_name"],
            )
        if machine_spec["connect_to_result"] and node_id:
            connect_to_result(
                client,
                ASSET_PATH,
                node_id,
                machine_spec["parent_machine"],
                machine_spec["parent_state"],
            )

        for state in machine_spec["states"]:
            ensure_call(
                client,
                "animation_query",
                "add_state_to_machine",
                {
                    "asset_path": ASSET_PATH,
                    "machine_name": machine_spec["machine_name"],
                    "state_name": state["name"],
                    "position_x": state["position_x"],
                    "position_y": state["position_y"],
                },
                ok_errors=("already exists",),
            )
            ensure_call(
                client,
                "animation_query",
                "set_state_animation",
                {
                    "asset_path": ASSET_PATH,
                    "machine_name": machine_spec["machine_name"],
                    "state_name": state["name"],
                    "anim_asset_path": state["anim"],
                    "loop": state["loop"],
                    "clear_existing": True,
                },
            )

        transition_results = []
        for transition in machine_spec["transitions"]:
            transition_result = ensure_machine_transition(
                client,
                machine_spec["machine_name"],
                transition["from"],
                transition["to"],
                transition["var"],
                transition.get("compare_value"),
            )
            if "hkx_event" in transition:
                transition_result["hkx_event"] = transition["hkx_event"]
            transition_results.append(transition_result)

        report["machines"].append(
            {
                "machine_name": machine_spec["machine_name"],
                "parent_machine": machine_spec["parent_machine"],
                "parent_state": machine_spec["parent_state"],
                "connect_to_result": machine_spec["connect_to_result"],
                "state_count": len(machine_spec["states"]),
                "transition_count": len(machine_spec["transitions"]),
                "transition_results": transition_results,
            }
        )

    ensure_standmoveoverwrite_layered_output(client, report)

    compile_result = client.call(
        "blueprint_query",
        "compile_blueprint",
        {"asset_path": ASSET_PATH},
    )
    save_result = save_asset_with_fallback(client, ASSET_PATH)
    state_machine_result = client.call(
        "animation_query",
        "get_state_machines",
        {"asset_path": ASSET_PATH},
    )

    report["compile"] = compile_result
    report["compile_result"] = compile_result
    report["save"] = save_result
    report["state_machine_snapshot"] = state_machine_result
    report["validation"] = {
        "compile_success": compile_result.get("success"),
        "compile_status": compile_result.get("status"),
        "error_count": compile_result.get("error_count"),
        "warning_count": compile_result.get("warning_count"),
        "state_machine_count": state_machine_result.get("count"),
        "sync_entry_rules": {
            "StandMoveableAction_SM": summarize_sync_entry_rules(
                client,
                "StandMoveableAction_SM",
                "StandMoveableActionIdle",
                STANDMOVEABLEACTION_SYNC_ENTRY_RULES,
                "StateStateId_StandMoveableAction",
            ),
            "StandMoveUpper_SM": summarize_sync_entry_rules(
                client,
                "StandMoveUpper_SM",
                "StandMoveUpperIdle",
                STANDMOVEUPPER_SYNC_ENTRY_RULES,
                "StateStateId_StandMoveableAction",
            ),
        },
    }

    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")

    print(json.dumps(report, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    os.makedirs(REPORT_PATH.parent, exist_ok=True)
    main()
