local M = {}

M.TARGET_SELF = "TARGET_SELF"
M.TARGET_ENE_0 = "TARGET_ENE_0"
M.TARGET_LOCALPLAYER = "TARGET_LOCALPLAYER"

M.AI_DIR_TYPE_F = "AI_DIR_TYPE_F"
M.AI_DIR_TYPE_B = "AI_DIR_TYPE_B"
M.AI_DIR_TYPE_L = "AI_DIR_TYPE_L"
M.AI_DIR_TYPE_R = "AI_DIR_TYPE_R"

M.GOAL_COMMON_Wait = "GOAL_COMMON_Wait"
M.GOAL_COMMON_Turn = "GOAL_COMMON_Turn"
M.GOAL_COMMON_ApproachTarget = "GOAL_COMMON_ApproachTarget"
M.GOAL_COMMON_LeaveTarget = "GOAL_COMMON_LeaveTarget"
M.GOAL_COMMON_SidewayMove = "GOAL_COMMON_SidewayMove"
M.GOAL_COMMON_AttackTunableSpin = "GOAL_COMMON_AttackTunableSpin"
M.GOAL_COMMON_ComboAttackTunableSpin = "GOAL_COMMON_ComboAttackTunableSpin"
M.GOAL_COMMON_ComboFinal = "GOAL_COMMON_ComboFinal"
M.GOAL_COMMON_Attack = "GOAL_COMMON_Attack"
M.GOAL_COMMON_ComboAttack = "GOAL_COMMON_ComboAttack"
M.GOAL_COMMON_ComboRepeat = "GOAL_COMMON_ComboRepeat"
M.GOAL_COMMON_SpinStep = "GOAL_COMMON_SpinStep"
M.GOAL_COMMON_Guard = "GOAL_COMMON_Guard"
M.GOAL_COMMON_EndureAttack = "GOAL_COMMON_EndureAttack"

function M.Snapshot(ai)
    return {
        dist = ai:GetDist(M.TARGET_ENE_0),
        hp_rate = ai:GetHpRate(M.TARGET_SELF),
        has_target = ai:HasBattleTarget(),
        can_see_target = ai:HasLineOfSightToTarget(),
        is_battle = ai:IsBattleState(),
        is_find = ai:IsFindState(),
        is_caution = ai:IsCautionState(),
        is_dead = ai:IsDead(),
    }
end

return M
