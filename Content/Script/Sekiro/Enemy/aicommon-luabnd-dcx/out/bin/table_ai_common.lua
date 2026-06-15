g_LogicTable = {}
g_GoalTable = {}
Logic = nil
Goal = nil

function RegisterTableLogic(f1_arg0)
    REGISTER_LOGIC_FUNC(f1_arg0, "TableLogic_" .. f1_arg0, "TableLogic_" .. f1_arg0 .. "_Interrupt")
    Logic = {}
    g_LogicTable[f1_arg0] = Logic
    
end

function RegisterTableGoal(f2_arg0, f2_arg1)
    REGISTER_GOAL(f2_arg0, f2_arg1)
    Goal = {}
    g_GoalTable[f2_arg0] = Goal
    
end

function SetupScriptLogicInfo(f3_arg0, f3_arg1)
    local f3_local0 = g_LogicTable[f3_arg0]
    if f3_local0 ~= nil then
        local f3_local1 = _CreateInterruptTypeInfoTable(f3_local0)
        local f3_local2 = not (f3_local0.Update == nil)
        local f3_local3 = _IsInterruptFuncExist(f3_local1, f3_local0)
        f3_local0.InterruptInfoTable = f3_local1
        f3_arg1:SetTableLogic(f3_local2, f3_local3)
    else
        f3_arg1:SetNormalLogic()
    end
    
end

function SetupScriptGoalInfo(f4_arg0, f4_arg1)
    local f4_local0 = g_GoalTable[f4_arg0]
    if f4_local0 ~= nil then
        local f4_local1 = _CreateInterruptTypeInfoTable(f4_local0)
        local f4_local2 = not (f4_local0.Update == nil)
        local f4_local3 = not (f4_local0.Terminate == nil)
        local f4_local4 = _IsInterruptFuncExist(f4_local1, f4_local0)
        local f4_local5 = not (f4_local0.Initialize == nil)
        f4_local0.InterruptInfoTable = f4_local1
        f4_arg1:SetTableGoal(f4_local2, f4_local3, f4_local4, f4_local5)
    else
        f4_arg1:SetNormalGoal()
    end
    
end

function ExecTableLogic(f5_arg0, f5_arg1)
    local f5_local0 = g_LogicTable[f5_arg1]
    if f5_local0 ~= nil then
        local f5_local1 = f5_local0.Main
        if f5_local1 ~= nil then
            f5_local1(f5_local0, f5_arg0)
        end
    end
    
end

function UpdateTableLogic(f6_arg0, f6_arg1)
    local f6_local0 = g_LogicTable[f6_arg1]
    if f6_local0 ~= nil then
        local f6_local1 = f6_local0.Update
        if f6_local1 ~= nil then
            f6_local1(f6_local0, f6_arg0)
        end
    end
    
end

function InitializeTableGoal(f7_arg0, f7_arg1, f7_arg2)
    local f7_local0 = false
    local f7_local1 = g_GoalTable[f7_arg2]
    if f7_local1 ~= nil then
        local f7_local2 = f7_local1.Initialize
        if f7_local2 ~= nil then
            f7_local2(f7_local1, f7_arg0, f7_arg1, f7_arg0:GetChangeBattleStateCount())
            f7_local0 = true
        end
    end
    return f7_local0
    
end

function ActivateTableGoal(f8_arg0, f8_arg1, f8_arg2)
    local f8_local0 = false
    local f8_local1 = g_GoalTable[f8_arg2]
    if f8_local1 ~= nil then
        local f8_local2 = f8_local1.Activate
        if f8_local2 ~= nil then
            f8_local0 = f8_local2(f8_local1, f8_arg0, f8_arg1)
        end
    end
    return f8_local0
    
end

function UpdateTableGoal(f9_arg0, f9_arg1, f9_arg2)
    local f9_local0 = GOAL_RESULT_Continue
    local f9_local1 = g_GoalTable[f9_arg2]
    if f9_local1 ~= nil then
        local f9_local2 = f9_local1.Update
        if f9_local2 ~= nil then
            f9_local0 = f9_local2(f9_local1, f9_arg0, f9_arg1)
        end
    end
    return f9_local0
    
end

function TerminateTableGoal(f10_arg0, f10_arg1, f10_arg2)
    local f10_local0 = false
    local f10_local1 = g_GoalTable[f10_arg2]
    if f10_local1 ~= nil then
        local f10_local2 = f10_local1.Terminate
        if f10_local2 ~= nil then
            f10_local0 = f10_local2(f10_local1, f10_arg0, f10_arg1)
        end
    end
    return f10_local0
    
end

function InterruptTableLogic(f11_arg0, f11_arg1, f11_arg2, f11_arg3)
    local f11_local0 = false
    local f11_local1 = g_LogicTable[f11_arg2]
    if f11_local1 ~= nil then
        f11_local0 = _InterruptTableGoal_TypeCall(f11_arg0, f11_arg1, f11_local1, f11_arg3)
    end
    return f11_local0
    
end

function InterruptTableLogic_Common(f12_arg0, f12_arg1, f12_arg2)
    local f12_local0 = false
    local f12_local1 = g_LogicTable[f12_arg2]
    if f12_local1 ~= nil and f12_local1.Interrupt ~= nil and f12_local1.Interrupt(f12_local1, f12_arg0, f12_arg1) then
        f12_local0 = true
    end
    if f12_arg0:IsInterupt(INTERUPT_MovedEnd_OnFailedPath) then
        f12_arg0:DecideWalkAroundPos()
        local f12_local2 = f12_arg0:GetActTypeOnFailedPathEnd()
        if 0 == f12_local2 then
            f12_local0 = true
        elseif 1 == f12_local2 then
            f12_arg1:ClearSubGoal()
            f12_arg0:AddTopGoal(GOAL_COMMON_Wait_On_FailedPath, -1, 0.1)
            f12_local0 = true
        elseif 2 == f12_local2 then
            f12_arg1:ClearSubGoal()
            f12_arg0:AddTopGoal(GOAL_COMMON_Wait_On_FailedPath, 0.5, 0.1)
            f12_local0 = true
        elseif 3 == f12_local2 then
            f12_arg1:ClearSubGoal()
            f12_arg0:AddTopGoal(GOAL_COMMON_WalkAround_On_FailedPath, -1, 0.1)
            f12_local0 = true
        elseif 4 == f12_local2 then
            f12_arg1:ClearSubGoal()
            f12_arg0:AddTopGoal(GOAL_COMMON_BackToHome_On_FailedPath, 100, 1, 2)
            f12_local0 = true
        end
        f12_arg0:SetStringIndexedNumber("Reach_EndOnFailedPath", 1)
        return f12_local0
    end
    if f12_arg0:HasSpecialEffectId(TARGET_SELF, 205050) or f12_arg0:HasSpecialEffectId(TARGET_SELF, 205051) then
        return false
    end
    if f12_arg0:IsInterupt(INTERUPT_ActivateSpecialEffect) then
        local f12_local2 = f12_arg0:GetSpecialEffectActivateInterruptType(0)
        if f12_local2 == COMMON_SP_EFFECT_PC_RETURN then
            f12_arg0:Replanning()
            return true
        elseif f12_local2 == COMMON_SP_EFFECT_PC_DEAD then
            f12_arg0:SetStringIndexedNumber("targetDeadFlag", 1)
            f12_arg0:Replanning()
            return false
        elseif f12_local2 == COMMON_SP_EFFECT_PC_REVIVAL_AFTER_2 and f12_arg0:HasSpecialEffectId(TARGET_SELF, 200000) then
            if f12_arg0:HasSpecialEffectId(TARGET_SELF, COMMON_SP_EFFECT_BOSS) then
                f12_arg0:Replanning()
                return true
            else
                f12_arg1:ClearSubGoal()
                f12_arg0:AddTopGoal(GOAL_COMMON_EndureAttack, 10, 1040, TARGET_ENE_0, 9999, 0, 0, 0, 0)
                return true
            end
        elseif f12_local2 == COMMON_SP_EFFECT_PC_REVIVAL_AFTER_2 and f12_arg0:HasSpecialEffectId(TARGET_SELF, 200004) then
            if f12_arg0:HasSpecialEffectId(TARGET_SELF, COMMON_SP_EFFECT_BOSS) then
                f12_arg0:Replanning()
                return true
            else
                f12_arg1:ClearSubGoal()
                f12_arg0:AddTopGoal(GOAL_COMMON_EndureAttack, 10, 401040, TARGET_ENE_0, 9999, 0, 0, 0, 0)
                return true
            end
        elseif f12_local2 == COMMON_SP_EFFECT_PC_REVIVAL_AFTER_3 then
            f12_arg0:Replanning()
            return true
        elseif f12_local2 == COMMON_SP_EFFECT_QUICK_TURN_TO_PC then
            f12_arg1:ClearSubGoal()
            f12_arg0:AddTopGoal(GOAL_COMMON_Turn, 3, TARGET_LOCALPLAYER, 20, -1, GOAL_RESULT_Success, true):SetFailedEndOption(AI_GOAL_FAILED_END_OPT__PARENT_NEXT_SUB_GOAL)
            f12_arg0:AddTopGoal(GOAL_COMMON_Wait, 0.5, TARGET_LOCALPLAYER, 0, 0, 0)
            return true
        elseif f12_local2 == COMMON_SP_EFFECT_ENEMY_TURN then
            if f12_arg0:HasSpecialEffectId(TARGET_SELF, 240100) == false then
                f12_arg0:ClearEnemyTarget()
            end
            f12_arg0:SetTimer(AI_TIMER_TEKIMAWASHI_REACTION, 3)
            f12_arg0:Replanning()
            return true
        elseif f12_local2 == COMMON_SP_EFFECT_BLOOD_SMOKE then
            if f12_arg0:IsBattleState() or f12_arg0:IsFindState() then
                if f12_arg0:HasSpecialEffectId(TARGET_SELF, COMMON_SP_EFFECT_ZAKO_REACTION) or f12_arg0:HasSpecialEffectId(TARGET_SELF, COMMON_SP_EFFECT_ZAKO_NOREACTION) then
                    f12_arg0:ClearEnemyTarget()
                    return true
                elseif f12_arg0:HasSpecialEffectId(TARGET_SELF, COMMON_SP_EFFECT_CHUBOSS_REACTION) then
                    f12_arg0:SetNumber(AI_NUMBER_BLOOD_SMOKE_BLINDNESS, 1)
                end
            end
        elseif f12_local2 == COMMON_SP_EFFECT_HIDE_IN_BLOOD then
            if (f12_arg0:IsBattleState() or f12_arg0:IsFindState()) and (f12_arg0:HasSpecialEffectId(TARGET_SELF, COMMON_SP_EFFECT_ZAKO_REACTION) or f12_arg0:HasSpecialEffectId(TARGET_SELF, COMMON_SP_EFFECT_ZAKO_NOREACTION)) then
                f12_arg0:ClearEnemyTarget()
                return true
            end
        elseif f12_local2 == 200250 then
            if f12_arg0:IsFinishTimer(13) then
                f12_arg0:SetStringIndexedNumber("ConsecutiveGuardCount", 1)
            else
                f12_arg0:SetStringIndexedNumber("ConsecutiveGuardCount", f12_arg0:GetStringIndexedNumber("ConsecutiveGuardCount") + 1)
            end
            f12_arg0:SetTimer(13, 1)
        elseif f12_local2 == 200210 or f12_local2 == 200211 then
            f12_arg0:SetStringIndexedNumber("ConsecutiveGuardCount", 0)
            f12_arg0:SetTimer(13, 0)
        elseif f12_local2 == COMMON_SP_EFFECT_CONFUSE or f12_local2 == COMMON_SP_EFFECT_CONFUSE_GHOST then
            f12_arg0:Replanning()
            return true
        end
    end
    if f12_arg0:IsInterupt(INTERUPT_InactivateSpecialEffect) then
        local f12_local2 = f12_arg0:GetSpecialEffectInactivateInterruptType(0)
        if f12_local2 == COMMON_SP_EFFECT_PC_NINSATSU then
            f12_arg0:Replanning()
            return true
        end
    end
    if f12_arg0:IsInterupt(INTERUPT_ChangeSoundTarget) and f12_arg0:HasSpecialEffectId(TARGET_SELF, 205060) == false and f12_arg0:HasSpecialEffectId(TARGET_SELF, 205061) == false and f12_arg0:GetLatestSoundTargetID() ~= 7700 and (f12_arg0:HasSpecialEffectId(TARGET_SELF, COMMON_SP_EFFECT_ZAKO_REACTION) or f12_arg0:HasSpecialEffectId(TARGET_SELF, COMMON_SP_EFFECT_CHUBOSS_REACTION)) then
        local f12_local2 = f12_arg0:GetLatestSoundTargetRank()
        if f12_local2 == AI_SOUND_RANK__IMPORTANT then
            if f12_arg0:IsFinishTimer(11) and f12_arg0:GetLatestSoundTargetID() ~= f12_arg0:GetNumber(AI_NUMBER_LATEST_SOUND_ID) then
                f12_arg1:ClearSubGoal()
                f12_arg0:AddTopGoal(GOAL_COMMON_Wait, f12_arg0:GetRandam_Float(0, 0.3), TARGET_SELF, 0, 0, 0):TimingSetTimer(11, 5, AI_TIMING_SET__ACTIVATE)
                f12_arg0:AddTopGoal(GOAL_COMMON_EndureAttack, 1, 710, TARGET_SELF, 9999, 0)
                f12_arg0:SetNumber(AI_NUMBER_LATEST_SOUND_ID, f12_arg0:GetLatestSoundTargetID())
                return true
            else
                f12_arg0:Replanning()
            end
        elseif f12_arg0:IsFinishTimer(12) and f12_arg0:GetLatestSoundTargetID() ~= f12_arg0:GetNumber(AI_NUMBER_LATEST_SOUND_ID) then
            f12_arg1:ClearSubGoal()
            f12_arg0:AddTopGoal(GOAL_COMMON_Wait, f12_arg0:GetRandam_Float(0, 0.3), TARGET_SELF, 0, 0, 0):TimingSetTimer(12, 5, AI_TIMING_SET__ACTIVATE)
            f12_arg0:AddTopGoal(GOAL_COMMON_EndureAttack, 1, 700, TARGET_SELF, 9999, 0)
            f12_arg0:SetNumber(AI_NUMBER_LATEST_SOUND_ID, f12_arg0:GetLatestSoundTargetID())
            return true
        else
            f12_arg0:Replanning()
        end
    end
    if f12_arg0:IsInterupt(INTERUPT_FindCorpseTarget) then
        f12_arg1:ClearSubGoal()
        f12_arg0:AddTopGoal(GOAL_COMMON_EndureAttack, 1, 710, TARGET_ENE_0, 9999, 0)
        return true
    end
    if f12_arg0:IsInterupt(INTERUPT_Inside_ObserveArea) and f12_arg0:IsBattleState() and f12_arg0:IsInsideObserve(COMMON_OBSERVE_SLOT_BATTLE_STEALTH) then
        if f12_arg0:IsVisibleCurrTarget() then
            f12_arg0:DeleteObserve(COMMON_OBSERVE_SLOT_BATTLE_STEALTH)
            f12_arg1:ClearSubGoal()
            f12_arg0:AddTopGoal(GOAL_COMMON_AttackTunableSpin, 1, 401040, TARGET_ENE_0, 9999, 0, 0, 0, 0)
            return true
        else
            f12_arg0:DeleteObserve(COMMON_OBSERVE_SLOT_BATTLE_STEALTH)
            f12_arg0:AddObserveChrDmyArea(COMMON_OBSERVE_SLOT_BATTLE_STEALTH, TARGET_ENE_0, 7, 90, 120, 30, 4)
            return false
        end
    end
    if f12_arg0:IsInterupt(INTERUPT_InvadeTriggerRegion) and f12_arg0:IsCautionState() then
        local f12_local2 = f12_arg0:GetLatestSoundTargetInstanceID()
        local f12_local3 = f12_arg0:GetInvadeTriggerRegionInfoNum()
        local f12_local4 = 600
        if f12_arg0:HasSpecialEffectId(TARGET_SELF, 200001) then
            if f12_arg0:GetRandam_Int(1, 100) <= 50 then
                f12_local4 = 610
            end
        elseif f12_arg0:HasSpecialEffectId(TARGET_SELF, 200002) then
            if f12_arg0:GetRandam_Int(1, 100) <= 50 then
                f12_local4 = 400600
            else
                f12_local4 = 400610
            end
        end
        for f12_local5 = 0, f12_local3 - 1, 1 do
            local f12_local8 = f12_arg0:GetInvadeTriggerRegionCategory(f12_local5)
            local f12_local9 = f12_arg0:GetInvadeTriggerRegionUnitID(f12_local5)
            if f12_local8 == 1000 and f12_local9 == f12_local2 then
                f12_arg0:RemoveTriggerRegionObserver(1000)
                f12_arg1:ClearSubGoal()
                f12_arg0:AddTopGoal(GOAL_COMMON_ConfirmCautionTarget, 30, f12_local4, TARGET_SELF, f12_arg0:GetRandam_Float(3, 4), TARGET_SELF)
                return true
            end
        end
    end
    if f12_arg0:IsInterupt(INTERUPT_Inside_ObserveArea) and f12_arg0:IsInsideObserve(30) then
        f12_arg1:ClearSubGoal()
        f12_arg1:AddSubGoal(GOAL_COMMON_Wait, 0.1, TARGET_SELF, 0, 0, 0)
    end
    return f12_local0
    
end

function InterruptTableGoal(f13_arg0, f13_arg1, f13_arg2, f13_arg3)
    local f13_local0 = false
    local f13_local1 = g_GoalTable[f13_arg2]
    if f13_local1 ~= nil then
        f13_local0 = _InterruptTableGoal_TypeCall(f13_arg0, f13_arg1, f13_local1, f13_arg3)
    end
    return f13_local0
    
end

function InterruptTableGoal_Common(f14_arg0, f14_arg1, f14_arg2)
    local f14_local0 = false
    local f14_local1 = g_GoalTable[f14_arg2]
    if f14_local1 ~= nil and f14_local1.Interrupt ~= nil then
        if f14_local1.Interrupt(f14_local1, f14_arg0, f14_arg1) then
            f14_local0 = true
        end
        if f14_arg1:IsInterruptSubGoalChanged() then
            f14_local0 = true
        end
    end
    return f14_local0
    
end

function _IsInterruptFuncExist(f15_arg0, f15_arg1)
    for f15_local0 = INTERUPT_First, INTERUPT_Last, 1 do
        if not f15_arg0[f15_local0].bEmpty then
            return true
        end
    end
    return false
    

end

function _InterruptTableGoal_TypeCall(f16_arg0, f16_arg1, f16_arg2, f16_arg3)
    if f16_arg2.InterruptInfoTable[f16_arg3].func(f16_arg0, f16_arg1, f16_arg2) then
        return true
    end
    return false
    
end

function _CreateInterruptTypeInfoTable(f17_arg0)
    return {[INTERUPT_FindEnemy] = {func = function (f18_arg0, f18_arg1, f18_arg2)
        if _GetInterruptFunc(f18_arg2.Interrupt_FindEnemy)(f18_arg2, f18_arg0, f18_arg1) then
            return true
        end
        if f18_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_FindEnemy ~= nil)}, [INTERUPT_FindAttack] = {func = function (f19_arg0, f19_arg1, f19_arg2)
        if _GetInterruptFunc(f19_arg2.Interrupt_FindAttack)(f19_arg2, f19_arg0, f19_arg1) then
            return true
        end
        if f19_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_FindAttack ~= nil)}, [INTERUPT_Damaged] = {func = function (f20_arg0, f20_arg1, f20_arg2)
        if _GetInterruptFunc(f20_arg2.Interrupt_Damaged)(f20_arg2, f20_arg0, f20_arg1) then
            return true
        end
        if f20_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_Damaged ~= nil)}, [INTERUPT_Damaged_Stranger] = {func = function (f21_arg0, f21_arg1, f21_arg2)
        if _GetInterruptFunc(f21_arg2.Interrupt_Damaged_Stranger)(f21_arg2, f21_arg0, f21_arg1) then
            return true
        end
        if f21_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_Damaged_Stranger ~= nil)}, [INTERUPT_FindMissile] = {func = function (f22_arg0, f22_arg1, f22_arg2)
        if _GetInterruptFunc(f22_arg2.Interrupt_FindMissile)(f22_arg2, f22_arg0, f22_arg1) then
            return true
        end
        if f22_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_FindMissile ~= nil)}, [INTERUPT_SuccessGuard] = {func = function (f23_arg0, f23_arg1, f23_arg2)
        if _GetInterruptFunc(f23_arg2.Interrupt_SuccessGuard)(f23_arg2, f23_arg0, f23_arg1) then
            return true
        end
        if f23_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_SuccessGuard ~= nil)}, [INTERUPT_MissSwing] = {func = function (f24_arg0, f24_arg1, f24_arg2)
        if _GetInterruptFunc(f24_arg2.Interrupt_MissSwing)(f24_arg2, f24_arg0, f24_arg1) then
            return true
        end
        if f24_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_MissSwing ~= nil)}, [INTERUPT_GuardBegin] = {func = function (f25_arg0, f25_arg1, f25_arg2)
        if _GetInterruptFunc(f25_arg2.Interrupt_GuardBegin)(f25_arg2, f25_arg0, f25_arg1) then
            return true
        end
        if f25_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_GuardBegin ~= nil)}, [INTERUPT_GuardFinish] = {func = function (f26_arg0, f26_arg1, f26_arg2)
        if _GetInterruptFunc(f26_arg2.Interrupt_GuardFinish)(f26_arg2, f26_arg0, f26_arg1) then
            return true
        end
        if f26_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_GuardFinish ~= nil)}, [INTERUPT_GuardBreak] = {func = function (f27_arg0, f27_arg1, f27_arg2)
        if _GetInterruptFunc(f27_arg2.Interrupt_GuardBreak)(f27_arg2, f27_arg0, f27_arg1) then
            return true
        end
        if f27_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_GuardBreak ~= nil)}, [INTERUPT_Shoot] = {func = function (f28_arg0, f28_arg1, f28_arg2)
        if _GetInterruptFunc(f28_arg2.Interrupt_Shoot)(f28_arg2, f28_arg0, f28_arg1) then
            return true
        end
        if f28_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_Shoot ~= nil)}, [INTERUPT_ShootImpact] = {func = function (f29_arg0, f29_arg1, f29_arg2)
        if _GetInterruptFunc(f29_arg2.Interrupt_ShootImpact)(f29_arg2, f29_arg0, f29_arg1) then
            return true
        end
        if f29_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_ShootImpact ~= nil)}, [INTERUPT_UseItem] = {func = function (f30_arg0, f30_arg1, f30_arg2)
        if _GetInterruptFunc(f30_arg2.Interrupt_UseItem)(f30_arg2, f30_arg0, f30_arg1) then
            return true
        end
        if f30_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_UseItem ~= nil)}, [INTERUPT_EnterBattleArea] = {func = function (f31_arg0, f31_arg1, f31_arg2)
        if _GetInterruptFunc(f31_arg2.Interrupt_EnterBattleArea)(f31_arg2, f31_arg0, f31_arg1) then
            return true
        end
        if f31_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_EnterBattleArea ~= nil)}, [INTERUPT_LeaveBattleArea] = {func = function (f32_arg0, f32_arg1, f32_arg2)
        if _GetInterruptFunc(f32_arg2.Interrupt_LeaveBattleArea)(f32_arg2, f32_arg0, f32_arg1) then
            return true
        end
        if f32_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_LeaveBattleArea ~= nil)}, [INTERUPT_CANNOT_MOVE] = {func = function (f33_arg0, f33_arg1, f33_arg2)
        if _GetInterruptFunc(f33_arg2.Interrupt_CANNOT_MOVE)(f33_arg2, f33_arg0, f33_arg1) then
            return true
        end
        if f33_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_CANNOT_MOVE ~= nil)}, [INTERUPT_Inside_ObserveArea] = {func = function (f34_arg0, f34_arg1, f34_arg2)
        if _InterruptTableGoal_Inside_ObserveArea(f34_arg2, f34_arg0, f34_arg1) then
            return true
        end
        if f34_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_Inside_ObserveArea ~= nil)}, [INTERUPT_ReboundByOpponentGuard] = {func = function (f35_arg0, f35_arg1, f35_arg2)
        if _GetInterruptFunc(f35_arg2.Interrupt_ReboundByOpponentGuard)(f35_arg2, f35_arg0, f35_arg1) then
            return true
        end
        if f35_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_ReboundByOpponentGuard ~= nil)}, [INTERUPT_ForgetTarget] = {func = function (f36_arg0, f36_arg1, f36_arg2)
        if _GetInterruptFunc(f36_arg2.Interrupt_ForgetTarget)(f36_arg2, f36_arg0, f36_arg1) then
            return true
        end
        if f36_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_ForgetTarget ~= nil)}, [INTERUPT_FriendRequestSupport] = {func = function (f37_arg0, f37_arg1, f37_arg2)
        if _GetInterruptFunc(f37_arg2.Interrupt_FriendRequestSupport)(f37_arg2, f37_arg0, f37_arg1) then
            return true
        end
        if f37_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_FriendRequestSupport ~= nil)}, [INTERUPT_TargetIsGuard] = {func = function (f38_arg0, f38_arg1, f38_arg2)
        if _GetInterruptFunc(f38_arg2.Interrupt_TargetIsGuard)(f38_arg2, f38_arg0, f38_arg1) then
            return true
        end
        if f38_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_TargetIsGuard ~= nil)}, [INTERUPT_HitEnemyWall] = {func = function (f39_arg0, f39_arg1, f39_arg2)
        if _GetInterruptFunc(f39_arg2.Interrupt_HitEnemyWall)(f39_arg2, f39_arg0, f39_arg1) then
            return true
        end
        if f39_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_HitEnemyWall ~= nil)}, [INTERUPT_SuccessParry] = {func = function (f40_arg0, f40_arg1, f40_arg2)
        if _GetInterruptFunc(f40_arg2.Interrupt_SuccessParry)(f40_arg2, f40_arg0, f40_arg1) then
            return true
        end
        if f40_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_SuccessParry ~= nil)}, [INTERUPT_CANNOT_MOVE_DisableInterupt] = {func = function (f41_arg0, f41_arg1, f41_arg2)
        if _GetInterruptFunc(f41_arg2.Interrupt_CANNOT_MOVE_DisableInterupt)(f41_arg2, f41_arg0, f41_arg1) then
            return true
        end
        if f41_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_CANNOT_MOVE_DisableInterupt ~= nil)}, [INTERUPT_ParryTiming] = {func = function (f42_arg0, f42_arg1, f42_arg2)
        if _GetInterruptFunc(f42_arg2.Interrupt_ParryTiming)(f42_arg2, f42_arg0, f42_arg1) then
            return true
        end
        if f42_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_ParryTiming ~= nil)}, [INTERUPT_RideNode_LadderBottom] = {func = function (f43_arg0, f43_arg1, f43_arg2)
        if _GetInterruptFunc(f43_arg2.Interrupt_RideNode_LadderBottom)(f43_arg2, f43_arg0, f43_arg1) then
            return true
        end
        if f43_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_RideNode_LadderBottom ~= nil)}, [INTERUPT_FLAG_RideNode_Door] = {func = function (f44_arg0, f44_arg1, f44_arg2)
        if _GetInterruptFunc(f44_arg2.Interrupt_FLAG_RideNode_Door)(f44_arg2, f44_arg0, f44_arg1) then
            return true
        end
        if f44_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_FLAG_RideNode_Door ~= nil)}, [INTERUPT_StraightByPath] = {func = function (f45_arg0, f45_arg1, f45_arg2)
        if _GetInterruptFunc(f45_arg2.Interrupt_StraightByPath)(f45_arg2, f45_arg0, f45_arg1) then
            return true
        end
        if f45_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_StraightByPath ~= nil)}, [INTERUPT_ChangedAnimIdOffset] = {func = function (f46_arg0, f46_arg1, f46_arg2)
        if _GetInterruptFunc(f46_arg2.Interrupt_ChangedAnimIdOffset)(f46_arg2, f46_arg0, f46_arg1) then
            return true
        end
        if f46_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_ChangedAnimIdOffset ~= nil)}, [INTERUPT_SuccessThrow] = {func = function (f47_arg0, f47_arg1, f47_arg2)
        if _GetInterruptFunc(f47_arg2.Interrupt_SuccessThrow)(f47_arg2, f47_arg0, f47_arg1) then
            return true
        end
        if f47_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_SuccessThrow ~= nil)}, [INTERUPT_LookedTarget] = {func = function (f48_arg0, f48_arg1, f48_arg2)
        if _GetInterruptFunc(f48_arg2.Interrupt_LookedTarget)(f48_arg2, f48_arg0, f48_arg1) then
            return true
        end
        if f48_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_LookedTarget ~= nil)}, [INTERUPT_LoseSightTarget] = {func = function (f49_arg0, f49_arg1, f49_arg2)
        if _GetInterruptFunc(f49_arg2.Interrupt_LoseSightTarget)(f49_arg2, f49_arg0, f49_arg1) then
            return true
        end
        if f49_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_LoseSightTarget ~= nil)}, [INTERUPT_RideNode_InsideWall] = {func = function (f50_arg0, f50_arg1, f50_arg2)
        if _GetInterruptFunc(f50_arg2.Interrupt_RideNode_InsideWall)(f50_arg2, f50_arg0, f50_arg1) then
            return true
        end
        if f50_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_RideNode_InsideWall ~= nil)}, [INTERUPT_MissSwingSelf] = {func = function (f51_arg0, f51_arg1, f51_arg2)
        if _GetInterruptFunc(f51_arg2.Interrupt_MissSwingSelf)(f51_arg2, f51_arg0, f51_arg1) then
            return true
        end
        if f51_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_MissSwingSelf ~= nil)}, [INTERUPT_GuardBreakBlow] = {func = function (f52_arg0, f52_arg1, f52_arg2)
        if _GetInterruptFunc(f52_arg2.Interrupt_GuardBreakBlow)(f52_arg2, f52_arg0, f52_arg1) then
            return true
        end
        if f52_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_GuardBreakBlow ~= nil)}, [INTERUPT_TargetOutOfRange] = {func = function (f53_arg0, f53_arg1, f53_arg2)
        if _InterruptTableGoal_TargetOutOfRange(f53_arg2, f53_arg0, f53_arg1) then
            return true
        end
        if f53_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_TargetOutOfRange ~= nil)}, [INTERUPT_UnstableFloor] = {func = function (f54_arg0, f54_arg1, f54_arg2)
        if _GetInterruptFunc(f54_arg2.Interrupt_UnstableFloor)(f54_arg2, f54_arg0, f54_arg1) then
            return true
        end
        if f54_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_UnstableFloor ~= nil)}, [INTERUPT_BreakFloor] = {func = function (f55_arg0, f55_arg1, f55_arg2)
        if _GetInterruptFunc(f55_arg2.Interrupt_BreakFloor)(f55_arg2, f55_arg0, f55_arg1) then
            return true
        end
        if f55_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_BreakFloor ~= nil)}, [INTERUPT_BreakObserveObj] = {func = function (f56_arg0, f56_arg1, f56_arg2)
        if _GetInterruptFunc(f56_arg2.Interrupt_BreakObserveObj)(f56_arg2, f56_arg0, f56_arg1) then
            return true
        end
        if f56_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_BreakObserveObj ~= nil)}, [INTERUPT_EventRequest] = {func = function (f57_arg0, f57_arg1, f57_arg2)
        if _GetInterruptFunc(f57_arg2.Interrupt_EventRequest)(f57_arg2, f57_arg0, f57_arg1) then
            return true
        end
        if f57_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_EventRequest ~= nil)}, [INTERUPT_Outside_ObserveArea] = {func = function (f58_arg0, f58_arg1, f58_arg2)
        if _InterruptTableGoal_Outside_ObserveArea(f58_arg2, f58_arg0, f58_arg1) then
            return true
        end
        if f58_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_Outside_ObserveArea ~= nil)}, [INTERUPT_TargetOutOfAngle] = {func = function (f59_arg0, f59_arg1, f59_arg2)
        if _InterruptTableGoal_TargetOutOfAngle(f59_arg2, f59_arg0, f59_arg1) then
            return true
        end
        if f59_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_TargetOutOfAngle ~= nil)}, [INTERUPT_PlatoonAiOrder] = {func = function (f60_arg0, f60_arg1, f60_arg2)
        if _GetInterruptFunc(f60_arg2.Interrupt_PlatoonAiOrder)(f60_arg2, f60_arg0, f60_arg1) then
            return true
        end
        if f60_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_PlatoonAiOrder ~= nil)}, [INTERUPT_ActivateSpecialEffect] = {func = function (f61_arg0, f61_arg1, f61_arg2)
        if _InterruptTableGoal_ActivateSpecialEffect(f61_arg2, f61_arg0, f61_arg1) then
            return true
        end
        if f61_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_ActivateSpecialEffect ~= nil)}, [INTERUPT_InactivateSpecialEffect] = {func = function (f62_arg0, f62_arg1, f62_arg2)
        if _InterruptTableGoal_InactivateSpecialEffect(f62_arg2, f62_arg0, f62_arg1) then
            return true
        end
        if f62_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_InactivateSpecialEffect ~= nil)}, [INTERUPT_MovedEnd_OnFailedPath] = {func = function (f63_arg0, f63_arg1, f63_arg2)
        if _GetInterruptFunc(f63_arg2.Interrupt_MovedEnd_OnFailedPath)(f63_arg2, f63_arg0, f63_arg1) then
            return true
        end
        if f63_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_MovedEnd_OnFailedPath ~= nil)}, [INTERUPT_ChangeSoundTarget] = {func = function (f64_arg0, f64_arg1, f64_arg2)
        if _GetInterruptFunc(f64_arg2.Interrupt_ChangeSoundTarget)(f64_arg2, f64_arg0, f64_arg1) then
            return true
        end
        if f64_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_ChangeSoundTarget ~= nil)}, [INTERUPT_OnCreateDamage] = {func = function (f65_arg0, f65_arg1, f65_arg2)
        if _GetInterruptFunc(f65_arg2.Interrupt_OnCreateDamage)(f65_arg2, f65_arg0, f65_arg1) then
            return true
        end
        if f65_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_OnCreateDamage ~= nil)}, [INTERUPT_InvadeTriggerRegion] = {func = function (f66_arg0, f66_arg1, f66_arg2)
        if _InterruptTableGoal_InvadeTriggerRegion(f66_arg2, f66_arg0, f66_arg1) then
            return true
        end
        if f66_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_InvadeTriggerRegion ~= nil)}, [INTERUPT_LeaveTriggerRegion] = {func = function (f67_arg0, f67_arg1, f67_arg2)
        if _InterruptTableGoal_LeaveTriggerRegion(f67_arg2, f67_arg0, f67_arg1) then
            return true
        end
        if f67_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_LeaveTriggerRegion ~= nil)}, [INTERUPT_AIGuardBroken] = {func = function (f68_arg0, f68_arg1, f68_arg2)
        if _GetInterruptFunc(f68_arg2.Interrupt_AIGuardBroken)(f68_arg2, f68_arg0, f68_arg1) then
            return true
        end
        if f68_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_AIGuardBroken ~= nil)}, [INTERUPT_AIReboundByOpponentGuard] = {func = function (f69_arg0, f69_arg1, f69_arg2)
        if _GetInterruptFunc(f69_arg2.Interrupt_AIReboundByOpponentGuard)(f69_arg2, f69_arg0, f69_arg1) then
            return true
        end
        if f69_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_AIReboundByOpponentGuard ~= nil)}, [INTERUPT_BackstabRisk] = {func = function (f70_arg0, f70_arg1, f70_arg2)
        if _GetInterruptFunc(f70_arg2.Interrupt_BackstabRisk)(f70_arg2, f70_arg0, f70_arg1) then
            return true
        end
        if f70_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_BackstabRisk ~= nil)}, [INTERUPT_FindIndicationTarget] = {func = function (f71_arg0, f71_arg1, f71_arg2)
        if _GetInterruptFunc(f71_arg2.Interrupt_FindIndicationTarget)(f71_arg2, f71_arg0, f71_arg1) then
            return true
        end
        if f71_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_FindIndicationTarget ~= nil)}, [INTERUPT_FindCorpseTarget] = {func = function (f72_arg0, f72_arg1, f72_arg2)
        if _GetInterruptFunc(f72_arg2.Interrupt_FindCorpseTarget)(f72_arg2, f72_arg0, f72_arg1) then
            return true
        end
        if f72_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_FindCorpseTarget ~= nil)}, [INTERUPT_FindFailedPath] = {func = function (f73_arg0, f73_arg1, f73_arg2)
        if _GetInterruptFunc(f73_arg2.Interrupt_FindFailedPath)(f73_arg2, f73_arg0, f73_arg1) then
            return true
        end
        if f73_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_FindFailedPath ~= nil)}, [INTERUPT_GuardedMyAttack] = {func = function (f74_arg0, f74_arg1, f74_arg2)
        if _GetInterruptFunc(f74_arg2.Interrupt_GuardedMyAttack)(f74_arg2, f74_arg0, f74_arg1) then
            return true
        end
        if f74_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_GuardedMyAttack ~= nil)}, [INTERUPT_WanderedOffPathRepath] = {func = function (f75_arg0, f75_arg1, f75_arg2)
        if _GetInterruptFunc(f75_arg2.Interrupt_WanderedOffPathRepath)(f75_arg2, f75_arg0, f75_arg1) then
            return true
        end
        if f75_arg1:IsInterruptSubGoalChanged() then
            return true
        end
        return false
        
    end, bEmpty = not (f17_arg0.Interrupt_WanderedOffPathRepath ~= nil)}}

    
end

function _GetInterruptFunc(f76_arg0)
    if f76_arg0 ~= nil then
        return f76_arg0
    end
    return _InterruptTableGoal_TypeCall_Dummy
    
end

function _InterruptTableGoal_TypeCall_Dummy()
    return false
    
end

function _InterruptTableGoal_TargetOutOfRange_Common(f78_arg0, f78_arg1, f78_arg2, f78_arg3, f78_arg4)
    local f78_local0 = false
    for f78_local1 = 0, 31, 1 do
        if f78_arg3(f78_local1) then
            f78_local0 = true
            if f78_arg4(f78_arg0, f78_arg1, f78_arg2, f78_local1) then
                return true
            end
        end
    end
    if bSlotEnable then
        return false
    end
    return f78_arg4(f78_arg0, f78_arg1, f78_arg2, -1)
    

end

function _InterruptTableGoal_TargetOutOfRange(f79_arg0, f79_arg1, f79_arg2)
    return _InterruptTableGoal_TargetOutOfRange_Common(f79_arg0, f79_arg1, f79_arg2, function (f80_arg0)
        return f79_arg1:IsTargetOutOfRangeInterruptSlot(f80_arg0)
        
    end, _GetInterruptFunc(f79_arg0.Interrupt_TargetOutOfRange))

    
end

function _InterruptTableGoal_TargetOutOfAngle(f81_arg0, f81_arg1, f81_arg2)
    return _InterruptTableGoal_TargetOutOfRange_Common(f81_arg0, f81_arg1, f81_arg2, function (f82_arg0)
        return f81_arg1:IsTargetOutOfAngleInterruptSlot(f82_arg0)
        
    end, _GetInterruptFunc(f81_arg0.Interrupt_TargetOutOfAngle))

    
end

function _InterruptTableGoal_Inside_ObserveArea(f83_arg0, f83_arg1, f83_arg2)
    local f83_local0 = f83_arg1:GetAreaObserveSlotNum(AI_AREAOBSERVE_INTERRUPT__INSIDE)
    for f83_local1 = 0, f83_local0 - 1, 1 do
        if _GetInterruptFunc(f83_arg0.Interrupt_Inside_ObserveArea)(f83_arg0, f83_arg1, f83_arg2, f83_arg1:GetAreaObserveSlot(AI_AREAOBSERVE_INTERRUPT__INSIDE, f83_local1)) then
            return true
        end
    end
    

end

function _InterruptTableGoal_Outside_ObserveArea(f84_arg0, f84_arg1, f84_arg2)
    local f84_local0 = f84_arg1:GetAreaObserveSlotNum(AI_AREAOBSERVE_INTERRUPT__OUTSIDE)
    for f84_local1 = 0, f84_local0 - 1, 1 do
        if _GetInterruptFunc(f84_arg0.Interrupt_Outside_ObserveArea)(f84_arg0, f84_arg1, f84_arg2, f84_arg1:GetAreaObserveSlot(AI_AREAOBSERVE_INTERRUPT__OUTSIDE, f84_local1)) then
            return true
        end
    end
    

end

function _InterruptTableGoal_ActivateSpecialEffect(f85_arg0, f85_arg1, f85_arg2)
    local f85_local0 = f85_arg1:GetSpecialEffectActivateInterruptNum()
    for f85_local1 = 0, f85_local0 - 1, 1 do
        if _GetInterruptFunc(f85_arg0.Interrupt_ActivateSpecialEffect)(f85_arg0, f85_arg1, f85_arg2, f85_arg1:GetSpecialEffectActivateInterruptType(f85_local1)) then
            return true
        end
    end
    

end

function _InterruptTableGoal_InactivateSpecialEffect(f86_arg0, f86_arg1, f86_arg2)
    local f86_local0 = f86_arg1:GetSpecialEffectInactivateInterruptNum()
    for f86_local1 = 0, f86_local0 - 1, 1 do
        if _GetInterruptFunc(f86_arg0.Interrupt_InactivateSpecialEffect)(f86_arg0, f86_arg1, f86_arg2, f86_arg1:GetSpecialEffectInactivateInterruptType(f86_local1)) then
            return true
        end
    end
    

end

function _InterruptTableGoal_InvadeTriggerRegion(f87_arg0, f87_arg1, f87_arg2)
    local f87_local0 = f87_arg1:GetInvadeTriggerRegionInfoNum()
    for f87_local1 = 0, f87_local0 - 1, 1 do
        if _GetInterruptFunc(f87_arg0.Interrupt_InvadeTriggerRegion)(f87_arg0, f87_arg1, f87_arg2, f87_arg1:GetInvadeTriggerRegionCategory(f87_local1)) then
            return true
        end
    end
    

end

function _InterruptTableGoal_LeaveTriggerRegion(f88_arg0, f88_arg1, f88_arg2)
    local f88_local0 = f88_arg1:GetLeaveTriggerRegionInfoNum()
    for f88_local1 = 0, f88_local0 - 1, 1 do
        if _GetInterruptFunc(f88_arg0.Interrupt_LeaveTriggerRegion)(f88_arg0, f88_arg1, f88_arg2, f88_arg1:GetLeaveTriggerRegionCategory(f88_local1)) then
            return true
        end
    end
    

end


