RegisterTableGoal(GOAL_NingunOsa_506001_Battle, "GOAL_NingunOsa_506001_Battle")
REGISTER_GOAL_NO_UPDATE(GOAL_NingunOsa_506001_Battle, true)

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
    local f2_local5 = f2_arg1:GetSpRate(TARGET_SELF)
    local f2_local6 = f2_arg1:GetDist(TARGET_ENE_0)
    local f2_local7 = f2_arg1:GetRandam_Int(1, 100)
    local f2_local8 = f2_arg1:GetExcelParam(AI_EXCEL_THINK_PARAM_TYPE__thinkAttr_doAdmirer)
    local f2_local9 = f2_arg1:GetEventRequest()
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 110010)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 110125)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 3506000)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 3506030)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 3506021)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 5030)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 3506080)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 3506082)
    Set_ConsecutiveGuardCount_Interrupt(f2_arg1)
    if f2_arg0.Kengeki_Activate(f2_arg0, f2_arg1, f2_arg2) then
        return
    end
    if f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 110060) or f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 110010) then
        if f2_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) then
            f2_local0[21] = 1
            f2_local0[28] = 100
        else
            f2_local0[21] = 100
        end
    elseif Common_ActivateAct(f2_arg1, f2_arg2, 0, 1) then
    elseif f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 110125) then
        f2_local0[40] = 100
    elseif f2_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_B, 90) then
        if f2_local6 > 7 then
            f2_local0[21] = 1
            f2_local0[30] = 100
        elseif f2_local6 > 5 then
            f2_local0[21] = 1
            f2_local0[30] = 100
        else
            f2_local0[21] = 1
            f2_local0[30] = 100
        end
    elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 3506081) then
        if f2_local5 < 0.75 then
            f2_local0[14] = 400
        end
        f2_local0[2] = 100
        f2_local0[6] = 100
    elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 5031) or f2_arg1:HasSpecialEffectId(TARGET_SELF, 5032) then
        if f2_arg1:HasSpecialEffectId(TARGET_SELF, 5031) then
            f2_local0[6] = 100
            f2_local0[9] = 200
        else
            f2_local0[6] = 100
            f2_local0[8] = 200
        end
    elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 5033) then
        f2_local0[11] = 300
        f2_local0[8] = 100
        f2_local0[9] = 100
    elseif f2_local6 >= 10 then
        f2_local0[2] = 100
        f2_local0[6] = 200
        f2_local0[8] = 100
        f2_local0[9] = 100
    elseif f2_local6 >= 7 then
        f2_local0[2] = 50
        f2_local0[6] = 100
        f2_local0[8] = 100
        f2_local0[9] = 200
    elseif f2_local6 > 3 then
        f2_local0[1] = 250
        f2_local0[4] = 150
        f2_local0[11] = 100
    else
        f2_local0[1] = 100
        f2_local0[4] = 250
        f2_local0[11] = 50
        f2_local0[30] = 100
    end
    if f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 9050) then
        f2_local0[9] = f2_local0[9] * 1.5
        f2_local0[11] = f2_local0[11] * 2
    end
    if f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 3506090) then
        f2_local0[11] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 45, 2) == false and SpaceCheck(f2_arg1, f2_arg2, -45, 2) == false then
        f2_local0[22] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 90, 1) == false and SpaceCheck(f2_arg1, f2_arg2, -45, 1) == false then
        f2_local0[23] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 90, 5) == false and SpaceCheck(f2_arg1, f2_arg2, -45, 5) == false then
        f2_local0[31] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 180, 2) == false then
        f2_local0[24] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 180, 1) == false then
        f2_local0[25] = 0
    end
    f2_local0[1] = SetCoolTime(f2_arg1, f2_arg2, 3000, 5, f2_local0[1], 1)
    f2_local0[2] = SetCoolTime(f2_arg1, f2_arg2, 3018, 5, f2_local0[2], 1)
    f2_local0[7] = SetCoolTime(f2_arg1, f2_arg2, 3010, 15, f2_local0[7], 1)
    f2_local0[7] = SetCoolTime(f2_arg1, f2_arg2, 3064, 15, f2_local0[7], 1)
    f2_local0[3] = SetCoolTime(f2_arg1, f2_arg2, 3003, 10, f2_local0[3], 1)
    f2_local0[6] = SetCoolTime(f2_arg1, f2_arg2, 3003, 8, f2_local0[6], 1)
    f2_local0[4] = SetCoolTime(f2_arg1, f2_arg2, 3030, 12, f2_local0[4], 1)
    f2_local0[4] = SetCoolTime(f2_arg1, f2_arg2, 3007, 12, f2_local0[4], 1)
    f2_local0[4] = SetCoolTime(f2_arg1, f2_arg2, 3005, 4, f2_local0[4], 1)
    f2_local0[9] = SetCoolTime(f2_arg1, f2_arg2, 3015, 5, f2_local0[9], 1)
    f2_local0[9] = SetCoolTime(f2_arg1, f2_arg2, 3031, 5, f2_local0[9], 1)
    f2_local0[11] = SetCoolTime(f2_arg1, f2_arg2, 3031, 5, f2_local0[11], 1)
    f2_local0[11] = SetCoolTime(f2_arg1, f2_arg2, 3015, 5, f2_local0[11], 1)
    f2_local0[14] = SetCoolTime(f2_arg1, f2_arg2, 3045, 30, f2_local0[14], 1)
    f2_local1[1] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act01)
    f2_local1[2] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act02)
    f2_local1[3] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act03)
    f2_local1[4] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act04)
    f2_local1[6] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act06)
    f2_local1[7] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act07)
    f2_local1[8] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act08)
    f2_local1[9] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act09)
    f2_local1[10] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act10)
    f2_local1[11] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act11)
    f2_local1[12] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act12)
    f2_local1[14] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act14)
    f2_local1[15] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act15)
    f2_local1[21] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act21)
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
    f2_local1[41] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act41)
    f2_local1[49] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act49)
    f2_local1[50] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act50)
    local f2_local10 = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.ActAfter_AdjustSpace)
    Common_Battle_Activate(f2_arg1, f2_arg2, f2_local0, f2_local1, f2_local10, f2_local2)
    
end

Goal.Act01 = function (f3_arg0, f3_arg1, f3_arg2)
    local f3_local0 = 4.8 - f3_arg0:GetMapHitRadius(TARGET_SELF)
    local f3_local1 = 4.8 - f3_arg0:GetMapHitRadius(TARGET_SELF)
    local f3_local2 = 999
    local f3_local3 = 30
    local f3_local4 = 0
    local f3_local5 = 1.5
    local f3_local6 = 3
    if f3_arg0:HasSpecialEffectId(TARGET_ENE_0, 3506090) then
        f3_local3 = 100
    end
    if f3_arg0:IsFinishTimer(2) == false then
        f3_local3 = 100
    end
    Approach_Act_Flex(f3_arg0, f3_arg1, f3_local0, f3_local1, f3_local2, f3_local3, f3_local4, f3_local5, f3_local6)
    local f3_local7 = 0
    local f3_local8 = 0
    local f3_local9 = f3_arg0:GetRandam_Int(1, 100)
    f3_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3000, TARGET_ENE_0, 4.2 - f3_arg0:GetMapHitRadius(TARGET_SELF), f3_local7, f3_local8, 0, 0):TimingSetNumber(5, f3_arg0:GetNumber(5) + 2, AI_TIMING_SET__ACTIVATE)
    f3_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3001, TARGET_ENE_0, 5.8 - f3_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, f3_arg0:GetNumber(5) + 7, AI_TIMING_SET__ACTIVATE)
    if f3_local9 <= 50 then
        f3_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3002, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f3_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    else
        f3_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3063, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f3_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    end
    return 0
    
end

Goal.Act02 = function (f4_arg0, f4_arg1, f4_arg2)
    local f4_local0 = 11 - f4_arg0:GetMapHitRadius(TARGET_SELF)
    local f4_local1 = 11 - f4_arg0:GetMapHitRadius(TARGET_SELF)
    local f4_local2 = 999
    local f4_local3 = 30
    local f4_local4 = 0
    local f4_local5 = 1
    local f4_local6 = 2
    if f4_arg0:HasSpecialEffectId(TARGET_ENE_0, 3506090) then
        f4_local3 = 100
    end
    if f4_arg0:IsFinishTimer(2) == false then
        f4_local3 = 100
    end
    Approach_Act_Flex(f4_arg0, f4_arg1, f4_local0, f4_local1, f4_local2, f4_local3, f4_local4, f4_local5, f4_local6)
    local f4_local7 = 0
    local f4_local8 = 0
    f4_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3018, TARGET_ENE_0, 9999, f4_local7, f4_local8, 0, 0):TimingSetNumber(5, f4_arg0:GetNumber(5) + 9, AI_TIMING_SET__ACTIVATE)
    return 0
    
end

Goal.Act03 = function (f5_arg0, f5_arg1, f5_arg2)
    local f5_local0 = 10.7 - f5_arg0:GetMapHitRadius(TARGET_SELF)
    local f5_local1 = 10.7 - f5_arg0:GetMapHitRadius(TARGET_SELF)
    local f5_local2 = 999
    local f5_local3 = 30
    local f5_local4 = 0
    local f5_local5 = 1
    local f5_local6 = 2
    if f5_arg0:HasSpecialEffectId(TARGET_ENE_0, 3506090) then
        f5_local3 = 100
    end
    if f5_arg0:IsFinishTimer(2) == false then
        f5_local3 = 100
    end
    Approach_Act_Flex(f5_arg0, f5_arg1, f5_local0, f5_local1, f5_local2, f5_local3, f5_local4, f5_local5, f5_local6)
    local f5_local7 = 0
    local f5_local8 = 0
    f5_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3003, TARGET_ENE_0, 9999, f5_local7, f5_local8, 0, 0):TimingSetNumber(5, f5_arg0:GetNumber(5) + 9, AI_TIMING_SET__ACTIVATE)
    return 0
    
end

Goal.Act04 = function (f6_arg0, f6_arg1, f6_arg2)
    local f6_local0 = 2.8 - f6_arg0:GetMapHitRadius(TARGET_SELF)
    local f6_local1 = 2.8 - f6_arg0:GetMapHitRadius(TARGET_SELF)
    local f6_local2 = 999
    local f6_local3 = 30
    local f6_local4 = 0
    local f6_local5 = 1
    local f6_local6 = 2
    if f6_arg0:HasSpecialEffectId(TARGET_ENE_0, 3506090) then
        f6_local3 = 100
    end
    if f6_arg0:IsFinishTimer(2) == false then
        f6_local3 = 100
    end
    Approach_Act_Flex(f6_arg0, f6_arg1, f6_local0, f6_local1, f6_local2, f6_local3, f6_local4, f6_local5, f6_local6)
    local f6_local7 = 0
    local f6_local8 = 0
    f6_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3005, TARGET_ENE_0, 9999, f6_local7, f6_local8, 0, 0):TimingSetNumber(5, f6_arg0:GetNumber(5) + 1, AI_TIMING_SET__ACTIVATE)
    return 0
    
end

Goal.Act05 = function (f7_arg0, f7_arg1, f7_arg2)
    local f7_local0 = 3.3 - f7_arg0:GetMapHitRadius(TARGET_SELF)
    local f7_local1 = 3.3 - f7_arg0:GetMapHitRadius(TARGET_SELF)
    local f7_local2 = 999
    local f7_local3 = 30
    local f7_local4 = 0
    local f7_local5 = 1.5
    local f7_local6 = 3
    if f7_arg0:HasSpecialEffectId(TARGET_ENE_0, 3506090) then
        f7_local3 = 100
    end
    if f7_arg0:IsFinishTimer(2) == false then
        f7_local3 = 100
    end
    Approach_Act_Flex(f7_arg0, f7_arg1, f7_local0, f7_local1, f7_local2, f7_local3, f7_local4, f7_local5, f7_local6)
    local f7_local7 = 0
    local f7_local8 = 0
    f7_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3008, TARGET_ENE_0, 6 - f7_arg0:GetMapHitRadius(TARGET_SELF), f7_local7, f7_local8, 0, 0):TimingSetNumber(5, f7_arg0:GetNumber(5) + 6, AI_TIMING_SET__ACTIVATE)
    return 0
    
end

Goal.Act06 = function (f8_arg0, f8_arg1, f8_arg2)
    local f8_local0 = 10.7 - f8_arg0:GetMapHitRadius(TARGET_SELF) - 1
    local f8_local1 = 10.7 - f8_arg0:GetMapHitRadius(TARGET_SELF) - 1
    local f8_local2 = 999
    local f8_local3 = 30
    local f8_local4 = 0
    local f8_local5 = 1.5
    local f8_local6 = 3
    local f8_local7 = f8_arg0:GetRandam_Int(1, 100)
    if f8_arg0:HasSpecialEffectId(TARGET_ENE_0, 3506090) then
        f8_local3 = 100
    end
    if f8_arg0:IsFinishTimer(2) == false then
        f8_local3 = 100
    end
    Approach_Act_Flex(f8_arg0, f8_arg1, f8_local0, f8_local1, f8_local2, f8_local3, f8_local4, f8_local5, f8_local6)
    local f8_local8 = 0
    local f8_local9 = 0
    f8_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3009, TARGET_ENE_0, 999 - f8_arg0:GetMapHitRadius(TARGET_SELF), f8_local8, f8_local9, 0, 0):TimingSetNumber(5, f8_arg0:GetNumber(5) + 1, AI_TIMING_SET__ACTIVATE)
    f8_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3014, TARGET_ENE_0, 9999, 0):TimingSetNumber(5, f8_arg0:GetNumber(5) + 2, AI_TIMING_SET__ACTIVATE)
    f8_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3003, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f8_arg0:GetNumber(5) + 9, AI_TIMING_SET__ACTIVATE)
    return 0
    
end

Goal.Act07 = function (f9_arg0, f9_arg1, f9_arg2)
    local f9_local0 = 3.5 - f9_arg0:GetMapHitRadius(TARGET_SELF)
    local f9_local1 = 3.5 - f9_arg0:GetMapHitRadius(TARGET_SELF)
    local f9_local2 = 999
    local f9_local3 = 30
    local f9_local4 = 0
    local f9_local5 = 1.5
    local f9_local6 = 3
    if f9_arg0:HasSpecialEffectId(TARGET_ENE_0, 3506090) then
        f9_local3 = 100
    end
    if f9_arg0:IsFinishTimer(2) == false then
        f9_local3 = 100
    end
    Approach_Act_Flex(f9_arg0, f9_arg1, f9_local0, f9_local1, f9_local2, f9_local3, f9_local4, f9_local5, f9_local6)
    local f9_local7 = 0
    local f9_local8 = 0
    f9_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3010, TARGET_ENE_0, 11 - f9_arg0:GetMapHitRadius(TARGET_SELF), f9_local7, f9_local8, 0, 0):TimingSetNumber(5, 0, AI_TIMING_SET__ACTIVATE)
    return 0
    
end

Goal.Act08 = function (f10_arg0, f10_arg1, f10_arg2)
    local f10_local0 = 11 - f10_arg0:GetMapHitRadius(TARGET_SELF)
    local f10_local1 = 11 - f10_arg0:GetMapHitRadius(TARGET_SELF)
    local f10_local2 = 999
    local f10_local3 = 30
    local f10_local4 = 0
    local f10_local5 = 1.5
    local f10_local6 = 3
    local f10_local7 = f10_arg0:GetRandam_Int(1, 100)
    if f10_arg0:HasSpecialEffectId(TARGET_ENE_0, 3506090) then
        f10_local3 = 100
    end
    if f10_arg0:IsFinishTimer(2) == false then
        f10_local3 = 100
    end
    Approach_Act_Flex(f10_arg0, f10_arg1, f10_local0, f10_local1, f10_local2, f10_local3, f10_local4, f10_local5, f10_local6)
    local f10_local8 = 0
    local f10_local9 = 0
    local f10_local10 = f10_arg0:GetDist(TARGET_ENE_0)
    local f10_local11 = 3011
    f10_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, f10_local11, TARGET_ENE_0, 9999, f10_local8, f10_local9, 0, 0):TimingSetNumber(5, f10_arg0:GetNumber(5) + 1, AI_TIMING_SET__ACTIVATE)
    if f10_local7 <= 50 then
        f10_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3002, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f10_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    else
        f10_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3005, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f10_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    end
    return 0
    
end

Goal.Act09 = function (f11_arg0, f11_arg1, f11_arg2)
    local f11_local0 = 9 - f11_arg0:GetMapHitRadius(TARGET_SELF)
    local f11_local1 = 9 - f11_arg0:GetMapHitRadius(TARGET_SELF)
    local f11_local2 = 999
    local f11_local3 = 30
    local f11_local4 = 0
    local f11_local5 = 1.5
    local f11_local6 = 3
    local f11_local7 = f11_arg0:GetRandam_Int(1, 100)
    if f11_arg0:HasSpecialEffectId(TARGET_ENE_0, 3506090) then
        f11_local3 = 100
    end
    if f11_arg0:IsFinishTimer(2) == false then
        f11_local3 = 100
    end
    Approach_Act_Flex(f11_arg0, f11_arg1, f11_local0, f11_local1, f11_local2, f11_local3, f11_local4, f11_local5, f11_local6)
    local f11_local8 = 0
    local f11_local9 = 0
    f11_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3015, TARGET_ENE_0, 4.5 - f11_arg0:GetMapHitRadius(TARGET_SELF), f11_local8, f11_local9, 0, 0):TimingSetNumber(5, f11_arg0:GetNumber(5) + 5, AI_TIMING_SET__ACTIVATE)
    if f11_arg0:HasSpecialEffectId(TARGET_ENE_0, 3506090) then
        f11_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3063, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f11_arg0:GetNumber(5) + 8, AI_TIMING_SET__ACTIVATE)
    else
        f11_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3032, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f11_arg0:GetNumber(5) + 8, AI_TIMING_SET__ACTIVATE)
    end
    return 0
    
end

Goal.Act10 = function (f12_arg0, f12_arg1, f12_arg2)
    local f12_local0 = 0
    local f12_local1 = f12_arg0:GetRandam_Int(1, 100)
    local f12_local2 = f12_arg0:IsExistMeshOnLine(TARGET_SELF, AI_DIR_TYPE_L, 5)
    local f12_local3 = f12_arg0:IsExistMeshOnLine(TARGET_SELF, AI_DIR_TYPE_R, 5)
    if f12_local2 then
        if f12_local3 then
            if f12_local1 <= 50 then
                f12_local0 = 0
            else
                f12_local0 = 1
            end
        else
            f12_local0 = 0
        end
    elseif f12_local3 then
        f12_local0 = 1
    else
        f12_local0 = 2
    end
    local f12_local4 = 100
    local f12_local5 = 0
    local f12_local6 = 1.5
    local f12_local7 = 5
    if f12_local0 == 2 then
        local f12_local8 = 9 - f12_arg0:GetMapHitRadius(TARGET_SELF)
        local f12_local9 = 9 - f12_arg0:GetMapHitRadius(TARGET_SELF)
        local f12_local10 = 9 - f12_arg0:GetMapHitRadius(TARGET_SELF)
        Approach_Act_Flex(f12_arg0, f12_arg1, f12_local8, f12_local9, f12_local10, f12_local4, f12_local5, f12_local6, f12_local7)
        local f12_local11 = 0
        local f12_local12 = 0
        f12_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3047, TARGET_ENE_0, 9999, f12_local11, f12_local12, 0, 0):TimingSetNumber(5, f12_arg0:GetNumber(5) + 8, AI_TIMING_SET__ACTIVATE)
    elseif f12_local0 == 0 then
        local f12_local8 = f12_arg0:GetRandam_Int(70, 90)
        f12_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, 3, TARGET_ENE_0, 0, f12_local8, false, true, -1)
        local f12_local9 = 7.8 - f12_arg0:GetMapHitRadius(TARGET_SELF)
        local f12_local10 = 7.8 - f12_arg0:GetMapHitRadius(TARGET_SELF)
        local f12_local11 = 7.8 - f12_arg0:GetMapHitRadius(TARGET_SELF)
        Approach_Act_Flex(f12_arg0, f12_arg1, f12_local9, f12_local10, f12_local11, f12_local4, f12_local5, f12_local6, f12_local7)
        local f12_local12 = 0
        local f12_local13 = 0
        f12_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3046, TARGET_ENE_0, 9999, f12_local12, f12_local13, 0, 0):TimingSetNumber(5, f12_arg0:GetNumber(5) + 8, AI_TIMING_SET__ACTIVATE)
    else
        local f12_local8 = f12_arg0:GetRandam_Int(70, 90)
        f12_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, 3, TARGET_ENE_0, 1, f12_local8, false, true, -1)
        local f12_local9 = 7.8 - f12_arg0:GetMapHitRadius(TARGET_SELF)
        local f12_local10 = 7.8 - f12_arg0:GetMapHitRadius(TARGET_SELF)
        local f12_local11 = 7.8 - f12_arg0:GetMapHitRadius(TARGET_SELF)
        Approach_Act_Flex(f12_arg0, f12_arg1, f12_local9, f12_local10, f12_local11, f12_local4, f12_local5, f12_local6, f12_local7)
        local f12_local12 = 0
        local f12_local13 = 0
        f12_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3046, TARGET_ENE_0, 9999, f12_local12, f12_local13, 0, 0):TimingSetNumber(5, f12_arg0:GetNumber(5) + 8, AI_TIMING_SET__ACTIVATE)
    end
    return 0
    
end

Goal.Act11 = function (f13_arg0, f13_arg1, f13_arg2)
    local f13_local0 = 4.5 - f13_arg0:GetMapHitRadius(TARGET_SELF) + 1
    local f13_local1 = 4.5 - f13_arg0:GetMapHitRadius(TARGET_SELF) + 1
    local f13_local2 = 4.5 - f13_arg0:GetMapHitRadius(TARGET_SELF) + 1
    local f13_local3 = 100
    local f13_local4 = 0
    local f13_local5 = 1.5
    local f13_local6 = 3
    local f13_local7 = f13_arg0:GetRandam_Int(1, 100)
    if f13_arg0:HasSpecialEffectId(TARGET_ENE_0, 3506090) then
        f13_local3 = 100
    end
    Approach_Act_Flex(f13_arg0, f13_arg1, f13_local0, f13_local1, f13_local2, f13_local3, f13_local4, f13_local5, f13_local6)
    local f13_local8 = 0
    local f13_local9 = 0
    f13_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3031, TARGET_ENE_0, 9999, f13_local8, f13_local9, 0, 0):TimingSetNumber(5, f13_arg0:GetNumber(5) + 6, AI_TIMING_SET__ACTIVATE)
    return 0
    
end

Goal.Act12 = function (f14_arg0, f14_arg1, f14_arg2)
    local f14_local0 = 0
    local f14_local1 = 0
    f14_arg1:AddSubGoal(GOAL_COMMON_Wait, 0.1, TARGET_SELF, 0, 0, 0)
    f14_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3018, TARGET_ENE_0, 9999, f14_local0, f14_local1, 0, 0):TimingSetNumber(5, f14_arg0:GetNumber(5) + 9, AI_TIMING_SET__ACTIVATE)
    return 0
    
end

Goal.Act13 = function (f15_arg0, f15_arg1, f15_arg2)
    local f15_local0 = 5 - f15_arg0:GetMapHitRadius(TARGET_SELF)
    local f15_local1 = 5 - f15_arg0:GetMapHitRadius(TARGET_SELF)
    local f15_local2 = 999
    local f15_local3 = 30
    local f15_local4 = 0
    local f15_local5 = 1.5
    local f15_local6 = 3
    if f15_arg0:HasSpecialEffectId(TARGET_ENE_0, 3506090) then
        f15_local3 = 100
    end
    if f15_arg0:IsFinishTimer(2) == false then
        f15_local3 = 100
    end
    Approach_Act_Flex(f15_arg0, f15_arg1, f15_local0, f15_local1, f15_local2, f15_local3, f15_local4, f15_local5, f15_local6)
    local f15_local7 = 0
    local f15_local8 = 0
    f15_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3026, TARGET_ENE_0, 9999, f15_local7, f15_local8, 0, 0):TimingSetNumber(5, f15_arg0:GetNumber(5) + 15, AI_TIMING_SET__ACTIVATE)
    return 0
    
end

Goal.Act14 = function (f16_arg0, f16_arg1, f16_arg2)
    local f16_local0 = 0
    local f16_local1 = 0
    f16_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3045, TARGET_ENE_0, 9999, f16_local0, f16_local1, 0, 0)
    return 0
    
end

Goal.Act15 = function (f17_arg0, f17_arg1, f17_arg2)
    local f17_local0 = 9 - f17_arg0:GetMapHitRadius(TARGET_SELF)
    local f17_local1 = 9 - f17_arg0:GetMapHitRadius(TARGET_SELF)
    local f17_local2 = 999
    local f17_local3 = 30
    local f17_local4 = 0
    local f17_local5 = 1.5
    local f17_local6 = 3
    local f17_local7 = f17_arg0:GetRandam_Int(1, 100)
    if f17_arg0:HasSpecialEffectId(TARGET_ENE_0, 3506090) then
        f17_local3 = 100
    end
    if f17_arg0:IsFinishTimer(2) == false then
        f17_local3 = 100
    end
    Approach_Act_Flex(f17_arg0, f17_arg1, f17_local0, f17_local1, f17_local2, f17_local3, f17_local4, f17_local5, f17_local6)
    local f17_local8 = 0
    local f17_local9 = 0
    f17_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3015, TARGET_ENE_0, 4.5 - f17_arg0:GetMapHitRadius(TARGET_SELF), f17_local8, f17_local9, 0, 0):TimingSetNumber(5, f17_arg0:GetNumber(5) + 5, AI_TIMING_SET__ACTIVATE)
    f17_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3032, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f17_arg0:GetNumber(5) + 8, AI_TIMING_SET__ACTIVATE)
    return 0
    
end

Goal.Act21 = function (f18_arg0, f18_arg1, f18_arg2)
    local f18_local0 = 3
    local f18_local1 = 45
    f18_arg1:AddSubGoal(GOAL_COMMON_Turn, f18_local0, TARGET_ENE_0, f18_local1, -1, GOAL_RESULT_Success, true)
    return 0
    
end

Goal.Act23 = function (f19_arg0, f19_arg1, f19_arg2)
    local f19_local0 = 0
    if SpaceCheck(f19_arg0, f19_arg1, -90, 1) == true then
        if SpaceCheck(f19_arg0, f19_arg1, 90, 1) == true then
            if f19_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                f19_local0 = 0
            else
                f19_local0 = 1
            end
        else
            f19_local0 = 0
        end
    elseif SpaceCheck(f19_arg0, f19_arg1, 90, 1) == true then
        f19_local0 = 1
    else
    end
    local f19_local1 = 2.5
    if f19_arg2 == nil then
        f19_local1 = 2.5
    else
        f19_local1 = f19_arg2
    end
    local f19_local2 = f19_arg0:GetRandam_Int(30, 45)
    f19_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f19_local1, TARGET_ENE_0, f19_local0, f19_local2, true, true, -1)
    return 0
    
end

Goal.Act24 = function (f20_arg0, f20_arg1, f20_arg2)
    local f20_local0 = 3
    local f20_local1 = 0
    local f20_local2 = 4.5
    local f20_local3 = f20_arg0:GetRandam_Int(30, 45)
    f20_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f20_local0, 5201, TARGET_ENE_0, f20_local1, AI_DIR_TYPE_B, 0):TimingSetNumber(5, 0, AI_TIMING_SET__ACTIVATE)
    f20_local2 = 3.5
    local f20_local4 = 0
    if SpaceCheck(f20_arg0, f20_arg1, -90, 1) == true then
        if SpaceCheck(f20_arg0, f20_arg1, 90, 1) == true then
            if f20_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                f20_local4 = 0
            else
                f20_local4 = 1
            end
        else
            f20_local4 = 0
        end
    elseif SpaceCheck(f20_arg0, f20_arg1, 90, 1) == true then
        f20_local4 = 1
    else
    end
    return 0
    
end

Goal.Act25 = function (f21_arg0, f21_arg1, f21_arg2)
    local f21_local0 = f21_arg0:GetRandam_Float(2, 4)
    local f21_local1 = f21_arg0:GetRandam_Float(1, 3)
    local f21_local2 = -1
    f21_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, f21_local0, TARGET_ENE_0, f21_local1, TARGET_ENE_0, true, f21_local2):SetTargetRange(0, -99, 10)
    f21_arg0:SetTimer(1, 10)
    return 0
    
end

Goal.Act26 = function (f22_arg0, f22_arg1, f22_arg2)
    f22_arg1:AddSubGoal(GOAL_COMMON_Wait, 2, TARGET_SELF, 0, 0, 0)
    return 0
    
end

Goal.Act27 = function (f23_arg0, f23_arg1, f23_arg2)
    local f23_local0 = f23_arg0:GetDist(TARGET_ENE_0)
    local f23_local1 = f23_arg0:GetDistYSigned(TARGET_ENE_0)
    local f23_local2 = f23_local1 / math.tan(math.deg(30))
    local f23_local3 = f23_arg0:GetRandam_Int(0, 1)
    f23_arg0:SetNumber(10, f23_local3)
    if f23_local1 >= 3 then
        if f23_local2 + 1 <= f23_local0 then
            if SpaceCheck(f23_arg0, f23_arg1, 0, 4) == true then
                f23_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.1, TARGET_ENE_0, f23_local2, TARGET_SELF, false, -1)
            elseif SpaceCheck(f23_arg0, f23_arg1, 0, 3) == true then
                f23_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.5, TARGET_ENE_0, f23_local2, TARGET_SELF, true, -1)
            end
        elseif f23_local0 <= f23_local2 - 1 then
            f23_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 10, TARGET_ENE_0, f23_local2, TARGET_ENE_0, true, -1):SetTargetRange(0, -99, 12)
        end
    elseif SpaceCheck(f23_arg0, f23_arg1, 0, 4) == true then
        f23_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.1, TARGET_ENE_0, 0, TARGET_SELF, false, -1)
    elseif SpaceCheck(f23_arg0, f23_arg1, 0, 3) == true then
        f23_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.5, TARGET_ENE_0, 0, TARGET_SELF, true, -1)
    elseif SpaceCheck(f23_arg0, f23_arg1, 0, 1) == false then
        f23_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 0.5, TARGET_ENE_0, 999, TARGET_ENE_0, true, -1):SetTargetRange(0, -99, 12)
    end
    f23_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, 3, TARGET_ENE_0, f23_local3, f23_arg0:GetRandam_Int(30, 45), true, true, -1):SetTargetRange(0, -99, 12)
    return 0
    
end

Goal.Act28 = function (f24_arg0, f24_arg1, f24_arg2)
    local f24_local0 = f24_arg0:GetDist(TARGET_ENE_0)
    local f24_local1 = f24_arg0:GetRandam_Float(3, 3.5)
    local f24_local2 = f24_arg0:GetRandam_Int(30, 45)
    local f24_local3 = -1
    local f24_local4 = f24_arg0:GetRandam_Int(0, 1)
    if f24_local0 <= 5 then
        if SpaceCheck(f24_arg0, f24_arg1, 180, 1) == true then
            f24_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 3, TARGET_ENE_0, 6, TARGET_ENE_0, true, f24_local3)
        else
            f24_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f24_local1, TARGET_ENE_0, f24_local4, f24_local2, true, true, f24_local3)
        end
    elseif f24_local0 <= 7 then
        f24_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f24_local1, TARGET_ENE_0, f24_local4, f24_local2, true, true, f24_local3)
    elseif f24_local0 <= 8 then
        f24_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 3, TARGET_ENE_0, 3, TARGET_SELF, true, -1)
    else
        f24_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 3, TARGET_ENE_0, 8, TARGET_SELF, false, -1)
    end
    return 0
    
end

Goal.Act30 = function (f25_arg0, f25_arg1, f25_arg2)
    local f25_local0 = f25_arg0:GetDist(TARGET_ENE_0)
    local f25_local1 = 3
    local f25_local2 = 0
    if SpaceCheck(f25_arg0, f25_arg1, -135, 1) == true then
        if SpaceCheck(f25_arg0, f25_arg1, 135, 1) == true then
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
    f25_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f25_local1, 5202 + f25_local2, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0):TimingSetNumber(5, 0, AI_TIMING_SET__ACTIVATE)
    return 0
    
end

Goal.Act31 = function (f26_arg0, f26_arg1, f26_arg2)
    local f26_local0 = f26_arg0:GetDist(TARGET_ENE_0)
    local f26_local1 = f26_arg0:GetRandam_Int(1, 100)
    local f26_local2 = -1
    local f26_local3 = 0
    if SpaceCheck(f26_arg0, f26_arg1, -90, 5) == true then
        if SpaceCheck(f26_arg0, f26_arg1, 90, 5) == true then
            if f26_local1 <= 50 then
                f26_local3 = 0
            else
                f26_local3 = 1
            end
        else
            f26_local3 = 0
        end
    elseif SpaceCheck(f26_arg0, f26_arg1, 90, 1) == true then
        f26_local3 = 1
    else
    end
    local f26_local4 = 1.8
    local f26_local5 = f26_arg0:GetRandam_Int(30, 45)
    f26_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f26_local4, TARGET_ENE_0, f26_local3, f26_local5, false, true, f26_local2)
    f26_arg0:SetNumber(10, f26_local3)
    return 0
    
end

Goal.Act32 = function (f27_arg0, f27_arg1, f27_arg2)
    local f27_local0 = f27_arg0:GetDist(TARGET_ENE_0)
    local f27_local1 = 0
    local f27_local2 = 0
    local f27_local3 = f27_arg0:GetNumber(10)
    if f27_local0 <= 10 then
        if f27_local3 == 1 then
            f27_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3023, TARGET_ENE_0, 10 - f27_arg0:GetMapHitRadius(TARGET_SELF), f27_local2, f27_local1, 0, 0)
            f27_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3024, TARGET_ENE_0, 6.5 - f27_arg0:GetMapHitRadius(TARGET_SELF), f27_local2, f27_local1, 0, 0)
            f27_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3027, TARGET_ENE_0, 9999, f27_local2, f27_local1, 0, 0):TimingSetNumber(5, f27_arg0:GetNumber(5) + 6, AI_TIMING_SET__ACTIVATE)
        else
            f27_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3022, TARGET_ENE_0, 9999, f27_local2, f27_local1, 0, 0)
            f27_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3023, TARGET_ENE_0, 9999, f27_local2, f27_local1, 0, 0)
            f27_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3025, TARGET_ENE_0, 10.7 - f27_arg0:GetMapHitRadius(TARGET_SELF), f27_local2, f27_local1, 0, 0):TimingSetNumber(5, f27_arg0:GetNumber(5) + 3, AI_TIMING_SET__ACTIVATE)
            f27_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3003, TARGET_ENE_0, 9999, f27_local2, f27_local1, 0, 0):TimingSetNumber(5, f27_arg0:GetNumber(5) + 11, AI_TIMING_SET__ACTIVATE)
        end
    elseif f27_local3 == 1 then
        f27_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3021, TARGET_ENE_0, 9999, f27_local2, f27_local1, 0, 0)
        f27_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3020, TARGET_ENE_0, 9999, f27_local2, f27_local1, 0, 0)
        f27_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3021, TARGET_ENE_0, 9 - f27_arg0:GetMapHitRadius(TARGET_SELF), f27_local2, f27_local1, 0, 0)
        f27_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3015, TARGET_ENE_0, 9999, f27_local2, f27_local1, 0, 0):TimingSetNumber(5, f27_arg0:GetNumber(5) + 9, AI_TIMING_SET__ACTIVATE)
    else
        f27_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3020, TARGET_ENE_0, 9999, f27_local2, f27_local1, 0, 0)
        f27_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3021, TARGET_ENE_0, 9999, f27_local2, f27_local1, 0, 0)
        f27_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3025, TARGET_ENE_0, 10.7 - f27_arg0:GetMapHitRadius(TARGET_SELF), f27_local2, f27_local1, 0, 0):TimingSetNumber(5, f27_arg0:GetNumber(5) + 3, AI_TIMING_SET__ACTIVATE)
        f27_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3003, TARGET_ENE_0, 9999, f27_local2, f27_local1, 0, 0):TimingSetNumber(5, f27_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    end
    return 0
    
end

Goal.Act33 = function (f28_arg0, f28_arg1, f28_arg2)
    local f28_local0 = 0
    local f28_local1 = 0
    local f28_local2 = f28_arg0:GetNumber(10)
    f28_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3020, TARGET_ENE_0, 9999, f28_local1, f28_local0, 0, 0)
    f28_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3021, TARGET_ENE_0, 9999, f28_local1, f28_local0, 0, 0)
    f28_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3025, TARGET_ENE_0, 10.7 - f28_arg0:GetMapHitRadius(TARGET_SELF), f28_local1, f28_local0, 0, 0):TimingSetNumber(5, f28_arg0:GetNumber(5) + 3, AI_TIMING_SET__ACTIVATE)
    f28_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3003, TARGET_ENE_0, 9999, f28_local1, f28_local0, 0, 0):TimingSetNumber(5, f28_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    return 0
    
end

Goal.Act40 = function (f29_arg0, f29_arg1, f29_arg2)
    local f29_local0 = 4 - f29_arg0:GetMapHitRadius(TARGET_SELF)
    local f29_local1 = 4 - f29_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f29_local2 = 4 - f29_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f29_local3 = 100
    local f29_local4 = 0
    local f29_local5 = 6
    local f29_local6 = 10
    local f29_local7 = f29_arg0:GetDist(TARGET_ENE_0)
    Approach_Act_Flex(f29_arg0, f29_arg1, f29_local0, f29_local1, f29_local2, f29_local3, f29_local4, f29_local5, f29_local6)
    local f29_local8 = 0
    local f29_local9 = 0
    f29_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3040, TARGET_ENE_0, 9999, f29_local8, f29_local9, 0, 0)
    return 0
    
end

Goal.Act41 = function (f30_arg0, f30_arg1, f30_arg2)
    local f30_local0 = 3
    local f30_local1 = 0
    local f30_local2 = 4.5
    local f30_local3 = f30_arg0:GetRandam_Int(30, 45)
    if SpaceCheck(f30_arg0, f30_arg1, 180, 5) then
        f30_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f30_local0, 5201, TARGET_ENE_0, f30_local1, AI_DIR_TYPE_B, 0)
        f30_local2 = 3.5
    end
    local f30_local4 = 0
    if SpaceCheck(f30_arg0, f30_arg1, -90, 1) == true then
        if SpaceCheck(f30_arg0, f30_arg1, 90, 1) == true then
            if f30_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                f30_local4 = 0
            else
                f30_local4 = 1
            end
        else
            f30_local4 = 0
        end
    elseif SpaceCheck(f30_arg0, f30_arg1, 90, 1) == true then
        f30_local4 = 1
    else
    end
    f30_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f30_local2, TARGET_ENE_0, f30_local4, f30_local3, true, true, -1)
    return 0
    
end

Goal.Act49 = function (f31_arg0, f31_arg1, f31_arg2)
    local f31_local0 = 0
    local f31_local1 = 0
    if f31_arg0:GetNumber(2) == 0 then
        f31_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3035, TARGET_ENE_0, 9999, f31_local1, f31_local0, 0, 0)
        f31_arg0:SetNumber(2, 1)
    elseif f31_arg0:GetNumber(2) == 1 then
        f31_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3036, TARGET_ENE_0, 9999, f31_local1, f31_local0, 0, 0)
        f31_arg0:SetNumber(2, 2)
    else
        f31_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3038, TARGET_ENE_0, 9999, f31_local1, f31_local0, 0, 0)
        f31_arg0:SetNumber(2, 0)
    end
    return 0
    
end

Goal.Act50 = function (f32_arg0, f32_arg1, f32_arg2)
    local f32_local0 = 2.2
    local f32_local1 = 999
    local f32_local2 = 999
    local f32_local3 = 100
    local f32_local4 = 0
    local f32_local5 = 1.5
    local f32_local6 = 3
    Approach_Act_Flex(f32_arg0, f32_arg1, f32_local0, f32_local1, f32_local2, f32_local3, f32_local4, f32_local5, f32_local6)
    local f32_local7 = 0
    local f32_local8 = 0
    f32_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3041, TARGET_ENE_0, 9999, f32_local7, f32_local8, 0, 0)
    return 0
    
end

Goal.Interrupt = function (f33_arg0, f33_arg1, f33_arg2)
    local f33_local0 = f33_arg1:GetDist(TARGET_ENE_0)
    local f33_local1 = f33_arg1:GetRandam_Int(1, 100)
    local f33_local2 = f33_arg1:GetSpecialEffectActivateInterruptType(0)
    local f33_local3 = f33_arg1:GetSpRate(TARGET_SELF)
    if f33_arg1:IsLadderAct(TARGET_SELF) then
        return false
    end
    if not f33_arg1:HasSpecialEffectId(TARGET_SELF, 200004) then
        return false
    end
    if f33_arg1:IsInterupt(INTERUPT_ParryTiming) and f33_arg0.Parry(f33_arg1, f33_arg2, 50, 0) then
        return true
    end
    if f33_arg1:IsInterupt(INTERUPT_ShootImpact) and f33_arg0.ShootReaction(f33_arg1, f33_arg2) then
        return true
    end
    if Interupt_PC_Break(f33_arg1) and f33_local0 <= 8 then
        f33_arg1:Replanning()
        return true
    end
    if f33_arg1:IsInterupt(INTERUPT_Inside_ObserveArea) and f33_arg1:IsInsideObserve(0) and f33_arg1:GetTimer(1) <= 17.5 then
        f33_arg2:ClearSubGoal()
        f33_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 20006, TARGET_ENE_0, 9999, 0)
        f33_arg1:DeleteObserve(0)
        return true
    end
    if f33_arg1:IsInterupt(INTERUPT_ActivateSpecialEffect) then
        if f33_local2 == 3506080 then
            f33_arg1:SetTimer(1, 20)
            f33_arg1:AddObserveArea(0, TARGET_SELF, TARGET_ENE_0, AI_DIR_TYPE_F, 360, 2)
            f33_arg1:Replanning()
            return true
        elseif f33_local2 == 3506000 then
            if f33_arg1:HasSpecialEffectId(TARGET_SELF, 200051) then
                f33_arg2:ClearSubGoal()
                f33_arg2:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3030, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f33_arg1:GetNumber(5) + 25, AI_TIMING_SET__ACTIVATE)
                return true
            else
                f33_arg2:ClearSubGoal()
                f33_arg2:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3007, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f33_arg1:GetNumber(5) + 5, AI_TIMING_SET__ACTIVATE)
                return true
            end
        elseif f33_local2 == 3506082 then
            if f33_arg1:GetNumber(3) >= 5 then
                f33_arg2:ClearSubGoal()
                f33_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 20008, TARGET_ENE_0, 9999, 0)
                f33_arg1:DeleteObserve(0)
                return true
            else
                f33_arg1:SetNumber(3, f33_arg1:GetNumber(3) + 1)
                return false
            end
        end
    end
    if Interupt_Use_Item(f33_arg1, 4, 20) then
        if f33_local0 <= 5 then
            f33_arg1:Replanning()
            return true
        elseif f33_local0 <= 10.7 - f33_arg1:GetMapHitRadius(TARGET_SELF) - 1 then
            f33_arg2:ClearSubGoal()
            f33_arg2:AddSubGoal(GOAL_COMMON_Wait, 0.1, TARGET_SELF, 0, 0, 0)
            f33_arg2:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 1, 3003, TARGET_ENE_0, 9999, 0, 0, 0, 0)
            return true
        else
            f33_arg1:Replanning()
            return true
        end
    end
    if f33_arg1:IsInterupt(INTERUPT_InactivateSpecialEffect) then
        if f33_arg1:GetSpecialEffectInactivateInterruptType(0) == 110125 then
            f33_arg1:Replanning()
            return true
        elseif f33_arg1:GetSpecialEffectInactivateInterruptType(0) == 110010 then
            f33_arg1:Replanning()
            return true
        end
        return false
    end
    if f33_arg1:IsInterupt(INTERUPT_LoseSightTarget) and f33_arg1:IsActiveGoal(GOAL_COMMON_SidewayMove) then
        if f33_arg1:GetNumber(10) == 0 then
            f33_arg2:ClearSubGoal()
            f33_arg2:AddSubGoal(GOAL_COMMON_SidewayMove, 1, TARGET_ENE_0, 1, f33_arg1:GetRandam_Int(30, 45), true, true, -1):SetTargetRange(0, -99, 10)
            return true
        elseif f33_arg1:GetNumber(10) == 1 then
            f33_arg2:ClearSubGoal()
            f33_arg2:AddSubGoal(GOAL_COMMON_SidewayMove, 1, TARGET_ENE_0, 0, f33_arg1:GetRandam_Int(30, 45), true, true, -1):SetTargetRange(0, -99, 10)
            return true
        else
            f33_arg1:Replanning()
            return false
        end
    end
    if f33_arg1:IsInterupt(INTERUPT_TargetOutOfRange) and f33_arg1:IsTargetOutOfRangeInterruptSlot(0) then
        f33_arg1:Replanning()
        return false
    end
    return false
    
end

Goal.Parry = function (f34_arg0, f34_arg1, f34_arg2, f34_arg3)
    local f34_local0 = f34_arg0:GetDist(TARGET_ENE_0)
    local f34_local1 = GetDist_Parry(f34_arg0)
    local f34_local2 = f34_arg0:GetRandam_Int(1, 100)
    local f34_local3 = f34_arg0:GetRandam_Int(1, 100)
    local f34_local4 = f34_arg0:GetRandam_Int(1, 100)
    local f34_local5 = f34_arg0:HasSpecialEffectId(TARGET_ENE_0, 109970)
    local f34_local6 = f34_arg0:HasSpecialEffectId(TARGET_ENE_0, COMMON_SP_EFFECT_PC_ATTACK_RUSH)
    if f34_arg0:IsFinishTimer(AI_TIMER_PARRY_INTERVAL) == false then
        return false
    end
    if f34_arg0:HasSpecialEffectId(TARGET_ENE_0, 110450) or f34_arg0:HasSpecialEffectId(TARGET_ENE_0, 110501) or f34_arg0:HasSpecialEffectId(TARGET_ENE_0, 110500) then
        return false
    end
    f34_arg0:SetTimer(AI_TIMER_PARRY_INTERVAL, 0.1)
    if f34_arg2 == nil then
        f34_arg2 = 50
    end
    if f34_arg0:HasSpecialEffectId(TARGET_SELF, 3506080) then
        if f34_arg0:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_F, 360, f34_local1) then
            f34_arg1:ClearSubGoal()
            f34_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 20007, TARGET_ENE_0, 9999, 0)
            f34_arg0:DeleteObserve(0)
            return true
        end
    elseif f34_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) and f34_arg0:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_F, 90, f34_local1) then
        if f34_local6 then
            f34_arg1:ClearSubGoal()
            f34_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.3, 3103, TARGET_ENE_0, 9999, 0)
            return true
        elseif f34_local5 then
            if f34_arg0:HasSpecialEffectId(TARGET_SELF, 3506070) then
                f34_arg1:ClearSubGoal()
                f34_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3102, TARGET_ENE_0, 9999, 0)
                return true
            else
                f34_arg1:ClearSubGoal()
                f34_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3041, TARGET_ENE_0, 9999, 0)
                return true
            end
        elseif f34_arg0:HasSpecialEffectId(TARGET_ENE_0, 109980) then
            f34_arg1:ClearSubGoal()
            f34_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 1, 5201, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0)
            return true
        elseif f34_local3 <= Get_ConsecutiveGuardCount(f34_arg0) * f34_arg2 then
            f34_arg1:ClearSubGoal()
            f34_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3101, TARGET_ENE_0, 9999, 0)
            return true
        elseif f34_arg0:HasSpecialEffectId(TARGET_SELF, 3506070) then
            f34_arg1:ClearSubGoal()
            f34_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3102, TARGET_ENE_0, 9999, 0)
            return true
        else
            f34_arg1:ClearSubGoal()
            f34_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3100, TARGET_ENE_0, 9999, 0)
            return true
        end
    else
        return false
    end
    
end

Goal.ShootReaction = function (f35_arg0, f35_arg1)
    if f35_arg0:HasSpecialEffectId(TARGET_SELF, 3506080) then
        f35_arg1:ClearSubGoal()
        f35_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 20007, TARGET_ENE_0, 9999, 0)
        return true
    else
        f35_arg1:ClearSubGoal()
        f35_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3103, TARGET_ENE_0, 9999, 0):TimingSetTimer(2, 2, AI_TIMING_SET__ACTIVATE)
        return true
    end
    
end

Goal.Kengeki_Activate = function (f36_arg0, f36_arg1, f36_arg2, f36_arg3)
    local f36_local0 = ReturnKengekiSpecialEffect(f36_arg1)
    if f36_local0 == 0 then
        return false
    end
    local f36_local1 = {}
    local f36_local2 = {}
    local f36_local3 = {}
    Common_Clear_Param(f36_local1, f36_local2, f36_local3)
    local f36_local4 = f36_arg1:GetDist(TARGET_ENE_0)
    local f36_local5 = f36_arg1:GetSp(TARGET_SELF)
    if f36_local0 == 200226 then
        f36_local1[9] = 200
        f36_local1[10] = 100
    elseif f36_local0 == 200210 then
        if f36_local4 >= 4 then
            f36_local1[26] = 100
        else
            f36_local1[1] = 150
            f36_local1[12] = 300
        end
    elseif f36_local0 == 200211 then
        if f36_local4 >= 4 then
            f36_local1[26] = 100
        else
            f36_local1[2] = 150
            f36_local1[4] = 300
            f36_local1[8] = 800
            f36_local1[12] = 200
        end
    elseif f36_arg1:GetNumber(5) >= 25 - 3 then
        if f36_local4 >= 4 then
            f36_local1[26] = 100
        elseif f36_local0 == 200201 or f36_local0 == 200211 or f36_local0 == 200216 then
            f36_local1[8] = 300
            f36_local1[24] = 100
        else
            f36_local1[24] = 100
        end
    elseif f36_local0 == 200200 then
        if f36_local4 >= 4 then
            f36_local1[26] = 100
        elseif f36_arg1:GetNumber(5) >= 25 then
            f36_local1[1] = 200
            f36_local1[3] = 100
            f36_local1[26] = 100
        else
            f36_local1[1] = 100
            f36_local1[6] = 100
            f36_local1[3] = 100
            f36_local1[26] = 100
        end
    elseif f36_local0 == 200201 then
        if f36_local4 >= 4 then
            f36_local1[26] = 100
        else
            f36_local1[2] = 100
            f36_local1[7] = 100
            f36_local1[8] = 1500
            f36_local1[26] = 100
        end
    elseif f36_local0 == 200215 then
        if f36_local4 >= 4 then
            f36_local1[26] = 100
        elseif f36_arg1:GetNumber(5) >= 25 then
            f36_local1[1] = 200
            f36_local1[6] = 200
        else
            f36_local1[1] = 200
            f36_local1[6] = 200
        end
    elseif f36_local0 == 200216 then
        if f36_local4 >= 4 then
            f36_local1[26] = 100
        else
            f36_local1[2] = 100
            f36_local1[7] = 100
            f36_local1[8] = 1500
        end
    end
    if f36_arg1:HasSpecialEffectId(TARGET_SELF, 200051) == false then
        f36_local1[8] = 0
    end
    f36_local1[1] = SetCoolTime(f36_arg1, f36_arg2, 3061, 2, f36_local1[1], 1)
    f36_local1[2] = SetCoolTime(f36_arg1, f36_arg2, 3066, 2, f36_local1[2], 1)
    f36_local1[3] = SetCoolTime(f36_arg1, f36_arg2, 3064, 5, f36_local1[3], 1)
    f36_local1[3] = SetCoolTime(f36_arg1, f36_arg2, 3010, 5, f36_local1[3], 1)
    f36_local1[4] = SetCoolTime(f36_arg1, f36_arg2, 3068, 12, f36_local1[4], 1)
    f36_local1[5] = SetCoolTime(f36_arg1, f36_arg2, 3063, 5, f36_local1[5], 1)
    f36_local1[6] = SetCoolTime(f36_arg1, f36_arg2, 3060, 2, f36_local1[6], 1)
    f36_local1[7] = SetCoolTime(f36_arg1, f36_arg2, 3065, 2, f36_local1[7], 1)
    f36_local1[8] = SetCoolTime(f36_arg1, f36_arg2, 3069, 25, f36_local1[8], 1)
    f36_local1[12] = SetCoolTime(f36_arg1, f36_arg2, 3030, 12, f36_local1[12], 1)
    f36_local1[12] = SetCoolTime(f36_arg1, f36_arg2, 3007, 12, f36_local1[12], 1)
    f36_local1[12] = SetCoolTime(f36_arg1, f36_arg2, 3005, 4, f36_local1[12], 1)
    f36_local2[1] = REGIST_FUNC(f36_arg1, f36_arg2, f36_arg0.Kengeki01)
    f36_local2[2] = REGIST_FUNC(f36_arg1, f36_arg2, f36_arg0.Kengeki02)
    f36_local2[3] = REGIST_FUNC(f36_arg1, f36_arg2, f36_arg0.Kengeki03)
    f36_local2[4] = REGIST_FUNC(f36_arg1, f36_arg2, f36_arg0.Kengeki04)
    f36_local2[5] = REGIST_FUNC(f36_arg1, f36_arg2, f36_arg0.Kengeki05)
    f36_local2[6] = REGIST_FUNC(f36_arg1, f36_arg2, f36_arg0.Kengeki06)
    f36_local2[7] = REGIST_FUNC(f36_arg1, f36_arg2, f36_arg0.Kengeki07)
    f36_local2[8] = REGIST_FUNC(f36_arg1, f36_arg2, f36_arg0.Kengeki08)
    f36_local2[9] = REGIST_FUNC(f36_arg1, f36_arg2, f36_arg0.Kengeki09)
    f36_local2[10] = REGIST_FUNC(f36_arg1, f36_arg2, f36_arg0.Kengeki10)
    f36_local2[11] = REGIST_FUNC(f36_arg1, f36_arg2, f36_arg0.Kengeki11)
    f36_local2[12] = REGIST_FUNC(f36_arg1, f36_arg2, f36_arg0.Kengeki12)
    f36_local2[21] = REGIST_FUNC(f36_arg1, f36_arg2, f36_arg0.Act21)
    f36_local2[22] = REGIST_FUNC(f36_arg1, f36_arg2, f36_arg0.Act22)
    f36_local2[23] = REGIST_FUNC(f36_arg1, f36_arg2, f36_arg0.Act23)
    f36_local2[24] = REGIST_FUNC(f36_arg1, f36_arg2, f36_arg0.Act24)
    f36_local2[25] = REGIST_FUNC(f36_arg1, f36_arg2, f36_arg0.Act25)
    f36_local2[26] = REGIST_FUNC(f36_arg1, f36_arg2, f36_arg0.NoAction)
    f36_local2[30] = REGIST_FUNC(f36_arg1, f36_arg2, f36_arg0.Kengeki30)
    local f36_local6 = REGIST_FUNC(f36_arg1, f36_arg2, f36_arg0.ActAfter_AdjustSpace)
    return Common_Kengeki_Activate(f36_arg1, f36_arg2, f36_local1, f36_local2, f36_local6, f36_local3)
    
end

Goal.Kengeki01 = function (f37_arg0, f37_arg1, f37_arg2)
    f37_arg1:ClearSubGoal()
    f37_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3061, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f37_arg0:GetNumber(5) + 6, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki02 = function (f38_arg0, f38_arg1, f38_arg2)
    f38_arg1:ClearSubGoal()
    f38_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3066, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f38_arg0:GetNumber(5) + 6, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki03 = function (f39_arg0, f39_arg1, f39_arg2)
    f39_arg1:ClearSubGoal()
    f39_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3064, TARGET_ENE_0, 11 - f39_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, 0, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki04 = function (f40_arg0, f40_arg1, f40_arg2)
    f40_arg1:ClearSubGoal()
    f40_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3068, TARGET_ENE_0, 6 - f40_arg0:GetMapHitRadius(TARGET_SELF), 0):TimingSetNumber(5, 0, AI_TIMING_SET__ACTIVATE)
    f40_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3017, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f40_arg0:GetNumber(5) + 25, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki05 = function (f41_arg0, f41_arg1, f41_arg2)
    f41_arg1:ClearSubGoal()
    f41_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3063, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f41_arg0:GetNumber(5) + 8, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki06 = function (f42_arg0, f42_arg1, f42_arg2)
    f42_arg1:ClearSubGoal()
    f42_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3060, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f42_arg0:GetNumber(5) + 6, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki07 = function (f43_arg0, f43_arg1, f43_arg2)
    f43_arg1:ClearSubGoal()
    f43_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3065, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f43_arg0:GetNumber(5) + 6, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki08 = function (f44_arg0, f44_arg1, f44_arg2)
    f44_arg1:ClearSubGoal()
    f44_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3069, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f44_arg0:GetNumber(5) + 6, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki09 = function (f45_arg0, f45_arg1, f45_arg2)
    f45_arg1:ClearSubGoal()
    f45_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3090, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f45_arg0:GetNumber(5) + 6, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki10 = function (f46_arg0, f46_arg1, f46_arg2)
    f46_arg1:ClearSubGoal()
    f46_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3091, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f46_arg0:GetNumber(5) + 6, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki11 = function (f47_arg0, f47_arg1, f47_arg2)
    f47_arg1:ClearSubGoal()
    f47_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3026, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f47_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki12 = function (f48_arg0, f48_arg1, f48_arg2)
    f48_arg1:ClearSubGoal()
    f48_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3005, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f48_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki30 = function (f49_arg0, f49_arg1, f49_arg2)
    local f49_local0 = f49_arg0:GetDist(TARGET_ENE_0)
    local f49_local1 = 3
    local f49_local2 = 0
    if SpaceCheck(f49_arg0, f49_arg1, -135, 1) == true then
        if SpaceCheck(f49_arg0, f49_arg1, 135, 1) == true then
            if f49_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                f49_local2 = 0
            else
                f49_local2 = 1
            end
        else
            f49_local2 = 0
        end
    elseif SpaceCheck(f49_arg0, f49_arg1, 90, 1) == true then
        f49_local2 = 1
    else
    end
    f49_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f49_local1, 5202 + f49_local2, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0):TimingSetNumber(5, 0, AI_TIMING_SET__ACTIVATE)
    
end

Goal.NoAction = function (f50_arg0, f50_arg1, f50_arg2)
    return -1
    
end

Goal.ActAfter_AdjustSpace = function (f51_arg0, f51_arg1, f51_arg2)
    
end

Goal.Update = function (f52_arg0, f52_arg1, f52_arg2)
    return Update_Default_NoSubGoal(f52_arg0, f52_arg1, f52_arg2)
    
end

Goal.Terminate = function (f53_arg0, f53_arg1, f53_arg2)
    
end


