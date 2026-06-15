function CommonNPC_ChangeWepL1(f1_arg0, f1_arg1)
    local f1_local0 = f1_arg0:GetEquipWeaponIndex(ARM_L)
    if WEP_Primary ~= f1_local0 then
        f1_arg1:AddSubGoal(GOAL_COMMON_Attack, 10, NPC_ATK_ChangeWep_L1, TARGET_NONE, DIST_None)
    end
    
end

function CommonNPC_ChangeWepR1(f2_arg0, f2_arg1)
    local f2_local0 = f2_arg0:GetEquipWeaponIndex(ARM_R)
    if WEP_Primary ~= f2_local0 then
        f2_arg1:AddSubGoal(GOAL_COMMON_Attack, 10, NPC_ATK_ChangeWep_R1, TARGET_NONE, DIST_None)
    end
    
end

function CommonNPC_ChangeWepL2(f3_arg0, f3_arg1)
    local f3_local0 = f3_arg0:GetEquipWeaponIndex(ARM_L)
    if WEP_Secondary ~= f3_local0 then
        f3_arg1:AddSubGoal(GOAL_COMMON_Attack, 10, NPC_ATK_ChangeWep_L2, TARGET_NONE, DIST_None)
    end
    
end

function CommonNPC_ChangeWepR2(f4_arg0, f4_arg1)
    local f4_local0 = f4_arg0:GetEquipWeaponIndex(ARM_R)
    if WEP_Secondary ~= f4_local0 then
        f4_arg1:AddSubGoal(GOAL_COMMON_Attack, 10, NPC_ATK_ChangeWep_R2, TARGET_NONE, DIST_None)
    end
    
end

function CommonNPC_SwitchBothHandMode(f5_arg0, f5_arg1)
    if not f5_arg0:IsBothHandMode(TARGET_SELF) then
        f5_arg1:AddSubGoal(GOAL_COMMON_Attack, 10, NPC_ATK_SwitchWep, TARGET_NONE, DIST_None)
    end
    
end

function CommonNPC_SwitchOneHandMode(f6_arg0, f6_arg1)
    if f6_arg0:IsBothHandMode(TARGET_SELF) then
        f6_arg1:AddSubGoal(GOAL_COMMON_Attack, 10, NPC_ATK_SwitchWep, TARGET_NONE, DIST_None)
    end
    
end

function NPC_Approach_Act(f7_arg0, f7_arg1, f7_arg2, f7_arg3, f7_arg4)
    f7_arg0:EndDash()
    local f7_local0 = -1
    local f7_local1 = f7_arg0:GetRandam_Int(1, 100)
    if f7_local1 <= f7_arg4 then
        f7_local0 = 4
    end
    local f7_local2 = f7_arg0:GetDist(TARGET_ENE_0)
    if f7_arg3 <= f7_local2 then
        f7_arg0:StartDash()
        f7_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 10, TARGET_ENE_0, f7_arg2, TARGET_SELF, false, f7_local0)
    else
        f7_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 5, TARGET_ENE_0, f7_arg2, TARGET_SELF, false, f7_local0)
    end
    
end

function NPC_KATATE_Switch(f8_arg0, f8_arg1)
    if f8_arg0:IsBothHandMode(TARGET_SELF) then
        f8_arg1:AddSubGoal(GOAL_COMMON_NonspinningComboAttack, 10, NPC_ATK_SwitchWep, TARGET_ENE_0, DIST_None, 0)
    end
    
end

function NPC_RYOUTE_Switch(f9_arg0, f9_arg1)
    if not f9_arg0:IsBothHandMode(TARGET_SELF) then
        f9_arg1:AddSubGoal(GOAL_COMMON_NonspinningComboAttack, 10, NPC_ATK_SwitchWep, TARGET_ENE_0, DIST_None, 0)
    end
    
end

function Damaged_StepCount_NPCPlayer(f10_arg0, f10_arg1, f10_arg2, f10_arg3, f10_arg4, f10_arg5, f10_arg6, f10_arg7, f10_arg8)
    local f10_local0 = f10_arg0:GetDist(TARGET_ENE_0)
    local f10_local1 = f10_arg0:GetRandam_Int(1, 100)
    local f10_local2 = f10_arg0:GetRandam_Int(1, 100)
    local f10_local3 = f10_arg0:GetRandam_Int(1, 100)
    if f10_arg0:IsInterupt(INTERUPT_Damaged) and f10_local0 < f10_arg2 and f10_local1 <= f10_arg3 then
        f10_arg1:ClearSubGoal()
        if f10_local2 <= f10_arg6 then
            f10_arg1:AddSubGoal(GOAL_COMMON_Attack, 10, NPC_ATK_StepB, TARGET_ENE_0, DIST_None, 0)
        elseif f10_local2 <= f10_arg6 + f10_arg7 then
            f10_arg1:AddSubGoal(GOAL_COMMON_Attack, 10, NPC_ATK_StepL, TARGET_ENE_0, DIST_None, 0)
        else
            f10_arg1:AddSubGoal(GOAL_COMMON_Attack, 10, NPC_ATK_StepR, TARGET_ENE_0, DIST_None, 0)
        end
        if f10_local3 <= f10_arg4 then
            f10_arg1:AddSubGoal(GOAL_COMMON_ComboAttack, 10, f10_arg5, TARGET_ENE_0, DIST_Middle, 0)
        end
        return true
    end
    
end

function FindAttack_Step_NPCPlayer(f11_arg0, f11_arg1, f11_arg2, f11_arg3, f11_arg4, f11_arg5, f11_arg6)
    local f11_local0 = f11_arg0:GetDist(TARGET_ENE_0)
    local f11_local1 = f11_arg0:GetRandam_Int(1, 100)
    local f11_local2 = f11_arg0:GetRandam_Int(1, 100)
    if f11_arg0:IsInterupt(INTERUPT_FindAttack) and f11_local0 <= f11_arg2 and f11_local1 <= f11_arg3 then
        f11_arg1:ClearSubGoal()
        if f11_local2 <= f11_arg4 then
            f11_arg1:AddSubGoal(GOAL_COMMON_Attack, 10, NPC_ATK_StepB, TARGET_ENE_0, DIST_None, 0)
        elseif f11_local2 <= f11_arg4 + f11_arg5 then
            f11_arg1:AddSubGoal(GOAL_COMMON_Attack, 10, NPC_ATK_StepL, TARGET_ENE_0, DIST_None, 0)
        else
            f11_arg1:AddSubGoal(GOAL_COMMON_Attack, 10, NPC_ATK_StepR, TARGET_ENE_0, DIST_None, 0)
        end
        return true
    end
    
end

function FindAttack_Act(f12_arg0, f12_arg1, f12_arg2, f12_arg3)
    local f12_local0 = f12_arg0:GetDist(TARGET_ENE_0)
    local f12_local1 = f12_arg0:GetRandam_Int(1, 100)
    if f12_arg0:IsInterupt(INTERUPT_FindAttack) and f12_local0 <= f12_arg2 and f12_local1 <= f12_arg3 then
        f12_arg1:ClearSubGoal()
        return true
    end
    return false
    
end

function FindAttack_Step(f13_arg0, f13_arg1, f13_arg2, f13_arg3, f13_arg4, f13_arg5, f13_arg6, f13_arg7)
    local f13_local0 = f13_arg0:GetDist(TARGET_ENE_0)
    local f13_local1 = f13_arg0:GetRandam_Int(1, 100)
    local f13_local2 = f13_arg0:GetRandam_Int(1, 100)
    local f13_local3 = GET_PARAM_IF_NIL_DEF(f13_arg4, 50)
    local f13_local4 = GET_PARAM_IF_NIL_DEF(f13_arg5, 25)
    local f13_local5 = GET_PARAM_IF_NIL_DEF(f13_arg6, 25)
    local f13_local6 = GET_PARAM_IF_NIL_DEF(f13_arg7, 3)
    if f13_arg0:IsInterupt(INTERUPT_FindAttack) and f13_local0 <= f13_arg2 and f13_local1 <= f13_arg3 then
        f13_arg1:ClearSubGoal()
        if f13_local2 <= f13_local3 then
            f13_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 5, 701, TARGET_ENE_0, 0, AI_DIR_TYPE_B, f13_local6)
        elseif f13_local2 <= f13_local3 + f13_local4 then
            f13_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 5, 702, TARGET_ENE_0, 0, AI_DIR_TYPE_L, f13_local6)
        else
            f13_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 5, 703, TARGET_ENE_0, 0, AI_DIR_TYPE_R, f13_local6)
        end
        return true
    end
    
end

function FindAttack_Guard(f14_arg0, f14_arg1, f14_arg2, f14_arg3, f14_arg4, f14_arg5, f14_arg6)
    local f14_local0 = f14_arg0:GetDist(TARGET_ENE_0)
    local f14_local1 = f14_arg0:GetRandam_Int(1, 100)
    local f14_local2 = f14_arg0:GetRandam_Int(1, 100)
    local f14_local3 = GET_PARAM_IF_NIL_DEF(f14_arg4, 40)
    local f14_local4 = GET_PARAM_IF_NIL_DEF(f14_arg5, 4)
    local f14_local5 = GET_PARAM_IF_NIL_DEF(f14_arg6, 3)
    if f14_arg0:IsInterupt(INTERUPT_FindAttack) and f14_local0 <= f14_arg2 and f14_local1 <= f14_arg3 then
        f14_arg1:ClearSubGoal()
        if f14_local2 <= f14_local3 then
            f14_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 4, TARGET_ENE_0, f14_local5, TARGET_ENE_0, true, 9910)
        else
            f14_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 4, TARGET_ENE_0, f14_local5, TARGET_ENE_0, true, 9910)
            f14_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f14_local4, TARGET_ENE_0, f14_arg0:GetRandam_Int(0, 1), f14_arg0:GetRandam_Int(30, 45), true, true, 9910)
        end
        return true
    end
    
end

function FindAttack_Step_or_Guard(f15_arg0, f15_arg1, f15_arg2, f15_arg3, f15_arg4, f15_arg5, f15_arg6, f15_arg7, f15_arg8, f15_arg9, f15_arg10, f15_arg11)
    local f15_local0 = f15_arg0:GetDist(TARGET_ENE_0)
    local f15_local1 = f15_arg0:GetRandam_Int(1, 100)
    local f15_local2 = f15_arg0:GetRandam_Int(1, 100)
    local f15_local3 = f15_arg0:GetRandam_Int(1, 100)
    local f15_local4 = GET_PARAM_IF_NIL_DEF(f15_arg5, 50)
    local f15_local5 = GET_PARAM_IF_NIL_DEF(f15_arg6, 25)
    local f15_local6 = GET_PARAM_IF_NIL_DEF(f15_arg7, 25)
    local f15_local7 = GET_PARAM_IF_NIL_DEF(f15_arg8, 3)
    local f15_local8 = GET_PARAM_IF_NIL_DEF(f15_arg9, 40)
    local f15_local9 = GET_PARAM_IF_NIL_DEF(f15_arg10, 4)
    local f15_local10 = GET_PARAM_IF_NIL_DEF(f15_arg11, 3)
    if f15_arg0:IsInterupt(INTERUPT_FindAttack) and f15_local0 <= f15_arg2 and f15_local1 <= f15_arg3 then
        if f15_local2 <= f15_arg4 then
            f15_arg1:ClearSubGoal()
            if f15_local3 <= f15_local4 then
                f15_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 5, 701, TARGET_ENE_0, 0, AI_DIR_TYPE_B, f15_local7)
            elseif f15_local3 <= f15_local4 + f15_local5 then
                f15_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 5, 702, TARGET_ENE_0, 0, AI_DIR_TYPE_L, f15_local7)
            else
                f15_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 5, 703, TARGET_ENE_0, 0, AI_DIR_TYPE_R, f15_local7)
            end
            return true
        else
            f15_arg1:ClearSubGoal()
            if f15_local3 <= f15_local8 then
                f15_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 4, TARGET_ENE_0, f15_local10, TARGET_ENE_0, true, 9910)
            else
                f15_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 4, TARGET_ENE_0, f15_local10, TARGET_ENE_0, true, 9910)
                f15_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f15_local9, TARGET_ENE_0, f15_arg0:GetRandam_Int(0, 1), f15_arg0:GetRandam_Int(30, 45), true, true, 9910)
            end
            return true
        end
    end
    
end

function Damaged_Act(f16_arg0, f16_arg1, f16_arg2, f16_arg3)
    local f16_local0 = f16_arg0:GetDist(TARGET_ENE_0)
    local f16_local1 = f16_arg0:GetRandam_Int(1, 100)
    if f16_arg0:IsInterupt(INTERUPT_Damaged) and f16_local0 < f16_arg2 and f16_local1 <= f16_arg3 then
        f16_arg1:ClearSubGoal()
        return true
    end
    return false
    
end

function Damaged_Guard(f17_arg0, f17_arg1, f17_arg2, f17_arg3, f17_arg4, f17_arg5, f17_arg6)
    local f17_local0 = f17_arg0:GetDist(TARGET_ENE_0)
    local f17_local1 = f17_arg0:GetRandam_Int(1, 100)
    local f17_local2 = f17_arg0:GetRandam_Int(1, 100)
    local f17_local3 = GET_PARAM_IF_NIL_DEF(f17_arg4, 40)
    local f17_local4 = GET_PARAM_IF_NIL_DEF(f17_arg5, 4)
    local f17_local5 = GET_PARAM_IF_NIL_DEF(f17_arg6, 3)
    if f17_arg0:IsInterupt(INTERUPT_Damaged) and f17_local0 <= f17_arg2 and f17_local1 <= f17_arg3 then
        f17_arg1:ClearSubGoal()
        if f17_local2 <= f17_local3 then
            f17_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 4, TARGET_ENE_0, f17_local5, TARGET_ENE_0, true, 9910)
        else
            f17_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 4, TARGET_ENE_0, f17_local5, TARGET_ENE_0, true, 9910)
            f17_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f17_local4, TARGET_ENE_0, f17_arg0:GetRandam_Int(0, 1), f17_arg0:GetRandam_Int(30, 45), true, true, 9910)
        end
        return true
    end
    
end

function Damaged_Step(f18_arg0, f18_arg1, f18_arg2, f18_arg3, f18_arg4, f18_arg5, f18_arg6, f18_arg7)
    local f18_local0 = f18_arg0:GetDist(TARGET_ENE_0)
    local f18_local1 = f18_arg0:GetRandam_Int(1, 100)
    local f18_local2 = f18_arg0:GetRandam_Int(1, 100)
    local f18_local3 = GET_PARAM_IF_NIL_DEF(f18_arg4, 50)
    local f18_local4 = GET_PARAM_IF_NIL_DEF(f18_arg5, 25)
    local f18_local5 = GET_PARAM_IF_NIL_DEF(f18_arg6, 25)
    local f18_local6 = GET_PARAM_IF_NIL_DEF(f18_arg7, 3)
    if f18_arg0:IsInterupt(INTERUPT_Damaged) and f18_local0 <= f18_arg2 and f18_local1 <= f18_arg3 then
        f18_arg1:ClearSubGoal()
        if f18_local2 <= f18_local3 then
            f18_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 5, 701, TARGET_ENE_0, 0, AI_DIR_TYPE_B, f18_local6)
        elseif f18_local2 <= f18_local3 + f18_local4 then
            f18_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 5, 702, TARGET_ENE_0, 0, AI_DIR_TYPE_L, f18_local6)
        else
            f18_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 5, 703, TARGET_ENE_0, 0, AI_DIR_TYPE_R, f18_local6)
        end
        return true
    end
    
end

function Damaged_Step_or_Guard(f19_arg0, f19_arg1, f19_arg2, f19_arg3, f19_arg4, f19_arg5, f19_arg6, f19_arg7, f19_arg8, f19_arg9, f19_arg10, f19_arg11)
    local f19_local0 = f19_arg0:GetDist(TARGET_ENE_0)
    local f19_local1 = f19_arg0:GetRandam_Int(1, 100)
    local f19_local2 = f19_arg0:GetRandam_Int(1, 100)
    local f19_local3 = f19_arg0:GetRandam_Int(1, 100)
    local f19_local4 = GET_PARAM_IF_NIL_DEF(f19_arg5, 50)
    local f19_local5 = GET_PARAM_IF_NIL_DEF(f19_arg6, 25)
    local f19_local6 = GET_PARAM_IF_NIL_DEF(f19_arg7, 25)
    local f19_local7 = GET_PARAM_IF_NIL_DEF(f19_arg8, 3)
    local f19_local8 = GET_PARAM_IF_NIL_DEF(f19_arg9, 40)
    local f19_local9 = GET_PARAM_IF_NIL_DEF(f19_arg10, 4)
    local f19_local10 = GET_PARAM_IF_NIL_DEF(f19_arg11, 3)
    if f19_arg0:IsInterupt(INTERUPT_Damaged) and f19_local0 <= f19_arg2 and f19_local1 <= f19_arg3 then
        if f19_local2 <= f19_arg4 then
            f19_arg1:ClearSubGoal()
            if f19_local3 <= f19_local4 then
                f19_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 5, 701, TARGET_ENE_0, 0, AI_DIR_TYPE_B, f19_local7)
            elseif f19_local3 <= f19_local4 + f19_local5 then
                f19_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 5, 702, TARGET_ENE_0, 0, AI_DIR_TYPE_L, f19_local7)
            else
                f19_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 5, 703, TARGET_ENE_0, 0, AI_DIR_TYPE_R, f19_local7)
            end
            return true
        else
            f19_arg1:ClearSubGoal()
            if f19_local3 <= f19_local8 then
                f19_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 4, TARGET_ENE_0, f19_local10, TARGET_ENE_0, true, 9910)
            else
                f19_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 4, TARGET_ENE_0, f19_local10, TARGET_ENE_0, true, 9910)
                f19_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f19_local9, TARGET_ENE_0, f19_arg0:GetRandam_Int(0, 1), f19_arg0:GetRandam_Int(30, 45), true, true, 9910)
            end
            return true
        end
    end
    
end

function GuardBreak_Act(f20_arg0, f20_arg1, f20_arg2, f20_arg3)
    local f20_local0 = f20_arg0:GetDist(TARGET_ENE_0)
    local f20_local1 = f20_arg0:GetRandam_Int(1, 100)
    if f20_arg0:IsInterupt(INTERUPT_GuardBreak) and f20_local0 <= f20_arg2 and f20_local1 <= f20_arg3 then
        f20_arg1:ClearSubGoal()
        return true
    end
    return false
    
end

function GuardBreak_Attack(f21_arg0, f21_arg1, f21_arg2, f21_arg3, f21_arg4)
    local f21_local0 = f21_arg0:GetDist(TARGET_ENE_0)
    local f21_local1 = f21_arg0:GetRandam_Int(1, 100)
    if f21_arg0:IsInterupt(INTERUPT_GuardBreak) and f21_local0 <= f21_arg2 and f21_local1 <= f21_arg3 then
        f21_arg1:ClearSubGoal()
        f21_arg1:AddSubGoal(GOAL_COMMON_Attack, 10, f21_arg4, TARGET_ENE_0, DIST_Middle, 0)
        return true
    end
    return false
    
end

function MissSwing_Int(f22_arg0, f22_arg1, f22_arg2, f22_arg3)
    local f22_local0 = f22_arg0:GetDist(TARGET_ENE_0)
    local f22_local1 = f22_arg0:GetRandam_Int(1, 100)
    if f22_arg0:IsInterupt(INTERUPT_MissSwing) and f22_local0 <= f22_arg2 and f22_local1 <= f22_arg3 then
        f22_arg1:ClearSubGoal()
        return true
    end
    return false
    
end

function MissSwing_Attack(f23_arg0, f23_arg1, f23_arg2, f23_arg3, f23_arg4)
    local f23_local0 = f23_arg0:GetDist(TARGET_ENE_0)
    local f23_local1 = f23_arg0:GetRandam_Int(1, 100)
    if f23_arg0:IsInterupt(INTERUPT_MissSwing) and f23_local0 <= f23_arg2 and f23_local1 <= f23_arg3 then
        f23_arg1:ClearSubGoal()
        f23_arg1:AddSubGoal(GOAL_COMMON_Attack, 10, f23_arg4, TARGET_ENE_0, DIST_Middle, 0)
        return true
    end
    return false
    
end

function UseItem_Act(f24_arg0, f24_arg1, f24_arg2, f24_arg3)
    local f24_local0 = f24_arg0:GetDist(TARGET_ENE_0)
    local f24_local1 = f24_arg0:GetRandam_Int(1, 100)
    if f24_arg0:IsInterupt(INTERUPT_UseItem) and f24_local0 <= f24_arg2 and f24_local1 <= f24_arg3 then
        f24_arg1:ClearSubGoal()
        return true
    end
    return false
    
end

function Shoot_1kind(f25_arg0, f25_arg1, f25_arg2, f25_arg3)
    local f25_local0 = f25_arg0:GetDist(TARGET_ENE_0)
    local f25_local1 = f25_arg0:GetRandam_Int(1, 100)
    local f25_local2 = GET_PARAM_IF_NIL_DEF(bkStepPer, 50)
    local f25_local3 = GET_PARAM_IF_NIL_DEF(leftStepPer, 25)
    local f25_local4 = GET_PARAM_IF_NIL_DEF(rightStepPer, 25)
    local f25_local5 = GET_PARAM_IF_NIL_DEF(safetyDist, 3)
    if f25_arg0:IsInterupt(INTERUPT_Shoot) and f25_local0 <= f25_arg2 and f25_local1 <= f25_arg3 then
        f25_arg1:ClearSubGoal()
        return true
    end
    return false
    
end

function Shoot_2dist(f26_arg0, f26_arg1, f26_arg2, f26_arg3, f26_arg4, f26_arg5)
    local f26_local0 = f26_arg0:GetDist(TARGET_ENE_0)
    local f26_local1 = f26_arg0:GetRandam_Int(1, 100)
    local f26_local2 = f26_arg0:GetRandam_Int(1, 100)
    if f26_arg0:IsInterupt(INTERUPT_Shoot) then
        if f26_local0 <= f26_arg2 then
            if f26_local1 <= f26_arg4 then
                f26_arg1:ClearSubGoal()
                return 1
            end
        elseif f26_local0 <= f26_arg3 then
            if f26_local1 <= f26_arg5 then
                f26_arg1:ClearSubGoal()
                return 2
            end
        else
            return 0
        end
    end
    return 0
    
end

function MissSwingSelf_Step(f27_arg0, f27_arg1, f27_arg2, f27_arg3, f27_arg4, f27_arg5, f27_arg6)
    local f27_local0 = f27_arg0:GetDist(TARGET_ENE_0)
    local f27_local1 = f27_arg0:GetRandam_Int(1, 100)
    local f27_local2 = f27_arg0:GetRandam_Int(1, 100)
    local f27_local3 = GET_PARAM_IF_NIL_DEF(f27_arg3, 50)
    local f27_local4 = GET_PARAM_IF_NIL_DEF(f27_arg4, 25)
    local f27_local5 = GET_PARAM_IF_NIL_DEF(f27_arg5, 25)
    local f27_local6 = GET_PARAM_IF_NIL_DEF(f27_arg6, 3)
    if f27_arg0:IsInterupt(INTERUPT_MissSwingSelf) and f27_local1 <= f27_arg2 then
        f27_arg1:ClearSubGoal()
        if f27_local2 <= f27_local3 then
            f27_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 5, 701, TARGET_ENE_0, 0, AI_DIR_TYPE_B, f27_local6)
        elseif f27_local2 <= f27_local3 + f27_local4 then
            f27_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 5, 702, TARGET_ENE_0, 0, AI_DIR_TYPE_L, f27_local6)
        else
            f27_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 5, 703, TARGET_ENE_0, 0, AI_DIR_TYPE_R, f27_local6)
        end
        return true
    end
    
end

function RebByOpGuard_Step(f28_arg0, f28_arg1, f28_arg2, f28_arg3, f28_arg4, f28_arg5, f28_arg6)
    local f28_local0 = f28_arg0:GetDist(TARGET_ENE_0)
    local f28_local1 = f28_arg0:GetRandam_Int(1, 100)
    local f28_local2 = f28_arg0:GetRandam_Int(1, 100)
    local f28_local3 = GET_PARAM_IF_NIL_DEF(f28_arg3, 50)
    local f28_local4 = GET_PARAM_IF_NIL_DEF(f28_arg4, 25)
    local f28_local5 = GET_PARAM_IF_NIL_DEF(f28_arg5, 25)
    local f28_local6 = GET_PARAM_IF_NIL_DEF(f28_arg6, 3)
    if f28_arg0:IsInterupt(INTERUPT_ReboundByOpponentGuard) and f28_local1 <= f28_arg2 then
        f28_arg1:ClearSubGoal()
        if f28_local2 <= f28_local3 then
            f28_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 5, 701, TARGET_ENE_0, 0, AI_DIR_TYPE_B, f28_local6)
        elseif f28_local2 <= f28_local3 + f28_local4 then
            f28_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 5, 702, TARGET_ENE_0, 0, AI_DIR_TYPE_L, f28_local6)
        else
            f28_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 5, 703, TARGET_ENE_0, 0, AI_DIR_TYPE_R, f28_local6)
        end
        return true
    end
    
end

function SuccessGuard_Act(f29_arg0, f29_arg1, f29_arg2, f29_arg3)
    local f29_local0 = f29_arg0:GetDist(TARGET_ENE_0)
    local f29_local1 = f29_arg0:GetRandam_Int(1, 100)
    local f29_local2 = f29_arg0:GetRandam_Int(1, 100)
    if f29_arg0:IsInterupt(INTERUPT_SuccessGuard) and f29_local0 <= f29_arg2 and f29_local1 <= f29_arg3 then
        f29_arg1:ClearSubGoal()
        return true
    end
    return false
    
end

function SuccessGuard_Attack(f30_arg0, f30_arg1, f30_arg2, f30_arg3, f30_arg4)
    local f30_local0 = f30_arg0:GetDist(TARGET_ENE_0)
    local f30_local1 = f30_arg0:GetRandam_Int(1, 100)
    if f30_arg0:IsInterupt(INTERUPT_SuccessGuard) and f30_local0 <= f30_arg2 and f30_local1 <= f30_arg3 then
        f30_arg1:ClearSubGoal()
        f30_arg1:AddSubGoal(GOAL_COMMON_Attack, 10, f30_arg4, TARGET_ENE_0, DIST_Middle, 0)
        return true
    end
    return false
    
end

function FarDamaged_Act(f31_arg0, f31_arg1, f31_arg2, f31_arg3)
    local f31_local0 = f31_arg0:GetDist(TARGET_ENE_0)
    local f31_local1 = f31_arg0:GetRandam_Int(1, 100)
    if f31_arg0:IsInterupt(INTERUPT_Damaged) and f31_arg2 <= f31_local0 and f31_local1 <= f31_arg3 then
        f31_arg1:ClearSubGoal()
        return true
    end
    return false
    
end

function MissSwing_Act(f32_arg0, f32_arg1, f32_arg2, f32_arg3)
    local f32_local0 = f32_arg0:GetDist(TARGET_ENE_0)
    local f32_local1 = f32_arg0:GetRandam_Int(1, 100)
    if f32_arg0:IsInterupt(INTERUPT_MissSwing) and f32_local0 <= f32_arg2 and f32_local1 <= f32_arg3 then
        f32_arg1:ClearSubGoal()
        return true
    end
    return false
    
end

function FindGuardBreak_Act(f33_arg0, f33_arg1, f33_arg2, f33_arg3)
    local f33_local0 = f33_arg0:GetDist(TARGET_ENE_0)
    local f33_local1 = f33_arg0:GetRandam_Int(1, 100)
    if f33_arg0:IsInterupt(INTERUPT_GuardBreak) and f33_local0 <= f33_arg2 and f33_local1 <= f33_arg3 then
        f33_arg1:ClearSubGoal()
        return true
    end
    return false
    
end

function FindGuardFinish_Act(f34_arg0, f34_arg1, f34_arg2, f34_arg3)
    local f34_local0 = f34_arg0:GetDist(TARGET_ENE_0)
    local f34_local1 = f34_arg0:GetRandam_Int(1, 100)
    if f34_arg0:IsInterupt(INTERUPT_GuardFinish) and f34_local0 <= f34_arg2 and f34_local1 <= f34_arg3 then
        f34_arg1:ClearSubGoal()
        return true
    end
    return false
    
end

function FindShoot_Act(f35_arg0, f35_arg1, f35_arg2, f35_arg3, f35_arg4, f35_arg5, f35_arg6, f35_arg7)
    local f35_local0 = f35_arg0:GetDist(TARGET_ENE_0)
    local f35_local1 = f35_arg0:GetRandam_Int(1, 100)
    if f35_arg0:IsInterupt(INTERUPT_Shoot) then
        if f35_local0 <= f35_arg5 and f35_local1 <= f35_arg2 then
            f35_arg1:ClearSubGoal()
            return 1
        elseif f35_local0 <= f35_arg6 and f35_local1 <= f35_arg3 then
            f35_arg1:ClearSubGoal()
            return 2
        elseif f35_local0 <= f35_arg7 and f35_local1 <= f35_arg4 then
            f35_arg1:ClearSubGoal()
            return 3
        else
            f35_arg1:ClearSubGoal()
            return 0
        end
    end
    return 0
    
end

function BusyApproach_Act(f36_arg0, f36_arg1, f36_arg2, f36_arg3, f36_arg4)
    local f36_local0 = -1
    local f36_local1 = f36_arg0:GetRandam_Int(1, 100)
    if f36_local1 <= f36_arg4 then
        f36_local0 = 9910
    end
    local f36_local2 = f36_arg0:GetDist(TARGET_ENE_0)
    if f36_arg3 <= f36_local2 then
        f36_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 10, TARGET_ENE_0, f36_arg2, TARGET_SELF, false, f36_local0)
    else
        f36_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 2, TARGET_ENE_0, f36_arg2, TARGET_SELF, true, f36_local0)
    end
    
end

function Approach_and_Attack_Act(f37_arg0, f37_arg1, f37_arg2, f37_arg3, f37_arg4, f37_arg5, f37_arg6, f37_arg7, f37_arg8)
    local f37_local0 = f37_arg0:GetDist(TARGET_ENE_0)
    local f37_local1 = true
    if f37_arg3 <= f37_local0 then
        f37_local1 = false
    end
    local f37_local2 = -1
    local f37_local3 = f37_arg0:GetRandam_Int(1, 100)
    if f37_local3 <= f37_arg4 then
        f37_local2 = 9910
    end
    local f37_local4 = GET_PARAM_IF_NIL_DEF(f37_arg7, 1.5)
    local f37_local5 = GET_PARAM_IF_NIL_DEF(f37_arg8, 20)
    f37_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 10, TARGET_ENE_0, f37_arg2, TARGET_SELF, f37_local1, f37_local2)
    f37_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f37_arg5, TARGET_ENE_0, f37_arg6, f37_local4, f37_local5)
    
end

function KeepDist_and_Attack_Act(f38_arg0, f38_arg1, f38_arg2, f38_arg3, f38_arg4, f38_arg5, f38_arg6, f38_arg7)
    local f38_local0 = f38_arg0:GetDist(TARGET_ENE_0)
    local f38_local1 = true
    if f38_arg4 <= f38_local0 then
        f38_local1 = false
    end
    local f38_local2 = -1
    local f38_local3 = f38_arg0:GetRandam_Int(1, 100)
    if f38_local3 <= f38_arg5 then
        f38_local2 = 9910
    end
    f38_arg1:AddSubGoal(GOAL_COMMON_KeepDist, 10, TARGET_ENE_0, f38_arg2, f38_arg3, TARGET_ENE_0, f38_local1, f38_local2)
    f38_arg1:AddSubGoal(GOAL_COMMON_Attack, 10, f38_arg6, TARGET_ENE_0, f38_arg7, 0)
    
end

function Approach_and_GuardBreak_Act(f39_arg0, f39_arg1, f39_arg2, f39_arg3, f39_arg4, f39_arg5, f39_arg6, f39_arg7, f39_arg8)
    local f39_local0 = f39_arg0:GetDist(TARGET_ENE_0)
    local f39_local1 = true
    if f39_arg3 <= f39_local0 then
        f39_local1 = false
    end
    local f39_local2 = -1
    local f39_local3 = f39_arg0:GetRandam_Int(1, 100)
    if f39_local3 <= f39_arg4 then
        f39_local2 = 9910
    end
    f39_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 10, TARGET_ENE_0, f39_arg2, TARGET_SELF, f39_local1, f39_local2)
    f39_arg1:AddSubGoal(GOAL_COMMON_GuardBreakAttack, 10, f39_arg5, TARGET_ENE_0, f39_arg6, 0)
    f39_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, f39_arg7, TARGET_ENE_0, f39_arg8, 0)
    
end

function GetWellSpace_Act(f40_arg0, f40_arg1, f40_arg2, f40_arg3, f40_arg4, f40_arg5, f40_arg6, f40_arg7)
    local f40_local0 = -1
    local f40_local1 = f40_arg0:GetRandam_Int(1, 100)
    if f40_local1 <= f40_arg2 then
        f40_local0 = 9910
    end
    local f40_local2 = f40_arg0:GetRandam_Int(1, 100)
    local f40_local3 = f40_arg0:GetRandam_Int(0, 1)
    local f40_local4 = f40_arg0:GetTeamRecordCount(COORDINATE_TYPE_SideWalk_L + f40_local3, TARGET_ENE_0, 2)
    if f40_local2 <= f40_arg3 then
    elseif f40_local2 <= f40_arg3 + f40_arg4 and f40_local4 < 2 then
        f40_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 2.5, TARGET_ENE_0, 2, TARGET_ENE_0, true, f40_local0)
        f40_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, 3, TARGET_ENE_0, f40_local3, f40_arg0:GetRandam_Int(30, 45), true, true, f40_local0)
    elseif f40_local2 <= f40_arg3 + f40_arg4 + f40_arg5 then
        f40_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 2.5, TARGET_ENE_0, 3, TARGET_ENE_0, true, f40_local0)
    elseif f40_local2 <= f40_arg3 + f40_arg4 + f40_arg5 + f40_arg6 then
        f40_arg1:AddSubGoal(GOAL_COMMON_Wait, f40_arg0:GetRandam_Float(0.5, 1), 0, 0, 0, 0)
    else
        f40_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 5, 701, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 4)
    end
    
end

function GetWellSpace_Act_IncludeSidestep(f41_arg0, f41_arg1, f41_arg2, f41_arg3, f41_arg4, f41_arg5, f41_arg6, f41_arg7, f41_arg8)
    local f41_local0 = -1
    local f41_local1 = f41_arg0:GetRandam_Int(1, 100)
    if f41_local1 <= f41_arg2 then
        f41_local0 = 9910
    end
    local f41_local2 = f41_arg0:GetRandam_Int(1, 100)
    local f41_local3 = f41_arg0:GetRandam_Int(0, 1)
    local f41_local4 = f41_arg0:GetTeamRecordCount(COORDINATE_TYPE_SideWalk_L + f41_local3, TARGET_ENE_0, 2)
    if f41_local2 <= f41_arg3 then
    elseif f41_local2 <= f41_arg3 + f41_arg4 and f41_local4 < 2 then
        f41_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 2.5, TARGET_ENE_0, 2, TARGET_ENE_0, true, f41_local0)
        f41_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, 3, TARGET_ENE_0, f41_local3, f41_arg0:GetRandam_Int(30, 45), true, true, f41_local0)
    elseif f41_local2 <= f41_arg3 + f41_arg4 + f41_arg5 then
        f41_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 2.5, TARGET_ENE_0, 3, TARGET_ENE_0, true, f41_local0)
    elseif f41_local2 <= f41_arg3 + f41_arg4 + f41_arg5 + f41_arg6 then
        f41_arg1:AddSubGoal(GOAL_COMMON_Wait, f41_arg0:GetRandam_Float(0.5, 1), 0, 0, 0, 0)
    elseif f41_local2 <= f41_arg3 + f41_arg4 + f41_arg5 + f41_arg6 + f41_arg7 then
        f41_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 5, 6001, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 4)
    else
        local f41_local5 = f41_arg0:GetRandam_Int(1, 100)
        if f41_local5 <= 50 then
            f41_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 5, 6002, TARGET_ENE_0, 0, AI_DIR_TYPE_L, 4)
        else
            f41_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 5, 6003, TARGET_ENE_0, 0, AI_DIR_TYPE_R, 4)
        end
    end
    
end

function Shoot_Act(f42_arg0, f42_arg1, f42_arg2, f42_arg3, f42_arg4)
    if f42_arg4 == 1 then
        f42_arg1:AddSubGoal(GOAL_COMMON_Attack, 10, f42_arg2, TARGET_ENE_0, DIST_None, 0)
    elseif f42_arg4 >= 2 then
        f42_arg1:AddSubGoal(GOAL_COMMON_ComboAttack, 10, f42_arg2, TARGET_ENE_0, DIST_None, 0)
        if f42_arg4 >= 3 then
            f42_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, f42_arg3, TARGET_ENE_0, DIST_None, 0)
            if f42_arg4 >= 4 then
                f42_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, f42_arg3, TARGET_ENE_0, DIST_None, 0)
                if f42_arg4 >= 5 then
                    f42_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, f42_arg3, TARGET_ENE_0, DIST_None, 0)
                end
            end
        end
        f42_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, f42_arg3, TARGET_ENE_0, DIST_None, 0)
    end
    
end

function Approach_Act(f43_arg0, f43_arg1, f43_arg2, f43_arg3, f43_arg4, f43_arg5)
    if f43_arg5 == nil then
        f43_arg5 = 10
    end
    local f43_local0 = f43_arg0:GetDist(TARGET_ENE_0)
    local f43_local1 = true
    if f43_arg3 <= f43_local0 then
        f43_local1 = false
    end
    local f43_local2 = -1
    local f43_local3 = f43_arg0:GetRandam_Int(1, 100)
    if f43_local3 <= f43_arg4 then
        f43_local2 = 9910
    end
    f43_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, f43_arg5, TARGET_ENE_0, f43_arg2, TARGET_SELF, f43_local1, f43_local2)
    
end

function Approach_or_Leave_Act(f44_arg0, f44_arg1, f44_arg2, f44_arg3, f44_arg4, f44_arg5)
    local f44_local0 = f44_arg0:GetDist(TARGET_ENE_0)
    local f44_local1 = true
    if f44_arg4 ~= -1 and f44_arg4 <= f44_local0 then
        f44_local1 = false
    end
    local f44_local2 = -1
    local f44_local3 = f44_arg0:GetRandam_Int(1, 100)
    if f44_local3 <= f44_arg5 then
        f44_local2 = 9910
    end
    if f44_arg2 <= f44_local0 then
        f44_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 5, TARGET_ENE_0, f44_arg3, TARGET_SELF, f44_local1, f44_local2)
    else
        f44_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 5, TARGET_ENE_0, f44_arg2, TARGET_ENE_0, true, f44_local2)
    end
    
end

function Watching_Parry_Chance_Act(f45_arg0, f45_arg1)
    FirstDist = f45_arg0:GetRandam_Float(2, 4)
    SecondDist = f45_arg0:GetRandam_Float(2, 4)
    f45_arg1:AddSubGoal(GOAL_COMMON_KeepDist, 5, TARGET_ENE_0, FirstDist, FirstDist + 0.5, TARGET_ENE_0, true, 9920)
    f45_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f45_arg0:GetRandam_Float(3, 5), TARGET_ENE_0, f45_arg0:GetRandam_Int(0, 1), 180, true, true, 9920)
    f45_arg1:AddSubGoal(GOAL_COMMON_KeepDist, 5, TARGET_ENE_0, SecondDist, SecondDist + 0.5, TARGET_ENE_0, true, 9920)
    f45_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f45_arg0:GetRandam_Float(3, 5), TARGET_ENE_0, f45_arg0:GetRandam_Int(0, 1), 180, true, true, 9920)
    
end

function Parry_Act(f46_arg0, f46_arg1, f46_arg2, f46_arg3, f46_arg4, f46_arg5)
    local f46_local0 = f46_arg0:GetDist(TARGET_ENE_0)
    if f46_arg0:IsInterupt(INTERUPT_ParryTiming) then
        if f46_local0 <= f46_arg2 and f46_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, f46_arg3) then
            f46_arg1:ClearSubGoal()
            f46_arg1:AddSubGoal(GOAL_COMMON_Parry, 1.25, 4000, TARGET_SELF, 0)
            return true
        end
    elseif f46_arg0:IsInterupt(INTERUPT_SuccessParry) and f46_local0 <= f46_arg4 and f46_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, f46_arg5) then
        f46_arg1:ClearSubGoal()
        f46_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 3, TARGET_ENE_0, 1, TARGET_SELF, false, -1)
        local f46_local1 = f46_arg0:GetRandam_Float(0.3, 0.6)
        f46_arg1:AddSubGoal(GOAL_COMMON_Wait, f46_local1, TARGET_ENE_0)
        f46_arg1:AddSubGoal(GOAL_COMMON_Attack, 10, 3110, TARGET_ENE_0, 3, 0)
        return true
    end
    
end

function ObserveAreaForBackstab(f47_arg0, f47_arg1, f47_arg2, f47_arg3, f47_arg4)
    f47_arg0:AddObserveArea(f47_arg2, TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_B, f47_arg4, f47_arg3)
    
end

function Backstab_Act(f48_arg0, f48_arg1, f48_arg2, f48_arg3, f48_arg4, f48_arg5)
    if f48_arg0:IsInterupt(INTERUPT_Inside_ObserveArea) and f48_arg0:IsThrowing() == false and f48_arg0:IsFinishTimer(f48_arg4) == true and f48_arg0:IsInsideObserve(f48_arg2) then
        f48_arg0:SetTimer(f48_arg4, f48_arg5)
        f48_arg1:ClearSubGoal()
        f48_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 5, TARGET_ENE_0, f48_arg3, TARGET_SELF, false, -1)
        f48_arg1:AddSubGoal(GOAL_COMMON_Attack, 10, 3110, TARGET_ENE_0, 3, 0)
        return true
    end
    
end

function Torimaki_Act(f49_arg0, f49_arg1, f49_arg2)
    local f49_local0 = -1
    local f49_local1 = f49_arg0:GetRandam_Int(1, 100)
    if f49_local1 <= f49_arg2 then
        f49_local0 = 9910
    end
    local f49_local2 = f49_arg0:GetDist(TARGET_ENE_0)
    if f49_local2 >= 15 then
        f49_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 5, TARGET_ENE_0, 4.5, TARGET_SELF, true, -1)
    elseif f49_local2 >= 6 then
        f49_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 5, TARGET_ENE_0, 4.5, TARGET_SELF, true, -1)
    elseif f49_local2 >= 3 then
        f49_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, 3, TARGET_ENE_0, f49_arg0:GetRandam_Int(0, 1), f49_arg0:GetRandam_Int(30, 45), true, true, f49_local0)
    else
        f49_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 5, TARGET_ENE_0, 4, TARGET_ENE_0, true, f49_local0)
    end
    f49_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, 3, TARGET_ENE_0, f49_arg0:GetRandam_Int(0, 1), f49_arg0:GetRandam_Int(30, 45), true, true, f49_local0)
    
end

function Kankyaku_Act(f50_arg0, f50_arg1, f50_arg2)
    local f50_local0 = -1
    local f50_local1 = f50_arg0:GetRandam_Int(1, 100)
    if f50_local1 <= f50_arg2 then
        f50_local0 = 9910
    end
    local f50_local2 = f50_arg0:GetDist(TARGET_ENE_0)
    if f50_local2 >= 15 then
        f50_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 5, TARGET_ENE_0, 6.5, TARGET_SELF, true, -1)
    elseif f50_local2 >= 8 then
        f50_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 5, TARGET_ENE_0, 6.5, TARGET_SELF, true, -1)
    elseif f50_local2 >= 4 then
        f50_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, 3, TARGET_ENE_0, f50_arg0:GetRandam_Int(0, 1), f50_arg0:GetRandam_Int(30, 45), true, true, f50_local0)
    else
        f50_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 5, TARGET_ENE_0, 6, TARGET_ENE_0, true, f50_local0)
    end
    f50_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, 3, TARGET_ENE_0, f50_arg0:GetRandam_Int(0, 1), f50_arg0:GetRandam_Int(30, 45), true, true, f50_local0)
    
end

function ClearTableParam(f51_arg0, f51_arg1)
    local f51_local0 = 50
    local f51_local1 = 1
    for f51_local2 = 1, f51_local0, 1 do
        f51_arg0[f51_local2] = 0
        f51_arg1[f51_local2] = {}
    end
    

end

function SelectOddsIndex(f52_arg0, f52_arg1)
    local f52_local0 = table.getn(f52_arg1)
    local f52_local1 = 0
    for f52_local2 = 1, f52_local0, 1 do
        f52_local1 = f52_local1 + f52_arg1[f52_local2]
    end
    local f52_local2 = f52_arg0:GetRandam_Int(0, f52_local1 - 1)
    for f52_local3 = 1, f52_local0, 1 do
        local f52_local6 = f52_arg1[f52_local3]
        if f52_local2 < f52_local6 then
            return f52_local3
        end
        f52_local2 = f52_local2 - f52_local6
    end
    return -1
    


end

function SelectFunc(f53_arg0, f53_arg1, f53_arg2)
    local f53_local0 = SelectOddsIndex(f53_arg0, f53_arg1)
    if f53_local0 < 1 then
        return nil
    end
    return f53_arg2[f53_local0]
    
end

function SelectGoalFunc(f54_arg0, f54_arg1, f54_arg2)
    local f54_local0 = _GetGoalActFuncTable(f54_arg0)
    return SelectFunc(f54_arg1, f54_arg2, f54_local0)
    
end

function CallAttackAndAfterFunc(f55_arg0, f55_arg1, f55_arg2, f55_arg3, f55_arg4, f55_arg5)
    local f55_local0 = SelectOddsIndex(f55_arg1, f55_arg3)
    local f55_local1 = 0
    if f55_local0 >= 1 then
        local f55_local2 = _GetGoalActFuncTable(f55_arg0)
        local f55_local3 = nil
        if f55_arg4 ~= nil then
            f55_local3 = f55_arg4[f55_local0]
        end
        f55_local1 = f55_local2[f55_local0](f55_arg0, f55_arg1, f55_arg2, f55_local3)
    end
    local f55_local2 = f55_arg1:GetRandam_Int(1, 100)
    if f55_local2 <= f55_local1 then
        if f55_arg0.ActAfter ~= nil then
            f55_arg0.ActAfter(f55_arg0, f55_arg1, f55_arg2, f55_arg5)
        else
            HumanCommon_ActAfter_AdjustSpace(f55_arg1, f55_arg2, f55_arg5)
        end
    end
    
end

function _GetGoalActFuncTable(f56_arg0)
    return {f56_arg0.Act01, f56_arg0.Act02, f56_arg0.Act03, f56_arg0.Act04, f56_arg0.Act05, f56_arg0.Act06, f56_arg0.Act07, f56_arg0.Act08, f56_arg0.Act09, f56_arg0.Act10, f56_arg0.Act11, f56_arg0.Act12, f56_arg0.Act13, f56_arg0.Act14, f56_arg0.Act15, f56_arg0.Act16, f56_arg0.Act17, f56_arg0.Act18, f56_arg0.Act19, f56_arg0.Act20}
    
end

function GetTargetAngle(f57_arg0, f57_arg1)
    if f57_arg0:IsInsideTarget(f57_arg1, AI_DIR_TYPE_F, 90) then
        if f57_arg0:IsInsideTarget(f57_arg1, AI_DIR_TYPE_F, 90) then
            return TARGET_ANGLE_FRONT
        elseif f57_arg0:IsInsideTarget(f57_arg1, AI_DIR_TYPE_L, 180) then
            return TARGET_ANGLE_LEFT
        else
            return TARGET_ANGLE_RIGHT
        end
    end
    if f57_arg0:IsInsideTarget(f57_arg1, AI_DIR_TYPE_L, 90) then
        return TARGET_ANGLE_LEFT
    elseif f57_arg0:IsInsideTarget(f57_arg1, AI_DIR_TYPE_R, 90) then
        return TARGET_ANGLE_RIGHT
    else
        return TARGET_ANGLE_BACK
    end
    
end


