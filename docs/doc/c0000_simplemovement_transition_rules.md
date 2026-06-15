# ABP_Sekiro_C0000_SimpleMovement_HKXTurn 状态机转场条件

最后更新：2026-05-14

## 范围

- 当前运行动画蓝图：`/Game/Animation/Sekiro/C0000/Blueprints/ABP_Sekiro_C0000_SimpleMovement_HKXTurn`
- 状态机：`BaseLayer_SM`
- 转场变量：`FSM_AnimStateId`
- 当前 `BaseLayer_SM` 转场数量：`132`
- 当前蓝图编译结果：`0 errors / 0 warnings`
- 持久化方式：已通过编辑器保存动画蓝图资产，状态节点和转场条件写入 `.uasset`，重启编辑器后仍应存在。

## 只狼参考结论

完整 HKX 状态机拆解见：

`docs/doc/c0000_hkx_standmove_sm_transitions.md`

原始 HKX：

`E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE\chr\c0000-behbnd-dcx\Behaviors\C0000.hkx.xml`

关键结论：

- `StandMove_SM` 有 `17` 个状态，起始状态是 `StandMoveLoop`。
- HKX 里有 `17` 条 `wildcardTransitions`，它们不是表达式条件，而是由 `eventId/eventName` 直接触发目标状态。
- 另有 `10` 条 state-local transition，主要负责部分移动/转向状态回到 `StandMoveLoop`。
- UE 动画蓝图没有真正的 HKX wildcard transition，所以这里把 wildcard 语义映射成“所有活动源状态都可以跳到所有活动目标状态”的显式 transition。
- Lua 负责根据输入方向、当前朝向和只狼脚本逻辑选择目标状态，并写入 `FSM_AnimStateId`；AnimBP 只做 `FSM_AnimStateId == 目标状态ID`，不在蓝图里重复计算角度。

## 活动状态与编码

当前 AnimBP 主路径只使用下列 12 个状态。旧方向状态仍保留在蓝图里，但不作为主路径参与转场。

| 状态 | FSM_AnimStateId | 用途 |
| --- | ---: | --- |
| Idle | 0 | 站立待机 |
| MoveStart | 10 | 起步 |
| MoveLoop | 20 | 移动循环 |
| MoveStop | 30 | 停步 |
| QuickTurnLeft90 | 42 | 原地左 90 转向 |
| QuickTurnRight90 | 43 | 原地右 90 转向 |
| QuickTurnLeft180 | 52 | 原地左 180 转向 |
| QuickTurnRight180 | 53 | 原地右 180 转向 |
| QuickTurnMoveStartLeft180 | 62 | 起步阶段左 180 转向 |
| QuickTurnMoveStartRight180 | 63 | 起步阶段右 180 转向 |
| MoveQuickTurnLeft180 | 72 | 移动中左 180 转向 |
| MoveQuickTurnRight180 | 73 | 移动中右 180 转向 |

旧方向状态：

`MoveStartBack`, `MoveStartLeft`, `MoveStartRight`, `MoveLoopBack`, `MoveLoopLeft`, `MoveLoopRight`, `MoveStopBack`, `MoveStopLeft`, `MoveStopRight`

这些状态未删除，以降低资产结构风险；但本轮规整后不再保留它们与主路径之间的 transition。

## 转场矩阵

为了还原 HKX 的 wildcard/event-driven 语义，`BaseLayer_SM` 现在使用 12 个活动状态的全连接转场矩阵：

- 任意活动源状态 `From`
- 可以转到任意其他活动目标状态 `To`
- 排除 `From == To`
- 条件统一为：`FSM_AnimStateId == To 对应编码`
- 总数：`12 * 11 = 132`

也就是说，只要 Lua 把 `FSM_AnimStateId` 设置为某个目标状态编号，当前无论处于 Idle、MoveStart、MoveLoop、MoveStop，还是某个 QuickTurn 状态，AnimBP 都有合法 transition 可以进入目标状态。这修复了之前“只有后退能转向、左右键没有转向入口”的问题。

## CrossFade 规则

| 场景 | CrossFade |
| --- | ---: |
| 进入任意 QuickTurn / MoveQuickTurn 状态 | 0.03 |
| 从任意 QuickTurn / MoveQuickTurn 状态退出到普通移动状态 | 0.04 |
| 普通移动状态进入 MoveStart | 0.06 |
| 其他普通移动状态之间切换 | 0.08 |

说明：

- QuickTurn 入场使用更短融合，避免按 A/D 或 S 时转向被普通移动动画吃掉。
- QuickTurn 出场使用 `0.04`，给转向动画留一点姿态衔接时间，降低一帧错姿态/倒地感。
- 普通移动保持 `0.06 ~ 0.08`，避免起步、循环、停步之间过硬。

## HKX Event 到 UE 状态映射

| HKX eventName | eventId | UE 状态 | FSM_AnimStateId |
| --- | ---: | --- | ---: |
| W_StandQuickTurnLeft90 | 1054 | QuickTurnLeft90 | 42 |
| W_StandQuickTurnRight90 | 1055 | QuickTurnRight90 | 43 |
| W_StandQuickTurnLeft180 | 805 | QuickTurnLeft180 | 52 |
| W_StandQuickTurnRight180 | 804 | QuickTurnRight180 | 53 |
| W_StandQuickTurnMoveStartLeft180 | 818 | QuickTurnMoveStartLeft180 | 62 |
| W_StandQuickTurnMoveStartRight180 | 819 | QuickTurnMoveStartRight180 | 63 |
| W_StandMoveQuickTurnLeft180 | 820 | MoveQuickTurnLeft180 | 72 |
| W_StandMoveQuickTurnRight180 | 821 | MoveQuickTurnRight180 | 73 |

普通移动状态由 Lua 输出非方向编码：

| UE 状态 | FSM_AnimStateId |
| --- | ---: |
| Idle | 0 |
| MoveStart | 10 |
| MoveLoop | 20 |
| MoveStop | 30 |

## Lua 与 AnimBP 分工

Lua 当前负责：

- 根据 `GetMoveInputAngleDegrees()` 获取“当前角色朝向 vs 输入世界方向”的相对角。
- 按只狼脚本逻辑区分左/右、90/180、原地/起步/移动中 QuickTurn。
- 写入 `FSM_AnimStateId`。
- QuickTurn 退出前补齐剩余 yaw，确保角色朝向已经对齐输入方向后再进入普通 `MoveStart/MoveLoop`。

AnimBP 当前负责：

- 只根据 `FSM_AnimStateId` 做状态跳转。
- 不再依赖 `MoveStartLeft/Right/Back` 等方向状态。
- 不在转场图里判断输入角，避免 Lua 和 AnimBP 两套判断互相打架。

## 验证记录

- 批量规整结果：`desired_rule_count=132`。
- 已移除重复 transition：`duplicate_removed_count=40`。
- 最终 `BaseLayer_SM` transition 数量：`132`。
- 已接线规则数量：`wired_count=132`。
- 规则图结构：`Result + Get FSM_AnimStateId + Equal(Integer)`。
- `ABP_Sekiro_C0000_SimpleMovement_HKXTurn` 编译：`success=true`，`status=UpToDate`。
- 蓝图编译错误：`0`。
- 蓝图编译警告：`0`。
- 资产已保存：`/Game/Animation/Sekiro/C0000/Blueprints/ABP_Sekiro_C0000_SimpleMovement_HKXTurn`。

## 动画素材轴向修复记录

2026-05-14 追加修复：

- 修复对象：`a000_000010`, `a000_000011`, `a000_000012`, `a000_000013`, `a000_000132`, `a000_000133`, `a000_000442`, `a000_000443`。
- 问题现象：这些 AnimSequence 单独预览时角色横躺，`RootPos` 高度落在 Y 轴，Z 轴接近 0。
- 原因判断：现有 `.uasset` 是错误轴向导入结果；同一源 FBX 用正确导入参数临时导入后，`RootPos` 会回到 Z 轴。
- 修复方式：从 `E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE\exports\c0000_StandMove_SM_all` 重新导入上述 8 个 FBX，使用 `convert_scene=true`, `convert_scene_unit=true`, `import_rotation=(0,0,0)`, `force_front_x_axis=false`，并保存覆盖原动画资产。
- 自动检查：修复后 `a000_000010` 的第一帧 `RootPos=(-0.0, 0.0, 94.3)`, `Head=(-0.8, 3.5, 150.5)`；`a000_000443` 的第一帧 `RootPos=(3.5, 0.0, 78.6)`, `Head=(3.0, 36.2, 120.2)`。
- 临时导入测试目录 `/Game/Animation/Sekiro/C0000/_TempAxisTest` 已清理。

## 左右键 MoveLoop 斜向修复记录

2026-05-14 追加修复：

- 问题现象：按 A/D 触发 90 度转向后，进入 `MoveLoop` 时角色仍带有偏角，看起来像斜向前行走。
- 原因判断：90 度转向 `exit_time=0.34`，但模拟 yaw 的 `turn_window_start=0.14`, `turn_window_end=0.82`；在 0.34 秒退出时 yaw 还未推进到完整 90 度，随后 `clear_turn_runtime()` 会丢掉剩余 yaw。
- 修复方式：`PreviewCharacter.lua` 增加 `complete_quick_turn_yaw()`，QuickTurn 状态退出前强制补齐 `spec.yaw_delta - runtime.turn.applied_yaw_delta`。
- 同步调整：ground QuickTurn 结束时如果仍按着移动，直接回 `BaseMoveStart`，不再先落 `BaseIdle` 再下一帧起步。
- 预期结果：按 A/D 后角色先完整转到目标方向，再进入普通前向移动循环，`MoveLoop` 不再表现为斜向前走。

## 加速进入跑步动画记录

2026-05-14 追加修复：

- 问题现象：角色移动速度已经接近跑步，但 `MoveLoop` 仍只播放 `a000_000200` 走路循环，按住 WASD 加速后不会进入跑步动画。
- 原因判断：`BaseLayer_SM / MoveLoop` 之前只接了单个 `a000_000200 SequencePlayer`，没有使用已有的方向移动 BlendSpace；同时 Lua 在非冲刺移动时把 `MoveSpeedLevel` 上限压到 `PRM_RUN_STICK_LEVEL=0.75`，导致 `MoveSpeedIndex` 和 BlendSpace 速度轴都无法自然进入 Run 区间。
- AnimBP 修复：`MoveLoop` 仍保留为现有状态，不新增 Run 状态；状态内部改接 `/Game/Animation/Sekiro/C0000/Blueprints/BS_StandMoveLoop_Directional`。BlendSpace 的 `X` 轴由 `MoveAngle` 驱动，`Y` 轴由 `MoveSpeedLevelReal` 驱动。
- Lua 修复：`get_move_speed_level_target()` 保留普通移动和 Shift 冲刺两档。普通 WASD 只到 `PRM_RUN_STICK_LEVEL=0.75`，Shift 冲刺才把目标速度等级推到 `1.0`；`MoveSpeedLevelReal` 继续用原有 `converge_value()` 做平滑加速，因此按住 Shift 后会从普通移动爬升到跑步 BlendSpace 顶端。
- 同步调整：`SetPreviewMoveSpeed()` 改用 `target_move_speed`，让角色实际移动速度和动画速度轴保持一致，避免“身体跑、动画走”的错位。
- 验证记录：`ABP_Sekiro_C0000_SimpleMovement_HKXTurn` 编译通过，错误 `0`，警告 `0`，资产已保存。

2026-05-14 追加修正：

- 问题现象：上一版把普通 WASD 和 Shift 冲刺都映射到了 `MoveSpeedLevel=1.0`，导致 `sprint` 虽然被 Lua 读到，但不会产生额外加速感。
- 修复方式：普通移动重新限制到 `Constants.PRM_RUN_STICK_LEVEL`，只有 `context.sprint == true` 时才进入 `1.0` 跑步目标。这样 Shift 会实际驱动 `MoveSpeedIndex` 进入 Run，并让 `SetPreviewMoveSpeed()` 从 `WALK_SPEED` 提升到 `RUN_SPEED`。

2026-05-14 追加修正 2：

- 问题现象：尝试在 `MoveLoop` 内增加 `Blend Poses by bool` 后，运行时向前移动出现 T-pose，说明状态内部 bool 分支输出链路存在空 Pose 风险。
- 回退方式：移除 bool 分支方案，`MoveLoop` 恢复为单一 `BS_StandMoveLoop_Directional` 直连 `StateResult`，避免任何空分支导致 T-pose。
- 奔跑修复方式：重建 `BS_StandMoveLoop_Directional` 的完整 10 个样本点。`Y=0` 保持普通移动循环：`a000_000200/201/202/203`；`Y=1` 改为 sprint/奔跑循环：`a000_000460/461/462/463`。Shift 会把 `MoveSpeedLevelReal` 推到 `1.0`，从而在同一个稳定 BlendSpace 内混到奔跑动画。
- 保留数据线：`USekiroSimpleMovementAnimInstance.bSprintHeld` 和 Lua 写入仍保留，便于后续如果需要重建独立 Sprint 状态或调试输入，但当前 `MoveLoop` 不再依赖 bool 分支。
- 验证记录：`BS_StandMoveLoop_Directional` 样本数为 `10`；AnimBP 编译通过，错误 `0`，警告 `0`；`ABP_Sekiro_C0000_SimpleMovement_HKXTurn` 和 `BS_StandMoveLoop_Directional` 均已保存。
