local Constants = require("Sekiro.C0000.Constants")
require("Sekiro.C0000.MathUtils")
local StateUtils = require("Sekiro.C0000.StateUtils")
require("Sekiro.C0000.StateDefines")
local PreviewConfig = require("Sekiro.C0000.PreviewCharacterConfig")
require("Sekiro.C0000.MovementUtils")
local M = {}

M.LayerDefaults = {
    [Constants.LAYER_BASE] = {
        state = Constants.BASE_STATE_IDLE,
        previous_state = Constants.BASE_STATE_IDLE,
        direction = Constants.MOVE_DIRECTION_NONE,
        applied_yaw_delta = 0.0,
        event = "W_BaseIdle",
        state_name = "Idle",
        turn_angle = 0.0,
    },
    [Constants.LAYER_ACTION] = {
        state = Constants.ACTION_STATE_IDLE,
        previous_state = Constants.ACTION_STATE_IDLE,
        direction = Constants.MOVE_DIRECTION_NONE,
        applied_yaw_delta = 0.0,
        event = "ActionIdle",
        state_name = "ActionIdle",
    },
    [Constants.LAYER_REACTION] = {
        state = Constants.REACTION_STATE_IDLE,
        previous_state = Constants.REACTION_STATE_IDLE,
        direction = Constants.MOVE_DIRECTION_NONE,
        applied_yaw_delta = 0.0,
        event = "ReactionIdle",
        state_name = "ReactionIdle",
    },
}

function M.ensure_runtime(self)
    if self.Runtime then
        self.Runtime.input = self.Runtime.input or {}
        if self.Runtime.input.forward == nil then
            self.Runtime.input.forward = 0
        end
        if self.Runtime.input.right == nil then
            self.Runtime.input.right = 0
        end
        if self.Runtime.input.previous_forward == nil then
            self.Runtime.input.previous_forward = self.Runtime.input.forward or 0
        end
        if self.Runtime.input.previous_pure_forward == nil then
            self.Runtime.input.previous_pure_forward = 0
        end
        if self.Runtime.input.last_pure_forward == nil then
            self.Runtime.input.last_pure_forward = 0
        end
        self.Runtime.input.opposite_forward_back_until =
            resolve_number(self.Runtime.input.opposite_forward_back_until, 0.0)
        if self.Runtime.input.previous_right == nil then
            self.Runtime.input.previous_right = self.Runtime.input.right or 0
        end
        if self.Runtime.input.left_held == nil then
            self.Runtime.input.left_held = false
        end
        if self.Runtime.input.right_held == nil then
            self.Runtime.input.right_held = false
        end
        if self.Runtime.input.previous_left_held == nil then
            self.Runtime.input.previous_left_held = false
        end
        if self.Runtime.input.previous_right_held == nil then
            self.Runtime.input.previous_right_held = false
        end
        if self.Runtime.input.sprint == nil then
            self.Runtime.input.sprint = false
        end
        if self.Runtime.input.strength == nil then
            self.Runtime.input.strength = 0.0
        end
        if self.Runtime.input.previous_strength == nil then
            self.Runtime.input.previous_strength = 0.0
        end
        if self.Runtime.input.canceled_move_input == nil then
            self.Runtime.input.canceled_move_input = false
        end
        self.Runtime.input.suppress_move_until_input_released =
            resolve_bool(self.Runtime.input.suppress_move_until_input_released, false)
        if self.Runtime.input.direction == nil then
            self.Runtime.input.direction = Constants.MOVE_DIRECTION_NONE
        end
        self.Runtime.input.forward_left_source_until =
            resolve_number(self.Runtime.input.forward_left_source_until, 0.0)
        self.Runtime.input.forward_right_source_until =
            resolve_number(self.Runtime.input.forward_right_source_until, 0.0)
        if self.Runtime.input.move_angle == nil then
            self.Runtime.input.move_angle = 0.0
        end
        if self.Runtime.input.turn_angle == nil then
            self.Runtime.input.turn_angle = self.Runtime.input.move_angle
        end
        if self.Runtime.input.twist_angle == nil then
            self.Runtime.input.twist_angle = -self.Runtime.input.move_angle
        end
        self.Runtime.layers = self.Runtime.layers or {}
        for _, layer in pairs(self.Runtime.layers) do
            if layer.applied_yaw_delta == nil then
                layer.applied_yaw_delta = 0.0
            end
            if layer.turn_angle == nil then
                layer.turn_angle = 0.0
            end
        end
        self.Runtime.turn = self.Runtime.turn or {}
        if self.Runtime.turn.active == nil then
            self.Runtime.turn.active = false
        end
        self.Runtime.turn.event_key = self.Runtime.turn.event_key or ""
        self.Runtime.turn.source = self.Runtime.turn.source or ""
        self.Runtime.turn.exit_policy = self.Runtime.turn.exit_policy or ""
        self.Runtime.turn.turn_angle = resolve_number(self.Runtime.turn.turn_angle, 0.0)
        self.Runtime.turn.twist_angle = resolve_number(self.Runtime.turn.twist_angle, 0.0)
        self.Runtime.turn.applied_yaw_delta = resolve_number(self.Runtime.turn.applied_yaw_delta, 0.0)
        self.Runtime.turn.next_move_quick_turn_time = resolve_number(self.Runtime.turn.next_move_quick_turn_time, 0.0)
        self.Runtime.turn.ground_quick_turn_suppress_until = resolve_number(self.Runtime.turn.ground_quick_turn_suppress_until, 0.0)
        self.Runtime.turn.quick_turn_reentry_block_until = resolve_number(self.Runtime.turn.quick_turn_reentry_block_until, 0.0)
        self.Runtime.chain = self.Runtime.chain or {}
        self.Runtime.chain.active = resolve_bool(self.Runtime.chain.active, false)
        self.Runtime.chain.next_event = self.Runtime.chain.next_event or nil
        self.Runtime.chain.exit_time = resolve_number(self.Runtime.chain.exit_time, 0.0)
        self.Runtime.anim = self.Runtime.anim or {}
        if self.Runtime.anim.move_speed_level == nil then
            self.Runtime.anim.move_speed_level = 0.0
        end
        if self.Runtime.anim.move_speed_level_real == nil then
            self.Runtime.anim.move_speed_level_real = 0.0
        end
        if self.Runtime.anim.move_speed_index == nil then
            self.Runtime.anim.move_speed_index = Constants.MOVE_SPEED_INDEX_WALK
        end
        if self.Runtime.anim.move_loop_play_rate == nil then
            self.Runtime.anim.move_loop_play_rate = 1.0
        end
        if self.Runtime.anim.target_move_speed == nil then
            self.Runtime.anim.target_move_speed = 0.0
        end
        if self.Runtime.anim.last_direction == nil then
            self.Runtime.anim.last_direction = Constants.MOVE_DIRECTION_FORWARD
        end
        self.Runtime.movement_events = self.Runtime.movement_events or {}
        self.Runtime.movement_events.active_counts = self.Runtime.movement_events.active_counts or {}
        self.Runtime.movement_events.numeric_values = self.Runtime.movement_events.numeric_values or {}
        self.Runtime.movement_events.source_args = self.Runtime.movement_events.source_args or {}
        self.Runtime.movement_events.synthetic_pulses = self.Runtime.movement_events.synthetic_pulses or {}
        self.Runtime.weapon = self.Runtime.weapon or {
            left_waist_drawn = self.IsMortalBladeDrawn and self:IsMortalBladeDrawn() or false,
            pending_action_state = 0,
        }
        return self.Runtime
    end

    self.Runtime = {
        time = 0.0,
        input = {
            forward = 0,
            right = 0,
            previous_forward = 0,
            previous_pure_forward = 0,
            last_pure_forward = 0,
            opposite_forward_back_until = 0.0,
            previous_right = 0,
            left_held = false,
            right_held = false,
            previous_left_held = false,
            previous_right_held = false,
            sprint = false,
            strength = 0.0,
            previous_strength = 0.0,
            canceled_move_input = false,
            suppress_move_until_input_released = false,
            suppressed_target_direction = Constants.MOVE_DIRECTION_NONE,
            quick_turn_90_suppress_until = 0.0,
            direction = Constants.MOVE_DIRECTION_NONE,
            forward_left_source_until = 0.0,
            forward_right_source_until = 0.0,
            move_angle = 0.0,
            turn_angle = 0.0,
            twist_angle = 0.0,
        },
        layers = {
            [Constants.LAYER_BASE] = {
                state = Constants.BASE_STATE_IDLE,
                previous_state = Constants.BASE_STATE_IDLE,
                direction = Constants.MOVE_DIRECTION_NONE,
                applied_yaw_delta = 0.0,
                entered_at = 0.0,
                elapsed = 0.0,
                event = "W_BaseIdle",
                state_name = "Idle",
                turn_angle = 0.0,
            },
            [Constants.LAYER_ACTION] = {
                state = Constants.ACTION_STATE_IDLE,
                previous_state = Constants.ACTION_STATE_IDLE,
                direction = Constants.MOVE_DIRECTION_NONE,
                applied_yaw_delta = 0.0,
                entered_at = 0.0,
                elapsed = 0.0,
                event = "ActionIdle",
                state_name = "ActionIdle",
            },
            [Constants.LAYER_REACTION] = {
                state = Constants.REACTION_STATE_IDLE,
                previous_state = Constants.REACTION_STATE_IDLE,
                direction = Constants.MOVE_DIRECTION_NONE,
                applied_yaw_delta = 0.0,
                entered_at = 0.0,
                elapsed = 0.0,
                event = "ReactionIdle",
                state_name = "ReactionIdle",
            },
        },
        turn = {
            active = false,
            event_key = "",
            source = "",
            exit_policy = "",
            turn_angle = 0.0,
            twist_angle = 0.0,
            applied_yaw_delta = 0.0,
            source_direction = Constants.MOVE_DIRECTION_NONE,
            target_direction = Constants.MOVE_DIRECTION_NONE,
            next_move_quick_turn_time = 0.0,
            ground_quick_turn_suppress_until = 0.0,
            quick_turn_reentry_block_until = 0.0,
        },
        chain = {
            active = false,
            next_event = nil,
            exit_time = 0.0,
        },
        anim = {
            move_speed_level = 0.0,
            move_speed_level_real = 0.0,
            move_speed_index = Constants.MOVE_SPEED_INDEX_WALK,
            move_loop_play_rate = 1.0,
            target_move_speed = 0.0,
            last_direction = Constants.MOVE_DIRECTION_FORWARD,
        },
        facing = {
            direction = Constants.MOVE_DIRECTION_FORWARD,
        },
        movement_events = {
            active_counts = {},
            numeric_values = {},
            source_args = {},
            synthetic_pulses = {},
            behavior_ref_counts = {},
            behavior_ref_managed = {},
        },
        weapon = {
            left_waist_drawn = self.IsMortalBladeDrawn and self:IsMortalBladeDrawn() or false,
            pending_action_state = 0,
        },
        pending_request_clears = {},
    }

    return self.Runtime
end

function M.get_layer_runtime(runtime, layer_id)
    if not runtime.layers[layer_id] then
        local default = LayerDefaults[layer_id] or LayerDefaults[Constants.LAYER_BASE]
        runtime.layers[layer_id] = {
            state = default.state,
            previous_state = default.previous_state,
            direction = default.direction,
            applied_yaw_delta = default.applied_yaw_delta or 0.0,
            entered_at = runtime.time,
            elapsed = 0.0,
            event = default.event,
            state_name = default.state_name,
            turn_angle = 0.0,
        }
    end
    if runtime.layers[layer_id].applied_yaw_delta == nil then
        runtime.layers[layer_id].applied_yaw_delta = 0.0
    end
    if runtime.layers[layer_id].turn_angle == nil then
        runtime.layers[layer_id].turn_angle = 0.0
    end
    return runtime.layers[layer_id]
end

function M.get_state_machine(self)
    if self.GetSekiroLayeredStateMachine then
        return self:GetSekiroLayeredStateMachine()
    end
    return nil
end

function M.get_env_query(self)
    if self.GetSekiroEnvQuery then
        return self:GetSekiroEnvQuery()
    end
    return nil
end

function M.get_movement_event_runtime(runtime)
    runtime.movement_events = runtime.movement_events or {}
    runtime.movement_events.active_counts = runtime.movement_events.active_counts or {}
    runtime.movement_events.numeric_values = runtime.movement_events.numeric_values or {}
    runtime.movement_events.source_args = runtime.movement_events.source_args or {}
    runtime.movement_events.synthetic_pulses = runtime.movement_events.synthetic_pulses or {}
    runtime.movement_events.behavior_ref_counts = runtime.movement_events.behavior_ref_counts or {}
    runtime.movement_events.behavior_ref_managed = runtime.movement_events.behavior_ref_managed or {}
    return runtime.movement_events
end

function M.IsTaeBehaviorRefActive(runtime, behavior_ref_id)
    local events = get_movement_event_runtime(runtime)
    return resolve_number(events.behavior_ref_counts[behavior_ref_id], 0) > 0
end

function M.env(self, id, subkey)
    if id == 3036 then
        local runtime = ensure_runtime(self)
        if IsTaeBehaviorRefActive(runtime, subkey or 0) then
            return true
        end
    end

    local query = get_env_query(self)
    if not query then
        return false
    end

    local key = subkey or 0
    if id == 333 or id == 1108 then
        return query:EnvFloat(id, key)
    end
    if id == 105 then
        return query:EnvInt(id, key)
    end
    return query:EnvBool(id, key)
end


function M.clear_turn_runtime(runtime)
    runtime.turn = runtime.turn or {}
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

function M.clear_chain_runtime(runtime)
    runtime.chain = runtime.chain or {}
    runtime.chain.active = false
    runtime.chain.next_event = nil
    runtime.chain.exit_time = 0.0
end

function M.clear_ground_attack_runtime(runtime)
    runtime.ground_attack = runtime.ground_attack or {}
    runtime.ground_attack.pending_release = false
    runtime.ground_attack.pending_release_state = 0
    runtime.ground_attack.pending_attack = false
    runtime.ground_attack.pending_attack_state = 0
end

function M.is_ground_attack_end_base_settle_active(runtime)
    return runtime
        and runtime.ground_attack
        and runtime.time < resolve_number(runtime.ground_attack.base_settle_until, 0.0)
end

function M.begin_chain_runtime(runtime, spec)
    runtime.chain = runtime.chain or {}
    runtime.chain.active = true
    runtime.chain.next_event = spec.next_event
    runtime.chain.exit_time = resolve_number(spec.exit_time, resolve_number(spec.duration, 0.0))
end

function M.begin_turn_runtime(runtime, event_key, spec, context)
    runtime.turn = runtime.turn or {}
    runtime.turn.active = true
    runtime.turn.event_key = event_key or ""
    runtime.turn.source = spec.turn_source or ""
    runtime.turn.exit_policy = spec.exit_policy or ""
    runtime.turn.next_event = spec.next_event
    runtime.turn.turn_angle = resolve_number(context.turn_angle, resolve_number(context.move_angle, 0.0))
    runtime.turn.twist_angle = resolve_number(context.twist_angle, -runtime.turn.turn_angle)
    runtime.turn.applied_yaw_delta = 0.0
    runtime.turn.source_direction = context.facing_direction or Constants.MOVE_DIRECTION_NONE
    runtime.turn.target_direction = context.target_direction or Constants.MOVE_DIRECTION_NONE
end

function M.consume_reaction_event(self)
    if self.ConsumePreviewReactionEvent then
        return self:ConsumePreviewReactionEvent()
    end
    return ""
end

function M.consume_action_event(self)
    if self.ConsumePreviewActionEvent then
        return self:ConsumePreviewActionEvent()
    end
    return ""
end

function M.clear_queued_preview_events(self)
    if self.ClearPreviewQueuedEvents then
        self:ClearPreviewQueuedEvents()
        return
    end

    if self.ConsumePreviewActionEvent then
        self:ConsumePreviewActionEvent()
    end
    if self.ConsumePreviewReactionEvent then
        self:ConsumePreviewReactionEvent()
    end
end

function M:ReleaseLegacyPreviewMovementLock()
    if self.SetPreviewMovementLocked then
        pcall(function()
            self:SetPreviewMovementLocked(false)
        end)
    end
end

function M.GetEnemyAutoWeaponDistanceCm()
    return math.max(resolve_number(PreviewConfig.EnemyAutoWeaponDistanceCm, 500.0), 0.0)
end

function M.GetAttackFaceTargetDistanceCm()
    return math.max(resolve_number(AttackFaceTargetDistanceCm, 2500.0), 0.0)
end

function M.GetLocomotionWeaponBlendTarget(runtime)
    return runtime.weapon and runtime.weapon.left_waist_drawn and 1.0 or 0.0
end

function M.GetLocomotionWeaponBlend(runtime)
    return resolve_number(
        runtime.anim and runtime.anim.locomotion_weapon_blend,
        GetLocomotionWeaponBlendTarget(runtime)
    )
end

function M.UpdateLocomotionWeaponBlend(runtime, delta_seconds)
    local target = GetLocomotionWeaponBlendTarget(runtime)
    runtime.anim.locomotion_weapon_blend = converge_value(
        GetLocomotionWeaponBlend(runtime),
        target,
        LocomotionWeaponBlendRate,
        LocomotionWeaponBlendRate,
        delta_seconds
    )
    return runtime.anim.locomotion_weapon_blend
end

function M.GetLocomotionAnimAssetName(runtime, layer)
    local prefix = GetLocomotionWeaponBlend(runtime) >= 0.5 and "a000" or "a010"
    local state = layer and layer.state or Constants.BASE_STATE_IDLE
    if state == Constants.BASE_STATE_MOVE_START
        or state == Constants.BASE_STATE_QUICK_TURN_MOVE_START_180 then
        return string.format("%s_000400", prefix)
    end
    if state == Constants.BASE_STATE_MOVE_LOOP
        or state == Constants.BASE_STATE_MOVE_QUICK_TURN_180 then
        return string.format("%s_000500", prefix)
    end
    return "none"
end

function M.reset_runtime(self)
    local runtime = ensure_runtime(self)

    clear_queued_preview_events(self)

    runtime.time = 0.0
    runtime.input.forward = 0
    runtime.input.right = 0
    runtime.input.previous_forward = 0
    runtime.input.previous_pure_forward = 0
    runtime.input.last_pure_forward = 0
    runtime.input.opposite_forward_back_until = 0.0
    runtime.input.previous_right = 0
    runtime.input.left_held = false
    runtime.input.right_held = false
    runtime.input.previous_left_held = false
    runtime.input.previous_right_held = false
    runtime.input.sprint = false
    runtime.input.strength = 0.0
    runtime.input.previous_strength = 0.0
    runtime.input.canceled_move_input = false
    runtime.input.suppress_move_until_input_released = false
    runtime.input.suppressed_target_direction = Constants.MOVE_DIRECTION_NONE
    runtime.input.quick_turn_90_suppress_until = 0.0
    runtime.input.direction = Constants.MOVE_DIRECTION_NONE
    runtime.input.forward_left_source_until = 0.0
    runtime.input.forward_right_source_until = 0.0
    runtime.input.move_angle = 0.0
    runtime.input.turn_angle = 0.0
    runtime.input.twist_angle = 0.0
    runtime.layers = {}
    runtime.pending_request_clears = {}
    runtime.movement_events = {
        active_counts = {},
        numeric_values = {},
        source_args = {},
        synthetic_pulses = {},
        behavior_ref_counts = {},
        behavior_ref_managed = {},
    }
    runtime.weapon = {
        left_waist_drawn = self.IsMortalBladeDrawn and self:IsMortalBladeDrawn() or false,
        pending_action_state = 0,
    }
    clear_turn_runtime(runtime)
    clear_chain_runtime(runtime)
    runtime.turn.next_move_quick_turn_time = 0.0
    runtime.turn.quick_turn_reentry_block_until = 0.0
    runtime.turn.move_stop_restart_quick_turn_suppress_until = 0.0
    runtime.turn.diagonal_face_lerp_until = 0.0
    runtime.left_waist_draw_move_lock_until = 0.0
    ReleaseLegacyPreviewMovementLock(self)
    runtime.anim.move_speed_level = 0.0
    runtime.anim.move_speed_level_real = 0.0
    runtime.anim.locomotion_weapon_blend = GetLocomotionWeaponBlendTarget(runtime)
    runtime.anim.move_speed_index = Constants.MOVE_SPEED_INDEX_WALK
    runtime.anim.move_loop_play_rate = 1.0
    runtime.anim.target_move_speed = 0.0
    runtime.anim.last_direction = Constants.MOVE_DIRECTION_FORWARD
    runtime.facing = runtime.facing or {}
    local actor_facing_direction = Wasd90.resolve_actor_facing_direction(self)
    runtime.facing.direction = Wasd90.is_cardinal_move_direction(actor_facing_direction)
        and actor_facing_direction
        or Constants.MOVE_DIRECTION_FORWARD

    local state_machine = get_state_machine(self)
    if state_machine and state_machine.ResetLayerStates then
        state_machine:ResetLayerStates()
    end

    local layer = get_layer_runtime(runtime, Constants.LAYER_BASE)
    layer.state = Constants.BASE_STATE_IDLE
    layer.previous_state = Constants.BASE_STATE_IDLE
    layer.direction = Constants.MOVE_DIRECTION_NONE
    layer.applied_yaw_delta = 0.0
    layer.turn_angle = 0.0
    layer.entered_at = 0.0
    layer.elapsed = 0.0
    layer.event = "W_BaseIdle"
    layer.state_name = "Idle"

    local action_layer = get_layer_runtime(runtime, Constants.LAYER_ACTION)
    action_layer.state = Constants.ACTION_STATE_IDLE
    action_layer.previous_state = Constants.ACTION_STATE_IDLE
    action_layer.direction = Constants.MOVE_DIRECTION_NONE
    action_layer.applied_yaw_delta = 0.0
    action_layer.turn_angle = 0.0
    action_layer.entered_at = 0.0
    action_layer.elapsed = 0.0
    action_layer.event = "ActionIdle"
    action_layer.state_name = "ActionIdle"

    local reaction_layer = get_layer_runtime(runtime, Constants.LAYER_REACTION)
    reaction_layer.state = Constants.REACTION_STATE_IDLE
    reaction_layer.previous_state = Constants.REACTION_STATE_IDLE
    reaction_layer.direction = Constants.MOVE_DIRECTION_NONE
    reaction_layer.applied_yaw_delta = 0.0
    reaction_layer.turn_angle = 0.0
    reaction_layer.entered_at = 0.0
    reaction_layer.elapsed = 0.0
    reaction_layer.event = "ReactionIdle"
    reaction_layer.state_name = "ReactionIdle"

    if state_machine and state_machine.SetLayerState then
        state_machine:SetLayerState(
            Constants.LAYER_BASE,
            Constants.BASE_STATE_IDLE,
            "Idle",
            "W_BaseIdle",
            Constants.MOVE_DIRECTION_NONE
        )
        state_machine:SetLayerState(
            Constants.LAYER_ACTION,
            Constants.ACTION_STATE_IDLE,
            "ActionIdle",
            "ActionIdle",
            Constants.MOVE_DIRECTION_NONE
        )
        state_machine:SetLayerState(
            Constants.LAYER_REACTION,
            Constants.REACTION_STATE_IDLE,
            "ReactionIdle",
            "ReactionIdle",
            Constants.MOVE_DIRECTION_NONE
        )
    end

    require("Sekiro.C0000.FireEventHandlers").reset_anim_values(self)

    if self.SetPreviewMoveSpeed then
        self:SetPreviewMoveSpeed(WALK_SPEED)
    end
end


function M.is_turn90_event_key(event_key)
    return event_key == "BaseQuickTurnLeft90"
        or event_key == "BaseQuickTurnRight90"
        or event_key == "BaseMoveStartQuickTurnLeft90"
        or event_key == "BaseMoveStartQuickTurnRight90"
        or event_key == "BaseForwardLeftBackQuickTurnLeft90"
        or event_key == "BaseForwardRightBackQuickTurnRight90"
end

function M.is_move_start_quick_turn_bridge_event_key(event_key)
    return event_key == "BaseMoveStartQuickTurnLeft90_Bridge"
        or event_key == "BaseMoveStartQuickTurnRight90_Bridge"
end

M.is_quick_turn_state = StateUtils.is_quick_turn_state
M.is_valid_direction = StateUtils.is_valid_direction
M.is_cardinal_direction = StateUtils.is_cardinal_direction
M.is_deflect_guard_action_state = StateUtils.is_deflect_guard_action_state
M.resolve_cardinal_direction_from_axes = StateUtils.resolve_cardinal_direction_from_axes
M.state_accepts_direction = StateUtils.state_accepts_direction

_G.LayerDefaults = M.LayerDefaults
_G.ensure_runtime = M.ensure_runtime
_G.get_layer_runtime = M.get_layer_runtime
_G.get_state_machine = M.get_state_machine
_G.get_env_query = M.get_env_query
_G.get_movement_event_runtime = M.get_movement_event_runtime
_G.IsTaeBehaviorRefActive = M.IsTaeBehaviorRefActive
_G.env = M.env
_G.is_quick_turn_state = M.is_quick_turn_state
_G.clear_turn_runtime = M.clear_turn_runtime
_G.clear_chain_runtime = M.clear_chain_runtime
_G.clear_ground_attack_runtime = M.clear_ground_attack_runtime
_G.is_ground_attack_end_base_settle_active = M.is_ground_attack_end_base_settle_active
_G.begin_chain_runtime = M.begin_chain_runtime
_G.begin_turn_runtime = M.begin_turn_runtime
_G.consume_reaction_event = M.consume_reaction_event
_G.consume_action_event = M.consume_action_event
_G.clear_queued_preview_events = M.clear_queued_preview_events
_G.ReleaseLegacyPreviewMovementLock = M.ReleaseLegacyPreviewMovementLock
_G.GetEnemyAutoWeaponDistanceCm = M.GetEnemyAutoWeaponDistanceCm
_G.GetAttackFaceTargetDistanceCm = M.GetAttackFaceTargetDistanceCm
_G.GetLocomotionWeaponBlendTarget = M.GetLocomotionWeaponBlendTarget
_G.GetLocomotionWeaponBlend = M.GetLocomotionWeaponBlend
_G.UpdateLocomotionWeaponBlend = M.UpdateLocomotionWeaponBlend
_G.GetLocomotionAnimAssetName = M.GetLocomotionAnimAssetName
_G.reset_runtime = M.reset_runtime
_G.is_valid_direction = M.is_valid_direction
_G.is_cardinal_direction = M.is_cardinal_direction
_G.is_deflect_guard_action_state = M.is_deflect_guard_action_state
_G.resolve_cardinal_direction_from_axes = M.resolve_cardinal_direction_from_axes
_G.is_turn90_event_key = M.is_turn90_event_key
_G.is_move_start_quick_turn_bridge_event_key = M.is_move_start_quick_turn_bridge_event_key
_G.state_accepts_direction = M.state_accepts_direction

return M
