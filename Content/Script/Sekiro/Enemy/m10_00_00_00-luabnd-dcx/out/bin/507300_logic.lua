RegisterTableLogic(507300)

Logic.Main = function (f1_arg0, f1_arg1)
    local f1_local0 = f1_arg1:GetEventRequest()
    if f1_arg1:HasSpecialEffectId(TARGET_SELF, 200004) then
        _COMMON_SetBattleGoal(f1_arg1)
    elseif f1_local0 == 30 then
        f1_arg1:AddTopGoal(GOAL_COMMON_AttackTunableSpin, 10, 3030, TARGET_ENE_0, 9999, 0, 0, 0, 0)
        f1_arg1:AddTopGoal(GOAL_COMMON_AttackTunableSpin, 10, 20000, TARGET_ENE_0, 9999, 0, 0, 0, 0)
    else
        f1_arg1:AddTopGoal(GOAL_COMMON_Wait, 10, TARGET_SELF, 0, 0, 0)
    end
    
end

Logic.Interrupt = function (f2_arg0, f2_arg1, f2_arg2)
    if f2_arg1:IsInterupt(INTERUPT_EventRequest) then
        f2_arg1:Replanning()
        return true
    end
    return false
    
end


