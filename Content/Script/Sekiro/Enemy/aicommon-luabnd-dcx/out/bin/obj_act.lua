REGISTER_GOAL_UPDATE_TIME(GOAL_COMMON_ObjActTest, 0.5, 0.6)

function ObjActTest_Activate(f1_arg0, f1_arg1)
    local f1_local0 = f1_arg1:GetParam(0)
    local f1_local1 = f1_arg1:GetParam(1)
    f1_arg0:KickEvent(0)
    
end

function ObjActTest_Update(f2_arg0, f2_arg1)
    if f2_arg0:IsFinishObjAct() then
        return GOAL_RESULT_Success
    end
    if f2_arg1:GetLife() <= 0 then
        return GOAL_RESULT_Failed
    end
    if not f2_arg0:IsExistReqObjAct() then
        f2_arg1:SetNumber(0, 1)
        return GOAL_RESULT_Failed
    end
    return GOAL_RESULT_Continue
    
end

function ObjActTest_Terminate(f3_arg0, f3_arg1)
    f3_arg0:ClearFinishObjAct()
    
end

REGISTER_GOAL_NO_INTERUPT(GOAL_COMMON_ObjActTest, true)

function ObjActTest_Interupt(f4_arg0, f4_arg1)
    return false
    
end


