RegisterTableGoal(GOAL_MurabitoZombie_takeyari_genkaku_151040_Battle, "GOAL_MurabitoZombie_takeyari_genkaku_151040_Battle")
REGISTER_GOAL_NO_UPDATE(GOAL_MurabitoZombie_takeyari_genkaku_151040_Battle, true)

Goal.Initialize = function (f1_arg0, f1_arg1, f1_arg2, f1_arg3)
    
end

Goal.Activate = function (f2_arg0, f2_arg1, f2_arg2)
    Init_Pseudo_Global(f2_arg1, f2_arg2)
    f2_arg1:SetStringIndexedNumber("Warp_Point_Back", f2_arg1:GetRandam_Int(1002850, 1002857))
    f2_arg1:SetStringIndexedNumber("Warp_Point_Center", f2_arg1:GetRandam_Int(1002860, 1002867))
    f2_arg1:SetStringIndexedNumber("Warp_Point_Front", f2_arg1:GetRandam_Int(1002870, 1002877))
    f2_arg1:SetStringIndexedNumber("Warp_Region_Back", 1002840)
    f2_arg1:SetStringIndexedNumber("Warp_Region_Front", 1002841)
    if f2_arg1:HasSpecialEffectId(TARGET_SELF, 5020) then
        f2_arg1:SetStringIndexedNumber("Warp_Point_Back", f2_arg1:GetRandam_Int(9992900, 9992907))
        f2_arg1:SetStringIndexedNumber("Warp_Point_Center", f2_arg1:GetRandam_Int(9992910, 9992917))
        f2_arg1:SetStringIndexedNumber("Warp_Point_Front", f2_arg1:GetRandam_Int(9992920, 9992927))
        f2_arg1:SetStringIndexedNumber("Warp_Region_Back", 9992980)
        f2_arg1:SetStringIndexedNumber("Warp_Region_Front", 9992982)
    elseif f2_arg1:GetNpcThinkParamID() == 15109400 and not f2_arg1:HasSpecialEffectId(TARGET_SELF, 5020) then
        f2_arg1:SetStringIndexedNumber("Warp_Point_Back", f2_arg1:GetRandam_Int(9992800, 9992807))
        f2_arg1:SetStringIndexedNumber("Warp_Point_Center", f2_arg1:GetRandam_Int(9992810, 9992817))
        f2_arg1:SetStringIndexedNumber("Warp_Point_Front", f2_arg1:GetRandam_Int(9992820, 9992827))
        f2_arg1:SetStringIndexedNumber("Warp_Region_Back", 9992880)
        f2_arg1:SetStringIndexedNumber("Warp_Region_Front", 9992882)
    end
    local f2_local0 = {}
    local f2_local1 = {}
    local f2_local2 = {}
    Common_Clear_Param(f2_local0, f2_local1, f2_local2)
    local f2_local3 = f2_arg1:GetDist(TARGET_ENE_0)
    local f2_local4 = f2_arg1:GetExcelParam(AI_EXCEL_THINK_PARAM_TYPE__thinkAttr_doAdmirer)
    local f2_local5 = f2_arg1:GetEventRequest()
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 110124)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 3509070)
    if f2_arg1:GetNumber(1) == 0 then
        if f2_arg1:IsInsideTargetRegion(TARGET_EVENT, f2_arg1:GetStringIndexedNumber("Warp_Region_Back")) == true then
            f2_local0[36] = 100
            f2_arg1:SetNumber(1, 36)
        elseif f2_arg1:IsInsideTargetRegion(TARGET_EVENT, f2_arg1:GetStringIndexedNumber("Warp_Region_Front")) == true then
            f2_local0[38] = 100
            f2_arg1:SetNumber(1, 38)
        elseif f2_arg1:IsInsideTargetRegion(TARGET_EVENT, f2_arg1:GetStringIndexedNumber("Warp_Region_Back")) == false and f2_arg1:IsInsideTargetRegion(TARGET_EVENT, f2_arg1:GetStringIndexedNumber("Warp_Region_Front")) == false then
            f2_local0[37] = 100
            f2_arg1:SetNumber(1, 37)
        end
    elseif f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 110010) then
        KankyakuAct(f2_arg1, f2_arg2, 0)
    elseif Common_ActivateAct(f2_arg1, f2_arg2) then
    elseif f2_local4 == 1 and f2_arg1:GetTeamOrder(ORDER_TYPE_Role) == ROLE_TYPE_Kankyaku then
        if f2_local3 >= 8 then
            f2_local0[5] = 100
            f2_local0[7] = 500
            f2_local0[23] = 100
            f2_local0[28] = 100
            f2_local0[29] = 0
        elseif f2_local3 >= 4 then
            f2_local0[23] = 200
            f2_local0[28] = 200
            f2_local0[29] = 200
        else
            f2_local0[23] = 200
            f2_local0[28] = 200
            f2_local0[29] = 200
        end
    elseif f2_local4 == 1 and f2_arg1:GetTeamOrder(ORDER_TYPE_Role) == ROLE_TYPE_Torimaki then
        if f2_local3 >= 8 then
            f2_local0[1] = 0
            f2_local0[2] = 0
            f2_local0[3] = 0
            f2_local0[5] = 100
            f2_local0[23] = 50
            f2_local0[28] = 50
            f2_local0[29] = 0
        elseif f2_local3 >= 4 then
            f2_local0[1] = 0
            f2_local0[2] = 0
            f2_local0[3] = 0
            f2_local0[5] = 100
            f2_local0[23] = 50
            f2_local0[28] = 50
            f2_local0[29] = 1
        else
            f2_local0[1] = 0
            f2_local0[2] = 0
            f2_local0[3] = 0
            f2_local0[23] = 50
            f2_local0[28] = 50
            f2_local0[29] = 1
        end
    elseif f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 110030) then
        f2_local0[28] = 100
    elseif f2_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_B, 180) then
        f2_local0[21] = 100
        f2_local0[23] = 1
    elseif f2_local3 >= 11 then
        f2_local0[1] = 200
        f2_local0[2] = 350
        f2_local0[3] = 350
    elseif f2_local3 >= 8 then
        f2_local0[1] = 400
        f2_local0[2] = 300
        f2_local0[3] = 300
    elseif f2_local3 > 5 then
        f2_local0[1] = 500
        f2_local0[2] = 250
        f2_local0[3] = 250
        f2_local0[10] = 0
    else
        f2_local0[1] = 400
        f2_local0[2] = 150
        f2_local0[3] = 150
        f2_local0[10] = 300
    end
    if SpaceCheck(f2_arg1, f2_arg2, 45, 2) == false and SpaceCheck(f2_arg1, f2_arg2, -45, 2) == false then
        f2_local0[22] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 90, 1) == false and SpaceCheck(f2_arg1, f2_arg2, -45, 1) == false then
        f2_local0[23] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 180, 2) == false then
        f2_local0[24] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 180, 1) == false then
        f2_local0[25] = 0
    end
    f2_local0[1] = SetCoolTime(f2_arg1, f2_arg2, 3010, 5, f2_local0[1], 1)
    f2_local0[2] = SetCoolTime(f2_arg1, f2_arg2, 3011, 5, f2_local0[2], 1)
    f2_local0[3] = SetCoolTime(f2_arg1, f2_arg2, 3012, 5, f2_local0[3], 1)
    f2_local0[5] = SetCoolTime(f2_arg1, f2_arg2, 3025, 10, f2_local0[5], 1)
    f2_local0[10] = SetCoolTime(f2_arg1, f2_arg2, 3020, 5, f2_local0[10], 1)
    f2_local1[1] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act01)
    f2_local1[2] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act02)
    f2_local1[3] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act03)
    f2_local1[5] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act05)
    f2_local1[6] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act06)
    f2_local1[7] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act07)
    f2_local1[10] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act10)
    f2_local1[15] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act15)
    f2_local1[21] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act21)
    f2_local1[22] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act22)
    f2_local1[23] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act23)
    f2_local1[24] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act24)
    f2_local1[25] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act25)
    f2_local1[26] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act26)
    f2_local1[27] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act27)
    f2_local1[28] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act28)
    f2_local1[29] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act29)
    f2_local1[35] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act35)
    f2_local1[36] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act36)
    f2_local1[37] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act37)
    f2_local1[38] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act38)
    f2_local1[40] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act40)
    f2_local1[41] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act41)
    f2_local1[42] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act42)
    f2_local1[43] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act43)
    f2_local1[44] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act44)
    local f2_local6 = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.ActAfter_AdjustSpace)
    Common_Battle_Activate(f2_arg1, f2_arg2, f2_local0, f2_local1, f2_local6, f2_local2)
    
end

Goal.Act01 = function (f3_arg0, f3_arg1, f3_arg2)
    local f3_local0 = 4.2 - f3_arg0:GetMapHitRadius(TARGET_SELF) + (f3_arg0:GetRandam_Float(0, 2.5) - 0.8)
    local f3_local1 = f3_local0
    local f3_local2 = f3_local0 + 8
    local f3_local3 = 100
    local f3_local4 = 0
    local f3_local5 = 1.5
    local f3_local6 = 2
    Approach_Act_Flex(f3_arg0, f3_arg1, f3_local0, f3_local1, f3_local2, f3_local3, f3_local4, f3_local5, f3_local6)
    local f3_local7 = 0
    local f3_local8 = 0
    f3_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3010, TARGET_ENE_0, 9999, f3_local7, f3_local8, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act02 = function (f4_arg0, f4_arg1, f4_arg2)
    local f4_local0 = 5.5 - f4_arg0:GetMapHitRadius(TARGET_SELF) + (f4_arg0:GetRandam_Float(0, 2.5) - 0.8)
    local f4_local1 = f4_local0
    local f4_local2 = f4_local0 + 9
    local f4_local3 = 100
    local f4_local4 = 0
    local f4_local5 = 1.5
    local f4_local6 = 2
    Approach_Act_Flex(f4_arg0, f4_arg1, f4_local0, f4_local1, f4_local2, f4_local3, f4_local4, f4_local5, f4_local6)
    local f4_local7 = 0
    local f4_local8 = 0
    f4_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3011, TARGET_ENE_0, 9999, f4_local7, f4_local8, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act03 = function (f5_arg0, f5_arg1, f5_arg2)
    local f5_local0 = 2.8 - f5_arg0:GetMapHitRadius(TARGET_SELF) + (f5_arg0:GetRandam_Float(0, 2.5) - 0.8)
    local f5_local1 = f5_local0
    local f5_local2 = f5_local0 + 9
    local f5_local3 = 0
    local f5_local4 = 0
    local f5_local5 = 1.5
    local f5_local6 = 2
    Approach_Act_Flex(f5_arg0, f5_arg1, f5_local0, f5_local1, f5_local2, f5_local3, f5_local4, f5_local5, f5_local6)
    local f5_local7 = 0
    local f5_local8 = 0
    f5_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3012, TARGET_ENE_0, 9999, f5_local7, f5_local8, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act05 = function (f6_arg0, f6_arg1, f6_arg2)
    local f6_local0 = 0
    local f6_local1 = 0
    f6_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3025, TARGET_ENE_0, 9999, f6_local0, f6_local1, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act06 = function (f7_arg0, f7_arg1, f7_arg2)
    local f7_local0 = -1
    local f7_local1 = f7_arg0:GetRandam_Int(1, 2)
    local f7_local2 = f7_arg0:GetRandam_Int(0, 1)
    local f7_local3 = 3
    local f7_local4 = f7_arg0:GetRandam_Int(30, 45)
    if SpaceCheck(f7_arg0, f7_arg1, 180, 1) == true then
        f7_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 10, TARGET_ENE_0, 8, TARGET_ENE_0, true, f7_local0)
    else
        f7_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f7_local3, TARGET_ENE_0, f7_local2, f7_local4, true, true, f7_local0)
    end
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act07 = function (f8_arg0, f8_arg1, f8_arg2)
    local f8_local0 = 7
    local f8_local1 = 10
    local f8_local2 = 15
    local f8_local3 = 0
    local f8_local4 = 0
    local f8_local5 = 1.5
    local f8_local6 = 2
    f8_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 10, TARGET_ENE_0, 6, TARGET_SELF, false, -1)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act10 = function (f9_arg0, f9_arg1, f9_arg2)
    local f9_local0 = 0
    local f9_local1 = 0
    f9_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3020, TARGET_ENE_0, 9999, f9_local0, f9_local1, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act15 = function (f10_arg0, f10_arg1, f10_arg2)
    local f10_local0 = 0
    local f10_local1 = 0
    f10_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3031, TARGET_ENE_0, 9999, f10_local0, f10_local1, 0, 0)
    GetWellSpace_Odds = 0
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
    local f12_local2 = f12_arg0:GetDist(TARGET_FRI_0)
    local f12_local3 = f12_arg0:GetRandam_Int(1, 100)
    if SpaceCheck(f12_arg0, f12_arg1, -45, 2) == true and SpaceCheck(f12_arg0, f12_arg1, 45, 2) == true and f12_local2 >= 2.5 then
        if f12_local3 <= 50 then
            f12_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f12_local0, 5212, TARGET_ENE_0, f12_local1, AI_DIR_TYPE_L, 0)
        else
            f12_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f12_local0, 5213, TARGET_ENE_0, f12_local1, AI_DIR_TYPE_R, 0)
        end
    elseif f12_arg0:IsInsideTarget(TARGET_FRI_0, AI_DIR_TYPE_R, 100) and SpaceCheck(f12_arg0, f12_arg1, -45, 2) == true and f12_local2 <= 2.5 then
        f12_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f12_local0, 5212, TARGET_ENE_0, f12_local1, AI_DIR_TYPE_L, 0)
    elseif f12_arg0:IsInsideTarget(TARGET_FRI_0, AI_DIR_TYPE_L, 100) and SpaceCheck(f12_arg0, f12_arg1, 45, 2) == true and f12_local2 <= 2.5 then
        f12_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f12_local0, 5213, TARGET_ENE_0, f12_local1, AI_DIR_TYPE_R, 0)
    elseif SpaceCheck(f12_arg0, f12_arg1, -45, 2) == true and SpaceCheck(f12_arg0, f12_arg1, 45, 2) == true then
        if f12_local3 <= 50 then
            f12_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f12_local0, 5212, TARGET_ENE_0, f12_local1, AI_DIR_TYPE_L, 0)
        else
            f12_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f12_local0, 5213, TARGET_ENE_0, f12_local1, AI_DIR_TYPE_R, 0)
        end
    elseif SpaceCheck(f12_arg0, f12_arg1, -45, 2) == true then
        f12_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f12_local0, 5212, TARGET_ENE_0, f12_local1, AI_DIR_TYPE_L, 0)
    elseif SpaceCheck(f12_arg0, f12_arg1, 45, 2) == true then
        f12_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f12_local0, 5213, TARGET_ENE_0, f12_local1, AI_DIR_TYPE_R, 0)
    else
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act23 = function (f13_arg0, f13_arg1, f13_arg2)
    local f13_local0 = f13_arg0:GetDist(TARGET_ENE_0)
    local f13_local1 = f13_arg0:GetDist(TARGET_FRI_0)
    local f13_local2 = f13_arg0:GetSp(TARGET_SELF)
    local f13_local3 = 20
    local f13_local4 = f13_arg0:GetRandam_Int(1, 100)
    local f13_local5 = -1
    local f13_local6 = f13_arg0:GetRandam_Int(0, 1)
    if f13_arg0:IsInsideTarget(TARGET_FRI_0, AI_DIR_TYPE_R, 100) and SpaceCheck(f13_arg0, f13_arg1, -90, 1) == true and f13_local1 <= 2.5 then
        f13_local6 = 0
    elseif f13_arg0:IsInsideTarget(TARGET_FRI_0, AI_DIR_TYPE_L, 100) and SpaceCheck(f13_arg0, f13_arg1, 90, 1) == true and f13_local1 <= 2.5 then
        f13_local6 = 1
    end
    local f13_local7 = 3
    local f13_local8 = f13_arg0:GetRandam_Int(30, 45)
    f13_arg0:SetNumber(10, f13_local6)
    f13_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f13_local7, TARGET_ENE_0, f13_local6, f13_local8, true, true, f13_local5):TimingSetTimer(2, 4, UPDATE_SUCCESS)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act24 = function (f14_arg0, f14_arg1, f14_arg2)
    local f14_local0 = f14_arg0:GetDist(TARGET_ENE_0)
    local f14_local1 = 3
    local f14_local2 = 0
    local f14_local3 = 5211
    if SpaceCheck(f14_arg0, f14_arg1, 180, 2) ~= true or SpaceCheck(f14_arg0, f14_arg1, 180, 4) ~= true or f14_local0 > 4 then
    else
        f14_local3 = 5211
        if false then
        else
        end
    end
    f14_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f14_local1, f14_local3, TARGET_ENE_0, f14_local2, AI_DIR_TYPE_B, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act25 = function (f15_arg0, f15_arg1, f15_arg2)
    local f15_local0 = f15_arg0:GetRandam_Float(2, 4)
    local f15_local1 = f15_arg0:GetRandam_Float(1, 3)
    local f15_local2 = f15_arg0:GetDist(TARGET_ENE_0)
    local f15_local3 = -1
    if SpaceCheck(f15_arg0, f15_arg1, 180, 1) == true then
        f15_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, f15_local0, TARGET_ENE_0, f15_local1, TARGET_ENE_0, true, f15_local3)
    else
    end
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
    if f17_local1 >= 3 then
        if f17_local2 + 1 <= f17_local0 then
            if SpaceCheck(f17_arg0, f17_arg1, 0, 4) == true then
                f17_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.1, TARGET_ENE_0, f17_local2, TARGET_SELF, false, -1)
            elseif SpaceCheck(f17_arg0, f17_arg1, 0, 3) == true then
                f17_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.5, TARGET_ENE_0, f17_local2, TARGET_SELF, true, -1)
            end
        elseif f17_local0 <= f17_local2 - 1 then
            f17_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 10, TARGET_ENE_0, f17_local2, TARGET_ENE_0, true, -1)
        end
    elseif SpaceCheck(f17_arg0, f17_arg1, 0, 4) == true then
        f17_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.1, TARGET_ENE_0, 0, TARGET_SELF, false, -1)
    elseif SpaceCheck(f17_arg0, f17_arg1, 0, 3) == true then
        f17_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.5, TARGET_ENE_0, 0, TARGET_SELF, true, -1)
    elseif SpaceCheck(f17_arg0, f17_arg1, 0, 1) == false then
        f17_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 0.5, TARGET_ENE_0, 999, TARGET_ENE_0, true, -1)
    end
    f17_arg0:SetNumber(10, f17_local3)
    f17_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, 3, TARGET_ENE_0, f17_local3, f17_arg0:GetRandam_Int(30, 45), true, true, -1)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act28 = function (f18_arg0, f18_arg1, f18_arg2)
    local f18_local0 = f18_arg0:GetDist(TARGET_ENE_0)
    local f18_local1 = f18_arg0:GetRandam_Float(1, 3.5)
    local f18_local2 = 1.5
    local f18_local3 = f18_arg0:GetRandam_Int(30, 45)
    local f18_local4 = -1
    local f18_local5 = f18_arg0:GetRandam_Int(0, 1)
    if f18_local0 <= 7 then
        f18_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f18_local1, TARGET_ENE_0, f18_local5, f18_local3, true, true, f18_local4)
    elseif f18_local0 <= 10 then
        f18_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, f18_local2, TARGET_ENE_0, 7.9, TARGET_SELF, true, -1)
    else
        f18_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, f18_local2, TARGET_ENE_0, 14.9, TARGET_SELF, false, -1)
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act29 = function (f19_arg0, f19_arg1, f19_arg2)
    local f19_local0 = f19_arg0:GetDist(TARGET_ENE_0)
    local f19_local1 = 7
    local f19_local2 = 0
    local f19_local3 = f19_arg0:GetRandam_Float(1, 3.5)
    f19_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, f19_local3, TARGET_ENE_0, f19_local1, TARGET_ENE_0, true, -1)
    
end

Goal.Act35 = function (f20_arg0, f20_arg1, f20_arg2)
    local f20_local0 = f20_arg0:GetDist(TARGET_ENE_0)
    local f20_local1 = f20_arg0:GetRandam_Int(1, 100)
    local f20_local2 = f20_arg0:GetRandam_Int(0, 1)
    local f20_local3 = f20_arg0:GetRandam_Float(2, 3.5)
    local f20_local4 = 3
    local f20_local5 = 0
    local f20_local6 = f20_arg0:GetDist(TARGET_FRI_0)
    local f20_local7 = f20_arg0:GetRandam_Int(1, 100)
    local f20_local8 = f20_arg0:GetRandam_Float(6.5, 7.5)
    local f20_local9 = f20_arg0:GetRandam_Float(5.5, 6.5)
    local f20_local10 = 999
    local f20_local11 = 100
    if f20_local0 >= 10 then
        Approach_Act(f20_arg0, f20_arg1, f20_local8, f20_local10, 0, 3)
    elseif f20_local0 >= 5 then
    elseif f20_local0 >= 3.5 then
        f20_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 3, TARGET_ENE_0, f20_local8, TARGET_ENE_0, false, 9910)
    else
        f20_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 5, 5201, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 2)
    end
    f20_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f20_local3, TARGET_ENE_0, f20_local2, f20_arg0:GetRandam_Int(30, 45), true, true, 9910):TimingSetTimer(2, 4, UPDATE_SUCCESS)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act36 = function (f21_arg0, f21_arg1, f21_arg2)
    local f21_local0 = f21_arg0:GetStringIndexedNumber("Warp_Point_Back")
    f21_arg0:SetNumber(2, f21_local0)
    f21_arg0:SetEventMoveTarget(f21_local0)
    f21_arg1:AddSubGoal(GOAL_COMMON_ToTargetWarp, 10, POINT_EVENT, AI_DIR_TYPE_F, 0, TARGET_ENE_0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act37 = function (f22_arg0, f22_arg1, f22_arg2)
    local f22_local0 = f22_arg0:GetStringIndexedNumber("Warp_Point_Center")
    f22_arg0:SetNumber(2, f22_local0)
    f22_arg0:SetEventMoveTarget(f22_local0)
    f22_arg1:AddSubGoal(GOAL_COMMON_ToTargetWarp, 10, POINT_EVENT, AI_DIR_TYPE_F, 0, TARGET_ENE_0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act38 = function (f23_arg0, f23_arg1, f23_arg2)
    local f23_local0 = f23_arg0:GetStringIndexedNumber("Warp_Point_Front")
    f23_arg0:SetNumber(2, f23_local0)
    f23_arg0:SetEventMoveTarget(f23_local0)
    f23_arg1:AddSubGoal(GOAL_COMMON_ToTargetWarp, 10, POINT_EVENT, AI_DIR_TYPE_F, 0, TARGET_ENE_0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act40 = function (f24_arg0, f24_arg1, f24_arg2)
    local f24_local0 = f24_arg0:GetRandam_Int(9992960, 9992967)
    f24_arg0:SetNumber(2, f24_local0)
    f24_arg0:SetEventMoveTarget(f24_local0)
    f24_arg1:AddSubGoal(GOAL_COMMON_ToTargetWarp, 10, POINT_EVENT, AI_DIR_TYPE_F, 0, TARGET_ENE_0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act41 = function (f25_arg0, f25_arg1, f25_arg2)
    local f25_local0 = f25_arg0:GetRandam_Int(9992964, 9992971)
    f25_arg0:SetNumber(2, f25_local0)
    f25_arg0:SetEventMoveTarget(f25_local0)
    f25_arg1:AddSubGoal(GOAL_COMMON_ToTargetWarp, 10, POINT_EVENT, AI_DIR_TYPE_F, 0, TARGET_ENE_0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act42 = function (f26_arg0, f26_arg1, f26_arg2)
    local f26_local0 = f26_arg0:GetRandam_Int(9992968, 9992975)
    f26_arg0:SetNumber(2, f26_local0)
    f26_arg0:SetEventMoveTarget(f26_local0)
    f26_arg1:AddSubGoal(GOAL_COMMON_ToTargetWarp, 10, POINT_EVENT, AI_DIR_TYPE_F, 0, TARGET_ENE_0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act43 = function (f27_arg0, f27_arg1, f27_arg2)
    local f27_local0 = f27_arg0:GetRandam_Int(0, 1)
    local f27_local1 = f27_arg0:GetRandam_Int(9992810, 9992817)
    f27_arg0:SetNumber(2, f27_local1)
    f27_arg0:SetEventMoveTarget(f27_local1)
    f27_arg1:AddSubGoal(GOAL_COMMON_ToTargetWarp, 10, POINT_EVENT, AI_DIR_TYPE_F, f27_local0, TARGET_ENE_0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act44 = function (f28_arg0, f28_arg1, f28_arg2)
    local f28_local0 = f28_arg0:GetRandam_Int(0, 1)
    local f28_local1 = f28_arg0:GetRandam_Int(9992800, 9992807)
    f28_arg0:SetNumber(2, f28_local1)
    f28_arg0:SetEventMoveTarget(f28_local1)
    f28_arg1:AddSubGoal(GOAL_COMMON_ToTargetWarp, 10, POINT_EVENT, AI_DIR_TYPE_F, f28_local0, TARGET_ENE_0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Interrupt = function (f29_arg0, f29_arg1, f29_arg2)
    local f29_local0 = f29_arg1:GetSpecialEffectActivateInterruptType(0)
    if f29_arg1:IsLadderAct(TARGET_SELF) then
        return false
    end
    if not f29_arg1:HasSpecialEffectId(TARGET_SELF, 200004) then
        return false
    end
    if f29_arg1:IsInterupt(INTERUPT_Damaged) then
        return f29_arg0.Damaged(f29_arg1, f29_arg2)
    end
    if f29_arg1:IsInterupt(INTERUPT_ActivateSpecialEffect) and f29_local0 == 3509070 then
        f29_arg2:ClearSubGoal()
        f29_arg2:AddSubGoal(GOAL_COMMON_AttackImmediateAction, 1, 3031, TARGET_ENE_0, 9999, 0, 0, 0, 0)
        return true
    end
    if f29_arg1:GetSpecialEffectActivateInterruptType(0) == 110124 then
        f29_arg2:ClearSubGoal()
        f29_arg1:Replaning()
        return false
    end
    return false
    
end

Goal.Parry = function (f30_arg0, f30_arg1, f30_arg2)
    local f30_local0 = f30_arg0:GetHpRate(TARGET_SELF)
    local f30_local1 = f30_arg0:GetDist(TARGET_ENE_0)
    local f30_local2 = f30_arg0:GetSp(TARGET_SELF)
    local f30_local3 = f30_arg0:GetRandam_Int(1, 100)
    local f30_local4 = 0
    if not f30_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) or not f30_arg0:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_F, 90, 3) or f30_arg0:HasSpecialEffectId(TARGET_ENE_0, 109012) then
    elseif f30_arg0:IsTargetGuard(TARGET_SELF) then
        if f30_arg0:HasSpecialEffectId(TARGET_ENE_0, 109970) then
        else
            f30_arg1:ClearSubGoal()
            f30_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3100, TARGET_ENE_0, 9999, 0)
            return true
        end
    elseif f30_arg0:HasSpecialEffectId(TARGET_ENE_0, 109970) then
        f30_arg1:ClearSubGoal()
        f30_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3101, TARGET_ENE_0, 9999, 0)
        return true
    else
        f30_arg1:ClearSubGoal()
        f30_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3100, TARGET_ENE_0, 9999, 0)
        return true
    end
    return false
    
end

Goal.Damaged = function (f31_arg0, f31_arg1, f31_arg2)
    local f31_local0 = f31_arg0:GetHpRate(TARGET_SELF)
    local f31_local1 = f31_arg0:GetDist(TARGET_ENE_0)
    local f31_local2 = f31_arg0:GetSp(TARGET_SELF)
    local f31_local3 = f31_arg0:GetRandam_Int(1, 100)
    local f31_local4 = 0
    if f31_local3 <= 33 then
        f31_arg1:ClearSubGoal()
        f31_arg1:AddSubGoal(GOAL_COMMON_SpinStep, StepLife, 5211, TARGET_ENE_0, TurnTime, AI_DIR_TYPE_B, 0):TimingSetTimer(3, 6, UPDATE_SUCCESS)
        return true
    elseif f31_local3 <= 67 then
    end
    return false
    
end

Goal.ActAfter_AdjustSpace = function (f32_arg0, f32_arg1, f32_arg2)
    f32_arg1:AddSubGoal(GOAL_MurabitoZombie_takeyari_genkaku_151040_AfterAttackAct, 10)
    
end

Goal.Update = function (f33_arg0, f33_arg1, f33_arg2)
    return Update_Default_NoSubGoal(f33_arg0, f33_arg1, f33_arg2)
    
end

Goal.Terminate = function (f34_arg0, f34_arg1, f34_arg2)
    
end

RegisterTableGoal(GOAL_MurabitoZombie_takeyari_genkaku_151040_AfterAttackAct, "GOAL_MurabitoZombie_takeyari_genkaku_151040_AfterAttackAct")
REGISTER_GOAL_NO_SUB_GOAL(GOAL_MurabitoZombie_takeyari_genkaku_151040_AfterAttackAct, true)

Goal.Activate = function (f35_arg0, f35_arg1, f35_arg2)
    local f35_local0 = f35_arg1:GetDist(TARGET_ENE_0)
    local f35_local1 = f35_arg1:GetToTargetAngle(TARGET_ENE_0)
    local f35_local2 = f35_arg1:GetHpRate(TARGET_SELF)
    local f35_local3 = {}
    if f35_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_B, 160) then
        f35_local3[1] = 100
        f35_local3[2] = 0
        f35_local3[3] = 0
    elseif f35_local0 >= 7 then
        f35_local3[1] = 100
        f35_local3[2] = 0
        f35_local3[3] = 0
    elseif f35_local0 >= 3 then
        f35_local3[1] = 30
        f35_local3[2] = 45
        f35_local3[3] = 25
    else
        f35_local3[1] = 30
        f35_local3[2] = 20
        f35_local3[3] = 50
    end
    local f35_local4 = SelectOddsIndex(f35_arg1, f35_local3)
    if f35_local4 == 1 then
    elseif f35_local4 == 2 then
        f35_arg2:AddSubGoal(GOAL_COMMON_SidewayMove, f35_arg1:GetRandam_Float(0, 1), TARGET_ENE_0, f35_arg1:GetRandam_Int(1.5, 3), f35_arg1:GetRandam_Int(30, 45), true, true, -1)
    elseif f35_local4 == 3 then
        f35_arg2:AddSubGoal(GOAL_COMMON_LeaveTarget, f35_arg1:GetRandam_Int(1.5, 3), TARGET_ENE_0, 7, TARGET_ENE_0, true, -1)
    end
    
end

Goal.Update = function (f36_arg0, f36_arg1, f36_arg2)
    return Update_Default_NoSubGoal(f36_arg0, f36_arg1, f36_arg2)
    
end


