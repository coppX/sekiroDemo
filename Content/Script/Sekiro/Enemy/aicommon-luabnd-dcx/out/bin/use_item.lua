REGISTER_GOAL_NO_UPDATE(GOAL_COMMON_UseItem, true)
REGISTER_GOAL_NO_INTERUPT(GOAL_COMMON_UseItem, true)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_UseItem, 0, "?A?C?e???C???f?b?N?X", 0)

function UseItem_Activate(f1_arg0, f1_arg1)
    local f1_local0 = f1_arg1:GetParam(0)
    f1_arg0:ChangeEquipItem(f1_local0)
    f1_arg1:AddSubGoal(GOAL_COMMON_Attack, 5, NPC_ATK_Item, TARGET_NONE, DIST_None)
    
end

function UseItem_Update(f2_arg0, f2_arg1)
    return GOAL_RESULT_Continue
    
end

function UseItem_Terminate(f3_arg0, f3_arg1)
    
end

function UseItem_Interupt(f4_arg0, f4_arg1)
    return false
    
end


