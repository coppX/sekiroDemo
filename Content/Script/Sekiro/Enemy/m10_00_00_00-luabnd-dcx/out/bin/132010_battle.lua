RegisterTableGoal(GOAL_Takaragoi_piranha_132010_Battle, "GOAL_Takaragoi_piranha_132010_Battle")
REGISTER_GOAL_NO_UPDATE(GOAL_Takaragoi_piranha_132010_Battle, true)

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
    if f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 110060) then
        if f2_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) then
            f2_local0[20] = 100
        else
            f2_local0[21] = 100
        end
    elseif f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 110015) then
        if f2_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) then
            f2_local0[20] = 100
        else
            f2_local0[21] = 100
        end
    elseif f2_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_B, 180) then
        if f2_local3 > 30 then
            f2_local0[21] = 100
        elseif f2_local3 > 15 then
            f2_local0[21] = 100
            f2_local0[2] = 100
            f2_local0[22] = 100
        else
            f2_local0[21] = 100
        end
    elseif f2_local3 >= 100 then
        f2_local0[20] = 100
    elseif f2_local3 >= 15 then
        f2_local0[2] = 100
        f2_local0[22] = 100
    elseif f2_local3 >= 5 then
        f2_local0[3] = 100
        f2_local0[22] = 20
    else
        f2_local0[1] = 100
        f2_local0[22] = 50
    end
    if f2_arg1:GetDistY(TARGET_ENE_0) >= 2 or f2_arg1:HasSpecialEffectId(TARGET_SELF, 5020) then
        f2_local0[3] = 0
    end
    f2_local1[1] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act01)
    f2_local1[2] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act02)
    f2_local1[3] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act03)
    f2_local1[20] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act20)
    f2_local1[21] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act21)
    f2_local1[22] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act22)
    local f2_local5 = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.ActAfter_AdjustSpace)
    Common_Battle_Activate(f2_arg1, f2_arg2, f2_local0, f2_local1, f2_local5, f2_local2)
    
end

Goal.Act01 = function (f3_arg0, f3_arg1, f3_arg2)
    local f3_local0 = f3_arg0:GetRandam_Float(2, 4)
    local f3_local1 = f3_arg0:GetRandam_Float(5, 10)
    local f3_local2 = f3_arg0:GetDist(TARGET_ENE_0)
    local f3_local3 = -1
    local f3_local4 = false
    local f3_local5 = f3_arg0:GetRandam_Int(1, 3)
    if f3_local2 >= 10 then
        f3_local4 = true
    end
    f3_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, f3_local5, TARGET_ENE_0, 9999, TARGET_SELF, f3_local4, -1):SetLifeEndSuccess(true)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act02 = function (f4_arg0, f4_arg1, f4_arg2)
    local f4_local0 = f4_arg0:GetDist(TARGET_ENE_0)
    local f4_local1 = 10
    local f4_local2 = 7.5
    local f4_local3 = -1
    f4_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, f4_local2, TARGET_ENE_0, f4_local1, TARGET_SELF, false, f4_local3)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act03 = function (f5_arg0, f5_arg1, f5_arg2)
    local f5_local0 = f5_arg0:GetDist(TARGET_ENE_0)
    local f5_local1 = 10
    local f5_local2 = 0 + 5
    local f5_local3 = 10 + 5
    local f5_local4 = 0
    local f5_local5 = 0
    local f5_local6 = 5
    local f5_local7 = 3
    local f5_local8 = 3001
    local f5_local9 = 0
    local f5_local10 = 0
    f5_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f5_local8, TARGET_ENE_0, 9999, f5_local9, f5_local10, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act20 = function (f6_arg0, f6_arg1, f6_arg2)
    f6_arg1:AddSubGoal(GOAL_COMMON_Wait, 0.5, TARGET_SELF, 0, 0, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act21 = function (f7_arg0, f7_arg1, f7_arg2)
    f7_arg1:AddSubGoal(GOAL_COMMON_Turn, 3, TARGET_ENE_0, f7_arg0:GetRandam_Int(15, 30))
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act22 = function (f8_arg0, f8_arg1, f8_arg2)
    local f8_local0 = f8_arg0:GetDist(TARGET_ENE_0)
    local f8_local1 = 9999
    local f8_local2 = 0
    local f8_local3 = 0
    local f8_local4 = f8_arg0:GetRandam_Int(2, 5)
    local f8_local5 = f8_arg0:GetRandam_Int(1, 100)
    local f8_local6 = f8_arg0:GetRandam_Int(1, 100)
    local f8_local7 = f8_arg0:GetRandam_Float(1.5, 3)
    local f8_local8 = f8_arg0:GetRandam_Float(1.5, 3)
    local f8_local9 = f8_arg0:GetRandam_Float(3, 8)
    local f8_local10 = f8_arg0:GetRandam_Int(1, 3)
    local f8_local11 = false
    if f8_local6 >= 50 then
        f8_local11 = true
    end
    if f8_local0 < 10 then
        f8_local11 = false
    end
    if f8_local5 <= 50 then
        f8_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f8_local7, TARGET_ENE_0, 3, TARGET_SELF, iswalk, -1, AI_DIR_TYPE_ToL, f8_local9)
    else
        f8_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f8_local7, TARGET_ENE_0, 3, TARGET_SELF, iswalk, -1, AI_DIR_TYPE_ToR, f8_local9)
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Interrupt = function (f9_arg0, f9_arg1, f9_arg2)
    local f9_local0 = f9_arg1:GetSpecialEffectActivateInterruptType(0)
    if f9_arg1:IsLadderAct(TARGET_SELF) then
        return false
    end
    if not f9_arg1:HasSpecialEffectId(TARGET_SELF, 200004) then
        return false
    end
    if f9_arg1:IsInterupt(INTERUPT_ParryTiming) then
    end
    if f9_arg1:IsInterupt(INTERUPT_Damaged) then
    end
    return false
    
end

Goal.Parry = function (f10_arg0, f10_arg1, f10_arg2)
    local f10_local0 = f10_arg0:GetHpRate(TARGET_SELF)
    local f10_local1 = f10_arg0:GetDist(TARGET_ENE_0)
    local f10_local2 = f10_arg0:GetSp(TARGET_SELF)
    local f10_local3 = f10_arg0:GetRandam_Int(1, 100)
    local f10_local4 = 0
    if not f10_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) or not f10_arg0:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_F, 90, 3) or f10_arg0:HasSpecialEffectId(TARGET_ENE_0, 109012) then
    elseif f10_arg0:IsTargetGuard(TARGET_SELF) then
        if f10_arg0:HasSpecialEffectId(TARGET_ENE_0, 109970) then
        else
            f10_arg1:ClearSubGoal()
            f10_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3100, TARGET_ENE_0, 9999, 0)
            return true
        end
    elseif f10_arg0:HasSpecialEffectId(TARGET_ENE_0, 109970) then
        f10_arg1:ClearSubGoal()
        f10_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3101, TARGET_ENE_0, 9999, 0)
        return true
    else
        f10_arg1:ClearSubGoal()
        f10_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3100, TARGET_ENE_0, 9999, 0)
        return true
    end
    return false
    
end

Goal.Damaged = function (f11_arg0, f11_arg1, f11_arg2)
    return false
    
end

Goal.NoAction = function (f12_arg0, f12_arg1, f12_arg2)
    return -1
    
end

Goal.ActAfter_AdjustSpace = function (f13_arg0, f13_arg1, f13_arg2)
    
end

Goal.Update = function (f14_arg0, f14_arg1, f14_arg2)
    return Update_Default_NoSubGoal(f14_arg0, f14_arg1, f14_arg2)
    
end

Goal.Terminate = function (f15_arg0, f15_arg1, f15_arg2)
    
end


