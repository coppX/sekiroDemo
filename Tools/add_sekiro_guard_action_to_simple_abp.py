import json
import sys
import traceback
from pathlib import Path


TOOL_DIR = Path(__file__).resolve().parent
if str(TOOL_DIR) not in sys.path:
    sys.path.append(str(TOOL_DIR))

from sekiro_monolith_client import MCPClient, ensure_call


ASSET_PATH = "/Game/Animation/Sekiro/C0000/Blueprints/ABP_Sekiro_C0000_SimpleMovement_MoveStartSubSM_HKXQuickTurnStart"
REPORT_PATH = TOOL_DIR.parent / "Saved" / "SekiroImportReports" / "c0000_guard_action_abp_report.json"


GUARD_VARIABLES = (
    "FSM_ActionDeflectGuardIdleActive",
    "FSM_ActionDeflectGuardMoveForwardActive",
    "FSM_ActionDeflectGuardMoveBackActive",
    "FSM_ActionDeflectGuardMoveLeftActive",
    "FSM_ActionDeflectGuardMoveRightActive",
    "FSM_ActionDeflectGuardToStandActive",
)

GUARD_STATES = (
    {
        "name": "DeflectGuardIdle",
        "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a050_002000",
        "loop": True,
        "x": 1776,
        "y": -224,
    },
    {
        "name": "DeflectGuardMoveForward",
        "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a050_002200",
        "loop": True,
        "x": 2128,
        "y": -448,
    },
    {
        "name": "DeflectGuardMoveBack",
        "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a050_002201",
        "loop": True,
        "x": 2128,
        "y": -224,
    },
    {
        "name": "DeflectGuardMoveLeft",
        "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a050_002202",
        "loop": True,
        "x": 2128,
        "y": 0,
    },
    {
        "name": "DeflectGuardMoveRight",
        "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a050_002203",
        "loop": True,
        "x": 2128,
        "y": 224,
    },
    {
        "name": "DeflectGuardToStand",
        "anim": "/Game/Animation/Sekiro/C0000/StandMoveableAction_SM/a050_203010",
        "loop": False,
        "x": 1776,
        "y": 16,
    },
)

GUARD_MOVE_STATES = (
    ("DeflectGuardMoveForward", "FSM_ActionDeflectGuardMoveForwardActive"),
    ("DeflectGuardMoveBack", "FSM_ActionDeflectGuardMoveBackActive"),
    ("DeflectGuardMoveLeft", "FSM_ActionDeflectGuardMoveLeftActive"),
    ("DeflectGuardMoveRight", "FSM_ActionDeflectGuardMoveRightActive"),
)

GUARD_TRANSITIONS = [
    ("ActionIdle", "DeflectGuardIdle", "FSM_ActionDeflectGuardIdleActive"),
    ("DeflectGuardIdle", "DeflectGuardToStand", "FSM_ActionDeflectGuardToStandActive"),
    ("DeflectGuardIdle", "ActionIdle", "FSM_ActionIdleActive"),
    ("DeflectGuardToStand", "ActionIdle", "FSM_ActionIdleActive"),
]

for move_state, move_variable in GUARD_MOVE_STATES:
    GUARD_TRANSITIONS.append(("ActionIdle", move_state, move_variable))
    GUARD_TRANSITIONS.append(("DeflectGuardIdle", move_state, move_variable))
    GUARD_TRANSITIONS.append((move_state, "DeflectGuardIdle", "FSM_ActionDeflectGuardIdleActive"))
    GUARD_TRANSITIONS.append((move_state, "DeflectGuardToStand", "FSM_ActionDeflectGuardToStandActive"))
    GUARD_TRANSITIONS.append((move_state, "ActionIdle", "FSM_ActionIdleActive"))

for from_state, _from_variable in GUARD_MOVE_STATES:
    for to_state, to_variable in GUARD_MOVE_STATES:
        if from_state != to_state:
            GUARD_TRANSITIONS.append((from_state, to_state, to_variable))


def call_ok(client: MCPClient, tool: str, action: str, params: dict, ok_errors: tuple[str, ...] = ()):
    return ensure_call(client, tool, action, params, ok_errors=ok_errors)


def main() -> None:
    client = MCPClient()
    report = {
        "asset_path": ASSET_PATH,
        "status": "running",
        "steps": [],
    }

    try:
        for variable_name in GUARD_VARIABLES:
            result = call_ok(
                client,
                "blueprint_query",
                "add_variable",
                {
                    "asset_path": ASSET_PATH,
                    "name": variable_name,
                    "type": "bool",
                    "default_value": "false",
                    "category": "Sekiro|FSM",
                    "instance_editable": False,
                },
                ok_errors=("already exists",),
            )
            report["steps"].append({"name": f"add variable {variable_name}", "result": result})

        for state in GUARD_STATES:
            result = call_ok(
                client,
                "animation_query",
                "add_state_to_machine",
                {
                    "asset_path": ASSET_PATH,
                    "machine_name": "Action_SM",
                    "state_name": state["name"],
                    "position_x": state["x"],
                    "position_y": state["y"],
                },
                ok_errors=("already exists",),
            )
            report["steps"].append({"name": f"add state {state['name']}", "result": result})

            result = call_ok(
                client,
                "animation_query",
                "set_state_animation",
                {
                    "asset_path": ASSET_PATH,
                    "machine_name": "Action_SM",
                    "state_name": state["name"],
                    "anim_asset_path": state["anim"],
                    "loop": state["loop"],
                    "clear_existing": True,
                },
            )
            report["steps"].append({"name": f"set animation {state['name']}", "result": result})

        for from_state, to_state, variable_name in GUARD_TRANSITIONS:
            result = call_ok(
                client,
                "animation_query",
                "add_transition",
                {
                    "asset_path": ASSET_PATH,
                    "machine_name": "Action_SM",
                    "from_state": from_state,
                    "to_state": to_state,
                },
                ok_errors=("already be connected", "already exists"),
            )
            report["steps"].append({"name": f"add transition {from_state}->{to_state}", "result": result})

            result = call_ok(
                client,
                "animation_query",
                "set_transition_rule",
                {
                    "asset_path": ASSET_PATH,
                    "machine_name": "Action_SM",
                    "from_state": from_state,
                    "to_state": to_state,
                    "variable_name": variable_name,
                },
            )
            report["steps"].append({"name": f"set rule {from_state}->{to_state}", "result": result})

        for from_state, to_state, _variable_name in GUARD_TRANSITIONS:
            result = call_ok(
                client,
                "animation_query",
                "set_anim_graph_node_property",
                {
                    "asset_path": ASSET_PATH,
                    "node_id": "Action_SM",
                    "property_path": "__RemoveEmptyDuplicateTransition",
                    "value": f"{from_state}|{to_state}",
                },
            )
            report["steps"].append({"name": f"dedupe transition {from_state}->{to_state}", "result": result})

        report["compile"] = call_ok(
            client,
            "blueprint_query",
            "compile_blueprint",
            {"asset_path": ASSET_PATH},
        )
        report["save"] = call_ok(
            client,
            "blueprint_query",
            "save_asset",
            {"asset_path": ASSET_PATH},
        )
        report["state_machines"] = call_ok(
            client,
            "animation_query",
            "get_state_machines",
            {"asset_path": ASSET_PATH},
        )
        report["status"] = "success"
        REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
        REPORT_PATH.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
        print(json.dumps(report, ensure_ascii=False, indent=2))
    except Exception as exc:
        report["status"] = "failed"
        report["error"] = str(exc)
        report["traceback"] = traceback.format_exc()
        REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
        REPORT_PATH.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
        raise


if __name__ == "__main__":
    main()
