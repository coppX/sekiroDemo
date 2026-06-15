import json
import os
import traceback
from collections import Counter

import unreal


PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
EXPORT_ROOT = r"E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE\exports"
IMPORT_ROOT = "/Game/Animation/Sekiro/C0000"
REPORT_PATH = os.path.join(PROJECT_ROOT, "Saved", "SekiroImportReports", "c0000_motion_import_summary.json")

BINDPOSE_SOURCE = os.path.join(EXPORT_ROOT, "c0000_shared_bindpose", "c0000_bindpose.fbx")
BASE_DESTINATION = f"{IMPORT_ROOT}/Base"

ANIMATION_BATCHES = [
    {
        "name": "StandMoveLower_SM",
        "source_dir": os.path.join(EXPORT_ROOT, "c0000_StandMoveLower_SM_all"),
        "destination_path": f"{IMPORT_ROOT}/StandMoveLower_SM",
    },
    {
        "name": "StandMoveUpper_SM",
        "source_dir": os.path.join(EXPORT_ROOT, "c0000_StandMoveUpper_SM_all"),
        "destination_path": f"{IMPORT_ROOT}/StandMoveUpper_SM",
    },
    {
        "name": "StandMoveableAction_SM",
        "source_dir": os.path.join(EXPORT_ROOT, "c0000_StandMoveableAction_SM_all"),
        "destination_path": f"{IMPORT_ROOT}/StandMoveableAction_SM",
    },
    {
        "name": "StandMove_SM",
        "source_dir": os.path.join(EXPORT_ROOT, "c0000_StandMove_SM_all"),
        "destination_path": f"{IMPORT_ROOT}/StandMove_SM",
    },
    {
        "name": "NewThrowAtk_SM",
        "source_dir": os.path.join(EXPORT_ROOT, "c0000_NewThrowAtk_SM"),
        "destination_path": f"{IMPORT_ROOT}/NewThrowAtk_SM",
    },
    {
        "name": "NewThrowKill_SM",
        "source_dir": os.path.join(EXPORT_ROOT, "c0000_NewThrowKill_SM"),
        "destination_path": f"{IMPORT_ROOT}/NewThrowKill_SM",
    },
]


def log(message: str) -> None:
    unreal.log(message)
    print(message)


def ensure_directory(asset_path: str) -> None:
    if unreal.EditorAssetLibrary.does_directory_exist(asset_path):
        return
    if not unreal.EditorAssetLibrary.make_directory(asset_path):
        raise RuntimeError(f"Failed to create directory: {asset_path}")


def list_assets_by_class(asset_path: str, class_name: str) -> list[str]:
    assets = unreal.EditorAssetLibrary.list_assets(asset_path, recursive=True, include_folder=False)
    matches: list[str] = []
    for asset_path_name in assets:
        asset = unreal.load_asset(asset_path_name)
        if not asset:
            continue
        if asset.get_class().get_name() == class_name:
            matches.append(asset_path_name)
    return sorted(matches)


def list_assets_with_classes(asset_path: str) -> list[dict]:
    assets = unreal.EditorAssetLibrary.list_assets(asset_path, recursive=True, include_folder=False)
    matches = []
    for asset_path_name in assets:
        asset = unreal.load_asset(asset_path_name)
        if not asset:
            continue
        matches.append(
            {
                "path": asset_path_name,
                "class_name": asset.get_class().get_name(),
            }
        )
    matches.sort(key=lambda item: item["path"])
    return matches


def asset_name_from_object_path(asset_path: str) -> str:
    asset_name = asset_path.rsplit("/", 1)[-1]
    if "." in asset_name:
        asset_name = asset_name.split(".", 1)[0]
    return asset_name


def create_import_task(filename: str, destination_path: str, options: unreal.FbxImportUI) -> unreal.AssetImportTask:
    task = unreal.AssetImportTask()
    task.set_editor_property("filename", filename)
    task.set_editor_property("destination_path", destination_path)
    task.set_editor_property("automated", True)
    task.set_editor_property("replace_existing", True)
    task.set_editor_property("replace_existing_settings", True)
    task.set_editor_property("save", True)
    task.set_editor_property("options", options)
    return task


def create_bindpose_import_options() -> unreal.FbxImportUI:
    options = unreal.FbxImportUI()
    options.set_editor_property("automated_import_should_detect_type", False)
    options.set_editor_property("original_import_type", unreal.FBXImportType.FBXIT_SKELETAL_MESH)
    options.set_editor_property("mesh_type_to_import", unreal.FBXImportType.FBXIT_SKELETAL_MESH)
    options.set_editor_property("import_as_skeletal", True)
    options.set_editor_property("import_mesh", True)
    options.set_editor_property("import_animations", False)
    options.set_editor_property("create_physics_asset", True)
    options.set_editor_property("import_materials", True)
    options.set_editor_property("import_textures", True)

    skeletal_mesh_data = options.get_editor_property("skeletal_mesh_import_data")
    skeletal_mesh_data.set_editor_property("convert_scene", True)
    skeletal_mesh_data.set_editor_property("convert_scene_unit", True)
    skeletal_mesh_data.set_editor_property("preserve_smoothing_groups", True)
    skeletal_mesh_data.set_editor_property(
        "normal_import_method",
        unreal.FBXNormalImportMethod.FBXNIM_IMPORT_NORMALS_AND_TANGENTS,
    )
    return options


def create_animation_import_options(skeleton: unreal.Skeleton) -> unreal.FbxImportUI:
    options = unreal.FbxImportUI()
    options.set_editor_property("automated_import_should_detect_type", False)
    options.set_editor_property("original_import_type", unreal.FBXImportType.FBXIT_ANIMATION)
    options.set_editor_property("mesh_type_to_import", unreal.FBXImportType.FBXIT_ANIMATION)
    options.set_editor_property("import_as_skeletal", True)
    options.set_editor_property("import_mesh", False)
    options.set_editor_property("import_animations", True)
    options.set_editor_property("import_materials", False)
    options.set_editor_property("import_textures", False)
    options.set_editor_property("skeleton", skeleton)

    animation_data = options.get_editor_property("anim_sequence_import_data")
    animation_data.set_editor_property(
        "animation_length",
        unreal.FBXAnimationLengthImportType.FBXALIT_EXPORTED_TIME,
    )
    animation_data.set_editor_property("import_bone_tracks", True)
    animation_data.set_editor_property("remove_redundant_keys", False)
    return options


def import_tasks(tasks: list[unreal.AssetImportTask]) -> list[list[str]]:
    unreal.AssetToolsHelpers.get_asset_tools().import_asset_tasks(tasks)
    task_results: list[list[str]] = []
    for task in tasks:
        imported_object_paths = [str(path) for path in task.get_editor_property("imported_object_paths")]
        task_results.append(imported_object_paths)
    return task_results


def find_first_asset(asset_paths: list[str], class_name: str):
    for asset_path in asset_paths:
        asset = unreal.load_asset(asset_path)
        if not asset:
            continue
        if asset.get_class().get_name() == class_name:
            return asset_path, asset
    return None, None


def fallback_find_asset(directory: str, class_name: str):
    for asset_path in list_assets_by_class(directory, class_name):
        asset = unreal.load_asset(asset_path)
        if asset:
            return asset_path, asset
    return None, None


def collect_fbx_files(source_dir: str) -> list[str]:
    files = []
    for entry in sorted(os.listdir(source_dir)):
        if not entry.lower().endswith(".fbx"):
            continue
        if entry.lower() == "c0000_bindpose.fbx":
            continue
        files.append(os.path.join(source_dir, entry))
    return files


def write_report(report: dict) -> None:
    os.makedirs(os.path.dirname(REPORT_PATH), exist_ok=True)
    with open(REPORT_PATH, "w", encoding="utf-8") as report_file:
        json.dump(report, report_file, ensure_ascii=False, indent=2)


def import_bindpose() -> dict:
    ensure_directory(BASE_DESTINATION)
    bindpose_task = create_import_task(BINDPOSE_SOURCE, BASE_DESTINATION, create_bindpose_import_options())
    [imported_paths] = import_tasks([bindpose_task])

    skeleton_path, skeleton = find_first_asset(imported_paths, "Skeleton")
    if not skeleton:
        skeleton_path, skeleton = fallback_find_asset(BASE_DESTINATION, "Skeleton")
    if not skeleton:
        raise RuntimeError("Bind-pose import succeeded but no Skeleton asset was found.")

    skeletal_mesh_path, _ = find_first_asset(imported_paths, "SkeletalMesh")
    if not skeletal_mesh_path:
        skeletal_mesh_path, _ = fallback_find_asset(BASE_DESTINATION, "SkeletalMesh")

    physics_asset_path, _ = find_first_asset(imported_paths, "PhysicsAsset")
    if not physics_asset_path:
        physics_asset_path, _ = fallback_find_asset(BASE_DESTINATION, "PhysicsAsset")

    asset_details = list_assets_with_classes(BASE_DESTINATION)
    class_breakdown = Counter(item["class_name"] for item in asset_details)
    materials = [
        item["path"]
        for item in asset_details
        if item["class_name"] in {"Material", "MaterialInstanceConstant"}
    ]
    textures = [
        item["path"]
        for item in asset_details
        if item["class_name"].startswith("Texture")
    ]

    return {
        "imported_object_paths": imported_paths,
        "skeleton_asset_path": skeleton_path,
        "skeletal_mesh_asset_path": skeletal_mesh_path,
        "physics_asset_path": physics_asset_path,
        "asset_class_breakdown": dict(sorted(class_breakdown.items())),
        "material_assets": materials,
        "texture_assets": textures,
        "all_asset_details": asset_details,
        "skeleton_object": skeleton,
    }


def import_animation_batch(batch: dict, skeleton: unreal.Skeleton) -> dict:
    source_dir = batch["source_dir"]
    destination_path = batch["destination_path"]
    batch_name = batch["name"]

    ensure_directory(destination_path)
    fbx_files = collect_fbx_files(source_dir)
    log(f"[SekiroImport] {batch_name}: preparing {len(fbx_files)} animation FBX files.")

    tasks = []
    for fbx_file in fbx_files:
        tasks.append(create_import_task(fbx_file, destination_path, create_animation_import_options(skeleton)))

    task_results = import_tasks(tasks)
    imported_asset_paths = []
    for imported_paths in task_results:
        for asset_path in imported_paths:
            asset = unreal.load_asset(asset_path)
            if asset and asset.get_class().get_name() == "AnimSequence":
                imported_asset_paths.append(asset_path)
    imported_asset_paths = sorted(set(imported_asset_paths))

    anim_assets_in_directory = list_assets_by_class(destination_path, "AnimSequence")
    anim_names_in_directory = {asset_name_from_object_path(asset_path) for asset_path in anim_assets_in_directory}
    missing_assets = [
        os.path.splitext(os.path.basename(fbx_file))[0]
        for fbx_file in fbx_files
        if os.path.splitext(os.path.basename(fbx_file))[0] not in anim_names_in_directory
    ]

    return {
        "name": batch_name,
        "source_dir": source_dir,
        "destination_path": destination_path,
        "source_fbx_count": len(fbx_files),
        "imported_anim_sequence_paths": imported_asset_paths,
        "directory_anim_sequence_paths": anim_assets_in_directory,
        "missing_anim_assets": missing_assets,
    }


def main() -> None:
    report = {
        "project_root": PROJECT_ROOT,
        "export_root": EXPORT_ROOT,
        "import_root": IMPORT_ROOT,
        "bindpose_source": BINDPOSE_SOURCE,
        "batches": [],
        "status": "running",
    }

    try:
        log("[SekiroImport] Import started.")

        bindpose_result = import_bindpose()
        skeleton = bindpose_result.pop("skeleton_object")
        report["bindpose"] = bindpose_result

        total_source_fbx = 0
        total_directory_anims = 0

        requested_batches = {
            name.strip()
            for name in os.environ.get("SEKIRO_C0000_BATCHES", "").split(",")
            if name.strip()
        }
        batches = [
            batch
            for batch in ANIMATION_BATCHES
            if not requested_batches or batch["name"] in requested_batches
        ]
        if requested_batches:
            missing_batches = sorted(requested_batches - {batch["name"] for batch in batches})
            if missing_batches:
                raise RuntimeError(f"Unknown C0000 animation batch filter(s): {missing_batches}")

        for batch in batches:
            batch_result = import_animation_batch(batch, skeleton)
            total_source_fbx += batch_result["source_fbx_count"]
            total_directory_anims += len(batch_result["directory_anim_sequence_paths"])
            report["batches"].append(batch_result)
            log(
                f"[SekiroImport] {batch_result['name']}: "
                f"{len(batch_result['directory_anim_sequence_paths'])}/{batch_result['source_fbx_count']} anim assets present."
            )

        report["total_source_animation_fbx"] = total_source_fbx
        report["total_directory_anim_sequences"] = total_directory_anims
        report["status"] = "success"
        write_report(report)
        log(f"[SekiroImport] Import finished successfully. Report: {REPORT_PATH}")
    except Exception as exc:
        report["status"] = "failed"
        report["error"] = str(exc)
        report["traceback"] = traceback.format_exc()
        write_report(report)
        unreal.log_error(report["traceback"])
        raise


if __name__ == "__main__":
    main()
