import sys

import unreal


PREVIEW_MAP = "/Game/Maps/Debug/L_Sekiro_C0000_Preview"
PREVIEW_BP = "/Game/Animation/Sekiro/C0000/Blueprints/BP_Sekiro_C0000_PreviewCharacter"
DT = 1.0 / 60.0
STANDARD_TURN_FRAMES = 20
TURN_FRAME_TOLERANCE = 2
STATE_MOVE_START = 1
STATE_MOVE_LOOP = 2

DIRECTION_IDS = {
    "F": 0,
    "B": 1,
    "L": 2,
    "R": 3,
}

SOURCE_YAWS = {
    "F": 0.0,
    "B": 180.0,
    "L": -90.0,
    "R": 90.0,
}

QUICK_TURN_EVENTS = (
    "W_StandQuickTurnLeft90",
    "W_StandQuickTurnRight90",
    "W_StandQuickTurnLeft180",
    "W_StandQuickTurnRight180",
    "W_StandQuickTurnMoveStartLeft180",
    "W_StandQuickTurnMoveStartRight180",
    "W_StandMoveQuickTurnLeft180",
    "W_StandMoveQuickTurnRight180",
)

QUICK_TURN_180_EVENTS = (
    "W_StandQuickTurnLeft180",
    "W_StandQuickTurnRight180",
    "W_StandQuickTurnMoveStartLeft180",
    "W_StandQuickTurnMoveStartRight180",
    "W_StandMoveQuickTurnLeft180",
    "W_StandMoveQuickTurnRight180",
)


def call(obj, name, *args):
    fn = getattr(obj, name, None)
    if fn is None:
        raise RuntimeError("missing method: {}".format(name))
    return fn(*args)


def get_state(actor):
    sm = actor.get_sekiro_layered_state_machine()
    return sm.get_layer_state(0)


def step_frame_events(actor, frames):
    events = []
    for _ in range(frames):
        if not actor.step_preview_runtime(DT):
            raise RuntimeError("StepPreviewRuntime failed")
        event = str(actor.get_editor_property("preview_debug_last_event_name"))
        events.append(event)
    return events


def step(actor, frames):
    frame_events = step_frame_events(actor, frames)
    events = []
    for event in frame_events:
        if event and (not events or events[-1] != event):
            events.append(event)
    return events


def max_consecutive_event_frames(frame_events, event_names):
    event_names = set(event_names)
    best = 0
    current = 0
    for event in frame_events:
        if event in event_names:
            current += 1
            best = max(best, current)
        else:
            current = 0
    return best


def assert_standard_turn_frames(label, frame_events, event_names):
    frames = max_consecutive_event_frames(frame_events, event_names)
    min_frames = STANDARD_TURN_FRAMES - TURN_FRAME_TOLERANCE
    max_frames = STANDARD_TURN_FRAMES + TURN_FRAME_TOLERANCE
    unreal.log(
        "[WASD90Test] {} turn_frames={} expected={} tolerance={}".format(
            label,
            frames,
            STANDARD_TURN_FRAMES,
            TURN_FRAME_TOLERANCE,
        )
    )
    if frames < min_frames or frames > max_frames:
        raise RuntimeError(
            "{} turn duration failed: frames={} expected {}..{}".format(
                label,
                frames,
                min_frames,
                max_frames,
            )
        )


def count_quick_turn_events(events):
    return sum(1 for event in events if event in QUICK_TURN_EVENTS)


def angle_delta_degrees(a, b):
    delta = (a - b + 180.0) % 360.0 - 180.0
    return delta


def set_input(actor, forward, right):
    actor.set_preview_input_override(forward, right, False)


def clear_input(actor):
    actor.clear_preview_input_override()
    step(actor, 8)


def run_case(actor_class, source_name, _source_input, target_name, target_input, expected_event):
    actor = unreal.EditorLevelLibrary.spawn_actor_from_class(
        actor_class,
        unreal.Vector(0.0, 0.0, 120.0),
        unreal.Rotator(0.0, 0.0, 0.0),
    )
    if actor is None:
        raise RuntimeError("failed to spawn preview actor")

    try:
        step(actor, 1)
        actor.set_actor_rotation(
            unreal.Rotator(pitch=0.0, yaw=SOURCE_YAWS[source_name], roll=0.0),
            False,
        )
        sm = actor.get_sekiro_layered_state_machine()
        sm.set_layer_state(
            0,
            STATE_MOVE_LOOP,
            "MoveLoop",
            "W_BaseMoveLoop",
            DIRECTION_IDS["F"],
        )
        start_location = actor.get_actor_location()
        set_input(actor, target_input[0], target_input[1])
        start_yaw = actor.get_actor_rotation().yaw
        start_input_angle = actor.get_move_input_angle_degrees()
        events = step(actor, 80)
        end_location = actor.get_actor_location()
        moved = start_location.distance(end_location) > 10.0
        yaw = actor.get_actor_rotation().yaw
        input_angle = actor.get_move_input_angle_degrees()
        state = get_state(actor)
        final_state = state.state_id

        saw_bridge = "W_BaseMoveStartQuickTurnLeft90Bridge" in events \
            or "W_BaseMoveStartQuickTurnRight90Bridge" in events
        saw_expected = expected_event in events
        yaw_ok = abs(angle_delta_degrees(yaw, SOURCE_YAWS[target_name])) < 20.0
        ok = moved and not saw_bridge and saw_expected and yaw_ok and abs(input_angle) < 15.0
        unreal.log(
            "[WASD90Test] {} -> {} start_yaw={:.2f} start_input_angle={:.2f} moved={} yaw={:.2f} input_angle={:.2f} final_state={} events={}".format(
                source_name,
                target_name,
                start_yaw,
                start_input_angle,
                moved,
                yaw,
                input_angle,
                final_state,
                ",".join(events),
            )
        )
        if not ok:
            raise RuntimeError(
                "{} -> {} failed: moved={}, saw_bridge={}, saw_expected={}, yaw_ok={}, input_angle={:.2f}".format(
                    source_name,
                    target_name,
                    moved,
                    saw_bridge,
                    saw_expected,
                    yaw_ok,
                    input_angle,
                )
            )
    finally:
        unreal.EditorLevelLibrary.destroy_actor(actor)


def run_hold_back_sequence(actor_class):
    actor = unreal.EditorLevelLibrary.spawn_actor_from_class(
        actor_class,
        unreal.Vector(0.0, 0.0, 120.0),
        unreal.Rotator(0.0, 0.0, 0.0),
    )
    if actor is None:
        raise RuntimeError("failed to spawn preview actor")

    try:
        step(actor, 1)
        start_location = actor.get_actor_location()
        set_input(actor, -1, 0)
        events = step(actor, 150)
        end_location = actor.get_actor_location()
        moved = start_location.distance(end_location) > 10.0
        yaw = actor.get_actor_rotation().yaw
        input_angle = actor.get_move_input_angle_degrees()
        quick_turn_count = count_quick_turn_events(events)

        unreal.log(
            "[WASD90Test] hold B moved={} yaw={:.2f} input_angle={:.2f} quick_turn_count={} events={}".format(
                moved,
                yaw,
                input_angle,
                quick_turn_count,
                ",".join(events),
            )
        )

        ok = moved and quick_turn_count <= 2 and abs(input_angle) < 10.0 and abs(abs(yaw) - 180.0) < 20.0
        if not ok:
            raise RuntimeError(
                "hold B failed: moved={}, yaw={:.2f}, input_angle={:.2f}, quick_turn_count={}".format(
                    moved,
                    yaw,
                    input_angle,
                    quick_turn_count,
                )
            )
    finally:
        unreal.EditorLevelLibrary.destroy_actor(actor)


def run_back_facing_hold_back_sequence(actor_class):
    actor = unreal.EditorLevelLibrary.spawn_actor_from_class(
        actor_class,
        unreal.Vector(0.0, 0.0, 120.0),
        unreal.Rotator(0.0, 0.0, 0.0),
    )
    if actor is None:
        raise RuntimeError("failed to spawn preview actor")

    try:
        step(actor, 1)
        actor.set_actor_rotation(
            unreal.Rotator(pitch=0.0, yaw=180.0, roll=0.0),
            False,
        )
        sm = actor.get_sekiro_layered_state_machine()
        sm.set_layer_state(
            0,
            STATE_MOVE_LOOP,
            "MoveLoop",
            "W_BaseMoveLoop",
            DIRECTION_IDS["F"],
        )
        start_location = actor.get_actor_location()
        set_input(actor, -1, 0)
        events = step(actor, 90)
        end_location = actor.get_actor_location()
        moved = start_location.distance(end_location) > 10.0
        yaw = actor.get_actor_rotation().yaw
        input_angle = actor.get_move_input_angle_degrees()
        quick_turn_count = count_quick_turn_events(events)

        unreal.log(
            "[WASD90Test] facing B hold B moved={} yaw={:.2f} input_angle={:.2f} quick_turn_count={} events={}".format(
                moved,
                yaw,
                input_angle,
                quick_turn_count,
                ",".join(events),
            )
        )

        ok = moved and quick_turn_count == 0 and abs(input_angle) < 10.0 and abs(abs(yaw) - 180.0) < 20.0
        if not ok:
            raise RuntimeError(
                "facing B hold B failed: moved={}, yaw={:.2f}, input_angle={:.2f}, quick_turn_count={}".format(
                    moved,
                    yaw,
                    input_angle,
                    quick_turn_count,
                )
            )
    finally:
        unreal.EditorLevelLibrary.destroy_actor(actor)


def run_direct_180_case(actor_class, source_name, target_name, target_input):
    actor = unreal.EditorLevelLibrary.spawn_actor_from_class(
        actor_class,
        unreal.Vector(0.0, 0.0, 120.0),
        unreal.Rotator(0.0, 0.0, 0.0),
    )
    if actor is None:
        raise RuntimeError("failed to spawn preview actor")

    try:
        step(actor, 1)
        actor.set_actor_rotation(
            unreal.Rotator(pitch=0.0, yaw=SOURCE_YAWS[source_name], roll=0.0),
            False,
        )
        sm = actor.get_sekiro_layered_state_machine()
        sm.set_layer_state(
            0,
            STATE_MOVE_LOOP,
            "MoveLoop",
            "W_BaseMoveLoop",
            DIRECTION_IDS["F"],
        )
        start_location = actor.get_actor_location()
        set_input(actor, target_input[0], target_input[1])
        frame_events = step_frame_events(actor, 150)
        events = []
        for event in frame_events:
            if event and (not events or events[-1] != event):
                events.append(event)
        end_location = actor.get_actor_location()
        moved = start_location.distance(end_location) > 10.0
        yaw = actor.get_actor_rotation().yaw
        input_angle = actor.get_move_input_angle_degrees()
        saw_180 = "W_StandMoveQuickTurnRight180" in events or "W_StandMoveQuickTurnLeft180" in events
        yaw_ok = abs(angle_delta_degrees(yaw, SOURCE_YAWS[target_name])) < 20.0

        unreal.log(
            "[WASD90Test] direct180 {} -> {} moved={} yaw={:.2f} input_angle={:.2f} saw_180={} events={}".format(
                source_name,
                target_name,
                moved,
                yaw,
                input_angle,
                saw_180,
                ",".join(events),
            )
        )

        ok = moved and saw_180 and yaw_ok and abs(input_angle) < 15.0
        if not ok:
            raise RuntimeError(
                "direct180 {} -> {} failed: moved={}, yaw={:.2f}, input_angle={:.2f}, saw_180={}, yaw_ok={}".format(
                    source_name,
                    target_name,
                    moved,
                    yaw,
                    input_angle,
                    saw_180,
                    yaw_ok,
                )
            )
        assert_standard_turn_frames(
            "direct180 {} -> {}".format(source_name, target_name),
            frame_events,
            ("W_StandMoveQuickTurnRight180", "W_StandMoveQuickTurnLeft180"),
        )
    finally:
        unreal.EditorLevelLibrary.destroy_actor(actor)


def run_idle_direct_180_case(actor_class, source_name, target_name, target_input):
    actor = unreal.EditorLevelLibrary.spawn_actor_from_class(
        actor_class,
        unreal.Vector(0.0, 0.0, 120.0),
        unreal.Rotator(0.0, 0.0, 0.0),
    )
    if actor is None:
        raise RuntimeError("failed to spawn preview actor")

    try:
        step(actor, 1)
        actor.set_actor_rotation(
            unreal.Rotator(pitch=0.0, yaw=SOURCE_YAWS[source_name], roll=0.0),
            False,
        )
        start_location = actor.get_actor_location()
        set_input(actor, target_input[0], target_input[1])
        frame_events = step_frame_events(actor, 190)
        events = []
        for event in frame_events:
            if event and (not events or events[-1] != event):
                events.append(event)
        end_location = actor.get_actor_location()
        moved = start_location.distance(end_location) > 10.0
        yaw = actor.get_actor_rotation().yaw
        input_angle = actor.get_move_input_angle_degrees()
        saw_prelude = "W_StandQuickTurnMoveStartRight180" in events \
            or "W_StandQuickTurnMoveStartLeft180" in events
        saw_idle_turn = "W_StandQuickTurnRight180" in events \
            or "W_StandQuickTurnLeft180" in events
        yaw_ok = abs(angle_delta_degrees(yaw, SOURCE_YAWS[target_name])) < 20.0

        unreal.log(
            "[WASD90Test] idle180 {} -> {} moved={} yaw={:.2f} input_angle={:.2f} saw_prelude={} saw_idle_turn={} events={}".format(
                source_name,
                target_name,
                moved,
                yaw,
                input_angle,
                saw_prelude,
                saw_idle_turn,
                ",".join(events),
            )
        )

        ok = moved and saw_prelude and saw_idle_turn and yaw_ok and abs(input_angle) < 15.0
        if not ok:
            raise RuntimeError(
                "idle180 {} -> {} failed: moved={}, yaw={:.2f}, input_angle={:.2f}, saw_prelude={}, saw_idle_turn={}, yaw_ok={}".format(
                    source_name,
                    target_name,
                    moved,
                    yaw,
                    input_angle,
                    saw_prelude,
                    saw_idle_turn,
                    yaw_ok,
                )
            )
        assert_standard_turn_frames(
            "idle180 {} -> {}".format(source_name, target_name),
            frame_events,
            ("W_StandQuickTurnRight180", "W_StandQuickTurnLeft180"),
        )
    finally:
        unreal.EditorLevelLibrary.destroy_actor(actor)


def run_move_start_immediate_180_case(actor_class, source_name, target_name, target_input):
    actor = unreal.EditorLevelLibrary.spawn_actor_from_class(
        actor_class,
        unreal.Vector(0.0, 0.0, 120.0),
        unreal.Rotator(0.0, 0.0, 0.0),
    )
    if actor is None:
        raise RuntimeError("failed to spawn preview actor")

    try:
        step(actor, 1)
        actor.set_actor_rotation(
            unreal.Rotator(pitch=0.0, yaw=SOURCE_YAWS[source_name], roll=0.0),
            False,
        )
        sm = actor.get_sekiro_layered_state_machine()
        sm.set_layer_state(
            0,
            STATE_MOVE_START,
            "MoveStart",
            "W_StandMoveStart",
            DIRECTION_IDS["F"],
        )
        start_location = actor.get_actor_location()
        set_input(actor, target_input[0], target_input[1])
        frame_events = step_frame_events(actor, 150)
        events = []
        for event in frame_events:
            if event and (not events or events[-1] != event):
                events.append(event)
        end_location = actor.get_actor_location()
        moved = start_location.distance(end_location) > 10.0
        yaw = actor.get_actor_rotation().yaw
        input_angle = actor.get_move_input_angle_degrees()
        saw_move_start_180 = "W_StandQuickTurnMoveStartRight180" in events \
            or "W_StandQuickTurnMoveStartLeft180" in events
        saw_move_loop_180 = "W_StandMoveQuickTurnRight180" in events \
            or "W_StandMoveQuickTurnLeft180" in events
        yaw_ok = abs(angle_delta_degrees(yaw, SOURCE_YAWS[target_name])) < 20.0

        unreal.log(
            "[WASD90Test] moveStartImmediate180 {} -> {} moved={} yaw={:.2f} input_angle={:.2f} saw_move_start_180={} saw_move_loop_180={} events={}".format(
                source_name,
                target_name,
                moved,
                yaw,
                input_angle,
                saw_move_start_180,
                saw_move_loop_180,
                ",".join(events),
            )
        )

        ok = moved and saw_move_start_180 and not saw_move_loop_180 and yaw_ok and abs(input_angle) < 15.0
        if not ok:
            raise RuntimeError(
                "moveStartImmediate180 {} -> {} failed: moved={}, yaw={:.2f}, input_angle={:.2f}, saw_move_start_180={}, saw_move_loop_180={}, yaw_ok={}".format(
                    source_name,
                    target_name,
                    moved,
                    yaw,
                    input_angle,
                    saw_move_start_180,
                    saw_move_loop_180,
                    yaw_ok,
                )
            )
        assert_standard_turn_frames(
            "moveStartImmediate180 {} -> {}".format(source_name, target_name),
            frame_events,
            ("W_StandQuickTurnMoveStartRight180", "W_StandQuickTurnMoveStartLeft180"),
        )
    finally:
        unreal.EditorLevelLibrary.destroy_actor(actor)


def run_real_input_sequence(actor_class, side_name, side_input):
    actor = unreal.EditorLevelLibrary.spawn_actor_from_class(
        actor_class,
        unreal.Vector(0.0, 0.0, 120.0),
        unreal.Rotator(0.0, 0.0, 0.0),
    )
    if actor is None:
        raise RuntimeError("failed to spawn preview actor")

    try:
        step(actor, 1)
        set_input(actor, -1, 0)
        events_to_back = step(actor, 120)
        set_input(actor, 0, -1)
        if side_name == "R":
            set_input(actor, 0, 1)
        else:
            set_input(actor, 0, -1)
        events_to_side = step(actor, 80)
        yaw_after_side = actor.get_actor_rotation().yaw

        set_input(actor, 1, 0)
        events_to_forward = step(actor, 120)
        yaw_after_forward = actor.get_actor_rotation().yaw
        input_angle = actor.get_move_input_angle_degrees()
        all_events = events_to_back + events_to_side + events_to_forward

        unreal.log(
            "[WASD90Test] real B -> {} -> F yaw_side={:.2f} yaw_forward={:.2f} input_angle={:.2f} events={}".format(
                side_name,
                yaw_after_side,
                yaw_after_forward,
                input_angle,
                ",".join(all_events),
            )
        )

        expected_side_sign_ok = yaw_after_side > 45.0 if side_name == "R" else yaw_after_side < -45.0
        expected_forward_event = "W_StandQuickTurnLeft90" if side_name == "R" else "W_StandQuickTurnRight90"
        saw_expected_forward_90 = expected_forward_event in events_to_forward
        forward_90_count = sum(
            1 for event in events_to_forward
            if event in ("W_StandQuickTurnLeft90", "W_StandQuickTurnRight90")
        )
        saw_forward_180 = any(event in QUICK_TURN_180_EVENTS for event in events_to_forward)
        ok = expected_side_sign_ok \
            and abs(input_angle) < 10.0 \
            and abs(yaw_after_forward) < 15.0 \
            and saw_expected_forward_90 \
            and forward_90_count == 1 \
            and not saw_forward_180
        if not ok:
            raise RuntimeError(
                "real B -> {} -> F failed: yaw_side={:.2f}, yaw_forward={:.2f}, input_angle={:.2f}, saw_forward_90={}, forward_90_count={}, saw_forward_180={}".format(
                    side_name,
                    yaw_after_side,
                    yaw_after_forward,
                    input_angle,
                    saw_expected_forward_90,
                    forward_90_count,
                    saw_forward_180,
                )
            )
    finally:
        unreal.EditorLevelLibrary.destroy_actor(actor)


def run_axis_switch_opposite_180_sequence(
    actor_class,
    first_opposite_name,
    first_opposite_input,
    side_name,
    side_input,
    final_name,
    final_input,
):
    actor = unreal.EditorLevelLibrary.spawn_actor_from_class(
        actor_class,
        unreal.Vector(0.0, 0.0, 120.0),
        unreal.Rotator(0.0, 0.0, 0.0),
    )
    if actor is None:
        raise RuntimeError("failed to spawn preview actor")

    try:
        step(actor, 1)
        set_input(actor, 1, 0)
        step(actor, 90)
        set_input(actor, first_opposite_input[0], first_opposite_input[1])
        events_to_ws_opposite = step(actor, 190)
        set_input(actor, side_input[0], side_input[1])
        events_to_side = step(actor, 110)
        yaw_after_side = actor.get_actor_rotation().yaw

        start_location = actor.get_actor_location()
        set_input(actor, final_input[0], final_input[1])
        events_to_final = step(actor, 190)
        settle_events = step(actor, 60)
        end_location = actor.get_actor_location()
        state = get_state(actor)
        final_state = state.state_id
        yaw = actor.get_actor_rotation().yaw
        input_angle = actor.get_move_input_angle_degrees()
        moved = start_location.distance(end_location) > 10.0
        saw_first_180 = any(event in QUICK_TURN_180_EVENTS for event in events_to_ws_opposite)
        saw_final_180 = any(event in QUICK_TURN_180_EVENTS for event in events_to_final)
        saw_final_90 = "W_StandQuickTurnRight90" in events_to_final \
            or "W_StandQuickTurnLeft90" in events_to_final
        repeated_after_settle = count_quick_turn_events(settle_events)
        yaw_ok = abs(angle_delta_degrees(yaw, SOURCE_YAWS[final_name])) < 20.0
        state_ok = final_state in (STATE_MOVE_START, STATE_MOVE_LOOP)

        unreal.log(
            "[WASD90Test] axisSwitch180 F -> {} -> {} -> {} moved={} yaw_side={:.2f} yaw={:.2f} input_angle={:.2f} state={} first180={} final180={} final90={} settle_qt={} events={}".format(
                first_opposite_name,
                side_name,
                final_name,
                moved,
                yaw_after_side,
                yaw,
                input_angle,
                final_state,
                saw_first_180,
                saw_final_180,
                saw_final_90,
                repeated_after_settle,
                ",".join(events_to_ws_opposite + events_to_side + events_to_final + settle_events),
            )
        )

        ok = moved \
            and saw_first_180 \
            and saw_final_180 \
            and not saw_final_90 \
            and repeated_after_settle == 0 \
            and yaw_ok \
            and abs(input_angle) < 15.0 \
            and state_ok
        if not ok:
            raise RuntimeError(
                "axisSwitch180 F -> {} -> {} -> {} failed: moved={}, yaw={:.2f}, input_angle={:.2f}, state={}, first180={}, final180={}, final90={}, settle_qt={}, yaw_ok={}".format(
                    first_opposite_name,
                    side_name,
                    final_name,
                    moved,
                    yaw,
                    input_angle,
                    final_state,
                    saw_first_180,
                    saw_final_180,
                    saw_final_90,
                    repeated_after_settle,
                    yaw_ok,
                )
            )
    finally:
        unreal.EditorLevelLibrary.destroy_actor(actor)


def run_quick_tap_opposite_releases_to_stop_case(
    actor_class,
    source_name,
    source_input,
    opposite_name,
    opposite_input,
    tap_frames=2,
):
    actor = unreal.EditorLevelLibrary.spawn_actor_from_class(
        actor_class,
        unreal.Vector(0.0, 0.0, 120.0),
        unreal.Rotator(0.0, 0.0, 0.0),
    )
    if actor is None:
        raise RuntimeError("failed to spawn preview actor")

    try:
        step(actor, 1)
        actor.set_actor_rotation(
            unreal.Rotator(pitch=0.0, yaw=SOURCE_YAWS[source_name], roll=0.0),
            False,
        )
        sm = actor.get_sekiro_layered_state_machine()
        sm.set_layer_state(
            0,
            STATE_MOVE_LOOP,
            "MoveLoop",
            "W_BaseMoveLoop",
            DIRECTION_IDS["F"],
        )

        set_input(actor, source_input[0], source_input[1])
        step(actor, 60)
        set_input(actor, opposite_input[0], opposite_input[1])
        tap_events = step(actor, tap_frames)
        actor.clear_preview_input_override()
        release_events = step(actor, 220)
        state = get_state(actor)
        final_state = state.state_id
        yaw = actor.get_actor_rotation().yaw
        input_angle = actor.get_move_input_angle_degrees()
        events = tap_events + release_events
        saw_180 = any(event in QUICK_TURN_180_EVENTS for event in events)
        saw_stop = "W_BaseMoveStop" in events or "W_BaseIdle" in events
        stopped_state = final_state not in (STATE_MOVE_START, STATE_MOVE_LOOP)

        unreal.log(
            "[WASD90Test] quickTapOpposite {} -> {} release yaw={:.2f} input_angle={:.2f} state={} saw180={} saw_stop={} events={}".format(
                source_name,
                opposite_name,
                yaw,
                input_angle,
                final_state,
                saw_180,
                saw_stop,
                ",".join(events),
            )
        )

        ok = saw_180 and saw_stop and stopped_state and abs(input_angle) < 5.0
        if not ok:
            raise RuntimeError(
                "quickTapOpposite {} -> {} release failed: yaw={:.2f}, input_angle={:.2f}, state={}, saw180={}, saw_stop={}".format(
                    source_name,
                    opposite_name,
                    yaw,
                    input_angle,
                    final_state,
                    saw_180,
                    saw_stop,
                )
            )
    finally:
        unreal.EditorLevelLibrary.destroy_actor(actor)


def run_move_start_quick_tap_opposite_releases_to_stop_case(
    actor_class,
    source_name,
    source_input,
    opposite_name,
    opposite_input,
    tap_frames=2,
):
    actor = unreal.EditorLevelLibrary.spawn_actor_from_class(
        actor_class,
        unreal.Vector(0.0, 0.0, 120.0),
        unreal.Rotator(0.0, 0.0, 0.0),
    )
    if actor is None:
        raise RuntimeError("failed to spawn preview actor")

    try:
        step(actor, 1)
        actor.set_actor_rotation(
            unreal.Rotator(pitch=0.0, yaw=SOURCE_YAWS[source_name], roll=0.0),
            False,
        )
        set_input(actor, source_input[0], source_input[1])
        step(actor, 8)
        set_input(actor, opposite_input[0], opposite_input[1])
        tap_events = step(actor, tap_frames)
        actor.clear_preview_input_override()
        release_events = step(actor, 220)
        state = get_state(actor)
        final_state = state.state_id
        yaw = actor.get_actor_rotation().yaw
        input_angle = actor.get_move_input_angle_degrees()
        events = tap_events + release_events
        saw_180 = any(event in QUICK_TURN_180_EVENTS for event in events)
        saw_stop = "W_BaseMoveStop" in events or "W_BaseIdle" in events
        stopped_state = final_state not in (STATE_MOVE_START, STATE_MOVE_LOOP)

        unreal.log(
            "[WASD90Test] moveStartQuickTapOpposite {} -> {} release yaw={:.2f} input_angle={:.2f} state={} saw180={} saw_stop={} events={}".format(
                source_name,
                opposite_name,
                yaw,
                input_angle,
                final_state,
                saw_180,
                saw_stop,
                ",".join(events),
            )
        )

        ok = saw_180 and saw_stop and stopped_state and abs(input_angle) < 5.0
        if not ok:
            raise RuntimeError(
                "moveStartQuickTapOpposite {} -> {} release failed: yaw={:.2f}, input_angle={:.2f}, state={}, saw180={}, saw_stop={}".format(
                    source_name,
                    opposite_name,
                    yaw,
                    input_angle,
                    final_state,
                    saw_180,
                    saw_stop,
                )
            )
    finally:
        unreal.EditorLevelLibrary.destroy_actor(actor)


def main():
    unreal.EditorLoadingAndSavingUtils.load_map(PREVIEW_MAP)
    actor_class = unreal.EditorAssetLibrary.load_blueprint_class(PREVIEW_BP)
    if actor_class is None:
        raise RuntimeError("failed to load {}".format(PREVIEW_BP))

    cases = [
        ("F", (1, 0), "L", (0, -1), "W_StandQuickTurnLeft90"),
        ("F", (1, 0), "R", (0, 1), "W_StandQuickTurnRight90"),
        ("B", (-1, 0), "R", (0, 1), "W_StandQuickTurnLeft90"),
        ("B", (-1, 0), "L", (0, -1), "W_StandQuickTurnRight90"),
        ("L", (0, -1), "B", (-1, 0), "W_StandQuickTurnLeft90"),
        ("L", (0, -1), "F", (1, 0), "W_StandQuickTurnRight90"),
        ("R", (0, 1), "F", (1, 0), "W_StandQuickTurnLeft90"),
        ("R", (0, 1), "B", (-1, 0), "W_StandQuickTurnRight90"),
    ]

    for source_name, source_input, target_name, target_input, expected_event in cases:
        run_case(actor_class, source_name, source_input, target_name, target_input, expected_event)

    run_hold_back_sequence(actor_class)
    run_back_facing_hold_back_sequence(actor_class)
    run_idle_direct_180_case(actor_class, "F", "B", (-1, 0))
    run_idle_direct_180_case(actor_class, "B", "F", (1, 0))
    run_move_start_immediate_180_case(actor_class, "F", "B", (-1, 0))
    run_move_start_immediate_180_case(actor_class, "B", "F", (1, 0))
    run_direct_180_case(actor_class, "F", "B", (-1, 0))
    run_direct_180_case(actor_class, "B", "F", (1, 0))
    run_direct_180_case(actor_class, "L", "R", (0, 1))
    run_direct_180_case(actor_class, "R", "L", (0, -1))
    run_real_input_sequence(actor_class, "L", (0, -1))
    run_real_input_sequence(actor_class, "R", (0, 1))
    run_axis_switch_opposite_180_sequence(actor_class, "B", (-1, 0), "R", (0, 1), "L", (0, -1))
    run_axis_switch_opposite_180_sequence(actor_class, "B", (-1, 0), "L", (0, -1), "R", (0, 1))
    run_quick_tap_opposite_releases_to_stop_case(actor_class, "F", (1, 0), "B", (-1, 0))
    run_quick_tap_opposite_releases_to_stop_case(actor_class, "B", (-1, 0), "F", (1, 0))
    run_quick_tap_opposite_releases_to_stop_case(actor_class, "L", (0, -1), "R", (0, 1))
    run_quick_tap_opposite_releases_to_stop_case(actor_class, "R", (0, 1), "L", (0, -1))
    run_move_start_quick_tap_opposite_releases_to_stop_case(actor_class, "F", (1, 0), "B", (-1, 0))
    run_move_start_quick_tap_opposite_releases_to_stop_case(actor_class, "B", (-1, 0), "F", (1, 0))
    run_move_start_quick_tap_opposite_releases_to_stop_case(actor_class, "L", (0, -1), "R", (0, 1))
    run_move_start_quick_tap_opposite_releases_to_stop_case(actor_class, "R", (0, 1), "L", (0, -1))
    run_quick_tap_opposite_releases_to_stop_case(actor_class, "F", (1, 0), "B", (-1, 0), 1)
    run_quick_tap_opposite_releases_to_stop_case(actor_class, "B", (-1, 0), "F", (1, 0), 1)
    run_quick_tap_opposite_releases_to_stop_case(actor_class, "L", (0, -1), "R", (0, 1), 1)
    run_quick_tap_opposite_releases_to_stop_case(actor_class, "R", (0, 1), "L", (0, -1), 1)
    run_move_start_quick_tap_opposite_releases_to_stop_case(actor_class, "F", (1, 0), "B", (-1, 0), 1)
    run_move_start_quick_tap_opposite_releases_to_stop_case(actor_class, "B", (-1, 0), "F", (1, 0), 1)
    run_move_start_quick_tap_opposite_releases_to_stop_case(actor_class, "L", (0, -1), "R", (0, 1), 1)
    run_move_start_quick_tap_opposite_releases_to_stop_case(actor_class, "R", (0, 1), "L", (0, -1), 1)

    unreal.log("[WASD90Test] PASS")
    return 0


try:
    sys.exit(main())
except Exception as exc:
    unreal.log_error("[WASD90Test] FAIL: {}".format(exc))
    sys.exit(1)
