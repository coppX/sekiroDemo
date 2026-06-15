function Platoon000130_Activate(f1_arg0)
    f1_arg0:SetEnablePlatoonMove(true)
    f1_arg0:SetFormationType(0, 2)
    f1_arg0:SetFormationParam(0, 0, 0)
    f1_arg0:SetFormationParam(1, -1, -1)
    f1_arg0:SetFormationParam(2, 1, -1)
    f1_arg0:SetFormationParam(3, -1, -3)
    f1_arg0:SetFormationParam(4, 1, -3)
    f1_arg0:SetFormationParam(5, -1, -5)
    f1_arg0:SetBaseMoveRate(0, 4)
    
end

function Platoon000130_Deactivate(f2_arg0)
    
end

function Platoon000130_Update(f3_arg0)
    Platoon_Common_Act(f3_arg0)
    
end


