RegisterTableLogic(140010)

Logic.Main = function (f1_arg0, f1_arg1)
    if COMMON_HiPrioritySetup(f1_arg1) then
        return true
    end
    if f1_arg1:HasSpecialEffectId(TARGET_SELF, 205080) and _COMMON_AddStateTransitionGoal(f1_arg1, COMMON_FLAG_BOSS) then
        return true
    else
    end
    if f1_arg1:HasSpecialEffectId(TARGET_SELF, 220020) then
        if f1_arg0.KugutsuAct(f1_arg1, goal) then
            return true
        end
    elseif f1_arg1:IsFinishTimer(AI_TIMER_TEKIMAWASHI_REACTION) == false then
        local f1_local0 = f1_arg1:GetExcelParam(AI_EXCEL_THINK_PARAM_TYPE__battleGoalID)
        if f1_local0 == GOAL_Kenkaku_weak_140000_Battle then
            JuzuReaction(f1_arg1, goal, 0, 20105)
        else
            JuzuReaction(f1_arg1, goal, 1, 20105)
        end
        return true
    end
    if f1_arg1:HasSpecialEffectId(TARGET_SELF, 205080) then
        _COMMON_SetBattleGoal(f1_arg1)
    else
        COMMON_EzSetup(f1_arg1)
    end
    
end

Logic.Interrupt = function (f2_arg0, f2_arg1, f2_arg2)
    return false
    
end

Logic.KugutsuAct = function (f3_arg0, f3_arg1)
    if f3_arg0:IsBattleState() == false and f3_arg0:IsFindState() == false then
        f3_arg0:AddTopGoal(GOAL_KugutsuAct_20000_Battle, -1)
        return true
    end
    return false
    
end


