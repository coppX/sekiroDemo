# `act(id, ...)` 函数参考

本文档基于 [action/script/](../action/script/) 下五个反编译脚本（`c0000.dec.lua`、`c0000_transition.dec.lua`、`c0000_define.dec.lua`、`c0000_cmsg.dec.lua`、`c1010.dec.lua`）共 **688 处 `act(...)` 调用**整理而来。

## 总体说明

`act(id, ...)` 与 [`env(id, ...)`](Lua%20env.md) 是引擎暴露给 Lua 行为脚本的两个核心绑定：

- **`env`**：只读查询（询问引擎"现在是什么状态？"）。
- **`act`**：写指令（让引擎"去做某件事"）——驱动播放音效、特效、改变动画标志位、写 Havok 行为变量、清除受伤状态、注册下一帧投技/动作、推送 UI 提示等。

两个参数的关系：**第一个参数（`id`）是动作类型**，第二个参数（以及后续可选参数）是该动作类型所需的具体载荷或子类型。同一个 `id` 一般有固定的参数语义；不同 `id` 之间没有强约束。

> ⚠️ 本仓库为静态反编译，**没有引擎源码**。下面所有语义都是从代码上下文、常量名（`DAMAGE_FLAG_*`、`HAND_*` 等）和命名习惯推断出来的。**观察到的事实（参数取值、调用位置）是确定的；功能解释属于推断**——具体见每条记录右侧的"置信度"标记。

置信度图例：**高**＝多处证据互相印证或语义一目了然；**中**＝可推断但存在多义性；**低**＝仅凭参数名/单一调用现场猜测。

## 按 ID 段速查

| ID 段 | 用途归类 |
|---|---|
| 100 系（101、123、127、135–141、147–161） | 玩家状态/状态机底层指令：暂停、清除受伤、播放投技反应、设置伤害吸收方向、注册可投状态等 |
| 2000 系（2002、2015、2018、2019、2024） | 触发特殊效果（SP_EFFECT）、设置着地/跳跃前摇、计时器 |
| 3000 系（3004、3011、3016–3037） | 高阶玩家行为：钩索、攀爬、动作引导 UI、跳跃方向预计算、投技状态、踢墙、闪避等 |
| 9000 系（9000–9103） | 调试/底层 Havok 联动：打印、Reset、State 变化通告、节点查询 |

## 详细记录

### 100 系——玩家底层状态指令

#### `act(101, bool)` — 锁定/解锁"动作输入接受"标志位 (置信度：中)
- 出现在 [c0000.dec.lua:119](../action/script/c0000.dec.lua#L119) 的 `Update()` 末尾被设为 `FALSE`，并在 [c0000.dec.lua:271](../action/script/c0000.dec.lua#L271) 等多处 `STATE_TYPE_LOWER`、`STATE_TYPE_STANDBY`、`STATE_TYPE_STANDBY_GUARD`、`STATE_TYPE_STANDBY_ATK` 等待机/上半身动作分支中被设为 `TRUE`。
- 同时在 [c0000_transition.dec.lua:2460](../action/script/c0000_transition.dec.lua#L2460)（`BEH_A_GROUND_MOVE_START`）、[c0000_transition.dec.lua:2555](../action/script/c0000_transition.dec.lua#L2555)、[c0000_cmsg.dec.lua:2254](../action/script/c0000_cmsg.dec.lua#L2254) 出现。
- 第二个参数为 `TRUE`/`FALSE`（即 `1/0`）。
- 推断：每帧默认 `Update()` 关闭，仅在玩家处于"可接受输入的待机/动作分支"时打开。可能与 `_SpeedUpdate()` 联动控制移动速度刷新。

#### `act(123)` — 触发"道具使用失败/打断"反馈 (置信度：低)
- [c0000_transition.dec.lua:4127](../action/script/c0000_transition.dec.lua#L4127)、[c0000_transition.dec.lua:4622](../action/script/c0000_transition.dec.lua#L4622)：在 `BEH_A_USE_ITEM`/`BEH_A_AGING_USE_ITEM` 分支里，当 `env(113) == TRUE` 时调用，紧跟 `ResetRequest()`。
- 推断：可能用于显示 UI"无法使用"提示或退还使用计数。

#### `act(127)` — 清除/重置当前受伤反应状态 (置信度：高)
- 高频出现在所有 `BEH_R_*`（受伤、防御、被击破、死亡）反应分支的入口，以及 `c0000_cmsg.dec.lua : ThrowScript_onActivate()`（[14461](../action/script/c0000_cmsg.dec.lua#L14461)）。
- [c0000_transition.dec.lua:1035](../action/script/c0000_transition.dec.lua#L1035) 含原始注释：`act(127)  -- 清除当前受伤状态`；[c0000_transition.dec.lua:1123](../action/script/c0000_transition.dec.lua#L1123) 含注释：`act(127)  -- 清除受伤状态`。
- 无参数。
- 用途：打开新一轮受伤/防御反应前，先丢弃旧的受伤累积状态（受伤等级、僵直堆栈等），让新动画干净播放。

#### `act(135)` — 投技防御结束清理 (置信度：中)
- 仅出现在 `c0000_cmsg.dec.lua : ThrowDef6XXXXX_onDeactivate()` 系列（[15864](../action/script/c0000_cmsg.dec.lua#L15864) 起约 50 处），与 `act(9101)` 在 `_onActivate` 配对。
- 推断：解除被投技状态时归还角色控制权/重置投技解算器。

#### `act(136, 0)` — 重置投技请求/相关计时 (置信度：中)
- [c0000.dec.lua:150](../action/script/c0000.dec.lua#L150) 在 `Initialize()` 调用；[c0000_transition.dec.lua:288](../action/script/c0000_transition.dec.lua#L288)、[c0000_transition.dec.lua:315](../action/script/c0000_transition.dec.lua#L315)、[c0000_transition.dec.lua:331](../action/script/c0000_transition.dec.lua#L331)、[c0000_transition.dec.lua:400](../action/script/c0000_transition.dec.lua#L400) 等死亡/传送/进入投技结束分支调用；[c0000_cmsg.dec.lua:14467](../action/script/c0000_cmsg.dec.lua#L14467) 在 `ThrowScript_onDeactivate()` 调用。
- 第二个参数恒为 `0`，可能表示"清零"。
- 推断：重置投技/特殊脚本的全局计时器或动画 ID。

#### `act(138)` — 启用动作按钮显示（A 键提示） (置信度：中)
- 紧跟 `act(3034, ACTION_BUTTON_EXEC_TYPE_*)` 出现，覆盖 `STAND/CROUCH/HANG/SWIM/...` 各种姿态的 `EVENT_ENABLE_ACTION_BUTTON` 状态。
- 例：[c0000.dec.lua:381–384](../action/script/c0000.dec.lua#L381)、[c0000.dec.lua:472–474](../action/script/c0000.dec.lua#L472)、[c0000.dec.lua:677–679](../action/script/c0000.dec.lua#L677)。
- 推断：把"按 X 交互/对话/拾取"的提示推到 UI 层。`3034` 是注册具体执行类型，`138` 是激活提示。

#### `act(139)` — Warp/Map-event 通用入口指令 (置信度：低)
- 唯一调用 [c0000.dec.lua:248](../action/script/c0000.dec.lua#L248)：`UpdateAddState()` 检测到 `event_id ∈ {710200, 710201, 710203, 710204, 710205, 710206, 710207}`（地图/事件相关 EventName ID），调用 `act(139)` 后 `FireEvent("W_Event"..event_id)`。
- 推断：在播放地图传送/事件动画前进行某种通用前置处理（如禁用碰撞或解锁相机）。

#### `act(141, DAMAGE_FLAG_*)` — 注册受伤动画级别 (置信度：高)
- 第二参数取自 `c0000_define.dec.lua` 的 `DAMAGE_FLAG_*` 枚举：`MINIMUM=0`、`SMALL=1`、`MEDIUM=2`、`LARGE=3`、`SMALL_BLOW=4`、`LARGE_BLOW=5`、`FLING=6`、`BLAST=7`、`PUSH=8`、`BREATH=9`、`WEAK=10`、`GUARD_SMALL=11`、`GUARD_LARGE=12`、`GUARD_EXLARGE=13`、`GUARD_BREAK=14`。
- 高频出现在 [c0000_transition.dec.lua](../action/script/c0000_transition.dec.lua) 的 `BEH_R_HIT_DAMAGE`/`BEH_R_GUARD_DAMAGE` 分支，紧邻 `FireEvent("W_StandDamage*")`、`FireEvent("W_*GuardDamage")` 调用。
- 例：用户当前选中的 [c0000_transition.dec.lua:1695](../action/script/c0000_transition.dec.lua#L1695) `act(141, DAMAGE_FLAG_LARGE)`——这是 `damage_type == DAMAGE_TYPE_DAMAGEBREAK` 且当前已在 `HKB_STATE_STAND_DAMAGE_BREAK` 状态时调用，用于把"已被击破时再次受到致命一击"的动画级别强制标为 LARGE，随后 `FireEvent("W_StandDamageBreakDamage")`。
- 用途：把本帧将要播放的受伤反应"等级标签"写入引擎，让后续 Havok 状态机选择对应的硬直时长、受击位移和音效集合。

#### `act(147)` — 取消/隐藏动作按钮提示 (置信度：中)
- 与 `act(138)` 相对，出现在"按钮可用条件不满足"的早 return 分支。
- 例：[c0000.dec.lua:431](../action/script/c0000.dec.lua#L431)、[c0000.dec.lua:438](../action/script/c0000.dec.lua#L438)、[c0000.dec.lua:470](../action/script/c0000.dec.lua#L470)、[c0000.dec.lua:477](../action/script/c0000.dec.lua#L477)，常见于 `EVENT_ENABLE_ACTION_BUTTON` 内部的 `if env(...) == FALSE then act(147) end`。

#### `act(148, name, value)` — 写入 Havok 行为变量（`SetVariable` 的底层封装） (置信度：高)
- 唯一调用 [c0000.dec.lua:57–59](../action/script/c0000.dec.lua#L57)：
  ```lua
  function SetVariable(name, value)
      act(148, name, value)
  end
  ```
- 三个参数：固定 `148`、变量名字符串、新值。这是脚本层与 Havok 行为图通信的主要写入通道；脚本中绝大多数地方都通过 `SetVariable(...)` 包装调用。

#### `act(150)` — 启用/请求"道具使用上半身分层"播放 (置信度：低)
- [c0000.dec.lua:321](../action/script/c0000.dec.lua#L321) 在 `STATE_TYPE_ACTION_ITEM_USE` 时（且未激活望远镜/未在战斗）调用；[c0000_transition.dec.lua:4139](../action/script/c0000_transition.dec.lua#L4139)、[c0000_transition.dec.lua:4627](../action/script/c0000_transition.dec.lua#L4627) 在 `BEH_A_USE_ITEM` 分支调用，紧邻 `act(154, HAND_RIGHT)`。
- 推断：触发上半身使用道具叠加层混入，让玩家在移动中也能用药/扔暗器。

#### `act(154, HAND_LEFT|HAND_RIGHT)` — 标记下一次"换手"动作 (置信度：中)
- 第二参数取自 `c0000_define.dec.lua`：`HAND_LEFT=0`、`HAND_RIGHT=1`、`HAND_LEFT_BOTH=2`、`HAND_RIGHT_BOTH=3`。
- `HAND_LEFT` 出现在副武器（义手忍具）相关分支：[c0000_transition.dec.lua:665](../action/script/c0000_transition.dec.lua#L665)、[c0000_transition.dec.lua:1152](../action/script/c0000_transition.dec.lua#L1152) 等等，多与 `subWeaponCategory == WEP_MOTION_CATEGORY_074` 检查同框出现。
- `HAND_RIGHT` 出现在主武器（刀）相关分支：[c0000_transition.dec.lua:1321](../action/script/c0000_transition.dec.lua#L1321)（防御伤害开始）、[c0000_transition.dec.lua:3404](../action/script/c0000_transition.dec.lua#L3404)（攻击发起）、[c0000_cmsg.dec.lua:14477](../action/script/c0000_cmsg.dec.lua#L14477) 等共数百处。
- 推断：通知引擎"接下来这个反应/动作走的是哪只手的武器/义手"，影响动画分支和 IK。

#### `act(155, AI_INTERUPT_USE_ITEM)` — 通知 AI 中断（玩家用了葫芦）(置信度：高)
- 第二参数为 `c0000_define.dec.lua:564` 的 `AI_INTERUPT_USE_ITEM = 1`（与 `AI_INTERUPT_FIND_ATTACK = 0` 共一组）。
- 全部出现在 [c0000_transition.dec.lua](../action/script/c0000_transition.dec.lua) 的"葫芦回血"`if itemAnimeType == ITEM_GOURD_RECOVER ...` 等分支：[4190](../action/script/c0000_transition.dec.lua#L4190)、[4259](../action/script/c0000_transition.dec.lua#L4259)、[4392](../action/script/c0000_transition.dec.lua#L4392)、[4553](../action/script/c0000_transition.dec.lua#L4553)、[4571](../action/script/c0000_transition.dec.lua#L4571)。
- 用途：玩家喝药时通知周围 AI"产生干扰事件"，让敌人可能转向追击或调整目标。

#### `act(156)` — 自动锁定瞄准（每帧驱动） (置信度：中)
- 唯一出现在 [c0000_transition.dec.lua:5538](../action/script/c0000_transition.dec.lua#L5538) 的 `_UpdateAutoAim()` 中：`g_autoAimTime` 未到上限且 `env(1118) == FALSE`（非锁定状态）时调用。
- 推断：在攻击/反应起手帧的一小段时间内（约 0.166s）每帧持续矫正朝向最近目标，弥补未锁定时的方向偏差。

#### `act(157)` — 关闭/重置自动瞄准 (置信度：高)
- [c0000_transition.dec.lua:5548](../action/script/c0000_transition.dec.lua#L5548) `_StopAutoAim()` 唯一调用，与 `act(156)` 配对。

#### `act(159, DAMAGE_ABSORPTION_DIGREE_*)` — 设置受伤吸收/僵直方向 (置信度：高)
- 第二参数取自 `c0000_define.dec.lua:522–525`：`DAMAGE_ABSORPTION_DIGREE_F = 0`、`B = 180`、`L = 90`、`R = -90`（即正前/正后/正左/正右的角度）。
- 出现在 `BEH_R_HIT_DAMAGE`/`BEH_R_GUARD_DAMAGE` 分支：[c0000_transition.dec.lua:1056](../action/script/c0000_transition.dec.lua#L1056)、[1155](../action/script/c0000_transition.dec.lua#L1155)、[1285–1287](../action/script/c0000_transition.dec.lua#L1285)、[1450–1452](../action/script/c0000_transition.dec.lua#L1450)、[1645–1647](../action/script/c0000_transition.dec.lua#L1645) 等。
- 局部辅助函数 `_setDamageAbsorption(damage_angle_FB)` 内部就是按前/后判断后调用此 `act(159, ...)`。
- 用途：决定本次受伤后位移方向（向前倒/向后倒）以及速度衰减朝向。

#### `act(160, THROWABLE_STATE_ATK_*)` 与 `act(161, THROWABLE_STATE_DEF_*)` — 注册可投技攻击/防御状态 (置信度：高)
- 第二参数取自 `c0000_define.dec.lua:500–521` 的 `THROWABLE_STATE_*` 枚举：
  - `ATK_*`：本帧玩家可以发起的投技种类（站立 `PC_STAND=1`、蹲伏 `PC_CROUCH=2`、空中 `PC_NORMAL_FALL=3`、抱墙左/右 `PC_COVER_LOOK_L/R=4/5`、攀爬 `PC_HANG=6`、忍杀终结 `PC_FINISH_NINSATSU=9`、龙咳 `PC_AGING=10/11`、游泳 `PC_SWIM=12`、潜水 `PC_DIVE=13`、不可用 `COMMON_IMPOSSIBLE=255`）。
  - `DEF_*`：本帧玩家可以被投的姿态（地面 `PC_GROUND=1`、空中 `PC_AIR=2`、游泳 `PC_SWIM=3`、潜水 `PC_DIVE=4`、不可用 `COMMON_IMPOSSIBLE=255`）。
- 全部集中在 [c0000.dec.lua](../action/script/c0000.dec.lua) 的 `_UpdateState_Style*` 分支（[450 起](../action/script/c0000.dec.lua#L452)），按当前 `currentStyle`（站立/蹲伏/防御/抱墙/攀爬/坠落/游泳/潜水/龙咳）成对设置 `(160, ATK_状态)` 与 `(161, DEF_状态)`。
- 用途：每帧告知引擎"接下来玩家能不能发起忍杀/能不能被敌人投"，是投技窗口校验的核心。

### 2000 系——特殊效果与特殊计时

#### `act(2002, SP_EFFECT_*)` — 触发指定 ID 的 SpEffect (置信度：高)
- 第二参数取 `c0000_define.dec.lua` 中 `SP_EFFECT_*`（**注意**：不是 `SP_EF_REF_*`，二者不同——`SP_EF_REF_*` 是行为参考的"种类索引"，喂给 `env(3036, ...)` 查询；`SP_EFFECT_*` 是真正的特效 ID 数值）。
- 已观察到的具体值：
  - `SP_EFFECT_DEACTIVATE_HP_AUTO_CHARGE = 109011`（[c0000.dec.lua:117](../action/script/c0000.dec.lua#L117) 等多处，受伤后关闭自动回血）
  - `SP_EFFECT_CROUCHING = 109012`（[c0000.dec.lua:460](../action/script/c0000.dec.lua#L460) 进入蹲伏姿态时打的标记）
  - `SP_EFFECT_STYLE_DEFLECT_GUARD = 109023`（[c0000.dec.lua:294, 315, 362, 488](../action/script/c0000.dec.lua#L294) 进入防御/弹反相关 STATE_TYPE_*_GUARD 时）
  - `SP_EFFECT_SP_STATE_TO_STATE_BLEND = 100241`（[c0000.dec.lua:785](../action/script/c0000.dec.lua#L785) 移动状态切换补间）
  - `SP_EFFECT_ENABLE_*_NINSATSU`（[c0000_transition.dec.lua:5082, 5093, 5095, 5100, 5118, 5120](../action/script/c0000_transition.dec.lua#L5082) 蹲伏/墙左/墙右/拉下忍杀）
  - `SP_EF_ITEM_USE_PRIORITIZE`（[c0000.dec.lua:424](../action/script/c0000.dec.lua#L424)）
- 用途：动态在玩家身上挂载/触发由 SpEffectParam 配置的状态效果（攻防加成、姿态标志、动画混合权重等）。

##### 范例详解：`SP_EFFECT_CROUCHING` 与 `SpEffectParam` 的三层关系 (置信度：高)

以 [c0000.dec.lua:460](../action/script/c0000.dec.lua#L460) `act(2002, SP_EFFECT_CROUCHING)` 为例，可以完整串起「Lua 常量名 → 数值 ID → Param 表行」三层映射，这也是所有 `act(2002, SP_EFFECT_*)` 调用的通用范式。

**三层映射链：**

| 层级 | 文件 | 内容 |
|---|---|---|
| ① Lua 符号 | [c0000_define.dec.lua:799](../action/script/c0000_define.dec.lua#L799) | `SP_EFFECT_CROUCHING = 109012` |
| ② 引擎动作 | [c0000.dec.lua:460](../action/script/c0000.dec.lua#L460) | `act(2002, SP_EFFECT_CROUCHING)`（`2002` 固定表示"触发 SpEffect"，第二参数就是 SpEffect ID） |
| ③ Param 数据 | [Param/SpEffectParam.csv](../Param/SpEffectParam.csv) 第 1508 行 | `ID=109012, Name=Crouching`，以及 400+ 字段承载的具体效果参数 |

**触发时机与上下文（来自 [c0000.dec.lua:458–485](../action/script/c0000.dec.lua#L458)）：**
- 在 `_UpdateState_StyleUpdate()` 分支 `currentStyle == STYLE_TYPE_CROUCH` 入口被**每帧**调用（注意是 Style 分发，不是一次性状态切换）；
- 同分支紧接着会做：`_LandReset` → `act(2002, SP_EFFECT_CROUCHING)` → 依 `WireMoveStartIndex` 预计算 `GROUND_WIRE_MOVE_START` → 根据 standby 状态开启 `ACTION_BUTTON_EXEC_TYPE_BASE/ITEM_PICK/EAVESDROP` → 根据 `g_forceCrouch` 决定 `THROWABLE_STATE_ATK_PC_STAND` 或 `COMMON_IMPOSSIBLE`；
- 也就是说：**只要玩家当前是"蹲伏姿态"，引擎每帧都会重新挂一次 109012 号特效**——这是把"玩家正在蹲"这一事实持续广播给引擎其他系统（AI 感知、敌人视线、交互判定等）的通道。

**`SpEffectParam.csv` 表头结构（约 411 列）：**

表头位于 [Param/SpEffectParam.csv:1](../Param/SpEffectParam.csv#L1)，第一行`ID=0, Name="passive effects?"`是**默认值行**（字段默认 `0` 或 `1`）。字段按用途可大致分为：
- 基础：`ID, Name, iconId, conditionHp, effectEndurance, motionInterval`
- 属性倍率：`maxHpRate, maxMpRate, maxStaminaRate`
- 防御减伤倍率：`slashDamageCutRate, lightHitDamageCutRate, thrustDamageCutRate, neutralDamageCutRate, magicDamageCutRate, fireDamageCutRate, thunderDamageCutRate, darkDamageCutRate, toughnessDamageCutRate`
- 攻击倍率/加成：`physicsAttackRate, physicsAttackPowerRate, ... darkAttackPowerRate`
- 属性抗性：`registPoizonChangeRate, registIllnessChangeRate, registBloodChangeRate, registCurseChangeRate, registFreezeChangeRate`
- 作用对象过滤：`effectTargetSelf/Friend/Enemy/Player/AI/Live/Ghost/...`
- AI 感知影响：`mapVisibilityOverrideDark, mapVisibilityOverridePitchDark, hearingSearchEnemyRate, sightSearchRate, aroundSightPointAddRate`
- 触发联动：`replaceSpEffectId, cycleOccurrenceSpEffectId, atkOccurrenceSpEffectId, counterSpEffectId`
- 姿态/投技：`stateInfo, overrideThrowTypeId, throwCondition`
- VFX：`vfxId, vfxId1..vfxId7, dmypolyId, addFootEffectSfxId`
- 忍杀/体力攻击：`atkNinsatsuDmgRate, atkHeavyHitDmgRate, defNinsatsuDmgRate, ...`

**109012（Crouching）的所有非默认字段（相对 `ID=0` 默认行）：**

分类列出（`default → 109012`）：

*标识类：*
- `ID: 0 → 109012`
- `Name: "passive effects?" → "Crouching"`

*生命条件：*
- `conditionHp: 0 → -1`（无 HP 触发条件）
- `conditionHpRate: 0 → -1`

*倍率基线（几乎所有 `*Rate` 字段被置 1，表示"无修正"——这是 Sekiro 里"纯姿态标记"类 SpEffect 的通用模式，把所有乘法因子显式写成 1 而不是 0，避免默认 0 被当成减免到 0%）：*
- HP/MP/耐力上限：`maxHpRate, maxMpRate, maxStaminaRate: 0 → 1`
- 物/魔/火/雷/暗 防御减伤：`slash/lightHit/thrust/neutral/magic/fire/thunder/dark DamageCutRate: 0 → 1`
- 对应攻击倍率：`slash/lightHit/thrust/neutral/magic/fire/thunder/dark AttackRate: 0 → 1`
- 对应攻击力加成：`physicsAttackPowerRate, magicAttackPowerRate, fireAttackPowerRate, thunderAttackPowerRate, darkAttackPowerRate: 0 → 1`
- 属性倍率另一组：`slash/lightHit/thrust/neutral AttackPowerRate: 0 → 1`
- 属性抗性倍率：`fire/thunder/physics/magic DiffenceRate: 0 → 1`
- 属性伤害率：`fallDamageRate, soulRate, equipWeightChangeRate, allItemWeightChangeRate, haveSoulRate: 0 → 1`
- 刀耐/体力攻击：`staminaAttackRate, guardDefFlickPowerRate, guardStaminaCutRate, toughnessDamageCutRate, saReceiveDamageRate: 0 → 1`
- 忍杀/特殊体系：`atk/def Ninsatsu/HeavyHit/AntiGround/AntiAir/LightShoot DmgRate: 0 → 1`，`ninsatsuAttackPowerRate, heavyHitAttackPowerRate, antiGroundAttackPowerRate, antiAirAttackPowerRate, lightShootAttackPowerRate: 0 → 1`
- 体力攻击细分：`def Slash/LightHit/Thrust/Neutral/Ninsatu/HeavyHit/AntiGround/AntiAir/LightShoot StaminaDmgRate: 0 → 1`
- 属性 A/B/C：`defAttriA/B/C StaminaDmgRate, attriA/B/C AttackRate, attriA/B/C AttackPowerRate, attriA/B/C DamageCutRate: 0 → 1`
- 玩家/敌人 物/魔/火/雷/暗 伤害修正：`defPlayerDmgCorrectRate_*, defEnemyDmgCorrectRate_*, atkPlayerDmgCorrectRate_*, atkEnemyDmgCorrectRate_*, defObjDmgCorrectRate, defObjectAttackPowerRate: 0 → 1`
- 抗性变化率：`registPoizon/Illness/Blood/Curse/Freeze ChangeRate, soulStealRate, lifeReductionRate, hpRecoverRate: 0 → 1`
- 道具/技能消耗：`artsConsumptionRate, magicConsumptionRate, shamanConsumptionRate, miracleConsumptionRate: 0 → 1`
- 葫芦修正：`changeHpEstusFlaskCorrectRate, changeMpEstusFlaskCorrectRate, extendLifeRate, contractLifeRate: 0 → 1`
- 其他：`haveSkillPointRate, attackHitParryStaminaAttackRate, defStaminaAttackRate: 0 → 1`
- 近战攻击倍率重复组：`slash/lightHit/thrust/neutral AttackRate: 0 → 1`
- 感知：`sightSearchRate, hearingSearchRate, aroundSightPointAddRate, hearingSearchEnemyRate: 0 → 1`
- 作用目标开关（**非常重要**）：`effectTargetSelf/Friend/Enemy/Player/AI/Live/Ghost: 0 → 1`，`effectTargetOpposeTarget/FriendlyTarget/SelfTarget: 0 → 1`——意味着"这个效果对所有目标都生效"，与部分阵营限定 SpEffect 形成对比
- 所有 `vowType0..vowType15: 0 → 1`——对任何"誓约/阵营"都生效

*真正非平凡的字段（这几项才是"Crouching 与 Default 语义不同"的核心标志）：*
- `animIdOffset: 0 → -1`（无动画 ID 偏移）
- `mapVisibilityOverrideDark: 0 → 1`、`mapVisibilityOverridePitchDark: 0 → 2` —— **蹲伏使玩家在暗/极暗环境下的可见度发生指定等级的覆盖**。这是 Sekiro 潜行系统的关键：蹲姿在暗区里降低敌人对玩家的视觉感知
- `bloodDamageRate: 0 → 100`、`freezeDamageRate: 0 → 100` —— 受血/冻伤害倍率（100 可能是"100%正常伤害"的含义，而非默认 0 的"禁用"）
- `stateInfo: 0 → 281` —— **状态分类/标签位**，供引擎其他系统按位判断"当前是否为 crouching 类型 SpEffect"。281 的确切位含义需进一步对照 SpEffectParam 位表确定
- 各类引用 ID 置 -1（意为"无关联"）：`replaceSpEffectId, cycleOccurrenceSpEffectId, atkOccurrenceSpEffectId, addBehaviorJudgeId_condition, vfxId, vfxId1..7, accumuOverFireId, accumuOverVal, accumuUnderFireId, accumuUnderVal, addFootEffectSfxId, antiDarkSightDmypolyId, overrideThrowTypeId, effectEndDeleteDecalGroupId, teamOffenseEffectivity, chrWireVariationNo, chrWireTargetDmypolyId, chrWireLandingPointDmypolyId: 0 → -1`

**结论 / 可复用的解读框架：**

1. `act` 的**第一个参数是引擎动作 ID**——`2002` 专职"挂载/触发一个 SpEffect"。第二个参数则是 **SpEffect 的数值 ID**（也就是 `SpEffectParam.csv` 的主键 `ID` 列），在 Lua 里以 `SP_EFFECT_*` 常量形式出现（定义在 `c0000_define.dec.lua` 的 760–800 段）。
2. 注意与 `env(3036, SP_EF_REF_*)` 的区别：`SP_EF_REF_*`（数值通常是 0–500 的小编号，如 `SP_EF_REF_FORCE_CROUCH = 110000`、`SP_EF_REF_TAE_ENABLE_ADD_ACTION_INPUT_CROUCH = 407`）是**查询标志位的索引**，不是 `SpEffectParam` 的主键；而 `SP_EFFECT_*`（10xxxx 段）才是 `SpEffectParam` 主键。两套常量在命名上只差一个词，但在 Param 表里不能互换。
3. 单单"`act(2002, 109012)`"这一行，就是脚本→引擎→Param 三层联动的最小样本：**脚本**告诉引擎该挂哪个 SpEffect；**引擎**按 ID 去 `SpEffectParam` 取这一行配置；该行的**各字段**再把具体的减伤/感知/动画 offset/VFX/忍杀倍率等派发给对应子系统。分析其他 `act(2002, SP_EFFECT_*)` 调用时可以套用完全一样的三层链路。

#### `act(2015, n, m)` — 临时性僵直/无敌帧/可读输入窗口 (置信度：低)
- [c0000.dec.lua:121](../action/script/c0000.dec.lua#L121) `act(2015, 0, 0)` 每帧 `Update()` 末尾调用——清零；
- [c0000.dec.lua:254, 257](../action/script/c0000.dec.lua#L254) `act(2015, 60, 60)`：当处于 `STAND_IDLE`、`CROUCH_IDLE`、`DEFLECT_GUARD_IDLE` 等可移动待机状态时设置为 60。
- 推断：双参数可能是"持续帧数 + 衰减帧数"或"上半身 + 下半身权重"，60 接近 1 秒（60 fps）。

#### `act(2018)` — 强制对齐根运动/中断当前位移 (置信度：低)
- [c0000.dec.lua:260](../action/script/c0000.dec.lua#L260)（地面跳跃 ready）、[c0000.dec.lua:375, 391, 418](../action/script/c0000.dec.lua#L375)（事件状态）、[c0000.dec.lua:580, 598, 627, 662, 671, 684](../action/script/c0000.dec.lua#L580)（多个 `_StyleUpdate` 末尾）、[c0000_transition.dec.lua:2921, 2954](../action/script/c0000_transition.dec.lua#L2921)（跳跃前摇）。
- 推断：把 root motion 的累积位移落地，便于切换到下一段动画。

#### `act(2019)` — 跳跃方向/根运动重计算 (置信度：低)
- [c0000_transition.dec.lua:482](../action/script/c0000_transition.dec.lua#L482)（墙跳定位跳）、[c0000_transition.dec.lua:2954](../action/script/c0000_transition.dec.lua#L2954)（普通跳跃，锁定时调用）、[c0000_transition.dec.lua:5516](../action/script/c0000_transition.dec.lua#L5516)（4 方向 step，锁定时调用）。
- 调用条件：均为 `env(1118) == TRUE`（已锁定目标），`act(2019)` 后立刻读取 `KickAngle`/`KickStickLevel` 等变量。
- 推断：当锁定目标时，让引擎重新解算面向目标的跳跃/闪避方向偏移。

#### `act(2024)` — 道具消耗/确认（用药"消耗一格"）(置信度：低)
- [c0000_transition.dec.lua:4098, 4136, 4621, 4625](../action/script/c0000_transition.dec.lua#L4098)：均在 `BEH_A_USE_ITEM`/`BEH_A_AGING_USE_ITEM` 的入口附近调用。
- 推断：通知引擎扣除道具计数/进入动画消耗确认。

### 3000 系——动作系统、UI 引导、跳跃/闪避方向

#### `act(3004, SP_EFFECT_SOUND_SHOT_TARGET)` — 锁定目标音效触发 (置信度：低)
- 唯一调用 [c0000.dec.lua:798](../action/script/c0000.dec.lua#L798)：`if env(3036, SP_EF_REF_TAE_LOCK_TARGET_GEN_SP_SOUND_SHOT) == TRUE then act(3004, SP_EFFECT_SOUND_SHOT_TARGET) end`，配合 `SP_EFFECT_SOUND_SHOT_TARGET = 107918`。
- 推断：在带有 TAE 标志的攻击动画指定帧上，对锁定目标点位生成定位音效。

#### `act(3011)` — 进入潜水姿态准备 (置信度：低)
- 唯一 [c0000.dec.lua:652](../action/script/c0000.dec.lua#L652)：在 `_StyleUpdate_Dive` 等分支顶部调用。

#### `act(3016, 0)` 与 `act(3016, 1)` — 注册"摔落保护墙"类型 (置信度：高)
- [c0000_transition.dec.lua:5579](../action/script/c0000_transition.dec.lua#L5579)：`_UpdateFallProtection()` 内部，根据 `g_paramHkbState[...][PARAM_HKB_STATE__ENABLE_FALL_PROTECT_WALL_STRONG]` 调用 `act(3016, 0)`；
- [c0000_transition.dec.lua:5582](../action/script/c0000_transition.dec.lua#L5582)：根据 `..._WALL_WEAK` 调用 `act(3016, 1)`。
- 第二参数：`0=墙强保护`、`1=墙弱保护`，决定坠落时贴墙抓取的吸附判定档位。

#### `act(3018, 0|1)` — 启用/关闭钩索 IK (置信度：中)
- 设为 `1`：[c0000.dec.lua:793](../action/script/c0000.dec.lua#L793)，当当前 `HKB_STATE` 是各类 `WIRE_SHOOT/WIRE_MOVE_READY` 时；
- 设为 `0`：[c0000_transition.dec.lua:3316, 3358, 3380, 3641, 4641](../action/script/c0000_transition.dec.lua#L3316) 在退出钩索状态时。

#### `act(3019, 0|1)` — 锁定时跳跃前摇方向标志 (置信度：中)
- 设为 `1`：[c0000.dec.lua:782](../action/script/c0000.dec.lua#L782)，处于 `GROUND_JUMP_READY/START`、`SPRINT_SPECIAL_ATTACK_JUMP_READY` 等状态且 `Selector_GroundJumpType == FORWARD_LOCKON` 时。
- 设为 `0`：[c0000_transition.dec.lua:2282, 3612, 3619, 3644, 3651, 5221](../action/script/c0000_transition.dec.lua#L2282) 在锁定踢墙跳/各种跳跃完成后清除。

#### `act(3023, MOVE_DISTANCE_PRE_CALCULATE_TYPE_*, MOVE_DISTANCE_PRE_CALCULATE_ANIM_ID_*)` — 注册"位移预计算"动画 (置信度：高)
- 两个参数都来自 `c0000_define.dec.lua:526–547`：
  - `_TYPE_*`（0–11）：动作类别（游泳→潜水、潜水→游泳、地面钩索移动起始、空中钩索射出、空中受身钩索、钩索连续射出、游泳钩索、攀爬→站立等）。
  - `_ANIM_ID_*`：对应类别下的具体动画 ID（如 `SWIM_TO_DIVE = 210100`、`AIR_WIRE_SHOOT = 202100`、`HANG_TO_STAND = 217500`）。
- 全部出现在 [c0000.dec.lua](../action/script/c0000.dec.lua) 的 `_StyleUpdate_*` 中，按当前姿态把"接下来可能要播的位移动画"提前注册给引擎，让引擎能在动画激活前就把目标位移距离算好（用于钩索精确落点等）。

#### `act(3025, angle)` — 注册跳跃/闪避目标角度 (置信度：高)
- 第二参数是浮点角度，常见形式为 `angle - PRM_*_ANGLE_CENTER_*`（来自 `c0000_define.dec.lua:232–273` 的 `PRM_GROUND_JUMP_ANGLE_CENTER_*`、`PRM_4DIR_JUMP_ANGLE_CENTER_*`、`PRM_4DIR_STEP_ANGLE_CENTER_*`、`PRM_GROUND_STEP_ANGLE_CENTER_*` 等）。
- 全部集中在 [c0000_transition.dec.lua:5354–5503](../action/script/c0000_transition.dec.lua#L5354) 的局部跳跃/Step 函数（`_setGroundJumpDir`、`_set4DirJumpDir`、`_set4DirStepDir`、`_setGroundStepDir`），以及 [c0000_transition.dec.lua:540, 565, 3007](../action/script/c0000_transition.dec.lua#L540) 的弹跳/触墙跳。
- 用途：把摇杆方向相对于身体朝向的偏移角度送给 Havok，决定 8 方向跳跃/闪避动画的混合权重。

#### `act(3026)` — 进入抱墙起手 (置信度：低)
- [c0000.dec.lua:736](../action/script/c0000.dec.lua#L736)：`BEH_A_COVER_START` 分支顶部。

#### `act(3027)` — 进入地面攀爬起手 (置信度：低)
- [c0000.dec.lua:747](../action/script/c0000.dec.lua#L747)：`BEH_A_GROUND_HANG_START` 分支顶部。

#### `act(3028)` — 进入空中攀爬起手 (置信度：低)
- [c0000.dec.lua:762](../action/script/c0000.dec.lua#L762)：`BEH_A_AIR_HANG_START` 分支顶部。

#### `act(3029, EZ_STATE_REF_*)` — 触发 ESD（EzState）状态机 (置信度：中)
- 第二参数取 `c0000_define.dec.lua:483–491` 的 `EZ_STATE_REF_SND_*`（NPC 谈话各阶段：`LOOP=1`、`END=2`、`711333=4`、`EAVESDROP_LOOP=10`、`EAVESDROP_END=11`、`ENGRAVER=20`、`ENGRAVER_DUMMY=25`、`INTERRUPT=90`、`711300=720000`），或 [c1010.dec.lua](../action/script/c1010.dec.lua) 的 `TALK_REF_C1010_*`。
- 用途：通知 ESD 触发对应的 NPC 谈话/偷听音频段。

#### `act(3030, ACTION_GUIDE_*, ACTION_ARM_*)` — 显示动作引导 UI 提示 (置信度：高)
- 两个参数都在 `c0000_define.dec.lua` 中定义：
  - `ACTION_GUIDE_*`（行 548–557）：抱墙开始/结束、攀爬开始/结束、攀爬→站立、攀爬→坠落、潜水切换……
  - `ACTION_ARM_*`（行 4–21）：用哪个手柄按键提示（`WALL_HANG=12`、`SP_MOVE=5`、`JUMP=4`……）。
- 例：[c0000.dec.lua:738](../action/script/c0000.dec.lua#L738) `act(3030, ACTION_GUIDE_COVER_START, ACTION_ARM_WALL_HANG)`。
- 用途：左下角"按 Y 攀爬"等浮动提示的注册。

#### `act(3032)` — 强制清除高级动作请求/解锁 (置信度：低)
- [c0000.dec.lua:349, 370, 386, 399, 595, 608](../action/script/c0000.dec.lua#L349)：在 `STATE_TYPE_REACTION_DEATH*`、`STATE_TYPE_EVENT*`、`_StyleUpdate_FreeFall/WireFall` 中调用。
- 推断：清空跳跃/钩索/掩体等待启动的请求队列。

#### `act(3034, ACTION_BUTTON_EXEC_TYPE_*)` — 注册具体的动作按钮可用类型 (置信度：高)
- 第二参数取 `c0000_define.dec.lua:558–562`：`BASE=0`、`ITEM_PICK=1`、`EAVESDROP=2`、`TALK_SKIP=3`、`DIVE_BASE=4`。
- 与 `act(138)` 配套：`138` 启用提示、`3034` 告诉引擎当前可用的具体类型。

#### `act(3035)` — 钩索/受身相关清理 (置信度：低)
- [c0000.dec.lua:596, 609](../action/script/c0000.dec.lua#L596)：`_StyleUpdate_FreeFall`、`_StyleUpdate_WireFall` 中调用。

#### `act(3036)` — 关闭摔落保护 (置信度：低)
- 唯一 [c0000_transition.dec.lua:5584](../action/script/c0000_transition.dec.lua#L5584)：`_UpdateFallProtection()` 中当不满足 `WALL_WEAK` 条件时的 else 分支。
- 推断：清掉墙保护标志，允许正常坠落。

#### `act(3037)` — 进入游泳姿态前置 (置信度：低)
- 唯一 [c0000.dec.lua:625](../action/script/c0000.dec.lua#L625)：`_StyleUpdate_Swim` 顶部，紧邻 `act(3032)`（如果在 free fall）。

### 9000 系——调试/Havok 联动

#### `act(9000, str)` — 打印调试字符串（`PrintString` 的实现） (置信度：高)
- 唯一 [c0000_define.dec.lua:859–861](../action/script/c0000_define.dec.lua#L859)：
  ```lua
  function PrintString(str)
      act(9000, str)
  end
  ```

#### `act(9100)` — 通知"动作已开始"（State Type 切换上行）(置信度：中)
- 主要在 [c0000.dec.lua](../action/script/c0000.dec.lua) 的 `_UpdateState_*` 中：进入 `STATE_TYPE_STANDBY/UPPER_STANDBY/STANDBY_GUARD/STANDBY_ATK/...` 时调用。
- [c0000_cmsg.dec.lua:5307, 9128](../action/script/c0000_cmsg.dec.lua#L5307) 也有零散调用。
- 推断：可能是给引擎的"心跳/广播"，让 SoundEvent 之类的子系统得知玩家此刻进入了某个稳定状态。

#### `act(9101)` — 通知"状态机已重置"或"状态进入"(置信度：中)
- [c0000.dec.lua:130](../action/script/c0000.dec.lua#L130) `ResetRequest()` 唯一封装调用：
  ```lua
  function ResetRequest()
      act(9101)
  end
  ```
- 同时手动出现在大量 `*_onActivate()` 入口（[c0000_cmsg.dec.lua](../action/script/c0000_cmsg.dec.lua) 中数百处投技反应函数都以 `act(9101)` 起手）、[c0000_transition.dec.lua:3403](../action/script/c0000_transition.dec.lua#L3403)（攻击发起）。
- 推断：通知引擎"清空当前帧的动作请求/事件队列"，避免堆叠多个互斥指令。

#### `act(9102)` — 进入剧情/事件类状态的标记 (置信度：低)
- [c0000.dec.lua:368, 379, 395](../action/script/c0000.dec.lua#L368)：`STATE_TYPE_EVENT*` 内部，`if env(339, 1) == FALSE then act(9102) end`。
- 推断：禁用某些常规更新（输入/AI 干扰）以确保事件/剧情段干净播放。

#### `act(9103, n)` — 通知 NPC 武器特殊攻击动画 ID (置信度：高)
- [c0000.dec.lua:307–309, 328–330](../action/script/c0000.dec.lua#L307)：在 `STATE_TYPE_ACTION_ATK*`/`STATE_TYPE_REACTION_ATK` 中：
  ```lua
  if _IsNpcWeapon() ~= TRUE then
      act(9103, 1)
  else
      act(9103, hkbGetVariable("NTCAnimId_NpcSpAttack"))
  end
  ```
- 用途：把"用什么动画跑特殊攻击"告诉引擎——常规武器固定为 1，捡起的 NPC 武器（剑圣相关）则按变量动态决定。

## 常见参数规律

1. **第一个参数永远是整数 ID**，分布稀疏（100、123、127、135–141、147–161、2002–2024、3004–3037、9000–9103），强烈提示引擎内部用一个 switch/jump 表分发。
2. **第二个参数的语义完全由第一个参数决定**：
   - `BEH_R_*` 系列：跟 `DAMAGE_FLAG_*`、`DAMAGE_ABSORPTION_DIGREE_*`、`HAND_*`、`THROWABLE_STATE_*`。
   - 移动/跳跃：跟 `PRM_*_ANGLE_CENTER_*` 或预计算 `MOVE_DISTANCE_PRE_CALCULATE_*`。
   - 特殊效果：跟 `SP_EFFECT_*`（最终特效 ID 数值），与 `env(3036, SP_EF_REF_*)` 是不同维度。
   - UI 引导：跟 `ACTION_GUIDE_*` + `ACTION_ARM_*`（双参数）。
   - 调试/底层：要么无参（如 `127`、`157`），要么是字符串/Havok 变量名（如 `148`、`9000`）。
3. **频次分布**：受伤/防御反应（`127`、`141`、`154`、`159`）和攻防/状态心跳（`9100`、`9101`、`101`、`160`、`161`）占据了 600+ 调用中的大多数，反映"玩家脚本的工作 ≈ 每帧告诉引擎当前玩家可以被怎么打、可以怎么打人、要播什么受伤"。

## 不确定 / 待确认条目

下列 ID 的功能仅有单一现场，强烈依赖更多反编译/日志才能确认：`123`、`135`、`136`、`139`、`150`、`156`、`2015`、`2018`、`2019`、`2024`、`3011`、`3026`、`3027`、`3028`、`3032`、`3035`、`3036`、`3037`、`9100`、`9102`。

如果后续在 [chr/c0000-behbnd-dcx/c0000.hkx.xml](../chr/c0000-behbnd-dcx/c0000.hkx.xml) 找到对应的 hkbCustomEvent 节点，或在内存抓取得到引擎符号表，可以把上述条目从"低/中"提升到"高"置信度。

## 参考文件

- [doc/Lua env.md](Lua%20env.md) — 配套的查询函数参考
- [action/script/c0000_define.dec.lua](../action/script/c0000_define.dec.lua) — 所有出现的常量来源
- [action/eventnameid.txt](../action/eventnameid.txt)、[action/statenameid.txt](../action/statenameid.txt)、[action/variablenameid.txt](../action/variablenameid.txt) — ID 名称映射
