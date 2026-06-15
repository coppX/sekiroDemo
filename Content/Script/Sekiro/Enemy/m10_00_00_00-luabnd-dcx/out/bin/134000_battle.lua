RegisterTableGoal(GOAL_SuichuKubinashi_134000_Battle, "GOAL_SuichuKubinashi_134000_Battle")
REGISTER_GOAL_NO_UPDATE(GOAL_SuichuKubinashi_134000_Battle, true)

Goal.Initialize = function (f1_arg0, f1_arg1, f1_arg2, f1_arg3)
    
end

Goal.Activate = function (f2_arg0, f2_arg1, f2_arg2)
    Init_Pseudo_Global(f2_arg1, f2_arg2)
    local f2_local0 = {}
    local f2_local1 = {}
    local f2_local2 = {}
    Common_Clear_Param(f2_local0, f2_local1, f2_local2)
    local f2_local3 = f2_arg1:GetDist(TARGET_ENE_0)
    local f2_local4 = f2_arg1:GetExcelParam(AI_EXCEL_THINK_PARAM_TYPE__thinkAttr_doAdmirer)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 3134000)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 5025)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 5029)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 5030)
    if f2_arg0.Kengeki_Activate(f2_arg0, f2_arg1, f2_arg2) then
        return
    end
    if f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 110060) then
        if f2_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) then
            f2_local0[26] = 100
        else
            f2_local0[21] = 100
        end
    elseif f2_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_B, 180) then
        f2_local0[21] = 100
        if f2_local3 <= 6 then
            f2_local0[5] = 100
            if f2_arg1:GetNumber(5) >= 1 then
                f2_local0[4] = 1000
            end
        end
    elseif f2_local3 > 8 then
        f2_local0[6] = 100
        f2_local0[7] = 100
    elseif f2_local3 >= 5 then
        f2_local0[4] = 100
        f2_local0[6] = 100
        f2_local0[7] = 100
    else
        f2_local0[5] = 100
        if f2_arg1:GetNumber(5) >= 1 then
            f2_local0[4] = 10000
        end
    end
    if SpaceCheck(f2_arg1, f2_arg2, 45, 2) == false and SpaceCheck(f2_arg1, f2_arg2, -45, 2) == false then
        f2_local0[22] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 90, 1) == false and SpaceCheck(f2_arg1, f2_arg2, -90, 1) == false then
        f2_local0[23] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 180, 2) == false then
        f2_local0[24] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 180, 1) == false then
        f2_local0[25] = 0
    end
    if f2_arg1:HasSpecialEffectId(TARGET_SELF, 5020) then
        f2_local0[6] = 100
    end
    f2_local0[1] = SetCoolTime(f2_arg1, f2_arg2, 3000, 15, f2_local0[1], 1)
    f2_local0[3] = SetCoolTime(f2_arg1, f2_arg2, 3004, 15, f2_local0[3], 1)
    f2_local0[4] = SetCoolTime(f2_arg1, f2_arg2, 3005, 8, f2_local0[4], 1)
    f2_local1[1] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act01)
    f2_local1[2] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act02)
    f2_local1[3] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act03)
    f2_local1[4] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act04)
    f2_local1[5] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act05)
    f2_local1[6] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act06)
    f2_local1[7] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act07)
    f2_local1[8] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act08)
    f2_local1[9] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act09)
    f2_local1[10] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act10)
    f2_local1[11] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act11)
    f2_local1[12] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act12)
    f2_local1[13] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act13)
    f2_local1[14] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act14)
    f2_local1[15] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act15)
    f2_local1[21] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act21)
    f2_local1[22] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act22)
    f2_local1[23] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act23)
    f2_local1[24] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act24)
    f2_local1[25] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act25)
    f2_local1[26] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act26)
    f2_local1[27] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act27)
    f2_local1[28] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act28)
    local f2_local5 = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.ActAfter_AdjustSpace)
    Common_Battle_Activate(f2_arg1, f2_arg2, f2_local0, f2_local1, f2_local5, f2_local2)
    
end

Goal.Act01 = function (f3_arg0, f3_arg1, f3_arg2)
    f3_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3000, TARGET_ENE_0, 9999, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act02 = function (f4_arg0, f4_arg1, f4_arg2)
    local f4_local0 = 5.9 - f4_arg0:GetMapHitRadius(TARGET_SELF)
    local f4_local1 = 5.9 - f4_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f4_local2 = 5.9 - f4_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f4_local3 = 100
    local f4_local4 = 0
    local f4_local5 = 1.5
    local f4_local6 = 3
    Approach_Act_Flex(f4_arg0, f4_arg1, f4_local0, f4_local1, f4_local2, f4_local3, f4_local4, f4_local5, f4_local6)
    local f4_local7 = 0
    local f4_local8 = 0
    f4_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3001, TARGET_ENE_0, 9999, f4_local7, f4_local8, 0, 0):TimingSetNumber(5, f4_arg0:GetNumber(5) + 7, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act03 = function (f5_arg0, f5_arg1, f5_arg2)
    local f5_local0 = 4.6 - f5_arg0:GetMapHitRadius(TARGET_SELF)
    local f5_local1 = 4.6 - f5_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f5_local2 = 4.6 - f5_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f5_local3 = 100
    local f5_local4 = 0
    local f5_local5 = 1.5
    local f5_local6 = 3
    local f5_local7 = 0
    local f5_local8 = 0
    f5_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3002, TARGET_ENE_0, 9999, f5_local7, f5_local8, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act04 = function (f6_arg0, f6_arg1, f6_arg2)
    local f6_local0 = 0
    local f6_local1 = 0
    f6_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3015, TARGET_ENE_0, 9999, f6_local0, f6_local1, 0, 0):TimingSetNumber(5, 0, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act05 = function (f7_arg0, f7_arg1, f7_arg2)
    local f7_local0 = 0
    local f7_local1 = 0
    f7_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3016, TARGET_ENE_0, 9999, f7_local0, f7_local1, 0, 0):TimingSetNumber(5, f7_arg0:GetNumber(5) + 7, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act06 = function (f8_arg0, f8_arg1, f8_arg2)
    local f8_local0 = 0
    local f8_local1 = 0
    local f8_local2 = f8_arg0:GetRandam_Int(1, 100)
    if f8_local2 <= 50 and f8_arg0:HasSpecialEffectId(TARGET_SELF, 5021) then
        f8_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3020, TARGET_ENE_0, 9999, f8_local0, f8_local1, 0, 0)
        f8_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3006, TARGET_ENE_0, 9999, 0, 0)
    else
        f8_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3022, TARGET_ENE_0, 9999, f8_local0, f8_local1, 0, 0)
    end
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act07 = function (f9_arg0, f9_arg1, f9_arg2)
    local f9_local0 = 0
    local f9_local1 = 0
    f9_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3021, TARGET_ENE_0, 9999, f9_local0, f9_local1, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act08 = function (f10_arg0, f10_arg1, f10_arg2)
    local f10_local0 = 0
    local f10_local1 = 0
    f10_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3019, TARGET_ENE_0, 9999, f10_local0, f10_local1, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act10 = function (f11_arg0, f11_arg1, f11_arg2)
    local f11_local0 = 0
    local f11_local1 = 0
    f11_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3004, TARGET_ENE_0, 9999, f11_local0, f11_local1, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act21 = function (f12_arg0, f12_arg1, f12_arg2)
    local f12_local0 = 3
    local f12_local1 = 45
    f12_arg1:AddSubGoal(GOAL_COMMON_Turn, f12_local0, TARGET_ENE_0, f12_local1, -1, GOAL_RESULT_Success, true)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act22 = function (f13_arg0, f13_arg1, f13_arg2)
    local f13_local0 = 3
    local f13_local1 = 0
    local f13_local2 = 5202
    if SpaceCheck(f13_arg0, f13_arg1, -45, 2) == true then
        if SpaceCheck(f13_arg0, f13_arg1, 45, 2) == true then
            if f13_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                f13_local2 = 5202
            else
                f13_local2 = 5203
            end
        else
            f13_local2 = 5202
        end
    elseif SpaceCheck(f13_arg0, f13_arg1, 45, 2) == true then
        f13_local2 = 5203
    else
    end
    f13_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f13_local0, f13_local2, TARGET_ENE_0, f13_local1, AI_DIR_TYPE_R, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act23 = function (f14_arg0, f14_arg1, f14_arg2)
    local f14_local0 = f14_arg0:GetDist(TARGET_ENE_0)
    local f14_local1 = f14_arg0:GetSp(TARGET_SELF)
    local f14_local2 = 20
    local f14_local3 = f14_arg0:GetRandam_Int(1, 100)
    local f14_local4 = -1
    local f14_local5 = 0
    if SpaceCheck(f14_arg0, f14_arg1, -90, 1) == true then
        if SpaceCheck(f14_arg0, f14_arg1, 90, 1) == true then
            if f14_arg0:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_R, 180, 999) then
                f14_local5 = 1
            else
                f14_local5 = 0
            end
        else
            f14_local5 = 0
        end
    elseif SpaceCheck(f14_arg0, f14_arg1, 90, 1) == true then
        f14_local5 = 1
    else
    end
    local f14_local6 = 3
    local f14_local7 = f14_arg0:GetRandam_Int(30, 45)
    f14_arg0:SetNumber(10, f14_local5)
    f14_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f14_local6, TARGET_ENE_0, f14_local5, f14_local7, true, true, f14_local4)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act24 = function (f15_arg0, f15_arg1, f15_arg2)
    local f15_local0 = f15_arg0:GetDist(TARGET_ENE_0)
    local f15_local1 = 3
    local f15_local2 = 0
    local f15_local3 = 5201
    if SpaceCheck(f15_arg0, f15_arg1, 180, 2) ~= true or SpaceCheck(f15_arg0, f15_arg1, 180, 4) ~= true or f15_local0 > 4 then
    else
        f15_local3 = 5211
        if false then
        else
        end
    end
    f15_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f15_local1, f15_local3, TARGET_ENE_0, f15_local2, AI_DIR_TYPE_B, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act25 = function (f16_arg0, f16_arg1, f16_arg2)
    local f16_local0 = f16_arg0:GetRandam_Float(2, 4)
    local f16_local1 = f16_arg0:GetRandam_Float(5, 7)
    local f16_local2 = f16_arg0:GetDist(TARGET_ENE_0)
    local f16_local3 = -1
    f16_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, f16_local0, TARGET_ENE_0, f16_local1, TARGET_ENE_0, true, f16_local3)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act26 = function (f17_arg0, f17_arg1, f17_arg2)
    f17_arg1:AddSubGoal(GOAL_COMMON_Wait, 0.5, TARGET_SELF, 0, 0, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act27 = function (f18_arg0, f18_arg1, f18_arg2)
    local f18_local0 = f18_arg0:GetDist(TARGET_ENE_0)
    local f18_local1 = f18_arg0:GetDistYSigned(TARGET_ENE_0)
    local f18_local2 = f18_local1 / math.tan(math.deg(30))
    local f18_local3 = f18_arg0:GetRandam_Int(0, 1)
    if f18_local1 >= 3 then
        if f18_local2 + 1 <= f18_local0 then
            if SpaceCheck(f18_arg0, f18_arg1, 0, 4) == true then
                f18_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.1, TARGET_ENE_0, f18_local2, TARGET_SELF, false, -1)
            elseif SpaceCheck(f18_arg0, f18_arg1, 0, 3) == true then
                f18_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.5, TARGET_ENE_0, f18_local2, TARGET_SELF, true, -1)
            end
        elseif f18_local0 <= f18_local2 - 1 then
            f18_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 10, TARGET_ENE_0, f18_local2, TARGET_ENE_0, true, -1)
        else
            f18_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, 3, TARGET_ENE_0, f18_local3, f18_arg0:GetRandam_Int(30, 45), true, true, -1)
            f18_arg0:SetNumber(10, f18_local3)
        end
    elseif SpaceCheck(f18_arg0, f18_arg1, 0, 4) == true then
        f18_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.1, TARGET_ENE_0, 0, TARGET_SELF, false, -1)
    elseif SpaceCheck(f18_arg0, f18_arg1, 0, 3) == true then
        f18_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.5, TARGET_ENE_0, 0, TARGET_SELF, true, -1)
    elseif SpaceCheck(f18_arg0, f18_arg1, 0, 1) == false then
        f18_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 0.5, TARGET_ENE_0, 999, TARGET_ENE_0, true, -1)
    else
        f18_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, 3, TARGET_ENE_0, f18_local3, f18_arg0:GetRandam_Int(30, 45), true, true, -1)
        f18_arg0:SetNumber(10, f18_local3)
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act28 = function (f19_arg0, f19_arg1, f19_arg2)
    local f19_local0 = f19_arg0:GetDist(TARGET_ENE_0)
    local f19_local1 = 1.5
    local f19_local2 = 1.5
    local f19_local3 = f19_arg0:GetRandam_Int(30, 45)
    local f19_local4 = -1
    local f19_local5 = f19_arg0:GetRandam_Int(0, 1)
    if f19_local0 <= 3 then
        f19_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f19_local1, TARGET_ENE_0, f19_local5, f19_local3, true, true, f19_local4)
    elseif f19_local0 <= 8 then
        f19_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, f19_local2, TARGET_ENE_0, 3, TARGET_SELF, true, -1)
    else
        f19_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, f19_local2, TARGET_ENE_0, 8, TARGET_SELF, false, -1)
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Interrupt = function (f20_arg0, f20_arg1, f20_arg2)
    local f20_local0 = f20_arg1:GetSpecialEffectActivateInterruptType(0)
    local f20_local1 = f20_arg1:GetDist(TARGET_ENE_0)
    local f20_local2 = f20_arg1:GetRandam_Int(1, 100)
    if f20_arg1:IsLadderAct(TARGET_SELF) then
        return false
    end
    if not f20_arg1:HasSpecialEffectId(TARGET_SELF, 200004) then
        return false
    end
    if f20_local0 == 3134000 then
        f20_arg2:ClearSubGoal()
        f20_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 10, 3015, TARGET_ENE_0, 9999, 0, 0)
        return true
    elseif f20_local0 == 5025 then
        if f20_local1 >= 6 then
            if f20_local2 <= 50 then
                f20_arg2:ClearSubGoal()
                f20_arg2:AddSubGoal(GOAL_COMMON_ComboFinal, 3, 3020, TARGET_ENE_0, 999, 0, 0, 0, 0)
            elseif f20_local2 <= 75 then
                f20_arg2:ClearSubGoal()
                f20_arg2:AddSubGoal(GOAL_COMMON_ComboFinal, 3, 3021, TARGET_ENE_0, 999, 0, 0, 0, 0)
                if false then
                end
            end
        end
    elseif f20_local0 == 5030 and f20_local1 >= 15 == true then
        if f20_local2 <= 50 then
            f20_arg2:ClearSubGoal()
            f20_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 10, 3021, TARGET_ENE_0, 999, 0, 0, 0, 0)
        else
            f20_arg2:ClearSubGoal()
            f20_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 10, 3020, TARGET_ENE_0, 999, 0, 0, 0, 0)
        end
    end
    return false
    
end

Goal.Parry = function (f21_arg0, f21_arg1, f21_arg2)
    local f21_local0 = f21_arg0:GetHpRate(TARGET_SELF)
    local f21_local1 = f21_arg0:GetDist(TARGET_ENE_0)
    local f21_local2 = f21_arg0:GetSp(TARGET_SELF)
    local f21_local3 = f21_arg0:GetRandam_Int(1, 100)
    local f21_local4 = 0
    if not f21_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) or not f21_arg0:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_F, 90, 3) or f21_arg0:HasSpecialEffectId(TARGET_ENE_0, 109012) then
    elseif f21_arg0:IsTargetGuard(TARGET_SELF) then
        if f21_arg0:HasSpecialEffectId(TARGET_ENE_0, 109970) then
        else
            f21_arg1:ClearSubGoal()
            f21_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3100, TARGET_ENE_0, 9999, 0)
            return true
        end
    elseif f21_arg0:HasSpecialEffectId(TARGET_ENE_0, 109970) then
        f21_arg1:ClearSubGoal()
        f21_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3101, TARGET_ENE_0, 9999, 0)
        return true
    else
        f21_arg1:ClearSubGoal()
        f21_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3100, TARGET_ENE_0, 9999, 0)
        return true
    end
    return false
    
end

Goal.Damaged = function (f22_arg0, f22_arg1, f22_arg2)
    local f22_local0 = 3
    if SpaceCheck(f22_arg0, f22_arg1, 180, 2) then
        f22_arg1:ClearSubGoal()
        f22_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f22_local0, 5201, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0)
        return true
    end
    return false
    
end

Goal.Kengeki_Activate = function (f23_arg0, f23_arg1, f23_arg2, f23_arg3)
    local f23_local0 = ReturnKengekiSpecialEffect(f23_arg1)
    if f23_local0 == 0 then
        return false
    end
    local f23_local1 = {}
    local f23_local2 = {}
    local f23_local3 = {}
    Common_Clear_Param(f23_local1, f23_local2, f23_local3)
    local f23_local4 = f23_arg1:GetDist(TARGET_ENE_0)
    local f23_local5 = f23_arg1:GetSp(TARGET_SELF)
    if f23_local5 <= 0 then
        f23_local1[50] = 100
    elseif f23_local0 == 200200 then
        if f23_local4 >= 2 then
            f23_local1[50] = 100
        elseif f23_local4 <= 0.2 then
            f23_local1[50] = 100
        else
            f23_local1[3] = 100
        end
    elseif f23_local0 == 200201 then
        if f23_local4 >= 2 then
            f23_local1[50] = 100
        elseif f23_local4 <= 0.2 then
            f23_local1[50] = 100
        else
            f23_local1[4] = 100
        end
    elseif f23_local0 == 200205 then
        if f23_local4 >= 2 then
            f23_local1[50] = 100
        elseif f23_local4 <= 0.2 then
            f23_local1[50] = 100
        else
            f23_local1[1] = 100
        end
    elseif f23_local0 == 200206 then
        if f23_local4 >= 2 then
            f23_local1[50] = 100
        elseif f23_local4 <= 0.2 then
            f23_local1[50] = 100
        else
            f23_local1[2] = 100
        end
    elseif f23_local0 == 200210 then
        if f23_local4 >= 2 then
            f23_local1[50] = 100
        elseif f23_local4 <= 0.2 then
            f23_local1[50] = 100
        else
            f23_local1[7] = 100
        end
    elseif f23_local0 == 200211 then
        if f23_local4 >= 2 then
            f23_local1[50] = 100
        elseif f23_local4 <= 0.2 then
            f23_local1[50] = 100
        else
            f23_local1[8] = 100
        end
    elseif f23_local0 == 200215 then
        if f23_local4 >= 2 then
            f23_local1[50] = 100
        elseif f23_local4 <= 0.2 then
            f23_local1[50] = 100
        else
            f23_local1[5] = 100
        end
    elseif f23_local0 == 200216 then
        if f23_local4 >= 2 then
            f23_local1[50] = 100
        elseif f23_local4 <= 0.2 then
            f23_local1[50] = 100
        else
            f23_local1[6] = 100
        end
    else
        f23_local1[50] = 100
    end
    f23_local2[1] = REGIST_FUNC(f23_arg1, f23_arg2, f23_arg0.Kengeki01)
    f23_local2[2] = REGIST_FUNC(f23_arg1, f23_arg2, f23_arg0.Kengeki02)
    f23_local2[3] = REGIST_FUNC(f23_arg1, f23_arg2, f23_arg0.Kengeki03)
    f23_local2[4] = REGIST_FUNC(f23_arg1, f23_arg2, f23_arg0.Kengeki04)
    f23_local2[5] = REGIST_FUNC(f23_arg1, f23_arg2, f23_arg0.Kengeki05)
    f23_local2[6] = REGIST_FUNC(f23_arg1, f23_arg2, f23_arg0.Kengeki06)
    f23_local2[7] = REGIST_FUNC(f23_arg1, f23_arg2, f23_arg0.Kengeki07)
    f23_local2[8] = REGIST_FUNC(f23_arg1, f23_arg2, f23_arg0.Kengeki08)
    f23_local2[50] = REGIST_FUNC(f23_arg1, f23_arg2, f23_arg0.NoAction)
    local f23_local6 = REGIST_FUNC(f23_arg1, f23_arg2, f23_arg0.ActAfter_AdjustSpace)
    Common_Kengeki_Activate(f23_arg1, f23_arg2, f23_local1, f23_local2, f23_local6, f23_local3)
    
end

Goal.Kengeki01 = function (f24_arg0, f24_arg1, f24_arg2)
    f24_arg1:ClearSubGoal()
    f24_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3050, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.Kengeki02 = function (f25_arg0, f25_arg1, f25_arg2)
    f25_arg1:ClearSubGoal()
    f25_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3055, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.Kengeki03 = function (f26_arg0, f26_arg1, f26_arg2)
    f26_arg1:ClearSubGoal()
    f26_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3060, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.Kengeki04 = function (f27_arg0, f27_arg1, f27_arg2)
    f27_arg1:ClearSubGoal()
    f27_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3065, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.Kengeki05 = function (f28_arg0, f28_arg1, f28_arg2)
    f28_arg1:ClearSubGoal()
    f28_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3070, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.Kengeki06 = function (f29_arg0, f29_arg1, f29_arg2)
    f29_arg1:ClearSubGoal()
    f29_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3075, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.Kengeki07 = function (f30_arg0, f30_arg1, f30_arg2)
    f30_arg1:ClearSubGoal()
    f30_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3085, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.Kengeki08 = function (f31_arg0, f31_arg1, f31_arg2)
    f31_arg1:ClearSubGoal()
    f31_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3085, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.NoAction = function (f32_arg0, f32_arg1, f32_arg2)
    return -1
    
end

Goal.ActAfter_AdjustSpace = function (f33_arg0, f33_arg1, f33_arg2)
    
end

Goal.Update = function (f34_arg0, f34_arg1, f34_arg2)
    return Update_Default_NoSubGoal(f34_arg0, f34_arg1, f34_arg2)
    
end

Goal.Terminate = function (f35_arg0, f35_arg1, f35_arg2)
    
end


