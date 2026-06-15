import json
from pathlib import Path

import unreal


PREVIEW_MAP_PATH = "/Game/Maps/Debug/L_Sekiro_C0000_Preview"
PREVIEW_CHARACTER_LABEL = "SekiroPreview_Character"
REPORT_PATH = Path(r"E:\UEProj\Sekiro\SekiroDemo\Saved\SekiroImportReports\c0000_event_bridge_validation.json")
MAX_WAIT_TICKS = 180


state = {
    "phase": "boot",
    "wait_ticks": 0,
    "actor": None,
    "handle": None,
    "report": {
        "map": PREVIEW_MAP_PATH,
        "preview_character_label": PREVIEW_CHARACTER_LABEL,
        "stages": [],
    },
}


def log(message: str) -> None:
    unreal.log(f"[c0000-event-bridge] {message}")


def actor_label(actor) -> str:
    try:
        return actor.get_actor_label()
    except Exception:
        try:
            return actor.get_name()
        except Exception:
            return "<unknown>"


def get_editor_subsystems():
    return (
        unreal.get_editor_subsystem(unreal.LevelEditorSubsystem),
        unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem),
    )


def find_preview_actor(world):
    actors = unreal.GameplayStatics.get_all_actors_of_class(world, unreal.Actor)
    for actor in actors:
        label = actor_label(actor)
        name = actor.get_name()
        if label == PREVIEW_CHARACTER_LABEL or name.startswith(PREVIEW_CHARACTER_LABEL):
            return actor
    return None


def snapshot_actor(actor):
    return {
        "label": actor_label(actor),
        "name": actor.get_name(),
        "preview_debug_last_event_name": str(actor.preview_debug_last_event_name or ""),
        "preview_debug_last_event_time_seconds": float(actor.preview_debug_last_event_time_seconds or 0.0),
        "preview_debug_input_forward": int(actor.preview_debug_input_forward or 0),
        "preview_debug_input_right": int(actor.preview_debug_input_right or 0),
        "preview_debug_sprint_held": bool(actor.preview_debug_sprint_held),
        "move_type": int(actor.get_anim_int_var("MoveType")),
        "stance_move_type": int(actor.get_anim_int_var("StanceMoveType")),
        "move_speed_index": int(actor.get_anim_int_var("MoveSpeedIndex")),
        "selector_use_transition_effect": int(actor.get_anim_int_var("Selector_UseTransitionEffect")),
        "selector_use_stater_to_state_transition_effect": int(
            actor.get_anim_int_var("Selector_UseStaterToStateTransitionEffect")
        ),
        "state_state_id_stand_moveable_action": int(actor.get_anim_int_var("StateStateId_StandMoveableAction")),
        "move_direction": float(actor.get_anim_float_var("MoveDirection")),
        "move_angle": float(actor.get_anim_float_var("MoveAngle")),
        "turn_angle": float(actor.get_anim_float_var("TurnAngle")),
    }


def add_stage(name: str, data: dict) -> None:
    state["report"]["stages"].append({"name": name, **data})
    log(f"stage={name} data={json.dumps(data, ensure_ascii=False)}")


def write_report() -> None:
    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text(json.dumps(state["report"], indent=2, ensure_ascii=False), encoding="utf-8")
    log(f"report={REPORT_PATH}")
    log(json.dumps(state["report"], ensure_ascii=False))


def finish(success: bool, error: str | None = None) -> None:
    level_editor, _ = get_editor_subsystems()
    if state["handle"] is not None:
        unreal.unregister_slate_post_tick_callback(state["handle"])
        state["handle"] = None

    state["report"]["success"] = bool(success)
    if error:
        state["report"]["error"] = error
        log(f"finish_error={error}")
    else:
        log("finish_success=true")

    try:
        if level_editor and level_editor.is_in_play_in_editor():
            unreal.EditorLevelLibrary.editor_end_play()
    except Exception as exc:
        state["report"]["end_play_error"] = str(exc)

    write_report()

    if hasattr(unreal, "EditorPythonScriptingLibrary"):
        try:
            unreal.EditorPythonScriptingLibrary.set_keep_python_script_alive(False)
        except Exception:
            pass

    unreal.SystemLibrary.quit_editor()


def tick(_delta_seconds: float) -> None:
    try:
        level_editor, editor_subsystem = get_editor_subsystems()
        if not level_editor or not editor_subsystem:
            finish(False, "Failed to acquire editor subsystems.")
            return

        if state["phase"] == "boot":
            editor_world = editor_subsystem.get_editor_world()
            add_stage(
                "boot",
                {
                    "editor_world": editor_world.get_path_name() if editor_world else None,
                    "in_play_in_editor": bool(level_editor.is_in_play_in_editor()),
                },
            )
            if level_editor.is_in_play_in_editor():
                unreal.EditorLevelLibrary.editor_end_play()
            level_editor.editor_play_simulate()
            state["phase"] = "wait_for_pie_actor"
            log("phase->wait_for_pie_actor")
            return

        if state["phase"] == "wait_for_pie_actor":
            game_world = editor_subsystem.get_game_world()
            actor = find_preview_actor(game_world) if game_world else None
            state["wait_ticks"] += 1
            if actor:
                state["actor"] = actor
                add_stage(
                    "pie_ready",
                    {
                        "wait_ticks": state["wait_ticks"],
                        "game_world": game_world.get_path_name(),
                        "actor": snapshot_actor(actor),
                    },
                )
                state["phase"] = "prime_move"
                log("phase->prime_move")
                return

            if state["wait_ticks"] >= MAX_WAIT_TICKS:
                finish(
                    False,
                    f"Timed out waiting for PIE actor after {MAX_WAIT_TICKS} ticks. "
                    f"game_world={game_world.get_path_name() if game_world else None}",
                )
            return

        actor = state["actor"]
        if not actor:
            finish(False, "Preview actor reference became invalid.")
            return

        if state["phase"] == "prime_move":
            actor.clear_preview_input_override()
            actor.reset_sekiro_transient_vars()
            actor.set_preview_debug_last_event("", 0.0)
            actor.set_preview_input_override(1, 0, False)
            step_results = [bool(actor.step_preview_runtime(0.016)) for _ in range(5)]
            add_stage(
                "prime_move",
                {
                    "step_results": step_results,
                    "actor": snapshot_actor(actor),
                },
            )
            state["phase"] = "trigger_item_pill"
            log("phase->trigger_item_pill")
            return

        if state["phase"] == "trigger_item_pill":
            trigger_ok = bool(actor.trigger_preview_sekiro_event("W_ItemPillTonicMove"))
            step_results = [bool(actor.step_preview_runtime(0.016)) for _ in range(3)]
            add_stage(
                "trigger_item_pill",
                {
                    "trigger_ok": trigger_ok,
                    "step_results": step_results,
                    "actor": snapshot_actor(actor),
                },
            )
            state["phase"] = "trigger_deflect_return"
            log("phase->trigger_deflect_return")
            return

        if state["phase"] == "trigger_deflect_return":
            trigger_ok = bool(actor.trigger_preview_sekiro_event("W_DeflectGuardToStandMove"))
            step_results = [bool(actor.step_preview_runtime(0.016)) for _ in range(3)]
            add_stage(
                "trigger_deflect_return",
                {
                    "trigger_ok": trigger_ok,
                    "step_results": step_results,
                    "actor": snapshot_actor(actor),
                },
            )
            state["phase"] = "idle_family_to_move"
            log("phase->idle_family_to_move")
            return

        if state["phase"] == "idle_family_to_move":
            actor.clear_preview_input_override()
            actor.reset_sekiro_transient_vars()
            actor.set_preview_debug_last_event("", 0.0)
            actor.step_preview_runtime(0.016)
            idle_trigger_ok = bool(actor.trigger_preview_sekiro_event("W_ItemPillTonic"))
            idle_snapshot = snapshot_actor(actor)
            actor.set_preview_input_override(1, 0, False)
            step_results = [bool(actor.step_preview_runtime(0.016)) for _ in range(2)]
            move_snapshot = snapshot_actor(actor)
            add_stage(
                "idle_family_to_move",
                {
                    "idle_trigger_ok": idle_trigger_ok,
                    "step_results": step_results,
                    "idle_actor": idle_snapshot,
                    "move_actor": move_snapshot,
                },
            )
            finish(True)
    except Exception as exc:
        finish(False, str(exc))


if hasattr(unreal, "EditorPythonScriptingLibrary"):
    unreal.EditorPythonScriptingLibrary.set_keep_python_script_alive(True)

state["handle"] = unreal.register_slate_post_tick_callback(tick)
log("Registered validation tick callback.")
