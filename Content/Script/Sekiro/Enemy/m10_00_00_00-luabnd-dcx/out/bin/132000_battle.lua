RegisterTableGoal(GOAL_Takaragoi_132000_Battle, "GOAL_Takaragoi_132000_Battle")
REGISTER_GOAL_NO_UPDATE(GOAL_Takaragoi_132000_Battle, true)

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
    local f2_local5 = f2_arg1:GetEventRequest()
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 3132010)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 3132011)
    if f2_local5 == 30 then
        f2_local0[30] = 100
    elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 200030) then
        if f2_arg1:IsFinishTimer(9) == true and f2_arg1:GetNumber(9) == 1 then
            f2_local0[20] = 100
        elseif f2_local3 >= 40 then
            f2_local0[20] = 100
        else
            f2_local0[12] = 100
        end
    elseif f2_arg1:IsFinishTimer(9) == true and f2_arg1:GetNumber(9) == 1 then
        f2_local0[20] = 100
    else
        f2_local0[12] = 100
    end
    f2_local1[1] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act01)
    f2_local1[2] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act02)
    f2_local1[3] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act03)
    f2_local1[4] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act04)
    f2_local1[10] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act10)
    f2_local1[11] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act11)
    f2_local1[12] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act12)
    f2_local1[20] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act20)
    f2_local1[26] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act26)
    f2_local1[30] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act30)
    local f2_local6 = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.ActAfter_AdjustSpace)
    Common_Battle_Activate(f2_arg1, f2_arg2, f2_local0, f2_local1, f2_local6, f2_local2)
    
end

Goal.Act01 = function (f3_arg0, f3_arg1, f3_arg2)
    local f3_local0 = f3_arg0:GetRandam_Float(2, 4)
    local f3_local1 = f3_arg0:GetRandam_Float(5, 7)
    local f3_local2 = f3_arg0:GetDist(TARGET_ENE_0)
    local f3_local3 = 9920
    local f3_local4 = false
    local f3_local5 = f3_arg0:GetRandam_Float(2, 6)
    local f3_local6 = f3_arg0:GetRandam_Int(1, 100)
    local f3_local7 = f3_arg0:GetRandam_Float(0.5, 2)
    if f3_local6 <= 50 then
        f3_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, 5, TARGET_ENE_0, 3.5, TARGET_SELF, false, 9920, AI_DIR_TYPE_ToL, 100)
    elseif f3_local6 <= 100 then
        f3_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, 5, TARGET_ENE_0, 3.5, TARGET_SELF, false, 9920, AI_DIR_TYPE_ToR, 100)
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act02 = function (f4_arg0, f4_arg1, f4_arg2)
    local f4_local0 = f4_arg0:GetRandam_Float(2, 4)
    local f4_local1 = f4_arg0:GetRandam_Float(5, 7)
    local f4_local2 = f4_arg0:GetDist(TARGET_ENE_0)
    local f4_local3 = 9920
    local f4_local4 = -1
    local f4_local5 = 6
    if f4_local2 >= 50 then
        f4_local4 = true
    end
    f4_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3001, TARGET_ENE_0, 9999, 0, 0, 0, 0)
    f4_arg0:SetNumber(1, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act03 = function (f5_arg0, f5_arg1, f5_arg2)
    local f5_local0 = f5_arg0:GetDist(TARGET_ENE_0)
    local f5_local1 = 9999
    local f5_local2 = 0
    local f5_local3 = 0
    local f5_local4 = f5_arg0:GetRandam_Int(1, 100)
    local f5_local5 = f5_arg0:GetRandam_Float(0.5, 2)
    local f5_local6 = f5_arg0:GetRandam_Float(20, 45) + 100 - f5_local0 * 2
    local f5_local7 = AI_DIR_TYPE_R
    local f5_local8 = AI_DIR_TYPE_ToR
    local f5_local9 = TARGET_SELF
    if f5_local4 <= 50 then
        f5_local7 = AI_DIR_TYPE_L
        f5_local8 = AI_DIR_TYPE_ToL
    end
    if f5_local4 <= 50 then
        f5_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, 0.5, TARGET_ENE_0, 3.5, TARGET_SELF, false, -1, f5_local8, 5, true)
    else
        f5_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, 1, TARGET_ENE_0, 3.5, TARGET_SELF, false, -1, f5_local7, 5, true)
    end
    f5_arg0:SetNumber(1, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act04 = function (f6_arg0, f6_arg1, f6_arg2)
    local f6_local0 = f6_arg0:GetDist(TARGET_ENE_0)
    local f6_local1 = 9999
    local f6_local2 = 0
    local f6_local3 = 0
    local f6_local4 = f6_arg0:GetRandam_Int(1, 100)
    local f6_local5 = f6_arg0:GetRandam_Float(0.5, 2)
    local f6_local6 = f6_arg0:GetRandam_Float(20, 45) + 50 - f6_local0 * 2
    local f6_local7 = AI_DIR_TYPE_L
    local f6_local8 = AI_DIR_TYPE_R
    local f6_local9 = AI_DIR_TYPE_F
    local f6_local10 = TARGET_SELF
    if f6_arg0:GetNumber(1) >= 1 then
        f6_local7 = AI_DIR_TYPE_ToL
        f6_local8 = AI_DIR_TYPE_ToR
        f6_local9 = AI_DIR_TYPE_ToF
        f6_local10 = TARGET_ENE_0
    end
    if f6_local4 <= 30 then
        f6_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f6_local5, f6_local10, 3.5, TARGET_SELF, false, 9920, f6_local7, 10, true)
    elseif f6_local4 <= 60 then
        f6_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f6_local5, f6_local10, 3.5, TARGET_SELF, false, 9920, f6_local8, 13, true)
    else
        f6_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f6_local5, f6_local10, 3.5, TARGET_SELF, false, 9920, f6_local9, 5, true)
    end
    f6_arg0:SetNumber(1, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act10 = function (f7_arg0, f7_arg1, f7_arg2)
    local f7_local0 = f7_arg0:GetDist(TARGET_ENE_0)
    local f7_local1 = 9999
    local f7_local2 = 0
    local f7_local3 = 0
    local f7_local4 = f7_arg0:GetRandam_Int(1, 100)
    local f7_local5 = 0.5
    local f7_local6 = f7_arg0:GetRandam_Float(2, 5)
    local f7_local7 = AI_DIR_TYPE_L
    local f7_local8 = AI_DIR_TYPE_R
    local f7_local9 = AI_DIR_TYPE_F
    local f7_local10 = TARGET_SELF
    if f7_arg0:GetNumber(1) >= 1 then
        f7_local7 = AI_DIR_TYPE_ToL
        f7_local8 = AI_DIR_TYPE_ToR
        f7_local9 = AI_DIR_TYPE_ToB
        f7_local10 = TARGET_ENE_0
    end
    if f7_local4 <= 30 then
        f7_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f7_local5, TARGET_ENE_0, 3.5, TARGET_SELF, false, 9920, f7_local7, f7_local6, true)
    elseif f7_local4 <= 60 then
        f7_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f7_local5, TARGET_ENE_0, 3.5, TARGET_SELF, false, 9920, f7_local8, f7_local6, true)
    else
        f7_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f7_local5, TARGET_ENE_0, 3.5, TARGET_SELF, false, 9920, f7_local9, f7_local6, true)
    end
    f7_arg0:SetNumber(1, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act11 = function (f8_arg0, f8_arg1, f8_arg2)
    local f8_local0 = 0.8
    local f8_local1 = 2
    local f8_local2 = f8_arg0:GetDist(TARGET_ENE_0)
    local f8_local3 = f8_arg0:GetRandam_Int(1, 100)
    local f8_local4 = f8_arg0:GetNumber(3)
    local f8_local5 = f8_arg0:GetNumber(4)
    local f8_local6 = f8_arg0:GetNumber(5)
    if f8_arg0:HasSpecialEffectId(TARGET_SELF, 200000) then
        f8_local0 = f8_local0 + 1
        f8_local1 = f8_local1 + 1
    end
    if f8_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 180) then
        f8_arg0:SetNumber(3, f8_local2)
        if f8_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 120) and f8_local5 == 2 then
            f8_arg0:SetNumber(4, 1)
            f8_arg0:SetNumber(5, 1)
            f8_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f8_local0, TARGET_ENE_0, 1, TARGET_SELF, false, 9920, AI_DIR_TYPE_ToR, 54)
        elseif f8_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_L, 120) and f8_local5 == 1 then
            f8_arg0:SetNumber(4, 2)
            f8_arg0:SetNumber(5, 2)
            f8_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f8_local0, TARGET_ENE_0, 1, TARGET_SELF, false, 9920, AI_DIR_TYPE_ToL, 55)
        else
            f8_arg0:SetNumber(4, 0)
            f8_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, f8_local1, TARGET_ENE_0, 9999, TARGET_SELF, false, 9920)
        end
    elseif f8_local3 <= 50 and f8_local5 == 0 then
        f8_arg0:SetNumber(3, f8_local2)
        if f8_local6 == 2 then
            f8_arg0:SetNumber(4, 1)
            f8_arg0:SetNumber(5, 1)
            f8_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f8_local0 * 0.5, TARGET_ENE_0, 0, TARGET_SELF, false, 9920, AI_DIR_TYPE_ToR, 30)
        else
            f8_arg0:SetNumber(4, 2)
            f8_arg0:SetNumber(5, 2)
            f8_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f8_local0 * 0.5, TARGET_ENE_0, 0, TARGET_SELF, false, 9920, AI_DIR_TYPE_ToL, 31)
        end
    elseif f8_local4 + 2 < f8_local2 then
        f8_arg0:SetNumber(3, f8_local2)
        f8_arg0:SetNumber(4, 0)
        f8_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, f8_local1, TARGET_ENE_0, 9999, TARGET_SELF, false, 9920)
    elseif f8_local6 == 2 then
        f8_arg0:SetNumber(4, 1)
        f8_arg0:SetNumber(5, 1)
        f8_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f8_local0 * 0.5, TARGET_ENE_0, 0, TARGET_SELF, false, 9920, AI_DIR_TYPE_ToR, 10)
    else
        f8_arg0:SetNumber(4, 2)
        f8_arg0:SetNumber(5, 2)
        f8_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f8_local0 * 0.5, TARGET_ENE_0, 0, TARGET_SELF, false, 9920, AI_DIR_TYPE_ToL, 11)
    end
    f8_arg0:SetNumber(1, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act12 = function (f9_arg0, f9_arg1, f9_arg2)
    f9_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 1, TARGET_ENE_0, 9999, TARGET_SELF, false, 9920)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act20 = function (f10_arg0, f10_arg1, f10_arg2)
    f10_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 603000, TARGET_SELF, 9999, 0, 0, 0, 0)
    f10_arg0:SetNumber(9, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act26 = function (f11_arg0, f11_arg1, f11_arg2)
    f11_arg1:AddSubGoal(GOAL_COMMON_Wait, 0.5, TARGET_SELF, 0, 0, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act30 = function (f12_arg0, f12_arg1, f12_arg2)
    f12_arg1:AddSubGoal(GOAL_COMMON_WaitWithAnime, 10, 20010, TARGET_NONE)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Interrupt = function (f13_arg0, f13_arg1, f13_arg2)
    local f13_local0 = f13_arg1:GetSpecialEffectActivateInterruptType(0)
    local f13_local1 = f13_arg1:GetDist(TARGET_ENE_0)
    local f13_local2 = f13_arg1:GetRandam_Int(1, 100)
    local f13_local3 = 5400
    if f13_arg1:IsLadderAct(TARGET_SELF) then
        return false
    end
    if not f13_arg1:HasSpecialEffectId(TARGET_SELF, 200004) then
        return false
    end
    if f13_arg1:IsInterupt(INTERUPT_EventRequest) then
        f13_arg1:Replanning()
        return true
    end
    if f13_arg1:IsInterupt(INTERUPT_ActivateSpecialEffect) then
        if f13_local0 == 3132010 and f13_arg1:IsFinishTimer(9) == true and f13_arg1:GetNumber(9) == 0 then
            f13_arg1:SetNumber(9, 1)
            f13_arg1:SetTimer(9, 2)
            f13_arg1:Replanning()
            return true
        else
        end
        return false
    end
    return false
    
end

Goal.NoAction = function (f14_arg0, f14_arg1, f14_arg2)
    return -1
    
end

Goal.ActAfter_AdjustSpace = function (f15_arg0, f15_arg1, f15_arg2)
    
end

Goal.Update = function (f16_arg0, f16_arg1, f16_arg2)
    return Update_Default_NoSubGoal(f16_arg0, f16_arg1, f16_arg2)
    
end

Goal.Terminate = function (f17_arg0, f17_arg1, f17_arg2)
    
end


