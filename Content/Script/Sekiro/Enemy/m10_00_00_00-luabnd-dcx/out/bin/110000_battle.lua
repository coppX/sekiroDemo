RegisterTableGoal(GOAL_Yamori_110000_Battle, "GOAL_Yamori_110000_Battle")
REGISTER_GOAL_NO_UPDATE(GOAL_Yamori_110000_Battle, true)

Goal.Initialize = function (f1_arg0, f1_arg1, f1_arg2, f1_arg3)
    
end

Goal.Activate = function (f2_arg0, f2_arg1, f2_arg2)
    Init_Pseudo_Global(f2_arg1, f2_arg2)
    f2_arg1:SetStringIndexedNumber("Dist_Step_Small", 2)
    local f2_local0 = {}
    local f2_local1 = {}
    local f2_local2 = {}
    Common_Clear_Param(f2_local0, f2_local1, f2_local2)
    local f2_local3 = f2_arg1:GetHpRate(TARGET_SELF)
    local f2_local4 = f2_arg1:GetSp(TARGET_SELF)
    local f2_local5 = f2_arg1:GetDist(TARGET_ENE_0)
    local f2_local6 = f2_arg1:GetExcelParam(AI_EXCEL_THINK_PARAM_TYPE__thinkAttr_doAdmirer)
    local f2_local7 = f2_arg1:GetEventRequest()
    local f2_local8 = 300
    local f2_local9 = 4
    local f2_local10 = 60
    local f2_local11 = 6.8 - f2_arg1:GetMapHitRadius(TARGET_SELF)
    f2_arg1:AddObserveArea(0, TARGET_SELF, TARGET_ENE_0, AI_DIR_TYPE_B, f2_local8, f2_local9)
    f2_arg1:AddObserveArea(1, TARGET_SELF, TARGET_ENE_0, AI_DIR_TYPE_F, f2_local10, f2_local11)
    if f2_arg1:HasSpecialEffectId(TARGET_SELF, 200060) == true then
        f2_local0[8] = 999
    elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 5020) and f2_arg1:HasSpecialEffectId(TARGET_SELF, 5450) == true then
        f2_local0[26] = 100
    elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 5026) == true then
        f2_local0[1] = 100
    elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 5027) == true then
        f2_local0[2] = 100
    elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 5028) == true then
        f2_local0[3] = 100
    elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 220020) then
        if f2_arg1:GetNumber(0) == 0 then
            f2_local0[7] = 100
        else
            f2_local0[34] = 100
        end
    elseif f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 110060) then
        if f2_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) then
            f2_local0[26] = 100
        else
            f2_local0[21] = 100
        end
    elseif f2_arg1:CheckDoesExistPath(TARGET_ENE_0, AI_DIR_TYPE_F, 0, 0) == false then
        f2_local0[6] = 100
        f2_local0[26] = 100
    elseif f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 110030) then
        f2_local0[28] = 100
    elseif f2_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_B, 180) then
        if f2_local5 > 7 then
            f2_local0[21] = 100
        elseif f2_local5 > 5 then
            f2_local0[21] = 100
        else
            f2_local0[21] = 100
        end
    elseif f2_arg1:IsFinishTimer(0) == true then
        f2_local0[7] = 10000
        f2_local0[8] = 10
        f2_local0[33] = 50
    elseif f2_local5 >= 11 then
        f2_local0[6] = 20
        f2_local0[7] = 20
        f2_local0[33] = 50
    elseif f2_local5 >= 5 then
        f2_local0[6] = 20
        f2_local0[7] = 20
        f2_local0[33] = 100
    elseif f2_local5 > 3 then
        f2_local0[6] = 20
        f2_local0[7] = 20
        f2_local0[33] = 100
    else
        f2_local0[6] = 0
        f2_local0[7] = 20
        f2_local0[8] = 100
        f2_local0[33] = 100
    end
    if f2_arg1:HasSpecialEffectId(TARGET_SELF, 5022) then
        if f2_arg1:HasSpecialEffectId(TARGET_SELF, 220020) then
            f2_local0[7] = 100
        else
            f2_local0[7] = 0
            f2_local0[8] = 100
        end
    end
    if SpaceCheck(f2_arg1, f2_arg2, 45, f2_arg1:GetStringIndexedNumber("Dist_Step_Small")) == false and SpaceCheck(f2_arg1, f2_arg2, -45, f2_arg1:GetStringIndexedNumber("Dist_Step_Small")) == false then
        f2_local0[22] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 90, 1) == false and SpaceCheck(f2_arg1, f2_arg2, -90, 1) == false then
        f2_local0[23] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 180, f2_arg1:GetStringIndexedNumber("Dist_Step_Small")) == false then
        f2_local0[24] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 180, 1) == false then
        f2_local0[25] = 0
    end
    f2_local0[8] = SetCoolTime(f2_arg1, f2_arg2, 3021, 5, f2_local0[8], 1)
    f2_local1[1] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act01)
    f2_local1[2] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act02)
    f2_local1[3] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act03)
    f2_local1[6] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act06)
    f2_local1[7] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act07)
    f2_local1[8] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act08)
    f2_local1[21] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act21)
    f2_local1[22] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act22)
    f2_local1[26] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act26)
    f2_local1[27] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act27)
    f2_local1[28] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act28)
    f2_local1[31] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act31)
    f2_local1[32] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act32)
    f2_local1[33] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act33)
    f2_local1[34] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act34)
    local f2_local12 = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.ActAfter_AdjustSpace)
    Common_Battle_Activate(f2_arg1, f2_arg2, f2_local0, f2_local1, f2_local12, f2_local2)
    
end

Goal.Act01 = function (f3_arg0, f3_arg1, f3_arg2)
    local f3_local0 = f3_arg0:GetRandam_Float(0, 2)
    if f3_arg0:HasSpecialEffectId(TARGET_SELF, 5023) then
        f3_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 20, 20020, TARGET_ENE_0, 999, 0, 0, 0, 0)
    else
        f3_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 20, 20000, TARGET_ENE_0, 999, 0, 0, 0, 0)
    end
    f3_arg1:AddSubGoal(GOAL_COMMON_Wait, f3_local0, TARGET_SELF, 0, 0, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act02 = function (f4_arg0, f4_arg1, f4_arg2)
    local f4_local0 = f4_arg0:GetRandam_Float(0, 2)
    if f4_arg0:HasSpecialEffectId(TARGET_SELF, 5023) then
        f4_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 20, 20021, TARGET_ENE_0, 999, 0, 0, 0, 0)
    else
        f4_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 20, 20010, TARGET_ENE_0, 999, 0, 0, 0, 0)
    end
    f4_arg1:AddSubGoal(GOAL_COMMON_Wait, f4_local0, TARGET_SELF, 0, 0, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act03 = function (f5_arg0, f5_arg1, f5_arg2)
    local f5_local0 = f5_arg0:GetRandam_Float(0, 2)
    if f5_arg0:HasSpecialEffectId(TARGET_SELF, 5023) then
        f5_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 20, 20022, TARGET_ENE_0, 999, 0, 0, 0, 0)
    else
        f5_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 20, 20012, TARGET_ENE_0, 999, 0, 0, 0, 0)
    end
    f5_arg1:AddSubGoal(GOAL_COMMON_Wait, f5_local0, TARGET_SELF, 0, 0, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act06 = function (f6_arg0, f6_arg1, f6_arg2)
    local f6_local0 = 20 - f6_arg0:GetMapHitRadius(TARGET_SELF)
    local f6_local1 = 20 - f6_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f6_local2 = 20 - f6_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f6_local3 = 100
    local f6_local4 = 0
    local f6_local5 = 1.5
    local f6_local6 = 3
    Approach_Act_Flex(f6_arg0, f6_arg1, f6_local0, f6_local1, f6_local2, f6_local3, f6_local4, f6_local5, f6_local6)
    local f6_local7 = 3020
    local f6_local8 = 0
    local f6_local9 = 0
    local f6_local10 = f6_arg0:GetRandam_Int(1, 100)
    local f6_local11 = 360
    local f6_local12 = 2
    f6_arg0:AddObserveArea(0, TARGET_SELF, TARGET_ENE_0, AI_DIR_TYPE_B, f6_local11, f6_local12)
    f6_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f6_local7, TARGET_ENE_0, 9999, f6_local8, f6_local9, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act07 = function (f7_arg0, f7_arg1, f7_arg2)
    local f7_local0 = 6.8 - f7_arg0:GetMapHitRadius(TARGET_SELF)
    local f7_local1 = 6.8 - f7_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f7_local2 = 6.8 - f7_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f7_local3 = 100
    local f7_local4 = 0
    local f7_local5 = 1.5
    local f7_local6 = 3
    Approach_Act_Flex(f7_arg0, f7_arg1, f7_local0, f7_local1, f7_local2, f7_local3, f7_local4, f7_local5, f7_local6)
    local f7_local7 = 0
    local f7_local8 = 0
    local f7_local9 = f7_arg0:GetRandam_Int(1, 100)
    f7_arg0:DeleteObserve(0)
    f7_arg0:DeleteObserve(1)
    f7_arg1:AddSubGoal(GOAL_COMMON_Turn, 2, TARGET_ENE_0, 45, -1, GOAL_RESULT_Success, true)
    if f7_arg0:HasSpecialEffectId(TARGET_SELF, 5023) then
        f7_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3006, TARGET_ENE_0, 9999, f7_local7, f7_local8, 0, 0)
    else
        f7_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3005, TARGET_ENE_0, 9999, f7_local7, f7_local8, 0, 0)
    end
    f7_arg0:SetTimer(0, 5)
    if f7_arg0:HasSpecialEffectId(TARGET_SELF, 220020) then
        f7_arg0:SetNumber(0, 1)
    end
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act08 = function (f8_arg0, f8_arg1, f8_arg2)
    local f8_local0 = 2.5 - f8_arg0:GetMapHitRadius(TARGET_SELF)
    local f8_local1 = 2.5 - f8_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f8_local2 = 2.5 - f8_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f8_local3 = 100
    local f8_local4 = 0
    local f8_local5 = 1.5
    local f8_local6 = 3
    Approach_Act_Flex(f8_arg0, f8_arg1, f8_local0, f8_local1, f8_local2, f8_local3, f8_local4, f8_local5, f8_local6)
    local f8_local7 = 3021
    local f8_local8 = 0
    local f8_local9 = 0
    local f8_local10 = f8_arg0:GetRandam_Int(1, 100)
    f8_arg0:DeleteObserve(0)
    f8_arg0:DeleteObserve(1)
    f8_arg1:AddSubGoal(GOAL_COMMON_Turn, 2, TARGET_ENE_0, 45, -1, GOAL_RESULT_Success, true)
    f8_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f8_local7, TARGET_ENE_0, 9999, f8_local8, f8_local9, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act21 = function (f9_arg0, f9_arg1, f9_arg2)
    local f9_local0 = 3
    local f9_local1 = 45
    f9_arg0:DeleteObserve(1)
    f9_arg1:AddSubGoal(GOAL_COMMON_Turn, f9_local0, TARGET_ENE_0, f9_local1, -1, GOAL_RESULT_Success, false)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act26 = function (f10_arg0, f10_arg1, f10_arg2)
    local f10_local0 = f10_arg0:GetRandam_Float(5, 8)
    f10_arg1:AddSubGoal(GOAL_COMMON_Wait, f10_local0, TARGET_SELF, 0, 0, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act31 = function (f11_arg0, f11_arg1, f11_arg2)
    local f11_local0 = 0
    local f11_local1 = 0
    local f11_local2 = f11_arg0:GetRandam_Int(1, 100)
    local f11_local3 = f11_arg0:GetRandam_Int(1, 100)
    local f11_local4 = f11_arg0:GetRandam_Float(0.5, 1.5)
    local f11_local5 = f11_arg0:GetRandam_Float(0.5, 1.5)
    local f11_local6 = 3031
    local f11_local7 = 3032
    f11_arg0:DeleteObserve(1)
    if f11_local2 <= 50 then
        f11_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f11_local4, TARGET_ENE_0, 0, TARGET_SELF, false, -1, AI_DIR_TYPE_ToL, 10)
        if f11_local3 <= 33 then
            f11_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f11_local6, TARGET_ENE_0, 9999, f11_local0, f11_local1, 0, 0)
        elseif f11_local3 <= 66 then
            f11_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f11_local7, TARGET_ENE_0, 9999, f11_local0, f11_local1, 0, 0)
        else
            f11_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f11_local4, TARGET_ENE_0, 0, TARGET_SELF, false, -1, AI_DIR_TYPE_ToL, 10)
        end
        f11_arg1:AddSubGoal(GOAL_COMMON_Wait, f11_local5, TARGET_NONE, 0, 0, 0)
    else
        f11_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f11_local4, TARGET_ENE_0, 0, TARGET_SELF, false, -1, AI_DIR_TYPE_ToR, 10)
        if f11_local3 <= 50 then
            f11_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f11_local6, TARGET_ENE_0, 9999, f11_local0, f11_local1, 0, 0)
        else
            f11_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f11_local7, TARGET_ENE_0, 9999, f11_local0, f11_local1, 0, 0)
        end
        f11_arg1:AddSubGoal(GOAL_COMMON_Wait, f11_local5, TARGET_NONE, 0, 0, 0)
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act32 = function (f12_arg0, f12_arg1, f12_arg2)
    local f12_local0 = 4 - f12_arg0:GetMapHitRadius(TARGET_SELF)
    local f12_local1 = 4 - f12_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f12_local2 = 4 - f12_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f12_local3 = 100
    local f12_local4 = 0
    local f12_local5 = 1.5
    local f12_local6 = 3
    Approach_Act_Flex(f12_arg0, f12_arg1, f12_local0, f12_local1, f12_local2, f12_local3, f12_local4, f12_local5, f12_local6)
    local f12_local7 = 3031
    local f12_local8 = 3032
    local f12_local9 = 0
    local f12_local10 = 0
    local f12_local11 = f12_arg0:GetRandam_Int(1, 100)
    if f12_local11 <= 50 then
        f12_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f12_local7, TARGET_ENE_0, 9999, f12_local9, f12_local10, 0, 0)
    else
        f12_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f12_local8, TARGET_ENE_0, 9999, f12_local9, f12_local10, 0, 0)
    end
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act33 = function (f13_arg0, f13_arg1, f13_arg2)
    local f13_local0 = f13_arg0:GetDist(TARGET_ENE_0)
    local f13_local1 = 9999
    local f13_local2 = 0
    local f13_local3 = 0
    local f13_local4 = f13_arg0:GetRandam_Int(2, 5)
    local f13_local5 = f13_arg0:GetRandam_Int(1, 100)
    local f13_local6 = f13_arg0:GetRandam_Float(1.5, 2.5)
    local f13_local7 = f13_arg0:GetRandam_Float(1.5, 2)
    local f13_local8 = 3
    local f13_local9 = 3031
    local f13_local10 = 3032
    f13_arg0:DeleteObserve(1)
    if f13_local5 <= 50 then
        f13_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f13_local6, TARGET_ENE_0, 5, TARGET_SELF, false, -1, AI_DIR_TYPE_ToL, 10)
        f13_arg1:AddSubGoal(GOAL_COMMON_Wait, f13_local7, TARGET_NONE, 0, 0, 0)
    else
        f13_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f13_local6, TARGET_ENE_0, 5, TARGET_SELF, false, -1, AI_DIR_TYPE_ToR, 10)
        f13_arg1:AddSubGoal(GOAL_COMMON_Wait, f13_local7, TARGET_NONE, 0, 0, 0)
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act34 = function (f14_arg0, f14_arg1, f14_arg2)
    local f14_local0 = 4 - f14_arg0:GetMapHitRadius(TARGET_SELF)
    local f14_local1 = 4 - f14_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f14_local2 = 4 - f14_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f14_local3 = 100
    local f14_local4 = 0
    local f14_local5 = 1.5
    local f14_local6 = 3
    local f14_local7 = 3031
    local f14_local8 = 3032
    local f14_local9 = 3030
    local f14_local10 = 0
    local f14_local11 = 0
    local f14_local12 = f14_arg0:GetRandam_Int(1, 100)
    local f14_local13 = f14_arg0:GetRandam_Int(1, 100)
    if f14_local12 <= 33 then
        f14_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3031, TARGET_ENE_0, 9999, f14_local10, f14_local11, 0, 0)
    elseif f14_local12 <= 66 then
        f14_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3032, TARGET_ENE_0, 9999, f14_local10, f14_local11, 0, 0)
    else
        f14_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3030, TARGET_ENE_0, 9999, f14_local10, f14_local11, 0, 0)
    end
    if f14_arg0:HasSpecialEffectId(TARGET_SELF, 220020) then
        f14_arg0:SetNumber(0, 0)
    end
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Interrupt = function (f15_arg0, f15_arg1, f15_arg2)
    local f15_local0 = f15_arg1:GetHpRate(TARGET_SELF)
    local f15_local1 = f15_arg1:GetDist(TARGET_ENE_0)
    local f15_local2 = f15_arg1:GetSp(TARGET_SELF)
    local f15_local3 = f15_arg1:GetSpecialEffectActivateInterruptType(0)
    if f15_arg1:IsLadderAct(TARGET_SELF) then
        return false
    end
    if not f15_arg1:HasSpecialEffectId(TARGET_SELF, 200004) then
        return false
    end
    if f15_arg1:HasSpecialEffectId(TARGET_SELF, 5026) or f15_arg1:HasSpecialEffectId(TARGET_SELF, 5027) or f15_arg1:HasSpecialEffectId(TARGET_SELF, 5028) then
        return false
    end
    if f15_arg1:IsInterupt(INTERUPT_ActivateSpecialEffect) then
    end
    if f15_arg1:IsInterupt(INTERUPT_Inside_ObserveArea) then
        if f15_arg1:IsInsideObserve(0) then
            f15_arg2:ClearSubGoal()
            f15_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 1.5, 3030, TARGET_ENE_0, 9999, 0, 0)
            return true
        elseif f15_arg1:IsInsideObserve(1) then
            f15_arg2:ClearSubGoal()
            if f15_arg1:HasSpecialEffectId(TARGET_SELF, 5023) then
                f15_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 2.5, 3006, TARGET_ENE_0, 9999, 0, 0)
            else
                f15_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 2.5, 3005, TARGET_ENE_0, 9999, 0, 0)
            end
            return true
        end
    end
    return false
    
end

Goal.ActAfter_AdjustSpace = function (f16_arg0, f16_arg1, f16_arg2)
    
end

Goal.Update = function (f17_arg0, f17_arg1, f17_arg2)
    return Update_Default_NoSubGoal(f17_arg0, f17_arg1, f17_arg2)
    
end

Goal.Terminate = function (f18_arg0, f18_arg1, f18_arg2)
    
end


