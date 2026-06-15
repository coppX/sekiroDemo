import json
import os
import re
import subprocess
import traceback

import unreal


PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
OBJ_SOURCE_DIR = os.path.join(PROJECT_ROOT, "ImportSource", "Sekiro", "Weapons", "WP_A_0300", "Obj")
DESTINATION = "/Game/Animation/Sekiro/C0000/Weapons"
REPORT_PATH = os.path.join(PROJECT_ROOT, "Saved", "SekiroImportReports", "wp_a_0300_import_summary.json")
COMBINED_SHEATHED_SOURCE = os.path.join(OBJ_SOURCE_DIR, "WP_A_0300_L_CompleteSheathed.obj")
FLVER_EXPORTER = os.path.join(
    PROJECT_ROOT,
    "Tools",
    "SekiroFlverObjExporter",
    "bin",
    "Release",
    "net8.0",
    "SekiroFlverObjExporter.exe",
)
SOURCE_WP_A_0300_L_FLVER = (
    r"E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE"
    r"\parts\wp_a_0300_l-partsbnd-dcx\parts\Weapon\WP_A_0300\WP_A_0300_L.flver"
)

STATIC_MESHES = [
    {
        "source": os.path.join(OBJ_SOURCE_DIR, "WP_A_0300.obj"),
        "asset_name": "SM_WP_A_0300_Textured",
        "description": "WP_A_0300.flver main Kusabimaru weapon mesh",
    },
    {
        "source": os.path.join(OBJ_SOURCE_DIR, "WP_A_0300_1.obj"),
        "asset_name": "SM_WP_A_0300_Sheath",
        "description": "WP_A_0300_1.flver sheath-side mesh",
    },
    {
        "source": COMBINED_SHEATHED_SOURCE,
        "asset_name": "SM_WP_A_0300_L_Sheathed",
        "description": "Combined WP_A_0300_L.flver + WP_A_0300_1_L.flver complete sheathed/back weapon state mesh",
    },
    {
        "source": os.path.join(OBJ_SOURCE_DIR, "WP_A_0300_1_L.obj"),
        "asset_name": "SM_WP_A_0300_L_Sheath",
        "description": "WP_A_0300_1_L.flver sheathed/back sheath-side mesh",
    },
]

SOURCE_EMPTY_MESHES = [
    {
        "source": os.path.join(OBJ_SOURCE_DIR, "WP_A_0300_2.obj"),
        "description": "WP_A_0300_2.flver exports no triangles",
    },
    {
        "source": os.path.join(OBJ_SOURCE_DIR, "WP_A_0300_2_L.obj"),
        "description": "WP_A_0300_2_L.flver exports no triangles",
    },
]

SOURCE_MATERIAL_ASSETS = {
    "0300_4_weapon": "0300_4_weapon",
    "Material__732": "Material__732",
    "o9515": "o9515",
}

DUMMY_LINE_RE = re.compile(
    r"^dummy ref=(?P<ref>-?\d+) parent=(?P<parent>-?\d+):(?P<parent_name>.*?) "
    r"attach=(?P<attach>-?\d+):(?P<attach_name>.*?) "
    r"pos=<(?P<pos>[^>]*)> fwd=<(?P<fwd>[^>]*)> up=<(?P<up>[^>]*)>"
)


def log(message: str) -> None:
    unreal.log(message)
    print(message)


def ensure_directory(asset_path: str) -> None:
    if unreal.EditorAssetLibrary.does_directory_exist(asset_path):
        return
    if not unreal.EditorAssetLibrary.make_directory(asset_path):
        raise RuntimeError(f"Failed to create directory: {asset_path}")


def sanitize_mtl_content(path: str) -> str:
    if not os.path.isfile(path):
        return ""
    with open(path, "r", encoding="utf-8") as handle:
        return handle.read().strip()


def write_combined_sheathed_obj() -> dict:
    parts = [
        os.path.join(OBJ_SOURCE_DIR, "WP_A_0300_L.obj"),
        os.path.join(OBJ_SOURCE_DIR, "WP_A_0300_1_L.obj"),
    ]
    for part in parts:
        if not os.path.isfile(part):
            raise RuntimeError(f"Combined sheathed source part not found: {part}")

    combined_mtl = os.path.join(OBJ_SOURCE_DIR, "WP_A_0300_L_CompleteSheathed.mtl")
    combined_lines = ["# Combined complete sheathed wp_a_0300_l", "mtllib WP_A_0300_L_CompleteSheathed.mtl", ""]
    vertex_offset = 0
    texcoord_offset = 0
    normal_offset = 0
    source_stats = []

    def remap_index(index_text: str, offset: int) -> str:
        if not index_text:
            return index_text
        value = int(index_text)
        if value > 0:
            return str(value + offset)
        return index_text

    def remap_face_token(token: str) -> str:
        values = token.split("/")
        if len(values) >= 1:
            values[0] = remap_index(values[0], vertex_offset)
        if len(values) >= 2:
            values[1] = remap_index(values[1], texcoord_offset)
        if len(values) >= 3:
            values[2] = remap_index(values[2], normal_offset)
        return "/".join(values)

    for part in parts:
        local_vertices = 0
        local_texcoords = 0
        local_normals = 0
        local_faces = 0
        combined_lines.append(f"o {os.path.splitext(os.path.basename(part))[0]}")
        with open(part, "r", encoding="utf-8") as handle:
            for raw_line in handle:
                line = raw_line.rstrip("\n")
                if not line or line.startswith("#") or line.startswith("mtllib "):
                    continue
                if line.startswith("v "):
                    local_vertices += 1
                    combined_lines.append(line)
                elif line.startswith("vt "):
                    local_texcoords += 1
                    combined_lines.append(line)
                elif line.startswith("vn "):
                    local_normals += 1
                    combined_lines.append(line)
                elif line.startswith("f "):
                    local_faces += 1
                    tokens = line.split()
                    combined_lines.append("f " + " ".join(remap_face_token(token) for token in tokens[1:]))
                else:
                    combined_lines.append(line)

        source_stats.append(
            {
                "source": part,
                "vertices": local_vertices,
                "texcoords": local_texcoords,
                "normals": local_normals,
                "faces": local_faces,
            }
        )
        vertex_offset += local_vertices
        texcoord_offset += local_texcoords
        normal_offset += local_normals
        combined_lines.append("")

    mtl_content = "\n\n".join(
        sanitize_mtl_content(os.path.splitext(part)[0] + ".mtl")
        for part in parts
        if sanitize_mtl_content(os.path.splitext(part)[0] + ".mtl")
    )
    with open(COMBINED_SHEATHED_SOURCE, "w", encoding="utf-8", newline="\n") as handle:
        handle.write("\n".join(combined_lines))
    with open(combined_mtl, "w", encoding="utf-8", newline="\n") as handle:
        handle.write(mtl_content + "\n")

    return {
        "output": COMBINED_SHEATHED_SOURCE,
        "mtl": combined_mtl,
        "vertices": vertex_offset,
        "texcoords": texcoord_offset,
        "normals": normal_offset,
        "sources": source_stats,
    }


def parse_vector(text: str) -> tuple[float, float, float]:
    parts = [float(part.strip()) for part in text.split(",")]
    if len(parts) != 3:
        raise RuntimeError(f"Expected 3-vector, got: {text}")
    return parts[0], parts[1], parts[2]


def flver_vector_to_ue(vector: tuple[float, float, float], scale: float) -> unreal.Vector:
    return unreal.Vector(vector[0] * scale, vector[1] * scale, -vector[2] * scale)


def flver_dummy_position_to_ue(vector: tuple[float, float, float]) -> unreal.Vector:
    return flver_vector_to_ue(vector, 100.0)


def sanitize_socket_token(value: str) -> str:
    token = re.sub(r"[^A-Za-z0-9_]+", "_", value.strip())
    return token.strip("_") or "none"


def parse_flver_dummies() -> list[dict]:
    if not os.path.isfile(FLVER_EXPORTER):
        raise RuntimeError(f"FLVER exporter not found: {FLVER_EXPORTER}")
    if not os.path.isfile(SOURCE_WP_A_0300_L_FLVER):
        raise RuntimeError(f"Source FLVER not found: {SOURCE_WP_A_0300_L_FLVER}")

    result = subprocess.run(
        [FLVER_EXPORTER, "--inspect", SOURCE_WP_A_0300_L_FLVER],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(f"FLVER dummy inspect failed: {result.stderr or result.stdout}")

    dummies = []
    for line in result.stdout.splitlines():
        match = DUMMY_LINE_RE.match(line.strip())
        if not match:
            continue

        index = len(dummies)
        reference_id = int(match.group("ref"))
        parent_name = match.group("parent_name")
        attach_name = match.group("attach_name")
        position = parse_vector(match.group("pos"))
        forward = parse_vector(match.group("fwd"))
        upward = parse_vector(match.group("up"))
        socket_name = (
            f"FLVERDummy_{reference_id:03d}_{index:02d}_"
            f"P_{sanitize_socket_token(parent_name)}_A_{sanitize_socket_token(attach_name)}"
        )
        dummies.append(
            {
                "index": index,
                "reference_id": reference_id,
                "parent_bone_index": int(match.group("parent")),
                "parent_bone": parent_name,
                "attach_bone_index": int(match.group("attach")),
                "attach_bone": attach_name,
                "position": position,
                "forward": forward,
                "upward": upward,
                "socket_name": socket_name,
            }
        )

    return dummies


def add_flver_dummy_sockets() -> dict:
    mesh_name = "SM_WP_A_0300_L_Sheathed"
    mesh = load_destination_asset(mesh_name)
    if not mesh:
        raise RuntimeError(f"Static mesh not found for socket import: {mesh_name}")

    dummies = parse_flver_dummies()
    added = []
    replaced = []
    mesh.modify()
    for reference_id in sorted({dummy["reference_id"] for dummy in dummies}):
        tag = f"FLVERDummy:{reference_id}"
        for socket in list(mesh.get_sockets_by_tag(tag)):
            mesh.remove_socket(socket)
            replaced.append(str(socket.get_editor_property("socket_name")))

    for dummy in dummies:
        socket_name = dummy["socket_name"]
        existing_socket = mesh.find_socket(socket_name)
        if existing_socket:
            mesh.remove_socket(existing_socket)
            replaced.append(socket_name)

        socket = unreal.new_object(
            unreal.StaticMeshSocket,
            outer=mesh,
            name=f"{socket_name}_Socket",
        )
        socket.set_editor_property("socket_name", socket_name)
        socket.set_editor_property("relative_location", flver_dummy_position_to_ue(dummy["position"]))
        forward = flver_vector_to_ue(dummy["forward"], 1.0)
        upward = flver_vector_to_ue(dummy["upward"], 1.0)
        socket.set_editor_property("relative_rotation", unreal.MathLibrary.make_rot_from_xz(forward, upward))
        socket.set_editor_property("relative_scale", unreal.Vector(1.0, 1.0, 1.0))
        socket.set_editor_property("tag", f"FLVERDummy:{dummy['reference_id']}")
        mesh.add_socket(socket)
        found_after_add = mesh.find_socket(socket_name) is not None
        added.append(
            {
                **dummy,
                "ue_location": str(socket.get_editor_property("relative_location")),
                "ue_rotation": str(socket.get_editor_property("relative_rotation")),
                "found_after_add": found_after_add,
            }
        )

    unreal.EditorAssetLibrary.save_loaded_asset(mesh)
    unreal.EditorAssetLibrary.save_asset(f"{DESTINATION}/{mesh_name}.{mesh_name}", only_if_is_dirty=False)
    return {
        "mesh": mesh.get_path_name(),
        "source_flver": SOURCE_WP_A_0300_L_FLVER,
        "socket_count": len(added),
        "replaced_sockets": replaced,
        "sockets": added,
    }


def create_import_task(filename: str, destination_path: str, destination_name: str):
    task = unreal.AssetImportTask()
    task.set_editor_property("filename", filename)
    task.set_editor_property("destination_path", destination_path)
    task.set_editor_property("destination_name", destination_name)
    task.set_editor_property("automated", True)
    task.set_editor_property("replace_existing", True)
    task.set_editor_property("replace_existing_settings", True)
    task.set_editor_property("save", True)
    return task


def try_set(obj, property_name: str, value) -> bool:
    try:
        obj.set_editor_property(property_name, value)
        return True
    except Exception as exc:
        log(f"[WP_A_0300] Skip property {property_name}: {exc}")
        return False


def load_destination_asset(name: str):
    return unreal.load_asset(f"{DESTINATION}/{name}.{name}")


def inspect_source_material_assets() -> list[dict]:
    inspected = []
    for source_name, asset_name in SOURCE_MATERIAL_ASSETS.items():
        asset = load_destination_asset(asset_name)
        if not asset:
            inspected.append({"source_material": source_name, "asset": asset_name, "status": "missing"})
            continue

        inspected.append(
            {
                "source_material": source_name,
                "asset": asset.get_path_name(),
                "class": asset.get_class().get_name(),
                "status": "available",
            }
        )
    return inspected


def import_static_meshes() -> list[dict]:
    tasks = []
    for mesh_info in STATIC_MESHES:
        source = mesh_info["source"]
        if not os.path.isfile(source):
            raise RuntimeError(f"OBJ source not found: {source}")
        tasks.append(create_import_task(source, DESTINATION, mesh_info["asset_name"]))

    unreal.AssetToolsHelpers.get_asset_tools().import_asset_tasks(tasks)

    reports = []
    for mesh_info, task in zip(STATIC_MESHES, tasks):
        asset_name = mesh_info["asset_name"]
        asset_path = f"{DESTINATION}/{asset_name}.{asset_name}"
        mesh = unreal.load_asset(asset_path)
        if not mesh:
            raise RuntimeError(f"Static mesh import did not create {asset_path}")
        unreal.EditorAssetLibrary.save_loaded_asset(mesh)
        reports.append(
            {
                "source": mesh_info["source"],
                "asset_path": asset_path,
                "description": mesh_info["description"],
                "imported_object_paths": [str(path) for path in task.get_editor_property("imported_object_paths")],
                "material_slot_count": len(mesh.get_editor_property("static_materials")),
            }
        )
    return reports


def assign_materials() -> list[dict]:
    material_cache = {}
    for source_name, asset_name in SOURCE_MATERIAL_ASSETS.items():
        material = load_destination_asset(asset_name)
        if material:
            material_cache[source_name.lower()] = material

    reports = []
    for mesh_info in STATIC_MESHES:
        asset_name = mesh_info["asset_name"]
        asset_path = f"{DESTINATION}/{asset_name}.{asset_name}"
        mesh = unreal.load_asset(asset_path)
        if not mesh:
            continue

        assignments = []
        for slot_index, static_material in enumerate(mesh.get_editor_property("static_materials")):
            slot_name = str(static_material.get_editor_property("material_slot_name")).lower()
            target_material = None
            if "material__732" in slot_name or "blade" in slot_name:
                target_material = material_cache.get("material__732")
            elif "o9515" in slot_name:
                target_material = material_cache.get("o9515")
            elif "0300_4_weapon" in slot_name:
                target_material = material_cache.get("0300_4_weapon")

            if target_material:
                mesh.set_material(slot_index, target_material)
                assignments.append(
                    {
                        "slot_index": slot_index,
                        "slot_name": slot_name,
                        "material": target_material.get_path_name(),
                    }
                )

        unreal.EditorAssetLibrary.save_loaded_asset(mesh)
        reports.append({"mesh": asset_path, "assignments": assignments})

    return reports


def inspect_destination_assets() -> list[dict]:
    result = []
    for asset_path in sorted(unreal.EditorAssetLibrary.list_assets(DESTINATION, recursive=False, include_folder=False)):
        if "0300" not in asset_path:
            continue
        asset = unreal.load_asset(asset_path)
        result.append(
            {
                "path": asset_path,
                "class": asset.get_class().get_name() if asset else None,
            }
        )
    return result


def write_report(report: dict) -> None:
    os.makedirs(os.path.dirname(REPORT_PATH), exist_ok=True)
    with open(REPORT_PATH, "w", encoding="utf-8") as handle:
        json.dump(report, handle, ensure_ascii=False, indent=2)


def main() -> None:
    ensure_directory(DESTINATION)
    combined_sheathed_report = write_combined_sheathed_obj()
    report = {
        "destination": DESTINATION,
        "combined_sheathed_source": combined_sheathed_report,
        "static_meshes": import_static_meshes(),
        "skipped_empty_sources": SOURCE_EMPTY_MESHES,
        "source_material_assets": inspect_source_material_assets(),
        "materials": assign_materials(),
        "flver_dummy_sockets": add_flver_dummy_sockets(),
        "destination_assets": inspect_destination_assets(),
    }
    write_report(report)
    log(f"[WP_A_0300] Import complete. Report: {REPORT_PATH}")


try:
    main()
except Exception as exc:
    write_report({"error": str(exc), "traceback": traceback.format_exc()})
    log(f"[WP_A_0300] Import failed: {exc}")
    raise
