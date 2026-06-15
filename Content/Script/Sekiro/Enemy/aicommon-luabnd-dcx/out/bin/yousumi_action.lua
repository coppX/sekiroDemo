RegisterTableGoal(GOAL_COMMON_YousumiAct, "YousumiAct")
REGISTER_GOAL_NO_SUB_GOAL(GOAL_COMMON_YousumiAct, true)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_YousumiAct, 0, "??????", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_YousumiAct, 1, "???p?x", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_YousumiAct, 2, "????p?x", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_YousumiAct, 3, "?p???I?t?Z?b?g", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_YousumiAct, 4, "?????S?[???????", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_YousumiAct, 5, "??????S?[???????", 0)

Goal.Activate = function (f1_arg0, f1_arg1, f1_arg2)
    local f1_local0 = f1_arg2:GetParam(0)
    local f1_local1 = f1_arg2:GetParam(1)
    local f1_local2 = f1_arg2:GetParam(2)
    local f1_local3 = f1_arg2:GetParam(3)
    local f1_local4 = f1_arg2:GetParam(4)
    local f1_local5 = f1_arg2:GetParam(5)
    if f1_local4 == 0 then
        f1_local4 = 1
    end
    if f1_local5 == 0 then
        f1_local5 = 2.5
    end
    local f1_local6 = f1_arg2:GetLife()
    local f1_local7 = f1_arg1:GetDist(TARGET_ENE_0)
    local f1_local8 = f1_arg1:GetDistYSigned(TARGET_ENE_0)
    local f1_local9 = 1
    local f1_local10 = 30
    local f1_local11 = f1_local8 / math.sin(math.rad(f1_local1))
    local f1_local12 = f1_local8 / math.sin(math.rad(f1_local2))
    local f1_local13 = f1_arg1:GetRandam_Int(0, 1)
    local f1_local14 = true
    local f1_local15 = 2.5
    local f1_local16 = -1
    if f1_local3 == 9910 then
        f1_local16 = 9910
    end
    local f1_local17 = SpaceCheck_SidewayMove(f1_arg1, f1_arg2, 1)
    if f1_local17 == 0 then
        f1_local13 = 0
    elseif f1_local17 == 1 then
        f1_local13 = 1
    elseif f1_local17 == 2 then
    else
    end
    local f1_local18 = TARGET_ENE_0
    if f1_arg1:CheckDoesExistPathWithSetPoint(TARGET_ENE_0, AI_DIR_TYPE_F, 0, 0) == false then
        f1_local18 = POINT_UnreachTerminate
        f1_local7 = f1_arg1:GetDist_Point(POINT_UnreachTerminate)
        f1_local15 = 0.5
    end
    if f1_arg1:GetStringIndexedNumber("Reach_EndOnFailedPath") == 1 then
        f1_arg1:SetStringIndexedNumber("Reach_EndOnFailedPath", 0)
    elseif f1_local10 <= f1_local7 then
        f1_arg2:AddSubGoal(GOAL_COMMON_ApproachTarget, 1.5, f1_local18, f1_local10 - 0.5, TARGET_SELF, false, f1_local16)
    elseif f1_local8 > 0 then
        if f1_local12 <= f1_local7 then
            if f1_local7 <= f1_local15 then
            elseif f1_local7 - f1_local12 >= 5 and f1_local0 == false then
                f1_arg2:AddSubGoal(GOAL_COMMON_ApproachTarget, 1.5, f1_local18, f1_local15, TARGET_SELF, false, f1_local16)
            else
                f1_arg2:AddSubGoal(GOAL_COMMON_ApproachTarget, 3, f1_local18, f1_local15, TARGET_SELF, true, f1_local16)
            end
        elseif f1_local7 <= f1_local11 then
            if f1_arg1:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 180) then
                if SpaceCheck(f1_arg1, f1_arg2, 180, 1.5) == true then
                    f1_arg2:AddSubGoal(GOAL_COMMON_LeaveTarget, f1_local4, TARGET_ENE_0, 50, TARGET_ENE_0, true, f1_local16)
                end
            elseif SpaceCheck(f1_arg1, f1_arg2, 0, 0.5) == true then
                f1_arg2:AddSubGoal(GOAL_COMMON_LeaveTarget, f1_local4, TARGET_ENE_0, 50, TARGET_ENE_0, true, f1_local16)
            else
                f1_arg2:AddSubGoal(GOAL_COMMON_Turn, 3, TARGET_ENE_0, 0, 0, 0, 0)
                if false then
                end
            end
        end
    elseif SpaceCheck(f1_arg1, f1_arg2, 0, 0.5) == false then
        f1_arg2:AddSubGoal(GOAL_COMMON_LeaveTarget, f1_local4, TARGET_ENE_0, 50, TARGET_ENE_0, true, f1_local16)
    elseif f1_local7 <= f1_local15 then
    elseif SpaceCheck(f1_arg1, f1_arg2, 0, 4) == true and f1_local0 == false then
        f1_arg2:AddSubGoal(GOAL_COMMON_ApproachTarget, 1.5, f1_local18, f1_local15, TARGET_SELF, false, f1_local16)
    elseif SpaceCheck(f1_arg1, f1_arg2, 0, 3) == true then
        f1_arg2:AddSubGoal(GOAL_COMMON_ApproachTarget, 3, f1_local18, f1_local15, TARGET_SELF, true, f1_local16)
    else
    end
    
end

Goal.Update = function (f2_arg0, f2_arg1, f2_arg2)
    return Update_Default_NoSubGoal(f2_arg0, f2_arg1, f2_arg2)
    
end

Goal.Terminate = function (f3_arg0, f3_arg1, f3_arg2)
    
end

Goal.Interrupt = function (f4_arg0, f4_arg1, f4_arg2)
    if f4_arg1:IsInterupt(INTERUPT_MovedEnd_OnFailedPath) then
        f4_arg2:ClearSubGoal()
        f4_arg2:AddSubGoal(GOAL_COMMON_Wait_On_FailedPath, 0.5, 0.1)
        return true
    end
    return false
    
end


