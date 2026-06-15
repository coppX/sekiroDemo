REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_WalkAround, 0, "???????~????a", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_WalkAround, 1, "??????", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_WalkAround, 2, "?G????????ûÐ??", 0)

function WalkAround_Activate(f1_arg0, f1_arg1)
    local f1_local0 = f1_arg1:GetParam(0)
    local f1_local1 = f1_arg1:GetParam(1)
    local f1_local2 = f1_arg1:GetParam(2)
    local f1_local3 = not (f1_arg1:GetParam(3) == 0)
    local f1_local4 = 30
    local f1_local5 = POINT_WalkAroundPosition_Home
    if f1_local3 then
        f1_local5 = POINT_WalkAroundPosition_Free
    end
    if f1_local3 then
        f1_arg0:ChangeWalkAroundFreePoint()
    else
        f1_arg0:DecideWalkAroundPos()
    end
    local f1_local6 = f1_arg0:GetDist(f1_local5)
    if f1_local6 >= 2 then
        f1_arg1:AddSubGoal(GOAL_COMMON_MoveToSomewhere, f1_local4, f1_local5, AI_DIR_TYPE_CENTER, f1_local0, TARGET_SELF, f1_local1)
        f1_arg1:AddSubGoal(GOAL_COMMON_Wait, f1_arg0:GetRandam_Int(3, 6), TARGET_NONE, 0, 0, 0)
    else
        f1_arg1:AddSubGoal(GOAL_COMMON_Wait, 0.1, TARGET_NONE, 0, 0, 0)
    end
    
end

function WalkAround_Update(f2_arg0, f2_arg1)
    local f2_local0 = f2_arg1:GetParam(2)
    if f2_arg0:IsSearchTarget(TARGET_ENE_0) == true and f2_arg0:GetDist(TARGET_ENE_0) < f2_local0 then
        return GOAL_RESULT_Failed
    end
    return GOAL_RESULT_Continue
    
end

function WalkAround_Terminate(f3_arg0, f3_arg1)
    
end

function WalkAround_Interupt(f4_arg0, f4_arg1)
    return false
    
end


