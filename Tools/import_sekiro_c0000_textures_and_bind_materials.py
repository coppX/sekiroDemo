import json
import os
import traceback

import unreal


PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
MANIFEST_PATH = os.path.join(PROJECT_ROOT, "Saved", "SekiroImportReports", "c0000_texture_manifest.json")
REPORT_PATH = os.path.join(PROJECT_ROOT, "Saved", "SekiroImportReports", "c0000_texture_import_summary.json")
TEXTURE_DESTINATION = "/Game/Animation/Sekiro/C0000/Textures"
BASE_MATERIAL_DIR = "/Game/Animation/Sekiro/C0000/Base"


def log(message: str) -> None:
    unreal.log(message)
    print(message)


def ensure_directory(asset_path: str) -> None:
    if unreal.EditorAssetLibrary.does_directory_exist(asset_path):
        return
    if not unreal.EditorAssetLibrary.make_directory(asset_path):
        raise RuntimeError(f"Failed to create directory: {asset_path}")


def load_manifest() -> dict:
    with open(MANIFEST_PATH, "r", encoding="utf-8") as handle:
        return json.load(handle)


def write_report(report: dict) -> None:
    os.makedirs(os.path.dirname(REPORT_PATH), exist_ok=True)
    with open(REPORT_PATH, "w", encoding="utf-8") as handle:
        json.dump(report, handle, ensure_ascii=False, indent=2)


def create_import_task(filename: str, destination_path: str) -> unreal.AssetImportTask:
    task = unreal.AssetImportTask()
    task.set_editor_property("filename", filename)
    task.set_editor_property("destination_path", destination_path)
    task.set_editor_property("automated", True)
    task.set_editor_property("replace_existing", True)
    task.set_editor_property("replace_existing_settings", True)
    task.set_editor_property("save", True)
    return task


def import_textures(manifest: dict) -> dict:
    ensure_directory(TEXTURE_DESTINATION)

    tasks = []
    source_to_name = {}
    skipped_existing_assets = []
    for texture in manifest["textures"]:
        source_tga_path = texture["converted_tga_path"]
        if not os.path.isfile(source_tga_path):
            continue
        existing_asset_path = get_texture_asset_path(texture["texture_name"])
        if unreal.EditorAssetLibrary.does_asset_exist(existing_asset_path):
            skipped_existing_assets.append(existing_asset_path)
            continue
        tasks.append(create_import_task(source_tga_path, TEXTURE_DESTINATION))
        source_to_name[source_tga_path] = texture["texture_name"]

    if tasks:
        unreal.AssetToolsHelpers.get_asset_tools().import_asset_tasks(tasks)

    imported = []
    for task in tasks:
        for object_path in task.get_editor_property("imported_object_paths"):
            imported.append(str(object_path))

    return {
        "attempted_texture_files": len(tasks),
        "skipped_existing_texture_assets": skipped_existing_assets,
        "imported_object_paths": sorted(set(imported)),
        "texture_source_to_name": source_to_name,
    }


def get_texture_asset_path(texture_name: str) -> str:
    return f"{TEXTURE_DESTINATION}/{texture_name}.{texture_name}"


def configure_texture_asset(texture_asset, usage_hint: str) -> None:
    texture_asset.set_editor_property("srgb", usage_hint in {"color", "emissive"})

    if usage_hint == "normal":
        texture_asset.set_editor_property(
            "compression_settings",
            unreal.TextureCompressionSettings.TC_NORMALMAP,
        )
    elif usage_hint in {"mask", "ambient_occlusion"}:
        texture_asset.set_editor_property(
            "compression_settings",
            unreal.TextureCompressionSettings.TC_MASKS,
        )
    else:
        texture_asset.set_editor_property(
            "compression_settings",
            unreal.TextureCompressionSettings.TC_DEFAULT,
        )

    unreal.EditorAssetLibrary.save_loaded_asset(texture_asset)


def configure_imported_textures(manifest: dict) -> dict:
    configured = []
    missing = []

    for texture in manifest["textures"]:
        asset_path = get_texture_asset_path(texture["texture_name"])
        texture_asset = unreal.load_asset(asset_path)
        if not texture_asset:
            missing.append(asset_path)
            continue

        configure_texture_asset(texture_asset, texture["usage_hint"])
        configured.append(
            {
                "texture_name": texture["texture_name"],
                "asset_path": asset_path,
                "usage_hint": texture["usage_hint"],
            }
        )

    return {
        "configured_textures": configured,
        "missing_texture_assets": missing,
    }


def set_texture_parameter(material_instance, parameter_name: str, texture_asset) -> dict:
    setter_return = unreal.MaterialEditingLibrary.set_material_instance_texture_parameter_value(
        material_instance,
        parameter_name,
        texture_asset,
    )
    actual_texture = unreal.MaterialEditingLibrary.get_material_instance_texture_parameter_value(
        material_instance,
        parameter_name,
    )
    expected_path = texture_asset.get_path_name() if texture_asset else None
    actual_path = actual_texture.get_path_name() if actual_texture else None
    return {
        "setter_return": bool(setter_return),
        "verified": actual_path == expected_path,
        "actual_texture_asset_path": actual_path,
    }


def set_scalar_parameter(material_instance, parameter_name: str, value: float) -> dict:
    setter_return = unreal.MaterialEditingLibrary.set_material_instance_scalar_parameter_value(
        material_instance,
        parameter_name,
        value,
    )
    actual_value = unreal.MaterialEditingLibrary.get_material_instance_scalar_parameter_value(
        material_instance,
        parameter_name,
    )
    return {
        "setter_return": bool(setter_return),
        "verified": abs(actual_value - value) < 1e-6,
        "actual_value": actual_value,
    }


def bind_materials(manifest: dict) -> dict:
    material_reports = []
    missing_materials = []
    total_assignments = 0
    verified_texture_assignments = 0
    verified_scalar_assignments = 0

    scalar_map = {
        "DiffuseColorMap": "DiffuseColorMapWeight",
        "NormalMap": "NormalMapWeight",
        "SpecularColorMap": "SpecularColorMapWeight",
        "EmissiveColorMap": "EmissiveColorMapWeight",
        "AmbientOcclusionMap": "AmbientOcclusionMapWeight",
    }

    for material_info in manifest["materials"]:
        material_asset_path = (
            f"{BASE_MATERIAL_DIR}/{material_info['ue_material_name']}.{material_info['ue_material_name']}"
        )
        material_instance = unreal.load_asset(material_asset_path)
        if not material_instance:
            missing_materials.append(material_asset_path)
            continue

        assignments = []
        missing_textures = []

        for slot_name, slot_info in material_info["primary_assignments"].items():
            total_assignments += 1
            texture_asset_path = get_texture_asset_path(slot_info["texture_name"])
            texture_asset = unreal.load_asset(texture_asset_path)
            if not texture_asset:
                missing_textures.append(texture_asset_path)
                continue

            texture_result = set_texture_parameter(material_instance, slot_name, texture_asset)
            if texture_result["verified"]:
                verified_texture_assignments += 1

            scalar_result = {
                "setter_return": None,
                "verified": None,
                "actual_value": None,
            }
            scalar_parameter_name = scalar_map.get(slot_name)
            if scalar_parameter_name:
                scalar_result = set_scalar_parameter(material_instance, scalar_parameter_name, 1.0)
                if scalar_result["verified"]:
                    verified_scalar_assignments += 1

            assignments.append(
                {
                    "slot_name": slot_name,
                    "texture_name": slot_info["texture_name"],
                    "texture_asset_path": texture_asset_path,
                    "source_type": slot_info["source_type"],
                    "texture_setter_return": texture_result["setter_return"],
                    "texture_verified": texture_result["verified"],
                    "actual_texture_asset_path": texture_result["actual_texture_asset_path"],
                    "scalar_parameter_name": scalar_parameter_name,
                    "scalar_setter_return": scalar_result["setter_return"],
                    "scalar_verified": scalar_result["verified"],
                    "actual_scalar_value": scalar_result["actual_value"],
                }
            )

        save_result = unreal.EditorAssetLibrary.save_loaded_asset(material_instance)

        material_reports.append(
            {
                "material_asset_path": material_asset_path,
                "source_material_name": material_info["source_material_name"],
                "assignments": assignments,
                "missing_texture_assets": missing_textures,
                "save_result": bool(save_result),
            }
        )

    return {
        "bound_materials": material_reports,
        "missing_material_assets": missing_materials,
        "total_assignments": total_assignments,
        "verified_texture_assignments": verified_texture_assignments,
        "verified_scalar_assignments": verified_scalar_assignments,
    }


def main() -> None:
    report = {
        "manifest_path": MANIFEST_PATH,
        "texture_destination": TEXTURE_DESTINATION,
        "base_material_dir": BASE_MATERIAL_DIR,
        "status": "running",
    }

    try:
        manifest = load_manifest()
        log("[SekiroTextureImport] Import started.")

        import_report = import_textures(manifest)
        config_report = configure_imported_textures(manifest)
        bind_report = bind_materials(manifest)

        report.update(import_report)
        report.update(config_report)
        report.update(bind_report)
        report["status"] = "success"

        write_report(report)
        log(f"[SekiroTextureImport] Import finished successfully. Report: {REPORT_PATH}")
    except Exception as exc:
        report["status"] = "failed"
        report["error"] = str(exc)
        report["traceback"] = traceback.format_exc()
        write_report(report)
        unreal.log_error(report["traceback"])
        raise


if __name__ == "__main__":
    main()
