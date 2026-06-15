import unreal


BACK_ATTACH_SOCKET = "C0000_FLVERDummy_044_Ref047_A_Spine2"
BACK_AIM_SOCKET = "C0000_FLVERDummy_528_Ref015_A_LargeSheath"


def component_info(component):
    mesh = component.get_editor_property("static_mesh")
    attach_parent = component.get_attach_parent()
    return {
        "name": component.get_name(),
        "socket": str(component.get_attach_socket_name()),
        "parent": attach_parent.get_name() if attach_parent else "",
        "mesh": mesh.get_path_name() if mesh else "",
        "relative_rotation": str(component.get_editor_property("relative_rotation")),
        "relative_location": str(component.get_editor_property("relative_location")),
        "hidden_in_game": component.get_editor_property("hidden_in_game"),
    }


def normal(vector):
    length = vector.length()
    if length <= 0.0001:
        return unreal.Vector(0.0, 0.0, 0.0)
    return vector / length


def verify_spawned_alignment(cls):
    actor = unreal.EditorLevelLibrary.spawn_actor_from_class(
        cls,
        unreal.Vector(0.0, 0.0, 0.0),
        unreal.Rotator(0.0, 0.0, 0.0),
    )
    try:
        components = {
            component.get_name(): component
            for component in actor.get_components_by_class(unreal.StaticMeshComponent)
        }
        sheathed = components["BackSheathedWeapon"]
        mesh_component = actor.get_editor_property("mesh")
        if str(sheathed.get_attach_socket_name()) != BACK_ATTACH_SOCKET:
            raise RuntimeError("Spawned BackSheathedWeapon is not attached to expected back socket")
        attach_distance = (
            sheathed.get_socket_location("socket1")
            - mesh_component.get_socket_location(BACK_ATTACH_SOCKET)
        ).length()
        aim_distance = (
            sheathed.get_socket_location("socket2")
            - mesh_component.get_socket_location(BACK_AIM_SOCKET)
        ).length()
        weapon_direction = normal(
            sheathed.get_socket_location("socket2") - sheathed.get_socket_location("socket1")
        )
        back_direction = normal(
            mesh_component.get_socket_location(BACK_AIM_SOCKET) - mesh_component.get_socket_location(BACK_ATTACH_SOCKET)
        )
        direction_dot = weapon_direction.dot(back_direction)
        unreal.log(
            "VERIFY_MORTAL_BLADE_ALIGNMENT "
            f"socket1_to_back_attach={attach_distance:.4f} socket2_to_back_aim={aim_distance:.4f} "
            f"direction_dot={direction_dot:.4f} "
            f"relative_scale={sheathed.get_editor_property('relative_scale3d')}"
        )
        scale = sheathed.get_editor_property("relative_scale3d")
        if (
            attach_distance > 0.1
            or aim_distance > 1.3
            or direction_dot < 0.99
            or abs(scale.x - 1.0) > 0.001
            or abs(scale.y - 1.0) > 0.001
            or abs(scale.z - 1.0) > 0.001
        ):
            raise RuntimeError(
                "Back sheathed weapon socket alignment is wrong: "
                f"socket1_to_back_attach={attach_distance}, "
                f"socket2_to_back_aim={aim_distance}, direction_dot={direction_dot}, scale={scale}"
            )
    finally:
        unreal.EditorLevelLibrary.destroy_actor(actor)


def main():
    cls = unreal.load_class(
        None,
        "/Game/Animation/Sekiro/C0000/Blueprints/BP_Sekiro_C0000_PreviewCharacter.BP_Sekiro_C0000_PreviewCharacter_C",
    )
    if not cls:
        cls = unreal.load_class(None, "/Script/SekiroDemo.SekiroC0000PreviewCharacter")
    if not cls:
        raise RuntimeError("Failed to load preview character class")

    cdo = unreal.get_default_object(cls)
    mesh_component = cdo.get_editor_property("mesh")
    for socket_name in (BACK_ATTACH_SOCKET, BACK_AIM_SOCKET, "R_Weapon", "L_Wepon_Case"):
        if not mesh_component.does_socket_exist(socket_name):
            raise RuntimeError(f"Missing character mesh socket/bone: {socket_name}")

    components = {
        component.get_name(): component
        for component in cdo.get_components_by_class(unreal.StaticMeshComponent)
    }

    for name in ("BackSheathedWeapon", "LeftHandScabbard", "RightHandDrawBlade"):
        component = components.get(name)
        if not component:
            raise RuntimeError(f"Missing component: {name}")
        unreal.log(f"VERIFY_MORTAL_BLADE {component_info(component)}")

    sheathed = components["BackSheathedWeapon"]
    left_scabbard = components["LeftHandScabbard"]
    if str(left_scabbard.get_attach_socket_name()) != "L_Wepon_Case":
        raise RuntimeError("LeftHandScabbard is not attached to waist case bone L_Wepon_Case")
    if str(components["RightHandDrawBlade"].get_attach_socket_name()) != "R_Weapon":
        raise RuntimeError("RightHandDrawBlade is not attached to R_Weapon")
    if not sheathed.get_editor_property("static_mesh"):
        raise RuntimeError("BackSheathedWeapon has no mesh")
    if not left_scabbard.get_editor_property("static_mesh"):
        raise RuntimeError("LeftHandScabbard has no mesh")
    if "SM_WP_A_0300_L_Sheathed" not in sheathed.get_editor_property("static_mesh").get_path_name():
        raise RuntimeError("Back sheathed weapon is not using SM_WP_A_0300_L_Sheathed")
    for socket_name in ("socket1", "socket2"):
        if not sheathed.does_socket_exist(socket_name):
            raise RuntimeError(f"Back sheathed weapon mesh is missing socket: {socket_name}")
    if not components["RightHandDrawBlade"].get_editor_property("static_mesh"):
        raise RuntimeError("RightHandDrawBlade has no mesh")

    verify_spawned_alignment(cls)

    unreal.log("VERIFY_MORTAL_BLADE success")


main()
