# SekiroDemo 项目总结：状态机设计与 C++/Lua 调用链

最后更新：2026-06-15

## 1. 项目概览

`SekiroDemo` 是一个基于 Unreal Engine 5.7 的只狼机制复刻/实验工程。当前项目已经从早期的资产导入阶段，推进到“主角动作状态机 + 敌人 AI/Lua 脚本 + 动画事件驱动战斗”的运行时阶段。

当前核心内容包括：

- 主角 `C0000` 的移动、转身、拔刀/收刀、防御、地面五段连招等动作逻辑。
- 基于 TAE 动画事件的攻击窗口、连招窗口、武器显示切换和 hitbox 创建。
- 主角通过帧事件创建攻击碰撞体，对敌人造成伤害。
- 敌人基础行走、巡逻、索敌、接近、攻击、受击、死亡逻辑。
- 正面忍杀的分段流程：主角 `ThrowAtk/ThrowKill` 与敌人 `ThrowDef/ThrowDefDeath` 分开驱动。
- UnLua 作为 C++ 与 Lua 之间的脚本桥接层。

核心代码位置：

| 模块 | 路径 | 职责 |
| --- | --- | --- |
| 主角运行时 | `Source/SekiroDemo/SekiroC0000PreviewCharacter.*` | 主角输入、AnimBP 变量写入、Lua 绑定、hitbox、忍杀 |
| 分层状态机组件 | `Source/SekiroDemo/SekiroLayeredStateMachineComponent.*` | 保存 Base/Action/Reaction 三层运行态 |
| 环境查询组件 | `Source/SekiroDemo/SekiroEnvQueryComponent.*` | 向 Lua/AnimBP 暴露 env 查询、输入、特效、武器和投技状态 |
| 敌人 Actor | `Source/SekiroDemo/SekiroEnemyCharacter.*` | 敌人角色、武器挂载、受击、死亡、忍杀受身 |
| 敌人脚本脑 | `Source/SekiroDemo/SekiroEnemyScriptBrainComponent.*` | 敌人感知、目标、AI 状态、Lua 调度、移动和攻击接口 |
| 敌人动画桥 | `Source/SekiroDemo/SekiroEnemyAnimBridgeComponent.*` | 将 AI 命令写入敌人 AnimBP 变量 |
| 主角 Lua | `Content/Script/Sekiro/C0000/*.lua` | 主角动作状态机、事件规格、状态转换、AnimBP 变量同步 |
| 敌人 Lua | `Content/Script/Sekiro/Enemy/*.lua` | 原版 AI Lua 适配、GoalStack、敌人 logic/battle 脚本 |

## 2. 状态机整体设计

当前项目里存在两类状态机：

1. 主角动作状态机：负责动画语义、动作层、反应层和 AnimBP 驱动。
2. 敌人 AI 语义状态机：负责敌人的感知、战斗状态和 Lua 决策调度。

二者职责不同：

- 主角状态机更接近“动画行为状态机”，核心是 `Base / Action / Reaction` 分层。
- 敌人 Brain 状态机更接近“AI 感知状态机”，核心是 `Idle / Battle / Find / Caution / Dead`。

## 3. 主角分层状态机

主角使用 `USekiroLayeredStateMachineComponent` 保存运行时状态。该组件本身不负责复杂决策，只维护每层当前状态：

```cpp
LayerId
StateId
PreviousStateId
DirectionId
PreviousDirectionId
StateElapsedSeconds
StateName
LastEventName
bChangedThisFrame
```

启动时默认创建三层：

```text
Layer 0: Base     -> Idle
Layer 1: Action   -> ActionIdle
Layer 2: Reaction -> ReactionIdle
```

### 3.1 Base 层

Base 层负责基础移动和朝向修正，是主角 locomotion 的主干。

主要状态包括：

| 状态 | ID | 作用 |
| --- | ---: | --- |
| `Idle` | 0 | 待机 |
| `MoveStart` | 1 | 起步入口态 |
| `MoveLoop` | 2 | 移动循环 |
| `MoveStop` | 3 | 停步 |
| `QuickTurn90` | 4 | 原地 90 度快速转向 |
| `QuickTurn180` | 5 | 原地 180 度快速转向 |
| `QuickTurnMoveStart180` | 6 | 起步阶段 180 度转向 |
| `MoveQuickTurn180` | 7 | 移动中 180 度转向 |

设计特点是：顶层状态保持语义抽象，不把所有方向、速度、动画资源都展开成大量顶层状态。方向和速度细节通过 selector、AnimBP 变量和子状态机下沉处理。

### 3.2 Action 层

Action 层承载会覆盖或叠加基础移动语义的动作。

当前包含：

- 道具使用，例如葫芦饮用。
- 义手动作。
- 左腰武器拔刀/收刀。
- 防御和防御移动。
- 地面攻击连招。

常见状态包括：

| 状态 | ID | 作用 |
| --- | ---: | --- |
| `ActionIdle` | 0 | 动作层空闲 |
| `ActionItemGourdDrink` | 200 | 站立喝药 |
| `ActionItemGourdDrinkMove` | 1200 | 移动喝药 |
| `ActionLeftWaistSheathe` | 19260 | 收刀 |
| `ActionLeftWaistDraw` | 19261 | 拔刀 |
| `ActionDeflectGuardIdle` | 409 | 站立防御 |
| `ActionDeflectGuardMoveForward` | 4100 | 前移动防御 |
| `GroundAttackCombo1-5` | 11200+ | 地面五段连招 |

### 3.3 Reaction 层

Reaction 层用于格挡、弹反、受击等反应动作。它与 Action 层分离，避免把受击/弹反逻辑混进基础移动状态机。

主要状态包括：

| 状态 | ID | 作用 |
| --- | ---: | --- |
| `ReactionIdle` | 0 | 反应层空闲 |
| `ReactionDeflectGuard` | 120 | 格挡/弹反反应 |
| `ReactionDeflectGuardMove` | 1120 | 移动中的格挡/弹反反应 |

## 4. 主角 Lua 状态机运行方式

主角真正的状态决策主要在 Lua 中完成。

关键文件：

- `Content/Script/Sekiro/C0000/PreviewCharacter.lua`
- `Content/Script/Sekiro/C0000/AnimRuntime.lua`
- `Content/Script/Sekiro/C0000/FireEventHandlers.lua`
- `Content/Script/Sekiro/C0000/EventSpecs.lua`
- `Content/Script/Sekiro/C0000/Constants.lua`
- `Content/Script/Sekiro/C0000/StateDefines.lua`

主流程如下：

```text
输入 / 动画事件 / 调试触发
        |
        v
PreviewCharacter.lua
        |
        v
activate_event(event_key, context)
        |
        v
FireEventHandlers.handle/apply_spec
        |
        v
apply_layer_event
        |
        +--> 更新 Lua Runtime.layers
        +--> 调用 C++ SetLayerState
        +--> 写入 AnimBP 变量
        +--> pulse Req_* 请求变量
```

Lua runtime 自己维护一份状态：

```lua
runtime.layers = {
    [LAYER_BASE] = {
        state,
        previous_state,
        direction,
        entered_at,
        elapsed,
        event,
        state_name,
    },
    [LAYER_ACTION] = { ... },
    [LAYER_REACTION] = { ... },
}
```

当状态变化时，Lua 会同步到 C++：

```lua
state_machine:SetLayerState(layer_id, layer.state, layer.state_name, layer.event, layer.direction)
```

同时写入 AnimBP 变量，例如：

```text
FSM_ActionStateId
FSM_ActionActive
FSM_GroundAttackActive
FSM_ReactionStateId
MoveDirection
MoveSpeedLevel
TurnAngle
Req_*
Return_*
```

因此主角侧可以理解为：

```text
Lua 负责决策
C++ 负责 UE 能力封装
AnimBP 负责表现执行
```

## 5. 主角 C++ 与 Lua 调用链

`ASekiroC0000PreviewCharacter` 实现 `IUnLuaInterface`：

```cpp
FString ASekiroC0000PreviewCharacter::GetModuleName_Implementation() const
{
    return TEXT("Sekiro.C0000.PreviewCharacter");
}
```

C++ 在运行时通过 UnLua 绑定到：

```text
Content/Script/Sekiro/C0000/PreviewCharacter.lua
```

### 5.1 C++ 调 Lua

C++ 会调用 Lua 中的方法：

| Lua 方法 | 调用场景 |
| --- | --- |
| `ReceiveBeginPlay` | BeginPlay 后初始化 Lua runtime |
| `ReceiveTick` | 每帧更新输入、状态、AnimBP 变量 |
| `TriggerSekiroEvent` | C++ 或调试工具触发动作事件 |
| `OnSekiroMovementAnimEvent` | AnimNotify/TAE 事件转发到 Lua |

### 5.2 Lua 调 C++

Lua 通过 UnLua 直接调用 C++ 暴露的 UFUNCTION，例如：

| C++ 函数 | 用途 |
| --- | --- |
| `GetSekiroLayeredStateMachine()` | 取得分层状态机组件 |
| `GetSekiroEnvQuery()` | 取得环境查询组件 |
| `SetAnimBoolVar()` | 写 AnimBP bool 变量 |
| `SetAnimIntVar()` | 写 AnimBP int 变量 |
| `SetAnimFloatVar()` | 写 AnimBP float 变量 |
| `ApplyPreviewMovementInput()` | 应用移动输入 |
| `AddPreviewFacingYaw()` | 修改角色朝向 |
| `QueuePreviewActionEvent()` | 入队动作事件 |
| `ConsumePreviewActionEvent()` | 消耗动作事件 |

主角侧调用关系可以概括为：

```text
ASekiroC0000PreviewCharacter
        |
        | UnLua bind
        v
Sekiro.C0000.PreviewCharacter.lua
        |
        +--> 状态决策
        +--> 写 AnimBP 变量
        +--> 调 C++ 移动/朝向/环境查询接口
        +--> 同步 LayeredStateMachine
```

## 6. 敌人 AI 状态机

敌人侧使用 `USekiroEnemyScriptBrainComponent` 作为脚本脑组件。

AI 语义状态定义为：

```cpp
enum class ESekiroEnemyBrainState : uint8
{
    Idle = 0,
    Battle = 1,
    Dead = 2,
    Caution = 3,
    Find = 4
};
```

状态含义：

| 状态 | 作用 |
| --- | --- |
| `Idle` | 无有效目标或脱战，执行巡逻 |
| `Battle` | 看到目标并进入战斗 |
| `Find` | 被攻击或有记忆目标，但暂时看不到目标 |
| `Caution` | 有目标但视线受阻，警戒 |
| `Dead` | 死亡 |

状态刷新逻辑主要由距离、目标存在、视线和攻击记忆决定：

```text
无目标 / 超出脱战距离 -> Idle
有目标但看不见       -> Caution 或 Find
看见目标             -> Battle
死亡                 -> Dead
```

`NotifyAttackedBy()` 会强制把攻击者设为目标，并开启一段攻击记忆时间。这样敌人即使短时间丢失视线，也可以进入 `Find` 而不是立即回到 `Idle`。

## 7. 敌人 C++ 与 Lua 调用链

敌人侧不是用 `IUnLuaInterface` 绑定成一个 Lua 类，而是 C++ 手动调用 Lua 模块。

关键函数是：

```cpp
USekiroEnemyScriptBrainComponent::TryRunLuaLogic(float DeltaTime)
```

它会：

1. 激活 UnLua。
2. 获取 Lua 环境。
3. `require("Sekiro.Enemy.OriginalRuntime")`。
4. 取模块里的 `Main` 函数。
5. 把当前 BrainComponent 作为 `ai` 对象传给 Lua。
6. 如果使用原版逻辑，则额外传入 `OriginalSekiroLogicId`，默认是 `101200`。

调用链如下：

```text
USekiroEnemyScriptBrainComponent::TickComponent
        |
        v
Think
        |
        v
TryRunLuaLogic
        |
        v
require("Sekiro.Enemy.OriginalRuntime")
        |
        v
OriginalRuntime.Main(ai, logic_id)
        |
        v
加载 101200_logic.lua / 101200_battle.lua
        |
        v
原版 Logic.Main / Goal.Activate
        |
        v
GoalStack:AddSubGoal
        |
        v
ai:ScriptApproach / ScriptAttackAtRange / ScriptSidewayMove / ScriptWait
        |
        v
USekiroEnemyAnimBridgeComponent
        |
        v
敌人 AnimBP 变量
```

## 8. 敌人 Lua 适配层

敌人 Lua 的入口是：

```text
Content/Script/Sekiro/Enemy/OriginalRuntime.lua
```

它的职责是把原版只狼 AI Lua 脚本适配到 UE 运行时。

主要做了几件事：

- 安装原版脚本依赖的全局函数和常量。
- 注册 `TARGET_SELF`、`TARGET_ENE_0`、`AI_DIR_TYPE_F` 等原版概念。
- 注册 `GOAL_COMMON_AttackTunableSpin`、`GOAL_COMMON_ApproachTarget` 等 Goal 名称。
- 加载公共 AI 脚本 `common_battle_func.lua`。
- 按 logic id 加载原版拆出的 `*_logic.lua` 和 `*_battle.lua`。
- 将原版 Goal 转换成 UE 侧可执行的 C++ 接口调用。

例如 `101200_logic.lua` 中会调用：

```lua
COMMON_EzSetup(ai)
```

然后进入 battle goal，选择攻击 Act，最后通过 `GoalStack` 执行。

## 9. GoalStack 的作用

`GoalStack.lua` 是敌人 Lua 到 C++ 行为接口之间的翻译层。

典型映射如下：

| 原版 Goal | UE/C++ 调用 |
| --- | --- |
| `GOAL_COMMON_Wait` | `ai:ScriptWait()` |
| `GOAL_COMMON_Turn` | `ai:ScriptTurnToTarget()` |
| `GOAL_COMMON_ApproachTarget` | `ai:ScriptApproach()` |
| `GOAL_COMMON_LeaveTarget` | `ai:ScriptLeaveTarget()` |
| `GOAL_COMMON_SidewayMove` | `ai:ScriptSidewayMove()` |
| `GOAL_COMMON_Attack*` | `ai:ScriptAttackAtRange()` |
| `GOAL_COMMON_ComboAttack*` | `ai:ScriptAttackAtRange()` |
| `GOAL_COMMON_Guard` | 暂时映射为等待 |

这意味着原版 AI Lua 不需要直接知道 UE 的 AnimBP、Controller 或 MovementComponent，只需要照常添加 Goal。真正执行动作的是 C++ Brain 和 AnimBridge。

## 10. 敌人动画桥接

`USekiroEnemyAnimBridgeComponent` 接收 `FSekiroEnemyAnimCommand`：

```cpp
Type
AttackId
StateId
EventName
ExpectedDuration
bCanBeInterrupted
```

命令类型包括：

```text
Move
Attack
Damage
Reaction
SpecialEvent
ThrowDef
ThrowDefDeath
Death
```

AnimBridge 通过反射写敌人 AnimInstance 变量：

```text
EnemyLayer
EnemyAttackId
EnemyStateId
MoveSpeedLevel
MoveDirection
MoveBattleStateId
Req_Attack
Req_Damage
Req_Reaction
Req_Death
C9997_Req_*
```

敌人攻击链路可以简化为：

```text
Lua battle 选择 Act
        |
        v
GoalStack 添加 Attack Goal
        |
        v
USekiroEnemyScriptBrainComponent::ScriptAttackAtRange
        |
        v
USekiroEnemyAnimBridgeComponent::SendAttackCommand
        |
        v
写 EnemyAttackId / EnemyStateId / Req_Attack
        |
        v
ABP_Sekiro_Enemy_C9997_Master 播放攻击
```

## 11. 战斗与动画事件

当前战斗系统大量依赖动画事件。

主角侧：

- `HandleSekiroMovementAnimEvent()` 接收 TAE/AnimNotify。
- `TAE_1` 用于触发攻击 hitbox。
- `TAE_32` 用于武器样式/拔刀状态。
- `TAE_715` 用于右手武器显示。
- Lua 的 `OnSekiroMovementAnimEvent()` 会维护动画事件 active 状态和 behavior ref。

敌人侧：

- `ASekiroEnemyCharacter::HandleSekiroEnemyAnimEvent()` 处理敌人攻击事件。
- `TAE_1` 激活或销毁敌人攻击碰撞。
- 根据 `BehaviorJudgeID` 解析攻击参数、伤害、挂点和碰撞体尺寸。

受击链路：

```text
主角攻击 hitbox overlap 敌人
        |
        v
ASekiroEnemyCharacter::ApplyPlayerAttackHit
        |
        +--> 扣血
        +--> NotifyAttackedBy
        +--> 选择 Damage / Death 动画命令
        v
EnemyAnimBridge::SendAnimCommand
```

## 12. 忍杀设计

当前忍杀是分段设计，而不是一个单一动画。

主角侧：

```text
ThrowAtk  -> 刺入
ThrowKill -> 拔刀击杀
```

敌人侧：

```text
ThrowDef      -> 被刺入受身
ThrowDefDeath -> 死亡阶段
```

这样设计的原因是：

- 主角刺入过程可能被打断。
- 敌人进入受身并不一定立刻死亡。
- 主角和敌人的动画需要分别控制、分别确认。

当前 C++ 中的对应入口：

| 函数 | 职责 |
| --- | --- |
| `StartFrontDeathblowOnEnemy()` | 主角开始正面忍杀 |
| `BeginFrontDeathblow()` | 敌人进入 ThrowDef |
| `ConfirmFrontDeathblowKill()` | 敌人进入 ThrowDefDeath |

## 13. 当前完成度

已经完成或基本可用：

- 主角三层动作状态机框架。
- 主角移动、起步、停止、快速转向。
- 主角地面五段连招。
- 防御姿态和防御移动。
- 动画事件驱动的攻击窗口和连招窗口。
- 主角 hitbox 创建与敌人受击。
- 敌人基础巡逻、接近、攻击、受击、死亡。
- 敌人原版 Lua logic/battle 的初步适配。
- 敌人通用 AnimBridge。
- 正面忍杀分段流程。
- C++/Lua 双向调用链路。

仍然偏实验或需要完善：

- 敌人原版 AI API 不是全量实现，部分函数仍是 stub 或简化逻辑。
- `GetExcelParam`、guard、special effect、interrupt 等系统需要进一步补全。
- 敌人 `EnemyAnimProfile` 的攻击 ID 到动画状态映射还需要继续数据化。
- 部分攻击碰撞参数仍有硬编码。
- TAE 配置和导入工具还需要继续自动化，减少逐动画手工配置。
- 日志和调试开关较多，后续需要整理成统一 debug 面板或调试组件。

## 14. 架构评价

当前架构方向是合理的：

```text
Lua 负责行为决策
C++ 负责 UE 能力、反射写变量、碰撞、移动、对象生命周期
AnimBP 负责动画表现和状态承载
DataAsset 负责敌人差异配置
```

主角侧已经形成了比较完整的“语义状态 + 分层驱动 + 动画事件窗口”结构。敌人侧则正在搭建“原版 AI Lua + UE 适配层 + 通用敌人 AnimBP”的路线。

这套结构的优点是：

- 行为逻辑不被硬塞进 AnimBP。
- AnimBP 更像状态和表现执行器。
- Lua 可以复用或接近原版只狼 AI 脚本结构。
- C++ 保持为稳定运行时接口层。
- 后续增加敌人时，可以通过 DataAsset 和 Lua 表扩展，而不是复制整套蓝图。

## 15. 后续建议

建议优先推进以下方向：

1. 补齐敌人 Lua API。
   重点补 `GetExcelParam`、special effect、guard、interrupt、path check、cooldown 和 act rate。

2. 数据化敌人攻击映射。
   将 `AttackId -> StateId -> Animation`、攻击距离、冷却、权重从硬编码迁移到 `USekiroEnemyAnimProfile` 和 `USekiroEnemyCombatProfile`。

3. 完善 TAE 事件导入链路。
   尽量让攻击窗口、连招窗口、武器显示、behavior ref 都来自导入表，减少手动维护。

4. 建立敌人调试面板。
   显示 BrainState、当前目标、距离、LOS、LastDecisionDebug、当前 AttackId、cooldown、Lua act。

5. 整理主角状态机文档和事件表。
   将 `EventSpecs.lua`、`Constants.lua` 中的状态、事件、AnimBP 变量整理成一张可维护的状态表。

6. 继续完善忍杀对齐。
   重点处理主角刺入点、敌人朝向、位移锁定、ThrowAtk 到 ThrowKill 的确认窗口。

