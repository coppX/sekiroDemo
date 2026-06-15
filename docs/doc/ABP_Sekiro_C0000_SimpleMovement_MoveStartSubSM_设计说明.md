# ABP_Sekiro_C0000_SimpleMovement_MoveStartSubSM 设计说明

最后更新：2026-05-15

## 范围

- 资产：`/Game/Animation/Sekiro/C0000/Blueprints/ABP_Sekiro_C0000_SimpleMovement_MoveStartSubSM`
- 本文描述的是当前工程里这份 AnimBP 的实际实现方式，不是理想化方案，也不是只狼原版 HKX 的逐项复刻说明。
- 重点关注它如何按只狼常见的 `style / layer / state` 思路组织 `MoveStart`、基础移动、动作层和受击反应层。

## 依据

- 动画蓝图资产本体：`E:\UEProj\Sekiro\SekiroDemo\Content\Animation\Sekiro\C0000\Blueprints\ABP_Sekiro_C0000_SimpleMovement_MoveStartSubSM.uasset`
- 资产检查输出：`E:\UEProj\Sekiro\SekiroDemo\Saved\Codex\inspect_move_start_subsm.json`
- 运行时驱动脚本：`E:\UEProj\Sekiro\SekiroDemo\Content\Script\Sekiro\C0000\PreviewCharacter.lua`
- 常量定义：`E:\UEProj\Sekiro\SekiroDemo\Content\Script\Sekiro\C0000\Constants.lua`
- 分层状态运行时：`E:\UEProj\Sekiro\SekiroDemo\Source\SekiroDemo\SekiroLayeredStateMachineComponent.h`
- 预览角色绑定：`E:\UEProj\Sekiro\SekiroDemo\Source\SekiroDemo\SekiroC0000PreviewCharacter.cpp`
- 相关参考文档：`E:\UEProj\Sekiro\SekiroDemo\docs\doc\c0000_simplemovement_transition_rules.md`、`E:\UEProj\Sekiro\SekiroDemo\docs\superpowers\specs\2026-05-09-sekiro-master-animbp-design.md`

## 一句话结论

`ABP_Sekiro_C0000_SimpleMovement_MoveStartSubSM` 不是一个单层、纯蓝图自决策的移动状态机，而是一个非常接近只狼思路的“语义状态 + 分层驱动 + 方向/速度选择器”结构：

- `Base / Action / Reaction` 三层并行组织。
- `MoveStart` 不是单动画，而是 Base 层里的一个入口状态，内部再用 `MoveStart_SM` 做 8 个起步变体选择。
- 顶层状态优先表达“我现在处于什么语义阶段”，方向、速度、左右变体等细节尽量下沉到选择器、子状态机或附加层里。
- 运行时主要由 Lua 决策，AnimBP 更像是一个接收状态结果并执行播放的载体。

## 按只狼的 `style / layer / state` 思路拆解

### 1. Style：先分姿态/语义，再分方向和速度

当前实现里，“style”不是一个单独叫 `Style` 的字段，而是通过状态组织方式体现出来的。

- `Base locomotion style`
  `Idle -> MoveStart -> MoveLoop -> MoveStop` 是最核心的基础移动语义。
- `MoveStart style`
  起步不是一个统一动画，而是按 `Run/Walk` 与 `Forward/Back/Left/Right` 再细分成 8 个变体。
- `QuickTurn correction style`
  快速转向被单独建成一组中间修正状态，包括原地 90 度、原地 180 度、起步阶段 180 度、移动中 180 度。
- `Additive action style`
  行为层不是把所有动作塞进 Base，而是用 `Action_SM` 承载“同一语义动作的站立版/移动版”。
- `Reaction style`
  反应层同样独立，使用 `Reaction_SM` 处理格挡弹反这类受力反馈，并按 `Idle/Move` 选择对应姿态版本。

这正是只狼常见的设计特点：先定义“动作语义属于哪一类姿态”，再决定它在站立、移动、转向等上下文中的具体播放版本。

### 2. Layer：不是一棵大树，而是 Base / Action / Reaction 分层

从资产图命名和运行时脚本可以确认，当前实现的核心层级如下：

| Layer | 当前图 | 作用 |
| --- | --- | --- |
| Base | `BaseLayer_SM` | 管基础移动、转向、起停与位移主姿态 |
| Action | `Action_SM` | 管动作层语义，如喝葫芦、义手展开 |
| Reaction | `Reaction_SM` | 管反应层语义，如格挡/弹反反馈 |
| Base 内部子层 | `MoveStart_SM` | 只负责 `MoveStart` 内部的 8 向起步选择 |

运行时也明确按三层维护：

- `Constants.lua` 定义 `LAYER_BASE = 0`、`LAYER_ACTION = 1`、`LAYER_REACTION = 2`。
- `PreviewCharacter.lua` 里 `LayerNames` 直接映射为 `Base / Action / Reaction`。
- `SekiroLayeredStateMachineComponent::ResetLayerStates()` 启动时默认创建三层：
  `Idle`、`ActionIdle`、`ReactionIdle`。

这说明当前实现并不是“Base 里包办一切”，而是已经采用了只狼式的分层状态机思路。

### 3. State：顶层状态保持抽象，细节通过 selector 或子状态机下沉

状态设计上，当前实现有两个明显特征：

- 顶层 Base 状态名偏抽象。
  它强调 `MoveStart / MoveLoop / MoveStop / QuickTurn` 这些语义阶段，而不是直接在顶层铺满 `RunStartForward / WalkStartBack / MoveLoopRight` 这类细分态。
- 方向与速度细节被下沉。
  `MoveStart` 的方向、速度并不继续膨胀顶层状态数量，而是放到 `FSM_MoveStartSelectorId` 和 `MoveStart_SM` 里解决。

这与只狼的思路很接近：先判定“当前属于哪一个语义状态族”，再在状态族内部选择具体方向、速度、动画资源。

## 当前状态机结构总览

资产检查结果显示，这份 AnimBP 当前包含 28 个状态图，151 个转场图。结构可以概括为：

```text
ABP_Sekiro_C0000_SimpleMovement_MoveStartSubSM
|- BaseLayer_SM (12 states)
|  |- Idle
|  |- MoveStart
|  |  `- MoveStart_SM (8 states)
|  |- MoveLoop
|  |- MoveStop
|  |- QuickTurnLeft90
|  |- QuickTurnRight90
|  |- QuickTurnLeft180
|  |- QuickTurnRight180
|  |- QuickTurnMoveStartLeft180
|  |- QuickTurnMoveStartRight180
|  |- MoveQuickTurnLeft180
|  `- MoveQuickTurnRight180
|- Action_SM (5 states)
|  |- ActionIdle
|  |- ActionItemGourdDrinkIdle
|  |- ActionItemGourdDrinkMove
|  |- ActionSubWeaponExpandIdle
|  `- ActionSubWeaponExpandMove
`- Reaction_SM (3 states)
   |- ReactionIdle
   |- ReactionDeflectGuardIdle
   `- ReactionDeflectGuardMove
```

其中：

- `BaseLayer_SM` 是主体。
- `MoveStart_SM` 是 Base 层中的子状态机，不是独立顶层 locomotion。
- `Action_SM` 和 `Reaction_SM` 采用成对语义状态的设计，而不是把动作/反应直接并入 Base。

## Base 层设计

### 1. Base 的状态族

`Constants.lua` 中 Base 逻辑态的枚举为：

| 逻辑态 | ID |
| --- | ---: |
| `BASE_STATE_IDLE` | 0 |
| `BASE_STATE_MOVE_START` | 1 |
| `BASE_STATE_MOVE_LOOP` | 2 |
| `BASE_STATE_MOVE_STOP` | 3 |
| `BASE_STATE_QUICK_TURN_90` | 4 |
| `BASE_STATE_QUICK_TURN_180` | 5 |
| `BASE_STATE_QUICK_TURN_MOVE_START_180` | 6 |
| `BASE_STATE_MOVE_QUICK_TURN_180` | 7 |

这里的关键点是：

- 逻辑层把 QuickTurn 视为“状态族”。
- 具体到 AnimBP 资产时，再拆成 `Left/Right` 两个具体状态。

也就是说，逻辑层先决定“我要进入哪一种转向语义”，动画层再落到左/右具体资源，这就是典型的“语义先行，表现后分流”。

### 2. BaseLayer_SM 当前具体状态

| 状态 | 作用 | 绑定动画 |
| --- | --- | --- |
| `Idle` | 基础待机 | `a000_000000` |
| `MoveStart` | 起步入口态，内部继续分流到 `MoveStart_SM` | `a000_000400` |
| `MoveLoop` | 移动循环 | `a000_000500` |
| `MoveStop` | 收步/停步 | `a000_000600` |
| `QuickTurnLeft90` | 原地左 90 度修正 | `a000_000010` |
| `QuickTurnRight90` | 原地右 90 度修正 | `a000_000011` |
| `QuickTurnLeft180` | 原地左 180 度修正 | `a000_000012` |
| `QuickTurnRight180` | 原地右 180 度修正 | `a000_000013` |
| `QuickTurnMoveStartLeft180` | 起步阶段左 180 度修正 | `a000_000132` |
| `QuickTurnMoveStartRight180` | 起步阶段右 180 度修正 | `a000_000133` |
| `MoveQuickTurnLeft180` | 移动中左 180 度修正 | `a000_000442` |
| `MoveQuickTurnRight180` | 移动中右 180 度修正 | `a000_000443` |

Base 层不是把所有方向移动都做成独立顶层状态，而是只把“对整体行为有明显语义差异”的环节抬到顶层：

- 起步
- 循环
- 停步
- 朝向纠正

这种做法让顶层状态机更像只狼的语义骨架，而不是单纯的资源列表。

### 3. Base 层的转场风格

根据现有检查结果，`BaseLayer_SM` 当前有 132 个转场图。这说明它已经被整理成接近“显式 wildcard/event-driven”的矩阵式结构：

- Base 层活跃状态之间有非常高的互通性。
- 实际要去哪个目标态，主要不是在蓝图里重新计算一遍方向和角度。
- 更核心的做法是运行时先算出目标语义，再把结果写进 AnimBP 变量，让状态机执行已有入口。

这和只狼 HKX 里“事件/语义先决策，状态机只负责合法跳转”的方向是一致的。

## MoveStart 子状态机设计

`MoveStart` 的真正核心不是顶层那一个 `MoveStart` 名字，而是内部嵌套的 `MoveStart_SM`。

### 1. MoveStart_SM 当前 8 个状态

| 状态 | 速度语义 | 方向槽位 | 绑定动画 |
| --- | --- | --- | --- |
| `RunStartF` | Run | Forward | `a000_000400` |
| `RunStartB` | Run | Back | `a000_000401` |
| `RunStartL` | Run | Left-family | `a000_000402` |
| `RunStartR` | Run | Right-family | `a000_000403` |
| `WalkStartF` | Walk | Forward | `a000_000100` |
| `WalkStartB` | Walk | Back | `a000_000101` |
| `WalkStartL` | Walk | Left-family | `a000_000102` |
| `WalkStartR` | Walk | Right-family | `a000_000103` |

这里最重要的设计结论是：

- 起步已经按 `速度 × 方向槽位` 做了二维拆分。
- 但它没有继续扩成完整 8 向独立动画，而是把斜前左、斜后左都并到 `Left-family`，把斜前右、斜后右都并到 `Right-family`。

### 2. MoveStart 的 selector 规则

`PreviewCharacter.lua` 当前通过下面的逻辑构造起步选择器：

```lua
local move_start_direction_slot = DirectionStateOffsets[direction]
local move_start_selector_id = move_speed_index * 10 + move_start_direction_slot
set_anim_int(self, "FSM_MoveStartSelectorId", move_start_selector_id)
```

方向槽位映射如下：

| 输入方向 | 槽位 |
| --- | ---: |
| `Forward` | 0 |
| `Back` | 1 |
| `Left` / `ForwardLeft` / `BackLeft` | 2 |
| `Right` / `ForwardRight` / `BackRight` | 3 |

速度索引如下：

| 速度 | 索引 |
| --- | ---: |
| `Walk` | 0 |
| `Run` | 1 |

因此，`MoveStart_SM` 的本质并不是一个长期驻留状态机，而是一个“起步阶段的样式选择器”：

- 先由逻辑层决定当前是 Walk 还是 Run。
- 再把方向压缩成 4 个播放槽位。
- 最后进入对应的起步动画。

这就是只狼味道很重的设计方式：顶层状态不负责承载所有具体表现，真正的资源选择在状态内部完成。

### 3. 为什么 `MoveStart_SM` 很关键

如果不做 `MoveStart_SM`，通常会出现两种退化方案：

- 直接把 `MoveStartF / MoveStartB / MoveStartL / MoveStartR / WalkStart... / RunStart...` 全部摊平到顶层。
- 或者只保留一个 `MoveStart`，丢失起步方向与步态差异。

当前实现选的是中间方案：

- 顶层仍然保持 `MoveStart` 这个抽象语义。
- 具体播放细节交给子状态机。

这正是更接近只狼的组织方式。

## Action 层设计

`Action_SM` 当前有 5 个状态：

| 状态 | 语义 | 绑定动画 |
| --- | --- | --- |
| `ActionIdle` | 动作层空闲 | 无专属序列 |
| `ActionItemGourdDrinkIdle` | 站立喝葫芦 | `StandMoveableAction_SM/a000_250000` |
| `ActionItemGourdDrinkMove` | 移动中喝葫芦 | `StandMoveUpper_SM/a000_250000` |
| `ActionSubWeaponExpandIdle` | 站立义手展开 | `StandMoveableAction_SM/a070_412000` |
| `ActionSubWeaponExpandMove` | 移动中义手展开 | `StandMoveUpper_SM/a070_412001` |

设计特征非常明确：

- 同一动作语义拆成 `Idle` 版和 `Move` 版。
- 不是在 Base 层里新增“喝葫芦移动态”“义手展开移动态”等大批组合状态。
- 动作层本质上是在复用“语义动作 + 移动上下文”的组合规则。

`PreviewCharacter.lua` 里，`ActionEventVariants` 也是按这个思路定义的：

- `ActionItemGourdDrink = { idle, move }`
- `ActionSubWeaponExpand = { idle, move }`

运行时通过 `select_add_event_spec(...)`，结合 `context.wants_move` 自动选择站立版或移动版。这就是典型的“同一动作语义在不同 locomotion style 下切换变体”。

## Reaction 层设计

`Reaction_SM` 当前有 3 个状态：

| 状态 | 语义 | 绑定动画 |
| --- | --- | --- |
| `ReactionIdle` | 反应层空闲 | 无专属序列 |
| `ReactionDeflectGuardIdle` | 站立格挡/弹反 | `StandMoveableAction_SM/a050_203010` |
| `ReactionDeflectGuardMove` | 移动中格挡/弹反 | `StandMoveUpper_SM/a050_203011` |

它的设计方式与 Action 层一致：

- 先定义反应语义。
- 再按 `Idle / Move` 变体分流。

但优先级比 Action 更高。当前脚本逻辑里：

- Reaction 触发时会取消 Action 层。
- 只有 Reaction 处于 `Idle` 时，Action 层才允许激活。

这非常符合只狼式的分层优先级：受击/防御反应优先于普通动作表现。

## 当前实现中的 `state` 不是“资源名”，而是“语义族 + 上下文”

综合来看，这份 AnimBP 的 `state` 设计不是简单的一状态一动画资源，而是分成三层理解：

| 层次 | 当前做法 |
| --- | --- |
| 语义族 | `MoveStart`、`MoveLoop`、`QuickTurn180`、`ActionItemGourdDrink`、`ReactionDeflectGuard` |
| 上下文 | `Idle / Move`、`Walk / Run`、`Forward / Back / Left-family / Right-family` |
| 落地资源 | 最终映射到 `a000_000400`、`a070_412001` 等具体序列 |

所以它更像：

`语义状态 -> 上下文选择 -> 播放资源`

而不是：

`一个离散资源 = 一个最终状态`

这就是只狼状态机设计里最值得保留的思路。

## 运行时驱动方式

当前实现不是把所有判断都放在 AnimBP transition 里，而是由 Lua 先做一层决策，再把结果回写到 AnimBP：

- `FSM_AnimStateId`
- `FSM_ActionStateId`
- `FSM_ReactionStateId`
- `FSM_MoveStartSelectorId`

`PreviewCharacter.lua` 负责：

- 读取输入方向、移动速度、转向角。
- 判定当前 Base 语义态。
- 判定是否进入 QuickTurn 家族。
- 按 `wants_move` 选择 Action/Reaction 的站立版或移动版。
- 把最终状态结果同步给 AnimBP。

这意味着当前 AnimBP 的职责更偏向：

- 播放器
- 分发器
- 状态容器

而不是完整的行为推理中心。

## 与只狼设计思路的对应关系

如果按“只狼中的 `style / layer / state`”来总结，当前实现可以归纳成下面几条：

1. `style` 先行
   不是先想“有哪些动画资源”，而是先想“当前处于哪种移动/动作/反应风格”。
2. `layer` 并行
   Base 管主移动，Action 管动作附加，Reaction 管受击反应，彼此职责清晰。
3. `state` 抽象
   顶层 State 尽量保持语义名，方向和速度细节下沉，不在顶层爆炸。
4. `selector` 落地
   `MoveStart_SM`、`Idle/Move` 变体和左右方向槽位，都是 selector 思维而不是平铺思维。
5. 外部逻辑驱动
   先由外部逻辑判定，再把状态结果喂给动画蓝图，这比把所有角度判断写死在 AnimBP 里更接近只狼。

## 当前实现的特点与限制

当前版本已经具备明显的只狼式骨架，但仍然保留一些工程化取舍：

- `MoveStart_SM` 只做到 `Walk/Run × 4 槽位`，斜向没有独立起步动画，而是并入左右槽位。
- QuickTurn 家族在逻辑上是“状态族”，但在资产层仍然拆成左右具体态，这是为了资源落地清晰，而不是纯抽象 selector。
- Action/Reaction 层目前只覆盖少量样例动作，说明分层结构已经搭好，但动作库还没有扩展开。
- 当前强依赖 Lua 驱动，不是一个“脱离脚本也能自洽推理”的纯 AnimBP。

## 结论

`ABP_Sekiro_C0000_SimpleMovement_MoveStartSubSM` 当前最值得保留的设计，不是某个单独状态名，而是这三层组织方法：

- 用 `Base / Action / Reaction` 代替单一大状态机。
- 用 `MoveStart -> MoveStart_SM` 代替顶层平铺起步态。
- 用“语义态 + 上下文 selector”代替“每个资源都当成一个顶层状态”。

如果后续继续朝只狼风格靠拢，这份状态机最自然的演进方向也应该是继续强化这三点，而不是回退成单层、全平铺、纯资源驱动的状态图。
