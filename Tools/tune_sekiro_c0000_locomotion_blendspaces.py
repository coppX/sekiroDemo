import json
import sys
from pathlib import Path


TOOL_DIR = Path(__file__).resolve().parent
if str(TOOL_DIR) not in sys.path:
    sys.path.append(str(TOOL_DIR))

from sekiro_monolith_client import MCPClient


PROJECT_ROOT = TOOL_DIR.parent
REPORT_PATH = PROJECT_ROOT / "Saved" / "SekiroImportReports" / "c0000_blendspace_tuning_report.json"

BLENDSPACE_SPECS = [
    {
        "asset_path": "/Game/Animation/Sekiro/C0000/Blueprints/BS_StandMoveStart_Directional",
        "target_weight_interpolation_speed_per_sec": 5.0,
    },
    {
        "asset_path": "/Game/Animation/Sekiro/C0000/Blueprints/BS_StandMoveStartFromFreeFall_Directional",
        "target_weight_interpolation_speed_per_sec": 5.0,
    },
    {
        "asset_path": "/Game/Animation/Sekiro/C0000/Blueprints/BS_StandMoveStartFromFreeFallShortStiff_Directional",
        "target_weight_interpolation_speed_per_sec": 5.0,
    },
    {
        "asset_path": "/Game/Animation/Sekiro/C0000/Blueprints/BS_StandMoveLoop_Directional",
        "target_weight_interpolation_speed_per_sec": 5.0,
    },
    {
        "asset_path": "/Game/Animation/Sekiro/C0000/Blueprints/BS_StandMoveLoopFromSprint_Directional",
        "target_weight_interpolation_speed_per_sec": 5.0,
    },
    {
        "asset_path": "/Game/Animation/Sekiro/C0000/Blueprints/BS_StandMoveLowerStart_Directional",
        "target_weight_interpolation_speed_per_sec": 5.0,
    },
    {
        "asset_path": "/Game/Animation/Sekiro/C0000/Blueprints/BS_StandMoveLowerLoop_Directional",
        "target_weight_interpolation_speed_per_sec": 5.0,
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


def tune_blendspace(client: MCPClient, spec: dict) -> dict:
    asset_path = spec["asset_path"]
    target_speed = spec["target_weight_interpolation_speed_per_sec"]

    command = f"""
import json
import unreal

asset_path = {json.dumps(asset_path, ensure_ascii=False)}
target_speed = {target_speed}
asset = unreal.load_asset(asset_path)
if not asset:
    raise RuntimeError(f"BlendSpace not found: {{asset_path}}")

before_value = float(asset.get_editor_property("target_weight_interpolation_speed_per_sec"))
asset.set_editor_property("target_weight_interpolation_speed_per_sec", target_speed)
after_value = float(asset.get_editor_property("target_weight_interpolation_speed_per_sec"))
saved = unreal.EditorAssetLibrary.save_loaded_asset(asset, only_if_is_dirty=False)

print(json.dumps({{
    "asset_path": asset_path,
    "before_value": before_value,
    "after_value": after_value,
    "saved": bool(saved),
}}, ensure_ascii=False))
"""
    return run_editor_python(client, command)


def main() -> None:
    client = MCPClient()
    report = {
        "status": "running",
        "assets": [],
    }

    try:
        for spec in BLENDSPACE_SPECS:
            report["assets"].append(tune_blendspace(client, spec))

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
