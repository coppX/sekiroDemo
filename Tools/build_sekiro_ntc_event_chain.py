import json
import sys
import traceback
from pathlib import Path


TOOL_DIR = Path(__file__).resolve().parent
if str(TOOL_DIR) not in sys.path:
    sys.path.append(str(TOOL_DIR))

from sekiro_monolith_client import MCPClient, MCPError, ensure_call


ASSET_PATH = "/Game/Animation/Sekiro/C0000/Blueprints/ABP_Sekiro_C0000_SimpleMovement_MoveStartSubSM_HKXQuickTurnStart"
REPORT_PATH = TOOL_DIR.parent / "Saved" / "SekiroImportReports" / "c0000_ntc_event_chain_report.json"


def write_report(report: dict) -> None:
    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")


def call_ok(client: MCPClient, tool: str, action: str, params: dict, ok_errors: tuple[str, ...] = ()):
    return ensure_call(client, tool, action, params, ok_errors=ok_errors)


def main() -> None:
    client = MCPClient()
    report = {
        "asset_path": ASSET_PATH,
        "status": "running",
        "created_chain": [
            "Master_SM",
            "NTCEvent",
            "NTCEvent Script",
            "NTCEvent_SM",
            "GroundNonCombatAreaLeave",
            "GroundNonCombatAreaLeave_CMSG",
            "GroundNonCombatAreaEnter",
            "GroundNonCombatAreaEnter_CMSG",
        ],
        "steps": [],
    }

    try:
        # HKX mirror segment:
        # Master_SM -> NTCEvent -> NTCEvent_SM -> GroundNonCombatArea* -> *_CMSG.
        # The "Script" and "CMSG" names are represented by nested state-machine/player nodes
        # inside their parent states, because UE AnimGraph does not expose HKX script-generator
        # node classes directly.
        step = call_ok(
            client,
            "animation_query",
            "create_state_machine",
            {
                "asset_path": ASSET_PATH,
                "graph_name": "AnimGraph",
                "machine_name": "Master_SM",
                "position_x": 1800,
                "position_y": 360,
            },
            ok_errors=("already exists",),
        )
        report["steps"].append({"name": "create Master_SM", "result": step})

        step = call_ok(
            client,
            "animation_query",
            "add_state_to_machine",
            {
                "asset_path": ASSET_PATH,
                "machine_name": "Master_SM",
                "state_name": "NTCEvent",
                "position_x": 260,
                "position_y": 0,
            },
            ok_errors=("already exists",),
        )
        report["steps"].append({"name": "add NTCEvent state", "result": step})

        step = call_ok(
            client,
            "animation_query",
            "create_state_machine",
            {
                "asset_path": ASSET_PATH,
                "graph_name": "Master_SM",
                "state_name": "NTCEvent",
                "machine_name": "NTCEvent_SM",
                "position_x": 240,
                "position_y": 0,
            },
            ok_errors=("already exists",),
        )
        report["steps"].append({"name": "create NTCEvent_SM inside NTCEvent", "result": step})

        for state_name, anim_path, x, y in (
            ("GroundNonCombatAreaLeave", "/Game/Animation/Sekiro/C0000/StandMove_SM/a000_700510", 360, -120),
            ("GroundNonCombatAreaEnter", "/Game/Animation/Sekiro/C0000/StandMove_SM/a000_700500", 360, 120),
        ):
            step = call_ok(
                client,
                "animation_query",
                "add_state_to_machine",
                {
                    "asset_path": ASSET_PATH,
                    "machine_name": "NTCEvent_SM",
                    "state_name": state_name,
                    "position_x": x,
                    "position_y": y,
                },
                ok_errors=("already exists",),
            )
            report["steps"].append({"name": f"add {state_name} state", "result": step})

            step = call_ok(
                client,
                "animation_query",
                "set_state_animation",
                {
                    "asset_path": ASSET_PATH,
                    "machine_name": "NTCEvent_SM",
                    "state_name": state_name,
                    "anim_asset_path": anim_path,
                    "loop": False,
                    "clear_existing": True,
                },
            )
            report["steps"].append(
                {
                    "name": f"set {state_name}_CMSG animation",
                    "cmsg_node": f"{state_name}_CMSG",
                    "anim_asset_path": anim_path,
                    "result": step,
                }
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
        report["state_machines"] = call_ok(
            client,
            "animation_query",
            "get_state_machines",
            {"asset_path": ASSET_PATH},
        )
        report["status"] = "success"
        write_report(report)
    except Exception as exc:
        report["status"] = "failed"
        report["error"] = str(exc)
        report["traceback"] = traceback.format_exc()
        write_report(report)
        raise


if __name__ == "__main__":
    main()
