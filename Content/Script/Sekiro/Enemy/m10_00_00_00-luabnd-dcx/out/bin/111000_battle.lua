RegisterTableGoal(GOAL_JijoOba_111000_Battle, "GOAL_JijoOba_111000_Battle")
REGISTER_GOAL_NO_UPDATE(GOAL_JijoOba_111000_Battle, true)

Goal.Initialize = function (f1_arg0, f1_arg1, f1_arg2, f1_arg3)
    
end

Goal.Activate = function (f2_arg0, f2_arg1, f2_arg2)
    Init_Pseudo_Global(f2_arg1, f2_arg2)
    local f2_local0 = {}
    local f2_local1 = {}
    local f2_local2 = {}
    Common_Clear_Param(f2_local0, f2_local1, f2_local2)
    f2_arg1:DeleteObserveSpecialEffectAttribute(TARGET_SELF, 5025)
    f2_arg1:DeleteObserveSpecialEffectAttribute(TARGET_SELF, 5026)
    f2_arg1:DeleteObserveSpecialEffectAttribute(TARGET_SELF, 5027)
    f2_arg1:DeleteObserveSpecialEffectAttribute(TARGET_SELF, 5028)
    local f2_local3 = f2_arg1:GetSp(TARGET_SELF)
    local f2_local4 = f2_arg1:GetDist(TARGET_ENE_0)
    local f2_local5 = f2_arg1:GetRandam_Int(1, 100)
    local f2_local6 = f2_arg1:GetExcelParam(AI_EXCEL_THINK_PARAM_TYPE__thinkAttr_doAdmirer)
    local f2_local7 = f2_arg1:GetEventRequest(0)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 109031)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 110030)
    if f2_local7 == 10 then
        f2_local0[10] = 100
    elseif f2_local7 == 11 then
        f2_arg2:ClearSubGoal()
        f2_arg2:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 20002, TARGET_ENE_0, 9999, TurnTime, FrontAngle, 0, 0)
        return true
    elseif f2_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_B, 180) then
        f2_local0[21] = 100
    else
        f2_local0[1] = 100
    end
    f2_local1[1] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act01)
    f2_local1[2] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act02)
    f2_local1[3] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act03)
    f2_local1[4] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act04)
    f2_local1[5] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act05)
    f2_local1[6] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act06)
    f2_local1[7] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act07)
    f2_local1[10] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act10)
    f2_local1[21] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act21)
    f2_local1[22] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act22)
    f2_local1[23] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act23)
    f2_local1[24] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act24)
    f2_local1[25] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act25)
    f2_local1[26] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act26)
    f2_local1[27] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act27)
    f2_local1[28] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act28)
    f2_local1[29] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act29)
    f2_local1[31] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act31)
    local f2_local8 = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.ActAfter_AdjustSpace)
    Common_Battle_Activate(f2_arg1, f2_arg2, f2_local0, f2_local1, f2_local8, f2_local2)
    
end

Goal.Act01 = function (f3_arg0, f3_arg1, f3_arg2)
    local f3_local0 = f3_arg0:GetDist(TARGET_ENE_0)
    local f3_local1 = 3000
    local f3_local2 = 999 - f3_arg0:GetMapHitRadius(TARGET_SELF)
    local f3_local3 = 0
    local f3_local4 = 0
    f3_arg0:AddObserveSpecialEffectAttribute(TARGET_SELF, 5025)
    f3_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, f3_local1, TARGET_ENE_0, f3_local2, f3_local3, f3_local4, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act02 = function (f4_arg0, f4_arg1, f4_arg2)
    local f4_local0 = f4_arg0:GetDist(TARGET_ENE_0)
    local f4_local1 = 3002
    local f4_local2 = 999
    local f4_local3 = 999 - f4_arg0:GetMapHitRadius(TARGET_SELF)
    local f4_local4 = 0
    local f4_local5 = 0
    local f4_local6 = f4_arg0:GetRandam_Int(1, 100)
    f4_arg0:AddObserveSpecialEffectAttribute(TARGET_SELF, 5026)
    f4_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, f4_local1, TARGET_SELF, f4_local3, f4_local4, f4_local5, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act03 = function (f5_arg0, f5_arg1, f5_arg2)
    local f5_local0 = f5_arg0:GetDist(TARGET_ENE_0)
    local f5_local1 = 3001
    local f5_local2 = 999
    local f5_local3 = 999 - f5_arg0:GetMapHitRadius(TARGET_SELF)
    local f5_local4 = 0
    local f5_local5 = 0
    local f5_local6 = f5_arg0:GetRandam_Int(1, 100)
    f5_arg0:AddObserveSpecialEffectAttribute(TARGET_SELF, 5027)
    f5_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, f5_local1, TARGET_ENE_0, f5_local3, f5_local4, f5_local5, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act04 = function (f6_arg0, f6_arg1, f6_arg2)
    local f6_local0 = 3
    local f6_local1 = 45
    f6_arg1:AddSubGoal(GOAL_COMMON_Guard, 999, 9910, TARGET_SELF, false, 0)
    f6_arg0:SetNumber(0, 1)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act05 = function (f7_arg0, f7_arg1, f7_arg2)
    local f7_local0 = f7_arg0:GetDist(TARGET_ENE_0)
    local f7_local1 = 3003
    local f7_local2 = 999
    local f7_local3 = 999 - f7_arg0:GetMapHitRadius(TARGET_SELF)
    local f7_local4 = 0
    local f7_local5 = 0
    local f7_local6 = f7_arg0:GetRandam_Int(1, 100)
    f7_arg0:AddObserveSpecialEffectAttribute(TARGET_SELF, 5028)
    f7_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, f7_local1, TARGET_ENE_0, f7_local3, f7_local4, f7_local5, 0, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act06 = function (f8_arg0, f8_arg1, f8_arg2)
    local f8_local0 = f8_arg0:GetDist(TARGET_ENE_0)
    local f8_local1 = 3002
    local f8_local2 = 999
    local f8_local3 = 999 - f8_arg0:GetMapHitRadius(TARGET_SELF)
    local f8_local4 = 0
    local f8_local5 = 0
    local f8_local6 = f8_arg0:GetRandam_Int(1, 100)
    f8_arg0:AddObserveSpecialEffectAttribute(TARGET_SELF, 5026)
    f8_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, f8_local1, TARGET_SELF, f8_local3, f8_local4, f8_local5, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act07 = function (f9_arg0, f9_arg1, f9_arg2)
    local f9_local0 = f9_arg0:GetDist(TARGET_ENE_0)
    local f9_local1 = 3001
    local f9_local2 = 999
    local f9_local3 = 999 - f9_arg0:GetMapHitRadius(TARGET_SELF)
    local f9_local4 = 0
    local f9_local5 = 0
    local f9_local6 = f9_arg0:GetRandam_Int(1, 100)
    f9_arg0:AddObserveSpecialEffectAttribute(TARGET_SELF, 5027)
    f9_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, f9_local1, TARGET_ENE_0, f9_local3, f9_local4, f9_local5, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act10 = function (f10_arg0, f10_arg1, f10_arg2)
    local f10_local0 = f10_arg0:GetDist_Point(POINT_EVENT)
    local f10_local1 = 3000
    local f10_local2 = 0
    local f10_local3 = 0
    if f10_local0 > 5 then
        f10_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 10, POINT_EVENT, 0, TARGET_SELF, false, -1)
    else
        f10_arg1:AddSubGoal(GOAL_COMMON_Guard, 10, 9910, TARGET_SELF, false, 0)
    end
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act21 = function (f11_arg0, f11_arg1, f11_arg2)
    local f11_local0 = 3
    local f11_local1 = 45
    f11_arg1:AddSubGoal(GOAL_COMMON_Turn, f11_local0, TARGET_ENE_0, f11_local1, -1, GOAL_RESULT_Success, true)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act22 = function (f12_arg0, f12_arg1, f12_arg2)
    local f12_local0 = 3
    local f12_local1 = 0
    local f12_local2 = 3
    if InsideRange(f12_arg0, f12_arg1, 90, 180, -9999, 9999) then
        f12_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f12_local0, 5202, TARGET_ENE_0, f12_local1, AI_DIR_TYPE_L, f12_local2)
    elseif InsideRange(f12_arg0, f12_arg1, -90, 180, -9999, 9999) then
        f12_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f12_local0, 5203, TARGET_ENE_0, f12_local1, AI_DIR_TYPE_R, f12_local2)
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act23 = function (f13_arg0, f13_arg1, f13_arg2)
    local f13_local0 = f13_arg0:GetRandam_Float(3, 5)
    local f13_local1 = f13_arg0:GetRandam_Int(30, 45)
    if InsideRange(f13_arg0, f13_arg1, 90, 180, -9999, 9999) then
        f13_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f13_local0, TARGET_ENE_0, 0, f13_local1, true, true, -1)
    elseif InsideRange(f13_arg0, f13_arg1, -90, 180, -9999, 9999) then
        f13_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f13_local0, TARGET_ENE_0, 1, f13_local1, true, true, -1)
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act24 = function (f14_arg0, f14_arg1, f14_arg2)
    local f14_local0 = 3
    local f14_local1 = 0
    local f14_local2 = 3
    f14_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f14_local0, 5201, TARGET_ENE_0, f14_local1, AI_DIR_TYPE_B, f14_local2)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act25 = function (f15_arg0, f15_arg1, f15_arg2)
    local f15_local0 = f15_arg0:GetRandam_Float(3, 5)
    local f15_local1 = 5
    f15_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, f15_local0, TARGET_ENE_0, f15_local1, TARGET_ENE_0, true, -1)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act26 = function (f16_arg0, f16_arg1, f16_arg2)
    f16_arg1:AddSubGoal(GOAL_COMMON_Wait, 0.5, TARGET_SELF, 0, 0, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act27 = function (f17_arg0, f17_arg1, f17_arg2)
    local f17_local0 = f17_arg0:GetDist(TARGET_ENE_0)
    local f17_local1 = f17_arg0:GetDistYSigned(TARGET_ENE_0)
    local f17_local2 = f17_local1 / math.tan(math.deg(30))
    local f17_local3 = f17_arg0:GetRandam_Int(0, 1)
    f17_arg0:SetNumber(10, f17_local3)
    if f17_local1 >= 3 then
        if f17_local2 + 1 <= f17_local0 then
            if SpaceCheck(f17_arg0, f17_arg1, 0, 4) == true then
                f17_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.1, TARGET_ENE_0, f17_local2, TARGET_SELF, false, -1)
            elseif SpaceCheck(f17_arg0, f17_arg1, 0, 3) == true then
                f17_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.5, TARGET_ENE_0, f17_local2, TARGET_SELF, true, -1)
            end
        elseif f17_local0 <= f17_local2 - 1 then
            f17_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 10, TARGET_ENE_0, f17_local2, TARGET_ENE_0, true, -1):SetTargetRange(0, -99, 12)
        end
    elseif SpaceCheck(f17_arg0, f17_arg1, 0, 4) == true then
        f17_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.1, TARGET_ENE_0, 0, TARGET_SELF, false, -1)
    elseif SpaceCheck(f17_arg0, f17_arg1, 0, 3) == true then
        f17_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.5, TARGET_ENE_0, 0, TARGET_SELF, true, -1)
    elseif SpaceCheck(f17_arg0, f17_arg1, 0, 1) == false then
        f17_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 0.5, TARGET_ENE_0, 999, TARGET_ENE_0, true, -1):SetTargetRange(0, -99, 12)
    end
    f17_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, 3, TARGET_ENE_0, f17_local3, f17_arg0:GetRandam_Int(30, 45), true, true, -1):SetTargetRange(0, -99, 12)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act28 = function (f18_arg0, f18_arg1, f18_arg2)
    local f18_local0 = f18_arg0:GetDist(TARGET_ENE_0)
    local f18_local1 = 1.5
    local f18_local2 = 1.5
    local f18_local3 = f18_arg0:GetRandam_Int(30, 45)
    local f18_local4 = -1
    local f18_local5 = f18_arg0:GetRandam_Int(0, 1)
    if SpaceCheck(f18_arg0, f18_arg1, 180, 1) == true then
        f18_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, f18_local2, TARGET_ENE_0, 6, TARGET_ENE_0, true, f18_local4)
    else
        f18_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f18_local1, TARGET_ENE_0, f18_local5, f18_local3, true, true, f18_local4)
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act29 = function (f19_arg0, f19_arg1, f19_arg2)
    local f19_local0 = f19_arg0:GetDist(TARGET_ENE_0)
    local f19_local1 = 10
    local f19_local2 = 100
    local f19_local3 = 0
    local f19_local4 = 1.5
    local f19_local5 = 3
    f19_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, f19_local5, TARGET_ENE_0, f19_local1, TARGET_SELF, false, Guard)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act31 = function (f20_arg0, f20_arg1, f20_arg2)
    local f20_local0 = f20_arg0:GetRandam_Float(3, 4)
    local f20_local1 = 10
    local f20_local2 = f20_arg0:GetDist(TARGET_ENE_0)
    local f20_local3 = -1
    local f20_local4 = f20_arg0:GetRandam_Int(1, 100)
    f20_arg0:SetNumber(10, 1)
    local f20_local5 = 0
    if SpaceCheck(f20_arg0, f20_arg1, -90, 1) == true then
        if SpaceCheck(f20_arg0, f20_arg1, 90, 1) == true then
            if f20_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                f20_local5 = 0
            else
                f20_local5 = 1
            end
        else
            f20_local5 = 0
        end
    elseif SpaceCheck(f20_arg0, f20_arg1, 90, 1) == true then
        f20_local5 = 1
    else
    end
    local f20_local6 = f20_arg0:GetRandam_Int(30, 45)
    f20_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f20_local0, TARGET_ENE_0, f20_local5, f20_local6, true, true, f20_local3)
    f20_arg0:SetTimer(2, 8)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Interrupt = function (f21_arg0, f21_arg1, f21_arg2)
    local f21_local0 = f21_arg1:GetDist(TARGET_ENE_0)
    local f21_local1 = f21_arg1:GetSp(TARGET_SELF)
    local f21_local2 = f21_arg1:GetRandam_Int(1, 100)
    local f21_local3 = 0
    local f21_local4 = f21_arg1:GetSpecialEffectActivateInterruptType(0)
    local f21_local5 = 90
    local f21_local6 = 999 - f21_arg1:GetMapHitRadius(TARGET_SELF)
    if f21_arg1:IsLadderAct(TARGET_SELF) then
        return false
    end
    if not f21_arg1:HasSpecialEffectId(TARGET_SELF, 200004) then
        return false
    end
    if f21_arg1:IsInterupt(INTERUPT_Inside_ObserveArea) then
        f21_arg2:ClearSubGoal()
        f21_arg0.Act06(f21_arg1, f21_arg2, paramTbl)
        f21_arg1:DeleteObserve(1)
        return true
    end
    if f21_arg1:GetSpecialEffectActivateInterruptType(0) == 5025 then
        if f21_local0 <= 10 then
            f21_arg2:ClearSubGoal()
            f21_arg0.Act06(f21_arg1, f21_arg2, paramTbl)
        elseif f21_local0 <= 25 then
            f21_arg2:ClearSubGoal()
            f21_arg0.Act07(f21_arg1, f21_arg2, paramTbl)
            if false then
            else
            end
        end
    end
    if f21_arg1:GetSpecialEffectActivateInterruptType(0) == 5026 then
        if f21_local0 >= 15 and f21_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_B, 180) then
            if f21_local2 >= 10 then
                f21_arg2:ClearSubGoal()
                f21_arg0.Act05(f21_arg1, f21_arg2, paramTbl)
                if false then
                end
            end
        else
            f21_arg2:ClearSubGoal()
            f21_arg0.Act05(f21_arg1, f21_arg2, paramTbl)
        end
    else
    end
    if f21_arg1:GetSpecialEffectActivateInterruptType(0) == 5027 and f21_local0 <= 8 then
        f21_arg2:ClearSubGoal()
        f21_arg0.Act06(f21_arg1, f21_arg2, paramTbl)
        if false then
        else
        end
    end
    if f21_arg1:GetSpecialEffectActivateInterruptType(0) == 5028 and f21_local0 <= 8 then
        f21_arg2:ClearSubGoal()
        f21_arg0.Act04(f21_arg1, f21_arg2, paramTbl)
        if false then
        else
        end
    end
    if f21_arg1:IsInterupt(INTERUPT_LoseSightTarget) and f21_arg1:IsActiveGoal(GOAL_COMMON_SidewayMove) then
        if f21_arg1:GetNumber(10) == 0 then
            f21_arg2:ClearSubGoal()
            f21_arg2:AddSubGoal(GOAL_COMMON_SidewayMove, 1, TARGET_ENE_0, 1, f21_arg1:GetRandam_Int(30, 45), true, true, -1):SetTargetRange(0, -99, 10)
        elseif f21_arg1:GetNumber(10) == 1 then
            f21_arg2:ClearSubGoal()
            f21_arg2:AddSubGoal(GOAL_COMMON_SidewayMove, 1, TARGET_ENE_0, 0, f21_arg1:GetRandam_Int(30, 45), true, true, -1):SetTargetRange(0, -99, 10)
        end
        return true
    end
    return false
    
end

Goal.ActAfter_AdjustSpace = function (f22_arg0, f22_arg1, f22_arg2)
    
end

Goal.Update = function (f23_arg0, f23_arg1, f23_arg2)
    return Update_Default_NoSubGoal(f23_arg0, f23_arg1, f23_arg2)
    
end

Goal.Terminate = function (f24_arg0, f24_arg1, f24_arg2)
    
end


