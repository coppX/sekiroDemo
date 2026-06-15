import json
import math
import os
import shutil
import time
import traceback

import unreal


ASSET_PATH = "/Game/Animation/Sekiro/C0000/GroundAttack_SM/a050_300020.a050_300020"
DISK_PATH = r"E:\UEProj\Sekiro\SekiroDemo\Content\Animation\Sekiro\C0000\GroundAttack_SM\a050_300020.uasset"
REPORT_PATH = r"E:\UEProj\Sekiro\SekiroDemo\Saved\Codex\combo3_follow_rootpos_turn_report.json"


def q_normalize(q):
    length = math.sqrt(q.x * q.x + q.y * q.y + q.z * q.z + q.w * q.w) or 1.0
    return unreal.Quat(q.x / length, q.y / length, q.z / length, q.w / length)


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


def q_yaw_degrees(q):
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


def summarize(anim):
    lib = unreal.AnimationLibrary if hasattr(unreal, "AnimationLibrary") else unreal.AnimationBlueprintLibrary
    frames = max(2, int(round(anim.get_play_length() * 30)) + 1)
    result = {}
    samplers = {
        "MasterLocal": lambda frame: lib.get_bone_pose_for_frame(anim, "Master", frame, False).rotation,
        "RootPosLocal": lambda frame: lib.get_bone_pose_for_frame(anim, "RootPos", frame, False).rotation,
        "RootRotYLocal": lambda frame: lib.get_bone_pose_for_frame(anim, "RootRotY", frame, False).rotation,
        "RootPosRootRotYComponent": lambda frame: q_mul(
            lib.get_bone_pose_for_frame(anim, "RootPos", frame, False).rotation,
            lib.get_bone_pose_for_frame(anim, "RootRotY", frame, False).rotation,
        ),
    }
    for name, sampler in samplers.items():
        values = unwrap([q_yaw_degrees(sampler(frame)) for frame in range(frames)])
        result[name] = {
            "start": round(values[0], 3),
            "end": round(values[-1], 3),
            "delta": round(values[-1] - values[0], 3),
            "min": round(min(values), 3),
            "max": round(max(values), 3),
        }
    return result


def main():
    report = {"asset": ASSET_PATH, "status": "running"}
    try:
        if os.path.exists(DISK_PATH):
            backup = DISK_PATH + ".bak_pre_follow_rootpos_turn_" + time.strftime("%Y%m%d_%H%M%S")
            shutil.copy2(DISK_PATH, backup)
            report["backup"] = backup

        anim = unreal.load_asset(ASSET_PATH)
        if anim is None:
            raise RuntimeError(f"Failed to load {ASSET_PATH}")

        lib = unreal.AnimationLibrary if hasattr(unreal, "AnimationLibrary") else unreal.AnimationBlueprintLibrary
        frames = max(2, int(round(anim.get_play_length() * 30)) + 1)
        report["before"] = summarize(anim)

        first_rootroty = lib.get_bone_pose_for_frame(anim, "RootRotY", 0, False)
        positions = []
        rotations = []
        scales = []
        for frame in range(frames):
            current = lib.get_bone_pose_for_frame(anim, "RootRotY", frame, False)
            positions.append(current.translation)
            rotations.append(first_rootroty.rotation)
            scales.append(current.scale3d)

        controller = anim.controller
        report["set_RootRotY_ok"] = controller.set_bone_track_keys("RootRotY", positions, rotations, scales, True)
        report["set_rootroty_ok"] = controller.set_bone_track_keys("rootroty", positions, rotations, scales, True)
        unreal.EditorAssetLibrary.save_loaded_asset(anim)

        report["after"] = summarize(anim)
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
