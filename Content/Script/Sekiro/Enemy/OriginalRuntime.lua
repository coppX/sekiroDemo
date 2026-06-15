local GoalStack = require("Sekiro.Enemy.Common.GoalStack")

local M = {}
local loaded = false
local logic_by_id = {}
local goal_by_id = {}
local default_logic_id = 101200
local default_goal_id = 101200
local loading_script_id = nil

local function no_op()
end

local function original_module_name(script_id, suffix)
    return string.format("Sekiro.Enemy.m10_00_00_00-luabnd-dcx.out.bin.%06d_%s", tonumber(script_id) or default_logic_id, suffix)
end

local function install_globals()
    _G.REGISTER_LOGIC_FUNC = no_op
    _G.REGISTER_GOAL = no_op
    _G.REGISTER_GOAL_NO_UPDATE = no_op
    _G.REGISTER_GOAL_NO_SUB_GOAL = no_op
    _G.REGISTER_GOAL_NO_INTERUPT = no_op
    _G.REGISTER_GOAL_NO_UPDATE_GOAL = no_op
    _G.REGISTER_GOAL_USE_AVOID_CHR = no_op
    _G.REGISTER_DBG_GOAL_PARAM = no_op

    _G.TARGET_SELF = "TARGET_SELF"
    _G.TARGET_ENE_0 = "TARGET_ENE_0"
    _G.TARGET_LOCALPLAYER = "TARGET_ENE_0"
    _G.TARGET_NONE = "TARGET_NONE"
    _G.POINT_EVENT = "POINT_EVENT"

    _G.AI_DIR_TYPE_F = "AI_DIR_TYPE_F"
    _G.AI_DIR_TYPE_B = "AI_DIR_TYPE_B"
    _G.AI_DIR_TYPE_L = "AI_DIR_TYPE_L"
    _G.AI_DIR_TYPE_R = "AI_DIR_TYPE_R"
    _G.AI_DIR_TYPE_CENTER = "AI_DIR_TYPE_F"

    _G.GOAL_COMMON_Wait = "GOAL_COMMON_Wait"
    _G.GOAL_COMMON_Turn = "GOAL_COMMON_Turn"
    _G.GOAL_COMMON_ApproachTarget = "GOAL_COMMON_ApproachTarget"
    _G.GOAL_COMMON_LeaveTarget = "GOAL_COMMON_LeaveTarget"
    _G.GOAL_COMMON_SidewayMove = "GOAL_COMMON_SidewayMove"
    _G.GOAL_COMMON_Attack = "GOAL_COMMON_Attack"
    _G.GOAL_COMMON_AttackTunableSpin = "GOAL_COMMON_AttackTunableSpin"
    _G.GOAL_COMMON_ComboAttack = "GOAL_COMMON_ComboAttack"
    _G.GOAL_COMMON_ComboAttackTunableSpin = "GOAL_COMMON_ComboAttackTunableSpin"
    _G.GOAL_COMMON_ComboRepeat = "GOAL_COMMON_ComboRepeat"
    _G.GOAL_COMMON_ComboFinal = "GOAL_COMMON_ComboFinal"
    _G.GOAL_COMMON_SpinStep = "GOAL_COMMON_SpinStep"
    _G.GOAL_COMMON_Guard = "GOAL_COMMON_Guard"
    _G.GOAL_COMMON_EndureAttack = "GOAL_COMMON_EndureAttack"
    _G.GOAL_COMMON_NonspinningAttack = "GOAL_COMMON_NonspinningAttack"

    _G.GOAL_RESULT_Success = 1
    _G.GOAL_RESULT_Continue = 0
    _G.AI_GOAL_FAILED_END_OPT__PARENT_NEXT_SUB_GOAL = 1
    _G.AI_TIMING_SET__ACTIVATE = 0

    _G.DIST_None = 9999
    _G.DIST_Near = 250
    _G.DIST_Middle = 500
    _G.DIST_Far = 800
    _G.DIST_Out = 1200

    _G.TARGET_SELF = "TARGET_SELF"
    _G.AI_TIMER_TEKIMAWASHI_REACTION = 1001
    _G.AI_EXCEL_THINK_PARAM_TYPE__thinkAttr_doAdmirer = 1

    _G.RegisterTableLogic = function(id)
        _G.Logic = {}
        logic_by_id[id] = _G.Logic
    end

    _G.RegisterTableGoal = function(id, name)
        _G.Goal = {}
        goal_by_id[id or loading_script_id or default_goal_id] = _G.Goal
    end

    _G.REGIST_FUNC = function(_ai, _goal, fn)
        return fn
    end

    _G.Init_Pseudo_Global = no_op
    _G.Set_ConsecutiveGuardCount_Interrupt = no_op
    _G.Common_ActivateAct = function()
        return false
    end
    _G.ReturnKengekiSpecialEffect = function()
        return 0
    end
    _G.JuzuReaction = function()
        return false
    end
    _G.HumanCommon_ActAfter_AdjustSpace = no_op

    _G.SpaceCheck = function(ai, _goal, angle, dist)
        return ai:SpaceCheck(angle, dist)
    end

    _G.SetCoolTime = function(ai, _goal, attack_id, _seconds, rate, _slot)
        if ai:IsAttackCoolingDown(attack_id) then
            return 0
        end
        return rate or 0
    end

    _G.Approach_Act_Flex = function(ai, _goal, stop_dist, _walk_dist, _run_dist, _odds_guard)
        local stop_cm = (tonumber(stop_dist) or 0) * 100
        if ai:GetDist("TARGET_ENE_0") * 100 > stop_cm then
            ai:ScriptApproach(stop_cm)
            if _goal and _goal.MarkActionLocked then
                _goal:MarkActionLocked()
            end
        else
            ai:ScriptTurnToTarget()
        end
    end

    _G.COMMON_HiPrioritySetup = function(ai)
        if ai:IsDead() then
            ai:PushDeath()
            return true
        end
        return false
    end

    _G.COMMON_EzSetup = function(ai)
        local runtime_goal = GoalStack.New(ai)
        if ai:HasBattleTarget() or ai:IsFindState() or ai:IsBattleState() then
            local battle_goal = goal_by_id[default_goal_id]
            if battle_goal and battle_goal.Activate then
                battle_goal.Activate(battle_goal, ai, runtime_goal)
                return true
            end
        end
        ai:ScriptPatrol()
        return true
    end

    _G._COMMON_SetBattleGoal = _G.COMMON_EzSetup
end

local function load_once()
    if loaded then
        return
    end

    install_globals()
    require("Sekiro.Enemy.aicommon-luabnd-dcx.out.bin.common_battle_func")
    loaded = true
end

local function load_original_script(script_id)
    script_id = tonumber(script_id) or default_logic_id
    if logic_by_id[script_id] then
        return true
    end

    loading_script_id = script_id
    _G.Goal = nil
    local battle_ok = pcall(require, original_module_name(script_id, "battle"))
    if battle_ok and _G.Goal and not goal_by_id[script_id] then
        goal_by_id[script_id] = _G.Goal
    end

    _G.Logic = nil
    local ok = pcall(require, original_module_name(script_id, "logic"))
    if ok and _G.Logic and not logic_by_id[script_id] then
        logic_by_id[script_id] = _G.Logic
    end
    loading_script_id = nil
    return ok and logic_by_id[script_id] ~= nil
end

function M.Main(ai, logic_id)
    load_once()
    default_logic_id = logic_id or default_logic_id
    if not load_original_script(default_logic_id) then
        load_original_script(101200)
    end
    default_goal_id = default_logic_id
    local logic = logic_by_id[default_logic_id] or logic_by_id[101200]
    if not logic or not logic.Main then
        ai:ScriptPatrol()
        return false
    end

    _G.goal = GoalStack.New(ai)
    return logic.Main(logic, ai)
end

return M
