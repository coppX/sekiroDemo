REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_WaitWithAnime, 0, "?A?j??ID", 0)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_WaitWithAnime, 1, "??????", 1)

function WaitWithAnime_Activate(f1_arg0, f1_arg1)
    local f1_local0 = f1_arg1:GetParam(0)
    local f1_local1 = f1_arg1:GetParam(1)
    f1_arg1:AddSubGoal(GOAL_COMMON_AttackNonCancel, f1_arg1:GetLife(), f1_local0, f1_local1, 9999, 0, -1)
    
end

function WaitWithAnime_Update(f2_arg0, f2_arg1)
    return GOAL_RESULT_Continue
    
end

function WaitWithAnime_Terminate(f3_arg0, f3_arg1)
    
end

function WaitWithAnime_Interupt(f4_arg0, f4_arg1)
    return false
    
end


