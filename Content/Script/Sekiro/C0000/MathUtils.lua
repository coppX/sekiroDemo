local Constants = require("Sekiro.C0000.Constants")

local M = {}

function M.resolve_bool(value, default_value)
    if value == nil then
        return default_value
    end
    return value and true or false
end

function M.resolve_number(value, default_value)
    if value == nil then
        return default_value
    end

    local result = tonumber(value)
    if result == nil then
        return default_value
    end
    return result
end

function M.clamp01(value)
    return math.max(0.0, math.min(M.resolve_number(value, 0.0), 1.0))
end

function M.remap_range_clamped(value, start_value, end_value)
    local start_alpha = M.resolve_number(start_value, 0.0)
    local end_alpha = M.resolve_number(end_value, 1.0)
    if end_alpha <= start_alpha then
        return M.clamp01(value)
    end
    return M.clamp01((M.resolve_number(value, 0.0) - start_alpha) / (end_alpha - start_alpha))
end

function M.smooth_step(value)
    local clamped = M.clamp01(value)
    return clamped * clamped * (3.0 - 2.0 * clamped)
end

function M.clamp_intent(value)
    local number = M.resolve_number(value, 0)
    if number > 0 then
        return 1
    end
    if number < 0 then
        return -1
    end
    return 0
end

function M.converge_value(current, target, max_inc, max_dec, delta_seconds)
    current = M.resolve_number(current, target)
    target = M.resolve_number(target, 0.0)
    local delta = math.max(M.resolve_number(delta_seconds, 0.0), 0.0)

    if current < target then
        return math.min(current + math.abs(max_inc) * delta, target)
    end
    if target < current then
        return math.max(current - math.abs(max_dec) * delta, target)
    end
    return target
end

function M.ExtractTaeParamNumber(source_args, param_name)
    if not source_args or source_args == "" then
        return nil
    end

    local quoted = string.match(source_args, '"' .. param_name .. '"%s*:%s*"([^"]+)"')
    local value = quoted or string.match(source_args, param_name .. "%s*=%s*([%-%.%d]+)")
    return tonumber(value)
end

_G.resolve_bool = M.resolve_bool
_G.resolve_number = M.resolve_number
_G.clamp01 = M.clamp01
_G.remap_range_clamped = M.remap_range_clamped
_G.smooth_step = M.smooth_step
_G.clamp_intent = M.clamp_intent    
_G.converge_value = M.converge_value
_G.ExtractTaeParamNumber = M.ExtractTaeParamNumber

return M