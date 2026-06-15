function WaitOnFailedPath_Activate(f1_arg0, f1_arg1)
    f1_arg1:AddSubGoal(GOAL_COMMON_Wait, 1, 0, 0, 0, 0)
    
end

function WaitOnFailedPath_Update(f2_arg0, f2_arg1)
    local f2_local0 = GOAL_RESULT_Continue
    if f2_arg1:GetSubGoalNum() <= 0 then
        doesExist = f2_arg0:CheckDoesExistPath(TARGET_ENE_0, AI_DIR_TYPE_L, 0.5, 0)
        if true == doesExist then
            f2_local0 = GOAL_RESULT_Success
        else
            checkInterval = f2_arg1:GetParam(0)
            f2_arg1:AddSubGoal(GOAL_COMMON_Wait, checkInterval, 0, 0, 0, 0)
            f2_local0 = GOAL_RESULT_Continue
        end
    end
    return f2_local0
    
end

function WaitOnFailedPath_Terminate(f3_arg0, f3_arg1)
    
end

function WaitOnFailedPath_Interupt(f4_arg0, f4_arg1)
    if f4_arg0:IsInterupt(INTERUPT_MovedEnd_OnFailedPath) then
        return true
    end
    return true
    
end


