# C0000.hkx.xml - StandMove_SM 状态节点与转场条件

生成时间：2026-05-14

## 来源

- HKX XML：`E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE\chr\c0000-behbnd-dcx\Behaviors\C0000.hkx.xml`
- HkbEditor：`E:\SekiroTools\HkbEditor_v0.15.4_win64\HkbEditor_v0.15.4`
- 状态机对象：`object583`
- 状态机名：`StandMove_SM`
- Havok 类型：`hkbStateMachine`
- 起始状态 ID：`0`
- 起始状态：`StandMoveLoop`
- 状态节点数量：`17`
- 转场数量：`27`
- Wildcard 转场数量：`17`
- 状态自身转场数量：`10`

## 读取结论

`StandMove_SM` 内部转场全部是事件驱动。所有转场记录的 `condition` 都是 `object0`，即没有额外的 `hkbExpressionCondition` 或其它条件对象。

因此这里的“转换条件”可以理解为：收到指定 `eventId / eventName` 时进入对应状态。实际什么时候发这些事件，由只狼脚本和 TAE/动画事件控制，例如 `c0000_transition.dec.lua` 中的 `FireEvent(...)` / `FireEventNoReset(...)`。

所有转场的 `triggerInterval` 和 `initiateInterval` 都是默认值：

```text
enterEventId = -1
exitEventId  = -1
enterTime    = 0
exitTime     = 0
```

## 状态节点

| 顺序 | StateId | 状态名 | StateInfo 对象 | Generator 类型 | Generator 名 | 本状态转场数组 |
| ---: | ---: | --- | --- | --- | --- | --- |
| 0 | 0 | `StandMoveLoop` | `object1064` | `hkbLayerGenerator` | `StandMoveLoop LayerGenerator` | `object0` |
| 1 | 1 | `StandMoveStartFromFreeFall` | `object1065` | `hkbLayerGenerator` | `StandMoveStartFromFreeFall LayerGenerator` | `object2198` |
| 2 | 3 | `StandMoveStartFromFreeFallShortStiff` | `object1066` | `hkbLayerGenerator` | `StandMoveStartFromFreeFallShortStiff LayerGenerator` | `object2200` |
| 3 | 4 | `StandMoveStartFromLandGroundPositioningJump` | `object1067` | `hkbLayerGenerator` | `StandMoveStartFromLandGroundPositioningJump LayerGenerator` | `object2202` |
| 4 | 5 | `StandMoveStart` | `object1068` | `hkbLayerGenerator` | `StandMoveStart LayerGenerator` | `object2204` |
| 5 | 7 | `StandWalkStop` | `object1069` | `hkbManualSelectorGenerator` | `StandWalkStop_Selector` | `object0` |
| 6 | 8 | `StandRunStop` | `object1070` | `hkbManualSelectorGenerator` | `StandRunStop_Selector` | `object0` |
| 7 | 9 | `StandQuickTurnLeft180` | `object1071` | `CustomManualSelectorGenerator` | `StandQuickTurnLeft180_CMSG` | `object0` |
| 8 | 10 | `StandQuickTurnRight180` | `object1072` | `CustomManualSelectorGenerator` | `StandQuickTurnRight180_CMSG` | `object0` |
| 9 | 11 | `StandQuickTurnMoveStartLeft180` | `object1073` | `hkbLayerGenerator` | `StandQuickTurnMoveStartLeft180 LayerGenerator` | `object2210` |
| 10 | 12 | `StandQuickTurnMoveStartRight180` | `object1074` | `hkbLayerGenerator` | `StandQuickTurnMoveStartRight180 LayerGenerator` | `object2212` |
| 11 | 13 | `StandMoveQuickTurnLeft180` | `object1075` | `hkbLayerGenerator` | `StandMoveQuickTurnLeft180 LayerGenerator` | `object2214` |
| 12 | 14 | `StandMoveQuickTurnRight180` | `object1076` | `hkbLayerGenerator` | `StandMoveQuickTurnRight180 LayerGenerator` | `object2216` |
| 13 | 15 | `StandQuickTurnLeft90` | `object1077` | `CustomManualSelectorGenerator` | `StandQuickTurnLeft90_CMSG` | `object0` |
| 14 | 16 | `StandQuickTurnRight90` | `object1078` | `CustomManualSelectorGenerator` | `StandQuickTurnRight90_CMSG` | `object0` |
| 15 | 17 | `StandMoveStartFromSprint` | `object1079` | `CustomManualSelectorGenerator` | `StandMoveStartFromSprint_CMSG` | `object2220` |
| 16 | 18 | `StandMoveLoopFromSprint` | `object1080` | `hkbLayerGenerator` | `StandMoveLoopFromSprint LayerGenerator` | `object2222` |

## Wildcard 转场

`wildcardTransitions = object1081`。这些转场从 `StandMove_SM` 任意状态触发。

| # | From | EventId | EventName / 条件 | ToStateId | To | Condition | TransitionEffect | Flags |
| ---: | --- | ---: | --- | ---: | --- | --- | --- | ---: |
| 1 | `<Any State>` | 104 | `W_StandMoveStartFromFreeFall` | 1 | `StandMoveStartFromFreeFall` | 无 | `TaeBlend_NoSrcMotion_IgnorFromGenerator` (`CustomTransitionEffect`, `object1949`) | 3584 |
| 2 | `<Any State>` | 103 | `W_StandMoveLoop` | 0 | `StandMoveLoop` | 无 | `SelectBlend` (`hkbManualSelectorTransitionEffect`, `object2224`) | 3584 |
| 3 | `<Any State>` | 523 | `W_StandMoveStartFromFreeFallShortStiff` | 3 | `StandMoveStartFromFreeFallShortStiff` | 无 | `TaeBlend_NoSrcMotion_IgnorFromGenerator` (`CustomTransitionEffect`, `object1949`) | 3584 |
| 4 | `<Any State>` | 524 | `W_StandMoveStartFromLandGroundPositioningJump` | 4 | `StandMoveStartFromLandGroundPositioningJump` | 无 | `TaeBlend_NoSrcMotion_IgnorFromGenerator` (`CustomTransitionEffect`, `object1949`) | 3584 |
| 5 | `<Any State>` | 794 | `W_StandMoveStart` | 5 | `StandMoveStart` | 无 | `SelectBlend` (`hkbManualSelectorTransitionEffect`, `object2224`) | 3584 |
| 6 | `<Any State>` | 802 | `W_StandWalkStop` | 7 | `StandWalkStop` | 无 | `TaeBlend_NoSrcMotion_IgnorFromGenerator` (`CustomTransitionEffect`, `object1949`) | 3584 |
| 7 | `<Any State>` | 803 | `W_StandRunStop` | 8 | `StandRunStop` | 无 | `TaeBlend_NoSrcMotion_IgnorFromGenerator` (`CustomTransitionEffect`, `object1949`) | 3584 |
| 8 | `<Any State>` | 804 | `W_StandQuickTurnRight180` | 10 | `StandQuickTurnRight180` | 无 | `TaeBlend_NoSrcMotion_IgnorFromGenerator` (`CustomTransitionEffect`, `object1949`) | 3584 |
| 9 | `<Any State>` | 805 | `W_StandQuickTurnLeft180` | 9 | `StandQuickTurnLeft180` | 无 | `TaeBlend_NoSrcMotion_IgnorFromGenerator` (`CustomTransitionEffect`, `object1949`) | 3584 |
| 10 | `<Any State>` | 818 | `W_StandQuickTurnMoveStartLeft180` | 11 | `StandQuickTurnMoveStartLeft180` | 无 | `TaeBlend_NoSrcMotion_IgnorFromGenerator` (`CustomTransitionEffect`, `object1949`) | 3584 |
| 11 | `<Any State>` | 819 | `W_StandQuickTurnMoveStartRight180` | 12 | `StandQuickTurnMoveStartRight180` | 无 | `TaeBlend_NoSrcMotion_IgnorFromGenerator` (`CustomTransitionEffect`, `object1949`) | 3584 |
| 12 | `<Any State>` | 820 | `W_StandMoveQuickTurnLeft180` | 13 | `StandMoveQuickTurnLeft180` | 无 | `TaeBlend_NoSrcMotion_IgnorFromGenerator` (`CustomTransitionEffect`, `object1949`) | 3584 |
| 13 | `<Any State>` | 821 | `W_StandMoveQuickTurnRight180` | 14 | `StandMoveQuickTurnRight180` | 无 | `TaeBlend_NoSrcMotion_IgnorFromGenerator` (`CustomTransitionEffect`, `object1949`) | 3584 |
| 14 | `<Any State>` | 1054 | `W_StandQuickTurnLeft90` | 15 | `StandQuickTurnLeft90` | 无 | `TaeBlend_NoSrcMotion_IgnorFromGenerator` (`CustomTransitionEffect`, `object1949`) | 3584 |
| 15 | `<Any State>` | 1055 | `W_StandQuickTurnRight90` | 16 | `StandQuickTurnRight90` | 无 | `TaeBlend_NoSrcMotion_IgnorFromGenerator` (`CustomTransitionEffect`, `object1949`) | 3584 |
| 16 | `<Any State>` | 1568 | `W_StandMoveStartFromSprint` | 17 | `StandMoveStartFromSprint` | 无 | `TaeBlend_IgnorFromGenerator` (`CustomTransitionEffect`, `object2225`) | 3584 |
| 17 | `<Any State>` | 1580 | `W_StandMoveLoopFromSprint` | 18 | `StandMoveLoopFromSprint` | 无 | `TaeBlend_IgnorFromGenerator` (`CustomTransitionEffect`, `object2225`) | 3584 |

## 状态自身转场

这些转场只从指定状态触发，目标都回到 `StandMoveLoop`。

| # | From | EventId | EventName / 条件 | ToStateId | To | Condition | TransitionEffect | Flags |
| ---: | --- | ---: | --- | ---: | --- | --- | --- | ---: |
| 18 | `StandMoveStartFromFreeFall` | 102 | `StandMoveStartFromFreeFall_to_StandMoveLoop` | 0 | `StandMoveLoop` | 无 | `SelectStateToStateBlend` (`hkbManualSelectorTransitionEffect`, `object3590`) | 0 |
| 19 | `StandMoveStartFromFreeFallShortStiff` | 522 | `StandMoveStartFromFreeFallShortStiff_to_StandMoveLoop` | 0 | `StandMoveLoop` | 无 | `SelectStateToStateBlend` (`hkbManualSelectorTransitionEffect`, `object3590`) | 0 |
| 20 | `StandMoveStartFromLandGroundPositioningJump` | 525 | `StandMoveStartFromLandGroundPositioningJump_to_StandMoveLoop` | 0 | `StandMoveLoop` | 无 | `SelectStateToStateBlend` (`hkbManualSelectorTransitionEffect`, `object3590`) | 0 |
| 21 | `StandMoveStart` | 795 | `StandMoveStart_to_StandMoveLoop` | 0 | `StandMoveLoop` | 无 | `SelectStateToStateBlend` (`hkbManualSelectorTransitionEffect`, `object3590`) | 0 |
| 22 | `StandQuickTurnMoveStartLeft180` | 814 | `StandQuickTurnMoveStartLeft180_to_StandMoveLoop` | 0 | `StandMoveLoop` | 无 | `SelectStateToStateBlend` (`hkbManualSelectorTransitionEffect`, `object3590`) | 0 |
| 23 | `StandQuickTurnMoveStartRight180` | 815 | `StandQuickTurnMoveStartRight180_to_StandMoveLoop` | 0 | `StandMoveLoop` | 无 | `SelectStateToStateBlend` (`hkbManualSelectorTransitionEffect`, `object3590`) | 0 |
| 24 | `StandMoveQuickTurnLeft180` | 816 | `StandMoveQuickTurnLeft180_to_StandMoveLoop` | 0 | `StandMoveLoop` | 无 | `SelectStateToStateBlend` (`hkbManualSelectorTransitionEffect`, `object3590`) | 0 |
| 25 | `StandMoveQuickTurnRight180` | 817 | `StandMoveQuickTurnRight180_to_StandMoveLoop` | 0 | `StandMoveLoop` | 无 | `SelectStateToStateBlend` (`hkbManualSelectorTransitionEffect`, `object3590`) | 0 |
| 26 | `StandMoveStartFromSprint` | 1567 | `StandMoveStartFromSprint_to_StandMoveLoop` | 0 | `StandMoveLoop` | 无 | `StateToStateBlendIgnoreToWorld` (`hkbBlendingTransitionEffect`, `object3372`) | 0 |
| 27 | `StandMoveLoopFromSprint` | 1581 | `StandMoveLoopFromSprint_to_StandMoveLoop` | 0 | `StandMoveLoop` | 无 | `SelectStateToStateBlend` (`hkbManualSelectorTransitionEffect`, `object3590`) | 0 |

## 转向相关摘录

下面这些是与 UE 当前转向还原最相关的 StandMove 状态和事件：

| 目标状态 | StateId | 进入事件 | EventId | 出场事件 |
| --- | ---: | --- | ---: | --- |
| `StandQuickTurnLeft90` | 15 | `W_StandQuickTurnLeft90` | 1054 | 无本状态内部转场 |
| `StandQuickTurnRight90` | 16 | `W_StandQuickTurnRight90` | 1055 | 无本状态内部转场 |
| `StandQuickTurnLeft180` | 9 | `W_StandQuickTurnLeft180` | 805 | 无本状态内部转场 |
| `StandQuickTurnRight180` | 10 | `W_StandQuickTurnRight180` | 804 | 无本状态内部转场 |
| `StandQuickTurnMoveStartLeft180` | 11 | `W_StandQuickTurnMoveStartLeft180` | 818 | `StandQuickTurnMoveStartLeft180_to_StandMoveLoop` |
| `StandQuickTurnMoveStartRight180` | 12 | `W_StandQuickTurnMoveStartRight180` | 819 | `StandQuickTurnMoveStartRight180_to_StandMoveLoop` |
| `StandMoveQuickTurnLeft180` | 13 | `W_StandMoveQuickTurnLeft180` | 820 | `StandMoveQuickTurnLeft180_to_StandMoveLoop` |
| `StandMoveQuickTurnRight180` | 14 | `W_StandMoveQuickTurnRight180` | 821 | `StandMoveQuickTurnRight180_to_StandMoveLoop` |

注意：`StandQuickTurnLeft90`、`StandQuickTurnRight90`、`StandQuickTurnLeft180`、`StandQuickTurnRight180` 在 `StandMove_SM` 内没有状态自身转场数组，说明它们的结束/回落不是通过本状态机内的 `*_to_StandMoveLoop` 局部转场表达的；需要结合上层状态机、脚本事件或动画/TAE 事件继续追踪。

## 与 Lua 事件选择的关系

`StandMove_SM` 本身不判断角度；角度判断在脚本层完成，然后通过事件驱动状态机：

- `_GroundQuickTurn(current_hkb_state)` 会发：
  - `W_StandQuickTurnLeft90`
  - `W_StandQuickTurnRight90`
  - `W_StandQuickTurnLeft180`
  - `W_StandQuickTurnRight180`
- `BEH_A_QUICK_TURN_MOVE_START` 会发：
  - `W_StandQuickTurnMoveStartLeft180`
  - `W_StandQuickTurnMoveStartRight180`
- `BEH_A_STAND_MOVE_QUICK_TURN` 会发：
  - `W_StandMoveQuickTurnLeft180`
  - `W_StandMoveQuickTurnRight180`

这意味着 UE AnimBP 若要贴近原工程，应把“条件判断”放在 Lua/逻辑层，AnimBP 侧只接收已经选好的目标状态事件或状态 ID。
