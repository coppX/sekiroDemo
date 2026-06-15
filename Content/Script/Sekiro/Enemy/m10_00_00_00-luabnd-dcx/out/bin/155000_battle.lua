RegisterTableGoal(GOAL_Yatou_katanaYumi_155000_Battle, "GOAL_Yatou_katanaYumi_155000_Battle")
REGISTER_GOAL_NO_UPDATE(GOAL_Yatou_katanaYumi_155000_Battle, true)

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
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 3155020)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 5027)
    Set_ConsecutiveGuardCount_Interrupt(f2_arg1)
    f2_arg1:DeleteObserve(0)
    f2_arg1:DeleteObserve(1)
    f2_arg1:DeleteObserve(2)
    if f2_arg0.Kengeki_Activate(f2_arg0, f2_arg1, f2_arg2) then
        return
    end
    if f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 110060) then
        if f2_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) then
            f2_local0[26] = 100
        else
            f2_local0[21] = 100
        end
    elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 200050) then
        f2_local0[20] = 100
    elseif Common_ActivateAct(f2_arg1, f2_arg2) then
    elseif f2_arg1:CheckDoesExistPath(TARGET_ENE_0, AI_DIR_TYPE_F, 0, 0) == false then
        if f2_arg1:HasSpecialEffectId(TARGET_SELF, 3155560) then
            f2_local0[27] = 100
        else
            f2_local0[7] = 100
            f2_local0[27] = 100
        end
    elseif f2_local4 == 1 and f2_arg1:GetTeamOrder(ORDER_TYPE_Role) == ROLE_TYPE_Kankyaku then
        KankyakuAct(f2_arg1, f2_arg2)
    elseif f2_local4 == 1 and f2_arg1:GetTeamOrder(ORDER_TYPE_Role) == ROLE_TYPE_Torimaki then
        if TorimakiAct(f2_arg1, f2_arg2) then
            f2_local0[3] = 100
            f2_local0[4] = 100
            f2_local0[15] = 100
        end
    elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 3155550) then
        f2_local0[28] = 200
    elseif f2_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_B, 180) then
        f2_local0[21] = 100
        f2_local0[22] = 1
    elseif f2_arg1:IsTargetGuard(TARGET_ENE_0) and f2_arg1:HasSpecialEffectId(TARGET_SELF, 3155110) then
        f2_local0[42] = 100
    elseif f2_arg1:GetNumber(0) == 0 and f2_arg1:HasSpecialEffectId(TARGET_SELF, 5010) then
        f2_local0[4] = 100
    elseif f2_local3 >= 10 then
        f2_local0[1] = 0
        f2_local0[2] = 0
        f2_local0[3] = 0
        f2_local0[4] = 100
        f2_local0[5] = 100
        f2_local0[6] = 100
        f2_local0[15] = 200
        f2_local0[16] = 0
        f2_local0[23] = 100
    elseif f2_local3 >= 7 then
        f2_local0[1] = 0
        f2_local0[2] = 50
        f2_local0[3] = 0
        f2_local0[4] = 30
        f2_local0[5] = 100
        f2_local0[6] = 100
        f2_local0[15] = 50
        f2_local0[16] = 50
    elseif f2_local3 >= 5 then
        f2_local0[1] = 0
        f2_local0[2] = 100
        f2_local0[3] = 0
        f2_local0[4] = 0
        f2_local0[5] = 100
        f2_local0[6] = 300
        f2_local0[15] = 50
        f2_local0[16] = 100
        f2_local0[24] = 100
    elseif f2_local3 > 3 then
        f2_local0[1] = 50
        f2_local0[2] = 100
        f2_local0[3] = 100
        f2_local0[4] = 200
        f2_local0[5] = 0
        f2_local0[6] = 0
        f2_local0[15] = 0
        f2_local0[16] = 30
        f2_local0[24] = 100
    else
        f2_local0[1] = 100
        f2_local0[2] = 100
        f2_local0[3] = 100
        f2_local0[4] = 0
        f2_local0[5] = 0
        f2_local0[6] = 0
        f2_local0[24] = 100
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
    if f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 109031) then
        f2_local0[1] = 100
        f2_local0[2] = 0
        f2_local0[3] = 0
        f2_local0[4] = 0
        f2_local0[5] = 0
        f2_local0[15] = 0
        f2_local0[16] = 0
    end
    f2_local0[1] = SetCoolTime(f2_arg1, f2_arg2, 3004, 8, f2_local0[1], 1)
    f2_local0[2] = SetCoolTime(f2_arg1, f2_arg2, 3003, 8, f2_local0[2], 1)
    f2_local0[3] = SetCoolTime(f2_arg1, f2_arg2, 3001, 8, f2_local0[3], 1)
    f2_local0[4] = SetCoolTime(f2_arg1, f2_arg2, 3000, 8, f2_local0[4], 1)
    f2_local0[5] = SetCoolTime(f2_arg1, f2_arg2, 3005, 8, f2_local0[5], 1)
    f2_local0[6] = SetCoolTime(f2_arg1, f2_arg2, 3009, 8, f2_local0[6], 1)
    f2_local0[8] = SetCoolTime(f2_arg1, f2_arg2, 3015, 8, f2_local0[8], 1)
    f2_local0[9] = SetCoolTime(f2_arg1, f2_arg2, 3018, 8, f2_local0[9], 1)
    f2_local0[10] = SetCoolTime(f2_arg1, f2_arg2, 3000, 5, f2_local0[10], 1)
    f2_local0[10] = SetCoolTime(f2_arg1, f2_arg2, 3030, 8, f2_local0[10], 1)
    f2_local0[11] = SetCoolTime(f2_arg1, f2_arg2, 3030, 8, f2_local0[11], 1)
    f2_local0[12] = SetCoolTime(f2_arg1, f2_arg2, 3000, 2, f2_local0[12], 1)
    f2_local0[13] = SetCoolTime(f2_arg1, f2_arg2, 3002, 2, f2_local0[13], 1)
    f2_local0[15] = SetCoolTime(f2_arg1, f2_arg2, 3007, 15, f2_local0[15], 1)
    f2_local0[16] = SetCoolTime(f2_arg1, f2_arg2, 3017, 10, f2_local0[16], 1)
    f2_local0[24] = SetCoolTime(f2_arg1, f2_arg2, 5211, 8, f2_local0[24], 0)
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
    f2_local1[15] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act15)
    f2_local1[16] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act16)
    f2_local1[20] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act20)
    f2_local1[21] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act21)
    f2_local1[22] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act22)
    f2_local1[23] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act23)
    f2_local1[24] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act24)
    f2_local1[25] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act25)
    f2_local1[26] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act26)
    f2_local1[27] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act27)
    f2_local1[28] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act28)
    f2_local1[41] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act41)
    f2_local1[42] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act42)
    local f2_local5 = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.ActAfter_AdjustSpace)
    Common_Battle_Activate(f2_arg1, f2_arg2, f2_local0, f2_local1, f2_local5, f2_local2)
    
end

Goal.Act01 = function (f3_arg0, f3_arg1, f3_arg2)
    local f3_local0 = 3 - f3_arg0:GetMapHitRadius(TARGET_SELF)
    local f3_local1 = 3 - f3_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f3_local2 = 3 - f3_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f3_local3 = 100
    local f3_local4 = 0
    local f3_local5 = 1.5
    local f3_local6 = 3
    local f3_local7 = f3_arg0:GetRandam_Int(1, 100)
    Approach_Act_Flex(f3_arg0, f3_arg1, f3_local0, f3_local1, f3_local2, f3_local3, f3_local4, f3_local5, f3_local6)
    local f3_local8 = 0
    local f3_local9 = 0
    f3_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3004, TARGET_ENE_0, 9999, f3_local8, f3_local9, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act02 = function (f4_arg0, f4_arg1, f4_arg2)
    local f4_local0 = 6.5 - f4_arg0:GetMapHitRadius(TARGET_SELF)
    local f4_local1 = 6.5 - f4_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f4_local2 = 6.5 - f4_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f4_local3 = 100
    local f4_local4 = 0
    local f4_local5 = 1.5
    local f4_local6 = 3
    Approach_Act_Flex(f4_arg0, f4_arg1, f4_local0, f4_local1, f4_local2, f4_local3, f4_local4, f4_local5, f4_local6)
    local f4_local7 = 2.5 - f4_arg0:GetMapHitRadius(TARGET_SELF)
    local f4_local8 = 0
    local f4_local9 = 0
    local f4_local10 = f4_arg0:GetDist(TARGET_ENE_0)
    f4_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 30, 3003, TARGET_ENE_0, 2.5, f4_local8, f4_local9, 0, 0)
    local f4_local11 = f4_arg0:GetRandam_Int(1, 100)
    if f4_local11 > 0 then
        f4_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3008, TARGET_ENE_0, 9999, 0, 0)
    else
        f4_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3011, TARGET_ENE_0, 9999, 0, 0)
    end
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act03 = function (f5_arg0, f5_arg1, f5_arg2)
    local f5_local0 = 3.5 - f5_arg0:GetMapHitRadius(TARGET_SELF)
    local f5_local1 = 3.5 - f5_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f5_local2 = 3.5 - f5_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f5_local3 = 100
    local f5_local4 = 0
    local f5_local5 = 1.5
    local f5_local6 = 3
    Approach_Act_Flex(f5_arg0, f5_arg1, f5_local0, f5_local1, f5_local2, f5_local3, f5_local4, f5_local5, f5_local6)
    local f5_local7 = 0
    local f5_local8 = 0
    f5_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3001, TARGET_ENE_0, 9999, f5_local7, f5_local8, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act04 = function (f6_arg0, f6_arg1, f6_arg2)
    local f6_local0 = 4 - f6_arg0:GetMapHitRadius(TARGET_SELF)
    local f6_local1 = 4 - f6_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f6_local2 = 4 - f6_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f6_local3 = 100
    local f6_local4 = 0
    local f6_local5 = 1.5
    local f6_local6 = 3
    Approach_Act_Flex(f6_arg0, f6_arg1, f6_local0, f6_local1, f6_local2, f6_local3, f6_local4, f6_local5, f6_local6)
    local f6_local7 = 2.5 - f6_arg0:GetMapHitRadius(TARGET_SELF)
    local f6_local8 = 0
    local f6_local9 = 0
    local f6_local10 = f6_arg0:GetDist(TARGET_ENE_0)
    f6_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 30, 3000, TARGET_ENE_0, 4, f6_local8, f6_local9, 0, 0)
    f6_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3016, TARGET_ENE_0, 9999, 0, 0)
    f6_arg0:SetNumber(0, 1)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act05 = function (f7_arg0, f7_arg1, f7_arg2)
    local f7_local0 = 5.5 - f7_arg0:GetMapHitRadius(TARGET_SELF)
    local f7_local1 = 5.5 - f7_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f7_local2 = 5.5 - f7_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f7_local3 = 100
    local f7_local4 = 0
    local f7_local5 = 1.5
    local f7_local6 = 3
    Approach_Act_Flex(f7_arg0, f7_arg1, f7_local0, f7_local1, f7_local2, f7_local3, f7_local4, f7_local5, f7_local6)
    local f7_local7 = 3 - f7_arg0:GetMapHitRadius(TARGET_SELF)
    local f7_local8 = 0
    local f7_local9 = 0
    local f7_local10 = f7_arg0:GetDist(TARGET_ENE_0)
    f7_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 30, 3005, TARGET_ENE_0, f7_local7, f7_local8, f7_local9, 0, 0)
    f7_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3013, TARGET_ENE_0, 9999, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act06 = function (f8_arg0, f8_arg1, f8_arg2)
    local f8_local0 = 7.6 - f8_arg0:GetMapHitRadius(TARGET_SELF)
    local f8_local1 = 7.6 - f8_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f8_local2 = 7.6 - f8_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f8_local3 = 100
    local f8_local4 = 0
    local f8_local5 = 1.5
    local f8_local6 = 3
    Approach_Act_Flex(f8_arg0, f8_arg1, f8_local0, f8_local1, f8_local2, f8_local3, f8_local4, f8_local5, f8_local6)
    local f8_local7 = 0
    local f8_local8 = 0
    f8_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3009, TARGET_ENE_0, 9999, f8_local7, f8_local8, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act07 = function (f9_arg0, f9_arg1, f9_arg2)
    local f9_local0 = f9_arg0:GetDist(TARGET_ENE_0)
    local f9_local1 = 10 - f9_arg0:GetMapHitRadius(TARGET_SELF)
    local f9_local2 = 10 - f9_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f9_local3 = 10 - f9_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f9_local4 = 100
    local f9_local5 = 0
    local f9_local6 = 1.5
    local f9_local7 = 3
    local f9_local8 = 3010
    Approach_Act_Flex(f9_arg0, f9_arg1, f9_local1, f9_local2, f9_local3, f9_local4, f9_local5, f9_local6, f9_local7)
    f9_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3010, TARGET_ENE_0, 9999, TurnTime, FrontAngle, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act08 = function (f10_arg0, f10_arg1, f10_arg2)
    local f10_local0 = 4 - f10_arg0:GetMapHitRadius(TARGET_SELF)
    local f10_local1 = 4 - f10_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f10_local2 = 4 - f10_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f10_local3 = 100
    local f10_local4 = 0
    local f10_local5 = 1.5
    local f10_local6 = 3
    local f10_local7 = f10_arg0:GetRandam_Int(1, 100)
    Approach_Act_Flex(f10_arg0, f10_arg1, f10_local0, f10_local1, f10_local2, f10_local3, f10_local4, f10_local5, f10_local6)
    local f10_local8 = 4 - f10_arg0:GetMapHitRadius(TARGET_SELF)
    local f10_local9 = 4.5 - f10_arg0:GetMapHitRadius(TARGET_SELF)
    local f10_local10 = 0
    local f10_local11 = 0
    local f10_local12 = 3000
    local f10_local13 = 3012
    local f10_local14 = 3013
    f10_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3015, TARGET_ENE_0, f10_local8, f10_local10, f10_local11, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act09 = function (f11_arg0, f11_arg1, f11_arg2)
    local f11_local0 = 3 - f11_arg0:GetMapHitRadius(TARGET_SELF)
    local f11_local1 = 3 - f11_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f11_local2 = 3 - f11_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f11_local3 = 100
    local f11_local4 = 0
    local f11_local5 = 1.5
    local f11_local6 = 3
    local f11_local7 = f11_arg0:GetRandam_Int(1, 100)
    Approach_Act_Flex(f11_arg0, f11_arg1, f11_local0, f11_local1, f11_local2, f11_local3, f11_local4, f11_local5, f11_local6)
    local f11_local8 = 3 - f11_arg0:GetMapHitRadius(TARGET_SELF)
    local f11_local9 = 0
    local f11_local10 = 0
    f11_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3018, TARGET_ENE_0, f11_local8, f11_local9, f11_local10, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act15 = function (f12_arg0, f12_arg1, f12_arg2)
    local f12_local0 = 0
    local f12_local1 = 0
    local f12_local2 = f12_arg0:GetRandam_Int(1, 100)
    if f12_local2 < 50 then
        f12_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3007, TARGET_ENE_0, 5, f12_local0, f12_local1, 0, 0)
    else
        f12_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3014, TARGET_ENE_0, 5, f12_local0, f12_local1, 0, 0)
    end
    local f12_local3 = 180
    local f12_local4 = 5
    f12_arg0:AddObserveArea(0, TARGET_SELF, TARGET_ENE_0, AI_DIR_TYPE_F, f12_local3, f12_local4)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act16 = function (f13_arg0, f13_arg1, f13_arg2)
    local f13_local0 = 0
    local f13_local1 = 0
    local f13_local2 = f13_arg0:GetDist(TARGET_ENE_0)
    f13_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 30, 3017, TARGET_ENE_0, 4, f13_local0, f13_local1, 0, 0)
    f13_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3019, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.Act20 = function (f14_arg0, f14_arg1, f14_arg2)
    local f14_local0 = 0
    local f14_local1 = 0
    local f14_local2 = f14_arg0:GetDist(TARGET_ENE_0)
    f14_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3040, TARGET_ENE_0, 5, f14_local0, f14_local1, 0, 0)
    
end

Goal.Act21 = function (f15_arg0, f15_arg1, f15_arg2)
    local f15_local0 = 3
    local f15_local1 = 45
    f15_arg1:AddSubGoal(GOAL_COMMON_Turn, f15_local0, TARGET_ENE_0, f15_local1, -1, GOAL_RESULT_Success, true)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act22 = function (f16_arg0, f16_arg1, f16_arg2)
    local f16_local0 = 3
    local f16_local1 = 0
    if SpaceCheck(f16_arg0, f16_arg1, -45, 2) == true then
        if SpaceCheck(f16_arg0, f16_arg1, 45, 2) == true then
            if f16_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                f16_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f16_local0, 5202, TARGET_ENE_0, f16_local1, AI_DIR_TYPE_L, 0)
            else
                f16_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f16_local0, 5203, TARGET_ENE_0, f16_local1, AI_DIR_TYPE_R, 0)
            end
        else
            f16_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f16_local0, 5202, TARGET_ENE_0, f16_local1, AI_DIR_TYPE_L, 0)
        end
    elseif SpaceCheck(f16_arg0, f16_arg1, 45, 2) == true then
        f16_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f16_local0, 5203, TARGET_ENE_0, f16_local1, AI_DIR_TYPE_R, 0)
    else
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act23 = function (f17_arg0, f17_arg1, f17_arg2)
    local f17_local0 = f17_arg0:GetSp(TARGET_SELF)
    local f17_local1 = 0
    local f17_local2 = f17_arg0:GetRandam_Int(1, 100)
    local f17_local3 = -1
    local f17_local4 = 0
    if SpaceCheck(f17_arg0, f17_arg1, -90, 1) == true then
        if SpaceCheck(f17_arg0, f17_arg1, 90, 1) == true then
            if f17_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                f17_local4 = 1
            else
                f17_local4 = 0
            end
        else
            f17_local4 = 0
        end
    elseif SpaceCheck(f17_arg0, f17_arg1, 90, 1) == true then
        f17_local4 = 1
    else
        GetWellSpace_Odds = 100
        return GetWellSpace_Odds
    end
    local f17_local5 = 1.8
    local f17_local6 = f17_arg0:GetRandam_Int(30, 45)
    f17_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f17_local5, TARGET_ENE_0, f17_local4, f17_local6, true, true, f17_local3)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act24 = function (f18_arg0, f18_arg1, f18_arg2)
    local f18_local0 = f18_arg0:GetDist(TARGET_ENE_0)
    local f18_local1 = 3
    local f18_local2 = 0
    local f18_local3 = 5211
    if SpaceCheck(f18_arg0, f18_arg1, 180, 2) ~= true or SpaceCheck(f18_arg0, f18_arg1, 180, 4) ~= true or f18_local0 > 4 then
    else
        f18_local3 = 5211
        if false then
        else
        end
    end
    f18_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f18_local1, f18_local3, TARGET_ENE_0, f18_local2, AI_DIR_TYPE_B, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act25 = function (f19_arg0, f19_arg1, f19_arg2)
    local f19_local0 = f19_arg0:GetRandam_Float(2, 4)
    local f19_local1 = f19_arg0:GetRandam_Float(1, 3)
    local f19_local2 = f19_arg0:GetDist(TARGET_ENE_0)
    local f19_local3 = -1
    if SpaceCheck(f19_arg0, f19_arg1, 180, 1) == true then
        f19_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, f19_local0, TARGET_ENE_0, f19_local1, TARGET_ENE_0, true, f19_local3)
    else
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act26 = function (f20_arg0, f20_arg1, f20_arg2)
    f20_arg1:AddSubGoal(GOAL_COMMON_Wait, 0.5, TARGET_SELF, 0, 0, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act27 = function (f21_arg0, f21_arg1, f21_arg2)
    local f21_local0 = f21_arg0:GetRandam_Int(1, 100)
    if YousumiAct_SubGoal(f21_arg0, f21_arg1, true, 60, 30) == false then
        GetWellSpace_Odds = 0
        return GetWellSpace_Odds
    end
    local f21_local1 = 0
    local f21_local2 = SpaceCheck_SidewayMove(f21_arg0, f21_arg1, 1)
    if f21_local2 == 0 then
        f21_local1 = 0
    elseif f21_local2 == 1 then
        f21_local1 = 1
    elseif f21_local2 == 2 then
        if f21_local0 <= 50 then
            f21_local1 = 0
        else
            f21_local1 = 1
        end
    else
        f21_arg1:AddSubGoal(GOAL_COMMON_Wait, 1, TARGET_SELF, 0, 0, 0)
        GetWellSpace_Odds = 0
        return GetWellSpace_Odds
    end
    f21_arg0:SetNumber(10, f21_local1)
    f21_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, 3, TARGET_ENE_0, f21_local1, f21_arg0:GetRandam_Int(30, 45), true, true, -1)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act28 = function (f22_arg0, f22_arg1, f22_arg2)
    local f22_local0 = f22_arg0:GetDist(TARGET_ENE_0)
    local f22_local1 = 1.5
    local f22_local2 = 1.5
    local f22_local3 = f22_arg0:GetRandam_Int(30, 45)
    local f22_local4 = -1
    local f22_local5 = f22_arg0:GetRandam_Int(0, 1)
    if f22_local0 <= 3 then
        f22_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f22_local1, TARGET_ENE_0, f22_local5, f22_local3, true, true, f22_local4)
    elseif f22_local0 <= 8 then
        f22_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, f22_local2, TARGET_ENE_0, 3, TARGET_SELF, true, -1)
    else
        f22_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, f22_local2, TARGET_ENE_0, 8, TARGET_SELF, false, -1)
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act41 = function (f23_arg0, f23_arg1, f23_arg2)
    local f23_local0 = 3.5
    local f23_local1 = f23_arg0:GetRandam_Int(30, 45)
    local f23_local2 = 0
    if SpaceCheck(f23_arg0, f23_arg1, -90, 1) == true then
        if SpaceCheck(f23_arg0, f23_arg1, 90, 1) == true then
            if f23_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                f23_local2 = 0
            else
                f23_local2 = 1
            end
        else
            f23_local2 = 0
        end
    elseif SpaceCheck(f23_arg0, f23_arg1, 90, 1) == true then
        f23_local2 = 1
    else
    end
    f23_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f23_local0, TARGET_ENE_0, f23_local2, f23_local1, true, true, -1)
    return GETWELLSPACE_ODDS
    
end

Goal.Act42 = function (f24_arg0, f24_arg1, f24_arg2)
    local f24_local0 = f24_arg0:GetDist(TARGET_ENE_0)
    local f24_local1 = f24_arg0:GetDistYSigned(TARGET_ENE_0)
    local f24_local2 = f24_local1 / math.tan(math.deg(30))
    local f24_local3 = f24_arg0:GetRandam_Int(0, 1)
    if SpaceCheck(f24_arg0, f24_arg1, 180, 1) == true then
        if f24_local0 <= 8 then
            f24_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 2, TARGET_ENE_0, 8, TARGET_ENE_0, true, -1)
        else
            if SpaceCheck(f24_arg0, f24_arg1, -90, 1) == true then
                if SpaceCheck(f24_arg0, f24_arg1, 90, 1) == true then
                    if f24_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                        f24_local3 = 1
                    else
                        f24_local3 = 0
                    end
                else
                    f24_local3 = 0
                end
            elseif SpaceCheck(f24_arg0, f24_arg1, 90, 1) == true then
                f24_local3 = 1
            else
                f24_arg1:AddSubGoal(GOAL_COMMON_Wait, 0.5, TARGET_SELF, 0, 0, 0)
            end
            f24_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, 1, TARGET_ENE_0, f24_local3, f24_arg0:GetRandam_Int(30, 45), true, true, -1)
        end
    else
        if SpaceCheck(f24_arg0, f24_arg1, -90, 1) == true then
            if SpaceCheck(f24_arg0, f24_arg1, 90, 1) == true then
                if f24_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                    f24_local3 = 1
                else
                    f24_local3 = 0
                end
            else
                f24_local3 = 0
            end
        elseif SpaceCheck(f24_arg0, f24_arg1, 90, 1) == true then
            f24_local3 = 1
        else
            f24_arg1:AddSubGoal(GOAL_COMMON_Wait, 0.5, TARGET_SELF, 0, 0, 0)
        end
        f24_arg0:SetNumber(10, f24_local3)
        f24_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, 3, TARGET_ENE_0, f24_local3, f24_arg0:GetRandam_Int(30, 45), true, true, -1)
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Interrupt = function (f25_arg0, f25_arg1, f25_arg2)
    local f25_local0 = f25_arg1:GetSpecialEffectActivateInterruptType(0)
    local f25_local1 = 90
    local f25_local2 = 4
    local f25_local3 = f25_arg1:GetDist(TARGET_ENE_0)
    local f25_local4 = 3
    local f25_local5 = 0
    local f25_local6 = 5211
    if f25_arg1:IsLadderAct(TARGET_SELF) then
        return false
    end
    if not f25_arg1:HasSpecialEffectId(TARGET_SELF, 200004) then
        return false
    end
    if f25_arg1:IsInterupt(INTERUPT_ParryTiming) then
        return Common_Parry(f25_arg1, f25_arg2, 0, 25, 0, 3102)
    end
    if f25_arg1:IsInterupt(INTERUPT_Damaged) then
        return f25_arg0.Damaged(f25_arg1, f25_arg2)
    end
    if f25_arg1:IsInterupt(INTERUPT_Inside_ObserveArea) and f25_arg1:IsInsideObserve(0) then
        f25_arg2:ClearSubGoal()
        if f25_arg1:IsFinishTimer(0) == true then
            f25_arg2:AddSubGoal(GOAL_COMMON_ComboFinal, 3, 3015, TARGET_ENE_0, 9999, 0, 0)
            f25_arg1:SetTimer(0, 30)
        else
            f25_arg0.Act16(f25_arg1, f25_arg2, paramTbl)
        end
        f25_arg1:DeleteObserve(0)
        return true
    end
    if f25_arg1:IsInterupt(INTERUPT_ActivateSpecialEffect) then
        if f25_local0 ~= 200200 then
            local f25_local7 = 200201
            if not f25_local7 then
                f25_local7 = 200205
                if not f25_local7 then
                    f25_local7 = 200206
                    if not f25_local7 then
                        f25_local7 = 200215
                        if not f25_local7 then
                        end
                    end
                end
            end
        end
        f25_arg1:SetStringIndexedNumber("kengekiCount", f25_arg1:GetStringIndexedNumber("kengekiCount") + 1)
    end
    if f25_arg1:IsInterupt(INTERUPT_ShootImpact) and f25_arg0.ShootReaction(f25_arg1, f25_arg2) then
        return true
    end
    return false
    
end

Goal.Damaged = function (f26_arg0, f26_arg1, f26_arg2)
    local f26_local0 = f26_arg0:GetHpRate(TARGET_SELF)
    local f26_local1 = f26_arg0:GetDist(TARGET_ENE_0)
    local f26_local2 = f26_arg0:GetSp(TARGET_SELF)
    local f26_local3 = f26_arg0:GetRandam_Int(1, 100)
    local f26_local4 = 0
    if f26_local3 <= 33 then
        f26_arg1:ClearSubGoal()
        f26_arg1:AddSubGoal(GOAL_COMMON_SpinStep, StepLife, 5211, TARGET_ENE_0, TurnTime, AI_DIR_TYPE_B, 0):TimingSetTimer(3, 6, UPDATE_SUCCESS)
        f26_arg0:SetStringIndexedNumber("kengekiCount", f26_arg0:GetStringIndexedNumber("kengekiCount") + 1)
        return true
    elseif f26_local3 <= 67 then
    end
    return false
    
end

Goal.ShootReaction = function (f27_arg0, f27_arg1)
    f27_arg1:ClearSubGoal()
    f27_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3100, TARGET_ENE_0, 9999, 0)
    return true
    
end

Goal.Kengeki_Activate = function (f28_arg0, f28_arg1, f28_arg2, f28_arg3)
    local f28_local0 = ReturnKengekiSpecialEffect(f28_arg1)
    if f28_local0 == 0 then
        return false
    end
    local f28_local1 = {}
    local f28_local2 = {}
    local f28_local3 = {}
    Common_Clear_Param(f28_local1, f28_local2, f28_local3)
    local f28_local4 = f28_arg1:GetDist(TARGET_ENE_0)
    local f28_local5 = f28_arg1:GetSp(TARGET_SELF)
    if f28_local5 <= 0 then
        f28_local1[50] = 100
    elseif f28_local0 == 200200 then
        if f28_local4 >= 2 then
            f28_local1[50] = 100
        elseif f28_local4 <= 0.2 then
            f28_local1[50] = 100
        else
            f28_local1[3] = 100
        end
    elseif f28_local0 == 200201 then
        if f28_local4 >= 2 then
            f28_local1[50] = 100
        elseif f28_local4 <= 0.2 then
            f28_local1[50] = 100
        else
            f28_local1[4] = 100
        end
    elseif f28_local0 == 200205 then
        if f28_local4 >= 2 then
            f28_local1[50] = 100
        elseif f28_local4 <= 0.2 then
            f28_local1[50] = 100
        else
            f28_local1[1] = 100
        end
    elseif f28_local0 == 200206 then
        if f28_local4 >= 2 then
            f28_local1[50] = 100
        elseif f28_local4 <= 0.2 then
            f28_local1[50] = 100
        else
            f28_local1[2] = 100
        end
    elseif f28_local0 == 200210 then
        if f28_local4 >= 2 then
            f28_local1[50] = 100
        elseif f28_local4 <= 0.2 then
            f28_local1[50] = 100
        else
            f28_local1[7] = 100
        end
    elseif f28_local0 == 200211 then
        if f28_local4 >= 2 then
            f28_local1[50] = 100
        elseif f28_local4 <= 0.2 then
            f28_local1[50] = 100
        else
            f28_local1[8] = 100
        end
    elseif f28_local0 == 200215 then
        if f28_local4 >= 2 then
            f28_local1[50] = 100
        elseif f28_local4 <= 0.2 then
            f28_local1[50] = 100
        else
            f28_local1[5] = 100
        end
    elseif f28_local0 == 200216 then
        if f28_local4 >= 2 then
            f28_local1[50] = 100
        elseif f28_local4 <= 0.2 then
            f28_local1[50] = 100
        else
            f28_local1[6] = 100
        end
    end
    f28_local2[1] = REGIST_FUNC(f28_arg1, f28_arg2, f28_arg0.Kengeki01)
    f28_local2[2] = REGIST_FUNC(f28_arg1, f28_arg2, f28_arg0.Kengeki02)
    f28_local2[3] = REGIST_FUNC(f28_arg1, f28_arg2, f28_arg0.Kengeki03)
    f28_local2[4] = REGIST_FUNC(f28_arg1, f28_arg2, f28_arg0.Kengeki04)
    f28_local2[5] = REGIST_FUNC(f28_arg1, f28_arg2, f28_arg0.Kengeki05)
    f28_local2[6] = REGIST_FUNC(f28_arg1, f28_arg2, f28_arg0.Kengeki06)
    f28_local2[7] = REGIST_FUNC(f28_arg1, f28_arg2, f28_arg0.Kengeki07)
    f28_local2[8] = REGIST_FUNC(f28_arg1, f28_arg2, f28_arg0.Kengeki08)
    f28_local2[50] = REGIST_FUNC(f28_arg1, f28_arg2, f28_arg0.NoAction)
    local f28_local6 = REGIST_FUNC(f28_arg1, f28_arg2, f28_arg0.ActAfter_AdjustSpace)
    return Common_Kengeki_Activate(f28_arg1, f28_arg2, f28_local1, f28_local2, f28_local6, f28_local3)
    
end

Goal.Kengeki01 = function (f29_arg0, f29_arg1, f29_arg2)
    
end

Goal.Kengeki02 = function (f30_arg0, f30_arg1, f30_arg2)
    
end

Goal.Kengeki03 = function (f31_arg0, f31_arg1, f31_arg2)
    f31_arg1:ClearSubGoal()
    f31_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3061, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.Kengeki04 = function (f32_arg0, f32_arg1, f32_arg2)
    f32_arg1:ClearSubGoal()
    f32_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3065, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.Kengeki05 = function (f33_arg0, f33_arg1, f33_arg2)
    f33_arg1:ClearSubGoal()
    f33_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3072, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.Kengeki06 = function (f34_arg0, f34_arg1, f34_arg2)
    f34_arg1:ClearSubGoal()
    f34_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3072, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.Kengeki07 = function (f35_arg0, f35_arg1, f35_arg2)
    f35_arg1:ClearSubGoal()
    f35_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3072, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.Kengeki08 = function (f36_arg0, f36_arg1, f36_arg2)
    f36_arg1:ClearSubGoal()
    f36_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3072, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.NoAction = function (f37_arg0, f37_arg1, f37_arg2)
    return -1
    
end

Goal.ActAfter_AdjustSpace = function (f38_arg0, f38_arg1, f38_arg2)
    
end

Goal.Update = function (f39_arg0, f39_arg1, f39_arg2)
    return Update_Default_NoSubGoal(f39_arg0, f39_arg1, f39_arg2)
    
end

Goal.Terminate = function (f40_arg0, f40_arg1, f40_arg2)
    
end


