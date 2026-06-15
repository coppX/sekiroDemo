# `c0000_transition.dec.lua` 文档

## 1. 文件定位

`action/script/c0000_transition.dec.lua` 不是一个单纯的“动作表”文件，它更像是 `c0000` 玩家行为状态机中的过渡判定层。  
从当前仓库可直接观察到：

- `action/script/c0000.dec.lua` 中的 `Initialize()` 会调用 `ValidateOrderTableInit()`。
- `action/script/c0000.dec.lua` 中的 `UpdateState(current_hkb_state)` 会按顺序调用：
  - `Control(current_hkb_state)`
  - `Validate(current_hkb_state)`
  - `FireStateEndEvent(current_hkb_state)`

这说明 `c0000_transition.dec.lua` 至少承担三类职责：

1. 初始化行为判定表。
2. 在每个状态更新时决定是否切换到新的 behavior。
3. 在状态结束或更新后补发事件、收尾状态、同步附加行为。

## 2. 它在整个 `c0000` 调度链中的位置

可以把当前几个文件理解成下面的关系：

```text
c0000_define.dec.lua
  提供常量:
  STYLE_TYPE_*, STATE_TYPE_*, SP_EF_REF_*, ACTION_GUIDE_*, THROWABLE_STATE_* ...

c0000_cmsg.dec.lua
  提供状态元数据:
  g_paramHkbState[HKB_STATE_*] = { ... , STYLE_TYPE_*, STATE_TYPE_* }

c0000.dec.lua
  提供入口与主循环:
  Initialize()
  Update()
  InitState()
  UpdateState()
  UpdateAddState()

c0000_transition.dec.lua
  提供核心过渡逻辑:
  ValidateOrderTableInit()
  Validate()
  FireStateEndEvent()
  _ActivateBehavior()
  _ActivateAddBehavior()
  各类 _Update* / _set* / _Validate* 辅助函数
```

直接观察结论：

- `c0000.dec.lua` 更像“调度器/壳层”。
- `c0000_transition.dec.lua` 更像“规则引擎 + 过渡执行器”。
- `c0000_define.dec.lua` 提供枚举和特殊效果常量。
- `c0000_cmsg.dec.lua` 提供大量 `HKB_STATE_*` 与 `STYLE_TYPE_*` / `STATE_TYPE_*` 的映射关系。

## 3. 文件顶部的行为枚举体系

文件开头先定义了大量 `BEH_*` / `BEH_ADD_*` 常量，例如：

- 反应类：`BEH_R_DEATH`、`BEH_R_HIT_DAMAGE`、`BEH_R_FALL`、`BEH_R_LAND`
- 行动类：`BEH_A_GROUND_ATTACK`、`BEH_A_GROUND_JUMP`、`BEH_A_CROUCH_START`
- 附加行为类：`BEH_ADD_R_SUB_WEAPON_EXPAND`、`BEH_A_ADD_ACTION_INPUT_JUMP`

从命名可以直接看出，脚本把行为至少分为两层：

- 主 behavior：由 `BEH_R_*` 与 `BEH_A_*` 描述，通常对应主状态切换或主要动作/反应。
- Add behavior：由 `BEH_ADD_*` 描述，通常对应附加层、补充反应或附加输入反馈。

这里的 `R` 很明显表示 reaction，`A` 表示 action。这个判断来自命名和后续表结构的直接对应关系，不只是猜测。

## 4. 关键数据结构

### 4.1 `g_behaviorValidateOrder`

`g_behaviorValidateOrder` 是主行为判定的优先级序列。  
它把 behavior id 和对应验证函数绑定在一起，例如：

- `{BEH_R_THROW_DEATH, g_ValidateReactionTable[BEH_R_THROW_DEATH]}`
- `{BEH_R_DEATH, g_ValidateReactionTable[BEH_R_DEATH]}`
- `{BEH_A_ITEM_USE, g_ValidateActionTable[BEH_A_ITEM_USE]}`
- `{BEH_A_GROUND_JUMP, g_ValidateActionTable[BEH_A_GROUND_JUMP]}`

这个表的重要性很高，因为 `Validate()` 最终是按顺序遍历它，找到第一个满足条件的主 behavior。

### 4.2 `g_behaviorTable`

`g_behaviorTable[behaviorId] = { ... }` 为每个 behavior 提供一个按 style 排布的可用性表。  
表长与 `STYLE_TYPE_NUM = 16` 对应。

结合 `c0000_define.dec.lua` 可知 style 至少包括：

- `STYLE_TYPE_STAND`
- `STYLE_TYPE_CROUCH`
- `STYLE_TYPE_COVER`
- `STYLE_TYPE_HANG`
- `STYLE_TYPE_FREE_FALL`
- `STYLE_TYPE_WIRE_FALL`
- `STYLE_TYPE_SWIM`
- `STYLE_TYPE_DIVE`
- `STYLE_TYPE_AGING_*`

因此 `g_behaviorTable` 的作用不是“是否触发”，而是“某个 behavior 在某种 style 下是否允许参与判定”。

### 4.2.1 `g_behaviorTable` 的 16 列对应什么

结合 `action/script/c0000_define.dec.lua` 的定义，可以把 `g_behaviorTable` 每一列按顺序解释为：

| 列序号 | style 常量 |
| --- | --- |
| 1 | `STYLE_TYPE_STAND` |
| 2 | `STYLE_TYPE_CROUCH` |
| 3 | `STYLE_TYPE_GROUND_GUARD` |
| 4 | `STYLE_TYPE_COVER` |
| 5 | `STYLE_TYPE_COVER_LOOK` |
| 6 | `STYLE_TYPE_HANG` |
| 7 | `STYLE_TYPE_FREE_FALL` |
| 8 | `STYLE_TYPE_WIRE_FALL` |
| 9 | `STYLE_TYPE_SPRINT` |
| 10 | `STYLE_TYPE_CLING` |
| 11 | `STYLE_TYPE_SWIM` |
| 12 | `STYLE_TYPE_DIVE` |
| 13 | `STYLE_TYPE_AGING_STAND` |
| 14 | `STYLE_TYPE_AGING_FALL` |
| 15 | `STYLE_TYPE_AGING_SWIM` |
| 16 | `STYLE_TYPE_AGING_DIVE` |

也就是说，如果看到：

```lua
[BEH_R_LAND] = {0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0}
```

可以直接读成：

- `BEH_R_LAND` 只会在 `STYLE_TYPE_FREE_FALL` 与 `STYLE_TYPE_AGING_FALL` 下参与判定。

再比如：

```lua
[BEH_A_SWIM_MOVE_START] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0}
```

它说明：

- `BEH_A_SWIM_MOVE_START` 只在 `STYLE_TYPE_SWIM` 下有效。

### 4.2.2 如何阅读 `g_behaviorTable`

把 `g_behaviorTable` 当成“行为适用域矩阵”会比较准确：

- 行：behavior
- 列：style
- 值：`1/0`

它不表达优先级，只表达“当前 style 是否允许这条规则进入候选集”。

真正的执行顺序仍然由：

- `g_behaviorValidateOrder`
- `g_behaviorValidateOrderAddReaction`
- `g_behaviorValidateOrderAddAction`

控制。

换句话说，`g_behaviorTable` 决定的是“能不能参加比赛”，而 `g_behaviorValidateOrder` 决定的是“谁先出场”。

### 4.2.3 从矩阵中能直接看出的设计模式

从当前表里可以直接观察到几种明显模式：

- 强制反应类 behavior 通常覆盖多个 style。
  例如 `BEH_R_DEATH`、`BEH_R_SPECIAL_DAMAGE` 在很多 style 下都为 `1`。
- 强风格绑定行为只会出现在极少数 style。
  例如 `BEH_A_SWIM_TO_DIVE` 只属于 `STYLE_TYPE_SWIM`，`BEH_R_DIVE_TO_SWIM` 只属于 `STYLE_TYPE_DIVE`。
- 空中类行为集中在 `STYLE_TYPE_FREE_FALL` / `STYLE_TYPE_WIRE_FALL`。
  例如 `BEH_A_AIR_ATTACK`、`BEH_A_AIR_WIRE_SHOOT`、`BEH_A_AIR_HANG_START`。
- 老年状态（`AGING_*`）并不是全量复用普通 style，而是有单独列。
  例如 `BEH_A_AGING_ATTACK`、`BEH_A_AGING_ACTION`、`BEH_R_CURE_AGING`。
- 部分行为会跨地面与 sprint 共享。
  例如 `BEH_A_GROUND_ATTACK`、`BEH_A_GROUND_STEP` 在 `STYLE_TYPE_SPRINT` 也常常有效。

这说明这套系统不是“每个 style 独立写一遍行为”，而是：

```text
先用 style 做粗筛
  -> 再用 validate 函数做细判
  -> 最后由激活函数把 behavior 转成事件
```

### 4.3 `g_ValidateReactionTable` / `g_ValidateActionTable`

这两个大表分别把：

- reaction behavior
- action behavior

映射到具体判定函数。

例如：

- `g_ValidateReactionTable[BEH_R_THROW_DEATH] = function (...) ... end`
- `g_ValidateActionTable[BEH_A_GROUND_MOVE_START] = function (...) ... end`

也就是说，真正的“能不能切”不在 `Validate()` 里硬编码，而是分散在这些细粒度验证函数中。

### 4.4 `g_addBehaviorTable` / `g_behaviorValidateOrderAddReaction`

Add behavior 也复用了相同思路：

- `g_addBehaviorTable`：某个 add behavior 在哪些 style 下有效
- `g_behaviorValidateOrderAddReaction`：附加 reaction 的判定顺序
- `g_behaviorValidateOrderAddAction`：附加 action 的判定顺序

## 5. `ValidateOrderTableInit()`：把“静态规则表”编译成按 style 分类的运行时表

`ValidateOrderTableInit()` 做的事情很关键：

1. 遍历 `g_behaviorValidateOrder`
2. 读取每个 behavior 在 `g_behaviorTable` 中的 style 可用性
3. 按 style 把行为判定项写入 `g_behaviorValidateOrderByStyle`
4. 对 add reaction / add action 也做同样处理

可以把它理解为一次启动期的“预编译”：

```text
全局优先级表
  -> 根据 style 过滤
  -> 生成按 style 分桶的验证顺序表
  -> 运行时直接查当前 style 对应的表
```

这能减少运行时每帧重复判断“当前 style 能不能使用这个 behavior”。

## 6. `Validate(current_hkb_state)`：主过渡入口

`Validate()` 是整份脚本里最核心的函数之一。

### 6.1 输入来源

它先通过：

- `g_paramHkbState[current_hkb_state][PARAM_HKB_STATE__STYLE_TYPE]`
- `g_paramHkbState[current_hkb_state][PARAM_HKB_STATE__STATE_TYPE]`

取得当前状态所属的 style 和 state type。

这里的 `g_paramHkbState` 不在本文件内定义，而是在 `action/script/c0000_cmsg.dec.lua` 中以超大映射表的形式出现。

### 6.2 主流程

`Validate()` 逻辑可以概括成：

```text
读取 currentStyle / currentState
  -> 先处理 add behavior
  -> 再按优先级寻找一个主 behavior
  -> 如果找到:
       停止 auto aim
       激活 behavior
       按条件清理 throw / sound / 其他状态
```

### 6.3 Add behavior 先于主 behavior

内部局部函数 `f2_local3()` 会先遍历：

- `g_addBehaviorReactionValidateOrderByStyle[currentStyle]`
- `g_addBehaviorActionValidateOrderByStyle[currentStyle]`

只要对应验证函数返回 `TRUE`，就调用 `_ActivateAddBehavior(...)`。

这说明 add behavior 不是“最后补发”，而是和主 behavior 并行的一层附加状态控制。

### 6.4 主 behavior 取“第一个命中的规则”

局部函数 `f2_local2()` 遍历 `g_behaviorValidateOrderByStyle[currentStyle]`，对每个条目执行验证函数。  
一旦某个验证函数返回 `TRUE`，就立即返回对应 behavior id。

这意味着：

- 行为判定存在强优先级。
- 如果多个条件同时成立，排在前面的 behavior 会覆盖后面的 behavior。

例如，`g_behaviorValidateOrder` 中死亡、受击、破防、落地等 reaction 都排在大量普通 action 之前，这符合“强制反应优先于输入动作”的设计。

### 6.5 后处理

一旦 `nextBehavior ~= BEH_NONE`：

- 调用 `_StopAutoAim()`
- 调用 `_ActivateBehavior(current_hkb_state, nextBehavior)`
- 某些投技相关 state 会触发 `act(136, 0)` 清理 throw 相关状态
- 大量“纯移动/纯过渡类 behavior”之外的行为会触发 `act(3029, EZ_STATE_REF_SND_NPC_TALK_INTERRUPT)`，看起来是在打断 NPC 对话相关声音状态

**推测：** `act(...)` 是引擎侧行为命令接口，不在本文件中定义；从使用方式看，它承担“设置状态 / 发控制命令 / 切换特效 / 切换提示 / 声音控制”等作用。这个结论来自调用模式，而不是本仓库中有明确 API 文档。

## 7. `FireStateEndEvent(current_hkb_state)`：状态末尾的事件分发与收尾

`FireStateEndEvent()` 的体量很大，说明它承担大量“状态结束后的归并处理”。

直接可观察到的职责包括：

### 7.1 记录上一次动作上下文

它会更新：

- `g_isUpperAction`
- `g_beforeMoveSpeedIndex`
- `g_beforeMoveDirection`

这些值随后会被其他逻辑用于状态过渡或混合判断。

### 7.2 处理死亡 / 复活 / 死亡循环事件

函数中有一大段根据：

- `currentState`
- 当前 `HKB_STATE_*`
- `env(1000)`、`env(3028)`、`env(3036, SP_EF_REF_TAE_ENABLE_REVIVAL)` 等环境条件

来触发不同事件，例如：

- `FireEvent("W_GroundRevival")`
- `FireEvent("W_LandRevival")`
- `FireEvent("W_SwimRevival")`
- `FireEvent("W_DiveRevival")`
- `FireEvent("W_GroundDeathLoop")`

这说明本文件不仅判定“能否切状态”，也负责把底层 damage/death state 转换成更高层的 HKB event。

### 7.3 处理 crouch / cover / hang / throw 后的回归

在 `env(339, 0) == TRUE` 分支下，函数会把某些状态结束后导回：

- `W_CrouchIdle`
- `W_CoverIdle`
- `W_FreeFall`
- `ExecHangIdle(current_hkb_state)`
- `W_StandMove`

这表明脚本在做一种“结束后落回哪个待机/循环状态”的统一管理。

### 7.4 处理对话 /窃听 /特殊事件收尾

从整个函数的事件名和 `HKB_STATE_EVENT*` / `HKB_STATE_EAVESDROP*` 相关分支来看，它也处理事件状态结束后的收束。

## 8. `Control(current_hkb_state)`：比 `Validate()` 更宽的状态控制层

虽然 `Validate()` 决定“切到哪个 behavior”，但 `Control()` 负责的范围更广。

从可直接读出的代码看，它至少做这些事：

### 8.1 同步基础运行状态

- 更新 `g_forceCrouch`
- 更新 `g_beforeFireLand`
- 记录/清理投技动画 id
- 响应特定 event id（如 `710200` 一类）

### 8.2 按 `STATE_TYPE_*` 做通用控制

例如：

- 待机类 state：刷新速度、输入、auto aim
- 攻击类 state：设置 NTC 攻击动画
- Guard / Sub Guard：附加 `SP_EFFECT_STYLE_DEFLECT_GUARD`
- Item Use：调用 `act(150)` 等
- Death / Throw Death：调用 `act(3032)`，并设置 prone/fall/death 选择器
- Event / Talk / Eavesdrop：配置 action button、对话声音、事件状态

这部分让 `Control()` 更像“当前 state 的运行时管理器”，而不只是过渡器。

### 8.3 按 `STYLE_TYPE_*` 做 style-specific 控制

这是 `Control()` 另一大块内容。  
它会针对：

- `STYLE_TYPE_STAND`
- `STYLE_TYPE_CROUCH`
- `STYLE_TYPE_SWIM`
- `STYLE_TYPE_DIVE`
- `STYLE_TYPE_AGING_STAND`
- `STYLE_TYPE_AGING_FALL`

分别设置：

- 主菜单可用性
- action button 类型
- throwable state
- move distance 预计算
- water / dive / wire move 特殊行为
- 某些 style 下的 `act(101, TRUE)` / `act(2018)` / `act(3037)` 等控制

从架构上看，`Control()` 将“当前状态属于哪个抽象姿态(style)”作为第一层分流条件。

### 8.4 管理引导提示（Action Guide）

文件中可看到多个闭包与判断，最终触发：

- `act(3030, ACTION_GUIDE_COVER_START, ACTION_ARM_WALL_HANG)`
- `act(3030, ACTION_GUIDE_HANG_START, ACTION_ARM_WALL_HANG)`
- `act(3030, ACTION_GUIDE_SWIM_TO_DIVE, ACTION_ARM_SP_MOVE)`
- `act(3030, ACTION_GUIDE_DIVE_TO_SWIM, ACTION_ARM_JUMP)`

结合 `c0000_define.dec.lua` 中的 `ACTION_GUIDE_*` 常量，这部分非常像 UI 或交互提示层。

### 8.5 更新多个“后置系统”

在函数末尾还会调用：

- `_UpdateFallProtection(current_hkb_state)`
- `_UpdateAutoAim()`
- `_UpdateThrowAnimSelector()`
- `_UpdateNextThrowInfo(current_hkb_state)`

说明 `Control()` 也是多个子系统的汇合点。

## 9. 本文件中的辅助函数族

除了三大核心函数，本文件还定义了很多辅助函数，可以按职能分组理解：

### 9.1 速度 / 方向 / locomotion

- `_SpeedUpdate(current_hkb_state)`
- `_DiveSpeedUpdate(current_hkb_state)`
- `_MoveDirectionUpdate()`
- `GetLocomotionType()`

### 9.2 跳跃 / step / quick turn / wire move

- `_SetJumpDirection(...)`
- `_GroundQuickTurn(current_hkb_state)`
- `_set4DirJumpDir(...)`
- `_set8DirStepDir(...)`
- `_fireGroundStep(current_hkb_state)`
- `GetWireMoveStartIndex(current_hkb_state)`

### 9.3 自动瞄准 / 投技 / 落地保护

- `_StartAutoAim()`
- `_UpdateAutoAim()`
- `_StopAutoAim()`
- `_UpdateThrowAnimSelector()`
- `_UpdateNextThrowInfo(current_hkb_state)`
- `_UpdateFallProtection(current_hkb_state)`

### 9.4 具体行为执行

- `_ActivateBehavior(current_hkb_state, next_behavior)`
- `_ActivateAddBehavior(current_hkb_state, next_add_behavior)`

这些函数才真正把 behavior id 转成事件或状态切换执行。

## 10. `g_behaviorTable`、验证函数、激活函数三者的关系

这三个层次最好放在一起理解：

```text
g_behaviorTable
  决定这个 behavior 在当前 style 下是否允许被考虑

g_ValidateReactionTable / g_ValidateActionTable
  决定当前帧/当前状态下，这个 behavior 的触发条件是否满足

_ActivateBehavior / _ActivateAddBehavior
  决定一旦命中，该 behavior 最终转换成哪个 W_* 事件、哪些变量设置、哪些 act(...) 调用
```

所以一次完整的主 behavior 触发链，大致是：

```text
current_hkb_state
  -> g_paramHkbState 解析出 style/state type
  -> g_behaviorTable 过滤当前 style 不可用的 behavior
  -> g_behaviorValidateOrder 按优先级遍历
  -> 对应 g_Validate*Table 函数返回 TRUE
  -> _ActivateBehavior() 发出具体 W_* 事件
```

这比“直接在一个大 if 里判断并切状态”更模块化，也更容易按 style 扩展。

## 11. `_ActivateAddBehavior()`：附加行为如何落地

`_ActivateAddBehavior(current_hkb_state, next_add_behavior)` 的分支数量不算太夸张，但它把 add behavior 的用途讲得很清楚。

### 11.1 Add behavior 的主要用途

从分支可直接看出，附加行为主要覆盖这些场景：

- 附加混合层切换
  - `BEH_ADD_R_SUB_WEAPON_EXPAND`
  - `BEH_ADD_R_NIGHTVISION_START`
  - `BEH_ADD_R_NIGHTVISION_END`
  - `BEH_ADD_R_NON_COMBAT_AREA_ENTER`
  - `BEH_ADD_R_NON_COMBAT_AREA_LEAVE`
- 附加 damage / deflect 反馈
  - `BEH_ADD_R_HIT_DAMAGE`
  - `BEH_ADD_R_SWIM_HIT_DAMAGE`
  - `BEH_ADD_R_GUARD_DAMAGE`
  - `BEH_ADD_R_BREAK_DAMAGE`
  - `BEH_ADD_R_SPECIAL_DAMAGE`
- Add input resend
  - `BEH_ADD_R_ADD_ACTION_INPUT_RESEND`
- 附加骨骼/手部可视层
  - `BEH_ADD_R_BARE_HAND_RIGHT_START`
  - `BEH_ADD_R_BARE_HAND_RIGHT_END`

### 11.2 它通常做哪些动作

`_ActivateAddBehavior()` 常见的操作模式是：

1. 先设定某个 blend 变量，例如：
   - `SetVariable("AddSubWeaponBlend", 1)`
   - `SetVariable("AddActionBlend", 1)`
   - `SetVariable("AddDamageBlend", 1)`
2. 再发一个 `W_Add*` 或相关事件：
   - `W_AddSubWeaponExpand`
   - `W_AddNightvisionStart`
   - `W_AddDamageStart`
   - `W_AddActionInputJump`

这说明 add behavior 更像“附加层动画/效果/输入提示”的执行器，而不是主体 locomotion 或主状态流转。

### 11.3 `BEH_ADD_R_ADD_ACTION_INPUT_RESEND` 很值得注意

这个分支会检查一串 `SP_EF_REF_TAE_ENABLE_ADD_ACTION_INPUT_*` 特效开关，然后重新发出：

- `W_AddActionInputJump`
- `W_AddActionInputUseItem`
- `W_AddActionInputCrouch`
- `W_AddActionInputAttack`
- `W_AddActionInputGuard`
- `W_AddActionInputSubAttack`
- `W_AddActionInputWireShoot`
- `W_AddActionInputWallHang`
- `W_AddActionInputKick`
- `W_AddActionInputSubWeaponChange`

从代码表现看，这一支很像“把当前允许的附加输入重新推送到 add layer”。

**推测：** 这可能用于提示重发、输入窗口重建，或右手/附加层 UI 与动画同步。当前仓库没有更直接的引擎说明。

## 12. `_ActivateBehavior()`：主行为如何落地为 `W_*` 事件

`_ActivateBehavior(current_hkb_state, next_behavior)` 是整个文件最重要的执行器之一。  
它的结构非常明确：

- 先按 `next_behavior` 分类
- 在每个分支里读取 `env(...)` / `hkbGetVariable(...)`
- 设置 selector、damage direction、blend、death type 等变量
- 最后通过 `FireEvent(...)` 或 `FireEventNoReset(...)` 进入真正的 HKB 事件流

### 12.1 它不是简单的一对一映射

这里不能把它理解成：

```text
BEH_X -> W_X
```

因为很多 behavior 都会继续细分：

- 取决于 `currentStyle`
- 取决于 `damageType`
- 取决于 `damageLevel`
- 取决于元素属性，如火 / 雷 / 弱雷
- 取决于若干 `SP_EF_REF_*` 开关

也就是说，一个 behavior 只是“高层语义槽位”，真正落地时还会二次分流。

### 12.2 典型模式 1：死亡类 behavior

`BEH_R_DEATH` 是最明显的例子。

它会继续根据：

- `DAMAGE_TYPE_FORCE_DEATH`
- `DAMAGE_TYPE_DEATH_FALLING`
- `DAMAGE_TYPE_FALL_DEAD_RETURN`
- `DAMAGE_TYPE_LAND_DEAD_RETURN`
- `DAMAGE_TYPE_LAND_DEAD`

以及 `currentStyle` 是否是：

- `STYLE_TYPE_FREE_FALL`
- `STYLE_TYPE_WIRE_FALL`
- `STYLE_TYPE_SWIM`
- `STYLE_TYPE_DIVE`
- `STYLE_TYPE_AGING_FALL`

再决定发出：

- `W_DiveForceDeath`
- `W_FallDeathStart`
- `W_LandDeadReturnStart`
- `W_SwimDeathStart`
- `W_DiveDeathStart`
- `W_GroundDeathStart`
- `W_GroundDeathStartElectricShock`
- `W_GroundDeathStartPoison`

这说明 `BEH_R_DEATH` 在逻辑层只是“进入死亡处理”，而不是某一个具体动作。

### 12.3 典型模式 2：普通受击类 behavior

`BEH_R_HIT_DAMAGE` 也不是一个单事件，它会按：

- 空中/挂墙/钢索坠落
- crouch
- 普通地面
- damage level
- 特定义手（如 `WEP_MOTION_CATEGORY_074`）

分流到不同事件，例如：

- `W_AirDamageSmall`
- `W_AirDamageLargeStart`
- `W_StandDamageSmall`
- `W_StandDamageMiddle`
- `W_StandDamageLarge`
- `W_CrouchDamageSmall`
- `W_CrouchDamageLarge`
- `W_SubAttackJumpReady`

因此文档里更合理的说法应该是：

- `BEH_R_HIT_DAMAGE` 负责统一接收普通受击语义；
- `_ActivateBehavior()` 再把它精化成具体受击状态。

### 12.4 典型模式 3：移动 / 落地 / 姿态切换类 behavior

从分支列表上看，下面这些 behavior 也是独立大类：

- `BEH_R_FALL`
- `BEH_R_LAND`
- `BEH_R_LAND_WIRE`
- `BEH_R_LAND_READY`
- `BEH_R_LAND_WATER`
- `BEH_R_STAND_MOVE_TO_SWIM`
- `BEH_R_SWIM_TO_STAND_MOVE`
- `BEH_R_DIVE_TO_SWIM`
- `BEH_A_GROUND_MOVE_START`
- `BEH_A_GROUND_MOVE_STOP`
- `BEH_A_SWIM_MOVE_START`
- `BEH_A_DIVE_MOVE_START`
- `BEH_A_SWIM_TO_DIVE`

这说明这套 behavior 系统并不只服务于 combat，也覆盖 locomotion、落地反馈、地面/水面/潜水之间的姿态切换。

### 12.5 典型模式 4：输入动作类 behavior

后半段大量分支属于玩家可主动触发的动作：

- `BEH_A_GROUND_ATTACK`
- `BEH_A_GROUND_RELEASE_ATTACK`
- `BEH_A_GROUND_SP_ATTACK`
- `BEH_A_GROUND_SUB_ATTACK`
- `BEH_A_ITEM_USE`
- `BEH_A_GROUND_WIRE_SHOOT`
- `BEH_A_CROUCH_START`
- `BEH_A_COVER_START`
- `BEH_A_GROUND_HANG_START`
- `BEH_A_AIR_ATTACK`
- `BEH_A_AIR_SP_ATTACK`
- `BEH_A_AIR_SUB_ATTACK`

这部分通常会：

- 先设置 selector / direction / 资源相关变量
- 再发出目标 `W_*` 事件

**直接观察：** `Validate()` 负责“当前输入是否能转成某个行为”，`_ActivateBehavior()` 负责“这个行为应该进入哪一个具体动画状态”。

## 13. `_ActivateBehavior()` 分支分组速览

如果不逐个读完整个函数，可以先按分组理解：

### 13.1 反应类

- Throw 相关：`BEH_R_THROW_DEATH`、`BEH_R_THROW_KILL`、`BEH_R_THROW_ESCAPE`
- Death 相关：`BEH_R_DEATH`
- Damage 相关：`BEH_R_HIT_DAMAGE`、`BEH_R_SPECIAL_DAMAGE`、`BEH_R_AGING_DAMAGE`
- Guard / Break 相关：`BEH_R_GUARD_DAMAGE`、`BEH_R_SWIM_GUARD_DAMAGE`、`BEH_R_BREAK_DAMAGE`、`BEH_R_AIR_BREAK_DAMAGE`
- 落地/跌落相关：`BEH_R_FALL`、`BEH_R_LAND`、`BEH_R_LAND_WIRE`、`BEH_R_LAND_READY`、`BEH_R_LAND_WIRE_READY`
- 水体/姿态切换：`BEH_R_LAND_WATER`、`BEH_R_STAND_MOVE_TO_SWIM`、`BEH_R_SWIM_TO_STAND_MOVE`、`BEH_R_DIVE_TO_SWIM`
- 交互/事件：`BEH_R_NPC_TALK_START`、`BEH_R_NPC_TALK_END`、`BEH_R_NPC_TALK_ACTION`、`BEH_R_NON_COMBAT_AREA_ENTER`

### 13.2 行动类

- 地面移动：`BEH_A_GROUND_MOVE_START`、`BEH_A_GROUND_MOVE_STOP`、`BEH_A_GROUND_MOVE_SPEED_CHANGE`
- 水中/潜水移动：`BEH_A_SWIM_MOVE_START`、`BEH_A_DIVE_MOVE_START`、`BEH_A_DIVE_MOVE_UP_START`
- 跳跃/转身：`BEH_A_GROUND_JUMP`、`BEH_A_WALL_JUMP`、`BEH_A_GROUND_QUICK_TURN`、`BEH_A_SPRINT_QUICK_TURN`
- 空中动作：`BEH_A_AIR_ATTACK`、`BEH_A_AIR_SP_ATTACK`、`BEH_A_AIR_SUB_ATTACK`、`BEH_A_AIR_WIRE_SHOOT`
- 地面战斗：`BEH_A_GROUND_ATTACK`、`BEH_A_GROUND_SP_ATTACK`、`BEH_A_GROUND_SUB_ATTACK`
- 防御姿态：`BEH_A_DEFLECT_GUARD_START`、`BEH_A_DEFLECT_GUARD_CONTINUE`、`BEH_A_DEFLECT_GUARD_END`
- 姿态/场景动作：`BEH_A_CROUCH_START`、`BEH_A_COVER_START`、`BEH_A_GROUND_HANG_START`
- 其他输入桥接：`BEH_A_ADD_ACTION_INPUT_JUMP`、`BEH_A_ADD_SUB_WEAPON_CHANGE`

这个分组方式比按代码顺序硬读更适合建立整体脑图。

## 14. 与其他文件的依赖关系

### 10.1 `action/script/c0000.dec.lua`

直接依赖关系最明确：

- `Initialize()` 调 `ValidateOrderTableInit()`
- `UpdateState()` 调 `Control()`、`Validate()`、`FireStateEndEvent()`
- `UpdateAddState()` 会处理附加状态，如 `HKB_STATE_ADD_SUB_WEAPON_CHANGE`

因此可以把 `c0000.dec.lua` 看成宿主文件，而 `c0000_transition.dec.lua` 是其核心逻辑实现层。

### 10.2 `action/script/c0000_define.dec.lua`

这个文件提供本文件大量直接使用的常量，包括：

- `STYLE_TYPE_*`
- `STATE_TYPE_*`
- `SP_EF_REF_*`
- `ACTION_GUIDE_*`
- `THROWABLE_STATE_*`
- 以及大量 `HKB_STATE_*`

没有这个常量层，`c0000_transition.dec.lua` 几乎不可读。

### 10.3 `action/script/c0000_cmsg.dec.lua`

这个文件最关键的贡献是 `g_paramHkbState`。  
`Validate()` 与 `Control()` 都依赖它把 `current_hkb_state` 映射到：

- style type
- state type

换言之，`c0000_transition.dec.lua` 本身不定义状态元数据，它只是消费状态元数据。

### 10.4 `TAE Animation Designations.md`

这是仓库里的补充参考资料，不是脚本直接依赖。  
它能帮助把某些事件号/动画区段和游戏动作类别对应起来，例如：

- `a000_201000 --> a000_201987` 对应 Jump
- `a000_202000 --> a000_202710` 对应 Hook
- `a000_210000 --> a000_210161` 对应 Swimming and Death in the Water
- `a000_220001 --> a000_220027` 对应 Eavesdropping

**推测：** 这类资料有助于解释本文件中 jump / wire / swim / eavesdrop / event 相关状态簇的游戏语义，但它不是代码级证据源，不能替代脚本本身。

## 15. 可以直接抓住的主流程

如果只想快速理解这份脚本，建议抓住下面这条主链：

```text
Initialize()
  -> ValidateOrderTableInit()

每帧/每状态更新:
UpdateState(current_hkb_state)
  -> Control(current_hkb_state)
  -> Validate(current_hkb_state)
  -> FireStateEndEvent(current_hkb_state)
```

其中：

- `Control()` 负责“当前状态怎么运行、开什么输入/提示/特效/投技规则”
- `Validate()` 负责“当前状态下一步应该切到哪个 behavior”
- `FireStateEndEvent()` 负责“状态结束后补发哪个事件、回落到哪个 idle/loop、怎么处理死亡/复活/对话尾声”

## 16. 观察与推测分界

### 可直接确认的事实

- 本文件定义了完整的 behavior 枚举、验证表、style 可用性表和主过渡逻辑。
- `Validate()` 通过 `g_paramHkbState` 获取当前 style/state，并按优先级选择 behavior。
- `FireStateEndEvent()` 大量处理死亡、复活、idle 回落、event/talk/eavesdrop 收尾。
- `Control()` 负责 state-type 与 style-type 双层分流的运行时控制。

### 带推测性质的解释

- `act(...)` 很可能是引擎命令接口。
- `env(...)` 很可能是环境/输入/特殊效果/状态查询接口。
- `hkbFireEvent(...)`、`hkbGetVariable(...)` 等显然属于 HKB/Havok Behavior 侧接口，但本仓库没有提供其正式 API 说明。
- Add behavior 很像“附加层状态/输入回显/附加反应系统”，但具体在引擎里的渲染或混合机制，这里无法仅凭脚本完全证明。

## 17. 目前最值得继续深挖的点

如果后续要继续扩展这份文档，优先级最高的方向是：

1. 继续展开 `_ActivateBehavior()` 的后半段，把各个 action behavior 到 `W_*` 事件的映射整理成表格。
2. 为 `g_behaviorTable` 抽取一份“代表性 behavior x style”矩阵摘要，帮助快速查阅。
3. 整理 `g_ValidateReactionTable` / `g_ValidateActionTable` 中最重要的几类条件：
   - death / damage / guard / break
   - jump / wire / swim / dive
   - item / sub weapon / talk / non-combat
4. 从 `g_paramHkbState` 反推出常见 `HKB_STATE_*` 属于哪些 `STYLE_TYPE_*` / `STATE_TYPE_*` 簇。

这三项做完之后，`c0000_transition.dec.lua` 的整体结构会更加清晰。
