function BackToHomeOnFailedPath_Activate(f1_arg0, f1_arg1)
    local f1_local0 = f1_arg1:GetParam(0)
    f1_arg1:SetTimer(0, f1_local0)
    local f1_local1 = f1_arg1:GetParam(1)
    f1_arg1:AddSubGoal(GOAL_COMMON_BackToHome, 100, f1_local1)
    
end

function BackToHomeOnFailedPath_Update(f2_arg0, f2_arg1)
    local f2_local0 = GOAL_RESULT_Continue
    if true == f2_arg1:IsFinishTimer(0) then
        local f2_local1 = false
        if true == f2_arg0:IsLookToTarget(TARGET_ENE_0, 40) then
            f2_local1 = f2_arg0:CheckDoesExistPath(TARGET_ENE_0, AI_DIR_TYPE_L, 0.5, 0)
        end
        if true == f2_local1 then
            f2_local0 = GOAL_RESULT_Success
        else
            local f2_local2 = f2_arg1:GetParam(0)
            f2_arg1:SetTimer(0, f2_local2)
        end
    end
    if f2_arg1:GetSubGoalNum() <= 0 then
        return GOAL_RESULT_Success
    end
    return f2_local0
    
end

function BackToHomeOnFailedPath_Terminate(f3_arg0, f3_arg1)
    
end

function BackToHomeOnFailedPath_Interupt(f4_arg0, f4_arg1)
    if f4_arg0:IsInterupt(INTERUPT_MovedEnd_OnFailedPath) then
        return true
    end
    return false
    
end


