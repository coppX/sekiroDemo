import json
import math
import os
import traceback

import unreal


ASSET_PATH = "/Game/Animation/Sekiro/C0000/GroundAttack_SM/a050_300020.a050_300020"
HKX_JSON = (
    r"E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE"
    r"\exports\c0000_ground_attack_root_reimport_all\_intermediate\anim_a050_300020.hkx.json"
)
MODEL_JSON = (
    r"E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE"
    r"\exports\alias_probe_11\_intermediate\model.json"
)
REPORT_PATH = r"E:\UEProj\Sekiro\SekiroDemo\Saved\Codex\combo3_hkx_keypoint_probe.json"


def q_normalize_list(q):
    x, y, z, w = q
    length = math.sqrt(x * x + y * y + z * z + w * w) or 1.0
    return [x / length, y / length, z / length, w / length]


def q_normalize(q):
    length = math.sqrt(q.x * q.x + q.y * q.y + q.z * q.z + q.w * q.w) or 1.0
    return unreal.Quat(q.x / length, q.y / length, q.z / length, q.w / length)


def q_mul_list(a, b):
    ax, ay, az, aw = q_normalize_list(a)
    bx, by, bz, bw = q_normalize_list(b)
    return q_normalize_list(
        [
            aw * bx + ax * bw + ay * bz - az * by,
            aw * by - ax * bz + ay * bw + az * bx,
            aw * bz + ax * by - ay * bx + az * bw,
            aw * bw - ax * bx - ay * by - az * bz,
        ]
    )


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


def yaw_list(q):
    x, y, z, w = q_normalize_list(q)
    fx = 2.0 * (x * z + w * y)
    fz = 1.0 - 2.0 * (x * x + y * y)
    return math.degrees(math.atan2(fx, fz))


def yaw(q):
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


def summary(values):
    values = unwrap(values)
    return {
        "start": round(values[0], 3),
        "end": round(values[-1], 3),
        "delta": round(values[-1] - values[0], 3),
        "min": round(min(values), 3),
        "max": round(max(values), 3),
    }


def hkx_summary():
    anim = json.load(open(HKX_JSON, encoding="utf-8"))
    model = json.load(open(MODEL_JSON, encoding="utf-8"))
    bone_names = [bone["name"] for bone in model["skeleton"]["bones"]]
    name_to_index = {name: index for index, name in enumerate(bone_names)}
    bone_to_track = {bone_index: track_index for track_index, bone_index in enumerate(anim["transform_track_to_bone_map"])}

    def bone_q(frame, bone_name):
        bone_index = name_to_index[bone_name]
        track_index = bone_to_track[bone_index]
        return frame["bone_transforms"][track_index]["r"]

    frames = anim["frames"]
    return {
        "Master": summary([yaw_list(bone_q(frame, "Master")) for frame in frames]),
        "RootPos": summary([yaw_list(bone_q(frame, "RootPos")) for frame in frames]),
        "Pelvis": summary([yaw_list(bone_q(frame, "Pelvis")) for frame in frames]),
        "RootRotY": summary([yaw_list(bone_q(frame, "RootRotY")) for frame in frames]),
        "RootPos*RootRotY": summary([yaw_list(q_mul_list(bone_q(frame, "RootPos"), bone_q(frame, "RootRotY"))) for frame in frames]),
        "Master*RootPos*RootRotY": summary(
            [
                yaw_list(q_mul_list(q_mul_list(bone_q(frame, "Master"), bone_q(frame, "RootPos")), bone_q(frame, "RootRotY")))
                for frame in frames
            ]
        ),
        "RootPos*Pelvis": summary([yaw_list(q_mul_list(bone_q(frame, "RootPos"), bone_q(frame, "Pelvis"))) for frame in frames]),
    }


def ue_summary():
    anim = unreal.load_asset(ASSET_PATH)
    if anim is None:
        raise RuntimeError(f"Failed to load {ASSET_PATH}")
    lib = unreal.AnimationLibrary if hasattr(unreal, "AnimationLibrary") else unreal.AnimationBlueprintLibrary
    frames = max(2, int(round(anim.get_play_length() * 30)) + 1)

    def bone_q(frame, bone_name):
        return lib.get_bone_pose_for_frame(anim, bone_name, frame, False).rotation

    return {
        "Master": summary([yaw(bone_q(frame, "Master")) for frame in range(frames)]),
        "RootPos": summary([yaw(bone_q(frame, "RootPos")) for frame in range(frames)]),
        "Pelvis": summary([yaw(bone_q(frame, "Pelvis")) for frame in range(frames)]),
        "RootRotY": summary([yaw(bone_q(frame, "RootRotY")) for frame in range(frames)]),
        "RootPos*RootRotY": summary([yaw(q_mul(bone_q(frame, "RootPos"), bone_q(frame, "RootRotY"))) for frame in range(frames)]),
        "Master*RootPos*RootRotY": summary(
            [yaw(q_mul(q_mul(bone_q(frame, "Master"), bone_q(frame, "RootPos")), bone_q(frame, "RootRotY"))) for frame in range(frames)]
        ),
        "RootPos*Pelvis": summary([yaw(q_mul(bone_q(frame, "RootPos"), bone_q(frame, "Pelvis"))) for frame in range(frames)]),
    }


def main():
    report = {"asset": ASSET_PATH, "hkx_json": HKX_JSON, "status": "running"}
    try:
        report["hkx"] = hkx_summary()
        report["ue"] = ue_summary()
        report["status"] = "success"
    except Exception as exc:
        report["status"] = "failed"
        report["error"] = str(exc)
        report["traceback"] = traceback.format_exc()
        raise
    finally:
        os.makedirs(os.path.dirname(REPORT_PATH), exist_ok=True)
        with open(REPORT_PATH, "w", encoding="utf-8") as report_file:
            json.dump(report, report_file, ensure_ascii=False, indent=2)
        print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
