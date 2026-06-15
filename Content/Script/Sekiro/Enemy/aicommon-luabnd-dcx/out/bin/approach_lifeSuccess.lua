REGISTER_GOAL_NO_SUB_GOAL(GOAL_COMMON_ApproachTarget_LifeSuccess, true)

function ApproachTargetLifeSuccess_Activate(f1_arg0, f1_arg1)
    f1_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, -1, f1_arg1:GetParam(0), f1_arg1:GetParam(1), f1_arg1:GetParam(2), f1_arg1:GetParam(3), f1_arg1:GetParam(4), f1_arg1:GetParam(5), f1_arg1:GetParam(6))
    
end

function ApproachTargetLifeSuccess_Update(f2_arg0, f2_arg1)
    if f2_arg1:GetSubGoalNum() <= 0 then
        return GOAL_RESULT_Success
    end
    if f2_arg1:GetLife() <= 0 then
        return GOAL_RESULT_Success
    end
    return GOAL_RESULT_Continue
    
end

function ApproachTargetLifeSuccess_Terminate(f3_arg0, f3_arg1)
    
end

function ApproachTargetLifeSuccess_Interupt(f4_arg0, f4_arg1)
    return false
    
end


