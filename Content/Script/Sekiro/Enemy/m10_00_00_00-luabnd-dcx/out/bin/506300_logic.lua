RegisterTableLogic(506300)

Logic.Main = function (f1_arg0, f1_arg1)
    f1_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 107710)
    f1_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 110060)
    f1_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 110015)
    if COMMON_HiPrioritySetup(f1_arg1, COMMON_FLAG_BOSS) then
        return true
    end
    COMMON_EzSetup(f1_arg1, COMMON_FLAG_BOSS)
    
end

Logic.Interrupt = function (f2_arg0, f2_arg1, f2_arg2)
    local f2_local0 = f2_arg1:GetSpecialEffectActivateInterruptType(0)
    if f2_arg1:IsInterupt(INTERUPT_ActivateSpecialEffect) then
        if f2_local0 == 107710 then
            f2_arg1:Replanning()
            return true
        elseif f2_arg1:GetSpecialEffectActivateInterruptType(0) == 110060 then
            f2_arg1:SetStringIndexedNumber("targetDeadFlag", 1)
            f2_arg1:Replanning()
            retval = false
        elseif f2_arg1:GetSpecialEffectActivateInterruptType(0) == 110015 then
            f2_arg1:SetStringIndexedNumber("targetDeadFlag", 0)
            f2_arg1:Replanning()
            retval = false
        end
    end
    return false
    
end


