local Constants = require("Sekiro.C0000.Constants")
local M = {}

M.StateNames = {
    [Constants.BASE_STATE_IDLE] = "Idle",
    [Constants.BASE_STATE_MOVE_START] = "MoveStart",
    [Constants.BASE_STATE_MOVE_LOOP] = "MoveLoop",
    [Constants.BASE_STATE_MOVE_STOP] = "MoveStop",
    [Constants.BASE_STATE_QUICK_TURN_90] = "QuickTurn90",
    [Constants.BASE_STATE_QUICK_TURN_180] = "QuickTurn180",
    [Constants.BASE_STATE_QUICK_TURN_MOVE_START_180] = "QuickTurnMoveStart180",
    [Constants.BASE_STATE_MOVE_QUICK_TURN_180] = "MoveQuickTurn180",
    [Constants.ACTION_STATE_ITEM_GOURD_DRINK] = "ActionItemGourdDrink",
    [Constants.ACTION_STATE_ITEM_GOURD_DRINK_MOVE] = "ActionItemGourdDrinkMove",
    [Constants.ACTION_STATE_SUB_WEAPON_EXPAND] = "ActionSubWeaponExpand",
    [Constants.ACTION_STATE_SUB_WEAPON_EXPAND_MOVE] = "ActionSubWeaponExpandMove",
    [Constants.ACTION_STATE_LEFT_WAIST_DRAW] = "ActionLeftWaistDraw",
    [Constants.ACTION_STATE_LEFT_WAIST_DRAW_MOVE] = "ActionLeftWaistDrawMove",
    [Constants.ACTION_STATE_LEFT_WAIST_SHEATHE] = "ActionLeftWaistSheathe",
    [Constants.ACTION_STATE_LEFT_WAIST_SHEATHE_MOVE] = "ActionLeftWaistSheatheMove",
    [Constants.ACTION_STATE_DEFLECT_GUARD_IDLE] = "DeflectGuardIdle",
    [Constants.ACTION_STATE_DEFLECT_GUARD_MOVE_FORWARD] = "DeflectGuardMoveForward",
    [Constants.ACTION_STATE_DEFLECT_GUARD_MOVE_BACK] = "DeflectGuardMoveBack",
    [Constants.ACTION_STATE_DEFLECT_GUARD_MOVE_LEFT] = "DeflectGuardMoveLeft",
    [Constants.ACTION_STATE_DEFLECT_GUARD_MOVE_RIGHT] = "DeflectGuardMoveRight",
    [Constants.ACTION_STATE_DEFLECT_GUARD_TO_STAND] = "DeflectGuardToStand",
    [Constants.REACTION_STATE_DEFLECT_GUARD] = "ReactionDeflectGuard",
    [Constants.REACTION_STATE_DEFLECT_GUARD_MOVE] = "ReactionDeflectGuardMove",
}

M.LayerNames = {
    [Constants.LAYER_BASE] = "Base",
    [Constants.LAYER_ACTION] = "Action",
    [Constants.LAYER_REACTION] = "Reaction",
}

M.DirectionNames = {
    [Constants.MOVE_DIRECTION_NONE] = "None",
    [Constants.MOVE_DIRECTION_FORWARD] = "Forward",
    [Constants.MOVE_DIRECTION_BACK] = "Back",
    [Constants.MOVE_DIRECTION_LEFT] = "Left",
    [Constants.MOVE_DIRECTION_RIGHT] = "Right",
    [Constants.MOVE_DIRECTION_FORWARD_LEFT] = "ForwardLeft",
    [Constants.MOVE_DIRECTION_FORWARD_RIGHT] = "ForwardRight",
    [Constants.MOVE_DIRECTION_BACK_LEFT] = "BackLeft",
    [Constants.MOVE_DIRECTION_BACK_RIGHT] = "BackRight",
}

M.DirectionAngles = {
    [Constants.MOVE_DIRECTION_FORWARD] = 0.0,
    [Constants.MOVE_DIRECTION_BACK] = 180.0,
    [Constants.MOVE_DIRECTION_LEFT] = -90.0,
    [Constants.MOVE_DIRECTION_RIGHT] = 90.0,
    [Constants.MOVE_DIRECTION_FORWARD_LEFT] = -45.0,
    [Constants.MOVE_DIRECTION_FORWARD_RIGHT] = 45.0,
    [Constants.MOVE_DIRECTION_BACK_LEFT] = -135.0,
    [Constants.MOVE_DIRECTION_BACK_RIGHT] = 135.0,
}

M.DirectionStateOffsets = {
    [Constants.MOVE_DIRECTION_FORWARD] = 0,
    [Constants.MOVE_DIRECTION_BACK] = 1,
    [Constants.MOVE_DIRECTION_LEFT] = 2,
    [Constants.MOVE_DIRECTION_RIGHT] = 3,
    [Constants.MOVE_DIRECTION_FORWARD_LEFT] = 2,
    [Constants.MOVE_DIRECTION_FORWARD_RIGHT] = 3,
    [Constants.MOVE_DIRECTION_BACK_LEFT] = 2,
    [Constants.MOVE_DIRECTION_BACK_RIGHT] = 3,
}

M.MoveStartSelectorAngles = {
    [0] = 0.0,
    [1] = 180.0,
    [2] = -90.0,
    [3] = 90.0,
}

M.LayerDefaults = {
    [Constants.LAYER_BASE] = {
        state = Constants.BASE_STATE_IDLE,
        previous_state = Constants.BASE_STATE_IDLE,
        direction = Constants.MOVE_DIRECTION_NONE,
        event = "W_BaseIdle",
        state_name = "Idle",
    },
    [Constants.LAYER_ACTION] = {
        state = Constants.ACTION_STATE_IDLE,
        previous_state = Constants.ACTION_STATE_IDLE,
        direction = Constants.MOVE_DIRECTION_NONE,
        event = "ActionIdle",
        state_name = "ActionIdle",
    },
    [Constants.LAYER_REACTION] = {
        state = Constants.REACTION_STATE_IDLE,
        previous_state = Constants.REACTION_STATE_IDLE,
        direction = Constants.MOVE_DIRECTION_NONE,
        event = "ReactionIdle",
        state_name = "ReactionIdle",
    },
}

M.ActionEventVariants = {
    ActionItemGourdDrink = {
        idle = "ActionItemGourdDrinkIdle",
        move = "ActionItemGourdDrinkMove",
    },
    ActionSubWeaponExpand = {
        idle = "ActionSubWeaponExpandIdle",
        move = "ActionSubWeaponExpandMove",
    },
    ActionLeftWaistDraw = {
        idle = "ActionLeftWaistDrawIdle",
        move = "ActionLeftWaistDrawMove",
        force_idle = true,
    },
    ActionLeftWaistSheathe = {
        idle = "ActionLeftWaistSheatheIdle",
        move = "ActionLeftWaistSheatheMove",
        force_idle = true,
    },
    GroundAttack = {
        idle = "GroundAttackCombo1",
        move = "GroundAttackCombo1",
    },
    DeflectGuard = {
        idle = "DeflectGuardIdle",
        move = "DeflectGuardMoveForward",
    },
    DeflectGuardRelease = {
        idle = "DeflectGuardToStand",
        move = "DeflectGuardToStand",
    },
}

M.ReactionEventVariants = {
    ReactionDeflectGuard = {
        idle = "ReactionDeflectGuardIdle",
        move = "ReactionDeflectGuardMove",
    },
}
_G.StateNames = M.StateNames
_G.LayerNames = M.LayerNames
_G.DirectionNames = M.DirectionNames
_G.DirectionAngles = M.DirectionAngles
_G.DirectionStateOffsets = M.DirectionStateOffsets
_G.MoveStartSelectorAngles = M.MoveStartSelectorAngles
_G.ActionEventVariants = M.ActionEventVariants
_G.ReactionEventVariants = M.ReactionEventVariants
_G.LayerDefaults = M.LayerDefaults

return M
