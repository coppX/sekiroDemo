import argparse
import json
import os
import re
import sys
import time
import traceback
from types import SimpleNamespace

import unreal

TOOLS_DIR = os.path.dirname(os.path.abspath(__file__))
if TOOLS_DIR not in sys.path:
    sys.path.insert(0, TOOLS_DIR)

import import_sekiro_hkx_animation as hkx_import


PROJECT_ROOT = os.path.abspath(os.path.join(TOOLS_DIR, ".."))
DEFAULT_EXPORT_ROOT = os.path.join(hkx_import.DEFAULT_SEKIRO_GAME_ROOT, "exports")
DEFAULT_ASSET_ROOT = "/Game/Animation/Sekiro/C0000"
DEFAULT_SKELETON = "/Game/Animation/Sekiro/C0000/Base/c0000_bindpose_Skeleton.c0000_bindpose_Skeleton"

DESTINATION_SOURCE_HINTS = [
    ("GroundAttack_SM", ["c0000_ground_attack_root_reimport_all", "c0000_ground_attack_combo"]),
    ("StandMoveableAction_SM", ["c0000_StandMoveableAction_SM_all", "c0000_deflect_guard_idle", "c0000_deflect_guard_move"]),
    ("StandMoveLower_SM", ["c0000_StandMoveLower_SM_all"]),
    ("StandMoveUpper_SM", ["c0000_StandMoveUpper_SM_all"]),
    ("StandMove_SM", ["c0000_StandMove_SM_all"]),
]

SOURCE_NAME_ALIASES = {
    "a000_000142": "a000_000132",
    "a000_000143": "a000_000133",
}


def log(message):
    unreal.log(message)
    print(message)


def split_paths(value):
    if not value:
        return []
    return [part.strip() for part in re.split(r"[;,]", value) if part.strip()]


def normalize_object_path(asset_path):
    return hkx_import.normalize_asset_path(asset_path)


def package_path(asset_path):
    return hkx_import.package_path(asset_path)


def asset_name(asset_path):
    return package_path(asset_path).rsplit("/", 1)[-1]


def source_name_candidates(name):
    candidates = [name]
    if name in SOURCE_NAME_ALIASES:
        candidates.append(SOURCE_NAME_ALIASES[name])
    for suffix in ["_LoopFixed"]:
        if name.endswith(suffix):
            candidates.append(name[: -len(suffix)])
    return candidates


def infer_tae_xml_for_source_name(batch_args, source_name):
    match = re.match(r"a(\d{3})_(\d{6})$", source_name, re.IGNORECASE)
    if not match:
        return ""
    tae_group = f"a{int(match.group(1)):02d}-tae"
    return os.path.join(batch_args.tae_root, tae_group, f"anim-{match.group(2)}.xml")


def parse_args():
    parser = argparse.ArgumentParser(
        description="Batch reimport existing Sekiro AnimSequence assets through import_sekiro_hkx_animation.py."
    )
    parser.add_argument("--asset-root", default=os.environ.get("SEKIRO_BATCH_ASSET_ROOT", DEFAULT_ASSET_ROOT))
    parser.add_argument("--asset-list", default=os.environ.get("SEKIRO_BATCH_ASSET_LIST", ""))
    parser.add_argument("--source-root", default=os.environ.get("SEKIRO_BATCH_SOURCE_ROOT", DEFAULT_EXPORT_ROOT))
    parser.add_argument("--source-roots", default=os.environ.get("SEKIRO_BATCH_SOURCE_ROOTS", ""))
    parser.add_argument("--skeleton", default=os.environ.get("SEKIRO_BATCH_SKELETON", DEFAULT_SKELETON))
    parser.add_argument(
        "--fbx-mode",
        choices=["import", "skip"],
        default=os.environ.get("SEKIRO_BATCH_FBX_MODE", "import"),
    )
    parser.add_argument(
        "--tae-events",
        choices=["import", "skip"],
        default=os.environ.get("SEKIRO_BATCH_TAE_EVENTS", "import"),
    )
    parser.add_argument(
        "--animation-data",
        choices=["import", "skip"],
        default=os.environ.get("SEKIRO_BATCH_ANIMATION_DATA", "import"),
    )
    parser.add_argument("--tae-root", default=os.environ.get("SEKIRO_BATCH_TAE_ROOT", hkx_import.DEFAULT_TAE_ROOT))
    parser.add_argument("--tae-track-name", default=os.environ.get("SEKIRO_BATCH_TAE_TRACK_NAME", "TAE"))
    parser.add_argument("--model-json", default=os.environ.get("SEKIRO_BATCH_MODEL_JSON", hkx_import.DEFAULT_MODEL_JSON))
    parser.add_argument(
        "--bones",
        default=os.environ.get("SEKIRO_BATCH_BONES", "all_except_master"),
    )
    parser.add_argument(
        "--rotation-mode",
        choices=["preserve_fbx", "raw_hkx", "hkx_delta_from_fbx_first"],
        default=os.environ.get("SEKIRO_BATCH_ROTATION_MODE", "preserve_fbx"),
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
        default=os.environ.get("SEKIRO_BATCH_ROOT_MOTION", "hkx_xz_to_ue_xy"),
    )
    parser.add_argument(
        "--master-root-facing",
        choices=["preserve_first", "align_to_root_motion"],
        default=os.environ.get("SEKIRO_BATCH_MASTER_ROOT_FACING", "align_to_root_motion"),
    )
    parser.add_argument(
        "--master-rotation",
        choices=["preserve_first", "raw_hkx", "hkx_delta_from_fbx_first"],
        default=os.environ.get("SEKIRO_BATCH_MASTER_ROTATION", "preserve_first"),
    )
    parser.add_argument(
        "--master-visual-rotation-transfer",
        choices=["none", "rootpos", "preserve_fbx_component_chain"],
        default=os.environ.get("SEKIRO_BATCH_MASTER_VISUAL_ROTATION_TRANSFER", "preserve_fbx_component_chain"),
    )
    parser.add_argument("--sample-rate", type=float, default=float(os.environ.get("SEKIRO_BATCH_SAMPLE_RATE", "30.0")))
    parser.add_argument("--include-regex", default=os.environ.get("SEKIRO_BATCH_INCLUDE_REGEX", ""))
    parser.add_argument("--exclude-regex", default=os.environ.get("SEKIRO_BATCH_EXCLUDE_REGEX", ""))
    parser.add_argument("--limit", type=int, default=int(os.environ.get("SEKIRO_BATCH_LIMIT", "0")))
    parser.add_argument("--dry-run", action="store_true", default=os.environ.get("SEKIRO_BATCH_DRY_RUN", "").lower() in {"1", "true", "yes"})
    parser.add_argument("--continue-on-error", action="store_true", default=os.environ.get("SEKIRO_BATCH_CONTINUE_ON_ERROR", "1").lower() in {"1", "true", "yes"})
    parser.add_argument("--report", default=os.environ.get("SEKIRO_BATCH_REPORT", ""))
    parser.add_argument("--per-asset-report-dir", default=os.environ.get("SEKIRO_BATCH_PER_ASSET_REPORT_DIR", ""))
    args, _unknown = parser.parse_known_args(sys.argv[1:])

    config_path = os.environ.get("SEKIRO_BATCH_CONFIG", "")
    if config_path:
        with open(config_path, "r", encoding="utf-8") as config_file:
            config = json.load(config_file)
        for key, value in config.items():
            attr = key.replace("-", "_")
            if hasattr(args, attr) and value is not None:
                setattr(args, attr, value)

    if not args.report:
        args.report = os.path.join(
            PROJECT_ROOT,
            "Saved",
            "Codex",
            "batch_reimport_sekiro_hkx_animations_" + time.strftime("%Y%m%d_%H%M%S") + ".json",
        )
    if not args.per_asset_report_dir:
        args.per_asset_report_dir = os.path.join(
            PROJECT_ROOT,
            "Saved",
            "Codex",
            "batch_reimport_sekiro_hkx_animations_" + time.strftime("%Y%m%d_%H%M%S"),
        )
    return args


def explicit_asset_list(value):
    if not value:
        return []
    if os.path.isfile(value):
        with open(value, "r", encoding="utf-8") as asset_file:
            return [line.strip() for line in asset_file if line.strip() and not line.strip().startswith("#")]
    return split_paths(value)


def list_anim_sequences(asset_root):
    assets = []
    for asset_path in unreal.EditorAssetLibrary.list_assets(asset_root, recursive=True, include_folder=False):
        asset = unreal.load_asset(asset_path)
        if asset and asset.get_class().get_name() == "AnimSequence":
            assets.append(normalize_object_path(asset_path))
    return sorted(set(assets))


def collect_source_roots(args):
    configured = split_paths(args.source_roots)
    if configured:
        return [os.path.abspath(path) for path in configured]

    root = os.path.abspath(args.source_root)
    if not os.path.isdir(root):
        return [root]
    source_roots = []
    for name in sorted(os.listdir(root)):
        path = os.path.join(root, name)
        if os.path.isdir(path):
            source_roots.append(path)
    return source_roots


def build_source_index(source_roots):
    index = {}
    for root in source_roots:
        if not os.path.isdir(root):
            continue
        for current_root, _dirs, files in os.walk(root):
            for filename in files:
                lower = filename.lower()
                path = os.path.join(current_root, filename)
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
                entry[source_type].append(path)
    for entry in index.values():
        entry["fbx"].sort()
        entry["hkx_json"].sort()
    return index


def source_score(asset_path, source_path):
    score = 0
    normalized_asset = package_path(asset_path).lower()
    normalized_source = source_path.replace("\\", "/").lower()
    for destination_hint, source_hints in DESTINATION_SOURCE_HINTS:
        if destination_hint.lower() not in normalized_asset:
            continue
        score += 100
        for source_hint in source_hints:
            if source_hint.lower() in normalized_source:
                score += 50
                break
    if "/groundattack_sm/" in normalized_asset and "root_reimport_all" in normalized_source:
        score += 10
    return score


def choose_source(asset_path, candidates):
    if not candidates:
        return ""
    return sorted(candidates, key=lambda path: (-source_score(asset_path, path), path.lower()))[0]


def make_import_args(batch_args, asset_path, source_name, fbx_path, hkx_json_path, report_path):
    return SimpleNamespace(
        asset=asset_path,
        destination_name=asset_name(asset_path),
        fbx=fbx_path if batch_args.fbx_mode == "import" else "",
        hkx_json=hkx_json_path,
        model_json=batch_args.model_json,
        tae_xml=infer_tae_xml_for_source_name(batch_args, source_name),
        tae_root=batch_args.tae_root,
        tae_track_name=batch_args.tae_track_name,
        tae_events=batch_args.tae_events,
        skeleton=batch_args.skeleton,
        destination=package_path(asset_path).rsplit("/", 1)[0],
        bones=batch_args.bones,
        report=report_path,
        animation_data=batch_args.animation_data,
        rotation_mode=batch_args.rotation_mode,
        root_motion=batch_args.root_motion,
        master_root_facing=batch_args.master_root_facing,
        master_rotation=batch_args.master_rotation,
        master_visual_rotation_transfer=batch_args.master_visual_rotation_transfer,
        sample_rate=batch_args.sample_rate,
    )


def should_include(asset_path, args):
    name = asset_name(asset_path)
    if args.include_regex and not re.search(args.include_regex, name):
        return False
    if args.exclude_regex and re.search(args.exclude_regex, name):
        return False
    return True


def write_report(path, report):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as report_file:
        json.dump(report, report_file, ensure_ascii=False, indent=2)


def main():
    args = parse_args()
    quit_editor = os.environ.get("SEKIRO_BATCH_QUIT_EDITOR", "").lower() in {"1", "true", "yes"}
    report = {
        "status": "running",
        "asset_root": args.asset_root,
        "asset_list": args.asset_list,
        "source_root": args.source_root,
        "source_roots": [],
        "fbx_mode": args.fbx_mode,
        "animation_data": args.animation_data,
        "dry_run": bool(args.dry_run),
        "items": [],
        "skipped": [],
        "failed": [],
    }

    try:
        source_roots = collect_source_roots(args)
        source_index = build_source_index(source_roots)
        report["source_roots"] = source_roots
        report["source_name_count"] = len(source_index)

        explicit_assets = explicit_asset_list(args.asset_list)
        assets = [normalize_object_path(asset) for asset in explicit_assets] if explicit_assets else list_anim_sequences(args.asset_root)
        assets = [asset for asset in assets if should_include(asset, args)]
        if args.limit > 0:
            assets = assets[: args.limit]

        log(f"[SekiroBatchReimport] Found {len(assets)} AnimSequence assets to inspect.")

        for asset_path in assets:
            name = asset_name(asset_path)
            source_name = ""
            sources = {"fbx": [], "hkx_json": []}
            for candidate in source_name_candidates(name):
                candidate_sources = source_index.get(candidate)
                if candidate_sources:
                    source_name = candidate
                    sources = candidate_sources
                    break
            fbx_path = choose_source(asset_path, sources.get("fbx", []))
            hkx_json_path = choose_source(asset_path, sources.get("hkx_json", []))
            item = {
                "asset": asset_path,
                "name": name,
                "source_name": source_name or name,
                "fbx": fbx_path,
                "hkx_json": hkx_json_path,
                "status": "pending",
            }

            if args.animation_data != "skip" and not hkx_json_path:
                item["status"] = "skipped"
                item["reason"] = "missing hkx json"
                report["skipped"].append(item)
                log(f"[SekiroBatchReimport] SKIP {name}: missing HKX json.")
                continue
            if args.animation_data != "skip" and args.fbx_mode == "import" and not fbx_path:
                item["status"] = "skipped"
                item["reason"] = "missing fbx"
                report["skipped"].append(item)
                log(f"[SekiroBatchReimport] SKIP {name}: missing FBX.")
                continue

            per_asset_report = os.path.join(args.per_asset_report_dir, name + "_hkx_import_report.json")
            item["report"] = per_asset_report
            report["items"].append(item)

            if args.dry_run:
                item["status"] = "dry_run"
                log(f"[SekiroBatchReimport] DRY {name}: {asset_path}")
                continue

            log(f"[SekiroBatchReimport] Import {name}: {asset_path}")
            try:
                import_args = make_import_args(args, asset_path, item["source_name"], fbx_path, hkx_json_path, per_asset_report)
                asset_report = hkx_import.run_import(import_args)
                item["status"] = asset_report.get("status", "unknown")
                item["per_asset_status"] = asset_report.get("status", "unknown")
            except Exception as exc:
                item["status"] = "failed"
                item["error"] = str(exc)
                item["traceback"] = traceback.format_exc()
                report["failed"].append(item)
                if not args.continue_on_error:
                    raise
            finally:
                write_report(args.report, report)

        report["imported_count"] = len([item for item in report["items"] if item["status"] == "success"])
        report["dry_run_count"] = len([item for item in report["items"] if item["status"] == "dry_run"])
        report["skipped_count"] = len(report["skipped"])
        report["failed_count"] = len(report["failed"])
        report["status"] = "failed" if report["failed"] else "success"
        write_report(args.report, report)
        log(f"[SekiroBatchReimport] Finished: {report['status']}. Report: {args.report}")
    except Exception as exc:
        report["status"] = "failed"
        report["error"] = str(exc)
        report["traceback"] = traceback.format_exc()
        write_report(args.report, report)
        unreal.log_error(report["traceback"])
        raise
    finally:
        if quit_editor:
            unreal.SystemLibrary.quit_editor()


if __name__ == "__main__":
    main()
