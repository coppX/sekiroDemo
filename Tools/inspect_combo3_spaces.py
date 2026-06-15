import json
import math
import os

import unreal


ASSET_PATH = "/Game/Animation/Sekiro/C0000/GroundAttack_SM/a050_300020.a050_300020"
REPORT_PATH = r"E:\UEProj\Sekiro\SekiroDemo\Saved\Codex\combo3_space_probe.json"


def q_yaw_degrees(q):
    x, y, z, w = q.x, q.y, q.z, q.w
    length = math.sqrt(x * x + y * y + z * z + w * w) or 1.0
    x, y, z, w = x / length, y / length, z / length, w / length
    fx = 2.0 * (x * z + w * y)
    fz = 1.0 - 2.0 * (x * x + y * y)
    return math.degrees(math.atan2(fx, fz))


def vec(v):
    return [round(v.x, 3), round(v.y, 3), round(v.z, 3)]


def main():
    anim = unreal.load_asset(ASSET_PATH)
    lib = unreal.AnimationLibrary if hasattr(unreal, "AnimationLibrary") else unreal.AnimationBlueprintLibrary
    frames = max(2, int(round(anim.get_play_length() * 30)) + 1)
    samples = []
    for frame in range(frames):
        if frame % 5 != 0 and frame != frames - 1:
            continue
        t = min(anim.get_play_length(), frame / 30.0)
        row = {"frame": frame, "t": round(t, 3)}
        for bone in ["Master", "RootPos", "RootRotY", "Pelvis", "Spine", "R_Weapon"]:
            row[bone] = {}
            for flag in [False, True]:
                tr = lib.get_bone_pose_for_time(anim, bone, t, flag)
                row[bone]["flag_" + str(flag)] = {
                    "loc": vec(tr.translation),
                    "yaw": round(q_yaw_degrees(tr.rotation), 3),
                }
        samples.append(row)
    os.makedirs(os.path.dirname(REPORT_PATH), exist_ok=True)
    with open(REPORT_PATH, "w", encoding="utf-8") as f:
        json.dump({"asset": ASSET_PATH, "frames": frames, "samples": samples}, f, ensure_ascii=False, indent=2)
    print(json.dumps({"report": REPORT_PATH, "sample_count": len(samples)}, ensure_ascii=False))


if __name__ == "__main__":
    main()
