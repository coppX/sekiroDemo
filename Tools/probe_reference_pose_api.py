import json
import os

import unreal


PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
REPORT_PATH = os.path.join(PROJECT_ROOT, "Saved", "SekiroImportReports", "reference_pose_api_probe.json")


def safe_call(label, func):
    try:
        value = func()
        return {"ok": True, "value": str(value), "type": type(value).__name__}
    except Exception as exc:
        return {"ok": False, "error": str(exc)}


def main():
    mesh = unreal.load_asset("/Game/Animation/Sekiro/C0000/Base/c0000_bindpose.c0000_bindpose")
    skeleton = mesh.get_editor_property("skeleton")
    ref = skeleton.get_reference_pose()
    names = ref.get_bone_names()
    spine_index = list(map(str, names)).index("Spine")
    case_index = list(map(str, names)).index("B_Wepon_Case0_L")
    report = {
        "ref_dir": [name for name in dir(ref) if "bone" in name.lower() or "pose" in name.lower() or "transform" in name.lower() or "parent" in name.lower()],
        "spine_index": spine_index,
        "case_index": case_index,
        "calls": {
            "get_ref_bone_pose_spine_local": safe_call("get_ref_bone_pose_spine_local", lambda: ref.get_ref_bone_pose("Spine", unreal.AnimPoseSpaces.LOCAL)),
            "get_ref_bone_pose_spine_world": safe_call("get_ref_bone_pose_spine_world", lambda: ref.get_ref_bone_pose("Spine", unreal.AnimPoseSpaces.WORLD)),
            "get_ref_bone_pose_case_world": safe_call("get_ref_bone_pose_case_world", lambda: ref.get_ref_bone_pose("B_Wepon_Case0_L", unreal.AnimPoseSpaces.WORLD)),
            "get_ref_pose_relative_case_spine": safe_call("get_ref_pose_relative_case_spine", lambda: ref.get_ref_pose_relative_transform("B_Wepon_Case0_L", "Spine", unreal.AnimPoseSpaces.WORLD)),
        },
    }
    os.makedirs(os.path.dirname(REPORT_PATH), exist_ok=True)
    with open(REPORT_PATH, "w", encoding="utf-8") as handle:
        json.dump(report, handle, ensure_ascii=False, indent=2)


main()
