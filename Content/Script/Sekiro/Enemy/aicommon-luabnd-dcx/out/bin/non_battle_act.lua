REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_NonBattleAct, 0, "?G????????ûÐ???ym?z", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_NonBattleAct, 1, "?G??????I???H", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_NonBattleAct, 2, "????H", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_NonBattleAct, 3, "????yTYPE?z", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_NonBattleAct, 4, "????????????ym?z", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_NonBattleAct, 5, "??@???S?[??", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_NonBattleAct, 6, "?p???I?t?Z?b?g", 0)
REGISTER_GOAL_UPDATE_TIME(GOAL_COMMON_NonBattleAct, 0.1, 0.2)

function NonBattleAct_Activate(f1_arg0, f1_arg1)
    local f1_local0 = f1_arg1:GetParam(2)
    if f1_arg0:HasSpecialEffectId(TARGET_SELF, 5000) then
        f1_local0 = false
    elseif f1_local0 == 0 then
        f1_local0 = true
    else
        f1_local0 = false
    end
    if f1_arg0:IsValidPlatoon() == true and f1_arg0:IsPlatoonLeader() == false and not f1_arg0:HasSpecialEffectId(TARGET_SELF, 5002) then
        local f1_local1 = f1_arg0:GetPlatoonCommand()
        local f1_local2 = f1_local1:GetCommandNo()
        local f1_local3 = f1_arg0:GetDist(TARGET_TEAM_FORMATION)
        if f1_local2 == 5 then
            if f1_arg0:IsSearchTarget(TARGET_ENE_0) then
                local f1_local4 = f1_arg1:GetParam(7)
                local f1_local5 = f1_arg1:GetParam(6)
                f1_arg1:AddSubGoal(GOAL_COMMON_BackToHome_With_Parry, f1_arg1:GetLife())
            elseif f1_local3 < 1 then
                f1_arg1:AddSubGoal(GOAL_COMMON_Stay, 0.5, 0, TARGET_TEAM_FORMATION)
            else
                f1_arg1:AddSubGoal(GOAL_COMMON_MoveToSomewhere, f1_arg1:GetLife(), TARGET_TEAM_FORMATION, AI_DIR_TYPE_CENTER, 0.1, TARGET_SELF, f1_local0, 0, nil, AI_CALC_DIST_TYPE__XYZ, f1_arg1:GetParam(6), GUARD_GOAL_DESIRE_RET_Continue, false)
            end
        else
            NonBattleAct_Common(f1_arg0, f1_arg1)
        end
    elseif f1_arg0:IsValidPlatoon() == true and f1_arg0:IsPlatoonLeader() == true then
        NonBattleAct_Common(f1_arg0, f1_arg1)
    else
        NonBattleAct_Common(f1_arg0, f1_arg1)
    end
    
end

function NonBattleAct_Common(f2_arg0, f2_arg1)
    local f2_local0 = f2_arg0:GetPrevMovePointNumber()
    local f2_local1 = f2_arg0:GetMovePointWaitTime(f2_local0)
    local f2_local2 = f2_arg0:GetMovePointAnimId(f2_local0)
    f2_arg0:SetStringIndexedNumber("RouteMoveAction:prevPoint ", f2_local0)
    f2_arg0:SetStringIndexedNumber("RouteMoveAction:AnimId  ", f2_arg0:GetMovePointAnimId(f2_local0))
    f2_arg0:SetStringIndexedNumber("RouteMoveAction:WaitTime", f2_arg0:GetMovePointWaitTime(f2_local0))
    local f2_local3 = f2_arg0:GetMovePointNumber()
    local f2_local4 = f2_arg1:GetParam(2)
    if f2_arg0:HasSpecialEffectId(TARGET_SELF, 5000) then
        f2_local4 = false
    elseif f2_local4 == 0 then
        f2_local4 = true
    else
        f2_local4 = false
    end
    if f2_arg0:GetStringIndexedNumber("NonBattleAct_FailedPathMove") > 0 then
        local f2_local5 = f2_arg0:GetActTypeOnNonBattleFailedPathEnd()
        if AI_FAILED_PATH_NONBTL_ACT_TYPE__STAY == f2_local5 then
            f2_arg1:AddSubGoal(GOAL_COMMON_Stay, f2_arg1:GetLife(), 0, turn_tgt)
        elseif AI_FAILED_PATH_NONBTL_ACT_TYPE__WALK_AROUND == f2_local5 then
            f2_arg1:AddSubGoal(GOAL_COMMON_WalkAround, -1, 0.5, f2_local4)
        end
    elseif f2_local3 >= 0 then
        if f2_arg0:HasSpecialEffectId(TARGET_SELF, 205070) or f2_arg0:HasSpecialEffectId(TARGET_SELF, 205071) then
            f2_arg1:AddSubGoal(GOAL_COMMON_Wait, 5, TARGET_SELF, 0, 0, 0)
        elseif f2_arg0:IsSearchTarget(TARGET_ENE_0) then
            local f2_local5 = f2_arg1:GetParam(7)
            local f2_local6 = f2_arg1:GetParam(6)
            f2_arg1:AddSubGoal(GOAL_COMMON_BackToHome_With_Parry, f2_arg1:GetLife())
        elseif f2_arg0:HasSpecialEffectId(TARGET_SELF, 5001) then
            if f2_arg1:GetLastResult() == GOAL_RESULT_Success then
                local f2_local5 = f2_arg0:GetPrevMovePointNumber()
                local f2_local6 = f2_arg0:GetMovePointWaitTime(f2_local5)
                local f2_local7 = f2_arg0:GetMovePointAnimId(f2_local5)
                if f2_local7 > 0 then
                    f2_arg1:AddSubGoal(GOAL_COMMON_WaitWithAnime, 20, f2_local7, TARGET_SELF)
                end
                if f2_local6 > 0 then
                    f2_arg1:AddSubGoal(GOAL_COMMON_Wait, f2_local6)
                end
                f2_arg0:SetStringIndexedNumber("RouteMoveAction:prevPoint ", f2_local5)
                f2_arg0:SetStringIndexedNumber("RouteMoveAction:AnimId  ", f2_arg0:GetMovePointAnimId(f2_local5))
                f2_arg0:SetStringIndexedNumber("RouteMoveAction:WaitTime", f2_arg0:GetMovePointWaitTime(f2_local5))
            end
            f2_arg1:AddSubGoal(GOAL_COMMON_Turn, 3, POINT_MOVE_POINT, 30, f2_arg1:GetParam(6), 0, true)
            f2_arg1:AddSubGoal(GOAL_COMMON_MoveToSomewhere, f2_arg1:GetLife(), POINT_MOVE_POINT, AI_DIR_TYPE_CENTER, 0, TARGET_SELF, f2_local4, 0, 0, AI_CALC_DIST_TYPE__XYZ, f2_arg1:GetParam(6), GUARD_GOAL_DESIRE_RET_Continue, false)
        else
            if f2_arg1:GetLastResult() == GOAL_RESULT_Success then
                local f2_local5 = f2_arg0:GetPrevMovePointNumber()
                local f2_local6 = f2_arg0:GetMovePointWaitTime(f2_local5)
                local f2_local7 = f2_arg0:GetMovePointAnimId(f2_local5)
                if f2_local7 > 0 then
                    f2_arg1:AddSubGoal(GOAL_COMMON_WaitWithAnime, 20, f2_local7, TARGET_SELF)
                end
                if f2_local6 > 0 then
                    f2_arg1:AddSubGoal(GOAL_COMMON_Wait, f2_local6)
                end
                if f2_local7 > 0 or f2_local6 > 0 then
                    f2_arg1:AddSubGoal(GOAL_COMMON_Turn, 3, POINT_MOVE_POINT, 45, -1, GOAL_RESULT_Success, true)
                end
                f2_arg0:SetStringIndexedNumber("RouteMoveAction:prevPoint ", f2_local5)
                f2_arg0:SetStringIndexedNumber("RouteMoveAction:AnimId  ", f2_arg0:GetMovePointAnimId(f2_local5))
                f2_arg0:SetStringIndexedNumber("RouteMoveAction:WaitTime", f2_arg0:GetMovePointWaitTime(f2_local5))
            end
            local f2_local5 = f2_arg0:GetMovePointNumber()
            local f2_local6 = f2_arg0:GetMovePointWaitTime(f2_local5)
            local f2_local7 = f2_arg0:GetMovePointAnimId(f2_local5)
            if f2_local7 > 0 or f2_local6 > 0 then
                f2_arg1:AddSubGoal(GOAL_COMMON_MoveToSomewhere, f2_arg1:GetLife(), POINT_MOVE_POINT, AI_DIR_TYPE_CENTER, 0, TARGET_SELF, f2_local4, 0, 0, AI_CALC_DIST_TYPE__XYZ, f2_arg1:GetParam(6), GUARD_GOAL_DESIRE_RET_Continue, false)
            else
                f2_arg1:AddSubGoal(GOAL_COMMON_MoveToSomewhereSmooth, f2_arg1:GetLife(), POINT_MOVE_POINT, AI_DIR_TYPE_CENTER, 0, TARGET_SELF, f2_local4, 0, f2_arg1:GetParam(6), GUARD_GOAL_DESIRE_RET_Continue, false)
            end
        end
    else
        local f2_local5 = f2_arg0:GetMovePointEffectRange()
        local f2_local6 = f2_arg1:GetParam(3)
        local f2_local7 = f2_arg1:GetParam(4)
        local f2_local8 = f2_arg0:GetSmallActAnimId()
        local f2_local9 = f2_arg0:GetSmallActPreWaitTime()
        local f2_local10 = f2_arg0:GetSmallActPostWaitTime()
        f2_arg0:SetStringIndexedNumber("changePosition", f2_arg0:IsChangeInitialPosition())
        if f2_local7 == 0 then
            f2_local7 = 1
        end
        if f2_local7 < f2_local5 then
            local f2_local11 = f2_arg1:GetParam(7)
            if f2_arg0:HasSpecialEffectId(TARGET_SELF, 205070) or f2_arg0:HasSpecialEffectId(TARGET_SELF, 205071) then
                f2_arg1:AddSubGoal(GOAL_COMMON_Wait, 5, TARGET_SELF, 0, 0, 0)
            else
                local f2_local12 = f2_arg1:GetParam(7)
                local f2_local13 = f2_arg1:GetParam(6)
                f2_arg1:AddSubGoal(GOAL_COMMON_BackToHome_With_Parry, f2_arg1:GetLife())
            end
        else
            f2_arg0:SetStringIndexedNumber("SmallAct:toutatsu ", 1)
            if f2_arg0:GetMovePointType() == 6 then
                f2_arg1:AddSubGoal(GOAL_COMMON_WalkAround, -1, 0.5, true)
            elseif f2_arg0:IsChangeInitialPosition() == false and f2_local8 >= 0 then
                f2_arg1:AddSubGoal(GOAL_COMMON_Turn, 3, POINT_INIT_POSE, 15, -1, GOAL_RESULT_Success, true)
                f2_arg1:AddSubGoal(GOAL_COMMON_Wait, f2_local9)
                f2_arg1:AddSubGoal(GOAL_COMMON_WaitWithAnime, 20, f2_local8, TARGET_SELF)
                f2_arg1:AddSubGoal(GOAL_COMMON_Wait, f2_local10)
                f2_arg0:SetStringIndexedNumber("SmallAct:animeId ", f2_local8)
                f2_arg0:SetStringIndexedNumber("SmallAct:preWaitTime ", f2_local9)
                f2_arg0:SetStringIndexedNumber("SmallAct:postWaitTime ", f2_local10)
            elseif f2_arg1:IsExistParam(5) then
                local f2_local11 = f2_arg1:GetParam(5)
                if f2_local11 > 0 then
                    f2_arg1:AddSubGoal(f2_local11, f2_arg1:GetLife())
                else
                    local f2_local12 = f2_arg0:GetMovePointAnimId(f2_local0)
                    if f2_local12 > 0 and f2_arg0:GetNumber(AI_NUMBER_LAST_POINT_ACTION) == 0 then
                        local f2_local13 = f2_arg0:GetPrevMovePointNumber()
                        local f2_local14 = f2_arg0:GetMovePointWaitTime(f2_local13)
                        if f2_local12 > 0 then
                            f2_arg1:AddSubGoal(GOAL_COMMON_Turn, 3, POINT_INIT_POSE, 30, f2_arg1:GetParam(6), 0, true)
                            f2_arg1:AddSubGoal(GOAL_COMMON_WaitWithAnime, 20, f2_local12, POINT_INIT_POSE):TimingSetNumber(AI_NUMBER_LAST_POINT_ACTION, 1, AI_TIMING_SET__ACTIVATE)
                        end
                        if f2_local14 > 0 then
                            f2_arg1:AddSubGoal(GOAL_COMMON_Wait, f2_local14)
                        end
                        f2_arg0:SetStringIndexedNumber("RouteMoveAction:prevPoint ", f2_local13)
                        f2_arg0:SetStringIndexedNumber("RouteMoveAction:AnimId  ", f2_arg0:GetMovePointAnimId(f2_local13))
                        f2_arg0:SetStringIndexedNumber("RouteMoveAction:WaitTime", f2_arg0:GetMovePointWaitTime(f2_local13))
                    end
                    if f2_arg0:HasSpecialEffectId(TARGET_SELF, COMMON_SP_EFFECT_NOT_TURN_TO_POINT_INITIAL) then
                        f2_arg1:AddSubGoal(GOAL_COMMON_Wait, 10)
                    else
                        f2_arg1:AddSubGoal(GOAL_COMMON_Stay, f2_arg1:GetLife(), 0, f2_local6)
                    end
                end
            elseif f2_arg0:HasSpecialEffectId(TARGET_SELF, COMMON_SP_EFFECT_NOT_TURN_TO_POINT_INITIAL) then
                f2_arg1:AddSubGoal(GOAL_COMMON_Wait, 10)
            else
                f2_arg1:AddSubGoal(GOAL_COMMON_Stay, f2_arg1:GetLife(), 0, f2_local6)
            end
        end
    end
    
end

function NonBattleAct_Update(f3_arg0, f3_arg1)
    return GOAL_RESULT_Continue
    
end

function NonBattleAct_Terminate(f4_arg0, f4_arg1)
    
end

function NonBattleAct_Interupt(f5_arg0, f5_arg1)
    local f5_local0 = false or f5_arg0:IsInterupt(INTERUPT_Damaged_Stranger) or f5_arg0:IsInterupt(INTERUPT_Damaged)
    if f5_local0 then
        f5_arg1:SetTimer(1, 99999)
        return true
    end
    if f5_arg0:IsInterupt(INTERUPT_MovedEnd_OnFailedPath) and (f5_arg0:IsValidPlatoon() ~= true or f5_arg0:IsPlatoonLeader() ~= true) then
        f5_arg0:ResetInitialPosition()
        f5_arg0:SetStringIndexedNumber("NonBattleAct_FailedPathMove", 1)
        local f5_local1 = f5_arg0:GetActTypeOnNonBattleFailedPathEnd()
        if AI_FAILED_PATH_NONBTL_ACT_TYPE__WALK_AROUND == f5_local1 then
            f5_arg0:SetNonBattleWalkAroundMode(true)
        end
        f5_arg0:Replanning()
        return true
    end
    return false
    
end


