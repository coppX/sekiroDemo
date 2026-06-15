import argparse
import json
import math
import os
import sys
import traceback
import unreal

import sekiro_tae_event_import as tae_event_import


DEFAULT_SAMPLE_RATE = 30.0
DEFAULT_SEKIRO_GAME_ROOT = r"E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE"
DEFAULT_MODEL_JSON = (
    DEFAULT_SEKIRO_GAME_ROOT + r"\exports\alias_probe_11\_intermediate\model.json"
)
DEFAULT_TAE_ROOT = (
    DEFAULT_SEKIRO_GAME_ROOT
    + r"\chr\c0000-anibnd-dcx-wanibnd\Target\INTERROOT_win64\chr\c0000\tae"
)


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


def q_ue_yaw(q):
    q = q_normalize(q)
    sin_yaw = 2.0 * (q.w * q.z + q.x * q.y)
    cos_yaw = 1.0 - 2.0 * (q.y * q.y + q.z * q.z)
    return math.degrees(math.atan2(sin_yaw, cos_yaw))


def q_from_ue_yaw(yaw_degrees):
    half_radians = math.radians(yaw_degrees) * 0.5
    return unreal.Quat(0.0, 0.0, math.sin(half_radians), math.cos(half_radians))


def normalize_degrees(value):
    while value > 180.0:
        value -= 360.0
    while value < -180.0:
        value += 360.0
    return value


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


def get_anim_lib():
    return unreal.AnimationLibrary if hasattr(unreal, "AnimationLibrary") else unreal.AnimationBlueprintLibrary


def normalize_asset_path(asset_path):
    if "." in asset_path.rsplit("/", 1)[-1]:
        return asset_path
    name = asset_path.rsplit("/", 1)[-1]
    return asset_path + "." + name


def package_path(asset_path):
    return normalize_asset_path(asset_path).split(".", 1)[0]


def infer_destination(asset_path):
    return package_path(asset_path).rsplit("/", 1)[0]


def parse_script_args():
    # UE can pass script args inconsistently between versions, so every option
    # also has an environment-variable fallback.
    parser = argparse.ArgumentParser(description="Import a Sekiro animation and replay HKX local rotation tracks.")
    parser.add_argument("--asset", default=os.environ.get("SEKIRO_HKX_IMPORT_ASSET", ""))
    parser.add_argument("--fbx", default=os.environ.get("SEKIRO_HKX_IMPORT_FBX", ""))
    parser.add_argument("--hkx-json", default=os.environ.get("SEKIRO_HKX_IMPORT_JSON", ""))
    parser.add_argument("--model-json", default=os.environ.get("SEKIRO_HKX_IMPORT_MODEL_JSON", DEFAULT_MODEL_JSON))
    parser.add_argument("--tae-xml", default=os.environ.get("SEKIRO_HKX_IMPORT_TAE_XML", ""))
    parser.add_argument("--tae-root", default=os.environ.get("SEKIRO_HKX_IMPORT_TAE_ROOT", DEFAULT_TAE_ROOT))
    parser.add_argument("--tae-track-name", default=os.environ.get("SEKIRO_HKX_IMPORT_TAE_TRACK_NAME", "TAE"))
    parser.add_argument(
        "--tae-events",
        choices=["import", "skip"],
        default=os.environ.get("SEKIRO_HKX_IMPORT_TAE_EVENTS", "import"),
    )
    parser.add_argument("--skeleton", default=os.environ.get("SEKIRO_HKX_IMPORT_SKELETON", ""))
    parser.add_argument("--destination", default=os.environ.get("SEKIRO_HKX_IMPORT_DESTINATION", ""))
    parser.add_argument("--bones", default=os.environ.get("SEKIRO_HKX_IMPORT_BONES", "all_except_master"))
    parser.add_argument("--report", default=os.environ.get("SEKIRO_HKX_IMPORT_REPORT", ""))
    parser.add_argument(
        "--animation-data",
        choices=["import", "skip"],
        default=os.environ.get("SEKIRO_HKX_IMPORT_ANIMATION_DATA", "import"),
        help="Use skip to update TAE notify metadata without touching animation curves or root motion.",
    )
    parser.add_argument(
        "--rotation-mode",
        choices=["preserve_fbx", "raw_hkx", "hkx_delta_from_fbx_first"],
        default=os.environ.get("SEKIRO_HKX_IMPORT_ROTATION_MODE", "preserve_fbx"),
    )
    parser.add_argument(
        "--root-motion",
        choices=[
            "preserve",
            "hkx_xz_to_ue_xy",
            "raw_hkx",
            "hkx_z_to_master_x",
            "hkx_z_to_master_y",
            "hkx_z_to_master_neg_x",
            "hkx_z_to_master_neg_y",
        ],
        default=os.environ.get("SEKIRO_HKX_IMPORT_ROOT_MOTION", "hkx_xz_to_ue_xy"),
    )
    parser.add_argument(
        "--master-root-facing",
        choices=["preserve_first", "align_to_root_motion"],
        default=os.environ.get("SEKIRO_HKX_IMPORT_MASTER_ROOT_FACING", "align_to_root_motion"),
    )
    parser.add_argument(
        "--master-rotation",
        choices=["preserve_first", "raw_hkx", "hkx_delta_from_fbx_first"],
        default=os.environ.get("SEKIRO_HKX_IMPORT_MASTER_ROTATION", "preserve_first"),
    )
    parser.add_argument(
        "--master-visual-rotation-transfer",
        choices=["none", "rootpos", "preserve_fbx_component_chain"],
        default=os.environ.get("SEKIRO_HKX_IMPORT_MASTER_VISUAL_ROTATION_TRANSFER", "preserve_fbx_component_chain"),
    )
    parser.add_argument("--sample-rate", type=float, default=float(os.environ.get("SEKIRO_HKX_IMPORT_SAMPLE_RATE", "30.0")))
    args, _unknown = parser.parse_known_args(sys.argv[1:])

    config_path = os.environ.get("SEKIRO_HKX_IMPORT_CONFIG", "")
    if config_path:
        with open(config_path, "r", encoding="utf-8") as config_file:
            config = json.load(config_file)
        for key, value in config.items():
            attr = key.replace("-", "_")
            if hasattr(args, attr) and value is not None:
                setattr(args, attr, value)
    return args


def require_args(args):
    missing = []
    required = ["asset"]
    if getattr(args, "animation_data", "import") != "skip":
        required.extend(["hkx_json", "model_json"])
    for name in required:
        if not getattr(args, name, ""):
            missing.append(name)
    if args.fbx and not args.skeleton:
        missing.append("skeleton")
    if missing:
        raise RuntimeError("Missing required option(s): " + ", ".join(missing))
    args.asset = normalize_asset_path(args.asset)
    if not args.destination:
        args.destination = infer_destination(args.asset)
    if not args.report:
        safe_name = package_path(args.asset).rsplit("/", 1)[-1]
        args.report = os.path.abspath(os.path.join("Saved", "Codex", safe_name + "_hkx_import_report.json"))


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


def import_fbx(args):
    if not args.fbx:
        return []
    if not os.path.isfile(args.fbx):
        raise FileNotFoundError(args.fbx)
    skeleton = unreal.load_asset(args.skeleton)
    if skeleton is None:
        raise RuntimeError("Missing skeleton: " + args.skeleton)

    task = unreal.AssetImportTask()
    task.set_editor_property("filename", args.fbx)
    task.set_editor_property("destination_path", args.destination)
    task.set_editor_property("automated", True)
    task.set_editor_property("replace_existing", True)
    task.set_editor_property("replace_existing_settings", True)
    destination_name = str(getattr(args, "destination_name", "") or "").strip()
    if destination_name:
        task.set_editor_property("destination_name", destination_name)
    # Saving from AssetImportTask can trip ContentBrowser/Slate code while
    # running under PythonScriptCommandlet. Save once after HKX/TAE data is
    # applied instead.
    task.set_editor_property("save", False)
    task.set_editor_property("options", create_import_options(skeleton))
    unreal.AssetToolsHelpers.get_asset_tools().import_asset_tasks([task])
    return [str(path) for path in task.get_editor_property("imported_object_paths")]


def load_hkx(args):
    source = json.load(open(args.hkx_json, encoding="utf-8"))
    model = json.load(open(args.model_json, encoding="utf-8"))
    name_to_index = {bone["name"]: index for index, bone in enumerate(model["skeleton"]["bones"])}
    bone_to_track = {bone_index: track_index for track_index, bone_index in enumerate(source["transform_track_to_bone_map"])}
    track_bones = [
        bone["name"]
        for index, bone in enumerate(model["skeleton"]["bones"])
        if index in bone_to_track
    ]

    def transform(frame_index, bone_name):
        bone_index = name_to_index[bone_name]
        track_index = bone_to_track[bone_index]
        return source["frames"][frame_index]["bone_transforms"][track_index]

    return source, track_bones, transform


def infer_tae_xml_path(args):
    return tae_event_import.infer_tae_xml_path(args)


def apply_tae_events(anim, args):
    return tae_event_import.apply_tae_events(anim, args)


def resolve_bones(args, track_bones):
    value = str(args.bones or "").strip()
    if value == "all":
        return list(track_bones)
    if value == "all_except_master":
        return [bone for bone in track_bones if bone.lower() != "master"]
    if value == "root_angle":
        return [bone for bone in ["RootPos", "RootRotY"] if bone in track_bones]
    return [bone.strip() for bone in value.split(",") if bone.strip()]


def frame_count(anim, sample_rate):
    return max(2, int(round(anim.get_play_length() * sample_rate)) + 1)


def set_root_motion_settings(anim):
    lib = get_anim_lib()
    lib.set_root_motion_enabled(anim, True)
    if hasattr(unreal, "RootMotionRootLock"):
        lib.set_root_motion_lock_type(anim, unreal.RootMotionRootLock.ANIM_FIRST_FRAME)
    lib.set_is_root_motion_lock_forced(anim, False)

    for property_name, value in [
        ("enable_root_motion", True),
        ("force_root_lock", False),
        ("use_normalized_root_motion_scale", True),
    ]:
        try:
            anim.set_editor_property(property_name, value)
        except Exception:
            pass


def apply_hkx_rotations(anim, source, transform, bones, args):
    if args.rotation_mode == "preserve_fbx":
        return {
            "_mode": args.rotation_mode,
            "_skipped": "FBX rotations kept; HKX rotations were not written directly.",
        }

    lib = get_anim_lib()
    frames = frame_count(anim, args.sample_rate)
    if frames != len(source["frames"]):
        raise RuntimeError(f"Frame count mismatch: UE={frames}, HKX={len(source['frames'])}")

    result = {}
    controller = anim.controller
    controller.open_bracket("Replay HKX local rotations")
    try:
        for bone_name in bones:
            if bone_name not in source["_track_bones"]:
                result[bone_name] = {"skipped": "not in HKX track map"}
                continue
            positions = []
            rotations = []
            scales = []
            first_ue_rotation = lib.get_bone_pose_for_frame(anim, bone_name, 0, False).rotation
            first_hkx_rotation = q_from_list(transform(0, bone_name)["r"])
            hkx_to_ue_first = q_mul(first_ue_rotation, q_inverse(first_hkx_rotation))
            for frame_index in range(frames):
                current = lib.get_bone_pose_for_frame(anim, bone_name, frame_index, False)
                source_transform = transform(frame_index, bone_name)
                positions.append(current.translation)
                hkx_rotation = q_from_list(source_transform["r"])
                if args.rotation_mode == "raw_hkx":
                    rotations.append(hkx_rotation)
                else:
                    rotations.append(q_mul(hkx_to_ue_first, hkx_rotation))
                scales.append(current.scale3d)

            ok = controller.set_bone_track_keys(bone_name, positions, rotations, scales, True)
            lower_ok = True
            lower_name = bone_name.lower()
            if lower_name != bone_name:
                lower_ok = controller.set_bone_track_keys(lower_name, positions, rotations, scales, True)
            result[bone_name] = {
                "set": bool(ok),
                "set_lowercase_alias": bool(lower_ok),
                "rotation_mode": args.rotation_mode,
            }
    finally:
        controller.close_bracket()
    return result


def root_motion_vector(root_frame, mode):
    if len(root_frame) < 3:
        raise RuntimeError("HKX root_motion frame must contain at least 3 translation values.")
    hkx_x = float(root_frame[0])
    hkx_y = float(root_frame[1])
    hkx_z = float(root_frame[2])
    if mode == "hkx_xz_to_ue_xy":
        return unreal.Vector(hkx_x, hkx_z, hkx_y)
    if mode == "raw_hkx":
        return unreal.Vector(hkx_x, hkx_y, hkx_z)
    value = hkx_z
    if mode == "hkx_z_to_master_x":
        return unreal.Vector(value, 0.0, 0.0)
    if mode == "hkx_z_to_master_y":
        return unreal.Vector(0.0, value, 0.0)
    if mode == "hkx_z_to_master_neg_x":
        return unreal.Vector(-value, 0.0, 0.0)
    if mode == "hkx_z_to_master_neg_y":
        return unreal.Vector(0.0, -value, 0.0)
    raise RuntimeError("Unsupported root motion mode: " + str(mode))


def vector_list(value):
    return [round(float(value.x), 6), round(float(value.y), 6), round(float(value.z), 6)]


def number_list(values, count=3):
    return [round(float(values[index]), 6) for index in range(min(len(values), count))]


def delta_list(start, end, count=3):
    return [
        round(float(end[index]) - float(start[index]), 6)
        for index in range(min(len(start), len(end), count))
    ]


def vector_delta(start, end):
    return [
        round(float(end.x) - float(start.x), 6),
        round(float(end.y) - float(start.y), 6),
        round(float(end.z) - float(start.z), 6),
    ]


def xy_yaw_degrees(delta):
    x = float(delta[0])
    y = float(delta[1])
    if abs(x) < 0.000001 and abs(y) < 0.000001:
        return None
    return round(math.degrees(math.atan2(y, x)), 6)


def root_motion_axis_map(mode):
    if mode == "hkx_xz_to_ue_xy":
        return {
            "ue_x": "hkx_x",
            "ue_y": "hkx_z",
            "ue_z": "hkx_y",
            "description": "Sekiro HKX horizontal X/Z plane mapped to UE horizontal X/Y plane.",
        }
    if mode == "raw_hkx":
        return {
            "ue_x": "hkx_x",
            "ue_y": "hkx_y",
            "ue_z": "hkx_z",
            "description": "Raw HKX translation values without coordinate remapping.",
        }
    if mode == "hkx_z_to_master_x":
        return {"ue_x": "hkx_z", "ue_y": "0", "ue_z": "0"}
    if mode == "hkx_z_to_master_y":
        return {"ue_x": "0", "ue_y": "hkx_z", "ue_z": "0"}
    if mode == "hkx_z_to_master_neg_x":
        return {"ue_x": "-hkx_z", "ue_y": "0", "ue_z": "0"}
    if mode == "hkx_z_to_master_neg_y":
        return {"ue_x": "0", "ue_y": "-hkx_z", "ue_z": "0"}
    return None


def master_root_facing_rotation(first_rotation, translation_delta, mode):
    if mode == "preserve_first":
        return first_rotation, {"mode": mode}
    target_yaw = xy_yaw_degrees(translation_delta)
    if target_yaw is None:
        return first_rotation, {
            "mode": mode,
            "skipped": "root motion translation delta is zero",
        }
    source_yaw = q_ue_yaw(first_rotation)
    delta_yaw = normalize_degrees(target_yaw - source_yaw)
    rotation = q_mul(q_from_ue_yaw(delta_yaw), first_rotation)
    return rotation, {
        "mode": mode,
        "source_yaw_xy": round(source_yaw, 6),
        "target_yaw_xy": round(target_yaw, 6),
        "delta_yaw_xy": round(delta_yaw, 6),
        "result_yaw_xy": round(q_ue_yaw(rotation), 6),
    }


def apply_master_root_motion(anim, source, args):
    if args.root_motion == "preserve":
        return {"mode": args.root_motion}
    root_frames = source.get("root_motion", {}).get("frames", [])
    if not root_frames:
        return {"mode": args.root_motion, "skipped": "no root_motion.frames in HKX JSON"}

    lib = get_anim_lib()
    frames = frame_count(anim, args.sample_rate)
    if frames > len(root_frames):
        raise RuntimeError(f"Frame count mismatch: UE={frames}, HKX root_motion={len(root_frames)}")
    first_master = lib.get_bone_pose_for_frame(anim, "Master", 0, False)
    positions = []
    rotations = []
    scales = []
    for frame_index in range(frames):
        current = lib.get_bone_pose_for_frame(anim, "Master", frame_index, False)
        root_frame = root_frames[frame_index]
        positions.append(root_motion_vector(root_frame, args.root_motion))
        rotations.append(first_master.rotation)
        scales.append(current.scale3d)

    master_rotation, facing = master_root_facing_rotation(
        first_master.rotation,
        vector_delta(positions[0], positions[-1]),
        args.master_root_facing,
    )
    rotations = [master_rotation for _index in range(frames)]

    controller = anim.controller
    controller.open_bracket("Apply HKX root motion to Master")
    try:
        ok = controller.set_bone_track_keys("Master", positions, rotations, scales, True)
        lower_ok = controller.set_bone_track_keys("master", positions, rotations, scales, True)
    finally:
        controller.close_bracket()
    return {
        "mode": args.root_motion,
        "axis_map": root_motion_axis_map(args.root_motion),
        "master_root_facing": facing,
        "set_bone_track_Master": bool(ok),
        "set_bone_track_master_alias": bool(lower_ok),
        "hkx_translation_start": number_list(root_frames[0]),
        "hkx_translation_end": number_list(root_frames[frames - 1]),
        "hkx_translation_delta": delta_list(root_frames[0], root_frames[frames - 1]),
        "translation_start": vector_list(positions[0]),
        "translation_end": vector_list(positions[-1]),
        "translation_delta": vector_delta(positions[0], positions[-1]),
        "translation_yaw_xy": xy_yaw_degrees(vector_delta(positions[0], positions[-1])),
    }


def set_hkx_rotation_track(anim, source, transform, bone_name, mode, args):
    lib = get_anim_lib()
    frames = frame_count(anim, args.sample_rate)
    positions = []
    rotations = []
    scales = []
    first_ue_rotation = lib.get_bone_pose_for_frame(anim, bone_name, 0, False).rotation
    first_hkx_rotation = q_from_list(transform(0, bone_name)["r"])
    hkx_to_ue_first = q_mul(first_ue_rotation, q_inverse(first_hkx_rotation))
    for frame_index in range(frames):
        current = lib.get_bone_pose_for_frame(anim, bone_name, frame_index, False)
        hkx_rotation = q_from_list(transform(frame_index, bone_name)["r"])
        positions.append(current.translation)
        if mode == "raw_hkx":
            rotations.append(hkx_rotation)
        else:
            rotations.append(q_mul(hkx_to_ue_first, hkx_rotation))
        scales.append(current.scale3d)

    controller = anim.controller
    controller.open_bracket(f"Apply HKX rotation to {bone_name}")
    try:
        ok = controller.set_bone_track_keys(bone_name, positions, rotations, scales, True)
        lower_ok = True
        lower_name = bone_name.lower()
        if lower_name != bone_name:
            lower_ok = controller.set_bone_track_keys(lower_name, positions, rotations, scales, True)
    finally:
        controller.close_bracket()
    return {
        "mode": mode,
        "bone": bone_name,
        "set": bool(ok),
        "set_lowercase_alias": bool(lower_ok),
    }


def maybe_apply_master_hkx_rotation(anim, source, transform, args):
    if args.master_rotation == "preserve_first":
        return {"mode": args.master_rotation}
    return set_hkx_rotation_track(anim, source, transform, "Master", args.master_rotation, args)


def capture_master_visual_component_chain(anim, args):
    lib = get_anim_lib()
    frames = frame_count(anim, args.sample_rate)
    lower_roots = []
    visual_roots = []
    for frame_index in range(frames):
        master = lib.get_bone_pose_for_frame(anim, "Master", frame_index, False).rotation
        rootpos = lib.get_bone_pose_for_frame(anim, "RootPos", frame_index, False).rotation
        rootroty = lib.get_bone_pose_for_frame(anim, "RootRotY", frame_index, False).rotation
        lower_root = q_mul(master, rootpos)
        lower_roots.append(lower_root)
        visual_roots.append(q_mul(lower_root, rootroty))
    return {
        "lower_roots": lower_roots,
        "visual_roots": visual_roots,
    }


def apply_master_visual_rotation_transfer(anim, source, transform, args, component_chain=None):
    if args.master_visual_rotation_transfer == "none":
        return {"mode": args.master_visual_rotation_transfer}
    if args.master_visual_rotation_transfer not in {"rootpos", "preserve_fbx_component_chain"}:
        raise RuntimeError("Unsupported master visual rotation transfer: " + str(args.master_visual_rotation_transfer))
    if args.master_rotation != "preserve_first":
        return {
            "mode": args.master_visual_rotation_transfer,
            "skipped": "Master rotation is not stabilized",
        }
    if args.master_visual_rotation_transfer == "preserve_fbx_component_chain":
        if not component_chain:
            return {
                "mode": args.master_visual_rotation_transfer,
                "skipped": "missing captured FBX component chain",
            }
        return apply_preserved_master_visual_component_chain(anim, args, component_chain)

    track_bones = set(source.get("_track_bones", []))
    for bone_name in ["Master", "RootPos"]:
        if bone_name not in track_bones:
            return {
                "mode": args.master_visual_rotation_transfer,
                "skipped": f"{bone_name} is not in HKX track map",
            }

    lib = get_anim_lib()
    frames = frame_count(anim, args.sample_rate)
    if frames != len(source["frames"]):
        raise RuntimeError(f"Frame count mismatch: UE={frames}, HKX={len(source['frames'])}")

    first_ue_rootpos = lib.get_bone_pose_for_frame(anim, "RootPos", 0, False).rotation
    first_hkx_master = q_from_list(transform(0, "Master")["r"])
    first_hkx_rootpos = q_from_list(transform(0, "RootPos")["r"])
    first_hkx_visual_root = q_mul(first_hkx_master, first_hkx_rootpos)
    hkx_visual_to_ue_first = q_mul(first_ue_rootpos, q_inverse(first_hkx_visual_root))

    positions = []
    rotations = []
    scales = []
    for frame_index in range(frames):
        current = lib.get_bone_pose_for_frame(anim, "RootPos", frame_index, False)
        hkx_master = q_from_list(transform(frame_index, "Master")["r"])
        hkx_rootpos = q_from_list(transform(frame_index, "RootPos")["r"])
        positions.append(current.translation)
        rotations.append(q_mul(hkx_visual_to_ue_first, q_mul(hkx_master, hkx_rootpos)))
        scales.append(current.scale3d)

    controller = anim.controller
    controller.open_bracket("Transfer HKX Master visual turn to RootPos")
    try:
        ok = controller.set_bone_track_keys("RootPos", positions, rotations, scales, True)
        lower_ok = controller.set_bone_track_keys("rootpos", positions, rotations, scales, True)
    finally:
        controller.close_bracket()

    return {
        "mode": args.master_visual_rotation_transfer,
        "set_bone_track_RootPos": bool(ok),
        "set_bone_track_rootpos_alias": bool(lower_ok),
        "preserved_rootroty_turn": "RootRotY is left as its HKX-converted local track; RootPos only receives Master*RootPos cancellation.",
    }


def apply_preserved_master_visual_component_chain(anim, args, component_chain):
    lib = get_anim_lib()
    frames = frame_count(anim, args.sample_rate)
    if frames != len(component_chain["lower_roots"]) or frames != len(component_chain["visual_roots"]):
        raise RuntimeError("Captured component-chain frame count does not match the UE animation.")

    rootpos_positions = []
    rootpos_rotations = []
    rootpos_scales = []
    rootroty_positions = []
    rootroty_rotations = []
    rootroty_scales = []

    for frame_index in range(frames):
        current_master = lib.get_bone_pose_for_frame(anim, "Master", frame_index, False).rotation
        current_rootpos = lib.get_bone_pose_for_frame(anim, "RootPos", frame_index, False)
        current_rootroty = lib.get_bone_pose_for_frame(anim, "RootRotY", frame_index, False)

        desired_lower_root = component_chain["lower_roots"][frame_index]
        desired_visual_root = component_chain["visual_roots"][frame_index]
        rootpos_rotation = q_mul(q_inverse(current_master), desired_lower_root)
        lower_root_after_solve = q_mul(current_master, rootpos_rotation)
        rootroty_rotation = q_mul(q_inverse(lower_root_after_solve), desired_visual_root)

        rootpos_positions.append(current_rootpos.translation)
        rootpos_rotations.append(rootpos_rotation)
        rootpos_scales.append(current_rootpos.scale3d)
        rootroty_positions.append(current_rootroty.translation)
        rootroty_rotations.append(rootroty_rotation)
        rootroty_scales.append(current_rootroty.scale3d)

    controller = anim.controller
    controller.open_bracket("Preserve FBX component root chain after Master root motion")
    try:
        rootpos_ok = controller.set_bone_track_keys("RootPos", rootpos_positions, rootpos_rotations, rootpos_scales, True)
        rootpos_lower_ok = controller.set_bone_track_keys("rootpos", rootpos_positions, rootpos_rotations, rootpos_scales, True)
        rootroty_ok = controller.set_bone_track_keys("RootRotY", rootroty_positions, rootroty_rotations, rootroty_scales, True)
        rootroty_lower_ok = controller.set_bone_track_keys("rootroty", rootroty_positions, rootroty_rotations, rootroty_scales, True)
    finally:
        controller.close_bracket()

    return {
        "mode": args.master_visual_rotation_transfer,
        "set_bone_track_RootPos": bool(rootpos_ok),
        "set_bone_track_rootpos_alias": bool(rootpos_lower_ok),
        "set_bone_track_RootRotY": bool(rootroty_ok),
        "set_bone_track_rootroty_alias": bool(rootroty_lower_ok),
        "description": "Captured the FBX-imported Master*RootPos and Master*RootPos*RootRotY component rotations, then solved RootPos and RootRotY after replacing Master root motion.",
    }


def summarize_hkx(source, transform, chains):
    def bone_q(frame, bone):
        return q_from_list(transform(frame, bone)["r"])

    result = {}
    for name, chain in chains.items():
        values = []
        for frame in range(len(source["frames"])):
            q = unreal.Quat(0.0, 0.0, 0.0, 1.0)
            for bone in chain:
                q = q_mul(q, bone_q(frame, bone))
            values.append(q_yaw(q))
        result[name] = summarize_curve(values)
    return result


def summarize_ue(anim, chains, args):
    lib = get_anim_lib()
    frames = frame_count(anim, args.sample_rate)

    def bone_q(frame, bone):
        return lib.get_bone_pose_for_frame(anim, bone, frame, False).rotation

    result = {}
    for name, chain in chains.items():
        values = []
        for frame in range(frames):
            q = unreal.Quat(0.0, 0.0, 0.0, 1.0)
            for bone in chain:
                q = q_mul(q, bone_q(frame, bone))
            values.append(q_yaw(q))
        result[name] = summarize_curve(values)
    result["RootTrackYaw"] = summarize_curve(
        [
            q_yaw(lib.extract_root_track_transform(anim, min(anim.get_play_length(), frame / args.sample_rate)).rotation)
            for frame in range(frames)
        ]
    )
    return result


def run_import(args):
    require_args(args)
    report = {
        "status": "running",
        "asset": args.asset,
        "fbx": args.fbx,
        "hkx_json": args.hkx_json,
        "model_json": args.model_json,
        "animation_data": getattr(args, "animation_data", "import"),
        "tae_events": args.tae_events,
        "tae_xml": args.tae_xml or infer_tae_xml_path(args),
        "tae_track_name": args.tae_track_name,
        "bones": args.bones,
        "rotation_mode": args.rotation_mode,
        "root_motion": args.root_motion,
        "master_root_facing": args.master_root_facing,
        "master_rotation": args.master_rotation,
        "master_visual_rotation_transfer": args.master_visual_rotation_transfer,
    }

    try:
        anim = unreal.load_asset(args.asset)
        if anim is None:
            raise RuntimeError("Failed to load asset: " + args.asset)

        if getattr(args, "animation_data", "import") == "skip":
            report["imported_object_paths"] = []
            report["resolved_bones"] = []
            report["animation_data_skipped"] = True
        else:
            report["imported_object_paths"] = import_fbx(args)
            source, track_bones, transform = load_hkx(args)
            source["_track_bones"] = track_bones
            bones = resolve_bones(args, track_bones)
            report["resolved_bones"] = bones

            chains = {
                "Master": ["Master"],
                "RootPos": ["RootPos"],
                "RootRotY": ["RootRotY"],
                "Master*RootPos": ["Master", "RootPos"],
                "Master*RootPos*Pelvis": ["Master", "RootPos", "Pelvis"],
                "RootPos*Pelvis": ["RootPos", "Pelvis"],
                "RootPos*RootRotY": ["RootPos", "RootRotY"],
                "Master*RootPos*RootRotY": ["Master", "RootPos", "RootRotY"],
                "RootPos*RootRotY*RootRotXZ*Spine": ["RootPos", "RootRotY", "RootRotXZ", "Spine"],
                "Master*RootPos*RootRotY*RootRotXZ*Spine": ["Master", "RootPos", "RootRotY", "RootRotXZ", "Spine"],
            }
            report["hkx_summary"] = summarize_hkx(source, transform, chains)
            report["before"] = summarize_ue(anim, chains, args)

            report["applied_rotations"] = apply_hkx_rotations(anim, source, transform, bones, args)
            component_chain = capture_master_visual_component_chain(anim, args)
            report["master_root_motion"] = apply_master_root_motion(anim, source, args)
            report["master_rotation_result"] = maybe_apply_master_hkx_rotation(anim, source, transform, args)
            report["master_visual_rotation_transfer_result"] = apply_master_visual_rotation_transfer(
                anim,
                source,
                transform,
                args,
                component_chain,
            )
        report["tae_import"] = apply_tae_events(anim, args)
        if getattr(args, "animation_data", "import") != "skip":
            set_root_motion_settings(anim)

        unreal.EditorAssetLibrary.save_loaded_asset(anim)
        unreal.EditorAssetLibrary.save_asset(package_path(args.asset), only_if_is_dirty=False)
        if getattr(args, "animation_data", "import") != "skip":
            report["after"] = summarize_ue(anim, chains, args)
        report["status"] = "success"
    except Exception as exc:
        report["status"] = "failed"
        report["error"] = str(exc)
        report["traceback"] = traceback.format_exc()
        unreal.log_error(report["traceback"])
        raise
    finally:
        os.makedirs(os.path.dirname(args.report), exist_ok=True)
        with open(args.report, "w", encoding="utf-8") as report_file:
            json.dump(report, report_file, ensure_ascii=False, indent=2)
        if os.environ.get("SEKIRO_HKX_IMPORT_PRINT_REPORT", "1").lower() not in {"0", "false", "no"}:
            print(json.dumps(report, ensure_ascii=False, indent=2))

    return report


def main():
    args = parse_script_args()
    quit_editor = str(os.environ.get("SEKIRO_HKX_IMPORT_QUIT_EDITOR", "")).lower() in {"1", "true", "yes"}
    try:
        run_import(args)
    finally:
        if quit_editor:
            unreal.SystemLibrary.quit_editor()


if __name__ == "__main__":
    main()
