import json
import math
import os
import shutil
import time
import traceback

import unreal


ASSET_PATH = "/Game/Animation/Sekiro/C0000/GroundAttack_SM/a050_300020.a050_300020"
DISK_PATH = r"E:\UEProj\Sekiro\SekiroDemo\Content\Animation\Sekiro\C0000\GroundAttack_SM\a050_300020.uasset"
HKX_JSON = (
    r"E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE"
    r"\exports\c0000_ground_attack_root_reimport_all\_intermediate\anim_a050_300020.hkx.json"
)
MODEL_JSON = (
    r"E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE"
    r"\exports\alias_probe_11\_intermediate\model.json"
)
REPORT_PATH = r"E:\UEProj\Sekiro\SekiroDemo\Saved\Codex\combo3_transfer_hkx_master_to_rootroty_report.json"


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


def summarize(anim):
    lib = unreal.AnimationLibrary if hasattr(unreal, "AnimationLibrary") else unreal.AnimationBlueprintLibrary
    frames = max(2, int(round(anim.get_play_length() * 30)) + 1)
    samplers = {
        "Master": lambda frame: lib.get_bone_pose_for_frame(anim, "Master", frame, False).rotation,
        "RootPos": lambda frame: lib.get_bone_pose_for_frame(anim, "RootPos", frame, False).rotation,
        "Pelvis": lambda frame: lib.get_bone_pose_for_frame(anim, "Pelvis", frame, False).rotation,
        "RootRotY": lambda frame: lib.get_bone_pose_for_frame(anim, "RootRotY", frame, False).rotation,
        "RootPos*Pelvis": lambda frame: q_mul(
            lib.get_bone_pose_for_frame(anim, "RootPos", frame, False).rotation,
            lib.get_bone_pose_for_frame(anim, "Pelvis", frame, False).rotation,
        ),
        "RootPos*RootRotY": lambda frame: q_mul(
            lib.get_bone_pose_for_frame(anim, "RootPos", frame, False).rotation,
            lib.get_bone_pose_for_frame(anim, "RootRotY", frame, False).rotation,
        ),
    }
    result = {}
    for name, sampler in samplers.items():
        values = unwrap([q_yaw(sampler(frame)) for frame in range(frames)])
        result[name] = {
            "start": round(values[0], 3),
            "end": round(values[-1], 3),
            "delta": round(values[-1] - values[0], 3),
            "min": round(min(values), 3),
            "max": round(max(values), 3),
        }
    return result


def load_hkx_tracks():
    anim = json.load(open(HKX_JSON, encoding="utf-8"))
    model = json.load(open(MODEL_JSON, encoding="utf-8"))
    name_to_index = {bone["name"]: index for index, bone in enumerate(model["skeleton"]["bones"])}
    bone_to_track = {bone_index: track_index for track_index, bone_index in enumerate(anim["transform_track_to_bone_map"])}

    def track_quat(frame, bone_name):
        bone_index = name_to_index[bone_name]
        track_index = bone_to_track[bone_index]
        return q_from_list(frame["bone_transforms"][track_index]["r"])

    return {
        "frames": anim["frames"],
        "track_quat": track_quat,
    }


def main():
    report = {"asset": ASSET_PATH, "status": "running", "hkx_json": HKX_JSON}
    try:
        if os.path.exists(DISK_PATH):
            backup = DISK_PATH + ".bak_pre_transfer_hkx_master_to_rootroty_" + time.strftime("%Y%m%d_%H%M%S")
            shutil.copy2(DISK_PATH, backup)
            report["backup"] = backup

        anim = unreal.load_asset(ASSET_PATH)
        if anim is None:
            raise RuntimeError(f"Failed to load {ASSET_PATH}")
        lib = unreal.AnimationLibrary if hasattr(unreal, "AnimationLibrary") else unreal.AnimationBlueprintLibrary
        frames = max(2, int(round(anim.get_play_length() * 30)) + 1)
        hkx = load_hkx_tracks()
        if len(hkx["frames"]) != frames:
            raise RuntimeError(f"Frame count mismatch: UE={frames}, HKX={len(hkx['frames'])}")

        report["before"] = summarize(anim)

        master_positions, master_rotations, master_scales = [], [], []
        rootpos_positions, rootpos_rotations, rootpos_scales = [], [], []
        rootroty_positions, rootroty_rotations, rootroty_scales = [], [], []

        master_first = lib.get_bone_pose_for_frame(anim, "Master", 0, False).rotation
        for frame_index, hkx_frame in enumerate(hkx["frames"]):
            master = lib.get_bone_pose_for_frame(anim, "Master", frame_index, False)
            rootpos = lib.get_bone_pose_for_frame(anim, "RootPos", frame_index, False)
            rootroty = lib.get_bone_pose_for_frame(anim, "RootRotY", frame_index, False)

            hkx_master_q = hkx["track_quat"](hkx_frame, "Master")
            hkx_rootpos_q = hkx["track_quat"](hkx_frame, "RootPos")
            hkx_rootroty_q = hkx["track_quat"](hkx_frame, "RootRotY")

            # Original visible upper chain in HKX is Master * RootPos * RootRotY.
            # In UE, keep Master rotation fixed so root motion does not turn the actor,
            # then solve RootRotY so RootPos * RootRotY matches the HKX visible chain.
            desired_upper_component = q_mul(q_mul(hkx_master_q, hkx_rootpos_q), hkx_rootroty_q)
            solved_rootroty_q = q_mul(q_inverse(hkx_rootpos_q), desired_upper_component)

            master_positions.append(master.translation)
            master_rotations.append(master_first)
            master_scales.append(master.scale3d)

            rootpos_positions.append(rootpos.translation)
            rootpos_rotations.append(hkx_rootpos_q)
            rootpos_scales.append(rootpos.scale3d)

            rootroty_positions.append(rootroty.translation)
            rootroty_rotations.append(solved_rootroty_q)
            rootroty_scales.append(rootroty.scale3d)

        controller = anim.controller
        report["set_Master_ok"] = controller.set_bone_track_keys("Master", master_positions, master_rotations, master_scales, True)
        report["set_master_ok"] = controller.set_bone_track_keys("master", master_positions, master_rotations, master_scales, True)
        report["set_RootPos_ok"] = controller.set_bone_track_keys("RootPos", rootpos_positions, rootpos_rotations, rootpos_scales, True)
        report["set_rootpos_ok"] = controller.set_bone_track_keys("rootpos", rootpos_positions, rootpos_rotations, rootpos_scales, True)
        report["set_RootRotY_ok"] = controller.set_bone_track_keys("RootRotY", rootroty_positions, rootroty_rotations, rootroty_scales, True)
        report["set_rootroty_ok"] = controller.set_bone_track_keys("rootroty", rootroty_positions, rootroty_rotations, rootroty_scales, True)
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
