REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_ApproachSettingDirection, 0, "??????", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_ApproachSettingDirection, 1, "???B???•c??", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_ApproachSettingDirection, 2, "??????", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_ApproachSettingDirection, 3, "?????", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_ApproachSettingDirection, 4, "?K?[?hEzState???", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_ApproachSettingDirection, 5, "???????", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_ApproachSettingDirection, 6, "?w???????????", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_ApproachSettingDirection, 7, "?????I?????A?????????????", 0)
REGISTER_GOAL_NO_INTERUPT(GOAL_COMMON_ApproachSettingDirection, true)
REGISTER_GOAL_NO_SUB_GOAL(GOAL_COMMON_ApproachSettingDirection, true)

function ApproachSettingDirection_Activate(f1_arg0, f1_arg1)
    local f1_local0 = f1_arg1:GetLife()
    local f1_local1 = f1_arg1:GetParam(0)
    local f1_local2 = f1_arg1:GetParam(1)
    local f1_local3 = f1_arg1:GetParam(2)
    local f1_local4 = f1_arg1:GetParam(3)
    local f1_local5 = f1_arg1:GetParam(4)
    local f1_local6 = f1_arg1:GetParam(5)
    local f1_local7 = f1_arg1:GetParam(6)
    f1_arg1:AddSubGoal(GOAL_COMMON_MoveToSomewhere, -1, f1_local1, f1_local6, f1_local2, f1_local3, f1_local4, f1_local7, 0, false, f1_local5, GOAL_RESULT_Continue, false)
    
end

function ApproachSettingDirection_Update(f2_arg0, f2_arg1, f2_arg2)
    local f2_local0 = f2_arg1:GetParam(7)
    if f2_arg1:GetSubGoalNum() <= 0 then
        return GOAL_RESULT_Success
    end
    if f2_arg1:GetLife() <= 0 then
        if f2_local0 == nil then
            return GOAL_RESULT_Failed
        else
            return GOAL_RESULT_Success
        end
    end
    return GOAL_RESULT_Continue
    
end

function ApproachSettingDirection_Terminate(f3_arg0, f3_arg1)
    
end

function ApproachSettingDirection_Interupt(f4_arg0, f4_arg1)
    return false
    
end


