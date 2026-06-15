import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
import time
import traceback
import xml.etree.ElementTree as ET
from types import SimpleNamespace

import unreal

TOOLS_DIR = os.path.dirname(os.path.abspath(__file__))
if TOOLS_DIR not in sys.path:
    sys.path.insert(0, TOOLS_DIR)

import import_sekiro_hkx_animation as hkx_import
import sekiro_tae_event_import as tae_event_import


PROJECT_ROOT = os.path.abspath(os.path.join(TOOLS_DIR, ".."))
GAME_ROOT = hkx_import.DEFAULT_SEKIRO_GAME_ROOT
FLVER_EXPORTER = os.path.join(
    PROJECT_ROOT,
    "Tools",
    "SekiroFlverObjExporter",
    "bin",
    "Release",
    "net8.0",
    "SekiroFlverObjExporter.exe",
)
DUMMY_LINE_RE = re.compile(
    r"^dummy ref=(?P<ref>-?\d+) parent=(?P<parent>-?\d+):(?P<parent_name>.*?) "
    r"attach=(?P<attach>-?\d+):(?P<attach_name>.*?) "
    r"pos=<(?P<pos>[^>]*)> fwd=<(?P<fwd>[^>]*)> up=<(?P<up>[^>]*)>"
)

ENEMY_PRESETS = {
    "c1010": {
        "asset_root": "/Game/Animation/Sekiro/Enemy/C1010",
        "mesh": "/Game/Animation/Sekiro/Enemy/C1010/Base/c1010_bindpose.c1010_bindpose",
        "skeleton": "/Game/Animation/Sekiro/Enemy/C1010/Base/c1010_bindpose_Skeleton.c1010_bindpose_Skeleton",
        "flver": os.path.join(GAME_ROOT, "chr", "c1010-chrbnd-dcx", "c1010.flver"),
        "attack_dummy_sockets": [
            {
                "atk_param_id": 10100100,
                "behavior_judge_id": 100,
                "head_dummy": 11,
                "tail_dummy": 10,
                "radius_cm": 20.0,
            }
        ],
        "source_roots": [
            os.path.join(GAME_ROOT, "exports", "c1010_minimal"),
            os.path.join(GAME_ROOT, "exports", "c1010_MoveBattle"),
        ],
        "tae_xml": os.path.join(GAME_ROOT, "chr", "c1010-anibnd-dcx-wanibnd", "tae", "c1010.tae.xml"),
    }
}


def log(message):
    unreal.log(message)
    print(message)


def normalize_object_path(asset_path):
    return hkx_import.normalize_asset_path(asset_path)


def package_path(asset_path):
    return hkx_import.package_path(asset_path)


def asset_name(asset_path):
    return package_path(asset_path).rsplit("/", 1)[-1]


def split_paths(value):
    if not value:
        return []
    return [part.strip() for part in re.split(r"[;,]", value) if part.strip()]


def parse_args():
    parser = argparse.ArgumentParser(description="Import Sekiro enemy HKX animation data and enemy TAE event tables.")
    parser.add_argument("--enemy", default=os.environ.get("SEKIRO_ENEMY_IMPORT_ENEMY", "c1010"))
    parser.add_argument("--asset-root", default=os.environ.get("SEKIRO_ENEMY_IMPORT_ASSET_ROOT", ""))
    parser.add_argument("--asset-list", default=os.environ.get("SEKIRO_ENEMY_IMPORT_ASSET_LIST", ""))
    parser.add_argument("--source-roots", default=os.environ.get("SEKIRO_ENEMY_IMPORT_SOURCE_ROOTS", ""))
    parser.add_argument("--skeleton", default=os.environ.get("SEKIRO_ENEMY_IMPORT_SKELETON", ""))
    parser.add_argument("--tae-xml", default=os.environ.get("SEKIRO_ENEMY_IMPORT_TAE_XML", ""))
    parser.add_argument("--model-json", default=os.environ.get("SEKIRO_ENEMY_IMPORT_MODEL_JSON", ""))
    parser.add_argument("--fbx-mode", choices=["import", "skip"], default=os.environ.get("SEKIRO_ENEMY_IMPORT_FBX_MODE", "import"))
    parser.add_argument("--animation-data", choices=["import", "skip"], default=os.environ.get("SEKIRO_ENEMY_IMPORT_ANIMATION_DATA", "import"))
    parser.add_argument("--tae-events", choices=["import", "skip"], default=os.environ.get("SEKIRO_ENEMY_IMPORT_TAE_EVENTS", "import"))
    parser.add_argument("--include-regex", default=os.environ.get("SEKIRO_ENEMY_IMPORT_INCLUDE_REGEX", ""))
    parser.add_argument("--limit", type=int, default=int(os.environ.get("SEKIRO_ENEMY_IMPORT_LIMIT", "0")))
    parser.add_argument("--report", default=os.environ.get("SEKIRO_ENEMY_IMPORT_REPORT", ""))
    parser.add_argument("--per-asset-report-dir", default=os.environ.get("SEKIRO_ENEMY_IMPORT_PER_ASSET_REPORT_DIR", ""))
    args, _unknown = parser.parse_known_args(sys.argv[1:])

    preset = ENEMY_PRESETS.get(args.enemy.lower())
    if not preset:
        raise RuntimeError(f"Unknown enemy preset: {args.enemy}")

    args.asset_root = args.asset_root or preset["asset_root"]
    args.mesh = preset.get("mesh", "")
    args.skeleton = args.skeleton or preset["skeleton"]
    args.flver = preset.get("flver", "")
    args.attack_dummy_sockets = preset.get("attack_dummy_sockets", [])
    args.tae_xml = args.tae_xml or preset["tae_xml"]
    args.source_roots = split_paths(args.source_roots) or preset["source_roots"]
    args.model_json = args.model_json or os.path.join(args.source_roots[0], "_intermediate", "model.json")
    stamp = time.strftime("%Y%m%d_%H%M%S")
    args.report = args.report or os.path.join(PROJECT_ROOT, "Saved", "Codex", f"enemy_hkx_import_{args.enemy}_{stamp}.json")
    args.per_asset_report_dir = args.per_asset_report_dir or os.path.join(PROJECT_ROOT, "Saved", "Codex", f"enemy_hkx_import_{args.enemy}_{stamp}")
    return args


def list_anim_sequences(args):
    if args.asset_list:
        return [normalize_object_path(path) for path in split_paths(args.asset_list)]

    assets = []
    for path in unreal.EditorAssetLibrary.list_assets(args.asset_root, recursive=True, include_folder=False):
        asset = unreal.load_asset(path)
        if asset and asset.get_class().get_name() == "AnimSequence":
            assets.append(normalize_object_path(path))
    if args.include_regex:
        assets = [path for path in assets if re.search(args.include_regex, asset_name(path))]
    if args.limit > 0:
        assets = assets[: args.limit]
    return sorted(set(assets))


def build_source_index(source_roots):
    index = {}
    for root in source_roots:
        if not os.path.isdir(root):
            continue
        for current_root, _dirs, files in os.walk(root):
            for filename in files:
                lower = filename.lower()
                name = None
                source_type = None
                if lower.endswith(".fbx"):
                    name = os.path.splitext(filename)[0]
                    source_type = "fbx"
                elif lower.endswith(".hkx.json") and filename.startswith("anim_"):
                    name = filename[len("anim_") : -len(".hkx.json")]
                    source_type = "hkx_json"
                if not name:
                    continue
                entry = index.setdefault(name, {"fbx": [], "hkx_json": []})
                entry[source_type].append(os.path.join(current_root, filename))
    for entry in index.values():
        entry["fbx"].sort()
        entry["hkx_json"].sort()
    return index


def extract_enemy_tae_anim_xml(enemy_tae_xml, source_name, output_dir):
    anim_id_match = re.match(r"a(\d{3})_(\d{6})$", source_name, re.IGNORECASE)
    if not anim_id_match:
        return ""
    group_id = int(anim_id_match.group(1))
    suffix_id = int(anim_id_match.group(2))
    anim_id = group_id * 1000000 + suffix_id if group_id else suffix_id

    root = ET.parse(enemy_tae_xml).getroot()
    anims_by_id = {}
    for anim in root.findall("./anims/anim"):
        id_text = anim.findtext("id")
        if id_text:
            anims_by_id[int(float(id_text))] = anim

    candidates = []
    if anim_id in anims_by_id:
        candidates.append(anims_by_id[anim_id])
    for anim in root.findall("./anims/anim"):
        name_text = anim.findtext("name") or ""
        if f"_{suffix_id:06d}" in name_text and anim not in candidates:
            candidates.append(anim)

    for anim in candidates:
        source_anim = anim
        header = anim.find("header")
        if not anim.findall("./events/event") and header is not None and header.findtext("type") == "ImportOtherAnim":
            import_id = header.findtext("animId")
            if import_id and int(float(import_id)) in anims_by_id:
                source_anim = anims_by_id[int(float(import_id))]
        anim = source_anim
        if anim.findall("./events/event"):
            event_root = ET.Element("taeAnim")
            events = ET.SubElement(event_root, "events")
            for event in anim.findall("./events/event"):
                events.append(event)
            path = os.path.join(output_dir, f"{source_name}.tae_anim.xml")
            ET.ElementTree(event_root).write(path, encoding="utf-8", xml_declaration=True)
            return path
    return ""



def parse_vector(text):
    values = [float(part.strip()) for part in text.split(",")]
    if len(values) != 3:
        raise RuntimeError(f"Expected a 3-vector, got: {text}")
    return values[0], values[1], values[2]


def flver_vector_to_ue(vector, scale):
    return unreal.Vector(vector[0] * scale, -vector[2] * scale, vector[1] * scale)


def flver_position_to_ue(vector):
    return flver_vector_to_ue(vector, 100.0)


def vector_length(vector):
    return (vector.x * vector.x + vector.y * vector.y + vector.z * vector.z) ** 0.5


def safe_normal(vector, fallback):
    length = vector_length(vector)
    if length <= 0.0001:
        return fallback
    return unreal.Vector(vector.x / length, vector.y / length, vector.z / length)


def run_flver_inspect_all(flver_path):
    if not os.path.isfile(FLVER_EXPORTER):
        raise RuntimeError(f"FLVER exporter not found: {FLVER_EXPORTER}")
    if not os.path.isfile(flver_path):
        raise RuntimeError(f"Source FLVER not found: {flver_path}")

    env = dict(os.environ)
    env["PATH"] = GAME_ROOT + os.pathsep + env.get("PATH", "")
    result = subprocess.run(
        [FLVER_EXPORTER, "--inspect-all", flver_path],
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        check=False,
        env=env,
    )
    if result.returncode != 0:
        raise RuntimeError(f"FLVER dummy inspect failed: {result.stderr or result.stdout}")
    return result.stdout


def parse_flver_dummies(flver_path):
    dummies = {}
    for line in run_flver_inspect_all(flver_path).splitlines():
        match = DUMMY_LINE_RE.match(line.strip())
        if not match:
            continue
        reference_id = int(match.group("ref"))
        dummies[reference_id] = {
            "reference_id": reference_id,
            "parent_bone_index": int(match.group("parent")),
            "parent_bone": match.group("parent_name"),
            "attach_bone_index": int(match.group("attach")),
            "attach_bone": match.group("attach_name"),
            "position": parse_vector(match.group("pos")),
            "forward": parse_vector(match.group("fwd")),
            "upward": parse_vector(match.group("up")),
        }
    return dummies


def find_socket(mesh, socket_name):
    return mesh.find_socket(socket_name)


def rename_socket(mesh, socket, socket_name):
    old_name = str(socket.get_editor_property("socket_name"))
    if old_name == socket_name:
        return
    for attempt in (
        lambda: mesh.rename_socket(socket, socket_name),
        lambda: mesh.rename_socket(old_name, socket_name),
        lambda: mesh.rename_socket(socket, unreal.Name(socket_name)),
        lambda: mesh.rename_socket(unreal.Name(old_name), unreal.Name(socket_name)),
    ):
        try:
            attempt()
            if str(socket.get_editor_property("socket_name")) == socket_name:
                return
        except Exception:
            pass
    raise RuntimeError(f"Failed to rename socket {old_name} to {socket_name}")


def make_attack_socket_name(config):
    if config.get("socket_name"):
        return config["socket_name"]
    attack_id = config.get("atk_param_id", -1)
    if attack_id == -1:
        attack_id = config.get("attack_dummy_id", -1)
    if attack_id == -1:
        raise RuntimeError(f"Attack dummy socket config has no name source: {config}")
    return f"ATK{int(attack_id)}"


def add_or_update_attack_dummy_socket(mesh, reference_pose, dummies, config):
    socket_name = make_attack_socket_name(config)
    head_dummy = dummies.get(config["head_dummy"])
    tail_dummy = dummies.get(config["tail_dummy"])
    if not head_dummy or not tail_dummy:
        raise RuntimeError(f"Missing FLVER dummy pair for {socket_name}: {config['head_dummy']}/{config['tail_dummy']}")
    if head_dummy["attach_bone"] != tail_dummy["attach_bone"]:
        raise RuntimeError(f"{socket_name} dummy pair uses different attach bones")

    attach_bone = head_dummy["attach_bone"]
    head_location = flver_position_to_ue(head_dummy["position"])
    tail_location = flver_position_to_ue(tail_dummy["position"])
    center_location = (head_location + tail_location) * 0.5
    capsule_axis = safe_normal(tail_location - head_location, unreal.Vector(0.0, 0.0, 1.0))
    upward = safe_normal(flver_vector_to_ue(head_dummy["upward"], 1.0), unreal.Vector(1.0, 0.0, 0.0))
    component_rotation = unreal.MathLibrary.make_rot_from_zx(capsule_axis, upward)

    bone_transform = reference_pose.get_ref_bone_pose(attach_bone, unreal.AnimPoseSpaces.WORLD)
    relative_location = bone_transform.inverse_transform_location(center_location)
    relative_rotation = bone_transform.inverse_transform_rotation(component_rotation)

    socket = find_socket(mesh, socket_name)
    existed = socket is not None
    if not socket:
        socket = unreal.new_object(
            unreal.SkeletalMeshSocket,
            outer=mesh,
            name=f"{socket_name}_Object",
        )
        mesh.add_socket(socket)
        rename_socket(mesh, socket, socket_name)

    socket.set_socket_parent(mesh, attach_bone)
    socket.set_editor_property("relative_location", relative_location)
    socket.set_editor_property("relative_rotation", relative_rotation)
    socket.set_editor_property("relative_scale", unreal.Vector(1.0, 1.0, 1.0))

    return {
        **config,
        "socket_name": socket_name,
        "existed": existed,
        "attach_bone": attach_bone,
        "component_location": str(center_location),
        "component_rotation": str(component_rotation),
        "relative_location": str(relative_location),
        "relative_rotation": str(relative_rotation),
        "length_cm": vector_length(tail_location - head_location),
    }


def ensure_enemy_attack_dummy_sockets(args):
    if not getattr(args, "attack_dummy_sockets", None):
        return {"status": "skipped", "reason": "no attack dummy socket config"}

    mesh = unreal.load_asset(args.mesh)
    if not mesh:
        raise RuntimeError(f"Failed to load skeletal mesh for attack dummy sockets: {args.mesh}")

    dummies = parse_flver_dummies(args.flver)
    reference_pose = mesh.get_editor_property("skeleton").get_reference_pose()
    mesh.modify()
    imported = [
        add_or_update_attack_dummy_socket(mesh, reference_pose, dummies, config)
        for config in args.attack_dummy_sockets
    ]
    unreal.EditorAssetLibrary.save_loaded_asset(mesh)
    unreal.EditorAssetLibrary.save_asset(args.mesh, only_if_is_dirty=False)
    return {
        "status": "success",
        "mesh": args.mesh,
        "flver": args.flver,
        "imported": imported,
    }



def postprocess_enemy_attack_notify_params(asset_path):
    return tae_event_import.postprocess_enemy_attack_notify_params(asset_path)


def install_enemy_hkx_summary_compat():
    original_summarize_hkx = hkx_import.summarize_hkx
    original_summarize_ue = hkx_import.summarize_ue

    def safe_summarize_hkx(source, transform, chains):
        try:
            return original_summarize_hkx(source, transform, chains)
        except KeyError:
            result = {}
            for name, chain in chains.items():
                try:
                    result[name] = original_summarize_hkx(source, transform, {name: chain}).get(name, {})
                except KeyError as exc:
                    result[name] = {"skipped": f"missing bone {exc}"}
            return result

    def safe_summarize_ue(anim, chains, args):
        try:
            return original_summarize_ue(anim, chains, args)
        except Exception:
            result = {}
            for name, chain in chains.items():
                try:
                    result[name] = original_summarize_ue(anim, {name: chain}, args).get(name, {})
                except Exception as exc:
                    result[name] = {"skipped": str(exc)}
            return result

    hkx_import.summarize_hkx = safe_summarize_hkx
    hkx_import.summarize_ue = safe_summarize_ue


def run_import(args):
    install_enemy_hkx_summary_compat()
    assets = list_anim_sequences(args)
    sources = build_source_index(args.source_roots)
    report = {
        "status": "running",
        "enemy": args.enemy,
        "asset_root": args.asset_root,
        "source_roots": args.source_roots,
        "tae_xml": args.tae_xml,
        "attack_dummy_socket_import": {},
        "items": [],
        "failed": [],
    }
    try:
        report["attack_dummy_socket_import"] = ensure_enemy_attack_dummy_sockets(args)
        log(f"[EnemyImport] attack dummy sockets: {report['attack_dummy_socket_import'].get('status')}")
    except Exception as exc:
        report["attack_dummy_socket_import"] = {
            "status": "failed",
            "error": str(exc),
            "traceback": traceback.format_exc(),
        }
        report["failed"].append(report["attack_dummy_socket_import"])
        unreal.log_error(report["attack_dummy_socket_import"]["traceback"])

    os.makedirs(args.per_asset_report_dir, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix=f"{args.enemy}_tae_", dir=os.path.join(PROJECT_ROOT, "Saved", "Codex")) as tae_temp_dir:
        for asset_path in assets:
            name = asset_name(asset_path)
            item = {"asset": asset_path, "name": name}
            try:
                source = sources.get(name, {"fbx": [], "hkx_json": []})
                fbx = source["fbx"][0] if source["fbx"] and args.fbx_mode == "import" else ""
                hkx_json = source["hkx_json"][0] if source["hkx_json"] else ""
                tae_xml = extract_enemy_tae_anim_xml(args.tae_xml, name, tae_temp_dir)
                per_report = os.path.join(args.per_asset_report_dir, f"{name}_hkx_import_report.json")
                item.update({"fbx": fbx, "hkx_json": hkx_json, "tae_xml": tae_xml, "report": per_report})

                import_args = SimpleNamespace(
                    asset=asset_path,
                    destination_name=name,
                    fbx=fbx,
                    hkx_json=hkx_json,
                    model_json=args.model_json,
                    tae_xml=tae_xml,
                    tae_root="",
                    tae_track_name="TAE",
                    tae_events=args.tae_events if tae_xml else "skip",
                    skeleton=args.skeleton,
                    destination=package_path(asset_path).rsplit("/", 1)[0],
                    bones="all_except_master",
                    report=per_report,
                    animation_data=args.animation_data if hkx_json else "skip",
                    rotation_mode="preserve_fbx",
                    root_motion="hkx_xz_to_ue_xy",
                    master_root_facing="align_to_root_motion",
                    master_rotation="preserve_first",
                    master_visual_rotation_transfer="preserve_fbx_component_chain",
                    sample_rate=30.0,
                )
                if fbx and not unreal.load_asset(asset_path):
                    hkx_import.import_fbx(import_args)
                result = hkx_import.run_import(import_args)
                tae = result.get("tae_import", {})
                postprocess = postprocess_enemy_attack_notify_params(asset_path)
                item.update({
                    "status": result.get("status"),
                    "tae_source_event_count": tae.get("source_event_count", 0),
                    "tae_added_event_count": tae.get("added_event_count", 0),
                    "attack_notify_postprocess": postprocess,
                })
                log(f"[EnemyImport] {name}: {item['status']} tae={item['tae_added_event_count']}")
            except Exception as exc:
                item["status"] = "failed"
                item["error"] = str(exc)
                item["traceback"] = traceback.format_exc()
                report["failed"].append(item)
                unreal.log_error(item["traceback"])
            report["items"].append(item)

    report["status"] = "failed" if report["failed"] else "success"
    os.makedirs(os.path.dirname(args.report), exist_ok=True)
    with open(args.report, "w", encoding="utf-8") as handle:
        json.dump(report, handle, ensure_ascii=False, indent=2)
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return report


def main():
    run_import(parse_args())


if __name__ == "__main__":
    main()
