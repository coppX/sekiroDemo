import json
import math
import os
import traceback

import unreal


ASSET_PATH = "/Game/Animation/Sekiro/C0000/GroundAttack_SM/a050_300020.a050_300020"
REPORT_PATH = r"E:\UEProj\Sekiro\SekiroDemo\Saved\Codex\combo3_component_chain_probe.json"


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


def q_rotate_vec(q, v):
    q = q_normalize(q)
    u = unreal.Vector(q.x, q.y, q.z)
    s = q.w
    dot_uv = u.x * v.x + u.y * v.y + u.z * v.z
    dot_uu = u.x * u.x + u.y * u.y + u.z * u.z
    cross = unreal.Vector(
        u.y * v.z - u.z * v.y,
        u.z * v.x - u.x * v.z,
        u.x * v.y - u.y * v.x,
    )
    return unreal.Vector(
        2.0 * dot_uv * u.x + (s * s - dot_uu) * v.x + 2.0 * s * cross.x,
        2.0 * dot_uv * u.y + (s * s - dot_uu) * v.y + 2.0 * s * cross.y,
        2.0 * dot_uv * u.z + (s * s - dot_uu) * v.z + 2.0 * s * cross.z,
    )


def compose(parent, child):
    loc = parent["loc"] + q_rotate_vec(parent["rot"], child["loc"])
    rot = q_mul(parent["rot"], child["rot"])
    return {"loc": loc, "rot": rot}


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


def vec(v):
    return [round(v.x, 3), round(v.y, 3), round(v.z, 3)]


def get_local(lib, anim, bone, frame):
    tr = lib.get_bone_pose_for_frame(anim, bone, frame, False)
    return {"loc": tr.translation, "rot": tr.rotation}


def summarize_curve(samples, key):
    values = [sample[key] for sample in samples]
    unwrapped = unwrap(values)
    return {
        "start": round(unwrapped[0], 3),
        "end": round(unwrapped[-1], 3),
        "delta": round(unwrapped[-1] - unwrapped[0], 3),
        "min": round(min(unwrapped), 3),
        "max": round(max(unwrapped), 3),
    }


def main():
    report = {"asset": ASSET_PATH, "status": "running"}
    try:
        anim = unreal.load_asset(ASSET_PATH)
        if anim is None:
            raise RuntimeError("Failed to load asset")

        lib = unreal.AnimationLibrary if hasattr(unreal, "AnimationLibrary") else unreal.AnimationBlueprintLibrary
        frames = max(2, int(round(anim.get_play_length() * 30)) + 1)
        chains = {
            "Master": ["Master"],
            "RootPos": ["Master", "RootPos"],
            "Pelvis": ["Master", "RootPos", "Pelvis"],
            "RootRotY": ["Master", "RootPos", "RootRotY"],
            "RootRotXZ": ["Master", "RootPos", "RootRotY", "RootRotXZ"],
            "Spine": ["Master", "RootPos", "RootRotY", "RootRotXZ", "Spine"],
        }

        raw_samples = []
        compact_samples = []
        for frame in range(frames):
            locals_by_bone = {
                bone: get_local(lib, anim, bone, frame)
                for bone in ["Master", "RootPos", "Pelvis", "RootRotY", "RootRotXZ", "Spine"]
            }
            components = {}
            for name, chain in chains.items():
                current = {"loc": unreal.Vector(0.0, 0.0, 0.0), "rot": unreal.Quat(0.0, 0.0, 0.0, 1.0)}
                for bone in chain:
                    current = compose(current, locals_by_bone[bone])
                components[name] = current

            row = {"frame": frame, "t": round(min(anim.get_play_length(), frame / 30.0), 3)}
            for bone, tr in components.items():
                row[bone + "_yaw"] = q_yaw_degrees(tr["rot"])
                row[bone + "_loc"] = tr["loc"]
            raw_samples.append(row)

            if frame % 5 == 0 or frame == frames - 1:
                compact = {"frame": frame, "t": row["t"]}
                for bone in components:
                    compact[bone] = {
                        "yaw": round(row[bone + "_yaw"], 3),
                        "loc": vec(row[bone + "_loc"]),
                    }
                compact_samples.append(compact)

        report["frames"] = frames
        report["summary"] = {}
        for bone in chains:
            report["summary"][bone] = summarize_curve(raw_samples, bone + "_yaw")
        report["samples"] = compact_samples
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
            json.dump(report, report_file, ensure_ascii=False, indent=2, default=str)
        print(json.dumps({k: v for k, v in report.items() if k != "samples"}, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
