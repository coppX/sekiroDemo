import json
import os
import traceback

import unreal


SKELETON_PATH = "/Game/Animation/Sekiro/C0000/Base/c0000_bindpose_Skeleton.c0000_bindpose_Skeleton"
REPORT_PATH = r"E:\UEProj\Sekiro\SekiroDemo\Saved\Codex\skeleton_api_probe.json"


def main():
    report = {"skeleton": SKELETON_PATH, "status": "running"}
    try:
        skeleton = unreal.load_asset(SKELETON_PATH)
        report["class"] = str(skeleton.get_class().get_name()) if skeleton else None
        names = [name for name in dir(skeleton) if "bone" in name.lower() or "ref" in name.lower()]
        report["bone_api_names"] = names
        for method_name in [
            "get_reference_skeleton",
            "get_bone_tree",
            "get_bone_name",
            "get_parent_index",
            "get_reference_pose",
        ]:
            report[method_name] = hasattr(skeleton, method_name)
        if hasattr(skeleton, "get_reference_skeleton"):
            ref = skeleton.get_reference_skeleton()
            report["ref_type"] = str(type(ref))
            report["ref_dir"] = [name for name in dir(ref) if "bone" in name.lower() or "parent" in name.lower() or "ref" in name.lower()]
        if hasattr(skeleton, "get_reference_pose"):
            pose = skeleton.get_reference_pose()
            report["reference_pose_type"] = str(type(pose))
            report["reference_pose_dir"] = [
                name
                for name in dir(pose)
                if "bone" in name.lower() or "parent" in name.lower() or "name" in name.lower() or "transform" in name.lower()
            ]
            try:
                report["reference_pose_len"] = len(pose)
                report["reference_pose_first"] = str(pose[0]) if len(pose) else None
            except Exception as pose_exc:
                report["reference_pose_len_error"] = str(pose_exc)
            try:
                bone_names = [str(name) for name in pose.get_bone_names()]
                report["bone_count"] = len(bone_names)
                report["first_bones"] = bone_names[:30]
                report["all_bones"] = bone_names
                report["interesting_bones"] = {
                    target: [i for i, name in enumerate(bone_names) if name.lower() == target.lower()]
                    for target in ["Master", "master", "RootPos", "rootpos", "RootRotY", "rootroty", "Pelvis", "Spine"]
                }
                report["pose_api_probe"] = {}
                for target in ["Master", "RootPos", "RootRotY", "Pelvis", "Spine"]:
                    try:
                        report["pose_api_probe"][target] = {
                            "bone_pose": str(pose.get_bone_pose(target)),
                            "ref_bone_pose": str(pose.get_ref_bone_pose(target)),
                            "ref_pose_relative": str(pose.get_ref_pose_relative_transform(target)),
                        }
                    except Exception as target_exc:
                        report["pose_api_probe"][target] = {"error": str(target_exc)}
            except Exception as names_exc:
                report["bone_names_error"] = str(names_exc)
        report["status"] = "success"
    except Exception as exc:
        report["status"] = "failed"
        report["error"] = str(exc)
        report["traceback"] = traceback.format_exc()
        raise
    finally:
        os.makedirs(os.path.dirname(REPORT_PATH), exist_ok=True)
        with open(REPORT_PATH, "w", encoding="utf-8") as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
