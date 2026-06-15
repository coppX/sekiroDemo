local Constants = require("Sekiro.C0000.Constants")
local EventSpecs = require("Sekiro.C0000.EventSpecs")
local EventAliases = require("Sekiro.C0000.EventAliases")
local AnimVarWriter = require("Sekiro.C0000.AnimVarWriter")
local AnimRuntime = require("Sekiro.C0000.AnimRuntime")
require("Sekiro.C0000.StateUtils")
require("Sekiro.C0000.StateDefines")
require("Sekiro.C0000.MathUtils")
require("Sekiro.C0000.MovementUtils")
local PreviewConfig = require("Sekiro.C0000.PreviewCharacterConfig")

local M = {}

local REQUEST_PULSE_SECONDS = 0.20
local MOVE_START_MOTION_SELECTOR_SETTLE_SECONDS = 2.0 / 30.0
local MOVE_START_ANIME_SELECTOR_SETTLE_SECONDS = 0.12
local MOVE_START_ANIME_SELECTOR_VISUAL_SCALE = 0.0
local MOVE_LOOP_FROM_START_ANGLE_SETTLE_SECONDS = 0.24
local QUICK_TURN_MOVE_START_SELECTOR_F_PRELUDE_SECONDS = 1.0 / 60.0
local QUICK_TURN_MOVE_START_SELECTOR_BF_BLEND_SECONDS = 10.0 / 60.0
local SELECT_BLEND_SYNC = 0
local SELECT_BLEND_NO_SRC_MOTION_IGNORE_FROM_GENERATOR = 2
local SELECT_STATE_TO_STATE_IGNORE_TO_WORLD = 0
local SELECT_STATE_TO_STATE_TAE_BLEND = 1

local EventLookup = {}

local function add_event_table(events)
    for event_key, spec in pairs(events or {}) do
        EventLookup[event_key] = spec
        if spec.event and spec.event ~= "" then
            EventLookup[spec.event] = spec
        end
    end
end

add_event_table(EventSpecs.SimpleMovementEvents)
add_event_table(EventSpecs.SimpleActionEvents)
add_event_table(EventSpecs.SimpleReactionEvents)

local get_locomotion_weapon_blend = AnimRuntime.GetLocomotionWeaponBlend
local update_locomotion_weapon_blend = AnimRuntime.UpdateLocomotionWeaponBlend

local function ensure_runtime(self)
    self.Runtime = self.Runtime or {}
    local runtime = self.Runtime
    runtime.time = resolve_number(runtime.time, 0.0)
    runtime.layers = runtime.layers or {}
    runtime.pending_request_clears = runtime.pending_request_clears or {}
    runtime.anim = runtime.anim or {}
    runtime.input = runtime.input or {}
    runtime.turn = runtime.turn or {}
    runtime.chain = runtime.chain or {}
    runtime.weapon = runtime.weapon or {}
    runtime.fired_event_handlers = runtime.fired_event_handlers or {}

    for layer_id, default in pairs(LayerDefaults) do
        runtime.layers[layer_id] = runtime.layers[layer_id] or {}
        local layer = runtime.layers[layer_id]
        if layer.state == nil then
            layer.state = default.state
        end
        if layer.previous_state == nil then
            layer.previous_state = default.previous_state
        end
        if layer.direction == nil then
            layer.direction = default.direction
        end
        layer.event = layer.event or default.event
        layer.state_name = layer.state_name or default.state_name
        layer.elapsed = resolve_number(layer.elapsed, 0.0)
        layer.entered_at = resolve_number(layer.entered_at, runtime.time)
        layer.applied_yaw_delta = resolve_number(layer.applied_yaw_delta, 0.0)
        layer.turn_angle = resolve_number(layer.turn_angle, 0.0)
    end

    return runtime
end

local function get_layer_runtime(runtime, layer_id)
    local default = LayerDefaults[layer_id] or LayerDefaults[Constants.LAYER_BASE]
    runtime.layers[layer_id] = runtime.layers[layer_id] or {}
    local layer = runtime.layers[layer_id]
    layer.state = layer.state or default.state
    layer.previous_state = layer.previous_state or default.previous_state
    layer.direction = layer.direction or default.direction
    layer.event = layer.event or default.event
    layer.state_name = layer.state_name or default.state_name
    layer.elapsed = resolve_number(layer.elapsed, 0.0)
    return layer
end

local function set_anim_int(self, var_name, value)
    AnimVarWriter.set_int(self, var_name, value)
end

local function set_anim_bool(self, var_name, value)
    AnimVarWriter.set_bool(self, var_name, value)
end

local function set_anim_float(self, var_name, value)
    AnimVarWriter.set_float(self, var_name, value)
end

local function pulse_anim_bool(self, runtime, var_name)
    AnimVarWriter.pulse_bool(self, runtime, var_name, REQUEST_PULSE_SECONDS)
end

local function print_runtime(self, message)
    local text = "[SekiroFSM] " .. tostring(message)
    if KismetSystemLibrary and UE and UE.FLinearColor then
        pcall(function()
            KismetSystemLibrary.PrintString(
                self,
                text,
                true,
                true,
                UE.FLinearColor(0.92, 0.78, 0.34, 1.0),
                1.2,
                ""
            )
        end)
    end
    if UnLua and UnLua.Log then
        UnLua.Log(text)
    end
end

local function clear_turn_runtime(runtime)
    runtime.turn.active = false
    runtime.turn.event_key = ""
    runtime.turn.source = ""
    runtime.turn.exit_policy = ""
    runtime.turn.next_event = nil
    runtime.turn.turn_angle = 0.0
    runtime.turn.twist_angle = 0.0
    runtime.turn.applied_yaw_delta = 0.0
    runtime.turn.source_direction = Constants.MOVE_DIRECTION_NONE
    runtime.turn.target_direction = Constants.MOVE_DIRECTION_NONE
end

local function begin_turn_runtime(runtime, event_key, spec, context)
    runtime.turn.active = true
    runtime.turn.event_key = event_key or ""
    runtime.turn.source = spec.turn_source or ""
    runtime.turn.exit_policy = spec.exit_policy or ""
    runtime.turn.next_event = spec.next_event
    runtime.turn.turn_angle = resolve_number(spec.yaw_delta, resolve_number(context and context.turn_angle, 0.0))
    runtime.turn.twist_angle = -runtime.turn.turn_angle
    runtime.turn.applied_yaw_delta = 0.0
    runtime.turn.turn_window_start = resolve_number(spec.turn_window_start, 0.0)
    runtime.turn.turn_window_end = resolve_number(spec.turn_window_end, 1.0)
    runtime.turn.source_direction = context and context.facing_direction or Constants.MOVE_DIRECTION_NONE
    runtime.turn.target_direction = context and context.target_direction or Constants.MOVE_DIRECTION_NONE
    if not is_cardinal_direction(runtime.turn.target_direction) and context then
        runtime.turn.target_direction = resolve_cardinal_direction_from_axes(context.forward, context.right)
    end
end

local function clear_chain_runtime(runtime)
    runtime.chain.active = false
    runtime.chain.next_event = nil
    runtime.chain.exit_time = 0.0
end

local function begin_chain_runtime(runtime, spec)
    runtime.chain.active = true
    runtime.chain.next_event = spec.next_event
    runtime.chain.exit_time = resolve_number(spec.exit_time, resolve_number(spec.duration, 0.0))
end

local function resolve_direction(layer, context, spec)
    if spec.direction ~= nil then
        return spec.direction
    end
    if context and is_valid_direction(context.direction) then
        return context.direction
    end
    if layer and is_valid_direction(layer.direction) then
        return layer.direction
    end
    return Constants.MOVE_DIRECTION_FORWARD
end

local function get_anim_state_id(layer)
    local state_id = resolve_number(layer.state, Constants.BASE_STATE_IDLE)
    if not state_uses_direction(state_id) then
        return state_id * 10
    end

    local direction_id = resolve_number(layer.direction, Constants.MOVE_DIRECTION_FORWARD)
    local direction_offset = DirectionStateOffsets[direction_id]
    if direction_offset == nil then
        direction_offset = DirectionStateOffsets[Constants.MOVE_DIRECTION_FORWARD]
    end
    return state_id * 10 + direction_offset
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

local function resolve_move_start_selector_direction(context)
    if context and is_valid_direction(context.move_start_bridge_source_direction) then
        return context.move_start_bridge_source_direction
    end
    return Constants.MOVE_DIRECTION_FORWARD
end

local function resolve_move_start_selector_id(context)
    local selector_direction = resolve_move_start_selector_direction(context)
    local direction_slot = DirectionStateOffsets[selector_direction]
    if direction_slot == nil then
        direction_slot = DirectionStateOffsets[Constants.MOVE_DIRECTION_FORWARD]
    end
    return Constants.MOVE_SPEED_INDEX_RUN * 10 + direction_slot
end

local function resolve_move_start_selector_angle(selector_id)
    local direction_slot = math.floor(resolve_number(selector_id, Constants.MOVE_SPEED_INDEX_RUN * 10)) % 10
    return MoveStartSelectorAngles[direction_slot] or MoveStartSelectorAngles[0]
end

local function get_move_start_selector_blend_angle(direction)
    if direction == Constants.MOVE_DIRECTION_LEFT
        or direction == Constants.MOVE_DIRECTION_BACK_LEFT then
        return -45.0
    end
    if direction == Constants.MOVE_DIRECTION_FORWARD_LEFT then
        return -35.0
    end
    if direction == Constants.MOVE_DIRECTION_RIGHT
        or direction == Constants.MOVE_DIRECTION_BACK_RIGHT then
        return 45.0
    end
    if direction == Constants.MOVE_DIRECTION_FORWARD_RIGHT then
        return 35.0
    end
    return 0.0
end

local function resolve_move_start_selector_blend_angle(context, fallback_direction, selector_kind)
    local direction = fallback_direction
    if context and is_valid_direction(context.direction) then
        direction = context.direction
    end
    if not is_valid_direction(direction) then
        direction = Constants.MOVE_DIRECTION_FORWARD
    end

    local initial_angle = get_move_start_selector_blend_angle(direction)
    if selector_kind == "anime" then
        initial_angle = initial_angle * MOVE_START_ANIME_SELECTOR_VISUAL_SCALE
    end
    if math.abs(initial_angle) <= 0.01 then
        return 0.0
    end

    local elapsed = resolve_number(context and context.elapsed, 0.0)
    local settle_seconds = selector_kind == "motion"
        and MOVE_START_MOTION_SELECTOR_SETTLE_SECONDS
        or MOVE_START_ANIME_SELECTOR_SETTLE_SECONDS
    local alpha = smooth_step(elapsed / math.max(settle_seconds, 0.001))
    return initial_angle * (1.0 - alpha)
end

local function resolve_move_start_anime_sync_blend(context, fallback_direction)
    local direction = fallback_direction
    if context and is_valid_direction(context.direction) then
        direction = context.direction
    end
    if not is_valid_direction(direction) then
        direction = Constants.MOVE_DIRECTION_FORWARD
    end

    local anime_angle = resolve_move_start_selector_blend_angle(context, direction, "anime")
    local current_direction = math.abs(anime_angle) > 0.01 and direction or Constants.MOVE_DIRECTION_FORWARD
    local current_slot = DirectionStateOffsets[current_direction]
    if current_slot == nil then
        current_slot = DirectionStateOffsets[Constants.MOVE_DIRECTION_FORWARD]
    end

    return {
        current_id = Constants.MOVE_SPEED_INDEX_RUN * 10 + current_slot,
        current_angle = anime_angle,
    }
end

local function get_move_start_locked_direction(layer, fallback_direction)
    if layer and is_valid_direction(layer.move_start_input_direction) then
        return layer.move_start_input_direction
    end
    if is_valid_direction(fallback_direction) then
        return fallback_direction
    end
    return Constants.MOVE_DIRECTION_FORWARD
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
        return angle * get_move_loop_from_start_angle_alpha(layer)
    end
    return angle
end

local function is_pure_forward_back_move_input(context)
    return context
        and resolve_number(context.input_strength, 0.0) > 0.05
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

local function resolve_quick_turn_move_start_motion_selector_direction(direction, context)
    if context and context.current_state == Constants.BASE_STATE_QUICK_TURN_MOVE_START_180 then
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
    if is_opposite_forward_back_turn(context) or not is_valid_direction(direction) then
        return Constants.MOVE_DIRECTION_FORWARD
    end
    return direction
end

local function resolve_quick_turn_move_start_visible_selector_direction(direction, context)
    if context and context.current_state == Constants.BASE_STATE_QUICK_TURN_MOVE_START_180 then
        return Constants.MOVE_DIRECTION_FORWARD
    end
    if is_opposite_forward_back_turn(context) or not is_valid_direction(direction) then
        return Constants.MOVE_DIRECTION_FORWARD
    end
    return direction
end

local function sync_quick_turn_selector_flags(self, direction)
    local direction_slot = DirectionStateOffsets[direction]
    if direction_slot == nil then
        direction_slot = DirectionStateOffsets[Constants.MOVE_DIRECTION_FORWARD]
    end
    set_anim_bool(self, "QTMoveStartSelectorIsBack", direction_slot == 1)
    set_anim_bool(self, "QTMoveStartSelectorIsLeft", direction_slot == 2)
    set_anim_bool(self, "QTMoveStartSelectorIsRight", direction_slot == 3)
end

local function sync_hkx_turn_vars(self, runtime, layer, turn_angle)
    local quick_turn = is_quick_turn_state(layer.state)
    local signed_turn = resolve_number(turn_angle, 0.0)
    if runtime and runtime.turn and runtime.turn.active then
        signed_turn = resolve_number(runtime.turn.turn_angle, signed_turn)
    end

    set_anim_int(self, "TurnType", quick_turn and (signed_turn < 0.0 and -1 or 1) or 0)
    set_anim_int(self, "QuickTurnState", quick_turn and layer.state or 0)
    set_anim_int(
        self,
        "Selector_UseTransitionEffect",
        quick_turn and SELECT_BLEND_NO_SRC_MOTION_IGNORE_FROM_GENERATOR or SELECT_BLEND_SYNC
    )
    set_anim_int(
        self,
        "Selector_UseStaterToStateTransitionEffect",
        quick_turn and SELECT_STATE_TO_STATE_IGNORE_TO_WORLD or SELECT_STATE_TO_STATE_TAE_BLEND
    )
    set_anim_bool(self, "IsTurnTwist", quick_turn)
    set_anim_float(self, "TwistMasterAngle", quick_turn and signed_turn or 0.0)
    set_anim_float(self, "TwistUpperRootAngle", quick_turn and signed_turn * 0.35 or 0.0)
    set_anim_float(self, "MoveTwistAngle_Yaw", quick_turn and signed_turn or 0.0)
    set_anim_float(self, "MoveTwistAngle_Roll", 0.0)
end

local function sync_base_state_vars(self, layer)
    local state_id = resolve_number(layer.state, Constants.BASE_STATE_IDLE)
    local previous_state_id = resolve_number(layer.previous_state, state_id)
    local direction_id = resolve_number(layer.direction, Constants.MOVE_DIRECTION_NONE)
    local elapsed = resolve_number(layer.elapsed, 0.0)

    set_anim_int(self, "LayerId", Constants.LAYER_BASE)
    set_anim_int(self, "StateId", state_id)
    set_anim_int(self, "PreviousStateId", previous_state_id)
    set_anim_int(self, "DirectionId", direction_id)
    set_anim_float(self, "StateElapsedSeconds", elapsed)

    set_anim_int(self, "FSM_LayerId", Constants.LAYER_BASE)
    set_anim_int(self, "FSM_StateId", state_id)
    set_anim_int(self, "FSM_PreviousStateId", previous_state_id)
    set_anim_int(self, "FSM_DirectionId", direction_id)
    set_anim_int(self, "FSM_AnimStateId", get_anim_state_id(layer))
    set_anim_float(self, "FSM_StateElapsedSeconds", elapsed)
    set_anim_bool(
        self,
        "FSM_MoveStartAutoExit",
        state_id == Constants.BASE_STATE_MOVE_LOOP and previous_state_id == Constants.BASE_STATE_MOVE_START
    )
end

local function sync_base_anim_vars(self, runtime, layer, context)
    context = context or {}
    if self and self.IsMortalBladeDrawn then
        runtime.weapon = runtime.weapon or {}
        runtime.weapon.left_waist_drawn = self:IsMortalBladeDrawn() and true or false
    end

    local state_direction = resolve_number(layer.direction, Constants.MOVE_DIRECTION_NONE)
    local direction = resolve_anim_direction_for_state(layer.state, state_direction, context.direction)
    if direction == Constants.MOVE_DIRECTION_NONE and state_remembers_input_direction(layer.state) then
        direction = runtime.anim.last_direction
    end
    if state_remembers_input_direction(layer.state) then
        local tracked_direction = context.direction
        if tracked_direction == Constants.MOVE_DIRECTION_NONE then
            tracked_direction = direction
        end
        if tracked_direction ~= Constants.MOVE_DIRECTION_NONE then
            runtime.anim.last_direction = tracked_direction
        end
    end

    local move_speed_level = get_move_speed_level_target(context)
    local move_speed_index = resolve_move_speed_index(move_speed_level, runtime.anim.move_speed_index)
    local move_speed_level_real = get_move_speed_level_real(
        runtime.anim.move_speed_level_real,
        move_speed_level,
        context.delta_seconds
    )
    if context.wants_move and move_speed_level >= 1.0 then
        move_speed_level_real = 1.0
    end
    local locomotion_weapon_blend = update_locomotion_weapon_blend(runtime, context.delta_seconds)
    local move_loop_play_rate = get_move_loop_play_rate(move_speed_level_real)
    local target_move_speed = get_target_move_speed(move_speed_level_real, direction)
    if context.wants_move then
        target_move_speed = target_move_speed * get_move_start_movement_scale(layer)
    end
    if context.wants_move and is_deflect_guard_action_state(get_layer_runtime(runtime, Constants.LAYER_ACTION).state) then
        target_move_speed = math.min(target_move_speed, Constants.DEFLECT_GUARD_MOVE_SPEED)
    end

    local move_start_selector_id = Constants.MOVE_SPEED_INDEX_RUN * 10
    local move_start_motion_selector_id = move_start_selector_id
    local move_start_anime_selector_id = move_start_selector_id
    local move_start_motion_selector_angle = resolve_move_start_selector_angle(move_start_motion_selector_id)
    local move_start_anime_selector_angle = resolve_move_start_selector_angle(move_start_anime_selector_id)
    if layer.state == Constants.BASE_STATE_MOVE_START then
        local move_start_direction = get_move_start_locked_direction(layer, direction)
        local anime_sync_blend = resolve_move_start_anime_sync_blend(context, move_start_direction)
        move_start_selector_id = anime_sync_blend.current_id
        move_start_anime_selector_id = anime_sync_blend.current_id
        move_start_motion_selector_id = resolve_move_start_selector_id(context)
        layer.move_start_selector_id = anime_sync_blend.current_id
        move_start_motion_selector_angle =
            resolve_move_start_selector_blend_angle(context, move_start_direction, "motion")
        move_start_anime_selector_angle = anime_sync_blend.current_angle
    end

    runtime.anim.move_speed_level = move_speed_level
    runtime.anim.move_speed_level_real = move_speed_level_real
    runtime.anim.move_speed_index = move_speed_index
    runtime.anim.move_loop_play_rate = move_loop_play_rate
    runtime.anim.target_move_speed = target_move_speed

    local moving_pose = layer.state == Constants.BASE_STATE_MOVE_START
        or layer.state == Constants.BASE_STATE_MOVE_LOOP
        or layer.state == Constants.BASE_STATE_MOVE_STOP
        or layer.state == Constants.BASE_STATE_QUICK_TURN_MOVE_START_180
        or layer.state == Constants.BASE_STATE_MOVE_QUICK_TURN_180
    local move_type = moving_pose and 1 or 0
    local move_angle = resolve_number(context.move_angle, 0.0)
    local turn_angle = resolve_number(context.turn_angle, move_angle)
    local twist_angle = resolve_number(context.twist_angle, -turn_angle)
    local anim_move_speed_level = move_speed_level
    local anim_direction = direction

    if layer.state == Constants.BASE_STATE_MOVE_START then
        move_angle = move_start_motion_selector_angle
        anim_move_speed_level = 1.0
    end
    if layer.state == Constants.BASE_STATE_MOVE_LOOP
        and layer.previous_state == Constants.BASE_STATE_MOVE_START then
        local alpha = get_move_loop_from_start_angle_alpha(layer)
        move_angle = move_angle * alpha
        turn_angle = turn_angle * alpha
        twist_angle = twist_angle * alpha
    end
    if layer.state == Constants.BASE_STATE_MOVE_STOP and direction ~= Constants.MOVE_DIRECTION_NONE then
        move_angle = resolve_number(DirectionAngles[direction], move_angle)
        turn_angle = move_angle
        twist_angle = -move_angle
    end
    if is_quick_turn_state(layer.state) then
        move_angle = resolve_number(runtime.turn.turn_angle, resolve_number(layer.turn_angle, move_angle))
        turn_angle = move_angle
        twist_angle = resolve_number(runtime.turn.twist_angle, -turn_angle)
    end
    if layer.state == Constants.BASE_STATE_QUICK_TURN_MOVE_START_180 then
        local motion_selector_direction =
            resolve_quick_turn_move_start_motion_selector_direction(direction, context)
        local visible_selector_direction =
            resolve_quick_turn_move_start_visible_selector_direction(direction, context)
        move_start_motion_selector_angle =
            resolve_move_start_selector_blend_angle(context, motion_selector_direction, "motion")
        move_start_anime_selector_angle =
            resolve_move_start_selector_blend_angle(context, visible_selector_direction, "anime")
        move_angle = move_start_anime_selector_angle
        turn_angle = 0.0
        twist_angle = 0.0
        anim_move_speed_level = 1.0
        anim_direction = visible_selector_direction
    elseif layer.state == Constants.BASE_STATE_MOVE_QUICK_TURN_180 then
        move_angle = 0.0
        turn_angle = 0.0
        twist_angle = 0.0
        anim_move_speed_level = 1.0
        anim_direction = Constants.MOVE_DIRECTION_FORWARD
    end
    if is_ground_attack_action_state(get_layer_runtime(runtime, Constants.LAYER_ACTION).state) then
        move_start_motion_selector_angle = 0.0
        move_start_anime_selector_angle = 0.0
        move_angle = 0.0
        turn_angle = 0.0
        twist_angle = 0.0
        anim_direction = Constants.MOVE_DIRECTION_FORWARD
    end

    sync_base_state_vars(self, layer)
    set_anim_float(self, "LocomotionWeaponBlend", locomotion_weapon_blend)
    set_anim_float(self, "MoveSpeedLevel", anim_move_speed_level)
    set_anim_float(self, "MoveSpeedLevelReal", move_speed_level_real)
    set_anim_float(self, "MoveLoopPlayRate", move_loop_play_rate)
    set_anim_int(self, "MoveSpeedIndex", move_speed_index)
    set_anim_int(self, "NightvisionMoveSpeedIndex", move_speed_index + 1)
    set_anim_int(self, "FSM_MoveStartSelectorId", move_start_selector_id)
    set_anim_int(self, "FSM_MoveStartMotionSelectorId", move_start_motion_selector_id)
    set_anim_int(self, "FSM_MoveStartAnimeSelectorId", move_start_anime_selector_id)
    set_anim_float(self, "MoveStartMotionSelectorAngle", move_start_motion_selector_angle)
    set_anim_float(self, "MoveStartAnimeSelectorAngle", move_start_anime_selector_angle)
    sync_quick_turn_selector_flags(
        self,
        layer.state == Constants.BASE_STATE_QUICK_TURN_MOVE_START_180
            and anim_direction
            or Constants.MOVE_DIRECTION_FORWARD
    )
    set_anim_float(self, "MoveDirection", anim_direction)
    set_anim_int(self, "MoveDirectionIndex", anim_direction)
    set_anim_float(self, "MoveAngle", move_angle)
    set_anim_float(self, "MoveLoopMotionSelectorAngle", get_move_loop_selector_angle(layer, move_angle))
    set_anim_float(self, "MoveLoopAnimeSelectorAngle", get_move_loop_selector_angle(layer, move_angle))
    set_anim_float(self, "TurnAngle", turn_angle)
    set_anim_float(self, "TwistLowerRootAngle", twist_angle)
    sync_hkx_turn_vars(self, runtime, layer, turn_angle)
    set_anim_int(self, "MoveType", move_type)
    set_anim_int(self, "StanceMoveType", move_speed_index)
    set_anim_bool(self, "bSprintHeld", context.sprint)

    if self and self.SetPreviewMoveSpeed then
        local preview_move_speed = context.wants_move and target_move_speed or WALK_SPEED
        if layer.state == Constants.BASE_STATE_MOVE_STOP and not context.wants_move then
            preview_move_speed = 0.0
        end
        self:SetPreviewMoveSpeed(preview_move_speed)
    end
end

local function sync_add_layer_anim_vars(self, runtime)
    local action = get_layer_runtime(runtime, Constants.LAYER_ACTION)
    local reaction = get_layer_runtime(runtime, Constants.LAYER_REACTION)
    local action_state = action.state
    local ground_attack_active = is_ground_attack_action_state(action_state)

    set_anim_int(self, "FSM_ActionStateId", action_state)
    set_anim_bool(self, "FSM_ActionActive", action_state ~= Constants.ACTION_STATE_IDLE and not ground_attack_active)
    set_anim_bool(self, "FSM_ActionIdleActive", action_state == Constants.ACTION_STATE_IDLE)
    set_anim_bool(self, "FSM_ActionLeftWaistDrawIdleActive", action_state == Constants.ACTION_STATE_LEFT_WAIST_DRAW)
    set_anim_bool(self, "FSM_ActionLeftWaistDrawMoveActive", action_state == Constants.ACTION_STATE_LEFT_WAIST_DRAW_MOVE)
    set_anim_bool(self, "FSM_ActionLeftWaistSheatheIdleActive", action_state == Constants.ACTION_STATE_LEFT_WAIST_SHEATHE)
    set_anim_bool(self, "FSM_ActionLeftWaistSheatheMoveActive", action_state == Constants.ACTION_STATE_LEFT_WAIST_SHEATHE_MOVE)
    set_anim_bool(self, "FSM_ActionDeflectGuardIdleActive", action_state == Constants.ACTION_STATE_DEFLECT_GUARD_IDLE)
    set_anim_bool(self, "FSM_ActionDeflectGuardMoveForwardActive", action_state == Constants.ACTION_STATE_DEFLECT_GUARD_MOVE_FORWARD)
    set_anim_bool(self, "FSM_ActionDeflectGuardMoveBackActive", action_state == Constants.ACTION_STATE_DEFLECT_GUARD_MOVE_BACK)
    set_anim_bool(self, "FSM_ActionDeflectGuardMoveLeftActive", action_state == Constants.ACTION_STATE_DEFLECT_GUARD_MOVE_LEFT)
    set_anim_bool(self, "FSM_ActionDeflectGuardMoveRightActive", action_state == Constants.ACTION_STATE_DEFLECT_GUARD_MOVE_RIGHT)
    set_anim_bool(self, "FSM_ActionDeflectGuardToStandActive", action_state == Constants.ACTION_STATE_DEFLECT_GUARD_TO_STAND)
    set_anim_bool(self, "FSM_GroundAttackActive", ground_attack_active)
    set_anim_bool(self, "FSM_GroundAttackCombo1Active", action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_1)
    set_anim_bool(self, "FSM_GroundAttackCombo1ReleaseActive", action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_1_RELEASE)
    set_anim_bool(self, "FSM_GroundAttackCombo1ReverseActive", action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_1_REVERSE)
    set_anim_bool(self, "FSM_GroundAttackCombo1ReverseReleaseActive", action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_1_REVERSE_RELEASE)
    set_anim_bool(self, "FSM_GroundAttackCombo2Active", action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_2)
    set_anim_bool(self, "FSM_GroundAttackCombo2ReleaseActive", action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_2_RELEASE)
    set_anim_bool(self, "FSM_GroundAttackCombo2ReverseActive", action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_2_REVERSE)
    set_anim_bool(self, "FSM_GroundAttackCombo2ReverseReleaseActive", action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_2_REVERSE_RELEASE)
    set_anim_bool(self, "FSM_GroundAttackCombo3Active", action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_3)
    set_anim_bool(self, "FSM_GroundAttackCombo4Active", action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_4)
    set_anim_bool(self, "FSM_GroundAttackCombo5Active", action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_5)
    set_anim_float(self, "FSM_ActionStateElapsedSeconds", action.elapsed)

    set_anim_int(self, "FSM_ReactionStateId", reaction.state)
    set_anim_bool(self, "FSM_ReactionActive", reaction.state ~= Constants.REACTION_STATE_IDLE)
    set_anim_float(self, "FSM_ReactionStateElapsedSeconds", reaction.elapsed)
end

local function sync_state_machine(self, layer_id, layer)
    if self and self.GetSekiroLayeredStateMachine then
        local state_machine = self:GetSekiroLayeredStateMachine()
        if state_machine and state_machine.SetLayerState then
            state_machine:SetLayerState(layer_id, layer.state, layer.state_name, layer.event, layer.direction)
        end
    end
end

local function find_spec(event_name, event_key)
    local spec = event_key and EventLookup[event_key] or nil
    if spec then
        return spec, event_key
    end

    local alias_key = EventAliases.AliasToEventKey[event_name]
    if alias_key and EventLookup[alias_key] then
        return EventLookup[alias_key], alias_key
    end

    return EventLookup[event_name], event_name
end

local function apply_layer_event(self, runtime, event_name, event_key, spec, context)
    if not spec or not spec.layer then
        return false
    end

    local layer = get_layer_runtime(runtime, spec.layer)
    local direction = resolve_direction(layer, context, spec)
    if spec.layer == Constants.LAYER_BASE
        and spec.to_state == Constants.BASE_STATE_MOVE_STOP
        and layer.state == Constants.BASE_STATE_MOVE_START
        and context
        and not context.has_move_input then
        direction = Constants.MOVE_DIRECTION_FORWARD
    end

    layer.previous_state = layer.state
    layer.previous_direction = layer.direction
    layer.state = spec.to_state
    layer.direction = direction
    layer.turn_angle = resolve_number(spec.yaw_delta, resolve_number(context and context.turn_angle, context and context.move_angle or 0.0))
    layer.applied_yaw_delta = 0.0
    layer.entered_at = runtime.time
    layer.elapsed = 0.0
    layer.event = spec.event or event_name
    layer.state_name = spec.state_name or tostring(spec.to_state)

    sync_state_machine(self, spec.layer, layer)

    if spec.layer == Constants.LAYER_BASE then
        if spec.yaw_delta ~= nil then
            clear_chain_runtime(runtime)
            begin_turn_runtime(runtime, event_key or event_name, spec, context)
        else
            clear_turn_runtime(runtime)
            if spec.exit_policy == "next_event" and spec.next_event then
                begin_chain_runtime(runtime, spec)
            else
                clear_chain_runtime(runtime)
            end
        end
        if is_move_start_quick_turn_bridge_event_key(event_key) then
            runtime.input.forward_left_source_until = 0.0
            runtime.input.forward_right_source_until = 0.0
        end
        if is_turn90_event_key(event_key) then
            runtime.input.suppress_move_until_input_released = true
            runtime.input.suppressed_target_direction =
                context and resolve_cardinal_direction_from_axes(context.forward, context.right)
                or Constants.MOVE_DIRECTION_NONE
            runtime.input.quick_turn_90_suppress_until = runtime.time + 0.35
            runtime.input.forward_left_source_until = 0.0
            runtime.input.forward_right_source_until = 0.0
        end
        sync_base_anim_vars(self, runtime, layer, context)
        pulse_anim_bool(self, runtime, spec.request)
    else
        if spec.weapon_event == "left_waist_draw" or spec.weapon_event == "left_waist_sheathe" then
            runtime.left_waist_draw_move_lock_until = runtime.time + resolve_number(spec.duration, 1.4333333)
        end
        if spec.layer == Constants.LAYER_ACTION and is_ground_attack_action_state(spec.to_state) then
            sync_base_anim_vars(self, runtime, get_layer_runtime(runtime, Constants.LAYER_BASE), context)
        end
        sync_add_layer_anim_vars(self, runtime)
    end

    if spec.layer == Constants.LAYER_ACTION then
        if PreviewConfig.EnableRuntimeAnimLog and spec.anim_asset and spec.anim_asset ~= "" then
            print_runtime(
                self,
                string.format(
                    "Layer Action Enter: %s state=%d event=%s anim=%s",
                    tostring(layer.state_name or spec.state_name or ""),
                    resolve_number(spec.to_state, 0),
                    tostring(layer.event or spec.event or event_name or ""),
                    tostring(spec.anim_asset)
                )
            )
        end
        set_anim_int(self, "StateStateId_StandMoveableAction", spec.to_state)
    elseif spec.layer == Constants.LAYER_BASE then
        if PreviewConfig.EnableRuntimeAnimLog then
            print_runtime(
                self,
                string.format(
                    "Layer Base Enter: %s state=%d event=%s dir=%d turn=%.1f",
                    tostring(layer.state_name or spec.state_name or ""),
                    resolve_number(spec.to_state, 0),
                    tostring(layer.event or spec.event or event_name or ""),
                    resolve_number(layer.direction, Constants.MOVE_DIRECTION_NONE),
                    resolve_number(layer.turn_angle, 0.0)
                )
            )
        end
    end

    runtime.fired_event_handlers.last_event_name = event_name
    runtime.fired_event_handlers.last_event_key = event_key
    runtime.fired_event_handlers.last_handled = true
    return true
end

function M.apply_spec(self, spec, context, event_key)
    if not self or not spec then
        return false
    end

    local runtime = ensure_runtime(self)
    local event_name = spec.event or event_key or ""
    return apply_layer_event(self, runtime, event_name, event_key, spec, context)
end

function M.deactivate_layer(self, layer_id, event_name)
    if not self or not layer_id then
        return false
    end

    local runtime = ensure_runtime(self)
    local layer = get_layer_runtime(runtime, layer_id)
    local default = LayerDefaults[layer_id] or LayerDefaults[Constants.LAYER_ACTION]
    layer.previous_state = layer.state
    layer.previous_direction = layer.direction
    layer.state = default.state
    layer.direction = default.direction
    layer.entered_at = runtime.time
    layer.elapsed = 0.0
    layer.event = event_name or default.event
    layer.state_name = default.state_name

    sync_state_machine(self, layer_id, layer)
    sync_add_layer_anim_vars(self, runtime)
    return true
end

function M.sync_anim_values(self, context)
    if not self then
        return false
    end

    local runtime = ensure_runtime(self)
    local layer = get_layer_runtime(runtime, Constants.LAYER_BASE)
    sync_base_anim_vars(self, runtime, layer, context)
    sync_add_layer_anim_vars(self, runtime)
    return true
end

function M.flush_request_pulses(self)
    local runtime = ensure_runtime(self)
    AnimVarWriter.flush_pulses(self, runtime)
    AnimVarWriter.apply_staged(self)
end

function M.clear_anim_requests(self)
    AnimVarWriter.clear_request_prefixes(self)
end

function M.tick(self, context)
    M.sync_anim_values(self, context)
    M.flush_request_pulses(self)
end

function M.reset_anim_values(self)
    if not self then
        return false
    end

    local runtime = ensure_runtime(self)
    local layer = get_layer_runtime(runtime, Constants.LAYER_BASE)
    sync_base_state_vars(self, layer)
    sync_add_layer_anim_vars(self, runtime)
    set_anim_bool(self, "FSM_ActionActive", false)
    set_anim_bool(self, "FSM_ActionIdleActive", true)
    set_anim_bool(self, "FSM_ActionLeftWaistDrawIdleActive", false)
    set_anim_bool(self, "FSM_ActionLeftWaistDrawMoveActive", false)
    set_anim_bool(self, "FSM_ActionLeftWaistSheatheIdleActive", false)
    set_anim_bool(self, "FSM_ActionLeftWaistSheatheMoveActive", false)
    set_anim_bool(self, "FSM_ActionDeflectGuardIdleActive", false)
    set_anim_bool(self, "FSM_ActionDeflectGuardMoveForwardActive", false)
    set_anim_bool(self, "FSM_ActionDeflectGuardMoveBackActive", false)
    set_anim_bool(self, "FSM_ActionDeflectGuardMoveLeftActive", false)
    set_anim_bool(self, "FSM_ActionDeflectGuardMoveRightActive", false)
    set_anim_bool(self, "FSM_ActionDeflectGuardToStandActive", false)
    set_anim_bool(self, "FSM_GroundAttackActive", false)
    set_anim_bool(self, "FSM_GroundAttackCombo1Active", false)
    set_anim_bool(self, "FSM_GroundAttackCombo1ReleaseActive", false)
    set_anim_bool(self, "FSM_GroundAttackCombo1ReverseActive", false)
    set_anim_bool(self, "FSM_GroundAttackCombo1ReverseReleaseActive", false)
    set_anim_bool(self, "FSM_GroundAttackCombo2Active", false)
    set_anim_bool(self, "FSM_GroundAttackCombo2ReleaseActive", false)
    set_anim_bool(self, "FSM_GroundAttackCombo2ReverseActive", false)
    set_anim_bool(self, "FSM_GroundAttackCombo2ReverseReleaseActive", false)
    set_anim_bool(self, "FSM_GroundAttackCombo3Active", false)
    set_anim_bool(self, "FSM_GroundAttackCombo4Active", false)
    set_anim_bool(self, "FSM_GroundAttackCombo5Active", false)
    set_anim_int(self, "FSM_ActionStateId", Constants.ACTION_STATE_IDLE)
    set_anim_bool(self, "FSM_ReactionActive", false)
    set_anim_int(self, "FSM_ReactionStateId", Constants.REACTION_STATE_IDLE)
    set_anim_bool(self, "FSM_MoveStartAutoExit", false)
    set_anim_float(self, "MoveSpeedLevel", 0.0)
    set_anim_float(self, "MoveSpeedLevelReal", 0.0)
    set_anim_float(self, "LocomotionWeaponBlend", get_locomotion_weapon_blend(runtime))
    set_anim_float(self, "MoveLoopPlayRate", 1.0)
    set_anim_int(self, "MoveSpeedIndex", Constants.MOVE_SPEED_INDEX_WALK)
    set_anim_int(self, "NightvisionMoveSpeedIndex", Constants.MOVE_SPEED_INDEX_WALK + 1)
    set_anim_int(self, "FSM_MoveStartSelectorId", Constants.MOVE_SPEED_INDEX_RUN * 10)
    set_anim_int(self, "FSM_MoveStartMotionSelectorId", Constants.MOVE_SPEED_INDEX_RUN * 10)
    set_anim_int(self, "FSM_MoveStartAnimeSelectorId", Constants.MOVE_SPEED_INDEX_RUN * 10)
    set_anim_float(self, "MoveStartMotionSelectorAngle", 0.0)
    set_anim_float(self, "MoveStartAnimeSelectorAngle", 0.0)
    sync_quick_turn_selector_flags(self, Constants.MOVE_DIRECTION_FORWARD)
    set_anim_float(self, "MoveDirection", Constants.MOVE_DIRECTION_FORWARD)
    set_anim_int(self, "MoveDirectionIndex", Constants.MOVE_DIRECTION_FORWARD)
    set_anim_float(self, "MoveAngle", 0.0)
    set_anim_float(self, "MoveLoopMotionSelectorAngle", 0.0)
    set_anim_float(self, "MoveLoopAnimeSelectorAngle", 0.0)
    set_anim_float(self, "TurnAngle", 0.0)
    set_anim_float(self, "TwistLowerRootAngle", 0.0)
    set_anim_int(self, "TurnType", 0)
    set_anim_int(self, "QuickTurnState", 0)
    set_anim_int(self, "Selector_UseTransitionEffect", SELECT_BLEND_SYNC)
    set_anim_int(self, "Selector_UseStaterToStateTransitionEffect", SELECT_STATE_TO_STATE_TAE_BLEND)
    set_anim_bool(self, "IsTurnTwist", false)
    set_anim_float(self, "TwistMasterAngle", 0.0)
    set_anim_float(self, "TwistUpperRootAngle", 0.0)
    set_anim_float(self, "MoveTwistAngle_Yaw", 0.0)
    set_anim_float(self, "MoveTwistAngle_Roll", 0.0)
    set_anim_int(self, "MoveType", 0)
    set_anim_int(self, "StanceMoveType", 0)
    set_anim_bool(self, "bSprintHeld", false)
    return true
end

function M.handle(self, event_name, event_key, context)
    if not self or not event_name or event_name == "" then
        return false
    end

    local spec, resolved_key = find_spec(event_name, event_key)
    if not spec then
        return false
    end

    local runtime = ensure_runtime(self)
    local handled = apply_layer_event(self, runtime, event_name, resolved_key, spec, context)
    return handled, resolved_key
end

return M
