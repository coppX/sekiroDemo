RegisterTableGoal(GOAL_Yarisouhei_105000_Battle, "GOAL_Yarisouhei_105000_Battle")
REGISTER_GOAL_NO_UPDATE(GOAL_Yarisouhei_105000_Battle, true)

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
    local f2_local5 = Check_ReachAttack(f2_arg1, 4)
    local f2_local6 = f2_arg1:GetSpRate(TARGET_SELF)
    Set_ConsecutiveGuardCount_Interrupt(f2_arg1)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 110111)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 110112)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 110113)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 110114)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 110115)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 110116)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 110117)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 110118)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 110120)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 110121)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 107710)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 5026)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 5027)
    f2_arg1:AddObserveArea(0, TARGET_SELF, TARGET_ENE_0, AI_DIR_TYPE_B, 45, 4)
    if f2_arg0.Kengeki_Activate(f2_arg0, f2_arg1, f2_arg2) then
        return
    end
    if Common_ActivateAct(f2_arg1, f2_arg2) then
    elseif f2_local5 ~= POSSIBLE_ATTACK then
        if f2_local4 == 1 and f2_arg1:GetTeamOrder(ORDER_TYPE_Role) == ROLE_TYPE_Kankyaku then
            f2_local0[27] = 100
        elseif f2_local4 == 1 and f2_arg1:GetTeamOrder(ORDER_TYPE_Role) == ROLE_TYPE_Torimaki then
            f2_local0[27] = 100
        elseif f2_local5 == UNREACH_ATTACK then
            f2_local0[27] = 100
        elseif f2_local5 == REACH_ATTACK_TARGET_HIGH_POSITION then
            if f2_arg1:IsVisibleCurrTarget() then
                f2_local0[2] = 100
            else
                f2_local0[27] = 100
            end
        elseif f2_local5 == REACH_ATTACK_TARGET_LOW_POSITION then
            if f2_arg1:IsVisibleCurrTarget() then
                f2_local0[2] = 100
            else
                f2_local0[27] = 100
            end
        else
            f2_local0[27] = 100
        end
    elseif f2_local4 == 1 and f2_arg1:GetTeamOrder(ORDER_TYPE_Role) == ROLE_TYPE_Kankyaku then
        KankyakuAct(f2_arg1, f2_arg2)
    elseif f2_local4 == 1 and f2_arg1:GetTeamOrder(ORDER_TYPE_Role) == ROLE_TYPE_Torimaki then
        TorimakiAct(f2_arg1, f2_arg2, -1, 0)
    elseif f2_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_B, 180) then
        if f2_local3 <= 3 and f2_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_B, 90) then
            f2_local0[5] = 100
        else
            f2_local0[21] = 100
        end
    elseif f2_arg1:HasSpecialEffectId(TARGET_ENE_0, COMMON_SP_EFFECT_PC_BREAK) then
        if f2_local3 >= 5 then
            f2_local0[6] = 100
        else
            f2_local0[2] = 100
        end
    elseif f2_local3 >= 10 then
        f2_local0[1] = 0
        f2_local0[2] = 0
        f2_local0[3] = 0
        f2_local0[4] = 100
        f2_local0[6] = 100
        f2_local0[7] = 800
        f2_local0[23] = 20
    elseif f2_local3 >= 6.5 then
        f2_local0[1] = 100
        f2_local0[2] = 0
        f2_local0[3] = 100
        f2_local0[4] = 400
        f2_local0[6] = 200
        f2_local0[7] = 300
        f2_local0[23] = 50
    elseif f2_local3 >= 2 then
        f2_local0[1] = 200
        f2_local0[2] = 0
        f2_local0[3] = 300
        f2_local0[4] = 150
        f2_local0[6] = 200
        f2_local0[7] = 500
        f2_local0[23] = 50
    else
        f2_local0[1] = 0
        f2_local0[2] = 350
        f2_local0[3] = 350
        f2_local0[4] = 200
        f2_local0[6] = 0
        f2_local0[7] = 0
        f2_local0[24] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 45, 4) == false and SpaceCheck(f2_arg1, f2_arg2, -45, 4) == false then
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
    f2_local0[1] = SetCoolTime(f2_arg1, f2_arg2, 3000, 5, f2_local0[1], 1)
    f2_local0[2] = SetCoolTime(f2_arg1, f2_arg2, 3001, 15, f2_local0[2], 1)
    f2_local0[3] = SetCoolTime(f2_arg1, f2_arg2, 3002, 8, f2_local0[3], 1)
    f2_local0[4] = SetCoolTime(f2_arg1, f2_arg2, 3009, 15, f2_local0[4], 1)
    f2_local0[5] = SetCoolTime(f2_arg1, f2_arg2, 3012, 10, f2_local0[5], 1)
    f2_local0[6] = SetCoolTime(f2_arg1, f2_arg2, 3017, 30, f2_local0[6], 1)
    f2_local0[7] = SetCoolTime(f2_arg1, f2_arg2, 3020, 40, f2_local0[7], 1)
    f2_local0[24] = SetCoolTime(f2_arg1, f2_arg2, 5201, 7, f2_local0[24], 1)
    f2_local0[24] = SetCoolTime(f2_arg1, f2_arg2, 5211, 7, f2_local0[24], 1)
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
    local f2_local7 = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.ActAfter_AdjustSpace)
    Common_Battle_Activate(f2_arg1, f2_arg2, f2_local0, f2_local1, f2_local7, f2_local2)
    
end

Goal.Act01 = function (f3_arg0, f3_arg1, f3_arg2)
    local f3_local0 = 3.8 - f3_arg0:GetMapHitRadius(TARGET_SELF)
    local f3_local1 = 3.8 - f3_arg0:GetMapHitRadius(TARGET_SELF)
    local f3_local2 = 3.8 - f3_arg0:GetMapHitRadius(TARGET_SELF)
    local f3_local3 = 100
    local f3_local4 = 0
    local f3_local5 = 1.5
    local f3_local6 = 3
    Approach_Act_Flex(f3_arg0, f3_arg1, f3_local0, f3_local1, f3_local2, f3_local3, f3_local4, f3_local5, f3_local6)
    local f3_local7 = 0
    local f3_local8 = 0
    f3_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3000, TARGET_ENE_0, 9999, f3_local7, f3_local8, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act02 = function (f4_arg0, f4_arg1, f4_arg2)
    local f4_local0 = 4.3 - f4_arg0:GetMapHitRadius(TARGET_SELF)
    local f4_local1 = 4.3 - f4_arg0:GetMapHitRadius(TARGET_SELF)
    local f4_local2 = 4.3 - f4_arg0:GetMapHitRadius(TARGET_SELF)
    local f4_local3 = 100
    local f4_local4 = 0
    local f4_local5 = 1.5
    local f4_local6 = 3
    Approach_Act_Flex(f4_arg0, f4_arg1, f4_local0, f4_local1, f4_local2, f4_local3, f4_local4, f4_local5, f4_local6)
    local f4_local7 = 0
    local f4_local8 = 0
    f4_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3001, TARGET_ENE_0, 9999, f4_local7, f4_local8, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act03 = function (f5_arg0, f5_arg1, f5_arg2)
    local f5_local0 = 2.9 - f5_arg0:GetMapHitRadius(TARGET_SELF)
    local f5_local1 = 2.9 - f5_arg0:GetMapHitRadius(TARGET_SELF)
    local f5_local2 = 2.9 - f5_arg0:GetMapHitRadius(TARGET_SELF)
    local f5_local3 = 100
    local f5_local4 = 0
    local f5_local5 = 1.5
    local f5_local6 = 3
    Approach_Act_Flex(f5_arg0, f5_arg1, f5_local0, f5_local1, f5_local2, f5_local3, f5_local4, f5_local5, f5_local6)
    local f5_local7 = 2.9 - f5_arg0:GetMapHitRadius(TARGET_SELF)
    local f5_local8 = 4.6 - f5_arg0:GetMapHitRadius(TARGET_SELF)
    local f5_local9 = 0
    local f5_local10 = 0
    f5_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3002, TARGET_ENE_0, f5_local7, f5_local9, f5_local10, 0, 0)
    f5_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3013, TARGET_ENE_0, 9999, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act04 = function (f6_arg0, f6_arg1, f6_arg2)
    local f6_local0 = f6_arg0:GetDist(TARGET_ENE_0)
    local f6_local1 = 9.4 - f6_arg0:GetMapHitRadius(TARGET_SELF)
    local f6_local2 = 9.4 - f6_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f6_local3 = 9.4 - f6_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f6_local4 = 100
    local f6_local5 = 0
    local f6_local6 = 1.5
    local f6_local7 = 3
    local f6_local8 = 0
    local f6_local9 = 0
    if f6_local0 <= 5 then
        f6_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 3, 5211, TARGET_ENE_0, 0, AI_DIR_TYPE_F, 3)
    end
    f6_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3009, TARGET_ENE_0, 9999, f6_local8, f6_local9, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act05 = function (f7_arg0, f7_arg1, f7_arg2)
    local f7_local0 = 0
    local f7_local1 = 0
    f7_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3012, TARGET_ENE_0, 9999, f7_local0, f7_local1, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act06 = function (f8_arg0, f8_arg1, f8_arg2)
    local f8_local0 = 5.7 - f8_arg0:GetMapHitRadius(TARGET_SELF)
    local f8_local1 = 5.7 - f8_arg0:GetMapHitRadius(TARGET_SELF)
    local f8_local2 = 5.7 - f8_arg0:GetMapHitRadius(TARGET_SELF)
    local f8_local3 = 100
    local f8_local4 = 0
    local f8_local5 = 1.5
    local f8_local6 = 3
    Approach_Act_Flex(f8_arg0, f8_arg1, f8_local0, f8_local1, f8_local2, f8_local3, f8_local4, f8_local5, f8_local6)
    local f8_local7 = 4.9 - f8_arg0:GetMapHitRadius(TARGET_SELF)
    local f8_local8 = 4.5 - f8_arg0:GetMapHitRadius(TARGET_SELF)
    local f8_local9 = 0
    local f8_local10 = 0
    local f8_local11 = f8_arg0:GetRandam_Int(1, 100)
    f8_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3015, TARGET_ENE_0, f8_local8, f8_local9, f8_local10, 0, 0)
    f8_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3017, TARGET_ENE_0, 9999, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act07 = function (f9_arg0, f9_arg1, f9_arg2)
    local f9_local0 = f9_arg0:GetDist(TARGET_ENE_0)
    local f9_local1 = 13 - f9_arg0:GetMapHitRadius(TARGET_SELF)
    local f9_local2 = 13 - f9_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f9_local3 = 13 - f9_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f9_local4 = 100
    local f9_local5 = 0
    local f9_local6 = 1.5
    local f9_local7 = 3
    local f9_local8 = f9_arg0:GetDist(TARGET_ENE_0)
    Approach_Act_Flex(f9_arg0, f9_arg1, f9_local1, f9_local2, f9_local3, f9_local4, f9_local5, f9_local6, f9_local7)
    if f9_local8 <= 7 and f9_arg0:IsExistMeshOnLine(TARGET_SELF, AI_DIR_TYPE_B, 2) then
        f9_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 3, 5211, TARGET_ENE_0, 999, 0, 0, 0, 0)
        f9_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 3, 5211, TARGET_ENE_0, 9999, 0)
    end
    local f9_local9 = 0
    local f9_local10 = 0
    f9_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3020, TARGET_ENE_0, 9999, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act10 = function (f10_arg0, f10_arg1, f10_arg2)
    local f10_local0 = 0.1 - f10_arg0:GetMapHitRadius(TARGET_SELF)
    local f10_local1 = 0.1 - f10_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f10_local2 = 0.1 - f10_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f10_local3 = 100
    local f10_local4 = 0
    local f10_local5 = 1.5
    local f10_local6 = 3
    Approach_Act_Flex(f10_arg0, f10_arg1, f10_local0, f10_local1, f10_local2, f10_local3, f10_local4, f10_local5, f10_local6)
    local f10_local7 = 0
    local f10_local8 = 0
    f10_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3010, TARGET_ENE_0, 9999, f10_local7, f10_local8, 0, 0)
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
    local f12_local2 = 5202
    if SpaceCheck(f12_arg0, f12_arg1, -45, 4) == true then
        if SpaceCheck(f12_arg0, f12_arg1, 45, 4) == true then
            if f12_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                f12_local2 = 5212
            else
                f12_local2 = 5213
            end
        else
            f12_local2 = 5212
        end
    elseif SpaceCheck(f12_arg0, f12_arg1, 45, 4) == true then
        f12_local2 = 5213
    else
    end
    f12_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f12_local0, f12_local2, TARGET_ENE_0, f12_local1, AI_DIR_TYPE_R, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act23 = function (f13_arg0, f13_arg1, f13_arg2)
    local f13_local0 = f13_arg0:GetDist(TARGET_ENE_0)
    local f13_local1 = f13_arg0:GetSp(TARGET_SELF)
    local f13_local2 = 20
    local f13_local3 = f13_arg0:GetRandam_Int(1, 100)
    local f13_local4 = -1
    local f13_local5 = 0
    if SpaceCheck(f13_arg0, f13_arg1, -90, 1) == true then
        if SpaceCheck(f13_arg0, f13_arg1, 90, 1) == true then
            if f13_arg0:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_R, 180, 999) then
                f13_local5 = 1
            else
                f13_local5 = 0
            end
        else
            f13_local5 = 0
        end
    elseif SpaceCheck(f13_arg0, f13_arg1, 90, 1) == true then
        f13_local5 = 1
    else
    end
    local f13_local6 = 3
    local f13_local7 = f13_arg0:GetRandam_Int(30, 45)
    f13_arg0:SetNumber(10, f13_local5)
    f13_arg0:AddObserveArea(1, TARGET_SELF, TARGET_ENE_0, AI_DIR_TYPE_F, 90, 3)
    f13_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f13_local6, TARGET_ENE_0, f13_local5, f13_local7, true, true, f13_local4)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act24 = function (f14_arg0, f14_arg1, f14_arg2)
    local f14_local0 = f14_arg0:GetDist(TARGET_ENE_0)
    local f14_local1 = 3
    local f14_local2 = 0
    local f14_local3 = 5201
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
    local f15_local1 = f15_arg0:GetRandam_Float(5, 7)
    local f15_local2 = f15_arg0:GetDist(TARGET_ENE_0)
    local f15_local3 = -1
    f15_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, f15_local0, TARGET_ENE_0, f15_local1, TARGET_ENE_0, true, f15_local3)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act26 = function (f16_arg0, f16_arg1, f16_arg2)
    f16_arg1:AddSubGoal(GOAL_COMMON_Wait, 0.5, TARGET_SELF, 0, 0, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act27 = function (f17_arg0, f17_arg1, f17_arg2)
    local f17_local0 = f17_arg0:GetRandam_Int(1, 100)
    if YousumiAct_SubGoal(f17_arg0, f17_arg1, true, 60, 30) == false then
        GetWellSpace_Odds = 0
        return GetWellSpace_Odds
    end
    local f17_local1 = 0
    local f17_local2 = SpaceCheck_SidewayMove(f17_arg0, f17_arg1, 1)
    if f17_local2 == 0 then
        f17_local1 = 0
    elseif f17_local2 == 1 then
        f17_local1 = 1
    elseif f17_local2 == 2 then
        if f17_local0 <= 50 then
            f17_local1 = 0
        else
            f17_local1 = 1
        end
    else
        f17_arg1:AddSubGoal(GOAL_COMMON_Wait, 0.5, TARGET_SELF, 0, 0, 0)
        GetWellSpace_Odds = 0
        return GetWellSpace_Odds
    end
    f17_arg0:SetNumber(10, f17_local1)
    f17_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, 3, TARGET_ENE_0, f17_local1, f17_arg0:GetRandam_Int(30, 45), true, true, -1)
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
    if f18_local0 <= 3 then
        f18_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f18_local1, TARGET_ENE_0, f18_local5, f18_local3, true, true, f18_local4)
    elseif f18_local0 <= 8 then
        f18_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, f18_local2, TARGET_ENE_0, 3, TARGET_SELF, true, -1)
    else
        f18_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, f18_local2, TARGET_ENE_0, 8, TARGET_SELF, false, -1)
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Interrupt = function (f19_arg0, f19_arg1, f19_arg2)
    local f19_local0 = f19_arg1:GetDist(TARGET_ENE_0)
    local f19_local1 = f19_arg1:GetSpecialEffectActivateInterruptType(0)
    local f19_local2 = f19_arg1:GetRandam_Int(1, 100)
    local f19_local3 = f19_arg1:GetSpRate(TARGET_SELF)
    if f19_arg1:IsLadderAct(TARGET_SELF) then
        return false
    end
    if not f19_arg1:HasSpecialEffectId(TARGET_SELF, 200004) then
        return false
    end
    if f19_arg1:IsInterupt(INTERUPT_ParryTiming) and not f19_arg1:HasSpecialEffectId(TARGET_SELF, 5028) then
        return Common_Parry(f19_arg1, f19_arg2, 50, 0)
    end
    if f19_arg1:IsInterupt(INTERUPT_Damaged) then
        return f19_arg0.Damaged(f19_arg1, f19_arg2)
    end
    if Interupt_PC_Break(f19_arg1) then
        f19_arg1:Replanning()
        return true
    end
    if f19_arg1:IsInterupt(INTERUPT_ActivateSpecialEffect) then
        local f19_local4 = 5210
        local f19_local5 = 5211
        local f19_local6 = 5212
        local f19_local7 = 5213
        if f19_local1 == 110111 or f19_local1 == 110115 or f19_local1 == 110116 then
            if f19_arg1:HasSpecialEffectId(TARGET_SELF, 5029) and f19_local0 <= 6 then
                if f19_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) and f19_arg1:HasSpecialEffectId(TARGET_SELF, 5020) then
                    f19_arg2:ClearSubGoal()
                    f19_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 0.5, 3003, TARGET_ENE_0, 9999, 0)
                    return true
                end
            elseif f19_local0 <= 2 then
                f19_arg2:ClearSubGoal()
                f19_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, f19_local5, TARGET_ENE_0, 9999, 0)
                return true
            elseif f19_local0 <= 5 then
                if f19_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) then
                    if f19_arg1:HasSpecialEffectId(TARGET_SELF, 5020) then
                        f19_arg2:ClearSubGoal()
                        f19_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3003, TARGET_ENE_0, 9999, 0)
                        return true
                    end
                else
                    f19_arg2:ClearSubGoal()
                    f19_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, f19_local5, TARGET_ENE_0, 9999, 0)
                end
                do
                    return true
                end
                if false then
                end
            end
        elseif f19_local1 == 110112 or f19_local1 == 110117 or f19_local1 == 110118 then
            if f19_local0 <= 3 then
                if f19_arg1:HasSpecialEffectId(TARGET_SELF, 5020) then
                    f19_arg2:ClearSubGoal()
                    f19_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3003, TARGET_ENE_0, 9999, 0)
                    return true
                end
                return true
            elseif f19_local0 <= 8 then
                f19_arg2:ClearSubGoal()
                f19_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 2, f19_local4, TARGET_ENE_0, 9999, 0)
                f19_arg1:SetTimer(5, 2)
                if false then
                end
            end
        elseif f19_local1 == 110113 then
            if f19_local0 <= 3 then
                if f19_arg1:HasSpecialEffectId(TARGET_SELF, 5020) then
                    f19_arg2:ClearSubGoal()
                    f19_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3003, TARGET_ENE_0, 9999, 0)
                    return true
                end
            elseif f19_local0 <= 10 and f19_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) then
                f19_arg2:ClearSubGoal()
                f19_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, f19_local7, TARGET_ENE_0, 9999, 0)
                return true
            end
        elseif f19_local1 == 110114 then
            if f19_local0 <= 3 then
                if f19_arg1:HasSpecialEffectId(TARGET_SELF, 5020) then
                    f19_arg2:ClearSubGoal()
                    f19_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3003, TARGET_ENE_0, 9999, 0)
                    return true
                end
            elseif f19_local0 <= 10 and f19_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) then
                f19_arg2:ClearSubGoal()
                f19_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, f19_local6, TARGET_ENE_0, 9999, 0)
                return true
            end
        end
        if f19_local1 == 107710 then
            f19_arg2:ClearSubGoal()
            f19_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 2, 3024, TARGET_ENE_0, 9999, 0)
            return true
        end
        if f19_local1 == 5026 then
            if f19_local3 <= 0.3 then
                f19_arg2:ClearSubGoal()
                f19_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 2, 3090, TARGET_ENE_0, 9999, 0)
                return true
            end
        elseif f19_local1 == 5027 then
            f19_arg2:ClearSubGoal()
            f19_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 2, 3021, TARGET_ENE_0, 9999, 0)
            return true
        end
    end
    if f19_arg1:IsInterupt(INTERUPT_ShootImpact) and f19_arg0.ShootReaction(f19_arg1, f19_arg2) then
        return true
    end
    if f19_arg1:IsInterupt(INTERUPT_Inside_ObserveArea) then
        if f19_arg1:IsInsideObserve(0) == true and f19_arg1:IsFinishTimer(0) == true then
            f19_arg2:ClearSubGoal()
            f19_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 0.3, 3012, TARGET_ENE_0, 9999, 0)
            f19_arg1:SetTimer(0, 5)
            f19_arg1:DeleteObserve(0)
            return true
        elseif f19_arg1:IsInsideObserve(1) == true then
            f19_arg1:Replanning()
            f19_arg1:DeleteObserve(1)
            return true
        end
    end
    return false
    
end

Goal.Damaged = function (f20_arg0, f20_arg1, f20_arg2)
    local f20_local0 = 3
    return false
    
end

Goal.ShootReaction = function (f21_arg0, f21_arg1)
    local f21_local0 = f21_arg0:GetDist(TARGET_ENE_0)
    local f21_local1 = f21_arg0:GetRandam_Int(1, 100)
    if f21_arg0:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_F, 20, 999) then
        f21_arg1:ClearSubGoal()
        if f21_local0 <= 7 then
            f21_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3100, TARGET_ENE_0, 9999, 0)
        elseif SpaceCheck(f21_arg0, f21_arg1, -90, 2) == true then
            if SpaceCheck(f21_arg0, f21_arg1, 90, 2) == true then
                if f21_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                    f21_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 5202, TARGET_ENE_0, 9999, 0)
                else
                    f21_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 5203, TARGET_ENE_0, 9999, 0)
                end
            else
                f21_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 5202, TARGET_ENE_0, 9999, 0)
            end
        elseif SpaceCheck(f21_arg0, f21_arg1, 90, 2) == true then
            f21_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 5203, TARGET_ENE_0, 9999, 0)
        else
            f21_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3100, TARGET_ENE_0, 9999, 0)
        end
        return true
    end
    
end

Goal.Kengeki_Activate = function (f22_arg0, f22_arg1, f22_arg2, f22_arg3)
    local f22_local0 = ReturnKengekiSpecialEffect(f22_arg1)
    if f22_local0 == 0 then
        return false
    end
    local f22_local1 = {}
    local f22_local2 = {}
    local f22_local3 = {}
    Common_Clear_Param(f22_local1, f22_local2, f22_local3)
    local f22_local4 = f22_arg1:GetDist(TARGET_ENE_0)
    local f22_local5 = f22_arg1:GetSp(TARGET_SELF)
    if f22_local5 <= 0 then
        f22_local1[50] = 100
    elseif f22_local0 == 200200 then
        if f22_local4 >= 4 then
            f22_local1[50] = 100
        else
            f22_local1[1] = 50
            f22_local1[2] = 100
            f22_local1[50] = 20
        end
    elseif f22_local0 == 200201 then
        if f22_local4 >= 4 then
            f22_local1[50] = 100
        else
            f22_local1[3] = 50
            f22_local1[50] = 20
        end
    elseif f22_local0 == 200205 then
        if f22_local4 >= 4 then
            f22_local1[50] = 100
        else
            f22_local1[50] = 100
        end
    elseif f22_local0 == 200206 then
        if f22_local4 >= 4 then
            f22_local1[50] = 100
        else
            f22_local1[50] = 100
        end
    elseif f22_local0 == 200210 then
        if f22_local4 >= 4 then
            f22_local1[50] = 100
        else
            f22_local1[3] = 500
            f22_local1[5] = 350
        end
    elseif f22_local0 == 200211 then
        if f22_local4 >= 4 then
            f22_local1[50] = 100
        else
            f22_local1[3] = 500
            f22_local1[5] = 350
        end
    elseif f22_local0 == 200215 then
        if f22_local4 >= 4 then
            f22_local1[50] = 100
        else
            f22_local1[50] = 100
        end
    elseif f22_local0 == 200216 then
        if f22_local4 >= 4 then
            f22_local1[50] = 100
        else
            f22_local1[50] = 100
        end
    else
        f22_local1[50] = 100
    end
    if SpaceCheck(f22_arg1, f22_arg2, 45, 2) == false and SpaceCheck(f22_arg1, f22_arg2, -45, 2) == false then
        f22_local1[22] = 0
    end
    if SpaceCheck(f22_arg1, f22_arg2, 180, 2) == false then
        f22_local1[24] = 0
    end
    f22_local1[1] = SetCoolTime(f22_arg1, f22_arg2, 3070, 5, f22_local1[1], 1)
    f22_local1[2] = SetCoolTime(f22_arg1, f22_arg2, 3071, 5, f22_local1[2], 1)
    f22_local1[3] = SetCoolTime(f22_arg1, f22_arg2, 3075, 5, f22_local1[3], 1)
    f22_local1[4] = SetCoolTime(f22_arg1, f22_arg2, 3016, 5, f22_local1[4], 1)
    f22_local1[5] = SetCoolTime(f22_arg1, f22_arg2, 3017, 5, f22_local1[5], 1)
    f22_local2[1] = REGIST_FUNC(f22_arg1, f22_arg2, f22_arg0.Kengeki01)
    f22_local2[2] = REGIST_FUNC(f22_arg1, f22_arg2, f22_arg0.Kengeki02)
    f22_local2[3] = REGIST_FUNC(f22_arg1, f22_arg2, f22_arg0.Kengeki03)
    f22_local2[4] = REGIST_FUNC(f22_arg1, f22_arg2, f22_arg0.Kengeki04)
    f22_local2[5] = REGIST_FUNC(f22_arg1, f22_arg2, f22_arg0.Kengeki05)
    f22_local2[10] = REGIST_FUNC(f22_arg1, f22_arg2, f22_arg0.Kengeki10)
    f22_local2[20] = REGIST_FUNC(f22_arg1, f22_arg2, f22_arg0.Act02)
    f22_local2[21] = REGIST_FUNC(f22_arg1, f22_arg2, f22_arg0.Act21)
    f22_local2[22] = REGIST_FUNC(f22_arg1, f22_arg2, f22_arg0.Act22)
    f22_local2[23] = REGIST_FUNC(f22_arg1, f22_arg2, f22_arg0.Act23)
    f22_local2[24] = REGIST_FUNC(f22_arg1, f22_arg2, f22_arg0.Act24)
    f22_local2[25] = REGIST_FUNC(f22_arg1, f22_arg2, f22_arg0.Act25)
    f22_local2[50] = REGIST_FUNC(f22_arg1, f22_arg2, f22_arg0.NoAction)
    local f22_local6 = REGIST_FUNC(f22_arg1, f22_arg2, f22_arg0.ActAfter_AdjustSpace)
    Common_Kengeki_Activate(f22_arg1, f22_arg2, f22_local1, f22_local2, f22_local6, f22_local3)
    
end

Goal.Kengeki01 = function (f23_arg0, f23_arg1, f23_arg2)
    f23_arg1:ClearSubGoal()
    f23_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 3, 3070, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.Kengeki02 = function (f24_arg0, f24_arg1, f24_arg2)
    f24_arg1:ClearSubGoal()
    f24_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 3, 3071, TARGET_ENE_0, 9999, 0, 0)
    f24_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 3, 3013, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.Kengeki03 = function (f25_arg0, f25_arg1, f25_arg2)
    f25_arg1:ClearSubGoal()
    f25_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 3, 3075, TARGET_ENE_0, 9999, 0, 0)
    f25_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 3, 3013, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.Kengeki04 = function (f26_arg0, f26_arg1, f26_arg2)
    f26_arg1:ClearSubGoal()
    f26_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 3, 3016, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.Kengeki05 = function (f27_arg0, f27_arg1, f27_arg2)
    f27_arg1:ClearSubGoal()
    f27_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 3, 3017, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.NoAction = function (f28_arg0, f28_arg1, f28_arg2)
    return -1
    
end

Goal.ActAfter_AdjustSpace = function (f29_arg0, f29_arg1, f29_arg2)
    
end

Goal.Update = function (f30_arg0, f30_arg1, f30_arg2)
    return Update_Default_NoSubGoal(f30_arg0, f30_arg1, f30_arg2)
    
end

Goal.Terminate = function (f31_arg0, f31_arg1, f31_arg2)
    
end


