import json
import os
import traceback

import unreal


PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
MANIFEST_PATH = os.path.join(PROJECT_ROOT, "Saved", "SekiroImportReports", "c0000_texture_manifest.json")
REPORT_PATH = os.path.join(PROJECT_ROOT, "Saved", "SekiroImportReports", "c0000_material_binding_verification.json")
TEXTURE_DESTINATION = "/Game/Animation/Sekiro/C0000/Textures"
BASE_MATERIAL_DIR = "/Game/Animation/Sekiro/C0000/Base"


def load_manifest() -> dict:
    with open(MANIFEST_PATH, "r", encoding="utf-8") as handle:
        return json.load(handle)


def write_report(report: dict) -> None:
    os.makedirs(os.path.dirname(REPORT_PATH), exist_ok=True)
    with open(REPORT_PATH, "w", encoding="utf-8") as handle:
        json.dump(report, handle, ensure_ascii=False, indent=2)


def texture_asset_path(texture_name: str) -> str:
    return f"{TEXTURE_DESTINATION}/{texture_name}.{texture_name}"


def material_asset_path(material_name: str) -> str:
    return f"{BASE_MATERIAL_DIR}/{material_name}.{material_name}"


def get_texture_value(material_instance, parameter_name: str) -> str | None:
    texture = unreal.MaterialEditingLibrary.get_material_instance_texture_parameter_value(
        material_instance,
        parameter_name,
    )
    return texture.get_path_name() if texture else None


def get_scalar_value(material_instance, parameter_name: str) -> float:
    return unreal.MaterialEditingLibrary.get_material_instance_scalar_parameter_value(
        material_instance,
        parameter_name,
    )


def verify_materials(manifest: dict) -> dict:
    scalar_map = {
        "DiffuseColorMap": "DiffuseColorMapWeight",
        "NormalMap": "NormalMapWeight",
        "SpecularColorMap": "SpecularColorMapWeight",
        "EmissiveColorMap": "EmissiveColorMapWeight",
        "AmbientOcclusionMap": "AmbientOcclusionMapWeight",
    }

    material_reports = []
    missing_materials = []
    total_assignments = 0
    matched_assignments = 0
    matched_scalars = 0

    for material_info in manifest["materials"]:
        asset_path = material_asset_path(material_info["ue_material_name"])
        material_instance = unreal.load_asset(asset_path)
        if not material_instance:
            missing_materials.append(asset_path)
            continue

        assignments = []
        for slot_name, slot_info in material_info["primary_assignments"].items():
            total_assignments += 1
            expected_texture_path = texture_asset_path(slot_info["texture_name"])
            actual_texture_path = get_texture_value(material_instance, slot_name)
            texture_matches = actual_texture_path == expected_texture_path
            if texture_matches:
                matched_assignments += 1

            scalar_parameter_name = scalar_map.get(slot_name)
            actual_scalar = None
            scalar_matches = None
            if scalar_parameter_name:
                actual_scalar = get_scalar_value(material_instance, scalar_parameter_name)
                scalar_matches = abs(actual_scalar - 1.0) < 1e-6
                if scalar_matches:
                    matched_scalars += 1

            assignments.append(
                {
                    "slot_name": slot_name,
                    "texture_name": slot_info["texture_name"],
                    "expected_texture_asset_path": expected_texture_path,
                    "actual_texture_asset_path": actual_texture_path,
                    "texture_matches": texture_matches,
                    "scalar_parameter_name": scalar_parameter_name,
                    "actual_scalar_value": actual_scalar,
                    "scalar_matches_expected_one": scalar_matches,
                    "source_type": slot_info["source_type"],
                }
            )

        material_reports.append(
            {
                "material_asset_path": asset_path,
                "source_material_name": material_info["source_material_name"],
                "assignment_count": len(assignments),
                "matched_assignment_count": sum(1 for item in assignments if item["texture_matches"]),
                "matched_scalar_count": sum(1 for item in assignments if item["scalar_matches_expected_one"]),
                "assignments": assignments,
            }
        )

    return {
        "material_reports": material_reports,
        "missing_material_assets": missing_materials,
        "total_assignments": total_assignments,
        "matched_assignments": matched_assignments,
        "matched_scalars": matched_scalars,
    }


def main() -> None:
    report = {
        "manifest_path": MANIFEST_PATH,
        "report_path": REPORT_PATH,
        "status": "running",
    }

    try:
        manifest = load_manifest()
        verification = verify_materials(manifest)
        report.update(verification)
        report["status"] = "success"
        write_report(report)
        print(f"Verification report written: {REPORT_PATH}")
        print(
            "Matched assignments: "
            f"{report['matched_assignments']}/{report['total_assignments']}, "
            f"matched scalars: {report['matched_scalars']}"
        )
    except Exception as exc:
        report["status"] = "failed"
        report["error"] = str(exc)
        report["traceback"] = traceback.format_exc()
        write_report(report)
        raise


if __name__ == "__main__":
    main()
