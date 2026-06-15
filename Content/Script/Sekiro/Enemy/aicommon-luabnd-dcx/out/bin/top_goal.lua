function TopGoal_Activate(f1_arg0, f1_arg1)
    
end

function TopGoal_Update(f2_arg0, f2_arg1)
    return GOAL_RESULT_Continue
    
end

function TopGoal_Terminate(f3_arg0, f3_arg1)
    
end

function TopGoal_Interupt(f4_arg0, f4_arg1)
    if f4_arg0:IsInterupt(INTERUPT_CANNOT_MOVE) then
        local f4_local0 = f4_arg0:GetExcelParam(AI_EXCEL_THINK_PARAM_TYPE__CannotMoveAction)
        if f4_arg0:IsTouchBreakableObject() and f4_local0 >= 0 and f4_arg0:IsLookToTarget(POINT_CurrRequestPosition, 90) then
            f4_arg1:ClearSubGoal()
            f4_arg1:AddSubGoal(GOAL_COMMON_NonspinningAttack, -1, f4_local0, TARGET_NONE, DIST_None)
            return true
        end
    end
    if f4_arg0:IsInterupt(INTERUPT_CANNOT_MOVE_DisableInterupt) then
        local f4_local0 = f4_arg0:GetExcelParam(AI_EXCEL_THINK_PARAM_TYPE__CannotMoveAction)
        if f4_arg0:IsTouchBreakableObject() and f4_local0 >= 0 and f4_arg0:IsLookToTarget(POINT_CurrRequestPosition, 90) then
            f4_arg1:AddSubGoal_Front(GOAL_COMMON_NonspinningAttack, -1, f4_local0, TARGET_NONE, DIST_None)
            return true
        end
    end
    if f4_arg0:IsInterupt(INTERUPT_HitEnemyWall) then
        local f4_local0 = f4_arg0:GetExcelParam(AI_EXCEL_THINK_PARAM_TYPE__backhomeBattleDist)
        local f4_local1 = f4_arg0:GetExcelParam(AI_EXCEL_THINK_PARAM_TYPE__maxBackhomeDist)
        local f4_local2 = f4_arg0:GetDist(TARGET_ENE_0)
        local f4_local3 = f4_arg0:GetMovePointEffectRange()
        local f4_local4 = f4_arg0:GetExcelParam(AI_EXCEL_THINK_PARAM_TYPE__BackHomeLife_OnHitEnemyWall)
        if f4_local4 > 0 then
            local f4_local5 = f4_arg0:GetDist_Point(POINT_INITIAL)
            if f4_local1 <= f4_local3 or f4_local0 <= f4_local2 then
                if f4_local5 <= 1 then
                    f4_arg1:ClearSubGoal()
                    f4_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, f4_local4, TARGET_ENE_0, 999, TARGET_ENE_0, true, -1)
                    return true
                else
                    f4_arg1:ClearSubGoal()
                    f4_arg1:AddSubGoal(GOAL_COMMON_BackToHome_With_Parry, f4_local4):SetTargetRange(COMMON_OBSERVE_SLOT_FINISH_BACKHOME, f4_local0, 999)
                    return true
                end
            end
        end
    end
    if f4_arg0:IsInterupt(INTERUPT_TargetOutOfRange) and f4_arg0:IsTargetOutOfRangeInterruptSlot(COMMON_OBSERVE_SLOT_FINISH_BACKHOME) then
        f4_arg0:Replanning()
        return true
    end
    if f4_arg0:IsInterupt(INTERUPT_WanderedOffPathRepath) then
        f4_arg1:ClearSubGoal()
        f4_arg1:AddSubGoal(GOAL_COMMON_Wait, 0.1, TARGET_SELF, 0, 0, 0)
        return true
    end
    return false
    
end

function TopGoal_Update(f5_arg0, f5_arg1)
    return GOAL_RESULT_Continue
    
end


