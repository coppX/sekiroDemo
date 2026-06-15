function GetKengekiSpecialEffect(f1_arg0, f1_arg1, f1_arg2)
    if f1_arg2 == 200200 or f1_arg2 == 200201 or f1_arg2 == 200205 or f1_arg2 == 200206 or f1_arg2 == 200210 or f1_arg2 == 200211 or f1_arg2 == 200215 or f1_arg2 == 200216 or f1_arg2 == 200225 or f1_arg2 == 200226 or f1_arg2 == 200227 or f1_arg2 == 200228 or f1_arg2 == 200229 then
        return true
    end
    return false
    
end

function ReturnKengekiSpecialEffect(f2_arg0)
    if f2_arg0:HasSpecialEffectId(TARGET_SELF, 200200) then
        return 200200
    elseif f2_arg0:HasSpecialEffectId(TARGET_SELF, 200201) then
        return 200201
    elseif f2_arg0:HasSpecialEffectId(TARGET_SELF, 200205) then
        return 200205
    elseif f2_arg0:HasSpecialEffectId(TARGET_SELF, 200206) then
        return 200206
    elseif f2_arg0:HasSpecialEffectId(TARGET_SELF, 200210) then
        return 200210
    elseif f2_arg0:HasSpecialEffectId(TARGET_SELF, 200211) then
        return 200211
    elseif f2_arg0:HasSpecialEffectId(TARGET_SELF, 200215) then
        return 200215
    elseif f2_arg0:HasSpecialEffectId(TARGET_SELF, 200216) then
        return 200216
    elseif f2_arg0:HasSpecialEffectId(TARGET_SELF, 200225) then
        return 200225
    elseif f2_arg0:HasSpecialEffectId(TARGET_SELF, 200226) then
        return 200226
    elseif f2_arg0:HasSpecialEffectId(TARGET_SELF, 200227) then
        return 200227
    elseif f2_arg0:HasSpecialEffectId(TARGET_SELF, 200228) then
        return 200228
    elseif f2_arg0:HasSpecialEffectId(TARGET_SELF, 200229) then
        return 200229
    elseif f2_arg0:HasSpecialEffectId(TARGET_SELF, 200300) then
        return 200300
    elseif f2_arg0:HasSpecialEffectId(TARGET_SELF, 200301) then
        return 200301
    elseif f2_arg0:HasSpecialEffectId(TARGET_SELF, 200305) then
        return 200305
    elseif f2_arg0:HasSpecialEffectId(TARGET_SELF, 200306) then
        return 200306
    elseif f2_arg0:HasSpecialEffectId(TARGET_SELF, 200400) then
        return 200400
    elseif f2_arg0:HasSpecialEffectId(TARGET_SELF, 200401) then
        return 200401
    elseif f2_arg0:HasSpecialEffectId(TARGET_SELF, 200405) then
        return 200405
    elseif f2_arg0:HasSpecialEffectId(TARGET_SELF, 200406) then
        return 200406
    end
    return 0
    
end

function Check_KugutsuActState(f3_arg0)
    local f3_local0 = false
    if f3_arg0:HasSpecialEffectId(TARGET_SELF, 220020) and f3_arg0:IsFindState() == false and f3_arg0:IsBattleState() == false then
        f3_local0 = true
    end
    return f3_local0
    
end

function YousumiAct_TopGoal(f4_arg0, f4_arg1, f4_arg2, f4_arg3, f4_arg4)
    local f4_local0 = f4_arg0:GetDist(TARGET_ENE_0)
    local f4_local1 = f4_arg0:GetDistYSigned(TARGET_ENE_0)
    local f4_local2 = 1
    local f4_local3 = 30
    local f4_local4 = f4_local1 / math.sin(math.rad(f4_arg3))
    local f4_local5 = f4_local1 / math.sin(math.rad(f4_arg4))
    local f4_local6 = f4_arg0:GetRandam_Int(0, 1)
    local f4_local7 = true
    f4_arg0:SetNumber(10, f4_local6)
    local f4_local8 = TARGET_ENE_0
    if f4_arg0:GetCurrTargetType() == AI_TARGET_TYPE__MEMORY_ENEMY then
        f4_local8 = TARGET_SELF
    end
    if f4_arg0:GetStringIndexedNumber("Reach_EndOnFailedPath") == 1 then
        f4_arg0:SetStringIndexedNumber("Reach_EndOnFailedPath", 0)
        return true
    elseif f4_local0 <= f4_local2 then
        if SpaceCheck(f4_arg0, f4_arg1, 180, 1) == true then
            f4_arg0:AddTopGoal(GOAL_COMMON_LeaveTarget, 10, TARGET_ENE_0, f4_local2, f4_local8, true, -1)
            f4_local7 = false
        end
    elseif f4_local3 <= f4_local0 then
        f4_arg0:AddTopGoal(GOAL_COMMON_ApproachTarget, 1.5, TARGET_ENE_0, f4_local3 - 0.5, TARGET_SELF, false, -1)
        f4_local7 = false
    elseif f4_local1 > 0 then
        if f4_local4 <= f4_local2 then
            f4_local4 = f4_local2
        end
        if f4_local3 <= f4_local5 then
            f4_local5 = f4_local3
        end
        if f4_local5 <= f4_local0 then
            if f4_local0 - f4_local5 >= 5 and f4_arg2 == false then
                f4_arg0:AddTopGoal(GOAL_COMMON_ApproachTarget, 1.5, TARGET_ENE_0, f4_local5, TARGET_SELF, false, -1)
                f4_local7 = false
            else
                f4_arg0:AddTopGoal(GOAL_COMMON_ApproachTarget, 3, TARGET_ENE_0, f4_local5, TARGET_SELF, true, -1)
                f4_local7 = false
            end
        elseif f4_local0 <= f4_local4 then
            if f4_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 180) then
                if SpaceCheck(f4_arg0, f4_arg1, 180, 0.5) == true then
                    f4_arg0:AddTopGoal(GOAL_COMMON_LeaveTarget, 10, TARGET_ENE_0, f4_local4, f4_local8, true, -1)
                    f4_local7 = false
                end
            elseif SpaceCheck(f4_arg0, f4_arg1, 0, 0.5) == true then
                f4_arg0:AddTopGoal(GOAL_COMMON_LeaveTarget, 10, TARGET_ENE_0, f4_local4, f4_local8, true, -1)
                f4_local7 = false
            else
                f4_arg0:AddTopGoal(GOAL_COMMON_Turn, 3, TARGET_ENE_0, 0, 0, 0, 0)
            end
        elseif f4_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_B, 180) then
            f4_arg0:AddTopGoal(GOAL_COMMON_Turn, 3, TARGET_ENE_0, 0, 0, 0, 0)
        end
    else
        local f4_local9 = TARGET_ENE_0
        if f4_arg0:CheckDoesExistPathWithSetPoint(TARGET_ENE_0, AI_DIR_TYPE_F, 0, 0) == false then
            f4_local9 = POINT_UnreachTerminate
        end
        if SpaceCheck(f4_arg0, f4_arg1, 0, 4) == true and f4_arg2 == false then
            f4_arg0:AddTopGoal(GOAL_COMMON_ApproachTarget, 1.5, f4_local9, 0.5, TARGET_SELF, false, -1)
            f4_local7 = false
        elseif SpaceCheck(f4_arg0, f4_arg1, 0, 3) == true then
            f4_arg0:AddTopGoal(GOAL_COMMON_ApproachTarget, 3, f4_local9, 0.5, TARGET_SELF, true, -1)
            f4_local7 = false
        elseif SpaceCheck(f4_arg0, f4_arg1, 0, 0.5) == false then
            f4_arg0:AddTopGoal(GOAL_COMMON_LeaveTarget, 2, f4_local9, 50, f4_local8, true, -1)
            f4_arg0:AddTopGoal(GOAL_COMMON_Turn, 3, TARGET_ENE_0, 0, 0, 0, 0)
            f4_local7 = false
        end
    end
    return f4_local7
    
end

function YousumiAct_SubGoal(f5_arg0, f5_arg1, f5_arg2, f5_arg3, f5_arg4, f5_arg5)
    f5_arg1:AddSubGoal(GOAL_COMMON_YousumiAct, 10, f5_arg2, f5_arg3, f5_arg4, f5_arg5)
    return true
    
end

function TorimakiAct(f6_arg0, f6_arg1, f6_arg2, f6_arg3, f6_arg4)
    local f6_local0 = f6_arg0:GetDist(TARGET_ENE_0)
    local f6_local1 = f6_arg0:GetRandam_Float(1, 2)
    local f6_local2 = 1.5
    local f6_local3 = f6_arg0:GetRandam_Int(30, 45)
    local f6_local4 = -1
    local f6_local5 = 0
    local f6_local6 = f6_arg0:GetRandam_Int(1, 100)
    local f6_local7 = true
    local f6_local8 = f6_arg0:GetRandam_Float(-1, 1)
    if f6_arg2 == nil or f6_arg2 == -1 then
        f6_arg2 = 6
    end
    if f6_arg3 == nil or f6_arg3 == -1 then
        f6_arg3 = 10
    end
    if f6_arg4 == nil then
        f6_arg4 = false
    end
    if f6_arg2 ~= 0 and f6_local0 <= f6_arg2 - 2 then
        f6_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, f6_local2, TARGET_ENE_0, f6_arg2, TARGET_ENE_0, true, f6_local4)
    elseif f6_arg2 ~= 0 and f6_arg2 + 2 <= f6_local0 then
        if not f6_arg4 and f6_arg2 + 3 <= f6_local0 then
            f6_local7 = false
        end
        f6_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, f6_local2, TARGET_ENE_0, f6_arg2 + f6_local8, TARGET_SELF, f6_local7, -1)
    elseif f6_arg3 ~= nil and f6_local6 <= f6_arg3 then
        return true
    elseif SpaceCheck(f6_arg0, f6_arg1, 90, 1) == true or SpaceCheck(f6_arg0, f6_arg1, -90, 1) == true then
        f6_local5 = GetDirection_Sideway(f6_arg0)
        f6_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f6_local1, TARGET_ENE_0, f6_local5, f6_local3, true, true, f6_local4)
    elseif SpaceCheck(f6_arg0, f6_arg1, 180, 1) == true then
        f6_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, f6_local2, TARGET_ENE_0, 999, TARGET_ENE_0, true, f6_local4)
    else
        f6_arg1:AddSubGoal(GOAL_COMMON_Wait, 0.5, TARGET_SELF, 0, 0, 0)
    end
    return false
    
end

function KankyakuAct(f7_arg0, f7_arg1, f7_arg2, f7_arg3, f7_arg4)
    if f7_arg2 == nil or f7_arg2 == -1 then
        f7_arg2 = 10
    end
    if f7_arg3 == nil or f7_arg3 == -1 then
        f7_arg3 = 0
    end
    return TorimakiAct(f7_arg0, f7_arg1, f7_arg2, f7_arg3, f7_arg4)
    
end

function Common_ActivateAct(f8_arg0, f8_arg1, f8_arg2, f8_arg3)
    local f8_local0 = f8_arg0:GetDist(TARGET_ENE_0)
    local f8_local1 = f8_arg0:GetRandam_Float(1, 2)
    local f8_local2 = f8_arg0:GetRandam_Int(30, 45)
    local f8_local3 = -1
    local f8_local4 = 0
    if f8_arg2 == nil then
        f8_arg2 = 0
    end
    if f8_arg3 == nil then
        f8_arg3 = 0
    end
    if f8_arg0:HasSpecialEffectId(TARGET_ENE_0, 110060) then
        if f8_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) then
            f8_arg1:AddSubGoal(GOAL_COMMON_Wait, 0.5, TARGET_SELF, 0, 0, 0)
        else
            f8_arg1:AddSubGoal(GOAL_COMMON_Turn, 3, TARGET_ENE_0, 45, -1, GOAL_RESULT_Success, true)
        end
    elseif f8_arg0:HasSpecialEffectId(TARGET_ENE_0, 110015) and f8_arg0:GetStringIndexedNumber("Steped") ~= 1 then
        if f8_arg2 == 0 and SpaceCheck(f8_arg0, f8_arg1, 180, f8_arg0:GetStringIndexedNumber("Dist_Step_Small")) == true then
            if (f8_arg3 == 0 or f8_arg3 == 2) and SpaceCheck(f8_arg0, f8_arg1, 180, f8_arg0:GetStringIndexedNumber("Dist_Step_Large")) == true then
                if f8_arg3 == 0 and f8_local0 > 4 or f8_arg3 == 1 then
                    f8_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 3, 5201, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0)
                else
                    f8_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 3, 5211, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0)
                end
            else
                f8_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 3, 5201, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0)
            end
            f8_arg0:SetStringIndexedNumber("Steped", 1)
        elseif f8_arg2 <= 1 and (SpaceCheck(f8_arg0, f8_arg1, 90, 1) == true or SpaceCheck(f8_arg0, f8_arg1, -90, 1) == true) then
            f8_local4 = GetDirection_Sideway(f8_arg0)
            f8_arg1:AddSubGoal(GOAL_COMMON_SidewayMove, f8_local1, TARGET_ENE_0, f8_local4, f8_local2, true, true, f8_local3)
        else
            f8_arg1:AddSubGoal(GOAL_COMMON_Wait, 0.5, TARGET_SELF, 0, 0, 0)
        end
    elseif f8_arg2 <= 1 and (f8_arg0:HasSpecialEffectId(TARGET_ENE_0, COMMON_SP_EFFECT_PC_REVIVAL_AFTER_1) or f8_arg0:HasSpecialEffectId(TARGET_ENE_0, COMMON_SP_EFFECT_PC_REVIVAL_AFTER_2)) then
        KankyakuAct(f8_arg0, f8_arg1, 0)
    elseif f8_arg2 <= 1 and f8_arg0:HasSpecialEffectId(TARGET_ENE_0, 110030) then
        KankyakuAct(f8_arg0, f8_arg1, 0)
    else
        f8_arg0:SetStringIndexedNumber("Steped", 0)
        return false
    end
    return true
    
end

function GetDirection_Sideway(f9_arg0)
    if SpaceCheck(f9_arg0, goal, -90, 1) == true then
        if SpaceCheck(f9_arg0, goal, 90, 1) == true then
            if f9_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_R, 180) then
                return 1
            else
                return 0
            end
        else
            return 0
        end
    elseif SpaceCheck(f9_arg0, goal, 90, 1) == true then
        return 1
    else
        return 0
    end
    
end

function Get_ConsecutiveGuardCount(f10_arg0)
    local f10_local0 = 0
    if f10_arg0:IsFinishTimer(13) then
        f10_local0 = 0
    else
        f10_local0 = f10_arg0:GetStringIndexedNumber("ConsecutiveGuardCount")
    end
    return f10_local0
    
end

function Set_ConsecutiveGuardCount(f11_arg0, f11_arg1)
    if f11_arg1 == 200215 or f11_arg1 == 200216 then
        if f11_arg0:IsFinishTimer(13) then
            f11_arg0:SetStringIndexedNumber("ConsecutiveGuardCount", 1)
        else
            f11_arg0:SetStringIndexedNumber("ConsecutiveGuardCount", f11_arg0:GetStringIndexedNumber("ConsecutiveGuardCount") + 1)
        end
        f11_arg0:SetTimer(13, 1)
    elseif f11_arg1 == 200210 or f11_arg1 == 200211 then
        f11_arg0:SetStringIndexedNumber("ConsecutiveGuardCount", 0)
        f11_arg0:SetTimer(13, 0)
    end
    
end

function Set_ConsecutiveGuardCount_Interrupt(f12_arg0)
    f12_arg0:AddObserveSpecialEffectAttribute(TARGET_SELF, 200250)
    f12_arg0:AddObserveSpecialEffectAttribute(TARGET_SELF, 200210)
    f12_arg0:AddObserveSpecialEffectAttribute(TARGET_SELF, 200211)
    
end

function JuzuReaction(f13_arg0, f13_arg1, f13_arg2, f13_arg3, f13_arg4)
    local f13_local0 = f13_arg3
    local f13_local1 = 400600
    local f13_local2 = f13_arg0:GetRandam_Int(1, 100)
    local f13_local3 = f13_arg0:GetRandam_Int(1, 100)
    if f13_arg4 ~= nil and f13_local2 <= 50 then
        f13_local0 = f13_arg4
    end
    if f13_arg2 == 0 then
        f13_arg0:AddTopGoal(GOAL_COMMON_AttackTunableSpin, 10, f13_local0, TARGET_NONE, 9999, 0, 0, 0, 0):TimingSetTimer(AI_TIMER_TEKIMAWASHI_REACTION, 0, AI_TIMING_SET__ACTIVATE)
    else
        f13_arg0:AddTopGoal(GOAL_COMMON_AttackTunableSpin, 10, f13_local0, TARGET_NONE, 9999, 0, 0, 0, 0):TimingSetTimer(AI_TIMER_TEKIMAWASHI_REACTION, 0, AI_TIMING_SET__ACTIVATE)
    end
    return true
    
end

function SpaceCheck_SidewayMove(f14_arg0, f14_arg1, f14_arg2)
    local f14_local0 = nil
    if SpaceCheck(f14_arg0, f14_arg1, -90, f14_arg2) == true then
        if SpaceCheck(f14_arg0, f14_arg1, 90, f14_arg2) == true then
            f14_local0 = 2
        else
            f14_local0 = 0
        end
    elseif SpaceCheck(f14_arg0, f14_arg1, 90, f14_arg2) == true then
        f14_local0 = 1
    else
        f14_local0 = 3
    end
    return f14_local0
    
end

function Common_Parry(f15_arg0, f15_arg1, f15_arg2, f15_arg3, f15_arg4, f15_arg5)
    local f15_local0 = f15_arg0:GetDist(TARGET_ENE_0)
    local f15_local1 = GetDist_Parry(f15_arg0)
    local f15_local2 = f15_arg0:GetRandam_Int(1, 100)
    local f15_local3 = f15_arg0:GetRandam_Int(1, 100)
    local f15_local4 = f15_arg0:GetRandam_Int(1, 100)
    local f15_local5 = f15_arg0:HasSpecialEffectId(TARGET_ENE_0, 109970)
    local f15_local6 = f15_arg0:HasSpecialEffectId(TARGET_ENE_0, COMMON_SP_EFFECT_PC_ATTACK_RUSH)
    local f15_local7 = -1
    if f15_arg0:HasSpecialEffectId(TARGET_SELF, 221000) then
        f15_local7 = 0
    elseif f15_arg0:HasSpecialEffectId(TARGET_SELF, 221001) then
        f15_local7 = 1
    elseif f15_arg0:HasSpecialEffectId(TARGET_SELF, 221002) then
        f15_local7 = 2
    end
    if f15_arg0:IsFinishTimer(AI_TIMER_PARRY_INTERVAL) == false then
        return false
    end
    if f15_local7 == -1 then
        return false
    end
    if f15_arg0:HasSpecialEffectId(TARGET_SELF, 220062) then
        return false
    end
    if f15_arg0:HasSpecialEffectId(TARGET_ENE_0, 110450) or f15_arg0:HasSpecialEffectId(TARGET_ENE_0, 110501) or f15_arg0:HasSpecialEffectId(TARGET_ENE_0, 110500) then
        return false
    end
    f15_arg0:SetTimer(AI_TIMER_PARRY_INTERVAL, 0.1)
    if f15_arg2 == nil then
        f15_arg2 = 50
    end
    if f15_arg3 == nil then
        f15_arg3 = 0
    end
    if f15_arg4 == nil then
        f15_arg4 = 0
    end
    if f15_arg5 == nil then
        f15_arg5 = 3100
    end
    if f15_arg0:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90) and f15_arg0:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_F, 90, f15_local1) then
        if f15_local6 then
            f15_arg1:ClearSubGoal()
            f15_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.3, f15_arg5, TARGET_ENE_0, 9999, 0)
            return true
        elseif f15_local5 then
            if f15_arg0:IsTargetGuard(TARGET_SELF) and ReturnKengekiSpecialEffect(f15_arg0) == false then
                return false
            else
                if f15_local7 == 2 then
                    return false
                elseif f15_local7 == 1 then
                    if f15_local2 <= 50 then
                        f15_arg1:ClearSubGoal()
                        f15_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.3, 3101, TARGET_ENE_0, 9999, 0)
                        return true
                    end
                elseif f15_local7 == 0 and f15_local2 <= 100 then
                    f15_arg1:ClearSubGoal()
                    f15_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.3, 3101, TARGET_ENE_0, 9999, 0)
                    return true
                end
                return false
            end
        elseif f15_arg0:HasSpecialEffectId(TARGET_ENE_0, 109980) and f15_arg4 ~= -1 and f15_local7 == 0 then
            if f15_arg4 == 1 then
                f15_arg1:ClearSubGoal()
                f15_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 1, 5201, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0)
                return true
            else
                f15_arg1:ClearSubGoal()
                f15_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 1, 5211, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0)
                return true
            end
        elseif f15_local3 <= Get_ConsecutiveGuardCount(f15_arg0) * f15_arg2 then
            f15_arg1:ClearSubGoal()
            f15_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.3, 3101, TARGET_ENE_0, 9999, 0)
            return true
        else
            f15_arg1:ClearSubGoal()
            f15_arg1:AddSubGoal(GOAL_COMMON_EndureAttack, 0.3, 3100, TARGET_ENE_0, 9999, 0)
            return true
        end
    elseif f15_arg0:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_F, 90, f15_local1 + 1) then
        if f15_arg4 ~= -1 and f15_local4 <= f15_arg3 then
            if f15_arg4 == 1 then
                f15_arg1:ClearSubGoal()
                f15_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 1, 5201, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0)
                return true
            else
                f15_arg1:ClearSubGoal()
                f15_arg1:AddSubGoal(GOAL_COMMON_SpinStep, 1, 5211, TARGET_ENE_0, 0, AI_DIR_TYPE_B, 0)
                return true
            end
        else
            return false
        end
    else
        return false
    end
    
end

function GetDist_Parry(f16_arg0)
    local f16_local0 = PC_ATTACK_DIST_STAND
    if f16_arg0:HasSpecialEffectId(TARGET_ENE_0, 110271) then
        f16_local0 = PC_ATTACK_DIST_TESSEN
    elseif f16_arg0:HasSpecialEffectId(TARGET_ENE_0, 110231) then
        f16_local0 = PC_ATTACK_DIST_AXE
    elseif f16_arg0:HasSpecialEffectId(TARGET_ENE_0, 110250) then
        f16_local0 = PC_ATTACK_DIST_KODACHI
    elseif f16_arg0:HasSpecialEffectId(TARGET_ENE_0, 110291) then
        f16_local0 = PC_ATTACK_DIST_LANCE_1
    elseif f16_arg0:HasSpecialEffectId(TARGET_ENE_0, 110292) then
        f16_local0 = PC_ATTACK_DIST_LANCE_2
    elseif f16_arg0:HasSpecialEffectId(TARGET_ENE_0, 110290) then
        f16_local0 = PC_ATTACK_DIST_LANCE_TYPE1_CHARGE
    elseif f16_arg0:HasSpecialEffectId(TARGET_ENE_0, 110293) then
        f16_local0 = PC_ATTACK_DIST_LANCE_TYPE2_CHARGE
    elseif f16_arg0:HasSpecialEffectId(TARGET_ENE_0, 110400) then
        f16_local0 = PC_ATTACK_DIST_SPIN
    elseif f16_arg0:HasSpecialEffectId(TARGET_ENE_0, 110410) then
        f16_local0 = PC_ATTACK_DIST_JUMP_FRONT
    elseif f16_arg0:HasSpecialEffectId(TARGET_ENE_0, 110411) then
        f16_local0 = PC_ATTACK_DIST_JUMP_BACK
    elseif f16_arg0:HasSpecialEffectId(TARGET_ENE_0, 110420) then
        f16_local0 = PC_ATTACK_DIST_MEN_1
    elseif f16_arg0:HasSpecialEffectId(TARGET_ENE_0, 110421) then
        f16_local0 = PC_ATTACK_DIST_MEN_2
    elseif f16_arg0:HasSpecialEffectId(TARGET_ENE_0, 110430) then
        f16_local0 = PC_ATTACK_DIST_KENSEI_IAI
    elseif f16_arg0:HasSpecialEffectId(TARGET_ENE_0, 110440) then
        f16_local0 = PC_ATTACK_DIST_IAI
    elseif f16_arg0:HasSpecialEffectId(TARGET_ENE_0, 110450) then
        f16_local0 = PC_ATTACK_DIST_INVISIBLE_IAI_1
    elseif f16_arg0:HasSpecialEffectId(TARGET_ENE_0, 110451) then
        f16_local0 = PC_ATTACK_DIST_INVISIBLE_IAI_2
    elseif f16_arg0:HasSpecialEffectId(TARGET_ENE_0, 110460) then
        f16_local0 = PC_ATTACK_DIST_HASSOU
    elseif f16_arg0:HasSpecialEffectId(TARGET_ENE_0, 110470) then
        f16_local0 = PC_ATTACK_DIST_HUSHIGIRI_LV1
    elseif f16_arg0:HasSpecialEffectId(TARGET_ENE_0, 110480) then
        f16_local0 = PC_ATTACK_DIST_KICK_RUSH
    elseif f16_arg0:HasSpecialEffectId(TARGET_ENE_0, 110490) then
        f16_local0 = PC_ATTACK_DIST_PUNCHI
    elseif f16_arg0:HasSpecialEffectId(TARGET_ENE_0, 110501) then
        f16_local0 = PC_ATTACK_DIST_GATOTSU
    elseif f16_arg0:HasSpecialEffectId(TARGET_ENE_0, 109970) then
        f16_local0 = PC_ATTACK_DIST_THRUST
    end
    return f16_local0
    
end

function RankCheck_Parry(f17_arg0, f17_arg1, f17_arg2)
    local f17_local0 = f17_arg0:GetDist(TARGET_ENE_0)
    local f17_local1 = PC_ATTACK_DIST_STAND
    if f17_arg2 == 0 and f17_arg0:HasSpecialEffectId(TARGET_ENE_0, 109970) then
        return false
    else
        return true
    end
    
end

function Interupt_Use_Item(f18_arg0, f18_arg1, f18_arg2)
    local f18_local0 = false
    if f18_arg0:IsInterupt(INTERUPT_UseItem) and f18_arg0:IsStartAttack() == false then
        if f18_arg1 ~= nil then
            if f18_arg0:IsFinishTimer(f18_arg1) then
                f18_local0 = true
                f18_arg0:SetTimer(f18_arg1, f18_arg2)
            end
        else
            f18_local0 = true
        end
    end
    return f18_local0
    
end

function Interupt_PC_Break(f19_arg0, f19_arg1, f19_arg2)
    local f19_local0 = false
    if f19_arg0:IsInterupt(INTERUPT_ActivateSpecialEffect) and f19_arg0:GetSpecialEffectActivateInterruptType(0) == COMMON_SP_EFFECT_PC_BREAK and f19_arg0:IsStartAttack() == false then
        if f19_arg1 ~= nil then
            if f19_arg0:IsFinishTimer(f19_arg1) then
                f19_local0 = true
                f19_arg0:SetTimer(f19_arg1, f19_arg2)
            end
        else
            f19_local0 = true
        end
    end
    return f19_local0
    
end

function Check_ReachAttack(f20_arg0, f20_arg1)
    local f20_local0 = POSSIBLE_ATTACK
    local f20_local1 = f20_arg0:GetDist(TARGET_ENE_0)
    local f20_local2 = f20_arg0:GetDistYSigned(TARGET_ENE_0)
    if f20_arg0:CheckDoesExistPathWithSetPoint(TARGET_ENE_0, AI_DIR_TYPE_F, 0, 0) == false then
        if f20_arg1 < f20_local1 then
            f20_local0 = UNREACH_ATTACK
        elseif f20_local2 >= 0 then
            f20_local0 = REACH_ATTACK_TARGET_HIGH_POSITION
        else
            f20_local0 = REACH_ATTACK_TARGET_LOW_POSITION
        end
    elseif f20_arg0:HasSpecialEffectId(TARGET_ENE_0, 109220) or f20_arg0:HasSpecialEffectId(TARGET_ENE_0, 109221) then
        if f20_arg1 < f20_local1 then
            f20_local0 = UNREACH_ATTACK
        elseif f20_local2 >= 0 then
            f20_local0 = REACH_ATTACK_TARGET_HIGH_POSITION
        else
            f20_local0 = REACH_ATTACK_TARGET_LOW_POSITION
        end
    end
    return f20_local0
    
end


