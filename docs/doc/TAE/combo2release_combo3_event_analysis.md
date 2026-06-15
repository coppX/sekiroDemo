# Combo2Release -> Combo3 事件整理

本文整理 `GroundAttackCombo2Release` (`a050_300110`) 和 `GroundAttackCombo3` (`a050_300020`) 的 TAE/HKS 事件配置，重点关注连段切换、动画混合、转向、位移相关事件。

数据来源：

- `docs/doc/TAE/AniEventAnalyze/sekiro_a50_combat_anievent.csv`
- `docs/doc/TAE/AniEventAnalyze/sekiro_a50_combat_ani.csv`
- `docs/doc/TAE/SDT_TAE_动画事件对照表.md`
- `Content/Script/Sekiro/C0000/c0000_transition.dec.lua`
- `Content/Script/Sekiro/C0000/c0000_define.dec.lua`
- `Content/Script/Sekiro/C0000/PreviewCharacter.lua`
- UE AnimBP: `/Game/Animation/Sekiro/C0000/Blueprints/ABP_Sekiro_C0000_SimpleMovement_MoveStartSubSM_HKXQuickTurnStart`

## 事件映射

TAE 中的 `AddSpEffect` 会通过 `SpEffectID` 映射到 HKS 可查询的 `SP_EF_REF_*`。当前脚本里的关键映射如下：

| SpEffectID | Behavior Ref | HKS 常量 | 含义 |
| --- | ---: | --- | --- |
| `100358` | `216` | `SP_EF_REF_TAE_TRANSITION_GROUND_ATTACK_COMBO_3` | 当前动画允许切到 `GroundAttackCombo3` |
| `100360` | `217` | `SP_EF_REF_TAE_TRANSITION_GROUND_ATTACK_COMBO_4` | 当前动画允许切到 `GroundAttackCombo4` |
| `100367` | `221` | `SP_EF_REF_ENABLE_PRESS_DEFLECT_GUARD` | 允许按防御/弹反 |
| `100368` | `311` | `SP_EF_REF_ENABLE_PRESS_SUB_ATTACK` | 允许按副武器/义手攻击 |

原始 HKS 逻辑在收到地面攻击输入时，会检查：

```lua
elseif env(3036, SP_EF_REF_TAE_TRANSITION_GROUND_ATTACK_COMBO_3) == TRUE then
    FireEvent("W_GroundAttackCombo3")
```

也就是说，`Combo2Release -> Combo3` 的核心切换标志是 `a050_300110` 上的 `SpEffectID=100358`。

## Combo2Release

动画：`a050_300110`  
状态：`GroundAttackCombo2Release`  
TAE 时长记录：`1.633s`  
UE 当前动画长度：约 `1.533s`

| 类型 | 时间 | 事件 | 参数/说明 |
| --- | ---: | --- | --- |
| 动画混合 | `0.000 - 0.167` | `Blend` | 进入 `Combo2Release` 的混合期 |
| 切到 Combo3 标志 | `0.000 - 1.100` | `AddSpEffect` | `SpEffectID=100358`，映射到 `SP_EF_REF_TAE_TRANSITION_GROUND_ATTACK_COMBO_3` |
| 禁止转身 | `0.100 - 1.633` | `Disable Turning` | 大部分 `Combo2Release` 期间禁止角色转向 |
| 攻击取消 | `0.300 - 1.633` | `InvokeAnimCancelEnd_R1_LightKick` | R1 可取消窗口 |
| 闪避缓冲取消 | `0.400 - 1.633` | `End If Dodge Queued` | 有闪避输入时可退出 |
| L1/L2 取消 | `0.400 - 1.633` | `InvokeAnimCancelEnd_L1` / `InvokeAnimCancelEnd_L2` | 防御/义手取消窗口 |
| 其他行为窗口 | `0.400 - 1.633` | `JumpTable_137` / `JumpTable_154` | 未分类；`154` 在对照表中标记为空/损坏事件 |
| 移动缓冲取消 | `0.600 - 1.633` | `End If LS Move Queued` | 有左摇杆移动输入时可退出 |
| 道具/切武器取消 | `0.600 - 1.633` | `InvokeAnimCancelEnd_UseItem` / `End If Weapon Switch Queued` | 道具、切武器窗口 |
| 防御/副武器输入 | `0.600 - 1.633` | `AddSpEffect` | `SpEffectID=100367`、`100368` |
| 位移相关 | 无 | 无 | 未发现 `DisableMovement`、`MoveMult`、`RootMotionReduction`、`BoostRootMotionToReachTarget` |

结论：

- `Combo2Release` 从 `0.0s` 到 `1.1s` 都带有 “可以切 Combo3” 的标志。
- 但 R1 取消窗口从 `0.3s` 才开始。
- 因此如果玩家提前输入，运行时可能在 `0.3s` 后就切入 Combo3。

## Combo3

动画：`a050_300020`  
状态：`GroundAttackCombo3`  
TAE 时长记录：`2.033s`  
UE 当前动画长度：约 `1.933s`

| 类型 | 时间 | 事件 | 参数/说明 |
| --- | ---: | --- | --- |
| 禁止转身 | `0.000 - 0.100` | `Disable Turning` | Combo3 开头短暂禁转 |
| 动画混合 | `0.000 - 0.300` | `Blend` | 进入 Combo3 的混合期 |
| 后续连段标志 | `0.000 - 1.300` | `AddSpEffect` | `SpEffectID=100360`，映射到 Combo4 转移标志 |
| 转身速度 | `0.100 - 0.200` | `SetTurnSpeed` | `TurnSpeed=180.0`，`IsLockOnCheck=0` |
| 转身速度 | `0.200 - 0.300` | `SetTurnSpeed` | `TurnSpeed=360.0`，`IsLockOnCheck=0` |
| 躯干/攻击瞄准修正 | `0.300 - 0.700` | `Unknown_700` | 对照表中为 `CustomLookAtTwistModifier`；参数含 `ModifierID=130` |
| 禁止转身 | `0.400 - 2.033` | `Disable Turning` | 中后段禁止转向 |
| 攻击取消 | `0.700 - 2.033` | `InvokeAnimCancelEnd_R1_LightKick` | R1 可取消窗口 |
| 闪避/L1/L2 取消 | `0.700 - 2.033` | `End If Dodge Queued` / `InvokeAnimCancelEnd_L1` / `InvokeAnimCancelEnd_L2` | 取消窗口 |
| 移动缓冲取消 | `0.900 - 2.033` | `End If LS Move Queued` | 有移动输入时可退出 |
| 道具/切武器取消 | `0.900 - 2.033` | `InvokeAnimCancelEnd_UseItem` / `End If Weapon Switch Queued` | 道具、切武器窗口 |
| 防御/副武器输入 | `1.067 - 2.033` | `AddSpEffect` | `SpEffectID=100367`、`100368` |
| 位移相关 | 无 | 无 | 未发现 `DisableMovement`、`MoveMult`、`RootMotionReduction`、`BoostRootMotionToReachTarget` |

结论：

- Combo3 开头 `0.0 - 0.3s` 是混合期。
- Combo3 在 `0.1 - 0.3s` 有转身速度事件，之后 `0.4s` 起再次禁止转身。
- `Unknown_700` 在 SDT 对照表里对应 `CustomLookAtTwistModifier`，更偏上半身/攻击瞄准修正，不是 root motion 位移事件。

## UE AnimBP 混合

当前 UE AnimBP 的 `GroundAttackCombo3` 进入 transition 节点为：

- `AnimStateTransitionNode_120`
- `crossfade_duration = 0.3000000119`
- `blend_mode = Linear`
- `logic_type = Standard Blend`

这和 `a050_300020` 的 TAE `Blend 0.000 - 0.300` 一致。

## 切换时机判断

`Combo2Release -> Combo3` 的原始事件并不是一个固定时间点，而是两个条件叠加：

1. `a050_300110` 上 `SpEffectID=100358` 在 `0.000 - 1.100` 有效。
2. R1 取消窗口在 `0.300 - 1.633` 有效。

因此，理论上的最早切换时机是 `0.300s`。如果输入已经排队，运行时很可能在 `0.300s` 附近立即切入 Combo3。

脚步采样显示：

| Combo2Release 时间 | 与 Combo3 起始姿势的脚部平均差异 |
| ---: | ---: |
| `0.300s` | 约 `45.9cm` |
| `0.600s` | 约 `46.3cm` |
| `1.100s` | 约 `26.0cm` |
| `1.13s - 1.17s` | 当前采样中最接近 |

解释：

- 早切时 `RootPos` 可能接近，但左右脚姿势并不接近。
- 原始游戏可能依靠 `Combo3` 的 `0.3s` Blend 和 Havok 行为图混合来掩盖脚步差异。
- 如果 UE 侧实际混合/Root Motion 混合与原始 HKX 不一致，就会更明显地表现为脚滑或位移方向异常。

## 位移与右滑结论

这两段 TAE 事件里没有发现直接修改 root motion 方向或倍率的事件：

- 无 `SetMovementMultiplier` / `MoveMult`
- 无 `RootMotionReduction`
- 无 `BoostRootMotionToReachTarget`
- 无 `DisableMovement`

因此，播放 Combo3 时的整体侧滑更可能来自：

- 动画资产的 root motion 轨道方向；
- UE 状态切换时 root motion 混合方式；
- 运行时代码或 AnimBP 变量额外叠加的朝向/移动方向；
- 角色 Mesh 相对旋转和 `Master` 根轨道坐标系之间的解释差异。

### `+Y` 轨道修正实验

对比地面攻击前几段动画的 `Master` 根轨道：

| 动画 | `Master` 位移 |
| --- | ---: |
| `a050_300000` / Combo1 | `(0.000, 270.513, 0.000)` |
| `a050_300100` / Combo1Release | `(0.000, 194.296, 0.000)` |
| `a050_300010` / Combo2 | `(0.000, 247.798, 0.000)` |
| `a050_300110` / Combo2Release | `(0.000, 124.441, 0.000)` |
| `a050_300020` / Combo3，修正前 | `(-148.965, 0.000, 0.000)` |

可以看到，前两段及其 Release 都是沿 `+Y` 移动，只有 Combo3 是沿 `-X` 移动。由于预览角色 Mesh 在 C++ 中固定了相对旋转 `-90` 度：

```cpp
const FRotator PreviewMeshFacingRotation(0.0f, -90.0f, 0.0f);
```

`a050_300020` 的 `-X` root motion 在当前预览角色坐标系下会表现为向角色右侧滑动。因此做过一次实验性修正：只改 `a050_300020` 的 `Master` 平移轨道，把原来的 `-X` 曲线重投到 `+Y`：

| 动画 | `Master` 位移 |
| --- | ---: |
| `a050_300020` / Combo3，改为 `+Y` 后 | `(0.000, 148.965, 0.000)` |

这个实验可以消除“和前两段坐标轴不一致导致的右滑”，但它带来新的问题：`Combo3` 最后一帧的 `Master` 朝向约为 `160.47°`，而纯 `+Y` 位移方向是 `90°`，两者相差约 `70°`。因此角色最终朝向与 root motion 移动方向会明显不一致，视觉上接近“移动方向和最终朝向垂直”。

后续更合理的处理应当满足两个条件：

- 不再使用原始 `-X` 轨道造成右滑；
- root motion 的最终移动方向要和 Combo3 最后一帧朝向一致，而不是简单套用前两段的 `+Y` 轴。

基于这个判断，后续资产修正应以 `a050_300020` 最后一帧 `Master` 朝向作为投射方向，同时保留原位移长度和旋转曲线。

后续排查时，应优先对比：

1. `a050_300020` 的 `Master` root motion 位移方向；
2. Combo3 进入 transition 的 root motion 混合；
3. 地面攻击期间是否仍有 `AddMovementInput`、`MoveAngle`、`MoveDirection`、`TurnAngle` 等变量影响 AnimBP；
4. `SetTurnSpeed` 事件 `0.1 - 0.3s` 是否应只影响朝向，不应改变 root motion 位移方向。
