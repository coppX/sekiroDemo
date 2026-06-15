RegisterTableGoal(GOAL_COMMON_StepSafety, "StepSafety")
REGISTER_GOAL_NO_SUB_GOAL(GOAL_COMMON_StepSafety, true)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_StepSafety, 0, "?O?X?e?b?v?D??x", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_StepSafety, 1, "??X?e?b?v?D??x", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_StepSafety, 2, "???X?e?b?v?D??x", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_StepSafety, 3, "?E?X?e?b?v?D??x", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_StepSafety, 4, "??????", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_StepSafety, 5, "???S?`?F?b?N????", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_StepSafety, 6, "?X?e?b?v?O??????", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_StepSafety, 7, "???s?s???????????????", 0)

Goal.Activate = function (f1_arg0, f1_arg1, f1_arg2)
    local f1_local0 = {}
    local f1_local1 = {}
    local f1_local2 = {6000, 6001, 6002, 6003}
    local f1_local3 = {AI_DIR_TYPE_F, AI_DIR_TYPE_B, AI_DIR_TYPE_L, AI_DIR_TYPE_R}
    local f1_local4 = {0, 180, -90, 90}
    local f1_local5 = table.getn(f1_local2)
    local f1_local6 = f1_arg2:GetParam(f1_local5)
    local f1_local7 = f1_arg2:GetParam(f1_local5 + 1)
    local f1_local8 = f1_arg2:GetParam(f1_local5 + 2)
    local f1_local9 = f1_arg2:GetParam(f1_local5 + 3)
    for f1_local10 = 0, f1_local5 - 1, 1 do
        if f1_arg2:GetParam(f1_local10) >= 0 then
            local f1_local13 = table.getn(f1_local0) + 1
            for f1_local14 = 1, f1_local13 - 1, 1 do
                if f1_local0[f1_local14] < f1_arg2:GetParam(f1_local10) then
                    f1_local13 = f1_local14
                    break
                end
            end
            table.insert(f1_local0, f1_local13, f1_arg2:GetParam(f1_local10))
            table.insert(f1_local1, f1_local13, f1_local10 + 1)

        end
    end
    for f1_local10 = 1, table.getn(f1_local0), 1 do
        local f1_local13 = f1_local3[f1_local1[f1_local10]]
        local f1_local14 = f1_arg1:GetMapHitRadius(TARGET_SELF)
        if f1_local7 <= f1_arg1:GetExistMeshOnLineDistEx(TARGET_SELF, f1_local13, f1_local7 + 3, f1_local14, f1_local14) and not f1_arg1:IsExistChrOnLineSpecifyAngle(TARGET_SELF, f1_local4[f1_local1[f1_local10]], f1_local7, AI_SPA_DIR_TYPE_TargetF) then
            f1_arg2:SetNumber(0, 0)
            f1_arg2:AddSubGoal(GOAL_COMMON_SpinStep, f1_arg2:GetLife(), f1_local2[f1_local1[f1_local10]], f1_local6, f1_local8, AI_DIR_TYPE_B, -1)
            return
        end
    end
    if f1_local9 == false then
        f1_arg2:SetNumber(0, 1)
    end
    


end

Goal.Update = function (f2_arg0, f2_arg1, f2_arg2)
    if f2_arg2:GetSubGoalNum() <= 0 then
        if f2_arg2:GetNumber(0) == 1 then
            return GOAL_RESULT_Failed
        end
        return GOAL_RESULT_Success
    end
    return GOAL_RESULT_Continue
    
end


