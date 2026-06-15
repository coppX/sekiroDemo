RegisterTableGoal(GOAL_MurabitoZombie_kuwa_genkaku_151030_Battle, "GOAL_MurabitoZombie_kuwa_genkaku_151030_Battle")
REGISTER_GOAL_NO_UPDATE(GOAL_MurabitoZombie_kuwa_genkaku_151030_Battle, true)

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
    elseif f2_arg1:GetNpcThinkParamID() == 15109300 and not f2_arg1:HasSpecialEffectId(TARGET_SELF, 5020) then
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
        if f2_local3 >= 7 then
            f2_local0[5] = 100
            f2_local0[7] = 400
            f2_local0[23] = 100
            f2_local0[28] = 100
            f2_local0[29] = 0
        elseif f2_local3 >= 3 then
            f2_local0[5] = 100
            f2_local0[23] = 500
            f2_local0[24] = 100
            f2_local0[28] = 100
            f2_local0[29] = 100
        else
            f2_local0[23] = 100
            f2_local0[24] = 300
            f2_local0[28] = 200
            f2_local0[29] = 300
        end
    elseif f2_local4 == 1 and f2_arg1:GetTeamOrder(ORDER_TYPE_Role) == ROLE_TYPE_Torimaki then
        if f2_local3 >= 7 then
            f2_local0[1] = 0
            f2_local0[2] = 0
            f2_local0[5] = 100
            f2_local0[7] = 300
            f2_local0[23] = 100
            f2_local0[28] = 100
            f2_local0[29] = 0
        elseif f2_local3 >= 3 then
            f2_local0[5] = 100
            f2_local0[23] = 100
            f2_local0[24] = 1
            f2_local0[28] = 100
        else
            f2_local0[5] = 100
            f2_local0[23] = 100
            f2_local0[24] = 1
            f2_local0[28] = 100
        end
    elseif f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 110030) then
        f2_local0[28] = 100
    elseif f2_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_B, 180) then
        f2_local0[21] = 100
        f2_local0[22] = 1
    elseif f2_local3 >= 10 then
        f2_local0[1] = 500
        f2_local0[2] = 500
    elseif f2_local3 > 3 then
        f2_local0[1] = 600
        f2_local0[2] = 400
    else
        f2_local0[1] = 500
        f2_local0[2] = 400
        f2_local0[24] = 100
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
    f2_local0[1] = SetCoolTime(f2_arg1, f2_arg2, 3000, 5, f2_local0[1], 1)
    f2_local0[2] = SetCoolTime(f2_arg1, f2_arg2, 3003, 5, f2_local0[2], 1)
    f2_local0[5] = SetCoolTime(f2_arg1, f2_arg2, 3025, 10, f2_local0[5], 1)
    f2_local1[1] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act01)
    f2_local1[2] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act02)
    f2_local1[5] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act05)
    f2_local1[6] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act06)
    f2_local1[7] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act07)
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
    local f3_local0 = 4.7 - f3_arg0:GetMapHitRadius(TARGET_SELF) + (f3_arg0:GetRandam_Float(0, 2.5) - 0.8)
    local f3_local1 = f3_local0
    local f3_local2 = f3_local0 + 7
    local f3_local3 = 100
    local f3_local4 = 0
    local f3_local5 = 1.5
    local f3_local6 = 2
    Approach_Act_Flex(f3_arg0, f3_arg1, f3_local0, f3_local1, f3_local2, f3_local3, f3_local4, f3_local5, f3_local6)
    local f3_local7 = 2.6 - f3_arg0:GetMapHitRadius(TARGET_SELF) + 0.5
    local f3_local8 = 3.5 - f3_arg0:GetMapHitRadius(TARGET_SELF) + 0.5
    local f3_local9 = 0
    local f3_local10 = 0
    local f3_local11 = f3_arg0:GetRandam_Int(1, 100)
    if f3_local11 <= 60 then
        f3_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3000, TARGET_ENE_0, f3_local7, f3_local9, f3_local10, 0, 0)
        f3_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3001, TARGET_ENE_0, 9999, 0, 0)
    else
        f3_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3000, TARGET_ENE_0, f3_local8, f3_local9, f3_local10, 0, 0)
        f3_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3002, TARGET_ENE_0, 9999, 0, 0)
    end
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act02 = function (f4_arg0, f4_arg1, f4_arg2)
    local f4_local0 = 5 - f4_arg0:GetMapHitRadius(TARGET_SELF) + (f4_arg0:GetRandam_Float(0, 2.5) - 0.8)
    local f4_local1 = f4_local0
    local f4_local2 = f4_local0 + 7
    local f4_local3 = 100
    local f4_local4 = 0
    local f4_local5 = 1.5
    local f4_local6 = 2
    Approach_Act_Flex(f4_arg0, f4_arg1, f4_local0, f4_local1, f4_local2, f4_local3, f4_local4, f4_local5, f4_local6)
    local f4_local7 = 0
    local f4_local8 = 0
    f4_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3003, TARGET_ENE_0, 9999, f4_local7, f4_local8, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act05 = function (f5_arg0, f5_arg1, f5_arg2)
    local f5_local0 = 0
    local f5_local1 = 0
    f5_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3025, TARGET_ENE_0, 9999, f5_local0, f5_local1, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act06 = function (f6_arg0, f6_arg1, f6_arg2)
    local f6_local0 = -1
    local f6_local1 = f6_arg0:GetRandam_Int(1, 2)
    local f6_local2 = f6_arg0:GetRandam_Int(0, 1)
    local f6_local3 = 3
    local f6_local4 = f6_arg0:GetRandam_Int(30, 45)
    if SpaceCheck(f6_arg0, f6_arg1, 180, 1) == true then
        f6_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 10, TARGET_ENE_0, 8, TARGET_ENE_0, true, f6_local0)
    else
        f6_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f6_local3, TARGET_ENE_0, f6_local2, f6_local4, true, true, f6_local0)
    end
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act07 = function (f7_arg0, f7_arg1, f7_arg2)
    local f7_local0 = 7
    local f7_local1 = 10
    local f7_local2 = 15
    local f7_local3 = 0
    local f7_local4 = 0
    local f7_local5 = 1.5
    local f7_local6 = 2
    f7_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 10, TARGET_ENE_0, 6, TARGET_SELF, false, -1)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act15 = function (f8_arg0, f8_arg1, f8_arg2)
    local f8_local0 = 0
    local f8_local1 = 0
    f8_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3031, TARGET_ENE_0, 9999, f8_local0, f8_local1, 0, 0)
    GetWellSpace_Odds = 0
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
    local f10_local2 = f10_arg0:GetDist(TARGET_FRI_0)
    local f10_local3 = f10_arg0:GetRandam_Int(1, 100)
    if SpaceCheck(f10_arg0, f10_arg1, -45, 2) == true and SpaceCheck(f10_arg0, f10_arg1, 45, 2) == true and f10_local2 >= 2.5 then
        if f10_local3 <= 50 then
            f10_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f10_local0, 5212, TARGET_ENE_0, f10_local1, AI_DIR_TYPE_L, 0)
        else
            f10_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f10_local0, 5213, TARGET_ENE_0, f10_local1, AI_DIR_TYPE_R, 0)
        end
    elseif f10_arg0:IsInsideTarget(TARGET_FRI_0, AI_DIR_TYPE_R, 100) and SpaceCheck(f10_arg0, f10_arg1, -45, 2) == true and f10_local2 <= 2.5 then
        f10_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f10_local0, 5212, TARGET_ENE_0, f10_local1, AI_DIR_TYPE_L, 0)
    elseif f10_arg0:IsInsideTarget(TARGET_FRI_0, AI_DIR_TYPE_L, 100) and SpaceCheck(f10_arg0, f10_arg1, 45, 2) == true and f10_local2 <= 2.5 then
        f10_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f10_local0, 5213, TARGET_ENE_0, f10_local1, AI_DIR_TYPE_R, 0)
    elseif SpaceCheck(f10_arg0, f10_arg1, -45, 2) == true and SpaceCheck(f10_arg0, f10_arg1, 45, 2) == true then
        if f10_local3 <= 50 then
            f10_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f10_local0, 5212, TARGET_ENE_0, f10_local1, AI_DIR_TYPE_L, 0)
        else
            f10_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f10_local0, 5213, TARGET_ENE_0, f10_local1, AI_DIR_TYPE_R, 0)
        end
    elseif SpaceCheck(f10_arg0, f10_arg1, -45, 2) == true then
        f10_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f10_local0, 5212, TARGET_ENE_0, f10_local1, AI_DIR_TYPE_L, 0)
    elseif SpaceCheck(f10_arg0, f10_arg1, 45, 2) == true then
        f10_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f10_local0, 5213, TARGET_ENE_0, f10_local1, AI_DIR_TYPE_R, 0)
    else
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act23 = function (f11_arg0, f11_arg1, f11_arg2)
    local f11_local0 = f11_arg0:GetDist(TARGET_ENE_0)
    local f11_local1 = f11_arg0:GetDist(TARGET_FRI_0)
    local f11_local2 = f11_arg0:GetSp(TARGET_SELF)
    local f11_local3 = 20
    local f11_local4 = f11_arg0:GetRandam_Int(1, 100)
    local f11_local5 = -1
    local f11_local6 = f11_arg0:GetRandam_Int(0, 1)
    if f11_arg0:IsInsideTarget(TARGET_FRI_0, AI_DIR_TYPE_R, 100) and SpaceCheck(f11_arg0, f11_arg1, -90, 1) == true and f11_local1 <= 2.5 then
        f11_local6 = 0
    elseif f11_arg0:IsInsideTarget(TARGET_FRI_0, AI_DIR_TYPE_L, 100) and SpaceCheck(f11_arg0, f11_arg1, 90, 1) == true and f11_local1 <= 2.5 then
        f11_local6 = 1
    end
    local f11_local7 = 3
    local f11_local8 = f11_arg0:GetRandam_Int(30, 45)
    f11_arg0:SetNumber(10, f11_local6)
    f11_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f11_local7, TARGET_ENE_0, f11_local6, f11_local8, true, true, f11_local5):TimingSetTimer(2, 4, UPDATE_SUCCESS)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act24 = function (f12_arg0, f12_arg1, f12_arg2)
    local f12_local0 = f12_arg0:GetDist(TARGET_ENE_0)
    local f12_local1 = 3
    local f12_local2 = 0
    local f12_local3 = 5211
    if SpaceCheck(f12_arg0, f12_arg1, 180, 2) ~= true or SpaceCheck(f12_arg0, f12_arg1, 180, 4) ~= true or f12_local0 > 4 then
    else
        f12_local3 = 5211
        if false then
        else
        end
    end
    f12_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f12_local1, f12_local3, TARGET_ENE_0, f12_local2, AI_DIR_TYPE_B, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
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
    local f15_local2 = f15_local1 / math.tan(math.deg(30))
    local f15_local3 = f15_arg0:GetRandam_Int(0, 1)
    if f15_local1 >= 3 then
        if f15_local2 + 1 <= f15_local0 then
            if SpaceCheck(f15_arg0, f15_arg1, 0, 4) == true then
                f15_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.1, TARGET_ENE_0, f15_local2, TARGET_SELF, false, -1)
            elseif SpaceCheck(f15_arg0, f15_arg1, 0, 3) == true then
                f15_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.5, TARGET_ENE_0, f15_local2, TARGET_SELF, true, -1)
            end
        elseif f15_local0 <= f15_local2 - 1 then
            f15_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 10, TARGET_ENE_0, f15_local2, TARGET_ENE_0, true, -1)
        end
    elseif SpaceCheck(f15_arg0, f15_arg1, 0, 4) == true then
        f15_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.1, TARGET_ENE_0, 0, TARGET_SELF, false, -1)
    elseif SpaceCheck(f15_arg0, f15_arg1, 0, 3) == true then
        f15_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.5, TARGET_ENE_0, 0, TARGET_SELF, true, -1)
    elseif SpaceCheck(f15_arg0, f15_arg1, 0, 1) == false then
        f15_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 0.5, TARGET_ENE_0, 999, TARGET_ENE_0, true, -1)
    end
    f15_arg0:SetNumber(10, f15_local3)
    f15_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, 3, TARGET_ENE_0, f15_local3, f15_arg0:GetRandam_Int(30, 45), true, true, -1)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act28 = function (f16_arg0, f16_arg1, f16_arg2)
    local f16_local0 = f16_arg0:GetDist(TARGET_ENE_0)
    local f16_local1 = f16_arg0:GetRandam_Float(1, 3.5)
    local f16_local2 = 1.5
    local f16_local3 = f16_arg0:GetRandam_Int(30, 45)
    local f16_local4 = -1
    local f16_local5 = f16_arg0:GetRandam_Int(0, 1)
    if f16_local0 <= 7 then
        f16_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f16_local1, TARGET_ENE_0, f16_local5, f16_local3, true, true, f16_local4)
    elseif f16_local0 <= 10 then
        f16_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, f16_local2, TARGET_ENE_0, 7.9, TARGET_SELF, true, -1)
    else
        f16_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, f16_local2, TARGET_ENE_0, 9.9, TARGET_SELF, false, -1)
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act29 = function (f17_arg0, f17_arg1, f17_arg2)
    local f17_local0 = f17_arg0:GetDist(TARGET_ENE_0)
    local f17_local1 = 7
    local f17_local2 = 0
    local f17_local3 = f17_arg0:GetRandam_Float(1, 3.5)
    f17_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, f17_local3, TARGET_ENE_0, f17_local1, TARGET_ENE_0, true, -1)
    
end

Goal.Act35 = function (f18_arg0, f18_arg1, f18_arg2)
    local f18_local0 = f18_arg0:GetDist(TARGET_ENE_0)
    local f18_local1 = f18_arg0:GetRandam_Int(1, 100)
    local f18_local2 = f18_arg0:GetRandam_Int(0, 1)
    local f18_local3 = f18_arg0:GetRandam_Float(2, 3.5)
    local f18_local4 = 3
    local f18_local5 = 0
    local f18_local6 = f18_arg0:GetDist(TARGET_FRI_0)
    local f18_local7 = f18_arg0:GetRandam_Int(1, 100)
    local f18_local8 = f18_arg0:GetRandam_Float(6.5, 7.5)
    local f18_local9 = f18_arg0:GetRandam_Float(5.5, 6.5)
    local f18_local10 = 999
    local f18_local11 = 100
    if f18_local0 >= 10 then
        Approach_Act(f18_arg0, f18_arg1, f18_local8, f18_local10, 0, 3)
    elseif f18_local0 >= 5 then
    elseif f18_local0 >= 3.5 then
        f18_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 3, TARGET_ENE_0, f18_local8, TARGET_ENE_0, false, 9910)
    else
        f18_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 5, 5201, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 2)
    end
    f18_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f18_local3, TARGET_ENE_0, f18_local2, f18_arg0:GetRandam_Int(30, 45), true, true, 9910):TimingSetTimer(2, 4, UPDATE_SUCCESS)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act36 = function (f19_arg0, f19_arg1, f19_arg2)
    local f19_local0 = f19_arg0:GetStringIndexedNumber("Warp_Point_Back")
    f19_arg0:SetNumber(2, f19_local0)
    f19_arg0:SetEventMoveTarget(f19_local0)
    f19_arg1:AddSubGoal(GOAL_COMMON_ToTargetWarp, 10, POINT_EVENT, AI_DIR_TYPE_F, 0, TARGET_ENE_0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act37 = function (f20_arg0, f20_arg1, f20_arg2)
    local f20_local0 = f20_arg0:GetStringIndexedNumber("Warp_Point_Center")
    f20_arg0:SetNumber(2, f20_local0)
    f20_arg0:SetEventMoveTarget(f20_local0)
    f20_arg1:AddSubGoal(GOAL_COMMON_ToTargetWarp, 10, POINT_EVENT, AI_DIR_TYPE_F, 0, TARGET_ENE_0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act38 = function (f21_arg0, f21_arg1, f21_arg2)
    local f21_local0 = f21_arg0:GetStringIndexedNumber("Warp_Point_Front")
    f21_arg0:SetNumber(2, f21_local0)
    f21_arg0:SetEventMoveTarget(f21_local0)
    f21_arg1:AddSubGoal(GOAL_COMMON_ToTargetWarp, 10, POINT_EVENT, AI_DIR_TYPE_F, 0, TARGET_ENE_0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act40 = function (f22_arg0, f22_arg1, f22_arg2)
    local f22_local0 = f22_arg0:GetRandam_Int(9992960, 9992967)
    f22_arg0:SetNumber(2, f22_local0)
    f22_arg0:SetEventMoveTarget(f22_local0)
    f22_arg1:AddSubGoal(GOAL_COMMON_ToTargetWarp, 10, POINT_EVENT, AI_DIR_TYPE_F, 0, TARGET_ENE_0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act41 = function (f23_arg0, f23_arg1, f23_arg2)
    local f23_local0 = f23_arg0:GetRandam_Int(9992964, 9992971)
    f23_arg0:SetNumber(2, f23_local0)
    f23_arg0:SetEventMoveTarget(f23_local0)
    f23_arg1:AddSubGoal(GOAL_COMMON_ToTargetWarp, 10, POINT_EVENT, AI_DIR_TYPE_F, 0, TARGET_ENE_0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act42 = function (f24_arg0, f24_arg1, f24_arg2)
    local f24_local0 = f24_arg0:GetRandam_Int(9992968, 9992975)
    f24_arg0:SetNumber(2, f24_local0)
    f24_arg0:SetEventMoveTarget(f24_local0)
    f24_arg1:AddSubGoal(GOAL_COMMON_ToTargetWarp, 10, POINT_EVENT, AI_DIR_TYPE_F, 0, TARGET_ENE_0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act43 = function (f25_arg0, f25_arg1, f25_arg2)
    local f25_local0 = f25_arg0:GetRandam_Float(0, 1)
    local f25_local1 = f25_arg0:GetRandam_Int(9992810, 9992817)
    f25_arg0:SetNumber(2, f25_local1)
    f25_arg0:SetEventMoveTarget(f25_local1)
    f25_arg1:AddSubGoal(GOAL_COMMON_ToTargetWarp, 10, POINT_EVENT, AI_DIR_TYPE_F, f25_local0, TARGET_ENE_0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act44 = function (f26_arg0, f26_arg1, f26_arg2)
    local f26_local0 = f26_arg0:GetRandam_Int(0, 1)
    local f26_local1 = f26_arg0:GetRandam_Int(9992800, 9992807)
    f26_arg0:SetNumber(2, f26_local1)
    f26_arg0:SetEventMoveTarget(f26_local1)
    f26_arg1:AddSubGoal(GOAL_COMMON_ToTargetWarp, 10, POINT_EVENT, AI_DIR_TYPE_F, f26_local0, TARGET_ENE_0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Interrupt = function (f27_arg0, f27_arg1, f27_arg2)
    local f27_local0 = f27_arg1:GetSpecialEffectActivateInterruptType(0)
    if f27_arg1:IsLadderAct(TARGET_SELF) then
        return false
    end
    if not f27_arg1:HasSpecialEffectId(TARGET_SELF, 200004) then
        return false
    end
    if f27_arg1:IsInterupt(INTERUPT_Damaged) then
        return f27_arg0.Damaged(f27_arg1, f27_arg2)
    end
    if f27_arg1:IsInterupt(INTERUPT_ActivateSpecialEffect) and f27_local0 == 3509070 then
        f27_arg2:ClearSubGoal()
        f27_arg2:AddSubGoal(GOAL_COMMON_AttackImmediateAction, 1, 3031, TARGET_ENE_0, 9999, 0, 0, 0, 0)
        return true
    end
    if f27_arg1:GetSpecialEffectActivateInterruptType(0) == 110124 then
        f27_arg2:ClearSubGoal()
        f27_arg1:Replaning()
        return false
    end
    return false
    
end

Goal.Parry = function (f28_arg0, f28_arg1, f28_arg2)
    local f28_local0 = f28_arg0:GetHpRate(TARGET_SELF)
    local f28_local1 = f28_arg0:GetDist(TARGET_ENE_0)
    local f28_local2 = f28_arg0:GetSp(TARGET_SELF)
    local f28_local3 = f28_arg0:GetRandam_Int(1, 100)
    local f28_local4 = 0
    if not f28_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) or not f28_arg0:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_F, 90, 3) or f28_arg0:HasSpecialEffectId(TARGET_ENE_0, 109012) then
    elseif f28_arg0:IsTargetGuard(TARGET_SELF) then
        if f28_arg0:HasSpecialEffectId(TARGET_ENE_0, 109970) then
        else
            f28_arg1:ClearSubGoal()
            f28_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3100, TARGET_ENE_0, 9999, 0)
            return true
        end
    elseif f28_arg0:HasSpecialEffectId(TARGET_ENE_0, 109970) then
        f28_arg1:ClearSubGoal()
        f28_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3101, TARGET_ENE_0, 9999, 0)
        return true
    else
        f28_arg1:ClearSubGoal()
        f28_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3100, TARGET_ENE_0, 9999, 0)
        return true
    end
    return false
    
end

Goal.Damaged = function (f29_arg0, f29_arg1, f29_arg2)
    local f29_local0 = f29_arg0:GetHpRate(TARGET_SELF)
    local f29_local1 = f29_arg0:GetDist(TARGET_ENE_0)
    local f29_local2 = f29_arg0:GetSp(TARGET_SELF)
    local f29_local3 = f29_arg0:GetRandam_Int(1, 100)
    local f29_local4 = 0
    if f29_local3 <= 33 then
        f29_arg1:ClearSubGoal()
        f29_arg1:AddSubGoal(GOAL_COMMON_SpinStep, StepLife, 5211, TARGET_ENE_0, TurnTime, AI_DIR_TYPE_B, 0):TimingSetTimer(3, 6, UPDATE_SUCCESS)
        return true
    elseif f29_local3 <= 67 then
    end
    return false
    
end

Goal.ActAfter_AdjustSpace = function (f30_arg0, f30_arg1, f30_arg2)
    f30_arg1:AddSubGoal(GOAL_MurabitoZombie_kuwa_genkaku_151030_AfterAttackAct, 10)
    
end

Goal.Update = function (f31_arg0, f31_arg1, f31_arg2)
    return Update_Default_NoSubGoal(f31_arg0, f31_arg1, f31_arg2)
    
end

Goal.Terminate = function (f32_arg0, f32_arg1, f32_arg2)
    
end

RegisterTableGoal(GOAL_MurabitoZombie_kuwa_genkaku_151030_AfterAttackAct, "GOAL_MurabitoZombie_kuwa_genkaku_151030_AfterAttackAct")
REGISTER_GOAL_NO_SUB_GOAL(GOAL_MurabitoZombie_kuwa_genkaku_151030_AfterAttackAct, true)

Goal.Activate = function (f33_arg0, f33_arg1, f33_arg2)
    local f33_local0 = f33_arg1:GetDist(TARGET_ENE_0)
    local f33_local1 = f33_arg1:GetToTargetAngle(TARGET_ENE_0)
    local f33_local2 = f33_arg1:GetHpRate(TARGET_SELF)
    local f33_local3 = {}
    if f33_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_B, 160) then
        f33_local3[1] = 100
        f33_local3[2] = 0
        f33_local3[3] = 0
    elseif f33_local0 >= 7 then
        f33_local3[1] = 100
        f33_local3[2] = 0
        f33_local3[3] = 0
    elseif f33_local0 >= 3 then
        f33_local3[1] = 30
        f33_local3[2] = 45
        f33_local3[3] = 25
    else
        f33_local3[1] = 30
        f33_local3[2] = 20
        f33_local3[3] = 50
    end
    local f33_local4 = SelectOddsIndex(f33_arg1, f33_local3)
    if f33_local4 == 1 then
    elseif f33_local4 == 2 then
        f33_arg2:AddSubGoal(GOAL_COMMON_SidewayMove, f33_arg1:GetRandam_Float(0, 1), TARGET_ENE_0, f33_arg1:GetRandam_Int(1.5, 3), f33_arg1:GetRandam_Int(30, 45), true, true, -1)
    elseif f33_local4 == 3 then
        f33_arg2:AddSubGoal(GOAL_COMMON_LeaveTarget, f33_arg1:GetRandam_Int(1.5, 3), TARGET_ENE_0, 7, TARGET_ENE_0, true, -1)
    end
    
end

Goal.Update = function (f34_arg0, f34_arg1, f34_arg2)
    return Update_Default_NoSubGoal(f34_arg0, f34_arg1, f34_arg2)
    
end


