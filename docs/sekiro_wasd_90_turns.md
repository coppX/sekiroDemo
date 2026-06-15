# 只狼 WASD 90/180 度转向分析

## 参考来源

- 原工程行为文件：`E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE\chr\c0000-behbnd-dcx\Behaviors\c0000.hkx.xml`
- 当前项目入口：`Content/Script/Sekiro/C0000/PreviewCharacter.lua`
- `Content/Script/Sekiro/C0000/c0000_*.lua` 保持只读，不修改原版脚本。

## HKX 结论

- `StandMoveStart` 由 `W_StandMoveStart` 进入，通过 `StandMoveStart_to_StandMoveLoop` 进入移动循环。
- `StandMoveStart` 是双层 `LayerGenerator`：
  - Motion 层：`StandMoveStart_MotionSelector`，`useMotion=true`。
  - Anime 层：`StandMoveStart_AnimeSelector`，`useMotion=false`。
- 两层都会先用 `MoveSpeedIndex` 变量 `84` 选择走/跑，再用 `MoveDirection` 变量 `70` 选择 F/B/L/R。
- 跑步起步 selector 对应：
  - F：`StandRunStart_F_CMSG_Motion/Anime`，animId `400`，动画 `a000_000400_*` / `a010_000400_*`。
  - B：`StandRunStart_B_CMSG_Motion/Anime`，animId `401`。
  - L：`StandRunStart_L_CMSG_Motion/Anime`，animId `402`。
  - R：`StandRunStart_R_CMSG_Motion/Anime`，animId `403`。
- 90 度 quick turn：
  - `StandQuickTurnLeft90`：事件 `W_StandQuickTurnLeft90`，animId `10`，动画 `a000_000010`。
  - `StandQuickTurnRight90`：事件 `W_StandQuickTurnRight90`，animId `11`，动画 `a000_000011`。

## 180 度转向链路

原版 HKX / `c0000_transition.dec.lua` 里 180 度不是单一动画，而是三类：

### Idle / MoveStop 突然按相反方向

先进入移动起步 180 预备状态，再进入原地 180，最后进入移动：

```text
QuickTurnMoveStart180(W_StandQuickTurnMoveStart*180)
-> QuickTurn180(W_StandQuickTurn*180)
-> MoveStart
-> MoveLoop
```

对应 HKX 动画：

- 右 180：`StandQuickTurnRunStartRight180_F_CMSG_Motion/Anime`，animId `433`，后续 `StandQuickTurnRight180` 使用 animId `13`。
- 左 180：`StandQuickTurnRunStartLeft180_F_CMSG_Motion/Anime`，animId `432`，后续 `StandQuickTurnLeft180` 使用 animId `12`。

### MoveStart 或刚从 MoveStart 进入 MoveLoop 后立刻反向

这不是稳定移动中的转身，仍然走移动起步 180：

```text
QuickTurnMoveStart180(W_StandQuickTurnMoveStart*180)
-> MoveLoop
```

对应 HKX 动画：

- 右 180：`StandQuickTurnRunStartRight180_F_CMSG_Motion/Anime`，animId `433`。
- 左 180：`StandQuickTurnRunStartLeft180_F_CMSG_Motion/Anime`，animId `432`。

当前 UE 侧把“刚从 MoveStart 切进 MoveLoop 的短窗口”也归到这一类，窗口使用 `MOVE_LOOP_FROM_START_ANGLE_SETTLE_SECONDS`。

### 稳定 MoveLoop 中反向

稳定行走/跑动后突然 180 才走移动中 quick turn：

```text
MoveQuickTurn180(W_StandMoveQuickTurn*180)
-> MoveLoop
```

对应 HKX 动画：

- 右 180：`StandRunQuickTurnRight180_F_CMSG_Motion/Anime`，animId `443`。
- 左 180：`StandRunQuickTurnLeft180_F_CMSG_Motion/Anime`，animId `442`。

HKX 的 180 selector 虽然有 F/B/L/R 四个分支，但真正的 180 专用动画在 F 分支；B/L/R 分支多为普通移动/起步动画 `401/402/403`。因此 UE 侧的 180 事件会把 `DirectionId` 锁到 Forward，避免 WS 和 AD 反向时采样到不同的非 180 子动画。

## WASD 方向规则

WASD 表示最终目标绝对方向，不表示“本次相对向左/向右转”。判断流程：

1. 从 WASD 输入得到目标绝对方向。
2. 从 Actor yaw 同步角色当前绝对朝向。
3. 如果目标方向和当前朝向一致，不触发 quick turn，只正常前进。
4. 如果目标方向和当前朝向相差 90 度，进入 90 度桥接链路。
5. 如果目标方向和当前朝向相差 180 度，按当前 base state 选择上面的 180 度链路。
6. 180 度左右方向在绝对目标上等价，但事件会按原版逻辑尽量用 `TurnAngle` / `TwistLowerRootAngle` 的符号选择 Left180 或 Right180。进入 180 状态后会记录目标方向，避免同一长按输入反复重入。

## 180 度状态表

| 当前状态 | 目标相对当前朝向 | 状态链 | 主要动画 |
| --- | --- | --- | --- |
| Idle / MoveStop | 180 | `QuickTurnMoveStart180 -> QuickTurn180 -> MoveStart/MoveLoop` | Right: `a000_000433 -> a000_000013`；Left: `a000_000432 -> a000_000012` |
| MoveStart | 180 | `QuickTurnMoveStart180 -> MoveLoop` | Right: `a000_000433`；Left: `a000_000432` |
| MoveLoop，previous_state 是 MoveStart 且刚进入 | 180 | `QuickTurnMoveStart180 -> MoveLoop` | Right: `a000_000433`；Left: `a000_000432` |
| 稳定 MoveLoop | 180 | `MoveQuickTurn180 -> MoveLoop` | Right: `a000_000443`；Left: `a000_000442` |

180 度转身开始时会记录本次 `target_direction`。只要玩家仍然长按同一个目标方向，转身过程中不会 re-enter 到另一个 180 度事件；只有输入目标方向真的改变时，才允许后续重判。

## 当前 UE 侧转向时长

当前实现把所有“实际转向段”的时长统一为 90 度 quick turn 的时长：

```lua
STANDARD_QUICK_TURN_DURATION = 20.0 / 60.0
```

也就是约 `0.333s`，按 60 FPS 计算为 20 帧。这个统一时长应用到：

- 原地/地面 quick turn：45、90、135、180 度。
- MoveStart 期间的 quick turn：135、180 度。
- 稳定 MoveLoop 期间的 quick turn：135、180 度。
- WASD 90 度桥接链路里真正播放 `W_StandQuickTurnLeft90` / `W_StandQuickTurnRight90` 的转向段。

转向窗口也统一为完整事件区间：

```lua
turn_window_start = 0.0
turn_window_end = 1.0
```

这样 180 度不再使用原 HKX 动画片段较长的 `1.2s ~ 1.6s` 退出时间，而是和 90 度转向一样快。视觉上 180 度会在同样的 20 帧左右完成朝向修正，避免长按反向键时转身过程拖得过久。

以下节点不算实际转向段，因此保留短时长：

- `BaseMoveStartQuickTurnLeft90_Bridge` / `BaseMoveStartQuickTurnRight90_Bridge`：1 帧桥接节点，用来从 MoveStart 进入 90 度 quick turn。
- `BaseIdleQuickTurnLeft180Prelude` / `BaseIdleQuickTurnRight180Prelude`：1 帧 idle 180 前奏，用来先触发 `QuickTurnMoveStart180`，随后进入真正的 `QuickTurn180`。
- `BaseForwardLeftBackMoveQuickTurnLeft180Prelude` / `BaseForwardRightBackMoveQuickTurnRight180Prelude`：1 帧 MoveQuickTurn180 前奏，后续接 90 度 quick turn 链路。
- `BaseForwardLeftBackRunStop` / `BaseForwardRightBackRunStop`：5 帧停步桥接，用来复刻 F/L 或 F/R 到 B 的特殊链路。

测试覆盖在 `Tools/test_wasd_90_turns.py` 中。当前测试会检查：

- WASD 四个绝对朝向之间的 90 度转向事件正确。
- Idle / MoveStop 直接 180 度：`QuickTurnMoveStart180 -> QuickTurn180 -> MoveStart/MoveLoop`。
- MoveStart 期间立即 180 度：`QuickTurnMoveStart180 -> MoveLoop`。
- 稳定 MoveLoop 期间直接 180 度：`MoveQuickTurn180 -> MoveLoop`。
- WS 轴转向后切到 AD 轴，再长按反向 180 度时不会进入错误的 90 度事件。
- 快速点按反向键后松开，会进入停止/Idle，不会继续跑步动画。

最近一次 UE commandlet 测试结果：

```text
[WASD90Test] idle180 F -> B turn_frames=20 expected=20 tolerance=2
[WASD90Test] idle180 B -> F turn_frames=20 expected=20 tolerance=2
[WASD90Test] moveStartImmediate180 F -> B turn_frames=19 expected=20 tolerance=2
[WASD90Test] moveStartImmediate180 B -> F turn_frames=19 expected=20 tolerance=2
[WASD90Test] direct180 F -> B turn_frames=19 expected=20 tolerance=2
[WASD90Test] direct180 B -> F turn_frames=19 expected=20 tolerance=2
[WASD90Test] direct180 L -> R turn_frames=19 expected=20 tolerance=2
[WASD90Test] direct180 R -> L turn_frames=19 expected=20 tolerance=2
[WASD90Test] PASS
```
