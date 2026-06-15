RegisterTableGoal(GOAL_COMMON_WeaponChange, "WeaponChange")

Goal.Activate = function (f1_arg0, f1_arg1, f1_arg2)
    local f1_local0 = f1_arg2:GetParam(0)
    local f1_local1 = nil
    if f1_local0 == 0 then
        f1_local1 = 1300
    elseif f1_local0 == 1 then
        f1_local1 = 1310
    elseif f1_local0 == 2 then
        f1_local1 = 1320
    elseif f1_local0 == 3 then
        f1_local1 = 1330
    else
        f1_local1 = 1300
    end
    f1_arg2:AddSubGoal(GOAL_COMMON_NonspinningAttack, f1_arg2:GetLife(), f1_local1, TARGET_ENE_0, DIST_None)
    
end

Goal.Update = function (f2_arg0, f2_arg1, f2_arg2)
    if f2_arg2:GetSubGoalNum() <= 0 then
        return GOAL_RESULT_Success
    end
    return GOAL_RESULT_Continue
    
end


