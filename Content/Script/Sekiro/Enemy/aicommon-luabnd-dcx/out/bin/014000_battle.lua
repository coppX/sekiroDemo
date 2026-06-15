guardId = 0

function DS2PGTest14000_Battle_Activate(f1_arg0, f1_arg1)
    if f1_arg0:GetDist(TARGET_ENE_0) < 1 then
        f1_arg1:AddSubGoal(GOAL_COMMON_ComboAttack, 10, NPC_ATK_NormalR, TARGET_ENE_0, 3, 0)
    else
        f1_arg1:AddSubGoal(GOAL_COMMON_ApproachTarget, 10, TARGET_ENE_0, AI_DIR_TYPE_CENTER, TARGET_SELF, false, -1)
    end
    
end

function DS2PGTest14000_Battle_Update(f2_arg0, f2_arg1)
    if f2_arg0:GetDist(TARGET_ENE_0) > 20 then
        return GOAL_RESULT_Success
    end
    return GOAL_RESULT_Continue
    
end

function DS2PGTest14000_Battle_Terminate(f3_arg0, f3_arg1)
    
end

function DS2PGTest14000_Battle_Interupt(f4_arg0, f4_arg1)
    
end


