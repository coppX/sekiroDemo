import json
import math
import os
import traceback

import unreal


ASSET_PATH = "/Game/Animation/Sekiro/C0000/GroundAttack_SM/a050_300020.a050_300020"
DESTINATION_PATH = "/Game/Animation/Sekiro/C0000/GroundAttack_SM"
SKELETON_PATH = "/Game/Animation/Sekiro/C0000/Base/c0000_bindpose_Skeleton.c0000_bindpose_Skeleton"
SOURCE_FBX = (
    r"E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE"
    r"\exports\c0000_ground_attack_root_reimport_all\a050_300020.fbx"
)
SOURCE_JSON = (
    r"E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE"
    r"\exports\c0000_ground_attack_root_reimport_all\_intermediate\anim_a050_300020.hkx.json"
)
REPORT_PATH = r"E:\UEProj\Sekiro\SekiroDemo\Saved\Codex\combo3_hkx_style_restore_report.json"


def log(message):
    unreal.log(message)
    print(message)


def q_yaw_degrees(quat):
    x = quat.x
    y = quat.y
    z = quat.z
    w = quat.w
    length = math.sqrt(x * x + y * y + z * z + w * w) or 1.0
    x /= length
    y /= length
    z /= length
    w /= length
    fx = 2.0 * (x * z + w * y)
    fz = 1.0 - 2.0 * (x * x + y * y)
    return math.degrees(math.atan2(fx, fz))


def unwrap(values):
    result = []
    offset = 0.0
    previous = None
    for value in values:
        if previous is not None:
            delta = value - previous
            if delta > 180.0:
                offset -= 360.0
            elif delta < -180.0:
                offset += 360.0
        result.append(value + offset)
        previous = value
    return result


def create_import_options(skeleton):
    options = unreal.FbxImportUI()
    options.set_editor_property("automated_import_should_detect_type", False)
    options.set_editor_property("original_import_type", unreal.FBXImportType.FBXIT_ANIMATION)
    options.set_editor_property("mesh_type_to_import", unreal.FBXImportType.FBXIT_ANIMATION)
    options.set_editor_property("import_as_skeletal", True)
    options.set_editor_property("import_mesh", False)
    options.set_editor_property("import_animations", True)
    options.set_editor_property("import_materials", False)
    options.set_editor_property("import_textures", False)
    options.set_editor_property("skeleton", skeleton)

    animation_data = options.get_editor_property("anim_sequence_import_data")
    animation_data.set_editor_property("animation_length", unreal.FBXAnimationLengthImportType.FBXALIT_EXPORTED_TIME)
    animation_data.set_editor_property("import_bone_tracks", True)
    animation_data.set_editor_property("remove_redundant_keys", False)
    return options


def set_root_motion_settings(anim):
    anim_lib = getattr(unreal, "AnimationLibrary", None)
    if anim_lib is None:
        anim_lib = getattr(unreal, "AnimationBlueprintLibrary", None)
    if anim_lib is None:
        raise RuntimeError("AnimationLibrary/AnimationBlueprintLibrary is unavailable.")

    anim_lib.set_root_motion_enabled(anim, True)
    if hasattr(unreal, "RootMotionRootLock"):
        anim_lib.set_root_motion_lock_type(anim, unreal.RootMotionRootLock.ANIM_FIRST_FRAME)
    anim_lib.set_is_root_motion_lock_forced(anim, False)

    def try_set(property_name, value):
        try:
            anim.set_editor_property(property_name, value)
        except Exception:
            pass

    try_set("enable_root_motion", True)
    try_set("force_root_lock", False)
    try_set("use_normalized_root_motion_scale", True)


def restore_master_root_motion_translation(anim):
    with open(SOURCE_JSON, "r", encoding="utf-8") as json_file:
        source = json.load(json_file)

    root_frames = source["root_motion"]["frames"]
    anim_lib = getattr(unreal, "AnimationLibrary", None)
    if anim_lib is None:
        anim_lib = getattr(unreal, "AnimationBlueprintLibrary", None)

    positions = []
    rotations = []
    scales = []
    first_master_pose = anim_lib.get_bone_pose_for_frame(anim, "master", 0, False)
    for frame_index, root_frame in enumerate(root_frames):
        # HKX root_motion is exported along its local Z axis. In this project the
        # already-validated UE mapping is Master local Y+ for actor forward.
        positions.append(unreal.Vector(0.0, float(root_frame[2]), 0.0))
        current = anim_lib.get_bone_pose_for_frame(anim, "master", frame_index, False)
        # UE extracts rotation from the root track and applies it to the Actor.
        # The Sekiro visual spin belongs to RootRotY/Pelvis, not to Master.
        rotations.append(first_master_pose.rotation)
        scales.append(current.scale3d)

    controller = anim.controller
    controller.set_bone_track_keys("master", positions, rotations, scales, True)
    return {
        "source_json": SOURCE_JSON,
        "master_translation_start": [0.0, root_frames[0][2], 0.0],
        "master_translation_end": [0.0, root_frames[-1][2], 0.0],
        "key_count": len(root_frames),
    }


def sample_bone_yaws(anim):
    anim_lib = getattr(unreal, "AnimationLibrary", None)
    if anim_lib is None:
        anim_lib = getattr(unreal, "AnimationBlueprintLibrary", None)
    sample_times = [0.0, 0.1, 0.3, 0.6, 0.7, 1.0, 1.5, max(0.0, anim.get_play_length() - 0.001)]
    bones = ["Master", "RootPos", "RootRotY", "Pelvis"]
    result = {}
    for bone in bones:
        raw_yaws = []
        samples = []
        for time in sample_times:
            transform = anim_lib.get_bone_pose_for_time(anim, bone, time, False)
            yaw = q_yaw_degrees(transform.rotation)
            raw_yaws.append(yaw)
            samples.append({"t": round(time, 3), "yaw": round(yaw, 3)})
        unwrapped = unwrap(raw_yaws)
        result[bone] = {
            "samples": samples,
            "unwrapped_start_mid_end": [
                round(unwrapped[0], 3),
                round(unwrapped[len(unwrapped) // 2], 3),
                round(unwrapped[-1], 3),
            ],
            "unwrapped_delta": round(unwrapped[-1] - unwrapped[0], 3),
        }
    return result


def main():
    report = {
        "asset": ASSET_PATH,
        "source_fbx": SOURCE_FBX,
        "status": "running",
    }
    try:
        if not os.path.isfile(SOURCE_FBX):
            raise FileNotFoundError(SOURCE_FBX)
        skeleton = unreal.load_asset(SKELETON_PATH)
        if skeleton is None:
            raise RuntimeError(f"Missing skeleton: {SKELETON_PATH}")

        task = unreal.AssetImportTask()
        task.set_editor_property("filename", SOURCE_FBX)
        task.set_editor_property("destination_path", DESTINATION_PATH)
        task.set_editor_property("automated", True)
        task.set_editor_property("replace_existing", True)
        task.set_editor_property("replace_existing_settings", True)
        task.set_editor_property("save", True)
        task.set_editor_property("options", create_import_options(skeleton))

        unreal.AssetToolsHelpers.get_asset_tools().import_asset_tasks([task])
        imported_paths = [str(path) for path in task.get_editor_property("imported_object_paths")]
        anim = unreal.load_asset(ASSET_PATH)
        if anim is None:
            raise RuntimeError(f"Failed to load imported asset: {ASSET_PATH}")

        set_root_motion_settings(anim)
        master_root_motion = restore_master_root_motion_translation(anim)
        unreal.EditorAssetLibrary.save_loaded_asset(anim)

        report.update(
            {
                "status": "success",
                "imported_object_paths": imported_paths,
                "root_motion_enabled": bool(
                    getattr(unreal, "AnimationLibrary").is_root_motion_enabled(anim)
                    if hasattr(unreal, "AnimationLibrary")
                    else True
                ),
                "master_root_motion": master_root_motion,
                "play_length": anim.get_play_length(),
                "bone_yaw_samples": sample_bone_yaws(anim),
            }
        )
        log("[Combo3Restore] restored a050_300020 from FBX and saved.")
    except Exception as exc:
        report["status"] = "failed"
        report["error"] = str(exc)
        report["traceback"] = traceback.format_exc()
        unreal.log_error(report["traceback"])
        raise
    finally:
        os.makedirs(os.path.dirname(REPORT_PATH), exist_ok=True)
        with open(REPORT_PATH, "w", encoding="utf-8") as report_file:
            json.dump(report, report_file, ensure_ascii=False, indent=2)
        print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
