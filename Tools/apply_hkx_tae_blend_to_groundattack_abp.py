import csv
import json
import urllib.error
import urllib.request
from pathlib import Path


MCP_URL = "http://127.0.0.1:9316/mcp"
ASSET_PATH = "/Game/Animation/Sekiro/C0000/Blueprints/ABP_Sekiro_C0000_SimpleMovement_MoveStartSubSM_HKXQuickTurnStart"
GROUND_ATTACK_MACHINE_PATH_MARKER = "GroundAttack_SM"
TAE_CSV_PATH = Path("docs/doc/TAE/AniEventAnalyze/sekiro_a50_combat_anievent.csv")
REPORT_PATH = Path("Saved/SekiroImportReports/groundattack_tae_blend_patch_report.json")


GROUND_ATTACK_STATE_ANIMS = {
    "GroundAttackCombo1": "a050_300000",
    "GroundAttackCombo1Release": "a050_300100",
    "GroundAttackCombo1Reverse": "a050_300001",
    "GroundAttackCombo1ReverseRelease": "a050_300101",
    "GroundAttackCombo2": "a050_300010",
    "GroundAttackCombo2Release": "a050_300110",
    "GroundAttackCombo2Reverse": "a050_300011",
    "GroundAttackCombo2ReverseRelease": "a050_300111",
    "GroundAttackCombo3": "a050_300020",
    "GroundAttackCombo4": "a050_300030",
    "GroundAttackCombo5": "a050_300040",
}


def call_mcp(tool_name: str, action: str, params: dict) -> dict:
    payload = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "tools/call",
        "params": {
            "name": tool_name,
            "arguments": {
                "action": action,
                "params": params,
            },
        },
    }
    data = json.dumps(payload).encode("utf-8")
    request = urllib.request.Request(
        MCP_URL,
        data=data,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            raw = json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        raise RuntimeError(exc.read().decode("utf-8", errors="replace")) from exc

    if "error" in raw:
        raise RuntimeError(raw["error"].get("message", json.dumps(raw["error"])))

    result = raw.get("result", {})
    content = result.get("content", [])
    text = content[0].get("text", "") if content else ""
    if result.get("isError"):
        raise RuntimeError(text)
    return json.loads(text) if text else {}


def read_tae16_blend_durations(csv_path: Path) -> dict[str, float]:
    durations: dict[str, float] = {}
    with csv_path.open("r", encoding="utf-8-sig", newline="") as handle:
        reader = csv.reader(handle)
        for row in reader:
            if len(row) < 10:
                continue
            anim_id = row[0].strip()
            event_type = row[8].strip()
            event_name = row[10].strip()
            if event_type != "16" or event_name != "Blend":
                continue
            try:
                start = float(row[5])
                end = float(row[6])
            except ValueError:
                continue
            if start <= 0.0001 and end > start:
                durations[anim_id] = end - start
    return durations


def main() -> None:
    tae16_durations = read_tae16_blend_durations(TAE_CSV_PATH)
    state_blend_durations = {
        state: tae16_durations[anim_id]
        for state, anim_id in GROUND_ATTACK_STATE_ANIMS.items()
        if anim_id in tae16_durations
    }

    ue_script = f"""
import json
import re
import unreal

asset_path = {json.dumps(ASSET_PATH)}
machine_marker = {json.dumps(GROUND_ATTACK_MACHINE_PATH_MARKER)}
state_blend_durations = json.loads(r'''{json.dumps(state_blend_durations, ensure_ascii=False)}''')

bp = unreal.load_asset(asset_path)
if not bp:
    raise RuntimeError("AnimBP not found: " + asset_path)

state_graphs = []
transition_nodes = []
for graph in bp.get_animation_graphs():
    path = graph.get_path_name()
    if machine_marker not in path:
        continue
    if path.endswith(".Transition"):
        node_path = path[:-len(".Transition")]
        node = unreal.find_object(None, node_path) or unreal.load_object(None, node_path)
        if node:
            transition_nodes.append((node_path, node))
    else:
        name = graph.get_name()
        if name in state_blend_durations:
            state_graphs.append((path, name))

# UE creates the nested GroundAttack transition graphs in the same order as
# the state entry graphs in this generated AnimBP.  Keep this script scoped to
# the known machine so it can be re-run safely after ABP regeneration.
results = []
for index, (state_path, state_name) in enumerate(state_graphs):
    if index >= len(transition_nodes):
        results.append({{
            "state": state_name,
            "state_path": state_path,
            "patched": False,
            "reason": "missing transition node at matching index",
        }})
        continue
    node_path, node = transition_nodes[index]
    blend_duration = float(state_blend_durations[state_name])
    before_duration = float(node.get_editor_property("crossfade_duration"))
    before_mode = str(node.get_editor_property("blend_mode"))
    before_logic = str(node.get_editor_property("logic_type"))
    node.set_editor_property("crossfade_duration", blend_duration)
    node.set_editor_property("blend_mode", unreal.AlphaBlendOption.LINEAR)
    node.set_editor_property("logic_type", unreal.TransitionLogicType.TLT_STANDARD_BLEND)
    results.append({{
        "state": state_name,
        "transition_node": node_path.split(".")[-1],
        "before_duration": before_duration,
        "after_duration": float(node.get_editor_property("crossfade_duration")),
        "before_blend_mode": before_mode,
        "after_blend_mode": str(node.get_editor_property("blend_mode")),
        "before_logic_type": before_logic,
        "after_logic_type": str(node.get_editor_property("logic_type")),
        "patched": True,
    }})

unreal.BlueprintEditorLibrary.compile_blueprint(bp)
unreal.EditorAssetLibrary.save_loaded_asset(bp)
print(json.dumps({{
    "asset_path": asset_path,
    "state_count": len(state_graphs),
    "transition_count": len(transition_nodes),
    "patched_count": sum(1 for item in results if item.get("patched")),
    "results": results,
}}, ensure_ascii=False, indent=2))
"""

    result = call_mcp("editor_query", "run_python", {"command": ue_script})
    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
