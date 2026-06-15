import json
from pathlib import Path

from sekiro_monolith_client import MCPClient, MCPError, ensure_call


ABP_PATH = "/Game/Animation/Sekiro/C0000/Blueprints/ABP_Sekiro_C0000_Master"
PREVIEW_BP_PATH = "/Game/Animation/Sekiro/C0000/Blueprints/BP_Sekiro_C0000_PreviewCharacter"
PREVIEW_MAP_PATH = "/Game/Maps/Debug/L_Sekiro_C0000_Preview"
PREVIEW_BP_PARENT = "/Script/SekiroDemo.SekiroC0000PreviewCharacter"
SKELETAL_MESH_OBJECT_PATH = "/Game/Animation/Sekiro/C0000/Base/c0000_bindpose.c0000_bindpose"
ANIM_BLUEPRINT_CLASS_PATH = "/Game/Animation/Sekiro/C0000/Blueprints/ABP_Sekiro_C0000_Master.ABP_Sekiro_C0000_Master_C"
REPORT_PATH = Path(r"E:\UEProj\Sekiro\SekiroDemo\Saved\SekiroImportReports\c0000_preview_runtime_setup.json")
PREVIEW_MESH_COMPONENT_NAME = "CharacterMesh0"
PREVIEW_FOLDER = "SekiroPreview"
PREVIEW_FLOOR_LABEL = "SekiroPreview_Floor"
PREVIEW_DIRECTIONAL_LIGHT_LABEL = "SekiroPreview_DirectionalLight"
PREVIEW_SKYLIGHT_LABEL = "SekiroPreview_SkyLight"
PREVIEW_CHARACTER_LABEL = "SekiroPreview_Character"
PREVIEW_MAP_GAMEMODE_CLASS_PATH = "/Script/SekiroDemo.SekiroUIPreviewGameMode"


RUNTIME_VARIABLES = [
    {"name": "MoveType", "type": "int", "default_value": "0", "category": "Sekiro|Runtime", "instance_editable": False},
    {"name": "StanceMoveType", "type": "int", "default_value": "0", "category": "Sekiro|Runtime", "instance_editable": False},
    {"name": "MoveSpeedIndex", "type": "int", "default_value": "0", "category": "Sekiro|Runtime", "instance_editable": False},
    {"name": "NightvisionMoveSpeedIndex", "type": "int", "default_value": "0", "category": "Sekiro|Runtime", "instance_editable": False},
    {"name": "Selector_UseTransitionEffect", "type": "int", "default_value": "0", "category": "Sekiro|Runtime", "instance_editable": False},
    {"name": "Selector_UseStaterToStateTransitionEffect", "type": "int", "default_value": "0", "category": "Sekiro|Runtime", "instance_editable": False},
    {"name": "MoveSpeedLevel", "type": "float", "default_value": "0.0", "category": "Sekiro|Runtime", "instance_editable": False},
    {"name": "MoveSpeedLevelReal", "type": "float", "default_value": "0.0", "category": "Sekiro|Runtime", "instance_editable": False},
    {"name": "MoveDirection", "type": "float", "default_value": "0.0", "category": "Sekiro|Runtime", "instance_editable": False},
    {"name": "MoveAngle", "type": "float", "default_value": "0.0", "category": "Sekiro|Runtime", "instance_editable": False},
    {"name": "TurnAngle", "type": "float", "default_value": "0.0", "category": "Sekiro|Runtime", "instance_editable": False},
    {"name": "TwistLowerRootAngle", "type": "float", "default_value": "0.0", "category": "Sekiro|Runtime", "instance_editable": False},
    {"name": "StartTime_01", "type": "float", "default_value": "0.0", "category": "Sekiro|Runtime", "instance_editable": False},
    {"name": "StartTime_02", "type": "float", "default_value": "0.0", "category": "Sekiro|Runtime", "instance_editable": False},
    {"name": "StartTime_03", "type": "float", "default_value": "0.0", "category": "Sekiro|Runtime", "instance_editable": False},
]


def save_asset_with_fallback(client: MCPClient, asset_path: str):
    try:
        return client.call("blueprint_query", "save_asset", {"asset_path": asset_path})
    except MCPError as exc:
        save_via_editor = client.call(
            "editor_query",
            "run_python",
            {
                "command": (
                    "import json\n"
                    "import unreal\n"
                    f"asset = unreal.load_asset('{asset_path}')\n"
                    "if not asset:\n"
                    "    raise RuntimeError('Failed to load asset for fallback save.')\n"
                    "saved = unreal.EditorAssetLibrary.save_loaded_asset(asset, only_if_is_dirty=False)\n"
                    "if not saved:\n"
                    f"    saved = unreal.EditorAssetLibrary.save_asset('{asset_path}', only_if_is_dirty=False)\n"
                    "print(json.dumps({\n"
                    f"    'asset_path': '{asset_path}',\n"
                    "    'saved': bool(saved),\n"
                    "}, ensure_ascii=False))\n"
                ),
                "mode": "execute_file",
                "unattended": True,
            },
        )
        return {
            "fallback": True,
            "warning": str(exc),
            "editor_save": save_via_editor,
        }


def add_runtime_variables(client: MCPClient, report: dict):
    results = []
    for variable in RUNTIME_VARIABLES:
        result = ensure_call(
            client,
            "blueprint_query",
            "add_variable",
            {"asset_path": ABP_PATH, **variable},
            ok_errors=("already exists",),
        )
        results.append({"name": variable["name"], "result": result})

    compile_result = client.call("blueprint_query", "compile_blueprint", {"asset_path": ABP_PATH})
    save_result = save_asset_with_fallback(client, ABP_PATH)

    defaults = [
        {"property_name": "StateStateId_StandMoveableAction", "value": -1},
        {"property_name": "MoveType", "value": 0},
        {"property_name": "StanceMoveType", "value": 0},
        {"property_name": "MoveSpeedIndex", "value": 0},
        {"property_name": "NightvisionMoveSpeedIndex", "value": 0},
        {"property_name": "Selector_UseTransitionEffect", "value": 0},
        {"property_name": "Selector_UseStaterToStateTransitionEffect", "value": 0},
        {"property_name": "MoveSpeedLevel", "value": 0.0},
        {"property_name": "MoveSpeedLevelReal", "value": 0.0},
        {"property_name": "MoveDirection", "value": 0.0},
        {"property_name": "MoveAngle", "value": 0.0},
        {"property_name": "TurnAngle", "value": 0.0},
        {"property_name": "TwistLowerRootAngle", "value": 0.0},
        {"property_name": "StartTime_01", "value": 0.0},
        {"property_name": "StartTime_02", "value": 0.0},
        {"property_name": "StartTime_03", "value": 0.0},
    ]

    default_results = []
    for item in defaults:
        default_results.append(
            {
                "property_name": item["property_name"],
                "result": ensure_call(
                    client,
                    "blueprint_query",
                    "set_cdo_property",
                    {"asset_path": ABP_PATH, "property_name": item["property_name"], "value": item["value"]},
                    ok_errors=("not found",),
                ),
            }
        )

    report["runtime_variables"] = results
    report["runtime_variables_compile"] = compile_result
    report["runtime_variables_save"] = save_result
    report["runtime_defaults"] = default_results


def create_preview_blueprint(client: MCPClient, report: dict):
    create_result = ensure_call(
        client,
        "blueprint_query",
        "create_blueprint",
        {"save_path": PREVIEW_BP_PATH, "parent_class": PREVIEW_BP_PARENT},
        ok_errors=("already exists",),
    )
    reparent_result = ensure_call(
        client,
        "blueprint_query",
        "reparent_blueprint",
        {"asset_path": PREVIEW_BP_PATH, "new_parent_class": PREVIEW_BP_PARENT},
    )

    mesh_results = [
        ensure_call(
            client,
            "blueprint_query",
            "set_component_property",
            {
                "asset_path": PREVIEW_BP_PATH,
                "component_name": PREVIEW_MESH_COMPONENT_NAME,
                "property_name": "SkeletalMesh",
                "value": SKELETAL_MESH_OBJECT_PATH,
            },
        ),
        ensure_call(
            client,
            "blueprint_query",
            "set_component_property",
            {
                "asset_path": PREVIEW_BP_PATH,
                "component_name": PREVIEW_MESH_COMPONENT_NAME,
                "property_name": "AnimClass",
                "value": ANIM_BLUEPRINT_CLASS_PATH,
            },
        ),
    ]

    compile_result = client.call("blueprint_query", "compile_blueprint", {"asset_path": PREVIEW_BP_PATH})
    save_result = save_asset_with_fallback(client, PREVIEW_BP_PATH)

    report["preview_blueprint"] = {
        "create": create_result,
        "reparent": reparent_result,
        "mesh_setup": mesh_results,
        "compile": compile_result,
        "save": save_result,
    }


def create_preview_map(client: MCPClient, report: dict):
    try:
        map_load = client.call("editor_query", "load_level", {"path": PREVIEW_MAP_PATH})
        map_create = {"skipped": True, "message": "Loaded existing preview map."}
    except MCPError:
        map_create = ensure_call(
            client,
            "editor_query",
            "create_empty_map",
            {"path": PREVIEW_MAP_PATH, "map_template": "blank"},
            ok_errors=("already exists", "CreateAsset returned null"),
        )
        map_load = client.call("editor_query", "load_level", {"path": PREVIEW_MAP_PATH})
    clear_preview = client.call(
        "editor_query",
        "run_python",
        {
            "command": (
                "import unreal\n"
                f"folder = '{PREVIEW_FOLDER}'\n"
                "actor_subsystem = unreal.get_editor_subsystem(unreal.EditorActorSubsystem)\n"
                "actors = list(actor_subsystem.get_all_level_actors())\n"
                "deleted = []\n"
                "for actor in actors:\n"
                "    actor_folder = str(actor.get_folder_path())\n"
                "    if actor_folder == folder or actor_folder.startswith(folder + '/'):\n"
                "        deleted.append(actor.get_actor_label())\n"
                "        unreal.EditorLevelLibrary.destroy_actor(actor)\n"
                "print({'deleted_count': len(deleted), 'deleted_labels': deleted})\n"
            ),
            "mode": "execute_file",
            "unattended": True,
        },
    )

    floor = client.call(
        "mesh_query",
        "spawn_actor",
        {
            "class_or_mesh": "/Engine/BasicShapes/Cube",
            "location": [0.0, 0.0, -100.0],
            "rotation": [0.0, 0.0, 0.0],
            "scale": [30.0, 30.0, 1.0],
            "name": PREVIEW_FLOOR_LABEL,
            "folder": PREVIEW_FOLDER,
        },
    )
    directional_light = client.call(
        "mesh_query",
        "spawn_actor",
        {
            "class_or_mesh": "DirectionalLight",
            "location": [0.0, 0.0, 450.0],
            "rotation": [-45.0, 45.0, 0.0],
            "scale": [1.0, 1.0, 1.0],
            "name": PREVIEW_DIRECTIONAL_LIGHT_LABEL,
            "folder": PREVIEW_FOLDER,
        },
    )
    skylight = client.call(
        "mesh_query",
        "spawn_actor",
        {
            "class_or_mesh": "SkyLight",
            "location": [0.0, 0.0, 200.0],
            "rotation": [0.0, 0.0, 0.0],
            "scale": [1.0, 1.0, 1.0],
            "name": PREVIEW_SKYLIGHT_LABEL,
            "folder": PREVIEW_FOLDER,
        },
    )
    character = client.call(
        "blueprint_query",
        "spawn_blueprint_actor",
        {
            "blueprint": PREVIEW_BP_PATH,
            "location": [0.0, 0.0, -88.0],
            "rotation": [0.0, 0.0, 0.0],
            "scale": [1.0, 1.0, 1.0],
            "label": PREVIEW_CHARACTER_LABEL,
            "folder": PREVIEW_FOLDER,
        },
    )
    preview_world_settings = client.call(
        "editor_query",
        "run_python",
        {
            "command": (
                "import json\n"
                "import unreal\n"
                "world = unreal.EditorLevelLibrary.get_editor_world()\n"
                "world_settings = world.get_world_settings() if world else None\n"
                f"game_mode_class = unreal.load_class(None, '{PREVIEW_MAP_GAMEMODE_CLASS_PATH}')\n"
                "if not world_settings:\n"
                "    raise RuntimeError('Failed to resolve preview world settings.')\n"
                "if not game_mode_class:\n"
                "    raise RuntimeError('Failed to load preview map GameMode class.')\n"
                "world_settings.set_editor_property('default_game_mode', game_mode_class)\n"
                "resolved = world_settings.get_editor_property('default_game_mode')\n"
                "print(json.dumps({\n"
                "    'world': world.get_path_name() if world else None,\n"
                "    'default_game_mode': resolved.get_path_name() if resolved else None,\n"
                "}, ensure_ascii=False))\n"
            ),
            "mode": "execute_file",
            "unattended": True,
        },
    )
    save_level = client.call(
        "editor_query",
        "run_python",
        {
            "command": "import unreal\nunreal.EditorLevelLibrary.save_current_level()",
            "mode": "execute_file",
            "unattended": True,
        },
    )

    report["preview_map"] = {
        "create": map_create,
        "load": map_load,
        "clear_preview": clear_preview,
        "floor": floor,
        "directional_light": directional_light,
        "skylight": skylight,
        "character": character,
        "world_settings": preview_world_settings,
        "save_level": save_level,
    }


def main():
    client = MCPClient()
    report = {}

    add_runtime_variables(client, report)
    create_preview_blueprint(client, report)
    create_preview_map(client, report)

    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    print(json.dumps(report, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
