RegisterTableGoal(GOAL_NewInu_115000_Battle, "GOAL_NewInu_115000_Battle")
REGISTER_GOAL_NO_UPDATE(GOAL_NewInu_115000_Battle, true)

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
    local f2_local5 = f2_arg1:GetNpcThinkParamID()
    local f2_local6 = f2_arg1:GetDistYSigned(TARGET_ENE_0)
    local f2_local7 = f2_arg1:GetEventRequest()
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 3109001)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 3147000)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 109221)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 109220)
    f2_arg1:DeleteObserve(0)
    f2_arg1:SetNumber(15, 0)
    local f2_local8 = f2_arg1:GetEventRequest()
    if (f2_local8 >= 3000 or f2_arg1:HasSpecialEffectId(TARGET_SELF, 3115025)) and f2_arg1:GetNumber(2) == 0 then
        f2_local0[1] = 100
    elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 3147000) then
        f2_local0[1] = 100
    elseif f2_arg1:GetNumber(7) == 1 then
        f2_local0[33] = 100
    elseif f2_arg1:GetNumber(6) == 1 then
        f2_local0[32] = 100
    elseif f2_arg1:GetNumber(8) == 1 then
        if SpaceCheck(f2_arg1, f2_arg2, 180, 5) then
            f2_local0[24] = 100
            f2_local0[1] = 10
        else
            f2_local0[1] = 100
        end
        f2_arg1:SetNumber(8, 0)
    elseif f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 110060) then
        if f2_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) then
            f2_local0[26] = 100
        else
            f2_local0[21] = 100
        end
    elseif f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 110015) then
        f2_local0[10] = 100
    elseif f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 110030) then
        f2_local0[10] = 100
    elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 220020) then
        f2_local0[1] = 200
        f2_local0[10] = 100
    elseif f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 4200) and f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 109012) and f2_arg1:GetNumber(1) == 0 then
        f2_local0[12] = 100
    elseif f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 4200) and f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 109012) and f2_arg1:GetNumber(1) == 1 and f2_arg1:GetNumber(2) < 2 then
        f2_local0[14] = 100
    elseif f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 4200) and f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 109012) and f2_arg1:GetNumber(1) == 1 and f2_arg1:GetNumber(2) >= 2 then
        f2_local0[1] = 200
        f2_local0[14] = 200
    elseif f2_arg1:IsFinishTimer(3) == false then
        f2_local0[1] = 100
    elseif f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 110060) then
        if f2_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) then
            f2_local0[26] = 100
        else
            f2_local0[21] = 100
        end
    elseif f2_arg1:IsInsideTargetRegion(TARGET_ENE_0, 2502430) or f2_arg1:IsInsideTargetRegion(TARGET_ENE_0, 2502431) then
        if f2_local3 <= 10 then
            f2_local0[21] = 50
            f2_local0[24] = 500
            f2_local0[27] = 1
            if f2_arg1:HasSpecialEffectId(TARGET_SELF, 200051) then
                f2_local0[5] = 10
            end
        elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 200051) then
            f2_local0[5] = 400
        else
            f2_local0[41] = 300
            f2_local0[27] = 1
            f2_local0[10] = 300
        end
    elseif f2_arg1:CheckDoesExistPath(TARGET_ENE_0, AI_DIR_TYPE_F, 0, 0) == false or f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 109220) or f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 109221) then
        f2_local0[27] = 100
        f2_local0[21] = 50
        if f2_arg1:HasSpecialEffectId(TARGET_SELF, 200051) and f2_arg1:IsVisibleTarget(TARGET_ENE_0) then
            f2_local0[5] = 400
        end
    elseif f2_arg1:GetNumber(4) == 1 then
        f2_local0[1] = 100
    elseif f2_local3 >= 15 then
        f2_local0[34] = 100
    elseif f2_local4 == 1 and f2_arg1:GetTeamOrder(ORDER_TYPE_Role) == ROLE_TYPE_Kankyaku then
        if f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 109900) and f2_arg1:HasSpecialEffectId(TARGET_SELF, 3115020) == false then
            f2_local0[2] = 100
        elseif f2_arg1:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_B, 270, 9999) then
            if f2_arg1:HasSpecialEffectId(TARGET_SELF, 3115020) then
                f2_local0[20] = 1
                f2_local0[41] = 300
                f2_local0[42] = 200
            else
                f2_local0[10] = 300
                f2_local0[20] = 1
                f2_local0[31] = 200
            end
        elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 3115020) then
            f2_local0[41] = 300
            f2_local0[42] = 200
        else
            f2_local0[10] = 100
            f2_local0[31] = 100
        end
        if f2_local3 <= 3 then
            f2_local0[24] = f2_local0[10]
            f2_local0[10] = 1
        end
    elseif f2_local4 == 1 and f2_arg1:GetTeamOrder(ORDER_TYPE_Role) == ROLE_TYPE_Torimaki then
        if f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 109900) and f2_arg1:HasSpecialEffectId(TARGET_SELF, 3115020) == false then
            f2_local0[2] = 100
        elseif f2_arg1:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_B, 270, 9999) then
            if f2_arg1:HasSpecialEffectId(TARGET_SELF, 3115020) then
                f2_local0[20] = 1
                f2_local0[41] = 300
                f2_local0[42] = 200
            else
                f2_local0[10] = 300
                f2_local0[20] = 1
                f2_local0[31] = 200
            end
        elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 3115020) then
            f2_local0[1] = 50
            f2_local0[41] = 300
            f2_local0[42] = 200
        else
            f2_local0[1] = 50
            f2_local0[10] = 100
            f2_local0[31] = 100
        end
        if f2_local3 <= 3 then
            f2_local0[1] = 0
            f2_local0[24] = f2_local0[10]
            f2_local0[10] = 1
        elseif f2_local3 <= 5 then
            f2_local0[1] = 0
        end
    elseif f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 109900) and f2_arg1:HasSpecialEffectId(TARGET_SELF, 3115020) == false then
        f2_local0[2] = 100
    elseif f2_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_B, 180) then
        if f2_arg1:HasSpecialEffectId(TARGET_SELF, 3115020) then
            f2_local0[20] = 100
        else
            f2_local0[20] = 100
            f2_local0[31] = 100
        end
    elseif f2_local3 >= 12 then
        if f2_arg1:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_B, 270, 9999) then
            if f2_arg1:HasSpecialEffectId(TARGET_SELF, 3115020) then
                f2_local0[1] = 250
                f2_local0[20] = 1
                f2_local0[42] = 100
            else
                f2_local0[1] = 150
                f2_local0[20] = 1
                f2_local0[31] = 200
                if f2_arg1:HasSpecialEffectId(TARGET_SELF, 200051) then
                    f2_local0[3] = 400
                    f2_local0[4] = 400
                end
            end
        elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 3115020) then
            f2_local0[1] = 100
            f2_local0[20] = 1
            f2_local0[41] = 100
            f2_local0[42] = 400
        else
            f2_local0[1] = 250
            f2_local0[10] = 50
            f2_local0[24] = 0
            f2_local0[31] = 100
            if f2_arg1:HasSpecialEffectId(TARGET_SELF, 200051) then
                f2_local0[3] = 400
                f2_local0[4] = 400
            end
        end
    elseif f2_local3 >= 8 then
        if f2_arg1:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_B, 270, 9999) then
            if f2_arg1:HasSpecialEffectId(TARGET_SELF, 3115020) then
                f2_local0[1] = 200
                f2_local0[20] = 1
                f2_local0[41] = 100
                f2_local0[42] = 100
            else
                f2_local0[1] = 150
                f2_local0[10] = 200
                f2_local0[20] = 1
                f2_local0[31] = 200
                if f2_arg1:HasSpecialEffectId(TARGET_SELF, 200051) then
                    f2_local0[3] = 400
                    f2_local0[4] = 400
                end
            end
        elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 3115020) then
            f2_local0[1] = 0
            f2_local0[20] = 1
            f2_local0[24] = 0
            f2_local0[41] = 100
            f2_local0[42] = 100
        else
            f2_local0[1] = 1500
            f2_local0[24] = 50
            f2_local0[10] = 100
            f2_local0[31] = 100
            if f2_arg1:HasSpecialEffectId(TARGET_SELF, 200051) then
                f2_local0[3] = 400
                f2_local0[4] = 400
            end
        end
    elseif f2_local3 >= 5 then
        if f2_arg1:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_B, 270, 9999) then
            if f2_arg1:HasSpecialEffectId(TARGET_SELF, 3115020) then
                f2_local0[1] = 100
                f2_local0[20] = 1
                f2_local0[24] = 50
                f2_local0[41] = 100
                f2_local0[42] = 200
            else
                f2_local0[1] = 150
                f2_local0[10] = 300
                f2_local0[20] = 1
                f2_local0[31] = 200
                if f2_arg1:HasSpecialEffectId(TARGET_SELF, 200051) then
                    f2_local0[3] = 400
                    f2_local0[4] = 400
                end
            end
        elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 3115020) then
            f2_local0[1] = 0
            f2_local0[20] = 1
            f2_local0[24] = 200
            f2_local0[41] = 100
            f2_local0[42] = 100
        else
            f2_local0[1] = 600
            f2_local0[10] = 200
            f2_local0[24] = 100
            f2_local0[31] = 100
            if f2_arg1:HasSpecialEffectId(TARGET_SELF, 200051) then
                f2_local0[3] = 400
                f2_local0[4] = 400
            end
        end
    elseif f2_arg1:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_B, 270, 9999) then
        if f2_arg1:HasSpecialEffectId(TARGET_SELF, 3115020) then
            f2_local0[1] = 100
            f2_local0[20] = 1
            f2_local0[24] = 300
        else
            f2_local0[1] = 100
            f2_local0[10] = 300
            f2_local0[20] = 1
            f2_local0[31] = 200
        end
    elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 3115020) then
        f2_local0[1] = 1
        f2_local0[20] = 1
        f2_local0[24] = 400
    else
        f2_local0[1] = 100
        f2_local0[10] = 100
        f2_local0[24] = 500
        f2_local0[31] = 100
    end
    f2_local0[1] = SetCoolTime(f2_arg1, f2_arg2, 3000, 5, f2_local0[1], 1)
    f2_local0[1] = SetCoolTime(f2_arg1, f2_arg2, 3001, 5, f2_local0[1], 1)
    f2_local0[3] = SetCoolTime(f2_arg1, f2_arg2, 3020, 5, f2_local0[3], 1)
    if f2_arg1:GetNumber(4) >= 1 then
        f2_local0[1] = f2_local0[1] + f2_arg1:GetNumber(4) * 2
    end
    if f2_arg1:IsLockOnTarget(TARGET_ENE_0, TARGET_SELF) and f2_arg1:HasSpecialEffectId(TARGET_SELF, 3115020) == false then
        f2_local0[31] = 0
    end
    if f2_arg1:IsExistMeshOnLine(TARGET_ENE_0, AI_DIR_TYPE_F, 4) == false or f2_arg1:IsExistMeshOnLine(TARGET_ENE_0, AI_DIR_TYPE_B, 4) == false or f2_arg1:IsExistMeshOnLine(TARGET_ENE_0, AI_DIR_TYPE_R, 4) == false or f2_arg1:IsExistMeshOnLine(TARGET_ENE_0, AI_DIR_TYPE_L, 4) == false then
        f2_local0[31] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 90, 5) == false and SpaceCheck(f2_arg1, f2_arg2, -90, 5) == false then
        f2_local0[31] = 0
    end
    if f2_arg1:IsFinishTimer(1) == false then
        f2_local0[21] = 0
        f2_local0[24] = 1
    end
    if SpaceCheck(f2_arg1, f2_arg2, 180, 5) == false then
        f2_local0[21] = f2_local0[24]
        f2_local0[24] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, -45, 5) == false and SpaceCheck(f2_arg1, f2_arg2, 45, 5) == false then
        f2_local0[21] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 90, 1) == false and SpaceCheck(f2_arg1, f2_arg2, -90, 1) == false then
        f2_local0[42] = 0
    end
    f2_local0[5] = SetCoolTime(f2_arg1, f2_arg2, 3020, 6, f2_local0[5], 1)
    f2_local1[1] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act01)
    f2_local1[2] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act02)
    f2_local1[3] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act03)
    f2_local1[4] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act04)
    f2_local1[5] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act05)
    f2_local1[10] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act10)
    f2_local1[11] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act11)
    f2_local1[12] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act12)
    f2_local1[13] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act13)
    f2_local1[14] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act14)
    f2_local1[20] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act20)
    f2_local1[21] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act21)
    f2_local1[24] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act24)
    f2_local1[26] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act26)
    f2_local1[27] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act27)
    f2_local1[31] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act31)
    f2_local1[32] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act32)
    f2_local1[33] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act33)
    f2_local1[34] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act34)
    f2_local1[41] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act41)
    f2_local1[42] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act42)
    f2_local1[43] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act43)
    f2_local1[44] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act44)
    local f2_local9 = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.ActAfter_AdjustSpace)
    Common_Battle_Activate(f2_arg1, f2_arg2, f2_local0, f2_local1, f2_local9, f2_local2)
    f2_arg1:SetNumber(6, 0)
    
end

Goal.Act01 = function (f3_arg0, f3_arg1, f3_arg2)
    local f3_local0 = 5.8 - f3_arg0:GetMapHitRadius(TARGET_SELF)
    local f3_local1 = 5.8 - f3_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f3_local2 = 5.8 - f3_arg0:GetMapHitRadius(TARGET_SELF) + 1
    local f3_local3 = 100
    local f3_local4 = 0
    local f3_local5 = 1.5
    local f3_local6 = 4
    local f3_local7 = f3_arg0:GetDist(TARGET_ENE_0)
    Approach_Act_Flex(f3_arg0, f3_arg1, f3_local0, f3_local1, f3_local2, f3_local3, f3_local4, f3_local5, f3_local6)
    local f3_local8 = 3000
    local f3_local9 = 3001
    local f3_local10 = 9999 - f3_arg0:GetMapHitRadius(TARGET_SELF)
    local f3_local11 = 0
    local f3_local12 = 0
    local f3_local13 = f3_arg0:GetRandam_Int(1, 100)
    local f3_local14 = 5202
    if f3_local13 <= 50 then
        f3_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f3_local8, TARGET_ENE_0, f3_local10, f3_local11, f3_local12, 0, 0):TimingSetNumber(4, 0, AI_TIMING_SET__UPDATE_SUCCESS):TimingSetNumber(2, 1, AI_TIMING_SET__ACTIVATE)
        f3_local14 = 5203
    else
        f3_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f3_local9, TARGET_ENE_0, f3_local10, f3_local11, f3_local12, 0, 0):TimingSetNumber(4, 0, AI_TIMING_SET__UPDATE_SUCCESS):TimingSetNumber(2, 1, AI_TIMING_SET__ACTIVATE)
    end
    local f3_local15 = f3_arg0:GetRandam_Float(1.2, 2)
    local f3_local16 = 3
    if f3_arg0:IsExistMeshOnLine(TARGET_ENE_0, AI_DIR_TYPE_ToF, 3) then
        f3_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, 0.5, TARGET_SELF, 0, TARGET_SELF, false, -1, AI_DIR_TYPE_F, 5):TimingSetNumber(6, 1, AI_TIMING_SET__ACTIVATE)
    else
    end
    f3_arg0:SetTimer(0, 5)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act02 = function (f4_arg0, f4_arg1, f4_arg2)
    local f4_local0 = 3.9 - f4_arg0:GetMapHitRadius(TARGET_SELF)
    local f4_local1 = 3.9 - f4_arg0:GetMapHitRadius(TARGET_SELF)
    local f4_local2 = 3.9 - f4_arg0:GetMapHitRadius(TARGET_SELF) + 100
    local f4_local3 = 100
    local f4_local4 = 0
    local f4_local5 = 0
    local f4_local6 = 5
    local f4_local7 = f4_arg0:GetDist(TARGET_ENE_0)
    if f4_local2 < f4_local7 then
        f4_local0 = f4_local0 + 1.1
    end
    Approach_Act_Flex(f4_arg0, f4_arg1, f4_local0, f4_local1, f4_local2, f4_local3, f4_local4, f4_local5, f4_local6)
    local f4_local8 = 3005
    local f4_local9 = 9999 - f4_arg0:GetMapHitRadius(TARGET_SELF)
    local f4_local10 = 0
    local f4_local11 = 0
    f4_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f4_local8, TARGET_ENE_0, f4_local9, f4_local10, f4_local11, 0, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act03 = function (f5_arg0, f5_arg1, f5_arg2)
    local f5_local0 = 10 - f5_arg0:GetMapHitRadius(TARGET_SELF)
    local f5_local1 = 10 - f5_arg0:GetMapHitRadius(TARGET_SELF)
    local f5_local2 = 10 - f5_arg0:GetMapHitRadius(TARGET_SELF) + 100
    local f5_local3 = 100
    local f5_local4 = 0
    local f5_local5 = 0
    local f5_local6 = 5
    local f5_local7 = f5_arg0:GetDist(TARGET_ENE_0)
    Approach_Act_Flex(f5_arg0, f5_arg1, f5_local0, f5_local1, f5_local2, f5_local3, f5_local4, f5_local5, f5_local6)
    local f5_local8 = 3020
    local f5_local9 = 9999 - f5_arg0:GetMapHitRadius(TARGET_SELF)
    local f5_local10 = 0
    local f5_local11 = 0
    f5_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f5_local8, TARGET_ENE_0, f5_local9, f5_local10, f5_local11, 0, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act04 = function (f6_arg0, f6_arg1, f6_arg2)
    local f6_local0 = 10 - f6_arg0:GetMapHitRadius(TARGET_SELF) + 2.5
    local f6_local1 = 10 - f6_arg0:GetMapHitRadius(TARGET_SELF) + 2.5
    local f6_local2 = 10 - f6_arg0:GetMapHitRadius(TARGET_SELF) + 100
    local f6_local3 = 100
    local f6_local4 = 0
    local f6_local5 = 0
    local f6_local6 = 5
    local f6_local7 = f6_arg0:GetDist(TARGET_ENE_0)
    Approach_Act_Flex(f6_arg0, f6_arg1, f6_local0, f6_local1, f6_local2, f6_local3, f6_local4, f6_local5, f6_local6)
    local f6_local8 = 3021
    local f6_local9 = 9999 - f6_arg0:GetMapHitRadius(TARGET_SELF)
    local f6_local10 = 0
    local f6_local11 = 0
    f6_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f6_local8, TARGET_ENE_0, f6_local9, f6_local10, f6_local11, 0, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act05 = function (f7_arg0, f7_arg1, f7_arg2)
    local f7_local0 = 10 - f7_arg0:GetMapHitRadius(TARGET_SELF) + 2.5
    local f7_local1 = 10 - f7_arg0:GetMapHitRadius(TARGET_SELF) + 2.5
    local f7_local2 = 10 - f7_arg0:GetMapHitRadius(TARGET_SELF) + 100
    local f7_local3 = 100
    local f7_local4 = 0
    local f7_local5 = 0
    local f7_local6 = 5
    local f7_local7 = f7_arg0:GetDist(TARGET_ENE_0)
    local f7_local8 = 3020
    local f7_local9 = 9999 - f7_arg0:GetMapHitRadius(TARGET_SELF)
    local f7_local10 = 0
    local f7_local11 = 0
    f7_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f7_local8, TARGET_ENE_0, f7_local9, f7_local10, f7_local11, 0, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act10 = function (f8_arg0, f8_arg1, f8_arg2)
    local f8_local0 = 3
    local f8_local1 = 3002
    local f8_local2 = 3003
    local f8_local3 = 3004
    local f8_local4 = f8_arg0:GetNumber(f8_local0)
    local f8_local5 = 0
    local f8_local6 = f8_arg0:GetRandam_Int(1, 100)
    if f8_local4 == f8_local1 then
        if f8_local6 <= 50 then
            f8_local5 = f8_local2
        else
            f8_local5 = f8_local3
        end
    elseif f8_local4 == f8_local2 then
        if f8_local6 <= 50 then
            f8_local5 = f8_local1
        else
            f8_local5 = f8_local3
        end
    elseif f8_local4 == f8_local3 then
        if f8_local6 <= 50 then
            f8_local5 = f8_local1
        else
            f8_local5 = f8_local2
        end
    elseif f8_local6 <= 33 then
        f8_local5 = f8_local1
    elseif f8_local6 <= 66 then
        f8_local5 = f8_local2
    else
        f8_local5 = f8_local3
    end
    if f8_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 30) then
        f8_arg1:AddSubGoal(GOAL_COMMON_Turn, 2, TARGET_ENE_0, 30)
    end
    local f8_local7 = 9999 - f8_arg0:GetMapHitRadius(TARGET_SELF)
    local f8_local8 = 0
    local f8_local9 = 0
    if f8_local5 == f8_local3 then
        f8_arg1:AddSubGoal(GOAL_COMMON_WaitWithAnime, 20, f8_local5, TARGET_ENE_0)
    else
        f8_arg1:AddSubGoal(GOAL_COMMON_WaitWithAnime, 20, f8_local5, TARGET_ENE_0):TimingSetNumber(4, 1, AI_TIMING_SET__UPDATE_SUCCESS)
    end
    f8_arg0:SetNumber(f8_local0, f8_local5)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act11 = function (f9_arg0, f9_arg1, f9_arg2)
    f9_arg0:SetNumber(0, 1)
    local f9_local0 = 20 - f9_arg0:GetMapHitRadius(TARGET_SELF)
    local f9_local1 = 20 - f9_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f9_local2 = 20 - f9_arg0:GetMapHitRadius(TARGET_SELF) + 1
    local f9_local3 = 0
    local f9_local4 = 0
    local f9_local5 = 1.5
    local f9_local6 = 4
    Approach_Act_Flex(f9_arg0, f9_arg1, f9_local0, f9_local1, f9_local2, f9_local3, f9_local4, f9_local5, f9_local6)
    local f9_local7 = 3006
    local f9_local8 = 3007
    local f9_local9 = 99 - f9_arg0:GetMapHitRadius(TARGET_SELF) + 1
    local f9_local10 = 9999 - f9_arg0:GetMapHitRadius(TARGET_SELF)
    local f9_local11 = 0
    local f9_local12 = 0
    local f9_local13 = f9_arg0:GetRandam_Int(1, 100)
    f9_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, f9_local7, TARGET_ENE_0, f9_local9, f9_local11, f9_local12, 0, 0)
    f9_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, f9_local8, TARGET_ENE_0, f9_local10, 0, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act12 = function (f10_arg0, f10_arg1, f10_arg2)
    f10_arg0:SetNumber(1, 1)
    local f10_local0 = 20 - f10_arg0:GetMapHitRadius(TARGET_SELF)
    local f10_local1 = 20 - f10_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f10_local2 = 20 - f10_arg0:GetMapHitRadius(TARGET_SELF) + 1
    local f10_local3 = 100
    local f10_local4 = 0
    local f10_local5 = 1.5
    local f10_local6 = 4
    Approach_Act_Flex(f10_arg0, f10_arg1, f10_local0, f10_local1, f10_local2, f10_local3, f10_local4, f10_local5, f10_local6)
    local f10_local7 = 3006
    local f10_local8 = 3007
    local f10_local9 = 99 - f10_arg0:GetMapHitRadius(TARGET_SELF) + 1
    local f10_local10 = 9999 - f10_arg0:GetMapHitRadius(TARGET_SELF)
    local f10_local11 = 0
    local f10_local12 = 0
    local f10_local13 = f10_arg0:GetRandam_Int(1, 100)
    f10_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, f10_local7, TARGET_ENE_0, f10_local9, f10_local11, f10_local12, 0, 0)
    f10_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, f10_local8, TARGET_ENE_0, f10_local10, 0, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act13 = function (f11_arg0, f11_arg1, f11_arg2)
    local f11_local0 = 99 - f11_arg0:GetMapHitRadius(TARGET_SELF)
    local f11_local1 = 99 - f11_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f11_local2 = 99 - f11_arg0:GetMapHitRadius(TARGET_SELF) + 1
    local f11_local3 = 100
    local f11_local4 = 0
    local f11_local5 = 1.5
    local f11_local6 = 4
    Approach_Act_Flex(f11_arg0, f11_arg1, f11_local0, f11_local1, f11_local2, f11_local3, f11_local4, f11_local5, f11_local6)
    local f11_local7 = 3007
    local f11_local8 = 9999 - f11_arg0:GetMapHitRadius(TARGET_SELF)
    local f11_local9 = 0
    local f11_local10 = 0
    f11_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f11_local7, TARGET_ENE_0, f11_local8, f11_local9, f11_local10, 0, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act14 = function (f12_arg0, f12_arg1, f12_arg2)
    f12_arg0:SetNumber(2, f12_arg0:GetNumber(2) + 1)
    local f12_local0 = 99 - f12_arg0:GetMapHitRadius(TARGET_SELF)
    local f12_local1 = 99 - f12_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f12_local2 = 99 - f12_arg0:GetMapHitRadius(TARGET_SELF) + 1
    local f12_local3 = 100
    local f12_local4 = 0
    local f12_local5 = 1.5
    local f12_local6 = 4
    Approach_Act_Flex(f12_arg0, f12_arg1, f12_local0, f12_local1, f12_local2, f12_local3, f12_local4, f12_local5, f12_local6)
    local f12_local7 = 3007
    local f12_local8 = 9999 - f12_arg0:GetMapHitRadius(TARGET_SELF)
    local f12_local9 = 0
    local f12_local10 = 0
    f12_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f12_local7, TARGET_ENE_0, f12_local8, f12_local9, f12_local10, 0, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act20 = function (f13_arg0, f13_arg1, f13_arg2)
    f13_arg1:AddSubGoal(GOAL_COMMON_Turn, 2, TARGET_ENE_0, 90)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act21 = function (f14_arg0, f14_arg1, f14_arg2)
    local f14_local0 = 3
    local f14_local1 = 0
    local f14_local2 = 6
    if SpaceCheck(f14_arg0, f14_arg1, -45, 5) == true then
        if SpaceCheck(f14_arg0, f14_arg1, 45, 5) == true then
            if f14_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                f14_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f14_local0, 5202, TARGET_ENE_0, f14_local1, AI_DIR_TYPE_L, 0):TimingSetTimer(1, 2, AI_TIMING_SET__ACTIVATE)
            else
                f14_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f14_local0, 5203, TARGET_ENE_0, f14_local1, AI_DIR_TYPE_R, 0):TimingSetTimer(1, 2, AI_TIMING_SET__ACTIVATE)
            end
        else
            f14_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f14_local0, 5202, TARGET_ENE_0, f14_local1, AI_DIR_TYPE_L, 0):TimingSetTimer(1, 2, AI_TIMING_SET__ACTIVATE)
        end
    elseif SpaceCheck(f14_arg0, f14_arg1, 45, 5) == true then
        f14_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f14_local0, 5203, TARGET_ENE_0, f14_local1, AI_DIR_TYPE_R, 0):TimingSetTimer(1, 2, AI_TIMING_SET__ACTIVATE)
    else
        f14_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f14_local0, 5202, TARGET_ENE_0, f14_local1, AI_DIR_TYPE_L, 0):TimingSetTimer(1, 2, AI_TIMING_SET__ACTIVATE)
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act24 = function (f15_arg0, f15_arg1, f15_arg2)
    local f15_local0 = f15_arg0:GetDist(TARGET_ENE_0)
    local f15_local1 = 3
    local f15_local2 = 0
    local f15_local3 = f15_arg0:GetRandam_Int(1, 100)
    if f15_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 30) then
        f15_arg1:AddSubGoal(GOAL_COMMON_Turn, 2, TARGET_ENE_0, 30)
    end
    if SpaceCheck(f15_arg0, f15_arg1, 180, 5) == true then
        if SpaceCheck(f15_arg0, f15_arg1, 180, 5) == true then
            if f15_local0 > 4 then
                if f15_local3 <= 50 then
                    f15_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3010, TARGET_ENE_0, 9999, 0, 0, 0, 0):TimingSetTimer(1, 2, AI_TIMING_SET__ACTIVATE)
                else
                    f15_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3011, TARGET_ENE_0, 9999, 0, 0, 0, 0):TimingSetTimer(1, 2, AI_TIMING_SET__ACTIVATE)
                end
            elseif f15_local3 <= 50 then
                f15_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f15_local1, 5201, TARGET_ENE_0, f15_local2, AI_DIR_TYPE_B, 0):TimingSetTimer(1, 2, AI_TIMING_SET__ACTIVATE)
            else
                f15_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f15_local1, 5211, TARGET_ENE_0, f15_local2, AI_DIR_TYPE_B, 0):TimingSetTimer(1, 2, AI_TIMING_SET__ACTIVATE)
            end
        elseif f15_local3 <= 50 then
            f15_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3010, TARGET_ENE_0, 9999, 0, 0, 0, 0):TimingSetTimer(1, 2, AI_TIMING_SET__ACTIVATE)
        else
            f15_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3011, TARGET_ENE_0, 9999, 0, 0, 0, 0):TimingSetTimer(1, 2, AI_TIMING_SET__ACTIVATE)
        end
    else
        f15_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3010, TARGET_ENE_0, 9999, 0, 0, 0, 0):TimingSetTimer(1, 2, AI_TIMING_SET__ACTIVATE)
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act26 = function (f16_arg0, f16_arg1, f16_arg2)
    f16_arg1:AddSubGoal(GOAL_COMMON_Wait, 0.5, TARGET_ENE_0, 0, 0, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act27 = function (f17_arg0, f17_arg1, f17_arg2)
    if YousumiAct_SubGoal(f17_arg0, f17_arg1, false, 60, 30) == false then
        GetWellSpace_Odds = 0
        return GetWellSpace_Odds
    end
    local f17_local0 = 3002
    local f17_local1 = 9999 - f17_arg0:GetMapHitRadius(TARGET_SELF)
    local f17_local2 = 0
    local f17_local3 = 0
    local f17_local4 = f17_arg0:GetRandam_Int(1, 100)
    f17_arg1:AddSubGoal(GOAL_COMMON_Turn, 2, TARGET_ENE_0, 90)
    if f17_local4 <= 33 then
        f17_local0 = 3003
        f17_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f17_local0, TARGET_ENE_0, f17_local1, f17_local2, f17_local3, 0, 0)
    elseif f17_local4 <= 67 then
        f17_local0 = 3004
        f17_arg1:AddSubGoal(GOAL_COMMON_WaitWithAnime, 20, f17_local0, TARGET_ENE_0)
    else
        f17_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f17_local0, TARGET_ENE_0, f17_local1, f17_local2, f17_local3, 0, 0)
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act31 = function (f18_arg0, f18_arg1, f18_arg2)
    local f18_local0 = f18_arg0:GetDist(TARGET_ENE_0)
    local f18_local1 = 9999
    local f18_local2 = 0
    local f18_local3 = 0
    local f18_local4 = f18_arg0:GetRandam_Int(1, 100)
    local f18_local5 = f18_arg0:GetRandam_Float(0.8, 1.5)
    local f18_local6 = 3
    if SpaceCheck(f18_arg0, f18_arg1, 90, 5) then
        if SpaceCheck(f18_arg0, f18_arg1, -90, 5) then
            if f18_arg0:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_R, 180, 9999) then
                f18_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f18_local5, TARGET_ENE_0, 0, TARGET_SELF, false, -1, AI_DIR_TYPE_ToR, 10):TimingSetNumber(6, 1, AI_TIMING_SET__ACTIVATE)
            else
                f18_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f18_local5, TARGET_ENE_0, 0, TARGET_SELF, false, -1, AI_DIR_TYPE_ToL, 10):TimingSetNumber(6, 1, AI_TIMING_SET__ACTIVATE)
            end
        else
            f18_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f18_local5, TARGET_ENE_0, 0, TARGET_SELF, false, -1, AI_DIR_TYPE_ToR, 10):TimingSetNumber(6, 1, AI_TIMING_SET__ACTIVATE)
        end
    elseif SpaceCheck(f18_arg0, f18_arg1, -90, 5) then
        f18_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, f18_local5, TARGET_ENE_0, 0, TARGET_SELF, false, -1, AI_DIR_TYPE_ToL, 10):TimingSetNumber(6, 1, AI_TIMING_SET__ACTIVATE)
    else
        f18_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3003, TARGET_ENE_0, f18_local1, f18_local2, f18_local3, 0, 0)
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act32 = function (f19_arg0, f19_arg1, f19_arg2)
    local f19_local0 = 0
    local f19_local1 = 3
    if f19_arg0:IsInsideTargetEx(TARGET_SELF, TARGET_ENE_0, AI_DIR_TYPE_R, 180, 9999) then
        f19_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f19_local1, 5202, TARGET_ENE_0, f19_local0, AI_DIR_TYPE_L, 0):TimingSetTimer(1, 3, AI_TIMING_SET__ACTIVATE)
    else
        f19_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f19_local1, 5203, TARGET_ENE_0, f19_local0, AI_DIR_TYPE_R, 0):TimingSetTimer(1, 3, AI_TIMING_SET__ACTIVATE)
    end
    f19_arg0:SetNumber(6, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act33 = function (f20_arg0, f20_arg1, f20_arg2)
    f20_arg0:SetNumber(7, 0)
    local f20_local0 = 5.8 - f20_arg0:GetMapHitRadius(TARGET_SELF)
    local f20_local1 = 5.8 - f20_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f20_local2 = 5.8 - f20_arg0:GetMapHitRadius(TARGET_SELF) + 1
    local f20_local3 = 100
    local f20_local4 = 0
    local f20_local5 = 1.5
    local f20_local6 = 4
    local f20_local7 = 3000
    local f20_local8 = 3001
    local f20_local9 = 9999 - f20_arg0:GetMapHitRadius(TARGET_SELF)
    local f20_local10 = 0
    local f20_local11 = 0
    local f20_local12 = f20_arg0:GetRandam_Int(1, 100)
    local f20_local13 = f20_arg0:GetRandam_Float(1.2, 2)
    local f20_local14 = 3
    Approach_Act_Flex(f20_arg0, f20_arg1, f20_local0, f20_local1, f20_local2, f20_local3, f20_local4, f20_local5, f20_local6)
    if f20_local12 <= 50 then
        f20_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f20_local7, TARGET_ENE_0, f20_local9, f20_local10, f20_local11, 0, 0)
    else
        f20_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f20_local8, TARGET_ENE_0, f20_local9, f20_local10, f20_local11, 0, 0)
    end
    if f20_arg0:IsExistMeshOnLine(TARGET_ENE_0, AI_DIR_TYPE_ToF, 3) then
        f20_arg1:AddSubGoal(GOAL_COMMON_ApproachSettingDirection, 0.5, TARGET_SELF, 0, TARGET_SELF, false, -1, AI_DIR_TYPE_F, 5):TimingSetNumber(6, 1, AI_TIMING_SET__ACTIVATE)
    else
    end
    f20_arg0:SetTimer(0, 5)
    
end

Goal.Act34 = function (f21_arg0, f21_arg1, f21_arg2)
    f21_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 3, TARGET_ENE_0, 10, TARGET_SELF, false, -1)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act41 = function (f22_arg0, f22_arg1, f22_arg2)
    local f22_local0 = 18
    local f22_local1 = 18 + 2
    local f22_local2 = 18 + 2
    local f22_local3 = 0
    local f22_local4 = 0
    local f22_local5 = 1.5
    local f22_local6 = 3
    local f22_local7 = f22_arg0:GetDist(TARGET_ENE_0)
    Approach_Act_Flex(f22_arg0, f22_arg1, f22_local0, f22_local1, f22_local2, f22_local3, f22_local4, f22_local5, f22_local6)
    local f22_local8 = f22_arg0:GetRandam_Int(1, 100)
    if f22_local8 <= 80 then
        f22_arg1:AddSubGoal(GOAL_COMMON_WaitWithAnime, 20, 3004, TARGET_ENE_0)
    else
        f22_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3003, TARGET_ENE_0, 999, 0, 0, 0, 0)
    end
    f22_arg0:AddObserveArea(0, TARGET_SELF, TARGET_ENE_0, AI_DIR_TYPE_F, 180, 5)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act42 = function (f23_arg0, f23_arg1, f23_arg2)
    local f23_local0 = 18
    local f23_local1 = 18 + 2
    local f23_local2 = 18 + 2
    local f23_local3 = 0
    local f23_local4 = 0
    local f23_local5 = 1.5
    local f23_local6 = 3
    local f23_local7 = f23_arg0:GetDist(TARGET_ENE_0)
    Approach_Act_Flex(f23_arg0, f23_arg1, f23_local0, f23_local1, f23_local2, f23_local3, f23_local4, f23_local5, f23_local6)
    local f23_local8 = f23_arg0:GetRandam_Int(1, 100)
    local f23_local9 = 0
    local f23_local10 = SpaceCheck_SidewayMove(f23_arg0, f23_arg1, 2)
    if f23_local10 == 0 then
        f23_local9 = 0
    elseif f23_local10 == 1 then
        f23_local9 = 1
    elseif f23_local10 == 2 then
        if f23_arg0:HasSpecialEffectId(TARGET_SELF, 5025) then
            f23_local9 = 0
        elseif f23_arg0:HasSpecialEffectId(TARGET_SELF, 5026) then
            f23_local9 = 1
        elseif f23_local8 <= 50 then
            f23_local9 = 0
        else
            f23_local9 = 1
        end
    else
        f23_arg1:AddSubGoal(GOAL_COMMON_Wait, 1, TARGET_SELF, 0, 0, 0)
        GetWellSpace_Odds = 0
        return GetWellSpace_Odds
    end
    local f23_local11 = 3012
    if f23_local9 == 0 then
        f23_local11 = 3013
    end
    f23_arg1:AddSubGoal(GOAL_COMMON_WaitWithAnime, 20, f23_local11, TARGET_ENE_0)
    f23_arg0:AddObserveArea(0, TARGET_SELF, TARGET_ENE_0, AI_DIR_TYPE_F, 180, 5)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.ActAfter_AdjustSpace = function (f24_arg0, f24_arg1, f24_arg2)
    
end

Goal.Update = function (f25_arg0, f25_arg1, f25_arg2)
    return Update_Default_NoSubGoal(f25_arg0, f25_arg1, f25_arg2)
    
end

Goal.Terminate = function (f26_arg0, f26_arg1, f26_arg2)
    
end

Goal.Interrupt = function (f27_arg0, f27_arg1, f27_arg2)
    local f27_local0 = f27_arg1:GetDist(TARGET_ENE_0)
    local f27_local1 = f27_arg1:GetRandam_Int(1, 100)
    local f27_local2 = f27_arg1:GetSpecialEffectActivateInterruptType(0)
    if f27_arg1:IsLadderAct(TARGET_SELF) then
        return false
    end
    if f27_arg1:IsInterupt(INTERUPT_MovedEnd_OnFailedPath) then
        f27_arg2:ClearSubGoal()
        if f27_arg1:IsInsideTargetEx(TARGET_SELF, TARGET_ENE_0, AI_DIR_TYPE_R, 180, 9999) then
            f27_arg2:AddSubGoal(GOAL_COMMON_SpinStep, 1, 5202, TARGET_ENE_0, 0, AI_DIR_TYPE_L, 0):TimingSetTimer(1, 3, AI_TIMING_SET__ACTIVATE)
        else
            f27_arg2:AddSubGoal(GOAL_COMMON_SpinStep, 1, 5203, TARGET_ENE_0, 0, AI_DIR_TYPE_R, 0):TimingSetTimer(1, 3, AI_TIMING_SET__ACTIVATE)
        end
        return true
    end
    if f27_arg1:IsInterupt(INTERUPT_ParryTiming) then
        return f27_arg0.Parry(f27_arg1, f27_arg2)
    end
    if f27_arg1:IsInterupt(INTERUPT_Inside_ObserveArea) and f27_arg1:IsInsideObserve(0) then
        f27_arg1:SetNumber(8, 1)
        f27_arg1:Replanning()
        return true
    end
    if f27_arg1:IsInterupt(INTERUPT_ActivateSpecialEffect) then
        if f27_local2 == 3109001 and f27_arg1:IsFinishTimer(0) then
            if f27_arg1:HasSpecialEffectId(TARGET_SELF, 3115020) == false then
                f27_arg1:SetNumber(7, 1)
                f27_arg1:Replanning()
                return true
            end
        elseif f27_local2 == 3147000 then
            f27_arg1:Replanning()
            return true
        elseif f27_local2 == 109221 then
            f27_arg1:Replanning()
            return true
        end
    end
    if f27_arg1:IsInterupt(INTERUPT_InactivateSpecialEffect) and f27_arg1:GetSpecialEffectInactivateInterruptType(0) == 109220 then
        f27_arg1:Replanning()
        return true
    end
    return false
    
end

Goal.Parry = function (f28_arg0, f28_arg1, f28_arg2)
    local f28_local0 = f28_arg0:GetRandam_Int(1, 100)
    local f28_local1 = f28_arg0:GetDist(TARGET_ENE_0)
    if f28_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) and f28_arg0:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_F, 90, 5) and SpaceCheck(f28_arg0, f28_arg1, 180, 5) == true then
        if SpaceCheck(f28_arg0, f28_arg1, 180, 5) == true then
            if f28_local1 > 4 then
                f28_arg1:ClearSubGoal()
                if f28_local0 <= 50 then
                    f28_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3010, TARGET_ENE_0, 9999, 0)
                else
                    f28_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3011, TARGET_ENE_0, 9999, 0)
                end
            else
                f28_arg1:ClearSubGoal()
                if f28_local0 <= 50 then
                    f28_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 5201, TARGET_ENE_0, 9999, 0)
                else
                    f28_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 5211, TARGET_ENE_0, 9999, 0)
                end
            end
        else
            f28_arg1:ClearSubGoal()
            if f28_local0 <= 50 then
                f28_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3010, TARGET_ENE_0, 9999, 0)
            else
                f28_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3011, TARGET_ENE_0, 9999, 0)
            end
        end
        f28_arg0:SetTimer(3, 2)
        return true
    else
    end
    return false
    
end


