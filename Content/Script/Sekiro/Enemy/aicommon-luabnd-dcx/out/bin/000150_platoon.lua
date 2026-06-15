function Platoon000150_Activate(f1_arg0)
    f1_arg0:SetEnablePlatoonMove(true)
    f1_arg0:SetFormationType(0, 2)
    f1_arg0:SetFormationParam(0, 0, 0)
    f1_arg0:SetFormationParam(1, 0, 1.5)
    f1_arg0:SetFormationParam(2, 0, -1.5)
    f1_arg0:SetFormationParam(3, 0, -4.5)
    f1_arg0:SetFormationParam(4, 0, -7.5)
    f1_arg0:SetFormationParam(5, 0, -10.5)
    f1_arg0:SetBaseMoveRate(0, 1.5)
    
end

function Platoon000150_Deactivate(f2_arg0)
    
end

function Platoon000150_Update(f3_arg0)
    local f3_local0 = f3_arg0:GetMemberAI(0)
    if f3_local0:GetMovePointNumber() == -1 then
        f3_arg0:SetEnablePlatoonMove(false)
        for f3_local1 = f3_arg0:GetMemberNum() - 1, 0, -1 do
            f3_arg0:SendCommand(f3_local1, 0)
        end
    else
        Platoon_Common_Act(f3_arg0)
    end
    
end


