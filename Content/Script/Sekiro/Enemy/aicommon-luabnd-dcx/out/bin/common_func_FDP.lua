function Approach_Act_Flex(f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9)
    if f1_arg7 == nil then
        f1_arg7 = 3
    end
    if f1_arg8 == nil then
        f1_arg8 = 8
    end
    if f1_arg9 == nil then
        f1_arg9 = 0
    end
    local f1_local0 = f1_arg0:GetDist(TARGET_ENE_0)
    local f1_local1 = f1_arg0:GetRandam_Int(1, 100)
    local f1_local2 = true
    if f1_arg4 <= f1_local0 then
        f1_local2 = false
    elseif f1_arg3 <= f1_local0 and f1_local1 <= f1_arg5 then
        f1_local2 = false
    end
    if f1_arg0:IsInsideTargetRegion(TARGET_SELF, COMMON_REGION_FORCE_WALK_M11_0) or f1_arg0:IsInsideTargetRegion(TARGET_SELF, COMMON_REGION_FORCE_WALK_M11_1) then
        f1_local2 = true
    end
    local f1_local3 = -1
    local f1_local4 = f1_arg0:GetRandam_Int(1, 100)
    if f1_local4 <= f1_arg6 then
        f1_local3 = 9910
    end
    if f1_local2 == true then
        life = f1_arg7
    else
        life = f1_arg8
    end
    if f1_arg2 <= f1_local0 or f1_arg9 > 0 then
        if f1_local2 == true then
            f1_arg2 = f1_arg2 + f1_arg0:GetStringIndexedNumber("AddDistWalk")
        else
            f1_arg2 = f1_arg2 + f1_arg0:GetStringIndexedNumber("AddDistRun")
        end
        f1_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, life, TARGET_ENE_0, f1_arg2, TARGET_SELF, f1_local2, f1_local3)
    end
    
end

function SpaceCheck(f2_arg0, f2_arg1, f2_arg2, f2_arg3)
    local f2_local0 = f2_arg0:GetMapHitRadius(TARGET_SELF)
    local f2_local1 = f2_arg0:GetExistMeshOnLineDistSpecifyAngleEx(TARGET_SELF, f2_arg2, f2_arg3 + f2_local0, AI_SPA_DIR_TYPE_TargetF, f2_local0, 0)
    if f2_arg3 * 0.95 <= f2_local1 then
        return true
    else
        return false
    end
    
end

function InsideRange(f3_arg0, f3_arg1, f3_arg2, f3_arg3, f3_arg4, f3_arg5)
    return YSD_InsideRangeEx(f3_arg0, f3_arg1, f3_arg2, f3_arg3, f3_arg4, f3_arg5)
    
end

function InsideDir(f4_arg0, f4_arg1, f4_arg2, f4_arg3)
    return YSD_InsideRangeEx(f4_arg0, f4_arg1, f4_arg2, f4_arg3, -999, 999)
    
end

function YSD_InsideRangeEx(f5_arg0, f5_arg1, f5_arg2, f5_arg3, f5_arg4, f5_arg5)
    local f5_local0 = f5_arg0:GetDist(TARGET_ENE_0)
    if f5_arg4 <= f5_local0 and f5_local0 <= f5_arg5 then
        local f5_local1 = f5_arg0:GetToTargetAngle(TARGET_ENE_0)
        local f5_local2 = 0
        if f5_arg2 < 0 then
            f5_local2 = -1
        else
            f5_local2 = 1
        end
        if f5_arg2 + f5_arg3 / -2 <= f5_local1 and f5_local1 <= f5_arg2 + f5_arg3 / 2 or f5_arg2 + f5_arg3 / -2 <= f5_local1 + 360 * f5_local2 and f5_local1 + 360 * f5_local2 <= f5_arg2 + f5_arg3 / 2 then
            return true
        else
            return false
        end
    else
        return false
    end
    
end

function SetCoolTime(f6_arg0, f6_arg1, f6_arg2, f6_arg3, f6_arg4, f6_arg5)
    if f6_arg4 <= 0 then
        return 0
    elseif f6_arg0:GetAttackPassedTime(f6_arg2) <= f6_arg3 then
        return f6_arg5
    end
    return f6_arg4
    
end

function SpaceCheckBeforeAct(f7_arg0, f7_arg1, f7_arg2, f7_arg3, f7_arg4)
    if f7_arg4 <= 0 then
        return 0
    elseif SpaceCheck(f7_arg0, f7_arg1, f7_arg2, f7_arg3) then
        return f7_arg4
    else
        return 0
    end
    
end

function Counter_Act(f8_arg0, f8_arg1, f8_arg2, f8_arg3)
    local f8_local0 = 0.5
    if f8_arg2 == nil then
        f8_arg2 = 4
    end
    local f8_local1 = f8_arg0:GetRandam_Int(1, 100)
    local f8_local2 = f8_arg0:GetNumber(15)
    if f8_arg0:IsInterupt(INTERUPT_Damaged) then
        f8_arg0:SetTimer(15, 5)
        if f8_local2 == 0 then
            f8_local2 = f8_arg2
        end
        f8_arg0:SetNumber(15, f8_local2 * 2)
    end
    if f8_local2 >= 100 then
        f8_arg0:SetNumber(15, 100)
    end
    if f8_arg0:IsInterupt(INTERUPT_Damaged) and f8_local1 <= f8_arg0:GetNumber(15) and f8_arg0:GetTimer(14) <= 0 then
        f8_arg0:SetTimer(14, 3)
        f8_arg0:SetNumber(15, 0)
        f8_arg1:ClearSubGoal()
        f8_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, f8_local0, f8_arg3, TARGET_ENE_0, DIST_None, 0, 180, 0, 0)
        return true
    end
    return false
    
end

function ReactBackstab_Act(f9_arg0, f9_arg1, f9_arg2, f9_arg3, f9_arg4)
    local f9_local0 = f9_arg0:GetRandam_Int(1, 100)
    local f9_local1 = f9_arg0:GetRandam_Int(1, 100)
    local f9_local2 = 3
    local f9_local3 = 6000
    local f9_local4 = 6002
    local f9_local5 = 6003
    if f9_arg3 == nil then
        f9_arg4 = 0
    end
    if f9_arg0:IsInterupt(INTERUPT_BackstabRisk) then
        if f9_local0 <= f9_arg4 then
            f9_arg1:ClearSubGoal()
            f9_arg1:AddSubGoal(GOAL_COMMON_StabCounterAttack, f9_local2, f9_arg3, TARGET_ENE_0, DIST_None, 0, 180, 0, 0)
        elseif f9_arg2 == 1 then
            f9_arg1:ClearSubGoal()
            f9_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f9_local2, f9_local3, TARGET_SELF, 0, AI_DIR_TYPE_F, 0)
        elseif f9_arg2 == 2 then
            f9_arg1:ClearSubGoal()
            if f9_local1 <= 50 then
                f9_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f9_local2, f9_local4, TARGET_SELF, 0, AI_DIR_TYPE_L, 0)
            else
                f9_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f9_local2, f9_local5, TARGET_SELF, 0, AI_DIR_TYPE_R, 0)
            end
        elseif f9_arg2 == 3 then
            f9_arg1:ClearSubGoal()
            if f9_local1 <= 33 then
                f9_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f9_local2, f9_local3, TARGET_SELF, 0, AI_DIR_TYPE_F, 0)
            elseif f9_local1 <= 66 then
                f9_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f9_local2, f9_local4, TARGET_SELF, 0, AI_DIR_TYPE_L, 0)
            else
                f9_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f9_local2, f9_local5, TARGET_SELF, 0, AI_DIR_TYPE_R, 0)
            end
        end
        return false
    end
    
end

function Init_Pseudo_Global(f10_arg0, f10_arg1)
    f10_arg0:SetStringIndexedNumber("Dist_SideStep", 5)
    f10_arg0:SetStringIndexedNumber("Dist_BackStep", 5)
    f10_arg0:SetStringIndexedNumber("AddDistWalk", 0)
    f10_arg0:SetStringIndexedNumber("AddDistRun", 0)
    Init_AfterAttackAct(f10_arg0, f10_arg1)
    
end

function Init_AfterAttackAct(f11_arg0, f11_arg1)
    f11_arg0:SetStringIndexedNumber("DistMin_AAA", -999)
    f11_arg0:SetStringIndexedNumber("DistMax_AAA", 999)
    f11_arg0:SetStringIndexedNumber("BaseDir_AAA", AI_DIR_TYPE_F)
    f11_arg0:SetStringIndexedNumber("Angle_AAA", 360)
    f11_arg0:SetStringIndexedNumber("Odds_Guard_AAA", 0)
    f11_arg0:SetStringIndexedNumber("Odds_NoAct_AAA", 0)
    f11_arg0:SetStringIndexedNumber("Odds_BackAndSide_AAA", 0)
    f11_arg0:SetStringIndexedNumber("Odds_Back_AAA", 0)
    f11_arg0:SetStringIndexedNumber("Odds_Backstep_AAA", 0)
    f11_arg0:SetStringIndexedNumber("Odds_Sidestep_AAA", 0)
    f11_arg0:SetStringIndexedNumber("Odds_BitWait_AAA", 0)
    f11_arg0:SetStringIndexedNumber("Odds_BsAndSide_AAA", 0)
    f11_arg0:SetStringIndexedNumber("Odds_BsAndSs_AAA", 0)
    f11_arg0:SetStringIndexedNumber("DistMin_Inter_AAA", -999)
    f11_arg0:SetStringIndexedNumber("DistMax_Inter_AAA", 999)
    f11_arg0:SetStringIndexedNumber("BaseAng_Inter_AAA", 0)
    f11_arg0:SetStringIndexedNumber("Ang_Inter_AAA", 360)
    f11_arg0:SetStringIndexedNumber("BackAndSide_BackLife_AAA", 2)
    f11_arg0:SetStringIndexedNumber("BackAndSide_SideLife_AAA", f11_arg0:GetRandam_Float(2.5, 3.5))
    f11_arg0:SetStringIndexedNumber("BackLife_AAA", f11_arg0:GetRandam_Float(2, 3))
    f11_arg0:SetStringIndexedNumber("BsAndSide_SideLife_AAA", f11_arg0:GetRandam_Float(2.5, 3.5))
    f11_arg0:SetStringIndexedNumber("BackAndSide_BackDist_AAA", 1.5)
    f11_arg0:SetStringIndexedNumber("BackDist_AAA", f11_arg0:GetRandam_Float(2.5, 3.5))
    f11_arg0:SetStringIndexedNumber("BackAndSide_SideDir_AAA", f11_arg0:GetRandam_Int(45, 60))
    f11_arg0:SetStringIndexedNumber("BsAndSide_SideDir_AAA", f11_arg0:GetRandam_Int(45, 60))
    
end

function Update_Default_NoSubGoal(f12_arg0, f12_arg1, f12_arg2)
    if f12_arg2:GetSubGoalNum() <= 0 then
        return GOAL_RESULT_Success
    end
    return GOAL_RESULT_Continue
    
end

function GuardGoalSubFunc_Activate(f13_arg0, f13_arg1, f13_arg2)
    if 0 < f13_arg2 then
        f13_arg0:DoEzAction(f13_arg1, f13_arg2)
    end
    
end

function GuardGoalSubFunc_Update(f14_arg0, f14_arg1, f14_arg2, f14_arg3, f14_arg4)
    if 0 < f14_arg2 then
        if f14_arg1:GetNumber(0) ~= 0 then
            return GOAL_RESULT_Failed
        elseif f14_arg1:GetNumber(1) ~= 0 then
            return f14_arg3
        end
    end
    if f14_arg1:GetLife() <= 0 then
        if f14_arg4 then
            return GOAL_RESULT_Success
        else
            return GOAL_RESULT_Failed
        end
    end
    return GOAL_RESULT_Continue
    
end

function GuardGoalSubFunc_Interrupt(f15_arg0, f15_arg1, f15_arg2, f15_arg3)
    if 0 < f15_arg2 then
        if f15_arg0:IsInterupt(INTERUPT_Damaged) then
            f15_arg1:SetNumber(0, 1)
        elseif f15_arg0:IsInterupt(INTERUPT_SuccessGuard) and f15_arg3 ~= GOAL_RESULT_Continue then
            f15_arg1:SetNumber(1, 1)
        end
    end
    return false
    
end


