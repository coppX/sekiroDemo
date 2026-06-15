import json
import os

import unreal


PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
REPORT_PATH = os.path.join(PROJECT_ROOT, "Saved", "SekiroImportReports", "c0000_base_asset_inspection.json")
BASE_PATH = "/Game/Animation/Sekiro/C0000/Base"
TEXTURE_TEST_SOURCE = (
    r"E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE\exports\c0000_shared_bindpose"
    r"\c0000_bindpose.fbm\am_m_9000_armor_a.dds"
)
TEXTURE_TEST_DEST = f"{BASE_PATH}/_TextureImportProbe"


def save_report(payload: dict) -> None:
    os.makedirs(os.path.dirname(REPORT_PATH), exist_ok=True)
    with open(REPORT_PATH, "w", encoding="utf-8") as handle:
        json.dump(payload, handle, ensure_ascii=False, indent=2)


def list_material_instances() -> list[dict]:
    assets = unreal.EditorAssetLibrary.list_assets(BASE_PATH, recursive=False, include_folder=False)
    result = []
    for asset_path in sorted(assets):
        asset = unreal.load_asset(asset_path)
        if not asset or asset.get_class().get_name() != "MaterialInstanceConstant":
            continue

        parent = asset.get_editor_property("parent")
        texture_params = []
        scalar_params = []
        vector_params = []

        try:
            for info in unreal.MaterialEditingLibrary.get_texture_parameter_names(asset):
                texture = unreal.MaterialEditingLibrary.get_material_instance_texture_parameter_value(asset, info)
                texture_params.append(
                    {
                        "name": str(info),
                        "value": texture.get_path_name() if texture else None,
                    }
                )
        except Exception as exc:
            texture_params.append({"error": str(exc)})

        try:
            for info in unreal.MaterialEditingLibrary.get_scalar_parameter_names(asset):
                value = unreal.MaterialEditingLibrary.get_material_instance_scalar_parameter_value(asset, info)
                scalar_params.append(
                    {
                        "name": str(info),
                        "value": value,
                    }
                )
        except Exception as exc:
            scalar_params.append({"error": str(exc)})

        try:
            for info in unreal.MaterialEditingLibrary.get_vector_parameter_names(asset):
                value = unreal.MaterialEditingLibrary.get_material_instance_vector_parameter_value(asset, info)
                vector_params.append(
                    {
                        "name": str(info),
                        "value": str(value) if value else None,
                    }
                )
        except Exception as exc:
            vector_params.append({"error": str(exc)})

        result.append(
            {
                "asset_path": asset_path,
                "parent": parent.get_path_name() if parent else None,
                "texture_params": texture_params,
                "scalar_params": scalar_params,
                "vector_params": vector_params,
            }
        )
    return result


def try_import_dds_probe() -> dict:
    if unreal.EditorAssetLibrary.does_directory_exist(TEXTURE_TEST_DEST):
        unreal.EditorAssetLibrary.delete_directory(TEXTURE_TEST_DEST)
    unreal.EditorAssetLibrary.make_directory(TEXTURE_TEST_DEST)

    task = unreal.AssetImportTask()
    task.set_editor_property("filename", TEXTURE_TEST_SOURCE)
    task.set_editor_property("destination_path", TEXTURE_TEST_DEST)
    task.set_editor_property("automated", True)
    task.set_editor_property("replace_existing", True)
    task.set_editor_property("replace_existing_settings", True)
    task.set_editor_property("save", True)

    unreal.AssetToolsHelpers.get_asset_tools().import_asset_tasks([task])

    imported = [str(path) for path in task.get_editor_property("imported_object_paths")]
    existing_assets = unreal.EditorAssetLibrary.list_assets(TEXTURE_TEST_DEST, recursive=True, include_folder=False)

    return {
        "source": TEXTURE_TEST_SOURCE,
        "destination": TEXTURE_TEST_DEST,
        "imported_object_paths": imported,
        "existing_assets": existing_assets,
    }


def main() -> None:
    payload = {
        "material_instances": list_material_instances(),
        "dds_probe": try_import_dds_probe(),
    }
    save_report(payload)
    print(f"Inspection report written: {REPORT_PATH}")


if __name__ == "__main__":
    main()
