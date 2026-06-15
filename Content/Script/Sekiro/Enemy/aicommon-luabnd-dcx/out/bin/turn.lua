REGISTER_GOAL_UPDATE_TIME(GOAL_COMMON_ApproachTarget, 0, 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_Turn, 0, "????^?[?Q?b?g", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_Turn, 1, "???????p?x", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_Turn, 2, "?K?[?hEzState???", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_Turn, 3, "?K?[?h?S?[???I???^?C?v", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_Turn, 4, "?K?[?h?S?[???F???????s?????????????", 0)
REGISTER_GOAL_NO_SUB_GOAL(GOAL_COMMON_Turn, true)

function Turn_Activate(f1_arg0, f1_arg1)
    local f1_local0 = f1_arg1:GetParam(2)
    local f1_local1 = f1_arg1:GetParam(3)
    local f1_local2 = f1_arg1:GetParam(4)
    GuardGoalSubFunc_Activate(f1_arg0, life_time, f1_local0)
    
end

function Turn_Update(f2_arg0, f2_arg1)
    local f2_local0 = f2_arg1:GetParam(0)
    f2_arg0:RequestEmergencyQuickTurn()
    f2_arg0:TurnTo(f2_local0)
    if Turn_IsLookToTarget(f2_arg0, f2_arg1) then
        return GOAL_RESULT_Success
    end
    local f2_local1 = f2_arg1:GetParam(2)
    local f2_local2 = f2_arg1:GetParam(3)
    local f2_local3 = f2_arg1:GetParam(4)
    return GuardGoalSubFunc_Update(f2_arg0, f2_arg1, f2_local1, f2_local2, f2_local3)
    
end

function Turn_Terminate(f3_arg0, f3_arg1)
    
end

function Turn_Interupt(f4_arg0, f4_arg1)
    local f4_local0 = f4_arg1:GetParam(2)
    local f4_local1 = f4_arg1:GetParam(3)
    return GuardGoalSubFunc_Interrupt(f4_arg0, f4_arg1, f4_local0, f4_local1)
    
end

function Turn_IsLookToTarget(f5_arg0, f5_arg1)
    local f5_local0 = f5_arg1:GetParam(1)
    if f5_local0 <= 0 then
        f5_local0 = 15
    end
    return f5_arg0:IsLookToTarget(f5_local0)
    
end


