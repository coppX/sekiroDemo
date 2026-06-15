RegisterTableGoal(GOAL_EnemyBeforeAttack, "GOAL_EnemyBeforeAttack")
REGISTER_GOAL_NO_SUB_GOAL(GOAL_EnemyBeforeAttack, true)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyBeforeAttack, 0, "???", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyBeforeAttack, 1, "??????", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyBeforeAttack, 2, "?õT?A?N?V???????", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyBeforeAttack, 3, "???????s????", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyBeforeAttack, 4, "???????s????", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyBeforeAttack, 5, "???s?m??", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyBeforeAttack, 6, "?h??m??", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyBeforeAttack, 7, "??X?e?b?v?m??", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyBeforeAttack, 8, "?O?X?e?b?v?m??", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyBeforeAttack, 9, "?X?e?b?v??u", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyBeforeAttack, 10, "??????", 0)

Goal.Activate = function (f1_arg0, f1_arg1, f1_arg2)
    local f1_local0 = f1_arg2:GetParam(0)
    local f1_local1 = f1_arg2:GetParam(1)
    local f1_local2 = f1_arg2:GetParam(2)
    local f1_local3 = f1_arg2:GetParam(3)
    local f1_local4 = f1_arg2:GetParam(4)
    local f1_local5 = f1_arg2:GetParam(5)
    local f1_local6 = f1_arg2:GetParam(6)
    local f1_local7 = f1_arg2:GetParam(7)
    local f1_local8 = f1_arg2:GetParam(8)
    local f1_local9 = f1_arg2:GetParam(9)
    local f1_local10
    if f1_arg2:GetParam(10) == true then
        f1_local10 = 1
    else
        f1_local10 = 0
    end
    f1_arg1:TurnTo(TARGET_SELF)
    local f1_local11 = f1_arg1:GetAIAttackParam(f1_local2, AI_ATTACK_PARAM_TYPE__MIN_ARRIVE_DISTANCE)
    local f1_local12 = f1_arg1:GetAIAttackParam(f1_local2, AI_ATTACK_PARAM_TYPE__MAX_ARRIVE_DISTANCE)
    f1_arg2:AddSubGoal(GOAL_EnemyFlexibleApproach, f1_arg2:GetLife(), f1_local0, f1_local1, f1_local11, f1_local12, f1_local3, f1_local4, f1_local5, f1_local6, f1_local7, f1_local8, f1_local9, f1_local10)
    
end

Goal.Update = function (f2_arg0, f2_arg1, f2_arg2)
    if f2_arg2:GetSubGoalNum() <= 0 then
        return GOAL_RESULT_Success
    end
    return GOAL_RESULT_Continue
    
end

RegisterTableGoal(GOAL_EnemyAfterAttack, "GOAL_EnemyAfterAttack")
REGISTER_GOAL_NO_SUB_GOAL(GOAL_EnemyAfterAttack, true)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyAfterAttack, 0, "???", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyAfterAttack, 1, "??????", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyAfterAttack, 2, "???s?m??", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyAfterAttack, 3, "?h??m??", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyAfterAttack, 4, "???S????", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyAfterAttack, 5, "???????", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyAfterAttack, 6, "????m??", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyAfterAttack, 7, "?????u", 0)

Goal.Activate = function (f3_arg0, f3_arg1, f3_arg2)
    local f3_local0 = f3_arg2:GetParam(0)
    local f3_local1 = f3_arg2:GetParam(1)
    local f3_local2 = f3_arg1:GetDist(f3_local0)
    local f3_local3 = f3_arg2:GetParam(2)
    local f3_local4 = f3_arg2:GetParam(3)
    local f3_local5 = 1
    local f3_local6 = -1
    local f3_local7 = f3_arg2:GetParam(4)
    local f3_local8 = f3_arg2:GetParam(5)
    local f3_local9 = f3_arg2:GetParam(6)
    local f3_local10 = f3_arg2:GetParam(7)
    local f3_local11 = 0
    local f3_local12 = {}
    if f3_arg1:GetRandam_Float(0, 100) < f3_local3 then
        f3_local5 = 0
    end
    if f3_arg1:GetRandam_Float(0, 100) < f3_local4 then
        f3_local6 = 9910
    end
    for f3_local13 = 7000, 7008, 1 do
        f3_local12[f3_local13] = 0
        if f3_arg1:IsAIAttackParam(f3_local13) then
            if f3_arg1:GetAIAttackParam(f3_local13, AI_ATTACK_PARAM_TYPE__INTERVAL_EXEC) <= f3_arg1:GetIdTimer(f3_local13 + 7100000) or f3_arg1:GetNumber(60) == 1 then
                if f3_arg1:GetAIAttackParam(f3_local13, AI_ATTACK_PARAM_TYPE__DOES_SELECT_ON_OUT_RANGE) == 1 and f3_arg1:GetAIAttackParam(f3_local13, AI_ATTACK_PARAM_TYPE__DOES_SELECT_ON_INNER_RANGE) == 1 or f3_arg1:GetAIAttackParam(f3_local13, AI_ATTACK_PARAM_TYPE__MIN_OPTIMAL_DISTANCE) <= f3_local2 and f3_local2 <= f3_arg1:GetAIAttackParam(f3_local13, AI_ATTACK_PARAM_TYPE__MAX_OPTIMAL_DISTANCE) then
                    if f3_arg1:IsOptimalAttackRangeH(f3_local0, f3_local13) then
                        local f3_local16 = f3_arg1:GetIdTimer(f3_local13 + 7100000) - f3_arg1:GetAIAttackParam(f3_local13, AI_ATTACK_PARAM_TYPE__INTERVAL_EXEC)
                        if f3_local16 < 0 then
                            f3_local16 = 1
                        end
                        print("?yAfter Action?z" .. "?I???m??[" .. f3_local13 .. "]?@" .. f3_arg1:GetAIAttackParam(f3_local13, AI_ATTACK_PARAM_TYPE__SELECTION_TENDENCY) .. "?@?@" .. f3_arg1:GetAIAttackParam(f3_local13, AI_ATTACK_PARAM_TYPE__MAX_OPTIMAL_DISTANCE))
                        f3_local12[f3_local13] = f3_local16 * f3_arg1:GetAIAttackParam(f3_local13, AI_ATTACK_PARAM_TYPE__SELECTION_TENDENCY) * GetAttackRateByDist(f3_arg0, f3_arg1, f3_arg2, f3_local13, GetDistPos(f3_arg0, f3_arg1, f3_arg2, f3_local2))
                    else
                        print("?yAfter Action?z" .. "?p?x?O[" .. f3_local13 .. "]")
                    end
                else
                    print("?yAfter Action?z" .. "???O[" .. f3_local13 .. "]")
                end
            else
                print("?yAfter Action?z" .. "????O[" .. f3_local13 .. "]")
            end
        end
        f3_local11 = f3_local11 + f3_local12[f3_local13]
    end
    if f3_local11 <= 0 then
        print("?yAfter Action?z" .. "????ç·????")
        return
    end
    local f3_local13 = f3_arg1:GetRandam_Float(0.001, f3_local11)
    local f3_local14 = 9999999
    local f3_local15 = 0
    for f3_local16 = 7000, 7008, 1 do
        f3_local15 = f3_local15 + f3_local12[f3_local16]
        if f3_local13 <= f3_local15 then
            f3_local14 = f3_local16
            f3_arg2:SetNumber(0, f3_local16)
            f3_arg1:StartIdTimer(f3_local16 + 7100000)
            break
        end
    end
    if f3_local14 == 7000 then
        print("?yAfter Action?z" .. "?K?[?h??@")
        f3_arg2:AddSubGoal(GOAL_COMMON_Guard, f3_arg2:GetLife(), 9910, f3_local0, true, 0)
    elseif f3_local14 == 7001 then
        print("?yAfter Action?z" .. "???E???")
        f3_arg2:AddSubGoal(GOAL_COMMON_FlexibleSideWayMove, f3_arg2:GetLife(), f3_arg1:GetRandam_Float(1, 100), f3_arg1:GetRandam_Float(1, 100), f3_local0, f3_local7, f3_arg1:GetRandam_Float(45, 240), f3_local4, f3_arg1:GetAIAttackParam(7001, AI_ATTACK_PARAM_TYPE__MIN_OPTIMAL_DISTANCE), f3_arg1:GetAIAttackParam(7001, AI_ATTACK_PARAM_TYPE__MAX_OPTIMAL_DISTANCE))
    elseif f3_local14 == 7002 then
        print("?yAfter Action?z" .. "???")
        f3_arg2:AddSubGoal(GOAL_COMMON_LeaveTarget, f3_arg2:GetLife(), f3_local0, f3_arg1:GetAIAttackParam(7002, AI_ATTACK_PARAM_TYPE__MAX_OPTIMAL_DISTANCE), f3_local0, f3_local5, GuardID, 1, true):SetFailedEndOption(AI_GOAL_FAILED_END_OPT__PARENT_NEXT_SUB_GOAL)
    elseif f3_local14 == 7003 then
        print("?yAfter Action?z" .. "???X?e?b?v")
        f3_arg2:AddSubGoal(GOAL_EnemyStepLR, f3_arg2:GetLife(), f3_local0, f3_local7)
    elseif f3_local14 == 7004 then
        print("?yAfter Action?z" .. "??X?e?b?v")
        f3_arg2:AddSubGoal(GOAL_EnemyStepBack, f3_arg2:GetLife(), f3_local0, f3_local7)
    elseif f3_local14 == 7006 then
        print("?yAfter Action?z" .. "???????")
        f3_arg2:AddSubGoal(GOAL_EnemyKeepDist, f3_arg2:GetLife(), f3_local0, f3_local1, f3_arg1:GetAIAttackParam(7006, AI_ATTACK_PARAM_TYPE__MIN_OPTIMAL_DISTANCE), f3_arg1:GetAIAttackParam(7006, AI_ATTACK_PARAM_TYPE__MAX_OPTIMAL_DISTANCE), f3_local3, f3_local4, f3_local9, 0, f3_local8, f3_local9, f3_local10, f3_local7):SetFailedEndOption(AI_GOAL_FAILED_END_OPT__PARENT_NEXT_SUB_GOAL)
    elseif f3_local14 == 7007 then
        print("?yAfter Action?z" .. "?O?????")
        local f3_local16 = f3_arg1:GetAIAttackParam(7007, AI_ATTACK_PARAM_TYPE__MIN_ARRIVE_DISTANCE)
        if f3_local16 < 0 then
            f3_local16 = 0
        end
        local f3_local17 = (f3_local16 + f3_arg1:GetAIAttackParam(7007, AI_ATTACK_PARAM_TYPE__MAX_ARRIVE_DISTANCE)) / 2
        if f3_local17 < 0 then
            f3_local17 = 0
        end
        f3_arg2:AddSubGoal(GOAL_EnemyFlexibleApproach, f3_arg2:GetLife(), f3_local0, f3_local1, f3_local17, f3_local17, 0, 999, f3_local3, f3_local4, 0, 0, 0, 0)
    elseif f3_local14 == 7008 then
        print("?yAfter Action?z" .. "?O???X?e?b?v")
        f3_arg2:AddSubGoal(GOAL_EnemyStepFront, f3_arg2:GetLife(), f3_local0, f3_local7)
    else
        print("?yAfter Action?z" .. "?????????")
        f3_arg2:AddSubGoal(GOAL_COMMON_Turn, f3_arg2:GetLife(), f3_local0, 45, 0, 0)
    end
    


end

Goal.Update = function (f4_arg0, f4_arg1, f4_arg2)
    if f4_arg2:GetSubGoalNum() <= 0 then
        f4_arg1:TurnTo(TARGET_SELF)
        return GOAL_RESULT_Success
    end
    local f4_local0 = f4_arg2:GetParam(0)
    local f4_local1 = f4_arg2:GetParam(1)
    local f4_local2 = f4_arg1:GetDist(f4_local0)
    local f4_local3 = f4_arg2:GetNumber(0)
    if f4_local3 == 7000 then
        if (f4_arg1:GetAIAttackParam(f4_local3, AI_ATTACK_PARAM_TYPE__DOES_SELECT_ON_OUT_RANGE) == 1 and f4_arg1:GetAIAttackParam(f4_local3, AI_ATTACK_PARAM_TYPE__DOES_SELECT_ON_INNER_RANGE) == 1) == 0 and (f4_local2 < f4_arg1:GetAIAttackParam(f4_local3, AI_ATTACK_PARAM_TYPE__MIN_OPTIMAL_DISTANCE) or f4_arg1:GetAIAttackParam(f4_local3, AI_ATTACK_PARAM_TYPE__MAX_OPTIMAL_DISTANCE) < f4_local2) then
            return GOAL_RESULT_Success
        end
    elseif f4_local3 == 7002 then
    elseif f4_local3 == 7003 then
    elseif f4_local3 == 7004 then
    elseif f4_local3 == 7001 then
    elseif f4_local3 == 7006 then
    elseif f4_local3 == 7007 then
    elseif f4_local3 == 7008 then
    else
    end
    return GOAL_RESULT_Continue
    
end

RegisterTableGoal(GOAL_EnemyAfterAction, "GOAL_EnemyAfterAction")
REGISTER_GOAL_NO_SUB_GOAL(GOAL_EnemyAfterAction, true)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyAfterAction, 0, "???", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyAfterAction, 1, "??????", 1)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyAfterAction, 2, "?h?????m??", 2)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyAfterAction, 3, "??@", 3)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyAfterAction, 4, "?h???@", 4)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyAfterAction, 5, "?????", 5)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyAfterAction, 6, "???", 6)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyAfterAction, 7, "???X?e?b?v", 7)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyAfterAction, 8, "??X?e?b?v", 8)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyAfterAction, 9, "???????", 9)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyAfterAction, 10, "?????????", 10)

Goal.Activate = function (f5_arg0, f5_arg1, f5_arg2)
    local f5_local0 = f5_arg2:GetParam(0)
    local f5_local1 = f5_arg2:GetParam(1)
    local f5_local2 = f5_arg1:GetDist(f5_local0)
    local f5_local3 = f5_arg2:GetParam(2)
    local f5_local4 = f5_arg2:GetParam(3)
    local f5_local5 = f5_arg2:GetParam(4)
    local f5_local6 = f5_arg2:GetParam(5)
    local f5_local7 = f5_arg2:GetParam(6)
    local f5_local8 = f5_arg2:GetParam(7)
    local f5_local9 = f5_arg2:GetParam(8)
    local f5_local10 = f5_arg2:GetParam(9)
    local f5_local11 = f5_arg2:GetParam(10)
    local f5_local12 = f5_arg2:GetParam(11)
    local f5_local13 = f5_arg2:GetParam(12)
    local f5_local14 = 0
    local f5_local15 = {f5_local5, f5_local6, f5_local7, f5_local8, f5_local9, f5_local11, f5_local10}
    for f5_local16 = 7000, 7006, 1 do
        if f5_arg1:GetAIAttackParam(f5_local16, AI_ATTACK_PARAM_TYPE__MIN_OPTIMAL_DISTANCE) <= f5_local2 and f5_local2 <= f5_arg1:GetAIAttackParam(f5_local16, AI_ATTACK_PARAM_TYPE__MAX_OPTIMAL_DISTANCE) then
        else
            f5_local15[f5_local16 - 7000 + 1] = 0
        end
        f5_local14 = f5_local14 + f5_local15[f5_local16 - 7000 + 1]
    end
    local f5_local16 = f5_arg1:GetRandam_Float(0, f5_local14)
    local f5_local17 = 9999999
    local f5_local18 = 0
    for f5_local19 = 7000, 7006, 1 do
        f5_local18 = f5_local18 + f5_local15[f5_local19 - 7000 + 1]
        if f5_local16 <= f5_local18 then
            f5_local17 = f5_local19
            break
        end
    end
    if f5_local14 == 0 then
    elseif f5_local17 == 7002 then
        f5_arg2:AddSubGoal(GOAL_COMMON_LeaveTarget, f5_arg2:GetLife(), f5_local0, f5_arg1:GetAIAttackParam(7002, AI_ATTACK_PARAM_TYPE__MAX_OPTIMAL_DISTANCE), f5_local1, IsWalk, GuardID, 1, true):SetFailedEndOption(AI_GOAL_FAILED_END_OPT__PARENT_NEXT_SUB_GOAL)
        return
    elseif f5_local17 == 7003 then
        f5_arg2:AddSubGoal(GOAL_EnemyStepLR, f5_arg2:GetLife(), f5_local0, 5)
        return
    elseif f5_local17 == 7004 then
        print("??X?e?b?v")
        f5_arg2:AddSubGoal(GOAL_EnemyStepBack, f5_arg2:GetLife(), f5_local0, 5)
        return
    elseif f5_local17 == 7001 then
        f5_arg2:SetNumber(1, 2)
        f5_arg2:AddSubGoal(GOAL_COMMON_SidewayMove, f5_arg2:GetLife(), f5_local0, f5_arg1:GetRandam_Int(0, 1), f5_arg1:GetRandam_Float(30, 60), true, true, GuardID, 1)
        return
    elseif f5_local17 == 7000 then
        f5_arg2:SetNumber(1, 1)
        f5_arg2:AddSubGoal(GOAL_COMMON_Guard, f5_arg2:GetLife(), 9910, f5_local0, true, 1)
    elseif f5_local17 == 7006 then
        f5_arg2:AddSubGoal(GOAL_EnemyKeepDist, f5_arg2:GetLife(), f5_local0, f5_local1, f5_local12, f5_local13, 50, f5_local3, 30, 0, f5_arg0.EmergencyDist, f5_arg0.EmergencyEscapeRate, f5_arg0.EmergencyEscapeInterval, f5_arg0.EmergencyCheckDist):SetFailedEndOption(AI_GOAL_FAILED_END_OPT__PARENT_NEXT_SUB_GOAL)
    else
        f5_arg2:AddSubGoal(GOAL_COMMON_Turn, f5_arg2:GetLife(), f5_local0, 90, 0, 0)
        return
    end
    


end

Goal.Update = function (f6_arg0, f6_arg1, f6_arg2)
    local f6_local0 = f6_arg2:GetParam(0)
    local f6_local1 = f6_arg1:GetDist(f6_local0)
    if f6_arg2:GetNumber(1) ~= 0 then
        local f6_local2 = -1
        if f6_arg2:GetNumber(1) == 1 then
            f6_local2 = 7000
        elseif f6_arg2:GetNumber(1) == 2 then
            f6_local2 = 7001
        end
        if f6_local1 < f6_arg1:GetAIAttackParam(f6_local2, AI_ATTACK_PARAM_TYPE__MIN_OPTIMAL_DISTANCE) or f6_arg1:GetAIAttackParam(f6_local2, AI_ATTACK_PARAM_TYPE__MAX_OPTIMAL_DISTANCE) < f6_local1 then
            f6_arg1:TurnTo(TARGET_SELF)
            return GOAL_RESULT_Success
        end
    end
    if f6_arg2:GetSubGoalNum() <= 0 then
        f6_arg1:TurnTo(TARGET_SELF)
        return GOAL_RESULT_Success
    end
    return GOAL_RESULT_Continue
    
end

RegisterTableGoal(GOAL_EnemyApproachForAttack, "GOAL_EnemyApproachForAttack")
REGISTER_GOAL_NO_SUB_GOAL(GOAL_EnemyApproachForAttack, true)
Goal.Update = Update_FinishOnNoSubGoal

Goal.Activate = function (f7_arg0, f7_arg1, f7_arg2)
    f7_arg2:AddSubGoal(GOAL_EnemyBeforeAttack, f7_arg2:GetLife(), f7_arg2:GetParam(0), f7_arg2:GetParam(1), f7_arg2:GetParam(2), f7_arg2:GetParam(3), f7_arg2:GetParam(4), f7_arg2:GetParam(5), nil, nil, nil)
    
end

RegisterTableGoal(GOAL_EnemyStepRight, "GOAL_EnemyStepRight")
REGISTER_GOAL_NO_SUB_GOAL(GOAL_EnemyStepRight, true)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyStepRight, 0, "", 0)

Goal.Activate = function (f8_arg0, f8_arg1, f8_arg2)
    local f8_local0 = f8_arg2:GetParam(0)
    local f8_local1 = f8_arg2:GetParam(1)
    f8_arg1:StartIdTimer(7110004)
    f8_arg2:AddSubGoal(GOAL_COMMON_StepSafety, 5, -1, -1, -1, 1, f8_local0, f8_local1, 0, true)
    
end

RegisterTableGoal(GOAL_EnemyStepLeft, "GOAL_EnemyStepLeft")
REGISTER_GOAL_NO_SUB_GOAL(GOAL_EnemyStepLeft, true)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyStepLeft, 0, "", 0)

Goal.Activate = function (f9_arg0, f9_arg1, f9_arg2)
    local f9_local0 = f9_arg2:GetParam(0)
    local f9_local1 = f9_arg2:GetParam(1)
    f9_arg2:AddSubGoal(GOAL_COMMON_StepSafety, f9_arg2:GetLife(), -1, -1, 1, -1, f9_local0, f9_local1, 0, true)
    
end

RegisterTableGoal(GOAL_EnemyStepBack, "GOAL_EnemyStepBack")
REGISTER_GOAL_NO_SUB_GOAL(GOAL_EnemyStepBack, true)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyStepBack, 0, "", 0)

Goal.Activate = function (f10_arg0, f10_arg1, f10_arg2)
    local f10_local0 = f10_arg2:GetParam(0)
    local f10_local1 = f10_arg2:GetParam(1)
    f10_arg1:StartIdTimer(7110004)
    f10_arg2:AddSubGoal(GOAL_COMMON_StepSafety, f10_arg2:GetLife(), -1, 1, -1, -1, f10_local0, f10_local1, 0, true)
    
end

Goal.Update = function (f11_arg0, f11_arg1, f11_arg2)
    if f11_arg2:GetSubGoalNum() <= 0 then
        f11_arg1:TurnTo(TARGET_SELF)
        return GOAL_RESULT_Success
    end
    return GOAL_RESULT_Continue
    
end

RegisterTableGoal(GOAL_EnemyStepLR, "GOAL_EnemyStepLR")
REGISTER_GOAL_NO_SUB_GOAL(GOAL_EnemyStepLR, true)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyStepLR, 0, "", 0)

Goal.Activate = function (f12_arg0, f12_arg1, f12_arg2)
    local f12_local0 = f12_arg2:GetParam(0)
    local f12_local1 = f12_arg2:GetParam(1)
    f12_arg1:StartIdTimer(7110004)
    f12_arg2:AddSubGoal(GOAL_COMMON_StepSafety, f12_arg2:GetLife(), -1, -1, f12_arg1:GetRandam_Float(1, 100), f12_arg1:GetRandam_Float(1, 100), f12_local0, f12_local1, 0, true)
    
end

RegisterTableGoal(GOAL_EnemyStepBLR, "GOAL_EnemyStepBLR")
REGISTER_GOAL_NO_SUB_GOAL(GOAL_EnemyStepBLR, true)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyStepBLR, 0, "", 0)

Goal.Activate = function (f13_arg0, f13_arg1, f13_arg2)
    local f13_local0 = f13_arg2:GetParam(0)
    local f13_local1 = f13_arg2:GetParam(1)
    f13_arg2:AddSubGoal(GOAL_COMMON_StepSafety, f13_arg2:GetLife(), -1, f13_arg1:GetRandam_Float(1, 100), f13_arg1:GetRandam_Float(1, 100), f13_arg1:GetRandam_Float(1, 100), f13_local0, f13_local1, 0, true)
    
end

Goal.Update = function (f14_arg0, f14_arg1, f14_arg2)
    if f14_arg2:GetSubGoalNum() <= 0 then
        f14_arg1:TurnTo(TARGET_SELF)
        return GOAL_RESULT_Success
    end
    return GOAL_RESULT_Continue
    
end

RegisterTableGoal(GOAL_EnemyStepFront, "GOAL_EnemyStepFront")
REGISTER_GOAL_NO_SUB_GOAL(GOAL_EnemyStepFront, true)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyStepFront, 0, "", 0)

Goal.Activate = function (f15_arg0, f15_arg1, f15_arg2)
    local f15_local0 = f15_arg2:GetParam(0)
    local f15_local1 = f15_arg2:GetParam(1)
    f15_arg1:StartIdTimer(7110004)
    f15_arg2:AddSubGoal(GOAL_COMMON_StepSafety, f15_arg2:GetLife(), 1, -1, -1, -1, f15_local0, f15_local1, 0, true)
    
end

Goal.Update = function (f16_arg0, f16_arg1, f16_arg2)
    if f16_arg2:GetSubGoalNum() <= 0 then
        f16_arg1:TurnTo(TARGET_SELF)
        return GOAL_RESULT_Success
    end
    return GOAL_RESULT_Continue
    
end

RegisterTableGoal(GOAL_EnemyMoveToPoint, "GOAL_EnemyMoveToPoint")
ENABLE_COMBO_ATK_CANCEL(GOAL_EnemyMoveToPoint)
REGISTER_GOAL_NO_SUB_GOAL(GOAL_EnemyMoveToPoint, true)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyMoveToPoint, 0, "??W", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyMoveToPoint, 1, "??????", 1)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyMoveToPoint, 2, "???B???•c??", 2)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyMoveToPoint, 3, "??????", 3)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyMoveToPoint, 4, "?K?[?h???", 4)

Goal.Activate = function (f17_arg0, f17_arg1, f17_arg2)
    local f17_local0 = f17_arg2:GetParam(0)
    local f17_local1 = f17_arg2:GetParam(1)
    local f17_local2 = f17_arg2:GetParam(2)
    local f17_local3 = f17_arg2:GetParam(3)
    local f17_local4 = f17_arg2:GetParam(4)
    f17_arg1:SetEventMoveTarget(f17_local0)
    f17_arg2:AddSubGoal(GOAL_COMMON_ApproachTarget, f17_arg2:GetLife(), POINT_EVENT, f17_local2, f17_local1, f17_local3, f17_local4)
    
end

Goal.Update = function (f18_arg0, f18_arg1, f18_arg2)
    if f18_arg2:GetSubGoalNum() <= 0 then
        f18_arg1:TurnTo(TARGET_SELF)
        return GOAL_RESULT_Success
    end
    return GOAL_RESULT_Continue
    
end

RegisterTableGoal(GOAL_EnemyFlexisbleMove, "GOAL_EnemyFlexisbleMove")
REGISTER_GOAL_NO_SUB_GOAL(GOAL_EnemyFlexisbleMove, true)
REGISTER_DBG_GOAL_PARAM(GOAL_EnemyFlexisbleMove, 0, "", 0)

Goal.Activate = function (f19_arg0, f19_arg1, f19_arg2)
    local f19_local0 = f19_arg2:GetParam(0)
    local f19_local1 = f19_arg2:GetParam(1)
    local f19_local2 = f19_arg2:GetParam(2)
    local f19_local3 = f19_arg2:GetParam(3)
    
end

Goal.Update = function (f20_arg0, f20_arg1, f20_arg2)
    if f20_arg2:GetSubGoalNum() <= 0 then
        f20_arg1:TurnTo(TARGET_SELF)
        return GOAL_RESULT_Success
    end
    return GOAL_RESULT_Continue
    
end


