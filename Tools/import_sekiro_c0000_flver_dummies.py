import json
import os
import re
import subprocess
import traceback

import unreal


PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
GAME_ROOT = r"E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE"
SOURCE_C0000_CHRBND = os.path.join(GAME_ROOT, "chr", "c0000.chrbnd.dcx")
FLVER_EXPORTER = os.path.join(
    PROJECT_ROOT,
    "Tools",
    "SekiroFlverObjExporter",
    "bin",
    "Release",
    "net8.0",
    "SekiroFlverObjExporter.exe",
)
MESH_PATH = "/Game/Animation/Sekiro/C0000/Base/c0000_bindpose.c0000_bindpose"
REPORT_PATH = os.path.join(PROJECT_ROOT, "Saved", "SekiroImportReports", "c0000_flver_dummy_socket_import.json")

DUMMY_PREFIX = "C0000_FLVERDummy_"
DUMMY_LINE_RE = re.compile(
    r"^dummy ref=(?P<ref>-?\d+) parent=(?P<parent>-?\d+):(?P<parent_name>.*?) "
    r"attach=(?P<attach>-?\d+):(?P<attach_name>.*?) "
    r"pos=<(?P<pos>[^>]*)> fwd=<(?P<fwd>[^>]*)> up=<(?P<up>[^>]*)>"
)


def log(message: str) -> None:
    unreal.log(message)
    print(message)


def parse_vector(text: str) -> tuple[float, float, float]:
    values = [float(part.strip()) for part in text.split(",")]
    if len(values) != 3:
        raise RuntimeError(f"Expected a 3-vector, got: {text}")
    return values[0], values[1], values[2]


def flver_vector_to_ue(vector: tuple[float, float, float], scale: float) -> unreal.Vector:
    return unreal.Vector(vector[0] * scale, -vector[2] * scale, vector[1] * scale)


def flver_dummy_position_to_ue(vector: tuple[float, float, float]) -> unreal.Vector:
    return flver_vector_to_ue(vector, 100.0)


def flver_dummy_rotation_to_ue(dummy: dict) -> unreal.Rotator:
    forward = flver_vector_to_ue(dummy["forward"], 1.0)
    upward = flver_vector_to_ue(dummy["upward"], 1.0)
    return unreal.MathLibrary.make_rot_from_xz(forward, upward)


def is_joint_geometry_dummy(dummy: dict) -> bool:
    return dummy["reference_id"] == 15 and dummy["parent_bone"] == "間接ジオメトリ用ダミー"


def sanitize_socket_token(value: str) -> str:
    token = re.sub(r"[^A-Za-z0-9_]+", "_", value.strip())
    return token.strip("_") or "none"


def make_socket_name(dummy: dict) -> str:
    return (
        f"{DUMMY_PREFIX}{dummy['index']:03d}_Ref{dummy['reference_id']:03d}_"
        f"A_{sanitize_socket_token(dummy['attach_bone'])}"
    )


def run_flver_inspect_all() -> str:
    if not os.path.isfile(FLVER_EXPORTER):
        raise RuntimeError(f"FLVER exporter not found: {FLVER_EXPORTER}")
    if not os.path.isfile(SOURCE_C0000_CHRBND):
        raise RuntimeError(f"Source c0000 chrbnd not found: {SOURCE_C0000_CHRBND}")

    env = dict(os.environ)
    env["PATH"] = GAME_ROOT + os.pathsep + env.get("PATH", "")
    result = subprocess.run(
        [FLVER_EXPORTER, "--inspect-all", SOURCE_C0000_CHRBND],
        capture_output=True,
        text=True,
        check=False,
        env=env,
    )
    if result.returncode != 0:
        raise RuntimeError(f"FLVER dummy inspect failed: {result.stderr or result.stdout}")
    return result.stdout


def parse_flver_dummies() -> list[dict]:
    dummies = []
    for line in run_flver_inspect_all().splitlines():
        match = DUMMY_LINE_RE.match(line.strip())
        if not match:
            continue

        dummy = {
            "index": len(dummies),
            "reference_id": int(match.group("ref")),
            "parent_bone_index": int(match.group("parent")),
            "parent_bone": match.group("parent_name"),
            "attach_bone_index": int(match.group("attach")),
            "attach_bone": match.group("attach_name"),
            "position": parse_vector(match.group("pos")),
            "forward": parse_vector(match.group("fwd")),
            "upward": parse_vector(match.group("up")),
        }
        dummy["socket_name"] = make_socket_name(dummy)
        dummies.append(dummy)
    return dummies


def get_reference_bone_names(mesh) -> set[str]:
    skeleton = mesh.get_editor_property("skeleton")
    reference_pose = skeleton.get_reference_pose()
    return {str(name) for name in reference_pose.get_bone_names()}


def find_socket(mesh, socket_name: str):
    return mesh.find_socket(socket_name)


def rename_socket(mesh, socket, socket_name: str) -> None:
    old_name = str(socket.get_editor_property("socket_name"))
    if old_name == socket_name:
        return

    attempts = (
        lambda: mesh.rename_socket(socket, socket_name),
        lambda: mesh.rename_socket(old_name, socket_name),
        lambda: mesh.rename_socket(socket, unreal.Name(socket_name)),
        lambda: mesh.rename_socket(unreal.Name(old_name), unreal.Name(socket_name)),
    )
    errors = []
    for attempt in attempts:
        try:
            attempt()
            if str(socket.get_editor_property("socket_name")) == socket_name:
                return
        except Exception as exc:
            errors.append(str(exc))
    raise RuntimeError(f"Failed to rename socket {old_name} to {socket_name}: {' | '.join(errors)}")


def add_dummy_socket(mesh, reference_pose, dummy: dict) -> dict:
    socket = find_socket(mesh, dummy["socket_name"])
    existed = socket is not None
    if not socket:
        socket = unreal.new_object(
            unreal.SkeletalMeshSocket,
            outer=mesh,
            name=f"{dummy['socket_name']}_Object",
        )
        mesh.add_socket(socket)
        rename_socket(mesh, socket, dummy["socket_name"])

    bone_component_transform = reference_pose.get_ref_bone_pose(
        dummy["attach_bone"],
        unreal.AnimPoseSpaces.WORLD,
    )
    if is_joint_geometry_dummy(dummy):
        dummy_component_location = bone_component_transform.translation
        dummy_component_rotation = bone_component_transform.rotation.rotator()
        relative_location = unreal.Vector(0.0, 0.0, 0.0)
        relative_rotation = unreal.Rotator(0.0, 0.0, 0.0)
    else:
        dummy_component_location = flver_dummy_position_to_ue(dummy["position"])
        dummy_component_rotation = flver_dummy_rotation_to_ue(dummy)
        relative_location = bone_component_transform.inverse_transform_location(dummy_component_location)
        relative_rotation = bone_component_transform.inverse_transform_rotation(dummy_component_rotation)

    socket.set_socket_parent(mesh, dummy["attach_bone"])
    socket.set_editor_property("relative_location", relative_location)
    socket.set_editor_property("relative_rotation", relative_rotation)
    socket.set_editor_property("relative_scale", unreal.Vector(1.0, 1.0, 1.0))
    return {
        **dummy,
        "existed": existed,
        "ue_component_location": str(dummy_component_location),
        "ue_component_rotation": str(dummy_component_rotation),
        "ue_attach_bone_component_location": str(bone_component_transform.translation),
        "ue_location": str(socket.get_editor_property("relative_location")),
        "ue_rotation": str(socket.get_editor_property("relative_rotation")),
        "ue_scale": str(socket.get_editor_property("relative_scale")),
    }


def is_back_or_weapon_related(dummy: dict) -> bool:
    names = " ".join((dummy["parent_bone"], dummy["attach_bone"], dummy["socket_name"])).lower()
    return any(
        token in names
        for token in (
            "weapon",
            "wepon",
            "spine",
            "case",
            "armor",
            "sfx",
            "model_dmy",
            "dummy",
        )
    )


def write_report(report: dict) -> None:
    os.makedirs(os.path.dirname(REPORT_PATH), exist_ok=True)
    with open(REPORT_PATH, "w", encoding="utf-8") as handle:
        json.dump(report, handle, ensure_ascii=False, indent=2)


def main() -> None:
    mesh = unreal.load_asset(MESH_PATH)
    if not mesh:
        raise RuntimeError(f"Failed to load skeletal mesh: {MESH_PATH}")

    dummies = parse_flver_dummies()
    reference_bones = get_reference_bone_names(mesh)
    importable = [dummy for dummy in dummies if dummy["attach_bone"] in reference_bones]
    skipped = [
        {
            **dummy,
            "reason": "attach bone is not present in current UE skeleton",
        }
        for dummy in dummies
        if dummy["attach_bone"] not in reference_bones
    ]

    reference_pose = mesh.get_editor_property("skeleton").get_reference_pose()

    mesh.modify()
    imported = [add_dummy_socket(mesh, reference_pose, dummy) for dummy in importable]
    unreal.EditorAssetLibrary.save_loaded_asset(mesh)
    unreal.EditorAssetLibrary.save_asset(MESH_PATH, only_if_is_dirty=False)

    back_weapon_candidates = [
        imported_dummy
        for imported_dummy in imported
        if is_back_or_weapon_related(imported_dummy)
    ]
    report = {
        "mesh": MESH_PATH,
        "source": SOURCE_C0000_CHRBND,
        "source_dummy_count": len(dummies),
        "imported_socket_count": len(imported),
        "updated_existing_socket_count": len([dummy for dummy in imported if dummy["existed"]]),
        "skipped_dummy_count": len(skipped),
        "back_weapon_candidate_count": len(back_weapon_candidates),
        "back_weapon_candidates": back_weapon_candidates,
        "imported_sockets": imported,
        "skipped_dummies": skipped,
    }
    write_report(report)
    log(f"[C0000 FLVER Dummies] Imported {len(imported)} sockets, skipped {len(skipped)}. Report: {REPORT_PATH}")


try:
    main()
except Exception as exc:
    write_report({"error": str(exc), "traceback": traceback.format_exc()})
    log(f"[C0000 FLVER Dummies] Import failed: {exc}")
    raise
