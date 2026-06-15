local Constants = require("Sekiro.C0000.Constants")
require("Sekiro.C0000.AnimRuntime")
local KismetSystemLibrary = UE.UKismetSystemLibrary
local M = {}

function M.print_overlay_line(self, line_index, message, color)
    KismetSystemLibrary.PrintString(
        self,
        "[SekiroFSM] " .. message,
        true,
        false,
        color or UE.FLinearColor(0.76, 0.90, 1.0, 1.0),
        0.20,
        string.format("SekiroFSMOverlay_%02d", line_index)
    )
end

function M.get_display_state_name(layer)
    if not layer then
        return "nil"
    end
    if layer.state == Constants.ADD_STATE_NONE and layer.state_name then
        return layer.state_name
    end
    return StateNames[layer.state] or layer.state_name or tostring(layer.state)
end

function M.get_active_movement_event_summary(runtime)
    local events = get_movement_event_runtime(runtime)
    local names = {}
    for event_name, count in pairs(events.active_counts) do
        if resolve_number(count, 0) > 0 then
            names[#names + 1] = event_name
        end
    end
    table.sort(names)
    if #names == 0 then
        return "-"
    end
    return table.concat(names, ",")
end

function M.render_debug_overlay(self, context)
    local runtime = ensure_runtime(self)
    local layer = get_layer_runtime(runtime, Constants.LAYER_BASE)
    local action_layer = get_layer_runtime(runtime, Constants.LAYER_ACTION)
    local reaction_layer = get_layer_runtime(runtime, Constants.LAYER_REACTION)
    local state_machine = get_state_machine(self)
    local native_elapsed = 0.0
    if state_machine and state_machine.GetLayerStateElapsedSeconds then
        native_elapsed = resolve_number(state_machine:GetLayerStateElapsedSeconds(Constants.LAYER_BASE), 0.0)
    end
    local anim_state_id = resolve_number(get_anim_state_id(layer), 0)

    print_overlay_line(
        self,
        1,
        string.format(
            "Input f=%d r=%d sprint=%d wants=%d",
            context.forward,
            context.right,
            context.sprint and 1 or 0,
            context.wants_move and 1 or 0
        ),
        UE.FLinearColor(0.72, 0.96, 0.78, 1.0)
    )
    print_overlay_line(
        self,
        2,
        string.format(
            "Layer=Base State=%s Event=%s",
            StateNames[layer.state] or tostring(layer.state),
            layer.event or "nil"
        )
    )
    print_overlay_line(
        self,
        3,
        string.format(
            "Dir=%s AnimId=%d LuaElapsed=%.2f NativeElapsed=%.2f",
            DirectionNames[layer.direction] or tostring(layer.direction),
            anim_state_id,
            layer.elapsed or 0.0,
            native_elapsed
        )
    )
    print_overlay_line(
        self,
        4,
        string.format(
            "Anim speed raw=%.2f real=%.2f idx=%d rate=%.2f",
            runtime.anim.move_speed_level or 0.0,
            runtime.anim.move_speed_level_real or 0.0,
            runtime.anim.move_speed_index or Constants.MOVE_SPEED_INDEX_WALK,
            runtime.anim.move_loop_play_rate or 1.0
        ),
        UE.FLinearColor(0.96, 0.92, 0.62, 1.0)
    )
    print_overlay_line(
        self,
        5,
        string.format(
            "Action=%s %.2f Reaction=%s %.2f",
            get_display_state_name(action_layer),
            action_layer.elapsed or 0.0,
            get_display_state_name(reaction_layer),
            reaction_layer.elapsed or 0.0
        ),
        UE.FLinearColor(1.0, 0.72, 0.72, 1.0)
    )
    print_overlay_line(
        self,
        6,
        string.format(
            "HSpeed=%.1f Target=%.1f",
            self.GetHorizontalSpeed and self:GetHorizontalSpeed() or 0.0,
            runtime.anim.target_move_speed or 0.0
        ),
        UE.FLinearColor(0.82, 0.88, 1.0, 1.0)
    )
    print_overlay_line(
        self,
        7,
        string.format(
            "Angles move=%.1f turn=%.1f twist=%.1f",
            context.move_angle or 0.0,
            context.turn_angle or 0.0,
            context.twist_angle or 0.0
        ),
        UE.FLinearColor(0.86, 0.78, 1.0, 1.0)
    )
    print_overlay_line(
        self,
        8,
        string.format(
            "Turn active=%d src=%s event=%s yaw=%.1f",
            runtime.turn.active and 1 or 0,
            runtime.turn.source or "",
            runtime.turn.event_key or "",
            runtime.turn.applied_yaw_delta or 0.0
        ),
        UE.FLinearColor(0.86, 0.78, 1.0, 1.0)
    )
    print_overlay_line(
        self,
        9,
        string.format(
            "LocomotionAsset=%s DrawBlend=%.2f",
            GetLocomotionAnimAssetName(runtime, layer),
            GetLocomotionWeaponBlend(runtime)
        ),
        UE.FLinearColor(0.72, 1.0, 0.82, 1.0)
    )
    print_overlay_line(
        self,
        10,
        "AnimEvents=" .. get_active_movement_event_summary(runtime),
        UE.FLinearColor(0.72, 1.0, 0.82, 1.0)
    )
end

function M.print_runtime(self, message)
    local text = "[SekiroFSM] " .. tostring(message)
    KismetSystemLibrary.PrintString(
        self,
        text,
        true,
        true,
        UE.FLinearColor(0.92, 0.78, 0.34, 1.0),
        1.2,
        ""
    )
    if UnLua and UnLua.Log then
        UnLua.Log(text)
    end
end

_G.print_overlay_line = M.print_overlay_line
_G.get_display_state_name = M.get_display_state_name
_G.get_active_movement_event_summary = M.get_active_movement_event_summary
_G.render_debug_overlay = M.render_debug_overlay
_G.print_runtime = M.print_runtime

return M
