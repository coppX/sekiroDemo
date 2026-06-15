function TeamCallHelp_Activate(f1_arg0, f1_arg1)
    local f1_local0 = f1_arg0:GetExcelParam(AI_EXCEL_THINK_PARAM_TYPE__callHelp_CallActionId)
    local f1_local1 = f1_arg1:GetParam(0)
    f1_arg0:TeamHelp_ReserveCall()
    f1_arg0:TurnTo(f1_local1)
    if f1_arg0:IsLookToTarget() == true then
        f1_arg0:SetAttackRequest(f1_local0)
    end
    
end

function TeamCallHelp_Update(f2_arg0, f2_arg1)
    local f2_local0 = f2_arg0:GetExcelParam(AI_EXCEL_THINK_PARAM_TYPE__callHelp_CallActionId)
    local f2_local1 = f2_arg1:GetParam(0)
    if f2_arg1:GetLife() <= 0 then
        return GOAL_RESULT_Success
    end
    if f2_arg0:IsFinishAttack() then
        return GOAL_RESULT_Success
    end
    if f2_arg0:IsLookToTarget() == true then
        if f2_arg0:IsStartAttack() == false then
            f2_arg0:SetAttackRequest(f2_local0)
        end
    else
        f2_arg0:TurnTo(f2_local1)
    end
    return GOAL_RESULT_Continue
    
end

function TeamCallHelp_Terminate(f3_arg0, f3_arg1)
    f3_arg0:TeamHelp_Call()
    
end

REGISTER_GOAL_NO_INTERUPT(GOAL_COMMON_TeamCallHelp, true)

function TeamCallHelp_Interupt(f4_arg0, f4_arg1)
    return false
    
end


