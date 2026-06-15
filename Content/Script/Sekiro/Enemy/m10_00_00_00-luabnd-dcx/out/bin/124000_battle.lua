RegisterTableGoal(GOAL_Syamo_124000_Battle, "GOAL_Syamo_124000_Battle")
REGISTER_GOAL_NO_UPDATE(GOAL_Syamo_124000_Battle, true)

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
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 3124010)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 3124020)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 3124030)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 3124040)
    f2_arg1:DeleteObserve(0)
    if Common_ActivateAct(f2_arg1, f2_arg2) then
    elseif f2_arg1:CheckDoesExistPath(TARGET_ENE_0, AI_DIR_TYPE_F, 0, 0) == false then
        f2_local0[27] = 100
    elseif f2_local4 == 1 and f2_arg1:GetTeamOrder(ORDER_TYPE_Role) == ROLE_TYPE_Kankyaku then
        KankyakuAct(f2_arg1, f2_arg2)
    elseif f2_local4 == 1 and f2_arg1:GetTeamOrder(ORDER_TYPE_Role) == ROLE_TYPE_Torimaki then
        TorimakiAct(f2_arg1, f2_arg2, -1, 0)
    elseif f2_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_B, 180) then
        f2_local0[21] = 100
        f2_local0[22] = 1
    elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 5020) and f2_arg1:GetNumber(5) == 0 then
        f2_local0[3] = 100
    elseif f2_local3 >= 7 then
        f2_local0[1] = 100
        f2_local0[3] = 100
        f2_local0[20] = 50
        f2_local0[33] = 50
        f2_local0[34] = 50
    elseif f2_local3 >= 5 then
        f2_local0[1] = 100
        f2_local0[3] = 100
        f2_local0[20] = 100
        f2_local0[24] = 50
        f2_local0[33] = 50
        f2_local0[34] = 50
    elseif f2_local3 > 3 then
        f2_local0[1] = 100
        f2_local0[2] = 300
        f2_local0[3] = 100
        f2_local0[24] = 50
        f2_local0[34] = 50
        if f2_arg1:HasSpecialEffectId(TARGET_SELF, 311000) then
            f2_local0[24] = 100
        end
    else
        f2_local0[1] = 100
        f2_local0[2] = 200
        f2_local0[3] = 100
        f2_local0[24] = 50
        if f2_arg1:HasSpecialEffectId(TARGET_SELF, 311000) then
            f2_local0[24] = 300
        end
    end
    if f2_arg1:IsFinishTimer(0) == false then
        f2_local0[24] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 0, 5) == false then
        f2_local0[20] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 45, 5) == false and SpaceCheck(f2_arg1, f2_arg2, -45, 5) == false then
        f2_local0[22] = 0
        f2_local0[33] = 0
        f2_local0[34] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 90, 1) == false and SpaceCheck(f2_arg1, f2_arg2, -45, 1) == false then
        f2_local0[23] = 0
        f2_local0[33] = 0
        f2_local0[34] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 180, 5) == false then
        f2_local0[24] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 180, 1) == false then
        f2_local0[25] = 0
    end
    f2_local0[1] = SetCoolTime(f2_arg1, f2_arg2, 3000, 5, f2_local0[1], 1)
    f2_local0[2] = SetCoolTime(f2_arg1, f2_arg2, 3002, 5, f2_local0[2], 1)
    f2_local0[3] = SetCoolTime(f2_arg1, f2_arg2, 3004, 8, f2_local0[3], 1)
    f2_local0[4] = SetCoolTime(f2_arg1, f2_arg2, 3005, 8, f2_local0[4], 1)
    f2_local0[5] = SetCoolTime(f2_arg1, f2_arg2, 3007, 5, f2_local0[5], 1)
    f2_local0[6] = SetCoolTime(f2_arg1, f2_arg2, 3008, 5, f2_local0[6], 1)
    f2_local0[10] = SetCoolTime(f2_arg1, f2_arg2, 3020, 8, f2_local0[10], 1)
    f2_local0[20] = SetCoolTime(f2_arg1, f2_arg2, 5200, 8, f2_local0[20], 1)
    f2_local0[24] = SetCoolTime(f2_arg1, f2_arg2, 5201, 8, f2_local0[24], 1)
    f2_local1[1] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act01)
    f2_local1[2] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act02)
    f2_local1[3] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act03)
    f2_local1[4] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act04)
    f2_local1[10] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act10)
    f2_local1[20] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act20)
    f2_local1[21] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act21)
    f2_local1[22] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act22)
    f2_local1[23] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act23)
    f2_local1[24] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act24)
    f2_local1[25] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act25)
    f2_local1[26] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act26)
    f2_local1[27] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act27)
    f2_local1[28] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act28)
    f2_local1[33] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act33)
    f2_local1[34] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act34)
    local f2_local5 = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.ActAfter_AdjustSpace)
    Common_Battle_Activate(f2_arg1, f2_arg2, f2_local0, f2_local1, f2_local5, f2_local2)
    
end

Goal.Act01 = function (f3_arg0, f3_arg1, f3_arg2)
    local f3_local0 = 4 - f3_arg0:GetMapHitRadius(TARGET_SELF)
    local f3_local1 = 2 - f3_arg0:GetMapHitRadius(TARGET_SELF)
    local f3_local2 = 2 - f3_arg0:GetMapHitRadius(TARGET_SELF) + 999
    local f3_local3 = 80
    local f3_local4 = 0
    local f3_local5 = 1
    local f3_local6 = 3
    Approach_Act_Flex(f3_arg0, f3_arg1, f3_local0, f3_local1, f3_local2, f3_local3, f3_local4, f3_local5, f3_local6)
    local f3_local7 = 3000
    local f3_local8 = 3001
    local f3_local9 = 0
    local f3_local10 = 0
    local f3_local11 = f3_arg0:GetRandam_Int(1, 100)
    f3_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, f3_local7, TARGET_ENE_0, 9999, f3_local9, f3_local10, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act02 = function (f4_arg0, f4_arg1, f4_arg2)
    local f4_local0 = 2 - f4_arg0:GetMapHitRadius(TARGET_SELF)
    local f4_local1 = 2 - f4_arg0:GetMapHitRadius(TARGET_SELF)
    local f4_local2 = 2 - f4_arg0:GetMapHitRadius(TARGET_SELF) + 999
    local f4_local3 = 80
    local f4_local4 = 0
    local f4_local5 = 1
    local f4_local6 = 3
    Approach_Act_Flex(f4_arg0, f4_arg1, f4_local0, f4_local1, f4_local2, f4_local3, f4_local4, f4_local5, f4_local6)
    local f4_local7 = 3002
    local f4_local8 = 0
    local f4_local9 = 0
    f4_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f4_local7, TARGET_ENE_0, 9999, f4_local8, f4_local9, 0, 0)
    f4_arg0:SetNumber(0, 1)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act03 = function (f5_arg0, f5_arg1, f5_arg2)
    local f5_local0 = 3.5 - f5_arg0:GetMapHitRadius(TARGET_SELF) + 1
    local f5_local1 = 3.5 - f5_arg0:GetMapHitRadius(TARGET_SELF)
    local f5_local2 = 3.5 - f5_arg0:GetMapHitRadius(TARGET_SELF) + 999
    local f5_local3 = 80
    local f5_local4 = 0
    local f5_local5 = 1
    local f5_local6 = 3
    Approach_Act_Flex(f5_arg0, f5_arg1, f5_local0, f5_local1, f5_local2, f5_local3, f5_local4, f5_local5, f5_local6)
    local f5_local7 = 3001
    local f5_local8 = 0
    local f5_local9 = 0
    local f5_local10 = f5_arg0:GetRandam_Int(1, 100)
    f5_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, f5_local7, TARGET_ENE_0, 9999, f5_local8, f5_local9, 0, 0)
    f5_arg0:SetNumber(5, 1)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act04 = function (f6_arg0, f6_arg1, f6_arg2)
    local f6_local0 = 8 - f6_arg0:GetMapHitRadius(TARGET_SELF)
    local f6_local1 = 8 - f6_arg0:GetMapHitRadius(TARGET_SELF)
    local f6_local2 = 8 - f6_arg0:GetMapHitRadius(TARGET_SELF) + 999
    local f6_local3 = 80
    local f6_local4 = 0
    local f6_local5 = 1
    local f6_local6 = 3
    Approach_Act_Flex(f6_arg0, f6_arg1, f6_local0, f6_local1, f6_local2, f6_local3, f6_local4, f6_local5, f6_local6)
    local f6_local7 = 3007
    local f6_local8 = 0
    local f6_local9 = 0
    local f6_local10 = f6_arg0:GetRandam_Int(1, 100)
    f6_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, f6_local7, TARGET_ENE_0, 9999, f6_local8, f6_local9, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act10 = function (f7_arg0, f7_arg1, f7_arg2)
    local f7_local0 = 99 - f7_arg0:GetMapHitRadius(TARGET_SELF)
    local f7_local1 = 99 - f7_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f7_local2 = 99 - f7_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f7_local3 = 100
    local f7_local4 = 0
    local f7_local5 = 1.5
    local f7_local6 = 3
    Approach_Act_Flex(f7_arg0, f7_arg1, f7_local0, f7_local1, f7_local2, f7_local3, f7_local4, f7_local5, f7_local6)
    local f7_local7 = 3020
    local f7_local8 = 0
    local f7_local9 = 0
    local f7_local10 = 120
    local f7_local11 = 2 - f7_arg0:GetMapHitRadius(TARGET_SELF)
    f7_arg0:AddObserveArea(0, TARGET_SELF, TARGET_ENE_0, AI_DIR_TYPE_F, f7_local10, f7_local11)
    f7_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f7_local7, TARGET_ENE_0, 9999, f7_local8, f7_local9, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act20 = function (f8_arg0, f8_arg1, f8_arg2)
    local f8_local0 = f8_arg0:GetDist(TARGET_ENE_0)
    local f8_local1 = 3
    local f8_local2 = 0
    local f8_local3 = 5200
    local f8_local4 = 3002
    local f8_local5 = f8_arg0:GetRandam_Int(1, 100)
    local f8_local6 = 120
    local f8_local7 = 2 - f8_arg0:GetMapHitRadius(TARGET_SELF)
    f8_arg0:AddObserveArea(0, TARGET_SELF, TARGET_ENE_0, AI_DIR_TYPE_F, f8_local6, f8_local7)
    f8_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f8_local1, f8_local3, TARGET_ENE_0, f8_local2, AI_DIR_TYPE_F, 0)
    if f8_local5 <= 50 then
        f8_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, f8_local4, TARGET_ENE_0, 9999, 0)
    end
    f8_arg0:SetTimer(0, 5)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act21 = function (f9_arg0, f9_arg1, f9_arg2)
    local f9_local0 = 3
    local f9_local1 = 45
    f9_arg1:AddSubGoal(GOAL_COMMON_Turn, f9_local0, TARGET_ENE_0, f9_local1, -1, GOAL_RESULT_Success, true)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act22 = function (f10_arg0, f10_arg1, f10_arg2)
    local f10_local0 = 3
    local f10_local1 = 0
    if SpaceCheck(f10_arg0, f10_arg1, -45, 5) == true then
        if SpaceCheck(f10_arg0, f10_arg1, 45, 5) == true then
            if f10_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                f10_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f10_local0, 5202, TARGET_ENE_0, f10_local1, AI_DIR_TYPE_L, 0)
            else
                f10_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f10_local0, 5203, TARGET_ENE_0, f10_local1, AI_DIR_TYPE_R, 0)
            end
        else
            f10_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f10_local0, 5202, TARGET_ENE_0, f10_local1, AI_DIR_TYPE_L, 0)
        end
    elseif SpaceCheck(f10_arg0, f10_arg1, 45, 5) == true then
        f10_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f10_local0, 5203, TARGET_ENE_0, f10_local1, AI_DIR_TYPE_R, 0)
    else
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act23 = function (f11_arg0, f11_arg1, f11_arg2)
    local f11_local0 = f11_arg0:GetDist(TARGET_ENE_0)
    local f11_local1 = f11_arg0:GetSp(TARGET_SELF)
    local f11_local2 = 20
    local f11_local3 = f11_arg0:GetRandam_Int(1, 100)
    local f11_local4 = -1
    local f11_local5 = 0
    if SpaceCheck(f11_arg0, f11_arg1, -90, 1) == true then
        if SpaceCheck(f11_arg0, f11_arg1, 90, 1) == true then
            if f11_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                f11_local5 = 0
            else
                f11_local5 = 1
            end
        else
            f11_local5 = 0
        end
    elseif SpaceCheck(f11_arg0, f11_arg1, 90, 1) == true then
        f11_local5 = 1
    else
        GetWellSpace_Odds = 100
        return GetWellSpace_Odds
    end
    local f11_local6 = 3
    local f11_local7 = f11_arg0:GetRandam_Int(30, 45)
    f11_arg0:SetNumber(10, f11_local5)
    f11_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f11_local6, TARGET_ENE_0, f11_local5, f11_local7, true, true, f11_local4):TimingSetTimer(2, 4, UPDATE_SUCCESS)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act24 = function (f12_arg0, f12_arg1, f12_arg2)
    local f12_local0 = f12_arg0:GetDist(TARGET_ENE_0)
    local f12_local1 = 3
    local f12_local2 = 0
    local f12_local3 = 5201
    if SpaceCheck(f12_arg0, f12_arg1, 180, 5) == true then
        if f12_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
            f12_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f12_local1, f12_local3, TARGET_ENE_0, f12_local2, AI_DIR_TYPE_B, 0)
        else
            f12_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f12_local1, f12_local3, TARGET_ENE_0, f12_local2, AI_DIR_TYPE_B, 0)
        end
    else
    end
    
end

Goal.Act25 = function (f13_arg0, f13_arg1, f13_arg2)
    local f13_local0 = f13_arg0:GetRandam_Float(2, 4)
    local f13_local1 = f13_arg0:GetRandam_Float(1, 3)
    local f13_local2 = f13_arg0:GetDist(TARGET_ENE_0)
    local f13_local3 = -1
    if SpaceCheck(f13_arg0, f13_arg1, 180, 1) == true then
        f13_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, f13_local0, TARGET_ENE_0, f13_local1, TARGET_ENE_0, true, f13_local3)
    else
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act26 = function (f14_arg0, f14_arg1, f14_arg2)
    f14_arg1:AddSubGoal(GOAL_COMMON_Wait, 0.5, TARGET_SELF, 0, 0, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act27 = function (f15_arg0, f15_arg1, f15_arg2)
    local f15_local0 = f15_arg0:GetDist(TARGET_ENE_0)
    local f15_local1 = f15_arg0:GetDistYSigned(TARGET_ENE_0)
    local f15_local2 = 3
    local f15_local3 = f15_local1 / math.tan(math.deg(30))
    local f15_local4 = f15_arg0:GetRandam_Int(0, 1)
    f15_arg0:SetNumber(10, f15_local4)
    if f15_local1 >= 3 then
        if f15_local3 + 1 <= f15_local0 then
            if SpaceCheck(f15_arg0, f15_arg1, 0, 4) == true then
                f15_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.1, TARGET_ENE_0, f15_local3, TARGET_SELF, false, -1)
            elseif SpaceCheck(f15_arg0, f15_arg1, 0, 3) == true then
                f15_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.5, TARGET_ENE_0, f15_local3, TARGET_SELF, true, -1)
            end
        elseif f15_local0 <= f15_local3 - 1 then
            if SpaceCheck(f15_arg0, f15_arg1, 180, 1) == true then
                f15_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f15_local2, 5211, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0)
            else
                f15_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3003, TARGET_ENE_0, ATT_SUCCESSDIST, 0, 0, 0, 0)
            end
        end
    elseif SpaceCheck(f15_arg0, f15_arg1, 0, 4) == true then
        f15_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.1, TARGET_ENE_0, 0, TARGET_SELF, false, -1)
    elseif SpaceCheck(f15_arg0, f15_arg1, 0, 3) == true then
        f15_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.5, TARGET_ENE_0, 0, TARGET_SELF, true, -1)
    elseif SpaceCheck(f15_arg0, f15_arg1, 0, 1) == false then
        if SpaceCheck(f15_arg0, f15_arg1, 180, 1) == true then
            f15_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f15_local2, 5211, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0)
        else
            f15_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3003, TARGET_ENE_0, ATT_SUCCESSDIST, 0, 0, 0, 0)
        end
    end
    local f15_local5 = 3003
    local f15_local6 = ATT_SUCCESSDIST
    local f15_local7 = 0
    local f15_local8 = 0
    f15_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f15_local5, TARGET_ENE_0, f15_local6, f15_local7, f15_local8, 0, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act28 = function (f16_arg0, f16_arg1, f16_arg2)
    local f16_local0 = f16_arg0:GetDist(TARGET_ENE_0)
    local f16_local1 = 1.5
    local f16_local2 = 1.5
    local f16_local3 = f16_arg0:GetRandam_Int(30, 45)
    local f16_local4 = -1
    local f16_local5 = f16_arg0:GetRandam_Int(0, 1)
    if f16_local0 <= 3 then
        f16_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f16_local1, TARGET_ENE_0, f16_local5, f16_local3, true, true, f16_local4)
    elseif f16_local0 <= 8 then
        f16_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, f16_local2, TARGET_ENE_0, 3, TARGET_SELF, true, -1)
    else
        f16_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, f16_local2, TARGET_ENE_0, 8, TARGET_SELF, false, -1)
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act33 = function (f17_arg0, f17_arg1, f17_arg2)
    local f17_local0 = f17_arg0:GetDist(TARGET_ENE_0)
    local f17_local1 = 9999
    local f17_local2 = 0
    local f17_local3 = 0
    local f17_local4 = f17_arg0:GetRandam_Int(2, 5)
    local f17_local5 = f17_arg0:GetRandam_Int(1, 100)
    local f17_local6 = f17_arg0:GetRandam_Float(0.75, 1.25)
    local f17_local7 = 120
    local f17_local8 = 2 - f17_arg0:GetMapHitRadius(TARGET_SELF)
    f17_arg0:AddObserveArea(0, TARGET_SELF, TARGET_ENE_0, AI_DIR_TYPE_F, f17_local7, f17_local8)
    if SpaceCheck(f17_arg0, f17_arg1, 90, 2.5) == true then
        if f17_local5 <= 50 then
            f17_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f17_local6, TARGET_ENE_0, 5, TARGET_SELF, true, -1, AI_DIR_TYPE_ToL, 5)
        else
            f17_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f17_local6, TARGET_ENE_0, 5, TARGET_SELF, true, -1, AI_DIR_TYPE_ToR, 5)
        end
    end
    if SpaceCheck(f17_arg0, f17_arg1, 90, 2.5) == true then
        f17_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f17_local6, TARGET_ENE_0, 5, TARGET_SELF, true, -1, AI_DIR_TYPE_ToL, 5)
    elseif SpaceCheck(f17_arg0, f17_arg1, -45, 2.5) == true then
        f17_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f17_local6, TARGET_ENE_0, 5, TARGET_SELF, true, -1, AI_DIR_TYPE_ToR, 5)
    end
    
end

Goal.Act34 = function (f18_arg0, f18_arg1, f18_arg2)
    local f18_local0 = f18_arg0:GetDist(TARGET_ENE_0)
    local f18_local1 = 9999
    local f18_local2 = 0
    local f18_local3 = 0
    local f18_local4 = f18_arg0:GetRandam_Int(1, 100)
    local f18_local5 = f18_arg0:GetRandam_Float(0.75, 1.2)
    local f18_local6 = f18_arg0:GetDist(TARGET_ENE_0)
    local f18_local7 = 3
    local f18_local8 = 0
    local f18_local9 = 5200
    if SpaceCheck(f18_arg0, f18_arg1, 90, 5) == true then
        if f18_local4 <= 50 then
            f18_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f18_local5, TARGET_ENE_0, 5, TARGET_SELF, false, -1, AI_DIR_TYPE_ToL, 10)
        else
            f18_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f18_local5, TARGET_ENE_0, 5, TARGET_SELF, false, -1, AI_DIR_TYPE_ToR, 5)
        end
    end
    if SpaceCheck(f18_arg0, f18_arg1, 90, 5) == true then
        f18_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f18_local5, TARGET_ENE_0, 5, TARGET_SELF, false, -1, AI_DIR_TYPE_ToL, 10)
    elseif SpaceCheck(f18_arg0, f18_arg1, -45, 5) == true then
        f18_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f18_local5, TARGET_ENE_0, 5, TARGET_SELF, false, -1, AI_DIR_TYPE_ToR, 5)
    end
    if not f18_arg0:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_B, 150, 4) then
        f18_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f18_local7, f18_local9, TARGET_ENE_0, f18_local8, AI_DIR_TYPE_F, 0)
    else
    end
    f18_arg0:SetTimer(0, 5)
    
end

Goal.Interrupt = function (f19_arg0, f19_arg1, f19_arg2)
    local f19_local0 = f19_arg1:GetHpRate(TARGET_SELF)
    local f19_local1 = f19_arg1:GetDist(TARGET_ENE_0)
    local f19_local2 = f19_arg1:GetSp(TARGET_SELF)
    local f19_local3 = f19_arg1:GetSpecialEffectActivateInterruptType(0)
    local f19_local4 = f19_arg1:GetRandam_Int(1, 100)
    local f19_local5 = f19_arg1:GetHp(TARGET_ENE_0)
    local f19_local6 = f19_arg1:GetSp(TARGET_ENE_0)
    if f19_arg1:IsLadderAct(TARGET_SELF) then
        return false
    end
    if not f19_arg1:HasSpecialEffectId(TARGET_SELF, 200004) then
        return false
    end
    if f19_arg1:IsInterupt(INTERUPT_ParryTiming) then
        return f19_arg0.Parry(f19_arg1, f19_arg2)
    end
    if f19_arg1:IsInterupt(INTERUPT_Inside_ObserveArea) and f19_arg1:IsInsideObserve(0) then
        f19_arg2:ClearSubGoal()
        if f19_local4 <= 50 then
            f19_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 2, 3002, TARGET_ENE_0, 9999, 0, 0)
        elseif SpaceCheck(f19_arg1, f19_arg2, 180, 5) == true then
            f19_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 3, 5201, TARGET_ENE_0, 9999, 0, 0)
        else
        end
        f19_arg1:DeleteObserve(0)
        return true
    end
    if f19_arg1:IsInterupt(INTERUPT_ActivateSpecialEffect) and f19_arg1:GetSpecialEffectActivateInterruptType(0) == 3124040 and f19_arg1:HasSpecialEffectId(TARGET_SELF, 3124030) then
        f19_arg2:ClearSubGoal()
        f19_arg2:AddSubGoal(GOAL_COMMON_ComboFinal, 3, 3008, TARGET_ENE_0, 9999, 0, 0)
        return true
    end
    return false
    
end

Goal.ActAfter_AdjustSpace = function (f20_arg0, f20_arg1, f20_arg2)
    
end

Goal.Update = function (f21_arg0, f21_arg1, f21_arg2)
    return Update_Default_NoSubGoal(f21_arg0, f21_arg1, f21_arg2)
    
end

Goal.Terminate = function (f22_arg0, f22_arg1, f22_arg2)
    
end


