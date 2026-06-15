local M = {}

local DEFAULT_PULSE_SECONDS = 0.20

local function resolve_number(value, default_value)
    if value == nil then
        return default_value
    end
    local number = tonumber(value)
    if number == nil then
        return default_value
    end
    return number
end

local function ensure_pending_request_clears(runtime)
    if runtime then
        runtime.pending_request_clears = runtime.pending_request_clears or {}
        return runtime.pending_request_clears
    end
    return nil
end

local function ensure_runtime(self)
    if not self then
        return nil
    end
    self.Runtime = self.Runtime or {}
    return self.Runtime
end

local function ensure_staged(runtime, type_name)
    if not runtime then
        return nil
    end
    runtime.staged_anim_vars = runtime.staged_anim_vars or {
        ints = {},
        bools = {},
        floats = {},
    }
    runtime.staged_anim_vars[type_name] = runtime.staged_anim_vars[type_name] or {}
    return runtime.staged_anim_vars[type_name]
end

function M.set_int(self, var_name, value)
    if self and self.SetAnimIntVar then
        self:SetAnimIntVar(var_name, math.floor(resolve_number(value, 0)))
    end
end

function M.stage_int(self, var_name, value)
    local staged = ensure_staged(ensure_runtime(self), "ints")
    if staged and var_name and var_name ~= "" then
        staged[var_name] = math.floor(resolve_number(value, 0))
    end
end

function M.set_bool(self, var_name, value)
    if self and self.SetAnimBoolVar then
        self:SetAnimBoolVar(var_name, value and true or false)
    end
end

function M.stage_bool(self, var_name, value)
    local staged = ensure_staged(ensure_runtime(self), "bools")
    if staged and var_name and var_name ~= "" then
        staged[var_name] = value and true or false
    end
end

function M.set_float(self, var_name, value)
    if self and self.SetAnimFloatVar then
        self:SetAnimFloatVar(var_name, resolve_number(value, 0.0))
    end
end

function M.stage_float(self, var_name, value)
    local staged = ensure_staged(ensure_runtime(self), "floats")
    if staged and var_name and var_name ~= "" then
        staged[var_name] = resolve_number(value, 0.0)
    end
end

function M.pulse_bool(self, runtime, var_name, pulse_seconds)
    if not var_name or var_name == "" then
        return
    end

    M.stage_bool(self, var_name, true)
    local pending = ensure_pending_request_clears(runtime)
    if pending then
        pending[var_name] = resolve_number(runtime and runtime.time, 0.0)
            + resolve_number(pulse_seconds, DEFAULT_PULSE_SECONDS)
    end
end

function M.flush_pulses(self, runtime)
    local pending = ensure_pending_request_clears(runtime)
    if not pending then
        return
    end

    if not self or not self.SetAnimBoolVar then
        runtime.pending_request_clears = {}
        return
    end

    local time = resolve_number(runtime.time, 0.0)
    for var_name, clear_time in pairs(pending) do
        if time >= resolve_number(clear_time, 0.0) then
            M.stage_bool(self, var_name, false)
            pending[var_name] = nil
        end
    end
end

function M.apply_staged(self)
    local runtime = self and self.Runtime or nil
    local staged = runtime and runtime.staged_anim_vars or nil
    if not staged then
        return
    end

    for var_name, value in pairs(staged.ints or {}) do
        M.set_int(self, var_name, value)
    end
    for var_name, value in pairs(staged.floats or {}) do
        M.set_float(self, var_name, value)
    end
    for var_name, value in pairs(staged.bools or {}) do
        M.set_bool(self, var_name, value)
    end

    runtime.staged_anim_vars = nil
end

function M.clear_request_prefixes(self)
    if self and self.ClearAnimBoolVarsByPrefix then
        self:ClearAnimBoolVarsByPrefix("Req_")
        self:ClearAnimBoolVarsByPrefix("Return_")
    end
end

return M
