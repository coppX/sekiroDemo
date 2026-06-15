function MoveToMovePointAir_Activate(f1_arg0, f1_arg1)
    local f1_local0 = f1_arg1:GetParam(0)
    local f1_local1 = f1_arg1:GetParam(1)
    local f1_local2 = f1_arg1:GetParam(2)
    local f1_local3 = f1_arg1:GetParam(3)
    local f1_local4 = f1_arg1:GetParam(4)
    f1_arg0:SetAIFixedMoveTarget(f1_local0, f1_local2, 0)
    
end

function MoveToMovePointAir_Update(f2_arg0, f2_arg1)
    return GOAL_RESULT_Continue
    
end

function MoveToMovePointAir_Terminate(f3_arg0, f3_arg1)
    
end

REGISTER_GOAL_NO_INTERUPT(GOAL_COMMON_MoveToMovePointAir, true)

function MoveToMovePointAir_Interupt(f4_arg0, f4_arg1)
    return false
    
end


