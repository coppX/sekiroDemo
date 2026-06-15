RegisterTableGoal(GOAL_COMMON_LeaveTarget_LifeSuccess, "LeaveTargetLifeSuccess")
REGISTER_GOAL_NO_SUB_GOAL(GOAL_COMMON_LeaveTarget_LifeSuccess, true)

Goal.Activate = function (f1_arg0, f1_arg1, f1_arg2)
    f1_arg2:AddSubGoal(GOAL_COMMON_LeaveTarget, f1_arg2:GetLife(), f1_arg2:GetParam(0), f1_arg2:GetParam(1), f1_arg2:GetParam(2), f1_arg2:GetParam(3), f1_arg2:GetParam(4), f1_arg2:GetParam(5), f1_arg2:GetParam(6))
    
end

Goal.Update = function (f2_arg0, f2_arg1, f2_arg2)
    if f2_arg2:GetSubGoalNum() <= 0 then
        return GOAL_RESULT_Success
    end
    if f2_arg2:GetLife() <= 0 then
        return GOAL_RESULT_Success
    end
    return GOAL_RESULT_Continue
    
end


