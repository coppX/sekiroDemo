RegisterTableLogic(LOGIC_ID_Nanimosinai11001)

Logic.Main = function (f1_arg0, f1_arg1)
    f1_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, COMMON_SP_EFFECT_QUICK_TURN_TO_PC)
    f1_arg1:AddTopGoal(GOAL_COMMON_Wait, 10, TARGET_NONE, 0, 0, 0)
    
end

Logic.Interrupt = function (f2_arg0, f2_arg1, f2_arg2)
    if f2_arg1:IsInterupt(INTERUPT_ActivateSpecialEffect) then
        local f2_local0 = f2_arg1:GetSpecialEffectActivateInterruptType(0)
        if f2_local0 == COMMON_SP_EFFECT_QUICK_TURN_TO_PC then
            f2_arg2:ClearSubGoal()
            f2_arg1:AddTopGoal(GOAL_COMMON_Turn, 3, TARGET_LOCALPLAYER, 20, -1, GOAL_RESULT_Success, true)
            f2_arg1:AddTopGoal(GOAL_COMMON_Wait, 0.5, TARGET_LOCALPLAYER, 0, 0, 0)
            return true
        end
    end
    return false
    
end


