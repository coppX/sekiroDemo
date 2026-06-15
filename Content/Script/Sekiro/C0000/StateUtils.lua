local Constants = require("Sekiro.C0000.Constants")
require("Sekiro.C0000.MathUtils")
require("Sekiro.C0000.StateDefines")

local M = {}

function M.is_ground_attack_combo12_no_turn_state(action_state)
    return action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_1
        or action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_1_RELEASE
        or action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_1_REVERSE
        or action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_1_REVERSE_RELEASE
        or action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_2
        or action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_2_RELEASE
        or action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_2_REVERSE
        or action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_2_REVERSE_RELEASE
end


function M.is_ground_attack_action_state(action_state)
    return action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_1
        or action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_1_RELEASE
        or action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_1_REVERSE
        or action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_1_REVERSE_RELEASE
        or action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_2
        or action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_2_RELEASE
        or action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_2_REVERSE
        or action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_2_REVERSE_RELEASE
        or action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_3
        or action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_4
        or action_state == Constants.ACTION_STATE_GROUND_ATTACK_COMBO_5
end

function M.is_quick_turn_state(state_id)
    return state_id == Constants.BASE_STATE_QUICK_TURN_90
        or state_id == Constants.BASE_STATE_QUICK_TURN_180
        or state_id == Constants.BASE_STATE_QUICK_TURN_MOVE_START_180
        or state_id == Constants.BASE_STATE_MOVE_QUICK_TURN_180
end

function M.state_accepts_direction(state_id)
    return M.is_quick_turn_state(state_id)
end

function M.state_samples_input_direction(state_id)
    return state_id == Constants.BASE_STATE_MOVE_START
        or state_id == Constants.BASE_STATE_MOVE_LOOP
        or state_id == Constants.BASE_STATE_MOVE_STOP
        or M.state_accepts_direction(state_id)
end

function M.state_remembers_input_direction(state_id)
    return M.state_samples_input_direction(state_id)
end

function M.state_uses_direction(state_id)
    return M.state_accepts_direction(state_id)
end

function M.is_valid_direction(direction)
    return direction ~= nil
        and direction ~= Constants.MOVE_DIRECTION_NONE
        and DirectionStateOffsets[direction] ~= nil
end

function M.is_cardinal_direction(direction)
    return direction == Constants.MOVE_DIRECTION_FORWARD
        or direction == Constants.MOVE_DIRECTION_BACK
        or direction == Constants.MOVE_DIRECTION_LEFT
        or direction == Constants.MOVE_DIRECTION_RIGHT
end

function M.is_deflect_guard_action_state(state_id)
    return state_id == Constants.ACTION_STATE_DEFLECT_GUARD_IDLE
        or state_id == Constants.ACTION_STATE_DEFLECT_GUARD_MOVE_FORWARD
        or state_id == Constants.ACTION_STATE_DEFLECT_GUARD_MOVE_BACK
        or state_id == Constants.ACTION_STATE_DEFLECT_GUARD_MOVE_LEFT
        or state_id == Constants.ACTION_STATE_DEFLECT_GUARD_MOVE_RIGHT
end

function M.resolve_cardinal_direction_from_axes(forward, right)
    forward = resolve_number(forward, 0)
    right = resolve_number(right, 0)
    if forward > 0 and right == 0 then
        return Constants.MOVE_DIRECTION_FORWARD
    end
    if forward < 0 and right == 0 then
        return Constants.MOVE_DIRECTION_BACK
    end
    if forward == 0 and right < 0 then
        return Constants.MOVE_DIRECTION_LEFT
    end
    if forward == 0 and right > 0 then
        return Constants.MOVE_DIRECTION_RIGHT
    end
    return Constants.MOVE_DIRECTION_NONE
end

_G.is_ground_attack_combo12_no_turn_state = M.is_ground_attack_combo12_no_turn_state
_G.is_ground_attack_action_state = M.is_ground_attack_action_state
_G.is_quick_turn_state = M.is_quick_turn_state
_G.state_accepts_direction = M.state_accepts_direction
_G.state_samples_input_direction = M.state_samples_input_direction
_G.state_remembers_input_direction = M.state_remembers_input_direction
_G.state_uses_direction = M.state_uses_direction
_G.is_valid_direction = M.is_valid_direction
_G.is_cardinal_direction = M.is_cardinal_direction
_G.is_deflect_guard_action_state = M.is_deflect_guard_action_state
_G.resolve_cardinal_direction_from_axes = M.resolve_cardinal_direction_from_axes

return M
