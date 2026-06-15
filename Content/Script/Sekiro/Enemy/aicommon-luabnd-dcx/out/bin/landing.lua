REGISTER_GOAL_NO_INTERUPT(GOAL_COMMON_LiftOff, true)

function LiftOff_Activate(f1_arg0, f1_arg1)
    f1_arg1:AddSubGoal(GOAL_COMMON_Attack, 10, 9520, TARGET_NONE, DIST_None)
    
end

function LiftOff_Update(f2_arg0, f2_arg1)
    local f2_local0 = 5
    local f2_local1 = f2_arg0:GetDistY(TARGET_ENE_0)
    local f2_local2 = f2_arg1:GetLastSubGoalResult()
    if (f2_local2 == GOAL_RESULT_Success or f2_local2 == GOAL_RESULT_Failed) and (f2_arg0:IsLanding() or f2_local1 < f2_local0) then
        f2_arg1:AddSubGoal(GOAL_COMMON_Attack, 10, 9520, TARGET_NONE, DIST_None)
    end
    local f2_local3 = f2_arg0:IsLanding()
    if not f2_local3 and f2_local0 <= f2_local1 then
        return GOAL_RESULT_Success
    end
    return GOAL_RESULT_Continue
    
end

function LiftOff_Terminate(f3_arg0, f3_arg1)
    
end

function LiftOff_Interupt(f4_arg0, f4_arg1)
    return false
    
end

REGISTER_GOAL_NO_UPDATE(GOAL_COMMON_Landing, true)
REGISTER_GOAL_NO_INTERUPT(GOAL_COMMON_Landing, true)

function Landing_Activate(f5_arg0, f5_arg1)
    local f5_local0 = f5_arg1:GetParam(0)
    f5_arg0:SetAIFixedMoveTarget(f5_local0, TARGET_SELF, 0)
    local f5_local1 = f5_arg1:GetParam(1)
    f5_arg1:AddSubGoal(GOAL_COMMON_Landing_Move, 10, f5_local1)
    if f5_arg0:GetDistYSigned(TARGET_ENE_0) > 0 then
        f5_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 10, POINT_AI_FIXED_POS, 0.1, TARGET_SELF, false, -1)
    else
        f5_arg1:AddSubGoal(GOAL_COMMON_Landing_Landing, 10)
    end
    
end

function Landing_Update(f6_arg0, f6_arg1)
    return GOAL_RESULT_Continue
    
end

function Landing_Terminate(f7_arg0, f7_arg1)
    
end

function Landing_Interupt(f8_arg0, f8_arg1)
    return false
    
end

REGISTER_GOAL_UPDATE_TIME(GOAL_COMMON_Landing_Move, 0.5, 0.5)
REGISTER_GOAL_NO_INTERUPT(GOAL_COMMON_Landing_Move, true)

function Landing_Move_Activate(f9_arg0, f9_arg1)
    local f9_local0 = f9_arg1:GetParam(0)
    f9_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 10, POINT_AI_FIXED_POS, f9_local0, TARGET_SELF, false, -1)
    
end

function Landing_Move_Update(f10_arg0, f10_arg1)
    local f10_local0 = f10_arg0:GetDistXZ(POINT_AI_FIXED_POS)
    if f10_local0 < 1 then
        return GOAL_RESULT_Success
    end
    if f10_arg0:IsLanding() then
        return GOAL_RESULT_Failed
    end
    return GOAL_RESULT_Continue
    
end

function Landing_Move_Terminate(f11_arg0, f11_arg1)
    
end

function Landing_Move_Interupt(f12_arg0, f12_arg1)
    return false
    
end

REGISTER_GOAL_UPDATE_TIME(GOAL_COMMON_Landing_Landing, 0.5, 0.5)
REGISTER_GOAL_NO_INTERUPT(GOAL_COMMON_Landing_Landing, true)

function Landing_Landing_Activate(f13_arg0, f13_arg1)
    f13_arg1:AddSubGoal(GOAL_COMMON_Attack, f13_arg1:GetLife(), 9510, TARGET_NONE, DIST_None)
    
end

function Landing_Landing_Update(f14_arg0, f14_arg1)
    if f14_arg0:IsLanding() then
        local f14_local0 = f14_arg1:GetNumber(0)
        if f14_local0 > 10 then
            return GOAL_RESULT_Success
        else
            f14_local0 = f14_local0 + 1
            f14_arg1:SetNumber(0, f14_local0)
        end
    end
    local f14_local0 = f14_arg1:GetLastSubGoalResult()
    if (f14_local0 == GOAL_RESULT_Success or f14_local0 == GOAL_RESULT_Failed) and not f14_arg0:IsLanding() then
        f14_arg1:AddSubGoal(GOAL_COMMON_Attack, f14_arg1:GetLife(), 9510, TARGET_NONE, DIST_None)
    end
    if f14_arg0:GetDistYSigned(POINT_AI_FIXED_POS) > 1 then
        f14_arg0:PrintText("[Landing_Landing_Update]?^?[?Q?b?g??????????????????B???s????????B")
        return GOAL_RESULT_Failed
    end
    return GOAL_RESULT_Continue
    
end

function Landing_Landing_Terminate(f15_arg0, f15_arg1)
    
end

function Landing_Landing_Interupt(f16_arg0, f16_arg1)
    return false
    
end


