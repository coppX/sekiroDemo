local Context = require("Sekiro.Enemy.Common.AIContext")

local M = {}
local GoalStack = {}
GoalStack.__index = GoalStack

local function to_cm(value)
    value = tonumber(value) or 0
    if value > 0 and value < 30 then
        return value * 100
    end
    return value
end

function M.New(ai)
    return setmetatable({ ai = ai, entries = {}, action_locked = false }, GoalStack)
end

function GoalStack:ClearSubGoal()
    self.entries = {}
    self.action_locked = false
    self.ai:ClearSubGoal()
end

function GoalStack:AddTopGoal(goal_id, life, ...)
    return self:AddSubGoal(goal_id, life, ...)
end

function GoalStack:AddSubGoal(goal_id, life, ...)
    local args = { ... }
    table.insert(self.entries, { goal_id = goal_id, life = life or 0, args = args })
    return self:Run(goal_id, life, args)
end

function GoalStack:Run(goal_id, life, args)
    local ai = self.ai
    if self.action_locked then
        return self
    end

    if goal_id == Context.GOAL_COMMON_Wait then
        ai:ScriptWait(life or 0)
    elseif goal_id == Context.GOAL_COMMON_Turn then
        ai:ScriptTurnToTarget()
    elseif goal_id == Context.GOAL_COMMON_ApproachTarget then
        local stop_dist = tonumber(args[2]) or tonumber(args[1]) or 320
        ai:ScriptApproach(to_cm(stop_dist))
    elseif goal_id == Context.GOAL_COMMON_LeaveTarget then
        local keep_dist = tonumber(args[2]) or tonumber(args[1]) or 320
        ai:ScriptLeaveTarget(to_cm(keep_dist))
    elseif goal_id == Context.GOAL_COMMON_SidewayMove then
        local dir = tonumber(args[2]) or ai:GetRandam_Int(0, 1)
        ai:ScriptSidewayMove(dir)
    elseif goal_id == Context.GOAL_COMMON_AttackTunableSpin
        or goal_id == Context.GOAL_COMMON_ComboAttackTunableSpin
        or goal_id == Context.GOAL_COMMON_ComboFinal
        or goal_id == "GOAL_COMMON_Attack"
        or goal_id == "GOAL_COMMON_ComboAttack"
        or goal_id == "GOAL_COMMON_ComboRepeat"
        or goal_id == "GOAL_COMMON_NonspinningAttack"
        or goal_id == "GOAL_COMMON_AttackNonCancel"
        or goal_id == "GOAL_COMMON_EndureAttack" then
        local attack_id = tonumber(args[1]) or 3000
        local max_dist = tonumber(args[3]) or 9999
        if max_dist >= 9999 then
            ai:ScriptAttackAtRange(attack_id, 999999)
        else
            ai:ScriptAttackAtRange(attack_id, to_cm(max_dist))
        end
        self.action_locked = true
    elseif goal_id == "GOAL_COMMON_SpinStep" or goal_id == "GOAL_COMMON_StepSafety" then
        local step_id = tonumber(args[1]) or 0
        if step_id == 5202 or step_id == 6002 then
            ai:ScriptSidewayMove(0)
        elseif step_id == 5203 or step_id == 6003 then
            ai:ScriptSidewayMove(1)
        else
            ai:ScriptLeaveTarget(250)
        end
    elseif goal_id == "GOAL_COMMON_Guard" then
        ai:ScriptWait(life or 0.2)
    end

    return self
end

function GoalStack:MarkActionLocked()
    self.action_locked = true
    return self
end

function GoalStack:SetTargetRange(...)
    return self
end

function GoalStack:SetTargetAngle(...)
    return self
end

function GoalStack:SetFailedEndOption(...)
    return self
end

function GoalStack:TimingSetTimer(timer_id, seconds, _timing)
    self.ai:SetTimer(timer_id, seconds)
    return self
end

function GoalStack:TimingSetNumber(number_id, value, _timing)
    self.ai:SetNumber(number_id, value)
    return self
end

function GoalStack:GetLife()
    return 1.0
end

function GoalStack:Tick(_delta_time)
    return #self.entries > 0
end

return M
