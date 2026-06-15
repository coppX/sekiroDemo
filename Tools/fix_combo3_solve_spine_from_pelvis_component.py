import json
import math
import os
import shutil
import time
import traceback

import unreal


ASSET_PATH = "/Game/Animation/Sekiro/C0000/GroundAttack_SM/a050_300020.a050_300020"
DISK_PATH = r"E:\UEProj\Sekiro\SekiroDemo\Content\Animation\Sekiro\C0000\GroundAttack_SM\a050_300020.uasset"
MODEL_JSON = (
    r"E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE"
    r"\exports\alias_probe_11\_intermediate\model.json"
)
REPORT_PATH = r"E:\UEProj\Sekiro\SekiroDemo\Saved\Codex\combo3_solve_spine_from_pelvis_component_report.json"


def q_normalize(q):
    length = math.sqrt(q.x * q.x + q.y * q.y + q.z * q.z + q.w * q.w) or 1.0
    return unreal.Quat(q.x / length, q.y / length, q.z / length, q.w / length)


def q_inverse(q):
    q = q_normalize(q)
    return unreal.Quat(-q.x, -q.y, -q.z, q.w)


def q_mul(a, b):
    a = q_normalize(a)
    b = q_normalize(b)
    return q_normalize(
        unreal.Quat(
            a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,
            a.w * b.y - a.x * b.z + a.y * b.w + a.z * b.x,
            a.w * b.z + a.x * b.y - a.y * b.x + a.z * b.w,
            a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z,
        )
    )


def q_from_list(values):
    return q_normalize(unreal.Quat(float(values[0]), float(values[1]), float(values[2]), float(values[3])))


def q_angle_degrees(a, b):
    delta = q_mul(q_inverse(a), b)
    delta = q_normalize(delta)
    w = max(-1.0, min(1.0, abs(delta.w)))
    return math.degrees(2.0 * math.acos(w))


def q_yaw(q):
    q = q_normalize(q)
    fx = 2.0 * (q.x * q.z + q.w * q.y)
    fz = 1.0 - 2.0 * (q.x * q.x + q.y * q.y)
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


def summarize_curve(values):
    values = unwrap(values)
    return {
        "start": round(values[0], 3),
        "end": round(values[-1], 3),
        "delta": round(values[-1] - values[0], 3),
        "min": round(min(values), 3),
        "max": round(max(values), 3),
    }


def load_reference_spine_offset():
    model = json.load(open(MODEL_JSON, encoding="utf-8"))
    local_rotations = {
        bone["name"]: q_from_list(bone["local_rotation"])
        for bone in model["skeleton"]["bones"]
    }

    def chain_q(bones):
        result = unreal.Quat(0.0, 0.0, 0.0, 1.0)
        for bone in bones:
            result = q_mul(result, local_rotations[bone])
        return result

    ref_pelvis = chain_q(["Master", "RootPos", "Pelvis"])
    ref_spine = chain_q(["Master", "RootPos", "RootRotY", "RootRotXZ", "Spine"])
    return q_mul(q_inverse(ref_pelvis), ref_spine)


def summarize_ue(anim):
    lib = unreal.AnimationLibrary if hasattr(unreal, "AnimationLibrary") else unreal.AnimationBlueprintLibrary
    frames = max(2, int(round(anim.get_play_length() * 30)) + 1)

    def local_q(frame, bone):
        return lib.get_bone_pose_for_frame(anim, bone, frame, False).rotation

    def chain_q(frame, bones):
        result = unreal.Quat(0.0, 0.0, 0.0, 1.0)
        for bone in bones:
            result = q_mul(result, local_q(frame, bone))
        return result

    pelvis_components = [chain_q(frame, ["Master", "RootPos", "Pelvis"]) for frame in range(frames)]
    spine_components = [chain_q(frame, ["Master", "RootPos", "RootRotY", "RootRotXZ", "Spine"]) for frame in range(frames)]
    reference_offset = load_reference_spine_offset()
    drift = [
        q_angle_degrees(q_mul(pelvis_component, reference_offset), spine_component)
        for pelvis_component, spine_component in zip(pelvis_components, spine_components)
    ]

    return {
        "PelvisComponentYaw": summarize_curve([q_yaw(q) for q in pelvis_components]),
        "SpineComponentYaw": summarize_curve([q_yaw(q) for q in spine_components]),
        "SpineRelativeToReferencePelvisOffsetDegrees": {
            "start": round(drift[0], 3),
            "end": round(drift[-1], 3),
            "max": round(max(drift), 3),
            "mean": round(sum(drift) / len(drift), 3),
        },
        "RootTrackYaw": summarize_curve(
            [
                q_yaw(lib.extract_root_track_transform(anim, min(anim.get_play_length(), frame / 30.0)).rotation)
                for frame in range(frames)
            ]
        ),
    }


def main():
    report = {"asset": ASSET_PATH, "status": "running"}
    try:
        if os.path.exists(DISK_PATH):
            backup = DISK_PATH + ".bak_pre_solve_spine_from_pelvis_component_" + time.strftime("%Y%m%d_%H%M%S")
            shutil.copy2(DISK_PATH, backup)
            report["backup"] = backup

        anim = unreal.load_asset(ASSET_PATH)
        if anim is None:
            raise RuntimeError(f"Failed to load {ASSET_PATH}")

        lib = unreal.AnimationLibrary if hasattr(unreal, "AnimationLibrary") else unreal.AnimationBlueprintLibrary
        frames = max(2, int(round(anim.get_play_length() * 30)) + 1)
        report["before"] = summarize_ue(anim)

        def local_q(frame, bone):
            return lib.get_bone_pose_for_frame(anim, bone, frame, False).rotation

        def rootpos_component(frame):
            return q_mul(local_q(frame, "Master"), local_q(frame, "RootPos"))

        def pelvis_component(frame):
            return q_mul(rootpos_component(frame), local_q(frame, "Pelvis"))

        reference_offset = load_reference_spine_offset()
        report["target_offset"] = "reference_pose_Pelvis_to_Spine"

        positions = []
        rotations = []
        scales = []
        for frame in range(frames):
            current = lib.get_bone_pose_for_frame(anim, "RootRotY", frame, False)
            desired_spine_component = q_mul(pelvis_component(frame), reference_offset)
            child_chain = q_mul(local_q(frame, "RootRotXZ"), local_q(frame, "Spine"))
            solved_local = q_mul(
                q_mul(q_inverse(rootpos_component(frame)), desired_spine_component),
                q_inverse(child_chain),
            )
            positions.append(current.translation)
            rotations.append(solved_local)
            scales.append(current.scale3d)

        controller = anim.controller
        controller.open_bracket("Solve combo3 spine from pelvis component")
        try:
            report["set_RootRotY_ok"] = controller.set_bone_track_keys("RootRotY", positions, rotations, scales, True)
            report["set_rootroty_ok"] = controller.set_bone_track_keys("rootroty", positions, rotations, scales, True)
        finally:
            controller.close_bracket()

        if hasattr(unreal, "AnimationLibrary"):
            unreal.AnimationLibrary.set_root_motion_enabled(anim, True)
            unreal.AnimationLibrary.set_root_motion_lock_type(anim, unreal.RootMotionRootLock.ANIM_FIRST_FRAME)
            unreal.AnimationLibrary.set_is_root_motion_lock_forced(anim, False)

        unreal.EditorAssetLibrary.save_loaded_asset(anim)
        unreal.EditorAssetLibrary.save_asset(ASSET_PATH.split(".")[0], only_if_is_dirty=False)

        report["after"] = summarize_ue(anim)
        report["status"] = "success"
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
