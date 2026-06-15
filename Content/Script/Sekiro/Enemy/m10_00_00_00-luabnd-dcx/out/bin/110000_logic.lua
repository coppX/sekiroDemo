RegisterTableLogic(110000)

Logic.Main = function (f1_arg0, f1_arg1)
    f1_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 3503000)
    if COMMON_HiPrioritySetup(f1_arg1) then
        return true
    end
    if f1_arg1:HasSpecialEffectId(TARGET_SELF, 220020) then
        if f1_arg0.KugutsuAct(f1_arg1, goal) then
            return true
        end
    elseif f1_arg1:IsFinishTimer(AI_TIMER_TEKIMAWASHI_REACTION) == false then
        JuzuReaction(f1_arg1, goal, 0, 20105)
        return true
    end
    COMMON_EzSetup(f1_arg1)
    
end

Logic.Interrupt = function (f2_arg0, f2_arg1, f2_arg2)
    local f2_local0 = f2_arg1:GetSpecialEffectActivateInterruptType(0)
    if f2_arg1:IsInterupt(INTERUPT_ActivateSpecialEffect) and f2_local0 == 3503000 then
        return f2_arg0.FumareDokuhakiReaction(f2_arg1, f2_arg2)
    end
    return false
    
end

Logic.FumareDokuhakiReaction = function (f3_arg0, f3_arg1, f3_arg2)
    local f3_local0 = f3_arg0:GetDist(TARGET_ENE_0)
    local f3_local1 = f3_arg0:GetRandam_Int(1, 100)
    local f3_local2 = 20020
    local f3_local3 = 0
    local f3_local4 = 0
    f3_arg1:ClearSubGoal()
    f3_arg0:AddTopGoal(GOAL_COMMON_AttackImmediateAction, 0.5, f3_local2, TARGET_SELF, 9999, f3_local3, f3_local4, 0, 0)
    return true
    
end

Logic.KugutsuAct = function (f4_arg0, f4_arg1)
    if f4_arg0:IsBattleState() == false and f4_arg0:IsFindState() == false then
        f4_arg0:AddTopGoal(GOAL_KugutsuAct_20000_Battle, -1)
        return true
    end
    return false
    
end


