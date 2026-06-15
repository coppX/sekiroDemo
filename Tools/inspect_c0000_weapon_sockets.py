import unreal


def main():
    mesh = unreal.load_asset("/Game/Animation/Sekiro/C0000/Base/c0000_bindpose")
    if not mesh:
        raise RuntimeError("Failed to load c0000_bindpose")

    names = [
        "R_Weapon",
        "L_Weapon",
        "Dummy10020_BackWeapon",
        "B_Wepon_Case",
        "B_Wepon_Case0_L",
        "B_Wepon_Case0_R",
        "R_Wepon_Case",
        "L_Wepon_Case",
    ]
    skel = mesh.get_editor_property("skeleton")
    ref = skel.get_reference_pose()
    bone_names = [str(name) for name in ref.get_bone_names()]
    for name in names:
        bone_index = bone_names.index(name) if name in bone_names else -1
        unreal.log(f"WEAPON_SOCKET_CHECK {name} bone_index={bone_index}")


main()
