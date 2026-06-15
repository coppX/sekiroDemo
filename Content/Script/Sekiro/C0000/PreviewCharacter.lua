local KismetSystemLibrary = UE.UKismetSystemLibrary
local Constants = require("Sekiro.C0000.Constants")
local EventSpecs = require("Sekiro.C0000.EventSpecs")
local MovementAnimEvents = require("Sekiro.C0000.MovementAnimEvents")
local PreviewConfig = require("Sekiro.C0000.PreviewCharacterConfig")
require("Sekiro.C0000.StateUtils")
require("Sekiro.C0000.MathUtils")
require("Sekiro.C0000.AnimRuntime")
require("Sekiro.C0000.MovementUtils")
require("Sekiro.C0000.DebugUtils")
require("Sekiro.C0000.AttackTransitions")
require("Sekiro.C0000.StateDefines")

---@type SekiroC0000PreviewCharacter_C
local M = UnLua.Class()

local REQUEST_PULSE_SECONDS = 0.20
local MOVE_INPUT_DIAGONAL_FACE_LERP_SPEED = 5.5
local MOVE_INPUT_DIAGONAL_FACE_RECOVER_SECONDS = 0.32
local MOVE_START_FACE_LERP_SPEED = 5.0
local MOVE_START_FACE_LERP_RECOVER_SECONDS = 0.38
local MOVE_INPUT_FACE_DEAD_ANGLE = 1.0
local MOVE_START_MOTION_SELECTOR_SETTLE_SECONDS = 2.0 / 30.0
local MOVE_START_ANIME_SELECTOR_SETTLE_SECONDS = 0.12
local MOVE_START_ANIME_SELECTOR_VISUAL_SCALE = 0.0
local QUICK_TURN_REENTRY_DEBOUNCE_SECONDS = 0.05
local MOVE_STOP_RESTART_QUICK_TURN_SUPPRESS_SECONDS = 0.18
local GROUND_ATTACK_END_BASE_SETTLE_SECONDS = 0.12
local MOVE_START_QUICK_TURN_GATE_SECONDS = 0.20
local FORWARD_LEFT_SOURCE_MEMORY_SECONDS = 1.25
local QUICK_TURN_MOVE_START_SELECTOR_F_PRELUDE_SECONDS = 1.0 / 60.0
local QUICK_TURN_MOVE_START_SELECTOR_BF_BLEND_SECONDS = 10.0 / 60.0
local MOVEMENT_EVENT_LS_MOVE_QUEUED = MovementAnimEvents.EVENT_LS_MOVE_QUEUED
local MOVEMENT_EVENT_MOVE_START_TO_LOOP = MovementAnimEvents.EVENT_MOVE_START_TO_LOOP
local MOVE_START_TO_LOOP_EVENT_LEAD_SECONDS = 0.24
local MOVE_START_TO_LOOP_TURN_EVENT_LEAD_SECONDS = 0.24
local MOVE_START_TO_LOOP_NOTIFY_LEAD_SECONDS = 0.24
local MOVE_START_TO_LOOP_TURN_NOTIFY_LEAD_SECONDS = 0.24
local MOVE_START_TO_LOOP_FORCE_SECONDS = 1.42
local MOVE_START_TO_LOOP_EXIT_SECONDS = 1.38
local MOVE_START_TO_LOOP_TURN_EXIT_SECONDS = 1.38
local MOVE_START_TO_LOOP_PREDICT_SECONDS = 1.0 / 60.0
local MOVE_LOOP_FROM_START_ANGLE_SETTLE_SECONDS = 0.24
local SELECT_BLEND_SYNC = 0
local SELECT_BLEND_NO_SRC_MOTION_IGNORE_FROM_GENERATOR = 2
local SELECT_STATE_TO_STATE_IGNORE_TO_WORLD = 0
local SELECT_STATE_TO_STATE_TAE_BLEND = 1
local get_quick_turn_spec
local get_quick_turn_exit_time

local function apply_preview_facing_yaw(self, delta_yaw)
    local yaw_delta = resolve_number(delta_yaw, 0.0)
    if math.abs(yaw_delta) <= 0.01 then
        return false
    end

    local runtime = ensure_runtime(self)
    if is_ground_attack_action_state(get_layer_runtime(runtime, Constants.LAYER_ACTION).state) then
        return false
    end

    local ok = pcall(function()
        self:AddPreviewFacingYaw(yaw_delta)
    end)
    if ok then
        return true
    end

    ok = pcall(function()
        self:K2_AddActorWorldRotation(UE.FRotator(0.0, yaw_delta, 0.0), false, nil, false)
    end)
    if ok then
        return true
    end

    return false
end

function M.GetTaeBehaviorRefId(event_name, numeric_value, source_args)
    return MovementAnimEvents.get_tae_behavior_ref_id(event_name, numeric_value, source_args)
end

function M.SetTaeBehaviorRefActive(events, event_name, active, numeric_value, source_args)
    return MovementAnimEvents.set_tae_behavior_ref_active(events, event_name, active, numeric_value, source_args)
end

local function set_movement_anim_event_active(runtime, event_name, active, numeric_value, source_args, skip_behavior_ref)
    return MovementAnimEvents.set_active(runtime, event_name, active, numeric_value, source_args, skip_behavior_ref)
end

local function set_tae_movement_alias_active(runtime, event_name, active, source_args)
    return MovementAnimEvents.set_tae_alias_active(runtime, event_name, active, source_args)
end

local function has_movement_anim_event(runtime, event_name)
    return MovementAnimEvents.has(runtime, event_name)
end

local function pulse_movement_anim_event(runtime, event_name, numeric_value, source_args)
    return MovementAnimEvents.pulse(runtime, event_name, numeric_value, source_args)
end

local function clear_synthetic_movement_anim_events(runtime)
    return MovementAnimEvents.clear_synthetic(runtime)
end

local function is_turning_locked_by_anim_event(runtime)
    return MovementAnimEvents.is_turning_locked(runtime)
end

local function get_anim_event_turn_speed(runtime)
    return MovementAnimEvents.get_turn_speed(runtime)
end

local function get_anim_event_move_scale(runtime, base_scale, allow_disabled_movement)
    return MovementAnimEvents.get_move_scale(runtime, base_scale, allow_disabled_movement)
end

local activate_event

local function get_preview_move_angle(self, forward, right)
    if clamp_intent(forward) == 0 and clamp_intent(right) == 0 then
        return 0.0
    end

    -- Match Sekiro's TurnAngle semantics: compare requested world movement
    -- against the character's current facing. After the quick-turn rotates the
    -- actor, the angle naturally settles toward zero instead of retriggering.
    if self.GetMoveInputAngleDegrees then
        local ok, angle = pcall(function()
            return self:GetMoveInputAngleDegrees()
        end)
        if ok then
            return resolve_number(angle, 0.0)
        end
    end

    return math.deg(math.atan(resolve_number(right, 0.0), resolve_number(forward, 0.0)))
end

local function resolve_move_direction_from_angle(angle)
    local signed_angle = resolve_number(angle, 0.0)
    local abs_angle = math.abs(signed_angle)
    if abs_angle <= Constants.TURN_8WAY_DEAD_ANGLE then
        return Constants.MOVE_DIRECTION_FORWARD
    end
    if abs_angle <= Constants.TURN_8WAY_45_MAX_ANGLE then
        return signed_angle < 0.0
            and Constants.MOVE_DIRECTION_FORWARD_LEFT
            or Constants.MOVE_DIRECTION_FORWARD_RIGHT
    end
    if abs_angle <= Constants.TURN_8WAY_90_MAX_ANGLE then
        return signed_angle < 0.0 and Constants.MOVE_DIRECTION_LEFT or Constants.MOVE_DIRECTION_RIGHT
    end
    if abs_angle <= Constants.TURN_8WAY_135_MAX_ANGLE then
        return signed_angle < 0.0
            and Constants.MOVE_DIRECTION_BACK_LEFT
            or Constants.MOVE_DIRECTION_BACK_RIGHT
    end
    return Constants.MOVE_DIRECTION_BACK
end

local function is_valid_move_direction(direction)
    return direction ~= nil
        and direction ~= Constants.MOVE_DIRECTION_NONE
        and DirectionStateOffsets[direction] ~= nil
end

local function is_forward_diagonal_move_input(context)
    return context
        and context.input_strength > 0.05
        and resolve_number(context.forward, 0) > 0
        and resolve_number(context.right, 0) ~= 0
end

local function is_pure_forward_back_move_input(context)
    return context
        and context.input_strength > 0.05
        and resolve_number(context.forward, 0) ~= 0
        and resolve_number(context.right, 0) == 0
end

local function is_opposite_forward_back_turn(context)
    if not is_pure_forward_back_move_input(context) then
        return false
    end

    local turn_angle = math.abs(resolve_number(context.turn_angle, resolve_number(context.move_angle, 0.0)))
    return turn_angle >= Constants.QUICK_TURN_MOVE_START_ANGLE
end

local function get_move_start_loop_transition_time(context)
    local spec = EventSpecs.SimpleMovementEvents.BaseMoveStart
    local transition_times = spec.move_loop_transition_times
    if transition_times then
        local direction = context.current_direction
        if direction == Constants.MOVE_DIRECTION_NONE then
            direction = context.direction
        end
        local transition_time = transition_times[direction]
        if transition_time ~= nil then
            return transition_time
        end
    end
    return spec.duration
end

local function is_turning_move_start_context(context)
    if not context then
        return false
    end

    local direction = context.current_direction
    if direction == Constants.MOVE_DIRECTION_NONE then
        direction = context.direction
    end
    if direction ~= Constants.MOVE_DIRECTION_NONE
        and direction ~= Constants.MOVE_DIRECTION_FORWARD then
        return true
    end

    return math.abs(resolve_number(context.turn_angle, 0.0)) > 12.0
end

local function get_move_start_to_loop_event_lead(context)
    return is_turning_move_start_context(context)
        and MOVE_START_TO_LOOP_TURN_EVENT_LEAD_SECONDS
        or MOVE_START_TO_LOOP_EVENT_LEAD_SECONDS
end

local function get_move_start_to_loop_notify_lead(context)
    return is_turning_move_start_context(context)
        and MOVE_START_TO_LOOP_TURN_NOTIFY_LEAD_SECONDS
        or MOVE_START_TO_LOOP_NOTIFY_LEAD_SECONDS
end

local function get_move_start_to_loop_exit_time(context)
    local move_loop_time = get_move_start_loop_transition_time(context)
    local requested_exit_time = is_turning_move_start_context(context)
        and MOVE_START_TO_LOOP_TURN_EXIT_SECONDS
        or MOVE_START_TO_LOOP_EXIT_SECONDS
    local lead_exit_time = move_loop_time - get_move_start_to_loop_event_lead(context)
    return math.max(math.min(requested_exit_time, lead_exit_time, MOVE_START_TO_LOOP_FORCE_SECONDS), 0.0)
end

local function will_reach_move_start_to_loop_exit(context)
    local elapsed = resolve_number(context and context.elapsed, 0.0)
    local delta_seconds = math.max(resolve_number(context and context.delta_seconds, 0.0), 0.0)
    local predicted_elapsed = elapsed + math.max(delta_seconds, MOVE_START_TO_LOOP_PREDICT_SECONDS)
    return predicted_elapsed >= get_move_start_to_loop_exit_time(context)
end

local function ensure_move_start_to_loop_notify(self, context)
    local runtime = ensure_runtime(self)
    if has_movement_anim_event(runtime, MOVEMENT_EVENT_MOVE_START_TO_LOOP) then
        return true
    end

    local layer = get_layer_runtime(runtime, Constants.LAYER_BASE)
    if layer.state ~= Constants.BASE_STATE_MOVE_START then
        return false
    end
    if layer.move_start_to_loop_notify_fired then
        return false
    end
    if not will_reach_move_start_to_loop_exit(context) then
        return false
    end

    layer.move_start_to_loop_notify_fired = true
    pulse_movement_anim_event(
        runtime,
        MOVEMENT_EVENT_MOVE_START_TO_LOOP,
        1.0,
        "LuaSyntheticMoveStartToLoop"
    )
    return true
end

local function get_quick_turn_to_loop_source_args(spec)
    local event_name = spec and spec.event or ""
    if event_name == "W_StandQuickTurnMoveStartLeft180" then
        return "StandQuickTurnMoveStartLeft180_to_StandMoveLoop"
    end
    if event_name == "W_StandQuickTurnMoveStartRight180" then
        return "StandQuickTurnMoveStartRight180_to_StandMoveLoop"
    end
    if event_name == "W_StandMoveQuickTurnLeft180" then
        return "StandMoveQuickTurnLeft180_to_StandMoveLoop"
    end
    if event_name == "W_StandMoveQuickTurnRight180" then
        return "StandMoveQuickTurnRight180_to_StandMoveLoop"
    end
    return "LuaSyntheticQuickTurnToMoveLoop"
end

local function will_reach_quick_turn_to_loop_exit(context, spec)
    local elapsed = resolve_number(context and context.elapsed, 0.0)
    local delta_seconds = math.max(resolve_number(context and context.delta_seconds, 0.0), 0.0)
    local predicted_elapsed = elapsed + math.max(delta_seconds, MOVE_START_TO_LOOP_PREDICT_SECONDS)
    return predicted_elapsed >= get_quick_turn_exit_time(nil, spec)
end

local function ensure_quick_turn_to_loop_notify(self, context)
    local runtime = ensure_runtime(self)
    if has_movement_anim_event(runtime, MOVEMENT_EVENT_LS_MOVE_QUEUED) then
        return true
    end

    if context.current_state ~= Constants.BASE_STATE_QUICK_TURN_MOVE_START_180
        and context.current_state ~= Constants.BASE_STATE_MOVE_QUICK_TURN_180 then
        return false
    end

    local spec = get_quick_turn_spec(self, context.current_state, context.current_direction)
    if not spec or spec.exit_policy ~= "move_loop" then
        return false
    end

    local layer = get_layer_runtime(runtime, Constants.LAYER_BASE)
    if layer.quick_turn_to_loop_notify_fired then
        return false
    end
    if not will_reach_quick_turn_to_loop_exit(context, spec) then
        return false
    end

    layer.quick_turn_to_loop_notify_fired = true
    pulse_movement_anim_event(
        runtime,
        MOVEMENT_EVENT_LS_MOVE_QUEUED,
        1.0,
        get_quick_turn_to_loop_source_args(spec)
    )
    return true
end

local function get_move_loop_from_start_angle_alpha(layer)
    if not layer
        or layer.state ~= Constants.BASE_STATE_MOVE_LOOP
        or layer.previous_state ~= Constants.BASE_STATE_MOVE_START then
        return 1.0
    end

    local elapsed = resolve_number(layer.elapsed, 0.0)
    return smooth_step(elapsed / math.max(MOVE_LOOP_FROM_START_ANGLE_SETTLE_SECONDS, 0.001))
end

local function get_move_loop_selector_angle(layer, move_angle)
    local angle = resolve_number(move_angle, 0.0)
    if layer
        and layer.state == Constants.BASE_STATE_MOVE_LOOP
        and layer.previous_state == Constants.BASE_STATE_MOVE_START then
        -- Match HKX's TaeBlend_Sync feel: MoveLoop enters from the same forward
        -- visual selector as MoveStart, then releases toward the live selector
        -- over a few frames instead of snapping to a side sample on frame 0.
        return angle * get_move_loop_from_start_angle_alpha(layer)
    end
    return angle
end

local function get_move_stop_exit_time(context)
    local spec = EventSpecs.SimpleMovementEvents.BaseMoveStop
    local direction_durations = spec.direction_durations
    if direction_durations then
        local direction = context.current_direction
        if direction == Constants.MOVE_DIRECTION_NONE then
            direction = context.direction
        end
        local duration = direction_durations[direction]
        if duration ~= nil then
            return duration
        end
    end
    return spec.duration
end

local function resolve_anim_direction_for_state(state_id, state_direction, input_direction)
    if state_samples_input_direction(state_id) then
        if state_direction ~= Constants.MOVE_DIRECTION_NONE then
            return state_direction
        end
        return input_direction
    end
    if state_id == Constants.BASE_STATE_IDLE then
        return Constants.MOVE_DIRECTION_NONE
    end
    return Constants.MOVE_DIRECTION_FORWARD
end

local function select_signed_turn_event(signed_angle, left45, right45, left90, right90, left135, right135, left180, right180)
    local abs_angle = math.abs(resolve_number(signed_angle, 0.0))
    if abs_angle <= Constants.TURN_8WAY_DEAD_ANGLE then
        return nil
    end

    local is_right = signed_angle > 0.0
    if abs_angle <= Constants.TURN_8WAY_45_MAX_ANGLE then
        return is_right and right45 or left45
    end
    if abs_angle <= Constants.TURN_8WAY_90_MAX_ANGLE then
        return is_right and right90 or left90
    end
    if abs_angle <= Constants.TURN_8WAY_135_MAX_ANGLE then
        return is_right and right135 or left135
    end
    return is_right and right180 or left180
end

local function select_ground_turn_event_by_angle(signed_angle)
    local abs_angle = math.abs(resolve_number(signed_angle, 0.0))
    if abs_angle > Constants.GROUND_QUICK_TURN_180_ANGLE then
        return signed_angle > 0.0
            and "BaseQuickTurnRight180"
            or "BaseQuickTurnLeft180"
    end

    return signed_angle > 0.0
        and "BaseQuickTurnRight90"
        or "BaseQuickTurnLeft90"
end

local function select_idle_move_input_turn_event_by_angle(signed_angle)
    return select_signed_turn_event(
        signed_angle,
        nil,
        nil,
        "BaseQuickTurnLeft90",
        "BaseQuickTurnRight90",
        "BaseQuickTurnMoveStartLeft135",
        "BaseQuickTurnMoveStartRight135",
        "BaseIdleQuickTurnLeft180Prelude",
        "BaseIdleQuickTurnRight180Prelude"
    )
end

local function select_move_start_turn_event_by_angle(signed_angle)
    local abs_angle = math.abs(resolve_number(signed_angle, 0.0))
    if abs_angle < Constants.QUICK_TURN_MOVE_START_ANGLE then
        return nil
    end
    return signed_angle > 0.0
        and "BaseQuickTurnMoveStartRight180"
        or "BaseQuickTurnMoveStartLeft180"
end

local function is_opposite_forward_back_input_change(context)
    if not is_pure_forward_back_move_input(context) then
        return false
    end
    if Wasd90
        and Wasd90.is_cardinal_move_direction(context.target_direction)
        and context.target_direction == context.facing_direction then
        return false
    end

    local current_forward = resolve_number(context.forward, 0)
    local source_forward = resolve_number(context.previous_forward, 0)
    if source_forward == 0 then
        source_forward = resolve_number(context.previous_pure_forward, 0)
    end
    if source_forward == 0 then
        local source_direction = context.current_direction
        if source_direction == Constants.MOVE_DIRECTION_FORWARD then
            source_forward = 1
        elseif source_direction == Constants.MOVE_DIRECTION_BACK then
            source_forward = -1
        end
    end

    if source_forward == 0 then
        return false
    end

    if source_forward * current_forward >= 0 then
        return false
    end

    return true
end

local function is_opposite_forward_back_turn90_guard_active(context)
    return is_pure_forward_back_move_input(context)
        and resolve_number(context.time, 0.0) <= resolve_number(context.opposite_forward_back_until, 0.0)
end

function M.QuickTurnVariant(left_event, right_event)
    return {
        left = left_event,
        right = right_event,
    }
end

local function select_opposite_forward_back_idle_turn_event(context)
    local cardinal_180 = Wasd90.select_cardinal_180_event(
        context,
        M.QuickTurnVariant("BaseIdleQuickTurnLeft180Prelude", "BaseIdleQuickTurnRight180Prelude"),
        M.QuickTurnVariant("BaseQuickTurnMoveStartLeft180", "BaseQuickTurnMoveStartRight180"),
        M.QuickTurnVariant("BaseMoveQuickTurnLeft180", "BaseMoveQuickTurnRight180")
    )
    if cardinal_180 then
        return cardinal_180
    end
    if is_opposite_forward_back_input_change(context) then
        return "BaseIdleQuickTurnRight180Prelude"
    end
    return nil
end

local function select_opposite_forward_back_ground_turn_event(context)
    local cardinal_180 = Wasd90.select_cardinal_180_event(
        context,
        M.QuickTurnVariant("BaseQuickTurnLeft180", "BaseQuickTurnRight180"),
        M.QuickTurnVariant("BaseQuickTurnMoveStartLeft180", "BaseQuickTurnMoveStartRight180"),
        M.QuickTurnVariant("BaseMoveQuickTurnLeft180", "BaseMoveQuickTurnRight180")
    )
    if cardinal_180 then
        return cardinal_180
    end
    if is_opposite_forward_back_input_change(context) then
        return "BaseQuickTurnRight180"
    end
    return nil
end

local function select_opposite_forward_back_move_start_turn_event(context)
    local cardinal_180 = Wasd90.select_cardinal_180_event(
        context,
        M.QuickTurnVariant("BaseIdleQuickTurnLeft180Prelude", "BaseIdleQuickTurnRight180Prelude"),
        M.QuickTurnVariant("BaseQuickTurnMoveStartLeft180", "BaseQuickTurnMoveStartRight180"),
        M.QuickTurnVariant("BaseMoveQuickTurnLeft180", "BaseMoveQuickTurnRight180")
    )
    if cardinal_180 then
        return cardinal_180
    end
    if is_opposite_forward_back_input_change(context) then
        return "BaseQuickTurnMoveStartRight180"
    end
    return nil
end

local function select_opposite_forward_back_move_loop_turn_event(context)
    local cardinal_180 = Wasd90.select_cardinal_180_event(
        context,
        M.QuickTurnVariant("BaseIdleQuickTurnLeft180Prelude", "BaseIdleQuickTurnRight180Prelude"),
        M.QuickTurnVariant("BaseQuickTurnMoveStartLeft180", "BaseQuickTurnMoveStartRight180"),
        M.QuickTurnVariant("BaseMoveQuickTurnLeft180", "BaseMoveQuickTurnRight180")
    )
    if cardinal_180 then
        return cardinal_180
    end
    if is_opposite_forward_back_input_change(context) then
        return "BaseMoveQuickTurnRight180"
    end
    return nil
end

local function select_opposite_forward_back_turn_event_for_state(context)
    local cardinal_180 = Wasd90.select_cardinal_180_event(
        context,
        M.QuickTurnVariant("BaseIdleQuickTurnLeft180Prelude", "BaseIdleQuickTurnRight180Prelude"),
        M.QuickTurnVariant("BaseQuickTurnMoveStartLeft180", "BaseQuickTurnMoveStartRight180"),
        M.QuickTurnVariant("BaseMoveQuickTurnLeft180", "BaseMoveQuickTurnRight180")
    )
    if cardinal_180 then
        return cardinal_180
    end
    if not is_opposite_forward_back_input_change(context) then
        return nil
    end

    if context.current_state == Constants.BASE_STATE_MOVE_LOOP then
        return "BaseMoveQuickTurnRight180"
    end
    if context.current_state == Constants.BASE_STATE_MOVE_START then
        return "BaseQuickTurnMoveStartRight180"
    end
    if context.current_state == Constants.BASE_STATE_MOVE_QUICK_TURN_180
        or context.current_state == Constants.BASE_STATE_QUICK_TURN_MOVE_START_180 then
        return "BaseMoveLoop"
    end
    return "BaseIdleQuickTurnRight180Prelude"
end

local function is_turn90_event_key(event_key)
    return event_key == "BaseQuickTurnLeft90"
        or event_key == "BaseQuickTurnRight90"
        or event_key == "BaseMoveStartQuickTurnLeft90"
        or event_key == "BaseMoveStartQuickTurnRight90"
        or event_key == "BaseMoveStartQuickTurnLeft90_Bridge"
        or event_key == "BaseMoveStartQuickTurnRight90_Bridge"
        or event_key == "BaseForwardLeftBackQuickTurnLeft90"
        or event_key == "BaseForwardRightBackQuickTurnRight90"
end

function is_quick_turn_event_key(event_key)
    return is_turn90_event_key(event_key)
        or event_key == "BaseQuickTurnLeft180"
        or event_key == "BaseQuickTurnRight180"
        or event_key == "BaseIdleQuickTurnLeft180Prelude"
        or event_key == "BaseIdleQuickTurnRight180Prelude"
        or event_key == "BaseQuickTurnMoveStartLeft135"
        or event_key == "BaseQuickTurnMoveStartRight135"
        or event_key == "BaseQuickTurnMoveStartLeft180"
        or event_key == "BaseQuickTurnMoveStartRight180"
        or event_key == "BaseMoveQuickTurnLeft135"
        or event_key == "BaseMoveQuickTurnRight135"
        or event_key == "BaseMoveQuickTurnLeft180"
        or event_key == "BaseMoveQuickTurnRight180"
        or event_key == "BaseForwardLeftBackMoveQuickTurnLeft180Prelude"
        or event_key == "BaseForwardRightBackMoveQuickTurnRight180Prelude"
end

function is_quick_turn_angle_valid(event_key, context)
    if context
        and Wasd90
        and Wasd90.is_cardinal_move_direction(context.target_direction)
        and context.target_direction == context.facing_direction then
        return false
    end
    local abs_angle = math.abs(resolve_number(context and context.turn_angle, 0.0))
    if is_turn90_event_key(event_key) then
        return abs_angle > Constants.GROUND_QUICK_TURN_TRIGGER_ANGLE
    end
    return abs_angle >= Constants.QUICK_TURN_MOVE_START_ANGLE
end

Wasd90 = {}

function Wasd90.is_move_start_quick_turn_bridge_event_key(event_key)
    return event_key == "BaseMoveStartQuickTurnLeft90_Bridge"
        or event_key == "BaseMoveStartQuickTurnRight90_Bridge"
end

function Wasd90.is_move_start_quick_turn_bridge_event_name(event_name)
    return event_name == "W_BaseMoveStartQuickTurnLeft90Bridge"
        or event_name == "W_BaseMoveStartQuickTurnRight90Bridge"
end

Wasd90.is_cardinal_move_direction = is_cardinal_direction
Wasd90.resolve_cardinal_direction_from_axes = resolve_cardinal_direction_from_axes

function Wasd90.normalize_signed_angle(angle)
    angle = resolve_number(angle, 0.0)
    while angle > 180.0 do
        angle = angle - 360.0
    end
    while angle <= -180.0 do
        angle = angle + 360.0
    end
    return angle
end

function Wasd90.resolve_cardinal_direction_from_angle(angle)
    local signed_angle = Wasd90.normalize_signed_angle(angle)
    local abs_angle = math.abs(signed_angle)
    if abs_angle <= Constants.TURN_8WAY_DEAD_ANGLE then
        return Constants.MOVE_DIRECTION_FORWARD
    end
    if abs_angle >= 180.0 - Constants.TURN_8WAY_DEAD_ANGLE then
        return Constants.MOVE_DIRECTION_BACK
    end
    if math.abs(abs_angle - 90.0) <= Constants.TURN_8WAY_DEAD_ANGLE then
        return signed_angle < 0.0
            and Constants.MOVE_DIRECTION_LEFT
            or Constants.MOVE_DIRECTION_RIGHT
    end
    return Constants.MOVE_DIRECTION_NONE
end

local function get_actor_yaw(self)
    if not self then
        return 0.0
    end

    local rotation = nil
    if self.GetActorRotation then
        local ok, result = pcall(function()
            return self:GetActorRotation()
        end)
        if ok then
            rotation = result
        end
    end
    if not rotation and self.K2_GetActorRotation then
        local ok, result = pcall(function()
            return self:K2_GetActorRotation()
        end)
        if ok then
            rotation = result
        end
    end
    if not rotation then
        return 0.0
    end

    return resolve_number(rotation.Yaw or rotation.yaw or rotation.Y or rotation.y, 0.0)
end

function Wasd90.resolve_actor_facing_direction(self)
    if not self then
        return Constants.MOVE_DIRECTION_NONE
    end

    local rotation = nil
    if self.GetActorRotation then
        local ok, result = pcall(function()
            return self:GetActorRotation()
        end)
        if ok then
            rotation = result
        end
    end
    if not rotation and self.K2_GetActorRotation then
        local ok, result = pcall(function()
            return self:K2_GetActorRotation()
        end)
        if ok then
            rotation = result
        end
    end
    if not rotation then
        return Constants.MOVE_DIRECTION_NONE
    end

    local yaw = rotation.Yaw or rotation.yaw or rotation.Y or rotation.y
    if yaw == nil then
        return Constants.MOVE_DIRECTION_NONE
    end
    return Wasd90.resolve_cardinal_direction_from_angle(yaw)
end

function Wasd90.select_cardinal_90_bridge_event(context)
    if not context
        or context.suppress_move_until_input_released
        or resolve_number(context.input_strength, 0.0) <= 0.05 then
        return nil
    end

    local state_can_bridge =
        context.current_state == Constants.BASE_STATE_IDLE
        or context.current_state == Constants.BASE_STATE_MOVE_START
        or context.current_state == Constants.BASE_STATE_MOVE_LOOP
        or context.current_state == Constants.BASE_STATE_MOVE_STOP
    if not state_can_bridge then
        return nil
    end

    local target_direction = Wasd90.resolve_cardinal_direction_from_axes(context.forward, context.right)
    if not Wasd90.is_cardinal_move_direction(target_direction) then
        return nil
    end

    local target_angle = DirectionAngles[target_direction]
    if target_angle == nil then
        return nil
    end

    local source_direction = context.facing_direction
    if not Wasd90.is_cardinal_move_direction(source_direction) then
        -- WASD is an absolute target direction. The current absolute facing is
        -- the target world direction minus the actor-relative input angle.
        source_direction = Wasd90.resolve_cardinal_direction_from_angle(
            target_angle - resolve_number(context.move_angle, 0.0)
        )
    end
    if not Wasd90.is_cardinal_move_direction(source_direction) then
        source_direction = context.current_direction
    end
    if not Wasd90.is_cardinal_move_direction(source_direction) then
        source_direction = context.previous_direction
    end
    if not Wasd90.is_cardinal_move_direction(source_direction) then
        source_direction = Wasd90.resolve_cardinal_direction_from_axes(context.previous_forward, context.previous_right)
    end
    if not Wasd90.is_cardinal_move_direction(source_direction)
        and context.current_state == Constants.BASE_STATE_IDLE then
        source_direction = Constants.MOVE_DIRECTION_FORWARD
    end
    if not Wasd90.is_cardinal_move_direction(source_direction) or source_direction == target_direction then
        return nil
    end

    local source_angle = DirectionAngles[source_direction]
    if source_angle == nil then
        return nil
    end

    local signed_delta = Wasd90.normalize_signed_angle(target_angle - source_angle)
    if math.abs(math.abs(signed_delta) - 90.0) > 0.01 then
        return nil
    end

    return signed_delta > 0.0
        and "BaseQuickTurnRight90"
        or "BaseQuickTurnLeft90"
end

local function select_forward_diagonal_opposite_90_bridge_event(context)
    if not context
        or context.suppress_move_until_input_released
        or resolve_number(context.input_strength, 0.0) <= 0.05 then
        return nil
    end

    local remembered_forward_left =
        resolve_number(context.time, 0.0) <= resolve_number(context.forward_left_source_until, 0.0)
    local remembered_forward_right =
        resolve_number(context.time, 0.0) <= resolve_number(context.forward_right_source_until, 0.0)
    if resolve_number(context.forward, 0) <= 0 and not remembered_forward_left and not remembered_forward_right then
        return nil
    end
    local state_can_bridge =
        context.current_state == Constants.BASE_STATE_MOVE_START
        or context.current_state == Constants.BASE_STATE_MOVE_LOOP
        or context.current_state == Constants.BASE_STATE_MOVE_STOP
        or remembered_forward_left
        or remembered_forward_right
    if not state_can_bridge then
        return nil
    end

    local right_is_target = resolve_number(context.right, 0) > 0
        or (context.right_held and not context.previous_right_held)
    local left_is_target = resolve_number(context.right, 0) < 0
        or (context.left_held and not context.previous_left_held)

    local source_is_forward_left =
        context.current_direction == Constants.MOVE_DIRECTION_FORWARD_LEFT
        or context.previous_direction == Constants.MOVE_DIRECTION_FORWARD_LEFT
        or resolve_number(context.previous_right, 0) < 0
        or (context.previous_left_held and not context.previous_right_held)
        or remembered_forward_left
    if source_is_forward_left and right_is_target then
        return "BaseQuickTurnRight90"
    end

    local source_is_forward_right =
        context.current_direction == Constants.MOVE_DIRECTION_FORWARD_RIGHT
        or context.previous_direction == Constants.MOVE_DIRECTION_FORWARD_RIGHT
        or resolve_number(context.previous_right, 0) > 0
        or (context.previous_right_held and not context.previous_left_held)
        or remembered_forward_right
    if source_is_forward_right and left_is_target then
        return "BaseQuickTurnLeft90"
    end

    return nil
end

function Wasd90.select_wasd_90_bridge_event(context)
    return Wasd90.select_cardinal_90_bridge_event(context)
        or select_forward_diagonal_opposite_90_bridge_event(context)
end

function Wasd90.resolve_cardinal_turn_delta(context)
    if not context then
        return nil
    end

    local target_direction = context.target_direction
    if not Wasd90.is_cardinal_move_direction(target_direction) then
        target_direction = Wasd90.resolve_cardinal_direction_from_axes(context.forward, context.right)
    end
    if not Wasd90.is_cardinal_move_direction(target_direction) then
        return nil
    end

    local source_direction = context.facing_direction
    if not Wasd90.is_cardinal_move_direction(source_direction) then
        source_direction = context.current_direction
    end
    if not Wasd90.is_cardinal_move_direction(source_direction) then
        source_direction = context.previous_direction
    end
    if not Wasd90.is_cardinal_move_direction(source_direction) then
        return nil
    end

    local source_angle = DirectionAngles[source_direction]
    local target_angle = DirectionAngles[target_direction]
    if source_angle == nil or target_angle == nil then
        return nil
    end

    return {
        source_direction = source_direction,
        target_direction = target_direction,
        signed_delta = Wasd90.normalize_signed_angle(target_angle - source_angle),
    }
end

function Wasd90.select_cardinal_180_event(context, idle_event, move_start_event, move_loop_event)
    if not context
        or context.suppress_move_until_input_released
        or resolve_number(context.input_strength, 0.0) <= 0.05 then
        return nil
    end

    local turn = Wasd90.resolve_cardinal_turn_delta(context)
    if not turn or math.abs(math.abs(turn.signed_delta) - 180.0) > 0.01 then
        return nil
    end

    local use_left = false
    if context.current_state == Constants.BASE_STATE_MOVE_LOOP
        and not (context.previous_state == Constants.BASE_STATE_MOVE_START
            and resolve_number(context.elapsed, 0.0) <= MOVE_LOOP_FROM_START_ANGLE_SETTLE_SECONDS) then
        use_left = resolve_number(context.turn_angle, resolve_number(context.move_angle, 0.0)) < 0.0
    else
        use_left = resolve_number(context.twist_angle, -resolve_number(context.turn_angle, 0.0)) > 0.0
    end

    local function select_variant(event_or_variant)
        if type(event_or_variant) == "table" then
            return use_left and event_or_variant.left or event_or_variant.right
        end
        return event_or_variant
    end

    if context.current_state == Constants.BASE_STATE_MOVE_LOOP then
        if context.previous_state == Constants.BASE_STATE_MOVE_START
            and resolve_number(context.elapsed, 0.0) <= MOVE_LOOP_FROM_START_ANGLE_SETTLE_SECONDS then
            return select_variant(move_start_event)
        end
        return select_variant(move_loop_event)
    end
    if context.current_state == Constants.BASE_STATE_MOVE_START then
        return select_variant(move_start_event)
    end
    if context.current_state == Constants.BASE_STATE_IDLE
        or context.current_state == Constants.BASE_STATE_MOVE_STOP then
        return select_variant(idle_event)
    end
    return nil
end

local function select_forward_left_to_back_stop_turn_event(context)
    if not context
        or context.suppress_move_until_input_released
        or resolve_number(context.input_strength, 0.0) <= 0.05
        or resolve_number(context.forward, 0) >= 0 then
        return nil
    end
    if resolve_number(context.right, 0) == 0
        and not context.left_held
        and not context.right_held then
        return nil
    end

    local remembered_forward_left =
        resolve_number(context.time, 0.0) <= resolve_number(context.forward_left_source_until, 0.0)
    local state_can_chain =
        context.current_state == Constants.BASE_STATE_MOVE_START
        or context.current_state == Constants.BASE_STATE_MOVE_LOOP
        or context.current_state == Constants.BASE_STATE_MOVE_STOP
        or remembered_forward_left
    if not state_can_chain then
        return nil
    end

    local source_is_forward_left =
        context.current_direction == Constants.MOVE_DIRECTION_FORWARD_LEFT
        or context.previous_direction == Constants.MOVE_DIRECTION_FORWARD_LEFT
        or remembered_forward_left
    if not source_is_forward_left then
        return nil
    end

    return "BaseForwardLeftBackRunStop"
end

local function select_forward_right_to_back_stop_turn_event(context)
    if not context
        or context.suppress_move_until_input_released
        or resolve_number(context.input_strength, 0.0) <= 0.05
        or resolve_number(context.forward, 0) >= 0 then
        return nil
    end
    if resolve_number(context.right, 0) == 0
        and not context.left_held
        and not context.right_held then
        return nil
    end

    local remembered_forward_right =
        resolve_number(context.time, 0.0) <= resolve_number(context.forward_right_source_until, 0.0)
    local state_can_chain =
        context.current_state == Constants.BASE_STATE_MOVE_START
        or context.current_state == Constants.BASE_STATE_MOVE_LOOP
        or context.current_state == Constants.BASE_STATE_MOVE_STOP
        or remembered_forward_right
    if not state_can_chain then
        return nil
    end

    local source_is_forward_right =
        context.current_direction == Constants.MOVE_DIRECTION_FORWARD_RIGHT
        or context.previous_direction == Constants.MOVE_DIRECTION_FORWARD_RIGHT
        or remembered_forward_right
    if not source_is_forward_right then
        return nil
    end

    return "BaseForwardRightBackRunStop"
end

local function select_forward_diagonal_to_back_stop_turn_event(context)
    return select_forward_left_to_back_stop_turn_event(context)
        or select_forward_right_to_back_stop_turn_event(context)
end

local function resolve_quick_turn_move_start_motion_selector_direction(direction, context)
    if context and context.current_state == Constants.BASE_STATE_QUICK_TURN_MOVE_START_180 then
        -- HKX drives the invisible Motion selector through F -> B/F -> F.
        -- The Motion layer has zero pose bone weights, so this phase should
        -- not leak the back-start footwork into the visible character pose.
        local elapsed = resolve_number(context.elapsed, 0.0)
        if elapsed <= QUICK_TURN_MOVE_START_SELECTOR_F_PRELUDE_SECONDS then
            return Constants.MOVE_DIRECTION_FORWARD
        end

        if elapsed <= QUICK_TURN_MOVE_START_SELECTOR_F_PRELUDE_SECONDS
            + QUICK_TURN_MOVE_START_SELECTOR_BF_BLEND_SECONDS then
            return Constants.MOVE_DIRECTION_BACK
        end

        return Constants.MOVE_DIRECTION_FORWARD
    end

    if is_opposite_forward_back_turn(context) then
        return Constants.MOVE_DIRECTION_FORWARD
    end

    if not is_valid_move_direction(direction) then
        return Constants.MOVE_DIRECTION_FORWARD
    end
    return direction
end

local function resolve_quick_turn_move_start_visible_selector_direction(direction, context)
    if context and context.current_state == Constants.BASE_STATE_QUICK_TURN_MOVE_START_180 then
        return Constants.MOVE_DIRECTION_FORWARD
    end

    if is_opposite_forward_back_turn(context) then
        return Constants.MOVE_DIRECTION_FORWARD
    end

    if not is_valid_move_direction(direction) then
        return Constants.MOVE_DIRECTION_FORWARD
    end
    return direction
end

local function select_move_loop_turn_event_by_angle(signed_angle)
    local abs_angle = math.abs(resolve_number(signed_angle, 0.0))
    if abs_angle < Constants.STAND_MOVE_QUICK_TURN_ANGLE then
        return nil
    end
    return signed_angle > 0.0
        and "BaseMoveQuickTurnRight180"
        or "BaseMoveQuickTurnLeft180"
end

local function sync_polled_input(self)
    local runtime = ensure_runtime(self)
    local forward = 0
    local right = 0
    local sprint = false
    local query = get_env_query(self)

    if query then
        forward = clamp_intent(query.MoveInputForward)
        right = clamp_intent(query.MoveInputRight)
        sprint = resolve_bool(query.bSprintHeld, false)
    end

    if self.GetPreviewForwardIntent then
        local preview_forward = clamp_intent(self:GetPreviewForwardIntent())
        if preview_forward ~= 0 then
            forward = preview_forward
        elseif forward == 0 then
            forward = preview_forward
        end
    end
    if self.GetPreviewRightIntent then
        local preview_right = clamp_intent(self:GetPreviewRightIntent())
        if preview_right ~= 0 then
            right = preview_right
        elseif right == 0 then
            right = preview_right
        end
    end
    if not sprint and self.IsPreviewSprintHeld then
        sprint = resolve_bool(self:IsPreviewSprintHeld(), false)
    end

    local previous_forward = resolve_number(runtime.input.forward, 0.0)
    local previous_pure_forward = resolve_number(runtime.input.last_pure_forward, 0.0)
    local previous_right = resolve_number(runtime.input.right, 0.0)
    local previous_left_held = resolve_bool(runtime.input.left_held, false)
    local previous_right_held = resolve_bool(runtime.input.right_held, false)
    local left_held = right < 0
    local right_held = right > 0

    local previous_strength = resolve_number(runtime.input.strength, 0.0)
    local strength = math.min(math.sqrt(forward * forward + right * right), 1.0)
    if strength <= 0.05 then
        runtime.input.suppress_move_until_input_released = false
        runtime.input.suppressed_target_direction = Constants.MOVE_DIRECTION_NONE
        runtime.input.quick_turn_90_suppress_until = 0.0
    elseif runtime.input.suppress_move_until_input_released then
        local target_direction = Wasd90.resolve_cardinal_direction_from_axes(forward, right)
        if Wasd90.is_cardinal_move_direction(target_direction)
            and Wasd90.is_cardinal_move_direction(runtime.input.suppressed_target_direction)
            and target_direction ~= runtime.input.suppressed_target_direction then
            runtime.input.suppress_move_until_input_released = false
            runtime.input.suppressed_target_direction = Constants.MOVE_DIRECTION_NONE
            runtime.input.quick_turn_90_suppress_until = 0.0
        end
    end
    local direction = Constants.MOVE_DIRECTION_NONE
    local move_angle = get_preview_move_angle(self, forward, right)
    local turn_angle = move_angle
    local twist_angle = -move_angle
    if strength > 0.0 then
        direction = resolve_move_direction_from_angle(move_angle)
    end
    runtime.facing = runtime.facing or {}
    local actor_facing_direction = Wasd90.resolve_actor_facing_direction(self)
    local has_actor_facing_direction = Wasd90.is_cardinal_move_direction(actor_facing_direction)
    if has_actor_facing_direction then
        runtime.facing.direction = actor_facing_direction
    end
    if strength > 0.05 and not has_actor_facing_direction then
        local target_direction = Wasd90.resolve_cardinal_direction_from_axes(forward, right)
        local target_angle = DirectionAngles[target_direction]
        if target_angle ~= nil then
            local facing_direction = Wasd90.resolve_cardinal_direction_from_angle(target_angle - move_angle)
            if Wasd90.is_cardinal_move_direction(facing_direction) then
                runtime.facing.direction = facing_direction
            end
        end
    end

    if forward > 0 and (left_held or right < 0 or direction == Constants.MOVE_DIRECTION_FORWARD_LEFT) then
        runtime.input.forward_left_source_until = runtime.time + FORWARD_LEFT_SOURCE_MEMORY_SECONDS
    elseif runtime.time > resolve_number(runtime.input.forward_left_source_until, 0.0) then
        runtime.input.forward_left_source_until = 0.0
    end
    if forward > 0 and (right_held or right > 0 or direction == Constants.MOVE_DIRECTION_FORWARD_RIGHT) then
        runtime.input.forward_right_source_until = runtime.time + FORWARD_LEFT_SOURCE_MEMORY_SECONDS
    elseif runtime.time > resolve_number(runtime.input.forward_right_source_until, 0.0) then
        runtime.input.forward_right_source_until = 0.0
    end

    local env_wants_move = env(self, 2000) == true and env(self, 1105) ~= true
    local canceled_move_input = strength <= 0.05 and env_wants_move
    if canceled_move_input then
        runtime.turn.quick_turn_reentry_block_until = runtime.time + QUICK_TURN_REENTRY_DEBOUNCE_SECONDS
    end

    if strength > 0.05
        and right == 0
        and forward ~= 0
        and previous_pure_forward ~= 0
        and previous_pure_forward * forward < 0 then
        runtime.input.opposite_forward_back_until = runtime.time + 10.0
    elseif strength > 0.05
        and right == 0
        and forward ~= 0
        and runtime.time <= resolve_number(runtime.input.opposite_forward_back_until, 0.0) then
        runtime.input.opposite_forward_back_until = runtime.time + 10.0
    elseif strength > 0.05 and right ~= 0 then
        runtime.input.opposite_forward_back_until = 0.0
    elseif strength <= 0.05 then
        runtime.input.opposite_forward_back_until = 0.0
    end

    runtime.input.forward = forward
    runtime.input.right = right
    runtime.input.previous_forward = previous_forward
    runtime.input.previous_pure_forward = previous_pure_forward
    runtime.input.previous_right = previous_right
    runtime.input.left_held = left_held
    runtime.input.right_held = right_held
    runtime.input.previous_left_held = previous_left_held
    runtime.input.previous_right_held = previous_right_held
    runtime.input.sprint = sprint
    runtime.input.previous_strength = previous_strength
    runtime.input.strength = strength
    runtime.input.canceled_move_input = canceled_move_input
    runtime.input.move_angle = move_angle
    runtime.input.turn_angle = turn_angle
    runtime.input.twist_angle = twist_angle
    runtime.input.direction = direction
    if strength > 0.05 and right == 0 and forward ~= 0 then
        runtime.input.last_pure_forward = forward
    elseif strength <= 0.05 or right ~= 0 then
        runtime.input.last_pure_forward = 0
    end

    if self.SetPreviewDebugInput then
        self:SetPreviewDebugInput(forward, right, sprint)
    end
end

local function get_layer_state_id(self, runtime, layer_id)
    local state_machine = get_state_machine(self)
    if state_machine and state_machine.GetLayerStateId then
        return resolve_number(state_machine:GetLayerStateId(layer_id), Constants.BASE_STATE_IDLE)
    end
    return get_layer_runtime(runtime, layer_id).state
end

local function get_layer_direction_id(self, runtime, layer_id)
    local state_machine = get_state_machine(self)
    if state_machine and state_machine.GetLayerDirectionId then
        return resolve_number(state_machine:GetLayerDirectionId(layer_id), Constants.MOVE_DIRECTION_NONE)
    end
    return get_layer_runtime(runtime, layer_id).direction
end

local function get_layer_elapsed_seconds(self, runtime, layer_id)
    local state_machine = get_state_machine(self)
    if state_machine and state_machine.GetLayerStateElapsedSeconds then
        return math.max(resolve_number(state_machine:GetLayerStateElapsedSeconds(layer_id), 0.0), 0.0)
    end
    return math.max(runtime.time - get_layer_runtime(runtime, layer_id).entered_at, 0.0)
end

local function get_layer_state_name(self, runtime, layer_id)
    local state_machine = get_state_machine(self)
    if state_machine and state_machine.GetLayerStateName then
        local ok, name = pcall(function()
            return state_machine:GetLayerStateName(layer_id)
        end)
        if ok and name and name ~= "" then
            return name
        end
    end
    return get_layer_runtime(runtime, layer_id).state_name
end

local function get_layer_event_name(self, runtime, layer_id)
    local state_machine = get_state_machine(self)
    if state_machine and state_machine.GetLayerLastEventName then
        local ok, name = pcall(function()
            return state_machine:GetLayerLastEventName(layer_id)
        end)
        if ok and name and name ~= "" then
            return name
        end
    end
    return get_layer_runtime(runtime, layer_id).event
end

local function reset_anim_requests(self)
    require("Sekiro.C0000.FireEventHandlers").clear_anim_requests(self)
end
activate_event = function(self, event_key, context)
    if is_turn90_event_key(event_key) and is_opposite_forward_back_turn90_guard_active(context) then
        local remapped_event = select_opposite_forward_back_turn_event_for_state(context)
        if remapped_event then
            event_key = remapped_event
        end
    end

    if event_key == "BaseIdleQuickTurnLeft180Prelude"
        or event_key == "BaseIdleQuickTurnRight180Prelude"
        or event_key == "BaseQuickTurnMoveStartLeft135"
        or event_key == "BaseQuickTurnMoveStartRight135"
        or event_key == "BaseQuickTurnMoveStartLeft180"
        or event_key == "BaseQuickTurnMoveStartRight180"
        or event_key == "BaseMoveQuickTurnLeft135"
        or event_key == "BaseMoveQuickTurnRight135"
        or event_key == "BaseMoveQuickTurnLeft180"
        or event_key == "BaseMoveQuickTurnRight180" then
        if not is_opposite_forward_back_turn90_guard_active(context) then
            local forward_left_to_back_chain = select_forward_diagonal_to_back_stop_turn_event(context)
            if forward_left_to_back_chain then
                local chain_spec = EventSpecs.SimpleMovementEvents[forward_left_to_back_chain]
                if chain_spec then
                    return require("Sekiro.C0000.FireEventHandlers").handle(
                        self,
                        chain_spec.event or forward_left_to_back_chain,
                        forward_left_to_back_chain,
                        context
                    )
                end
            end
            local diagonal_bridge = Wasd90.select_wasd_90_bridge_event(context)
            if diagonal_bridge then
                local bridge_spec = EventSpecs.SimpleMovementEvents[diagonal_bridge]
                if bridge_spec then
                    return require("Sekiro.C0000.FireEventHandlers").handle(
                        self,
                        bridge_spec.event or diagonal_bridge,
                        diagonal_bridge,
                        context
                    )
                end
            end
        end
    end

    local spec = EventSpecs.SimpleMovementEvents[event_key]
    if not spec then
        return false
    end
    local handled = require("Sekiro.C0000.FireEventHandlers").handle(
        self,
        spec.event or event_key,
        event_key,
        context
    )
    if handled then
        return true
    end
    return false
end

local function deactivate_add_layer(self, layer_id, event_name)
    local runtime = ensure_runtime(self)
    local layer = get_layer_runtime(runtime, layer_id)
    local default = LayerDefaults[layer_id] or LayerDefaults[Constants.LAYER_ACTION]
    local previous_state = layer.state

    if previous_state == default.state and layer.event == default.event then
        return false
    end

    local ended_ground_attack =
        layer_id == Constants.LAYER_ACTION and is_ground_attack_action_state(previous_state)
    local handled = require("Sekiro.C0000.FireEventHandlers").deactivate_layer(self, layer_id, event_name)
    if layer_id == Constants.LAYER_ACTION then
        clear_ground_attack_runtime(runtime)
        if ended_ground_attack then
            local base_layer = get_layer_runtime(runtime, Constants.LAYER_BASE)
            print_runtime(
                self,
                string.format(
                    "GroundAttack ActionEnd detail: prevAction=%s Base=%s input=%.2f f=%.2f r=%.2f move=%.1f turn=%.1f suppressRelease=%s ActorYaw=%.2f",
                    StateNames[previous_state] or tostring(previous_state),
                    StateNames[base_layer.state] or tostring(base_layer.state),
                    resolve_number(runtime.input and runtime.input.strength, 0.0),
                    resolve_number(runtime.input and runtime.input.forward, 0.0),
                    resolve_number(runtime.input and runtime.input.right, 0.0),
                    resolve_number(runtime.input and runtime.input.move_angle, 0.0),
                    resolve_number(runtime.input and runtime.input.turn_angle, 0.0),
                    tostring(runtime.input and runtime.input.suppress_move_until_input_released),
                    get_actor_yaw(self)
                )
            )
            runtime.ground_attack.base_settle_until =
                runtime.time + GROUND_ATTACK_END_BASE_SETTLE_SECONDS
            runtime.turn.active = false
            runtime.turn.applied_yaw_delta = 0.0
            runtime.turn.ground_quick_turn_suppress_until =
                math.max(
                    resolve_number(runtime.turn.ground_quick_turn_suppress_until, 0.0),
                    runtime.ground_attack.base_settle_until
                )
            if resolve_number(runtime.input and runtime.input.strength, 0.0) > 0.05 then
                runtime.input.suppress_move_until_input_released = true
                runtime.input.suppressed_target_direction =
                    Wasd90.resolve_cardinal_direction_from_axes(
                        runtime.input.forward,
                        runtime.input.right
                    )
                runtime.input.quick_turn_90_suppress_until =
                    math.max(
                        resolve_number(runtime.input.quick_turn_90_suppress_until, 0.0),
                        runtime.ground_attack.base_settle_until
                    )
                print_runtime(
                    self,
                    string.format(
                        "GroundAttack ActionEnd: suppress Base quick turn until move input release dir=%s strength=%.2f",
                        DirectionNames[runtime.input.suppressed_target_direction]
                            or tostring(runtime.input.suppressed_target_direction),
                        resolve_number(runtime.input.strength, 0.0)
                    )
                )
            end
        end
    end
    print_runtime(
        self,
        string.format(
            "Layer %s: %s -> %s event=%s",
            LayerNames[layer_id] or tostring(layer_id),
            StateNames[previous_state] or tostring(previous_state),
            default.state_name,
            event_name or default.event
        )
    )
    return handled
end

local function refresh_layer_from_component(self, runtime, layer_id)
    local layer = get_layer_runtime(runtime, layer_id)
    local current_state = get_layer_state_id(self, runtime, layer_id)
    local current_direction = get_layer_direction_id(self, runtime, layer_id)
    local current_event = get_layer_event_name(self, runtime, layer_id)
    local current_state_name = get_layer_state_name(self, runtime, layer_id)
    local native_elapsed = get_layer_elapsed_seconds(self, runtime, layer_id)
    local state_changed = current_state ~= layer.state
    local direction_changed = current_direction ~= layer.direction
    local event_changed = current_event ~= nil and current_event ~= "" and current_event ~= layer.event

    if state_changed or direction_changed or event_changed then
        layer.previous_state = layer.state
        layer.previous_direction = layer.direction
        layer.state = current_state
        layer.direction = current_direction
        layer.event = current_event
        layer.state_name = current_state_name
        layer.applied_yaw_delta = 0.0
        layer.turn_angle = 0.0
        layer.move_start_selector_id = nil
        layer.move_start_to_loop_notify_fired = nil
        layer.quick_turn_to_loop_notify_fired = nil
        if current_state == Constants.BASE_STATE_MOVE_START then
            layer.move_start_input_direction = current_direction
        else
            layer.move_start_input_direction = nil
        end
        layer.entered_at = runtime.time - native_elapsed
    end

    layer.elapsed = math.max(native_elapsed, runtime.time - layer.entered_at)
    return layer, current_state
end

local function read_context(self, delta_seconds)
    local runtime = ensure_runtime(self)
    local layer, current_state = refresh_layer_from_component(self, runtime, Constants.LAYER_BASE)
    local action_layer = refresh_layer_from_component(self, runtime, Constants.LAYER_ACTION)
    local reaction_layer = refresh_layer_from_component(self, runtime, Constants.LAYER_REACTION)

    local has_move_input = runtime.input.strength > 0.05
    local wants_move = has_move_input
    if not wants_move and not runtime.input.canceled_move_input then
        wants_move = env(self, 2000) == true
            and env(self, 1105) ~= true
    end

    return {
        delta_seconds = delta_seconds,
        layer = Constants.LAYER_BASE,
        current_state = current_state,
        elapsed = layer.elapsed,
        wants_move = wants_move,
        has_move_input = has_move_input,
        canceled_move_input = runtime.input.canceled_move_input,
        input_strength = runtime.input.strength,
        previous_input_strength = runtime.input.previous_strength,
        move_angle = runtime.input.move_angle,
        turn_angle = runtime.input.turn_angle,
        twist_angle = runtime.input.twist_angle,
        forward = runtime.input.forward,
        right = runtime.input.right,
        previous_forward = runtime.input.previous_forward,
        previous_pure_forward = runtime.input.previous_pure_forward,
        opposite_forward_back_until = runtime.input.opposite_forward_back_until,
        previous_right = runtime.input.previous_right,
        left_held = runtime.input.left_held,
        right_held = runtime.input.right_held,
        previous_left_held = runtime.input.previous_left_held,
        previous_right_held = runtime.input.previous_right_held,
        suppress_move_until_input_released = runtime.input.suppress_move_until_input_released,
        forward_left_source_until = runtime.input.forward_left_source_until,
        forward_right_source_until = runtime.input.forward_right_source_until,
        time = runtime.time,
        sprint = runtime.input.sprint,
        direction = runtime.input.direction,
        target_direction = Wasd90.resolve_cardinal_direction_from_axes(runtime.input.forward, runtime.input.right),
        facing_direction = runtime.facing and runtime.facing.direction or Constants.MOVE_DIRECTION_FORWARD,
        current_event = layer.event,
        current_direction = layer.direction,
        previous_state = layer.previous_state or layer.state,
        previous_direction = layer.previous_direction or layer.direction,
        action_state = action_layer.state,
        action_elapsed = action_layer.elapsed,
        reaction_state = reaction_layer.state,
        reaction_elapsed = reaction_layer.elapsed,
    }
end

local function select_ground_quick_turn_event(self, context)
    local runtime = ensure_runtime(self)
    if runtime.input and runtime.input.suppress_move_until_input_released then
        return nil
    end
    if runtime.time < resolve_number(runtime.turn.ground_quick_turn_suppress_until, 0.0) then
        return nil
    end
    if is_forward_diagonal_move_input(context) then
        return nil
    end

    local opposite_forward_back_event = select_opposite_forward_back_ground_turn_event(context)
    if opposite_forward_back_event then
        return opposite_forward_back_event
    end

    local turn_angle = resolve_number(context.turn_angle, resolve_number(context.move_angle, 0.0))
    local twist_angle = -resolve_number(context.twist_angle, -turn_angle)
    local abs_angle = math.abs(turn_angle)
    local abs_twist = math.abs(twist_angle)
    if abs_angle <= Constants.GROUND_QUICK_TURN_TRIGGER_ANGLE
        and abs_twist <= Constants.GROUND_QUICK_TURN_TRIGGER_ANGLE then
        return nil
    end

    local signed_turn = turn_angle
    if abs_twist > abs_angle then
        signed_turn = twist_angle
    end
    return select_ground_turn_event_by_angle(signed_turn)
end

local function select_idle_move_input_turn_event(self, context)
    local runtime = ensure_runtime(self)
    if not context or not context.wants_move then
        return nil
    end
    if runtime.input and runtime.input.suppress_move_until_input_released then
        return nil
    end

    local opposite_forward_back_event = select_opposite_forward_back_idle_turn_event(context)
    if opposite_forward_back_event then
        return opposite_forward_back_event
    end

    local diagonal_bridge = Wasd90.select_wasd_90_bridge_event(context)
    if diagonal_bridge then
        return diagonal_bridge
    end

    if is_forward_diagonal_move_input(context) then
        return nil
    end

    local turn_angle = resolve_number(context.turn_angle, resolve_number(context.move_angle, 0.0))
    local twist_angle = -resolve_number(context.twist_angle, -turn_angle)
    local signed_turn = math.abs(twist_angle) > math.abs(turn_angle) and twist_angle or turn_angle
    if runtime.time < resolve_number(runtime.turn.ground_quick_turn_suppress_until, 0.0) then
        local fresh_move_press = resolve_number(context.previous_input_strength, 0.0) <= 0.05
            and resolve_number(context.input_strength, 0.0) > 0.05
        if not fresh_move_press or math.abs(signed_turn) <= Constants.TURN_8WAY_135_MAX_ANGLE then
            return nil
        end
    end
    return select_idle_move_input_turn_event_by_angle(signed_turn)
end

local function select_move_start_quick_turn_event(self, context)
    local runtime = ensure_runtime(self)
    if runtime.input
        and (runtime.input.suppress_move_until_input_released
            or runtime.time < resolve_number(runtime.input.quick_turn_90_suppress_until, 0.0)) then
        return nil
    end
    if runtime.time < resolve_number(runtime.turn.move_stop_restart_quick_turn_suppress_until, 0.0) then
        return nil
    end
    if context
        and context.current_state == Constants.BASE_STATE_MOVE_START
        and resolve_number(context.elapsed, 0.0) < MOVE_START_QUICK_TURN_GATE_SECONDS then
        return nil
    end
    local diagonal_bridge = Wasd90.select_wasd_90_bridge_event(context)
    if diagonal_bridge then
        return diagonal_bridge
    end
    if is_forward_diagonal_move_input(context) then
        return nil
    end

    local opposite_forward_back_event = select_opposite_forward_back_move_start_turn_event(context)
    if opposite_forward_back_event then
        return opposite_forward_back_event
    end

    local twist_angle = resolve_number(context.twist_angle, -resolve_number(context.turn_angle, 0.0))
    if context.input_strength <= 0.05
        or math.abs(twist_angle) <= Constants.QUICK_TURN_MOVE_START_ANGLE then
        return nil
    end
    if self and env(self, 3036, Constants.SP_EF_REF_TAE_GROUND_QUICK_TURN) then
        return nil
    end
    return select_move_start_turn_event_by_angle(-twist_angle)
end

local function select_move_loop_quick_turn_event(self, context)
    local runtime = ensure_runtime(self)
    if context
        and Wasd90.is_cardinal_move_direction(context.target_direction)
        and context.target_direction == context.facing_direction then
        return nil
    end
    if runtime.input
        and (runtime.input.suppress_move_until_input_released
            or runtime.time < resolve_number(runtime.input.quick_turn_90_suppress_until, 0.0)) then
        return nil
    end
    if runtime.time < resolve_number(runtime.turn.move_stop_restart_quick_turn_suppress_until, 0.0) then
        return nil
    end
    if is_forward_diagonal_move_input(context) then
        return nil
    end

    local opposite_forward_back_event = select_opposite_forward_back_move_loop_turn_event(context)
    if opposite_forward_back_event then
        return opposite_forward_back_event
    end

    local turn_angle = resolve_number(context.turn_angle, resolve_number(context.move_angle, 0.0))
    if context.input_strength <= 0.05
        or math.abs(turn_angle) <= Constants.STAND_MOVE_QUICK_TURN_ANGLE then
        return nil
    end

    if runtime.time < resolve_number(runtime.turn.next_move_quick_turn_time, 0.0) then
        return nil
    end

    if env(self, 3036, Constants.SP_EF_REF_TAE_GROUND_QUICK_TURN) then
        return nil
    end

    local tae_gate_open = env(self, 3036, Constants.SP_EF_REF_TAE_ENABLE_GROUND_QUICK_TURN)
    local simulated_gate_open = context.elapsed >= Constants.STAND_MOVE_QUICK_TURN_GATE_DELAY
    if not tae_gate_open and not simulated_gate_open then
        return nil
    end

    return select_move_loop_turn_event_by_angle(turn_angle)
end

function get_quick_turn_spec(self, state_id, direction_id)
    local runtime = ensure_runtime(self)
    if runtime.turn.active and runtime.turn.event_key and runtime.turn.event_key ~= "" then
        local active_spec = EventSpecs.SimpleMovementEvents[runtime.turn.event_key]
        if active_spec then
            return active_spec
        end
    end

    local is_left = direction_id == Constants.MOVE_DIRECTION_LEFT
        or direction_id == Constants.MOVE_DIRECTION_FORWARD_LEFT
        or direction_id == Constants.MOVE_DIRECTION_BACK_LEFT
    if state_id == Constants.BASE_STATE_QUICK_TURN_90 then
        return is_left
            and EventSpecs.SimpleMovementEvents.BaseQuickTurnLeft90
            or EventSpecs.SimpleMovementEvents.BaseQuickTurnRight90
    end
    if state_id == Constants.BASE_STATE_QUICK_TURN_180 then
        return is_left
            and EventSpecs.SimpleMovementEvents.BaseQuickTurnLeft180
            or EventSpecs.SimpleMovementEvents.BaseQuickTurnRight180
    end
    if state_id == Constants.BASE_STATE_QUICK_TURN_MOVE_START_180 then
        return is_left
            and EventSpecs.SimpleMovementEvents.BaseQuickTurnMoveStartLeft180
            or EventSpecs.SimpleMovementEvents.BaseQuickTurnMoveStartRight180
    end
    if state_id == Constants.BASE_STATE_MOVE_QUICK_TURN_180 then
        return is_left
            and EventSpecs.SimpleMovementEvents.BaseMoveQuickTurnLeft180
            or EventSpecs.SimpleMovementEvents.BaseMoveQuickTurnRight180
    end
    return nil
end

local function get_quick_turn_duration(self, spec)
    if not spec then
        return 0.0
    end

    local duration = math.max(resolve_number(spec.duration, 0.0), 0.0)
    if duration > 0.0 then
        return duration
    end

    if spec.anim_asset and self.GetAnimSequenceLengthByPath then
        return math.max(resolve_number(self:GetAnimSequenceLengthByPath(spec.anim_asset), 0.0), 0.0)
    end

    return 0.0
end

function get_quick_turn_exit_time(self, spec)
    if not spec then
        return 0.0
    end

    local duration = get_quick_turn_duration(self, spec)
    local exit_time = resolve_number(spec.exit_time, 0.0)
    if exit_time > 0.0 then
        if duration > 0.0 then
            return math.min(exit_time, duration)
        end
        return exit_time
    end

    return duration
end

local function sync_quick_turn_yaw(self, context, spec)
    local runtime = ensure_runtime(self)
    local total_yaw = resolve_number(spec and spec.yaw_delta, 0.0)
    if math.abs(total_yaw) <= 0.0 then
        runtime.turn.applied_yaw_delta = 0.0
        return
    end
    if math.abs(resolve_number(runtime.turn.applied_yaw_delta, 0.0) - total_yaw) <= 0.01 then
        return
    end

    local duration = get_quick_turn_duration(self, spec)
    local target_yaw = total_yaw
    if duration > 0.0 then
        local progress = resolve_number(context.elapsed, 0.0) / duration
        local turn_progress = remap_range_clamped(
            progress,
            spec.turn_window_start,
            spec.turn_window_end
        )
        target_yaw = total_yaw * smooth_step(turn_progress)
    end

    local applied_yaw = resolve_number(runtime.turn.applied_yaw_delta, 0.0)
    local delta_yaw = target_yaw - applied_yaw
    if apply_preview_facing_yaw(self, delta_yaw) then
        sync_polled_input(self)
    end
    runtime.turn.applied_yaw_delta = target_yaw
end

local function complete_quick_turn_yaw(self, spec)
    local runtime = ensure_runtime(self)
    local total_yaw = resolve_number(spec and spec.yaw_delta, 0.0)
    if math.abs(total_yaw) <= 0.0 then
        return
    end

    local applied_yaw = resolve_number(runtime.turn.applied_yaw_delta, 0.0)
    local remaining_yaw = total_yaw - applied_yaw
    if math.abs(remaining_yaw) <= 0.01 then
        runtime.turn.applied_yaw_delta = total_yaw
        return
    end

    if apply_preview_facing_yaw(self, remaining_yaw) then
        sync_polled_input(self)
    end
    runtime.turn.applied_yaw_delta = total_yaw
end

function M.BuildCompletedQuickTurnExitContext(self, context)
    local runtime = ensure_runtime(self)
    local exit_context = read_context(self, context.delta_seconds)
    local target_direction = runtime.turn and runtime.turn.target_direction or Constants.MOVE_DIRECTION_NONE
    if not Wasd90.is_cardinal_move_direction(target_direction) then
        return exit_context
    end
    if Wasd90.is_cardinal_move_direction(exit_context.target_direction)
        and exit_context.target_direction ~= target_direction then
        return exit_context
    end

    -- WASD is an absolute target. Once the turn reaches that target, the next
    -- locomotion state must start as forward-relative movement, not with the
    -- stale pre-turn relative input that can still be cached for one frame.
    runtime.facing = runtime.facing or {}
    runtime.facing.direction = target_direction
    runtime.input.direction = Constants.MOVE_DIRECTION_FORWARD
    runtime.input.move_angle = 0.0
    runtime.input.turn_angle = 0.0
    runtime.input.twist_angle = 0.0

    exit_context.direction = Constants.MOVE_DIRECTION_FORWARD
    exit_context.move_angle = 0.0
    exit_context.turn_angle = 0.0
    exit_context.twist_angle = 0.0
    exit_context.facing_direction = target_direction
    exit_context.target_direction = target_direction
    return exit_context
end

local function finish_quick_turn(self, context)
    local runtime = ensure_runtime(self)
    local spec = get_quick_turn_spec(self, context.current_state, context.current_direction)
    if not spec then
        return nil
    end

    sync_quick_turn_yaw(self, context, spec)

    if context.elapsed < get_quick_turn_exit_time(self, spec) then
        return nil
    end

    -- Some Sekiro turn clips can blend out before our simulated yaw window
    -- has reached 100%. Complete the actor yaw before returning to normal
    -- MoveLoop, otherwise A/D input becomes a diagonal-forward walk.
    complete_quick_turn_yaw(self, spec)

    local turn_source = runtime.turn.source or spec.turn_source or ""
    local next_event = "BaseIdle"
    local exit_policy = runtime.turn.exit_policy or spec.exit_policy or ""
    if exit_policy == "quick_turn_180" and spec.next_event then
        next_event = spec.next_event
    elseif exit_policy == "idle" then
        next_event = "BaseIdle"
    elseif turn_source == "ground" then
        runtime.turn.ground_quick_turn_suppress_until =
            runtime.time + Constants.GROUND_QUICK_TURN_REENTRY_SUPPRESS_TIME
        if context.has_move_input then
            next_event = "BaseMoveStart"
        end
    elseif exit_policy == "move_loop" then
        next_event = "BaseMoveLoop"
        if not context.has_move_input then
            next_event = "BaseMoveStop"
        end
    elseif context.has_move_input then
        next_event = "BaseMoveStart"
    end

    if turn_source == "move_loop" then
        runtime.turn.next_move_quick_turn_time = runtime.time + Constants.STAND_MOVE_QUICK_TURN_COOLDOWN
    end
    local exit_context = context
    if exit_policy ~= "quick_turn_180" then
        exit_context = M.BuildCompletedQuickTurnExitContext(self, context)
    end
    clear_turn_runtime(runtime)

    return activate_event(self, next_event, exit_context)
end

local function select_quick_turn_reentry_event(self, context)
    local runtime = ensure_runtime(self)
    local active_event = runtime.turn.event_key or ""
    if active_event == ""
        or not context.has_move_input
        or context.canceled_move_input
        or runtime.time < resolve_number(runtime.turn.quick_turn_reentry_block_until, 0.0) then
        return nil
    end
    if Wasd90.is_cardinal_move_direction(runtime.turn.target_direction)
        and runtime.turn.target_direction == context.target_direction then
        return nil
    end

    local next_event = nil
    if context.current_state == Constants.BASE_STATE_MOVE_QUICK_TURN_180 then
        local turn_angle = resolve_number(context.turn_angle, resolve_number(context.move_angle, 0.0))
        if math.abs(turn_angle) > Constants.STAND_MOVE_QUICK_TURN_ANGLE then
            next_event = select_move_loop_turn_event_by_angle(turn_angle)
        end
    elseif context.current_state == Constants.BASE_STATE_QUICK_TURN_MOVE_START_180 then
        -- HKX keeps StandQuickTurnMoveStart*180 in the same state until its
        -- 815/816 next-state event sends it to StandMoveLoop. Direction changes
        -- during the clip are handled by the state's internal selector, so do
        -- not re-enter the opposite UE quick-turn state mid-clip.
        return nil
    elseif context.current_state == Constants.BASE_STATE_QUICK_TURN_180 then
        local turn_angle = resolve_number(context.turn_angle, resolve_number(context.move_angle, 0.0))
        local twist_angle = -resolve_number(context.twist_angle, -turn_angle)
        local signed_turn = math.abs(twist_angle) > math.abs(turn_angle) and twist_angle or turn_angle
        if math.abs(signed_turn) > Constants.GROUND_QUICK_TURN_180_ANGLE then
            next_event = select_ground_turn_event_by_angle(signed_turn)
        end
    end

    if next_event and next_event ~= active_event then
        return next_event
    end
    return nil
end

local function select_lsmove_queued_exit_event(self, context)
    if not context.wants_move then
        return nil
    end

    local runtime = ensure_runtime(self)
    ensure_quick_turn_to_loop_notify(self, context)
    if not has_movement_anim_event(runtime, MOVEMENT_EVENT_LS_MOVE_QUEUED) then
        return nil
    end

    if context.current_state == Constants.BASE_STATE_MOVE_QUICK_TURN_180
        or context.current_state == Constants.BASE_STATE_QUICK_TURN_MOVE_START_180 then
        if not context.has_move_input then
            return nil
        end
        return "BaseMoveLoop"
    end
    if context.current_state == Constants.BASE_STATE_QUICK_TURN_90
        or context.current_state == Constants.BASE_STATE_QUICK_TURN_180
        or (context.current_state == Constants.BASE_STATE_MOVE_STOP
            and math.abs(resolve_number(context.turn_angle, resolve_number(context.move_angle, 0.0))) <= MOVE_INPUT_FACE_DEAD_ANGLE) then
        return "BaseMoveStart"
    end

    return nil
end

local function activate_idle_quick_turn_prelude_exit(self, context)
    local runtime = ensure_runtime(self)
    local next_event = runtime.turn and runtime.turn.next_event
    if not runtime.turn
        or runtime.turn.exit_policy ~= "quick_turn_180"
        or not next_event then
        return nil
    end

    clear_turn_runtime(runtime)
    return activate_event(self, next_event, context)
end

local function activate_chained_state_exit(self, context)
    local runtime = ensure_runtime(self)
    if not runtime.chain or not runtime.chain.active or not runtime.chain.next_event then
        return nil
    end
    if resolve_number(context.elapsed, 0.0) < resolve_number(runtime.chain.exit_time, 0.0) then
        return nil
    end

    local next_event = runtime.chain.next_event
    clear_chain_runtime(runtime)
    clear_ground_attack_runtime(runtime)
    return activate_event(self, next_event, context)
end

local BaseValidateByState = {
    [Constants.BASE_STATE_IDLE] = function(self, context)
        if context.wants_move then
            local quick_turn_event = select_idle_move_input_turn_event(self, context)
            if quick_turn_event then
                return quick_turn_event
            end
            return "BaseMoveStart"
        end
        local quick_turn_event = select_ground_quick_turn_event(self, context)
        if quick_turn_event then
            return quick_turn_event
        end
        return nil
    end,

    [Constants.BASE_STATE_MOVE_START] = function(self, context)
        local runtime = ensure_runtime(self)
        local opposite_forward_back_event = select_opposite_forward_back_move_start_turn_event(context)
        if opposite_forward_back_event then
            clear_chain_runtime(runtime)
            return opposite_forward_back_event
        end
        local chained_exit = activate_chained_state_exit(self, context)
        if chained_exit then
            return chained_exit
        end
        if runtime.chain and runtime.chain.active then
            return nil
        end
        local forward_left_to_back_chain = select_forward_diagonal_to_back_stop_turn_event(context)
        if forward_left_to_back_chain then
            return forward_left_to_back_chain
        end
        local diagonal_bridge = Wasd90.select_wasd_90_bridge_event(context)
        if diagonal_bridge then
            return diagonal_bridge
        end
        if not context.wants_move then
            return "BaseMoveStop"
        end
        local move_loop_time = get_move_start_loop_transition_time(context)
        if ensure_move_start_to_loop_notify(self, context) then
            return "BaseMoveLoop"
        end
        if context.elapsed >= move_loop_time - get_move_start_to_loop_event_lead(context) then
            return "BaseMoveLoop"
        end
        if has_movement_anim_event(runtime, MOVEMENT_EVENT_MOVE_START_TO_LOOP)
            and context.elapsed >= move_loop_time - get_move_start_to_loop_notify_lead(context) then
            return "BaseMoveLoop"
        end
        if context.elapsed >= MOVE_START_QUICK_TURN_GATE_SECONDS then
            local quick_turn_event = select_move_start_quick_turn_event(self, context)
            if quick_turn_event then
                return quick_turn_event
            end
        end
        return nil
    end,

    [Constants.BASE_STATE_MOVE_LOOP] = function(self, context)
        local opposite_forward_back_event = select_opposite_forward_back_move_loop_turn_event(context)
        if opposite_forward_back_event then
            return opposite_forward_back_event
        end
        local forward_left_to_back_chain = select_forward_diagonal_to_back_stop_turn_event(context)
        if forward_left_to_back_chain then
            return forward_left_to_back_chain
        end
        local diagonal_bridge = Wasd90.select_wasd_90_bridge_event(context)
        if diagonal_bridge then
            return diagonal_bridge
        end
        if not context.wants_move then
            return "BaseMoveStop"
        end
        local quick_turn_event = select_move_loop_quick_turn_event(self, context)
        if quick_turn_event then
            return quick_turn_event
        end
        return nil
    end,

    [Constants.BASE_STATE_MOVE_STOP] = function(self, context)
        local runtime = ensure_runtime(self)
        local opposite_forward_back_event = select_opposite_forward_back_idle_turn_event(context)
        if opposite_forward_back_event then
            clear_chain_runtime(runtime)
            return opposite_forward_back_event
        end
        local chained_exit = activate_chained_state_exit(self, context)
        if chained_exit then
            return chained_exit
        end
        if runtime.chain and runtime.chain.active then
            return nil
        end
        local forward_left_to_back_chain = select_forward_diagonal_to_back_stop_turn_event(context)
        if forward_left_to_back_chain then
            return forward_left_to_back_chain
        end
        if context.wants_move then
            local quick_turn_event = select_idle_move_input_turn_event(self, context)
            if quick_turn_event then
                return quick_turn_event
            end
        end
        local lsmove_exit_event = select_lsmove_queued_exit_event(self, context)
        if lsmove_exit_event then
            return lsmove_exit_event
        end
        if context.wants_move then
            runtime.turn.move_stop_restart_quick_turn_suppress_until =
                runtime.time + MOVE_STOP_RESTART_QUICK_TURN_SUPPRESS_SECONDS
            return "BaseMoveStart"
        end
        if context.elapsed >= get_move_stop_exit_time(context) then
            return "BaseIdle"
        end
        return nil
    end,

    [Constants.BASE_STATE_QUICK_TURN_90] = function(self, context)
        local lsmove_exit_event = select_lsmove_queued_exit_event(self, context)
        if lsmove_exit_event then
            return lsmove_exit_event
        end
        return finish_quick_turn(self, context)
    end,

    [Constants.BASE_STATE_QUICK_TURN_180] = function(self, context)
        local lsmove_exit_event = select_lsmove_queued_exit_event(self, context)
        if lsmove_exit_event then
            return lsmove_exit_event
        end
        local reentry_event = select_quick_turn_reentry_event(self, context)
        if reentry_event then
            return activate_event(self, reentry_event, context)
        end
        return finish_quick_turn(self, context)
    end,

    [Constants.BASE_STATE_QUICK_TURN_MOVE_START_180] = function(self, context)
        local prelude_exit = activate_idle_quick_turn_prelude_exit(self, context)
        if prelude_exit then
            return prelude_exit
        end
        local lsmove_exit_event = select_lsmove_queued_exit_event(self, context)
        if lsmove_exit_event then
            return lsmove_exit_event
        end
        local reentry_event = select_quick_turn_reentry_event(self, context)
        if reentry_event then
            return activate_event(self, reentry_event, context)
        end
        return finish_quick_turn(self, context)
    end,

    [Constants.BASE_STATE_MOVE_QUICK_TURN_180] = function(self, context)
        local runtime = ensure_runtime(self)
        if is_opposite_forward_back_turn90_guard_active(context)
            and runtime.chain
            and runtime.chain.active
            and is_turn90_event_key(runtime.chain.next_event) then
            clear_chain_runtime(runtime)
            return "BaseMoveLoop"
        end
        local chained_exit = activate_chained_state_exit(self, context)
        if chained_exit then
            return chained_exit
        end
        if runtime.chain and runtime.chain.active then
            return nil
        end
        local lsmove_exit_event = select_lsmove_queued_exit_event(self, context)
        if lsmove_exit_event then
            return lsmove_exit_event
        end
        local reentry_event = select_quick_turn_reentry_event(self, context)
        if reentry_event then
            return activate_event(self, reentry_event, context)
        end
        return finish_quick_turn(self, context)
    end,
}

local function validate_base_layer(self, context)
    local runtime = ensure_runtime(self)
    local action_state = get_layer_runtime(runtime, Constants.LAYER_ACTION).state
    if is_ground_attack_action_state(action_state) then
        runtime.turn.active = false
        runtime.turn.applied_yaw_delta = 0.0
        runtime.turn.next_move_quick_turn_time = runtime.time + QUICK_TURN_REENTRY_DEBOUNCE_SECONDS
        local base_layer = get_layer_runtime(runtime, Constants.LAYER_BASE)
        if is_quick_turn_state(context.current_state) or is_quick_turn_state(base_layer.state) then
            base_layer.previous_state = base_layer.state
            base_layer.previous_direction = base_layer.direction
            base_layer.state = Constants.BASE_STATE_IDLE
            base_layer.direction = Constants.MOVE_DIRECTION_NONE
            base_layer.event = "W_BaseIdle"
            base_layer.state_name = "Idle"
            base_layer.applied_yaw_delta = 0.0
            base_layer.turn_angle = 0.0
            base_layer.elapsed = 0.0
            base_layer.entered_at = runtime.time

            local state_machine = get_state_machine(self)
            if state_machine and state_machine.SetLayerState then
                state_machine:SetLayerState(
                    Constants.LAYER_BASE,
                    base_layer.state,
                    base_layer.state_name,
                    base_layer.event,
                    base_layer.direction
                )
            end
        end
        return true
    end
    if is_ground_attack_end_base_settle_active(runtime) then
        local base_layer = get_layer_runtime(runtime, Constants.LAYER_BASE)
        if is_quick_turn_state(context.current_state) or is_quick_turn_state(base_layer.state) then
            base_layer.previous_state = base_layer.state
            base_layer.previous_direction = base_layer.direction
            base_layer.state = Constants.BASE_STATE_IDLE
            base_layer.direction = Constants.MOVE_DIRECTION_NONE
            base_layer.event = "W_BaseIdle"
            base_layer.state_name = "Idle"
            base_layer.applied_yaw_delta = 0.0
            base_layer.turn_angle = 0.0
            base_layer.elapsed = 0.0
            base_layer.entered_at = runtime.time

            local state_machine = get_state_machine(self)
            if state_machine and state_machine.SetLayerState then
                state_machine:SetLayerState(
                    Constants.LAYER_BASE,
                    base_layer.state,
                    base_layer.state_name,
                    base_layer.event,
                    base_layer.direction
                )
            end
        end
        return true
    end

    local validator = BaseValidateByState[context.current_state]
    if runtime.chain and runtime.chain.active then
        if validator then
            return validator(self, context)
        end
    end
    if is_quick_turn_state(context.current_state) and validator then
        return validator(self, context)
    end
    local wasd_90_bridge = Wasd90.select_wasd_90_bridge_event(context)
    if wasd_90_bridge then
        return wasd_90_bridge
    end
    local wasd_180_event = Wasd90.select_cardinal_180_event(
        context,
        M.QuickTurnVariant("BaseIdleQuickTurnLeft180Prelude", "BaseIdleQuickTurnRight180Prelude"),
        M.QuickTurnVariant("BaseQuickTurnMoveStartLeft180", "BaseQuickTurnMoveStartRight180"),
        M.QuickTurnVariant("BaseMoveQuickTurnLeft180", "BaseMoveQuickTurnRight180")
    )
    if wasd_180_event then
        return wasd_180_event
    end

    local original_driver = require("Sekiro.C0000.OriginalMovementDriver")
    original_driver.sync_context(self, context)
    local query = get_env_query(self)
    original_driver.apply_env_overrides_to_query(self, query)
    local original_event = original_driver.decide_base_event(
        self,
        context,
        function(id, subkey)
            return env(self, id, subkey)
        end
    )
    if original_event
        and is_quick_turn_event_key(original_event)
        and not is_quick_turn_angle_valid(original_event, context) then
        original_event = nil
    elseif original_driver.was_last_event_handled(self) then
        return true
    end
    if original_event then
        return original_event
    end

    if not validator then
        return "BaseIdle"
    end
    return validator(self, context)
end

local function select_add_event_spec(event_table, variants_by_event, event_name, wants_move)
    if not event_name or event_name == "" then
        return nil
    end

    local variants = variants_by_event[event_name]
    if not variants then
        return nil
    end

    if variants.force_idle then
        wants_move = false
    end

    local preferred_key = wants_move and variants.move or variants.idle
    local fallback_key = wants_move and variants.idle or variants.move
    return event_table[preferred_key] or event_table[fallback_key]
end

function M:IsLeftWaistDrawActionActive(runtime)
    if runtime.time < resolve_number(runtime.left_waist_draw_move_lock_until, 0.0) then
        return true
    end

    runtime.left_waist_draw_move_lock_until = 0.0
    return false
end

function M:SuppressLeftWaistDrawMoveContext(runtime, context)
    if not M.IsLeftWaistDrawActionActive(self, runtime) then
        return context
    end

    context.wants_move = false
    context.has_move_input = false
    context.input_strength = 0.0
    context.forward = 0
    context.right = 0
    context.sprint = false
    return context
end

local function find_add_spec_by_state(event_table, state_id)
    for _, spec in pairs(event_table) do
        if spec.to_state == state_id then
            return spec
        end
    end
    return nil
end

local function select_ground_attack_followup_spec(self, event_table, event_name, action_state, elapsed)
    if not event_name or event_name == "" then
        return nil
    end

    local transitions = GroundAttackInputTransitions[action_state]
    local transition = transitions and transitions[event_name] or nil
    if type(transition) == "table" then
        local current_elapsed = resolve_number(elapsed, 0.0)
        local min_elapsed = transition.min_elapsed or 0.0
        local max_elapsed = transition.max_elapsed or math.huge
        if current_elapsed < min_elapsed or current_elapsed > max_elapsed then
            return nil
        end
        if transition.behavior_ref_gate and not env(self, 3036, transition.behavior_ref_gate) then
            return nil
        end
        if transition.cancel_event_gate and not has_movement_anim_event(ensure_runtime(self), transition.cancel_event_gate) then
            return nil
        end
        return event_table[transition.spec]
    end

    local spec_key = transition
    return spec_key and event_table[spec_key] or nil
end

local function get_ground_attack_release_followup(self, event_table, event_name, action_layer)
    local runtime = ensure_runtime(self)
    runtime.ground_attack = runtime.ground_attack or {}
    local ground_attack = runtime.ground_attack
    local requested_event = event_name

    if event_name == "GroundAttackRelease" then
        ground_attack.pending_release = true
        ground_attack.pending_release_state = action_layer.state
    elseif event_name == "GroundAttack" then
        ground_attack.pending_attack = true
        ground_attack.pending_attack_state = action_layer.state
    elseif event_name and event_name ~= "" then
        ground_attack.pending_attack = false
        ground_attack.pending_attack_state = 0
        ground_attack.pending_release = false
        ground_attack.pending_release_state = 0
    elseif ground_attack.pending_release then
        if ground_attack.pending_release_state ~= action_layer.state then
            ground_attack.pending_release = false
            ground_attack.pending_release_state = 0
            return nil
        end
        requested_event = "GroundAttackRelease"
    elseif ground_attack.pending_attack then
        if ground_attack.pending_attack_state ~= action_layer.state then
            ground_attack.pending_attack = false
            ground_attack.pending_attack_state = 0
            return nil
        end
        requested_event = "GroundAttack"
    end

    local followup_spec = select_ground_attack_followup_spec(
        self,
        event_table,
        requested_event,
        action_layer.state,
        action_layer.elapsed
    )
    if followup_spec and requested_event == "GroundAttackRelease" then
        ground_attack.pending_release = false
        ground_attack.pending_release_state = 0
    elseif followup_spec and requested_event == "GroundAttack" then
        ground_attack.pending_attack = false
        ground_attack.pending_attack_state = 0
    end
    return followup_spec
end

local function is_ground_attack_input(event_name)
    return event_name == "GroundAttack" or event_name == "GroundAttackRelease"
end

local function wants_ground_attack_restart_after_action_end(runtime, event_name, action_layer)
    if event_name == "GroundAttack" then
        return true
    end

    local ground_attack = runtime and runtime.ground_attack or nil
    return ground_attack
        and ground_attack.pending_attack == true
        and ground_attack.pending_attack_state == action_layer.state
end

local function is_throw_active(self)
    if not self or not self.GetSekiroEnvQuery then
        return false
    end
    local ok, env_query = pcall(function()
        return self:GetSekiroEnvQuery()
    end)
    return ok and env_query and env_query.bThrowActive == true
end

function M:SetLeftWaistWeaponDrawn(runtime, is_drawn)
    runtime.weapon = runtime.weapon or {}
    local was_drawn = runtime.weapon.left_waist_drawn

    runtime.weapon.left_waist_drawn = is_drawn and true or false
    if was_drawn ~= runtime.weapon.left_waist_drawn and self.SetMortalBladeDrawn then
        pcall(function()
            self:SetMortalBladeDrawn(runtime.weapon.left_waist_drawn)
        end)
    end

    if self.LeftHandScabbard and self.LeftHandScabbard.SetStaticMesh and UE.UObject then
        runtime.weapon_assets = runtime.weapon_assets or {}
        local key = is_drawn and "left_waist_drawn" or "left_waist_sheathed"
        if runtime.weapon_assets[key] == nil then
            local path = is_drawn
                and "/Game/Animation/Sekiro/C0000/Weapons/SM_WP_A_0310_MortalBlade_DrawBlade.SM_WP_A_0310_MortalBlade_DrawBlade"
                or "/Game/Animation/Sekiro/C0000/Weapons/SM_WP_A_0310_MortalBlade.SM_WP_A_0310_MortalBlade"
            runtime.weapon_assets[key] = UE.UObject.Load(path)
        end
        if runtime.weapon_assets[key] then
            self.LeftHandScabbard:SetStaticMesh(runtime.weapon_assets[key])
        end
        self.LeftHandScabbard:SetVisibility(true, true)
        self.LeftHandScabbard:SetHiddenInGame(false, true)
    end
end

function M:SetRightHandMortalBladeVisible(visible)
    if self.SetMortalBladeRightHandVisible then
        pcall(function()
            self:SetMortalBladeRightHandVisible(visible and true or false)
        end)
    end

    if not self.RightHandDrawBlade then
        return
    end
    if visible and self.RightHandDrawBlade.SetStaticMesh and UE.UObject then
        local runtime = ensure_runtime(self)
        runtime.weapon_assets = runtime.weapon_assets or {}
        if runtime.weapon_assets.right_hand == nil then
            runtime.weapon_assets.right_hand = UE.UObject.Load(
                "/Game/Animation/Sekiro/C0000/Weapons/SM_WP_A_0310_MortalBlade_Sheathed.SM_WP_A_0310_MortalBlade_Sheathed")
        end
        if runtime.weapon_assets.right_hand then
            self.RightHandDrawBlade:SetStaticMesh(runtime.weapon_assets.right_hand)
        end
    end
    self.RightHandDrawBlade:SetVisibility(visible and true or false, true)
    self.RightHandDrawBlade:SetHiddenInGame(not visible, true)
end

function M:SetRightHandMortalBladeDrawRotationAlpha(alpha)
    if not self.RightHandDrawBlade then
        return
    end

    local rotation = UE.FRotator(0.0, 180.0, 0.0)
    local ok = pcall(function()
        self.RightHandDrawBlade:SetRelativeRotation(rotation)
    end)
    if not ok then
        pcall(function()
            self.RightHandDrawBlade:K2_SetRelativeRotation(rotation, false, nil, false)
        end)
    end
end

function M:SetRightHandMortalBladeDrawAlignment(aligned)
    self:SetRightHandMortalBladeDrawRotationAlpha(aligned and 0.0 or 1.0)
end

function M:IsMortalBladeCurrentlyDrawn(runtime)
    if self.IsMortalBladeDrawn then
        return self:IsMortalBladeDrawn()
    end
    return runtime.weapon and runtime.weapon.left_waist_drawn or false
end

function M:GetVectorComponent(value, upper_name, lower_name)
    if not value then
        return 0.0
    end

    local ok, component = pcall(function()
        return value[upper_name]
    end)
    if ok and component ~= nil then
        return resolve_number(component, 0.0)
    end

    ok, component = pcall(function()
        return value[lower_name]
    end)
    if ok then
        return resolve_number(component, 0.0)
    end
    return 0.0
end

function M:GetVectorDistanceSquared(a, b)
    local dx = self:GetVectorComponent(a, "X", "x") - self:GetVectorComponent(b, "X", "x")
    local dy = self:GetVectorComponent(a, "Y", "y") - self:GetVectorComponent(b, "Y", "y")
    local dz = self:GetVectorComponent(a, "Z", "z") - self:GetVectorComponent(b, "Z", "z")
    return dx * dx + dy * dy + dz * dz
end

function M:GetSignedHorizontalAngleToLocation(location)
    if not location or not self.GetActorForwardVector then
        return nil
    end

    local self_location = self:GetActorLocationSafe(self)
    if not self_location then
        return nil
    end

    local forward = self:GetActorForwardVector()
    local forward_x = self:GetVectorComponent(forward, "X", "x")
    local forward_y = self:GetVectorComponent(forward, "Y", "y")
    local to_target_x = self:GetVectorComponent(location, "X", "x")
        - self:GetVectorComponent(self_location, "X", "x")
    local to_target_y = self:GetVectorComponent(location, "Y", "y")
        - self:GetVectorComponent(self_location, "Y", "y")

    local target_length_sq = to_target_x * to_target_x + to_target_y * to_target_y
    local forward_length_sq = forward_x * forward_x + forward_y * forward_y
    if target_length_sq <= 0.0001 or forward_length_sq <= 0.0001 then
        return nil
    end

    local target_length = math.sqrt(target_length_sq)
    local forward_length = math.sqrt(forward_length_sq)
    local dot = (forward_x * to_target_x + forward_y * to_target_y) / (forward_length * target_length)
    local cross_z = (forward_x * to_target_y - forward_y * to_target_x) / (forward_length * target_length)
    dot = math.max(math.min(dot, 1.0), -1.0)
    local signed_angle_rad = math.acos(dot)
    if cross_z < 0.0 then
        signed_angle_rad = -signed_angle_rad
    end
    return math.deg(signed_angle_rad)
end

function M:GetActorLocationSafe(actor)
    if not actor then
        return nil
    end

    local ok, location = pcall(function()
        return actor:K2_GetActorLocation()
    end)
    if ok then
        return location
    end
    return nil
end

function M:ArrayLikeToTable(values)
    if not values then
        return nil
    end
    if type(values) == "table" then
        return values
    end

    local ok, result = pcall(function()
        return values:ToTable()
    end)
    if ok and type(result) == "table" then
        return result
    end

    ok, result = pcall(function()
        local count = values:Num()
        local items = {}
        for index = 1, count do
            items[#items + 1] = values:Get(index)
        end
        return items
    end)
    if ok and type(result) == "table" then
        return result
    end

    ok, result = pcall(function()
        local count = values:Num()
        local items = {}
        for index = 0, count - 1 do
            items[#items + 1] = values:Get(index)
        end
        return items
    end)
    if ok and type(result) == "table" then
        return result
    end

    return nil
end

function M:GetWorldActorsTable()
    local world_ok, world = pcall(function()
        return self:GetWorld()
    end)
    if not world_ok or not world then
        return nil
    end

    local level = world and world.PersistentLevel
    local actors = level and level.Actors
    if not actors then
        return nil
    end

    return self:ArrayLikeToTable(actors)
end

function M:GetEnemyActorsByGameplayStatics()
    if not UE or not UE.UGameplayStatics then
        return nil
    end

    local runtime = ensure_runtime(self)
    runtime.enemy_auto_draw_gs = runtime.enemy_auto_draw_gs or {}

    local function try_get_all_actors_of_class(class_value)
        if not class_value or not UE.TArray or not UE.AActor then
            return nil
        end
        local ok, actors = pcall(function()
            local out_actors = UE.TArray(UE.AActor)
            local returned_actors = UE.UGameplayStatics.GetAllActorsOfClass(self, class_value, out_actors)
            return returned_actors or out_actors
        end)
        if not ok then
            return nil
        end
        local actor_table = self:ArrayLikeToTable(actors)
        if actor_table and #actor_table > 0 then
            return actor_table
        end

        ok, actors = pcall(function()
            return UE.UGameplayStatics.GetAllActorsOfClass(self, class_value)
        end)
        if ok then
            return self:ArrayLikeToTable(actors)
        end
        return nil
    end

    if not runtime.enemy_auto_draw_gs.enemy_class_failed then
        local actor_table = nil
        local ok, enemy_class = pcall(function()
            return UE.ASekiroEnemyCharacter and UE.ASekiroEnemyCharacter.StaticClass()
        end)
        if ok then
            actor_table = try_get_all_actors_of_class(enemy_class)
        end
        if actor_table and #actor_table > 0 then
            return actor_table, true
        end

        ok, enemy_class = pcall(function()
            return UE.UClass.Load("/Game/Animation/Sekiro/Enemy/C1010/Blueprints/BP_Sekiro_Enemy_C1010.BP_Sekiro_Enemy_C1010_C")
        end)
        if ok then
            actor_table = try_get_all_actors_of_class(enemy_class)
        end
        if actor_table and #actor_table > 0 then
            return actor_table, true
        end

        runtime.enemy_auto_draw_gs.enemy_class_failed = true
    end

    if UE.TArray and UE.AActor and not runtime.enemy_auto_draw_gs.context_tag_out_failed then
        local ok, actors = pcall(function()
            local out_actors = UE.TArray(UE.AActor)
            local returned_actors = UE.UGameplayStatics.GetAllActorsWithTag(self, "Enemy", out_actors)
            return returned_actors or out_actors
        end)
        if not ok then
            runtime.enemy_auto_draw_gs.context_tag_out_failed = true
        else
            local actor_table = self:ArrayLikeToTable(actors)
            if actor_table and #actor_table > 0 then
                return actor_table, true
            end
        end
    end

    if UE.TArray and UE.AActor and not runtime.enemy_auto_draw_gs.world_tag_out_failed then
        local ok, actors = pcall(function()
            local out_actors = UE.TArray(UE.AActor)
            local returned_actors = UE.UGameplayStatics.GetAllActorsWithTag(self:GetWorld(), "Enemy", out_actors)
            return returned_actors or out_actors
        end)
        if not ok then
            runtime.enemy_auto_draw_gs.world_tag_out_failed = true
        else
            local actor_table = self:ArrayLikeToTable(actors)
            if actor_table and #actor_table > 0 then
                return actor_table, true
            end
        end
    end

    if not runtime.enemy_auto_draw_gs.tag_only_failed then
        local ok, actors = pcall(function()
            return UE.UGameplayStatics.GetAllActorsWithTag("Enemy")
        end)
        if not ok then
            runtime.enemy_auto_draw_gs.tag_only_failed = true
        else
            local actor_table = self:ArrayLikeToTable(actors)
            if actor_table and #actor_table > 0 then
                return actor_table, true
            end
        end
    end

    if not runtime.enemy_auto_draw_gs.context_tag_failed then
        local ok, actors = pcall(function()
            return UE.UGameplayStatics.GetAllActorsWithTag(self, "Enemy")
        end)
        if not ok then
            runtime.enemy_auto_draw_gs.context_tag_failed = true
        else
            local actor_table = self:ArrayLikeToTable(actors)
            if actor_table and #actor_table > 0 then
                return actor_table, true
            end
        end
    end

    return nil
end

function M:ActorHasEnemyTag(actor)
    if not actor then
        return false
    end

    local ok, has_tag = pcall(function()
        return actor:ActorHasTag("Enemy")
    end)
    if ok and has_tag then
        return true
    end

    local tags = actor.Tags
    if tags and type(tags) ~= "table" then
        local ok, tag_table = pcall(function()
            return tags:ToTable()
        end)
        if ok then
            tags = tag_table
        end
    end
    if type(tags) == "table" then
        for _, tag in pairs(tags) do
            if tostring(tag) == "Enemy" then
                return true
            end
        end
    end
    local ok_name, actor_name = pcall(function()
        return actor:GetName()
    end)
    if ok_name and type(actor_name) == "string" and string.find(actor_name, "Sekiro_Enemy", 1, true) then
        return true
    end
    local ok_class, class_name = pcall(function()
        local actor_class = actor:GetClass()
        return actor_class and actor_class:GetName() or nil
    end)
    if ok_class and type(class_name) == "string" and string.find(class_name, "SekiroEnemy", 1, true) then
        return true
    end
    return false
end

function M:GetEnemyCandidateActors()
    local candidates, tagged_are_enemies = self:GetEnemyActorsByGameplayStatics()
    candidates = candidates or {}

    local world_actors = self:GetWorldActorsTable()
    if world_actors then
        for _, actor in pairs(world_actors) do
            local exists = false
            for _, candidate in pairs(candidates) do
                if candidate == actor then
                    exists = true
                    break
                end
            end
            if not exists then
                candidates[#candidates + 1] = actor
            end
        end
    end

    if #candidates == 0 then
        return nil, false
    end
    return candidates, false
end

function M:FindNearestEnemyInRange(max_distance_cm)
    local actors, actors_are_enemies = self:GetEnemyCandidateActors()
    if not actors then
        return nil, nil
    end

    local self_location = self:GetActorLocationSafe(self)
    if not self_location then
        return nil, nil
    end

    max_distance_cm = math.max(resolve_number(max_distance_cm, GetEnemyAutoWeaponDistanceCm()), 0.0)
    local max_distance_sq = max_distance_cm * max_distance_cm
    local nearest_actor = nil
    local nearest_distance_sq = nil
    for _, actor in pairs(actors) do
        if actor and actor ~= self and (actors_are_enemies or self:ActorHasEnemyTag(actor)) then
            local actor_location = self:GetActorLocationSafe(actor)
            local distance_sq = actor_location and self:GetVectorDistanceSquared(self_location, actor_location) or nil
            if distance_sq
                and distance_sq <= max_distance_sq
                and (nearest_distance_sq == nil or distance_sq < nearest_distance_sq) then
                nearest_actor = actor
                nearest_distance_sq = distance_sq
            end
        end
    end

    return nearest_actor, nearest_distance_sq
end

function M:HasEnemyInAutoDrawRange(max_distance_cm)
    local runtime = ensure_runtime(self)

    if self.HasVisibleEnemyInAutoWeaponRange then
        local ok, has_enemy = pcall(function()
            return self:HasVisibleEnemyInAutoWeaponRange()
        end)
        if ok then
            return has_enemy == true
        end
    end

    local actors, actors_are_enemies = self:GetEnemyCandidateActors()
    if not actors then
        if runtime.time >= resolve_number(runtime.enemy_auto_draw_next_debug_time, 0.0) then
            runtime.enemy_auto_draw_next_debug_time = runtime.time + 1.0
            print_runtime(self, "Enemy auto draw: no actor table")
        end
        return false
    end

    local self_location = self:GetActorLocationSafe(self)
    if not self_location then
        if runtime.time >= resolve_number(runtime.enemy_auto_draw_next_debug_time, 0.0) then
            runtime.enemy_auto_draw_next_debug_time = runtime.time + 1.0
            print_runtime(self, "Enemy auto draw: no self location")
        end
        return false
    end

    max_distance_cm = math.max(resolve_number(max_distance_cm, GetEnemyAutoWeaponDistanceCm()), 0.0)
    local max_distance_sq = max_distance_cm * max_distance_cm
    local nearest_distance_sq = nil
    local enemy_count = 0
    for _, actor in pairs(actors) do
        if actor and actor ~= self and (actors_are_enemies or self:ActorHasEnemyTag(actor)) then
            enemy_count = enemy_count + 1
            local actor_location = self:GetActorLocationSafe(actor)
            local distance_sq = actor_location and self:GetVectorDistanceSquared(self_location, actor_location) or nil
            if distance_sq and (nearest_distance_sq == nil or distance_sq < nearest_distance_sq) then
                nearest_distance_sq = distance_sq
            end
            if distance_sq and distance_sq <= max_distance_sq then
                return true
            end
        end
    end
    if runtime.time >= resolve_number(runtime.enemy_auto_draw_next_debug_time, 0.0) then
        runtime.enemy_auto_draw_next_debug_time = runtime.time + 1.0
        local nearest_distance = nearest_distance_sq and math.sqrt(nearest_distance_sq) or -1.0
        print_runtime(
            self,
            string.format(
                "Enemy auto draw: enemies=%d nearest=%.1fcm threshold=%.1fcm",
                enemy_count,
                nearest_distance,
                max_distance_cm
            )
        )
    end
    return false
end

function M:SetAutoAimTargetValidSafe(valid)
    if self.SetPreviewAutoAimTargetValid then
        local ok = pcall(function()
            self:SetPreviewAutoAimTargetValid(valid == true)
        end)
        if ok then
            return
        end
    end

    if self.GetSekiroEnvQuery then
        pcall(function()
            local env_query = self:GetSekiroEnvQuery()
            if env_query then
                env_query.bAutoAimTargetValid = valid == true
            end
        end)
    end
end

function M:QueueOrTriggerLeftWaistDraw()
    local queued_ok = pcall(function()
        self:QueuePreviewActionEvent("ActionLeftWaistDraw")
    end)
    if queued_ok then
        return true
    end

    local triggered_ok, triggered = pcall(function()
        return self:TriggerSekiroEvent("ActionLeftWaistDraw")
    end)
    return triggered_ok and triggered
end

function M:QueueOrTriggerLeftWaistSheathe()
    local queued_ok = pcall(function()
        self:QueuePreviewActionEvent("ActionLeftWaistSheathe")
    end)
    if queued_ok then
        return true
    end

    local triggered_ok, triggered = pcall(function()
        return self:TriggerSekiroEvent("ActionLeftWaistSheathe")
    end)
    return triggered_ok and triggered
end

function M:UpdateEnemyAutoDraw(runtime)
    runtime.enemy_auto_draw = runtime.enemy_auto_draw or {}
    local auto_draw = runtime.enemy_auto_draw
    if is_throw_active(self) then
        auto_draw.draw_queued = false
        auto_draw.sheathe_queued = false
        return
    end

    local blade_drawn = self:IsMortalBladeCurrentlyDrawn(runtime)
    local auto_weapon_distance_cm = math.max(
        resolve_number(PreviewConfig.EnemyAutoWeaponDistanceCm, GetEnemyAutoWeaponDistanceCm()),
        0.0
    )
    local enemy_in_range = self:HasEnemyInAutoDrawRange(auto_weapon_distance_cm)
    self:SetAutoAimTargetValidSafe(enemy_in_range)

    if enemy_in_range then
        auto_draw.was_in_range = true
        auto_draw.sheathe_queued = false
        if blade_drawn then
            auto_draw.draw_queued = false
            return
        end

        if not auto_draw.draw_queued then
            auto_draw.draw_queued = self:QueueOrTriggerLeftWaistDraw()
            if auto_draw.draw_queued then
                print_runtime(self, "Enemy in range: queued ActionLeftWaistDraw")
            end
        end
        return
    end

    auto_draw.draw_queued = false
    if not blade_drawn then
        auto_draw.sheathe_queued = false
        auto_draw.was_in_range = false
        return
    end

    if not auto_draw.sheathe_queued then
        auto_draw.sheathe_queued = self:QueueOrTriggerLeftWaistSheathe()
        if auto_draw.sheathe_queued then
            auto_draw.was_in_range = false
            print_runtime(self, "Enemy left range: queued ActionLeftWaistSheathe")
        end
    end
end

function M:RequestOriginalNonCombatTransition(weapon_event)
    if weapon_event == "left_waist_draw" then
        return require("Sekiro.C0000.OriginalMovementDriver").queue_non_combat_transition(self, "leave")
    end
    if weapon_event == "left_waist_sheathe" then
        return require("Sekiro.C0000.OriginalMovementDriver").queue_non_combat_transition(self, "enter")
    end
    return false
end

function M:UpdateLeftWaistWeaponVisual()
    local runtime = ensure_runtime(self)
    local action_layer = get_layer_runtime(runtime, Constants.LAYER_ACTION)
    local active_spec = find_add_spec_by_state(EventSpecs.SimpleActionEvents, action_layer.state)
    if not active_spec or not active_spec.weapon_event then
        runtime.weapon = runtime.weapon or {}
        if runtime.weapon.right_hand_aligned_for_action then
            self:SetRightHandMortalBladeDrawAlignment(false)
        end
        runtime.weapon.pending_action_state = 0
        runtime.weapon.right_hand_shown_for_action = false
        runtime.weapon.right_hand_aligned_for_action = false
        return
    end

    runtime.weapon = runtime.weapon or {}
    if runtime.weapon.pending_action_state ~= action_layer.state then
        runtime.weapon.pending_action_state = action_layer.state
        runtime.weapon.right_hand_shown_for_action = false
        runtime.weapon.right_hand_aligned_for_action = false
    end

    local fallback_switch_time = active_spec.weapon_event == "left_waist_sheathe" and 0.74 or 0.44
    if active_spec.weapon_event == "left_waist_draw" then
        local right_hand_time = resolve_number(active_spec.weapon_right_hand_time, 0.16666667)
        local align_until = resolve_number(active_spec.weapon_right_hand_align_until, 0.5)
        if not runtime.weapon.right_hand_shown_for_action and action_layer.elapsed >= right_hand_time then
            runtime.weapon.right_hand_shown_for_action = true
            runtime.weapon.right_hand_aligned_for_action = true
            self:SetRightHandMortalBladeDrawAlignment(true)
            self:SetRightHandMortalBladeVisible(true)
        end

        if runtime.weapon.right_hand_aligned_for_action then
            local blend_duration = math.max(align_until - right_hand_time, 0.001)
            local blend_alpha = (action_layer.elapsed - right_hand_time) / blend_duration
            if blend_alpha >= 1.0 then
                runtime.weapon.right_hand_aligned_for_action = false
                self:SetRightHandMortalBladeDrawAlignment(false)
            else
                self:SetRightHandMortalBladeDrawRotationAlpha(blend_alpha)
            end
        end
    end

    local switch_time = resolve_number(active_spec.weapon_switch_time, fallback_switch_time)
    if action_layer.elapsed < switch_time then
        return
    end

    if active_spec.weapon_event == "left_waist_draw" then
        self:SetLeftWaistWeaponDrawn(runtime, true)
        self:SetRightHandMortalBladeVisible(true)
    elseif active_spec.weapon_event == "left_waist_sheathe" then
        self:SetRightHandMortalBladeDrawAlignment(false)
        self:SetLeftWaistWeaponDrawn(runtime, false)
        self:SetRightHandMortalBladeVisible(false)
    end
end

local function validate_reaction_layer(self, context)
    local runtime = ensure_runtime(self)
    local reaction_layer = get_layer_runtime(runtime, Constants.LAYER_REACTION)
    local event_name = consume_reaction_event(self)
    local spec = select_add_event_spec(
        EventSpecs.SimpleReactionEvents,
        ReactionEventVariants,
        event_name,
        context.wants_move
    )

    if spec then
        deactivate_add_layer(self, Constants.LAYER_ACTION, "ActionCanceledByReaction")
        return require("Sekiro.C0000.FireEventHandlers").apply_spec(self, spec, context)
    end

    if reaction_layer.state ~= Constants.REACTION_STATE_IDLE then
        local active_spec = find_add_spec_by_state(EventSpecs.SimpleReactionEvents, reaction_layer.state)
        local duration = active_spec and active_spec.duration or 0.0
        if reaction_layer.elapsed >= duration then
            return deactivate_add_layer(self, Constants.LAYER_REACTION, "ReactionEnd")
        end
    end

    return false
end

local GuardMoveSpecByDirection = {
    [Constants.MOVE_DIRECTION_FORWARD] = "DeflectGuardMoveForward",
    [Constants.MOVE_DIRECTION_BACK] = "DeflectGuardMoveBack",
    [Constants.MOVE_DIRECTION_LEFT] = "DeflectGuardMoveLeft",
    [Constants.MOVE_DIRECTION_RIGHT] = "DeflectGuardMoveRight",
    [Constants.MOVE_DIRECTION_FORWARD_LEFT] = "DeflectGuardMoveForward",
    [Constants.MOVE_DIRECTION_FORWARD_RIGHT] = "DeflectGuardMoveForward",
    [Constants.MOVE_DIRECTION_BACK_LEFT] = "DeflectGuardMoveBack",
    [Constants.MOVE_DIRECTION_BACK_RIGHT] = "DeflectGuardMoveBack",
}

local function select_deflect_guard_hold_spec(context)
    if not context or not context.wants_move then
        return EventSpecs.SimpleActionEvents.DeflectGuardIdle
    end

    local direction = context.target_direction
    if direction == Constants.MOVE_DIRECTION_NONE then
        direction = context.direction
    end
    local spec_key = GuardMoveSpecByDirection[direction] or "DeflectGuardMoveForward"
    return EventSpecs.SimpleActionEvents[spec_key] or EventSpecs.SimpleActionEvents.DeflectGuardMoveForward
end

local function validate_action_layer(self, context)
    local runtime = ensure_runtime(self)
    local reaction_layer = get_layer_runtime(runtime, Constants.LAYER_REACTION)
    local action_layer = get_layer_runtime(runtime, Constants.LAYER_ACTION)

    if is_throw_active(self) then
        clear_ground_attack_runtime(runtime)
        if action_layer.state ~= Constants.ACTION_STATE_IDLE then
            return deactivate_add_layer(self, Constants.LAYER_ACTION, "ActionCanceledByThrow")
        end
        return false
    end

    if reaction_layer.state ~= Constants.REACTION_STATE_IDLE then
        return false
    end

    local event_name = consume_action_event(self)
    if is_ground_attack_input(event_name) and not self:IsMortalBladeCurrentlyDrawn(runtime) then
        return false
    end

    if action_layer.state ~= Constants.ACTION_STATE_IDLE then
        if is_deflect_guard_action_state(action_layer.state) then
            if event_name == "DeflectGuardRelease" then
                local release_spec = select_add_event_spec(
                    EventSpecs.SimpleActionEvents,
                    ActionEventVariants,
                    event_name,
                    context.wants_move
                )
                if release_spec then
                    return require("Sekiro.C0000.FireEventHandlers").apply_spec(self, release_spec, context)
                end
            end

            local guard_spec = select_deflect_guard_hold_spec(context)
            if guard_spec and guard_spec.to_state ~= action_layer.state then
                return require("Sekiro.C0000.FireEventHandlers").apply_spec(self, guard_spec, context)
            end
            return false
        end

        local followup_spec = get_ground_attack_release_followup(
            self,
            EventSpecs.SimpleActionEvents,
            event_name,
            action_layer
        )
        if followup_spec then
            return require("Sekiro.C0000.FireEventHandlers").apply_spec(self, followup_spec, context)
        end

        local active_spec = find_add_spec_by_state(EventSpecs.SimpleActionEvents, action_layer.state)
        if active_spec and active_spec.hold_until_release then
            return false
        end
        local duration = active_spec and active_spec.duration or 0.0
        if action_layer.elapsed >= duration then
            local restart_ground_attack = is_ground_attack_action_state(action_layer.state)
                and wants_ground_attack_restart_after_action_end(runtime, event_name, action_layer)
            local ended = deactivate_add_layer(self, Constants.LAYER_ACTION, "ActionEnd")
            if restart_ground_attack and self:IsMortalBladeCurrentlyDrawn(runtime) then
                local restart_spec = select_add_event_spec(
                    EventSpecs.SimpleActionEvents,
                    ActionEventVariants,
                    "GroundAttack",
                    context.wants_move
                )
                if restart_spec then
                    return require("Sekiro.C0000.FireEventHandlers").apply_spec(self, restart_spec, context)
                end
            end
            return ended
        end
        return false
    end

    if event_name == "DeflectGuardRelease" then
        return false
    end

    if event_name == "DeflectGuard" then
        local guard_spec = select_deflect_guard_hold_spec(context)
        if guard_spec then
            return require("Sekiro.C0000.FireEventHandlers").apply_spec(self, guard_spec, context)
        end
    end

    local spec = select_add_event_spec(
        EventSpecs.SimpleActionEvents,
        ActionEventVariants,
        event_name,
        context.wants_move
    )
    if spec then
        if spec.weapon_event and self:RequestOriginalNonCombatTransition(spec.weapon_event) then
            return false
        end
        return require("Sekiro.C0000.FireEventHandlers").apply_spec(self, spec, context)
    end

    return false
end

local ValidateOrderByLayer = {
    [Constants.LAYER_REACTION] = {
        validate_reaction_layer,
    },
    [Constants.LAYER_ACTION] = {
        validate_action_layer,
    },
    [Constants.LAYER_BASE] = {
        validate_base_layer,
    },
}

local function validate_layer(self, layer_id, context)
    local validators = ValidateOrderByLayer[layer_id]
    if not validators then
        return false
    end

    for _, validator in ipairs(validators) do
        local result = validator(self, context)

        if type(result) == "string" then
            return activate_event(self, result, context)
        end
        if result then
            return true
        end
    end
    return false
end

local function face_toward_move_input(self, context)
    if not context.wants_move then
        return false
    end

    local runtime = ensure_runtime(self)
    if M.IsLeftWaistDrawActionActive(self, runtime) then
        return false
    end

    if is_ground_attack_action_state(get_layer_runtime(runtime, Constants.LAYER_ACTION).state) then
        return false
    end
    if is_ground_attack_end_base_settle_active(runtime) then
        return false
    end

    if is_turning_locked_by_anim_event(runtime) then
        return false
    end

    local base_state = get_layer_runtime(runtime, Constants.LAYER_BASE).state
    if runtime.turn.active or is_quick_turn_state(base_state) then
        return false
    end

    local turn_angle = resolve_number(context.turn_angle, context.move_angle)
    local abs_angle = math.abs(turn_angle)
    if abs_angle <= MOVE_INPUT_FACE_DEAD_ANGLE then
        return false
    end

    local delta_seconds = math.max(resolve_number(context.delta_seconds, 0.0), 0.0)
    local forward = resolve_number(context.forward, 0)
    local right = resolve_number(context.right, 0)
    local is_diagonal_input = forward ~= 0 and right ~= 0
    local is_move_start = base_state == Constants.BASE_STATE_MOVE_START
    if is_move_start then
        runtime.turn.diagonal_face_lerp_until =
            runtime.time + MOVE_START_FACE_LERP_RECOVER_SECONDS
    elseif is_diagonal_input then
        runtime.turn.diagonal_face_lerp_until =
            runtime.time + MOVE_INPUT_DIAGONAL_FACE_RECOVER_SECONDS
    end

    local yaw_delta = 0.0
    if is_move_start then
        local alpha = math.min(delta_seconds * MOVE_START_FACE_LERP_SPEED, 1.0)
        yaw_delta = turn_angle * alpha
    elseif is_diagonal_input
        or runtime.time < resolve_number(runtime.turn.diagonal_face_lerp_until, 0.0) then
        local alpha = math.min(delta_seconds * MOVE_INPUT_DIAGONAL_FACE_LERP_SPEED, 1.0)
        yaw_delta = turn_angle * alpha
    else
        local max_yaw = get_anim_event_turn_speed(runtime) * delta_seconds
        yaw_delta = math.min(abs_angle, max_yaw)
        if turn_angle < 0.0 then
            yaw_delta = -yaw_delta
        end
    end

    if apply_preview_facing_yaw(self, yaw_delta) then
        sync_polled_input(self)
        return true
    end
    return false
end

local function apply_movement_input(self, context)
    if not context.wants_move then
        return
    end

    local runtime = ensure_runtime(self)
    if M.IsLeftWaistDrawActionActive(self, runtime) then
        return
    end

    local base_state = get_layer_runtime(runtime, Constants.LAYER_BASE).state
    if base_state == Constants.BASE_STATE_MOVE_STOP then
        stop_preview_movement(self)
        return
    end
    local moving_quick_turn =
        base_state == Constants.BASE_STATE_QUICK_TURN_MOVE_START_180
        or base_state == Constants.BASE_STATE_MOVE_QUICK_TURN_180
    if (runtime.turn.active or is_quick_turn_state(base_state)) and not moving_quick_turn then
        return
    end

    local forward = context.forward
    local right = context.right
    local scale = get_anim_event_move_scale(
        runtime,
        get_movement_input_scale(runtime.anim.move_speed_level_real or 0.0),
        moving_quick_turn
    )
    if scale <= 0.0 then
        stop_preview_movement(self)
        return
    end

    if self.ApplyPreviewMovementInput then
        self:ApplyPreviewMovementInput(scale)
        return
    end

    if forward ~= 0 and right ~= 0 then
        scale = scale * 0.70710678
    end

    if forward ~= 0 then
        self:AddMovementInput(self:GetActorForwardVector(), forward * scale, false)
    end
    if right ~= 0 then
        self:AddMovementInput(self:GetActorRightVector(), right * scale, false)
    end
end

function M:TriggerSekiroEvent(event_name)
    local context = read_context(self, 0.0)

    for event_key, spec in pairs(EventSpecs.SimpleMovementEvents) do
        if event_key == event_name or spec.event == event_name then
            return activate_event(self, event_key, context)
        end
    end

    local action_spec = select_add_event_spec(
        EventSpecs.SimpleActionEvents,
        ActionEventVariants,
        event_name,
        context.wants_move
    )
    if action_spec then
        if action_spec.weapon_event and self:RequestOriginalNonCombatTransition(action_spec.weapon_event) then
            return true
        end
        return require("Sekiro.C0000.FireEventHandlers").apply_spec(self, action_spec, context)
    end

    local reaction_spec = select_add_event_spec(
        EventSpecs.SimpleReactionEvents,
        ReactionEventVariants,
        event_name,
        context.wants_move
    )
    if reaction_spec then
        deactivate_add_layer(self, Constants.LAYER_ACTION, "ActionCanceledByReaction")
        return require("Sekiro.C0000.FireEventHandlers").apply_spec(self, reaction_spec, context)
    end

    print_runtime(self, "Unknown simple movement event: " .. tostring(event_name))
    return false
end

function M:OnSekiroMovementAnimEvent(event_name, active, numeric_value, source_args)
    local runtime = ensure_runtime(self)
    local event_name_text = tostring(event_name or "")
    if active and event_name_text == "TAE_32" then
        local weapon_style = ExtractTaeParamNumber(source_args, "WeaponStyle")
        if weapon_style ~= nil then
            local drawn = weapon_style >= 1
            self:SetLeftWaistWeaponDrawn(runtime, drawn)
            self:SetRightHandMortalBladeVisible(drawn)
        end
    elseif event_name_text == "TAE_224" then
        print_runtime(self, "TAE_224 active=" .. tostring(active) .. " args=" .. tostring(source_args or ""))
    elseif event_name_text == "TAE_715" then
        local weapon_model_type = ExtractTaeParamNumber(source_args, "WeaponModelType")
        if weapon_model_type ~= nil and weapon_model_type == 0 then
            if active then
                self:SetRightHandMortalBladeVisible(true)
            elseif not (self.IsMortalBladeDrawn and self:IsMortalBladeDrawn()) then
                self:SetRightHandMortalBladeVisible(false)
            end
        end
    end

    local skip_behavior_ref =
        event_name_text == "TAE_224"
        or event_name_text == "TAE_760"
        or event_name_text == "TAE_960"

    set_movement_anim_event_active(
        runtime,
        event_name,
        active,
        numeric_value,
        source_args,
        skip_behavior_ref
    )
    set_tae_movement_alias_active(runtime, event_name, active, source_args)
    return true
end

function M:ReceiveBeginPlay()
    reset_runtime(self)

    if self.Overridden and self.Overridden.ReceiveBeginPlay then
        self.Overridden.ReceiveBeginPlay(self)
    end
end

function M:ReceiveTick(delta_seconds)
    local runtime = ensure_runtime(self)
    runtime.time = runtime.time + math.max(resolve_number(delta_seconds, 0.0), 0.0)
    ReleaseLegacyPreviewMovementLock(self)
    self:UpdateEnemyAutoDraw(runtime)

    sync_polled_input(self)
    local context = read_context(self, delta_seconds)
    validate_layer(self, Constants.LAYER_REACTION, context)

    context = read_context(self, delta_seconds)
    validate_layer(self, Constants.LAYER_ACTION, context)
    self:UpdateLeftWaistWeaponVisual()
    if runtime.time >= resolve_number(runtime.left_waist_draw_move_lock_until, 0.0) then
        runtime.left_waist_draw_move_lock_until = 0.0
    end

    context = read_context(self, delta_seconds)
    context = M.SuppressLeftWaistDrawMoveContext(self, runtime, context)
    validate_layer(self, Constants.LAYER_BASE, context)

    context = read_context(self, delta_seconds)
    context = M.SuppressLeftWaistDrawMoveContext(self, runtime, context)
    if face_toward_move_input(self, context) then
        context = read_context(self, delta_seconds)
        context = M.SuppressLeftWaistDrawMoveContext(self, runtime, context)
    end
    require("Sekiro.C0000.FireEventHandlers").tick(self, context)
    apply_movement_input(self, context)
    render_debug_overlay(self, context)
    clear_synthetic_movement_anim_events(runtime)

    if self.Overridden and self.Overridden.ReceiveTick then
        self.Overridden.ReceiveTick(self, delta_seconds)
    end
end

function M:ReceiveEndPlay(reason)
    reset_anim_requests(self)

    if self.Overridden and self.Overridden.ReceiveEndPlay then
        self.Overridden.ReceiveEndPlay(self, reason)
    end
end

return M
