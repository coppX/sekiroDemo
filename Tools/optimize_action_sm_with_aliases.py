import json
import sys
import traceback
from pathlib import Path


TOOL_DIR = Path(__file__).resolve().parent
if str(TOOL_DIR) not in sys.path:
    sys.path.append(str(TOOL_DIR))

from sekiro_monolith_client import MCPClient, ensure_call


ASSET_PATH = "/Game/Animation/Sekiro/C0000/Blueprints/ABP_Sekiro_C0000_SimpleMovement_MoveStartSubSM_HKXQuickTurnStart"
MACHINE_NAME = "Action_SM"
REPORT_PATH = TOOL_DIR.parent / "Saved" / "SekiroImportReports" / "action_sm_alias_cleanup_report.json"


NORMAL_ACTION_STATES = (
    "ActionItemGourdDrinkIdle",
    "ActionItemGourdDrinkMove",
    "ActionSubWeaponExpandIdle",
    "ActionSubWeaponExpandMove",
    "ActionLeftWaistDrawIdle",
    "ActionLeftWaistDrawMove",
    "ActionLeftWaistSheatheIdle",
    "ActionLeftWaistSheatheMove",
)

GUARD_MOVE_STATES = (
    ("DeflectGuardMoveForward", "FSM_ActionDeflectGuardMoveForwardActive"),
    ("DeflectGuardMoveBack", "FSM_ActionDeflectGuardMoveBackActive"),
    ("DeflectGuardMoveLeft", "FSM_ActionDeflectGuardMoveLeftActive"),
    ("DeflectGuardMoveRight", "FSM_ActionDeflectGuardMoveRightActive"),
)

GUARD_STATES = (
    "DeflectGuardIdle",
    "DeflectGuardToStand",
    "DeflectGuardMoveForward",
    "DeflectGuardMoveBack",
    "DeflectGuardMoveLeft",
    "DeflectGuardMoveRight",
)

RETIRED_GUARD_MOVE_ALIASES = tuple(
    f"Alias_GuardMoveExcept_{state_name}"
    for state_name, _variable_name in GUARD_MOVE_STATES
)


def call_ok(client: MCPClient, tool: str, action: str, params: dict, ok_errors: tuple[str, ...] = ()):
    return ensure_call(client, tool, action, params, ok_errors=ok_errors)


def add_alias(client: MCPClient, name: str, states: tuple[str, ...], x: int, y: int):
    value = f"{name}|{','.join(states)}|{x}|{y}|false"
    return call_ok(
        client,
        "animation_query",
        "set_anim_graph_node_property",
        {
            "asset_path": ASSET_PATH,
            "node_id": MACHINE_NAME,
            "property_path": "__AddStateAlias",
            "value": value,
        },
    )


def add_alias_transition(client: MCPClient, from_name: str, to_name: str, variable_name: str):
    add_result = call_ok(
        client,
        "animation_query",
        "set_anim_graph_node_property",
        {
            "asset_path": ASSET_PATH,
            "node_id": MACHINE_NAME,
            "property_path": "__AddTransitionByName",
            "value": f"{from_name}|{to_name}",
        },
    )
    rule_result = call_ok(
        client,
        "animation_query",
        "set_transition_rule",
        {
            "asset_path": ASSET_PATH,
            "machine_name": MACHINE_NAME,
            "from_state": from_name,
            "to_state": to_name,
            "variable_name": variable_name,
        },
    )
    return {"add": add_result, "rule": rule_result}


def remove_transition(client: MCPClient, from_name: str, to_name: str):
    return call_ok(
        client,
        "animation_query",
        "set_anim_graph_node_property",
        {
            "asset_path": ASSET_PATH,
            "node_id": MACHINE_NAME,
            "property_path": "__RemoveTransitionByName",
            "value": f"{from_name}|{to_name}",
        },
    )


def remove_empty_duplicate_transition(client: MCPClient, from_name: str, to_name: str):
    return call_ok(
        client,
        "animation_query",
        "set_anim_graph_node_property",
        {
            "asset_path": ASSET_PATH,
            "node_id": MACHINE_NAME,
            "property_path": "__RemoveEmptyDuplicateTransition",
            "value": f"{from_name}|{to_name}",
        },
    )


def remove_alias(client: MCPClient, name: str):
    return call_ok(
        client,
        "animation_query",
        "set_anim_graph_node_property",
        {
            "asset_path": ASSET_PATH,
            "node_id": MACHINE_NAME,
            "property_path": "__RemoveStateAlias",
            "value": name,
        },
        ok_errors=(
            "Node 'Action_SM' not found",
            "Node not found",
            "Failed to set property",
            "Property",
        ),
    )


def main() -> None:
    client = MCPClient()
    report = {
        "asset_path": ASSET_PATH,
        "machine_name": MACHINE_NAME,
        "status": "running",
        "aliases": [],
        "alias_transitions": [],
        "removed_transitions": [],
    }

    try:
        all_non_idle = NORMAL_ACTION_STATES + GUARD_STATES
        guard_moves = tuple(state for state, _variable in GUARD_MOVE_STATES)
        guard_active = ("DeflectGuardIdle",) + guard_moves
        guard_standby = ("ActionIdle", "DeflectGuardIdle")
        guard_move_sources = ("ActionIdle", "DeflectGuardIdle") + guard_moves

        aliases = [
            ("Alias_ActionNonIdle", all_non_idle, 2560, -720),
            ("Alias_DeflectGuardActive", guard_active, 2560, -480),
            ("Alias_DeflectGuardMove", guard_moves, 2560, -240),
            ("Alias_ActionGuardStandby", guard_standby, 2560, 0),
            ("Alias_GuardMoveInput", guard_move_sources, 2560, 240),
        ]
        retired_aliases = []
        for target_state, _variable_name in GUARD_MOVE_STATES:
            except_states = tuple(state for state in guard_moves if state != target_state)
            retired_aliases.append((f"Alias_GuardMoveExcept_{target_state}", except_states, 4200, 224 + len(retired_aliases) * 160))

        for name, states, x, y in aliases:
            report["aliases"].append({
                "name": name,
                "states": list(states),
                "result": add_alias(client, name, states, x, y),
            })
        report["retired_aliases"] = []
        for name, states, x, y in retired_aliases:
            remove_result = remove_alias(client, name)
            entry = {
                "name": name,
                "remove_result": remove_result,
            }
            if remove_result.get("skipped"):
                entry["park_result"] = add_alias(client, name, states, x, y)
            report["retired_aliases"].append({
                **entry,
            })

        desired_transitions = [
            ("Alias_ActionNonIdle", "ActionIdle", "FSM_ActionIdleActive"),
            ("Alias_DeflectGuardActive", "DeflectGuardToStand", "FSM_ActionDeflectGuardToStandActive"),
            ("Alias_DeflectGuardMove", "DeflectGuardIdle", "FSM_ActionDeflectGuardIdleActive"),
        ]
        for target_state, variable_name in GUARD_MOVE_STATES:
            desired_transitions.append(("Alias_GuardMoveInput", target_state, variable_name))

        for from_name, to_name, variable_name in desired_transitions:
            report["alias_transitions"].append({
                "from": from_name,
                "to": to_name,
                "variable": variable_name,
                "result": add_alias_transition(client, from_name, to_name, variable_name),
            })
        report["deduped_transitions"] = []
        for from_name, to_name, _variable_name in desired_transitions:
            report["deduped_transitions"].append({
                "from": from_name,
                "to": to_name,
                "result": remove_empty_duplicate_transition(client, from_name, to_name),
            })

        obsolete_transitions = []
        for state_name in all_non_idle:
            obsolete_transitions.append((state_name, "ActionIdle"))

        obsolete_transitions.append(("DeflectGuardIdle", "DeflectGuardToStand"))
        for move_state, _variable_name in GUARD_MOVE_STATES:
            obsolete_transitions.append((move_state, "DeflectGuardIdle"))
            obsolete_transitions.append((move_state, "DeflectGuardToStand"))
            obsolete_transitions.append(("ActionIdle", move_state))
            obsolete_transitions.append(("DeflectGuardIdle", move_state))
            obsolete_transitions.append(("Alias_ActionGuardStandby", move_state))
            obsolete_transitions.append((f"Alias_GuardMoveExcept_{move_state}", move_state))

        for from_state, _from_variable in GUARD_MOVE_STATES:
            for to_state, _to_variable in GUARD_MOVE_STATES:
                if from_state != to_state:
                    obsolete_transitions.append((from_state, to_state))

        seen = set()
        for from_name, to_name in obsolete_transitions:
            key = (from_name, to_name)
            if key in seen:
                continue
            seen.add(key)
            report["removed_transitions"].append({
                "from": from_name,
                "to": to_name,
                "result": remove_transition(client, from_name, to_name),
            })

        report["state_machines"] = call_ok(
            client,
            "animation_query",
            "get_state_machines",
            {"asset_path": ASSET_PATH},
        )
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
        report["status"] = "success"
    except Exception as exc:
        report["status"] = "failed"
        report["error"] = str(exc)
        report["traceback"] = traceback.format_exc()
        raise
    finally:
        REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
        REPORT_PATH.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
        print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
