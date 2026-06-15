import sys
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from Tools.sekiro_monolith_client import MCPClient, ensure_call


ABP = "/Game/Animation/Sekiro/Enemy/C1010/ABP_Sekiro_Enemy_C1010_HKX_MoveBattle_Final"
SKELETON = "/Game/Animation/Sekiro/Enemy/C1010/Base/c1010_bindpose_Skeleton.c1010_bindpose_Skeleton"
BP_C1010 = "/Game/Animation/Sekiro/Enemy/C1010/Blueprints/BP_Sekiro_Enemy_C1010"

IDLE = "/Game/Animation/Sekiro/Enemy/C1010/Minimal/a000_000000"
ATTACK = "/Game/Animation/Sekiro/Enemy/C1010/Minimal/a000_003000"
DEATH_START = "/Game/Animation/Sekiro/Enemy/C1010/Death/DeathStart_SM/a000_010000"
DEATH_IDLE = "/Game/Animation/Sekiro/Enemy/C1010/Death/DeathIdle_SM/a000_010001"

MOVE_ANIMS = {
    "RunFrontBattle": "/Game/Animation/Sekiro/Enemy/C1010/MoveBattle/a000_405010",
    "WalkFrontBattle": "/Game/Animation/Sekiro/Enemy/C1010/MoveBattle/a000_405000",
    "WalkLeftBattle": "/Game/Animation/Sekiro/Enemy/C1010/MoveBattle/a000_405002",
    "WalkBackBattle": "/Game/Animation/Sekiro/Enemy/C1010/MoveBattle/a000_405001",
    "WalkRightBattle": "/Game/Animation/Sekiro/Enemy/C1010/MoveBattle/a000_405003",
}

VARS = [
    ("C9997_Req_Move", "bool", "false"),
    ("C9997_Req_Attack", "bool", "false"),
    ("C9997_Req_Death", "bool", "false"),
    ("C9997_Return_BattleIdle", "bool", "false"),
    ("MoveBattle_IsRunFront", "bool", "false"),
    ("MoveBattle_IsWalkFront", "bool", "false"),
    ("MoveBattle_IsWalkLeft", "bool", "false"),
    ("MoveBattle_IsWalkBack", "bool", "false"),
    ("MoveBattle_IsWalkRight", "bool", "false"),
    ("MoveBattleStateId", "int", "1"),
    ("MoveSpeedLevel", "float", "0.0"),
    ("MoveDirection", "float", "0.0"),
    ("EnemyLayer", "int", "0"),
    ("EnemyAttackId", "int", "0"),
    ("EnemyStateId", "int", "0"),
    ("C9997_Death_ToIdle", "bool", "false"),
]


def node_id_by_title(c, graph_name, title):
    try:
        data = c.call("blueprint_query", "get_graph_data", {"asset_path": ABP, "graph_name": graph_name})
    except Exception:
        return None
    for node in data.get("nodes", []):
        if node.get("title", "").split("\n", 1)[0] == title:
            return node.get("id")
    return None


def ensure_state_machine(c, graph_name, machine_name, state_name=None, x=0, y=0):
    machines = c.call("animation_query", "get_state_machines", {"asset_path": ABP}).get("state_machines", [])
    if any(m.get("name") == machine_name for m in machines):
        return node_id_by_title(c, state_name or graph_name, machine_name)
    params = {"asset_path": ABP, "graph_name": graph_name, "node_type": "StateMachine", "position_x": x, "position_y": y}
    if state_name:
        params["state_name"] = state_name
    node = c.call("animation_query", "add_anim_graph_node", params)
    ensure_call(c, "animation_query", "rename_state_machine", {"asset_path": ABP, "old_name": "New State Machine", "new_name": machine_name}, ok_errors=("not found", "already"))
    return node_id_by_title(c, state_name or graph_name, machine_name) or node.get("node_name")


def connect_result(c, graph_name, source_id, state_name=None):
    if state_name:
        target_id = c.call(
            "editor_query",
            "run_python",
            {
                "command": (
                    "import unreal\n"
                    f"abp=unreal.load_asset('{ABP}')\n"
                    f"g=next(g for g in abp.get_animation_graphs() if g.get_name()=='{state_name}')\n"
                    "n=g.get_graph_nodes_of_class(unreal.AnimGraphNode_StateResult.static_class(), True)[0]\n"
                    "print(n.get_name())\n"
                ),
                "mode": "execute_file",
                "unattended": True,
            },
        )["output"][0]["output"].strip()
        src_pin = "Pose"
        dst_pin = "Result"
        dst = {"id": target_id}
    else:
        data = c.call("blueprint_query", "get_graph_data", {"asset_path": ABP, "graph_name": graph_name})
        src = next(n for n in data["nodes"] if n["id"] == source_id)
        dst = next(n for n in data["nodes"] if n["class"] == "AnimGraphNode_Root")
        src_pin = next(p["name"] for p in src["pins"] if p["direction"] == "output" and "Pose" in p["name"])
        dst_pin = next(p["name"] for p in dst["pins"] if p["direction"] == "input")
    params = {
        "asset_path": ABP,
        "graph_name": graph_name,
        "source_node": source_id,
        "source_pin": src_pin,
        "target_node": dst["id"],
        "target_pin": dst_pin,
        "compile": False,
    }
    if state_name:
        params["state_name"] = state_name
    return ensure_call(c, "animation_query", "connect_anim_graph_pins", params, ok_errors=("TryCreateConnection failed", "already"))


def add_transition(c, machine, src, dst, var):
    ensure_call(
        c,
        "animation_query",
        "add_transition",
        {"asset_path": ABP, "machine_name": machine, "from_state": src, "to_state": dst},
        ok_errors=("already", "invalid"),
    )
    ensure_call(
        c,
        "animation_query",
        "set_transition_rule",
        {
            "asset_path": ABP,
            "machine_name": machine,
            "from_state": src,
            "to_state": dst,
            "variable_name": var,
            "compile": False,
        },
    )


def main():
    c = MCPClient()
    c.call(
        "editor_query",
        "run_python",
        {
            "command": (
                "import unreal\n"
                f"if unreal.EditorAssetLibrary.does_asset_exist('{ABP}'):\n"
                f"    unreal.EditorAssetLibrary.delete_asset('{ABP}')\n"
            ),
            "mode": "execute_file",
            "unattended": True,
        },
    )
    ensure_call(c, "animation_query", "create_anim_blueprint", {"asset_path": ABP, "skeleton_path": SKELETON, "parent_class": "AnimInstance"}, ok_errors=("already exists",))

    for name, typ, default in VARS:
        ensure_call(c, "blueprint_query", "add_variable", {"asset_path": ABP, "name": name, "type": typ, "default_value": default, "category": "C9997 Enemy Bridge", "instance_editable": True}, ok_errors=("already exists",))

    top_id = ensure_state_machine(c, "AnimGraph", "Move_SM", x=340, y=80)
    if top_id:
        connect_result(c, "AnimGraph", top_id)

    for name, x, y in [("BattleIdle", 0, 0), ("MoveBattle", 300, 0), ("Attack", 640, -160), ("Death", 640, 160)]:
        ensure_call(c, "animation_query", "add_state_to_machine", {"asset_path": ABP, "machine_name": "Move_SM", "state_name": name, "position_x": x, "position_y": y}, ok_errors=("already exists",))

    for state, anim, loop in [("BattleIdle", IDLE, True), ("Attack", ATTACK, False)]:
        ensure_call(c, "animation_query", "set_state_animation", {"asset_path": ABP, "machine_name": "Move_SM", "state_name": state, "anim_asset_path": anim, "loop": loop, "clear_existing": True})
    ensure_call(c, "animation_query", "set_state_machine_entry", {"asset_path": ABP, "machine_name": "Move_SM", "state_name": "BattleIdle"})

    nested_id = ensure_state_machine(c, "Move_SM", "MoveBattle_SM", state_name="MoveBattle", x=160, y=0)
    if nested_id:
        connect_result(c, "Move_SM", nested_id, "MoveBattle")

    for i, (state, anim) in enumerate(MOVE_ANIMS.items()):
        ensure_call(c, "animation_query", "add_state_to_machine", {"asset_path": ABP, "machine_name": "MoveBattle_SM", "state_name": state, "position_x": 320, "position_y": (i - 2) * 180}, ok_errors=("already exists",))
        ensure_call(c, "animation_query", "set_state_animation", {"asset_path": ABP, "machine_name": "MoveBattle_SM", "state_name": state, "anim_asset_path": anim, "loop": True, "clear_existing": True})
    ensure_call(c, "animation_query", "set_state_machine_entry", {"asset_path": ABP, "machine_name": "MoveBattle_SM", "state_name": "RunFrontBattle"})

    add_transition(c, "Move_SM", "BattleIdle", "MoveBattle", "C9997_Req_Move")
    add_transition(c, "Move_SM", "MoveBattle", "BattleIdle", "C9997_Return_BattleIdle")
    for src in ("BattleIdle", "MoveBattle"):
        add_transition(c, "Move_SM", src, "Attack", "C9997_Req_Attack")
        add_transition(c, "Move_SM", src, "Death", "C9997_Req_Death")
    add_transition(c, "Move_SM", "Attack", "Death", "C9997_Req_Death")

    move_rules = {
        "RunFrontBattle": "MoveBattle_IsRunFront",
        "WalkFrontBattle": "MoveBattle_IsWalkFront",
        "WalkLeftBattle": "MoveBattle_IsWalkLeft",
        "WalkBackBattle": "MoveBattle_IsWalkBack",
        "WalkRightBattle": "MoveBattle_IsWalkRight",
    }
    for src in MOVE_ANIMS:
        for dst, var in move_rules.items():
            if src != dst:
                add_transition(c, "MoveBattle_SM", src, dst, var)

    death_id = ensure_state_machine(c, "Move_SM", "Death_SM", state_name="Death", x=160, y=0)
    if death_id:
        connect_result(c, "Move_SM", death_id, "Death")
    for name, anim, loop, x in [
        ("DeathStart_SM", DEATH_START, False, 0),
        ("DeathIdle_SM", DEATH_IDLE, True, 360),
    ]:
        ensure_call(c, "animation_query", "add_state_to_machine", {"asset_path": ABP, "machine_name": "Death_SM", "state_name": name, "position_x": x, "position_y": 0}, ok_errors=("already exists",))
        ensure_call(c, "animation_query", "set_state_animation", {"asset_path": ABP, "machine_name": "Death_SM", "state_name": name, "anim_asset_path": anim, "loop": loop, "clear_existing": True})
    ensure_call(c, "animation_query", "set_state_machine_entry", {"asset_path": ABP, "machine_name": "Death_SM", "state_name": "DeathStart_SM"})
    add_transition(c, "Death_SM", "DeathStart_SM", "DeathIdle_SM", "C9997_Death_ToIdle")

    c.call("blueprint_query", "compile_blueprint", {"asset_path": ABP})
    c.call("blueprint_query", "save_asset", {"asset_path": ABP})

    cmd = f"""
import unreal
abp_cls = unreal.load_object(None, '{ABP}.{ABP.rsplit('/', 1)[-1]}_C')
bp = unreal.load_asset('{BP_C1010}')
cdo = unreal.get_default_object(bp.generated_class())
mesh = cdo.get_editor_property('mesh')
mesh.set_editor_property('animation_mode', unreal.AnimationMode.ANIMATION_BLUEPRINT)
mesh.set_editor_property('anim_class', abp_cls)
anim_cdo = unreal.get_default_object(abp_cls)
anim_cdo.set_editor_property('root_motion_mode', unreal.RootMotionMode.ROOT_MOTION_FROM_EVERYTHING)
unreal.EditorAssetLibrary.save_asset('{BP_C1010}', only_if_is_dirty=False)
unreal.EditorAssetLibrary.save_asset('{ABP}', only_if_is_dirty=False)
print('assigned')
"""
    print(c.call("editor_query", "run_python", {"command": cmd, "mode": "execute_file", "unattended": True}))


if __name__ == "__main__":
    main()
