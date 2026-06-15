import unreal

SRC = "/Game/Animation/Sekiro/Enemy/C1010/Base/c1010_bindpose.c1010_bindpose"
DST = "/Game/Animation/Sekiro/Enemy/C1010/BaseFiltered/c1010_bindpose.c1010_bindpose"

src = unreal.load_asset(SRC)
dst = unreal.load_asset(DST)
if not src or not dst:
    raise RuntimeError("Missing source or filtered skeletal mesh")

src_by_name = {}
for mat in src.get_editor_property("materials"):
    src_by_name[str(mat.material_slot_name)] = mat.material_interface

new_slots = []
for slot in dst.get_editor_property("materials"):
    name = str(slot.material_slot_name)
    if name in src_by_name and src_by_name[name]:
        slot.material_interface = src_by_name[name]
    new_slots.append(slot)

dst.set_editor_property("materials", new_slots)
unreal.EditorAssetLibrary.save_asset(DST)
print(f"fixed {len(new_slots)} slots")
