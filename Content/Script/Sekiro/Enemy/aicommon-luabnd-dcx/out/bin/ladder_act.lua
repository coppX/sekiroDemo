REGISTER_GOAL_NO_SUB_GOAL(GOAL_COMMON_LadderAct, true)

function _GetId(f1_arg0, f1_arg1)
    local f1_local0 = false
    if f1_arg1:IsNpcPlayer() or f1_arg1:IsLocalPlayer() then
        f1_local0 = true
    end
    local f1_local1 = f1_arg0
    if f1_local0 == true then
        if f1_arg0 == 7210 then
            f1_local1 = NPC_ATK_Ladder_10
        elseif f1_arg0 == 7211 then
            f1_local1 = NPC_ATK_Ladder_11
        elseif f1_arg0 == 7212 then
            f1_local1 = NPC_ATK_Ladder_12
        elseif f1_arg0 == 7213 then
            f1_local1 = NPC_ATK_Ladder_13
        elseif f1_arg0 == 7220 then
            f1_local1 = NPC_ATK_Ladder_20
        elseif f1_arg0 == 7221 then
            f1_local1 = NPC_ATK_Ladder_21
        elseif f1_arg0 == 7222 then
            f1_local1 = NPC_ATK_Ladder_22
        elseif f1_arg0 == 7223 then
            f1_local1 = NPC_ATK_Ladder_23
        end
    end
    return f1_local1
    
end

local f0_local0 = -1
local f0_local1 = 0
local f0_local2 = 1
local f0_local3 = 2
local f0_local4 = 3
local f0_local5 = 4
local f0_local6 = 5
local f0_local7 = 6
local f0_local8 = 7
local f0_local9 = 8
local f0_local10 = 9
local f0_local11 = 23
local f0_local12 = 7210
local f0_local13 = 7220
local f0_local14 = 7230

function LadderAct_Activate(f2_arg0, f2_arg1)
    local f2_local0 = f2_arg1:GetParam(0)
    local f2_local1 = f2_arg1:GetParam(1)
    local f2_local2 = f2_arg1:GetParam(2)
    local f2_local3 = f2_local2
    local f2_local4 = f2_arg0:GetLadderActState(TARGET_SELF)
    local f2_local5 = 0
    local f2_local6 = f2_arg0:CalcGetNearestLadderActDmyIdByLadderObj()
    if f2_local6 == 191 then
        f2_local5 = _GetId(7210, f2_arg0)
    else
        f2_local5 = _GetId(7220, f2_arg0)
    end
    if f2_local4 == f0_local0 then
        if f2_arg0:IsChrAroundLadderEdge(2, f2_local6) == false then
            f2_arg0:SetPosAngBy1stNearObjDmyId(f2_local6)
            f2_arg0:SetAttackRequest(f2_local5)
        elseif f2_local6 == 192 then
        elseif f2_local6 == 191 then
            return GOAL_RESULT_Failed
        else
        end
    end
    f2_arg0:OnStartLadderGoal()
    
end

function LadderAct_Update(f3_arg0, f3_arg1)
    local f3_local0 = f3_arg1:GetParam(0)
    local f3_local1 = f3_arg1:GetParam(1)
    if f3_arg0:LastPathFindingIsFailed() == false and f3_arg0:HasPathResult() == false then
        f3_arg0:FollowPath(f3_local1, AI_DIR_TYPE_CENTER, 1.5, true, 0)
    end
    f3_arg0:OnUpdateLadderGoal()
    local f3_local2 = f3_arg0:GetLadderDirMove(TARGET_ENE_0)
    f3_arg0:DoEzAction(0, -1)
    local f3_local3 = f3_arg0:GetLadderActState(TARGET_SELF)
    local f3_local4 = false
    if f3_local3 == f0_local9 or f3_local3 == f0_local10 then
        f3_local4 = true
    elseif f3_arg0:IsFinishAttack() or f3_arg0:IsEnableComboAttack() then
        f3_local4 = true
    end
    if f3_local4 then
        if f3_local3 == f0_local0 then
            return GOAL_RESULT_Success
        elseif f3_local2 == 0 then
        elseif f3_local2 == 1 then
            f3_arg0:SetAttackRequest(_GetId(f0_local12, f3_arg0))
        elseif f3_local2 == -1 then
            f3_arg0:SetAttackRequest(_GetId(f0_local13, f3_arg0))
        end
    end
    f3_arg1:AddLifeParentSubGoal(0.3)
    local f3_local5 = f3_arg0:GetLadderActState(TARGET_SELF)
    if f3_arg0:CanLadderGoalEnd() then
        return GOAL_RESULT_Success
    elseif f3_local5 == f0_local11 then
        return GOAL_RESULT_Failed
    end
    f3_local5 = GOAL_RESULT_Continue
    return f3_local5
    
end

function LadderAct_Terminate(f4_arg0, f4_arg1)
    f4_arg0:OnEndLadderGoal()
    
end

REGISTER_GOAL_NO_INTERUPT(GOAL_COMMON_LadderAct, true)

function LadderAct_Interupt(f5_arg0, f5_arg1)
    if f5_arg0:IsInterupt(INTERUPT_Damaged) then
        return false
    end
    return false
    
end


