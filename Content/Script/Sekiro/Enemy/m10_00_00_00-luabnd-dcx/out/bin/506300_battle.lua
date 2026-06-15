RegisterTableGoal(GOAL_NingunOsa_506300_Battle, "GOAL_NingunOsa_506300_Battle")
REGISTER_GOAL_NO_UPDATE(GOAL_NingunOsa_506300_Battle, true)

Goal.Initialize = function (f1_arg0, f1_arg1, f1_arg2, f1_arg3)
    
end

Goal.Activate = function (f2_arg0, f2_arg1, f2_arg2)
    Init_Pseudo_Global(f2_arg1, f2_arg2)
    local f2_local0 = {}
    local f2_local1 = {}
    local f2_local2 = {}
    Common_Clear_Param(f2_local0, f2_local1, f2_local2)
    local f2_local3 = f2_arg1:GetHpRate(TARGET_SELF)
    local f2_local4 = f2_arg1:GetSp(TARGET_SELF)
    local f2_local5 = f2_arg1:GetDist(TARGET_ENE_0)
    local f2_local6 = f2_arg1:GetRandam_Int(1, 100)
    local f2_local7 = f2_arg1:GetExcelParam(AI_EXCEL_THINK_PARAM_TYPE__thinkAttr_doAdmirer)
    local f2_local8 = f2_arg1:GetEventRequest()
    local f2_local9 = f2_arg1:GetSpRate(TARGET_SELF)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 110010)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 110125)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 3506000)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 3506030)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 3506004)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 3506021)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 5030)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 3506080)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 3506022)
    Set_ConsecutiveGuardCount_Interrupt(f2_arg1)
    if f2_arg0.Kengeki_Activate(f2_arg0, f2_arg1, f2_arg2) then
        return
    end
    if f2_arg1:GetNumber(8) == 1 and f2_arg1:HasSpecialEffectId(TARGET_SELF, 3506030) and f2_arg1:HasSpecialEffectId(TARGET_SELF, 3506080) then
        f2_local0[20] = 100
    elseif f2_arg1:GetNumber(9) == 1 and f2_arg1:HasSpecialEffectId(TARGET_SELF, 3506030) == false then
        f2_local0[34] = 100
        f2_local0[46] = 100
    elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 3506030) or f2_arg1:HasSpecialEffectId(TARGET_SELF, 3506080) then
        f2_local0[26] = 100
    elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 200051) and f2_arg1:GetNumber(3) == 0 then
        f2_local0[42] = 100
    elseif f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 110060) or f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 110010) then
        if f2_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) then
            f2_local0[21] = 1
            f2_local0[28] = 100
        else
            f2_local0[21] = 100
        end
    elseif Common_ActivateAct(f2_arg1, f2_arg2, 0, 1) then
    elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 3506040) then
        if f2_local5 > 8 then
            f2_local0[39] = 200
        else
            f2_local0[37] = 100
        end
    elseif f2_arg1:HasSpecialEffectId(TARGET_ENE_0, COMMON_SP_EFFECT_PC_BREAK) then
        f2_local0[40] = 100
    elseif f2_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_B, 180) then
        if f2_local5 > 7 then
            f2_local0[21] = 100
            f2_local0[30] = 1
            f2_local0[31] = 1
        elseif f2_local5 > 5 then
            f2_local0[21] = 1
            f2_local0[30] = 100
            f2_local0[31] = 50
        else
            f2_local0[21] = 1
            f2_local0[30] = 100
            f2_local0[31] = 1
        end
    elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 5031) then
        if f2_local5 >= 6.5 then
            f2_local0[11] = 100
        else
            f2_local0[3] = 100
        end
    elseif f2_arg1:GetNumber(5) >= 30 then
        if f2_local5 >= 3 then
            f2_local0[23] = 100
        else
            f2_local0[7] = 100
            f2_local0[24] = 100
        end
    elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 3506030) == false and f2_arg1:IsFinishTimer(1) and f2_arg1:HasSpecialEffectId(TARGET_SELF, 200051) and f2_arg1:HasSpecialEffectId(TARGET_SELF, 5034) == false and f2_local5 <= 12 and f2_local5 >= 3 then
        f2_local0[20] = 100
    elseif f2_local5 >= 10 then
        f2_local0[1] = 0
        f2_local0[3] = 0
        f2_local0[4] = 0
        f2_local0[6] = 100
        f2_local0[8] = 200
        f2_local0[9] = 150
        f2_local0[10] = 0
        f2_local0[11] = 100
        f2_local0[12] = 300
        f2_local0[15] = 200
        f2_local0[17] = 300
        f2_local0[30] = 0
        f2_local0[31] = 100
        f2_local0[35] = 500
        f2_local0[45] = 300
    elseif f2_local5 >= 7 then
        f2_local0[1] = 0
        f2_local0[3] = 0
        f2_local0[4] = 0
        f2_local0[6] = 100
        f2_local0[8] = 200
        f2_local0[9] = 150
        f2_local0[10] = 0
        f2_local0[11] = 100
        f2_local0[12] = 250
        f2_local0[15] = 200
        f2_local0[17] = 300
        f2_local0[30] = 0
        f2_local0[31] = 100
        f2_local0[32] = 200
        f2_local0[43] = 100
    elseif f2_local5 > 3 then
        f2_local0[1] = 300
        f2_local0[3] = 250
        f2_local0[4] = 100
        f2_local0[6] = 0
        f2_local0[8] = 0
        f2_local0[9] = 0
        f2_local0[10] = 100
        f2_local0[11] = 0
        f2_local0[12] = 0
        f2_local0[15] = 0
        f2_local0[17] = 100
        f2_local0[30] = 300
        f2_local0[31] = 0
        f2_local0[32] = 200
        f2_local0[43] = 100
        if f2_arg1:GetNinsatsuNum() <= 1 and f2_arg1:HasSpecialEffectId(TARGET_SELF, 3506030) == false and f2_arg1:GetNumber(10) == 2 then
            f2_local0[34] = 7
            f2_local0[46] = 5
        end
    else
        f2_local0[1] = 400
        f2_local0[3] = 200
        f2_local0[4] = 100
        f2_local0[6] = 0
        f2_local0[8] = 0
        f2_local0[9] = 0
        f2_local0[10] = 100
        f2_local0[11] = 0
        f2_local0[12] = 0
        f2_local0[15] = 0
        f2_local0[17] = 0
        f2_local0[30] = 250
        f2_local0[31] = 0
        f2_local0[43] = 100
        if f2_arg1:GetNinsatsuNum() <= 1 and f2_arg1:HasSpecialEffectId(TARGET_SELF, 3506030) == false and f2_arg1:GetNumber(10) == 2 then
            f2_local0[34] = 7
            f2_local0[46] = 5
        end
    end
    if SpaceCheck(f2_arg1, f2_arg2, 45, 2) == false and SpaceCheck(f2_arg1, f2_arg2, -45, 2) == false then
    end
    if SpaceCheck(f2_arg1, f2_arg2, 90, 1) == false and SpaceCheck(f2_arg1, f2_arg2, -90, 1) == false then
        f2_local0[23] = 1
    end
    if SpaceCheck(f2_arg1, f2_arg2, 90, 5) == false and SpaceCheck(f2_arg1, f2_arg2, -90, 5) == false then
        f2_local0[31] = 1
    end
    if SpaceCheck(f2_arg1, f2_arg2, -135, 3) == false and SpaceCheck(f2_arg1, f2_arg2, 135, 3) == false then
        f2_local0[30] = 1
    end
    if SpaceCheck(f2_arg1, f2_arg2, 180, 1) == false then
        f2_local0[25] = 1
    end
    if f2_local9 > 0.8 then
        f2_local0[18] = 0
    end
    f2_local0[1] = SetCoolTime(f2_arg1, f2_arg2, 3000, 5, f2_local0[1], 1)
    f2_local0[3] = SetCoolTime(f2_arg1, f2_arg2, 3020, 10, f2_local0[3], 1)
    f2_local0[3] = SetCoolTime(f2_arg1, f2_arg2, 3021, 10, f2_local0[3], 1)
    f2_local0[3] = SetCoolTime(f2_arg1, f2_arg2, 3022, 10, f2_local0[3], 1)
    f2_local0[3] = SetCoolTime(f2_arg1, f2_arg2, 3023, 10, f2_local0[3], 1)
    f2_local0[4] = SetCoolTime(f2_arg1, f2_arg2, 3005, 4, f2_local0[4], 1)
    f2_local0[4] = SetCoolTime(f2_arg1, f2_arg2, 3006, 8, f2_local0[4], 1)
    f2_local0[4] = SetCoolTime(f2_arg1, f2_arg2, 3007, 8, f2_local0[4], 1)
    f2_local0[6] = SetCoolTime(f2_arg1, f2_arg2, 3003, 15, f2_local0[6], 1)
    f2_local0[7] = SetCoolTime(f2_arg1, f2_arg2, 3010, 15, f2_local0[7], 1)
    f2_local0[7] = SetCoolTime(f2_arg1, f2_arg2, 3064, 15, f2_local0[7], 1)
    f2_local0[8] = SetCoolTime(f2_arg1, f2_arg2, 3011, 10, f2_local0[8], 1)
    f2_local0[8] = SetCoolTime(f2_arg1, f2_arg2, 3012, 10, f2_local0[8], 1)
    f2_local0[9] = SetCoolTime(f2_arg1, f2_arg2, 3015, 10, f2_local0[9], 1)
    f2_local0[10] = SetCoolTime(f2_arg1, f2_arg2, 3010, 15, f2_local0[10], 1)
    f2_local0[10] = SetCoolTime(f2_arg1, f2_arg2, 3064, 15, f2_local0[10], 1)
    f2_local0[11] = SetCoolTime(f2_arg1, f2_arg2, 3020, 10, f2_local0[11], 1)
    f2_local0[11] = SetCoolTime(f2_arg1, f2_arg2, 3021, 10, f2_local0[11], 1)
    f2_local0[11] = SetCoolTime(f2_arg1, f2_arg2, 3022, 10, f2_local0[11], 1)
    f2_local0[11] = SetCoolTime(f2_arg1, f2_arg2, 3023, 10, f2_local0[11], 1)
    f2_local0[12] = SetCoolTime(f2_arg1, f2_arg2, 3018, 10, f2_local0[12], 1)
    f2_local0[15] = SetCoolTime(f2_arg1, f2_arg2, 3011, 10, f2_local0[15], 1)
    f2_local0[15] = SetCoolTime(f2_arg1, f2_arg2, 3012, 10, f2_local0[15], 1)
    f2_local0[17] = SetCoolTime(f2_arg1, f2_arg2, 3033, 16, f2_local0[17], 1)
    f2_local0[18] = SetCoolTime(f2_arg1, f2_arg2, 3018, 25, f2_local0[18], 1)
    f2_local0[19] = SetCoolTime(f2_arg1, f2_arg2, 3049, 10, f2_local0[19], 1)
    f2_local0[20] = SetCoolTime(f2_arg1, f2_arg2, 3010, 25, f2_local0[20], 1)
    f2_local0[23] = SetCoolTime(f2_arg1, f2_arg2, 405002, 5, f2_local0[23], 1)
    f2_local0[23] = SetCoolTime(f2_arg1, f2_arg2, 405003, 5, f2_local0[23], 1)
    f2_local0[30] = SetCoolTime(f2_arg1, f2_arg2, 5202, 5, f2_local0[30], 1)
    f2_local0[30] = SetCoolTime(f2_arg1, f2_arg2, 5203, 5, f2_local0[30], 1)
    f2_local0[31] = SetCoolTime(f2_arg1, f2_arg2, 405012, 3, f2_local0[31], 1)
    f2_local0[31] = SetCoolTime(f2_arg1, f2_arg2, 405013, 3, f2_local0[31], 1)
    f2_local0[32] = SetCoolTime(f2_arg1, f2_arg2, 3048, 10, f2_local0[32], 1)
    f2_local0[34] = SetCoolTime(f2_arg1, f2_arg2, 3093, 25, f2_local0[34], 1)
    f2_local0[35] = SetCoolTime(f2_arg1, f2_arg2, 3092, 10, f2_local0[35], 1)
    f2_local0[43] = SetCoolTime(f2_arg1, f2_arg2, 3048, 10, f2_local0[43], 1)
    f2_local0[44] = SetCoolTime(f2_arg1, f2_arg2, 3049, 10, f2_local0[44], 1)
    f2_local0[46] = SetCoolTime(f2_arg1, f2_arg2, 3044, 25, f2_local0[46], 1)
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
    f2_local1[16] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act16)
    f2_local1[17] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act17)
    f2_local1[18] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act18)
    f2_local1[19] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act19)
    f2_local1[20] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act20)
    f2_local1[21] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act21)
    f2_local1[22] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act22)
    f2_local1[23] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act23)
    f2_local1[24] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act24)
    f2_local1[25] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act25)
    f2_local1[26] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act26)
    f2_local1[27] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act27)
    f2_local1[28] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act28)
    f2_local1[29] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act29)
    f2_local1[30] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act30)
    f2_local1[31] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act31)
    f2_local1[32] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act32)
    f2_local1[33] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act33)
    f2_local1[34] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act34)
    f2_local1[35] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act35)
    f2_local1[36] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act36)
    f2_local1[37] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act37)
    f2_local1[38] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act38)
    f2_local1[39] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act39)
    f2_local1[40] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act40)
    f2_local1[41] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act41)
    f2_local1[42] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act42)
    f2_local1[43] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act43)
    f2_local1[44] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act44)
    f2_local1[49] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act49)
    f2_local1[50] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act50)
    f2_local1[45] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act45)
    f2_local1[46] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act46)
    f2_local1[47] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act47)
    f2_local1[48] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act48)
    local f2_local10 = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.ActAfter_AdjustSpace)
    Common_Battle_Activate(f2_arg1, f2_arg2, f2_local0, f2_local1, f2_local10, f2_local2)
    
end

Goal.Act01 = function (f3_arg0, f3_arg1, f3_arg2)
    local f3_local0 = 4.8 - f3_arg0:GetMapHitRadius(TARGET_SELF)
    local f3_local1 = 4.8 - f3_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f3_local2 = 4.8 - f3_arg0:GetMapHitRadius(TARGET_SELF) + 3
    local f3_local3 = 100
    local f3_local4 = 0
    local f3_local5 = 1.5
    local f3_local6 = 3
    Approach_Act_Flex(f3_arg0, f3_arg1, f3_local0, f3_local1, f3_local2, f3_local3, f3_local4, f3_local5, f3_local6)
    local f3_local7 = 0
    local f3_local8 = 0
    local f3_local9 = f3_arg0:GetRandam_Int(1, 100)
    f3_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3000, TARGET_ENE_0, 4.2 - f3_arg0:GetMapHitRadius(TARGET_SELF), f3_local7, f3_local8, 0, 0):TimingSetNumber(5, f3_arg0:GetNumber(5) + 6, AI_TIMING_SET__ACTIVATE)
    if f3_local9 <= 30 then
        f3_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3001, TARGET_ENE_0, 3 - f3_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f3_arg0:GetNumber(5) + 8, AI_TIMING_SET__ACTIVATE)
        f3_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3013, TARGET_ENE_0, 6 - f3_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f3_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
        f3_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3017, TARGET_ENE_0, 9999, 0):TimingSetNumber(5, f3_arg0:GetNumber(5) + 15, AI_TIMING_SET__ACTIVATE)
    else
        f3_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3001, TARGET_ENE_0, 5.8 - f3_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f3_arg0:GetNumber(5) + 8, AI_TIMING_SET__ACTIVATE)
        if f3_local9 <= 80 then
            f3_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3023, TARGET_ENE_0, 5.8 - f3_arg0:GetMapHitRadius(TARGET_SELF), 0)
        else
            f3_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3024, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f3_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
        end
    end
    if f3_arg0:GetNumber(10) == 0 then
        f3_arg0:SetNumber(10, 1)
    elseif f3_arg0:GetNumber(10) == 1 then
        f3_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act02 = function (f4_arg0, f4_arg1, f4_arg2)
    local f4_local0 = 5.7 - f4_arg0:GetMapHitRadius(TARGET_SELF)
    local f4_local1 = 5.7 - f4_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f4_local2 = 5.7 - f4_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f4_local3 = 100
    local f4_local4 = 0
    local f4_local5 = 1.5
    local f4_local6 = 3
    local f4_local7 = f4_arg0:GetRandam_Int(1, 100)
    Approach_Act_Flex(f4_arg0, f4_arg1, f4_local0, f4_local1, f4_local2, f4_local3, f4_local4, f4_local5, f4_local6)
    local f4_local8 = 0
    local f4_local9 = 0
    f4_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3004, TARGET_ENE_0, 6.5 - f4_arg0:GetMapHitRadius(TARGET_SELF), f4_local8, f4_local9, 0, 0):TimingSetNumber(5, f4_arg0:GetNumber(5) + 8, AI_TIMING_SET__ACTIVATE)
    f4_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3048, TARGET_ENE_0, 9999, f4_local8, f4_local9, 0, 0):TimingSetNumber(5, f4_arg0:GetNumber(5) + 5, AI_TIMING_SET__ACTIVATE)
    if f4_arg0:GetNumber(10) == 0 then
        f4_arg0:SetNumber(10, 1)
    elseif f4_arg0:GetNumber(10) == 1 then
        f4_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act03 = function (f5_arg0, f5_arg1, f5_arg2)
    local f5_local0 = f5_arg0:GetDist(TARGET_ENE_0)
    local f5_local1 = 0
    local f5_local2 = 0
    if f5_local0 <= 5 then
        f5_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3023, TARGET_ENE_0, 10 - f5_arg0:GetMapHitRadius(TARGET_SELF), f5_local2, f5_local1, 0, 0)
    else
        f5_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3021, TARGET_ENE_0, 10 - f5_arg0:GetMapHitRadius(TARGET_SELF), f5_local2, f5_local1, 0, 0)
    end
    f5_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3024, TARGET_ENE_0, 6.5 - f5_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f5_arg0:GetNumber(5) + 8, AI_TIMING_SET__ACTIVATE)
    f5_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3027, TARGET_ENE_0, 9999, f5_local2, f5_local1):TimingSetNumber(5, f5_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    if f5_arg0:GetNumber(10) == 0 then
        f5_arg0:SetNumber(10, 1)
    elseif f5_arg0:GetNumber(10) == 1 then
        f5_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act04 = function (f6_arg0, f6_arg1, f6_arg2)
    local f6_local0 = 2.8 - f6_arg0:GetMapHitRadius(TARGET_SELF)
    local f6_local1 = 2.8 - f6_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f6_local2 = 2.8 - f6_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f6_local3 = 100
    local f6_local4 = 0
    local f6_local5 = 0.5
    local f6_local6 = 1.5
    Approach_Act_Flex(f6_arg0, f6_arg1, f6_local0, f6_local1, f6_local2, f6_local3, f6_local4, f6_local5, f6_local6)
    local f6_local7 = 0
    local f6_local8 = 0
    f6_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3005, TARGET_ENE_0, 9999, f6_local7, f6_local8, 0, 0):TimingSetNumber(5, f6_arg0:GetNumber(5) + 5, AI_TIMING_SET__ACTIVATE)
    if f6_arg0:GetNumber(10) == 0 then
        f6_arg0:SetNumber(10, 1)
    elseif f6_arg0:GetNumber(10) == 1 then
        f6_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act05 = function (f7_arg0, f7_arg1, f7_arg2)
    local f7_local0 = 3.3 - f7_arg0:GetMapHitRadius(TARGET_SELF)
    local f7_local1 = 3.3 - f7_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f7_local2 = 3.3 - f7_arg0:GetMapHitRadius(TARGET_SELF) + 3
    local f7_local3 = 100
    local f7_local4 = 0
    local f7_local5 = 1.5
    local f7_local6 = 3
    Approach_Act_Flex(f7_arg0, f7_arg1, f7_local0, f7_local1, f7_local2, f7_local3, f7_local4, f7_local5, f7_local6)
    local f7_local7 = 0
    local f7_local8 = 0
    f7_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3008, TARGET_ENE_0, 6 - f7_arg0:GetMapHitRadius(TARGET_SELF), f7_local7, f7_local8, 0, 0):TimingSetNumber(5, f7_arg0:GetNumber(5) + 8, AI_TIMING_SET__ACTIVATE)
    f7_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3017, TARGET_ENE_0, 9999, f7_local7, f7_local8, 0, 0):TimingSetNumber(5, f7_arg0:GetNumber(5) + 15, AI_TIMING_SET__ACTIVATE)
    if f7_arg0:GetNumber(10) == 0 then
        f7_arg0:SetNumber(10, 1)
    elseif f7_arg0:GetNumber(10) == 1 then
        f7_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act06 = function (f8_arg0, f8_arg1, f8_arg2)
    local f8_local0 = 10 - f8_arg0:GetMapHitRadius(TARGET_SELF) - 1
    local f8_local1 = 10 - f8_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f8_local2 = 10 - f8_arg0:GetMapHitRadius(TARGET_SELF) + 3
    local f8_local3 = 100
    local f8_local4 = 0
    local f8_local5 = 1.5
    local f8_local6 = 3
    local f8_local7 = f8_arg0:GetRandam_Int(1, 100)
    Approach_Act_Flex(f8_arg0, f8_arg1, f8_local0, f8_local1, f8_local2, f8_local3, f8_local4, f8_local5, f8_local6)
    local f8_local8 = 0
    local f8_local9 = 0
    f8_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3009, TARGET_ENE_0, 999 - f8_arg0:GetMapHitRadius(TARGET_SELF), f8_local8, f8_local9, 0, 0):TimingSetNumber(5, f8_arg0:GetNumber(5) + 1, AI_TIMING_SET__ACTIVATE)
    f8_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3014, TARGET_ENE_0, f8_local0, 0):TimingSetNumber(5, f8_arg0:GetNumber(5) + 2, AI_TIMING_SET__ACTIVATE)
    f8_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3003, TARGET_ENE_0, 6.2 - f8_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f8_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    f8_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3048, TARGET_ENE_0, 9999, f8_local8, f8_local9, 0, 0):TimingSetNumber(5, f8_arg0:GetNumber(5) + 5, AI_TIMING_SET__ACTIVATE)
    if f8_arg0:GetNumber(10) == 0 then
        f8_arg0:SetNumber(10, 1)
    elseif f8_arg0:GetNumber(10) == 1 then
        f8_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act07 = function (f9_arg0, f9_arg1, f9_arg2)
    local f9_local0 = 0
    local f9_local1 = 0
    f9_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3010, TARGET_ENE_0, 9999, f9_local0, f9_local1, 0, 0)
    local f9_local2 = 0
    if SpaceCheck(f9_arg0, f9_arg1, -90, 1) == true then
        if SpaceCheck(f9_arg0, f9_arg1, 90, 1) == true then
            if f9_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                f9_local2 = 0
            else
                f9_local2 = 1
            end
        else
            f9_local2 = 0
        end
    elseif SpaceCheck(f9_arg0, f9_arg1, 90, 1) == true then
        f9_local2 = 1
    else
    end
    local f9_local3 = f9_arg0:GetRandam_Float(2.5, 3.5)
    local f9_local4 = f9_arg0:GetRandam_Int(30, 45)
    local f9_local5 = f9_arg0:GetSpRate(TARGET_SELF)
    if f9_arg0:GetNumber(10) == 0 then
        f9_arg0:SetNumber(10, 1)
    elseif f9_arg0:GetNumber(10) == 1 then
        f9_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act08 = function (f10_arg0, f10_arg1, f10_arg2)
    local f10_local0 = f10_arg0:GetDist(TARGET_ENE_0)
    local f10_local1 = 11 - f10_arg0:GetMapHitRadius(TARGET_SELF)
    local f10_local2 = 11 - f10_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f10_local3 = 11 - f10_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f10_local4 = 100
    local f10_local5 = 0
    local f10_local6 = 1.5
    local f10_local7 = 3
    local f10_local8 = f10_arg0:GetRandam_Int(1, 100)
    Approach_Act_Flex(f10_arg0, f10_arg1, f10_local1, f10_local2, f10_local3, f10_local4, f10_local5, f10_local6, f10_local7)
    local f10_local9 = 0
    local f10_local10 = 0
    local f10_local11 = f10_arg0:GetDist(TARGET_ENE_0)
    local f10_local12 = 3011
    f10_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, f10_local12, TARGET_ENE_0, 6 - f10_arg0:GetMapHitRadius(TARGET_SELF), f10_local9, f10_local10, 0, 0):TimingSetNumber(5, f10_arg0:GetNumber(5) + 8, AI_TIMING_SET__ACTIVATE)
    f10_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3016, TARGET_ENE_0, 4.2 - f10_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f10_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    if f10_local8 <= 50 then
        f10_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3001, TARGET_ENE_0, 3 - f10_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f10_arg0:GetNumber(5) + 12, AI_TIMING_SET__ACTIVATE)
        f10_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3013, TARGET_ENE_0, 6 - f10_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f10_arg0:GetNumber(5) + 15, AI_TIMING_SET__ACTIVATE)
        f10_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3017, TARGET_ENE_0, 9999, 0):TimingSetNumber(5, f10_arg0:GetNumber(5) + 20, AI_TIMING_SET__ACTIVATE)
    else
        f10_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3024, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f10_arg0:GetNumber(5) + 15, AI_TIMING_SET__ACTIVATE)
    end
    if f10_arg0:GetNumber(10) == 0 then
        f10_arg0:SetNumber(10, 1)
    elseif f10_arg0:GetNumber(10) == 1 then
        f10_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act09 = function (f11_arg0, f11_arg1, f11_arg2)
    local f11_local0 = 9 - f11_arg0:GetMapHitRadius(TARGET_SELF)
    local f11_local1 = 9 - f11_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f11_local2 = 9 - f11_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f11_local3 = 100
    local f11_local4 = 0
    local f11_local5 = 1.5
    local f11_local6 = 3
    local f11_local7 = f11_arg0:GetRandam_Int(1, 100)
    Approach_Act_Flex(f11_arg0, f11_arg1, f11_local0, f11_local1, f11_local2, f11_local3, f11_local4, f11_local5, f11_local6)
    local f11_local8 = 0
    local f11_local9 = 0
    f11_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3015, TARGET_ENE_0, 9999, f11_local8, f11_local9, 0, 0):TimingSetNumber(5, f11_arg0:GetNumber(5) + 8, AI_TIMING_SET__ACTIVATE)
    if f11_local7 <= 100 then
        f11_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3000, TARGET_ENE_0, 3 - f11_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f11_arg0:GetNumber(5) + 12, AI_TIMING_SET__ACTIVATE)
        f11_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3068, TARGET_ENE_0, 6 - f11_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f11_arg0:GetNumber(5) + 15, AI_TIMING_SET__ACTIVATE)
        f11_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3017, TARGET_ENE_0, 9999, 0):TimingSetNumber(5, f11_arg0:GetNumber(5) + 20, AI_TIMING_SET__ACTIVATE)
        f11_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3016, TARGET_ENE_0, 9999, 0, 0, 0, 360):TimingSetNumber(5, f11_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    else
        f11_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3024, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f11_arg0:GetNumber(5) + 15, AI_TIMING_SET__ACTIVATE)
    end
    if f11_arg0:GetNumber(10) == 0 then
        f11_arg0:SetNumber(10, 1)
    elseif f11_arg0:GetNumber(10) == 1 then
        f11_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act10 = function (f12_arg0, f12_arg1, f12_arg2)
    local f12_local0 = 4.8 - f12_arg0:GetMapHitRadius(TARGET_SELF)
    local f12_local1 = 4.8 - f12_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f12_local2 = 4.8 - f12_arg0:GetMapHitRadius(TARGET_SELF) + 3
    local f12_local3 = 100
    local f12_local4 = 0
    local f12_local5 = 1.5
    local f12_local6 = 3
    Approach_Act_Flex(f12_arg0, f12_arg1, f12_local0, f12_local1, f12_local2, f12_local3, f12_local4, f12_local5, f12_local6)
    local f12_local7 = 0
    local f12_local8 = 0
    f12_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3010, TARGET_ENE_0, 11 - f12_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f12_arg0:GetNumber(5) + 8, AI_TIMING_SET__ACTIVATE)
    f12_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3018, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f12_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    if f12_arg0:GetNumber(10) == 0 then
        f12_arg0:SetNumber(10, 1)
    elseif f12_arg0:GetNumber(10) == 1 then
        f12_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act11 = function (f13_arg0, f13_arg1, f13_arg2)
    local f13_local0 = f13_arg0:GetDist(TARGET_ENE_0)
    local f13_local1 = 0
    local f13_local2 = 0
    local f13_local3 = f13_arg0:GetNumber(10)
    local f13_local4 = f13_arg0:GetRandam_Int(1, 100)
    f13_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3021, TARGET_ENE_0, 9999, f13_local2, f13_local1, 0, 0)
    f13_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3025, TARGET_ENE_0, 10.7 - f13_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f13_arg0:GetNumber(5) + 2, AI_TIMING_SET__ACTIVATE)
    if f13_local4 <= 60 then
        f13_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3003, TARGET_ENE_0, 6.2 - f13_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f13_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    else
        f13_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3018, TARGET_ENE_0, 6.2 - f13_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f13_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    end
    if f13_arg0:GetNumber(10) == 0 then
        f13_arg0:SetNumber(10, 1)
    elseif f13_arg0:GetNumber(10) == 1 then
        f13_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act12 = function (f14_arg0, f14_arg1, f14_arg2)
    local f14_local0 = 11 - f14_arg0:GetMapHitRadius(TARGET_SELF)
    local f14_local1 = 11 - f14_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f14_local2 = 11 - f14_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f14_local3 = 100
    local f14_local4 = 0
    local f14_local5 = 1.5
    local f14_local6 = 3
    Approach_Act_Flex(f14_arg0, f14_arg1, f14_local0, f14_local1, f14_local2, f14_local3, f14_local4, f14_local5, f14_local6)
    local f14_local7 = 0
    local f14_local8 = 0
    f14_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3018, TARGET_ENE_0, 9999, f14_local7, f14_local8, 0, 0):TimingSetNumber(5, f14_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    if f14_arg0:GetNumber(10) == 0 then
        f14_arg0:SetNumber(10, 1)
    elseif f14_arg0:GetNumber(10) == 1 then
        f14_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act13 = function (f15_arg0, f15_arg1, f15_arg2)
    local f15_local0 = 5 - f15_arg0:GetMapHitRadius(TARGET_SELF)
    local f15_local1 = 5 - f15_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f15_local2 = 5 - f15_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f15_local3 = 100
    local f15_local4 = 0
    local f15_local5 = 1.5
    local f15_local6 = 3
    Approach_Act_Flex(f15_arg0, f15_arg1, f15_local0, f15_local1, f15_local2, f15_local3, f15_local4, f15_local5, f15_local6)
    local f15_local7 = 0
    local f15_local8 = 0
    f15_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3026, TARGET_ENE_0, 9999, f15_local7, f15_local8, 0, 0):TimingSetNumber(5, f15_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    if f15_arg0:GetNumber(10) == 0 then
        f15_arg0:SetNumber(10, 1)
    elseif f15_arg0:GetNumber(10) == 1 then
        f15_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act14 = function (f16_arg0, f16_arg1, f16_arg2)
    local f16_local0 = 4.8 - f16_arg0:GetMapHitRadius(TARGET_SELF)
    local f16_local1 = 4.8 - f16_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f16_local2 = 4.8 - f16_arg0:GetMapHitRadius(TARGET_SELF) + 3
    local f16_local3 = 100
    local f16_local4 = 0
    local f16_local5 = 1.5
    local f16_local6 = 3
    Approach_Act_Flex(f16_arg0, f16_arg1, f16_local0, f16_local1, f16_local2, f16_local3, f16_local4, f16_local5, f16_local6)
    local f16_local7 = 0
    local f16_local8 = 0
    f16_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3010, TARGET_ENE_0, 999, 0):TimingSetNumber(5, f16_arg0:GetNumber(5) + 8, AI_TIMING_SET__ACTIVATE)
    f16_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3048, TARGET_ENE_0, 9999, f16_local7, f16_local8, 0, 0):TimingSetNumber(5, f16_arg0:GetNumber(5) + 5, AI_TIMING_SET__ACTIVATE)
    if f16_arg0:GetNumber(10) == 0 then
        f16_arg0:SetNumber(10, 1)
    elseif f16_arg0:GetNumber(10) == 1 then
        f16_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act15 = function (f17_arg0, f17_arg1, f17_arg2)
    local f17_local0 = 11 - f17_arg0:GetMapHitRadius(TARGET_SELF)
    local f17_local1 = 11 - f17_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f17_local2 = 11 - f17_arg0:GetMapHitRadius(TARGET_SELF) + 3
    local f17_local3 = 100
    local f17_local4 = 0
    local f17_local5 = 1.5
    local f17_local6 = 3
    Approach_Act_Flex(f17_arg0, f17_arg1, f17_local0, f17_local1, f17_local2, f17_local3, f17_local4, f17_local5, f17_local6)
    local f17_local7 = 0
    local f17_local8 = 0
    f17_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3011, TARGET_ENE_0, 6 - f17_arg0:GetMapHitRadius(TARGET_SELF), f17_local7, f17_local8, 0, 0):TimingSetNumber(5, f17_arg0:GetNumber(5) + 8, AI_TIMING_SET__ACTIVATE)
    f17_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3016, TARGET_ENE_0, 5.7 - f17_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f17_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    f17_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3004, TARGET_ENE_0, 6.5 - f17_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f17_arg0:GetNumber(5) + 12, AI_TIMING_SET__ACTIVATE)
    f17_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3027, TARGET_ENE_0, 9999, f17_local7, f17_local8):TimingSetNumber(5, f17_arg0:GetNumber(5) + 15, AI_TIMING_SET__ACTIVATE)
    if f17_arg0:GetNumber(10) == 0 then
        f17_arg0:SetNumber(10, 1)
    elseif f17_arg0:GetNumber(10) == 1 then
        f17_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act16 = function (f18_arg0, f18_arg1, f18_arg2)
    local f18_local0 = 3.3 - f18_arg0:GetMapHitRadius(TARGET_SELF)
    local f18_local1 = 3.3 - f18_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f18_local2 = 3.3 - f18_arg0:GetMapHitRadius(TARGET_SELF) + 3
    local f18_local3 = 100
    local f18_local4 = 0
    local f18_local5 = 1.5
    local f18_local6 = 3
    Approach_Act_Flex(f18_arg0, f18_arg1, f18_local0, f18_local1, f18_local2, f18_local3, f18_local4, f18_local5, f18_local6)
    local f18_local7 = 0
    local f18_local8 = 0
    f18_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3008, TARGET_ENE_0, 9999, f18_local7, f18_local8, 0, 0):TimingSetNumber(5, f18_arg0:GetNumber(5) + 7, AI_TIMING_SET__ACTIVATE)
    f18_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 1, 3023, TARGET_ENE_0, 9999, 0)
    f18_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3024, TARGET_ENE_0, 4.8 - f18_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f18_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    if f18_arg0:GetNumber(5) <= 30 - 10 then
        f18_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3000, TARGET_ENE_0, 4.2 - f18_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f18_arg0:GetNumber(5) + 11, AI_TIMING_SET__ACTIVATE)
        f18_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3001, TARGET_ENE_0, 5.8 - f18_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f18_arg0:GetNumber(5) + 15, AI_TIMING_SET__ACTIVATE)
        f18_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3002, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f18_arg0:GetNumber(5) + 21, AI_TIMING_SET__ACTIVATE)
    else
        f18_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3027, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f18_arg0:GetNumber(5) + 25, AI_TIMING_SET__ACTIVATE)
    end
    if f18_arg0:GetNumber(10) == 0 then
        f18_arg0:SetNumber(10, 1)
    elseif f18_arg0:GetNumber(10) == 1 then
        f18_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act17 = function (f19_arg0, f19_arg1, f19_arg2)
    local f19_local0 = 3.5 - f19_arg0:GetMapHitRadius(TARGET_SELF) - 0
    local f19_local1 = 15 - f19_arg0:GetMapHitRadius(TARGET_SELF) + 3
    local f19_local2 = 15 - f19_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f19_local3 = 15 - f19_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f19_local4 = 100
    local f19_local5 = 0
    local f19_local6 = 1.5
    local f19_local7 = 3
    local f19_local8 = f19_arg0:GetDist(TARGET_ENE_0)
    local f19_local9 = 0
    local f19_local10 = 0
    if f19_local8 <= 10 then
        Approach_Act_Flex(f19_arg0, f19_arg1, f19_local0, 0, 0, 100, f19_local5, f19_local6, f19_local7)
        f19_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3010, TARGET_ENE_0, 15 - f19_arg0:GetMapHitRadius(TARGET_SELF), f19_local9, f19_local10, 0, 0):TimingSetNumber(5, f19_arg0:GetNumber(5) + 1, AI_TIMING_SET__ACTIVATE)
        f19_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3033, TARGET_ENE_0, 9999, 0):TimingSetNumber(5, f19_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    else
        Approach_Act_Flex(f19_arg0, f19_arg1, f19_local1, f19_local2, f19_local3, f19_local4, f19_local5, f19_local6, f19_local7)
        f19_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3020, TARGET_ENE_0, 9999, f19_local9, f19_local10, 0, 0):TimingSetNumber(5, f19_arg0:GetNumber(5) + 1, AI_TIMING_SET__ACTIVATE)
        f19_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3021, TARGET_ENE_0, 9999, f19_local9, f19_local10, 0, 0):TimingSetNumber(5, f19_arg0:GetNumber(5) + 1, AI_TIMING_SET__ACTIVATE)
        f19_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3033, TARGET_ENE_0, 9999, 0):TimingSetNumber(5, f19_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    end
    if f19_arg0:GetNumber(10) == 0 then
        f19_arg0:SetNumber(10, 1)
    elseif f19_arg0:GetNumber(10) == 1 then
        f19_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act18 = function (f20_arg0, f20_arg1, f20_arg2)
    local f20_local0 = f20_arg0:GetDist(TARGET_ENE_0)
    local f20_local1 = 0
    local f20_local2 = 0
    if f20_local0 <= 5 then
        f20_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 5201, TARGET_ENE_0, 6 - f20_arg0:GetMapHitRadius(TARGET_SELF), f20_local1, f20_local2, 0, 0)
    end
    f20_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3045, TARGET_ENE_0, 9999, f20_local1, f20_local2):TimingSetTimer(2, 25, AI_TIMING_SET__ACTIVATE)
    if f20_arg0:GetNumber(10) == 0 then
        f20_arg0:SetNumber(10, 1)
    elseif f20_arg0:GetNumber(10) == 1 then
        f20_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act19 = function (f21_arg0, f21_arg1, f21_arg2)
    local f21_local0 = 0
    local f21_local1 = 0
    f21_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3049, TARGET_ENE_0, 9999, f21_local1, f21_local0, 0, 0)
    f21_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3033, TARGET_ENE_0, 9999, 0):TimingSetNumber(5, f21_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    if f21_arg0:GetNumber(10) == 0 then
        f21_arg0:SetNumber(10, 1)
    elseif f21_arg0:GetNumber(10) == 1 then
        f21_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act20 = function (f22_arg0, f22_arg1, f22_arg2)
    local f22_local0 = 2.6
    local f22_local1 = 9999
    local f22_local2 = -1
    if f22_arg0:GetDist(TARGET_ENE_0) <= 5 then
        f22_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3010, TARGET_ENE_0, 15 - f22_arg0:GetMapHitRadius(TARGET_SELF), 0, 0, 0, 0):TimingSetNumber(5, f22_arg0:GetNumber(5) + 1, AI_TIMING_SET__ACTIVATE)
    end
    f22_arg0:SetNumber(9, 1)
    if SpaceCheck(f22_arg0, f22_arg1, 180, 5) then
        f22_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3043, TARGET_ENE_0, 9999, 0):TimingSetTimer(1, 30, AI_TIMING_SET__ACTIVATE)
    else
        f22_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3042, TARGET_ENE_0, 9999, 0)
    end
    local f22_local3 = 10 - f22_arg0:GetMapHitRadius(TARGET_SELF) + 1
    local f22_local4 = 10 - f22_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f22_local5 = 10 - f22_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f22_local6 = 100
    local f22_local7 = 0
    local f22_local8 = 1.5
    local f22_local9 = 3
    local f22_local10 = 0
    local f22_local11 = 0
    if f22_arg0:GetNumber(8) == 1 then
        f22_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3033, TARGET_ENE_0, 10.7 - f22_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(8, 2, AI_TIMING_SET__ACTIVATE):TimingSetNumber(12, 0, AI_TIMING_SET__ACTIVATE)
    else
        f22_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3033, TARGET_ENE_0, 10.7 - f22_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f22_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE):TimingSetNumber(12, 0, AI_TIMING_SET__ACTIVATE)
    end
    if f22_arg0:GetNumber(10) == 0 then
        f22_arg0:SetNumber(10, 1)
    elseif f22_arg0:GetNumber(10) == 1 then
        f22_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act21 = function (f23_arg0, f23_arg1, f23_arg2)
    local f23_local0 = 3
    local f23_local1 = 45
    f23_arg1:AddSubGoal(GOAL_COMMON_Turn, f23_local0, TARGET_ENE_0, f23_local1, -1, GOAL_RESULT_Success, true)
    if f23_arg0:GetNumber(10) == 0 then
        f23_arg0:SetNumber(10, 1)
    elseif f23_arg0:GetNumber(10) == 1 then
        f23_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act22 = function (f24_arg0, f24_arg1, f24_arg2)
    local f24_local0 = 2.6
    local f24_local1 = 9999
    local f24_local2 = -1
    if f24_arg0:GetDist(TARGET_ENE_0) <= 5 then
        f24_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3010, TARGET_ENE_0, 15 - f24_arg0:GetMapHitRadius(TARGET_SELF), 0, 0, 0, 0):TimingSetNumber(5, f24_arg0:GetNumber(5) + 1, AI_TIMING_SET__ACTIVATE)
    end
    if SpaceCheck(f24_arg0, f24_arg1, 180, 5) then
        f24_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3043, TARGET_ENE_0, 9999, 0):TimingSetTimer(1, 30, AI_TIMING_SET__ACTIVATE)
    else
        f24_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3042, TARGET_ENE_0, 9999, 0):TimingSetTimer(1, 30, AI_TIMING_SET__ACTIVATE)
    end
    local f24_local3 = 10 - f24_arg0:GetMapHitRadius(TARGET_SELF) + 1
    local f24_local4 = 10 - f24_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f24_local5 = 10 - f24_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f24_local6 = 100
    local f24_local7 = 0
    local f24_local8 = 1.5
    local f24_local9 = 3
    local f24_local10 = 0
    local f24_local11 = 0
    if f24_arg0:GetNumber(10) == 0 then
        f24_arg0:SetNumber(10, 1)
    elseif f24_arg0:GetNumber(10) == 1 then
        f24_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act23 = function (f25_arg0, f25_arg1, f25_arg2)
    local f25_local0 = 0
    if SpaceCheck(f25_arg0, f25_arg1, -90, 1) == true then
        if SpaceCheck(f25_arg0, f25_arg1, 90, 1) == true then
            if f25_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                f25_local0 = 0
            else
                f25_local0 = 1
            end
        else
            f25_local0 = 0
        end
    elseif SpaceCheck(f25_arg0, f25_arg1, 90, 1) == true then
        f25_local0 = 1
    else
    end
    local f25_local1 = f25_arg0:GetRandam_Float(2.5, 3.5)
    local f25_local2 = f25_arg0:GetRandam_Int(30, 45)
    local f25_local3 = f25_arg0:GetSpRate(TARGET_SELF)
    f25_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f25_local1, TARGET_ENE_0, f25_local0, f25_local2, true, true, -1):TimingSetNumber(5, 0, AI_TIMING_SET__ACTIVATE)
    if f25_arg0:GetNumber(10) == 0 then
        f25_arg0:SetNumber(10, 1)
    elseif f25_arg0:GetNumber(10) == 1 then
        f25_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act24 = function (f26_arg0, f26_arg1, f26_arg2)
    local f26_local0 = 3
    local f26_local1 = 0
    local f26_local2 = f26_arg0:GetRandam_Float(2.5, 3.5)
    local f26_local3 = f26_arg0:GetRandam_Int(30, 45)
    if SpaceCheck(f26_arg0, f26_arg1, 180, 5) then
        f26_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f26_local0, 5201, TARGET_ENE_0, f26_local1, AI_DIR_TYPE_B, 0)
        f26_local2 = 2.5
    end
    local f26_local4 = 0
    if SpaceCheck(f26_arg0, f26_arg1, -90, 1) == true then
        if SpaceCheck(f26_arg0, f26_arg1, 90, 1) == true then
            if f26_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                f26_local4 = 0
            else
                f26_local4 = 1
            end
        else
            f26_local4 = 0
        end
    elseif SpaceCheck(f26_arg0, f26_arg1, 90, 1) == true then
        f26_local4 = 1
    else
    end
    local f26_local5 = f26_arg0:GetSpRate(TARGET_SELF)
    f26_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f26_local2, TARGET_ENE_0, f26_local4, f26_local3, true, true, -1):TimingSetNumber(5, 0, AI_TIMING_SET__ACTIVATE)
    if f26_arg0:GetNumber(10) == 0 then
        f26_arg0:SetNumber(10, 1)
    elseif f26_arg0:GetNumber(10) == 1 then
        f26_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act25 = function (f27_arg0, f27_arg1, f27_arg2)
    local f27_local0 = f27_arg0:GetRandam_Float(2, 4)
    local f27_local1 = f27_arg0:GetRandam_Float(1, 3)
    local f27_local2 = -1
    f27_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, f27_local0, TARGET_ENE_0, f27_local1, TARGET_ENE_0, true, f27_local2):SetTargetRange(0, -99, 10)
    if f27_arg0:GetNumber(10) == 0 then
        f27_arg0:SetNumber(10, 1)
    elseif f27_arg0:GetNumber(10) == 1 then
        f27_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act26 = function (f28_arg0, f28_arg1, f28_arg2)
    f28_arg1:AddSubGoal(GOAL_COMMON_Wait, 10, TARGET_SELF, 0, 0, 0)
    if f28_arg0:GetNumber(10) == 0 then
        f28_arg0:SetNumber(10, 1)
    elseif f28_arg0:GetNumber(10) == 1 then
        f28_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act27 = function (f29_arg0, f29_arg1, f29_arg2)
    local f29_local0 = f29_arg0:GetDist(TARGET_ENE_0)
    local f29_local1 = f29_arg0:GetDistYSigned(TARGET_ENE_0)
    local f29_local2 = f29_local1 / math.tan(math.deg(30))
    local f29_local3 = f29_arg0:GetRandam_Int(0, 1)
    f29_arg0:SetNumber(10, f29_local3)
    if f29_local1 >= 3 then
        if f29_local2 + 1 <= f29_local0 then
            if SpaceCheck(f29_arg0, f29_arg1, 0, 4) == true then
                f29_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.1, TARGET_ENE_0, f29_local2, TARGET_SELF, false, -1)
            elseif SpaceCheck(f29_arg0, f29_arg1, 0, 3) == true then
                f29_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.5, TARGET_ENE_0, f29_local2, TARGET_SELF, true, -1)
            end
        elseif f29_local0 <= f29_local2 - 1 then
            f29_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 10, TARGET_ENE_0, f29_local2, TARGET_ENE_0, true, -1):SetTargetRange(0, -99, 12)
        end
    elseif SpaceCheck(f29_arg0, f29_arg1, 0, 4) == true then
        f29_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.1, TARGET_ENE_0, 0, TARGET_SELF, false, -1)
    elseif SpaceCheck(f29_arg0, f29_arg1, 0, 3) == true then
        f29_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.5, TARGET_ENE_0, 0, TARGET_SELF, true, -1)
    elseif SpaceCheck(f29_arg0, f29_arg1, 0, 1) == false then
        f29_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 0.5, TARGET_ENE_0, 999, TARGET_ENE_0, true, -1):SetTargetRange(0, -99, 12)
    end
    f29_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, 3, TARGET_ENE_0, f29_local3, f29_arg0:GetRandam_Int(30, 45), true, true, -1):SetTargetRange(0, -99, 12):TimingSetNumber(5, f29_arg0:GetNumber(5) - 30, AI_TIMING_SET__ACTIVATE)
    if f29_arg0:GetNumber(10) == 0 then
        f29_arg0:SetNumber(10, 1)
    elseif f29_arg0:GetNumber(10) == 1 then
        f29_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act28 = function (f30_arg0, f30_arg1, f30_arg2)
    local f30_local0 = f30_arg0:GetDist(TARGET_ENE_0)
    local f30_local1 = f30_arg0:GetRandam_Float(3, 3.5)
    local f30_local2 = f30_arg0:GetRandam_Int(30, 45)
    local f30_local3 = -1
    local f30_local4 = f30_arg0:GetRandam_Int(0, 1)
    if f30_local0 <= 5 then
        if SpaceCheck(f30_arg0, f30_arg1, 180, 1) == true then
            f30_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 3, TARGET_ENE_0, 6, TARGET_ENE_0, true, f30_local3)
        else
            f30_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f30_local1, TARGET_ENE_0, f30_local4, f30_local2, true, true, f30_local3)
        end
    elseif f30_local0 <= 7 then
        f30_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f30_local1, TARGET_ENE_0, f30_local4, f30_local2, true, true, f30_local3)
    elseif f30_local0 <= 8 then
        f30_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 3, TARGET_ENE_0, 3, TARGET_SELF, true, -1)
    else
        f30_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 3, TARGET_ENE_0, 8, TARGET_SELF, false, -1)
    end
    if f30_arg0:GetNumber(10) == 0 then
        f30_arg0:SetNumber(10, 1)
    elseif f30_arg0:GetNumber(10) == 1 then
        f30_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act29 = function (f31_arg0, f31_arg1, f31_arg2)
    local f31_local0 = 11 - f31_arg0:GetMapHitRadius(TARGET_SELF)
    local f31_local1 = 11 - f31_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f31_local2 = 11 - f31_arg0:GetMapHitRadius(TARGET_SELF) + 3
    local f31_local3 = 100
    local f31_local4 = 0
    local f31_local5 = 1.5
    local f31_local6 = 3
    Approach_Act_Flex(f31_arg0, f31_arg1, f31_local0, f31_local1, f31_local2, f31_local3, f31_local4, f31_local5, f31_local6)
    local f31_local7 = 0
    local f31_local8 = 0
    f31_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3011, TARGET_ENE_0, 6 - f31_arg0:GetMapHitRadius(TARGET_SELF), f31_local7, f31_local8, 0, 0):TimingSetNumber(5, f31_arg0:GetNumber(5) + 8, AI_TIMING_SET__ACTIVATE)
    f31_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3016, TARGET_ENE_0, 5.7 - f31_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f31_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    f31_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3004, TARGET_ENE_0, 6.5 - f31_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f31_arg0:GetNumber(5) + 12, AI_TIMING_SET__ACTIVATE)
    f31_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3048, TARGET_ENE_0, 9999, f31_local7, f31_local8, 0, 0):TimingSetNumber(5, f31_arg0:GetNumber(5) + 5, AI_TIMING_SET__ACTIVATE)
    if f31_arg0:GetNumber(10) == 0 then
        f31_arg0:SetNumber(10, 1)
    elseif f31_arg0:GetNumber(10) == 1 then
        f31_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act30 = function (f32_arg0, f32_arg1, f32_arg2)
    local f32_local0 = f32_arg0:GetDist(TARGET_ENE_0)
    local f32_local1 = 3
    local f32_local2 = -1
    local f32_local3 = 0
    if SpaceCheck(f32_arg0, f32_arg1, -135, 1) == true then
        if SpaceCheck(f32_arg0, f32_arg1, 135, 1) == true then
            if f32_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                f32_local3 = 0
            else
                f32_local3 = 1
            end
        else
            f32_local3 = 0
        end
    elseif SpaceCheck(f32_arg0, f32_arg1, 90, 1) == true then
        f32_local3 = 1
    else
    end
    local f32_local4 = 1.8
    local f32_local5 = f32_arg0:GetRandam_Int(30, 45)
    f32_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f32_local1, 5202 + f32_local3, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0)
    if f32_arg0:GetNumber(10) == 0 then
        f32_arg0:SetNumber(10, 1)
    elseif f32_arg0:GetNumber(10) == 1 then
        f32_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act31 = function (f33_arg0, f33_arg1, f33_arg2)
    local f33_local0 = f33_arg0:GetDist(TARGET_ENE_0)
    local f33_local1 = f33_arg0:GetRandam_Int(1, 100)
    local f33_local2 = -1
    local f33_local3 = 0
    if SpaceCheck(f33_arg0, f33_arg1, -90, 5) == true then
        if SpaceCheck(f33_arg0, f33_arg1, 90, 5) == true then
            if f33_local1 <= 50 then
                f33_local3 = 0
            else
                f33_local3 = 1
            end
        else
            f33_local3 = 0
        end
    elseif SpaceCheck(f33_arg0, f33_arg1, 90, 1) == true then
        f33_local3 = 1
    else
    end
    local f33_local4 = 1.8
    local f33_local5 = f33_arg0:GetRandam_Int(30, 45)
    f33_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f33_local4, TARGET_ENE_0, f33_local3, f33_local5, false, true, f33_local2)
    f33_arg0:SetNumber(10, f33_local3)
    if f33_arg0:GetNumber(10) == 0 then
        f33_arg0:SetNumber(10, 1)
    elseif f33_arg0:GetNumber(10) == 1 then
        f33_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act32 = function (f34_arg0, f34_arg1, f34_arg2)
    local f34_local0 = f34_arg0:GetDist(TARGET_ENE_0)
    local f34_local1 = 0
    local f34_local2 = 0
    if f34_local0 <= 5 then
        f34_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3022, TARGET_ENE_0, 9999, f34_local2, f34_local1, 0, 0)
        f34_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3023, TARGET_ENE_0, 10 - f34_arg0:GetMapHitRadius(TARGET_SELF), f34_local2, f34_local1, 0, 0)
    else
        f34_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3021, TARGET_ENE_0, 9999, f34_local2, f34_local1, 0, 0)
        f34_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3020, TARGET_ENE_0, 9999, f34_local2, f34_local1, 0, 0)
    end
    f34_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3048, TARGET_ENE_0, 9999, f34_local2, f34_local1, 0, 0):TimingSetNumber(5, f34_arg0:GetNumber(5) + 5, AI_TIMING_SET__ACTIVATE)
    if f34_arg0:GetNumber(10) == 0 then
        f34_arg0:SetNumber(10, 1)
    elseif f34_arg0:GetNumber(10) == 1 then
        f34_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act33 = function (f35_arg0, f35_arg1, f35_arg2)
    local f35_local0 = 4.8 - f35_arg0:GetMapHitRadius(TARGET_SELF)
    local f35_local1 = 4.8 - f35_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f35_local2 = 4.8 - f35_arg0:GetMapHitRadius(TARGET_SELF) + 3
    local f35_local3 = 100
    local f35_local4 = 0
    local f35_local5 = 1.5
    local f35_local6 = 3
    Approach_Act_Flex(f35_arg0, f35_arg1, f35_local0, f35_local1, f35_local2, f35_local3, f35_local4, f35_local5, f35_local6)
    local f35_local7 = 0
    local f35_local8 = 0
    local f35_local9 = f35_arg0:GetRandam_Int(1, 100)
    f35_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3000, TARGET_ENE_0, 4.2 - f35_arg0:GetMapHitRadius(TARGET_SELF), f35_local7, f35_local8, 0, 0):TimingSetNumber(5, f35_arg0:GetNumber(5) + 6, AI_TIMING_SET__ACTIVATE)
    if f35_local9 <= 30 then
        f35_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3001, TARGET_ENE_0, 3 - f35_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f35_arg0:GetNumber(5) + 8, AI_TIMING_SET__ACTIVATE)
        f35_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3013, TARGET_ENE_0, 6 - f35_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f35_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
        f35_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3017, TARGET_ENE_0, 9999, 0):TimingSetNumber(5, f35_arg0:GetNumber(5) + 15, AI_TIMING_SET__ACTIVATE)
        f35_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3048, TARGET_ENE_0, 9999, f35_local7, f35_local8, 0, 0):TimingSetNumber(5, f35_arg0:GetNumber(5) + 5, AI_TIMING_SET__ACTIVATE)
    else
        f35_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3001, TARGET_ENE_0, 5.8 - f35_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f35_arg0:GetNumber(5) + 8, AI_TIMING_SET__ACTIVATE)
        if f35_local9 <= 80 then
            f35_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3023, TARGET_ENE_0, 5.8 - f35_arg0:GetMapHitRadius(TARGET_SELF), 0)
            f35_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3048, TARGET_ENE_0, 9999, f35_local7, f35_local8, 0, 0):TimingSetNumber(5, f35_arg0:GetNumber(5) + 5, AI_TIMING_SET__ACTIVATE)
        else
            f35_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3024, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f35_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
            f35_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3048, TARGET_ENE_0, 9999, f35_local7, f35_local8, 0, 0):TimingSetNumber(5, f35_arg0:GetNumber(5) + 5, AI_TIMING_SET__ACTIVATE)
        end
    end
    if f35_arg0:GetNumber(10) == 0 then
        f35_arg0:SetNumber(10, 1)
    elseif f35_arg0:GetNumber(10) == 1 then
        f35_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act34 = function (f36_arg0, f36_arg1, f36_arg2)
    local f36_local0 = 4 - f36_arg0:GetMapHitRadius(TARGET_SELF)
    local f36_local1 = 4 - f36_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f36_local2 = 4 - f36_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f36_local3 = 100
    local f36_local4 = 0
    local f36_local5 = 0.5
    local f36_local6 = 1.5
    Approach_Act_Flex(f36_arg0, f36_arg1, f36_local0, f36_local1, f36_local2, f36_local3, f36_local4, f36_local5, f36_local6)
    local f36_local7 = 0
    local f36_local8 = 0
    f36_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3093, TARGET_ENE_0, 9999, f36_local7, f36_local8, 0, 0):TimingSetNumber(9, 0, AI_TIMING_SET__ACTIVATE)
    f36_arg0:SetNumber(10, 0)
    return 0
    
end

Goal.Act35 = function (f37_arg0, f37_arg1, f37_arg2)
    local f37_local0 = 0
    local f37_local1 = 0
    f37_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3092, TARGET_ENE_0, 9999, f37_local1, f37_local0, 0, 0):TimingSetNumber(5, f37_arg0:GetNumber(5) + 5, AI_TIMING_SET__ACTIVATE)
    if f37_arg0:GetNumber(10) == 0 then
        f37_arg0:SetNumber(10, 1)
    elseif f37_arg0:GetNumber(10) == 1 then
        f37_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act36 = function (f38_arg0, f38_arg1, f38_arg2)
    local f38_local0 = 0
    local f38_local1 = 0
    f38_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3035, TARGET_ENE_0, 9999, f38_local1, f38_local0, 0, 0)
    f38_arg0:SetNumber(1, 0)
    if f38_arg0:GetNumber(10) == 0 then
        f38_arg0:SetNumber(10, 1)
    elseif f38_arg0:GetNumber(10) == 1 then
        f38_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act37 = function (f39_arg0, f39_arg1, f39_arg2)
    local f39_local0 = 0
    local f39_local1 = 0
    if f39_arg0:GetNumber(8) == 0 then
        f39_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3036, TARGET_ENE_0, 9999, f39_local1, f39_local0, 0, 0):TimingSetNumber(8, 1, AI_TIMING_SET__ACTIVATE)
        f39_arg0:SetNumber(1, 0)
    else
        f39_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3036, TARGET_ENE_0, 9999, f39_local1, f39_local0, 0, 0)
        f39_arg0:SetNumber(1, 0)
    end
    if f39_arg0:GetNumber(10) == 0 then
        f39_arg0:SetNumber(10, 1)
    elseif f39_arg0:GetNumber(10) == 1 then
        f39_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act38 = function (f40_arg0, f40_arg1, f40_arg2)
    local f40_local0 = 0
    local f40_local1 = 0
    if f40_arg0:GetNumber(8) == 0 then
        f40_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3037, TARGET_ENE_0, 9999, f40_local1, f40_local0, 0, 0):TimingSetNumber(8, 1, AI_TIMING_SET__ACTIVATE)
        f40_arg0:SetNumber(1, 0)
    else
        f40_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3037, TARGET_ENE_0, 9999, f40_local1, f40_local0, 0, 0)
        f40_arg0:SetNumber(1, 0)
    end
    if f40_arg0:GetNumber(10) == 0 then
        f40_arg0:SetNumber(10, 1)
    elseif f40_arg0:GetNumber(10) == 1 then
        f40_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act39 = function (f41_arg0, f41_arg1, f41_arg2)
    local f41_local0 = 0
    local f41_local1 = 0
    if f41_arg0:GetNumber(8) == 0 then
        f41_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3038, TARGET_ENE_0, 9999, f41_local1, f41_local0, 0, 0):TimingSetNumber(8, 1, AI_TIMING_SET__ACTIVATE)
        f41_arg0:SetNumber(1, 0)
    else
        f41_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3038, TARGET_ENE_0, 9999, f41_local1, f41_local0, 0, 0)
        f41_arg0:SetNumber(1, 0)
    end
    if f41_arg0:GetNumber(10) == 0 then
        f41_arg0:SetNumber(10, 1)
    elseif f41_arg0:GetNumber(10) == 1 then
        f41_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act40 = function (f42_arg0, f42_arg1, f42_arg2)
    local f42_local0 = 4 - f42_arg0:GetMapHitRadius(TARGET_SELF)
    local f42_local1 = 4 - f42_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f42_local2 = 4 - f42_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f42_local3 = 100
    local f42_local4 = 0
    local f42_local5 = 6
    local f42_local6 = 10
    local f42_local7 = f42_arg0:GetDist(TARGET_ENE_0)
    f42_arg1:AddSubGoal(GOAL_COMMON_Wait, 0.1, TARGET_SELF, 0, 0, 0)
    Approach_Act_Flex(f42_arg0, f42_arg1, f42_local0, f42_local1, f42_local2, f42_local3, f42_local4, f42_local5, f42_local6)
    local f42_local8 = 0
    local f42_local9 = 0
    f42_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3040, TARGET_ENE_0, 9999, f42_local8, f42_local9, 0, 0)
    return 0
    
end

Goal.Act41 = function (f43_arg0, f43_arg1, f43_arg2)
    local f43_local0 = 3
    local f43_local1 = 0
    local f43_local2 = 4.5
    local f43_local3 = f43_arg0:GetRandam_Int(30, 45)
    if SpaceCheck(f43_arg0, f43_arg1, 180, 5) then
        f43_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f43_local0, 5201, TARGET_ENE_0, f43_local1, AI_DIR_TYPE_B, 0)
        f43_local2 = 3.5
    end
    local f43_local4 = 0
    if SpaceCheck(f43_arg0, f43_arg1, -90, 1) == true then
        if SpaceCheck(f43_arg0, f43_arg1, 90, 1) == true then
            if f43_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                f43_local4 = 0
            else
                f43_local4 = 1
            end
        else
            f43_local4 = 0
        end
    elseif SpaceCheck(f43_arg0, f43_arg1, 90, 1) == true then
        f43_local4 = 1
    else
    end
    f43_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f43_local2, TARGET_ENE_0, f43_local4, f43_local3, true, true, -1):TimingSetNumber(5, f43_arg0:GetNumber(5) - 30, AI_TIMING_SET__ACTIVATE)
    if f43_arg0:GetNumber(10) == 0 then
        f43_arg0:SetNumber(10, 1)
    elseif f43_arg0:GetNumber(10) == 1 then
        f43_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act42 = function (f44_arg0, f44_arg1, f44_arg2)
    f44_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 10, 5201, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0):TimingSetTimer(1, 15, AI_TIMING_SET__ACTIVATE)
    return 0
    
end

Goal.Act43 = function (f45_arg0, f45_arg1, f45_arg2)
    local f45_local0 = 4 - f45_arg0:GetMapHitRadius(TARGET_SELF)
    local f45_local1 = 4 - f45_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f45_local2 = 4 - f45_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f45_local3 = 100
    local f45_local4 = 0
    local f45_local5 = 0.5
    local f45_local6 = 1.5
    Approach_Act_Flex(f45_arg0, f45_arg1, f45_local0, f45_local1, f45_local2, f45_local3, f45_local4, f45_local5, f45_local6)
    local f45_local7 = 0
    local f45_local8 = 0
    f45_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3048, TARGET_ENE_0, 9999, f45_local7, f45_local8, 0, 0):TimingSetNumber(5, f45_arg0:GetNumber(5) + 5, AI_TIMING_SET__ACTIVATE)
    if f45_arg0:GetNumber(10) == 0 then
        f45_arg0:SetNumber(10, 1)
    elseif f45_arg0:GetNumber(10) == 1 then
        f45_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act44 = function (f46_arg0, f46_arg1, f46_arg2)
    local f46_local0 = 0
    local f46_local1 = 0
    f46_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3049, TARGET_ENE_0, 9999, f46_local1, f46_local0, 0, 0)
    return 0
    
end

Goal.Act45 = function (f47_arg0, f47_arg1, f47_arg2)
    local f47_local0 = 4 - f47_arg0:GetMapHitRadius(TARGET_SELF)
    local f47_local1 = 4 - f47_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f47_local2 = 4 - f47_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f47_local3 = 100
    local f47_local4 = 0
    local f47_local5 = 0.5
    local f47_local6 = 1.5
    local f47_local7 = f47_arg0:GetRandam_Int(1, 100)
    Approach_Act_Flex(f47_arg0, f47_arg1, f47_local0, f47_local1, f47_local2, f47_local3, f47_local4, f47_local5, f47_local6)
    local f47_local8 = 0
    local f47_local9 = 0
    if f47_local7 <= 50 then
        f47_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3039, TARGET_ENE_0, 9999, f47_local8, f47_local9, 0, 0):TimingSetNumber(5, f47_arg0:GetNumber(5) + 5, AI_TIMING_SET__ACTIVATE)
    else
        f47_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3092, TARGET_ENE_0, 9999, f47_local8, f47_local9, 0, 0):TimingSetNumber(5, f47_arg0:GetNumber(5) + 5, AI_TIMING_SET__ACTIVATE)
    end
    if f47_arg0:GetNumber(10) == 0 then
        f47_arg0:SetNumber(10, 1)
    elseif f47_arg0:GetNumber(10) == 1 then
        f47_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act46 = function (f48_arg0, f48_arg1, f48_arg2)
    local f48_local0 = 4 - f48_arg0:GetMapHitRadius(TARGET_SELF)
    local f48_local1 = 4 - f48_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f48_local2 = 4 - f48_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f48_local3 = 100
    local f48_local4 = 0
    local f48_local5 = 0.5
    local f48_local6 = 1.5
    Approach_Act_Flex(f48_arg0, f48_arg1, f48_local0, f48_local1, f48_local2, f48_local3, f48_local4, f48_local5, f48_local6)
    local f48_local7 = 0
    local f48_local8 = 0
    f48_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3044, TARGET_ENE_0, 9999, f48_local7, f48_local8, 0, 0):TimingSetNumber(9, 0, AI_TIMING_SET__ACTIVATE)
    f48_arg0:SetNumber(10, 0)
    return 0
    
end

Goal.Act47 = function (f49_arg0, f49_arg1, f49_arg2)
    local f49_local0 = f49_arg0:GetDist(TARGET_ENE_0)
    local f49_local1 = 11 - f49_arg0:GetMapHitRadius(TARGET_SELF)
    local f49_local2 = 11 - f49_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f49_local3 = 11 - f49_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f49_local4 = 100
    local f49_local5 = 0
    local f49_local6 = 1.5
    local f49_local7 = 3
    local f49_local8 = f49_arg0:GetRandam_Int(1, 100)
    Approach_Act_Flex(f49_arg0, f49_arg1, f49_local1, f49_local2, f49_local3, f49_local4, f49_local5, f49_local6, f49_local7)
    local f49_local9 = 0
    local f49_local10 = 0
    local f49_local11 = f49_arg0:GetDist(TARGET_ENE_0)
    local f49_local12 = 3011
    f49_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, f49_local12, TARGET_ENE_0, 6 - f49_arg0:GetMapHitRadius(TARGET_SELF), f49_local9, f49_local10, 0, 0):TimingSetNumber(5, f49_arg0:GetNumber(5) + 8, AI_TIMING_SET__ACTIVATE)
    f49_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3016, TARGET_ENE_0, 4.2 - f49_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f49_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    if f49_local8 <= 50 then
        f49_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3001, TARGET_ENE_0, 3 - f49_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f49_arg0:GetNumber(5) + 12, AI_TIMING_SET__ACTIVATE)
        f49_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3013, TARGET_ENE_0, 6 - f49_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f49_arg0:GetNumber(5) + 15, AI_TIMING_SET__ACTIVATE)
        f49_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3017, TARGET_ENE_0, 9999, 0):TimingSetNumber(5, f49_arg0:GetNumber(5) + 20, AI_TIMING_SET__ACTIVATE)
        f49_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3048, TARGET_ENE_0, 9999, f49_local9, f49_local10, 0, 0):TimingSetNumber(5, f49_arg0:GetNumber(5) + 5, AI_TIMING_SET__ACTIVATE)
    else
        f49_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3024, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f49_arg0:GetNumber(5) + 15, AI_TIMING_SET__ACTIVATE)
        f49_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3048, TARGET_ENE_0, 9999, f49_local9, f49_local10, 0, 0):TimingSetNumber(5, f49_arg0:GetNumber(5) + 5, AI_TIMING_SET__ACTIVATE)
    end
    if f49_arg0:GetNumber(10) == 0 then
        f49_arg0:SetNumber(10, 1)
    elseif f49_arg0:GetNumber(10) == 1 then
        f49_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act48 = function (f50_arg0, f50_arg1, f50_arg2)
    local f50_local0 = 2.6
    local f50_local1 = 9999
    local f50_local2 = -1
    if f50_arg0:GetDist(TARGET_ENE_0) <= 5 then
        f50_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3010, TARGET_ENE_0, 15 - f50_arg0:GetMapHitRadius(TARGET_SELF), 0, 0, 0, 0):TimingSetNumber(5, f50_arg0:GetNumber(5) + 1, AI_TIMING_SET__ACTIVATE)
    end
    if SpaceCheck(f50_arg0, f50_arg1, 180, 5) then
        f50_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3043, TARGET_ENE_0, 9999, 0):TimingSetTimer(1, 30, AI_TIMING_SET__ACTIVATE)
    else
        f50_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3042, TARGET_ENE_0, 9999, 0):TimingSetTimer(1, 30, AI_TIMING_SET__ACTIVATE)
    end
    local f50_local3 = 10 - f50_arg0:GetMapHitRadius(TARGET_SELF) + 1
    local f50_local4 = 10 - f50_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f50_local5 = 10 - f50_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f50_local6 = 100
    local f50_local7 = 0
    local f50_local8 = 1.5
    local f50_local9 = 3
    local f50_local10 = 0
    local f50_local11 = 0
    f50_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3033, TARGET_ENE_0, 10.7 - f50_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f50_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    f50_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3048, TARGET_ENE_0, 9999, f50_local10, f50_local11, 0, 0):TimingSetNumber(5, f50_arg0:GetNumber(5) + 5, AI_TIMING_SET__ACTIVATE)
    if f50_arg0:GetNumber(10) == 0 then
        f50_arg0:SetNumber(10, 1)
    elseif f50_arg0:GetNumber(10) == 1 then
        f50_arg0:SetNumber(10, 2)
    end
    return 0
    
end

Goal.Act49 = function (f51_arg0, f51_arg1, f51_arg2)
    local f51_local0 = 0
    local f51_local1 = 0
    if f51_arg0:GetNumber(2) == 0 then
        f51_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3035, TARGET_ENE_0, 9999, f51_local1, f51_local0, 0, 0)
        f51_arg0:SetNumber(2, 1)
    elseif f51_arg0:GetNumber(2) == 1 then
        f51_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3036, TARGET_ENE_0, 9999, f51_local1, f51_local0, 0, 0)
        f51_arg0:SetNumber(2, 2)
    else
        f51_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3038, TARGET_ENE_0, 9999, f51_local1, f51_local0, 0, 0)
        f51_arg0:SetNumber(2, 0)
    end
    return 0
    
end

Goal.Act50 = function (f52_arg0, f52_arg1, f52_arg2)
    local f52_local0 = 2.2
    local f52_local1 = 2.2
    local f52_local2 = 2.2
    local f52_local3 = 100
    local f52_local4 = 0
    local f52_local5 = 1.5
    local f52_local6 = 3
    Approach_Act_Flex(f52_arg0, f52_arg1, f52_local0, f52_local1, f52_local2, f52_local3, f52_local4, f52_local5, f52_local6)
    local f52_local7 = 0
    local f52_local8 = 0
    f52_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3041, TARGET_ENE_0, 9999, f52_local7, f52_local8, 0, 0)
    return 0
    
end

Goal.Interrupt = function (f53_arg0, f53_arg1, f53_arg2)
    local f53_local0 = f53_arg1:GetDist(TARGET_ENE_0)
    local f53_local1 = f53_arg1:GetRandam_Int(1, 100)
    local f53_local2 = f53_arg1:GetSpecialEffectActivateInterruptType(0)
    local f53_local3 = f53_arg1:HasSpecialEffectId(TARGET_SELF, 3506030)
    if f53_arg1:IsLadderAct(TARGET_SELF) then
        return false
    end
    if not f53_arg1:HasSpecialEffectId(TARGET_SELF, 200004) then
        return false
    end
    if f53_arg1:IsInterupt(INTERUPT_ParryTiming) and f53_local3 == false and f53_arg0.Parry(f53_arg1, f53_arg2, 100, 0) then
        return true
    end
    if f53_arg1:IsInterupt(INTERUPT_ShootImpact) and f53_local3 == false and f53_arg0.ShootReaction(f53_arg1, f53_arg2) then
        return true
    end
    if Interupt_PC_Break(f53_arg1) then
        f53_arg1:Replanning()
        return true
    end
    if f53_arg1:IsInterupt(INTERUPT_ActivateSpecialEffect) then
        if f53_local2 == 3506080 then
            f53_arg1:Replanning()
            return true
        elseif f53_local2 == 3506000 then
            if f53_arg1:HasSpecialEffectId(TARGET_SELF, 200051) then
                f53_arg2:ClearSubGoal()
                f53_arg2:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3007, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f53_arg1:GetNumber(5) + 25, AI_TIMING_SET__ACTIVATE)
            else
                f53_arg2:ClearSubGoal()
                f53_arg2:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3006, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f53_arg1:GetNumber(5) + 25, AI_TIMING_SET__ACTIVATE)
            end
        elseif f53_local2 == 3506004 then
            f53_arg2:ClearSubGoal()
            f53_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 1, 3034, TARGET_ENE_0, 9999, 0):TimingSetNumber(5, f53_arg1:GetNumber(5) + 25, AI_TIMING_SET__ACTIVATE)
        elseif f53_local2 == 3506030 then
            f53_arg1:Replanning()
            return true
        elseif f53_local2 == 5030 then
            if f53_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_B, 280) then
                f53_arg2:ClearSubGoal()
                f53_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3028, TARGET_ENE_0, 9999, 0)
                return true
            elseif f53_local0 >= 5 then
                f53_arg2:ClearSubGoal()
                f53_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3029, TARGET_ENE_0, 9999, 0)
                return true
            end
        elseif f53_local2 == 3506022 and f53_arg1:GetNinsatsuNum() <= 1 then
            f53_arg1:SetNumber(3, 1)
            return false
        end
    end
    if Interupt_Use_Item(f53_arg1, 4, 20) and f53_local3 == false then
        if f53_local0 <= 5 then
            f53_arg1:Replanning()
            return true
        elseif f53_local0 <= 10.7 - f53_arg1:GetMapHitRadius(TARGET_SELF) - 1 then
            f53_arg2:ClearSubGoal()
            f53_arg2:AddSubGoal(GOAL_COMMON_Wait, 0.1, TARGET_SELF, 0, 0, 0)
            f53_arg2:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3003, TARGET_ENE_0, 6.2 - f53_arg1:GetMapHitRadius(TARGET_SELF), 0, 0, 0, 0)
            return true
        else
            f53_arg1:Replanning()
            return true
        end
    end
    if f53_arg1:IsInterupt(INTERUPT_InactivateSpecialEffect) then
        if f53_arg1:GetSpecialEffectInactivateInterruptType(0) == 110125 then
            f53_arg1:Replanning()
            return true
        elseif f53_arg1:GetSpecialEffectInactivateInterruptType(0) == 110010 then
            f53_arg1:Replanning()
            return true
        end
        return false
    end
    if f53_arg1:IsInterupt(INTERUPT_LoseSightTarget) and f53_arg1:IsActiveGoal(GOAL_COMMON_SidewayMove) then
        if f53_arg1:GetNumber(10) == 0 then
            f53_arg2:ClearSubGoal()
            f53_arg2:AddSubGoal(GOAL_COMMON_SidewayMove, 1, TARGET_ENE_0, 1, f53_arg1:GetRandam_Int(30, 45), true, true, -1):SetTargetRange(0, -99, 10)
            return true
        elseif f53_arg1:GetNumber(10) == 1 then
            f53_arg2:ClearSubGoal()
            f53_arg2:AddSubGoal(GOAL_COMMON_SidewayMove, 1, TARGET_ENE_0, 0, f53_arg1:GetRandam_Int(30, 45), true, true, -1):SetTargetRange(0, -99, 10)
            return true
        else
            f53_arg1:Replanning()
            return false
        end
    end
    if f53_arg1:IsInterupt(INTERUPT_TargetOutOfRange) and f53_arg1:IsTargetOutOfRangeInterruptSlot(0) then
        f53_arg1:Replanning()
        return false
    end
    return false
    
end

Goal.Parry = function (f54_arg0, f54_arg1, f54_arg2, f54_arg3)
    local f54_local0 = f54_arg0:GetDist(TARGET_ENE_0)
    local f54_local1 = GetDist_Parry(f54_arg0)
    local f54_local2 = f54_arg0:GetRandam_Int(1, 100)
    local f54_local3 = f54_arg0:GetRandam_Int(1, 100)
    local f54_local4 = f54_arg0:GetRandam_Int(1, 100)
    local f54_local5 = f54_arg0:GetRandam_Int(1, 100)
    local f54_local6 = f54_arg0:GetRandam_Int(1, 100)
    local f54_local7 = f54_arg0:HasSpecialEffectId(TARGET_ENE_0, 109970)
    local f54_local8 = f54_arg0:HasSpecialEffectId(TARGET_ENE_0, COMMON_SP_EFFECT_PC_ATTACK_RUSH)
    if f54_arg0:IsFinishTimer(AI_TIMER_PARRY_INTERVAL) == false then
        return false
    end
    if f54_arg0:HasSpecialEffectId(TARGET_ENE_0, 110450) then
        return false
    end
    f54_arg0:SetTimer(AI_TIMER_PARRY_INTERVAL, 0.1)
    if f54_arg2 == nil then
        f54_arg2 = 50
    end
    if f54_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) and f54_arg0:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_F, 90, f54_local1) then
        if f54_arg0:HasSpecialEffectId(TARGET_SELF, 3506080) then
            f54_arg1:ClearSubGoal()
            f54_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 20006, TARGET_ENE_0, 9999, 0)
            return true
        elseif f54_local8 then
            if f54_arg0:GetNinsatsuNum() <= 1 then
                if f54_local5 <= 30 then
                    f54_arg1:ClearSubGoal()
                    f54_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3039, TARGET_ENE_0, 9999, 0, 0)
                else
                    f54_arg1:ClearSubGoal()
                    f54_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.3, 3103, TARGET_ENE_0, 9999, 0)
                end
            elseif f54_local5 <= 30 then
                f54_arg1:ClearSubGoal()
                f54_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3039, TARGET_ENE_0, 9999, 0, 0)
            else
                f54_arg1:ClearSubGoal()
                f54_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.3, 3103, TARGET_ENE_0, 9999, 0)
            end
            return true
        elseif f54_local7 then
            if f54_arg0:HasSpecialEffectId(TARGET_SELF, 3506070) then
                f54_arg1:ClearSubGoal()
                f54_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3102, TARGET_ENE_0, 9999, 0)
                return true
            else
                f54_arg1:ClearSubGoal()
                f54_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3041, TARGET_ENE_0, 9999, 0)
                return true
            end
        elseif f54_arg0:GetNinsatsuNum() <= 1 then
            if f54_local5 <= 30 then
                f54_arg1:ClearSubGoal()
                f54_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3039, TARGET_ENE_0, 9999, 0, 0)
            elseif f54_arg0:HasSpecialEffectId(TARGET_ENE_0, 109980) then
                f54_arg1:ClearSubGoal()
                f54_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 1, 5201, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0)
                return true
            elseif f54_local3 <= Get_ConsecutiveGuardCount(f54_arg0) * f54_arg2 then
                f54_arg1:ClearSubGoal()
                f54_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3101, TARGET_ENE_0, 9999, 0)
                return true
            elseif f54_arg0:HasSpecialEffectId(TARGET_SELF, 3506070) then
                f54_arg1:ClearSubGoal()
                f54_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3102, TARGET_ENE_0, 9999, 0)
                return true
            else
                f54_arg1:ClearSubGoal()
                f54_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3100, TARGET_ENE_0, 9999, 0)
                return true
            end
        elseif f54_local5 <= 30 then
            f54_arg1:ClearSubGoal()
            f54_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3039, TARGET_ENE_0, 9999, 0, 0)
        elseif f54_arg0:HasSpecialEffectId(TARGET_ENE_0, 109980) then
            f54_arg1:ClearSubGoal()
            f54_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 1, 5201, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0)
            return true
        elseif f54_local3 <= Get_ConsecutiveGuardCount(f54_arg0) * f54_arg2 then
            f54_arg1:ClearSubGoal()
            f54_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3101, TARGET_ENE_0, 9999, 0)
            return true
        elseif f54_arg0:HasSpecialEffectId(TARGET_SELF, 3506070) then
            f54_arg1:ClearSubGoal()
            f54_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3102, TARGET_ENE_0, 9999, 0)
            return true
        else
            f54_arg1:ClearSubGoal()
            f54_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3100, TARGET_ENE_0, 9999, 0)
            return true
        end
    else
        return false
    end
    
end

Goal.ShootReaction = function (f55_arg0, f55_arg1)
    local f55_local0 = f55_arg0:GetRandam_Int(1, 100)
    if f55_local0 <= 50 then
        f55_arg1:ClearSubGoal()
        f55_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3092, TARGET_ENE_0, 9999, 0, 0)
    else
        f55_arg1:ClearSubGoal()
        f55_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3100, TARGET_ENE_0, 9999, 0)
    end
    return true
    
end

Goal.Kengeki_Activate = function (f56_arg0, f56_arg1, f56_arg2, f56_arg3)
    local f56_local0 = ReturnKengekiSpecialEffect(f56_arg1)
    if f56_local0 == 0 then
        return false
    end
    local f56_local1 = {}
    local f56_local2 = {}
    local f56_local3 = {}
    Common_Clear_Param(f56_local1, f56_local2, f56_local3)
    local f56_local4 = f56_arg1:GetDist(TARGET_ENE_0)
    local f56_local5 = f56_arg1:GetSp(TARGET_SELF)
    if f56_arg1:GetNinsatsuNum() <= 1 and f56_arg1:GetNumber(3) == 0 then
    elseif f56_local0 == 200226 then
        f56_local1[8] = 200
        f56_local1[9] = 100
    elseif f56_local0 == 200210 then
        if f56_local4 >= 3 then
            f56_local1[26] = 100
        else
            f56_local1[1] = 100
            f56_local1[5] = 100
            f56_local1[11] = 100
            f56_local1[12] = 300
        end
    elseif f56_local0 == 200211 then
        if f56_local4 >= 3 then
            f56_local1[26] = 100
        else
            f56_local1[2] = 100
            f56_local1[4] = 100
            f56_local1[12] = 200
        end
    elseif f56_arg1:GetNumber(5) >= 30 - 3 then
        f56_local1[24] = 100
        f56_local1[12] = 150
    elseif f56_local0 == 200200 then
        if f56_local4 >= 3 then
            f56_local1[26] = 100
        else
            f56_local1[1] = 100
            f56_local1[3] = 150
            f56_local1[6] = 100
            f56_local1[5] = 200
        end
    elseif f56_local0 == 200201 then
        if f56_local4 >= 3 then
            f56_local1[26] = 100
        else
            f56_local1[2] = 100
            f56_local1[7] = 100
            f56_local1[13] = 250
        end
    elseif f56_local0 == 200215 then
        if f56_local4 >= 3 then
            f56_local1[26] = 100
        elseif f56_arg1:GetNumber(5) >= 30 then
            f56_local1[1] = 100
            f56_local1[6] = 100
            f56_local1[3] = 100
            f56_local1[5] = 500
        else
            f56_local1[1] = 200
            f56_local1[3] = 100
        end
    elseif f56_local0 == 200216 then
        if f56_local4 >= 3 then
            f56_local1[26] = 100
        else
            f56_local1[2] = 200
            f56_local1[7] = 100
        end
    end
    f56_local1[2] = SetCoolTime(f56_arg1, f56_arg2, 3066, 2, f56_local1[2], 1)
    f56_local1[3] = SetCoolTime(f56_arg1, f56_arg2, 3064, 5, f56_local1[3], 1)
    f56_local1[4] = SetCoolTime(f56_arg1, f56_arg2, 3068, 5, f56_local1[4], 1)
    f56_local1[6] = SetCoolTime(f56_arg1, f56_arg2, 3060, 2, f56_local1[6], 1)
    f56_local1[7] = SetCoolTime(f56_arg1, f56_arg2, 3065, 2, f56_local1[7], 1)
    f56_local1[12] = SetCoolTime(f56_arg1, f56_arg2, 3005, 4, f56_local1[12], 1)
    f56_local1[12] = SetCoolTime(f56_arg1, f56_arg2, 3006, 8, f56_local1[12], 1)
    f56_local1[12] = SetCoolTime(f56_arg1, f56_arg2, 3007, 8, f56_local1[12], 1)
    f56_local1[13] = SetCoolTime(f56_arg1, f56_arg2, 3024, 5, f56_local1[13], 1)
    f56_local2[1] = REGIST_FUNC(f56_arg1, f56_arg2, f56_arg0.Kengeki01)
    f56_local2[2] = REGIST_FUNC(f56_arg1, f56_arg2, f56_arg0.Kengeki02)
    f56_local2[3] = REGIST_FUNC(f56_arg1, f56_arg2, f56_arg0.Kengeki03)
    f56_local2[4] = REGIST_FUNC(f56_arg1, f56_arg2, f56_arg0.Kengeki04)
    f56_local2[5] = REGIST_FUNC(f56_arg1, f56_arg2, f56_arg0.Kengeki05)
    f56_local2[6] = REGIST_FUNC(f56_arg1, f56_arg2, f56_arg0.Kengeki06)
    f56_local2[7] = REGIST_FUNC(f56_arg1, f56_arg2, f56_arg0.Kengeki07)
    f56_local2[8] = REGIST_FUNC(f56_arg1, f56_arg2, f56_arg0.Kengeki08)
    f56_local2[9] = REGIST_FUNC(f56_arg1, f56_arg2, f56_arg0.Kengeki09)
    f56_local2[11] = REGIST_FUNC(f56_arg1, f56_arg2, f56_arg0.Kengeki11)
    f56_local2[12] = REGIST_FUNC(f56_arg1, f56_arg2, f56_arg0.Kengeki12)
    f56_local2[13] = REGIST_FUNC(f56_arg1, f56_arg2, f56_arg0.Kengeki13)
    f56_local2[15] = REGIST_FUNC(f56_arg1, f56_arg2, f56_arg0.Act04)
    f56_local2[16] = REGIST_FUNC(f56_arg1, f56_arg2, f56_arg0.Act07)
    f56_local2[21] = REGIST_FUNC(f56_arg1, f56_arg2, f56_arg0.Act21)
    f56_local2[22] = REGIST_FUNC(f56_arg1, f56_arg2, f56_arg0.Act22)
    f56_local2[23] = REGIST_FUNC(f56_arg1, f56_arg2, f56_arg0.Act23)
    f56_local2[24] = REGIST_FUNC(f56_arg1, f56_arg2, f56_arg0.Kengeki24)
    f56_local2[25] = REGIST_FUNC(f56_arg1, f56_arg2, f56_arg0.Act25)
    f56_local2[26] = REGIST_FUNC(f56_arg1, f56_arg2, f56_arg0.NoAction)
    local f56_local6 = REGIST_FUNC(f56_arg1, f56_arg2, f56_arg0.ActAfter_AdjustSpace)
    return Common_Kengeki_Activate(f56_arg1, f56_arg2, f56_local1, f56_local2, f56_local6, f56_local3)
    
end

Goal.Kengeki01 = function (f57_arg0, f57_arg1, f57_arg2)
    f57_arg1:ClearSubGoal()
    f57_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3061, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f57_arg0:GetNumber(5) + 6, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki02 = function (f58_arg0, f58_arg1, f58_arg2)
    f58_arg1:ClearSubGoal()
    f58_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3066, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f58_arg0:GetNumber(5) + 6, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki03 = function (f59_arg0, f59_arg1, f59_arg2)
    f59_arg1:ClearSubGoal()
    f59_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3064, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, 0, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki04 = function (f60_arg0, f60_arg1, f60_arg2)
    f60_arg1:ClearSubGoal()
    f60_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3068, TARGET_ENE_0, 6 - f60_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f60_arg0:GetNumber(5) + 6, AI_TIMING_SET__ACTIVATE)
    f60_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3017, TARGET_ENE_0, 9999, 0):TimingSetNumber(5, f60_arg0:GetNumber(5) + 15, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki05 = function (f61_arg0, f61_arg1, f61_arg2)
    f61_arg1:ClearSubGoal()
    f61_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3063, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f61_arg0:GetNumber(5) + 8, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki06 = function (f62_arg0, f62_arg1, f62_arg2)
    f62_arg1:ClearSubGoal()
    f62_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3060, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f62_arg0:GetNumber(5) + 6, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki07 = function (f63_arg0, f63_arg1, f63_arg2)
    f63_arg1:ClearSubGoal()
    f63_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3065, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f63_arg0:GetNumber(5) + 6, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki08 = function (f64_arg0, f64_arg1, f64_arg2)
    f64_arg1:ClearSubGoal()
    f64_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3090, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f64_arg0:GetNumber(5) + 6, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki09 = function (f65_arg0, f65_arg1, f65_arg2)
    f65_arg1:ClearSubGoal()
    f65_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3091, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f65_arg0:GetNumber(5) + 6, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki11 = function (f66_arg0, f66_arg1, f66_arg2)
    f66_arg1:ClearSubGoal()
    f66_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3026, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f66_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki12 = function (f67_arg0, f67_arg1, f67_arg2)
    f67_arg1:ClearSubGoal()
    f67_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3005, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f67_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki13 = function (f68_arg0, f68_arg1, f68_arg2)
    f68_arg1:ClearSubGoal()
    f68_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3024, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f68_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki24 = function (f69_arg0, f69_arg1, f69_arg2)
    f69_arg1:ClearSubGoal()
    f69_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 5201, TARGET_ENE_0, 9999, 0, 0, 0, 0):TimingSetNumber(5, 0, AI_TIMING_SET__ACTIVATE)
    
end

Goal.NoAction = function (f70_arg0, f70_arg1, f70_arg2)
    return -1
    
end

Goal.ActAfter_AdjustSpace = function (f71_arg0, f71_arg1, f71_arg2)
    
end

Goal.Update = function (f72_arg0, f72_arg1, f72_arg2)
    return Update_Default_NoSubGoal(f72_arg0, f72_arg1, f72_arg2)
    
end

Goal.Terminate = function (f73_arg0, f73_arg1, f73_arg2)
    
end


