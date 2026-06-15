REGISTER_GOAL_UPDATE_TIME(GOAL_COMMON_Fall, 0.1, 0.2)
REGISTER_GOAL_NO_INTERUPT(GOAL_COMMON_Fall, true)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_Fall, 0, "?^?[?Q?b?g?yType?z", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_Fall, 1, "?????J?nEzState???", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_Fall, 2, "??????~EzState???", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_Fall, 3, "??????~?}?[?W??[m]", 0)

function Fall_Activate(f1_arg0, f1_arg1)
    local f1_local0 = f1_arg1:GetParam(0)
    local f1_local1 = f1_arg1:GetParam(1)
    local f1_local2 = f1_arg0:GetDistYSigned(f1_local0)
    if f1_local2 <= 0 then
        f1_arg0:SetAttackRequest(f1_local1)
    end
    
end

function Fall_Update(f2_arg0, f2_arg1)
    local f2_local0 = f2_arg1:GetParam(0)
    local f2_local1 = f2_arg1:GetParam(1)
    local f2_local2 = f2_arg1:GetParam(3)
    local f2_local3 = f2_arg0:GetDistYSigned(f2_local0)
    if f2_local2 < f2_local3 then
        return GOAL_RESULT_Success
    else
        f2_arg0:SetAttackRequest(f2_local1)
    end
    return GOAL_RESULT_Continue
    
end

function Fall_Terminate(f3_arg0, f3_arg1)
    local f3_local0 = f3_arg1:GetParam(2)
    f3_arg0:SetAttackRequest(f3_local0)
    
end

function Fall_Interupt(f4_arg0, f4_arg1)
    return false
    
end


