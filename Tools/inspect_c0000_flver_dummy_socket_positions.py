import json
import os
import traceback

import unreal


PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
MESH_PATH = "/Game/Animation/Sekiro/C0000/Base/c0000_bindpose.c0000_bindpose"
REPORT_PATH = os.path.join(PROJECT_ROOT, "Saved", "SekiroImportReports", "c0000_flver_dummy_socket_positions.json")

SOCKETS = [
    "C0000_FLVERDummy_024_Ref029_A_Spine",
    "C0000_FLVERDummy_086_Ref148_A_Spine",
    "C0000_FLVERDummy_115_Ref190_A_Spine1",
    "C0000_FLVERDummy_120_Ref190_A_Spine1",
    "C0000_FLVERDummy_025_Ref030_A_L_Wepon_Case",
    "C0000_FLVERDummy_026_Ref031_A_R_Wepon_Case",
    "C0000_FLVERDummy_088_Ref160_A_R_Wepon_Case",
    "C0000_FLVERDummy_089_Ref161_A_R_Wepon_Case",
    "C0000_FLVERDummy_090_Ref162_A_R_Wepon_Case",
    "C0000_FLVERDummy_044_Ref047_A_Spine2",
    "C0000_FLVERDummy_520_Ref015_A_B_Wepon_Case0_L",
    "C0000_FLVERDummy_521_Ref015_A_B_Wepon_Case",
    "C0000_FLVERDummy_522_Ref015_A_B_Wepon_Case0_R",
    "C0000_FLVERDummy_528_Ref015_A_LargeSheath",
    "C0000_FLVERDummy_529_Ref015_A_SpineArmor1",
    "C0000_FLVERDummy_530_Ref015_A_SpineArmor2",
    "C0000_FLVERDummy_431_Ref015_A_Spine2",
]


def vector_to_dict(value: unreal.Vector) -> dict:
    return {"x": value.x, "y": value.y, "z": value.z}


def rotator_to_dict(value: unreal.Rotator) -> dict:
    return {"pitch": value.pitch, "yaw": value.yaw, "roll": value.roll}


def write_report(report: dict) -> None:
    os.makedirs(os.path.dirname(REPORT_PATH), exist_ok=True)
    with open(REPORT_PATH, "w", encoding="utf-8") as handle:
        json.dump(report, handle, ensure_ascii=False, indent=2)


def main() -> None:
    mesh = unreal.load_asset(MESH_PATH)
    if not mesh:
        raise RuntimeError(f"Failed to load skeletal mesh: {MESH_PATH}")

    reference_pose = mesh.get_editor_property("skeleton").get_reference_pose()

    sockets = []
    for socket_name in SOCKETS:
        socket = mesh.find_socket(socket_name)
        if not socket:
            sockets.append({"socket_name": socket_name, "exists": False})
            continue
        parent_bone = str(socket.get_editor_property("bone_name"))
        relative_transform = unreal.Transform(
            socket.get_editor_property("relative_location"),
            socket.get_editor_property("relative_rotation"),
            socket.get_editor_property("relative_scale"),
        )
        bone_component_transform = reference_pose.get_ref_bone_pose(
            parent_bone,
            unreal.AnimPoseSpaces.WORLD,
        )
        transform = relative_transform * bone_component_transform
        sockets.append(
            {
                "socket_name": socket_name,
                "exists": True,
                "parent_bone": parent_bone,
                "location": vector_to_dict(transform.translation),
                "rotation": rotator_to_dict(transform.rotation.rotator()),
                "scale": vector_to_dict(transform.scale3d),
            }
        )

    pairs = []
    existing = [socket for socket in sockets if socket.get("exists")]
    for left in existing:
        for right in existing:
            if left["socket_name"] == right["socket_name"]:
                continue
            a = unreal.Vector(**left["location"])
            b = unreal.Vector(**right["location"])
            span = b - a
            pairs.append(
                {
                    "socket1": left["socket_name"],
                    "socket2": right["socket_name"],
                    "span": vector_to_dict(span),
                    "distance": span.length(),
                }
            )

    write_report({"mesh": MESH_PATH, "sockets": sockets, "pairs": pairs})
    unreal.log(f"[C0000 Dummy Positions] Report: {REPORT_PATH}")


try:
    main()
except Exception as exc:
    write_report({"error": str(exc), "traceback": traceback.format_exc()})
    unreal.log(f"[C0000 Dummy Positions] Failed: {exc}")
    raise
