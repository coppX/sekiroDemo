# Sekiro C0000 UE 动画状态机逻辑图

这份文档描述的是当前 `E:\UEProj\Sekiro\SekiroDemo` 工程里的 UE 预览实现，不是只狼原版 Havok 状态机本体。

## 总体机制

- 输入或调试事件先进入 `ASekiroC0000PreviewCharacter`
- C++ 把 Tick 和事件转发到 `PreviewCharacter.lua`
- Lua 不直接切 AnimGraph 状态，而是写 AnimBP 实例变量
- AnimBP transition rules 读取这些变量后，才真正进入目标状态

关键文件：

- `E:\UEProj\Sekiro\SekiroDemo\Source\SekiroDemo\SekiroC0000PreviewCharacter.cpp`
- `E:\UEProj\Sekiro\SekiroDemo\Content\Script\Sekiro\C0000\PreviewCharacter.lua`
- `E:\UEProj\Sekiro\SekiroDemo\Content\Script\Sekiro\C0000\EventSpecs.lua`
- `E:\UEProj\Sekiro\SekiroDemo\Saved\SekiroImportReports\c0000_master_animbp_mapping.json`
- `E:\UEProj\Sekiro\SekiroDemo\Saved\SekiroImportReports\c0000_transition_effect_tuning_report.json`

## 总流程图

```mermaid
flowchart TD
    A["WASD / Shift 或 TriggerPreviewSekiroEvent(EventName)"] --> B["C++ 预览角色"]
    B --> C["UpdatePreviewInputStateFromController()"]
    B --> D["StepPreviewRuntime(DeltaSeconds)"]
    B --> E["TriggerPreviewSekiroEvent(EventName)"]

    D --> F["Lua ReceiveTick(delta_seconds)"]
    E --> G["Lua TriggerSekiroEvent(event_name)"]

    F --> H["sync_polled_input()"]
    F --> I["apply_movement_input()"]
    F --> J["update_runtime_variables()"]
    F --> K["flush_pending_pulses()"]

    G --> L["try_trigger_event()"]
    J --> L

    L --> M{"事件类型"}
    M -->|StandMovePulseEvents| N["写 Req_* / Return_*"]
    M -->|PulseOnlyEvents| O["写循环/同步脉冲"]
    M -->|ActionIdleEvents| P["Req_W_Attack3049 + StateStateId_StandMoveableAction"]
    M -->|ActionMoveEvents| Q["Req_W_ChargeShotRightEnd + StateStateId_StandMoveableAction"]
    M -->|OverwriteLowerEvents| R["写 Lower Overwrite 请求"]

    J --> S["持续写入 MoveType / StanceMoveType / MoveSpeedIndex / MoveDirection / Selector_* / StartTime_*"]
    N --> K
    O --> K
    P --> K
    Q --> K
    R --> K

    K --> T["AnimBP 实例变量"]
    S --> T
    T --> U["AnimBP Transition Rules"]
    U --> V["Sekiro_MasterSubset_SM"]
    V --> W["StandMove_SM / StandMoveableAction_SM / StandMoveUpper_SM / StandMoveLower_SM"]
```

## 顶层状态机

顶层主状态机是 `Sekiro_MasterSubset_SM`，入口状态是 `StandMove`。

```mermaid
flowchart LR
    A[StandMove]
    B[StandMoveableAction]
    C[StandMoveOverwrite]

    A -->|"Req_W_Attack3050 或 Req_W_Attack3049"| B
    B -->|"Return_To_StandMove"| A

    A -->|"Req_W_Attack3052 或 Req_W_ChargeShotRightEnd"| C
    C -->|"Return_To_StandMove"| A

    B -->|"Req_W_ChargeShotRightEnd"| C
    C -->|"Return_To_StandMoveableAction_Idle"| B
```

对应关系：

- `StandMove -> StandMoveableAction`
  由 `Req_W_Attack3050` 或 `Req_W_Attack3049` 触发
- `StandMoveableAction -> StandMove`
  由 `Return_To_StandMove` 触发
- `StandMove -> StandMoveOverwrite`
  由 `Req_W_Attack3052` 或 `Req_W_ChargeShotRightEnd` 触发
- `StandMoveOverwrite -> StandMove`
  由 `Return_To_StandMove` 触发
- `StandMoveOverwrite -> StandMoveableAction`
  由 `Return_To_StandMoveableAction_Idle` 触发

## StandMove_SM 移动主干

`StandMove_SM` 是 `StandMove` 下面的子状态机，入口状态是 `StandMoveLoop`。

```mermaid
flowchart LR
    L0[StandMoveLoop]
    L1[StandMoveStart]
    L2[StandWalkStop]
    L3[StandRunStop]
    L4[StandQuickTurnRight180]
    L5[StandQuickTurnLeft180]
    L6[StandMoveStartFromSprint]
    L7[StandMoveLoopFromSprint]

    L0 -->|"Req_W_Event3018"| L1
    L1 -->|"Req_W_Event3019"| L0

    L0 -->|"Req_W_Event3026"| L2
    L0 -->|"Req_W_Event3027"| L3
    L0 -->|"Req_W_Event3028"| L4
    L0 -->|"Req_W_Event3029"| L5

    L0 -->|"Req_W_WideshotRightStart_mirror"| L6
    L6 -->|"Req_a000_00000000_End"| L7

    L2 -->|"Return_To_StandMove"| L0
    L3 -->|"Return_To_StandMove"| L0
    L4 -->|"Return_To_StandMove"| L0
    L5 -->|"Return_To_StandMove"| L0
```

Lua 在 `update_runtime_variables()` 里大致按这个顺序决定触发什么事件：

```mermaid
flowchart TD
    A["读取输入和速度"] --> B{"当前是否刚开始移动"}
    B -->|是| C["W_StandMoveLoop 或 W_StandMoveStart"]
    B -->|否| D{"是否从 Sprint 退出"}

    D -->|是| E["W_StandMoveStartFromSprint / W_StandRunStop / W_StandWalkStop"]
    D -->|否| F{"是否从移动切回静止"}

    F -->|是| G["W_StandRunStop / W_StandWalkStop / QuickTurn"]
    F -->|否| H{"是否移动中发生方向/速度变化"}

    H -->|是| I["W_StandMoveLoopSync 或 Move QuickTurn"]
    H -->|否| J["维持当前循环"]
```

## 动作状态机选态

这部分最关键的点是：

- `StandMoveableAction_SM` 入口是 `StandMoveableActionIdle`
- `StandMoveUpper_SM` 入口是 `StandMoveUpperIdle`
- 它们跳去哪个具体动作，不是靠一堆 `Req_*` bool 分别控制
- 而是靠 `StateStateId_StandMoveableAction == 某个整数`

```mermaid
flowchart TD
    A["Lua 触发 Idle 动作事件"] --> B["Req_W_Attack3049"]
    A --> C["StateStateId_StandMoveableAction = N"]
    B --> D["顶层进入 StandMoveableAction"]
    C --> E["StandMoveableActionIdle 根据 state_id 选具体状态"]
    E --> F["ItemPillTonic / DeflectGuardToStand / SubWeaponExpand ..."]
    F --> G["到时后发 Return_To_StandMoveableAction_Idle"]
    G --> H["再发 Return_To_StandMove"]
```

```mermaid
flowchart TD
    A["Lua 触发 Move 动作事件"] --> B["Req_W_ChargeShotRightEnd"]
    A --> C["StateStateId_StandMoveableAction = N"]
    B --> D["顶层进入 StandMoveOverwrite"]
    C --> E["StandMoveUpperIdle 根据 state_id 选具体状态"]
    E --> F["ItemPillTonicMove / DeflectGuardToStandMove / SubWeaponExpandMove ..."]
    F --> G["到时后发 Return_To_StandMove"]
```

常见例子：

- `state_id = 0`
  对应 `ItemPillTonic` 或 `ItemPillTonicMove`
- `state_id = 120`
  对应 `DeflectGuardToStand` 或 `DeflectGuardToStandMove`
- `state_id = 133`
  对应 `SubWeaponExpand` 或 `SubWeaponExpandMove`

## 变量职责拆分

### 1. 真正决定切到哪个状态的变量

- `Req_*`
- `Return_*`
- `StateStateId_StandMoveableAction`

### 2. 主要负责过渡样式和运动参数的变量

- `Selector_UseTransitionEffect`
- `Selector_UseStaterToStateTransitionEffect`
- `StartTime_01`
- `StartTime_02`
- `StartTime_03`
- `MoveType`
- `StanceMoveType`
- `MoveSpeedIndex`
- `MoveSpeedLevel`
- `MoveDirection`
- `MoveAngle`
- `TurnAngle`

## 具体事件例子

### 例 1：`W_ItemPillTonic`

```mermaid
sequenceDiagram
    participant Input as 输入/调试事件
    participant Lua as PreviewCharacter.lua
    participant AnimBP as ABP_Sekiro_C0000_Master

    Input->>Lua: W_ItemPillTonic
    Lua->>Lua: queue Req_W_Attack3049
    Lua->>AnimBP: StateStateId_StandMoveableAction = 0
    AnimBP->>AnimBP: StandMove -> StandMoveableAction
    AnimBP->>AnimBP: StandMoveableActionIdle -> ItemPillTonic
    Lua->>Lua: 定时发 Return_To_StandMoveableAction_Idle
    Lua->>Lua: 定时发 Return_To_StandMove
    AnimBP->>AnimBP: 回到 StandMove
```

### 例 2：`W_ItemPillTonicMove`

```mermaid
sequenceDiagram
    participant Input as 输入/调试事件
    participant Lua as PreviewCharacter.lua
    participant AnimBP as ABP_Sekiro_C0000_Master

    Input->>Lua: W_ItemPillTonicMove
    Lua->>Lua: queue Req_W_ChargeShotRightEnd
    Lua->>AnimBP: StateStateId_StandMoveableAction = 0
    AnimBP->>AnimBP: StandMove -> StandMoveOverwrite
    AnimBP->>AnimBP: StandMoveUpperIdle -> ItemPillTonicMove
    Lua->>Lua: 到时后发 Return_To_StandMove
    AnimBP->>AnimBP: 回到 StandMove
```

## 当前实现的一个重要特点

当前 Lua 默认：

- `enable_move_loop_transition = true`
- `enable_state_to_state_transition = true`
- `enable_sprint_action = true`
- `enable_item_use_move = true`
- `enable_direct_locomotion_preview = false`

因此当前预览实现里：

- 静止开始移动时，常常直接走 `W_StandMoveLoop`
- 不是每次都先走 `W_StandMoveStart`
- 移动中的速度档或方向切换，会用 `W_StandMoveLoopSync`
- 动作族切换时，`state_id` 负责“选哪个动作”，`Req_* / Return_*` 负责“什么时候进/什么时候退”


