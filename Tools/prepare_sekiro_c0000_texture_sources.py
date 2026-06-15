import json
import os
import re
import shutil
import subprocess
from collections import defaultdict


PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
MODEL_JSON_PATH = (
    r"E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE\exports\c0000_shared_bindpose"
    r"\_intermediate_bindpose\model.json"
)
SOURCE_TEXTURE_DIR = (
    r"E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE\exports\c0000_shared_bindpose"
    r"\_intermediate_bindpose\textures"
)
CONVERTED_TEXTURE_DIR = os.path.join(PROJECT_ROOT, "ImportSource", "Sekiro", "C0000", "TexturesTga")
REPORT_DIR = os.path.join(PROJECT_ROOT, "Saved", "SekiroImportReports")
MANIFEST_PATH = os.path.join(REPORT_DIR, "c0000_texture_manifest.json")
SUMMARY_PATH = os.path.join(REPORT_DIR, "c0000_texture_prepare_summary.json")


def sanitize_for_ue(name: str) -> str:
    return re.sub(r"[^A-Za-z0-9_]", "_", name)


def ensure_dir(path: str) -> None:
    os.makedirs(path, exist_ok=True)


def load_model_json() -> dict:
    with open(MODEL_JSON_PATH, "r", encoding="utf-8") as handle:
        return json.load(handle)


def slot_priority_rules() -> dict[str, list[str]]:
    return {
        "DiffuseColorMap": [
            "Character_AMSN__AO_SSS___Cs__snp_Texture2D_2_AlbedoMap_0",
            "Character_AMSN__Cat_Eye__snp_Texture2D_2_AlbedoMap_0",
            "Character_MeshDecal_snp_Texture2D_0_AlbedoMap_0",
            "Character_AMSN_snp_Texture2D_2_AlbedoMap_0",
            "Character_AMSN_SSS_snp_Texture2D_2_AlbedoMap_0",
            "Character_AN_Blend_AMSN__Fresnel__snp_Texture2D_2_AlbedoMap_0",
            "Character_AMSN__DetailBlend__snp_Texture2D_7_AlbedoMap",
            "Fur_NTC_snp_Texture2D_1_AlbedoMap_0",
            "AlbedoMap",
        ],
        "NormalMap": [
            "Character_AMSN__AO_SSS___Cs__snp_Texture2D_12_NormalMap",
            "Character_AMSN__Cat_Eye__snp_Texture2D_7_NormalMap_4",
            "Character_MeshDecal_snp_Texture2D_1_NormalMap_0",
            "Character_AMSN_snp_Texture2D_7_NormalMap_4",
            "Character_AMSN_SSS_snp_Texture2D_7_NormalMap_4",
            "Character_AN_Blend_AMSN__Fresnel__snp_Texture2D_7_NormalMap_4",
            "Character_AMSN__DetailBlend__snp_Texture2D_0_NormalMap",
            "Fur_NTC_snp_Texture2D_3_NormalMap_0",
            "NormalMap",
        ],
        "SpecularColorMap": [
            "ReflectanceMap",
            "MetallicMap",
        ],
        "EmissiveColorMap": [
            "EmissiveMap",
        ],
        "AmbientOcclusionMap": [
            "AmbientOcculusionMap",
            "AmbientOcclusionMap",
        ],
    }


def pick_primary_texture(material_textures: list[dict], target_slot: str) -> dict | None:
    rules = slot_priority_rules()[target_slot]
    candidates: list[tuple[int, str, dict]] = []
    for texture in material_textures:
        tex_type = texture["type"]
        for priority, pattern in enumerate(rules):
            if pattern in tex_type:
                candidates.append((priority, texture["name"], texture))
                break
    if not candidates:
        return None
    candidates.sort(key=lambda item: (item[0], item[1]))
    return candidates[0][2]


def infer_texture_usage(texture_types: list[str], texture_name: str) -> str:
    joined = " ".join(texture_types)
    if "NormalMap" in joined or texture_name.endswith("_n"):
        return "normal"
    if "AmbientOcculusionMap" in joined or "AmbientOcclusionMap" in joined:
        return "ambient_occlusion"
    if "EmissiveMap" in joined or texture_name.endswith("_em"):
        return "emissive"
    if (
        "ReflectanceMap" in joined
        or "MetallicMap" in joined
        or "Mask1Map" in joined
        or "Mask3Map" in joined
        or "DisplacementMap" in joined
        or texture_name.endswith("_m")
        or texture_name.endswith("_1m")
        or texture_name.endswith("_3m")
        or "_ao_" in texture_name
        or texture_name.endswith("_d")
    ):
        return "mask"
    return "color"


def build_manifest(model_data: dict) -> dict:
    material_defs: dict[str, dict] = {}
    texture_type_map: dict[str, set[str]] = defaultdict(set)

    for mesh in model_data["meshes"]:
        material = mesh["material"]
        material_name = material["name"]
        if material_name not in material_defs:
            material_defs[material_name] = material
        for texture in material.get("textures", []):
            texture_type_map[texture["name"]].add(texture["type"])

    materials = []
    for source_material_name in sorted(material_defs.keys()):
        material = material_defs[source_material_name]
        assignments = {}
        for slot_name in [
            "DiffuseColorMap",
            "NormalMap",
            "SpecularColorMap",
            "EmissiveColorMap",
            "AmbientOcclusionMap",
        ]:
            picked = pick_primary_texture(material["textures"], slot_name)
            if picked:
                assignments[slot_name] = {
                    "texture_name": picked["name"],
                    "source_type": picked["type"],
                }

        materials.append(
            {
                "source_material_name": source_material_name,
                "ue_material_name": sanitize_for_ue(source_material_name),
                "mtd": material["mtd"],
                "all_textures": material["textures"],
                "primary_assignments": assignments,
            }
        )

    textures = []
    for texture_name in sorted(texture_type_map.keys()):
        usage = infer_texture_usage(sorted(texture_type_map[texture_name]), texture_name)
        textures.append(
            {
                "texture_name": texture_name,
                "source_dds_path": os.path.join(SOURCE_TEXTURE_DIR, f"{texture_name}.dds"),
                "converted_tga_path": os.path.join(CONVERTED_TEXTURE_DIR, f"{texture_name}.tga"),
                "usage_hint": usage,
                "source_types": sorted(texture_type_map[texture_name]),
            }
        )

    return {
        "model_json_path": MODEL_JSON_PATH,
        "source_texture_dir": SOURCE_TEXTURE_DIR,
        "converted_texture_dir": CONVERTED_TEXTURE_DIR,
        "materials": materials,
        "textures": textures,
    }


def convert_texture(texconv_path: str, source_dds_path: str) -> subprocess.CompletedProcess:
    return subprocess.run(
        [
            texconv_path,
            "-ft",
            "tga",
            "-y",
            "-o",
            CONVERTED_TEXTURE_DIR,
            source_dds_path,
        ],
        capture_output=True,
        text=True,
        check=False,
    )


def prepare_textures(manifest: dict) -> dict:
    texconv_path = shutil.which("texconv.exe")
    if not texconv_path:
        raise RuntimeError("texconv.exe was not found in PATH.")

    ensure_dir(CONVERTED_TEXTURE_DIR)

    converted = []
    skipped = []
    missing_sources = []
    failed = []

    for texture in manifest["textures"]:
        source_path = texture["source_dds_path"]
        target_path = texture["converted_tga_path"]

        if not os.path.isfile(source_path):
            missing_sources.append(source_path)
            continue

        source_mtime = os.path.getmtime(source_path)
        target_exists = os.path.isfile(target_path)
        target_mtime = os.path.getmtime(target_path) if target_exists else -1.0

        if target_exists and target_mtime >= source_mtime:
            skipped.append(target_path)
            continue

        result = convert_texture(texconv_path, source_path)
        if result.returncode != 0 or not os.path.isfile(target_path):
            failed.append(
                {
                    "source": source_path,
                    "target": target_path,
                    "returncode": result.returncode,
                    "stdout": result.stdout,
                    "stderr": result.stderr,
                }
            )
            continue

        converted.append(target_path)

    return {
        "texconv_path": texconv_path,
        "converted_count": len(converted),
        "skipped_count": len(skipped),
        "missing_source_count": len(missing_sources),
        "failed_count": len(failed),
        "converted_files": converted,
        "skipped_files": skipped,
        "missing_source_files": missing_sources,
        "failed_files": failed,
    }


def write_json(path: str, payload: dict) -> None:
    ensure_dir(os.path.dirname(path))
    with open(path, "w", encoding="utf-8") as handle:
        json.dump(payload, handle, ensure_ascii=False, indent=2)


def main() -> None:
    model_data = load_model_json()
    manifest = build_manifest(model_data)
    prepare_summary = prepare_textures(manifest)

    write_json(MANIFEST_PATH, manifest)

    summary = {
        "manifest_path": MANIFEST_PATH,
        "summary_path": SUMMARY_PATH,
        "material_count": len(manifest["materials"]),
        "texture_count": len(manifest["textures"]),
        **prepare_summary,
    }
    write_json(SUMMARY_PATH, summary)

    print(f"Prepared {summary['texture_count']} textures for {summary['material_count']} materials.")
    print(f"Manifest: {MANIFEST_PATH}")
    print(f"Summary: {SUMMARY_PATH}")

    if summary["failed_count"] or summary["missing_source_count"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
