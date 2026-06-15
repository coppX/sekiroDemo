RegisterTableGoal(GOAL_SyuraSamurai_107000_Battle, "GOAL_SyuraSamurai_107000_Battle")
REGISTER_GOAL_NO_UPDATE(GOAL_SyuraSamurai_107000_Battle, true)

Goal.Initialize = function (f1_arg0, f1_arg1, f1_arg2, f1_arg3)
    
end

Goal.Activate = function (f2_arg0, f2_arg1, f2_arg2)
    Init_Pseudo_Global(f2_arg1, f2_arg2)
    local f2_local0 = {}
    local f2_local1 = {}
    local f2_local2 = {}
    Common_Clear_Param(f2_local0, f2_local1, f2_local2)
    local f2_local3 = f2_arg1:GetDist(TARGET_ENE_0)
    local f2_local4 = f2_arg1:GetDistY(TARGET_ENE_0)
    local f2_local5 = f2_arg1:GetExcelParam(AI_EXCEL_THINK_PARAM_TYPE__thinkAttr_doAdmirer)
    local f2_local6 = f2_arg1:GetHpRate(TARGET_SELF)
    local f2_local7 = f2_arg1:GetSpRate(TARGET_SELF)
    local f2_local8 = Check_ReachAttack(f2_arg1, 0)
    Set_ConsecutiveGuardCount_Interrupt(f2_arg1)
    if f2_arg0.Kengeki_Activate(f2_arg0, f2_arg1, f2_arg2) then
        return
    end
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 200225)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 5025)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 5026)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 3107001)
    local f2_local9 = 0
    if f2_arg1:IsTargetGuard(TARGET_ENE_0) then
        f2_local9 = 3
    end
    if Common_ActivateAct(f2_arg1, f2_arg2) then
    elseif f2_local8 ~= POSSIBLE_ATTACK then
        if f2_local5 == 1 and f2_arg1:GetTeamOrder(ORDER_TYPE_Role) == ROLE_TYPE_Kankyaku then
            f2_local0[27] = 100
        elseif f2_local5 == 1 and f2_arg1:GetTeamOrder(ORDER_TYPE_Role) == ROLE_TYPE_Torimaki then
            f2_local0[27] = 100
        elseif f2_local8 == UNREACH_ATTACK then
            f2_local0[27] = 200
            f2_local0[8] = 100
            f2_local0[20] = 100
        elseif f2_local8 == REACH_ATTACK_TARGET_HIGH_POSITION then
            f2_local0[6] = 200
            f2_local0[12] = 100
        elseif f2_local8 == REACH_ATTACK_TARGET_LOW_POSITION then
            f2_local0[1] = 300
        else
            f2_local0[27] = 100
        end
    elseif f2_local5 == 1 and f2_arg1:GetTeamOrder(ORDER_TYPE_Role) == ROLE_TYPE_Kankyaku then
        KankyakuAct(f2_arg1, f2_arg2)
    elseif f2_local5 == 1 and f2_arg1:GetTeamOrder(ORDER_TYPE_Role) == ROLE_TYPE_Torimaki then
        if TorimakiAct(f2_arg1, f2_arg2) then
            f2_local0[8] = 100
            f2_local0[9] = 100
        end
    elseif f2_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_B, 180) and f2_local3 <= 5 then
        f2_local0[21] = 100
    elseif not f2_arg1:IsExistMeshOnLine(TARGET_ENE_0, AI_DIR_TYPE_ToB, f2_local3) then
        f2_local0[30] = 100
        f2_local0[31] = 100
    elseif f2_arg1:HasSpecialEffectId(TARGET_ENE_0, COMMON_SP_EFFECT_PC_BREAK) then
        if f2_local3 >= 5 then
            f2_local0[12] = 100
        else
            f2_local0[6] = 100
        end
    else
        if f2_local3 >= 7 then
            f2_local0[1] = 0
            f2_local0[2] = 0
            f2_local0[3] = 0
            f2_local0[4] = 0
            f2_local0[5] = 0
            f2_local0[6] = 0
            f2_local0[7] = 200
            f2_local0[8] = 2000
            f2_local0[9] = 800
            f2_local0[10] = 2000
            f2_local0[12] = 100
            f2_local0[13] = 0
            f2_local0[23] = 0
        elseif f2_local3 >= 5 then
            f2_local0[1] = 100
            f2_local0[2] = 0
            f2_local0[3] = 100
            f2_local0[4] = 100
            f2_local0[5] = 50
            f2_local0[6] = 50
            f2_local0[7] = 100
            f2_local0[8] = 2000
            f2_local0[9] = 500
            f2_local0[10] = 500
            f2_local0[12] = 100
            f2_local0[13] = 100
            f2_local0[23] = 200
        elseif f2_local3 >= 3 then
            f2_local0[1] = 100
            f2_local0[2] = 150
            f2_local0[3] = 100
            f2_local0[4] = 150
            f2_local0[5] = 100
            f2_local0[6] = 150
            f2_local0[7] = 0
            f2_local0[8] = 100
            f2_local0[9] = 0
            f2_local0[10] = 0
            f2_local0[11] = 100
            f2_local0[12] = 100
            f2_local0[13] = 100
            f2_local0[23] = 200
        else
            f2_local0[1] = 200
            f2_local0[2] = 100
            f2_local0[3] = 100
            f2_local0[4] = 0
            f2_local0[5] = 50
            f2_local0[6] = 50
            f2_local0[7] = 0
            f2_local0[8] = 0
            f2_local0[9] = 0
            f2_local0[11] = 400
            f2_local0[12] = 200
            f2_local0[13] = 200
            f2_local0[23] = 100
            if f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 109012) then
                f2_local0[1] = 0
                f2_local0[3] = 0
                f2_local0[4] = 0
                f2_local0[5] = 0
            end
        end
        if f2_local6 <= 0.25 or f2_local7 <= 0.25 then
            f2_local0[8] = 0
            f2_local0[9] = 0
            f2_local0[10] = 0
        end
    end
    if f2_arg1:HasSpecialEffectId(TARGET_SELF, 3107010) or f2_arg1:HasSpecialEffectId(TARGET_SELF, 3107011) then
        f2_local0[1] = f2_local0[1] * 3
        f2_local0[3] = f2_local0[3] * 3
        f2_local0[12] = f2_local0[12] * 3
        f2_local0[13] = f2_local0[13] * 3
    elseif f2_local9 > 0 then
        f2_local0[2] = f2_local0[2] * (f2_local9 / 2)
        f2_local0[4] = f2_local0[4] * (f2_local9 / 2)
        f2_local0[5] = f2_local0[5] * (f2_local9 / 2)
        f2_local0[11] = f2_local0[11] * f2_local9
    end
    if f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 90) or f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 110125) then
        f2_local0[23] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 90, 1) == false and SpaceCheck(f2_arg1, f2_arg2, -45, 1) == false then
        f2_local0[23] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 180, 1) == false then
        f2_local0[25] = 0
    end
    if f2_arg1:HasSpecialEffectId(TARGET_SELF, 200051) then
        f2_local0[8] = 0
    end
    if f2_arg1:HasSpecialEffectId(TARGET_SELF, 200050) then
        f2_local0[9] = 0
        f2_local0[10] = 0
        f2_local0[20] = 0
    end
    f2_local0[1] = SetCoolTime(f2_arg1, f2_arg2, 3000, 5, f2_local0[1], 1)
    f2_local0[2] = SetCoolTime(f2_arg1, f2_arg2, 3002, 5, f2_local0[2], 1)
    f2_local0[3] = SetCoolTime(f2_arg1, f2_arg2, 3004, 5, f2_local0[3], 1)
    f2_local0[3] = SetCoolTime(f2_arg1, f2_arg2, 3062, 5, f2_local0[3], 1)
    f2_local0[4] = SetCoolTime(f2_arg1, f2_arg2, 3006, 7, f2_local0[4], 1)
    f2_local0[5] = SetCoolTime(f2_arg1, f2_arg2, 3007, 5, f2_local0[5], 1)
    f2_local0[5] = SetCoolTime(f2_arg1, f2_arg2, 3090, 3, f2_local0[5], 1)
    f2_local0[6] = SetCoolTime(f2_arg1, f2_arg2, 3009, 7, f2_local0[6], 1)
    f2_local0[7] = SetCoolTime(f2_arg1, f2_arg2, 3010, 5, f2_local0[7], 1)
    f2_local0[8] = SetCoolTime(f2_arg1, f2_arg2, 3011, 20, f2_local0[8], 1)
    f2_local0[9] = SetCoolTime(f2_arg1, f2_arg2, 3012, 8, f2_local0[9], 1)
    f2_local0[20] = SetCoolTime(f2_arg1, f2_arg2, 3012, 8, f2_local0[20], 1)
    f2_local0[10] = SetCoolTime(f2_arg1, f2_arg2, 3014, 10, f2_local0[10], 1)
    f2_local0[11] = SetCoolTime(f2_arg1, f2_arg2, 3015, 16, f2_local0[11], 1)
    f2_local0[12] = SetCoolTime(f2_arg1, f2_arg2, 3016, 8, f2_local0[12], 1)
    f2_local0[13] = SetCoolTime(f2_arg1, f2_arg2, 3017, 8, f2_local0[13], 1)
    f2_local0[23] = SetCoolTime(f2_arg1, f2_arg2, 405002, 4, f2_local0[23], 1)
    f2_local0[23] = SetCoolTime(f2_arg1, f2_arg2, 405003, 4, f2_local0[23], 1)
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
    f2_local1[20] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act20)
    f2_local1[21] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act21)
    f2_local1[23] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act23)
    f2_local1[25] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act25)
    f2_local1[26] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act26)
    f2_local1[27] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act27)
    f2_local1[28] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act28)
    f2_local1[30] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act30)
    f2_local1[31] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act31)
    f2_local1[41] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act41)
    local f2_local10 = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.ActAfter_AdjustSpace)
    Common_Battle_Activate(f2_arg1, f2_arg2, f2_local0, f2_local1, f2_local10, f2_local2)
    
end

Goal.Act01 = function (f3_arg0, f3_arg1, f3_arg2)
    local f3_local0 = 6 - f3_arg0:GetMapHitRadius(TARGET_SELF)
    local f3_local1 = 6 - f3_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f3_local2 = 6 - f3_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f3_local3 = 100
    local f3_local4 = 0
    local f3_local5 = 1.5
    local f3_local6 = 3
    Approach_Act_Flex(f3_arg0, f3_arg1, f3_local0, f3_local1, f3_local2, f3_local3, f3_local4, f3_local5, f3_local6)
    local f3_local7 = 5.2 - f3_arg0:GetMapHitRadius(TARGET_SELF)
    local f3_local8 = 0
    local f3_local9 = 0
    f3_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3000, TARGET_ENE_0, f3_local7, f3_local8, f3_local9, 0, 0)
    f3_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3001, TARGET_ENE_0, 9999, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act02 = function (f4_arg0, f4_arg1, f4_arg2)
    local f4_local0 = 4.4 - f4_arg0:GetMapHitRadius(TARGET_SELF)
    local f4_local1 = 4.4 - f4_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f4_local2 = 4.4 - f4_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f4_local3 = 100
    local f4_local4 = 0
    local f4_local5 = 1.5
    local f4_local6 = 3
    Approach_Act_Flex(f4_arg0, f4_arg1, f4_local0, f4_local1, f4_local2, f4_local3, f4_local4, f4_local5, f4_local6)
    local f4_local7 = 0
    local f4_local8 = 0
    f4_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3002, TARGET_ENE_0, 5.1 - f4_arg0:GetMapHitRadius(TARGET_SELF), f4_local7, f4_local8, 0, 0)
    f4_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3020, TARGET_ENE_0, 5.3 - f4_arg0:GetMapHitRadius(TARGET_SELF), 0)
    f4_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3005, TARGET_ENE_0, 5.1 - f4_arg0:GetMapHitRadius(TARGET_SELF), 0)
    f4_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3020, TARGET_ENE_0, 9999, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act03 = function (f5_arg0, f5_arg1, f5_arg2)
    local f5_local0 = 6.1 - f5_arg0:GetMapHitRadius(TARGET_SELF)
    local f5_local1 = 6.1 - f5_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f5_local2 = 6.1 - f5_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f5_local3 = 100
    local f5_local4 = 0
    local f5_local5 = 1.5
    local f5_local6 = 3
    Approach_Act_Flex(f5_arg0, f5_arg1, f5_local0, f5_local1, f5_local2, f5_local3, f5_local4, f5_local5, f5_local6)
    local f5_local7 = 0
    local f5_local8 = 0
    f5_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3004, TARGET_ENE_0, 7 - f5_arg0:GetMapHitRadius(TARGET_SELF), f5_local7, f5_local8, 0, 0)
    f5_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3021, TARGET_ENE_0, 9999, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act04 = function (f6_arg0, f6_arg1, f6_arg2)
    local f6_local0 = 7.6 - f6_arg0:GetMapHitRadius(TARGET_SELF)
    local f6_local1 = 7.6 - f6_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f6_local2 = 7.6 - f6_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f6_local3 = 100
    local f6_local4 = 0
    local f6_local5 = 1.5
    local f6_local6 = 3
    Approach_Act_Flex(f6_arg0, f6_arg1, f6_local0, f6_local1, f6_local2, f6_local3, f6_local4, f6_local5, f6_local6)
    local f6_local7 = 0
    local f6_local8 = 0
    f6_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3006, TARGET_ENE_0, 9999, f6_local7, f6_local8, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act05 = function (f7_arg0, f7_arg1, f7_arg2)
    local f7_local0 = 6.4 - f7_arg0:GetMapHitRadius(TARGET_SELF)
    local f7_local1 = 6.4 - f7_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f7_local2 = 6.4 - f7_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f7_local3 = 100
    local f7_local4 = 0
    local f7_local5 = 1.5
    local f7_local6 = 3
    Approach_Act_Flex(f7_arg0, f7_arg1, f7_local0, f7_local1, f7_local2, f7_local3, f7_local4, f7_local5, f7_local6)
    local f7_local7 = 6.3 - f7_arg0:GetMapHitRadius(TARGET_SELF)
    local f7_local8 = 0
    local f7_local9 = 0
    f7_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3007, TARGET_ENE_0, f7_local7, f7_local8, f7_local9, 0, 0)
    f7_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3008, TARGET_ENE_0, 9999, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act06 = function (f8_arg0, f8_arg1, f8_arg2)
    local f8_local0 = 4 - f8_arg0:GetMapHitRadius(TARGET_SELF)
    local f8_local1 = 4 - f8_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f8_local2 = 4 - f8_arg0:GetMapHitRadius(TARGET_SELF) + 2
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
    local f9_local0 = 7.1 - f9_arg0:GetMapHitRadius(TARGET_SELF)
    local f9_local1 = 7.1 - f9_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f9_local2 = 7.1 - f9_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f9_local3 = 100
    local f9_local4 = 0
    local f9_local5 = 5
    local f9_local6 = 10
    Approach_Act_Flex(f9_arg0, f9_arg1, f9_local0, f9_local1, f9_local2, f9_local3, f9_local4, f9_local5, f9_local6)
    local f9_local7 = 0
    local f9_local8 = 0
    f9_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3010, TARGET_ENE_0, 9999, f9_local7, f9_local8, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act08 = function (f10_arg0, f10_arg1, f10_arg2)
    local f10_local0 = 0
    local f10_local1 = 0
    f10_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3011, TARGET_SELF, 9999, f10_local0, f10_local1, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act09 = function (f11_arg0, f11_arg1, f11_arg2)
    local f11_local0 = 10 - f11_arg0:GetMapHitRadius(TARGET_SELF)
    local f11_local1 = 10 - f11_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f11_local2 = 10 - f11_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f11_local3 = 100
    local f11_local4 = 0
    local f11_local5 = 5
    local f11_local6 = 10
    Approach_Act_Flex(f11_arg0, f11_arg1, f11_local0, f11_local1, f11_local2, f11_local3, f11_local4, f11_local5, f11_local6)
    local f11_local7 = 6.8 - f11_arg0:GetMapHitRadius(TARGET_SELF)
    local f11_local8 = 0
    local f11_local9 = 0
    f11_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3012, TARGET_ENE_0, 9999, f11_local8, f11_local9, 0, 0)
    f11_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3022, TARGET_ENE_0, 9999, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act10 = function (f12_arg0, f12_arg1, f12_arg2)
    local f12_local0 = 0
    local f12_local1 = 0
    f12_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3014, TARGET_SELF, 9999, f12_local0, f12_local1, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act11 = function (f13_arg0, f13_arg1, f13_arg2)
    local f13_local0 = 6.3 - f13_arg0:GetMapHitRadius(TARGET_SELF)
    local f13_local1 = 6.3 - f13_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f13_local2 = 6.3 - f13_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f13_local3 = 100
    local f13_local4 = 0
    local f13_local5 = 1.5
    local f13_local6 = 3
    Approach_Act_Flex(f13_arg0, f13_arg1, f13_local0, f13_local1, f13_local2, f13_local3, f13_local4, f13_local5, f13_local6)
    local f13_local7 = 0
    local f13_local8 = 0
    f13_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3015, TARGET_ENE_0, 9999, f13_local7, f13_local8, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act12 = function (f14_arg0, f14_arg1, f14_arg2)
    local f14_local0 = 8.2 - f14_arg0:GetMapHitRadius(TARGET_SELF)
    local f14_local1 = 8.2 - f14_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f14_local2 = 8.2 - f14_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f14_local3 = 100
    local f14_local4 = 0
    local f14_local5 = 5
    local f14_local6 = 10
    Approach_Act_Flex(f14_arg0, f14_arg1, f14_local0, f14_local1, f14_local2, f14_local3, f14_local4, f14_local5, f14_local6)
    local f14_local7 = 0
    local f14_local8 = 0
    f14_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3016, TARGET_ENE_0, 7 - f14_arg0:GetMapHitRadius(TARGET_SELF), f14_local7, f14_local8, 0, 0)
    f14_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3019, TARGET_ENE_0, 9999, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act13 = function (f15_arg0, f15_arg1, f15_arg2)
    local f15_local0 = 6.8 - f15_arg0:GetMapHitRadius(TARGET_SELF)
    local f15_local1 = 6.8 - f15_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f15_local2 = 6.8 - f15_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f15_local3 = 100
    local f15_local4 = 0
    local f15_local5 = 1.5
    local f15_local6 = 3
    Approach_Act_Flex(f15_arg0, f15_arg1, f15_local0, f15_local1, f15_local2, f15_local3, f15_local4, f15_local5, f15_local6)
    local f15_local7 = 0
    local f15_local8 = 0
    f15_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3017, TARGET_ENE_0, 9999, f15_local7, f15_local8, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act20 = function (f16_arg0, f16_arg1, f16_arg2)
    local f16_local0 = 10 - f16_arg0:GetMapHitRadius(TARGET_SELF)
    local f16_local1 = 10 - f16_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f16_local2 = 10 - f16_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f16_local3 = 100
    local f16_local4 = 0
    local f16_local5 = 5
    local f16_local6 = 10
    local f16_local7 = 6.8 - f16_arg0:GetMapHitRadius(TARGET_SELF)
    local f16_local8 = 0
    local f16_local9 = 0
    f16_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3012, TARGET_ENE_0, 9999, f16_local8, f16_local9, 0, 0)
    f16_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3022, TARGET_ENE_0, 9999, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act21 = function (f17_arg0, f17_arg1, f17_arg2)
    local f17_local0 = 3
    local f17_local1 = 45
    f17_arg1:AddSubGoal(GOAL_COMMON_Turn, f17_local0, TARGET_ENE_0, f17_local1, -1, GOAL_RESULT_Success, true)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act23 = function (f18_arg0, f18_arg1, f18_arg2)
    local f18_local0 = f18_arg0:GetRandam_Int(1, 100)
    local f18_local1 = -1
    local f18_local2 = 0
    if SpaceCheck(f18_arg0, f18_arg1, -90, 1) == true then
        if SpaceCheck(f18_arg0, f18_arg1, 90, 1) == true then
            if f18_arg0:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_R, 180, 999) then
                f18_local2 = 1
            else
                f18_local2 = 0
            end
        else
            f18_local2 = 0
        end
    elseif SpaceCheck(f18_arg0, f18_arg1, 90, 1) == true then
        f18_local2 = 1
    else
    end
    local f18_local3 = 3
    local f18_local4 = f18_arg0:GetRandam_Int(30, 45)
    f18_arg0:SetNumber(10, f18_local2)
    f18_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f18_local3, TARGET_ENE_0, f18_local2, f18_local4, true, true, f18_local1)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act25 = function (f19_arg0, f19_arg1, f19_arg2)
    local f19_local0 = f19_arg0:GetRandam_Float(2, 4)
    local f19_local1 = f19_arg0:GetRandam_Float(1, 3)
    f19_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, f19_local0, TARGET_ENE_0, f19_local1, TARGET_ENE_0, true, -1)
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
    if f22_local0 <= 5 then
        f22_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f22_local1, TARGET_ENE_0, f22_local5, f22_local3, true, true, f22_local4)
    else
        f22_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, f22_local2, TARGET_ENE_0, 3, TARGET_SELF, true, -1)
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act30 = function (f23_arg0, f23_arg1, f23_arg2)
    local f23_local0 = 1.6
    local f23_local1 = f23_local0
    local f23_local2 = f23_local0
    local f23_local3 = 100
    local f23_local4 = 0
    local f23_local5 = 1.5
    local f23_local6 = 2.5
    Approach_Act_Flex(f23_arg0, f23_arg1, f23_local0, f23_local1, f23_local2, f23_local3, f23_local4, f23_local5, f23_local6)
    local f23_local7 = 5.2 - f23_arg0:GetMapHitRadius(TARGET_SELF)
    local f23_local8 = 0
    local f23_local9 = 0
    f23_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3000, TARGET_ENE_0, f23_local7, f23_local8, f23_local9, 0, 0)
    f23_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3001, TARGET_ENE_0, 9999, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act31 = function (f24_arg0, f24_arg1, f24_arg2)
    local f24_local0 = 1.6
    local f24_local1 = f24_local0
    local f24_local2 = f24_local0
    local f24_local3 = 100
    local f24_local4 = 0
    local f24_local5 = 1.5
    local f24_local6 = 2.5
    Approach_Act_Flex(f24_arg0, f24_arg1, f24_local0, f24_local1, f24_local2, f24_local3, f24_local4, f24_local5, f24_local6)
    local f24_local7 = 0
    local f24_local8 = 0
    f24_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3002, TARGET_ENE_0, 5.1 - f24_arg0:GetMapHitRadius(TARGET_SELF), f24_local7, f24_local8, 0, 0)
    f24_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3020, TARGET_ENE_0, 5.3 - f24_arg0:GetMapHitRadius(TARGET_SELF), 0)
    f24_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3005, TARGET_ENE_0, 5.1 - f24_arg0:GetMapHitRadius(TARGET_SELF), 0)
    f24_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3020, TARGET_ENE_0, 9999, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act41 = function (f25_arg0, f25_arg1, f25_arg2)
    local f25_local0 = 3.5
    local f25_local1 = f25_arg0:GetRandam_Int(30, 45)
    local f25_local2 = 0
    if SpaceCheck(f25_arg0, f25_arg1, -90, 1) == true then
        if SpaceCheck(f25_arg0, f25_arg1, 90, 1) == true then
            if f25_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                f25_local2 = 0
            else
                f25_local2 = 1
            end
        else
            f25_local2 = 0
        end
    elseif SpaceCheck(f25_arg0, f25_arg1, 90, 1) == true then
        f25_local2 = 1
    else
    end
    f25_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f25_local0, TARGET_ENE_0, f25_local2, f25_local1, true, true, -1)
    return GETWELLSPACE_ODDS
    
end

Goal.Interrupt = function (f26_arg0, f26_arg1, f26_arg2)
    local f26_local0 = f26_arg1:GetSpecialEffectActivateInterruptType(0)
    if f26_arg1:IsLadderAct(TARGET_SELF) then
        return false
    end
    if not f26_arg1:HasSpecialEffectId(TARGET_SELF, 200004) then
        return false
    end
    if f26_arg1:IsInterupt(INTERUPT_ParryTiming) then
        return f26_arg0.Parry(f26_arg1, f26_arg2, 50, 0, -1)
    end
    if f26_arg1:IsInterupt(INTERUPT_Damaged) and f26_arg0.Damaged(f26_arg1, f26_arg2) then
        return true
    end
    if f26_arg1:IsInterupt(INTERUPT_ShootImpact) and f26_arg0.ShootReaction(f26_arg1, f26_arg2) then
        return true
    end
    if Interupt_PC_Break(f26_arg1) then
        f26_arg1:Replanning()
        return true
    end
    if f26_arg1:IsInterupt(INTERUPT_ActivateSpecialEffect) then
        if f26_arg1:GetSpecialEffectActivateInterruptType(0) == 3107001 then
            if f26_arg1:HasSpecialEffectId(TARGET_SELF, 3107000) then
                f26_arg2:ClearSubGoal()
                if f26_arg1:HasSpecialEffectId(TARGET_SELF, 200050) and not f26_arg1:IsTargetGuard(TARGET_ENE_0) then
                    f26_arg2:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3018, TARGET_ENE_0, 9999, 0, 0)
                elseif f26_arg1:HasSpecialEffectId(TARGET_SELF, 200051) then
                    f26_arg2:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3022, TARGET_ENE_0, 9999, 0, 0)
                else
                    f26_arg2:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3003, TARGET_ENE_0, 9999, 0, 0)
                end
                return true
            else
                return false
            end
        elseif f26_arg1:GetSpecialEffectActivateInterruptType(0) == 5025 then
            return f26_arg0.Damaged(f26_arg1, f26_arg2)
        elseif f26_arg1:GetSpecialEffectActivateInterruptType(0) == 5026 then
        end
        return false
    end
    return false
    
end

Goal.Damaged = function (f27_arg0, f27_arg1, f27_arg2)
    local f27_local0 = f27_arg0:GetRandam_Int(1, 100)
    if f27_arg0:HasSpecialEffectId(TARGET_SELF, 5025) then
        f27_arg1:ClearSubGoal()
        f27_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 1, 3103, TARGET_ENE_0, 9999, 0)
        return true
    end
    return false
    
end

Goal.Parry = function (f28_arg0, f28_arg1, f28_arg2, f28_arg3, f28_arg4, f28_arg5)
    local f28_local0 = f28_arg0:GetDist(TARGET_ENE_0)
    local f28_local1 = GetDist_Parry(f28_arg0)
    local f28_local2 = f28_arg0:GetRandam_Int(1, 100)
    local f28_local3 = f28_arg0:GetRandam_Int(1, 100)
    local f28_local4 = f28_arg0:GetRandam_Int(1, 100)
    local f28_local5 = f28_arg0:HasSpecialEffectId(TARGET_ENE_0, 109970)
    local f28_local6 = f28_arg0:HasSpecialEffectId(TARGET_ENE_0, COMMON_SP_EFFECT_PC_ATTACK_RUSH)
    local f28_local7 = -1
    if f28_arg0:HasSpecialEffectId(TARGET_SELF, 221000) then
        f28_local7 = 0
    elseif f28_arg0:HasSpecialEffectId(TARGET_SELF, 221001) then
        f28_local7 = 1
    elseif f28_arg0:HasSpecialEffectId(TARGET_SELF, 221002) then
        f28_local7 = 2
    end
    if f28_arg0:IsFinishTimer(AI_TIMER_PARRY_INTERVAL) == false then
        return false
    end
    if f28_local7 == -1 then
        return false
    end
    if f28_arg0:HasSpecialEffectId(TARGET_SELF, 220062) then
        return false
    end
    if f28_arg0:HasSpecialEffectId(TARGET_ENE_0, 110450) or f28_arg0:HasSpecialEffectId(TARGET_ENE_0, 110501) or f28_arg0:HasSpecialEffectId(TARGET_ENE_0, 110500) then
        return false
    end
    f28_arg0:SetTimer(AI_TIMER_PARRY_INTERVAL, 0.1)
    if f28_arg2 == nil then
        f28_arg2 = 50
    end
    if f28_arg3 == nil then
        f28_arg3 = 0
    end
    if f28_arg4 == nil then
        f28_arg4 = 0
    end
    if f28_arg5 == nil then
        f28_arg5 = 3100
    end
    if f28_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) and f28_arg0:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_F, 90, f28_local1) then
        if f28_local6 then
            return false
        elseif f28_local5 then
            if f28_arg0:IsTargetGuard(TARGET_SELF) and ReturnKengekiSpecialEffect(f28_arg0) == false then
                return false
            else
                if f28_local7 == 2 then
                    return false
                elseif f28_local7 == 1 then
                    if f28_local2 <= 50 then
                        f28_arg1:ClearSubGoal()
                        f28_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.3, 3101, TARGET_ENE_0, 9999, 0)
                        return true
                    end
                elseif f28_local7 == 0 and f28_local2 <= 100 then
                    f28_arg1:ClearSubGoal()
                    f28_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.3, 3101, TARGET_ENE_0, 9999, 0)
                    return true
                end
                return false
            end
        elseif f28_arg0:HasSpecialEffectId(TARGET_ENE_0, 109980) and f28_arg4 ~= -1 and f28_local7 == 0 then
            if f28_arg4 == 1 then
                f28_arg1:ClearSubGoal()
                f28_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 1, 5201, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0)
                return true
            else
                f28_arg1:ClearSubGoal()
                f28_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 1, 5211, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0)
                return true
            end
        elseif f28_local3 <= Get_ConsecutiveGuardCount(f28_arg0) * f28_arg2 then
            f28_arg1:ClearSubGoal()
            f28_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.3, 3101, TARGET_ENE_0, 9999, 0)
            return true
        else
            f28_arg1:ClearSubGoal()
            f28_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.3, 3100, TARGET_ENE_0, 9999, 0)
            return true
        end
    elseif f28_arg0:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_F, 90, f28_local1 + 1) then
        if f28_arg4 ~= -1 and f28_local4 <= f28_arg3 then
            if f28_arg4 == 1 then
                f28_arg1:ClearSubGoal()
                f28_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 1, 5201, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0)
                return true
            else
                f28_arg1:ClearSubGoal()
                f28_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 1, 5211, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0)
                return true
            end
        else
            return false
        end
    else
        return false
    end
    
end

Goal.ShootReaction = function (f29_arg0, f29_arg1)
    return false
    
end

Goal.Kengeki_Activate = function (f30_arg0, f30_arg1, f30_arg2, f30_arg3)
    local f30_local0 = ReturnKengekiSpecialEffect(f30_arg1)
    if f30_local0 == 0 then
        return false
    end
    local f30_local1 = {}
    local f30_local2 = {}
    local f30_local3 = {}
    Common_Clear_Param(f30_local1, f30_local2, f30_local3)
    local f30_local4 = f30_arg1:GetDist(TARGET_ENE_0)
    local f30_local5 = f30_arg1:GetSp(TARGET_SELF)
    if f30_local5 <= 0 then
        f30_local1[50] = 100
    elseif f30_local0 == 200200 or f30_local0 == 200205 then
        if f30_local4 >= 5 then
            f30_local1[50] = 100
        elseif f30_local4 <= 0.2 then
            f30_local1[50] = 100
        else
            f30_local1[2] = 200
            f30_local1[5] = 400
            f30_local1[50] = 100
        end
    elseif f30_local0 == 200201 or f30_local0 == 200206 then
        if f30_local4 >= 5 then
            f30_local1[50] = 100
        elseif f30_local4 <= 0.2 then
            f30_local1[50] = 100
        else
            f30_local1[3] = 300
            f30_local1[6] = 400
            f30_local1[50] = 100
        end
    elseif f30_local0 == 200210 or f30_local0 == 200215 then
        if f30_local4 >= 5 then
            f30_local1[50] = 100
        elseif f30_local4 <= 0.2 then
            f30_local1[50] = 100
        else
            f30_local1[2] = 200
            f30_local1[5] = 300
        end
    elseif f30_local0 == 200211 or f30_local0 == 200216 then
        if f30_local4 >= 5 then
            f30_local1[50] = 100
        elseif f30_local4 <= 0.2 then
            f30_local1[50] = 100
        else
            f30_local1[3] = 200
            f30_local1[6] = 300
        end
    elseif f30_local0 == 200225 then
        f30_local1[4] = 10000
        if f30_local4 >= 5 then
        elseif f30_local4 <= 0.2 then
        else
            f30_local1[1] = 200
            f30_local1[50] = 100
        end
    else
        f30_local1[50] = 1
    end
    if f30_arg1:HasSpecialEffectId(TARGET_SELF, 200050) then
        f30_local1[4] = 0
    end
    f30_local1[1] = SetCoolTime(f30_arg1, f30_arg2, 3090, 5, f30_local1[1], 1)
    f30_local1[2] = SetCoolTime(f30_arg1, f30_arg2, 3062, 6, f30_local1[2], 1)
    f30_local1[2] = SetCoolTime(f30_arg1, f30_arg2, 3004, 6, f30_local1[2], 1)
    f30_local1[3] = SetCoolTime(f30_arg1, f30_arg2, 3067, 2, f30_local1[3], 1)
    f30_local1[4] = SetCoolTime(f30_arg1, f30_arg2, 3091, 2, f30_local1[4], 1)
    f30_local1[5] = SetCoolTime(f30_arg1, f30_arg2, 3061, 6, f30_local1[5], 1)
    f30_local1[6] = SetCoolTime(f30_arg1, f30_arg2, 3068, 6, f30_local1[6], 1)
    f30_local2[1] = REGIST_FUNC(f30_arg1, f30_arg2, f30_arg0.Kengeki01)
    f30_local2[2] = REGIST_FUNC(f30_arg1, f30_arg2, f30_arg0.Kengeki02)
    f30_local2[3] = REGIST_FUNC(f30_arg1, f30_arg2, f30_arg0.Kengeki03)
    f30_local2[4] = REGIST_FUNC(f30_arg1, f30_arg2, f30_arg0.Kengeki04)
    f30_local2[5] = REGIST_FUNC(f30_arg1, f30_arg2, f30_arg0.Kengeki05)
    f30_local2[6] = REGIST_FUNC(f30_arg1, f30_arg2, f30_arg0.Kengeki06)
    f30_local2[50] = REGIST_FUNC(f30_arg1, f30_arg2, f30_arg0.NoAction)
    local f30_local6 = REGIST_FUNC(f30_arg1, f30_arg2, f30_arg0.ActAfter_AdjustSpace)
    return Common_Kengeki_Activate(f30_arg1, f30_arg2, f30_local1, f30_local2, f30_local6, f30_local3)
    
end

Goal.Kengeki01 = function (f31_arg0, f31_arg1, f31_arg2)
    f31_arg1:ClearSubGoal()
    f31_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3090, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.Kengeki02 = function (f32_arg0, f32_arg1, f32_arg2)
    f32_arg1:ClearSubGoal()
    f32_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3062, TARGET_ENE_0, 7 - f32_arg0:GetMapHitRadius(TARGET_SELF), 0)
    f32_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3021, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.Kengeki03 = function (f33_arg0, f33_arg1, f33_arg2)
    f33_arg1:ClearSubGoal()
    f33_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3067, TARGET_ENE_0, 5.3 - f33_arg0:GetMapHitRadius(TARGET_SELF), 0)
    f33_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3005, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.Kengeki04 = function (f34_arg0, f34_arg1, f34_arg2)
    f34_arg1:ClearSubGoal()
    f34_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3091, TARGET_ENE_0, 6.8 - f34_arg0:GetMapHitRadius(TARGET_SELF), 0)
    f34_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3013, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.Kengeki05 = function (f35_arg0, f35_arg1, f35_arg2)
    f35_arg1:ClearSubGoal()
    f35_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3061, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.Kengeki06 = function (f36_arg0, f36_arg1, f36_arg2)
    f36_arg1:ClearSubGoal()
    f36_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3068, TARGET_ENE_0, 9999, 0, 0)
    
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


