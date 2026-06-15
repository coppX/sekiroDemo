function Platoon000140_Activate(f1_arg0)
    f1_arg0:SetEnablePlatoonMove(true)
    f1_arg0:SetFormationType(0, 2)
    f1_arg0:SetFormationParam(0, 0, 0)
    f1_arg0:SetFormationParam(1, -0.5, 0)
    f1_arg0:SetFormationParam(2, 0.5, 0)
    f1_arg0:SetFormationParam(3, -0.5, -1.5)
    f1_arg0:SetFormationParam(4, 0.5, -1.5)
    f1_arg0:SetFormationParam(5, -0.5, -3)
    f1_arg0:SetFormationParam(6, 0.5, -3)
    f1_arg0:SetBaseMoveRate(0, 1.2)
    
end

function Platoon000140_Deactivate(f2_arg0)
    
end

function Platoon000140_Update(f3_arg0)
    Platoon_Common_Act(f3_arg0)
    
end


