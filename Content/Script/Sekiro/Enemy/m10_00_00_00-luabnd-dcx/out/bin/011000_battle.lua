RegisterTableGoal(GOAL_NanimoShinai_11000_Battle, "GOAL_NanimoShinai_11000_Battle")
REGISTER_GOAL_NO_UPDATE(GOAL_NanimoShinai_11000_Battle, true)

Goal.Initialize = function (f1_arg0, f1_arg1, f1_arg2, f1_arg3)
    
end

Goal.Activate = function (f2_arg0, f2_arg1, f2_arg2)
    f2_arg2:AddSubGoal(GOAL_COMMON_Wait, 5, TARGET_NONE, 0, 0, 0)
    
end

Goal.Update = function (f3_arg0, f3_arg1, f3_arg2)
    return Update_Default_NoSubGoal(f3_arg0, f3_arg1, f3_arg2)
    
end

Goal.Terminate = function (f4_arg0, f4_arg1, f4_arg2)
    
end

Goal.Interrupt = function (f5_arg0, f5_arg1, f5_arg2)
    return false
    
end


