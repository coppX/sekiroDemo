import json
import os
import shutil
import time
import traceback

import unreal


ASSET_PATH = "/Game/Animation/Sekiro/C0000/GroundAttack_SM/a050_300020.a050_300020"
DESTINATION_PATH = "/Game/Animation/Sekiro/C0000/GroundAttack_SM"
SKELETON_PATH = "/Game/Animation/Sekiro/C0000/Base/c0000_bindpose_Skeleton.c0000_bindpose_Skeleton"
SOURCE_FBX = (
    r"E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE"
    r"\exports\c0000_ground_attack_root_reimport_all\a050_300020.fbx"
)
DISK_PATH = r"E:\UEProj\Sekiro\SekiroDemo\Content\Animation\Sekiro\C0000\GroundAttack_SM\a050_300020.uasset"
REPORT_PATH = r"E:\UEProj\Sekiro\SekiroDemo\Saved\Codex\combo3_reimport_fbx_only_report.json"


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


def set_root_motion_settings(anim):
    anim_lib = unreal.AnimationLibrary if hasattr(unreal, "AnimationLibrary") else unreal.AnimationBlueprintLibrary
    anim_lib.set_root_motion_enabled(anim, True)
    if hasattr(unreal, "RootMotionRootLock"):
        anim_lib.set_root_motion_lock_type(anim, unreal.RootMotionRootLock.ANIM_FIRST_FRAME)
    anim_lib.set_is_root_motion_lock_forced(anim, False)
    try:
        anim.set_editor_property("enable_root_motion", True)
        anim.set_editor_property("force_root_lock", False)
        anim.set_editor_property("use_normalized_root_motion_scale", True)
    except Exception:
        pass


def main():
    report = {"asset": ASSET_PATH, "source_fbx": SOURCE_FBX, "status": "running"}
    try:
        if not os.path.isfile(SOURCE_FBX):
            raise FileNotFoundError(SOURCE_FBX)
        if os.path.exists(DISK_PATH):
            backup = DISK_PATH + ".bak_pre_fbx_only_reimport_" + time.strftime("%Y%m%d_%H%M%S")
            shutil.copy2(DISK_PATH, backup)
            report["backup"] = backup

        skeleton = unreal.load_asset(SKELETON_PATH)
        if skeleton is None:
            raise RuntimeError(f"Missing skeleton: {SKELETON_PATH}")

        task = unreal.AssetImportTask()
        task.set_editor_property("filename", SOURCE_FBX)
        task.set_editor_property("destination_path", DESTINATION_PATH)
        task.set_editor_property("automated", True)
        task.set_editor_property("replace_existing", True)
        task.set_editor_property("replace_existing_settings", True)
        task.set_editor_property("save", True)
        task.set_editor_property("options", create_import_options(skeleton))

        unreal.AssetToolsHelpers.get_asset_tools().import_asset_tasks([task])
        report["imported_object_paths"] = [str(path) for path in task.get_editor_property("imported_object_paths")]

        anim = unreal.load_asset(ASSET_PATH)
        if anim is None:
            raise RuntimeError(f"Failed to load imported asset: {ASSET_PATH}")
        set_root_motion_settings(anim)
        unreal.EditorAssetLibrary.save_loaded_asset(anim)

        anim_lib = unreal.AnimationLibrary if hasattr(unreal, "AnimationLibrary") else unreal.AnimationBlueprintLibrary
        report["play_length"] = anim.get_play_length()
        report["root_motion_enabled"] = bool(anim_lib.is_root_motion_enabled(anim))
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
