function Platoon000110_Activate(f1_arg0)
    f1_arg0:SetEnablePlatoonMove(true)
    f1_arg0:SetFormationType(0, 2)
    f1_arg0:SetFormationParam(0, 0, 0)
    f1_arg0:SetFormationParam(1, 0, 0)
    f1_arg0:SetFormationParam(2, 2, -1)
    f1_arg0:SetFormationParam(3, 0, -3)
    f1_arg0:SetFormationParam(4, 2, -4)
    f1_arg0:SetFormationParam(5, 1, -7)
    f1_arg0:SetBaseMoveRate(0, 1.5)
    
end

function Platoon000110_Deactivate(f2_arg0)
    
end

function Platoon000110_Update(f3_arg0)
    Platoon_Common_Act(f3_arg0)
    
end


