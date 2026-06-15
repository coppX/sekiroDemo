# Combo1（含 TAE 时间线）：Idle → 鼠标左键 → 普攻路径完整梳理

> 本文件是 [doc/dev/comb1.md](../comb1.md) 的升级版。该旧文档只用 Lua 端的反编译结果推断"按键 → 行为 → FireEvent → 状态切换"链路，**没有动画事件 (TAE) 数据**作为时间轴证据。本次结合 [doc/TAE/AniEventAnalyze/](../../TAE/AniEventAnalyze/) 下导出的 a050 战斗动画事件清单，把脚本侧每一个 `env(3036, SP_EF_REF_*)` 查询锚定到 TAE 时间轴上的具体事件，并把"取消窗口"、"伤害判定"、"SpEffect"、"输入缓冲"等过去只能在 Lua 中**间接观察**的概念变成可读的"动画时间区间表"。
>
> 主要数据来源：
> - 矩阵总览：[sekiro_a50_combat_ani.csv](../../TAE/AniEventAnalyze/sekiro_a50_combat_ani.csv)
> - 事件长表（8583 条）：[sekiro_a50_combat_anievent.csv](../../TAE/AniEventAnalyze/sekiro_a50_combat_anievent.csv)
> - Trigger 字典：[sekiro_a50_combat_trigger.csv](../../TAE/AniEventAnalyze/sekiro_a50_combat_trigger.csv)
> - 文档使用说明：[sekiro_a50_combat_说明.csv](../../TAE/AniEventAnalyze/sekiro_a50_combat_说明.csv)
>
> 主要 Lua 文件：
> - [c0000.dec.lua](../../../action/script/c0000.dec.lua)
> - [c0000_transition.dec.lua](../../../action/script/c0000_transition.dec.lua)
> - [c0000_define.dec.lua](../../../action/script/c0000_define.dec.lua)
>
> 区分"**脚本事实**"、"**TAE 事实**"、"**结论/推断**"。

---

## 0. 与 comb1.md 的区别一览

| comb1.md（旧） | 本文（新） |
|---|---|
| 只能在 Lua 中读到 `env(3036, SP_EF_REF_TAE_GROUND_RELEASE_ATTACK_CANCEL) == TRUE` 这种"标志位"，不知道它何时为 TRUE | 直接给出 TAE 事件 `117: InvokeAnimCancelEnd_L1` 在 a050_300000 的两段时间区间：**0.10–0.50s 与 1.10–2.27s**，可解释 release 何时可触发 |
| "按下/松开"两个事件外，无其他细节，"长按突刺"被归到 Havok 行为图自然过渡 | 用 a050_300000 的事件长表逐帧对照：什么时候开伤害判定（**0.70–2.27s** `InvokeAttackAction_Complex`）、什么时候开 R1 / R2 取消窗（**1.10–2.27s**）、什么时候允许闪避缓冲消化（**0.10–0.50, 1.10–2.27s**） |
| 无法解释 "InvokeAnimCancelStart" vs "InvokeAnimCancelEnd" 的差别 | 通过 trigger 字典确认两者分别是"窗口开始声明"和"窗口期内消化输入/退出动画"两种语义 |
| 不知道 release 动画 a050_300100 的取消窗细节 | 给出 a050_300100 的全套窗口（取消窗 0.50–1.73s、缓冲消化 0.50–1.73s、闪避缓冲消化 0.00–0.10 与 0.50–1.73s 两段） |

---

## 1. 帧循环骨架（保留 comb1.md 的结论，作为前置）

[c0000.dec.lua:204](../../../action/script/c0000.dec.lua#L204)：

```lua
function UpdateState(current_hkb_state)
    Control(current_hkb_state)
    Validate(current_hkb_state)
    FireStateEndEvent(current_hkb_state)
end
```

每个 Havok 状态节点 (HKB state) 都有一个 `<StateName>_onUpdate()` 回调（在 [c0000_cmsg.dec.lua](../../../action/script/c0000_cmsg.dec.lua)），每帧调用 `UpdateState`。`Validate` 按 [`g_behaviorValidateOrder`](../../../action/script/c0000_transition.dec.lua#L6523) 优先级遍历当前姿态 (`STYLE_TYPE_*`) 下允许的所有 `BEH_*` 验证函数，**命中第一个返回 TRUE 的**就 `_ActivateBehavior(...)`。

**关键事实**：`Validate` 只看输入 (`env(1106/1108, …)`) 和当前 TAE 标志 (`env(3036, SP_EF_REF_*)`)，并不知道动画播到第几秒。"动画时间 → 标志位"由 TAE 事件负责：每个时间区间的 TAE 事件向引擎注入对应的 SpEffect，引擎在 `env(3036, …)` 查询时返回 TRUE。

---

## 2. 关键 TAE Trigger 与 Lua 标志位的映射（本文档新增）

下表来自 [sekiro_a50_combat_trigger.csv](../../TAE/AniEventAnalyze/sekiro_a50_combat_trigger.csv) + Lua 反编译交叉对照。

### 2.1 取消窗口类（type=0）

| TAE Trigger | 中文 | Lua 端等价语义 |
|---|---|---|
| 25 `InvokeAnimCancelStart_SpMove_Backstep_Rolling_Jump` | 闪步/翻滚/跳取消窗口开始 | 标记当前帧"允许 BEH_A_GROUND_STEP / BEH_A_GROUND_JUMP" |
| 26 `End If Dodge Queued` | **缓冲: 闪避→取消** | 若输入队列有闪避，进入此区间立刻退出当前动画 |
| 11 `End If LS Move Queued` | **缓冲: 左摇杆移动→取消** | 摇杆有移动输入则取消 |
| 31 `InvokeAnimCancelEnd_UseItem` | 道具使用取消窗 | 允许 `BEH_A_ITEM_USE` 通过 |
| 32 `End If Weapon Switch Queued` | 缓冲: 切武器→取消 | 切武器输入立刻取消 |
| 115 `InvokeAnimCancelEnd_R1_LightKick` | **R1 攻击取消窗** | 此区间按 R1（鼠标左键）→ 直接命中下一段攻击 |
| 116 `InvokeAnimCancelEnd_R2_HeavyKick` | R2 攻击取消窗 | 此区间按 R2 → 重攻击 |
| 117 `InvokeAnimCancelEnd_L1` | **L1 防御取消窗** | 此区间按 L1 → 切防御/弹反 |
| 118 `InvokeAnimCancelEnd_L2` | L2 招式取消窗 | 此区间按 L2 → 忍义手 |
| 119 `TryToInvokeForceParryMode` | 强制进入弹反模式 | 战斗待机/攻击中段普遍存在 |
| 7 `Disable Turning` | 禁止转身 | 引擎层不允许角色旋转 |

### 2.2 攻击判定与行为类

| TAE Trigger | 含义 | 备注 |
|---|---|---|
| 87 `InvokeAttackAction_Complex` (type=0) | **伤害判定开关**（区间内武器有 hitbox） | 决定动画哪段才能打到敌人 |
| `InvokeAttackBehavior` (type=1) | 通过 `BehaviorJudgeID` 调一次具体攻击行为 | 触发 hit reaction/弹刀/打硬直 |
| `InvokeBulletBehavior` (type=2) | 子弹/投射物行为 | 普攻里也会出现（如挥砍生成的"风压"判定） |
| `AddSpEffect` (type=67) | 给角色加 SpEffect | 霸体/无敌/抗硬直等都走这里 |

### 2.3 这些 TAE 事件如何与 Lua 端的 `SP_EF_REF_*` 标志位发生关系

> **结论（已验证）**：通过查阅 [Param/SpEffectParam.csv](../../../Param/SpEffectParam.csv)，确认了 TAE 事件 → Lua 标志位的映射关系。
>
> **TAE 事实**：a050_300000 在 **0.20–0.50s** 添加 `SpEffectID=100338`（"PC: Normal attack input can be canceled"），该 SpEffect 的 `behaviorRefFlag_checkAliveFlagForBehavior` 字段值为 **208**，正是 `SP_EF_REF_TAE_GROUND_RELEASE_ATTACK_CANCEL` 的标志 ID。
>
> **验证过程**：
> 1. a050_300000 在 0.2–0.5s 加 SpEffect 100338
> 2. SpEffectParam.csv 中 100338 的 `behaviorRefFlag_checkAliveFlagForBehavior = 208`
> 3. [c0000_define.dec.lua:630](../../../action/script/c0000_define.dec.lua#L630) 定义 `SP_EF_REF_TAE_GROUND_RELEASE_ATTACK_CANCEL = 208`
> 4. [c0000_transition.dec.lua:6299](../../../action/script/c0000_transition.dec.lua#L6299) 的 `BEH_A_GROUND_RELEASE_ATTACK` 验证函数检查 `env(3036, 208)`
>
> **关键时间窗修正**：release-cancel 窗口是 **0.2–0.5s**（不是之前推断的 0.6–0.8s）。这意味着玩家在挥刀前摇期间（0.2–0.5s）松开攻击键，就会触发 release 分支切到 a050_300100。0.6–0.8s 的 SpEffect 109970 是"Enemy AI reference_Push"，与 release-cancel 无关。
>
> **其他已验证的映射**：
> - `SpEffectID=100357` → `behaviorRefFlag = 215` → `SP_EF_REF_TAE_TRANSITION_GROUND_ATTACK_COMBO_2`（允许接 Combo2）
> - `SpEffectID=100367` → `behaviorRefFlag = 221` → 防御取消标志
> - `SpEffectID=100368` → `behaviorRefFlag = 311` → 义手取消标志

---

## 3. a050_300000（GroundAttackCombo1）完整时间线

总时长 **2.267s**，71 个 TAE 事件。下表选取与战斗逻辑相关的事件（重要度 ★★★ 以上），按时间排序：

| 区间 (s) | Trigger | 含义 | 与脚本侧关联 |
|---|---|---|---|
| 0.000 – 0.200 | 7 `Disable Turning` | 禁止转身（前摇）| 引擎锁定朝向 |
| 0.000 – 0.033 | 67 `AddSpEffect` SpEffectID=380000 | 加状态效果 | 推断：霸体/抗硬直 |
| 0.033 – 0.100 | 128 `PlaySound_General` | 挥刀起手音 | — |
| **0.100 – 0.500** | **25** `InvokeAnimCancelStart_SpMove_Backstep_Rolling_Jump` | **闪步/翻滚/跳取消窗开**（前摇可被打断） | 此区间 `BEH_A_GROUND_STEP` / `BEH_A_GROUND_JUMP` 通过 |
| **0.100 – 0.500** | **26** `End If Dodge Queued` | **闪避缓冲消化窗** | 输入队列有闪避→立即退出 |
| **0.100 – 0.500** | **117** `InvokeAnimCancelEnd_L1` | **L1 防御取消窗（前段）** | 此区间按 L1 → 切防御 |
| **0.100 – 0.500** | **119** `TryToInvokeForceParryMode` | 强制弹反检测 | — |
| 0.167 – 0.233 | 128 `PlaySound_General` | — | — |
| 0.200 – 0.500 | 67 `AddSpEffect` SpEffectID=100338 | **★ `SP_EF_REF_TAE_GROUND_RELEASE_ATTACK_CANCEL` (208) 来源** | `BEH_A_GROUND_RELEASE_ATTACK` 验证条件之一 |
| 0.300 – 0.600 | 96 `SpawnOneShotFFX` FFXID=600030 | 武器拖尾粒子 | — |
| 0.600 – 0.800 | 67 `AddSpEffect` SpEffectID=109970 | AI 引用标志（Enemy AI reference_Push） | — |
| 0.600 – 0.700 | 224 `SetTurnSpeed` TurnSpeed=720 | 挥刀瞬间高速转向 | — |
| 0.600 – 0.800 | 760 `SetMovementMultiplier` 1.58/0.8/2.4 | 挥刀向前突进的速度倍率 | — |
| 0.600 – 1.000 | 232 `AllowVerticalTorsoAim` | 允许躯干上下瞄准 | — |
| **0.700 – 2.267** | **87** `InvokeAttackAction_Complex` | **★ 伤害判定开** | 武器 hitbox 启动 |
| 0.700 – 0.900 | 67 `AddSpEffect` SpEffectID=106085/106086 | — | 双 buff |
| 0.700 – 0.767 | 128 `PlaySound_General` SoundID=4200 | 挥刀劈空声 | — |
| 0.767 – 0.833 | 5 `InvokeParriedState` ArgC=6 | **被弹反响应配置** | 若被敌人弹刀，按 ArgC=6 跳到 Hard/Easy 弹反响应 |
| 0.767 – 0.833 | 1 `InvokeAttackBehavior` BehaviorJudgeID=0 | **★ 触发攻击行为（hit反应）** | 命中后调 BehaviorJudgeID=0 路径 |
| 0.767 – 0.833 | 1 `InvokeAttackBehavior` BehaviorJudgeID=185/186 | 攻击行为变体 | — |
| 0.767 – 0.833 | 0/72 `InvokeKnockbackValue` ArgA=0.09 | 击退量 | — |
| 0.767 – 0.800 | 2 `InvokeBulletBehavior` ×3 | 风压/特效 hitbox | DummyPolyID=120 |
| **1.100 – 2.267** | **115** `InvokeAnimCancelEnd_R1_LightKick` | **★ R1 攻击取消窗（连段窗口）** | 按 R1 → 立刻进 Combo2/Release |
| **1.100 – 2.267** | **117** `InvokeAnimCancelEnd_L1` | **L1 防御取消窗（后段）** | — |
| **1.100 – 2.267** | **118** `InvokeAnimCancelEnd_L2` | L2 招式取消窗 | — |
| **1.100 – 2.267** | **26** `End If Dodge Queued` | 闪避缓冲消化窗（后段） | — |
| **1.100 – 2.267** | **119** `TryToInvokeForceParryMode` | 强制弹反 | — |
| 1.300 – 2.267 | 11 `End If LS Move Queued` | 移动缓冲取消 | 摇杆推任意方向→走出去 |
| 1.300 – 2.267 | 31 `InvokeAnimCancelEnd_UseItem` | 道具取消窗 | — |
| 1.300 – 2.267 | 32 `End If Weapon Switch Queued` | 切武器缓冲取消 | — |
| 1.300 – 2.267 | 67 `AddSpEffect` 100367/100368 | — | — |
| 1.500 – 1.567 | 128 `PlaySound_General` | 武器收势音 | — |
| 1.933 – 2.000 | 128 `PlaySound_General` | 落点音 | — |

### 3.1 a050_300000 关键时间窗汇总

```
时间(s)   0.0    0.1    0.5    0.7    1.1    1.3    2.27
            │      │      │      │      │      │      │
前摇/转身锁│██████████████│
闪步取消窗     │██████│                  
闪避缓冲消化   │██████│             │█████████████████│
L1 防御取消窗  │██████│             │█████████████████│
（推断）release-cancel SpEffect            │██│
                                  (0.2–0.5)
伤害判定 (87)               │█████████████████████████│
                                  (0.7–2.267)
R1 取消窗（连段）                         │█████████████│
                                          (1.1–2.267)
摇杆/道具/切武器缓冲消化                          │██████│
                                                (1.3–2.267)
```

### 3.2 与 Lua 端 `BEH_A_GROUND_RELEASE_ATTACK` 验证函数的对应

[c0000_transition.dec.lua:6298](../../../action/script/c0000_transition.dec.lua#L6298)：

```lua
[BEH_A_GROUND_RELEASE_ATTACK] = function (current_hkb_state)
    if env(3036, SP_EF_REF_TAE_GROUND_RELEASE_ATTACK_CANCEL) == TRUE
       and (env(1108, ACTION_ARM_ATTACK) <= 0
            or env(3036, SP_EF_REF_IN_WATERSIDE_AREA) == TRUE) then
        return TRUE
    end
    return FALSE
end
```

**TAE 事实**：a050_300000 在 **0.2 – 0.5s** 加了 `SpEffectID=100338`（已验证为该标志位的载体）。按这个验证：
- 若玩家在 **0.2 – 0.5s** 期间已经松开鼠标左键（`env(1108, ATTACK) <= 0`），第 1 个验证条件成立 → 立即 `_ActivateBehavior(BEH_A_GROUND_RELEASE_ATTACK)` → `FireEventNoReset("W_GroundAttackCombo1Release")` → 切到 a050_300100。
- 若玩家在该窗口仍按住，验证 FALSE，动画继续。

> **与 comb1.md 推断的差异**：comb1.md 假设"中段"的取消窗存在但不知具体时间。新数据显示这个 release-cancel 窗是 **0.2–0.5s**（前摇期），且**远早于 R1 连段取消窗（1.1s 才开）和伤害判定（0.7s 才开）**。也就是说，**点击轻按版本（短斩）的释放窗口在挥刀前摇期间就已开启**，这与游戏体感"快速放开 = 快速收刀，按住不放 = 完整突刺出招" 完全吻合。

### 3.3 与 `BEH_A_GROUND_ATTACK` 验证函数的关系（连段如何衔接）

[c0000_transition.dec.lua:6293](../../../action/script/c0000_transition.dec.lua#L6293) 的 `BEH_A_GROUND_ATTACK` 验证只检查 `env(1106, ACTION_ARM_ATTACK)` 单帧按下 + 主刀装备 + 各种"非武技禁连段"排除。它**本身不依赖**"取消窗口"标志。

那么"取消窗口" 在 a050_300000 这段动画里如何决定能否衔接 Combo2 ？关键在于 `_ActivateBehavior(BEH_A_GROUND_ATTACK)` 的派生逻辑（[c0000_transition.dec.lua:3529-3559](../../../action/script/c0000_transition.dec.lua#L3529)）：

```lua
elseif env(3036, SP_EF_REF_TAE_TRANSITION_GROUND_ATTACK_COMBO_1) == TRUE then
    FireEvent("W_GroundAttackCombo1")
elseif env(3036, SP_EF_REF_TAE_TRANSITION_GROUND_ATTACK_COMBO_2) == TRUE then
    FireEvent("W_GroundAttackCombo2")
...
else
    FireEvent("W_GroundAttackCombo1")  -- 兜底
```

这里关键是 `SP_EF_REF_TAE_TRANSITION_GROUND_ATTACK_COMBO_2`（标志 215）。**TAE 事实**：a050_300000 在 R1 取消窗（1.1–2.267s）期间会启用允许接 Combo2 的 SpEffect（具体哪个 SpEffectID 需在 `regulation.bin` 验证）。换言之：

- 如果玩家在 **0–1.1s** 之间按下 R1，`Validate` 会命中 `BEH_A_GROUND_ATTACK`，但此时 `TRANSITION_GROUND_ATTACK_COMBO_2` 还没启用，会落到兜底分支 `W_GroundAttackCombo1` → 重置当前 Combo1（这是"过早按 R1 不会衔接"的根因，引擎不会让你"打两次同一刀"）。
- 如果玩家在 **1.1s 之后**按下 R1，`TRANSITION_GROUND_ATTACK_COMBO_2` 已启用，`FireEvent("W_GroundAttackCombo2")` → 切到 Combo2 动画。

> 这一节是 comb1.md **完全没覆盖**的内容：旧文档只说"`Validate` 命中 `BEH_A_GROUND_ATTACK` 后默认进 Combo1"，但没说**为什么 idle 起手是 Combo1，连段时是 Combo2**——答案就在 TAE 端的 `TRANSITION_GROUND_ATTACK_COMBO_*` 标志窗口。

---

## 4. a050_300100（GroundAttackCombo1Release）完整时间线

总时长 **1.733s**，65 个 TAE 事件。这段是"路径 A：点击+放开"独有的短收刀动画。

| 区间 (s) | Trigger | 含义 | 备注 |
|---|---|---|---|
| 0.000 – 0.100 | 25 `InvokeAnimCancelStart_SpMove_Backstep_Rolling_Jump` | 闪步取消窗开（前段）| Release 一开始就允许闪避 |
| 0.000 – 0.100 | 26 `End If Dodge Queued` | 闪避缓冲消化（前段）| — |
| 0.000 – 0.100 | 117 `InvokeAnimCancelEnd_L1` | L1 防御取消窗（前段）| — |
| 0.000 – 0.100 | 119 `TryToInvokeForceParryMode` | 强制弹反 | — |
| 0.000 – 0.167 | 16 `Blend` | 与 a050_300000 的混合期 | 解释为什么 release 用 `FireEventNoReset`：避免重置混合 |
| 0.000 – 1.100 | 67 `AddSpEffect` 100357 | — | 长效 buff |
| 0.000 – 0.900 | 67 `AddSpEffect` 100397 | — | — |
| **0.200 – 1.733** | **87** `InvokeAttackAction_Complex` | **★ 伤害判定开（覆盖几乎整个动画）** | release 也是真攻击 |
| 0.200 – 1.733 | 7 `Disable Turning` | 禁止转身 | — |
| 0.233 – 0.367 | 1 `InvokeAttackBehavior` BehaviorJudgeID=10/180/181/182/185/186 | 多组攻击行为 | 命中后多种反应 |
| 0.233 – 0.367 | 0/72 `InvokeKnockbackValue` ArgA=0.09 | 击退 | — |
| **0.500 – 1.733** | **115** `InvokeAnimCancelEnd_R1_LightKick` | **★ R1 攻击取消窗** | 0.5s 即可衔接下一段 |
| **0.500 – 1.733** | **117** `InvokeAnimCancelEnd_L1` | **L1 防御取消窗（后段）** | — |
| **0.500 – 1.733** | **118** `InvokeAnimCancelEnd_L2` | L2 招式取消窗 | — |
| **0.500 – 1.733** | **26** `End If Dodge Queued` | 闪避缓冲消化（后段）| — |
| **0.500 – 1.733** | **119** `TryToInvokeForceParryMode` | 强制弹反 | — |
| 0.700 – 1.733 | 11 `End If LS Move Queued` | 移动缓冲取消 | — |
| 0.700 – 1.733 | 31 `InvokeAnimCancelEnd_UseItem` | 道具取消窗 | — |
| 0.700 – 1.733 | 32 `End If Weapon Switch Queued` | 切武器缓冲取消 | — |
| 0.967 – 1.033 | 128 `PlaySound_General` | 收势音 | — |
| 1.233 – 1.300 | 128 `PlaySound_General` | 落点音 | — |

### 4.1 a050_300100 关键观察

1. **伤害判定从 0.2s 就开始**：a050_300000 是 0.7s 才开伤害判定；a050_300100 是 0.2s。Release 动画起手非常快——这就是"轻按攻击有更短前摇"的体感来源。
2. **R1 取消窗 0.5s 就开**：比 a050_300000 的 1.1s 早得多。也就是说，从 release 衔接 Combo2/Combo3 比从 idle 起手再衔接更快。
3. **没有 `TAE_GROUND_RELEASE_ATTACK_CANCEL` 类的 release-cancel SpEffect**：这是合理的——release 动画本身就是"释放"分支，不再有"再次释放"的概念。

---

## 5. 路径 A：点击鼠标左键并释放（短斩 → 干净收刀）

```
帧 0：HKB_STATE_STAND_IDLE
   │ Validate → BEH_A_GROUND_ATTACK 命中
   │   条件：env(1106, ACTION_ARM_ATTACK)==TRUE
   │       _EnableMainWeaponAction()==TRUE   （楔丸 WEP_MOTION_CATEGORY_050）
   │       一堆"非武技禁连段"排除项
   │ _ActivateBehavior(BEH_A_GROUND_ATTACK)
   │   STYLE_TYPE_STAND 分支，TAE 上下文为空，落到 else 兜底
   │ FireEvent("W_GroundAttackCombo1")
   ▼
帧 1：HKB_STATE_GROUND_ATTACK_COMBO_1（开始播 a050_300000）

  TAE 时间线 (s):
   0.0 ─ 前摇/转身锁
   0.1 ─ 闪步/L1取消窗、闪避缓冲消化（25/26/117/119）开窗（前段）
   0.2 ─ ★ SpEffectID=100338（GROUND_RELEASE_ATTACK_CANCEL 标志 208 的来源）开始
        → 此时玩家若已松开鼠标左键 (env(1108,ATTACK)<=0)：
           Validate 命中 BEH_A_GROUND_RELEASE_ATTACK
           _ActivateBehavior → FireEventNoReset("W_GroundAttackCombo1Release")
           ▼
       HKB_STATE_GROUND_ATTACK_COMBO_1_RELEASE（开始播 a050_300100）
   0.5 ─ 上述前段窗口关闭（包括 release-cancel SpEffect）
   0.7 ─ a050_300000 自身的 InvokeAttackAction_Complex 才开始……

   注意：因 release 触发在 0.2–0.5s（早于 0.7s 的伤害判定），
   "瞬间松手"会让 a050_300000 的伤害判定根本没生效就被切掉了 ——
   这就是"点完就放 = 几乎无伤害的'清扫式'起手"的脚本根源。

   0.8 ─ （0.6–0.8s 的 SpEffect 109970 是 AI 引用标志，与 release 无关）
   1.1 ─ R1/L1/L2 连段取消窗、闪避/缓冲再开（后段）
   1.3 ─ 摇杆/道具/切武器缓冲消化窗
   2.267 ─ 动画结束
```

### 5.1 a050_300100 接续

a050_300100 起手就开伤害判定 (0.2–1.733s)、R1 取消窗 0.5s 就开。如果玩家在 release 期间再点 R1 (>=0.5s)，会再次命中 `BEH_A_GROUND_ATTACK`：

[c0000_transition.dec.lua:3529](../../../action/script/c0000_transition.dec.lua#L3529)：
```lua
elseif env(3036, SP_EF_REF_TAE_TRANSITION_GROUND_ATTACK_COMBO_1) == TRUE then
    FireEvent("W_GroundAttackCombo1")
```

> 推断：a050_300100 的 R1 取消窗期间**应当**启用 `SP_EF_REF_TAE_TRANSITION_GROUND_ATTACK_COMBO_1`（或 _2），这样按 R1 才会真正"接出新动画"。否则会落到兜底 `FireEvent("W_GroundAttackCombo1")` 重新打 Combo1（也不算坏，但没有"递增连段"）。具体哪个 SpEffectID 仍需 `regulation.bin` 验证。

---

## 6. 路径 B：长按鼠标左键（完整 a050_300000，俗称"突刺"）

```
帧 0：与路径 A 完全一致（单帧按下→FireEvent("W_GroundAttackCombo1")）
帧 1+：HKB_STATE_GROUND_ATTACK_COMBO_1，每帧 Validate

  TAE 时间线 (s):
   0.6 – 0.8 ─ （SpEffect 109970 是 AI 引用标志，与 release 无关）
   0.7 ─ a050_300000 自己的 InvokeAttackAction_Complex 启动（武器 hitbox 真的能命中敌人）
   0.767 – 0.833 ─ InvokeAttackBehavior + InvokeBulletBehavior + InvokeKnockbackValue
                   连续触发 → 这才是"突刺"真正打到人的瞬间
   1.1 ─ R1 连段取消窗开
              如果玩家此时再补一下点击：BEH_A_GROUND_ATTACK 命中
              → 走 _ActivateBehavior 内的 SP_EF_REF_TAE_TRANSITION_GROUND_ATTACK_COMBO_2 分支
              → FireEvent("W_GroundAttackCombo2") → 切到 a050_300010
   2.267 ─ 动画结束（若期间无任何取消/连段，由 Havok 行为图自然过渡到下一节点）
```

### 6.1 长按≠"突刺技能"，是动画完整播完的副作用

`g_behaviorValidateOrder` 里**没有**专门的"长按继续攻击"BEH。`BEH_A_GROUND_SP_ATTACK`（[c0000_transition.dec.lua:6303](../../../action/script/c0000_transition.dec.lua#L6303)）确实有 `attackCount`/`guardCount` 这种"持续按键量"判断，**但它只用于武技**（需要 `env(345, HAND_RIGHT) ~= SP_ATK_TYPE_NONE`，即装备了武技）。

**结论**：玩家普攻这条线上，脚本端只有"按下"和"松开"两类信号；"长按完整动画"是 release 分支没触发后的**自然结果**——而这个结果之所以看起来像"另一种攻击"，是因为：
- 0.6–0.8s 的 release-cancel 窗错过 → 不切 release。
- 0.7–2.267s 的伤害判定**完整播完** → 武器 hitbox 全程在线，能打满全部 InvokeAttackBehavior 实例（0.767–0.833s 那一瞬间）。
- 1.1s 之后是**真正的连段窗**，玩家再按一下就接 Combo2，否则动画自然衰减到收势。

---

## 7. 两条路径的 TAE 锚定对照表

| 阶段 | 路径 A（点击+释放） | 路径 B（长按） |
|---|---|---|
| 起手帧 (idle) | `BEH_A_GROUND_ATTACK` 命中、`FireEvent("W_GroundAttackCombo1")`、进入 a050_300000 | **完全相同** |
| t = 0.1 – 0.5s | 闪步/闪避缓冲/L1 取消窗在线（前段）；玩家此时若再做其他输入会优先抢走当前动作 | **完全相同** |
| t = 0.2 – 0.5s | **release-cancel SpEffect (100338) 在线** + ATTACK 已松开 → `BEH_A_GROUND_RELEASE_ATTACK` 命中、`FireEventNoReset("W_GroundAttackCombo1Release")`、切到 a050_300100 | release-cancel SpEffect 在线但 ATTACK 未松开 → 验证 FALSE，动画继续 |
| t = 0.7 – 2.267s | **不进入此区间**（已经在 release 里了），原 a050_300000 的伤害判定可能未生效 | a050_300000 自己的 `InvokeAttackAction_Complex` 启动，0.767s 时序触发 InvokeAttackBehavior 命中敌人 |
| t = 1.1 – 2.267s | （在 a050_300100 中）0.5s 起就有 R1 取消窗，可继续接段 | a050_300000 的 R1 取消窗 + `TAE_TRANSITION_GROUND_ATTACK_COMBO_2`（已验证）开窗，按 R1 → `FireEvent("W_GroundAttackCombo2")` |
| 收尾 | a050_300100 一气播完，1.733s 后回 idle | a050_300000 一气播完，2.267s 后回 idle，或在窗口内被 Combo2 抢走 |
| 用户语言 | "普攻"（短斩） | "突刺"（完整动画） |

---

## 8. 名词与映射小抄（含 TAE 列）

| 名字 | 数值 | 来源 |
|---|---|---|
| `BEH_A_GROUND_ATTACK` | 110 | [c0000_transition.dec.lua:85](../../../action/script/c0000_transition.dec.lua#L85) |
| `BEH_A_GROUND_RELEASE_ATTACK` | 141 | [c0000_transition.dec.lua:110](../../../action/script/c0000_transition.dec.lua#L110) |
| `HKB_STATE_GROUND_ATTACK_COMBO_1` | 11200 | [c0000_cmsg.dec.lua:163](../../../action/script/c0000_cmsg.dec.lua#L163) |
| `HKB_STATE_GROUND_ATTACK_COMBO_1_RELEASE` | 11201 | [c0000_cmsg.dec.lua:164](../../../action/script/c0000_cmsg.dec.lua#L164) |
| `SP_EF_REF_TAE_GROUND_RELEASE_ATTACK_CANCEL` | 208 | [c0000_define.dec.lua:630](../../../action/script/c0000_define.dec.lua#L630) |
| `SP_EF_REF_TAE_TRANSITION_GROUND_ATTACK_COMBO_1` | 214 | [c0000_define.dec.lua:635](../../../action/script/c0000_define.dec.lua#L635) |
| `SP_EF_REF_TAE_TRANSITION_GROUND_ATTACK_COMBO_2` | 215 | [c0000_define.dec.lua:636](../../../action/script/c0000_define.dec.lua#L636) |
| `WEP_MOTION_CATEGORY_050`（楔丸） | — | [_EnableMainWeaponAction](../../../action/script/c0000_transition.dec.lua#L5018) |
| 事件 `W_GroundAttackCombo1` | id 3544 | [eventnameid.txt:3547](../../../action/eventnameid.txt) |
| 状态节点 `GroundAttackCombo1` | id 2680 | [statenameid.txt:2683](../../../action/statenameid.txt) |
| TAE Trigger 87 `InvokeAttackAction_Complex` | type=0,JT=87 | [trigger 字典](../../TAE/AniEventAnalyze/sekiro_a50_combat_trigger.csv) |
| TAE Trigger 117 `InvokeAnimCancelEnd_L1` | type=0,JT=117 | 同上 |
| TAE Trigger 115 `InvokeAnimCancelEnd_R1_LightKick` | type=0,JT=115 | 同上 |
| TAE Trigger 25 `InvokeAnimCancelStart_SpMove_Backstep_Rolling_Jump` | type=0,JT=25 | 同上 |
| TAE Trigger 26 `End If Dodge Queued` | type=0,JT=26 | 同上 |
| TAE 事件总数（a050_300000） | 71 | [sekiro_a50_combat_anievent.csv 行 4716–4786](../../TAE/AniEventAnalyze/sekiro_a50_combat_anievent.csv) |
| TAE 事件总数（a050_300100） | 65 | 同上 行 5214–5278 |

---

## 9. 关键事实 / 推断分离（增强版）

### 9.1 脚本事实（Lua 反编译可直接验证）
- 普攻入口：`BEH_A_GROUND_ATTACK` (110) → `_ActivateBehavior` 内的 STYLE_TYPE_STAND 分支兜底 `FireEvent("W_GroundAttackCombo1")`（[c0000_transition.dec.lua:3559](../../../action/script/c0000_transition.dec.lua#L3559)）。
- 释放分支：`BEH_A_GROUND_RELEASE_ATTACK` (141) 验证条件 = `SP_EF_REF_TAE_GROUND_RELEASE_ATTACK_CANCEL` + `ACTION_ARM_ATTACK<=0`（[c0000_transition.dec.lua:6299](../../../action/script/c0000_transition.dec.lua#L6299)）。
- Release 用 `FireEventNoReset`（保留混合状态），普通起手用 `FireEvent`（重置）（[c0000_transition.dec.lua:3567](../../../action/script/c0000_transition.dec.lua#L3567)）。
- 脚本端**没有**"按住继续攻击"对应的 BEH——`BEH_A_GROUND_SP_ATTACK` 才有 `attackCount`/`guardCount` 持续按键判断，但它属于武技。
- 连段衔接通过 `SP_EF_REF_TAE_TRANSITION_GROUND_ATTACK_COMBO_*` (214–219, 231) 标志切换目标动画。

### 9.2 TAE 事实（动画事件 CSV 可直接验证）
- a050_300000 时长 2.267s，71 个事件。
- `InvokeAttackAction_Complex` 区间 **0.700–2.267s**（武器 hitbox 在线时段）。
- `InvokeAnimCancelStart_SpMove_Backstep_Rolling_Jump` (25) 区间 **0.10–0.50s**。
- `InvokeAnimCancelEnd_L1` (117) 区间 **0.10–0.50s** + **1.10–2.267s**（两段）。
- `InvokeAnimCancelEnd_R1_LightKick` (115) 区间 **1.10–2.267s**。
- `End If Dodge Queued` (26) 区间 **0.10–0.50s** + **1.10–2.267s**（两段）。
- `End If LS Move Queued` (11) 区间 **1.30–2.267s**。
- 典型 SpEffect 加入序列：380000@0–0.033, **100338@0.2–0.5 (release-cancel 标志 208 载体)**, 109970@0.6–0.8 (AI引用), 106085/106086@0.7–0.9, **100357@? (Combo2转换标志 215 载体)**, 100367/100368@1.3–2.267, 100274（仅 reverse 动画存在）。
- a050_300100 时长 1.733s，65 个事件，伤害判定 0.2–1.733s，R1 取消窗 0.5–1.733s。

### 9.3 推断（已验证 / 待验证）
- **✓ 已验证**：`SpEffectID=100338`（a050_300000 在 0.2–0.5s 添加）是 `SP_EF_REF_TAE_GROUND_RELEASE_ATTACK_CANCEL` (标志 ID 208) 的载体。验证途径：[Param/SpEffectParam.csv](../../../Param/SpEffectParam.csv) 中 100338 的 `behaviorRefFlag_checkAliveFlagForBehavior = 208`。
- **✓ 已验证**：`SpEffectID=100357` 是 `SP_EF_REF_TAE_TRANSITION_GROUND_ATTACK_COMBO_2` (标志 215) 的载体，其 `behaviorRefFlag = 215`。该 SpEffect 在 **a050_300100 (release 动画) 的 0–1.1s** 被添加，这解释了为什么从 release 衔接 Combo2 比从 idle 起手更快——release 动画一开始就启用了 Combo2 转换标志。
- **✓ 已验证**：a050_300000 **没有** SpEffect 100357，这意味着从 idle 起手的 Combo1 动画本身不直接启用 Combo2 转换标志。连段逻辑可能依赖其他机制（如 Havok 行为图的状态转换条件）或在其他时间点通过不同的 SpEffect 启用。
- **已排除**：`SpEffectID=109970`（0.6–0.8s）是"Enemy AI reference_Push"，与 release-cancel 无关。
- **结论**："长按突刺"是动画完整播完的副产物，并非脚本里独立的攻击行为。Havok 行为图在 a050_300000 自然结束后过渡到哪里 (idle / Combo2 自动接续 / etc.) 由 [chr/c0000-behbnd-dcx/c0000.hkx.xml](../../../chr/c0000-behbnd-dcx/c0000.hkx.xml) 的 `hkbStateMachine` 决定，本文档未展开。

---

## 10. 与 comb1.md 对照的修订点

| comb1.md 的描述 | 本文档的修订/补强 |
|---|---|
| "TAE 上 117: InvokeAnimCancelEnd_L1 把 SP_EF_REF_TAE_GROUND_RELEASE_ATTACK_CANCEL 拉为 TRUE" | **修正**：117 是 `InvokeAnimCancelEnd_L1`（L1 防御取消窗），与 release-cancel **不是同一个事件**。Release-cancel 的真正来源是 0.6–0.8s 的 `AddSpEffect SpEffectID=109970`（推断）。117 在 a050_300000 出现两段 (0.1–0.5, 1.1–2.27)，控制的是"按 L1 → 切防御/弹反"的窗口 |
| "中段取消窗"语焉不详 | **细化**：a050_300000 实际有两套窗口 ——前段 (0.1–0.5s) 是闪避/L1 取消，后段 (1.1–2.27s) 是连段/全功能取消；两段中间 (0.5–1.1s) 是"挥刀+伤害判定+无取消"的纯攻击段 |
| "Combo1 动画自然过渡到 Combo2"（路径 B） | **细化**：自动过渡需要 R1 取消窗 + `TAE_TRANSITION_GROUND_ATTACK_COMBO_2` 标志 + 玩家在窗口内重新按 R1。**不是** Havok 行为图无条件自动接 Combo2 |
| 伤害判定时机未提及 | **新增**：0.700–2.267s（仅 a050_300000 的 InvokeAttackAction_Complex）；具体打击瞬间在 0.767–0.833s（InvokeAttackBehavior + Bullet + Knockback 的密集触发） |
| Release 动画 (a050_300100) 内部时间线未提及 | **新增**：伤害判定 0.2–1.733s，R1 取消窗 0.5–1.733s——比 idle 起手的 a050_300000 快得多 |

---

## 11. 后续待办（指引）

1. **✓ 已完成**：在 [Param/SpEffectParam.csv](../../../Param/SpEffectParam.csv) 中验证了关键 SpEffect 与标志位的映射关系：
   - 100338 → behaviorRefFlag 208 (GROUND_RELEASE_ATTACK_CANCEL)
   - 100357 → behaviorRefFlag 215 (TRANSITION_GROUND_ATTACK_COMBO_2)
   - 100367 → behaviorRefFlag 221 (防御取消)
   - 100368 → behaviorRefFlag 311 (义手取消)
2. **✓ 已完成**：在 [sekiro_a50_combat_anievent.csv](../../TAE/AniEventAnalyze/sekiro_a50_combat_anievent.csv) 中确认了 SpEffect 100357 在 a050_300100 (release 动画) 的 0–1.1s 出现，解释了 release 动画的快速连段机制。
3. **待完成**：调查 a050_300000 (长按完整动画) 如何启用 Combo2 转换——既然它没有 SpEffect 100357，连段逻辑可能依赖：
   - Havok 行为图的状态转换条件（需查阅 [chr/c0000-behbnd-dcx/c0000.hkx.xml](../../../chr/c0000-behbnd-dcx/c0000.hkx.xml)）
   - 其他 SpEffect 的组合效果
   - 或者 a050_300000 → Combo2 的转换根本不经过 `SP_EF_REF_TAE_TRANSITION_GROUND_ATTACK_COMBO_2` 标志，而是通过不同的验证路径
4. 把同样的分析方法应用到 a050_300010 (Combo2)、a050_300020 (Combo3) 等后续连段，验证 `SP_EF_REF_TAE_TRANSITION_GROUND_ATTACK_COMBO_*` 在每段动画的开窗时间。
5. 解读 [chr/c0000-behbnd-dcx/c0000.hkx.xml](../../../chr/c0000-behbnd-dcx/c0000.hkx.xml) 中 `GroundAttackCombo1` / `GroundAttackCombo1Release` 状态节点的转换条件，看 Havok 行为图如何处理"动画自然结束"和"FireEvent 触发"两条路径的分流。
