import os
import unreal

FBX = r"E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE\exports\c1010_weapon_katana\c1010_bindpose.fbx"
DEST = "/Game/Animation/Sekiro/Enemy/C1010/Weapons/Katana"
SKEL = "/Game/Animation/Sekiro/Enemy/C1010/Base/c1010_bindpose_Skeleton.c1010_bindpose_Skeleton"
BP = "/Game/Animation/Sekiro/Enemy/C1010/Blueprints/BP_Sekiro_Enemy_C1010.BP_Sekiro_Enemy_C1010"
ABP = "/Game/Animation/Sekiro/Enemy/C1010/ABP_Sekiro_Enemy_C1010_Minimal.ABP_Sekiro_Enemy_C1010_Minimal_C"
WEAPON = DEST + "/SK_C1010_Katana.SK_C1010_Katana"
SRC_BODY = "/Game/Animation/Sekiro/Enemy/C1010/Base/c1010_bindpose.c1010_bindpose"

if not unreal.EditorAssetLibrary.does_directory_exist(DEST):
    unreal.EditorAssetLibrary.make_directory(DEST)

skeleton = unreal.load_asset(SKEL)
opts = unreal.FbxImportUI()
opts.set_editor_property("automated_import_should_detect_type", False)
opts.set_editor_property("original_import_type", unreal.FBXImportType.FBXIT_SKELETAL_MESH)
opts.set_editor_property("mesh_type_to_import", unreal.FBXImportType.FBXIT_SKELETAL_MESH)
opts.set_editor_property("import_as_skeletal", True)
opts.set_editor_property("import_mesh", True)
opts.set_editor_property("import_animations", False)
opts.set_editor_property("create_physics_asset", False)
opts.set_editor_property("import_materials", True)
opts.set_editor_property("import_textures", True)
opts.set_editor_property("skeleton", skeleton)
data = opts.get_editor_property("skeletal_mesh_import_data")
data.set_editor_property("convert_scene", True)
data.set_editor_property("convert_scene_unit", True)
data.set_editor_property("preserve_smoothing_groups", True)
data.set_editor_property("normal_import_method", unreal.FBXNormalImportMethod.FBXNIM_IMPORT_NORMALS_AND_TANGENTS)

task = unreal.AssetImportTask()
task.set_editor_property("filename", FBX)
task.set_editor_property("destination_path", DEST)
task.set_editor_property("destination_name", "SK_C1010_Katana")
task.set_editor_property("automated", True)
task.set_editor_property("replace_existing", True)
task.set_editor_property("replace_existing_settings", True)
task.set_editor_property("save", True)
task.set_editor_property("options", opts)
unreal.AssetToolsHelpers.get_asset_tools().import_asset_tasks([task])

weapon = unreal.load_asset(WEAPON)
body = unreal.load_asset(SRC_BODY)
if not weapon:
    raise RuntimeError("Weapon import failed")

src_by_name = {str(s.material_slot_name): s.material_interface for s in body.get_editor_property("materials")}
slots = []
for slot in weapon.get_editor_property("materials"):
    name = str(slot.material_slot_name)
    if name in src_by_name and src_by_name[name]:
        slot.material_interface = src_by_name[name]
    slots.append(slot)
weapon.set_editor_property("materials", slots)
unreal.EditorAssetLibrary.save_asset(WEAPON)
print("imported", WEAPON, "slots", len(slots))
