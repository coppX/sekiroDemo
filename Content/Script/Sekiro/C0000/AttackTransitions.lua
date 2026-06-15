local Constants = require("Sekiro.C0000.Constants")
local MovementAnimEvents = require("Sekiro.C0000.MovementAnimEvents")

local M = {}

M.GroundAttackInputTransitions = {
    [Constants.ACTION_STATE_GROUND_ATTACK_COMBO_1] = {
        GroundAttackRelease = {
            spec = "GroundAttackCombo1Release",
            behavior_ref_gate = Constants.SP_EF_REF_TAE_GROUND_RELEASE_ATTACK_CANCEL,
        },
    },
    [Constants.ACTION_STATE_GROUND_ATTACK_COMBO_1_RELEASE] = {
        GroundAttack = {
            spec = "GroundAttackCombo2",
            cancel_event_gate = MovementAnimEvents.EVENT_ANIM_CANCEL_END_R1_LIGHT_KICK,
            min_elapsed = 0.5,
            max_elapsed = 1.1,
        },
    },
    [Constants.ACTION_STATE_GROUND_ATTACK_COMBO_1_REVERSE] = {
        GroundAttack = {
            spec = "GroundAttackCombo1Reverse",
            cancel_event_gate = MovementAnimEvents.EVENT_ANIM_CANCEL_END_R1_LIGHT_KICK,
            min_elapsed = 0.0,
            max_elapsed = 1.5,
        },
        GroundAttackRelease = {
            spec = "GroundAttackCombo1ReverseRelease",
            behavior_ref_gate = Constants.SP_EF_REF_TAE_GROUND_RELEASE_ATTACK_CANCEL,
        },
    },
    [Constants.ACTION_STATE_GROUND_ATTACK_COMBO_1_REVERSE_RELEASE] = {
        GroundAttack = {
            spec = "GroundAttackCombo2",
            cancel_event_gate = MovementAnimEvents.EVENT_ANIM_CANCEL_END_R1_LIGHT_KICK,
            min_elapsed = 0.5,
            max_elapsed = 1.1,
        },
    },
    [Constants.ACTION_STATE_GROUND_ATTACK_COMBO_2] = {
        GroundAttackRelease = {
            spec = "GroundAttackCombo2Release",
            behavior_ref_gate = Constants.SP_EF_REF_TAE_GROUND_RELEASE_ATTACK_CANCEL,
        },
    },
    [Constants.ACTION_STATE_GROUND_ATTACK_COMBO_2_RELEASE] = {
        GroundAttack = {
            spec = "GroundAttackCombo3",
            behavior_ref_gate = Constants.SP_EF_REF_TAE_TRANSITION_GROUND_ATTACK_COMBO_3,
            cancel_event_gate = MovementAnimEvents.EVENT_ANIM_CANCEL_END_R1_LIGHT_KICK,
            min_elapsed = 0.3,
            max_elapsed = 1.1,
        },
    },
    [Constants.ACTION_STATE_GROUND_ATTACK_COMBO_2_REVERSE] = {
        GroundAttackRelease = {
            spec = "GroundAttackCombo2ReverseRelease",
            behavior_ref_gate = Constants.SP_EF_REF_TAE_GROUND_RELEASE_ATTACK_CANCEL,
        },
    },
    [Constants.ACTION_STATE_GROUND_ATTACK_COMBO_2_REVERSE_RELEASE] = {
        GroundAttack = {
            spec = "GroundAttackCombo3",
            behavior_ref_gate = Constants.SP_EF_REF_TAE_TRANSITION_GROUND_ATTACK_COMBO_3,
            cancel_event_gate = MovementAnimEvents.EVENT_ANIM_CANCEL_END_R1_LIGHT_KICK,
            min_elapsed = 0.4,
            max_elapsed = 1.3,
        },
    },
    [Constants.ACTION_STATE_GROUND_ATTACK_COMBO_3] = {
        GroundAttack = {
            spec = "GroundAttackCombo4",
            cancel_event_gate = MovementAnimEvents.EVENT_ANIM_CANCEL_END_R1_LIGHT_KICK,
            min_elapsed = 0.7,
            max_elapsed = 1.3,
        },
    },
    [Constants.ACTION_STATE_GROUND_ATTACK_COMBO_4] = {
        GroundAttack = {
            spec = "GroundAttackCombo5",
            cancel_event_gate = MovementAnimEvents.EVENT_ANIM_CANCEL_END_R1_LIGHT_KICK,
            min_elapsed = 0.5,
            max_elapsed = 1.5,
        },
    },
    [Constants.ACTION_STATE_GROUND_ATTACK_COMBO_5] = {
        GroundAttack = {
            spec = "GroundAttackCombo1",
            cancel_event_gate = MovementAnimEvents.EVENT_ANIM_CANCEL_END_R1_LIGHT_KICK,
            min_elapsed = 0.5,
            max_elapsed = 1.8,
        },
    },
}

_G.GroundAttackInputTransitions = M.GroundAttackInputTransitions

return M
