local M = {}

M.AliasToEventKey = {
    W_StandMoveStart = "BaseMoveStart",
    W_StandMoveLoop = "BaseMoveLoop",
    W_StandMoveLoopSync = "BaseMoveLoop",
    W_StandMoveLoopFromSprint = "BaseMoveLoop",
    W_StandWalkStop = "BaseMoveStop",
    W_StandRunStop = "BaseMoveStop",
    W_StandQuickTurnLeft90 = "BaseQuickTurnLeft90",
    W_StandQuickTurnRight90 = "BaseQuickTurnRight90",
    W_StandQuickTurnLeft180 = "BaseQuickTurnLeft180",
    W_StandQuickTurnRight180 = "BaseQuickTurnRight180",
    W_StandQuickTurnMoveStartLeft180 = "BaseQuickTurnMoveStartLeft180",
    W_StandQuickTurnMoveStartRight180 = "BaseQuickTurnMoveStartRight180",
    W_StandMoveQuickTurnLeft180 = "BaseMoveQuickTurnLeft180",
    W_StandMoveQuickTurnRight180 = "BaseMoveQuickTurnRight180",
}

function M.build_event_to_key(events)
    local event_to_key = {}
    for event_name, event_key in pairs(M.AliasToEventKey) do
        event_to_key[event_name] = event_key
    end
    for event_key, spec in pairs(events or {}) do
        event_to_key[event_key] = event_key
        if spec.event and spec.event ~= "" and event_to_key[spec.event] == nil then
            event_to_key[spec.event] = event_key
        end
    end
    return event_to_key
end

return M
