function Platoon000100_Activate(f1_arg0)
    f1_arg0:SetEnablePlatoonMove(true)
    f1_arg0:SetFormationType(0, 2)
    f1_arg0:SetFormationParam(0, 0, 0)
    f1_arg0:SetFormationParam(1, 0, 0)
    f1_arg0:SetFormationParam(2, 2, -2)
    f1_arg0:SetFormationParam(3, -2, -3)
    f1_arg0:SetFormationParam(4, 1, -5)
    f1_arg0:SetFormationParam(5, -1, -6)
    f1_arg0:SetBaseMoveRate(0, 1.2)
    
end

function Platoon000100_Deactivate(f2_arg0)
    
end

function Platoon000100_Update(f3_arg0)
    Platoon_Common_Act(f3_arg0)
    
end


