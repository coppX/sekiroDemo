import json
from pathlib import Path

from sekiro_monolith_client import MCPClient, MCPError


PROJECT_ROOT = Path(__file__).resolve().parent.parent
REPORT_PATH = PROJECT_ROOT / "Saved" / "SekiroImportReports" / "c0000_directional_locomotion_fix.json"

ABP_PATH = "/Game/Animation/Sekiro/C0000/Blueprints/ABP_Sekiro_C0000_Master"
PREVIEW_BP_PATH = "/Game/Animation/Sekiro/C0000/Blueprints/BP_Sekiro_C0000_PreviewCharacter"
SKELETON_PATH = "/Game/Animation/Sekiro/C0000/Base/c0000_bindpose_Skeleton"
PREVIEW_CHARACTER_LABEL = "SekiroPreview_Character"
PREVIEW_MOVEMENT_COMPONENT_NAME = "CharMoveComp"

BASE_ANIM_ROOT = "/Game/Animation/Sekiro/C0000/StandMove_SM"
BLUEPRINT_ROOT = "/Game/Animation/Sekiro/C0000/Blueprints"
LOWER_ANIM_ROOT = "/Game/Animation/Sekiro/C0000/StandMoveLower_SM"

ANGLE_AXIS_2D = {
    "name": "MoveAngle",
    "min": -180.0,
    "max": 180.0,
    "grid_divisions": 4,
    "snap_to_grid": False,
    "wrap_input": True,
}
SPEED_AXIS_2D = {
    "name": "MoveSpeedLevel",
    "min": 0.0,
    "max": 1.0,
    "grid_divisions": 4,
    "snap_to_grid": False,
    "wrap_input": False,
}
ANGLE_AXIS_1D = {
    "name": "MoveAngle",
    "min": -180.0,
    "max": 180.0,
    "grid_divisions": 4,
    "snap_to_grid": False,
    "wrap_input": True,
}


def make_cardinal_angle_samples_2d(
    root_path: str,
    walk_ids: tuple[str, str, str, str],
    run_ids: tuple[str, str, str, str],
):
    samples = []
    cardinal_points = (
        (0.0, walk_ids[0], run_ids[0]),
        (90.0, walk_ids[3], run_ids[3]),
        (180.0, walk_ids[1], run_ids[1]),
        (-90.0, walk_ids[2], run_ids[2]),
        (-180.0, walk_ids[1], run_ids[1]),
    )
    for angle, walk_anim_id, run_anim_id in cardinal_points:
        samples.append({"anim_path": f"{root_path}/{walk_anim_id}", "x": angle, "y": 0.0})
        samples.append({"anim_path": f"{root_path}/{run_anim_id}", "x": angle, "y": 1.0})
    return samples


def make_cardinal_angle_samples_1d(root_path: str, ids: tuple[str, str, str, str]):
    samples = []
    cardinal_points = (
        (0.0, ids[0]),
        (90.0, ids[3]),
        (180.0, ids[1]),
        (-90.0, ids[2]),
        (-180.0, ids[1]),
    )
    for angle, anim_id in cardinal_points:
        samples.append({"anim_path": f"{root_path}/{anim_id}", "x": angle, "y": 0.0})
    return samples


BLENDSPACE_SPECS = [
    {
        "asset_path": f"{BLUEPRINT_ROOT}/BS_StandMoveStart_Directional",
        "kind": "2d",
        "axis_x": ANGLE_AXIS_2D,
        "axis_y": SPEED_AXIS_2D,
        "samples": make_cardinal_angle_samples_2d(
            BASE_ANIM_ROOT,
            ("a000_000100", "a000_000101", "a000_000102", "a000_000103"),
            ("a000_000400", "a000_000401", "a000_000402", "a000_000403"),
        ),
    },
    {
        "asset_path": f"{BLUEPRINT_ROOT}/BS_StandMoveStartFromFreeFall_Directional",
        "kind": "2d",
        "axis_x": ANGLE_AXIS_2D,
        "axis_y": SPEED_AXIS_2D,
        "samples": make_cardinal_angle_samples_2d(
            BASE_ANIM_ROOT,
            ("a000_000110", "a000_000111", "a000_000112", "a000_000113"),
            ("a000_000410", "a000_000411", "a000_000412", "a000_000413"),
        ),
    },
    {
        "asset_path": f"{BLUEPRINT_ROOT}/BS_StandMoveStartFromFreeFallShortStiff_Directional",
        "kind": "2d",
        "axis_x": ANGLE_AXIS_2D,
        "axis_y": SPEED_AXIS_2D,
        "samples": make_cardinal_angle_samples_2d(
            BASE_ANIM_ROOT,
            ("a000_000120", "a000_000121", "a000_000122", "a000_000123"),
            ("a000_000420", "a000_000421", "a000_000422", "a000_000423"),
        ),
    },
    {
        "asset_path": f"{BLUEPRINT_ROOT}/BS_StandMoveLoop_Directional",
        "kind": "2d",
        "axis_x": ANGLE_AXIS_2D,
        "axis_y": SPEED_AXIS_2D,
        "samples": make_cardinal_angle_samples_2d(
            BASE_ANIM_ROOT,
            ("a000_000200", "a000_000201", "a000_000202", "a000_000203"),
            ("a000_000500", "a000_000501", "a000_000502", "a000_000503"),
        ),
    },
    {
        "asset_path": f"{BLUEPRINT_ROOT}/BS_StandMoveLoopFromSprint_Directional",
        "kind": "2d",
        "axis_x": ANGLE_AXIS_2D,
        "axis_y": SPEED_AXIS_2D,
        "samples": make_cardinal_angle_samples_2d(
            BASE_ANIM_ROOT,
            ("a000_000160", "a000_000161", "a000_000162", "a000_000163"),
            ("a000_000460", "a000_000461", "a000_000462", "a000_000463"),
        ),
    },
    {
        "asset_path": f"{BLUEPRINT_ROOT}/BS_StandWalkStop_Directional",
        "kind": "1d",
        "axis": ANGLE_AXIS_1D,
        "samples": make_cardinal_angle_samples_1d(
            BASE_ANIM_ROOT,
            ("a000_000300", "a000_000301", "a000_000302", "a000_000303"),
        ),
    },
    {
        "asset_path": f"{BLUEPRINT_ROOT}/BS_StandRunStop_Directional",
        "kind": "1d",
        "axis": ANGLE_AXIS_1D,
        "samples": make_cardinal_angle_samples_1d(
            BASE_ANIM_ROOT,
            ("a000_000600", "a000_000601", "a000_000602", "a000_000603"),
        ),
    },
    {
        "asset_path": f"{BLUEPRINT_ROOT}/BS_StandMoveLowerStart_Directional",
        "kind": "2d",
        "axis_x": ANGLE_AXIS_2D,
        "axis_y": SPEED_AXIS_2D,
        "samples": make_cardinal_angle_samples_2d(
            LOWER_ANIM_ROOT,
            ("a000_000100", "a000_000101", "a000_000102", "a000_000103"),
            ("a000_000400", "a000_000401", "a000_000402", "a000_000403"),
        ),
    },
    {
        "asset_path": f"{BLUEPRINT_ROOT}/BS_StandMoveLowerLoop_Directional",
        "kind": "2d",
        "axis_x": ANGLE_AXIS_2D,
        "axis_y": SPEED_AXIS_2D,
        "samples": make_cardinal_angle_samples_2d(
            LOWER_ANIM_ROOT,
            ("a000_000200", "a000_000201", "a000_000202", "a000_000203"),
            ("a000_000500", "a000_000501", "a000_000502", "a000_000503"),
        ),
    },
]


STATE_SPECS = [
    {
        "machine_name": "StandMove_SM",
        "state_name": "StandMoveStart",
        "asset_path": f"{BLUEPRINT_ROOT}/BS_StandMoveStart_Directional",
        "loop": False,
        "bindings": (("MoveAngle", "X"), ("MoveSpeedLevel", "Y")),
    },
    {
        "machine_name": "StandMove_SM",
        "state_name": "StandMoveStartFromFreeFall",
        "asset_path": f"{BLUEPRINT_ROOT}/BS_StandMoveStartFromFreeFall_Directional",
        "loop": False,
        "bindings": (("MoveAngle", "X"), ("MoveSpeedLevel", "Y")),
    },
    {
        "machine_name": "StandMove_SM",
        "state_name": "StandMoveStartFromFreeFallShortStiff",
        "asset_path": f"{BLUEPRINT_ROOT}/BS_StandMoveStartFromFreeFallShortStiff_Directional",
        "loop": False,
        "bindings": (("MoveAngle", "X"), ("MoveSpeedLevel", "Y")),
    },
    {
        "machine_name": "StandMove_SM",
        "state_name": "StandMoveStartFromLandGroundPositioningJump",
        "asset_path": f"{BLUEPRINT_ROOT}/BS_StandMoveStartFromFreeFall_Directional",
        "loop": False,
        "bindings": (("MoveAngle", "X"), ("MoveSpeedLevel", "Y")),
    },
    {
        "machine_name": "StandMove_SM",
        "state_name": "StandMoveLoop",
        "asset_path": f"{BLUEPRINT_ROOT}/BS_StandMoveLoop_Directional",
        "loop": True,
        "bindings": (("MoveAngle", "X"), ("MoveSpeedLevel", "Y")),
    },
    {
        "machine_name": "StandMove_SM",
        "state_name": "StandMoveLoopFromSprint",
        "asset_path": f"{BLUEPRINT_ROOT}/BS_StandMoveLoopFromSprint_Directional",
        "loop": True,
        "bindings": (("MoveAngle", "X"), ("MoveSpeedLevel", "Y")),
    },
    {
        "machine_name": "StandMove_SM",
        "state_name": "StandWalkStop",
        "asset_path": f"{BLUEPRINT_ROOT}/BS_StandWalkStop_Directional",
        "loop": False,
        "bindings": (("MoveAngle", "X"),),
    },
    {
        "machine_name": "StandMove_SM",
        "state_name": "StandRunStop",
        "asset_path": f"{BLUEPRINT_ROOT}/BS_StandRunStop_Directional",
        "loop": False,
        "bindings": (("MoveAngle", "X"),),
    },
    {
        "machine_name": "StandMoveLower_SM",
        "state_name": "StandMoveLowerStart",
        "asset_path": f"{BLUEPRINT_ROOT}/BS_StandMoveLowerStart_Directional",
        "loop": False,
        "bindings": (("MoveAngle", "X"), ("MoveSpeedLevel", "Y")),
    },
    {
        "machine_name": "StandMoveLower_SM",
        "state_name": "StandMoveLowerLoop",
        "asset_path": f"{BLUEPRINT_ROOT}/BS_StandMoveLowerLoop_Directional",
        "loop": True,
        "bindings": (("MoveAngle", "X"), ("MoveSpeedLevel", "Y")),
    },
]


def create_or_reuse_blendspace(client: MCPClient, spec: dict):
    action = "create_blend_space_1d" if spec["kind"] == "1d" else "create_blend_space"
    params = {"asset_path": spec["asset_path"], "skeleton_path": SKELETON_PATH}
    if spec["kind"] == "1d":
        params.update(
            {
                "axis_name": spec["axis"]["name"],
                "axis_min": spec["axis"]["min"],
                "axis_max": spec["axis"]["max"],
            }
        )
    else:
        params.update(
            {
                "axis_x_name": spec["axis_x"]["name"],
                "axis_x_min": spec["axis_x"]["min"],
                "axis_x_max": spec["axis_x"]["max"],
                "axis_y_name": spec["axis_y"]["name"],
                "axis_y_min": spec["axis_y"]["min"],
                "axis_y_max": spec["axis_y"]["max"],
            }
        )

    try:
        created = client.call("animation_query", action, params)
    except MCPError as exc:
        if "already exists" not in str(exc):
            raise
        created = {"skipped": True, "message": str(exc)}

    axis_results = []
    if spec["kind"] == "1d":
        axis_results.append(
            client.call(
                "animation_query",
                "set_blend_space_axis",
                {
                    "asset_path": spec["asset_path"],
                    "axis": "X",
                    **spec["axis"],
                },
            )
        )
    else:
        axis_results.append(
            client.call(
                "animation_query",
                "set_blend_space_axis",
                {
                    "asset_path": spec["asset_path"],
                    "axis": "X",
                    **spec["axis_x"],
                },
            )
        )
        axis_results.append(
            client.call(
                "animation_query",
                "set_blend_space_axis",
                {
                    "asset_path": spec["asset_path"],
                    "axis": "Y",
                    **spec["axis_y"],
                },
            )
        )

    info = client.call("animation_query", "get_blend_space_info", {"asset_path": spec["asset_path"]})
    existing_samples = info.get("samples", [])
    for sample in sorted(existing_samples, key=lambda item: item["index"], reverse=True):
        client.call(
            "animation_query",
            "delete_blendspace_sample",
            {"asset_path": spec["asset_path"], "sample_index": sample["index"]},
        )

    added_samples = []
    for sample in spec["samples"]:
        added_samples.append(
            client.call(
                "animation_query",
                "add_blendspace_sample",
                {
                    "asset_path": spec["asset_path"],
                    "anim_path": sample["anim_path"],
                    "x": sample["x"],
                    "y": sample["y"],
                },
            )
        )

    final_info = client.call("animation_query", "get_blend_space_info", {"asset_path": spec["asset_path"]})
    return {
        "asset_path": spec["asset_path"],
        "create": created,
        "axis": axis_results,
        "samples": added_samples,
        "final_info": final_info,
    }


def wire_state_to_blendspace(client: MCPClient, spec: dict):
    set_result = client.call(
        "animation_query",
        "set_state_animation",
        {
            "asset_path": ABP_PATH,
            "machine_name": spec["machine_name"],
            "state_name": spec["state_name"],
            "anim_asset_path": spec["asset_path"],
            "loop": spec["loop"],
            "clear_existing": True,
        },
    )

    node_name = set_result["node_name"]
    wires = []
    for index, (variable_name, target_pin) in enumerate(spec["bindings"]):
        var_result = client.call(
            "animation_query",
            "add_variable_get",
            {
                "asset_path": ABP_PATH,
                "graph_name": spec["machine_name"],
                "state_name": spec["state_name"],
                "variable_name": variable_name,
                "position_x": -620,
                "position_y": -120 + index * 180,
            },
        )
        wire_result = client.call(
            "animation_query",
            "connect_anim_graph_pins",
            {
                "asset_path": ABP_PATH,
                "graph_name": spec["machine_name"],
                "state_name": spec["state_name"],
                "source_node": var_result["node_name"],
                "source_pin": variable_name,
                "target_node": node_name,
                "target_pin": target_pin,
                "compile": False,
            },
        )
        wires.append(
            {
                "variable_name": variable_name,
                "target_pin": target_pin,
                "variable_node": var_result,
                "wire": wire_result,
            }
        )

    return {
        "state_name": spec["state_name"],
        "machine_name": spec["machine_name"],
        "set_state_animation": set_result,
        "wires": wires,
    }


def run_editor_python(client: MCPClient, command: str):
    return client.call(
        "editor_query",
        "run_python",
        {
            "command": command,
            "mode": "execute_file",
            "unattended": True,
        },
    )


def configure_preview_rotation(client: MCPClient):
    cdo_results = [
        client.call(
            "blueprint_query",
            "set_cdo_property",
            {
                "asset_path": PREVIEW_BP_PATH,
                "property_name": "bUseControllerRotationYaw",
                "value": False,
            },
        ),
        client.call(
            "blueprint_query",
            "set_component_property",
            {
                "asset_path": PREVIEW_BP_PATH,
                "component_name": PREVIEW_MOVEMENT_COMPONENT_NAME,
                "property_name": "bOrientRotationToMovement",
                "value": False,
            },
        ),
        client.call(
            "blueprint_query",
            "set_component_property",
            {
                "asset_path": PREVIEW_BP_PATH,
                "component_name": PREVIEW_MOVEMENT_COMPONENT_NAME,
                "property_name": "bUseControllerDesiredRotation",
                "value": False,
            },
        ),
        client.call(
            "blueprint_query",
            "set_component_property",
            {
                "asset_path": PREVIEW_BP_PATH,
                "component_name": PREVIEW_MOVEMENT_COMPONENT_NAME,
                "property_name": "RotationRate",
                "value": "(Pitch=0.0,Yaw=0.0,Roll=0.0)",
            },
        ),
    ]

    command = f"""
import json
import unreal

actor_subsystem = unreal.get_editor_subsystem(unreal.EditorActorSubsystem)
result = {{'updated_actor': False}}
for actor in actor_subsystem.get_all_level_actors():
    if actor.get_actor_label() != '{PREVIEW_CHARACTER_LABEL}':
        continue

    actor.use_controller_rotation_yaw = False
    actor.use_controller_rotation_pitch = False
    actor.use_controller_rotation_roll = False

    move = actor.get_movement_component()
    if move:
        move.orient_rotation_to_movement = False
        move.use_controller_desired_rotation = False
        move.rotation_rate = unreal.Rotator(0.0, 0.0, 0.0)

    result = {{
        'updated_actor': True,
        'use_controller_rotation_yaw': bool(actor.use_controller_rotation_yaw),
        'orient_rotation_to_movement': bool(move.orient_rotation_to_movement) if move else None,
        'use_controller_desired_rotation': bool(move.use_controller_desired_rotation) if move else None,
        'rotation_rate': {{
            'pitch': move.rotation_rate.pitch if move else None,
            'yaw': move.rotation_rate.yaw if move else None,
            'roll': move.rotation_rate.roll if move else None,
        }},
    }}
    break

print(json.dumps(result, ensure_ascii=False))
"""
    actor_result = run_editor_python(client, command)
    return {
        "blueprint_defaults": cdo_results,
        "editor_actor": actor_result,
    }


def save_assets(client: MCPClient, asset_paths: list[str]):
    unique_paths = []
    for path in asset_paths:
        if path not in unique_paths:
            unique_paths.append(path)

    command = f"""
import json
import unreal

paths = {json.dumps(unique_paths, ensure_ascii=False)}
results = []
for path in paths:
    saved = unreal.EditorAssetLibrary.save_asset(path, only_if_is_dirty=False)
    results.append({{'asset_path': path, 'saved': bool(saved)}})

print(json.dumps(results, ensure_ascii=False))
"""
    return run_editor_python(client, command)


def main():
    client = MCPClient()
    report = {
        "blendspaces": [],
        "states": [],
    }

    for spec in BLENDSPACE_SPECS:
        report["blendspaces"].append(create_or_reuse_blendspace(client, spec))

    for spec in STATE_SPECS:
        report["states"].append(wire_state_to_blendspace(client, spec))

    report["compile"] = client.call("blueprint_query", "compile_blueprint", {"asset_path": ABP_PATH})
    report["preview_rotation"] = configure_preview_rotation(client)
    report["save_assets"] = save_assets(
        client,
        [ABP_PATH, PREVIEW_BP_PATH] + [spec["asset_path"] for spec in BLENDSPACE_SPECS],
    )

    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    print(json.dumps(report, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
