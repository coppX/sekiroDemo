function Platoon000120_Activate(f1_arg0)
    f1_arg0:SetEnablePlatoonMove(true)
    f1_arg0:SetFormationType(0, 2)
    f1_arg0:SetFormationParam(0, 0, 0)
    f1_arg0:SetFormationParam(1, 0, 2)
    f1_arg0:SetFormationParam(2, 1, 1)
    f1_arg0:SetFormationParam(3, 2, 0)
    f1_arg0:SetFormationParam(4, 1, -1)
    f1_arg0:SetFormationParam(5, 0, -2)
    f1_arg0:SetFormationParam(6, -1, -1)
    f1_arg0:SetFormationParam(7, -2, 0)
    f1_arg0:SetFormationParam(8, -1, 1)
    f1_arg0:SetBaseMoveRate(0, 1.2)
    
end

function Platoon000120_Deactivate(f2_arg0)
    
end

function Platoon000120_Update(f3_arg0)
    Platoon_Common_Act(f3_arg0)
    
end


