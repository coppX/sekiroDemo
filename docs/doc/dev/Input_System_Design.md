# 只狼输入系统设计与脚本交互（UE5 复刻参考）

> 本文档总结只狼（FromSoftware）原版**输入系统**的工作模型，以及它如何与 Lua 行为脚本（`action/script/c0000*.dec.lua`）交互。后续可作为在 **UE5** 中实现等价输入层的设计依据。
>
> 引用源：[action/script/c0000_transition.dec.lua](../../action/script/c0000_transition.dec.lua)、[action/script/c0000.dec.lua](../../action/script/c0000.dec.lua)、[action/script/c0000_define.dec.lua](../../action/script/c0000_define.dec.lua)、[doc/env.md](../env.md)。

---

## 1. 关键结论：Pull 模型，不是 Push 模型

只狼**没有**「按下 X 键 → 触发回调函数」这种事件驱动结构。脚本里看不到 `OnKeyDown` / `OnAttackPressed`。真正的设计是：

1. **C++ 引擎**每帧把所有输入采样写入一张全局 `env(...)` 状态表（按键、摇杆、锁定、长按计数…）。
2. **Lua 行为脚本**每帧调用 `Validate()`，按优先级**遍历**当前姿态下所有候选行为（`g_behaviorValidateOrderByStyle[currentStyle]`）。
3. 每条候选行为的 `validFunc` 内部主动调用 `env(...)` 查询当前帧的输入与外部状态。
4. **第一个**返回 `TRUE` 的 `validFunc` 对应的 `behaviorId` 被 `_ActivateBehavior` 选中，进而 `FireEvent` 推动 Havok 状态机切到下一动画状态。

> **要点**：输入对脚本是**被查询（pull）**的状态，而不是**被传递（push）**的事件。`Validate(current_hkb_state)` 的入参里不带任何输入信息，输入是通过 `env()` 旁路获取的。

参考代码：[c0000_transition.dec.lua:235](../../action/script/c0000_transition.dec.lua#L235)

```lua
function Validate(current_hkb_state)
    local currentStyle = g_paramHkbState[current_hkb_state][PARAM_HKB_STATE__STYLE_TYPE]
    local currentState = g_paramHkbState[current_hkb_state][PARAM_HKB_STATE__STATE_TYPE]
    if env(337) == FALSE and (...) then
        local f2_local2 = function ()
            local functionTable = g_behaviorValidateOrderByStyle[currentStyle]
            if functionTable ~= nil then
                for _, entry in ipairs(functionTable) do
                    local behaviorId = entry[1]
                    local validFunc  = entry[2]
                    if validFunc(current_hkb_state, currentState) == TRUE then
                        return behaviorId       -- ← nextBehavior
                    end
                end
            end
            return BEH_NONE
        end
        ...
        local nextBehavior = f2_local2()
        if nextBehavior ~= BEH_NONE then
            _StopAutoAim()
            _ActivateBehavior(current_hkb_state, nextBehavior)
            ...
        end
    end
end
```

---

## 2. 数据流总图

```
┌────────────────────────────────────────────────────────────┐
│                         C++ 引擎层                          │
│  ┌────────────┐  ┌──────────────┐  ┌────────────────────┐  │
│  │ 物理按键   │  │ 摇杆 / 鼠标  │  │ 锁定 / 命中 / 受击 │  │
│  │ 采样       │  │ 采样         │  │ 等其他事件源       │  │
│  └─────┬──────┘  └──────┬───────┘  └─────────┬──────────┘  │
│        │                │                    │             │
│        ▼                ▼                    ▼             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │        每帧填表：env(typeId, subKey)                │   │
│  │  1106 单帧按下 │ 1108 长按时长 │ 1118 锁定 │ 1119 攻 │   │
│  │  1105 摇杆有输入 │ 1121 攻击横向偏移 │ 202 伤害类型  │   │
│  │  3035 TAE 允许输入 │ 3036 TAE 标志（180+）│ ……     │   │
│  └────────┬───────────────┬────────────────────┬───────┘   │
└───────────┼───────────────┼────────────────────┼───────────┘
            │               │                    │
            │               │                    │  Havok 行为变量
            │               │                    │  hkbGetVariable("MoveSpeedLevel" / "MoveAngle" / …)
            ▼               ▼                    ▼
┌────────────────────────────────────────────────────────────┐
│                       Lua 行为脚本层                        │
│                                                            │
│  Update() ─→ SetMoveType() ─→ Control() ─→ Validate()      │
│                                              │             │
│                                              ▼             │
│       g_behaviorValidateOrderByStyle[currentStyle]         │
│       ┌──────────────┬──────────────┬────────────────┐     │
│       │ {BEH_R_*, F} │ {BEH_A_*, F} │   …按优先级     │     │
│       └──────┬───────┴──────┬───────┴────────────────┘     │
│              │              │                              │
│              ▼              ▼                              │
│         validFunc()    validFunc()      ← 各自 env(...) 查询│
│              │              │                              │
│              ▼              ▼                              │
│        return TRUE/FALSE                                   │
│              │                                             │
│              ▼ 第一个 TRUE                                  │
│      _ActivateBehavior(BEH_*) ─→ FireEvent("...") ─→ Havok │
└────────────────────────────────────────────────────────────┘
```

---

## 3. 引擎暴露给脚本的输入查询接口

所有输入都通过 `env(typeId, subKey)` 暴露。**这是只读查询接口**，引擎写、脚本读，不存在脚本回写输入。

### 3.1 核心输入相关 env ID

| env 调用 | 类型 | 含义 | UE5 对应概念 |
|---|---|---|---|
| `env(1105)` | bool | **摇杆有输入**（移动待命） | `Vector2D` 移动输入是否非零 |
| `env(1106, ACTION_ARM_*)` | bool | **当前帧按下**（边缘触发） | `IA_*` 的 `Triggered` / `Started` 单帧 |
| `env(1108, ACTION_ARM_*)` | int | **长按计数 / 模拟值** | `IA_*` 的 `Ongoing` 持续时长（ms 或帧数） |
| `env(1118)` | bool | **锁定中** | 自定义 `IsLockedOn` 标志 |
| `env(1119)` | int | **攻击方向输入** | 攻击键按下时的摇杆方向枚举 |
| `env(1121)` | float | **攻击横向偏移**（< 0 为左） | 摇杆 X 轴在攻击瞬间的值 |
| `env(3035, ACTION_ARM_*)` | bool | **当前 TAE 允许的输入** | 当前蒙太奇允许提前输入的动作 |
| `env(3036, SP_EF_REF_*)` | bool | **TAE 标志查询**（180+ 子键） | 蒙太奇通知（Anim Notify）/ Gameplay Tag |
| `env(606)` | bool | `SP_EF_REF_DISABLE_ALL_INPUT` 屏蔽全部输入 | 全局输入门 |
| `env(337)` | bool | 处于投技/抓取（抑制行为输入） | 高优先级状态门控 |

数据来源：[doc/env.md](../env.md) 第 60–139、210–239 行。

### 3.2 `ACTION_ARM_*` 按键常量表（共 18 个）

定义于 [c0000_define.dec.lua:4](../../action/script/c0000_define.dec.lua#L4)，对应 `env(1106)`、`env(1108)`、`env(3035)` 的第二参数族。

| 常量 | 数值 | 含义 | UE5 建议命名 |
|------|------|------|------|
| `ACTION_ARM_ATTACK` | 0 | 攻击 | `IA_Attack` |
| `ACTION_ARM_SUB_ATTACK` | 1 | 副攻击（义手忍具） | `IA_SubAttack` |
| `ACTION_ARM_GUARD` | 2 | 防御 | `IA_Guard` |
| `ACTION_ARM_WIRE_SHOOT` | 3 | 钩索发射 | `IA_GrappleHook` |
| `ACTION_ARM_JUMP` | 4 | 跳跃 | `IA_Jump` |
| `ACTION_ARM_SP_MOVE` | 5 | 特殊移动（垫步/冲刺） | `IA_Step` / `IA_Sprint` |
| `ACTION_ARM_USE_ITEM` | 7 | 使用道具 | `IA_UseItem` |
| `ACTION_ARM_CHANGE_WEAPON_L` | 10 | 切换左手武器 | `IA_SwapSubWeapon` |
| `ACTION_ARM_WALL_HANG` | 12 | 墙挂 | `IA_WallHang` |
| `ACTION_ARM_BACKSTEP` | 13 | 后撤步 | `IA_Backstep` |
| `ACTION_ARM_ROLLING` | 14 | 翻滚 | `IA_Roll` |
| `ACTION_ARM_CROUCH` | 15 | 蹲伏 | `IA_Crouch` |
| `ACTION_ARM_SHINOBI_WEP_ACTION` | 18 | 忍义手动作 | `IA_ProstheticAction` |
| `ACTION_ARM_SWIM_ACCELERATION` | 28 | 游泳加速 | `IA_SwimSprint` |
| `ACTION_ARM_SWIM_UP` | 29 | 上浮 | `IA_SwimUp` |
| `ACTION_ARM_SWIM_DOWN` | 30 | 下潜 | `IA_SwimDown` |
| `ACTION_ARM_EAVESDROP` | 31 | 偷听 | `IA_Eavesdrop` |
| `ACTION_ARM_SPECIAL_ATTACK` | 32 | 居合 / 特殊攻击 | `IA_SpecialAttack` |

> 注意：
> - **`env(1106)` 全部 18 个按键都用**；
> - **`env(1108)` 只用 9 个**（`ATTACK`/`SUB_ATTACK`/`GUARD`/`SP_MOVE`/`USE_ITEM`/`WALL_HANG`/`SHINOBI_WEP_ACTION`/`SWIM_UP`/`SWIM_DOWN`）—— 即只对这 9 个键关心**长按时长**；
> - **`env(3035)` 只用 2 个**（`SHINOBI_WEP_ACTION`、`SPECIAL_ATTACK`）—— 仅这两个动作受 TAE 闸门控制。

### 3.3 三种输入语义的区分

只狼把**同一个物理按键**根据脚本查询方式拆成三种语义，UE5 实现时建议在输入子系统里同时维护：

| 语义 | 原 API | 含义 | UE5 实现建议 |
|---|---|---|---|
| **单帧按下（边缘）** | `env(1106, ACTION_ARM_X) == TRUE` | 该按键在**这一帧**被按下 | `EnhancedInput` 的 `Started` 触发 + 1 帧脉冲 |
| **持续按下（电平）** | `env(1108, ACTION_ARM_X) > 0` | 该按键已**累计按下** N 帧/N 毫秒 | 维护 `int32 PressedTicks[Action]`，每帧自增 |
| **TAE 允许提前输入** | `env(3035, ACTION_ARM_X) == TRUE` | 当前蒙太奇区间允许接收该输入 | 蒙太奇 Anim Notify 写入 `bAllowAction[X]` |

**典型用法对比**（来自 [c0000_transition.dec.lua:6151](../../action/script/c0000_transition.dec.lua#L6151)）：

```lua
-- 同时利用「长按 + 单帧按下 + TAE 标志」做防御弹反判定
if env(1108, ACTION_ARM_GUARD) > 0
   and (env(1106, ACTION_ARM_GUARD) == TRUE
        or env(3036, SP_EF_REF_ENABLE_PRESS_DEFLECT_GUARD) == TRUE)
   and _EnableMainWeaponAction() == TRUE then
    return TRUE   -- 触发 BEH_A_DEFLECT_GUARD_START
end
```

---

## 4. 输入如何决定「下一行为」

### 4.1 优先级表（共享数据）

[c0000_transition.dec.lua:6523](../../action/script/c0000_transition.dec.lua#L6523) `g_behaviorValidateOrder` 是一张**全局有序表**，按"反应类（BEH_R_*）→ 主动类（BEH_A_*）"的语义排列：

```
[1]  BEH_R_THROW_DEATH        ← 投技致死（最高优先级）
[2]  BEH_R_DEATH              ← 普通死亡
...
[5]  BEH_R_SPECIAL_DAMAGE     ← 特殊伤害（火/雷/发狂…）
[6]  BEH_R_HIT_DAMAGE         ← 普通受击
...
[31] BEH_A_GROUND_JUMP        ← 跳跃
[32] BEH_A_WALL_JUMP
...
[N]  BEH_A_GROUND_MOVE_START  ← 普通移动开始（接近末尾）
[N+1] BEH_A_GROUND_MOVE_STOP
```

**优先级规则**：受击/死亡这种**外部强制反应** > **特殊主动动作（攻击/跳）** > **普通移动**。在 UE5 中可以把它实现为一个有序的 `TArray<FBehaviorEntry>`。

### 4.2 按姿态分组（性能优化）

[c0000_transition.dec.lua:176](../../action/script/c0000_transition.dec.lua#L176) `ValidateOrderTableInit()` 在初始化时根据 `g_behaviorTable[behaviorId][styleType]` 的位掩码，把 `g_behaviorValidateOrder` 拆成 16 张子表 `g_behaviorValidateOrderByStyle[1..16]`。

每帧只遍历**当前姿态**那一张子表，避免做无效检查。例：`STYLE_TYPE_HANG`（攀爬）下不会出现 `BEH_A_GROUND_ATTACK`。

### 4.3 三类验证表

```
g_ValidateReactionTable[BEH_R_*]      — 被动反应规则（受伤/死亡/落地…）
g_ValidateActionTable[BEH_A_*]        — 主动动作规则（攻击/跳/移动…）
g_ValidateAddReactionTable[BEH_ADD_R_*] — 叠加层反应（夜视/受击叠加…）
```

每条 `validFunc(current_hkb_state, currentState) → TRUE/FALSE` 就是「在当前 hkb 状态、当前姿态下，外部条件（输入 + env 标志 + Havok 变量）是否满足触发该行为」。

**真实例子**：[c0000_transition.dec.lua:5984](../../action/script/c0000_transition.dec.lua#L5984)

```lua
g_ValidateActionTable = {
    [BEH_A_GROUND_MOVE_START] = function (current_hkb_state)
        if (env(1105) == TRUE                                   -- 摇杆有输入
            or env(2000) == TRUE                                -- 强制可移动
            or env(3036, SP_EF_REF_TAE_ENABLE_ITEM_USE_MOVE) == TRUE)
           and (GetLocomotionType() ~= LOCOMOTION_TYPE_MOVE
                or env(2000) == TRUE
                   and env(3036, SP_EF_REF_TAE_ENABLE_ITEM_USE_MOVE) == TRUE)
           and hkbGetVariable("MoveSpeedLevel") > 0 then
            return TRUE
        end
        return FALSE
    end,
    ...
}
```

> 摇杆相关的状态量（`MoveSpeedLevel`、`MoveAngle`、`MoveDirection`、`TurnAngle`）走的是 **Havok 行为变量**通道，由引擎从摇杆数据计算后写入，脚本通过 `hkbGetVariable("...")` 读取。这条线**和 `env()` 是平行的两条数据通道**。

---

## 5. 触发与执行：从 `nextBehavior` 到动画

[c0000_transition.dec.lua:283-294](../../action/script/c0000_transition.dec.lua#L283-L294)：

```lua
local nextBehavior = f2_local2()
if nextBehavior ~= BEH_NONE then
    _StopAutoAim()
    _ActivateBehavior(current_hkb_state, nextBehavior)
    ...
end
```

`_ActivateBehavior` 内部根据 `(currentStyle, current_hkb_state, next_behavior)` 三元组在 `g_behaviorReactionTable` / `g_behaviorActionTable` 里查表，最终调用 `FireEvent("W_XxxStart")` 把对应的 Havok 状态机事件丢给行为树，由 Havok 完成实际动画切换。

UE5 等价：`UAnimInstance` 的 `Montage_Play` 或 **状态机 transition** 由 C++ 触发。

---

## 6. 输入抑制 / 闸门机制

只狼对输入做**多层过滤**，按从粗到细排列：

| 层级 | 检查 | 含义 | UE5 等价 |
|---|---|---|---|
| ① 总闸 | `env(337)` 投技中 | 完全跳过 `Validate()` | 全局输入抑制标志 |
| ② TAE 标志 | `env(3036, SP_EF_REF_DISABLE_ALL_INPUT)` | 当前动画通知禁用所有输入 | Anim Notify 设 Tag |
| ③ TAE 标志 | `env(3036, SP_EF_REF_DISABLE_USE_ITEM_REQUEST)` | 禁止道具使用 | 局部输入屏蔽 |
| ④ TAE 标志 | `env(3036, SP_EF_REF_TAE_DISABLE_MAIN_MENU)` | 禁止打开菜单 | 局部输入屏蔽 |
| ⑤ TAE 闸门 | `env(3035, ACTION_ARM_X)` | 当前动画允许 X 输入 | Anim Notify 写白名单 |
| ⑥ 解锁 | `env(3033, ACTION_UNLOCK_TYPE_X)` | 玩家是否已学会该动作 | `Ability` 是否解锁 |
| ⑦ 资源 | `_EnableMainWeaponAction()` 等 | 武器/弹药/体力是否够 | Cost 检查 |
| ⑧ 优先级 | `g_behaviorValidateOrderByStyle` | 顺序遍历，先到先得 | 优先级数组 |

UE5 实现时建议把 ①–④ 做成一个 `FInputGate` 结构，⑤ 做成 `FAllowedInputMask`，⑥–⑦ 留给各 `GameplayAbility` 自己检查。

---

## 7. 「附加层」叠加输入

[c0000_transition.dec.lua:753-771](../../action/script/c0000_transition.dec.lua#L753-L771) 中的 `SP_EF_REF_TAE_ENABLE_ADD_ACTION_INPUT_*` 系列（数值 403–432）是**附加输入层**：动画播放过程中可以**预录入**下一动作（跳/道具/防御/攻击/钩索/墙挂/踢/换武器/特殊攻击），引擎把它写到 `env(3036)` 标志位，脚本下一帧读到后触发 `BEH_A_ADD_ACTION_INPUT_*`。

UE5 等价：**输入缓冲（Input Buffer）+ 蒙太奇区间允许列表**。

---

## 8. UE5 实现蓝图（建议）

### 8.1 类层划分

```
USekiroInputSubsystem (UGameInstanceSubsystem)
├─ FActionState[ACTION_ARM_NUM]          // 每个动作的 Pressed/Held/PressedTicks
├─ FRawAxis MoveAxis, LookAxis           // 摇杆原始值
├─ bool bLockedOn                        // 对应 env(1118)
├─ FInputGate Gate                       // 对应 ①–④
└─ Tick(): 从 Enhanced Input 拉值，更新所有字段

USekiroBehaviorComponent (UActorComponent on Player)
├─ TArray<FBehaviorEntry> ValidateOrder              // 对应 g_behaviorValidateOrder
├─ TMap<EStyleType, TArray<FBehaviorEntry>> ByStyle  // 对应 g_behaviorValidateOrderByStyle
├─ TMap<EBehaviorId, FValidateFunc> ReactionTable    // g_ValidateReactionTable
├─ TMap<EBehaviorId, FValidateFunc> ActionTable      // g_ValidateActionTable
├─ Validate(CurrentHkbState) → EBehaviorId           // 对应 Validate()
└─ ActivateBehavior(EBehaviorId)                     // 对应 _ActivateBehavior

USekiroAnimGate (UAnimNotifyState)
└─ 在蒙太奇区间内向 InputSubsystem 写入：
   - AllowedInputMask（对应 env(3035)）
   - TaeFlags（对应 env(3036) 的 SP_EF_REF_TAE_*）
```

### 8.2 帧循环

```
ATick(Player):
  1. SekiroInputSubsystem.Tick()       // 采样按键、更新长按计数
  2. SekiroBehaviorComponent.Update()  // 等价 c0000.Update()
       a. SetMoveType()                // 根据移动状态写 MoveType 变量
       b. nextBehavior = Validate()    // 等价 Validate()
       c. if nextBehavior != None:
            ActivateBehavior(nextBehavior)
       d. UAnimInstance::Montage_Play( BehaviorToMontage[nextBehavior] )
```

### 8.3 `validFunc` 风格示例（伪 C++）

```cpp
// 等价 [BEH_A_GROUND_MOVE_START]
bool ValidateGroundMoveStart(const FBehaviorContext& Ctx)
{
    auto* In = Ctx.Input;
    return (In->HasStickInput()
            || In->Env2000_Moveable
            || In->TaeFlag(SP_EF_REF_TAE_ENABLE_ITEM_USE_MOVE))
        && (Ctx.LocomotionType != ELocomotionType::Move
            || (In->Env2000_Moveable
                && In->TaeFlag(SP_EF_REF_TAE_ENABLE_ITEM_USE_MOVE)))
        && Ctx.Anim->GetVariableFloat("MoveSpeedLevel") > 0.f;
}
```

### 8.4 Enhanced Input 映射建议

| Enhanced Input Action | Trigger | 写入字段 |
|---|---|---|
| `IA_Attack` | Started + Triggered + Completed | `ActionState[ATTACK].PressedThisFrame / PressedTicks` |
| `IA_Move` (Vector2D) | Triggered | `MoveAxis`，并据此推 `MoveSpeedLevel` |
| `IA_LockOn` | Started（toggle） | `bLockedOn` |

### 8.5 状态机 vs 行为表

只狼用 Havok 行为树存动画/状态，用 Lua 行为表选下一状态。UE5 中**两个职责可以分离**：
- **行为选择层（Behavior Selection）**：纯 C++ 数据驱动，移植 `g_behaviorValidateOrder`、`g_ValidateActionTable` 等。
- **动画执行层**：Animation Blueprint 状态机或 Motion Matching；C++ 选完行为后通过 `Montage_Play` 或 `AnimInstance` 变量驱动。

---

## 9. 移植时的坑与注意点

1. **`env(1108)` 是 int 不是 bool**：长按返回累计时长（毫秒或帧数），脚本用 `> 0` 判断。UE5 实现要保留数值（用于「按到 N 毫秒触发冲刺」一类逻辑，参见 `env(1108, ACTION_ARM_SP_MOVE) > 200` 在 [c0000_transition.dec.lua:5137](../../action/script/c0000_transition.dec.lua#L5137)）。
2. **`env(1106)` 是单帧脉冲**：连续两帧按住时第二帧应返回 FALSE（仅边缘）。UE5 中用 `Started` 触发器，并在下一帧自动归零。
3. **TAE 标志和按键状态分属两个空间**：`env(3035)` 的"允许输入"和 `env(1106)` 的"实际按下"必须**同时**为真才触发，这是只狼"动画窗口期才能取消"的核心机制。
4. **`hkbGetVariable("MoveSpeedLevel")` 等是引擎写、脚本读**：摇杆模拟值不通过 `env`，走的是 Havok 变量。UE5 实现可以让 `AnimInstance` 持有这些变量，C++ 通过 `IAnimClassInterface` 读。
5. **优先级遍历顺序敏感**：受击反应必须排在主动动作之前，否则玩家在挨打瞬间还能起跳。UE5 实现时**保持 `g_behaviorValidateOrder` 的顺序原样移植**。
6. **多个验证函数同时为 TRUE 时只取第一个**：这是策划意图——例如同时按攻击+跳，攻击在前就攻击。不要随便改成"取最高优先级"。
7. **`env(337)` 是总开关**：投技/抓取动画期间整张表跳过遍历。UE5 可以用 GameplayTag `State.Throw.Active` 等价。
8. **`SP_EF_REF_DISABLE_ALL_INPUT`（值 606）**：动画通知设的"全屏蔽"标志。在道具/钩索/换武器三处都被检查（[c0000_transition.dec.lua:430/4088/4616/5978](../../action/script/c0000_transition.dec.lua#L430)）。

---

## 10. 参考文件清单

| 文件 | 作用 |
|---|---|
| [action/script/c0000.dec.lua](../../action/script/c0000.dec.lua) | 帧循环：`Update()` / `SetMoveType()` |
| [action/script/c0000_transition.dec.lua](../../action/script/c0000_transition.dec.lua) | 输入查询主战场：`Validate()`、`g_behaviorValidateOrder`、各 `g_Validate*Table` |
| [action/script/c0000_define.dec.lua](../../action/script/c0000_define.dec.lua) | `ACTION_ARM_*` / `STYLE_TYPE_*` / `SP_EF_REF_*` 常量定义 |
| [action/script/c0000_cmsg.dec.lua](../../action/script/c0000_cmsg.dec.lua) | 受击消息处理（输入以外的事件源） |
| [doc/env.md](../env.md) | `env()` 完整参考（输入、伤害、TAE 等） |
| [doc/c0000_transition.md](../c0000_transition.md) | 当前主交付物（架构与流程图） |
| [action/eventnameid.txt](../../action/eventnameid.txt) | `FireEvent` 事件名 ↔ ID 映射 |
| [action/variablenameid.txt](../../action/variablenameid.txt) | Havok 变量名 ↔ ID 映射 |
