RegisterTableGoal(GOAL_COMMON_BackToHome_With_Parry, "BackToHomeWithParry")
REGISTER_GOAL_NO_SUB_GOAL(GOAL_COMMON_BackToHome_With_Parry, true)

Goal.Initialize = function (f1_arg0, f1_arg1, f1_arg2)
    
end

Goal.Activate = function (f2_arg0, f2_arg1, f2_arg2)
    f2_arg2:AddSubGoal(GOAL_COMMON_BackToHome, f2_arg2:GetLife(), 0, false, 0, 0, TARGET_ENE_0)
    
end

Goal.Update = function (f3_arg0, f3_arg1, f3_arg2)
    return Update_Default_NoSubGoal(f3_arg0, f3_arg1, f3_arg2)
    
end

Goal.Terminate = function (f4_arg0, f4_arg1, f4_arg2)
    
end

Goal.Interrupt = function (f5_arg0, f5_arg1, f5_arg2)
    if f5_arg1:IsInterupt(INTERUPT_ParryTiming) then
        return Common_Parry(f5_arg1, f5_arg2, 0, 0)
    end
    if f5_arg1:IsInterupt(INTERUPT_ShootImpact) then
        local f5_local0 = -1
        if f5_arg1:HasSpecialEffectId(TARGET_SELF, 221000) then
            f5_local0 = 0
        elseif f5_arg1:HasSpecialEffectId(TARGET_SELF, 221001) then
            f5_local0 = 1
        elseif f5_arg1:HasSpecialEffectId(TARGET_SELF, 221002) then
            f5_local0 = 2
        end
        if f5_local0 == -1 then
            return false
        else
            f5_arg2:ClearSubGoal()
            f5_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3100, TARGET_ENE_0, 9999, 0)
            return true
        end
    end
    return false
    
end


