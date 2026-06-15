local Constants = require("Sekiro.C0000.Constants")
require("Sekiro.C0000.MathUtils")

local M = {}

local WALK_SPEED = 162.0
local WALK_SIDE_SPEED = 151.0
local RUN_SPEED = 555.0
local RUN_SIDE_SPEED = 423.0
local MOVE_START_MOVEMENT_RAMP_SECONDS = 0.55
local MOVE_START_MOVEMENT_MIN_SCALE = 0.28

M.WALK_SPEED = WALK_SPEED
M.WALK_SIDE_SPEED = WALK_SIDE_SPEED
M.RUN_SPEED = RUN_SPEED
M.RUN_SIDE_SPEED = RUN_SIDE_SPEED

function M.get_move_speed_level_target(context)
    local input_strength = math.max(resolve_number(context and context.input_strength, 0.0), 0.0)
    if not context or not context.wants_move then
        return 0.0
    end
    return math.max(input_strength, 1.0)
end

function M.resolve_move_speed_index(raw_speed_level, previous_index)
    local current_index = resolve_number(previous_index, Constants.MOVE_SPEED_INDEX_WALK)
    if current_index == Constants.MOVE_SPEED_INDEX_WALK then
        if raw_speed_level > Constants.PRM_RUN_STICK_LEVEL_WALK_TO_RUN then
            return Constants.MOVE_SPEED_INDEX_RUN
        end
        return Constants.MOVE_SPEED_INDEX_WALK
    end
    if raw_speed_level > Constants.PRM_RUN_STICK_LEVEL_RUN_TO_WALK then
        return Constants.MOVE_SPEED_INDEX_RUN
    end
    return Constants.MOVE_SPEED_INDEX_WALK
end

function M.get_move_speed_level_real(current_speed, raw_speed_level, delta_seconds)
    local inc_rate = raw_speed_level >= 1.0 and 6.0 or 3.0
    return converge_value(current_speed, raw_speed_level, inc_rate, 3.0, delta_seconds)
end

function M.get_run_alpha(move_speed_level_real)
    local walk_level = math.max(resolve_number(Constants.PRM_RUN_STICK_LEVEL, 0.75), 0.01)
    local denom = math.max(1.0 - walk_level, 0.01)
    if move_speed_level_real <= walk_level then
        return 0.0
    end
    return math.min((move_speed_level_real - walk_level) / denom, 1.0)
end

local function get_directional_locomotion_speeds(direction)
    if direction == Constants.MOVE_DIRECTION_BACK
        or direction == Constants.MOVE_DIRECTION_LEFT
        or direction == Constants.MOVE_DIRECTION_RIGHT then
        return WALK_SIDE_SPEED, RUN_SIDE_SPEED
    end
    if direction == Constants.MOVE_DIRECTION_FORWARD_LEFT
        or direction == Constants.MOVE_DIRECTION_FORWARD_RIGHT
        or direction == Constants.MOVE_DIRECTION_BACK_LEFT
        or direction == Constants.MOVE_DIRECTION_BACK_RIGHT then
        return (WALK_SPEED + WALK_SIDE_SPEED) * 0.5, (RUN_SPEED + RUN_SIDE_SPEED) * 0.5
    end
    return WALK_SPEED, RUN_SPEED
end

function M.get_target_move_speed(move_speed_level_real, direction)
    if move_speed_level_real <= 0.0 then
        return 0.0
    end
    local run_alpha = M.get_run_alpha(move_speed_level_real)
    local walk_speed, run_speed = get_directional_locomotion_speeds(direction)
    return walk_speed + (run_speed - walk_speed) * run_alpha
end

function M.get_movement_input_scale(move_speed_level_real)
    if move_speed_level_real <= 0.0 then
        return 0.0
    end
    return 1.0
end

function M.get_move_loop_play_rate(move_speed_level_real)
    return 1.0
end

function M.get_move_start_movement_scale(layer)
    if not layer or layer.state ~= Constants.BASE_STATE_MOVE_START then
        return 1.0
    end

    local alpha = math.min(
        math.max(resolve_number(layer.elapsed, 0.0) / MOVE_START_MOVEMENT_RAMP_SECONDS, 0.0),
        1.0
    )
    local smooth_alpha = smooth_step(alpha)
    return MOVE_START_MOVEMENT_MIN_SCALE
        + (1.0 - MOVE_START_MOVEMENT_MIN_SCALE) * smooth_alpha
end

_G.get_move_speed_level_target = M.get_move_speed_level_target
_G.resolve_move_speed_index = M.resolve_move_speed_index
_G.get_move_speed_level_real = M.get_move_speed_level_real
_G.get_run_alpha = M.get_run_alpha
_G.get_target_move_speed = M.get_target_move_speed
_G.get_movement_input_scale = M.get_movement_input_scale
_G.get_move_loop_play_rate = M.get_move_loop_play_rate
_G.get_move_start_movement_scale = M.get_move_start_movement_scale
_G.WALK_SPEED = WALK_SPEED
_G.RUN_SPEED = RUN_SPEED

return M
