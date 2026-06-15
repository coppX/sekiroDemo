REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_DashAttack, 0, "??????yType?z", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_DashAttack, 1, "?U???J?n?????ym?z", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_DashAttack, 2, "?U??EzState???", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_DashAttack, 3, "?K?[?hEzState???", 0)
REGISTER_GOAL_NO_UPDATE(GOAL_COMMON_DashAttack, true)
REGISTER_GOAL_NO_INTERUPT(GOAL_COMMON_DashAttack, true)

function DashAttack_Activate(f1_arg0, f1_arg1)
    f1_arg0:StartDash()
    local f1_local0 = f1_arg1:GetParam(0)
    local f1_local1 = f1_arg1:GetParam(1)
    local f1_local2 = f1_arg1:GetParam(3)
    f1_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 10, f1_local0, f1_local1, TARGET_SELF, false, f1_local2)
    local f1_local3 = f1_arg1:GetParam(2)
    f1_arg1:AddSubGoal(GOAL_COMMON_DashAttack_Attack, 10, f1_local0, f1_local3)
    
end

function DashAttack_Terminate(f2_arg0, f2_arg1)
    f2_arg0:EndDash()
    
end

function DashAttack_Update(f3_arg0, f3_arg1, f3_arg2)
    return GOAL_RESULT_Continue
    
end

function DashAttack_Interupt(f4_arg0, f4_arg1)
    return false
    
end

REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_DashAttack_Attack, 0, "??????yType?z", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_DashAttack_Attack, 1, "?U??EzState???", 0)
REGISTER_GOAL_NO_UPDATE(GOAL_COMMON_DashAttack_Attack, true)
REGISTER_GOAL_NO_INTERUPT(GOAL_COMMON_DashAttack_Attack, true)

function DashAttack_Attack_Activate(f5_arg0, f5_arg1)
    local f5_local0 = f5_arg1:GetParam(0)
    local f5_local1 = f5_arg1:GetParam(1)
    f5_arg0:MoveTo(f5_local0, AI_DIR_TYPE_CENTER, 0, false)
    f5_arg1:AddSubGoal(GOAL_COMMON_Attack, 10, f5_local1, f5_local0, DIST_None)
    
end

function DashAttack_Attack_Update(f6_arg0, f6_arg1)
    return GOAL_RESULT_Continue
    
end

function DashAttack_Attack_Terminate(f7_arg0, f7_arg1)
    
end

function DashAttack_Attack_Interupt(f8_arg0, f8_arg1)
    return false
    
end


