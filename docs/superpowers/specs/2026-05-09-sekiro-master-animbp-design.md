# Sekiro C0000 主动画蓝图状态机设计

Date: 2026-05-09
Project: `SekiroDemo`
Status: Draft for review

## 1. 目标

在 `E:\UEProj\Sekiro\SekiroDemo` 的 UE 工程内，为 `c0000` 创建一个总 `AnimBlueprint`，尽量按只狼 `c0000.hkx` 中的真实结构还原以下移动相关状态机逻辑：

- `StandMove_SM`
- `StandMoveLower_SM`
- `StandMoveUpper_SM`
- `StandMoveableAction_SM`

目标不是只把动画序列挂进去，而是尽量保留：

- 原始状态名
- 原始 `stateId`
- 关键 `eventId`
- 共享同步变量语义
- `StandMoveOverwrite` 的上下半身分层关系

## 2. 输入依据

本次设计使用以下本地数据作为唯一依据：

- 只狼行为 XML  
  `E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE\chr\c0000-behbnd-dcx\Behaviors\c0000.hkx.xml`
- 事件 ID 对照  
  `E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE\action\eventnameid.txt`
- 状态 ID 对照  
  `E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE\action\statenameid.txt`
- 已导入的 UE 动画资源  
  `/Game/Animation/Sekiro/C0000/...`
- Monolith 在线编辑能力  
  `http://127.0.0.1:9316/mcp`

Lua 结论：

- 已在只狼 `script` 目录内对相关状态名和事件名做定向搜索。
- 当前这 4 组移动状态机没有搜到直接可用的 Lua 命中。
- 因此本轮状态机拓扑与切换规则，以 `HKX + event/state 对照表` 为准。

## 3. 范围

本轮 in scope：

- 创建一个总 `AnimBlueprint`
- 为总图建立与 `Master_SM` 对齐的最小可运行子集
- 还原 `StandMove_SM`
- 还原 `StandMoveLower_SM`
- 还原 `StandMoveUpper_SM`
- 还原 `StandMoveableAction_SM`
- 还原 `StandMoveOverwrite` 的上下半身分层语义
- 保留 `StateStateId_StandMoveableAction`
- 为关键入口/返回事件建立 UE 侧变量映射
- 输出中文映射文档，方便后续接角色逻辑

本轮 out of scope：

- 还原 `Master_SM` 的全部 300+ 状态
- 还原未导入的其它战斗/受击/跳跃链路
- 接真实角色控制器、输入系统、战斗系统
- 完整还原只狼所有脚本层事件派发逻辑

## 4. 目标资产布局

建议新增以下 UE 资产路径：

- `Content/Animation/Sekiro/C0000/Blueprints/ABP_Sekiro_C0000_Master.uasset`

建议新增以下文档与报告：

- `docs/superpowers/specs/2026-05-09-sekiro-master-animbp-design.md`
- `Saved/SekiroImportReports/c0000_master_animbp_mapping.json`

命名原则：

- 状态机名称尽量与 HKX 原名一致
- 状态名称尽量与 HKX 原名一致
- UE 变量对事件名做最小清洗，保留原语义

## 5. HKX 真实结构结论

### 5.1 顶层入口

在只狼 `Master_SM` 中，本轮相关的三条主链路为：

- `StandMove`，`stateId = 97`
- `StandMoveableAction`，`stateId = 194`
- `StandMoveOverwrite`，`stateId = 195`

它们的生成器关系为：

- `StandMove -> StandMove_SM`
- `StandMoveableAction -> StandMoveableAction_SM`
- `StandMoveOverwrite -> StandMoveOverwrite LayerGenerator`

### 5.2 Overwrite 分层关系

`StandMoveOverwrite LayerGenerator` 由两层组成：

- 第 0 层：`StandMoveLower_SM`
- 第 1 层：`StandMoveUpper_SM`

同时：

- `indexOfSyncMasterChild = 1`

这意味着在原始 HKX 中，上半身层是同步主层。

### 5.3 共享同步变量

`StandMoveUpper_SM` 与 `StandMoveableAction_SM` 共用同一个同步变量：

- 变量索引：`164`
- 变量名：`StateStateId_StandMoveableAction`

这个变量必须在 UE 里保留。

## 6. UE 架构设计

### 6.1 总体结构

创建一个总 `AnimBlueprint`：

- 资产：`/Game/Animation/Sekiro/C0000/Blueprints/ABP_Sekiro_C0000_Master`
- 骨骼：`/Game/Animation/Sekiro/C0000/Base/c0000_bindpose_Skeleton`

期望中的逻辑结构为：

1. 顶层主状态机：`Sekiro_MasterSubset_SM`
2. 主状态：
   - `StandMove`
   - `StandMoveableAction`
   - `StandMoveOverwrite`
3. 子结构：
   - `StandMove` 对应 `StandMove_SM`
   - `StandMoveableAction` 对应 `StandMoveableAction_SM`
   - `StandMoveOverwrite` 对应 `StandMoveLower_SM + StandMoveUpper_SM`

### 6.2 Overwrite 的 UE 表达

`StandMoveOverwrite` 在 UE 中不作为单动画状态，而是作为一个分层动画图：

- 下层基础：`StandMoveLower_SM`
- 上层覆盖：`StandMoveUpper_SM`
- 组合节点：`Layered Blend Per Bone`

同步语义：

- 以上半身层为同步主层
- 与 HKX 的 `indexOfSyncMasterChild = 1` 保持一致

## 7. 状态机设计

### 7.1 `StandMoveLower_SM`

保留原始 2 态结构：

- `StandMoveLowerLoop`，`stateId = 0`
- `StandMoveLowerStart`，`stateId = 5`

已确认的重要切换：

- `W_Attack3051` -> `StandMoveLowerLoop`
- `W_AttackBoundParry_Add01` -> `StandMoveLowerStart`
- `StandMoveLowerStart` 通过 `W_AttackBoundGuard_Add04` 返回 `StandMoveLowerLoop`

### 7.2 `StandMove_SM`

保留“主循环 + 多个一次性入口态”结构。

当前范围内至少还原以下状态：

- `StandMoveLoop`
- `StandMoveStart`
- `StandMoveStartFromFreeFall`
- `StandMoveStartFromFreeFallShortStiff`
- `StandMoveStartFromLandGroundPositioningJump`
- `StandWalkStop`
- `StandRunStop`
- `StandQuickTurnLeft180`
- `StandQuickTurnRight180`
- `StandQuickTurnMoveStartLeft180`
- `StandQuickTurnMoveStartRight180`
- `StandMoveQuickTurnLeft180`
- `StandMoveQuickTurnRight180`
- `StandQuickTurnLeft90`
- `StandQuickTurnRight90`
- `StandMoveStartFromSprint`
- `StandMoveLoopFromSprint`

关键入口事件示例：

- `W_Event3018` -> `StandMoveStart`
- `W_Event3026` -> `StandWalkStop`
- `W_Event3027` -> `StandRunStop`
- `W_Event3028` -> `StandQuickTurnRight180`
- `W_Event3029` -> `StandQuickTurnLeft180`
- `W_WideshotRightStart_mirror` -> `StandMoveStartFromSprint`
- `a000_00000000_End` -> `StandMoveLoopFromSprint`

### 7.3 `StandMoveUpper_SM`

保留“wildcard 事件入口 + 多个上半身动作状态”的结构。

当前范围内保留全部 24 个状态及其原始 `stateId`。

重要状态示例：

- `ItemPillTonicMove`
- `DeflectGuardToStandMove`
- `DeflectGuardToStandMoveVariation`
- `SubWeaponExpandMove`
- `SubWeaponExpand2Move`
- `SubWeaponExpand3Move`
- `GroundSubAttackCombo1Move`
- `GroundSubAttackCombo1ReleaseMove`
- `GroundSubAttackLockOnMove`
- `GroundSubAttackLockOnReleaseMove`
- `ItemGourdDrinkMove`
- `ItemGourdDrinkRepeatMove`
- `ItemGourdDrinkFailedMove`
- `ItemGourdDrinkRepeatFailedMove`
- `ItemAntiHallucinogenMove`
- `ItemAntiGhostBuffMove`
- `ItemStoneMove`
- `ItemPaperDollExchangeWhiteMove`
- `ItemOhagiMove`
- `ItemKakiMove`
- `ItemPotteryMove`

关键入口事件示例：

- `W_Attack3052` -> `ItemPillTonicMove`
- `W_Attack3053` -> `DeflectGuardToStandMove`
- `W_Move` -> `DeflectGuardToStandMoveVariation`
- `W_IdleUnique421` -> `ItemGourdDrinkMove`
- `W_IdleUnique422` -> `ItemGourdDrinkRepeatMove`
- `W_IdleUnique430` -> `ItemGourdDrinkFailedMove`
- `W_IdleUnique431` -> `ItemGourdDrinkRepeatFailedMove`

### 7.4 `StandMoveableAction_SM`

保留与 `StandMoveUpper_SM` 平行的“可移动动作”结构。

当前范围内保留全部 24 个状态及其原始 `stateId`。

重要状态示例：

- `ItemPillTonic`
- `DeflectGuardToStand`
- `DeflectGuardToStandVariation`
- `SubWeaponExpand`
- `SubWeaponExpand2`
- `SubWeaponExpand3`
- `GroundSubAttackCombo1Moveable`
- `GroundSubAttackCombo1ReleaseMoveable`
- `GroundSubAttackLockOnMoveable`
- `GroundSubAttackLockOnReleaseMoveable`
- `ItemGourdDrink`
- `ItemGourdDrinkRepeat`
- `ItemGourdDrinkFailed`
- `ItemGourdDrinkRepeatFailed`
- `ItemAntiHallucinogen`
- `ItemAntiGhostBuff`
- `ItemStone`
- `ItemPaperDollExchangeWhite`
- `ItemOhagi`
- `ItemKaki`
- `ItemPottery`

关键入口事件示例：

- `W_Attack3050` -> `DeflectGuardToStand`
- `W_Attack3079` -> `SubWeaponExpand`
- `W_DeflectGuardToStand` -> `GroundSubAttackCombo1Moveable`
- `W_Master` -> `DeflectGuardToStandVariation`
- `W_ItemInvalid` -> `ItemAntiGhostBuff`

## 8. 变量与事件映射

### 8.1 必须保留的变量

必须创建：

- `StateStateId_StandMoveableAction`，`int`

用途：

- 对齐只狼 HKX 中 `StandMoveUpper_SM` 与 `StandMoveableAction_SM` 的共享状态语义
- 作为后续将事件驱动逻辑汇总到单一状态 ID 时的基础变量

### 8.2 事件请求变量

由于 Monolith 当前的过渡规则写接口本质上是“过渡绑定一个 `bool` 变量”，不能直接把 Havok `eventId` 原样写入 UE 过渡图，所以 UE 侧采用一次性请求变量方案。

命名规则：

- `Req_<原事件名清洗后>`

示例：

- `Req_W_Event3018`
- `Req_W_AttackBoundParry_Add01`
- `Req_W_IdleUnique421`
- `Req_W_Move`

规则：

- 事件变量默认 `false`
- 逻辑触发时置 `true`
- 成功进入目标状态后由事件消费逻辑清零

### 8.3 返回变量

对明显“一次性动作播完后回主态”的状态，建立返回变量或结束条件：

- `Return_To_StandMove`
- `Return_To_StandMoveLowerLoop`
- `Return_To_StandMoveableAction_Idle`

优先级：

1. HKX 有明确返回事件时，优先按返回事件还原
2. HKX 无明确返回事件时，优先按动画播完返回

## 9. Monolith 实现边界

本节所说的“实现边界”，即前文提到的 Monolith 工具能力边界。

当前 Monolith 已确认可直接使用的动画写接口包括：

- `create_anim_blueprint`
- `add_state_to_machine`
- `add_transition`
- `set_transition_rule`
- `set_state_animation`
- `add_anim_graph_node`
- `connect_anim_graph_pins`
- `set_anim_graph_node_property`

关键约束：

- Monolith 当前非常适合“在已有状态机里补状态、补过渡、设状态动画”
- 但它不是“直接批量新建多个 AnimGraph 状态机节点”的一等公民接口

因此实际制作阶段采用以下策略：

1. 优先创建一个总 `AnimBlueprint`
2. 以默认可编辑的状态机图为基础，先构建顶层最小可运行主链路
3. 能直接创建的状态机与过渡，用 Monolith 原生动作落地
4. 如果“新增多个独立状态机图节点”受限，则在同一总 ABP 内采用最接近 HKX 的图结构表达，不更换整体设计目标

这意味着：

- “设计目标”仍然是按 `StandMove / StandMoveableAction / StandMoveOverwrite` 三段关系还原
- “制作路径”允许在 Monolith 能力边界内做最小必要的图结构折中

## 10. 验收标准

交付完成时应满足：

1. `ABP_Sekiro_C0000_Master` 可成功编译
2. 顶层主状态机存在并可读
3. `StandMove_SM` 的关键状态与入口事件可对照 HKX
4. `StandMoveLower_SM` 的 2 态链路存在
5. `StandMoveUpper_SM` 的 24 态入口映射被保留
6. `StandMoveableAction_SM` 的 24 态入口映射被保留
7. `StateStateId_StandMoveableAction` 被保留
8. `StandMoveOverwrite` 的上下半身分层关系被表达
9. 输出中文映射文档，至少包含：
   - `eventId`
   - `eventName`
   - `stateId`
   - `stateName`
   - `UE变量名`
   - `UE目标状态`

## 11. 失败回退策略

若 Monolith 在以下任一环节失败：

- 新建总 ABP
- 定位默认状态机
- 创建状态
- 创建过渡
- 给状态绑定动画
- 设置 AnimGraph 分层节点

则回退策略为：

1. 保留同一目标资产路径
2. 用 Monolith 能成功写入的最小图结构先落地
3. 将无法直接写入的部分记录到映射文档中
4. 不切换为另一套无关的动画架构

## 12. 本轮实现顺序

建议执行顺序：

1. 创建总 `AnimBlueprint`
2. 建立顶层主状态机骨架
3. 还原 `StandMoveLower_SM`
4. 还原 `StandMove_SM`
5. 还原 `StandMoveableAction_SM`
6. 还原 `StandMoveUpper_SM`
7. 搭建 `StandMoveOverwrite` 分层混合
8. 写入关键事件变量与返回变量
9. 编译并导出映射报告
