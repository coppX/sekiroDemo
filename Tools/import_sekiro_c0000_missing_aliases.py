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
EXPORT_ROOT = base_import.EXPORT_ROOT
IMPORT_ROOT = base_import.IMPORT_ROOT
REPORT_PATH = os.path.join(
    PROJECT_ROOT,
    "Saved",
    "SekiroImportReports",
    "c0000_missing_alias_import_summary.json",
)

ALIAS_BATCHES = [
    {
        "name": "StandMove_SM_Aliases",
        "destination_path": f"{IMPORT_ROOT}/StandMove_SM",
        "source_dir": os.path.join(EXPORT_ROOT, "alias_probe_11"),
        "files": [
            "a000_000160.fbx",
            "a000_000161.fbx",
            "a000_000162.fbx",
            "a000_000163.fbx",
            "a000_000450.fbx",
            "a000_000460.fbx",
            "a000_000461.fbx",
            "a000_000462.fbx",
            "a000_000463.fbx",
        ],
    },
    {
        "name": "StandMoveUpper_SM_Aliases",
        "destination_path": f"{IMPORT_ROOT}/StandMoveUpper_SM",
        "source_dir": os.path.join(EXPORT_ROOT, "alias_probe_11"),
        "files": [
            "a000_252100.fbx",
            "a000_252200.fbx",
        ],
    },
    {
        "name": "StandMoveableAction_SM_Aliases",
        "destination_path": f"{IMPORT_ROOT}/StandMoveableAction_SM",
        "source_dir": os.path.join(EXPORT_ROOT, "alias_probe_11"),
        "files": [
            "a000_252100.fbx",
            "a000_252200.fbx",
        ],
    },
]


def log(message: str) -> None:
    unreal.log(message)
    print(message)


def ensure_source_files(batch: dict) -> list[str]:
    source_dir = batch["source_dir"]
    files = []
    missing = []

    for file_name in batch["files"]:
        file_path = os.path.join(source_dir, file_name)
        if not os.path.isfile(file_path):
            missing.append(file_path)
            continue
        files.append(file_path)

    if missing:
        raise FileNotFoundError(
            "Missing alias FBX files:\n" + "\n".join(missing)
        )

    return files


def import_alias_batch(batch: dict, skeleton: unreal.Skeleton) -> dict:
    destination_path = batch["destination_path"]
    base_import.ensure_directory(destination_path)

    fbx_files = ensure_source_files(batch)
    log(f"[SekiroAliasImport] {batch['name']}: preparing {len(fbx_files)} FBX files.")

    tasks = []
    for fbx_file in fbx_files:
        tasks.append(
            base_import.create_import_task(
                fbx_file,
                destination_path,
                base_import.create_animation_import_options(skeleton),
            )
        )

    task_results = base_import.import_tasks(tasks)
    imported_asset_paths = []
    for imported_paths in task_results:
        for asset_path in imported_paths:
            asset = unreal.load_asset(asset_path)
            if asset and asset.get_class().get_name() == "AnimSequence":
                imported_asset_paths.append(asset_path)

    imported_asset_paths = sorted(set(imported_asset_paths))
    directory_anim_assets = base_import.list_assets_by_class(destination_path, "AnimSequence")
    directory_anim_names = {
        base_import.asset_name_from_object_path(asset_path)
        for asset_path in directory_anim_assets
    }
    expected_asset_names = {
        os.path.splitext(os.path.basename(fbx_file))[0]
        for fbx_file in fbx_files
    }
    missing_assets = sorted(expected_asset_names - directory_anim_names)

    return {
        "name": batch["name"],
        "destination_path": destination_path,
        "source_dir": batch["source_dir"],
        "source_fbx_files": [os.path.basename(path) for path in fbx_files],
        "imported_anim_sequence_paths": imported_asset_paths,
        "directory_anim_sequence_paths": directory_anim_assets,
        "missing_anim_assets": missing_assets,
    }


def write_report(report: dict) -> None:
    os.makedirs(os.path.dirname(REPORT_PATH), exist_ok=True)
    with open(REPORT_PATH, "w", encoding="utf-8") as report_file:
        json.dump(report, report_file, ensure_ascii=False, indent=2)


def main() -> None:
    report = {
        "project_root": PROJECT_ROOT,
        "export_root": EXPORT_ROOT,
        "report_path": REPORT_PATH,
        "status": "running",
        "batches": [],
    }

    try:
        log("[SekiroAliasImport] Import started.")

        skeleton = unreal.load_asset(
            "/Game/Animation/Sekiro/C0000/Base/c0000_bindpose_Skeleton.c0000_bindpose_Skeleton"
        )
        if not skeleton:
            raise RuntimeError("Base skeleton asset was not found.")

        for batch in ALIAS_BATCHES:
            batch_result = import_alias_batch(batch, skeleton)
            report["batches"].append(batch_result)
            log(
                f"[SekiroAliasImport] {batch_result['name']}: "
                f"{len(batch_result['imported_anim_sequence_paths'])} imported, "
                f"{len(batch_result['missing_anim_assets'])} missing after import."
            )

        report["status"] = "success"
        write_report(report)
        log(f"[SekiroAliasImport] Import finished successfully. Report: {REPORT_PATH}")
    except Exception as exc:
        report["status"] = "failed"
        report["error"] = str(exc)
        report["traceback"] = traceback.format_exc()
        write_report(report)
        unreal.log_error(report["traceback"])
        raise


if __name__ == "__main__":
    main()
