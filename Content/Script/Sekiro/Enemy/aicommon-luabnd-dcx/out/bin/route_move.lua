REGISTER_GOAL_NO_SUB_GOAL(GOAL_COMMON_RouteMove, true)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_RouteMove, 0, "???[?g??G???e?B?e?BID", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_RouteMove, 1, "?J?n?_????????n????H", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_RouteMove, 2, "?I?[???????I???????H", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_RouteMove, 3, "???B???•c??", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_RouteMove, 4, "???????H", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_RouteMove, 5, "???????", 0)
REGISTER_GOAL_NO_INTERUPT(GOAL_COMMON_RouteMove, true)

function RouteMove_Activate(f1_arg0, f1_arg1)
    local f1_local0 = f1_arg1:GetLife()
    local f1_local1 = f1_arg1:GetParam(0)
    local f1_local2 = f1_arg1:GetParam(1)
    local f1_local3 = f1_arg1:GetParam(3)
    local f1_local4 = f1_arg1:GetParam(4)
    local f1_local5 = f1_arg1:GetParam(5)
    f1_arg0:SetRouteInfoByEntityId(f1_local1)
    if f1_local2 <= 0 then
        local f1_local6 = f1_arg0:CalcNearMovePointOnRoute(TARGET_SELF, AI_DIR_TYPE_CENTER, 0, f1_local5)
        f1_arg0:SetCurrentMovePointIndex(f1_local6)
    end
    f1_arg1:AddSubGoal(GOAL_COMMON_MoveToSomewhereSmooth, f1_local0, POINT_MOVE_POINT, AI_DIR_TYPE_CENTER, f1_local3, TARGET_SELF, f1_local4)
    f1_arg1:AddSubGoal(GOAL_COMMON_MoveToSomewhereSmooth, f1_local0, POINT_MOVE_POINT, AI_DIR_TYPE_CENTER, f1_local3, TARGET_SELF, f1_local4)
    
end

function RouteMove_Update(f2_arg0, f2_arg1)
    if f2_arg1:GetSubGoalNum() <= 1 then
        local f2_local0 = f2_arg1:GetLife()
        local f2_local1 = f2_arg1:GetParam(2)
        local f2_local2 = f2_arg1:GetParam(3)
        local f2_local3 = f2_arg1:GetParam(4)
        if f2_local1 > 0 and true == f2_arg0:IsRouteEnd() then
            return GOAL_RESULT_Success
        end
        f2_arg1:AddSubGoal(GOAL_COMMON_MoveToSomewhereSmooth, f2_local0, POINT_MOVE_POINT, AI_DIR_TYPE_CENTER, f2_local2, TARGET_SELF, f2_local3)
    end
    return GOAL_RESULT_Continue
    
end

function RouteMove_Terminate(f3_arg0, f3_arg1)
    
end

function RouteMove_Interupt(f4_arg0, f4_arg1)
    return false
    
end


