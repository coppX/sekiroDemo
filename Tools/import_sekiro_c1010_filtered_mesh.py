import json
import os
import traceback

import unreal


PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
EXPORT_ROOT = (
    r"E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE\exports\c1010_filtered"
)
SOURCE_FBX = os.path.join(EXPORT_ROOT, "c1010_bindpose.fbx")
DESTINATION = "/Game/Animation/Sekiro/Enemy/C1010/BaseFiltered"
EXISTING_SKELETON = "/Game/Animation/Sekiro/Enemy/C1010/Base/c1010_bindpose_Skeleton.c1010_bindpose_Skeleton"
REPORT_PATH = os.path.join(PROJECT_ROOT, "Saved", "SekiroImportReports", "c1010_filtered_mesh_import_summary.json")


def ensure_directory(asset_path: str) -> None:
    if not unreal.EditorAssetLibrary.does_directory_exist(asset_path):
        unreal.EditorAssetLibrary.make_directory(asset_path)


def list_assets(asset_path: str) -> list[dict]:
    result = []
    for path in unreal.EditorAssetLibrary.list_assets(asset_path, recursive=True, include_folder=False):
        asset = unreal.load_asset(path)
        if asset:
            result.append({"path": path, "class_name": asset.get_class().get_name()})
    return sorted(result, key=lambda item: item["path"])


def make_import_options(skeleton: unreal.Skeleton) -> unreal.FbxImportUI:
    options = unreal.FbxImportUI()
    options.set_editor_property("automated_import_should_detect_type", False)
    options.set_editor_property("original_import_type", unreal.FBXImportType.FBXIT_SKELETAL_MESH)
    options.set_editor_property("mesh_type_to_import", unreal.FBXImportType.FBXIT_SKELETAL_MESH)
    options.set_editor_property("import_as_skeletal", True)
    options.set_editor_property("import_mesh", True)
    options.set_editor_property("import_animations", False)
    options.set_editor_property("create_physics_asset", False)
    options.set_editor_property("import_materials", True)
    options.set_editor_property("import_textures", True)
    options.set_editor_property("skeleton", skeleton)

    data = options.get_editor_property("skeletal_mesh_import_data")
    data.set_editor_property("convert_scene", True)
    data.set_editor_property("convert_scene_unit", True)
    data.set_editor_property("preserve_smoothing_groups", True)
    data.set_editor_property("normal_import_method", unreal.FBXNormalImportMethod.FBXNIM_IMPORT_NORMALS_AND_TANGENTS)
    return options


def main() -> None:
    report = {
        "source_fbx": SOURCE_FBX,
        "destination": DESTINATION,
        "existing_skeleton": EXISTING_SKELETON,
        "status": "running",
    }

    try:
        if not os.path.isfile(SOURCE_FBX):
            raise FileNotFoundError(SOURCE_FBX)

        skeleton = unreal.load_asset(EXISTING_SKELETON)
        if not skeleton:
            raise RuntimeError(f"Missing skeleton: {EXISTING_SKELETON}")

        ensure_directory(DESTINATION)
        task = unreal.AssetImportTask()
        task.set_editor_property("filename", SOURCE_FBX)
        task.set_editor_property("destination_path", DESTINATION)
        task.set_editor_property("automated", True)
        task.set_editor_property("replace_existing", True)
        task.set_editor_property("replace_existing_settings", True)
        task.set_editor_property("save", True)
        task.set_editor_property("options", make_import_options(skeleton))

        unreal.AssetToolsHelpers.get_asset_tools().import_asset_tasks([task])
        imported = [str(path) for path in task.get_editor_property("imported_object_paths")]
        assets = list_assets(DESTINATION)
        skeletal_meshes = [item["path"] for item in assets if item["class_name"] == "SkeletalMesh"]

        report.update(
            {
                "status": "success",
                "imported_object_paths": imported,
                "skeletal_mesh_asset_path": skeletal_meshes[0] if skeletal_meshes else None,
                "assets": assets,
            }
        )
    except Exception as exc:
        report.update({"status": "failed", "error": str(exc), "traceback": traceback.format_exc()})
        unreal.log_error(report["traceback"])
        raise
    finally:
        os.makedirs(os.path.dirname(REPORT_PATH), exist_ok=True)
        with open(REPORT_PATH, "w", encoding="utf-8") as handle:
            json.dump(report, handle, ensure_ascii=False, indent=2)


if __name__ == "__main__":
    main()
