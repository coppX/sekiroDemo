RegisterTableGoal(GOAL_Otyou_509000_Battle, "GOAL_Otyou_509000_Battle")
REGISTER_GOAL_NO_UPDATE(GOAL_Otyou_509000_Battle, true)

Goal.Initialize = function (f1_arg0, f1_arg1, f1_arg2, f1_arg3)
    
end

Goal.Activate = function (f2_arg0, f2_arg1, f2_arg2)
    Init_Pseudo_Global(f2_arg1, f2_arg2)
    Set_ConsecutiveGuardCount_Interrupt(f2_arg1)
    if f2_arg0.Kengeki_Activate(f2_arg0, f2_arg1, f2_arg2) then
        return
    end
    local f2_local0 = {}
    local f2_local1 = {}
    local f2_local2 = {}
    Common_Clear_Param(f2_local0, f2_local1, f2_local2)
    local f2_local3 = f2_arg1:GetDist(TARGET_ENE_0)
    local f2_local4 = f2_arg1:GetDistXZ(TARGET_ENE_0)
    local f2_local5 = f2_arg1:GetExcelParam(AI_EXCEL_THINK_PARAM_TYPE__thinkAttr_doAdmirer)
    local f2_local6 = f2_arg1:GetHpRate(TARGET_SELF)
    local f2_local7 = f2_arg1:GetSpRate(TARGET_SELF)
    local f2_local8 = f2_arg1:GetRandam_Int(15, 20)
    local f2_local9 = f2_arg1:GetEventRequest()
    local f2_local10 = f2_arg1:GetRandam_Int(1, 100)
    f2_arg1:DeleteObserve(0)
    f2_arg1:DeleteObserve(1)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 200200)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 200201)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 200205)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 200206)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 200210)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 200211)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 200215)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 200216)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 200225)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 200226)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 200227)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 200228)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 5027)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 5029)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 5030)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 5031)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 200060)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 200061)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 200231)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 3509020)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 3509030)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 3509070)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 3509100)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 3509110)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 109031)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 3531)
    if f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 109900) then
        f2_arg1:SetNumber(6, 10)
    else
        f2_arg1:SetNumber(6, 1)
    end
    if f2_arg1:HasSpecialEffectId(TARGET_SELF, 5028) then
        f2_local0[38] = 100
    elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 5033) then
        if f2_local4 >= 5 then
            f2_local0[41] = 100
        elseif f2_arg1:IsExistMeshOnLine(TARGET_ENE_0, AI_DIR_TYPE_ToF, 2) == true then
            f2_local0[42] = 100
        else
            f2_local0[41] = 100
        end
    elseif f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 110010) or f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 110060) then
        if f2_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) then
            f2_local0[28] = 100
        else
            f2_local0[21] = 100
        end
    elseif Common_ActivateAct(f2_arg1, f2_arg2, 0, 1) then
    elseif f2_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_B, 90) then
        f2_local0[21] = 1
        f2_local0[24] = 100
        f2_local0[29] = 0
    else
        if f2_arg1:GetTimer(10) > 0 then
            f2_local0[3] = 100
            f2_local0[4] = 100
            f2_local0[18] = 100
            if f2_local3 <= 6 then
                f2_local0[37] = 100
            end
        end
        if f2_arg1:HasSpecialEffectId(TARGET_ENE_0, COMMON_SP_EFFECT_PC_BREAK) then
            if f2_local3 >= 8 then
                f2_local0[19] = 100
            elseif f2_local3 >= 6 then
                f2_local0[5] = 200
                f2_local0[37] = 100
            elseif f2_local3 > 4 then
                f2_local0[16] = 100
            else
                f2_local0[1] = 150
                f2_local0[4] = 200
            end
        elseif f2_arg1:GetNumber(1) >= 20 then
            f2_local0[23] = 100
            f2_arg1:SetTimer(4, 3)
            f2_arg1:SetNumber(1, 0)
        elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 200051) and f2_arg1:HasSpecialEffectId(TARGET_SELF, 200060) and f2_arg1:IsFinishTimer(0) == true and f2_arg1:IsFinishTimer(6) == true and f2_local9 == -1 then
            if f2_arg1:HasSpecialEffectId(TARGET_SELF, 5031) then
                f2_local0[8] = 100
            elseif f2_local3 >= 7 then
                f2_local0[8] = 100
            else
                f2_local0[14] = 100
            end
        elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 200051) and f2_arg1:IsFinishTimer(6) == true and not f2_arg1:HasSpecialEffectId(TARGET_SELF, 5020) then
            if f2_local3 >= 7 then
                f2_local0[7] = 100
            else
                f2_local0[11] = 100
            end
        elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 200051) and (f2_local6 <= 0.6 or f2_local7 <= 0.8) and f2_arg1:IsFinishTimer(0) == true and f2_arg1:IsFinishTimer(6) == true and not f2_arg1:HasSpecialEffectId(TARGET_SELF, 200060) then
            if f2_local3 >= 7 then
                f2_local0[7] = 100
            else
                f2_local0[11] = 100
            end
        elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 5032) then
            f2_local0[5] = 100
        elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 3509070) then
            if f2_local3 >= 15 then
                f2_local0[20] = 100
            elseif f2_local3 >= 10 then
                f2_local0[22] = 1
                f2_local0[23] = 100
            elseif f2_local3 > 3 then
                f2_local0[21] = 1
                f2_local0[25] = 100
            else
                f2_local0[21] = 1
                f2_local0[24] = 1
                f2_local0[25] = 10
            end
        elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 200060) then
            if f2_arg1:HasSpecialEffectId(TARGET_SELF, 5031) then
                f2_local0[30] = 100
                if f2_local3 >= 5 then
                    f2_local0[43] = 200
                end
            elseif f2_local3 >= 10 then
                f2_local0[12] = 100
                f2_local0[22] = 1
                f2_local0[23] = 100
                f2_local0[32] = 300
            elseif f2_local3 > 3 then
                f2_local0[21] = 1
                f2_local0[23] = 100
                f2_local0[25] = 1
                f2_local0[19] = 100
                f2_local0[32] = 500
            else
                f2_local0[1] = 30
                f2_local0[3] = 50
                f2_local0[4] = 50
                f2_local0[10] = 50
                f2_local0[21] = 1
                f2_local0[24] = 200
                f2_local0[25] = 100
                f2_local0[32] = 300
            end
        else
            if f2_arg1:GetNumber(3) >= 3 then
                if f2_local3 > 10 then
                    f2_local0[20] = 100
                else
                    f2_local0[2] = 100
                    f2_local0[5] = 100
                    f2_local0[15] = 100
                    f2_local0[37] = 100
                end
            elseif f2_local3 >= 7 then
                f2_local0[3] = 100
                f2_local0[9] = 100 * f2_arg1:GetNumber(6)
                f2_local0[12] = 100
                f2_local0[18] = 100
                f2_local0[19] = 100 * f2_arg1:GetNumber(6)
                f2_local0[23] = 450
            elseif f2_local3 >= 5 then
                f2_local0[1] = 150
                f2_local0[3] = 150
                f2_local0[4] = 150
                f2_local0[5] = 150
                f2_local0[12] = 100
                f2_local0[16] = 150
                f2_local0[19] = 100 * f2_arg1:GetNumber(6)
                f2_local0[23] = 150
                if f2_arg1:IsFinishTimer(3) == true then
                    f2_local0[24] = 100
                end
                if f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 109900) then
                    f2_local0[9] = 500
                end
            elseif f2_local3 > 3 then
                f2_local0[1] = 150
                f2_local0[3] = 150
                f2_local0[4] = 150
                f2_local0[5] = 1
                f2_local0[16] = 150
                f2_local0[23] = 1
                if f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 109900) then
                    f2_local0[9] = 300
                end
            else
                f2_local0[1] = 150
                f2_local0[3] = 200
                f2_local0[4] = 200
                f2_local0[5] = 1
                f2_local0[10] = 200
                f2_local0[16] = 100
                f2_local0[23] = 1
                if f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 110623) then
                    f2_local0[6] = 400
                    f2_local0[45] = 600
                end
            end
            if not f2_arg1:IsExistMeshOnLine(TARGET_SELF, AI_DIR_TYPE_B, 3) then
                f2_local0[23] = 50
                f2_local0[24] = 0
            end
        end
    end
    if f2_arg1:HasSpecialEffectId(TARGET_SELF, 200030) then
        f2_local0[1] = 0
    end
    if f2_arg1:HasSpecialEffectId(TARGET_SELF, 5031) then
        f2_local0[1] = 0
        f2_local0[3] = 0
        f2_local0[4] = 0
        f2_local0[9] = 0
        f2_local0[10] = 0
        f2_local0[12] = 0
        f2_local0[13] = 0
        f2_local0[20] = 0
        f2_local0[21] = 0
        f2_local0[22] = 0
        f2_local0[23] = 0
        f2_local0[24] = 0
        f2_local0[32] = 0
    end
    if not f2_arg1:HasSpecialEffectId(TARGET_SELF, 5031) then
        f2_local0[30] = 0
        f2_local0[31] = 0
    end
    if f2_arg1:IsFinishTimer(2) == false then
        f2_local0[23] = 1
    end
    if f2_arg1:IsFinishTimer(3) == false then
        f2_local0[32] = 0
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
    if SpaceCheck(f2_arg1, f2_arg2, 180, 2) == false then
        f2_local0[25] = 0
    end
    if not f2_arg1:IsFinishTimer(7) then
        f2_local0[16] = 0
    end
    if f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 109900) then
        f2_local0[16] = 0
        f2_local0[37] = 0
    end
    f2_local0[1] = SetCoolTime(f2_arg1, f2_arg2, 3021, 15, f2_local0[1], 1)
    f2_local0[1] = SetCoolTime(f2_arg1, f2_arg2, 3222, 5, f2_local0[1], 400)
    f2_local0[2] = SetCoolTime(f2_arg1, f2_arg2, 3022, 10, f2_local0[2], 1)
    f2_local0[3] = SetCoolTime(f2_arg1, f2_arg2, 3000, 13, f2_local0[3], 1)
    f2_local0[4] = SetCoolTime(f2_arg1, f2_arg2, 3004, 13, f2_local0[4], 1)
    f2_local0[5] = SetCoolTime(f2_arg1, f2_arg2, 3024, 13, f2_local0[5], 1)
    f2_local0[7] = SetCoolTime(f2_arg1, f2_arg2, 3018, 10, f2_local0[7], 1)
    f2_local0[8] = SetCoolTime(f2_arg1, f2_arg2, 3019, 10, f2_local0[8], 1)
    f2_local0[9] = SetCoolTime(f2_arg1, f2_arg2, 3013, 10, f2_local0[9], 1)
    f2_local0[10] = SetCoolTime(f2_arg1, f2_arg2, 3008, 10, f2_local0[10], 1)
    f2_local0[10] = SetCoolTime(f2_arg1, f2_arg2, 3222, 3, f2_local0[10], 300)
    f2_local0[12] = SetCoolTime(f2_arg1, f2_arg2, 3016, 10, f2_local0[12], 1)
    f2_local0[13] = SetCoolTime(f2_arg1, f2_arg2, 3016, 5, f2_local0[13], 1)
    f2_local0[16] = SetCoolTime(f2_arg1, f2_arg2, 3240, f2_local8, f2_local0[16], 1)
    f2_local0[18] = SetCoolTime(f2_arg1, f2_arg2, 3033, 10, f2_local0[18], 1)
    f2_local0[18] = SetCoolTime(f2_arg1, f2_arg2, 3222, 3, f2_local0[18], 500)
    f2_local0[19] = SetCoolTime(f2_arg1, f2_arg2, 3032, 10, f2_local0[19], 1)
    f2_local0[15] = SetCoolTime(f2_arg1, f2_arg2, 3024, 10, f2_local0[15], 1)
    f2_local0[17] = SetCoolTime(f2_arg1, f2_arg2, 3024, 10, f2_local0[17], 1)
    f2_local0[22] = SetCoolTime(f2_arg1, f2_arg2, 5202, 5, f2_local0[22], 1)
    f2_local0[22] = SetCoolTime(f2_arg1, f2_arg2, 5203, 5, f2_local0[22], 1)
    f2_local0[34] = SetCoolTime(f2_arg1, f2_arg2, 3010, 5, f2_local0[34], 1)
    f2_local0[35] = SetCoolTime(f2_arg1, f2_arg2, 3028, 15, f2_local0[35], 1)
    f2_local0[35] = SetCoolTime(f2_arg1, f2_arg2, 3029, 15, f2_local0[35], 1)
    f2_local0[37] = SetCoolTime(f2_arg1, f2_arg2, 3023, 20, f2_local0[37], 1)
    f2_local0[43] = SetCoolTime(f2_arg1, f2_arg2, 3200, 20, f2_local0[43], 1)
    f2_local0[43] = SetCoolTime(f2_arg1, f2_arg2, 3030, 5, f2_local0[43], 1)
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
    f2_local1[32] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act32)
    f2_local1[34] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act34)
    f2_local1[35] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act35)
    f2_local1[36] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act36)
    f2_local1[37] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act37)
    f2_local1[38] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act38)
    f2_local1[40] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act40)
    f2_local1[41] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act41)
    f2_local1[42] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act42)
    f2_local1[43] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act43)
    f2_local1[45] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act45)
    local f2_local11 = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.ActAfter_AdjustSpace)
    Common_Battle_Activate(f2_arg1, f2_arg2, f2_local0, f2_local1, f2_local11, f2_local2)
    
end

Goal.Act01 = function (f3_arg0, f3_arg1, f3_arg2)
    local f3_local0 = 0
    local f3_local1 = 0
    if SpaceCheck(f3_arg0, f3_arg1, 180, 4) then
        f3_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 3, 5201, TARGET_ENE_0, f3_local0, AI_DIR_TYPE_B, 0)
    end
    f3_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3021, TARGET_ENE_0, 9999, f3_local0, f3_local1, 0, 0):TimingSetNumber(1, f3_arg0:GetNumber(1) + 10, AI_TIMING_SET__ACTIVATE):TimingSetNumber(3, f3_arg0:GetNumber(3) + 1, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act02 = function (f4_arg0, f4_arg1, f4_arg2)
    local f4_local0 = 2 - f4_arg0:GetMapHitRadius(TARGET_SELF)
    local f4_local1 = 2 - f4_arg0:GetMapHitRadius(TARGET_SELF)
    local f4_local2 = 2 - f4_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f4_local3 = 100
    local f4_local4 = 0
    local f4_local5 = 1.5
    local f4_local6 = 3
    local f4_local7 = f4_arg0:GetRandam_Int(1, 100)
    Approach_Act_Flex(f4_arg0, f4_arg1, f4_local0, f4_local1, f4_local2, f4_local3, f4_local4, f4_local5, f4_local6)
    local f4_local8 = 0
    local f4_local9 = 0
    f4_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3022, TARGET_ENE_0, 9999, f4_local8, f4_local9, 0, 0):TimingSetNumber(3, 0, AI_TIMING_SET__ACTIVATE)
    local f4_local10 = 3
    local f4_local11 = 0
    local f4_local12 = 5202
    if SpaceCheck(f4_arg0, f4_arg1, -90, 2) == true then
        if SpaceCheck(f4_arg0, f4_arg1, 90, 2) == true then
            if f4_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                f4_local12 = 3026
            else
                f4_local12 = 3027
            end
        else
            f4_local12 = 3027
        end
    elseif SpaceCheck(f4_arg0, f4_arg1, 45, 2) == true then
        f4_local12 = 3026
    else
        f4_local12 = 3025
    end
    f4_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, f4_local12, TARGET_ENE_0, 9999, 0)
    f4_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3200, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(1, f4_arg0:GetNumber(1) + 4, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act03 = function (f5_arg0, f5_arg1, f5_arg2)
    local f5_local0 = 5 - f5_arg0:GetMapHitRadius(TARGET_SELF)
    local f5_local1 = 5 - f5_arg0:GetMapHitRadius(TARGET_SELF)
    local f5_local2 = 5 - f5_arg0:GetMapHitRadius(TARGET_SELF) + 5
    local f5_local3 = 0
    local f5_local4 = 0
    local f5_local5 = 1.5
    local f5_local6 = 3
    Approach_Act_Flex(f5_arg0, f5_arg1, f5_local0, f5_local1, f5_local2, f5_local3, f5_local4, f5_local5, f5_local6)
    local f5_local7 = 2 - f5_arg0:GetMapHitRadius(TARGET_SELF)
    local f5_local8 = 3 - f5_arg0:GetMapHitRadius(TARGET_SELF)
    local f5_local9 = 0
    local f5_local10 = 0
    local f5_local11 = f5_arg0:GetRandam_Int(0, 1)
    f5_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3000, TARGET_ENE_0, f5_local7, f5_local9, f5_local10, 0, 0)
    f5_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3001, TARGET_ENE_0, f5_local8, 0):TimingSetNumber(3, f5_arg0:GetNumber(3) + 1, AI_TIMING_SET__ACTIVATE)
    f5_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3002, TARGET_ENE_0, 9999, 0)
    f5_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3003, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(1, f5_arg0:GetNumber(1) + 7, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act04 = function (f6_arg0, f6_arg1, f6_arg2)
    local f6_local0 = 3 - f6_arg0:GetMapHitRadius(TARGET_SELF)
    local f6_local1 = 3 - f6_arg0:GetMapHitRadius(TARGET_SELF)
    local f6_local2 = 3 - f6_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f6_local3 = 100
    local f6_local4 = 0
    local f6_local5 = 1.5
    local f6_local6 = 3
    Approach_Act_Flex(f6_arg0, f6_arg1, f6_local0, f6_local1, f6_local2, f6_local3, f6_local4, f6_local5, f6_local6)
    local f6_local7 = 3 - f6_arg0:GetMapHitRadius(TARGET_SELF)
    local f6_local8 = 3 - f6_arg0:GetMapHitRadius(TARGET_SELF)
    local f6_local9 = 3 - f6_arg0:GetMapHitRadius(TARGET_SELF)
    local f6_local10 = 0
    local f6_local11 = 0
    local f6_local12 = f6_arg0:GetRandam_Int(0, 1)
    f6_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3004, TARGET_ENE_0, f6_local7, f6_local10, f6_local11, 0, 0)
    f6_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3005, TARGET_ENE_0, f6_local8, 0)
    f6_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3006, TARGET_ENE_0, f6_local9, 0):TimingSetNumber(3, f6_arg0:GetNumber(3) + 1, AI_TIMING_SET__ACTIVATE)
    f6_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3007, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(1, f6_arg0:GetNumber(1) + 5, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act05 = function (f7_arg0, f7_arg1, f7_arg2)
    local f7_local0 = 0
    local f7_local1 = 0
    if f7_arg0:HasSpecialEffectId(TARGET_SELF, 5032) then
        f7_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3011, TARGET_ENE_0, 5, 0)
        f7_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3012, TARGET_ENE_0, 5, 0, 0):TimingSetNumber(1, f7_arg0:GetNumber(1) + 7, AI_TIMING_SET__ACTIVATE)
    else
        f7_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3024, TARGET_ENE_0, 999, f7_local0, f7_local1, 0, 0)
        f7_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3230, TARGET_ENE_0, 999, 0)
        f7_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3011, TARGET_ENE_0, 5, 0)
        f7_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3012, TARGET_ENE_0, 5, 0, 0):TimingSetNumber(1, f7_arg0:GetNumber(1) + 7, AI_TIMING_SET__ACTIVATE)
    end
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act06 = function (f8_arg0, f8_arg1, f8_arg2)
    local f8_local0 = 0
    local f8_local1 = 0
    local f8_local2 = f8_arg0:GetRandam_Int(0, 1)
    local f8_local3 = f8_arg0:GetRandam_Int(30, 45)
    f8_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 5, 3017, TARGET_ENE_0, 9999, f8_local0, f8_local1, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act07 = function (f9_arg0, f9_arg1, f9_arg2)
    local f9_local0 = 0
    local f9_local1 = 0
    local f9_local2 = f9_arg0:GetRandam_Int(0, 1)
    local f9_local3 = f9_arg0:GetRandam_Int(30, 45)
    f9_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 5, 3018, TARGET_ENE_0, 9999, f9_local0, f9_local1, 0, 0):TimingSetNumber(1, f9_arg0:GetNumber(1) + 3, AI_TIMING_SET__ACTIVATE):TimingSetTimer(6, 10, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act08 = function (f10_arg0, f10_arg1, f10_arg2)
    local f10_local0 = 0
    local f10_local1 = 0
    if f10_arg0:HasSpecialEffectId(TARGET_SELF, 5031) then
        f10_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 5, 3020, TARGET_ENE_0, 9999, f10_local0, f10_local1, 0, 0)
        f10_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3210, TARGET_ENE_0, 9999, 0, 0):TimingSetTimer(0, 60, AI_TIMING_SET__UPDATE_SUCCESS)
    else
        f10_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 5, 3019, TARGET_ENE_0, 9999, f10_local0, f10_local1, 0, 0):TimingSetTimer(0, 60, AI_TIMING_SET__UPDATE_SUCCESS)
    end
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act09 = function (f11_arg0, f11_arg1, f11_arg2)
    local f11_local0 = 7 - f11_arg0:GetMapHitRadius(TARGET_SELF)
    local f11_local1 = 7 - f11_arg0:GetMapHitRadius(TARGET_SELF)
    local f11_local2 = 7 - f11_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f11_local3 = 100
    local f11_local4 = 0
    local f11_local5 = 1.5
    local f11_local6 = 3
    Approach_Act_Flex(f11_arg0, f11_arg1, f11_local0, f11_local1, f11_local2, f11_local3, f11_local4, f11_local5, f11_local6)
    local f11_local7 = 2.5 - f11_arg0:GetMapHitRadius(TARGET_SELF)
    local f11_local8 = 0
    local f11_local9 = 0
    local f11_local10 = f11_arg0:GetRandam_Int(0, 1)
    f11_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3013, TARGET_ENE_0, f11_local7, f11_local8, f11_local9, 0, 0)
    if f11_local10 == 0 then
        f11_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3015, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(3, 0, AI_TIMING_SET__ACTIVATE)
        f11_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3200, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(1, f11_arg0:GetNumber(1) + 7, AI_TIMING_SET__ACTIVATE)
    else
        f11_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3014, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(1, f11_arg0:GetNumber(1) + 5, AI_TIMING_SET__ACTIVATE):TimingSetNumber(3, f11_arg0:GetNumber(3) + 1, AI_TIMING_SET__ACTIVATE)
    end
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act10 = function (f12_arg0, f12_arg1, f12_arg2)
    local f12_local0 = 2 - f12_arg0:GetMapHitRadius(TARGET_SELF)
    local f12_local1 = 2 - f12_arg0:GetMapHitRadius(TARGET_SELF)
    local f12_local2 = 2 - f12_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f12_local3 = 100
    local f12_local4 = 0
    local f12_local5 = 1.5
    local f12_local6 = 3
    Approach_Act_Flex(f12_arg0, f12_arg1, f12_local0, f12_local1, f12_local2, f12_local3, f12_local4, f12_local5, f12_local6)
    local f12_local7 = 3 - f12_arg0:GetMapHitRadius(TARGET_SELF)
    local f12_local8 = 2.5 - f12_arg0:GetMapHitRadius(TARGET_SELF)
    local f12_local9 = 0
    local f12_local10 = 0
    f12_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3008, TARGET_ENE_0, f12_local7, f12_local9, f12_local10, 0, 0):TimingSetNumber(3, f12_arg0:GetNumber(3) + 1, AI_TIMING_SET__ACTIVATE)
    f12_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3009, TARGET_ENE_0, f12_local8, 0)
    f12_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3010, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(1, f12_arg0:GetNumber(1) + 5, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act11 = function (f13_arg0, f13_arg1, f13_arg2)
    local f13_local0 = 0
    local f13_local1 = 0
    local f13_local2 = f13_arg0:GetRandam_Int(0, 1)
    local f13_local3 = f13_arg0:GetRandam_Int(30, 45)
    if SpaceCheck(f13_arg0, f13_arg1, 180, 4) then
        f13_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 3, 5201, TARGET_ENE_0, f13_local0, AI_DIR_TYPE_B, 0):TimingSetTimer(6, 10, AI_TIMING_SET__ACTIVATE):TimingSetTimer(1, 3, AI_TIMING_SET__UPDATE_SUCCESS)
        f13_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3018, TARGET_ENE_0, DistToAtt2, 0):TimingSetNumber(1, f13_arg0:GetNumber(1) + 5, AI_TIMING_SET__ACTIVATE)
    else
        f13_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3018, TARGET_ENE_0, DistToAtt2, 0):TimingSetNumber(1, f13_arg0:GetNumber(1) + 5, AI_TIMING_SET__ACTIVATE):TimingSetTimer(6, 10, AI_TIMING_SET__ACTIVATE):TimingSetTimer(1, 3, AI_TIMING_SET__UPDATE_SUCCESS)
    end
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act12 = function (f14_arg0, f14_arg1, f14_arg2)
    local f14_local0 = 0
    local f14_local1 = 0
    f14_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 5, 3016, TARGET_ENE_0, 9999, f14_local0, f14_local1, 0, 0):TimingSetNumber(1, f14_arg0:GetNumber(1) + 3, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act13 = function (f15_arg0, f15_arg1, f15_arg2)
    local f15_local0 = 0
    local f15_local1 = 0
    if SpaceCheck(f15_arg0, f15_arg1, 180, 4) then
        f15_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 3, 5201, TARGET_ENE_0, f15_local0, AI_DIR_TYPE_B, 0)
    end
    f15_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 5, 3016, TARGET_ENE_0, 9999, f15_local0, f15_local1, 0, 0):TimingSetNumber(1, f15_arg0:GetNumber(1) + 5, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act14 = function (f16_arg0, f16_arg1, f16_arg2)
    local f16_local0 = 0
    local f16_local1 = 0
    if SpaceCheck(f16_arg0, f16_arg1, 180, 4) then
        f16_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 3, 5201, TARGET_ENE_0, f16_local0, AI_DIR_TYPE_B, 0)
    end
    f16_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 5, 3019, TARGET_ENE_0, 9999, f16_local0, f16_local1, 0, 0):TimingSetTimer(0, 60, AI_TIMING_SET__UPDATE_SUCCESS)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act15 = function (f17_arg0, f17_arg1, f17_arg2)
    local f17_local0 = 0
    local f17_local1 = 0
    local f17_local2 = f17_arg0:GetRandam_Int(1, 3)
    f17_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3024, TARGET_ENE_0, 9999, f17_local0, f17_local1, 0, 0):TimingSetNumber(3, 0, AI_TIMING_SET__ACTIVATE)
    if f17_local2 == 1 then
        f17_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3025, TARGET_ENE_0, 9999, 0)
    elseif f17_local2 == 2 then
        f17_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3026, TARGET_ENE_0, 9999, 0)
    else
        f17_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3027, TARGET_ENE_0, 9999, 0)
    end
    f17_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3200, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(1, f17_arg0:GetNumber(1) + 5, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act16 = function (f18_arg0, f18_arg1, f18_arg2)
    local f18_local0 = 0
    local f18_local1 = 0
    f18_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3024, TARGET_ENE_0, 9999, f18_local0, f18_local1, 0, 0)
    f18_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3240, TARGET_ENE_0, 9999, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act17 = function (f19_arg0, f19_arg1, f19_arg2)
    local f19_local0 = 0
    local f19_local1 = 0
    local f19_local2 = f19_arg0:GetRandam_Int(1, 2)
    f19_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3030, TARGET_ENE_0, 9999, f19_local0, f19_local1, 0, 0)
    f19_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3220, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(1, f19_arg0:GetNumber(1) + 5, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act18 = function (f20_arg0, f20_arg1, f20_arg2)
    local f20_local0 = 0
    local f20_local1 = 0
    local f20_local2 = f20_arg0:GetRandam_Int(1, 2)
    f20_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3033, TARGET_ENE_0, 9999, f20_local0, f20_local1, 0, 0):TimingSetNumber(1, f20_arg0:GetNumber(1) + 5, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act19 = function (f21_arg0, f21_arg1, f21_arg2)
    local f21_local0 = 0
    local f21_local1 = 0
    local f21_local2 = f21_arg0:GetRandam_Int(1, 2)
    f21_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3032, TARGET_ENE_0, 9999, f21_local0, f21_local1, 0, 0):TimingSetNumber(1, f21_arg0:GetNumber(1) + 5, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act20 = function (f22_arg0, f22_arg1, f22_arg2)
    local f22_local0 = 9
    local f22_local1 = 9 + 8
    local f22_local2 = 9 + 10
    local f22_local3 = 0
    local f22_local4 = 0
    local f22_local5 = 1.5
    local f22_local6 = 2
    local f22_local7 = f22_arg0:GetDist(TARGET_ENE_0)
    if f22_arg0:HasSpecialEffectId(TARGET_SELF, 3509070) then
        f22_arg0:AddObserveArea(1, TARGET_SELF, TARGET_ENE_0, AI_DIR_TYPE_F, 360, 4)
    end
    if f22_arg0:HasSpecialEffectId(TAEGET_SELF, 200060) and f22_arg0:HasSpecialEffectId(TAEGET_SELF, 3509070) then
        f22_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 10, TARGET_ENE_0, f22_local0, TARGET_SELF, true, -1)
    else
        f22_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 10, TARGET_ENE_0, f22_local0, TARGET_SELF, false, -1)
    end
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act21 = function (f23_arg0, f23_arg1, f23_arg2)
    local f23_local0 = 3
    local f23_local1 = 45
    if f23_arg0:HasSpecialEffectId(TARGET_SELF, 3509070) then
        f23_arg0:AddObserveArea(1, TARGET_SELF, TARGET_ENE_0, AI_DIR_TYPE_F, 360, 4)
    end
    f23_arg1:AddSubGoal(GOAL_COMMON_Turn, f23_local0, TARGET_ENE_0, f23_local1, -1, GOAL_RESULT_Success, true)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act22 = function (f24_arg0, f24_arg1, f24_arg2)
    local f24_local0 = 3
    local f24_local1 = 0
    local f24_local2 = 5202
    if SpaceCheck(f24_arg0, f24_arg1, -45, 2) == true then
        if SpaceCheck(f24_arg0, f24_arg1, 45, 2) == true then
            if f24_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                f24_local2 = 5202
            else
                f24_local2 = 5203
            end
        else
            f24_local2 = 5202
        end
    elseif SpaceCheck(f24_arg0, f24_arg1, 45, 2) == true then
        f24_local2 = 5203
    else
    end
    if f24_arg0:HasSpecialEffectId(TARGET_SELF, 3509070) then
        f24_arg0:AddObserveArea(1, TARGET_SELF, TARGET_ENE_0, AI_DIR_TYPE_F, 360, 4)
    end
    f24_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f24_local0, f24_local2, TARGET_ENE_0, f24_local1, AI_DIR_TYPE_R, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act23 = function (f25_arg0, f25_arg1, f25_arg2)
    local f25_local0 = f25_arg0:GetDist(TARGET_ENE_0)
    local f25_local1 = -1
    local f25_local2 = 0
    if SpaceCheck(f25_arg0, f25_arg1, -90, 1) == true then
        if SpaceCheck(f25_arg0, f25_arg1, 90, 1) == true then
            if f25_arg0:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_R, 180, 999) then
                f25_local2 = 1
            else
                f25_local2 = 0
            end
        else
            f25_local2 = 0
        end
    elseif SpaceCheck(f25_arg0, f25_arg1, 90, 1) == true then
        f25_local2 = 1
    else
    end
    local f25_local3 = 2
    local f25_local4 = f25_arg0:GetRandam_Int(30, 45)
    f25_arg0:SetNumber(10, f25_local2)
    if f25_arg0:HasSpecialEffectId(TARGET_SELF, 3509070) then
        f25_arg0:AddObserveArea(1, TARGET_SELF, TARGET_ENE_0, AI_DIR_TYPE_F, 360, 4)
    end
    f25_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f25_local3, TARGET_ENE_0, f25_local2, f25_local4, true, true, f25_local1)
    f25_arg0:SetTimer(2, 5)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act24 = function (f26_arg0, f26_arg1, f26_arg2)
    local f26_local0 = f26_arg0:GetDist(TARGET_ENE_0)
    local f26_local1 = 3
    local f26_local2 = 0
    local f26_local3 = 5201
    if SpaceCheck(f26_arg0, f26_arg1, 180, 2) == true and SpaceCheck(f26_arg0, f26_arg1, 180, 4) == true and false then
    else
    end
    if f26_arg0:HasSpecialEffectId(TARGET_SELF, 3509070) then
        f26_arg0:AddObserveArea(1, TARGET_SELF, TARGET_ENE_0, AI_DIR_TYPE_F, 360, 4)
    end
    f26_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f26_local1, f26_local3, TARGET_ENE_0, f26_local2, AI_DIR_TYPE_B, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act25 = function (f27_arg0, f27_arg1, f27_arg2)
    local f27_local0 = 1
    local f27_local1 = 20
    local f27_local2 = f27_arg0:GetDist(TARGET_ENE_0)
    local f27_local3 = -1
    if f27_arg0:HasSpecialEffectId(TARGET_SELF, 3509070) then
        f27_arg0:AddObserveArea(1, TARGET_SELF, TARGET_ENE_0, AI_DIR_TYPE_F, 360, 4)
    end
    f27_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, f27_local0, TARGET_ENE_0, f27_local1, TARGET_ENE_0, true, f27_local3)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act26 = function (f28_arg0, f28_arg1, f28_arg2)
    f28_arg1:AddSubGoal(GOAL_COMMON_Wait, 0.5, TARGET_SELF, 0, 0, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act27 = function (f29_arg0, f29_arg1, f29_arg2)
    local f29_local0 = f29_arg0:GetDist(TARGET_ENE_0)
    local f29_local1 = f29_arg0:GetDistYSigned(TARGET_ENE_0)
    local f29_local2 = f29_local1 / math.tan(math.deg(30))
    local f29_local3 = f29_arg0:GetRandam_Int(0, 1)
    if f29_local1 >= 3 then
        if f29_local2 + 1 <= f29_local0 then
            if SpaceCheck(f29_arg0, f29_arg1, 0, 4) == true then
                f29_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.1, TARGET_ENE_0, f29_local2, TARGET_SELF, false, -1)
            elseif SpaceCheck(f29_arg0, f29_arg1, 0, 3) == true then
                f29_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.5, TARGET_ENE_0, f29_local2, TARGET_SELF, true, -1)
            end
        elseif f29_local0 <= f29_local2 - 1 then
            f29_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 10, TARGET_ENE_0, f29_local2, TARGET_ENE_0, true, -1)
        end
    elseif SpaceCheck(f29_arg0, f29_arg1, 0, 4) == true then
        f29_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.1, TARGET_ENE_0, 0, TARGET_SELF, false, -1)
    elseif SpaceCheck(f29_arg0, f29_arg1, 0, 3) == true then
        f29_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.5, TARGET_ENE_0, 0, TARGET_SELF, true, -1)
    elseif SpaceCheck(f29_arg0, f29_arg1, 0, 1) == false then
        f29_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 0.5, TARGET_ENE_0, 999, TARGET_ENE_0, true, -1)
    end
    f29_arg0:SetNumber(10, f29_local3)
    f29_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, 3, TARGET_ENE_0, f29_local3, f29_arg0:GetRandam_Int(30, 45), true, true, -1)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act28 = function (f30_arg0, f30_arg1, f30_arg2)
    local f30_local0 = f30_arg0:GetDist(TARGET_ENE_0)
    local f30_local1 = 1.5
    local f30_local2 = 1.5
    local f30_local3 = f30_arg0:GetRandam_Int(30, 45)
    local f30_local4 = -1
    local f30_local5 = f30_arg0:GetRandam_Int(0, 1)
    if f30_local0 <= 3 then
        f30_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f30_local1, TARGET_ENE_0, f30_local5, f30_local3, true, true, f30_local4)
    elseif f30_local0 <= 8 then
        f30_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, f30_local2, TARGET_ENE_0, 3, TARGET_SELF, true, -1)
    else
        f30_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, f30_local2, TARGET_ENE_0, 8, TARGET_SELF, false, -1)
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act29 = function (f31_arg0, f31_arg1, f31_arg2)
    local f31_local0 = 3
    local f31_local1 = 0
    local f31_local2 = 3
    if InsideRange(f31_arg0, f31_arg1, 90, 180, -9999, 9999) and f31_arg0:IsExistMeshOnLine(TARGET_SELF, AI_DIR_TYPE_L, 2) or InsideRange(f31_arg0, f31_arg1, -90, 180, -9999, 9999) and not f31_arg0:IsExistMeshOnLine(TARGET_SELF, AI_DIR_TYPE_R, 2) then
        f31_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f31_local0, 5202, TARGET_ENE_0, f31_local1, AI_DIR_TYPE_L, f31_local2)
    elseif InsideRange(f31_arg0, f31_arg1, -90, 180, -9999, 9999) and f31_arg0:IsExistMeshOnLine(TARGET_SELF, AI_DIR_TYPE_R, 2) or InsideRange(f31_arg0, f31_arg1, 90, 180, -9999, 9999) and not f31_arg0:IsExistMeshOnLine(TARGET_SELF, AI_DIR_TYPE_L, 2) then
        f31_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f31_local0, 5203, TARGET_ENE_0, f31_local1, AI_DIR_TYPE_R, f31_local2)
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act30 = function (f32_arg0, f32_arg1, f32_arg2)
    local f32_local0 = 0
    local f32_local1 = 3026
    local f32_local2 = 0
    local f32_local3 = 3034
    local f32_local4 = f32_arg0:GetRandam_Int(30, 45)
    f32_arg0:AddObserveArea(0, TARGET_SELF, TARGET_ENE_0, AI_DIR_TYPE_F, 360, 8)
    if f32_arg0:GetNumber(4) == 0 then
        if SpaceCheck(f32_arg0, f32_arg1, -90, 1) == true then
            if SpaceCheck(f32_arg0, f32_arg1, 90, 1) == true then
                if f32_arg0:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_R, 180, 999) then
                    f32_local3 = 3035
                else
                    f32_local3 = 3034
                end
            else
                f32_local3 = 3034
            end
        elseif SpaceCheck(f32_arg0, f32_arg1, 90, 1) == true then
            f32_local3 = 3035
        else
        end
        f32_arg0:SetNumber(10, f32_local2)
        f32_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f32_local3, TARGET_ENE_0, 9999, f32_local0, FrontAngle, 0, 0)
        f32_arg0:SetNumber(4, 1)
    else
        if SpaceCheck(f32_arg0, f32_arg1, -45, 2) == true then
            if SpaceCheck(f32_arg0, f32_arg1, 45, 2) == true then
                if f32_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                    f32_local1 = 3026
                else
                    f32_local1 = 3027
                end
            else
                f32_local1 = 3026
            end
        elseif SpaceCheck(f32_arg0, f32_arg1, 45, 2) == true then
            f32_local1 = 3027
        else
        end
        f32_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f32_local1, TARGET_ENE_0, 9999, f32_local0, 0, 0, 0)
        f32_arg0:SetNumber(4, 0)
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act32 = function (f33_arg0, f33_arg1, f33_arg2)
    f33_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3030, TARGET_ENE_0, 9999, 0, 0, 0, 0):TimingSetTimer(3, 15, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act34 = function (f34_arg0, f34_arg1, f34_arg2)
    local f34_local0 = 5
    local f34_local1 = 5
    local f34_local2 = 5
    local f34_local3 = 0
    local f34_local4 = 0
    local f34_local5 = 1.5
    local f34_local6 = 2
    Approach_Act_Flex(f34_arg0, f34_arg1, f34_local0, f34_local1, f34_local2, f34_local3, f34_local4, f34_local5, f34_local6)
    local f34_local7 = 0
    local f34_local8 = 0
    f34_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 5, 3010, TARGET_ENE_0, 9999, f34_local7, f34_local8, 0, 0):TimingSetNumber(3, f34_arg0:GetNumber(3) + 1, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act35 = function (f35_arg0, f35_arg1, f35_arg2)
    local f35_local0 = 0
    local f35_local1 = 0
    local f35_local2 = f35_arg0:GetDist(TARGET_ENE_0)
    local f35_local3 = 3028
    if f35_arg0:IsEventFlag(19952081) == true then
        if f35_local2 <= 5 then
            f35_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 3, 5201, TARGET_ENE_0, f35_local0, AI_DIR_TYPE_B, 0)
            f35_local3 = 3028
        else
            f35_local3 = 3028
        end
    elseif f35_arg0:IsEventFlag(19952082) == true then
        f35_local3 = 3029
    else
        f35_arg1:AddSubGoal(GOAL_COMMON_Wait, 2, TARGET_ENE_0, 0, 0, 0)
    end
    f35_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 5, f35_local3, TARGET_ENE_0, 9999, f35_local0, f35_local1, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act36 = function (f36_arg0, f36_arg1, f36_arg2)
    local f36_local0 = 0
    local f36_local1 = 0
    f36_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 5, 3028, TARGET_ENE_0, 9999, f36_local0, f36_local1, 0, 0)
    f36_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 5, 3028, TARGET_ENE_0, 9999, 0, -1)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act37 = function (f37_arg0, f37_arg1, f37_arg2)
    local f37_local0 = 0
    local f37_local1 = 0
    f37_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 5, 3023, TARGET_ENE_0, 9999, 0, -1):TimingSetNumber(3, 0, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act38 = function (f38_arg0, f38_arg1, f38_arg2)
    local f38_local0 = 0
    local f38_local1 = 0
    f38_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3290, TARGET_ENE_0, 9999, f38_local0, f38_local1, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act40 = function (f39_arg0, f39_arg1, f39_arg2)
    local f39_local0 = 3
    local f39_local1 = 0
    local f39_local2 = 4.5
    local f39_local3 = f39_arg0:GetRandam_Int(30, 45)
    if SpaceCheck(f39_arg0, f39_arg1, 180, 5) then
        f39_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f39_local0, 5201, TARGET_ENE_0, f39_local1, AI_DIR_TYPE_B, 0)
        f39_local2 = 3.5
    end
    local f39_local4 = 0
    if SpaceCheck(f39_arg0, f39_arg1, -90, 1) == true then
        if SpaceCheck(f39_arg0, f39_arg1, 90, 1) == true then
            if f39_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                f39_local4 = 0
            else
                f39_local4 = 1
            end
        else
            f39_local4 = 0
        end
    elseif SpaceCheck(f39_arg0, f39_arg1, 90, 1) == true then
        f39_local4 = 1
    else
    end
    f39_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f39_local2, TARGET_ENE_0, f39_local4, f39_local3, true, true, -1)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act41 = function (f40_arg0, f40_arg1, f40_arg2)
    f40_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 5, 3210, TARGET_ENE_0, 9999, 0, 0, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act42 = function (f41_arg0, f41_arg1, f41_arg2)
    f41_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 5, 3220, TARGET_ENE_0, 9999, 0, 0, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act43 = function (f42_arg0, f42_arg1, f42_arg2)
    f42_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 5, 3200, TARGET_ENE_0, 9999, 0, 0, 0, 0):TimingSetTimer(10, 10, AI_TIMING_SET__SUCCESS)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act45 = function (f43_arg0, f43_arg1, f43_arg2)
    local f43_local0 = 0
    local f43_local1 = 0
    local f43_local2 = f43_arg0:GetRandam_Int(0, 1)
    local f43_local3 = f43_arg0:GetRandam_Int(30, 45)
    f43_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 5, 3061, TARGET_ENE_0, 9999, f43_local0, f43_local1, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Interrupt = function (f44_arg0, f44_arg1, f44_arg2)
    local f44_local0 = f44_arg1:GetSpecialEffectActivateInterruptType(0)
    local f44_local1 = f44_arg1:GetDist(TARGET_ENE_0)
    local f44_local2 = f44_arg1:GetRandam_Int(1, 100)
    local f44_local3 = 3
    local f44_local4 = 0
    local f44_local5 = 5202
    if f44_arg1:IsLadderAct(TARGET_SELF) then
        return false
    end
    if not f44_arg1:HasSpecialEffectId(TARGET_SELF, 200004) then
        return false
    end
    if f44_arg1:IsInterupt(INTERUPT_ParryTiming) and f44_arg1:HasSpecialEffectId(TARGET_SELF, 5030) == false then
        return f44_arg0.Parry(f44_arg1, f44_arg2, 50, 0)
    end
    if f44_arg1:IsInterupt(INTERUPT_Damaged) then
        return f44_arg0.Damaged(f44_arg1, f44_arg2)
    end
    if f44_arg1:IsInterupt(INTERUPT_ShootImpact) then
        return f44_arg0.ShootReaction(f44_arg1, f44_arg2)
    end
    if Interupt_PC_Break(f44_arg1) then
        f44_arg1:Replanning()
        return true
    end
    if f44_arg1:IsInterupt(INTERUPT_ActivateSpecialEffect) then
        if f44_arg1:HasSpecialEffectId(TARGET_SELF, 5031) and f44_arg1:HasSpecialEffectId(TARGET_ENE_0, 3531) then
            f44_arg2:ClearSubGoal()
            f44_arg2:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3210, TARGET_ENE_0, 9999, 0, 0)
            return true
        end
        if f44_local0 == 200060 then
            f44_arg1:SetTimer(0, 20)
            if f44_arg1:IsFinishTimer(4) ~= true or f44_arg1:GetNumber(1) >= 10 then
                f44_arg1:SetEventFlag(19952082, true)
                f44_arg1:SetNumber(1, 0)
            else
                f44_arg1:SetEventFlag(19952081, true)
            end
        elseif f44_local0 == 200061 then
            f44_arg1:SetTimer(0, 40)
            f44_arg1:SetEventFlag(19952081, false)
            f44_arg1:SetEventFlag(19952082, false)
        end
        if f44_local0 == 3509020 then
            if f44_arg1:IsEventFlag(19952081) == true then
                f44_arg1:SetEventFlag(19952081, false)
                f44_arg1:SetEventFlag(19952082, true)
            elseif f44_arg1:IsEventFlag(19952082) == true then
                f44_arg1:SetEventFlag(19952082, false)
                f44_arg1:SetEventFlag(19952081, true)
            end
        elseif f44_local0 == 3509030 then
            if f44_arg1:IsEventFlag(19952081) == true then
                f44_arg1:SetEventFlag(19952081, false)
                f44_arg1:SetEventFlag(19952082, true)
            elseif f44_arg1:IsEventFlag(19952082) == true then
                f44_arg1:SetEventFlag(19952082, false)
                f44_arg1:SetEventFlag(19952081, true)
            end
        end
        if f44_local0 == 5033 then
            if f44_local1 >= 5 then
                f44_arg2:ClearSubGoal()
                f44_arg2:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3200, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(1, f44_arg1:GetNumber(1) + 5, AI_TIMING_SET__ACTIVATE)
                return true
            elseif f44_local1 >= 2 then
                f44_arg2:ClearSubGoal()
                f44_arg2:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3230, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(1, f44_arg1:GetNumber(1) + 5, AI_TIMING_SET__ACTIVATE)
                return true
            else
                f44_arg2:ClearSubGoal()
                f44_arg2:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3220, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(1, f44_arg1:GetNumber(1) + 5, AI_TIMING_SET__ACTIVATE)
                return true
            end
        end
        if f44_local0 == 5027 then
            if (f44_arg1:HasSpecialEffectId(TARGET_ENE_0, 109031) or f44_arg1:HasSpecialEffectId(TARGET_ENE_0, 110125)) and f44_local1 <= 10 then
                f44_arg2:ClearSubGoal()
                f44_arg2:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3240, TARGET_ENE_0, 9999, 0):TimingSetNumber(1, f44_arg1:GetNumber(1) + 5, AI_TIMING_SET__ACTIVATE)
                return true
            elseif f44_local1 >= 5 then
                f44_arg2:ClearSubGoal()
                f44_arg2:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3200, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(1, f44_arg1:GetNumber(1) + 5, AI_TIMING_SET__ACTIVATE)
                return true
            elseif f44_local1 >= 2 then
                f44_arg2:ClearSubGoal()
                f44_arg2:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3230, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(1, f44_arg1:GetNumber(1) + 5, AI_TIMING_SET__ACTIVATE)
                return true
            else
                f44_arg2:ClearSubGoal()
                f44_arg2:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3220, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(1, f44_arg1:GetNumber(1) + 5, AI_TIMING_SET__ACTIVATE)
                return true
            end
        end
    end
    if Interupt_Use_Item(f44_arg1, 11, 10) then
        if f44_local1 <= 2 - f44_arg1:GetMapHitRadius(TARGET_SELF) then
            f44_arg1:SetTimer(4, 0)
            f44_arg2:ClearSubGoal()
            f44_arg2:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 1, 3022, TARGET_ENE_0, 9999, 0, 0, 0, 0)
            return true
        elseif f44_local1 <= 6 then
            f44_arg1:SetTimer(4, 0)
            f44_arg2:ClearSubGoal()
            f44_arg2:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3008, TARGET_ENE_0, 3, 0, 0, 0, 0)
            f44_arg2:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3009, TARGET_ENE_0, 2.5, 0)
            f44_arg2:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3010, TARGET_ENE_0, 9999, 0, 0)
            return true
        else
            f44_arg1:SetTimer(4, 0)
            f44_arg2:ClearSubGoal()
            f44_arg2:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 5, 3032, TARGET_ENE_0, 9999, f44_local4, FrontAngle, 0, 0)
            return true
        end
    end
    if f44_arg1:IsInterupt(INTERUPT_Inside_ObserveArea) then
        if f44_arg1:IsInsideObserve(0) then
            f44_arg1:DeleteObserve(0)
            f44_arg2:ClearSubGoal()
            f44_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 1, 3230, TARGET_ENE_0, 9999, 0):TimingSetTimer(10, 10, AI_TIMING_SET__SUCCESS)
            f44_arg2:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3011, TARGET_ENE_0, 5, 0)
            f44_arg2:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3012, TARGET_ENE_0, 5, 0, 0)
            return true
        elseif f44_arg1:IsInsideObserve(1) then
            f44_arg1:DeleteObserve(1)
            f44_arg2:ClearSubGoal()
            f44_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 1, 5201, TARGET_ENE_0, 9999, 0):TimingSetTimer(10, 10, AI_TIMING_SET__SUCCESS)
            f44_arg1:Replaning()
            return true
        end
    end
    return false
    
end

Goal.Parry = function (f45_arg0, f45_arg1, f45_arg2, f45_arg3)
    local f45_local0 = f45_arg0:GetDist(TARGET_ENE_0)
    local f45_local1 = GetDist_Parry(f45_arg0)
    local f45_local2 = f45_arg0:GetRandam_Int(1, 100)
    local f45_local3 = f45_arg0:GetRandam_Int(1, 100)
    local f45_local4 = f45_arg0:GetRandam_Int(1, 100)
    local f45_local5 = f45_arg0:HasSpecialEffectId(TARGET_ENE_0, 109970)
    local f45_local6 = f45_arg0:HasSpecialEffectId(TARGET_ENE_0, COMMON_SP_EFFECT_PC_ATTACK_RUSH)
    if f45_arg0:IsFinishTimer(AI_TIMER_PARRY_INTERVAL) == false then
        return false
    end
    if f45_arg0:HasSpecialEffectId(TARGET_ENE_0, 110450) or f45_arg0:HasSpecialEffectId(TARGET_ENE_0, 110501) or f45_arg0:HasSpecialEffectId(TARGET_ENE_0, 110500) then
        return false
    end
    f45_arg0:SetTimer(AI_TIMER_PARRY_INTERVAL, 0.1)
    if f45_arg2 == nil then
        f45_arg2 = 50
    end
    if f45_arg3 == nil then
        f45_arg3 = 0
    end
    if f45_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) and f45_arg0:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_F, 180, f45_local1) then
        if f45_local6 then
            f45_arg1:ClearSubGoal()
            f45_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.3, 3100, TARGET_ENE_0, 9999, 0)
            return true
        elseif f45_local5 then
            if f45_arg0:IsTargetGuard(TARGET_SELF) and ReturnKengekiSpecialEffect(f45_arg0) == false then
                return false
            else
                f45_arg1:ClearSubGoal()
                f45_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.3, 3101, TARGET_ENE_0, 9999, 0)
                return true
            end
        elseif f45_arg0:HasSpecialEffectId(TARGET_SELF, 5029) then
            f45_arg1:ClearSubGoal()
            f45_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.3, 3103, TARGET_ENE_0, 9999, 0)
            return true
        elseif f45_arg0:HasSpecialEffectId(TARGET_SELF, 5030) or f45_arg0:HasSpecialEffectId(TARGET_SELF, 5031) then
            f45_arg1:ClearSubGoal()
            f45_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.3, 3102, TARGET_ENE_0, 9999, 0)
            return true
        elseif f45_arg0:HasSpecialEffectId(TARGET_ENE_0, 109980) then
            f45_arg1:ClearSubGoal()
            f45_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 1, 5201, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0)
            return true
        elseif f45_local3 <= Get_ConsecutiveGuardCount(f45_arg0) * f45_arg2 then
            f45_arg1:ClearSubGoal()
            f45_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.3, 3101, TARGET_ENE_0, 9999, 0)
            return true
        else
            f45_arg1:ClearSubGoal()
            f45_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.3, 3100, TARGET_ENE_0, 9999, 0)
            return true
        end
    else
        return false
    end
    
end

Goal.Damaged = function (f46_arg0, f46_arg1, f46_arg2)
    local f46_local0 = f46_arg0:GetRandam_Int(1, 100)
    local f46_local1 = -1
    local f46_local2 = 3
    local f46_local3 = 1
    local f46_local4 = 1
    local f46_local5 = f46_arg0:GetRandam_Int(0, 1)
    local f46_local6 = 45
    local f46_local7 = f46_arg0:GetDist(TARGET_ENE_0)
    f46_arg0:SetTimer(7, 0.8)
    if f46_arg0:HasSpecialEffectId(TARGET_SELF, 5030) then
        if f46_local7 <= 3 then
            f46_arg1:ClearSubGoal()
            f46_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3220, TARGET_ENE_0, 9999, 0)
            return true
        else
            f46_arg1:ClearSubGoal()
            f46_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3250, TARGET_ENE_0, 9999, 0)
            return true
        end
    end
    
end

Goal.ShootReaction = function (f47_arg0, f47_arg1)
    local f47_local0 = f47_arg0:GetDist(TARGET_ENE_0)
    local f47_local1 = f47_arg0:GetDistXZ(TARGET_ENE_0)
    if not (f47_arg0:HasSpecialEffectId(TARGET_SELF, 5030) or f47_arg0:HasSpecialEffectId(TARGET_SELF, 5031) or f47_arg0:HasSpecialEffectId(TARGET_SELF, 5900)) then
        if f47_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 180, 190) then
            if f47_local0 <= 20 then
                f47_arg1:ClearSubGoal()
                f47_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3100, TARGET_ENE_0, 9999, 0)
                return true
            else
                f47_arg1:ClearSubGoal()
                f47_arg1:AddSubGoal(GOAL_COMMON_Wait, 0.3, TARGET_SELF, 0, 0, 0)
                f47_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3100, TARGET_ENE_0, 9999, 0)
                return true
            end
        end
    elseif (f47_arg0:HasSpecialEffectId(TARGET_SELF, 5030) or f47_arg0:HasSpecialEffectId(TARGET_SELF, 5031)) and f47_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 180, 190) then
        if f47_local0 <= 20 then
            f47_arg1:ClearSubGoal()
            f47_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3102, TARGET_ENE_0, 9999, 0)
            return true
        else
            f47_arg1:ClearSubGoal()
            f47_arg1:AddSubGoal(GOAL_COMMON_Wait, 0.3, TARGET_SELF, 0, 0, 0)
            f47_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.1, 3102, TARGET_ENE_0, 9999, 0)
            return true
        end
    end
    return false
    
end

Goal.Kengeki_Activate = function (f48_arg0, f48_arg1, f48_arg2)
    local f48_local0 = ReturnKengekiSpecialEffect(f48_arg1)
    if f48_local0 == 0 then
        return false
    end
    local f48_local1 = {}
    local f48_local2 = {}
    local f48_local3 = {}
    Common_Clear_Param(f48_local1, f48_local2, f48_local3)
    local f48_local4 = f48_arg1:GetDist(TARGET_ENE_0)
    local f48_local5 = f48_arg1:GetSp(TARGET_SELF)
    if f48_local0 == 200227 then
        f48_arg1:SetNumber(2, f48_arg1:GetNumber(2) + 1)
        if f48_arg1:GetNumber(2) >= 5 then
            f48_local1[4] = 100
            f48_arg1:SetNumber(2, 0)
        elseif f48_local4 >= 4 then
            f48_local1[50] = 100
        elseif f48_local4 <= 0.05 then
            f48_local1[50] = 100
        else
            f48_local1[2] = 100
            f48_local1[50] = 100
        end
    elseif f48_local0 == 200228 then
        f48_arg1:SetNumber(2, f48_arg1:GetNumber(2) + 1)
        if f48_arg1:GetNumber(2) >= 5 then
            f48_local1[5] = 100
            f48_arg1:SetNumber(2, 0)
        elseif f48_local4 >= 4 then
            f48_local1[50] = 100
        elseif f48_local4 <= 0.05 then
            f48_local1[3] = 100
        else
            f48_local1[3] = 100
            f48_local1[50] = 100
        end
    elseif f48_local0 == 200200 then
        if f48_local4 >= 4 then
        elseif f48_local4 <= 0.05 and false then
        end
    elseif f48_local0 == 200201 then
        if f48_local4 >= 4 then
        elseif f48_local4 <= 0.05 and false then
        end
    elseif f48_local0 == 200210 then
        if f48_local4 >= 4 then
            f48_local1[50] = 100
        elseif SpaceCheck(f48_arg1, f48_arg2, 180, 4) == false then
            f48_local1[6] = 20
            f48_local1[10] = 80
        else
            f48_local1[1] = 15
            f48_local1[9] = 15
            f48_local1[10] = 100
        end
    elseif f48_local0 == 200211 then
        if f48_local4 >= 4 then
            f48_local1[50] = 100
        elseif SpaceCheck(f48_arg1, f48_arg2, 180, 4) == false then
            f48_local1[6] = 40
            f48_local1[10] = 60
        else
            f48_local1[1] = 40
            f48_local1[9] = 20
            f48_local1[10] = 60
        end
    elseif f48_local0 == 200215 then
        if f48_local4 >= 4 and false then
        end
    elseif f48_local0 == 200216 and f48_local4 >= 4 and false then
    else
    end
    f48_local1[1] = SetCoolTime(f48_arg1, f48_arg2, 3017, 5, f48_local1[1], 1)
    f48_local1[4] = SetCoolTime(f48_arg1, f48_arg2, 3060, 5, f48_local1[4], 1)
    f48_local1[5] = SetCoolTime(f48_arg1, f48_arg2, 3065, 5, f48_local1[5], 1)
    f48_local1[6] = SetCoolTime(f48_arg1, f48_arg2, 3220, 3, f48_local1[6], 1)
    f48_local1[7] = SetCoolTime(f48_arg1, f48_arg2, 3021, 5, f48_local1[7], 1)
    f48_local1[8] = SetCoolTime(f48_arg1, f48_arg2, 3033, 8, f48_local1[8], 1)
    f48_local1[9] = SetCoolTime(f48_arg1, f48_arg2, 3023, 8, f48_local1[9], 1)
    f48_local1[10] = SetCoolTime(f48_arg1, f48_arg2, 3005, 10, f48_local1[10], 1)
    f48_local2[1] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki01)
    f48_local2[2] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki02)
    f48_local2[3] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki03)
    f48_local2[4] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki04)
    f48_local2[5] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki05)
    f48_local2[6] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki06)
    f48_local2[7] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki07)
    f48_local2[8] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki08)
    f48_local2[9] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki09)
    f48_local2[10] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki10)
    f48_local2[11] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki11)
    f48_local2[21] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Act21)
    f48_local2[22] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Act22)
    f48_local2[23] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Act23)
    f48_local2[24] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Act24)
    f48_local2[25] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Act25)
    f48_local2[50] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.NoAction)
    local f48_local6 = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.ActAfter_AdjustSpace)
    return Common_Kengeki_Activate(f48_arg1, f48_arg2, f48_local1, f48_local2, f48_local6, f48_local3)
    
end

Goal.Kengeki01 = function (f49_arg0, f49_arg1, f49_arg2)
    f49_arg1:ClearSubGoal()
    f49_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3017, TARGET_ENE_0, 9999, 0, 0)
    return 0
    
end

Goal.Kengeki02 = function (f50_arg0, f50_arg1, f50_arg2)
    f50_arg1:ClearSubGoal()
    f50_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 3, 3061, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(2, f50_arg0:GetNumber(2) + 3, AI_TIMING_SET__ACTIVATE)
    return 0
    
end

Goal.Kengeki03 = function (f51_arg0, f51_arg1, f51_arg2)
    f51_arg1:ClearSubGoal()
    f51_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 3, 3066, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(2, f51_arg0:GetNumber(2) + 3, AI_TIMING_SET__ACTIVATE)
    return 0
    
end

Goal.Kengeki04 = function (f52_arg0, f52_arg1, f52_arg2)
    f52_arg1:ClearSubGoal()
    f52_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 3, 3060, TARGET_ENE_0, 9999, 0, 0)
    return 0
    
end

Goal.Kengeki05 = function (f53_arg0, f53_arg1, f53_arg2)
    f53_arg1:ClearSubGoal()
    f53_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 3, 3065, TARGET_ENE_0, 9999, 0, 0)
    return 0
    
end

Goal.Kengeki06 = function (f54_arg0, f54_arg1, f54_arg2)
    f54_arg1:ClearSubGoal()
    f54_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 5, 3030, TARGET_SELF, 9999, 0, 0)
    f54_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 5, 3220, TARGET_SELF, 9999, 0, 0)
    f54_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 5, 3033, TARGET_SELF, 9999, 0, 0)
    return 0
    
end

Goal.Kengeki07 = function (f55_arg0, f55_arg1, f55_arg2)
    f55_arg1:ClearSubGoal()
    f55_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 3, 5201, TARGET_ENE_0, 9999, 0)
    f55_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 5, 3021, TARGET_ENE_0, 9999, 0, 0)
    return 0
    
end

Goal.Kengeki08 = function (f56_arg0, f56_arg1, f56_arg2)
    f56_arg1:ClearSubGoal()
    f56_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 3, 5201, TARGET_ENE_0, 9999, 0)
    f56_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 5, 3033, TARGET_ENE_0, 9999, 0, 0)
    return 0
    
end

Goal.Kengeki09 = function (f57_arg0, f57_arg1, f57_arg2)
    f57_arg1:ClearSubGoal()
    f57_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 3, 5201, TARGET_ENE_0, 9999, 0)
    f57_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 5, 3023, TARGET_ENE_0, 9999, 0, 0)
    return 0
    
end

Goal.Kengeki10 = function (f58_arg0, f58_arg1, f58_arg2)
    f58_arg1:ClearSubGoal()
    f58_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3066, TARGET_ENE_0, 9999, 0)
    f58_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3005, TARGET_ENE_0, 3 - f58_arg0:GetMapHitRadius(TARGET_SELF), 0)
    f58_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3006, TARGET_ENE_0, 7 - f58_arg0:GetMapHitRadius(TARGET_SELF), 0)
    f58_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3007, TARGET_ENE_0, 9999, 0, 0)
    return 0
    
end

Goal.Kengeki11 = function (f59_arg0, f59_arg1, f59_arg2)
    f59_arg1:ClearSubGoal()
    f59_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3061, TARGET_ENE_0, 9999, 0)
    f59_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3009, TARGET_ENE_0, 9999, 0)
    f59_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3010, TARGET_ENE_0, 9999, 0, 0)
    return 0
    
end

Goal.NoAction = function (f60_arg0, f60_arg1, f60_arg2)
    return -1
    
end

Goal.ActAfter_AdjustSpace = function (f61_arg0, f61_arg1, f61_arg2)
    
end

Goal.Update = function (f62_arg0, f62_arg1, f62_arg2)
    return Update_Default_NoSubGoal(f62_arg0, f62_arg1, f62_arg2)
    
end

Goal.Terminate = function (f63_arg0, f63_arg1, f63_arg2)
    
end


