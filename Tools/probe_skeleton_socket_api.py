import json
import os

import unreal


PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
REPORT_PATH = os.path.join(PROJECT_ROOT, "Saved", "SekiroImportReports", "skeleton_socket_api_probe.json")


def safe_get(obj, prop):
    try:
        value = obj.get_editor_property(prop)
        return {"ok": True, "value": str(value)}
    except Exception as exc:
        return {"ok": False, "error": str(exc)}


def main():
    skeleton = unreal.load_asset("/Game/Animation/Sekiro/C0000/Base/c0000_bindpose_Skeleton.c0000_bindpose_Skeleton")
    mesh = unreal.load_asset("/Game/Animation/Sekiro/C0000/Base/c0000_bindpose.c0000_bindpose")
    socket = unreal.new_object(unreal.SkeletalMeshSocket, outer=skeleton, name="TempSocketProbe")
    report = {
        "skeleton_dir": [name for name in dir(skeleton) if "socket" in name.lower() or "bone" in name.lower()],
        "mesh_dir": [name for name in dir(mesh) if "socket" in name.lower() or "bone" in name.lower()],
        "socket_dir": [name for name in dir(socket) if "socket" in name.lower() or "bone" in name.lower() or "transform" in name.lower() or "parent" in name.lower()],
        "socket_props": {
            prop: safe_get(socket, prop)
            for prop in (
                "socket_name",
                "bone_name",
                "relative_location",
                "relative_rotation",
                "relative_scale",
                "tag",
            )
        },
    }
    os.makedirs(os.path.dirname(REPORT_PATH), exist_ok=True)
    with open(REPORT_PATH, "w", encoding="utf-8") as handle:
        json.dump(report, handle, ensure_ascii=False, indent=2)


main()
