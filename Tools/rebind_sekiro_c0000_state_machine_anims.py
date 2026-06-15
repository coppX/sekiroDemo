import json
import sys
import traceback
from pathlib import Path


TOOL_DIR = Path(__file__).resolve().parent
if str(TOOL_DIR) not in sys.path:
    sys.path.append(str(TOOL_DIR))

import build_sekiro_master_subset_abp as build_spec
from sekiro_monolith_client import MCPClient


TARGET_MACHINES = {
    "StandMove_SM",
    "StandMoveLower_SM",
    "StandMoveUpper_SM",
    "StandMoveableAction_SM",
}

REPORT_PATH = TOOL_DIR.parent / "Saved" / "SekiroImportReports" / "c0000_state_anim_rebind_report.json"

STATE_ANIM_OVERRIDES = {
    ("StandMove_SM", "StandMoveStart"): "/Game/Animation/Sekiro/C0000/Blueprints/BS_StandMoveStart_Directional",
    ("StandMove_SM", "StandMoveStartFromFreeFall"): "/Game/Animation/Sekiro/C0000/Blueprints/BS_StandMoveStartFromFreeFall_Directional",
    ("StandMove_SM", "StandMoveStartFromFreeFallShortStiff"): "/Game/Animation/Sekiro/C0000/Blueprints/BS_StandMoveStartFromFreeFallShortStiff_Directional",
    ("StandMove_SM", "StandMoveStartFromLandGroundPositioningJump"): "/Game/Animation/Sekiro/C0000/Blueprints/BS_StandMoveStartFromFreeFall_Directional",
    ("StandMove_SM", "StandMoveLoop"): "/Game/Animation/Sekiro/C0000/Blueprints/BS_StandMoveLoop_Directional",
    ("StandMove_SM", "StandMoveLoopFromSprint"): "/Game/Animation/Sekiro/C0000/Blueprints/BS_StandMoveLoopFromSprint_Directional",
    ("StandMove_SM", "StandWalkStop"): "/Game/Animation/Sekiro/C0000/Blueprints/BS_StandWalkStop_Directional",
    ("StandMove_SM", "StandRunStop"): "/Game/Animation/Sekiro/C0000/Blueprints/BS_StandRunStop_Directional",
    ("StandMoveLower_SM", "StandMoveLowerStart"): "/Game/Animation/Sekiro/C0000/Blueprints/BS_StandMoveLowerStart_Directional",
    ("StandMoveLower_SM", "StandMoveLowerLoop"): "/Game/Animation/Sekiro/C0000/Blueprints/BS_StandMoveLowerLoop_Directional",
}


def write_report(report: dict) -> None:
    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")


def main() -> None:
    client = MCPClient()
    machine_specs = [
        spec
        for spec in build_spec.MACHINE_SPECS
        if spec["machine_name"] in TARGET_MACHINES
    ]

    report = {
        "asset_path": build_spec.ASSET_PATH,
        "target_machines": sorted(TARGET_MACHINES),
        "status": "running",
        "machines": [],
    }

    try:
        for machine_spec in machine_specs:
            machine_result = {
                "machine_name": machine_spec["machine_name"],
                "state_count": len(machine_spec["states"]),
                "states": [],
            }

            for state in machine_spec["states"]:
                override_path = STATE_ANIM_OVERRIDES.get((machine_spec["machine_name"], state["name"]))
                if override_path:
                    machine_result["states"].append(
                        {
                            "state_name": state["name"],
                            "anim_asset_path": override_path,
                            "loop": state["loop"],
                            "skipped": True,
                            "reason": "Owned by apply_sekiro_directional_locomotion.py",
                        }
                    )
                    continue

                anim_asset_path = state["anim"]
                result = client.call(
                    "animation_query",
                    "set_state_animation",
                    {
                        "asset_path": build_spec.ASSET_PATH,
                        "machine_name": machine_spec["machine_name"],
                        "state_name": state["name"],
                        "anim_asset_path": anim_asset_path,
                        "loop": state["loop"],
                        "clear_existing": True,
                    },
                )
                machine_result["states"].append(
                    {
                        "state_name": state["name"],
                        "anim_asset_path": anim_asset_path,
                        "loop": state["loop"],
                        "result": result,
                    }
                )

            report["machines"].append(machine_result)

        report["compile"] = client.call(
            "blueprint_query",
            "compile_blueprint",
            {"asset_path": build_spec.ASSET_PATH},
        )
        report["save"] = build_spec.save_asset_with_fallback(client, build_spec.ASSET_PATH)
        report["state_machine_snapshot"] = client.call(
            "animation_query",
            "get_state_machines",
            {"asset_path": build_spec.ASSET_PATH},
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
