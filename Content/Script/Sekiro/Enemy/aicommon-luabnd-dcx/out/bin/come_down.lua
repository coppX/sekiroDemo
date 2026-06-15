REGISTER_GOAL_UPDATE_TIME(GOAL_COMMON_ComeDown, 0.5, 0.5)
REGISTER_GOAL_NO_INTERUPT(GOAL_COMMON_ComeDown, true)

function ComeDown_Activate(f1_arg0, f1_arg1)
    f1_arg1:AddSubGoal(GOAL_COMMON_Attack, f1_arg1:GetLife(), 9510, TARGET_NONE, DIST_None)
    
end

function ComeDown_Update(f2_arg0, f2_arg1)
    f2_arg0:SetNumber(0, 0)
    local f2_local0 = f2_arg1:GetParam(0)
    if f2_arg0:IsLanding() then
        return GOAL_RESULT_Failed
    end
    local f2_local1 = f2_arg1:GetLastSubGoalResult()
    if f2_local1 == GOAL_RESULT_Success or f2_local1 == GOAL_RESULT_Failed then
        local f2_local2 = f2_arg0:GetDistY(TARGET_ENE_0)
        if f2_local2 < f2_local0 then
            f2_arg1:AddSubGoal(GOAL_COMMON_Attack, f2_arg1:GetLife(), 9510, TARGET_NONE, DIST_None)
        end
    end
    local f2_local2 = f2_arg0:GetDistY(TARGET_ENE_0)
    if f2_local2 <= f2_local0 then
        f2_arg0:SetNumber(0, 1)
        return GOAL_RESULT_Success
    end
    return GOAL_RESULT_Continue
    
end

function ComeDown_Terminate(f3_arg0, f3_arg1)
    
end

function ComeDown_Interupt(f4_arg0, f4_arg1)
    return false
    
end


