RegisterTableLogic(LOGIC_ID_PatrolLeader20000)

Logic.Main = function (f1_arg0, f1_arg1)
    f1_arg1:AddTopGoal(GOAL_COMMON_NonBattleAct, 10, 100, false, false, TARGET_SELF, 1)
    
end

Logic.Interrupt = function (f2_arg0, f2_arg1, f2_arg2)
    return false
    
end


