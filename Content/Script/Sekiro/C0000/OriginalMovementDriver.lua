local Constants = require("Sekiro.C0000.Constants")
local EventSpecs = require("Sekiro.C0000.EventSpecs")
local EventAliases = require("Sekiro.C0000.EventAliases")
require("Sekiro.C0000.MathUtils")
require("Sekiro.C0000.StateUtils")

local M = {}
local FireEventHandlers = nil

local TRUE = 1
local FALSE = 0

local EVENT_TO_KEY = EventAliases.build_event_to_key(EventSpecs.SimpleMovementEvents)

local NON_COMBAT_EVENT_NAMES = {
    W_GroundNonCombatAreaLeave = true,
    W_GroundNonCombatAreaMoveLeave = true,
    W_GroundNonCombatAreaEnter = true,
    W_GroundNonCombatAreaMoveEnter = true,
}

local QUICK_TURN_EVENT_KEYS = {
    BaseQuickTurnLeft90 = true,
    BaseQuickTurnRight90 = true,
    BaseQuickTurnLeft180 = true,
    BaseQuickTurnRight180 = true,
    BaseQuickTurnMoveStartLeft180 = true,
    BaseQuickTurnMoveStartRight180 = true,
    BaseMoveQuickTurnLeft180 = true,
    BaseMoveQuickTurnRight180 = true,
}

local HKB_STATE_NAMES = {
    [10000] = "HKB_STATE_STAND_IDLE",
    [10011] = "HKB_STATE_STAND_MOVE_LOOP",
    [10030] = "HKB_STATE_STAND_MOVE_START",
    [10031] = "HKB_STATE_STAND_WALK_STOP",
    [10040] = "HKB_STATE_STAND_QUICK_TURN_LEFT_90",
    [10041] = "HKB_STATE_STAND_QUICK_TURN_RIGHT_90",
    [10042] = "HKB_STATE_STAND_QUICK_TURN_LEFT_180",
    [10043] = "HKB_STATE_STAND_QUICK_TURN_RIGHT_180",
    [10052] = "HKB_STATE_STAND_QUICK_TURN_MOVE_START_LEFT_180",
    [10053] = "HKB_STATE_STAND_QUICK_TURN_MOVE_START_RIGHT_180",
    [10054] = "HKB_STATE_STAND_MOVE_QUICK_TURN_LEFT_180",
    [10055] = "HKB_STATE_STAND_MOVE_QUICK_TURN_RIGHT_180",
}

local function get_hkb_state_name(sandbox, hkb_state)
    if not hkb_state then
        return "nil"
    end
    for key, value in pairs(sandbox or {}) do
        if type(key) == "string" and string.sub(key, 1, 10) == "HKB_STATE_" and value == hkb_state then
            return key
        end
    end
    return HKB_STATE_NAMES[hkb_state] or ("HKB_STATE_" .. tostring(hkb_state))
end

local function to_original_bool(value)
    if value == nil then
        return FALSE
    end
    if value == true or value == TRUE then
        return TRUE
    end
    return FALSE
end

local function is_original_true(value)
    return value == TRUE or value == true
end

local DEFAULT_HKB_VARIABLES = {
    WireDramaticAngle = 0.0,
    WireMoveStartIndex = 0,
}

local function ensure_original_runtime(self)
    local runtime = self.Runtime or {}
    runtime.original_movement = runtime.original_movement or {}
    runtime.original_movement.variables = runtime.original_movement.variables or {}
    runtime.original_movement.acts = runtime.original_movement.acts or {}
    runtime.original_movement.fired_events = runtime.original_movement.fired_events or {}
    runtime.original_movement.reset_request_count = resolve_number(runtime.original_movement.reset_request_count, 0)
    runtime.original_movement.env_overrides = runtime.original_movement.env_overrides or {}
    self.Runtime = runtime
    return runtime.original_movement
end

local function is_move_state(state_id)
    return state_id == Constants.BASE_STATE_MOVE_START
        or state_id == Constants.BASE_STATE_MOVE_LOOP
        or state_id == Constants.BASE_STATE_QUICK_TURN_MOVE_START_180
        or state_id == Constants.BASE_STATE_MOVE_QUICK_TURN_180
end

local function is_stop_state(state_id)
    return state_id == Constants.BASE_STATE_MOVE_STOP
end

local function hkb_get_variable(self, name, context)
    local original = ensure_original_runtime(self)

    if context then
        if name == "MoveSpeedLevel" then
            return resolve_number(context.input_strength, 0.0)
        end
        if name == "MoveAngle" then
            return resolve_number(context.move_angle, 0.0)
        end
        if name == "TurnAngle" then
            return resolve_number(context.turn_angle, resolve_number(context.move_angle, 0.0))
        end
        if name == "TwistLowerRootAngle" then
            return resolve_number(context.twist_angle, -resolve_number(context.turn_angle, 0.0))
        end
    end

    if name == "MoveSpeedIndex" then
        if original.variables[name] ~= nil then
            return original.variables[name]
        end
        local runtime = self.Runtime or {}
        if runtime.anim and runtime.anim.move_speed_index ~= nil then
            return runtime.anim.move_speed_index
        end
        if self.GetAnimIntVar then
            local ok, value = pcall(function()
                return self:GetAnimIntVar(name)
            end)
            if ok then
                return resolve_number(value, Constants.MOVE_SPEED_INDEX_WALK)
            end
        end
        return Constants.MOVE_SPEED_INDEX_WALK
    end

    if name == "WireDramaticAngle" then
        if not original.logged_wire_dramatic_angle_default and UnLua and UnLua.Log then
            original.logged_wire_dramatic_angle_default = true
            UnLua.Log("[OriginalMovementDriver] default hkbGetVariable WireDramaticAngle=0")
        end
        return 0.0
    end
    if name == "WireMoveStartIndex" then
        return 0
    end

    if original.variables[name] ~= nil then
        return original.variables[name]
    end

    if DEFAULT_HKB_VARIABLES[name] ~= nil then
        return DEFAULT_HKB_VARIABLES[name]
    end

    if self.GetAnimFloatVar then
        local ok, value = pcall(function()
            return self:GetAnimFloatVar(name)
        end)
        if ok then
            return resolve_number(value, 0.0)
        end
    end
    return 0
end

local function hkb_set_variable(self, name, value)
    local original = ensure_original_runtime(self)
    original.variables[name] = value

    if not self then
        return TRUE
    end

    if type(value) == "boolean" and self.SetAnimBoolVar then
        local ok, handled = pcall(function()
            return self:SetAnimBoolVar(name, value)
        end)
        if ok and handled then
            return TRUE
        end
    end

    if type(value) == "number" then
        if self.SetAnimIntVar and math.floor(value) == value then
            local ok, handled = pcall(function()
                return self:SetAnimIntVar(name, math.floor(value))
            end)
            if ok and handled then
                return TRUE
            end
        end

        if self.SetAnimFloatVar then
            local ok, handled = pcall(function()
                return self:SetAnimFloatVar(name, value)
            end)
            if ok and handled then
                return TRUE
            end
        end
    end

    if type(value) ~= "boolean" and self.SetAnimBoolVar then
        local ok, handled = pcall(function()
            return self:SetAnimBoolVar(name, value == TRUE or value == 1)
        end)
        if ok and handled then
            return TRUE
        end
    end

    return FALSE
end

local function env_key(id, subkey)
    return tostring(id) .. ":" .. tostring(subkey or 0)
end

local function raw_env(self, id, subkey, env_callback)
    local original = ensure_original_runtime(self)
    local override = original.env_overrides[env_key(id, subkey)]
    if override ~= nil then
        return override
    end
    if type(id) ~= "number" or (subkey ~= nil and type(subkey) ~= "number") then
        return FALSE
    end
    if env_callback then
        local ok, value = pcall(env_callback, id, subkey)
        if ok then
            return value
        end
    end
    return FALSE
end

local function env_value(self, id, subkey, env_callback)
    local value = raw_env(self, id, subkey, env_callback)
    if type(value) == "boolean" then
        return value and TRUE or FALSE
    end
    return value or FALSE
end

local function handle_act(self, act_id, ...)
    local original = ensure_original_runtime(self)
    local args = { ... }
    original.acts[#original.acts + 1] = {
        id = act_id,
        args = args,
    }

    if act_id == 148 then
        return hkb_set_variable(self, args[1], args[2])
    end

    if act_id == 9100 or act_id == 9101 then
        original.reset_request_count = resolve_number(original.reset_request_count, 0) + 1
        original.last_reset_act_id = act_id
        if self.ClearPreviewQueuedEvents then
            self:ClearPreviewQueuedEvents()
        end
        return TRUE
    end

    if self.HandleSekiroAct then
        local serialized = {}
        for i = 1, #args do
            serialized[#serialized + 1] = tostring(args[i])
        end
        local ok, handled = pcall(function()
            return self:HandleSekiroAct(act_id, table.concat(serialized, ","))
        end)
        if ok then
            return to_original_bool(handled)
        end
    end
    return FALSE
end

local function apply_staged_anim_vars(self)
    local ok, writer = pcall(require, "Sekiro.C0000.AnimVarWriter")
    if ok and writer and writer.apply_staged then
        writer.apply_staged(self)
    end
end

local function get_fire_event_handlers()
    if FireEventHandlers ~= nil then
        return FireEventHandlers
    end

    local ok, handlers = pcall(require, "Sekiro.C0000.FireEventHandlers")
    if ok then
        FireEventHandlers = handlers
    else
        FireEventHandlers = false
    end
    return FireEventHandlers
end

local function fire_event(self, event_name, context)
    local event_key = EVENT_TO_KEY[event_name]
    local original = ensure_original_runtime(self)
    original.fired_event = event_name
    original.fired_event_key = event_key
    original.fired_event_handled = false
    original.fired_event_handler_error = nil
    original.fired_events[#original.fired_events + 1] = {
        name = event_name,
        key = event_key,
    }

    local non_combat_requested = original.preview_non_combat_transition
        and NON_COMBAT_EVENT_NAMES[event_name]
    local defer_to_preview_validation = event_key and QUICK_TURN_EVENT_KEYS[event_key]
    local handlers = ((event_key and not defer_to_preview_validation) or non_combat_requested)
        and get_fire_event_handlers()
        or nil
    if handlers and handlers.handle then
        local ok, handled, resolved_key = pcall(handlers.handle, self, event_name, event_key, context)
        if ok then
            original.fired_event_handled = handled and true or false
            if handled and non_combat_requested then
                original.preview_non_combat_transition = nil
            end
            if resolved_key and not event_key then
                event_key = resolved_key
                original.fired_event_key = resolved_key
                original.fired_events[#original.fired_events].key = resolved_key
            end
        else
            original.fired_event_handler_error = tostring(handled)
            if not original.fired_event_handler_error_logged and UnLua and UnLua.LogError then
                original.fired_event_handler_error_logged = true
                UnLua.LogError("[OriginalMovementDriver] FireEvent handler error: " .. tostring(handled))
            end
        end
    end
    return event_key
end

local function get_script_dir()
    if debug and debug.getinfo then
        local info = debug.getinfo(1, "S")
        local source = info and info.source or ""
        if string.sub(source, 1, 1) == "@" then
            source = string.sub(source, 2)
        end
        local dir = string.match(source, "^(.*)[/\\][^/\\]+$")
        if dir and dir ~= "" then
            return dir
        end
    end
    return "Content/Script/Sekiro/C0000"
end

local function set_chunk_env(chunk, sandbox)
    if setfenv then
        setfenv(chunk, sandbox)
    end
    return chunk
end

local function load_original_file(sandbox, script_dir, filename)
    local path = script_dir .. "/" .. filename
    local chunk, err
    local ok, loaded_chunk, loaded_err = pcall(loadfile, path, "t", sandbox)
    if ok and type(loaded_chunk) == "function" then
        chunk = loaded_chunk
    else
        err = loaded_err
        chunk, err = loadfile(path)
    end
    if not chunk then
        return false, err
    end
    chunk = set_chunk_env(chunk, sandbox)
    local ok, run_err = pcall(chunk)
    if not ok then
        return false, run_err
    end
    return true
end

local function create_sandbox(self)
    local sandbox = {}
    sandbox._driver_self = self
    sandbox._driver_context = nil
    sandbox._driver_env_callback = nil
    sandbox.TRUE = TRUE
    sandbox.FALSE = FALSE
    sandbox.INVALID = -1
    sandbox.unpack = unpack or table.unpack

    sandbox.hkbGetVariable = function(name)
        return hkb_get_variable(sandbox._driver_self, name, sandbox._driver_context)
    end
    sandbox.hkbSetVariable = function(name, value)
        return hkb_set_variable(sandbox._driver_self, name, value)
    end
    sandbox.hkbFireEvent = function(event_name)
        return fire_event(sandbox._driver_self, event_name, sandbox._driver_context)
    end
    sandbox.SetVariable = function(name, value)
        return handle_act(sandbox._driver_self, 148, name, value)
    end
    sandbox.ResetRequest = function()
        return handle_act(sandbox._driver_self, 9101)
    end
    sandbox.FireEvent = function(event_name)
        local event_key = fire_event(sandbox._driver_self, event_name, sandbox._driver_context)
        handle_act(sandbox._driver_self, 9101)
        return event_key
    end
    sandbox.FireEventNoReset = function(event_name)
        return fire_event(sandbox._driver_self, event_name, sandbox._driver_context)
    end
    sandbox.hkbIsNodeActive = function()
        return false
    end
    sandbox.act = function(act_id, ...)
        return handle_act(sandbox._driver_self, act_id, ...)
    end
    sandbox.env = function(id, subkey)
        return env_value(sandbox._driver_self, id, subkey, sandbox._driver_env_callback)
    end

    setmetatable(sandbox, {
        __index = function(_, key)
            return _G[key]
        end,
    })

    return sandbox
end

local function load_original_runtime(self)
    local original = ensure_original_runtime(self)
    if original.sandbox and original.loaded then
        return original.sandbox
    end

    local sandbox = create_sandbox(self)
    local script_dir = get_script_dir()
    local files = {
        "c0000_define.dec.lua",
        "c0000_cmsg.dec.lua",
        "c0000_transition.dec.lua",
        "c0000.dec.lua",
    }

    for _, filename in ipairs(files) do
        local ok, err = load_original_file(sandbox, script_dir, filename)
        if not ok then
            original.load_error = tostring(filename) .. ": " .. tostring(err)
            original.sandbox = sandbox
            original.loaded = false
            return nil
        end
    end

    if sandbox.Initialize then
        local ok, err = pcall(sandbox.Initialize)
        if not ok then
            original.load_error = "Initialize: " .. tostring(err)
            original.sandbox = sandbox
            original.loaded = false
            return nil
        end
    end

    original.sandbox = sandbox
    original.loaded = true
    original.load_error = nil

    if sandbox._ActivateBehavior and not original.activate_behavior_probe_installed then
        local original_activate_behavior = sandbox._ActivateBehavior
        sandbox._ActivateBehavior = function(hkb_state, behavior_id)
            local runtime_original = ensure_original_runtime(sandbox._driver_self)
            runtime_original.last_activated_hkb_state = hkb_state
            runtime_original.last_activated_behavior_id = behavior_id
            return original_activate_behavior(hkb_state, behavior_id)
        end
        original.activate_behavior_probe_installed = true
    end

    return sandbox
end

local function set_env_override(original, id, subkey, value)
    original.env_overrides[env_key(id, subkey)] = value
end

local function sync_tae_behavior_refs(self, original)
    local runtime = self.Runtime or {}
    local movement_events = runtime.movement_events or {}
    local behavior_ref_counts = movement_events.behavior_ref_counts or {}
    local behavior_ref_managed = movement_events.behavior_ref_managed or {}
    for behavior_ref_id, _ in pairs(behavior_ref_managed) do
        set_env_override(
            original,
            3036,
            math.floor(resolve_number(behavior_ref_id, 0)),
            resolve_number(behavior_ref_counts[behavior_ref_id], 0) > 0 and TRUE or FALSE
        )
    end
    for behavior_ref_id, count in pairs(behavior_ref_counts) do
        set_env_override(
            original,
            3036,
            math.floor(resolve_number(behavior_ref_id, 0)),
            resolve_number(count, 0) > 0 and TRUE or FALSE
        )
    end
end

local function sync_context(self, context)
    local original = ensure_original_runtime(self)
    local overrides = {}
    original.env_overrides = overrides

    local current_state = context.current_state
    local moving = is_move_state(current_state)
    local stopping = is_stop_state(current_state)
    local quick_turning = is_quick_turn_state(current_state)
    local move_speed_index = hkb_get_variable(self, "MoveSpeedIndex", context)
    local is_run = move_speed_index == Constants.MOVE_SPEED_INDEX_RUN or context.sprint

    set_env_override(original, 337, 0, FALSE)
    set_env_override(original, 1105, 0, (context.has_move_input or context.wants_move) and TRUE or FALSE)
    set_env_override(original, 2000, 0, context.wants_move and TRUE or FALSE)
    set_env_override(original, 3063, 1, 0)
    set_env_override(original, 3063, 2, 0)

    sync_tae_behavior_refs(self, original)

    set_env_override(original, 3036, Constants.SP_EF_REF_TAE_MOVING_WALK, (moving and not is_run) and TRUE or FALSE)
    set_env_override(original, 3036, Constants.SP_EF_REF_TAE_MOVING_RUN, (moving and is_run) and TRUE or FALSE)
    set_env_override(original, 3036, Constants.SP_EF_REF_TAE_MOVING_SPRINT, FALSE)
    set_env_override(original, 3036, Constants.SP_EF_REF_TAE_STOPING_WALK, stopping and TRUE or FALSE)
    set_env_override(original, 3036, Constants.SP_EF_REF_TAE_STOPING_RUN, FALSE)
    set_env_override(original, 3036, Constants.SP_EF_REF_TAE_STOPING_SPRINT, FALSE)
    set_env_override(original, 3036, Constants.SP_EF_REF_TAE_GROUND_QUICK_TURN, quick_turning and TRUE or FALSE)
    set_env_override(
        original,
        3036,
        Constants.SP_EF_REF_TAE_ENABLE_GROUND_QUICK_TURN,
        (resolve_number(context.elapsed, 0.0) >= Constants.STAND_MOVE_QUICK_TURN_GATE_DELAY) and TRUE or FALSE
    )
    set_env_override(original, 3036, Constants.SP_EF_REF_TAE_ENABLE_MOVE_SPEED_CHANGE_CANCEL, TRUE)
    set_env_override(original, 3036, Constants.SP_EF_REF_TAE_DISABLE_SPRINT_STOP, FALSE)
    set_env_override(original, 3036, Constants.SP_EF_REF_IN_SWAMP_AREA, FALSE)
    set_env_override(original, 3036, Constants.SP_EF_REF_IN_WATERSIDE_AREA, FALSE)
    if original.preview_non_combat_transition == "leave" then
        set_env_override(original, 207, 0, Constants.ARM_STYLE_SAFE)
        set_env_override(original, 3036, Constants.SP_EF_REF_IN_NON_COMBAT_AREA, FALSE)
        set_env_override(original, 3036, Constants.SP_EF_REF_TAE_CAMO_STANDBY_STATE, TRUE)
        set_env_override(original, 3036, Constants.SP_EF_REF_TAE_ENABLE_NON_COMBAT_TRANSITION, TRUE)
    elseif original.preview_non_combat_transition == "enter" then
        set_env_override(original, 207, 0, Constants.ARM_STYLE_NORMAL)
        set_env_override(original, 3036, Constants.SP_EF_REF_IN_NON_COMBAT_AREA, TRUE)
        set_env_override(original, 3036, Constants.SP_EF_REF_TAE_CAMO_STANDBY_STATE, TRUE)
        set_env_override(original, 3036, Constants.SP_EF_REF_TAE_ENABLE_NON_COMBAT_TRANSITION, TRUE)
    end

    hkb_set_variable(self, "MoveSpeedLevel", resolve_number(context.input_strength, 0.0))
    hkb_set_variable(self, "MoveAngle", resolve_number(context.move_angle, 0.0))
    hkb_set_variable(self, "TurnAngle", resolve_number(context.turn_angle, resolve_number(context.move_angle, 0.0)))
    hkb_set_variable(self, "TwistLowerRootAngle", resolve_number(context.twist_angle, -resolve_number(context.turn_angle, 0.0)))
end

local function apply_env_overrides_to_query(self, query)
    if not query or not query.SetBehaviorRefActive then
        return
    end

    local original = ensure_original_runtime(self)
    for key, value in pairs(original.env_overrides or {}) do
        local id_text, subkey_text = string.match(key, "^(%-?%d+):(%-?%d+)$")
        if tonumber(id_text) == 3036 then
            query:SetBehaviorRefActive(tonumber(subkey_text), is_original_true(value))
        end
    end
end

local function map_hkb_state(sandbox, context)
    local direction = context.current_direction
    if direction == nil or direction == Constants.MOVE_DIRECTION_NONE then
        direction = context.direction
    end
    local turn_angle = resolve_number(context.turn_angle, resolve_number(context.move_angle, 0.0))
    local use_right = turn_angle > 0

    if context.current_state == Constants.BASE_STATE_MOVE_START then
        return sandbox.HKB_STATE_STAND_MOVE_START or 10030
    end
    if context.current_state == Constants.BASE_STATE_MOVE_LOOP then
        return sandbox.HKB_STATE_STAND_MOVE_LOOP or 10011
    end
    if context.current_state == Constants.BASE_STATE_MOVE_STOP then
        return sandbox.HKB_STATE_STAND_WALK_STOP or 10031
    end
    if context.current_state == Constants.BASE_STATE_QUICK_TURN_90 then
        if direction == Constants.MOVE_DIRECTION_RIGHT or use_right then
            return sandbox.HKB_STATE_STAND_QUICK_TURN_RIGHT_90 or 10041
        end
        return sandbox.HKB_STATE_STAND_QUICK_TURN_LEFT_90 or 10040
    end
    if context.current_state == Constants.BASE_STATE_QUICK_TURN_180 then
        if direction == Constants.MOVE_DIRECTION_RIGHT or use_right then
            return sandbox.HKB_STATE_STAND_QUICK_TURN_RIGHT_180 or 10043
        end
        return sandbox.HKB_STATE_STAND_QUICK_TURN_LEFT_180 or 10042
    end
    if context.current_state == Constants.BASE_STATE_QUICK_TURN_MOVE_START_180 then
        if direction == Constants.MOVE_DIRECTION_RIGHT or use_right then
            return sandbox.HKB_STATE_STAND_QUICK_TURN_MOVE_START_RIGHT_180 or 10053
        end
        return sandbox.HKB_STATE_STAND_QUICK_TURN_MOVE_START_LEFT_180 or 10052
    end
    if context.current_state == Constants.BASE_STATE_MOVE_QUICK_TURN_180 then
        if direction == Constants.MOVE_DIRECTION_RIGHT or use_right then
            return sandbox.HKB_STATE_STAND_MOVE_QUICK_TURN_RIGHT_180 or 10055
        end
        return sandbox.HKB_STATE_STAND_MOVE_QUICK_TURN_LEFT_180 or 10054
    end
    return sandbox.HKB_STATE_STAND_IDLE or 10000
end

local function get_current_style_state(sandbox, hkb_state)
    local original = sandbox and sandbox._driver_self and ensure_original_runtime(sandbox._driver_self) or nil
    if not sandbox or not hkb_state or not sandbox.g_paramHkbState then
        if original and UnLua and UnLua.LogError then
            original.last_param_state_error = "missing g_paramHkbState"
            UnLua.LogError("[OriginalMovementDriver] missing g_paramHkbState for hkb_state=" .. tostring(hkb_state))
        end
        return nil, nil
    end

    local params = sandbox.g_paramHkbState[hkb_state]
    if not params then
        if original and UnLua and UnLua.LogError then
            original.last_param_state_error = "missing hkb_state"
            UnLua.LogError(
                "[OriginalMovementDriver] g_paramHkbState missing "
                    .. get_hkb_state_name(sandbox, hkb_state)
                    .. "("
                    .. tostring(hkb_state)
                    .. ")"
            )
        end
        return nil, nil
    end

    local style_index = sandbox.PARAM_HKB_STATE__STYLE_TYPE or 3
    local state_index = sandbox.PARAM_HKB_STATE__STATE_TYPE or 4
    local style_type = params[style_index]
    local state_type = params[state_index]
    if original then
        original.last_param_hkb_state = hkb_state
        original.last_param_hkb_state_name = get_hkb_state_name(sandbox, hkb_state)
        original.last_param_hkb_state_params = {
            params[1],
            params[2],
            params[3],
            params[4],
        }
        original.last_param_style_index = style_index
        original.last_param_state_index = state_index
        original.last_param_style_type = style_type
        original.last_param_state_type = state_type
    end
    local signature = table.concat({
        tostring(hkb_state),
        tostring(params[1]),
        tostring(params[2]),
        tostring(params[3]),
        tostring(params[4]),
        tostring(style_index),
        tostring(style_type),
        tostring(state_index),
        tostring(state_type),
    }, "|")
    if UnLua and UnLua.Log and (not original or original.last_param_log_signature ~= signature) then
        if original then
            original.last_param_log_signature = signature
        end
        UnLua.Log(
            string.format(
                "[OriginalMovementDriver] g_paramHkbState[%s(%d)] raw={%s,%s,%s,%s} style[%d]=%s state[%d]=%s",
                get_hkb_state_name(sandbox, hkb_state),
                hkb_state,
                tostring(params[1]),
                tostring(params[2]),
                tostring(params[3]),
                tostring(params[4]),
                style_index,
                tostring(style_type),
                state_index,
                tostring(state_type)
            )
        )
    end
    if style_type == nil or state_type == nil then
        if original then
            original.last_param_state_error = "nil style/state"
        end
        if UnLua and UnLua.LogError then
            UnLua.LogError(
                string.format(
                    "[OriginalMovementDriver] invalid g_paramHkbState entry for %s(%d): style=%s state=%s",
                    get_hkb_state_name(sandbox, hkb_state),
                    hkb_state,
                    tostring(style_type),
                    tostring(state_type)
                )
            )
        end
    end
    return style_type, state_type
end

local function log_transition_context(sandbox, context, hkb_state, current_style, current_state)
    if not UnLua or not UnLua.Log then
        return
    end
    local original = sandbox and sandbox._driver_self and ensure_original_runtime(sandbox._driver_self) or nil
    local signature = table.concat({
        tostring(context and context.current_state),
        tostring(hkb_state),
        tostring(current_style),
        tostring(current_state),
    }, "|")
    if original and original.last_transition_context_log_signature == signature then
        return
    end
    if original then
        original.last_transition_context_log_signature = signature
    end
    UnLua.Log(
        string.format(
            "[OriginalMovementDriver] transition context ue_state=%s hkb_state=%s(%d) style=%s state=%s",
            tostring(context and context.current_state),
            get_hkb_state_name(sandbox, hkb_state),
            hkb_state,
            tostring(current_style),
            tostring(current_state)
        )
    )
end

local function run_original_update_state(sandbox, hkb_state)
    local original = ensure_original_runtime(sandbox._driver_self)
    original.update_error = nil
    original.update_state_error = nil
    original.last_activated_behavior_id = nil
    original.last_activated_hkb_state = nil
    original.last_hkb_state = hkb_state

    if sandbox.Update then
        original.update_count = resolve_number(original.update_count, 0) + 1
        local ok, err = pcall(sandbox.Update)
        if not ok then
            original.update_error = tostring(err)
        end
    end

    if not sandbox.UpdateState then
        return nil
    end

    original.update_state_count = resolve_number(original.update_state_count, 0) + 1
    if not original.update_state_source and debug and debug.getinfo then
        local info = debug.getinfo(sandbox.UpdateState, "S")
        original.update_state_source = info and info.source or ""
    end
    if not original.update_state_logged and UnLua and UnLua.Log then
        original.update_state_logged = true
        UnLua.Log(
            "[OriginalMovementDriver] calling UpdateState source="
                .. tostring(original.update_state_source)
                .. " hkb_state="
                .. tostring(hkb_state)
        )
    end

    local ok, err = pcall(sandbox.UpdateState, hkb_state)
    if not ok then
        original.update_state_error = tostring(err)
        if not original.update_state_error_logged and UnLua and UnLua.LogError then
            original.update_state_error_logged = true
            UnLua.LogError("[OriginalMovementDriver] UpdateState error: " .. tostring(err))
        end
        return nil
    end
    original.update_state_return_count = resolve_number(original.update_state_return_count, 0) + 1
    if not original.update_state_return_logged and UnLua and UnLua.Log then
        original.update_state_return_logged = true
        UnLua.Log("[OriginalMovementDriver] UpdateState returned hkb_state=" .. tostring(hkb_state))
    end
    return original.fired_event_key
end

local function decide_with_original_scripts(self, context, env_callback)
    local sandbox = load_original_runtime(self)
    if not sandbox then
        local original = ensure_original_runtime(self)
        if not original.load_error_logged and UnLua and UnLua.LogError then
            original.load_error_logged = true
            UnLua.LogError("[OriginalMovementDriver] load failed: " .. tostring(original.load_error))
        end
        return nil
    end

    local original = ensure_original_runtime(self)
    original.fired_event = nil
    original.fired_event_key = nil
    original.fired_event_handled = false
    original.fired_event_handler_error = nil
    original.activate_error = nil
    original.update_error = nil
    original.update_state_error = nil
    sandbox._driver_self = self
    sandbox._driver_context = context
    sandbox._driver_env_callback = env_callback

    sync_context(self, context)

    local hkb_state = map_hkb_state(sandbox, context)
    local current_style, current_state = get_current_style_state(sandbox, hkb_state)
    log_transition_context(sandbox, context, hkb_state, current_style, current_state)
    original.last_transition_current_style = current_style
    original.last_transition_current_state = current_state
    original.last_transition_hkb_state = hkb_state

    local update_event_key = run_original_update_state(sandbox, hkb_state)
    apply_staged_anim_vars(self)
    if update_event_key then
        original.last_decision_source = "UpdateState"
        original.last_decision_event_key = update_event_key
        original.last_decision_event_name = original.fired_event
        original.decision_count = resolve_number(original.decision_count, 0) + 1
        if UnLua and UnLua.Log then
            UnLua.Log(
                "[OriginalMovementDriver] transition source=UpdateState behavior="
                    .. tostring(original.last_activated_behavior_id)
                    .. " event="
                    .. tostring(original.fired_event)
            )
        end
        return update_event_key
    end

    return nil
end

function M.decide_base_event(self, context, env_callback)
    if not self or not context then
        return nil
    end

    local ok, event_key = pcall(decide_with_original_scripts, self, context, env_callback)
    if ok then
        return event_key
    end

    local original = ensure_original_runtime(self)
    original.runtime_error = tostring(event_key)
    if not original.runtime_error_logged and UnLua and UnLua.LogError then
        original.runtime_error_logged = true
        UnLua.LogError("[OriginalMovementDriver] runtime error: " .. tostring(event_key))
    end
    return nil
end

function M.sync_context(self, context)
    if self and context then
        sync_context(self, context)
    end
end

function M.apply_env_overrides_to_query(self, query)
    apply_env_overrides_to_query(self, query)
end

function M.was_last_event_handled(self)
    local original = ensure_original_runtime(self)
    return original.fired_event_handled and true or false
end

function M.queue_non_combat_transition(self, transition)
    local original = ensure_original_runtime(self)
    if transition == "leave" or transition == "enter" then
        original.preview_non_combat_transition = transition
        return true
    end
    return false
end

M.hkbGetVariable = hkb_get_variable
M.hkbSetVariable = hkb_set_variable
M.hkbFireEvent = fire_event
M.FireEvent = fire_event
M.FireEventNoReset = fire_event
M.act = handle_act
M.env = env_value

return M
