RegisterTableGoal(GOAL_COMMON_ContinueKeepDist, "GOAL_COMMON_ContinueKeepDist")
REGISTER_GOAL_NO_SUB_GOAL(GOAL_COMMON_ContinueKeepDist, true)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_ContinueKeepDist, 0, "?^?[?Q?b?g", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_ContinueKeepDist, 1, "?????", 1)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_ContinueKeepDist, 2, "??™¦??", 2)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_ContinueKeepDist, 3, "???????s????", 3)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_ContinueKeepDist, 4, "???K?[?h?m??", 4)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_ContinueKeepDist, 5, "??????K?[?h?m??", 5)

Goal.Activate = function (f1_arg0, f1_arg1, f1_arg2)
    f1_arg0.ContinueKeepDist(f1_arg0, f1_arg1, f1_arg2)
    
end

Goal.Update = function (f2_arg0, f2_arg1, f2_arg2)
    local f2_local0 = f2_arg2:GetParam(1)
    local f2_local1 = f2_arg2:GetParam(2)
    local f2_local2 = f2_arg1:GetDist(Target)
    if f2_arg2:GetLife() <= 0 then
        return GOAL_RESULT_Success
    end
    if f2_arg2:GetSubGoalNum() <= 0 then
        f2_arg0.ContinueKeepDist(f2_arg0, f2_arg1, f2_arg2)
        return GOAL_RESULT_Continue
    end
    if f2_arg1:IsActiveGoal(GOAL_COMMON_SidewayMove) and (f2_local1 <= f2_local2 or f2_local0 <= f2_local2) then
        f2_arg2:ClearSubGoal()
        f2_arg0.ContinueKeepDist(f2_arg0, f2_arg1, f2_arg2)
        return GOAL_RESULT_Continue
    end
    return GOAL_RESULT_Continue
    
end

Goal.ContinueKeepDist = function (f3_arg0, f3_arg1, f3_arg2)
    local f3_local0 = f3_arg2:GetParam(0)
    local f3_local1 = f3_arg2:GetParam(1)
    local f3_local2 = f3_arg2:GetParam(2)
    local f3_local3 = f3_arg2:GetParam(3)
    local f3_local4 = f3_arg2:GetParam(4)
    local f3_local5 = f3_arg2:GetParam(5)
    local f3_local6 = f3_arg1:GetDist(f3_local0)
    if f3_local2 <= f3_local6 then
        local f3_local7 = -1
        if f3_arg1:GetRandam_Int(1, 100) <= f3_local4 then
            f3_local7 = 9910
        end
        if f3_local2 <= f3_local0 then
            f3_arg2:AddSubGoal(GOAL_COMMON_ApproachTarget, f3_arg2:GetLife(), TARGET_ENE_0, (f3_local2 + f3_local1) / 2, TARGET_SELF, false, f3_local7):SetFailedEndOption(AI_GOAL_FAILED_END_OPT__PARENT_NEXT_SUB_GOAL)
        else
            f3_arg2:AddSubGoal(GOAL_COMMON_ApproachTarget, f3_arg2:GetLife(), TARGET_ENE_0, (f3_local2 + f3_local1) / 2, TARGET_SELF, true, f3_local7):SetFailedEndOption(AI_GOAL_FAILED_END_OPT__PARENT_NEXT_SUB_GOAL)
        end
    elseif f3_local6 <= f3_local1 then
        local f3_local7 = -1
        if f3_arg1:GetRandam_Int(1, 100) <= f3_local5 then
            f3_local7 = 9910
        end
        f3_arg2:AddSubGoal(GOAL_COMMON_LeaveTarget, f3_arg2:GetLife(), TARGET_ENE_0, (f3_local2 + f3_local1) / 2, TARGET_ENE_0, true, f3_local7):SetFailedEndOption(AI_GOAL_FAILED_END_OPT__PARENT_NEXT_SUB_GOAL)
    end
    f3_arg2:AddSubGoal(GOAL_COMMON_SidewayMove, f3_arg1:GetRandam_Float(3, 5), TARGET_ENE_0, f3_arg1:GetRandam_Int(0, 1), f3_arg1:GetRandam_Int(30, 45), true, true, Guard)
    
end


