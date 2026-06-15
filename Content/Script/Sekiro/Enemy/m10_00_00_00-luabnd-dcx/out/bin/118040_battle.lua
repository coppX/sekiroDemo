RegisterTableGoal(GOAL_Genan_Tate_118040_Battle, "GOAL_Genan_Tate_118040_Battle")
REGISTER_GOAL_NO_UPDATE(GOAL_Genan_Tate_118040_Battle, true)

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
    local f2_local5 = Check_ReachAttack(f2_arg1, 0)
    f2_arg1:DeleteObserve(0)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 3118110)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 109031)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 110125)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 3118120)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 3118100)
    Set_ConsecutiveGuardCount_Interrupt(f2_arg1)
    if f2_arg0.Kengeki_Activate(f2_arg0, f2_arg1, f2_arg2) then
        return
    end
    if f2_arg1:HasSpecialEffectId(TARGET_SELF, 3118100) then
        f2_local0[26] = 100
    elseif Common_ActivateAct(f2_arg1, f2_arg2) then
    elseif f2_local5 ~= POSSIBLE_ATTACK then
        if f2_local4 == 1 and f2_arg1:GetTeamOrder(ORDER_TYPE_Role) == ROLE_TYPE_Kankyaku then
            f2_local0[27] = 100
        elseif f2_local4 == 1 and f2_arg1:GetTeamOrder(ORDER_TYPE_Role) == ROLE_TYPE_Torimaki then
            f2_local0[27] = 100
        elseif f2_local5 == UNREACH_ATTACK then
            f2_local0[27] = 100
        elseif f2_local5 == REACH_ATTACK_TARGET_HIGH_POSITION then
            f2_local0[9] = 100
            f2_local0[10] = 100
            f2_local0[27] = 100
        elseif f2_local5 == REACH_ATTACK_TARGET_LOW_POSITION then
            f2_local0[9] = 100
            f2_local0[10] = 100
            f2_local0[27] = 100
        else
            f2_local0[27] = 100
        end
    elseif f2_local4 == 1 and f2_arg1:GetTeamOrder(ORDER_TYPE_Role) == ROLE_TYPE_Kankyaku then
        KankyakuAct(f2_arg1, f2_arg2)
    elseif f2_local4 == 1 and f2_arg1:GetTeamOrder(ORDER_TYPE_Role) == ROLE_TYPE_Torimaki then
        TorimakiAct(f2_arg1, f2_arg2, -1, 0)
    elseif f2_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_B, 180) then
        f2_local0[21] = 100
    elseif f2_arg1:GetNumber(1) >= 7 then
        f2_local0[1] = 10
    elseif f2_arg1:GetNumber(2) >= 3 then
        f2_local0[8] = 10
    elseif f2_local3 >= 5 then
        f2_local0[6] = 100
        f2_local0[7] = 0
        f2_local0[23] = 1
    else
        f2_local0[2] = 100
        f2_local0[5] = 0
        f2_local0[8] = 0
        f2_local0[9] = 100
        f2_local0[10] = 50
        f2_local0[25] = 100
        f2_local0[30] = 100
        f2_local0[31] = 100
        f2_local0[32] = 100
        f2_local0[33] = 100
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
    f2_local0[1] = SetCoolTime(f2_arg1, f2_arg2, 3000, 9, f2_local0[1], 1)
    f2_local0[2] = SetCoolTime(f2_arg1, f2_arg2, 3005, 10, f2_local0[2], 1)
    f2_local0[3] = SetCoolTime(f2_arg1, f2_arg2, 3010, 7, f2_local0[3], 1)
    f2_local0[3] = SetCoolTime(f2_arg1, f2_arg2, 3011, 7, f2_local0[3], 1)
    f2_local0[5] = SetCoolTime(f2_arg1, f2_arg2, 3015, 10, f2_local0[5], 1)
    f2_local0[6] = SetCoolTime(f2_arg1, f2_arg2, 3008, 10, f2_local0[6], 1)
    f2_local0[7] = SetCoolTime(f2_arg1, f2_arg2, 3008, 10, f2_local0[7], 1)
    f2_local0[8] = SetCoolTime(f2_arg1, f2_arg2, 3006, 9, f2_local0[8], 1)
    f2_local0[9] = SetCoolTime(f2_arg1, f2_arg2, 3020, 7, f2_local0[9], 1)
    f2_local0[10] = SetCoolTime(f2_arg1, f2_arg2, 3017, 8, f2_local0[10], 1)
    f2_local0[23] = SetCoolTime(f2_arg1, f2_arg2, 405002, 5, f2_local0[23], 1)
    f2_local0[23] = SetCoolTime(f2_arg1, f2_arg2, 405003, 5, f2_local0[23], 1)
    f2_local0[25] = SetCoolTime(f2_arg1, f2_arg2, 405001, 10, f2_local0[25], 1)
    f2_local0[30] = SetCoolTime(f2_arg1, f2_arg2, 3005, 10, f2_local0[30], 1)
    f2_local0[31] = SetCoolTime(f2_arg1, f2_arg2, 3005, 10, f2_local0[31], 1)
    f2_local0[32] = SetCoolTime(f2_arg1, f2_arg2, 3005, 10, f2_local0[32], 1)
    f2_local0[33] = SetCoolTime(f2_arg1, f2_arg2, 3005, 10, f2_local0[33], 1)
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
    f2_local1[21] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act21)
    f2_local1[22] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act22)
    f2_local1[23] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act23)
    f2_local1[24] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act24)
    f2_local1[25] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act25)
    f2_local1[26] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act26)
    f2_local1[27] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act27)
    f2_local1[28] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act28)
    f2_local1[30] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act30)
    f2_local1[31] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act31)
    f2_local1[32] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act32)
    f2_local1[33] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act33)
    f2_local1[40] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act40)
    local f2_local6 = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.ActAfter_AdjustSpace)
    Common_Battle_Activate(f2_arg1, f2_arg2, f2_local0, f2_local1, f2_local6, f2_local2)
    
end

Goal.Act01 = function (f3_arg0, f3_arg1, f3_arg2)
    local f3_local0 = 4 - f3_arg0:GetMapHitRadius(TARGET_SELF)
    local f3_local1 = 4 - f3_arg0:GetMapHitRadius(TARGET_SELF) + 999
    local f3_local2 = 4 - f3_arg0:GetMapHitRadius(TARGET_SELF) + 999
    local f3_local3 = 0
    local f3_local4 = 0
    local f3_local5 = 3
    local f3_local6 = 3
    Approach_Act_Flex(f3_arg0, f3_arg1, f3_local0, f3_local1, f3_local2, f3_local3, f3_local4, f3_local5, f3_local6)
    local f3_local7 = 3.5 - f3_arg0:GetMapHitRadius(TARGET_SELF)
    local f3_local8 = 5.8 - f3_arg0:GetMapHitRadius(TARGET_SELF)
    local f3_local9 = 0
    local f3_local10 = 0
    f3_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3000, TARGET_ENE_0, f3_local7, f3_local9, f3_local10, 0, 0)
    f3_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3001, TARGET_ENE_0, f3_local8, 0)
    f3_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3002, TARGET_ENE_0, 9999, 0, 0)
    f3_arg0:SetNumber(1, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act02 = function (f4_arg0, f4_arg1, f4_arg2)
    local f4_local0 = 3.8 - f4_arg0:GetMapHitRadius(TARGET_SELF)
    local f4_local1 = 3.8 - f4_arg0:GetMapHitRadius(TARGET_SELF) + 999
    local f4_local2 = 3.8 - f4_arg0:GetMapHitRadius(TARGET_SELF) + 999
    local f4_local3 = 0
    local f4_local4 = 0
    local f4_local5 = 3
    local f4_local6 = 3
    Approach_Act_Flex(f4_arg0, f4_arg1, f4_local0, f4_local1, f4_local2, f4_local3, f4_local4, f4_local5, f4_local6)
    local f4_local7 = 0
    local f4_local8 = 0
    if f4_arg0:IsExistMeshOnLine(TARGET_ENE_0, AI_DIR_TYPE_ToF, 3) == false then
        f4_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 3, TARGET_ENE_0, 1, TARGET_SELF, false, -1)
    end
    f4_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3005, TARGET_ENE_0, 9999, f4_local7, f4_local8, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act03 = function (f5_arg0, f5_arg1, f5_arg2)
    local f5_local0 = 0
    local f5_local1 = 0
    local f5_local2 = 3010
    if f5_arg0:IsInsideTargetEx(TARGET_SELF, TARGET_ENE_0, AI_DIR_TYPE_R, 180, 5) then
        f5_local2 = 3011
    end
    if f5_arg0:IsExistMeshOnLine(TARGET_ENE_0, AI_DIR_TYPE_ToF, 3) == false then
        f5_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 3, TARGET_ENE_0, 1, TARGET_SELF, false, -1)
    end
    f5_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f5_local2, TARGET_ENE_0, 9999, f5_local0, f5_local1, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act04 = function (f6_arg0, f6_arg1, f6_arg2)
    local f6_local0 = 0
    local f6_local1 = 0
    if f6_arg0:IsExistMeshOnLine(TARGET_ENE_0, AI_DIR_TYPE_ToF, 3) == false then
        f6_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 3, TARGET_ENE_0, 1, TARGET_SELF, false, -1)
    end
    f6_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3016, TARGET_ENE_0, 9999, f6_local0, f6_local1, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act05 = function (f7_arg0, f7_arg1, f7_arg2)
    local f7_local0 = 0
    local f7_local1 = 0
    if f7_arg0:IsExistMeshOnLine(TARGET_ENE_0, AI_DIR_TYPE_ToF, 3) == false then
        f7_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 3, TARGET_ENE_0, 1, TARGET_SELF, false, -1)
    end
    f7_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3015, TARGET_ENE_0, 9999, f7_local0, f7_local1, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act06 = function (f8_arg0, f8_arg1, f8_arg2)
    local f8_local0 = 0
    local f8_local1 = 0
    local f8_local2 = 3
    if f8_arg0:IsExistMeshOnLine(TARGET_ENE_0, AI_DIR_TYPE_ToF, 3) == false then
        f8_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 3, TARGET_ENE_0, 1, TARGET_SELF, false, -1)
    end
    f8_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3008, TARGET_ENE_0, 9999, f8_local0, f8_local1, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act07 = function (f9_arg0, f9_arg1, f9_arg2)
    local f9_local0 = 0
    local f9_local1 = 0
    f9_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3008, TARGET_ENE_0, 9999, f9_local0, f9_local1, 0, 0)
    f9_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3015, TARGET_ENE_0, 9999, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act08 = function (f10_arg0, f10_arg1, f10_arg2)
    local f10_local0 = 0
    local f10_local1 = 0
    f10_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3006, TARGET_ENE_0, 9999, f10_local0, f10_local1, 0, 0)
    f10_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3007, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(2, 0, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act09 = function (f11_arg0, f11_arg1, f11_arg2)
    local f11_local0 = 3
    local f11_local1 = 999
    local f11_local2 = 999
    local f11_local3 = 0
    local f11_local4 = 0
    local f11_local5 = 1.5
    local f11_local6 = 3
    Approach_Act_Flex(f11_arg0, f11_arg1, f11_local0, f11_local1, f11_local2, f11_local3, f11_local4, f11_local5, f11_local6)
    local f11_local7 = 0
    local f11_local8 = 0
    f11_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3020, TARGET_ENE_0, 9999, f11_local7, f11_local8, 0, 0)
    f11_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3021, TARGET_ENE_0, 9999, 0)
    f11_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3022, TARGET_ENE_0, 9999, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act10 = function (f12_arg0, f12_arg1, f12_arg2)
    local f12_local0 = 0
    local f12_local1 = 0
    f12_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3017, TARGET_ENE_0, 9999, f12_local0, f12_local1, 0, 0)
    f12_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3018, TARGET_ENE_0, 9999, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act21 = function (f13_arg0, f13_arg1, f13_arg2)
    local f13_local0 = 3
    local f13_local1 = 45
    f13_arg1:AddSubGoal(GOAL_COMMON_Turn, f13_local0, TARGET_ENE_0, f13_local1, -1, GOAL_RESULT_Success, true)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act22 = function (f14_arg0, f14_arg1, f14_arg2)
    local f14_local0 = 3
    local f14_local1 = 0
    local f14_local2 = 5202
    if SpaceCheck(f14_arg0, f14_arg1, -45, 2) == true then
        if SpaceCheck(f14_arg0, f14_arg1, 45, 2) == true then
            if f14_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                f14_local2 = 5202
            else
                f14_local2 = 5203
            end
        else
            f14_local2 = 5202
        end
    elseif SpaceCheck(f14_arg0, f14_arg1, 45, 2) == true then
        f14_local2 = 5203
    else
    end
    f14_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f14_local0, f14_local2, TARGET_ENE_0, f14_local1, AI_DIR_TYPE_R, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act23 = function (f15_arg0, f15_arg1, f15_arg2)
    local f15_local0 = f15_arg0:GetDist(TARGET_ENE_0)
    local f15_local1 = f15_arg0:GetSp(TARGET_SELF)
    local f15_local2 = 20
    local f15_local3 = f15_arg0:GetRandam_Int(1, 100)
    local f15_local4 = -1
    local f15_local5 = 0
    if SpaceCheck(f15_arg0, f15_arg1, -90, 1) == true then
        if SpaceCheck(f15_arg0, f15_arg1, 90, 1) == true then
            if f15_arg0:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_R, 180, 999) then
                f15_local5 = 1
            else
                f15_local5 = 0
            end
        else
            f15_local5 = 0
        end
    elseif SpaceCheck(f15_arg0, f15_arg1, 90, 1) == true then
        f15_local5 = 1
    else
    end
    local f15_local6 = 3
    local f15_local7 = f15_arg0:GetRandam_Int(30, 45)
    f15_arg0:SetNumber(10, f15_local5)
    f15_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f15_local6, TARGET_ENE_0, f15_local5, f15_local7, true, true, f15_local4)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act24 = function (f16_arg0, f16_arg1, f16_arg2)
    local f16_local0 = f16_arg0:GetDist(TARGET_ENE_0)
    local f16_local1 = 3
    local f16_local2 = 0
    local f16_local3 = 5201
    if SpaceCheck(f16_arg0, f16_arg1, 180, 2) ~= true or SpaceCheck(f16_arg0, f16_arg1, 180, 4) ~= true or f16_local0 > 4 then
    else
        f16_local3 = 5211
        if false then
        else
        end
    end
    f16_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f16_local1, f16_local3, TARGET_ENE_0, f16_local2, AI_DIR_TYPE_B, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act25 = function (f17_arg0, f17_arg1, f17_arg2)
    local f17_local0 = f17_arg0:GetRandam_Float(2, 4)
    local f17_local1 = f17_arg0:GetRandam_Float(5, 7)
    local f17_local2 = f17_arg0:GetDist(TARGET_ENE_0)
    local f17_local3 = -1
    f17_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, f17_local0, TARGET_ENE_0, f17_local1, TARGET_ENE_0, true, f17_local3)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act26 = function (f18_arg0, f18_arg1, f18_arg2)
    f18_arg1:AddSubGoal(GOAL_COMMON_Wait, 0.5, TARGET_SELF, 0, 0, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act27 = function (f19_arg0, f19_arg1, f19_arg2)
    local f19_local0 = f19_arg0:GetRandam_Int(1, 100)
    if YousumiAct_SubGoal(f19_arg0, f19_arg1, true, 60, 30) == false then
        GetWellSpace_Odds = 0
        return GetWellSpace_Odds
    end
    local f19_local1 = 0
    local f19_local2 = SpaceCheck_SidewayMove(f19_arg0, f19_arg1, 1)
    if f19_local2 == 0 then
        f19_local1 = 0
    elseif f19_local2 == 1 then
        f19_local1 = 1
    elseif f19_local2 == 2 then
        if f19_local0 <= 50 then
            f19_local1 = 0
        else
            f19_local1 = 1
        end
    else
        f19_arg1:AddSubGoal(GOAL_COMMON_Wait, 1, TARGET_SELF, 0, 0, 0)
        GetWellSpace_Odds = 0
        return GetWellSpace_Odds
    end
    f19_arg0:SetNumber(10, f19_local1)
    f19_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, 3, TARGET_ENE_0, f19_local1, f19_arg0:GetRandam_Int(30, 45), true, true, -1)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act28 = function (f20_arg0, f20_arg1, f20_arg2)
    local f20_local0 = f20_arg0:GetDist(TARGET_ENE_0)
    local f20_local1 = 1.5
    local f20_local2 = 1.5
    local f20_local3 = f20_arg0:GetRandam_Int(30, 45)
    local f20_local4 = -1
    local f20_local5 = f20_arg0:GetRandam_Int(0, 1)
    if f20_local0 <= 3 then
        f20_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f20_local1, TARGET_ENE_0, f20_local5, f20_local3, true, true, f20_local4)
    else
        f20_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 3, TARGET_ENE_0, 3, TARGET_SELF, true, -1)
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act30 = function (f21_arg0, f21_arg1, f21_arg2)
    local f21_local0 = 0
    local f21_local1 = 0
    local f21_local2 = 3
    if f21_arg0:IsExistMeshOnLine(TARGET_ENE_0, AI_DIR_TYPE_ToF, 3) == false then
        f21_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 3, TARGET_ENE_0, 1, TARGET_SELF, false, -1)
    end
    f21_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3005, TARGET_ENE_0, 9999, f21_local0, f21_local1, 0, 0)
    f21_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3002, TARGET_ENE_0, 9999, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act31 = function (f22_arg0, f22_arg1, f22_arg2)
    local f22_local0 = 0
    local f22_local1 = 0
    local f22_local2 = 3
    if f22_arg0:IsExistMeshOnLine(TARGET_ENE_0, AI_DIR_TYPE_ToF, 3) == false then
        f22_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 3, TARGET_ENE_0, 1, TARGET_SELF, false, -1)
    end
    f22_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3005, TARGET_ENE_0, 9999, f22_local0, f22_local1, 0, 0)
    f22_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3006, TARGET_ENE_0, 9999, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act32 = function (f23_arg0, f23_arg1, f23_arg2)
    local f23_local0 = 0
    local f23_local1 = 0
    local f23_local2 = 3
    if f23_arg0:IsExistMeshOnLine(TARGET_ENE_0, AI_DIR_TYPE_ToF, 3) == false then
        f23_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 3, TARGET_ENE_0, 1, TARGET_SELF, false, -1)
    end
    f23_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3005, TARGET_ENE_0, 9999, f23_local0, f23_local1, 0, 0)
    f23_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3021, TARGET_ENE_0, 9999, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act33 = function (f24_arg0, f24_arg1, f24_arg2)
    local f24_local0 = 0
    local f24_local1 = 0
    local f24_local2 = 3
    if f24_arg0:IsExistMeshOnLine(TARGET_ENE_0, AI_DIR_TYPE_ToF, 3) == false then
        f24_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 3, TARGET_ENE_0, 1, TARGET_SELF, false, -1)
    end
    f24_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3005, TARGET_ENE_0, 9999, f24_local0, f24_local1, 0, 0)
    f24_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3022, TARGET_ENE_0, 9999, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act40 = function (f25_arg0, f25_arg1, f25_arg2)
    f25_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 20030, TARGET_ENE_0, 999, 0, 0, 0, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Interrupt = function (f26_arg0, f26_arg1, f26_arg2)
    local f26_local0 = f26_arg1:GetSpecialEffectActivateInterruptType(0)
    local f26_local1 = f26_arg1:GetDist(TARGET_ENE_0)
    if f26_arg1:IsLadderAct(TARGET_SELF) then
        return false
    end
    if not f26_arg1:HasSpecialEffectId(TARGET_SELF, 200004) then
        return false
    end
    if f26_arg1:IsInterupt(INTERUPT_Damaged) and f26_arg0.Damaged(f26_arg1, f26_arg2) then
        return true
    end
    if Interupt_PC_Break(f26_arg1) then
        f26_arg1:Replanning()
        return true
    end
    if f26_arg1:IsInterupt(INTERUPT_ActivateSpecialEffect) then
        if f26_local0 == 3118100 then
            f26_arg1:Replanning()
            return true
        elseif f26_local0 == 109031 and f26_local1 <= 4 then
            f26_arg2:ClearSubGoal()
            f26_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 1, 3015, TARGET_ENE_0, 9999, 0)
            return true
        elseif f26_local0 == 3118120 then
            f26_arg1:AddObserveArea(1, TARGET_SELF, TARGET_ENE_0, AI_DIR_TYPE_F, 120, 6)
            return true
        end
    end
    if f26_arg1:IsInterupt(INTERUPT_TargetIsGuard) then
        f26_arg1:SetNumber(1, f26_arg1:GetNumber(1) + 1)
    end
    if f26_arg1:IsInterupt(INTERUPT_Inside_ObserveArea) then
        if f26_arg1:IsInsideObserve(0) then
            if f26_arg1:IsInsideTargetEx(TARGET_SELF, TARGET_ENE_0, AI_DIR_TYPE_L, 180, 5) then
                f26_arg1:DeleteObserve(0)
                f26_arg2:ClearSubGoal()
                f26_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 1, 3010, TARGET_ENE_0, 9999, 0)
                return true
            else
                f26_arg1:DeleteObserve(0)
                f26_arg2:ClearSubGoal()
                f26_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 1, 3011, TARGET_ENE_0, 9999, 0)
                return true
            end
        elseif f26_arg1:IsInsideObserve(1) then
            f26_arg2:ClearSubGoal()
            f26_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 1, 3017, TARGET_ENE_0, 9999, 0)
            f26_arg2:AddSubGoal(GOAL_COMMON_ComboRepeat, 4, 3017, TARGET_ENE_0, 5.5, 0, 0)
            f26_arg2:AddSubGoal(GOAL_COMMON_ComboFinal, 5, 3018, TARGET_ENE_0, 9999, 0, 0)
            f26_arg1:DeleteObserve(1)
            return true
        end
    end
    return false
    
end

Goal.Damaged = function (f27_arg0, f27_arg1, f27_arg2)
    f27_arg0:SetNumber(2, f27_arg0:GetNumber(2) + 1)
    
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
    f28_local2[1] = REGIST_FUNC(f28_arg1, f28_arg2, f28_arg0.Kengeki01)
    f28_local2[2] = REGIST_FUNC(f28_arg1, f28_arg2, f28_arg0.Kengeki02)
    f28_local2[3] = REGIST_FUNC(f28_arg1, f28_arg2, f28_arg0.Kengeki03)
    f28_local2[4] = REGIST_FUNC(f28_arg1, f28_arg2, f28_arg0.Kengeki04)
    f28_local2[50] = REGIST_FUNC(f28_arg1, f28_arg2, f28_arg0.NoAction)
    local f28_local6 = REGIST_FUNC(f28_arg1, f28_arg2, f28_arg0.ActAfter_AdjustSpace)
    Common_Kengeki_Activate(f28_arg1, f28_arg2, f28_local1, f28_local2, f28_local6, f28_local3)
    
end

Goal.Kengeki01 = function (f29_arg0, f29_arg1, f29_arg2)
    f29_arg1:ClearSubGoal()
    f29_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 3, 3060, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(0, f29_arg0:GetNumber(0) + 1, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki02 = function (f30_arg0, f30_arg1, f30_arg2)
    f30_arg1:ClearSubGoal()
    f30_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 3, 3065, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(0, f30_arg0:GetNumber(0) + 1, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki03 = function (f31_arg0, f31_arg1, f31_arg2)
    f31_arg1:ClearSubGoal()
    f31_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3061, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(0, 0, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki04 = function (f32_arg0, f32_arg1, f32_arg2)
    f32_arg1:ClearSubGoal()
    f32_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3066, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(0, 0, AI_TIMING_SET__ACTIVATE)
    
end

Goal.NoAction = function (f33_arg0, f33_arg1, f33_arg2)
    return -1
    
end

Goal.ActAfter_AdjustSpace = function (f34_arg0, f34_arg1, f34_arg2)
    
end

Goal.Update = function (f35_arg0, f35_arg1, f35_arg2)
    return Update_Default_NoSubGoal(f35_arg0, f35_arg1, f35_arg2)
    
end

Goal.Terminate = function (f36_arg0, f36_arg1, f36_arg2)
    
end


