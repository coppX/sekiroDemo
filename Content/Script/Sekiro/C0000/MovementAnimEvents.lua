require("Sekiro.C0000.MathUtils")
require("Sekiro.C0000.AnimRuntime")

local M = {}

M.EVENT_LS_MOVE_QUEUED = "Sekiro_LSMoveQueued"
M.EVENT_DISABLE_TURNING = "Sekiro_DisableTurning"
M.EVENT_DISABLE_MOVEMENT = "Sekiro_DisableMovement"
M.EVENT_SET_TURN_SPEED = "Sekiro_SetTurnSpeed"
M.EVENT_MOVE_MULTIPLIER = "Sekiro_MoveMultiplier"
M.EVENT_LIMIT_WALK = "Sekiro_LimitMoveSpeedToWalk"
M.EVENT_DISABLE_DIRECTION_CHANGE = "Sekiro_DisableDirectionChange"
M.EVENT_MOVE_START_TO_LOOP = "Sekiro_MoveStartToMoveLoop"
M.EVENT_STAMINA_CONTROL = "Sekiro_StaminaControlParam"
M.EVENT_PC_BEHAVIOR = "Sekiro_PCBehavior"
M.EVENT_BLEND_TO_IDLE_OR_MOVEMENT_ANIM = "Sekiro_BlendToIdleOrMovementAnim"
M.EVENT_FACIAL_EXPRESSION_ADDITIVE = "Sekiro_FacialExpressionAdditive"
M.EVENT_ANIM_CANCEL_START_R1_R2_LIGHT_KICK_HEAVY_KICK = "InvokeAnimCancelStart_R1_R2_LightKick_HeavyKick"
M.EVENT_ANIM_CANCEL_START_L1_L2 = "InvokeAnimCancelStart_L1_L2"
M.EVENT_ANIM_CANCEL_START_MAGIC_R_MAGIC_L = "InvokeAnimCancelStart_MagicR_MagicL"
M.EVENT_ANIM_CANCEL_START_GUARD = "InvokeAnimCancelStart_Guard"
M.EVENT_ANIM_CANCEL_START_SP_MOVE_BACKSTEP_ROLLING_JUMP = "InvokeAnimCancelStart_SpMove_Backstep_Rolling_Jump"
M.EVENT_ANIM_CANCEL_START_USE_ITEM = "InvokeAnimCancelStart_UseItem"
M.EVENT_ANIM_CANCEL_START_L2 = "InvokeAnimCancelStart_L2"
M.EVENT_ANIM_CANCEL_START_USE_ITEM_BY_GOODS_PARAM = "InvokeAnimCancelStart_UseItem_ByGoodsParam"
M.EVENT_ANIM_CANCEL_START_EMERGENCY_STEP = "InvokeAnimCancelStart_EmergencyStep"
M.EVENT_ANIM_CANCEL_START_L1_L2_BY_WEAPON_PARAM = "InvokeAnimCancelStart_L1_L2_ByWeaponParam"
M.EVENT_ANIM_CANCEL_END_WITH_KEYBOARD_KEY = "InvokeAnimCancelEndWithKeyboardKey"
M.EVENT_ANIM_CANCEL_END_USE_ITEM = "InvokeAnimCancelEnd_UseItem"
M.EVENT_ANIM_CANCEL_END_GENERAL = "InvokeAnimCancelEnd_General"
M.EVENT_ANIM_CANCEL_END_L2_VARIANT = "InvokeAnimCancelEnd_L2_HksSet2011"
M.EVENT_ANIM_CANCEL_END_USE_ITEM_BY_GOODS_PARAM = "InvokeAnimCancelEnd_UseItem_ByGoodsParam"
M.EVENT_ANIM_CANCEL_END_EMERGENCY_STEP = "InvokeAnimCancelEnd_EmergencyStep"
M.EVENT_ANIM_CANCEL_END_R1_LIGHT_KICK = "InvokeAnimCancelEnd_R1_LightKick"
M.EVENT_ANIM_CANCEL_END_R2_HEAVY_KICK = "InvokeAnimCancelEnd_R2_HeavyKick"
M.EVENT_ANIM_CANCEL_END_L1 = "InvokeAnimCancelEnd_L1"
M.EVENT_ANIM_CANCEL_END_L2 = "InvokeAnimCancelEnd_L2"
M.EVENT_ANIM_CANCEL_END_EXTRA_L1_L2_BY_WEAPON_PARAM = "InvokeAnimCancelEndExtra_L1_L2_ByWeaponParam"
M.EVENT_ANIM_CANCEL_END_R2_PROSTHETIC = "InvokeAnimCancelEnd_R2_Prosthetic"
M.EVENT_ANIM_CANCEL_END_DEATHBLOW = "InvokeAnimCancelEnd_Deathblow"

local DEFAULT_TURN_SPEED = 1440.0

local SpEffectBehaviorRefIds = {
    [100274] = 227,
    [100296] = 231,
    [100338] = 208,
    [100357] = 215,
    [100358] = 216,
    [100360] = 217,
    [100361] = 218,
    [100367] = 221,
    [100368] = 311,
    [100397] = 318,
}

local TaeCancelEventAliases = {
    [1] = M.EVENT_ANIM_CANCEL_START_R1_R2_LIGHT_KICK_HEAVY_KICK,
    [6] = M.EVENT_ANIM_CANCEL_END_WITH_KEYBOARD_KEY,
    [9] = M.EVENT_ANIM_CANCEL_START_L1_L2,
    [10] = M.EVENT_ANIM_CANCEL_START_MAGIC_R_MAGIC_L,
    [21] = M.EVENT_ANIM_CANCEL_START_GUARD,
    [25] = M.EVENT_ANIM_CANCEL_START_SP_MOVE_BACKSTEP_ROLLING_JUMP,
    [30] = M.EVENT_ANIM_CANCEL_START_USE_ITEM,
    [31] = M.EVENT_ANIM_CANCEL_END_USE_ITEM,
    [34] = M.EVENT_ANIM_CANCEL_END_GENERAL,
    [103] = M.EVENT_ANIM_CANCEL_END_L2,
    [104] = M.EVENT_ANIM_CANCEL_END_L2_VARIANT,
    [105] = M.EVENT_ANIM_CANCEL_START_L2,
    [107] = M.EVENT_ANIM_CANCEL_END_USE_ITEM_BY_GOODS_PARAM,
    [108] = M.EVENT_ANIM_CANCEL_START_USE_ITEM_BY_GOODS_PARAM,
    [111] = M.EVENT_ANIM_CANCEL_START_EMERGENCY_STEP,
    [112] = M.EVENT_ANIM_CANCEL_END_EMERGENCY_STEP,
    [115] = M.EVENT_ANIM_CANCEL_END_R1_LIGHT_KICK,
    [116] = M.EVENT_ANIM_CANCEL_END_R2_HEAVY_KICK,
    [117] = M.EVENT_ANIM_CANCEL_END_L1,
    [118] = M.EVENT_ANIM_CANCEL_END_L2,
    [120] = M.EVENT_ANIM_CANCEL_START_L1_L2_BY_WEAPON_PARAM,
    [121] = M.EVENT_ANIM_CANCEL_END_EXTRA_L1_L2_BY_WEAPON_PARAM,
    [137] = M.EVENT_ANIM_CANCEL_END_R2_PROSTHETIC,
    [154] = M.EVENT_ANIM_CANCEL_END_DEATHBLOW,
}

function M.get_tae_behavior_ref_id(event_name, numeric_value, source_args)
    local event_name_text = tostring(event_name or "")
    local tae_type, tae_jump_table = string.match(event_name_text, "^TAE_(%d+)_(%d+)$")
    tae_type = tonumber(tae_type) or tonumber(string.match(event_name_text, "^TAE_(%d+)$"))
    if tae_type == nil then
        tae_type = tonumber(numeric_value)
    end
    if tae_type == nil then
        return nil
    end

    if tae_type == 0 then
        return ExtractTaeParamNumber(source_args, "JumpTableID")
            or tonumber(tae_jump_table)
            or tonumber(numeric_value)
    end

    if tae_type == 66 or tae_type == 67 or tae_type == 302 or tae_type == 401 or tae_type == 797 or tae_type == 940 then
        local sp_effect_id = ExtractTaeParamNumber(source_args, "SpEffectID")
        if sp_effect_id ~= nil then
            return SpEffectBehaviorRefIds[math.floor(sp_effect_id)] or sp_effect_id
        end
        return tae_type
    end

    return tae_type
end

function M.set_tae_behavior_ref_active(events, event_name, active, numeric_value, source_args)
    local behavior_ref_id = M.get_tae_behavior_ref_id(event_name, numeric_value, source_args)
    if behavior_ref_id == nil then
        return
    end

    local key = math.floor(behavior_ref_id)
    local counts = events.behavior_ref_counts
    events.behavior_ref_managed[key] = true
    local current_count = resolve_number(counts[key], 0)
    if active then
        counts[key] = current_count + 1
        return
    end

    local next_count = math.max(current_count - 1, 0)
    if next_count <= 0 then
        counts[key] = nil
    else
        counts[key] = next_count
    end
end

function M.set_active(runtime, event_name, active, numeric_value, source_args, skip_behavior_ref)
    if not event_name or event_name == "" then
        return
    end

    local events = get_movement_event_runtime(runtime)
    if not skip_behavior_ref then
        M.set_tae_behavior_ref_active(events, event_name, active, numeric_value, source_args)
    end

    local active_counts = events.active_counts
    local current_count = resolve_number(active_counts[event_name], 0)
    if active then
        active_counts[event_name] = current_count + 1
        events.numeric_values[event_name] = resolve_number(numeric_value, 0.0)
        events.source_args[event_name] = source_args or ""
        return
    end

    local next_count = math.max(current_count - 1, 0)
    if next_count <= 0 then
        active_counts[event_name] = nil
        events.numeric_values[event_name] = nil
        events.source_args[event_name] = nil
    else
        active_counts[event_name] = next_count
    end
end

function M.set_tae_alias_active(runtime, event_name, active, source_args)
    local event_name_text = tostring(event_name or "")
    local tae_cancel_id = tonumber(string.match(event_name_text, "^TAE_0_(%d+)$"))
        or tonumber(string.match(event_name_text, "^TAE_(%d+)$"))
    local tae_cancel_event = tae_cancel_id and TaeCancelEventAliases[tae_cancel_id] or nil
    if tae_cancel_event then
        M.set_active(runtime, tae_cancel_event, active, 0.0, source_args, true)
    end

    if event_name_text == "TAE_0_7" then
        M.set_active(runtime, M.EVENT_DISABLE_TURNING, active, 0.0, source_args, true)
    elseif event_name_text == "TAE_224" then
        M.set_active(
            runtime,
            M.EVENT_SET_TURN_SPEED,
            active,
            ExtractTaeParamNumber(source_args, "TurnSpeed") or DEFAULT_TURN_SPEED,
            source_args,
            true
        )
    elseif event_name_text == "TAE_760" then
        local enabled = tostring(source_args or ""):match("IsEnable%s*=%s*True") ~= nil
        M.set_active(
            runtime,
            M.EVENT_MOVE_MULTIPLIER,
            active and enabled,
            ExtractTaeParamNumber(source_args, "0x1BC") or 1.0,
            source_args,
            true
        )
    elseif event_name_text == "TAE_960" then
        M.set_active(
            runtime,
            M.EVENT_STAMINA_CONTROL,
            active,
            ExtractTaeParamNumber(source_args, "StaminaRatioType")
                or ExtractTaeParamNumber(source_args, "Unk00")
                or ExtractTaeParamNumber(source_args, "field_0")
                or 0.0,
            source_args,
            true
        )
    elseif event_name_text == "TAE_307" then
        M.set_active(runtime, M.EVENT_PC_BEHAVIOR, active, 0.0, source_args, true)
    elseif event_name_text == "TAE_605" then
        M.set_active(
            runtime,
            M.EVENT_BLEND_TO_IDLE_OR_MOVEMENT_ANIM,
            active,
            ExtractTaeParamNumber(source_args, "AnimID") or 0.0,
            source_args,
            true
        )
    elseif event_name_text == "TAE_607" then
        M.set_active(
            runtime,
            M.EVENT_FACIAL_EXPRESSION_ADDITIVE,
            active,
            ExtractTaeParamNumber(source_args, "Unk00") or 0.0,
            source_args,
            true
        )
    end
end

function M.has(runtime, event_name)
    local events = get_movement_event_runtime(runtime)
    return resolve_number(events.active_counts[event_name], 0) > 0
end

function M.pulse(runtime, event_name, numeric_value, source_args)
    M.set_active(runtime, event_name, true, numeric_value, source_args)
    local events = get_movement_event_runtime(runtime)
    events.synthetic_pulses[event_name] =
        resolve_number(events.synthetic_pulses[event_name], 0) + 1
end

function M.clear_synthetic(runtime)
    local events = get_movement_event_runtime(runtime)
    for event_name, count in pairs(events.synthetic_pulses) do
        local pulse_count = resolve_number(count, 0)
        for _ = 1, pulse_count do
            M.set_active(runtime, event_name, false, 0.0, "SyntheticEnd")
        end
        events.synthetic_pulses[event_name] = nil
    end
end

function M.get_value(runtime, event_name, default_value)
    local events = get_movement_event_runtime(runtime)
    if resolve_number(events.active_counts[event_name], 0) <= 0 then
        return default_value
    end
    return resolve_number(events.numeric_values[event_name], default_value)
end

function M.is_turning_locked(runtime)
    if M.has(runtime, M.EVENT_DISABLE_TURNING)
        or M.has(runtime, M.EVENT_DISABLE_DIRECTION_CHANGE) then
        return true
    end

    return M.has(runtime, M.EVENT_SET_TURN_SPEED)
        and M.get_value(runtime, M.EVENT_SET_TURN_SPEED, DEFAULT_TURN_SPEED) <= 0.0
end

function M.get_turn_speed(runtime)
    return math.max(M.get_value(runtime, M.EVENT_SET_TURN_SPEED, DEFAULT_TURN_SPEED), 0.0)
end

function M.get_move_scale(runtime, base_scale, allow_disabled_movement)
    local scale = resolve_number(base_scale, 0.0)
    if M.has(runtime, M.EVENT_DISABLE_MOVEMENT) and not allow_disabled_movement then
        return 0.0
    end
    if M.has(runtime, M.EVENT_LIMIT_WALK) then
        scale = math.min(scale, 1.0)
    end
    if M.has(runtime, M.EVENT_MOVE_MULTIPLIER) then
        scale = scale * math.max(M.get_value(runtime, M.EVENT_MOVE_MULTIPLIER, 1.0), 0.0)
    end
    return scale
end

return M
