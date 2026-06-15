RegisterTableGoal(GOAL_Fukuro_506300_Battle, "GOAL_Fukuro_506300_Battle")
REGISTER_GOAL_NO_UPDATE(GOAL_Fukuro_506300_Battle, true)

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
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 3507000)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 3507001)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 3507002)
    local f2_local5 = f2_arg1:GetEventRequest()
    local f2_local6 = f2_arg1:GetEventRequest(1)
    if f2_local6 == 20 then
        f2_local0[20] = 100
    elseif f2_local5 == 10 then
        if f2_arg1:GetNumber(15) == 1 then
            f2_local0[11] = 100
        elseif f2_local3 >= 12 then
            f2_local0[5] = 50
            f2_local0[7] = 0
            f2_local0[8] = 100
            f2_local0[9] = 100
            f2_local0[12] = 0
        elseif f2_local3 >= 8 then
            f2_local0[5] = 100
            f2_local0[7] = 0
            f2_local0[8] = 100
            f2_local0[9] = 100
            f2_local0[12] = 200
        elseif f2_local3 >= 4 then
            f2_local0[5] = 50
            f2_local0[7] = 100
            f2_local0[8] = 0
            f2_local0[9] = 0
            f2_local0[12] = 200
        else
            f2_local0[5] = 50
            f2_local0[7] = 100
            f2_local0[8] = 0
            f2_local0[9] = 0
            f2_local0[12] = 0
        end
    elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 3507010) then
        f2_local0[10] = 500
    else
        f2_local0[10] = 100
        f2_local0[31] = 100
    end
    f2_local0[1] = SetCoolTime(f2_arg1, f2_arg2, 3000, 10, f2_local0[1], 1)
    f2_local0[2] = SetCoolTime(f2_arg1, f2_arg2, 3001, 10, f2_local0[2], 1)
    f2_local0[3] = SetCoolTime(f2_arg1, f2_arg2, 3002, 10, f2_local0[3], 1)
    f2_local0[4] = SetCoolTime(f2_arg1, f2_arg2, 3004, 10, f2_local0[4], 1)
    f2_local0[5] = SetCoolTime(f2_arg1, f2_arg2, 3009, 10, f2_local0[5], 1)
    f2_local0[6] = SetCoolTime(f2_arg1, f2_arg2, 3005, 10, f2_local0[6], 1)
    f2_local0[7] = SetCoolTime(f2_arg1, f2_arg2, 3003, 10, f2_local0[7], 1)
    f2_local0[8] = SetCoolTime(f2_arg1, f2_arg2, 3006, 10, f2_local0[8], 1)
    f2_local0[9] = SetCoolTime(f2_arg1, f2_arg2, 3007, 10, f2_local0[9], 1)
    f2_local0[11] = SetCoolTime(f2_arg1, f2_arg2, 3020, 10, f2_local0[11], 1)
    f2_local0[12] = SetCoolTime(f2_arg1, f2_arg2, 3021, 10, f2_local0[12], 1)
    f2_local0[13] = SetCoolTime(f2_arg1, f2_arg2, 3022, 10, f2_local0[13], 1)
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
    f2_local1[20] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act20)
    f2_local1[21] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act21)
    f2_local1[26] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act26)
    f2_local1[31] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act31)
    local f2_local7 = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.ActAfter_AdjustSpace)
    Common_Battle_Activate(f2_arg1, f2_arg2, f2_local0, f2_local1, f2_local7, f2_local2)
    
end

Goal.Act01 = function (f3_arg0, f3_arg1, f3_arg2)
    local f3_local0 = 0
    local f3_local1 = 0
    f3_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3000, TARGET_ENE_0, 9999, f3_local0, f3_local1, 0, 0)
    return 0
    
end

Goal.Act02 = function (f4_arg0, f4_arg1, f4_arg2)
    local f4_local0 = 0
    local f4_local1 = 0
    f4_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3001, TARGET_ENE_0, 9999, f4_local0, f4_local1, 0, 0):SetFailedEndOption(AI_GOAL_FAILED_END_OPT__PARENT_NEXT_SUB_GOAL)
    f4_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3040, TARGET_ENE_0, 9999, f4_local0, f4_local1, 0, 0)
    return 0
    
end

Goal.Act03 = function (f5_arg0, f5_arg1, f5_arg2)
    local f5_local0 = 0
    local f5_local1 = 0
    f5_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3002, TARGET_ENE_0, 9999, f5_local0, f5_local1, 0, 0):SetFailedEndOption(AI_GOAL_FAILED_END_OPT__PARENT_NEXT_SUB_GOAL)
    f5_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3040, TARGET_ENE_0, 9999, f5_local0, f5_local1, 0, 0)
    return 0
    
end

Goal.Act04 = function (f6_arg0, f6_arg1, f6_arg2)
    local f6_local0 = 0
    local f6_local1 = 0
    f6_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3004, TARGET_ENE_0, 9999, f6_local0, f6_local1, 0, 0):SetFailedEndOption(AI_GOAL_FAILED_END_OPT__PARENT_NEXT_SUB_GOAL)
    f6_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3040, TARGET_ENE_0, 9999, f6_local0, f6_local1, 0, 0)
    return 0
    
end

Goal.Act05 = function (f7_arg0, f7_arg1, f7_arg2)
    local f7_local0 = 0
    local f7_local1 = 0
    if f7_arg0:GetNumber(1) == 1 then
        if f7_arg0:GetNumber(0) == 1 then
            f7_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3011, TARGET_ENE_0, 9999, f7_local0, f7_local1, 0, 0):TimingSetNumber(0, 0, AI_TIMING_SET__ACTIVATE)
        else
            f7_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3010, TARGET_ENE_0, 9999, f7_local0, f7_local1, 0, 0):TimingSetNumber(0, 0, AI_TIMING_SET__ACTIVATE)
        end
    end
    f7_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3009, TARGET_ENE_0, 9999, f7_local0, f7_local1, 0, 0):SetFailedEndOption(AI_GOAL_FAILED_END_OPT__PARENT_NEXT_SUB_GOAL):TimingSetNumber(1, 1, AI_TIMING_SET__ACTIVATE)
    f7_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3040, TARGET_ENE_0, 9999, f7_local0, f7_local1, 0, 0)
    return 0
    
end

Goal.Act06 = function (f8_arg0, f8_arg1, f8_arg2)
    local f8_local0 = 0
    local f8_local1 = 0
    f8_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3005, TARGET_ENE_0, 9999, f8_local0, f8_local1, 0, 0):SetFailedEndOption(AI_GOAL_FAILED_END_OPT__PARENT_NEXT_SUB_GOAL)
    f8_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3040, TARGET_ENE_0, 9999, f8_local0, f8_local1, 0, 0)
    return 0
    
end

Goal.Act07 = function (f9_arg0, f9_arg1, f9_arg2)
    local f9_local0 = 0
    local f9_local1 = 0
    if f9_arg0:GetNumber(1) == 1 then
        if f9_arg0:GetNumber(0) == 1 then
            f9_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3011, TARGET_ENE_0, 9999, f9_local0, f9_local1, 0, 0):TimingSetNumber(0, 0, AI_TIMING_SET__ACTIVATE)
        else
            f9_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3010, TARGET_ENE_0, 9999, f9_local0, f9_local1, 0, 0):TimingSetNumber(0, 0, AI_TIMING_SET__ACTIVATE)
        end
    end
    f9_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3003, TARGET_ENE_0, 9999, f9_local0, f9_local1, 0, 0):TimingSetNumber(1, 1, AI_TIMING_SET__ACTIVATE)
    return 0
    
end

Goal.Act08 = function (f10_arg0, f10_arg1, f10_arg2)
    local f10_local0 = 0
    local f10_local1 = 0
    if f10_arg0:GetNumber(1) == 1 then
        if f10_arg0:GetNumber(0) == 1 then
            f10_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3011, TARGET_ENE_0, 9999, f10_local0, f10_local1, 0, 0):TimingSetNumber(0, 0, AI_TIMING_SET__ACTIVATE)
        else
            f10_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3010, TARGET_ENE_0, 9999, f10_local0, f10_local1, 0, 0):TimingSetNumber(0, 0, AI_TIMING_SET__ACTIVATE)
        end
    end
    f10_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3006, TARGET_ENE_0, 9999, f10_local0, f10_local1, 0, 0):SetFailedEndOption(AI_GOAL_FAILED_END_OPT__PARENT_NEXT_SUB_GOAL):TimingSetNumber(1, 1, AI_TIMING_SET__ACTIVATE)
    f10_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3040, TARGET_ENE_0, 9999, f10_local0, f10_local1, 0, 0)
    return 0
    
end

Goal.Act09 = function (f11_arg0, f11_arg1, f11_arg2)
    local f11_local0 = 0
    local f11_local1 = 0
    if f11_arg0:GetNumber(1) == 1 then
        if f11_arg0:GetNumber(0) == 1 then
            f11_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3011, TARGET_ENE_0, 9999, f11_local0, f11_local1, 0, 0):TimingSetNumber(0, 0, AI_TIMING_SET__ACTIVATE)
        else
            f11_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3010, TARGET_ENE_0, 9999, f11_local0, f11_local1, 0, 0):TimingSetNumber(0, 0, AI_TIMING_SET__ACTIVATE)
        end
    end
    f11_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3007, TARGET_ENE_0, 9999, f11_local0, f11_local1, 0, 0):SetFailedEndOption(AI_GOAL_FAILED_END_OPT__PARENT_NEXT_SUB_GOAL):TimingSetNumber(1, 1, AI_TIMING_SET__ACTIVATE)
    f11_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3040, TARGET_ENE_0, 9999, f11_local0, f11_local1, 0, 0)
    return 0
    
end

Goal.Act10 = function (f12_arg0, f12_arg1, f12_arg2)
    local f12_local0 = f12_arg0:GetRandam_Float(1, 2)
    local f12_local1 = f12_arg0:GetNumber(0)
    if f12_arg0:HasSpecialEffectId(TARGET_SELF, 3507010) then
        f12_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3040, TARGET_ENE_0, 9999, turnTime, frontAngle, 0, 0)
        f12_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, 0.1, TARGET_SELF, 2, TARGET_SELF, false, -1, AI_DIR_TYPE_F, 5)
        f12_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f12_local0, TARGET_ENE_0, 1, TARGET_SELF, false, -1, AI_DIR_TYPE_ToL, 20):TimingSetNumber(0, 2, AI_TIMING_SET__ACTIVATE)
    elseif f12_local1 == 1 then
        f12_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, 0.1, TARGET_SELF, 2, TARGET_SELF, true, -1, AI_DIR_TYPE_F, 5)
        f12_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f12_local0, TARGET_ENE_0, 1, TARGET_SELF, true, -1, AI_DIR_TYPE_ToR, 20):TimingSetNumber(0, 1, AI_TIMING_SET__ACTIVATE)
    elseif f12_local1 == 2 then
        f12_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, 0.1, TARGET_SELF, 2, TARGET_SELF, false, -1, AI_DIR_TYPE_F, 5)
        f12_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f12_local0, TARGET_ENE_0, 1, TARGET_SELF, false, -1, AI_DIR_TYPE_ToL, 20):TimingSetNumber(0, 2, AI_TIMING_SET__ACTIVATE)
    else
        f12_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, 0.1, TARGET_SELF, 2, TARGET_SELF, false, -1, AI_DIR_TYPE_F, 5)
        f12_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3046, TARGET_ENE_0, 9999, turnTime, frontAngle, 0, 0)
        f12_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f12_local0, TARGET_ENE_0, 1, TARGET_SELF, false, -1, AI_DIR_TYPE_ToL, 20):TimingSetNumber(0, 2, AI_TIMING_SET__ACTIVATE)
    end
    return 0
    
end

Goal.Act11 = function (f13_arg0, f13_arg1, f13_arg2)
    local f13_local0 = 0
    local f13_local1 = 0
    f13_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3020, TARGET_ENE_0, 9999, f13_local0, f13_local1, 0, 0):SetFailedEndOption(AI_GOAL_FAILED_END_OPT__PARENT_NEXT_SUB_GOAL)
    f13_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3040, TARGET_ENE_0, 9999, f13_local0, f13_local1, 0, 0)
    return 0
    
end

Goal.Act12 = function (f14_arg0, f14_arg1, f14_arg2)
    local f14_local0 = 0
    local f14_local1 = 0
    if f14_arg0:GetNumber(1) == 1 then
        if f14_arg0:GetNumber(0) == 1 then
            f14_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3011, TARGET_ENE_0, 9999, f14_local0, f14_local1, 0, 0):TimingSetNumber(0, 0, AI_TIMING_SET__ACTIVATE)
        else
            f14_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3010, TARGET_ENE_0, 9999, f14_local0, f14_local1, 0, 0):TimingSetNumber(0, 0, AI_TIMING_SET__ACTIVATE)
        end
    end
    f14_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3021, TARGET_ENE_0, 9999, f14_local0, f14_local1, 0, 0):SetFailedEndOption(AI_GOAL_FAILED_END_OPT__PARENT_NEXT_SUB_GOAL):TimingSetNumber(1, 1, AI_TIMING_SET__ACTIVATE)
    f14_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3040, TARGET_ENE_0, 9999, f14_local0, f14_local1, 0, 0)
    return 0
    
end

Goal.Act13 = function (f15_arg0, f15_arg1, f15_arg2)
    local f15_local0 = 0
    local f15_local1 = 0
    f15_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3022, TARGET_ENE_0, 9999, f15_local0, f15_local1, 0, 0):SetFailedEndOption(AI_GOAL_FAILED_END_OPT__PARENT_NEXT_SUB_GOAL)
    f15_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3040, TARGET_ENE_0, 9999, f15_local0, f15_local1, 0, 0)
    return 0
    
end

Goal.Act14 = function (f16_arg0, f16_arg1, f16_arg2)
    local f16_local0 = 0
    local f16_local1 = 0
    f16_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3024, TARGET_ENE_0, 9999, f16_local0, f16_local1, 0, 0):SetFailedEndOption(AI_GOAL_FAILED_END_OPT__PARENT_NEXT_SUB_GOAL)
    f16_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3040, TARGET_ENE_0, 9999, f16_local0, f16_local1, 0, 0)
    return 0
    
end

Goal.Act15 = function (f17_arg0, f17_arg1, f17_arg2)
    local f17_local0 = 0
    local f17_local1 = 0
    local f17_local2 = f17_arg0:GetNumber(0)
    if f17_local2 == 2 then
        f17_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3044, TARGET_ENE_0, 9999, f17_local0, f17_local1, 0, 0)
    elseif f17_local2 == 0 then
        f17_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3045, TARGET_ENE_0, 9999, f17_local0, f17_local1, 0, 0)
    end
    f17_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3047, TARGET_ENE_0, 9999, f17_local0, f17_local1, 0, 0):TimingSetNumber(0, 1, AI_TIMING_SET__ACTIVATE)
    return 0
    
end

Goal.Act16 = function (f18_arg0, f18_arg1, f18_arg2)
    local f18_local0 = 0
    local f18_local1 = 0
    local f18_local2 = f18_arg0:GetNumber(0)
    if f18_local2 == 1 then
        f18_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3043, TARGET_ENE_0, 9999, f18_local0, f18_local1, 0, 0)
    elseif f18_local2 == 0 then
        f18_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3046, TARGET_ENE_0, 9999, f18_local0, f18_local1, 0, 0)
    end
    f18_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3048, TARGET_ENE_0, 9999, f18_local0, f18_local1, 0, 0):TimingSetNumber(0, 2, AI_TIMING_SET__ACTIVATE)
    return 0
    
end

Goal.Act20 = function (f19_arg0, f19_arg1, f19_arg2)
    local f19_local0 = f19_arg0:GetRandam_Int(1, 100)
    f19_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 20000, TARGET_ENE_0, 9999, 0, 0, 0, 0)
    if f19_arg0:GetNumber(9) == 0 then
        f19_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3012, TARGET_ENE_0, 9999, 0, 0, 0, 0):TimingSetNumber(9, 1, AI_TIMING_SET__ACTIVATE)
    elseif f19_local0 <= 50 then
        f19_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3004, TARGET_ENE_0, 9999, 0, 0, 0, 0)
    else
        f19_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3012, TARGET_ENE_0, 9999, 0, 0, 0, 0)
    end
    return 0
    
end

Goal.Act21 = function (f20_arg0, f20_arg1, f20_arg2)
    f20_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 20000, TARGET_ENE_0, 9999, 0, 0, 0, 0)
    f20_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3012, TARGET_ENE_0, 9999, 0, 0, 0, 0):TimingSetNumber(9, 1, AI_TIMING_SET__ACTIVATE)
    return 0
    
end

Goal.Act26 = function (f21_arg0, f21_arg1, f21_arg2)
    f21_arg1:AddSubGoal(GOAL_COMMON_Wait, 0.5, TARGET_SELF, 0, 0, 0)
    return 0
    
end

Goal.Act31 = function (f22_arg0, f22_arg1, f22_arg2)
    local f22_local0 = 0
    local f22_local1 = 0
    local f22_local2 = f22_arg0:GetNumber(0)
    local f22_local3 = 7.5
    if f22_local2 == 1 then
        f22_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 3, TARGET_ENE_0, f22_local3, TARGET_SELF, true, -1)
        f22_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3043, TARGET_ENE_0, 9999, f22_local0, f22_local1, 0, 0):SetFailedEndOption(AI_GOAL_FAILED_END_OPT__PARENT_NEXT_SUB_GOAL)
        f22_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, 0.5, TARGET_SELF, 2, TARGET_SELF, false, -1, AI_DIR_TYPE_F, 10)
        f22_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, 1, TARGET_ENE_0, 1, TARGET_SELF, false, -1, AI_DIR_TYPE_ToL, 20)
        f22_arg0:SetNumber(0, 2)
    elseif f22_local2 == 2 then
        f22_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 3, TARGET_ENE_0, f22_local3, TARGET_SELF, false, -1)
        f22_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3044, TARGET_ENE_0, 9999, f22_local0, f22_local1, 0, 0):SetFailedEndOption(AI_GOAL_FAILED_END_OPT__PARENT_NEXT_SUB_GOAL)
        f22_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, 0.5, TARGET_SELF, 2, TARGET_SELF, true, -1, AI_DIR_TYPE_F, 10)
        f22_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, 1, TARGET_ENE_0, 1, TARGET_SELF, true, -1, AI_DIR_TYPE_ToR, 20)
        f22_arg0:SetNumber(0, 1)
    else
        f22_arg1:AddSubGoal(GOAL_COMMON_Wait, 0.5, TARGET_SELF, 0, 0, 0)
    end
    return 0
    
end

Goal.Interrupt = function (f23_arg0, f23_arg1, f23_arg2)
    local f23_local0 = f23_arg1:GetSpecialEffectActivateInterruptType(0)
    if f23_arg1:IsLadderAct(TARGET_SELF) then
        return false
    end
    if not f23_arg1:HasSpecialEffectId(TARGET_SELF, 200004) then
        return false
    end
    if f23_arg1:IsInterupt(INTERUPT_EventRequest) then
        local f23_local1 = f23_arg1:GetEventRequest()
        if f23_local1 == 10 or f23_local1 == 20 then
            f23_arg1:Replanning()
            return true
        end
    end
    if f23_arg1:IsInterupt(INTERUPT_ActivateSpecialEffect) then
        local f23_local1 = f23_arg1:GetRandam_Int(1, 100)
        local f23_local2 = f23_arg1:GetDist(TARGET_ENE_0)
        if f23_local0 == 3507002 then
            f23_arg1:SetEventFlag(11005933, true)
            return false
        elseif f23_local0 == 3507000 then
            if f23_local1 <= 50 then
                f23_arg1:SetEventFlag(11005933, true)
            end
            return false
        elseif f23_local0 == 3507001 then
            if f23_local2 <= 15 and f23_local1 <= 50 then
                f23_arg1:SetEventFlag(11005933, true)
            end
            return false
        end
    end
    return false
    
end

Goal.ActAfter_AdjustSpace = function (f24_arg0, f24_arg1, f24_arg2)
    
end

Goal.Update = function (f25_arg0, f25_arg1, f25_arg2)
    return Update_Default_NoSubGoal(f25_arg0, f25_arg1, f25_arg2)
    
end

Goal.Terminate = function (f26_arg0, f26_arg1, f26_arg2)
    
end


