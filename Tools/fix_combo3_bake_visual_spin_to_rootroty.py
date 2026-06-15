import json
import math
import os
import shutil
import time
import traceback

import unreal


ASSET_PATH = "/Game/Animation/Sekiro/C0000/GroundAttack_SM/a050_300020.a050_300020"
DISK_PATH = r"E:\UEProj\Sekiro\SekiroDemo\Content\Animation\Sekiro\C0000\GroundAttack_SM\a050_300020.uasset"
REPORT_PATH = r"E:\UEProj\Sekiro\SekiroDemo\Saved\Codex\combo3_bake_visual_spin_to_rootroty_report.json"


def q_normalize(q):
    length = math.sqrt(q.x * q.x + q.y * q.y + q.z * q.z + q.w * q.w) or 1.0
    return unreal.Quat(q.x / length, q.y / length, q.z / length, q.w / length)


def q_mul(a, b):
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


def sample(anim):
    lib = unreal.AnimationLibrary if hasattr(unreal, "AnimationLibrary") else unreal.AnimationBlueprintLibrary
    frames = max(2, int(round(anim.get_play_length() * 30)) + 1)
    result = {}
    for bone in ["Master", "RootPos", "RootRotY", "Pelvis"]:
        yaws = []
        locs = []
        for frame in range(frames):
            t = min(anim.get_play_length(), frame / 30.0)
            transform = lib.get_bone_pose_for_time(anim, bone, t, False)
            yaws.append(q_yaw_degrees(transform.rotation))
            locs.append(transform.translation)
        unwrapped = unwrap(yaws)
        result[bone] = {
            "yaw_start": round(unwrapped[0], 3),
            "yaw_end": round(unwrapped[-1], 3),
            "yaw_delta": round(unwrapped[-1] - unwrapped[0], 3),
            "loc_start": [round(locs[0].x, 3), round(locs[0].y, 3), round(locs[0].z, 3)],
            "loc_end": [round(locs[-1].x, 3), round(locs[-1].y, 3), round(locs[-1].z, 3)],
        }
    return result


def main():
    report = {"asset": ASSET_PATH, "status": "running"}
    try:
        if os.path.exists(DISK_PATH):
            backup_path = DISK_PATH + ".bak_pre_bake_visual_spin_" + time.strftime("%Y%m%d_%H%M%S")
            shutil.copy2(DISK_PATH, backup_path)
            report["backup"] = backup_path

        anim = unreal.load_asset(ASSET_PATH)
        if anim is None:
            raise RuntimeError(f"Failed to load {ASSET_PATH}")

        lib = unreal.AnimationLibrary if hasattr(unreal, "AnimationLibrary") else unreal.AnimationBlueprintLibrary
        frames = max(2, int(round(anim.get_play_length() * 30)) + 1)
        report["before"] = sample(anim)

        rootroty_positions = []
        rootroty_rotations = []
        rootroty_scales = []
        for frame in range(frames):
            rootpos = lib.get_bone_pose_for_frame(anim, "RootPos", frame, False)
            rootroty = lib.get_bone_pose_for_frame(anim, "RootRotY", frame, False)
            rootroty_positions.append(rootroty.translation)
            # RootPos and RootRotY currently cancel each other. Multiplying the
            # RootPos rotation into RootRotY leaves RootPos untouched while
            # restoring the visual spin in RootRotY's component-space result.
            rootroty_rotations.append(q_mul(rootpos.rotation, rootroty.rotation))
            rootroty_scales.append(rootroty.scale3d)

        ok_upper = anim.controller.set_bone_track_keys(
            "RootRotY", rootroty_positions, rootroty_rotations, rootroty_scales, True
        )
        ok_lower = anim.controller.set_bone_track_keys(
            "rootroty", rootroty_positions, rootroty_rotations, rootroty_scales, True
        )

        unreal.EditorAssetLibrary.save_loaded_asset(anim)
        report["set_upper_ok"] = ok_upper
        report["set_lower_ok"] = ok_lower
        report["after"] = sample(anim)
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
