function WalkAroundOnFailedPath_Activate(f1_arg0, f1_arg1)
    local f1_local0 = f1_arg1:GetParam(0)
    f1_arg1:SetTimer(0, f1_local0)
    f1_arg1:AddSubGoal(GOAL_COMMON_Wait, 1, 0, 0, 0, 0)
    f1_arg0:BeginWalkAroundFree()
    
end

function WalkAroundOnFailedPath_Update(f2_arg0, f2_arg1)
    local f2_local0 = GOAL_RESULT_Continue
    if true == f2_arg1:IsFinishTimer(0) then
        local f2_local1 = f2_arg0:CheckDoesExistPath(TARGET_ENE_0, AI_DIR_TYPE_L, 0.5, 0)
        if true == f2_local1 then
            f2_local0 = GOAL_RESULT_Success
        else
            local f2_local2 = f2_arg1:GetParam(0)
            f2_arg1:SetTimer(0, f2_local2)
        end
    end
    if f2_arg1:GetSubGoalNum() <= 0 then
        WalkAroundFailedPath_AddInnerGoal(f2_arg0, f2_arg1)
    end
    return f2_local0
    
end

function WalkAroundOnFailedPath_Terminate(f3_arg0, f3_arg1)
    f3_arg0:EndWalkAroundFree()
    
end

function WalkAroundOnFailedPath_Interupt(f4_arg0, f4_arg1)
    if f4_arg0:IsInterupt(INTERUPT_MovedEnd_OnFailedPath) then
        return true
    end
    return false
    
end

function WalkAroundFailedPath_AddInnerGoal(f5_arg0, f5_arg1)
    local f5_local0 = POINT_WalkAroundPosition_Free
    f5_arg0:ChangeWalkAroundFreePoint()
    local f5_local1 = f5_arg0:GetDist(f5_local0)
    if f5_local1 >= 2 then
        f5_arg1:AddSubGoal(GOAL_COMMON_MoveToSomewhere, 30, f5_local0, AI_DIR_TYPE_CENTER, 1, TARGET_ENE_0, true)
        f5_arg1:AddSubGoal(GOAL_COMMON_Wait, f5_arg0:GetRandam_Int(3, 6), TARGET_ENE_0, 0, 0, 0)
    else
        f5_arg1:AddSubGoal(GOAL_COMMON_Wait, 0.1, TARGET_ENE_0, 0, 0, 0)
    end
    
end


