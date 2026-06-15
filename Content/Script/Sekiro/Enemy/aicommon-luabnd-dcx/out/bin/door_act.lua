REGISTER_GOAL_UPDATE_TIME(GOAL_COMMON_DoorAct, 0.2, 0.3)

function DoorAct_Activate(f1_arg0, f1_arg1)
    f1_arg0:PrintText("[DoorAct_Activate]Notice ObjAct")
    f1_arg0:SetAllowTriggerNearObjAct()
    
end

function DoorAct_Update(f2_arg0, f2_arg1)
    local f2_local0 = f2_arg0:IsExistReqObjAct()
    local f2_local1 = f2_arg0:HasGoal(GOAL_COMMON_ObjActTest)
    if f2_local0 and f2_local1 == false then
        f2_arg1:AddSubGoal(GOAL_COMMON_ObjActTest, 10, OBJ_ACT_TYPE_DOOR)
    end
    f2_arg1:AddLifeParentSubGoal(0.3)
    return GOAL_RESULT_Continue
    
end

function DoorAct_Terminate(f3_arg0, f3_arg1)
    
end

REGISTER_GOAL_NO_INTERUPT(GOAL_COMMON_DoorAct, true)

function DoorAct_Interupt(f4_arg0, f4_arg1)
    return false
    
end


