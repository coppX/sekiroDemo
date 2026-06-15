import json
import os
import sys
import traceback


TOOL_DIR = os.path.dirname(os.path.abspath(__file__))
if TOOL_DIR not in sys.path:
    sys.path.append(TOOL_DIR)

import unreal

import import_sekiro_c0000_motion_assets as base_import


PROJECT_ROOT = base_import.PROJECT_ROOT
IMPORT_ROOT = base_import.IMPORT_ROOT
SOURCE_DIR = (
    r"E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE"
    r"\exports\c0000_noncombat_weapon"
)
DESTINATION_PATH = f"{IMPORT_ROOT}/StandMove_SM"
REPORT_PATH = os.path.join(
    PROJECT_ROOT,
    "Saved",
    "SekiroImportReports",
    "c0000_noncombat_weapon_import_summary.json",
)
ANIM_FILES = [
    "a000_700500.fbx",
    "a000_700501.fbx",
    "a000_700510.fbx",
    "a000_700511.fbx",
]


def log(message: str) -> None:
    unreal.log(message)
    print(message)


def write_report(report: dict) -> None:
    os.makedirs(os.path.dirname(REPORT_PATH), exist_ok=True)
    with open(REPORT_PATH, "w", encoding="utf-8") as report_file:
        json.dump(report, report_file, ensure_ascii=False, indent=2)


def main() -> None:
    report = {
        "source_dir": SOURCE_DIR,
        "destination_path": DESTINATION_PATH,
        "status": "running",
        "source_files": [],
        "imported_anim_sequence_paths": [],
        "missing_source_files": [],
        "missing_assets": [],
    }

    try:
        skeleton = unreal.load_asset(
            "/Game/Animation/Sekiro/C0000/Base/c0000_bindpose_Skeleton.c0000_bindpose_Skeleton"
        )
        if not skeleton:
            raise RuntimeError("Base skeleton asset was not found.")

        base_import.ensure_directory(DESTINATION_PATH)
        options = base_import.create_animation_import_options(skeleton)

        tasks = []
        for file_name in ANIM_FILES:
            source_path = os.path.join(SOURCE_DIR, file_name)
            if not os.path.isfile(source_path):
                report["missing_source_files"].append(source_path)
                continue
            report["source_files"].append(source_path)
            tasks.append(base_import.create_import_task(source_path, DESTINATION_PATH, options))

        if report["missing_source_files"]:
            raise FileNotFoundError(
                "Missing non-combat weapon FBX files:\n"
                + "\n".join(report["missing_source_files"])
            )

        log(f"[SekiroNonCombatWeaponImport] Importing {len(tasks)} animation FBX files.")
        task_results = base_import.import_tasks(tasks)
        for imported_paths in task_results:
            for asset_path in imported_paths:
                asset = unreal.load_asset(asset_path)
                if asset and asset.get_class().get_name() == "AnimSequence":
                    report["imported_anim_sequence_paths"].append(asset_path)

        expected_names = {os.path.splitext(file_name)[0] for file_name in ANIM_FILES}
        directory_anim_paths = base_import.list_assets_by_class(DESTINATION_PATH, "AnimSequence")
        directory_anim_names = {
            base_import.asset_name_from_object_path(asset_path)
            for asset_path in directory_anim_paths
        }
        report["missing_assets"] = sorted(expected_names - directory_anim_names)
        report["directory_anim_sequence_paths"] = sorted(
            path
            for path in directory_anim_paths
            if base_import.asset_name_from_object_path(path) in expected_names
        )

        if report["missing_assets"]:
            raise RuntimeError(
                "Import completed but expected AnimSequence assets are missing: "
                + ", ".join(report["missing_assets"])
            )

        for asset_path in report["directory_anim_sequence_paths"]:
            unreal.EditorAssetLibrary.save_asset(asset_path, only_if_is_dirty=False)

        report["status"] = "success"
        write_report(report)
        log(f"[SekiroNonCombatWeaponImport] Import finished. Report: {REPORT_PATH}")
    except Exception as exc:
        report["status"] = "failed"
        report["error"] = str(exc)
        report["traceback"] = traceback.format_exc()
        write_report(report)
        unreal.log_error(report["traceback"])
        raise


if __name__ == "__main__":
    main()
