RegisterTableLogic(132000)

Logic.Main = function (f1_arg0, f1_arg1)
    if COMMON_HiPrioritySetup(f1_arg1) then
        return true
    end
    LOCAL_EzSetup(f1_arg1)
    
end

function LOCAL_EzSetup(f2_arg0)
    if not f2_arg0:HasSpecialEffectId(TARGET_SELF, 205050) and not f2_arg0:HasSpecialEffectId(TARGET_SELF, 205051) and LOCAL_AddStateTransitionGoal(f2_arg0) then
        return true
    end
    _COMMON_SetBattleActLogic(f2_arg0)
    if f2_arg0:IsLadderAct(TARGET_SELF) and not f2_arg0:HasGoal(GOAL_COMMON_LadderAct) then
        local f2_local0 = f2_arg0:GetTopGoal()
        if f2_local0 ~= nil then
            f2_local0:AddSubGoal_Front(GOAL_COMMON_LadderAct, -1, 3000, TARGET_SELF, f2_arg0:GetLadderDirMove(TARGET_SELF))
        else
            f2_arg0:AddTopGoal(GOAL_COMMON_LadderAct, -1, 3000, TARGET_SELF, f2_arg0:GetLadderDirMove(TARGET_SELF))
        end
    end
    
end

function LOCAL_AddStateTransitionGoal(f3_arg0)
    local f3_local0 = f3_arg0:IsSearchTarget(TARGET_ENE_0)
    local f3_local1 = f3_arg0:GetPrevTargetState()
    local f3_local2 = f3_arg0:GetCurrTargetType()
    if f3_arg0:IsFindState() or f3_arg0:IsBattleState() then
        f3_arg0:ClearSoundTarget()
        f3_arg0:ClearIndicationPosTarget()
        if f3_arg0:HasSpecialEffectId(TARGET_SELF, 200004) then
        elseif f3_arg0:HasSpecialEffectId(TARGET_SELF, 200002) then
            if f3_arg0:HasSpecialEffectId(TARGET_SELF, 220070) and f3_arg0:IsVisibleCurrTarget() == false then
                if not f3_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) then
                    f3_arg0:AddTopGoal(GOAL_COMMON_Turn, 3, TARGET_ENE_0, 40, -1, GOAL_RESULT_Success, true)
                else
                    f3_arg0:AddTopGoal(GOAL_COMMON_ClearTarget, 3, AI_TARGET_TYPE__NORMAL_ENEMY)
                end
            else
                f3_arg0:AddTopGoal(GOAL_COMMON_EndureAttack, 10, 201040, TARGET_ENE_0, 9999, 0, 0, 0, 0)
            end
            return true
        elseif f3_arg0:HasSpecialEffectId(TARGET_SELF, 200001) then
            if f3_arg0:HasSpecialEffectId(TARGET_SELF, 220070) and f3_arg0:IsVisibleCurrTarget() == false then
                if not f3_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) then
                    f3_arg0:AddTopGoal(GOAL_COMMON_Turn, 3, TARGET_ENE_0, 40, -1, GOAL_RESULT_Success, true)
                else
                    f3_arg0:AddTopGoal(GOAL_COMMON_EndureAttack, 10, 201040, TARGET_ENE_0, 9999, 0, 0, 0, 0)
                    f3_arg0:AddTopGoal(GOAL_COMMON_ClearTarget, 3, AI_TARGET_TYPE__NORMAL_ENEMY)
                end
            else
                f3_arg0:AddTopGoal(GOAL_COMMON_EndureAttack, 10, 201040, TARGET_ENE_0, 9999, 0, 0, 0, 0)
            end
            return true
        else
            if f3_arg0:HasSpecialEffectId(TARGET_SELF, 220070) and f3_arg0:IsVisibleCurrTarget() == false then
                if not f3_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) then
                    f3_arg0:AddTopGoal(GOAL_COMMON_Turn, 3, TARGET_ENE_0, 40, -1, GOAL_RESULT_Success, true)
                else
                    f3_arg0:AddTopGoal(GOAL_COMMON_EndureAttack, 10, 1040, TARGET_ENE_0, 9999, 0, 0, 0, 0)
                    f3_arg0:AddTopGoal(GOAL_COMMON_ClearTarget, 3, AI_TARGET_TYPE__NORMAL_ENEMY)
                end
            else
                f3_arg0:AddTopGoal(GOAL_COMMON_EndureAttack, 10, 1040, TARGET_ENE_0, 9999, 0, 0, 0, 0)
            end
            return true
        end
    elseif f3_arg0:IsCautionState() then
        if f3_local2 == AI_TARGET_TYPE__MEMORY_ENEMY then
            if f3_arg0:HasSpecialEffectId(TARGET_SELF, 200004) then
                f3_arg0:AddTopGoal(GOAL_COMMON_AttackTunableSpin, 10, 401020, TARGET_ENE_0, 9999, 0, 0, 0, 0)
                return true
            elseif f3_arg0:HasSpecialEffectId(TARGET_SELF, 200002) or f3_arg0:HasSpecialEffectId(TARGET_SELF, 200001) then
            else
                f3_arg0:AddTopGoal(GOAL_COMMON_EndureAttack, 10, 1010, TARGET_ENE_0, 9999, 0, 0, 0, 0)
                return true
            end
        elseif f3_local2 == AI_TARGET_TYPE__SOUND then
            f3_arg0:SetStringIndexedNumber("toCaotionFlag", 1)
            if f3_arg0:HasSpecialEffectId(TARGET_SELF, 200004) then
                f3_arg0:AddTopGoal(GOAL_COMMON_AttackTunableSpin, 10, 401020, TARGET_ENE_0, 9999, 0, 0, 0, 0)
                return true
            elseif f3_arg0:HasSpecialEffectId(TARGET_SELF, 200002) or f3_arg0:HasSpecialEffectId(TARGET_SELF, 200001) then
            else
                f3_arg0:AddTopGoal(GOAL_COMMON_EndureAttack, 10, 1010, TARGET_ENE_0, 9999, 0, 0, 0, 0)
                return true
            end
        elseif f3_local2 == AI_TARGET_TYPE__INDICATION_POS then
            f3_arg0:SetStringIndexedNumber("toCaotionFlag", 1)
            if f3_arg0:HasSpecialEffectId(TARGET_SELF, 200004) then
                f3_arg0:AddTopGoal(GOAL_COMMON_AttackTunableSpin, 10, 401020, TARGET_ENE_0, 9999, 0, 0, 0, 0)
                return true
            elseif f3_arg0:HasSpecialEffectId(TARGET_SELF, 200002) or f3_arg0:HasSpecialEffectId(TARGET_SELF, 200001) then
            else
                f3_arg0:AddTopGoal(GOAL_COMMON_EndureAttack, 10, 1010, TARGET_ENE_0, 9999, 0, 0, 0, 0)
                return true
            end
        elseif f3_local2 == AI_TARGET_TYPE__CORPSE_POS then
            f3_arg0:SetStringIndexedNumber("toCaotionFlag", 1)
            if f3_arg0:HasSpecialEffectId(TARGET_SELF, 200004) then
                f3_arg0:AddTopGoal(GOAL_COMMON_AttackTunableSpin, 10, 401020, TARGET_ENE_0, 9999, 0, 0, 0, 0)
                return true
            elseif f3_arg0:HasSpecialEffectId(TARGET_SELF, 200002) or f3_arg0:HasSpecialEffectId(TARGET_SELF, 200001) then
            else
                f3_arg0:AddTopGoal(GOAL_COMMON_EndureAttack, 10, 1010, TARGET_ENE_0, 9999, 0, 0, 0, 0)
                return true
            end
        end
    elseif f3_arg0:HasSpecialEffectId(TARGET_SELF, 200004) then
        f3_arg0:AddTopGoal(GOAL_COMMON_AttackTunableSpin, 10, 401000, TARGET_ENE_0, 9999, 0, 0, 0, 0)
        return true
    elseif f3_arg0:HasSpecialEffectId(TARGET_SELF, 200002) then
        f3_arg0:AddTopGoal(GOAL_COMMON_AttackTunableSpin, 10, 201000, TARGET_SELF, 9999, 0, 0, 0, 0)
        return true
    elseif f3_arg0:HasSpecialEffectId(TARGET_SELF, 200001) then
        f3_arg0:AddTopGoal(GOAL_COMMON_AttackTunableSpin, 10, 201000, TARGET_SELF, 9999, 0, 0, 0, 0)
        return true
    else
    end
    return false
    
end

Logic.Interrupt = function (f4_arg0, f4_arg1, f4_arg2)
    return false
    
end


