RegisterTableGoal(GOAL_Koeishu_147000_Battle, "GOAL_Koeishu_147000_Battle")
REGISTER_GOAL_NO_UPDATE(GOAL_Koeishu_147000_Battle, true)

Goal.Initialize = function (f1_arg0, f1_arg1, f1_arg2, f1_arg3)
    
end

Goal.Activate = function (f2_arg0, f2_arg1, f2_arg2)
    Init_Pseudo_Global(f2_arg1, f2_arg2)
    if f2_arg0.Kengeki_Activate(f2_arg0, f2_arg1, f2_arg2) then
        return
    end
    local f2_local0 = {}
    local f2_local1 = {}
    local f2_local2 = {}
    Common_Clear_Param(f2_local0, f2_local1, f2_local2)
    local f2_local3 = f2_arg1:GetDist(TARGET_ENE_0)
    local f2_local4 = f2_arg1:GetDistYSigned(TARGET_ENE_0)
    local f2_local5 = f2_arg1:GetDistXZ(TARGET_ENE_0)
    local f2_local6 = f2_arg1:GetExcelParam(AI_EXCEL_THINK_PARAM_TYPE__thinkAttr_doAdmirer)
    local f2_local7 = f2_arg1:GetHpRate(TARGET_SELF)
    local f2_local8 = f2_arg1:GetSpRate(TARGET_SELF)
    local f2_local9 = Check_ReachAttack(f2_arg1, 0)
    local f2_local10 = f2_arg1:GetNinsatsuNum()
    local f2_local11 = f2_arg1:GetNpcThinkParamID()
    local f2_local12 = f2_arg1:GetRandam_Int(0, 100)
    local f2_local13 = f2_arg1:GetEventRequest()
    local f2_local14 = f2_arg1:GetRandam_Float(19, 21)
    local f2_local15 = f2_arg1:GetRandam_Float(14, 16)
    local f2_local16 = f2_arg1:GetRandam_Float(9, 11)
    f2_arg1:SetStringIndexedNumber("heatUpMode", 1)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 5025)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 5026)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 5027)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 5028)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 5029)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 5030)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 5031)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 5032)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 5033)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 5034)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_SELF, 3147120)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 110125)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 109031)
    f2_arg1:AddObserveSpecialEffectAttribute(TARGET_ENE_0, 110120)
    Set_ConsecutiveGuardCount_Interrupt(f2_arg1)
    f2_arg1:DeleteObserve(0)
    f2_arg1:DeleteObserve(1)
    f2_arg1:DeleteObserve(2)
    if f2_arg1:HasSpecialEffectId(TARGET_SELF, 3147500) and f2_arg1:GetNumber(0) == 0 then
        f2_local0[20] = 100
    elseif f2_local13 == 20 and f2_arg1:GetNumber(0) == 0 then
        f2_local0[19] = 100
    elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 3147520) and f2_local10 <= 1 and f2_arg1:IsFinishTimer(8) == true and f2_local7 >= 0.9 and f2_local8 >= 0.7 and not f2_arg1:HasSpecialEffectId(TARGET_SELF, 3147120) then
        f2_local0[43] = 100
    elseif Common_ActivateAct(f2_arg1, f2_arg2, 0, 1) then
    elseif f2_local9 ~= POSSIBLE_ATTACK then
        if f2_local6 == 1 and f2_arg1:GetTeamOrder(ORDER_TYPE_Role) == ROLE_TYPE_Kankyaku then
            f2_local0[27] = 100
        elseif f2_local6 == 1 and f2_arg1:GetTeamOrder(ORDER_TYPE_Role) == ROLE_TYPE_Torimaki then
            f2_local0[27] = 100
        elseif f2_local9 == UNREACH_ATTACK then
            f2_local0[27] = 100
            f2_local0[30] = 300
        elseif f2_local9 == REACH_ATTACK_TARGET_HIGH_POSITION then
            f2_local0[1] = 100
            f2_local0[13] = 100
        elseif f2_local9 == REACH_ATTACK_TARGET_LOW_POSITION then
            f2_local0[1] = 100
            f2_local0[13] = 100
        else
            f2_local0[27] = 100
        end
    elseif f2_local6 == 1 and f2_arg1:GetTeamOrder(ORDER_TYPE_Role) == ROLE_TYPE_Kankyaku then
        if f2_arg1:IsInsideTargetRegion(TARGET_SELF, 1112470) then
            if f2_local3 >= 20 then
                KankyakuAct(f2_arg1, f2_arg2, 20)
            elseif f2_local3 >= 15 then
                KankyakuAct(f2_arg1, f2_arg2, 15)
            else
                KankyakuAct(f2_arg1, f2_arg2)
            end
        else
            KankyakuAct(f2_arg1, f2_arg2)
        end
    elseif f2_local6 == 1 and f2_arg1:GetTeamOrder(ORDER_TYPE_Role) == ROLE_TYPE_Torimaki then
        if f2_arg1:HasSpecialEffectId(TARGET_SELF, 3147111) then
            if f2_local3 >= 12 then
                f2_local0[29] = 200
            elseif f2_local3 >= 3 then
                f2_local0[23] = 200
                f2_local0[25] = 20
                f2_local0[1] = 1
            else
                f2_local0[23] = 20
                f2_local0[25] = 200
                f2_local0[1] = 1
            end
        elseif f2_arg1:IsInsideTargetRegion(TARGET_SELF, 1112470) then
            if f2_local3 >= 18 then
                if TorimakiAct(f2_arg1, f2_arg2, f2_local14, 40) then
                    f2_local0[2] = 10
                    f2_local0[11] = 30
                    if f2_arg1:IsVisibleTarget(TARGET_ENE_0) then
                        f2_local0[30] = 100
                    end
                end
            elseif f2_local3 >= 13 then
                if TorimakiAct(f2_arg1, f2_arg2, f2_local15, 40) then
                    f2_local0[2] = 10
                    f2_local0[11] = 50
                    if f2_arg1:IsVisibleTarget(TARGET_ENE_0) then
                        f2_local0[30] = 100
                    end
                end
            elseif f2_local3 >= 8 then
                if TorimakiAct(f2_arg1, f2_arg2, f2_local16, 30) then
                    f2_local0[2] = 50
                    f2_local0[11] = 50
                    if f2_arg1:IsVisibleTarget(TARGET_ENE_0) then
                        f2_local0[30] = 100
                    end
                end
            elseif TorimakiAct(f2_arg1, f2_arg2) then
                f2_local0[2] = 100
                f2_local0[11] = 100
            end
        elseif TorimakiAct(f2_arg1, f2_arg2) then
            f2_local0[2] = 100
            f2_local0[11] = 100
        end
    elseif f2_arg1:HasSpecialEffectId(TARGET_SELF, 3147110) and f2_arg1:IsFinishTimer(6) == true then
        f2_local0[20] = 100
    elseif f2_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_B, 180) then
        f2_local0[21] = 10
        f2_local0[22] = 10000
    elseif f2_local11 == 14703000 and f2_local4 <= -1.1 then
        if f2_local3 >= 3 then
            f2_local0[1] = 300
            f2_local0[6] = 300
            f2_local0[37] = 300
        else
            f2_local0[1] = 250
            f2_local0[6] = 300
            f2_local0[37] = 200
            f2_local0[30] = 250
        end
    elseif f2_local11 == 14703000 and f2_local4 >= 1.1 then
        if f2_local3 >= 3 then
            f2_local0[27] = 100
            f2_local0[30] = 500
            f2_local0[37] = 300
        else
            f2_local0[6] = 300
            f2_local0[24] = 300
            f2_local0[27] = 100
            f2_local0[37] = 300
        end
    elseif f2_local11 == 14701002 and f2_local4 <= -1.8 and f2_local5 <= 2 then
        f2_local0[27] = 50
        f2_local0[24] = 50
        f2_local0[37] = 900
    elseif f2_local11 == 14701002 and f2_local4 >= 1.8 and f2_local5 <= 2 then
        f2_local0[27] = 50
        f2_local0[24] = 50
        f2_local0[37] = 900
    elseif f2_arg1:IsFinishTimer(0) == false then
        f2_local0[1] = 1
        f2_local0[23] = 10000
        f2_arg1:SetTimer(0, 0)
    elseif (f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 109031) or f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 110125)) and f2_arg1:HasSpecialEffectId(TARGET_SELF, 5022) then
        f2_local0[6] = 100
    elseif f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 110120) and f2_local3 <= 4 then
        f2_local0[8] = 100
    elseif f2_local11 == 14701003 and f2_arg1:GetTeamOrder(ORDER_TYPE_Role) == ROLE_TYPE_Torimaki and f2_local12 >= 61 then
        if TorimakiAct(f2_arg1, f2_arg2, -1, 0) then
        end
    elseif f2_local11 == 14701004 and f2_arg1:GetTeamOrder(ORDER_TYPE_Role) == ROLE_TYPE_Torimaki and f2_local12 >= 81 then
        if TorimakiAct(f2_arg1, f2_arg2, -1, 0) then
        end
    elseif f2_local3 >= 10 then
        f2_local0[1] = 10
        f2_local0[2] = 200
        f2_local0[11] = 10
        f2_local0[42] = 100
        if f2_arg1:HasSpecialEffectId(TARGET_SELF, 5021) then
            f2_local0[17] = 400
            f2_local0[35] = 300
        end
    elseif f2_local3 >= 5 then
        f2_local0[1] = 50
        f2_local0[2] = 300
        f2_local0[3] = 200
        f2_local0[4] = 0
        f2_local0[11] = 50
        f2_local0[16] = 50
        f2_local0[23] = 100
        f2_local0[42] = 300
        if f2_arg1:HasSpecialEffectId(TARGET_SELF, 5021) then
            f2_local0[17] = 400
            f2_local0[35] = 300
        end
    elseif f2_local3 >= 3 then
        f2_local0[1] = 100
        f2_local0[2] = 20
        f2_local0[3] = 200
        f2_local0[4] = 200
        f2_local0[13] = 50
        f2_local0[16] = 100
        f2_local0[23] = 100
        if f2_arg1:HasSpecialEffectId(TARGET_SELF, 5021) then
            f2_local0[25] = 50
            f2_local0[35] = 250
        end
    else
        f2_local0[1] = 100
        f2_local0[2] = 20
        f2_local0[3] = 200
        f2_local0[4] = 200
        f2_local0[11] = 100
        f2_local0[13] = 100
        f2_local0[16] = 100
        f2_local0[24] = 100
        if f2_arg1:HasSpecialEffectId(TARGET_SELF, 5021) then
            f2_local0[25] = 50
            f2_local0[33] = 250
        end
    end
    if f2_local7 <= 0.5 then
        f2_local0[4] = f2_local0[4] + 200
    end
    if not f2_arg1:HasSpecialEffectId(TARGET_SELF, 5023) and f2_arg1:HasSpecialEffectId(TARGET_SELF, 5021) then
        f2_local0[3] = 0
        f2_local0[16] = 0
        f2_local0[42] = 0
    end
    if f2_arg1:IsFinishTimer(7) == true and f2_arg1:GetDist(TARGET_FRI_0) <= 30 and f2_arg1:HasSpecialEffectId(TARGET_FRI_0, 3115030) then
        if f2_local3 >= 2.5 then
            f2_local0[19] = 10000
        else
            f2_local0[32] = 1000
        end
    end
    if f2_local8 <= 0.4 and f2_arg1:IsFinishTimer(6) == true then
        f2_local0[40] = 500
    end
    if f2_arg1:IsFinishTimer(3) == false then
        f2_local0[24] = 0
        f2_local0[25] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 45, 2.5) == false and SpaceCheck(f2_arg1, f2_arg2, -45, 2.5) == false then
        f2_local0[22] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 90, 1) == false and SpaceCheck(f2_arg1, f2_arg2, -90, 1) == false then
        f2_local0[23] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 180, 2.5) == false then
        f2_local0[24] = 0
    end
    if SpaceCheck(f2_arg1, f2_arg2, 180, 1) == false then
        f2_local0[25] = 0
    end
    if f2_arg1:IsInsideTargetRegion(TARGET_SELF, 1112250) or f2_arg1:IsInsideTargetRegion(TARGET_ENE_0, 1112250) then
        f2_local0[42] = 0
    end
    if f2_arg1:HasSpecialEffectId(TARGET_SELF, 5023) and f2_arg1:HasSpecialEffectId(TARGET_ENE_0, 110270) then
        f2_local0[30] = 0
    end
    f2_local0[1] = SetCoolTime(f2_arg1, f2_arg2, 3000, 5, f2_local0[1], 1)
    f2_local0[1] = SetCoolTime(f2_arg1, f2_arg2, 3032, 5, f2_local0[1], 1)
    f2_local0[2] = SetCoolTime(f2_arg1, f2_arg2, 3003, 8, f2_local0[2], 1)
    f2_local0[3] = SetCoolTime(f2_arg1, f2_arg2, 3062, 8, f2_local0[3], 1)
    f2_local0[4] = SetCoolTime(f2_arg1, f2_arg2, 3067, 10, f2_local0[4], 1)
    f2_local0[5] = SetCoolTime(f2_arg1, f2_arg2, 3008, 15, f2_local0[5], 1)
    f2_local0[5] = SetCoolTime(f2_arg1, f2_arg2, 3034, 5, f2_local0[5], 1)
    f2_local0[6] = SetCoolTime(f2_arg1, f2_arg2, 3009, 8, f2_local0[6], 1)
    f2_local0[7] = SetCoolTime(f2_arg1, f2_arg2, 3010, 20, f2_local0[7], 1)
    f2_local0[7] = SetCoolTime(f2_arg1, f2_arg2, 3019, 20, f2_local0[7], 1)
    f2_local0[8] = SetCoolTime(f2_arg1, f2_arg2, 3011, 8, f2_local0[8], 1)
    f2_local0[9] = SetCoolTime(f2_arg1, f2_arg2, 3014, 10, f2_local0[9], 1)
    f2_local0[9] = SetCoolTime(f2_arg1, f2_arg2, 3035, 5, f2_local0[9], 1)
    f2_local0[10] = SetCoolTime(f2_arg1, f2_arg2, 3015, 20, f2_local0[10], 1)
    f2_local0[11] = SetCoolTime(f2_arg1, f2_arg2, 3017, 5, f2_local0[11], 1)
    f2_local0[12] = SetCoolTime(f2_arg1, f2_arg2, 3010, 15, f2_local0[12], 1)
    f2_local0[12] = SetCoolTime(f2_arg1, f2_arg2, 3019, 15, f2_local0[12], 1)
    f2_local0[13] = SetCoolTime(f2_arg1, f2_arg2, 3020, 15, f2_local0[13], 1)
    f2_local0[16] = SetCoolTime(f2_arg1, f2_arg2, 3001, 15, f2_local0[16], 1)
    f2_local0[17] = SetCoolTime(f2_arg1, f2_arg2, 3023, 15, f2_local0[17], 1)
    f2_local0[18] = SetCoolTime(f2_arg1, f2_arg2, 3019, 15, f2_local0[18], 1)
    f2_local0[19] = SetCoolTime(f2_arg1, f2_arg2, 3090, 3, f2_local0[19], 1)
    f2_local0[22] = SetCoolTime(f2_arg1, f2_arg2, 5202, 3, f2_local0[22], 1)
    f2_local0[22] = SetCoolTime(f2_arg1, f2_arg2, 5203, 3, f2_local0[22], 1)
    f2_local0[23] = SetCoolTime(f2_arg1, f2_arg2, 5010, 2, f2_local0[23], 1)
    f2_local0[24] = SetCoolTime(f2_arg1, f2_arg2, 5010, 2, f2_local0[24], 1)
    f2_local0[25] = SetCoolTime(f2_arg1, f2_arg2, 5010, 2, f2_local0[25], 1)
    f2_local0[30] = SetCoolTime(f2_arg1, f2_arg2, 3041, 4, f2_local0[30], 1)
    f2_local0[33] = SetCoolTime(f2_arg1, f2_arg2, 3026, 8, f2_local0[33], 1)
    f2_local0[33] = SetCoolTime(f2_arg1, f2_arg2, 3027, 8, f2_local0[33], 1)
    f2_local0[35] = SetCoolTime(f2_arg1, f2_arg2, 3026, 8, f2_local0[35], 1)
    f2_local0[35] = SetCoolTime(f2_arg1, f2_arg2, 3027, 8, f2_local0[35], 1)
    f2_local0[37] = SetCoolTime(f2_arg1, f2_arg2, 3062, 5, f2_local0[37], 1)
    f2_local0[37] = SetCoolTime(f2_arg1, f2_arg2, 6800, 5, f2_local0[37], 1)
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
    f2_local1[40] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act40)
    f2_local1[41] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act41)
    f2_local1[42] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act42)
    f2_local1[43] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act43)
    f2_local1[44] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act44)
    f2_local1[45] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act45)
    f2_local1[46] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act46)
    f2_local1[47] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act47)
    f2_local1[48] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act48)
    f2_local1[49] = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.Act49)
    local f2_local17 = REGIST_FUNC(f2_arg1, f2_arg2, f2_arg0.ActAfter_AdjustSpace)
    Common_Battle_Activate(f2_arg1, f2_arg2, f2_local0, f2_local1, f2_local17, f2_local2)
    
end

Goal.Act01 = function (f3_arg0, f3_arg1, f3_arg2)
    local f3_local0 = 3.5 - f3_arg0:GetMapHitRadius(TARGET_SELF)
    local f3_local1 = 3.5 - f3_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f3_local2 = 3.5 - f3_arg0:GetMapHitRadius(TARGET_SELF) + 10
    local f3_local3 = 0
    local f3_local4 = 0
    local f3_local5 = 3
    local f3_local6 = 3
    if f3_arg0:GetStringIndexedNumber("heatUpMode") == 1 then
        f3_local3 = 100
    end
    Approach_Act_Flex(f3_arg0, f3_arg1, f3_local0, f3_local1, f3_local2, f3_local3, f3_local4, f3_local5, f3_local6)
    if f3_arg0:HasSpecialEffectId(TARGET_SELF, 5021) then
        f3_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3000, TARGET_ENE_0, 999, TurnTime, FrontAngle, 0, 0)
        f3_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3026, TARGET_ENE_0, 9999, TurnTime, FrontAngle, 0, 0)
    else
        f3_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3000, TARGET_ENE_0, 9999, TurnTime, FrontAngle, 0, 0)
    end
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act02 = function (f4_arg0, f4_arg1, f4_arg2)
    local f4_local0 = 6.8 - f4_arg0:GetMapHitRadius(TARGET_SELF)
    local f4_local1 = 6.8 - f4_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f4_local2 = 6.8 - f4_arg0:GetMapHitRadius(TARGET_SELF) + 10
    local f4_local3 = 0
    local f4_local4 = 0
    local f4_local5 = 3
    local f4_local6 = 3
    local f4_local7 = f4_arg0:GetDist(TARGET_ENE_0)
    if f4_arg0:GetStringIndexedNumber("heatUpMode") == 1 then
        f4_local3 = 100
    end
    Approach_Act_Flex(f4_arg0, f4_arg1, f4_local0, f4_local1, f4_local2, f4_local3, f4_local4, f4_local5, f4_local6)
    local f4_local8 = 0
    local f4_local9 = 0
    if f4_local7 <= 5 then
        f4_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 3, 5201, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0)
    end
    f4_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3036, TARGET_ENE_0, 9999, f4_local8, f4_local9, 0, 0)
    f4_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat_SuccessAngle180, 10, 3003, TARGET_ENE_0, 9999, f4_local8, f4_local9, 0, 0)
    f4_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3033, TARGET_ENE_0, 9999, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act03 = function (f5_arg0, f5_arg1, f5_arg2)
    local f5_local0 = 2.8 - f5_arg0:GetMapHitRadius(TARGET_SELF)
    local f5_local1 = 2.8 - f5_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f5_local2 = 2.8 - f5_arg0:GetMapHitRadius(TARGET_SELF) + 10
    local f5_local3 = 0
    local f5_local4 = 0
    local f5_local5 = 3
    local f5_local6 = 3
    local f5_local7 = f5_arg0:GetDist(TARGET_ENE_0)
    if f5_arg0:GetStringIndexedNumber("heatUpMode") == 1 then
        f5_local3 = 100
    end
    Approach_Act_Flex(f5_arg0, f5_arg1, f5_local0, f5_local1, f5_local2, f5_local3, f5_local4, f5_local5, f5_local6)
    local f5_local8 = 0
    local f5_local9 = 0
    f5_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3062, TARGET_ENE_0, 9999, f5_local8, f5_local9, 0, 0)
    f5_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3064, TARGET_ENE_0, 9999, f5_local8, f5_local9, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act04 = function (f6_arg0, f6_arg1, f6_arg2)
    local f6_local0 = 3.6 - f6_arg0:GetMapHitRadius(TARGET_SELF)
    local f6_local1 = 3.6 - f6_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f6_local2 = 3.6 - f6_arg0:GetMapHitRadius(TARGET_SELF) + 5
    local f6_local3 = 0
    local f6_local4 = 0
    local f6_local5 = 3
    local f6_local6 = 3
    if f6_arg0:GetStringIndexedNumber("heatUpMode") == 1 then
        f6_local3 = 100
    end
    local f6_local7 = 5.6 - f6_arg0:GetMapHitRadius(TARGET_SELF)
    Approach_Act_Flex(f6_arg0, f6_arg1, f6_local0, f6_local1, f6_local2, f6_local3, f6_local4, f6_local5, f6_local6)
    if f6_arg0:HasSpecialEffectId(TARGET_SELF, 5021) then
        f6_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3067, TARGET_ENE_0, 9999, TurnTime, FrontAngle, 0, 0)
        f6_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3026, TARGET_ENE_0, 9999, TurnTime, FrontAngle, 0, 0)
    else
        f6_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3067, TARGET_ENE_0, 9999, TurnTime, FrontAngle, 0, 0)
        f6_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3018, TARGET_ENE_0, 9999, TurnTime, FrontAngle, 0, 0)
    end
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act05 = function (f7_arg0, f7_arg1, f7_arg2)
    local f7_local0 = f7_arg0:GetDist(TARGET_ENE_0)
    local f7_local1 = 5 - f7_arg0:GetMapHitRadius(TARGET_SELF)
    local f7_local2 = 5 - f7_arg0:GetMapHitRadius(TARGET_SELF)
    local f7_local3 = 5 - f7_arg0:GetMapHitRadius(TARGET_SELF) + 5
    local f7_local4 = 0
    local f7_local5 = 0
    local f7_local6 = 3
    local f7_local7 = 3
    local f7_local8 = f7_arg0:GetRandam_Int(1, 100)
    local f7_local9 = 3008
    if f7_arg0:GetStringIndexedNumber("heatUpMode") == 1 then
        f7_local4 = 100
    end
    local f7_local10 = 5 - f7_arg0:GetMapHitRadius(TARGET_SELF)
    local f7_local11 = 0
    local f7_local12 = 0
    local f7_local13 = 0
    local f7_local14 = 3031
    Approach_Act_Flex(f7_arg0, f7_arg1, f7_local1, f7_local2, f7_local3, f7_local4, f7_local5, f7_local6, f7_local7)
    f7_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f7_local9, TARGET_ENE_0, 9999, f7_local11, f7_local12, 0, 0):TimingSetNumber(5, f7_arg0:GetNumber(5) + 15, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act06 = function (f8_arg0, f8_arg1, f8_arg2)
    local f8_local0 = 6 - f8_arg0:GetMapHitRadius(TARGET_SELF)
    local f8_local1 = 6 - f8_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f8_local2 = 6 - f8_arg0:GetMapHitRadius(TARGET_SELF) + 5
    local f8_local3 = 0
    local f8_local4 = 0
    local f8_local5 = 3
    local f8_local6 = 3
    if f8_arg0:GetStringIndexedNumber("heatUpMode") == 1 then
        f8_local3 = 100
    end
    Approach_Act_Flex(f8_arg0, f8_arg1, f8_local0, f8_local1, f8_local2, f8_local3, f8_local4, f8_local5, f8_local6)
    local f8_local7 = 0
    local f8_local8 = 0
    f8_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 3, 3009, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f8_arg0:GetNumber(5) + 15, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act07 = function (f9_arg0, f9_arg1, f9_arg2)
    local f9_local0 = 7.1 - f9_arg0:GetMapHitRadius(TARGET_SELF)
    local f9_local1 = 2.8 - f9_arg0:GetMapHitRadius(TARGET_SELF)
    local f9_local2 = 7.1 - f9_arg0:GetMapHitRadius(TARGET_SELF) + 5
    local f9_local3 = 0
    local f9_local4 = 0
    local f9_local5 = 3
    local f9_local6 = 3
    if f9_arg0:GetStringIndexedNumber("heatUpMode") == 1 then
        f9_local3 = 100
    end
    Approach_Act_Flex(f9_arg0, f9_arg1, f9_local0, f9_local1, f9_local2, f9_local3, f9_local4, f9_local5, f9_local6)
    local f9_local7 = 0
    local f9_local8 = 0
    f9_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3019, TARGET_ENE_0, 9999, f9_local7, f9_local8, 0, 0):TimingSetNumber(5, f9_arg0:GetNumber(5) + 15, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act08 = function (f10_arg0, f10_arg1, f10_arg2)
    local f10_local0 = 2.5 - f10_arg0:GetMapHitRadius(TARGET_SELF)
    local f10_local1 = 2.5 - f10_arg0:GetMapHitRadius(TARGET_SELF)
    local f10_local2 = 2.5 - f10_arg0:GetMapHitRadius(TARGET_SELF) + 2
    local f10_local3 = 100
    local f10_local4 = 0
    local f10_local5 = 3
    local f10_local6 = 3
    local f10_local7 = f10_arg0:GetDistYSigned(TARGET_ENE_0)
    Approach_Act_Flex(f10_arg0, f10_arg1, f10_local0 + f10_local7 / 2, f10_local1, f10_local2, f10_local3, f10_local4, f10_local5, f10_local6)
    local f10_local8 = 0
    local f10_local9 = 0
    f10_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3011, TARGET_ENE_0, 9999, f10_local8, f10_local9, 0, 0):TimingSetNumber(5, f10_arg0:GetNumber(5) + 4, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act09 = function (f11_arg0, f11_arg1, f11_arg2)
    local f11_local0 = 4 - f11_arg0:GetMapHitRadius(TARGET_SELF)
    local f11_local1 = 4 - f11_arg0:GetMapHitRadius(TARGET_SELF)
    local f11_local2 = 4 - f11_arg0:GetMapHitRadius(TARGET_SELF) + 5
    local f11_local3 = 0
    local f11_local4 = 0
    local f11_local5 = 3
    local f11_local6 = 3
    if f11_arg0:GetStringIndexedNumber("heatUpMode") == 1 then
        f11_local3 = 100
    end
    local f11_local7 = 4 - f11_arg0:GetMapHitRadius(TARGET_SELF)
    local f11_local8 = 0
    local f11_local9 = 0
    local f11_local10 = f11_arg0:GetRandam_Int(1, 100)
    local f11_local11 = 3018
    local f11_local12 = 0
    local f11_local13 = 3031
    if SpaceCheck(f11_arg0, f11_arg1, 45, 2.5) == true then
        f11_local12 = 1
        f11_local11 = 3018
        f11_local0 = 4 - f11_arg0:GetMapHitRadius(TARGET_SELF) + 3
    end
    Approach_Act_Flex(f11_arg0, f11_arg1, f11_local0, f11_local1, f11_local2, f11_local3, f11_local4, f11_local5, f11_local6)
    f11_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, f11_local11, TARGET_ENE_0, 9999, f11_local8, f11_local9, 0, 0):TimingSetNumber(5, f11_arg0:GetNumber(5) + 3, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act10 = function (f12_arg0, f12_arg1, f12_arg2)
    f12_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3004, TARGET_ENE_0, 9999, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act11 = function (f13_arg0, f13_arg1, f13_arg2)
    local f13_local0 = 4.2 - f13_arg0:GetMapHitRadius(TARGET_SELF)
    local f13_local1 = 4.2 - f13_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f13_local2 = 4.2 - f13_arg0:GetMapHitRadius(TARGET_SELF) + 5
    local f13_local3 = 0
    local f13_local4 = 0
    local f13_local5 = 3
    local f13_local6 = 3
    if f13_arg0:GetStringIndexedNumber("heatUpMode") == 1 then
        f13_local3 = 100
    end
    Approach_Act_Flex(f13_arg0, f13_arg1, f13_local0, f13_local1, f13_local2, f13_local3, f13_local4, f13_local5, f13_local6)
    local f13_local7 = 0
    local f13_local8 = 0
    f13_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3017, TARGET_ENE_0, 9999, f13_local7, f13_local8, 0, 0):TimingSetNumber(5, f13_arg0:GetNumber(5) + 3, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act12 = function (f14_arg0, f14_arg1, f14_arg2)
    local f14_local0 = 4.7 - f14_arg0:GetMapHitRadius(TARGET_SELF)
    local f14_local1 = 2.8 - f14_arg0:GetMapHitRadius(TARGET_SELF)
    local f14_local2 = 4.7 - f14_arg0:GetMapHitRadius(TARGET_SELF)
    local f14_local3 = 0
    local f14_local4 = 0
    local f14_local5 = 3
    local f14_local6 = 3
    if f14_arg0:GetStringIndexedNumber("heatUpMode") == 1 then
        f14_local3 = 100
    end
    Approach_Act_Flex(f14_arg0, f14_arg1, f14_local0, f14_local1, f14_local2, f14_local3, f14_local4, f14_local5, f14_local6)
    local f14_local7 = 0
    local f14_local8 = 0
    f14_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3019, TARGET_ENE_0, 9999, f14_local7, f14_local8, 0, 0):TimingSetNumber(5, f14_arg0:GetNumber(5) + 15, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act13 = function (f15_arg0, f15_arg1, f15_arg2)
    local f15_local0 = 3.8 - f15_arg0:GetMapHitRadius(TARGET_SELF)
    local f15_local1 = 3.8 - f15_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f15_local2 = 3.8 - f15_arg0:GetMapHitRadius(TARGET_SELF) + 5
    local f15_local3 = 0
    local f15_local4 = 0
    local f15_local5 = 3
    local f15_local6 = 3
    if f15_arg0:GetStringIndexedNumber("heatUpMode") == 1 then
        f15_local3 = 100
    end
    Approach_Act_Flex(f15_arg0, f15_arg1, f15_local0, f15_local1, f15_local2, f15_local3, f15_local4, f15_local5, f15_local6)
    local f15_local7 = 0
    local f15_local8 = 0
    f15_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3020, TARGET_ENE_0, 9999, f15_local7, f15_local8, 0, 0):TimingSetNumber(5, f15_arg0:GetNumber(5) + 3, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act14 = function (f16_arg0, f16_arg1, f16_arg2)
    local f16_local0 = 4.2 - f16_arg0:GetMapHitRadius(TARGET_SELF)
    local f16_local1 = 4.2 - f16_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f16_local2 = 4.2 - f16_arg0:GetMapHitRadius(TARGET_SELF) + 5
    local f16_local3 = 0
    local f16_local4 = 0
    local f16_local5 = 3
    local f16_local6 = 3
    if f16_arg0:GetStringIndexedNumber("heatUpMode") == 1 then
        f16_local3 = 100
    end
    Approach_Act_Flex(f16_arg0, f16_arg1, f16_local0, f16_local1, f16_local2, f16_local3, f16_local4, f16_local5, f16_local6)
    local f16_local7 = 0
    local f16_local8 = 0
    f16_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3036, TARGET_ENE_0, 9999, f16_local7, f16_local8, 0, 0):TimingSetNumber(5, f16_arg0:GetNumber(5) + 3, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act15 = function (f17_arg0, f17_arg1, f17_arg2)
    local f17_local0 = 4.2 - f17_arg0:GetMapHitRadius(TARGET_SELF)
    local f17_local1 = 4.2 - f17_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f17_local2 = 4.2 - f17_arg0:GetMapHitRadius(TARGET_SELF) + 5
    local f17_local3 = 0
    local f17_local4 = 0
    local f17_local5 = 3
    local f17_local6 = 3
    if f17_arg0:GetStringIndexedNumber("heatUpMode") == 1 then
        f17_local3 = 100
    end
    Approach_Act_Flex(f17_arg0, f17_arg1, f17_local0, f17_local1, f17_local2, f17_local3, f17_local4, f17_local5, f17_local6)
    local f17_local7 = 0
    local f17_local8 = 0
    f17_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3037, TARGET_ENE_0, 9999, f17_local7, f17_local8, 0, 0):TimingSetNumber(5, f17_arg0:GetNumber(5) + 3, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act16 = function (f18_arg0, f18_arg1, f18_arg2)
    local f18_local0 = 3.5 - f18_arg0:GetMapHitRadius(TARGET_SELF)
    local f18_local1 = 3.5 - f18_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f18_local2 = 3.5 - f18_arg0:GetMapHitRadius(TARGET_SELF) + 5
    local f18_local3 = 0
    local f18_local4 = 0
    local f18_local5 = 3
    local f18_local6 = 3
    if f18_arg0:GetStringIndexedNumber("heatUpMode") == 1 then
        f18_local3 = 100
    end
    Approach_Act_Flex(f18_arg0, f18_arg1, f18_local0, f18_local1, f18_local2, f18_local3, f18_local4, f18_local5, f18_local6)
    f18_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3001, TARGET_ENE_0, 999, TurnTime, FrontAngle, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act17 = function (f19_arg0, f19_arg1, f19_arg2)
    local f19_local0 = 6 - f19_arg0:GetMapHitRadius(TARGET_SELF)
    local f19_local1 = 6 - f19_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f19_local2 = 6 - f19_arg0:GetMapHitRadius(TARGET_SELF) + 5
    local f19_local3 = 0
    local f19_local4 = 0
    local f19_local5 = 1.5
    local f19_local6 = 3
    local f19_local7 = f19_arg0:GetDist(TARGET_ENE_0)
    Approach_Act_Flex(f19_arg0, f19_arg1, f19_local0, f19_local1, f19_local2, f19_local3, f19_local4, f19_local5, f19_local6)
    if f19_local7 <= f19_local2 then
        f19_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, 1.5, TARGET_ENE_0, f19_arg0:GetRandam_Int(0, 1), f19_arg0:GetRandam_Int(30, 45), true, true, -1)
    end
    f19_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3021, TARGET_ENE_0, 999, 0, 0, 0, 0)
    f19_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3022, TARGET_ENE_0, 999, 0, 0, 0, 0)
    f19_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3022, TARGET_ENE_0, 999, 0, 0, 0, 0)
    f19_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3023, TARGET_ENE_0, 999, 0, 0, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act18 = function (f20_arg0, f20_arg1, f20_arg2)
    local f20_local0 = 4.7 - f20_arg0:GetMapHitRadius(TARGET_SELF)
    local f20_local1 = 2.8 - f20_arg0:GetMapHitRadius(TARGET_SELF)
    local f20_local2 = 4.7 - f20_arg0:GetMapHitRadius(TARGET_SELF)
    local f20_local3 = 0
    local f20_local4 = 0
    local f20_local5 = 3
    local f20_local6 = 3
    if f20_arg0:GetStringIndexedNumber("heatUpMode") == 1 then
        f20_local3 = 100
    end
    Approach_Act_Flex(f20_arg0, f20_arg1, f20_local0, f20_local1, f20_local2, f20_local3, f20_local4, f20_local5, f20_local6)
    local f20_local7 = 0
    local f20_local8 = 0
    f20_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3019, TARGET_ENE_0, 999, 0, 0, 0, 0)
    f20_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3007, TARGET_ENE_0, 999, 0, 0, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act19 = function (f21_arg0, f21_arg1, f21_arg2)
    local f21_local0 = f21_arg0:GetDist(TARGET_ENE_0)
    local f21_local1 = 6 - f21_arg0:GetMapHitRadius(TARGET_SELF)
    local f21_local2 = 6 - f21_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f21_local3 = 6 - f21_arg0:GetMapHitRadius(TARGET_SELF) + 5
    local f21_local4 = 0
    local f21_local5 = 0
    local f21_local6 = 3
    local f21_local7 = 3
    if f21_arg0:GetStringIndexedNumber("heatUpMode") == 1 then
        f21_local4 = 100
    end
    if f21_local0 <= 5 and SpaceCheck(f21_arg0, f21_arg1, 180, 3) == true then
        f21_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 3, 5201, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0)
        f21_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 3, 5201, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0):TimingSetTimer(0, 2, AI_TIMING_SET__ACTIVATE):TimingSetTimer(3, 10, AI_TIMING_SET__ACTIVATE)
    end
    local f21_local8 = 0
    local f21_local9 = 0
    f21_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3090, TARGET_ENE_0, 9999, f21_local8, f21_local9, 0, 0):TimingSetNumber(0, 1, AI_TIMING_SET__ACTIVATE):TimingSetTimer(7, 5, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act20 = function (f22_arg0, f22_arg1, f22_arg2)
    local f22_local0 = f22_arg0:GetDist(TARGET_ENE_0)
    if f22_local0 <= 5 and SpaceCheck(f22_arg0, f22_arg1, 180, 3) == true then
        f22_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 3, 5201, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0)
        f22_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 3, 5201, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0):TimingSetTimer(0, 2, AI_TIMING_SET__ACTIVATE):TimingSetTimer(3, 10, AI_TIMING_SET__ACTIVATE)
    end
    local f22_local1 = 0
    local f22_local2 = 0
    f22_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3091, TARGET_ENE_0, 9999, f22_local1, f22_local2, 0, 0):TimingSetNumber(0, 1, AI_TIMING_SET__ACTIVATE):TimingSetTimer(6, 8, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act30 = function (f23_arg0, f23_arg1, f23_arg2)
    local f23_local0 = f23_arg0:GetDist(TARGET_ENE_0)
    local f23_local1 = 3
    local f23_local2 = 0
    local f23_local3 = 3020
    local f23_local4 = 0
    local f23_local5 = 0
    f23_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3041, TARGET_ENE_0, 9999, f23_local4, f23_local5, 0, 0)
    GetWellSpace_Odds = 100
    return GET_WELL_SPACE_ODDS
    
end

Goal.Act31 = function (f24_arg0, f24_arg1, f24_arg2)
    local f24_local0 = 4.2 - f24_arg0:GetMapHitRadius(TARGET_SELF)
    local f24_local1 = 4.2 - f24_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f24_local2 = 4.2 - f24_arg0:GetMapHitRadius(TARGET_SELF) + 5
    local f24_local3 = 0
    local f24_local4 = 0
    local f24_local5 = 3
    local f24_local6 = 3
    if f24_arg0:GetStringIndexedNumber("heatUpMode") == 1 then
        f24_local3 = 100
    end
    Approach_Act_Flex(f24_arg0, f24_arg1, f24_local0, f24_local1, f24_local2, f24_local3, f24_local4, f24_local5, f24_local6)
    local f24_local7 = 0
    local f24_local8 = 0
    f24_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3036, TARGET_ENE_0, 9999, f24_local7, f24_local8, 0, 0)
    f24_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3033, TARGET_ENE_0, 9999, f24_local7, f24_local8, 0, 0):TimingSetNumber(5, f24_arg0:GetNumber(5) + 3, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act32 = function (f25_arg0, f25_arg1, f25_arg2)
    f25_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3005, TARGET_ENE_0, 9999, TurnTime, FrontAngle, 0, 0)
    f25_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3090, TARGET_ENE_0, 9999, TurnTime, FrontAngle, 0, 0):TimingSetNumber(0, 1, AI_TIMING_SET__ACTIVATE):TimingSetTimer(7, 5, AI_TIMING_SET__ACTIVATE)
    f25_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, f25_arg0:GetRandam_Float(0.2, 0.8), TARGET_ENE_0, 999, TARGET_ENE_0, true, -1):TimingSetTimer(3, 5, AI_TIMING_SET__ACTIVATE)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act33 = function (f26_arg0, f26_arg1, f26_arg2)
    local f26_local0 = 4.5 - f26_arg0:GetMapHitRadius(TARGET_SELF)
    local f26_local1 = 4.8 - f26_arg0:GetMapHitRadius(TARGET_SELF)
    local f26_local2 = 0
    local f26_local3 = 0
    f26_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3027, TARGET_ENE_0, 9999, f26_local2, f26_local3, 0, 0)
    f26_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3028, TARGET_ENE_0, f26_local1, f26_local2, f26_local3, 0, 0)
    f26_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3029, TARGET_ENE_0, 9999, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act34 = function (f27_arg0, f27_arg1, f27_arg2)
    local f27_local0 = 6 - f27_arg0:GetMapHitRadius(TARGET_SELF)
    local f27_local1 = 6 - f27_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f27_local2 = 6 - f27_arg0:GetMapHitRadius(TARGET_SELF) + 5
    local f27_local3 = 0
    local f27_local4 = 0
    local f27_local5 = 3
    local f27_local6 = 3
    if f27_arg0:GetStringIndexedNumber("heatUpMode") == 1 then
        f27_local3 = 100
    end
    Approach_Act_Flex(f27_arg0, f27_arg1, f27_local0, f27_local1, f27_local2, f27_local3, f27_local4, f27_local5, f27_local6)
    local f27_local7 = 4.5 - f27_arg0:GetMapHitRadius(TARGET_SELF)
    local f27_local8 = 4.8 - f27_arg0:GetMapHitRadius(TARGET_SELF)
    local f27_local9 = 0
    local f27_local10 = 0
    local f27_local11 = f27_arg0:GetRandam_Int(1, 100)
    f27_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3026, TARGET_ENE_0, f27_local7, f27_local9, f27_local10, 0, 0)
    f27_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3029, TARGET_ENE_0, 9999, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act35 = function (f28_arg0, f28_arg1, f28_arg2)
    local f28_local0 = 6 - f28_arg0:GetMapHitRadius(TARGET_SELF)
    local f28_local1 = 6 - f28_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f28_local2 = 6 - f28_arg0:GetMapHitRadius(TARGET_SELF) + 5
    local f28_local3 = 0
    local f28_local4 = 0
    local f28_local5 = 3
    local f28_local6 = 3
    if f28_arg0:GetStringIndexedNumber("heatUpMode") == 1 then
        f28_local3 = 100
    end
    Approach_Act_Flex(f28_arg0, f28_arg1, f28_local0, f28_local1, f28_local2, f28_local3, f28_local4, f28_local5, f28_local6)
    local f28_local7 = 4.5 - f28_arg0:GetMapHitRadius(TARGET_SELF)
    local f28_local8 = 4.8 - f28_arg0:GetMapHitRadius(TARGET_SELF)
    local f28_local9 = 0
    local f28_local10 = 0
    local f28_local11 = f28_arg0:GetRandam_Int(1, 100)
    f28_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3026, TARGET_ENE_0, f28_local7, f28_local9, f28_local10, 0, 0)
    f28_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3028, TARGET_ENE_0, f28_local8, f28_local9, f28_local10, 0, 0)
    f28_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3029, TARGET_ENE_0, 9999, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act36 = function (f29_arg0, f29_arg1, f29_arg2)
    local f29_local0 = 3
    f29_arg0:SetEventMoveTarget(1122330)
    f29_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, f29_local0, POINT_EVENT, 0.5, TARGET_SELF, false, -1)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act37 = function (f30_arg0, f30_arg1, f30_arg2)
    local f30_local0 = 1.2
    local f30_local1 = 0
    local f30_local2 = 1
    local f30_local3 = 0
    local f30_local4 = 0
    local f30_local5 = 1
    local f30_local6 = 1
    local f30_local7 = f30_arg0:GetDist(TARGET_ENE_0)
    if f30_arg0:GetStringIndexedNumber("heatUpMode") == 1 then
        f30_local3 = 100
    end
    Approach_Act_Flex(f30_arg0, f30_arg1, f30_local0, f30_local1, f30_local2, f30_local3, f30_local4, f30_local5, f30_local6)
    local f30_local8 = 0
    local f30_local9 = 0
    f30_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3062, TARGET_ENE_0, 9999, f30_local8, f30_local9, 0, 0)
    f30_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3064, TARGET_ENE_0, 9999, f30_local8, f30_local9, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act40 = function (f31_arg0, f31_arg1, f31_arg2)
    local f31_local0 = f31_arg0:GetDist(TARGET_ENE_0)
    local f31_local1 = 3
    local f31_local2 = 0
    local f31_local3 = 3020
    local f31_local4 = 0
    local f31_local5 = 0
    if f31_local0 < 5 and SpaceCheck(f31_arg0, f31_arg1, 180, 4) == true then
        f31_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f31_local1, 5201, TARGET_ENE_0, f31_local4, AI_DIR_TYPE_B, 0):TimingSetTimer(3, 6, UPDATE_SUCCESS)
        f31_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f31_local1, 5201, TARGET_ENE_0, f31_local4, AI_DIR_TYPE_B, 0):TimingSetTimer(3, 6, UPDATE_SUCCESS)
    end
    f31_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3040, TARGET_ENE_0, 9999, f31_local4, f31_local5, 0, 0):TimingSetTimer(4, 8, UPDATE_SUCCESS)
    f31_arg0:SetTimer(6, 20)
    return GET_WELL_SPACE_ODDS
    
end

Goal.Act41 = function (f32_arg0, f32_arg1, f32_arg2)
    local f32_local0 = f32_arg0:GetDist(TARGET_ENE_0)
    local f32_local1 = 3
    local f32_local2 = 3
    local f32_local3 = f32_arg0:GetRandam_Int(30, 45)
    local f32_local4 = -1
    local f32_local5 = f32_arg0:GetRandam_Int(0, 1)
    if f32_local0 <= 3 then
        f32_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, WalkLife, TARGET_ENE_0, 4, TARGET_ENE_0, true, guard)
    else
        f32_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f32_local1, TARGET_ENE_0, f32_local5, f32_local3, true, true, f32_local4)
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act42 = function (f33_arg0, f33_arg1, f33_arg2)
    local f33_local0 = 4.8 - f33_arg0:GetMapHitRadius(TARGET_SELF)
    local f33_local1 = 4.8 - f33_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f33_local2 = 4.8 - f33_arg0:GetMapHitRadius(TARGET_SELF) + 5
    local f33_local3 = 0
    local f33_local4 = 0
    local f33_local5 = 3
    local f33_local6 = 3
    if f33_arg0:GetStringIndexedNumber("heatUpMode") == 1 then
        f33_local3 = 100
    end
    Approach_Act_Flex(f33_arg0, f33_arg1, f33_local0, f33_local1, f33_local2, f33_local3, f33_local4, f33_local5, f33_local6)
    local f33_local7 = 4 - f33_arg0:GetMapHitRadius(TARGET_SELF)
    local f33_local8 = 0
    local f33_local9 = 0
    local f33_local10 = f33_arg0:GetRandam_Int(1, 100)
    f33_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3024, TARGET_ENE_0, 9999, f33_local8, f33_local9, 0, 0):TimingSetNumber(5, f33_arg0:GetNumber(5) + 3, AI_TIMING_SET__ACTIVATE)
    if not (f33_arg0:IsInsideTargetRegion(TARGET_SELF, 1112250) or f33_arg0:IsInsideTargetRegion(TARGET_ENE_0, 1112250)) then
        f33_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3034, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f33_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    end
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act43 = function (f34_arg0, f34_arg1, f34_arg2)
    local f34_local0 = f34_arg0:GetDist(TARGET_ENE_0)
    local f34_local1 = 3
    local f34_local2 = 0
    local f34_local3 = 3020
    local f34_local4 = 0
    local f34_local5 = 0
    if f34_local0 <= 3 then
        f34_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 1, 5201, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0)
        f34_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 1, 5201, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0)
        f34_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3045, TARGET_ENE_0, 9999, f34_local4, f34_local5, 0, 0):TimingSetTimer(8, 8, AI_TIMING_SET__ACTIVATE)
    else
        f34_arg1:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3045, TARGET_ENE_0, 9999, f34_local4, f34_local5, 0, 0):TimingSetTimer(8, 8, AI_TIMING_SET__ACTIVATE)
    end
    GetWellSpace_Odds = 100
    return GET_WELL_SPACE_ODDS
    
end

Goal.Act44 = function (f35_arg0, f35_arg1, f35_arg2)
    local f35_local0 = 6 - f35_arg0:GetMapHitRadius(TARGET_SELF)
    local f35_local1 = 6 - f35_arg0:GetMapHitRadius(TARGET_SELF) + 0
    local f35_local2 = 6 - f35_arg0:GetMapHitRadius(TARGET_SELF) + 5
    local f35_local3 = 0
    local f35_local4 = 0
    local f35_local5 = 3
    local f35_local6 = 3
    if f35_arg0:GetStringIndexedNumber("heatUpMode") == 1 then
        f35_local3 = 100
    end
    Approach_Act_Flex(f35_arg0, f35_arg1, f35_local0, f35_local1, f35_local2, f35_local3, f35_local4, f35_local5, f35_local6)
    local f35_local7 = 4.5 - f35_arg0:GetMapHitRadius(TARGET_SELF)
    local f35_local8 = 4.8 - f35_arg0:GetMapHitRadius(TARGET_SELF)
    local f35_local9 = 0
    local f35_local10 = 0
    local f35_local11 = f35_arg0:GetRandam_Int(1, 100)
    f35_arg1:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3017, TARGET_ENE_0, 9999, f35_local9, f35_local10, 0, 0)
    f35_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3024, TARGET_ENE_0, 9999, f35_local9, f35_local10, 0, 0)
    f35_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3033, TARGET_ENE_0, 9999, f35_local9, f35_local10, 0, 0)
    f35_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3064, TARGET_ENE_0, 9999, f35_local9, f35_local10, 0, 0)
    f35_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3035, TARGET_ENE_0, 9999, f35_local9, f35_local10, 0, 0)
    f35_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3007, TARGET_ENE_0, 9999, f35_local9, f35_local10, 0, 0)
    f35_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3026, TARGET_ENE_0, 9999, f35_local9, f35_local10, 0, 0)
    f35_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3028, TARGET_ENE_0, 9999, f35_local9, f35_local10, 0, 0)
    f35_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3029, TARGET_ENE_0, 9999, 0, 0)
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act21 = function (f36_arg0, f36_arg1, f36_arg2)
    local f36_local0 = 3
    local f36_local1 = 45
    f36_arg1:AddSubGoal(GOAL_COMMON_Turn, f36_local0, TARGET_ENE_0, f36_local1, -1, GOAL_RESULT_Success, true)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act22 = function (f37_arg0, f37_arg1, f37_arg2)
    local f37_local0 = 3
    local f37_local1 = 0
    local f37_local2 = 5202
    if SpaceCheck(f37_arg0, f37_arg1, -45, 2.5) == true then
        if SpaceCheck(f37_arg0, f37_arg1, 45, 2.5) == true then
            if f37_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                f37_local2 = 5202
            else
                f37_local2 = 5203
            end
        else
            f37_local2 = 5202
        end
    elseif SpaceCheck(f37_arg0, f37_arg1, 45, 2.5) == true then
        f37_local2 = 5203
    else
    end
    f37_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f37_local0, f37_local2, TARGET_ENE_0, f37_local1, AI_DIR_TYPE_R, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act23 = function (f38_arg0, f38_arg1, f38_arg2)
    local f38_local0 = f38_arg0:GetDist(TARGET_ENE_0)
    local f38_local1 = f38_arg0:GetSp(TARGET_SELF)
    local f38_local2 = f38_arg0:GetRandam_Int(1, 100)
    local f38_local3 = 0
    if SpaceCheck(f38_arg0, f38_arg1, -90, 1) == true then
        if SpaceCheck(f38_arg0, f38_arg1, 90, 1) == true then
            if f38_arg0:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_R, 180, 999) then
                f38_local3 = 1
            else
                f38_local3 = 0
            end
        else
            f38_local3 = 0
        end
    elseif SpaceCheck(f38_arg0, f38_arg1, 90, 1) == true then
        f38_local3 = 1
    else
    end
    local f38_local4 = f38_arg0:GetRandam_Float(3, 3)
    local f38_local5 = f38_arg0:GetRandam_Int(30, 45)
    if f38_arg0:GetStringIndexedNumber("heatUpMode") == 1 then
        f38_local4 = f38_arg0:GetRandam_Float(2, 3.5)
    end
    f38_arg0:SetNumber(10, f38_local3)
    f38_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f38_local4, TARGET_ENE_0, f38_local3, f38_local5, true, true, -1):TimingSetNumber(5, 0, AI_TIMING_SET__ACTIVATE)
    local f38_local6 = 90
    local f38_local7 = 4
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act24 = function (f39_arg0, f39_arg1, f39_arg2)
    local f39_local0 = f39_arg0:GetDist(TARGET_ENE_0)
    local f39_local1 = 3
    local f39_local2 = 0
    local f39_local3 = 5201
    local f39_local4 = f39_arg0:GetRandam_Int(1, 100)
    if SpaceCheck(f39_arg0, f39_arg1, 180, 6) == true and f39_local4 <= 50 then
        f39_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f39_local1, f39_local3, TARGET_ENE_0, f39_local2, AI_DIR_TYPE_B, 0)
        f39_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f39_local1, f39_local3, TARGET_ENE_0, f39_local2, AI_DIR_TYPE_B, 0):TimingSetTimer(0, 2, AI_TIMING_SET__ACTIVATE):TimingSetTimer(3, 10, AI_TIMING_SET__ACTIVATE)
    else
        f39_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f39_local1, f39_local3, TARGET_ENE_0, f39_local2, AI_DIR_TYPE_B, 0):TimingSetTimer(0, 2, AI_TIMING_SET__ACTIVATE):TimingSetTimer(3, 10, AI_TIMING_SET__ACTIVATE)
    end
    GetWellSpace_Odds = 100
    return GetWellSpace_Odds
    
end

Goal.Act25 = function (f40_arg0, f40_arg1, f40_arg2)
    local f40_local0 = f40_arg0:GetRandam_Float(2, 4)
    local f40_local1 = f40_arg0:GetRandam_Float(5, 7)
    local f40_local2 = f40_arg0:GetDist(TARGET_ENE_0)
    local f40_local3 = -1
    f40_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, f40_local0, TARGET_ENE_0, f40_local1, TARGET_ENE_0, true, f40_local3):TimingSetTimer(3, 5, AI_TIMING_SET__ACTIVATE)
    local f40_local4 = 90
    local f40_local5 = 4
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act26 = function (f41_arg0, f41_arg1, f41_arg2)
    f41_arg1:AddSubGoal(GOAL_COMMON_Wait, 0.5, TARGET_SELF, 0, 0, 0)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act27 = function (f42_arg0, f42_arg1, f42_arg2)
    local f42_local0 = f42_arg0:GetDist(TARGET_ENE_0)
    local f42_local1 = f42_arg0:GetDistYSigned(TARGET_ENE_0)
    local f42_local2 = f42_local1 / math.tan(math.deg(30))
    local f42_local3 = f42_arg0:GetRandam_Int(0, 1)
    if f42_local1 >= 2.5 then
        if f42_local2 + 1 <= f42_local0 then
            if SpaceCheck(f42_arg0, f42_arg1, 0, 4) == true then
                f42_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.1, TARGET_ENE_0, f42_local2, TARGET_SELF, false, -1)
            elseif SpaceCheck(f42_arg0, f42_arg1, 0, 3) == true then
                f42_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.5, TARGET_ENE_0, f42_local2, TARGET_SELF, true, -1)
            else
                f42_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, 3, TARGET_ENE_0, f42_local3, f42_arg0:GetRandam_Int(30, 45), true, true, -1)
            end
        elseif f42_local0 <= f42_local2 - 1 then
            f42_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 10, TARGET_ENE_0, f42_local2, TARGET_ENE_0, true, -1)
        else
            f42_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, 3, TARGET_ENE_0, f42_local3, f42_arg0:GetRandam_Int(30, 45), true, true, -1)
            f42_arg0:SetNumber(10, f42_local3)
        end
    elseif SpaceCheck(f42_arg0, f42_arg1, 0, 4) == true then
        f42_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.1, TARGET_ENE_0, 0, TARGET_SELF, false, -1)
    elseif SpaceCheck(f42_arg0, f42_arg1, 0, 3) == true then
        f42_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 0.5, TARGET_ENE_0, 0, TARGET_SELF, true, -1)
    elseif SpaceCheck(f42_arg0, f42_arg1, 0, 1) == false then
        f42_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 0.5, TARGET_ENE_0, 999, TARGET_ENE_0, true, -1)
    else
        f42_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, 3, TARGET_ENE_0, f42_local3, f42_arg0:GetRandam_Int(30, 45), true, true, -1)
        f42_arg0:SetNumber(10, f42_local3)
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act28 = function (f43_arg0, f43_arg1, f43_arg2)
    local f43_local0 = f43_arg0:GetDist(TARGET_ENE_0)
    local f43_local1 = 1.5
    local f43_local2 = 1.5
    local f43_local3 = f43_arg0:GetRandam_Int(30, 45)
    local f43_local4 = -1
    local f43_local5 = f43_arg0:GetRandam_Int(0, 1)
    if f43_local0 <= 3 then
        f43_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f43_local1, TARGET_ENE_0, f43_local5, f43_local3, true, true, f43_local4)
    elseif f43_local0 <= 8 then
        f43_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, f43_local2, TARGET_ENE_0, 3, TARGET_SELF, true, -1)
    else
        f43_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, f43_local2, TARGET_ENE_0, 8, TARGET_SELF, false, -1)
    end
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Act29 = function (f44_arg0, f44_arg1, f44_arg2)
    local f44_local0 = 3
    f44_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, f44_local0, TARGET_ENE_0, 8, TARGET_SELF, true, -1)
    GetWellSpace_Odds = 0
    return GetWellSpace_Odds
    
end

Goal.Interrupt = function (f45_arg0, f45_arg1, f45_arg2)
    local f45_local0 = f45_arg1:GetSpecialEffectActivateInterruptType(0)
    local f45_local1 = f45_arg1:GetDist(TARGET_ENE_0)
    local f45_local2 = f45_arg1:GetDistYSigned(TARGET_ENE_0)
    local f45_local3 = f45_arg1:GetRandam_Int(0, 100)
    if f45_arg1:IsLadderAct(TARGET_SELF) then
        return false
    end
    if not f45_arg1:HasSpecialEffectId(TARGET_SELF, 200004) then
        return false
    end
    if f45_arg1:IsInterupt(INTERUPT_ParryTiming) then
        return Common_Parry(f45_arg1, f45_arg2, 50, 0, 1, 3102)
    end
    if f45_arg1:IsInterupt(INTERUPT_Damaged) and not f45_arg1:HasSpecialEffectId(TARGET_SELF, 5028) then
        return f45_arg0.Damaged(f45_arg1, f45_arg2)
    end
    if f45_arg1:IsInterupt(INTERUPT_ActivateSpecialEffect) then
        if f45_local0 == 5027 then
            if f45_local1 <= 3.8 then
                f45_arg2:ClearSubGoal()
                f45_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 2, 3023, TARGET_ENE_0, 9999, 0, 0)
                return true
            elseif f45_local1 >= 5.5 then
                f45_arg2:ClearSubGoal()
                f45_arg2:AddSubGoal(GOAL_COMMON_EndureAttack, 2, 3023, TARGET_ENE_0, 9999, 0, 0)
                return true
            end
        elseif f45_local0 == 5028 then
            if f45_arg1:HasSpecialEffectId(TARGET_SELF, 3147111) and f45_local1 <= 4 then
                f45_arg1:Replanning()
                return true
            end
        elseif f45_local0 == 5029 then
            if f45_arg1:HasSpecialEffectId(TARGET_SELF, 5023) and f45_local1 >= 3 and f45_local1 <= 9 then
                if f45_local3 <= 50 then
                    f45_arg2:ClearSubGoal()
                    f45_arg2:AddSubGoal(GOAL_COMMON_ComboRepeat, 5, 3018, TARGET_ENE_0, 9999, 0, 0, 0, 0)
                    return true
                else
                    f45_arg2:ClearSubGoal()
                    f45_arg2:AddSubGoal(GOAL_COMMON_ComboRepeat, 5, 3003, TARGET_ENE_0, 9999, 0, 0, 0, 0)
                    return true
                end
            end
        elseif f45_local0 == 3147120 then
            f45_arg1:SetNumber(3, 1)
        end
    end
    if f45_arg1:IsInterupt(INTERUPT_ShootImpact) and f45_arg0.ShootReaction(f45_arg1, f45_arg2) then
        return true
    end
    if Interupt_Use_Item(f45_arg1, 10, 10) and f45_arg1:HasSpecialEffectId(TARGET_SELF, 5023) then
        if ThinkParam == 14703000 and f45_local2 <= -1.1 then
            f45_arg1:Replanning()
            return true
        elseif f45_local1 <= 2.5 then
            f45_arg2:ClearSubGoal()
            f45_arg2:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 1, 3000, TARGET_ENE_0, 9999, 0, 0, 0, 0)
            return true
        elseif f45_local1 <= 5 then
            f45_arg2:ClearSubGoal()
            f45_arg2:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 1, 3018, TARGET_ENE_0, 9999, 0, 0, 0, 0)
            return true
        elseif f45_arg1:HasSpecialEffectId(TARGET_SELF, 5021) and f45_local1 <= 6 - f45_arg1:GetMapHitRadius(TARGET_SELF) then
            f45_arg2:ClearSubGoal()
            f45_arg2:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 1, 3026, TARGET_ENE_0, 9999, 0, 0, 0, 0)
            return true
        else
            f45_arg1:Replanning()
            return true
        end
    end
    return false
    
end

Goal.Damaged = function (f46_arg0, f46_arg1, f46_arg2)
    local f46_local0 = 1
    local f46_local1 = f46_arg0:GetDist(TARGET_ENE_0)
    local f46_local2 = f46_arg0:GetRandam_Int(1, 100)
    if SpaceCheck(f46_arg0, f46_arg1, 180, 2.5) and f46_arg0:IsFinishTimer(3) and f46_local2 <= 50 then
        f46_arg1:ClearSubGoal()
        f46_arg0:SetTimer(3, 6)
        f46_arg1:AddSubGoal(GOAL_COMMON_SpinStep, f46_local0, 5201, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0):TimingSetTimer(0, 2, AI_TIMING_SET__ACTIVATE)
        return true
    end
    return false
    
end

Goal.ShootReaction = function (f47_arg0, f47_arg1)
    local f47_local0 = f47_arg0:GetDist(TARGET_ENE_0)
    if f47_arg0:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_F, 20, 999) then
        if f47_local0 <= 30 then
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
    return false
    
end

Goal.Kengeki_Activate = function (f48_arg0, f48_arg1, f48_arg2, f48_arg3)
    local f48_local0 = ReturnKengekiSpecialEffect(f48_arg1)
    if f48_local0 == 0 then
        return false
    end
    if f48_local0 == 200215 or f48_local0 == 200216 or f48_local0 == 200200 or f48_local0 == 200201 then
        f48_arg1:SetNumber(1, f48_arg1:GetNumber(1) + 1)
    end
    local f48_local1 = {}
    local f48_local2 = {}
    local f48_local3 = {}
    Common_Clear_Param(f48_local1, f48_local2, f48_local3)
    local f48_local4 = f48_arg1:GetDist(TARGET_ENE_0)
    local f48_local5 = f48_arg1:GetDistYSigned(TARGET_ENE_0)
    local f48_local6 = f48_arg1:GetSp(TARGET_SELF)
    local f48_local7 = 90
    local f48_local8 = f48_arg1:GetRandam_Int(4, 6)
    local f48_local9 = f48_arg1:GetNumber(1)
    local f48_local10 = f48_arg1:GetRandam_Int(1, 100)
    local f48_local11 = f48_arg1:GetHpRate(TARGET_SELF)
    local f48_local12 = f48_arg1:GetNpcThinkParamID()
    if f48_local0 == 200228 then
        f48_local1[6] = 100
        f48_local1[50] = 50
    elseif f48_local4 >= 4 then
        f48_local1[50] = 1000
    elseif f48_local12 == 14703000 and f48_local5 <= -1.1 then
        f48_local1[18] = 500
        f48_local1[26] = 400
        f48_local1[50] = 100
    elseif f48_local0 == 200210 then
        f48_local1[5] = 350
        f48_local1[6] = 650
        f48_local1[22] = 650
    elseif f48_local0 == 200211 then
        f48_local1[5] = 350
        f48_local1[6] = 650
        f48_local1[22] = 650
    elseif f48_local9 >= 4 then
        if f48_local4 <= 4 then
            if f48_local11 <= 0.5 then
                f48_local1[10] = 100
                f48_local1[40] = 1
            else
                f48_local1[40] = 10
            end
        else
            f48_local1[50] = 50
        end
    elseif f48_local0 == 200205 then
        f48_local1[2] = 300
        f48_local1[3] = 100
        f48_local1[8] = 100
        f48_local1[16] = 200
    elseif f48_local0 == 200200 then
        f48_local1[10] = 50
        f48_local1[11] = 200
        f48_local1[18] = 300
        f48_local1[24] = 300
    elseif f48_local0 == 200215 then
        f48_local1[2] = 200
        f48_local1[3] = 200
        f48_local1[8] = 200
        if f48_arg1:GetDist(TARGET_FRI_0) <= 30 and f48_arg1:HasSpecialEffectId(TARGET_FRI_0, 3115030) then
            f48_local1[41] = 10000
        end
    elseif f48_local0 == 200206 then
        f48_local1[2] = 200
        f48_local1[4] = 300
    elseif f48_local0 == 200201 then
        f48_local1[10] = 50
        f48_local1[19] = 100
        f48_local1[24] = 300
    elseif f48_local0 == 200216 then
        f48_local1[2] = 200
        f48_local1[4] = 300
        if f48_arg1:IsFinishTimer(7) == true and f48_arg1:GetDist(TARGET_FRI_0) <= 30 and f48_arg1:HasSpecialEffectId(TARGET_FRI_0, 3115030) then
            f48_local1[41] = 10000
        end
    elseif f48_local0 == 200225 then
        f48_local1[2] = 300
        f48_local1[3] = 200
    elseif f48_local0 == 200227 then
        f48_local1[18] = 300
        f48_local1[24] = 300
    else
    end
    if f48_local4 >= 2 then
        f48_local1[2] = 0
        f48_local1[8] = 0
    end
    if not f48_arg1:HasSpecialEffectId(TARGET_SELF, 5023) and f48_arg1:HasSpecialEffectId(TARGET_SELF, 5021) then
        f48_local1[2] = 0
        f48_local1[8] = 0
        f48_local1[10] = 0
        f48_local1[11] = 0
        f48_local1[40] = 0
    end
    if not f48_arg1:HasSpecialEffectId(TARGET_SELF, 5021) then
        f48_local1[22] = 0
    end
    if SpaceCheck(f48_arg1, f48_arg2, 180, 2.5) == false then
        f48_local1[24] = 0
    end
    if SpaceCheck(f48_arg1, f48_arg2, 90, 1) == false and SpaceCheck(f48_arg1, f48_arg2, -90, 1) == false then
        f48_local1[23] = 0
    end
    if SpaceCheck(f48_arg1, f48_arg2, 180, 1) == false then
        f48_local1[25] = 0
    end
    if f48_arg1:IsFinishTimer(3) == false then
        f48_local1[24] = 0
    end
    if f48_arg1:IsInsideTargetRegion(TARGET_SELF, 1112250) or f48_arg1:IsInsideTargetRegion(TARGET_ENE_0, 1112250) then
        f48_local1[6] = 0
    end
    f48_local1[1] = SetCoolTime(f48_arg1, f48_arg2, 3015, 5, f48_local1[1], 1)
    f48_local1[2] = SetCoolTime(f48_arg1, f48_arg2, 3017, 3, f48_local1[2], 1)
    f48_local1[2] = SetCoolTime(f48_arg1, f48_arg2, 3058, 3, f48_local1[2], 1)
    f48_local1[3] = SetCoolTime(f48_arg1, f48_arg2, 3051, 5, f48_local1[3], 1)
    f48_local1[4] = SetCoolTime(f48_arg1, f48_arg2, 3055, 5, f48_local1[4], 1)
    f48_local1[5] = SetCoolTime(f48_arg1, f48_arg2, 3056, 5, f48_local1[5], 1)
    f48_local1[6] = SetCoolTime(f48_arg1, f48_arg2, 3019, 20, f48_local1[6], 1)
    f48_local1[7] = SetCoolTime(f48_arg1, f48_arg2, 3066, 2, f48_local1[7], 1)
    f48_local1[8] = SetCoolTime(f48_arg1, f48_arg2, 3060, 2, f48_local1[8], 1)
    f48_local1[9] = SetCoolTime(f48_arg1, f48_arg2, 3008, 5, f48_local1[9], 1)
    f48_local1[10] = SetCoolTime(f48_arg1, f48_arg2, 3018, 5, f48_local1[10], 1)
    f48_local1[11] = SetCoolTime(f48_arg1, f48_arg2, 3062, 2, f48_local1[11], 1)
    f48_local1[11] = SetCoolTime(f48_arg1, f48_arg2, 3066, 2, f48_local1[11], 1)
    f48_local1[12] = SetCoolTime(f48_arg1, f48_arg2, 3058, 2, f48_local1[12], 1)
    f48_local1[12] = SetCoolTime(f48_arg1, f48_arg2, 3060, 2, f48_local1[12], 1)
    f48_local1[12] = SetCoolTime(f48_arg1, f48_arg2, 3067, 2, f48_local1[12], 1)
    f48_local1[14] = SetCoolTime(f48_arg1, f48_arg2, 3033, 5, f48_local1[14], 1)
    f48_local1[16] = SetCoolTime(f48_arg1, f48_arg2, 3063, 2, f48_local1[16], 1)
    f48_local1[17] = SetCoolTime(f48_arg1, f48_arg2, 3068, 2, f48_local1[17], 1)
    f48_local1[18] = SetCoolTime(f48_arg1, f48_arg2, 3064, 2, f48_local1[18], 1)
    f48_local1[22] = SetCoolTime(f48_arg1, f48_arg2, 3028, 20, f48_local1[22], 1)
    f48_local1[41] = SetCoolTime(f48_arg1, f48_arg2, 3090, 4, f48_local1[41], 1)
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
    f48_local2[12] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki12)
    f48_local2[13] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki13)
    f48_local2[14] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki14)
    f48_local2[15] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki15)
    f48_local2[16] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki16)
    f48_local2[17] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki17)
    f48_local2[18] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki18)
    f48_local2[19] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki19)
    f48_local2[20] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki20)
    f48_local2[22] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki22)
    f48_local2[23] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Act23)
    f48_local2[24] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Act24)
    f48_local2[25] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Act25)
    f48_local2[26] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki26)
    f48_local2[40] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki40)
    f48_local2[41] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki41)
    f48_local2[42] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki42)
    f48_local2[43] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki43)
    f48_local2[44] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki44)
    f48_local2[45] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.Kengeki45)
    f48_local2[50] = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.NoAction)
    local f48_local13 = REGIST_FUNC(f48_arg1, f48_arg2, f48_arg0.ActAfter_AdjustSpace)
    return Common_Kengeki_Activate(f48_arg1, f48_arg2, f48_local1, f48_local2, f48_local13, f48_local3)
    
end

Goal.Kengeki01 = function (f49_arg0, f49_arg1, f49_arg2)
    f49_arg1:ClearSubGoal()
    f49_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3015, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f49_arg0:GetNumber(5) + 15, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki02 = function (f50_arg0, f50_arg1, f50_arg2)
    f50_arg1:ClearSubGoal()
    f50_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3058, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f50_arg0:GetNumber(5) + 3, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki03 = function (f51_arg0, f51_arg1, f51_arg2)
    f51_arg1:ClearSubGoal()
    f51_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3051, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f51_arg0:GetNumber(5) + 3, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki04 = function (f52_arg0, f52_arg1, f52_arg2)
    f52_arg1:ClearSubGoal()
    f52_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3055, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f52_arg0:GetNumber(5) + 3, AI_TIMING_SET__ACTIVATE)
    if f52_arg0:HasSpecialEffectId(TARGET_SELF, 5022) and (not (f52_arg0:IsInsideTargetRegion(TARGET_SELF, 1112250) or f52_arg0:IsInsideTargetRegion(TARGET_ENE_0, 1112250))) then
        f52_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3034, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f52_arg0:GetNumber(5) + 10, AI_TIMING_SET__ACTIVATE)
    end
    
end

Goal.Kengeki05 = function (f53_arg0, f53_arg1, f53_arg2)
    f53_arg1:ClearSubGoal()
    f53_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3056, TARGET_ENE_0, 9999, 0, 0)
    f53_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3067, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f53_arg0:GetNumber(5) + 3, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki06 = function (f54_arg0, f54_arg1, f54_arg2)
    f54_arg1:ClearSubGoal()
    f54_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3019, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f54_arg0:GetNumber(5) + 15, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki07 = function (f55_arg0, f55_arg1, f55_arg2)
    f55_arg1:ClearSubGoal()
    f55_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3066, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f55_arg0:GetNumber(5) + 3, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki08 = function (f56_arg0, f56_arg1, f56_arg2)
    f56_arg1:ClearSubGoal()
    f56_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3060, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f56_arg0:GetNumber(5) + 3, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki09 = function (f57_arg0, f57_arg1, f57_arg2)
    f57_arg1:ClearSubGoal()
    f57_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3008, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f57_arg0:GetNumber(5) + 15, AI_TIMING_SET__ACTIVATE)
    f57_arg0:SetNumber(1, 0)
    
end

Goal.Kengeki10 = function (f58_arg0, f58_arg1, f58_arg2)
    f58_arg1:ClearSubGoal()
    f58_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3031, TARGET_ENE_0, 9999, 0, 0)
    f58_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3018, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f58_arg0:GetNumber(5) + 3, AI_TIMING_SET__ACTIVATE)
    f58_arg0:SetNumber(1, 0)
    
end

Goal.Kengeki11 = function (f59_arg0, f59_arg1, f59_arg2)
    f59_arg1:ClearSubGoal()
    f59_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3062, TARGET_ENE_0, 9999, 0, 0)
    f59_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3008, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f59_arg0:GetNumber(5) + 3, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki12 = function (f60_arg0, f60_arg1, f60_arg2)
    f60_arg1:ClearSubGoal()
    f60_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3067, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f60_arg0:GetNumber(5) + 3, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki13 = function (f61_arg0, f61_arg1, f61_arg2)
    local f61_local0 = f61_arg0:GetDist(TARGET_ENE_0)
    f61_arg1:ClearSubGoal()
    if f61_local0 <= 2 - f61_arg0:GetMapHitRadius(TARGET_SELF) + 0.3 then
        f61_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 3, 3005, TARGET_ENE_0, 9999, 0, 0):TimingSetTimer(0, 2, AI_TIMING_SET__ACTIVATE)
    else
        f61_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 3, 5201, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0):TimingSetTimer(0, 2, AI_TIMING_SET__ACTIVATE)
    end
    f61_arg0:SetTimer(3, 3)
    
end

Goal.Kengeki14 = function (f62_arg0, f62_arg1, f62_arg2)
    f62_arg1:ClearSubGoal()
    f62_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3032, TARGET_ENE_0, 5 - f62_arg0:GetMapHitRadius(TARGET_SELF) + 1, 0):TimingSetNumber(5, f62_arg0:GetNumber(5) + 3, AI_TIMING_SET__ACTIVATE)
    f62_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3008, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.Kengeki15 = function (f63_arg0, f63_arg1, f63_arg2)
    local f63_local0 = f63_arg0:GetRandam_Int(1, 100)
    f63_arg1:ClearSubGoal()
    f63_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3032, TARGET_ENE_0, 4.5 - f63_arg0:GetMapHitRadius(TARGET_SELF), 0)
    
end

Goal.Kengeki16 = function (f64_arg0, f64_arg1, f64_arg2)
    f64_arg1:ClearSubGoal()
    f64_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3063, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f64_arg0:GetNumber(5) + 3, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki17 = function (f65_arg0, f65_arg1, f65_arg2)
    f65_arg1:ClearSubGoal()
    f65_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3068, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f65_arg0:GetNumber(5) + 3, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki18 = function (f66_arg0, f66_arg1, f66_arg2)
    f66_arg1:ClearSubGoal()
    f66_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3064, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f66_arg0:GetNumber(5) + 3, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki19 = function (f67_arg0, f67_arg1, f67_arg2)
    f67_arg1:ClearSubGoal()
    f67_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3069, TARGET_ENE_0, 9999, 0, 0):TimingSetNumber(5, f67_arg0:GetNumber(5) + 3, AI_TIMING_SET__ACTIVATE)
    
end

Goal.Kengeki20 = function (f68_arg0, f68_arg1, f68_arg2)
    f68_arg1:ClearSubGoal()
    f68_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 3, 5201, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0)
    f68_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3003, TARGET_ENE_0, 9999, TurnTime, FrontAngle, 0, 0)
    f68_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3033, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.Kengeki21 = function (f69_arg0, f69_arg1, f69_arg2)
    local f69_local0 = 3.5 - f69_arg0:GetMapHitRadius(TARGET_SELF)
    local f69_local1 = 3.5 - f69_arg0:GetMapHitRadius(TARGET_SELF)
    local f69_local2 = 3.5 - f69_arg0:GetMapHitRadius(TARGET_SELF)
    local f69_local3 = 100
    local f69_local4 = 0
    local f69_local5 = 3
    local f69_local6 = 3
    f69_arg1:ClearSubGoal()
    Approach_Act_Flex(f69_arg0, f69_arg1, f69_local0, f69_local1, f69_local2, f69_local3, f69_local4, f69_local5, f69_local6)
    f69_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3062, TARGET_ENE_0, 9999, 0, 0)
    f69_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3008, TARGET_ENE_0, 9999, 0, 0)
    
end

Goal.Kengeki22 = function (f70_arg0, f70_arg1, f70_arg2)
    f70_arg1:ClearSubGoal()
    f70_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3028, TARGET_ENE_0, 9999, 0, 0)
    f70_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3029, TARGET_ENE_0, 9999, 0, 0)
    f70_arg0:SetNumber(1, 0)
    
end

Goal.Kengeki26 = function (f71_arg0, f71_arg1, f71_arg2)
    f71_arg1:ClearSubGoal()
    f71_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3009, TARGET_ENE_0, 9999, 0, 0)
    f71_arg0:SetNumber(1, 0)
    
end

Goal.Kengeki40 = function (f72_arg0, f72_arg1, f72_arg2)
    f72_arg1:ClearSubGoal()
    f72_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, 3009, TARGET_ENE_0, 9999, 0, 0)
    f72_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3033, TARGET_ENE_0, 9999, 0, 0)
    f72_arg0:SetNumber(1, 0)
    
end

Goal.Kengeki41 = function (f73_arg0, f73_arg1, f73_arg2)
    local f73_local0 = f73_arg0:GetDist(TARGET_ENE_0)
    f73_arg1:ClearSubGoal()
    f73_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 3, 5201, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0):TimingSetTimer(0, 2, AI_TIMING_SET__ACTIVATE):TimingSetTimer(3, 10, AI_TIMING_SET__ACTIVATE)
    f73_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3090, TARGET_ENE_0, 9999, 0, 0):TimingSetTimer(7, 8, AI_TIMING_SET__ACTIVATE)
    f73_arg0:SetNumber(1, 0)
    
end

Goal.NoAction = function (f74_arg0, f74_arg1, f74_arg2)
    return -1
    
end

Goal.ActAfter_AdjustSpace = function (f75_arg0, f75_arg1, f75_arg2)
    
end

Goal.Update = function (f76_arg0, f76_arg1, f76_arg2)
    return Update_Default_NoSubGoal(f76_arg0, f76_arg1, f76_arg2)
    
end

Goal.Terminate = function (f77_arg0, f77_arg1, f77_arg2)
    
end


