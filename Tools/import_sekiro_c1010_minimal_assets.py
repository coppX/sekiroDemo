import json
import os
import traceback
from collections import Counter

import unreal


PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
EXPORT_ROOT = (
    r"E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE\exports\c1010_minimal"
)
IMPORT_ROOT = "/Game/Animation/Sekiro/Enemy/C1010"
REPORT_PATH = os.path.join(PROJECT_ROOT, "Saved", "SekiroImportReports", "c1010_minimal_import_summary.json")

BINDPOSE_SOURCE = os.path.join(EXPORT_ROOT, "c1010_bindpose.fbx")
BASE_DESTINATION = f"{IMPORT_ROOT}/Base"
ANIMATION_DESTINATION = f"{IMPORT_ROOT}/Minimal"

ANIMATION_FILES = [
    "a000_000000.fbx",
    "a000_000210.fbx",
    "a000_000220.fbx",
    "a000_000230.fbx",
    "a000_003000.fbx",
    "a000_003007.fbx",
    "a000_020000.fbx",
]


def log(message: str) -> None:
    unreal.log(message)
    print(message)


def ensure_directory(asset_path: str) -> None:
    if not unreal.EditorAssetLibrary.does_directory_exist(asset_path):
        if not unreal.EditorAssetLibrary.make_directory(asset_path):
            raise RuntimeError(f"Failed to create directory: {asset_path}")


def list_assets_with_classes(asset_path: str) -> list[dict]:
    items = []
    for path in unreal.EditorAssetLibrary.list_assets(asset_path, recursive=True, include_folder=False):
        asset = unreal.load_asset(path)
        if asset:
            items.append({"path": path, "class_name": asset.get_class().get_name()})
    return sorted(items, key=lambda item: item["path"])


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

    data = options.get_editor_property("skeletal_mesh_import_data")
    data.set_editor_property("convert_scene", True)
    data.set_editor_property("convert_scene_unit", True)
    data.set_editor_property("preserve_smoothing_groups", True)
    data.set_editor_property("normal_import_method", unreal.FBXNormalImportMethod.FBXNIM_IMPORT_NORMALS_AND_TANGENTS)
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

    data = options.get_editor_property("anim_sequence_import_data")
    data.set_editor_property("animation_length", unreal.FBXAnimationLengthImportType.FBXALIT_EXPORTED_TIME)
    data.set_editor_property("import_bone_tracks", True)
    data.set_editor_property("remove_redundant_keys", False)
    return options


def import_tasks(tasks: list[unreal.AssetImportTask]) -> list[list[str]]:
    unreal.AssetToolsHelpers.get_asset_tools().import_asset_tasks(tasks)
    return [[str(path) for path in task.get_editor_property("imported_object_paths")] for task in tasks]


def first_loaded_asset(paths: list[str], class_name: str):
    for path in paths:
        asset = unreal.load_asset(path)
        if asset and asset.get_class().get_name() == class_name:
            return path, asset
    return None, None


def find_asset(directory: str, class_name: str):
    for item in list_assets_with_classes(directory):
        if item["class_name"] == class_name:
            asset = unreal.load_asset(item["path"])
            if asset:
                return item["path"], asset
    return None, None


def write_report(report: dict) -> None:
    os.makedirs(os.path.dirname(REPORT_PATH), exist_ok=True)
    with open(REPORT_PATH, "w", encoding="utf-8") as handle:
        json.dump(report, handle, ensure_ascii=False, indent=2)


def main() -> None:
    report = {
        "export_root": EXPORT_ROOT,
        "import_root": IMPORT_ROOT,
        "bindpose_source": BINDPOSE_SOURCE,
        "animation_files": ANIMATION_FILES,
        "status": "running",
    }

    try:
        if not os.path.isfile(BINDPOSE_SOURCE):
            raise FileNotFoundError(BINDPOSE_SOURCE)

        ensure_directory(BASE_DESTINATION)
        ensure_directory(ANIMATION_DESTINATION)

        log("[C1010Import] Importing bindpose.")
        bindpose_task = create_import_task(BINDPOSE_SOURCE, BASE_DESTINATION, create_bindpose_import_options())
        [bindpose_paths] = import_tasks([bindpose_task])

        skeleton_path, skeleton = first_loaded_asset(bindpose_paths, "Skeleton")
        if not skeleton:
            skeleton_path, skeleton = find_asset(BASE_DESTINATION, "Skeleton")
        if not skeleton:
            raise RuntimeError("Bindpose import did not produce a Skeleton.")

        mesh_path, _mesh = first_loaded_asset(bindpose_paths, "SkeletalMesh")
        if not mesh_path:
            mesh_path, _mesh = find_asset(BASE_DESTINATION, "SkeletalMesh")

        physics_path, _physics = first_loaded_asset(bindpose_paths, "PhysicsAsset")
        if not physics_path:
            physics_path, _physics = find_asset(BASE_DESTINATION, "PhysicsAsset")

        anim_tasks = []
        missing_sources = []
        for filename in ANIMATION_FILES:
            source = os.path.join(EXPORT_ROOT, filename)
            if os.path.isfile(source):
                anim_tasks.append(create_import_task(source, ANIMATION_DESTINATION, create_animation_import_options(skeleton)))
            else:
                missing_sources.append(source)

        log(f"[C1010Import] Importing {len(anim_tasks)} animation FBX files.")
        anim_results = import_tasks(anim_tasks) if anim_tasks else []

        base_assets = list_assets_with_classes(BASE_DESTINATION)
        anim_assets = list_assets_with_classes(ANIMATION_DESTINATION)
        report.update(
            {
                "status": "success",
                "bindpose_imported_object_paths": bindpose_paths,
                "skeleton_asset_path": skeleton_path,
                "skeletal_mesh_asset_path": mesh_path,
                "physics_asset_path": physics_path,
                "animation_import_results": anim_results,
                "missing_animation_sources": missing_sources,
                "base_asset_class_breakdown": dict(Counter(item["class_name"] for item in base_assets)),
                "animation_asset_paths": [item["path"] for item in anim_assets if item["class_name"] == "AnimSequence"],
                "base_assets": base_assets,
                "animation_assets": anim_assets,
            }
        )
        write_report(report)
        log(f"[C1010Import] Done. Report: {REPORT_PATH}")
    except Exception as exc:
        report["status"] = "failed"
        report["error"] = str(exc)
        report["traceback"] = traceback.format_exc()
        write_report(report)
        unreal.log_error(report["traceback"])
        raise


if __name__ == "__main__":
    main()
