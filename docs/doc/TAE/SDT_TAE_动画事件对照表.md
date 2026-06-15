# SDT TAE 动画事件中文对照表

> 数据来源：[chr/TAE.Template.SDT.xml](../../chr/TAE.Template.SDT.xml)（SoulsModders / SoulsTemplate 社区逆向产出的 SDT 版 TAE 模板）。
> 交叉参考：[doc/env.md](../env.md)（SP_EF_REF / SpEffect 查询体系）、[doc/Havok_Behavior_状态机文档.md](../Havok_Behavior_状态机文档.md)、[action/script/c0000_*.dec.lua](../../action/script/)。
>
> **TAE（TimeAct）** 是 FromSoftware 游戏在每条动画时间轴上挂载的"事件轨道"。每个事件由一个 **action id**（事件类型 / 此表第一列）和一段事件 / 参数构成；当动画播放到事件区间时，引擎根据 id 分派到对应的 hks/native 处理函数。Lua 脚本不直接产生 TAE 事件，但会通过 `env(3036, SP_EF_REF_*)`、`hkbIsNodeActive()`、`act(...)` 等 API 反向**查询**或**响应** TAE 触发的状态/SpEffect/标志。

## 阅读约定

- **类型缩写**（出现在"主要参数"列）：
  - `s8/s16/s32/s64` = 有符号整数（1/2/4/8 字节）
  - `u8/u16/u32` = 无符号整数
  - `f32` = 单精度浮点 ；`f32grad` = 浮点渐变（按事件时长插值）
  - `b` = 布尔（1 字节）；`aob` = 任意字节数组
- **参数省略规则**：仅列出在模板中具有 `name=...` 的命名字段。未命名（`<s32 />`）或断言 0（`assert="0"`）的占位字段视为保留 / 内部 padding，不在此表展开。
- **置信度图例**：
  - 🟢 已确认：模板提供清晰命名 + 枚举，语义在脚本/已有 doc 中得到佐证。
  - 🟡 推断：仅靠模板命名推断语义，未在脚本中找到直接证据。
  - 🔴 未知：模板里命名形如 `EventNNN` / 占位字段过多，仅作记录。
- **中文译名**遵循 [CLAUDE.md](../../CLAUDE.md) 的"保留原始标识符 + 个人解读分开"约定：原英文 name 视为权威标识，中文为解读，必要处用"?"标记不确定。

## 总览（按功能分组）

| 分组 | 主要功能 | ID 区间（实际出现） |
| --- | --- | --- |
| [§1 行为标志 ChrActionFlag](#1-行为标志-chractionflag) | 动画取消窗口、攻击判定、Death/状态切换、各类布尔标志位 | 0 |
| [§2 行为 / 攻击 Behavior 触发](#2-行为--攻击-behavior-触发) | 攻击命中、弹幕、抛投行为 | 1、2、4、5、9、17、24、304、307 |
| [§3 武器 / 道具 切换](#3-武器--道具-切换) | 武器架构（单/双手）、弩矢装卸、道具消耗、魔法施放 | 32、33、34、35、64、65 |
| [§4 SpEffect 施加](#4-speffect-施加) | 角色身上叠加 SpEffect（含联机/苇名/龙形/咒文流程） | 66、67、302、331、401、797、940 |
| [§5 FFX 视觉特效](#5-ffx-视觉特效) | 一次性 / 重复 / 武器附着 / 抛投 / SpEffect 驱动的 FFX | 95、96、99–101、108–123、961 |
| [§6 音效 / 印迹 / 震动](#6-音效--印迹--震动) | PlaySound 系列、DecalParam、Rumble Cam | 128–132、137–139、144–147、970、10130 |
| [§7 相机控制](#7-相机控制) | 锁定相机参数、看向 / 附着节点、角度覆写 | 150–156、238、520–522 |
| [§8 透明度 / 淡入淡出](#8-透明度--淡入淡出--调试) | 模糊反馈、Opacity 关键帧、debug print | 192、193、195–197 |
| [§9 角色参数控制](#9-角色参数控制) | 转身速度、SP/MP 恢复、击退、躯干瞄准、模型遮罩 | 224–237、305、340、510、603、760、800 |
| [§10 跳转表 / 动作请求](#10-跳转表--动作请求) | Hks 跳表早激活、ActionRequest、PCBehavior | 300、301、306、308、310–314、320、330、332 |
| [§11 流程 / 状态](#11-流程--状态) | EzState 标志、FullBodyWet、Locked-On 模块、Cult/咒文流程 | 227、231、500、510、520–522、720、793–799、796 |
| [§12 行为图 / 附加动画](#12-行为图--附加动画) | EnableBehavior、Additive Anim、Stay Anim、Test Param、HkbVariable | 600–607、234、235 |
| [§13 旋转 / 瞄准 / Twist](#13-旋转--瞄准--twist) | CustomLookAtTwist、FixedRotation、ChrTurnSpeed、手动瞄准 | 700、703–707 |
| [§14 苇名新增系列 700+](#14-苇名新增系列-700) | 苇名特有：708、709、720、730、731、750 | 708、709、720、730、731、750 |
| [§15 武器外观 / 隐藏 / 收鞘](#15-武器外观--隐藏--收鞘) | HideEquippedWeapon、ModelMask、收鞘标志、武器拖尾、模型位置 | 710–717、790、791 |
| [§16 骨骼修改](#16-骨骼修改) | ChangeBonePos / FixBone / AddHeight / TurnLowerBody | 770–772、780、781 |
| [§17 AI / NPC 行为](#17-ai--npc-行为) | AI 重规划重置、寻敌子弹、AI 音 | 229、237、782、785 |
| [§18 钩绳系统 Wire](#18-钩绳系统-wire) | 钩绳同步、滑行、看向、抑制坠落 | 900–905、717 |
| [§19 物理速度 / 引擎标志](#19-物理速度--引擎标志) | ChrPhysicsVelocity、各类 NewEngineFlag | 910–913、920–922、946、750 |
| [§20 杂项事件 930+](#20-杂项事件-930) | Throw 过场 SE/Decal、Event942–947 | 930–947 |
| [§21 无敌帧 IFrames](#21-无敌帧-iframes) | MistRaven / DuringAction / Throw / 通用 IFrames | 950–954 |
| [§22 体力 / 食物](#22-体力--其他) | StaminaControlParam、961_FFX、DS3Poise | 795、960、961 |
| [§23 调试 / Decal Wander](#23-调试--debug) | DebugDecal、Debug 移动倍率、DebugAnimSpeed、TestParam | 800、603、604、970、10137、10138 |

---

# §1 行为标志 ChrActionFlag

**ID 0（`ChrActionFlag`）** —— 单事件类型，但用 `FlagType` 子枚举区分了 90+ 种用途，几乎覆盖了"攻击判定"、"动画取消窗口"、"队列检查"、"死亡 / 倒地"、"Cult 仪式"、"投掷"、"未知布尔" 等所有"动作期间的逻辑节点"。

**通用参数：**

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `FlagType` | `s32` | 枚举，见下表 |
| `ArgA` | `f32` | 视 `FlagType` 而定 |
| `ArgB` | `s32` | 视 `FlagType` 而定（如 ShieldBlock(ArgB)） |
| `ArgC` | `u8` | 视 `FlagType` 而定（如 ParriedState(ArgC)） |
| `ArgD` | `u8` | 视 `FlagType` 而定 |
| `StateInfo` | `s16` | 状态附加信息 |

## 1.1 ChrActionFlag.FlagType 子标志对照表

> 名称分类小结：以 `AnimCancelStart_*` / `AnimCancelEnd_*` 开头的是**动画取消窗口的开闭**；以 `End If ... Queued` 开头的是**在输入排队命中时立即结束当前动画**；`Set_0x78_*` / `SetBool32_0x7C_*` / `SetStartbit*` 等是引擎内部偏移地址的位标志，多数语义未在公开资料中确认。

### 动画取消窗口（Anim Cancel）

| 值 | FlagType（英文） | 中文译名 | 置信度 |
| --- | --- | --- | --- |
| 1 | AnimCancelStart_R1_R2_LightKick_HeavyKick | 开启取消窗口：R1/R2/轻踢/重踢 | 🟢 |
| 9 | AnimCancelStart_L1_L2 | 开启取消窗口：L1/L2 | 🟢 |
| 10 | AnimCancelStart_MagicR_MagicL | 开启取消窗口：左/右魔法 | 🟢 |
| 21 | AnimCancelStart_Guard | 开启取消窗口：格挡 | 🟢 |
| 25 | AnimCancelStart_SpMove_Backstep_Rolling_Jump | 开启取消窗口：特殊位移 / 后撤步 / 翻滚 / 跳跃 | 🟢 |
| 30 | AnimCancelStart_UseItem | 开启取消窗口：使用道具 | 🟢 |
| 105 | AnimCancelStart_L2 | 开启取消窗口：L2 | 🟢 |
| 108 | AnimCancelStart_UseItem_ByGoodsParam | 开启取消窗口：使用道具（按 GoodsParam） | 🟢 |
| 111 | AnimCancelStart_EmergencyStep | 开启取消窗口：紧急步（受身 / 闪避） | 🟢 |
| 119 | TryToInvokeForceParryMode | ★ 强制进入弹反模式 | 🟢 |
| 120 | AnimCancelStart_L1_L2_ByWeaponParam | 开启取消窗口：L1/L2（按武器参数） | 🟢 |
| 6 | AnimCancelEndWithKeyboardKey | 结束取消窗口（绑定键盘按键） | 🟡 |
| 31 | AnimCancelEnd_UseItem | 结束取消窗口：使用道具 | 🟢 |
| 34 | AnimCancelEnd_General | 结束取消窗口：通用 | 🟢 |
| 103 | AnimCancelEnd_L2 | 结束取消窗口：L2 | 🟢 |
| 104 | AnimCancelEnd_L2_WeaponCancelType_HksSet2011 | 结束取消窗口：L2（特定武器取消类型 hks#2011） | 🟡 |
| 107 | AnimCancelEnd_UseItem_ByGoodsParam | 结束取消窗口：使用道具（按 GoodsParam） | 🟢 |
| 112 | AnimCancelEnd_EmergencyStep | 结束取消窗口：紧急步 | 🟢 |
| 115 | AnimCancelEnd_R1_LightKick | 结束取消窗口：R1 / 轻踢 | 🟢 |
| 116 | AnimCancelEnd_R2_HeavyKick | 结束取消窗口：R2 / 重踢 | 🟢 |
| 117 | AnimCancelEnd_L1 | 结束取消窗口：L1 | 🟢 |
| 118 | AnimCancelEnd_L2 | 结束取消窗口：L2 | 🟢 |
| 121 | AnimCancelEndExtra_L1_l2_ByWeaponParam | 额外结束取消窗口：L1/L2（按武器参数） | 🟢 |
| 137 | AnimCancelEnd_R2_Prosthetic | 结束取消窗口：R2 / 义肢 | 🟢 |
| 154 | AnimCancelEnd_Deathblow | 结束取消窗口：忍杀 | 🟢 |

### 输入队列命中即取消（End If ... Queued）

| 值 | FlagType（英文） | 中文译名 | 置信度 |
| --- | --- | --- | --- |
| 4 | End If RH Attack Queued | 若已排队右手攻击则立即结束 | 🟢 |
| 11 | End If LS Move Queued | 若已排队左摇杆移动则立即结束 | 🟢 |
| 16 | End If LH Attack Queued | 若已排队左手攻击则立即结束 | 🟢 |
| 22 | End If Guard Queued | 若已排队格挡则立即结束 | 🟢 |
| 23 | End If AI ComboAttack Queued | 若已排队 AI 连击则立即结束 | 🟢 |
| 26 | End If Dodge Queued | 若已排队闪避则立即结束 | 🟢 |
| 32 | End If Weapon Switch Queued | 若已排队武器切换则立即结束 | 🟢 |
| 78 | End If AI Move Queued | 若已排队 AI 移动则立即结束 | 🟢 |
| 79 | End If AI Step Queued | 若已排队 AI 步伐则立即结束 | 🟢 |
| 86 | End If AI Attack Queued | 若已排队 AI 攻击则立即结束 | 🟢 |
| 141 | Underwater_End If Dodge Queued | 水下：若已排队闪避则立即结束 | 🟢 |

### 状态 / 防御 / 反击

| 值 | FlagType（英文） | 中文译名 | 置信度 |
| --- | --- | --- | --- |
| 3 | ShieldBlock(ArgB) | 盾牌格挡（ArgB 指定盾参数） | 🟡 |
| 5 | ParriedState(ArgC) | 进入被弹反状态（ArgC 指定子类型） | 🟢 |
| 7 | Disable Turning | 禁止转身 | 🟢 |
| 8 | Flag As Dodging | 标记为闪避中 | 🟢 |
| 12 | Death | 死亡 | 🟢 |
| 27 | SetNoGravity | 取消重力 | 🟢 |
| 28 | IsLadder | 处于梯子上 | 🟢 |
| 89 | Disable All Movement | 完全禁止移动 | 🟢 |
| 90 | Limit Move Speed To Walk | 移动速度上限设为走 | 🟢 |
| 91 | Limit Move Speed To Dash | 移动速度上限设为冲刺 | 🟢 |
| 110 | DisableDirectionChange | 禁止改变方向 | 🟢 |
| 125 | MikiriCounter | 看破突刺（御身反击） | 🟢 |

### 投掷 / 抓取

| 值 | FlagType（英文） | 中文译名 | 置信度 |
| --- | --- | --- | --- |
| 67 | ThrowStart2 | 投掷开始 2 | 🟡 |
| 68 | HitSwing_ThrowStart1 | 命中挥砍 / 投掷开始 1 | 🟡 |
| 69 | ThrowType5 | 投掷类型 5 | 🟡 |
| 70 | ThrowType4 | 投掷类型 4 | 🟡 |
| 72 | KnockbackValue | 击退值 | 🟡 |

### 攻击判定

| 值 | FlagType（英文） | 中文译名 | 置信度 |
| --- | --- | --- | --- |
| 87 | InvokeAttackAction_Complex | ★ 触发攻击判定（复杂） | 🟢 |

> **说明**：87 是战斗动画中最核心的事件之一，决定武器 hitbox 在哪个时间段内能命中敌人。与 §2 的 `AttackBehavior` (type=1) 配合使用：87 开启伤害判定窗口，type=1 事件在命中瞬间触发具体的攻击行为（hit reaction / 弹刀 / 硬直）。详见 [doc/dev/comb/comb1_with_tae.md](../../dev/comb/comb1_with_tae.md) §3。

### 拾取 / 道具 / 输入

| 值 | FlagType（英文） | 中文译名 | 置信度 |
| --- | --- | --- | --- |
| 54 | Talk_DisableInput | 对话中：禁用输入 | 🟢 |
| 75 | SetBool32_0x7C_13_ItemPickUp_RememberInput | 拾取物品时记住输入 | 🟡 |
| 80 | SetBool32_0x7C_14_ItemPickUp_Default | 拾取物品默认 | 🟡 |
| 81 | SetBool32_0x7C_15_ActionButton4400 | 动作按钮 #4400 | 🟡 |

### 义肢 / 武器切换

| 值 | FlagType（英文） | 中文译名 | 置信度 |
| --- | --- | --- | --- |
| 106 | GetWeaponCancelType_HksSet2011_SameAs104 | 取武器取消类型（hksSet2011，同 104） | 🟡 |
| 109 | CanDoubleCast_hks331 | 能否双重施法（hks#331） | 🟡 |
| 133 | PC_ProstheticSwitchBuffer | 玩家：义肢切换缓冲 | 🟢 |
| 134 | PC_ProstheticSwitch | 玩家：义肢切换 | 🟢 |

### Cult 仪式（咒文流程，多见于神道剧情）

| 值 | FlagType（英文） | 中文译名 | 置信度 |
| --- | --- | --- | --- |
| 29 | Action_AndTAEDebuggingClass | 动作 + TAE 调试类 | 🔴 |
| 41 | HasSpace_Hks305 | 是否有空间（hks#305） | 🟡 |
| 42 | IsSweetSpot | 处于"甜点"判定范围内 | 🟡 |
| 46 | ExtraJumptable_IFAlive? | 额外跳转表（若存活？） | 🟡 |
| 47 | ExtraJumptable1_Death2 | 额外跳转表 1（死亡 2） | 🟡 |
| 48 | ExtraJumptable2_CultPromtCheck1 | 额外跳转表 2（咒文提示检查 1） | 🟡 |
| 51 | DontCancelIfFalling | 坠落时不取消 | 🟢 |
| 59 | WeakSpot | 弱点（受击时） | 🟢 |
| 76 | CultPromtCheck2 | 咒文提示检查 2 | 🟡 |
| 95 | PlayerDeathLight | 玩家死亡轻量级流程 | 🟢 |
| 99 | IsCultRitualProgressing | 咒文仪式进行中 | 🟢 |
| 113 | HeightCorrection | 高度修正 | 🟢 |
| 114 | ChangeLockOnMarkerPos | 改变锁定标记位置 | 🟢 |
| 124 | LockOnAutoSearch | 锁定自动搜索 | 🟢 |
| 149 | ? | 未知 | 🔴 |

### 引擎位标志（地址命名，语义多为推断）

| 值 | FlagType（英文） | 备注 | 置信度 |
| --- | --- | --- | --- |
| 14 | SetUnkBool | 未知布尔 | 🔴 |
| 15 | SetUnkFlags | 未知标志组 | 🔴 |
| 17–20 | Set_0x78_8 / Set_0x78_3 / DisableMapHit / Set_0x78_10 | 0x78 偏移系列布尔 | 🔴 |
| 24、35–40、44、49、50、52、53、55、58 | Set_0x78_*、Set0x1EB_Bool、Set0xEF_Bool、SetStartbit* | 各类内部布尔 | 🔴 |
| 56、57 | SetStartbit13_DamageModule / SetStartbit14_DamageModule | DamageModule 起始位 13/14 | 🔴 |
| 60–66、71、73、74、82–85、88、92 | SetBool32_0x7C_* 系列 | 0x7C 偏移上 32 位布尔字段 | 🔴 |
| 94、98、100–102 | SetStartbit0 / 17 / 18 / 21 | 起始位 | 🔴 |
| 96 | SetBool32_0x80_Startbit1 | 0x80 上起始位 1 | 🔴 |
| 122、123 | SetBool32_0x1E0 | 0x1E0 上 32 位布尔 | 🔴 |

> **个人解读**：上述大量 `0x7C` / `0x78` / `0x80` / `0x1E0` 命名出自社区 PE 逆向（ChrIns 结构体的字段偏移），不必死记。脚本侧基本只通过 `env(3036, SP_EF_REF_*)` 或 `hkbGetVariable(...)` 间接读取这些标志的"业务后果"，无需直接关心位偏移。

### 其它（带后缀解释）

| 值 | FlagType（英文） | 中文译名 | 置信度 |
| --- | --- | --- | --- |
| 0 | Do Nothing | 占位：什么也不做 | 🟢 |
| 2 | (不存在) | — | — |
| 13 | (不存在) | — | — |
| 33 | (不存在) | — | — |
| 43 / 45 | (不存在) | — | — |
| 77 | (不存在) | — | — |
| 93 | (不存在) | — | — |
| 97 | MagicCastingUselessChecks | 魔法施法的无关检查 | 🔴 |

---

# §2 行为 / 攻击 Behavior 触发

| ID | 英文名 | 中文译名 | 主要参数 | 说明 | 置信度 |
| --- | --- | --- | --- | --- | --- |
| 1 | AttackBehavior | 攻击行为触发 | `AttackType` (Standard / ForwardR1 / PlungingAttack / Parry)、`BehaviorJudgeID`、`DirectionType`、`Source`(0:默认/1:强制右手/2:强制左手)、`StateInfo` | 让 Havok 行为图分派一次攻击 Behavior（指定方向、武器手、攻击类别）。`BehaviorJudgeID` 关联 `BehaviorParam` 中的攻击伤害参数。 | 🟢 |
| 2 | BulletBehavior | 子弹行为 | `DummyPolyID`(发射点)、`BehaviorJudgeID`、`AttachmentType`、`Enable`、`StateInfo`、`Offset` | 在指定 DummyPoly 节点处生成 / 关闭一条 Bullet 行为（射弹）。 | 🟢 |
| 4 | BulletBehavior_Midair | 空中子弹行为 | 同 ID 2 | 用于空中飞行物（投掷物/法术）。 | 🟢 |
| 5 | CommonBehavior | 通用行为触发 | `AttackIndex (0-8)`、`BehaviorJudgeID` | 触发通用 Behavior（非攻击命中事件），按攻击索引下标。 | 🟡 |
| 9 | Event9 | 事件 9 | `u8` 单字节 | 含义未公开。 | 🔴 |
| 17 | Event17 | 事件 17 | 全为 padding | 占位事件。 | 🔴 |
| 24 | Event24 | 事件 24 | 4×s32 | 含义未公开。 | 🔴 |
| 304 | ThrowAttackBehavior | 投掷攻击行为 | `Index`、`BehaviorJudgeID` | 触发一次投掷类（抓取/处决）的行为判定。 | 🟢 |
| 307 | PCBehavior | 玩家专用行为 | `GetWeaponData`(u16)、`Offset`(u16)、`PCBehaviorType`(s32)、`BehaviorJudgeID` | 仅供玩家（PC = Player Character）的 Behavior 触发，会从武器槽读取附加数据。 | 🟢 |

---

# §3 武器 / 道具 切换

| ID | 英文名 | 中文译名 | 主要参数 | 说明 | 置信度 |
| --- | --- | --- | --- | --- | --- |
| 32 | SetWeaponStyle | 设置武器握法 | `WeaponStyle`：0 无/1 右手单手/2 左手双手/3 右手双手/4 左手变形单手/5 右手变形单手/6 未知 | 切换当前武器姿态（单/双手 / 义肢变形）。 | 🟢 |
| 33 | SwitchWeapon | 切换武器 | `WeaponSlotID` | 在武器槽之间切换实际装备。 | 🟢 |
| 34 | UnequipCrossbowBolt | 卸下弩箭矢 | `HandType`：0 左手 / 1 右手 | （SDT 中实际不用弩，但模板复用了 DS3 结构） | 🟡 |
| 35 | EquipCrossbowBolt | 装上弩箭矢 | `HandType`：0 左手 / 1 右手 | 同上。 | 🟡 |
| 64 | CastHighlightedMagic | 释放被高亮的魔法 | `DummyPolyID`、`ChrBulletSharedHitSlot`、`RefType`(RefId1–4) | 在指定 DummyPoly 上以指定 RefId 释放一次魔法 / 法术。 | 🟡 |
| 65 | ConsumeCurrentGoods | 消耗当前道具 | `HandType`(0 右手 / 1 左手)、`DirectionChanger`、`ChrBulletSharedHitSlot` | 消耗一次当前持有道具（药物 / 投掷物等）。 | 🟢 |

---

# §4 SpEffect 施加

| ID | 英文名 | 中文译名 | 参数 | 说明 | 置信度 |
| --- | --- | --- | --- | --- | --- |
| 66 | AddSpEffect_Multiplayer | 施加 SpEffect（联机版） | `SpEffectID` | 联机环境下叠加 SpEffect。 | 🟢 |
| 67 | AddSpEffect | 施加 SpEffect | `SpEffectID` | 在角色身上施加指定 SpEffect。脚本中通常通过 `env(3036, SP_EF_REF_*)` 间接观测此处施加的标志。 | 🟢 |
| 302 | AddSpEffect_DragonForm | 施加 SpEffect（龙形态） | `SpEffectID` | 仅在龙形态下生效。 | 🟡 |
| 331 | AddSpEffect_WeaponArts | 施加 SpEffect（武器战技） | `SpEffectID`、`SpEffectID_LowFP` | FP 充足 / 不足时分别施加不同 SpEffect。 | 🟢 |
| 401 | AddSpEffect_Multiplayer_401 | 施加 SpEffect（联机版 401） | `SpEffectID` | 与 66 类似，另一条联机通路。 | 🟡 |
| 797 | AddSpEffect_CultRitualCompletion | 施加 SpEffect（咒文仪式完成） | `SpEffectId` | 咒文 / 神道仪式完成时使用。 | 🟡 |
| 940 | BehaviorParam_AddSpEffect | 行为参数：施加 SpEffect | `BehaviorJudgeId` | 通过 BehaviorParam 索引间接施加 SpEffect。 | 🟡 |

> **关联**：SpEffect 是 Souls 系列贯穿全游戏的状态/Buff/Debuff 系统。Lua 侧通过 `env(3036, SP_EF_REF_BUKKAKE)` 等检查是否被 TAE 激活了某 SP_EF_REF。详见 [doc/env.md §SP_EF_REF_*](../env.md#sp_ef_refspeffect-引用-id)。

---

# §5 FFX 视觉特效

> **FFX**（FromSoftware FX）是粒子 / 后处理特效系统。所有 FFX 系列的参数共性：
>
> - `FFXID` / `FFXID_Deprecated`：FFX 资源 ID
> - `DummyPolyID`：附着点（DummyPoly = 模型上预留的点 / 骨骼挂点）
> - `SlotID`：FFX 槽位（同槽位可互斥 / 替换）
> - `IsIgnoreDummyPolyAngle` / `IsFollowDummyPoly` / `IsRestrictToDummyPoly`：朝向与跟随选项
> - `StateInfo`：状态信息位

| ID | 英文名 | 中文译名 | 关键差异 | 置信度 |
| --- | --- | --- | --- | --- |
| 95 | SpawnOneShotFFX_Ember | 一次性 FFX（残火/灰烬） | 带 ExtraSpawnCondition；DS3 残火/SDT 残留版 | 🟡 |
| 96 | SpawnOneShotFFX | 一次性 FFX | 通用一次性 FFX；含 StateInfo | 🟢 |
| 99 | SpawnRepeatingFFX | 重复播放 FFX | 只有 ID/DummyPoly/Slot，事件期间一直播放 | 🟢 |
| 100 | SpawnFFX_100 | FFX 类型 100 | 单参数 IsFollowDummyPoly | 🟡 |
| 101 | SpawnFFX_101 | FFX 类型 101 | 仅 FFXID，最简形式 | 🔴 |
| 108 | SpawnFFX_108 | FFX 类型 108 | 同 100，使用方差异不明 | 🔴 |
| 109 | SpawnFFX_109 | FFX 类型 109 | 同 100 | 🔴 |
| 110 | SpawnFFX_110 | FFX 类型 110 | 仅 FFXID | 🔴 |
| 112 | SpawnFFX_ByFloor | FFX（按地面类型） | 含 DummyPoly + 1 个未命名 s32 | 🟡 |
| 114 | SpawnFFX_GoodsAndMagic | FFX（道具/魔法关联） | `DummyPolySource`(Body/LeftWeap/RightWeap)、`ParamType`(MagicParam/EquipParamGoods)、`SFXIndexID`(Type0–2)、`TimerType` | 🟢 |
| 115 | SpawnFFX_GoodsAndMagicEX | FFX（道具/魔法扩展） | 与 114 同字段 | 🟢 |
| 116 | SpawnFFX_Throw | FFX（投掷） | `RepeatType`(PlayOnce/PlayTwice)、`IsRepeat` | 🟡 |
| 117 | SpawnFFX_ThrowDirection | FFX（投掷方向指示） | `ThrowDirectionSFXIndex` 等同 SFX 索引 | 🟡 |
| 118 | SpawnFFX_Blade | FFX（刀刃拖尾） | `DummyPolyBladeBaseID`、`DummyPolyBladeTipID` | 🟢 |
| 119 | SpawnFFX_Body_ForEventDuration | FFX（身体，事件期间） | `RepeatType` + `IsRepeat`；事件持续时间内重复 | 🟡 |
| 120 | PlayFFX | 播放 FFX（多 Ghost 变体） | 含 11 个 FFXID 变体（主、GreyGhost、WhiteGhost、BlackGhost、Sun、Berserker、Darkmoon、FarronWolf、Aldrich 等） | 🟡 |
| 121 | FFX_121 | FFX 类型 121 | 简化形式（FFXID + DummyPoly + b + u8） | 🔴 |
| 122 | SpawnFFX_BySpEffect1 | FFX（按 SpEffect 1） | `IsEnable`、`SpEffectID`：被该 SpEffect 驱动 | 🟡 |
| 123 | FFX_BySpEffect2 | FFX（按 SpEffect 2） | `SpEffectId` + 多个 b/u8 | 🔴 |
| 961 | 961_FFX | FFX（事件 961） | `FFXID`、`DummyPoly`、`StateInfo`；与 IFrames/咒文事件位置相邻 | 🟡 |

> **DummyPolySource 枚举**（频繁出现）：0 = Body 身体；1 = Left Weapon 左手武器；2 = Right Weapon 右手武器。

---

# §6 音效 / 印迹 / 震动

## 6.1 SoundType 枚举（在 ID 128–132 / 10130 共用）

| 值 | 前缀 | 中文 |
| --- | --- | --- |
| 0 | (a) | 环境 Environment |
| 1 | (c) | 角色 Character |
| 2 | (f) | 菜单音效 Menu SE |
| 3 | (o) | 物件 Object |
| 4 | (p) | 过场音效 Cutscene SE |
| 5 | (s) | SFX |
| 6 | (m) | BGM |
| 7 | (v) | 语音 Voice |
| 8 | (x) | 地面材质决定 |
| 9 | (b) | 护甲材质决定 |
| 10 | (g) | 幽灵 Ghost |

## 6.2 音效事件

| ID | 英文名 | 中文译名 | 关键参数 | 说明 | 置信度 |
| --- | --- | --- | --- | --- | --- |
| 128 | PlaySound_CenterBody | 播放音效（角色中心） | `SoundType`、`SoundID` | 在角色中心位置播放音效。 | 🟢 |
| 129 | PlaySound_BySlot | 播放音效（按槽位） | `SoundType`、`SoundID`、`DummyPolyID`、`SlotID`、`StateInfo` | 在指定 DummyPoly 和槽位播放音效。 | 🟢 |
| 130 | PlaySound_ByDummyPoly_PlayerVoice | 播放音效（按 DummyPoly，玩家语音） | `SoundType`、`SoundID`、`DummyPolyID`、`SlotID` | 通常用于玩家发声。 | 🟢 |
| 131 | PlaySound_BySlot | 播放音效（按槽位 2） | `SoundType`、`SoundID`、`DummyPolyID` | 与 129 同名但少 SlotID 之后字段。 | 🟢 |
| 132 | PlaySound_Weapon | 播放音效（武器） | `SoundType`、`SoundID` | 武器音效（挥砍、碰撞）。 | 🟢 |
| 970 | OldSoundDebug | 旧音效调试 | 7×f32 | 已废弃的调试事件。 | 🔴 |
| 10130 | PlaySound_WanderGhost | 播放音效（流浪幽灵） | 4×s32 + 2×u8 | SDT 中的"鬼"系列敌人专用。 | 🟡 |

## 6.3 Decal 印迹（地面 / 身体留痕）

| ID | 英文名 | 中文译名 | 关键参数 | 置信度 |
| --- | --- | --- | --- | --- |
| 137 | DecalParamID_CenterBody | 印迹参数（角色中心） | `DecalParamID` | 🟢 |
| 138 | DecalParamID_DummyPoly | 印迹参数（指定 DummyPoly） | `DecalParamID`、`DummyPolyID` | 🟢 |
| 139 | DecalParamID_ByFoot | 印迹参数（按脚部） | `DecalParamID` + 6×u16 索引 | 🟢 |
| 10137 | DebugDecal1 | 调试印迹 1 | `DecalParamId` | 🔴 |
| 10138 | DebugDecal2 | 调试印迹 2 | `DecalParamId` + s32 | 🔴 |

## 6.4 Rumble 手柄震动

| ID | 英文名 | 中文译名 | 关键参数 | 置信度 |
| --- | --- | --- | --- | --- |
| 144 | RumbleCam_Local | 局部相机震动 | `RumbleCamID`、`DummyPolyID`、`FalloffStart/End` | 🟢 |
| 145 | RumbleCam_Global | 全局相机震动 | `RumbleCamID`、`Condition`(0:无条件/1:OnGround) | 🟢 |
| 146 | RumbleCam_Global2 | 全局相机震动 2 | `RumbleCamID`、`Condition`、b | 🟢 |
| 147 | RumbleCam_Local2 | 局部相机震动 2 | `RumbleCamID`、`DummyPolyID`、`FalloffStart/End`、b | 🟢 |

---

# §7 相机控制

| ID | 英文名 | 中文译名 | 关键参数 | 说明 | 置信度 |
| --- | --- | --- | --- | --- | --- |
| 150 | SetLockCamParam | 设置锁定相机参数 | `LockCamParamID` | 切换 LockCamParam | 🟢 |
| 151 | CameraLookAtTarget | 相机看向目标 | `DummyPolyID`、`LookUpLimit`、`LookDownLimit`、`LookLeftLimit`、`LookRightLimit` | 上下左右注视范围限制。 | 🟢 |
| 152 | AttachCameraToNode | 相机附着到骨骼 | `DummyPolyID`、`BlendStrength` | 类似动画过场的相机绑定。 | 🟢 |
| 153 | CameraModule3 | 相机模块 3 | `CamDistTargetOverride`、`StartInterpolationSpeed`、`TransitionKeyframe`、`EndInterpolationSpeed`、`SlowStart`、`SlowEnd` | 距离覆写 + 插值速度。 | 🟡 |
| 154 | NULL_BROKEN_EVENT | 空 / 损坏事件 | 全为 padding | 模板标注为坏事件。 | 🟢 |
| 155 | SetLockParamID | 设置锁定参数 ID | `LockParamID` | 切换 LockParam | 🟢 |
| 156 | SetCameraAngle | 设置相机角度 | `VerticalAngle`、`HorizontalAngle`、`InterpolationType`(最近/顺时针/逆时针)、`OverrideVertical`、`OverrideHorizontal` | 强制相机角度（多用于过场 / 处决）。 | 🟢 |
| 238 | UsedForLockOnAnims | 用于锁定动画 | 1×s32 + 3×f32 | 锁定时朝向修正等。 | 🟡 |
| 520 | LockedOnModule1 | 锁定模块 1 | 全 padding | 标记事件。 | 🔴 |
| 521 | LockedOnModule2 | 锁定模块 2 | 1×s32 | — | 🔴 |
| 522 | LockedOnModule3 | 锁定模块 3 | `TargetChrParameter` | 与目标参数关联。 | 🔴 |

---

# §8 透明度 / 淡入淡出 / 调试

| ID | 英文名 | 中文译名 | 关键参数 | 置信度 |
| --- | --- | --- | --- | --- |
| 192 | DebugFadeOut | 调试用淡出 | `FadeOut` | 🟡 |
| 193 | SetOpacityKeyframe | 设置不透明度关键帧 | `OpacityAtEventStart`、`OpacityAtEventEnd` | 🟢 |
| 195 | EnableBlurFeedback | 启用模糊反馈 | 全 padding | 🟡 |
| 196 | DebugStringPrint_C_ARSN_BumpBlendDecal | 调试输出字符串（ARSN BumpBlend Decal） | s64 + 4×s32 + b | 内部调试用 | 🔴 |
| 197 | FadeOut | 淡出 | `GhostMain`、`GhostSub` | 残影/灵体主辅淡出 | 🟢 |

---

# §9 角色参数控制

| ID | 英文名 | 中文译名 | 关键参数 | 说明 | 置信度 |
| --- | --- | --- | --- | --- | --- |
| 224 | SetTurnSpeed | 设置转身速度 | `TurnSpeed`、`IsLockOnCheck` | 🟢 |
| 225 | SetSPRegenRatePercent | 设置体力恢复率百分比 | `RegenRatePercent` | SDT 的"SP"为耐力 / 体力。 | 🟢 |
| 226 | SetKnockbackPercent | 设置击退率百分比 | `KnockbackPercent` | 0–100。 | 🟢 |
| 230 | SetMPRegenRatePercent | 设置 MP 恢复率百分比 | `RegenRatePercent` | SDT 中此字段在玩家身上多用于义肢资源(?)。 | 🟡 |
| 232 | AllowVerticalTorsoAim | 允许躯干竖直瞄准 | `UpwardAngleLimit`、`DownwardAngleLimit`、`UpwardAngleThreshold`、`DownwardAngleThreshold` | 上下半身分离瞄准。 | 🟢 |
| 233 | ChangeChrDrawMask | 改角色绘制遮罩 | 32 个 u8 Mask | 决定哪些部件被渲染。 | 🟢 |
| 235 | Event235 | 事件 235（遮罩） | 32 个 b Mask | 与 233 同字段语义。 | 🟡 |
| 236 | RootMotionReduction | 根运动衰减 | `ReductionAtEventStart`、`ReductionAtEventEnd`、`ReductionType` | 衰减动画位移 | 🟢 |
| 305 | ExtraSADurability_Multiplier | 超甲(SA)耐久额外倍率 | `ExtraSADurabilityMultiplier` | SuperArmor 耐久。 | 🟡 |
| 340 | UnkAction340_ResetsGlobalTimestep | 重置全局时间步（未知） | 全 padding | 罕用 | 🔴 |
| 510 | FullBodyWet | 全身湿润 | 全 padding | 进水后 / 水下用 | 🟢 |
| 603 | DebugAnimSpeed | 调试动画速度 | `AnimSpeed` (u32) | 调试用 | 🟢 |
| 760 | BoostRootMotionToReachTarget | 增益根运动以触达目标 | `IsEnable`、`ReferenceDist`、`EnableRangeMin/Max`、`ArriveAngleFromTarget`、`ArriveDistFromTarget` | 自动逼近目标 | 🟢 |
| 800 | DebugMovementMultiplier | 调试移动倍率 | `MovDistMultiplier`、`CamTurnDistMultiplier`、`LadderDistMultiplier` | 🟢 |

---

# §10 跳转表 / 动作请求

| ID | 英文名 | 中文译名 | 关键参数 | 置信度 |
| --- | --- | --- | --- | --- |
| 300 | ActivateJumpTableEarly | 提前激活跳转表 | `JumpTableID_ToActivateEarly`、`JumpTable2ID_ToJudgeHowEarly`（0 默认/1 负重/2 武器重量率/3 压缩伤害率?/4 越早越好/5 敏捷施法速度/6 调试 TAE 值） | 🟢 |
| 301 | Event301 | 事件 301 | 1×s32 | 🔴 |
| 306 | Event306 | 事件 306 | f32×2 + Flags | 🔴 |
| 308 | Event308 | 事件 308 | 1×f32 | 🔴 |
| 310 | Event310 | 事件 310 | 2×u8 | 🔴 |
| 311 | Event311 | 事件 311 | 3×u8 | 🔴 |
| 312 | Event312 | 事件 312 | `BehaviorMask` (32 字节数组) | Behavior 掩码（按位允许哪些 Behavior） | 🟡 |
| 313 | Event313 | 事件 313 | `Flags` | 🔴 |
| 314 | Event314 | 事件 314 | 2×u8 | 🔴 |
| 320 | ActionRequest | 动作请求 | `ActRequest1` … `ActRequest7`（7 个布尔） | 类似输入请求位。 | 🟡 |
| 330 | WeaponArtFPConsumption | 战技 FP 消耗 | 全 padding（仅作为时机标记） | 🟢 |
| 332 | WeaponArtWeaponStyleCheck | 战技武器握法检查 | 全 padding | 🟢 |

---

# §11 流程 / 状态

| ID | 英文名 | 中文译名 | 关键参数 | 说明 | 置信度 |
| --- | --- | --- | --- | --- | --- |
| 227 | EventEzStateFlag\<HKS\_env301\> | EzState 标志事件 | `EzStateFlagID` | 触发某条 EzState 标志（在脚本 ezstate 体系中观测）。 | 🟢 |
| 228 | RagdollReviveTime | 布偶复活时间 | `ReviveTimerExtra`、`ReviveTimer` | Ragdoll 进入后多久允许复活。 | 🟢 |
| 231 | SetEzStateRequestID | 设置 EzState 请求 ID | `EzStateRequestID` | 🟢 |
| 500 | Event500 | 事件 500 | `FlagIndex`、`Index`(1:0/2:0x02000045或0x02000049/3:0x02000042/4:0x02000012) | EzState/事件标志检查 | 🟡 |
| 720 | SekiroNew720 | 苇名新事件 720 | `CultType`、未知 u8 | Cult 仪式类型相关 | 🟡 |
| 793 | CultWeaponValue | 咒文武器值 | `WeaponValue` | 🟡 |
| 794 | CultFlag | 咒文标志 | 全 padding | 🟡 |
| 796 | Menu | 打开菜单 | `MenuType`(0 升级/1 重生属性) | 触发等级/属性界面（如佛堂） | 🟢 |
| 798 | CultCompletionSfxValue | 咒文完成特效值 | `CultSfxValue` (f32) | 🟡 |
| 799 | CultExecution | 咒文执行 | 全 padding（事件触发） | 🟡 |

---

# §12 行为图 / 附加动画

| ID | 英文名 | 中文译名 | 关键参数 | 说明 | 置信度 |
| --- | --- | --- | --- | --- | --- |
| 234 | AddOffsetToNextAnimID | 对下一动画 ID 加偏移 | `Offset` | 让 Havok 在下一段动画上加上偏移。 | 🟢 |
| 600 | EnableBehavior | 启用 Behavior | `Mask`（行为掩码） | 决定哪些 Behavior 在该段时间内能被触发。 | 🟢 |
| 601 | SetAdditiveAnim | 设置附加动画 | `AnimType`、`WeightAtEventStart`、`WeightAtEventEnd`、`AnimType2` | 附加层动画的权重曲线。 | 🟢 |
| 602 | Event602 | 事件 602（StayAnim） | `StayAnimType`、2×f32 | 滞留 / 待机层动画 | 🟡 |
| 604 | TestParam | 测试参数 | 全 padding | 调试 | 🔴 |
| 605 | SetTimeActEditorHavokVariable | 设置 Havok 变量（TAE 编辑器） | `Unk00`、`VariableID`、`ValueGradient`(f32grad) | 把 hkb 变量在事件期间按渐变赋值（类似动画驱动的变量动画）。 | 🟢 |
| 606 | JiggleModifier | 抖动修改器 | `JigglerId`、`FadeIn`、`FadeOut` | 部件物理抖动开关 | 🟢 |
| 607 | FaceAnimation | 面部动画 | `AnimType`(0–12 对应 a000_790000…a000_790120)、`Weight`(f32grad) | 选择面部动画并按曲线插值权重。 | 🟢 |

---

# §13 旋转 / 瞄准 / Twist

| ID | 英文名 | 中文译名 | 关键参数 | 说明 | 置信度 |
| --- | --- | --- | --- | --- | --- |
| 700 | CustomLookAtTwistModifier | 自定义看向 / Twist 修改器 | `UpLimitAngle/DownLimitAngle/RightLimitAngle/LeftLimitAngle`；`ModifierID`(0/1/2 Twist、5/6 NPC对话 Twist、10 未用、30/31 Throw、50 未用、100/110/120/130 Attack、140/150 Wire)；`TargetType`(0 自由瞄准/1/2 篝火献祭怠机/3 玩家锁定/4/5 钩绳/6 锁定（未用）/7 自由瞄准（蹲伏/横扫）/8 抓取/9 自由瞄准（NPC）/10 自由瞄准（高警戒）/11 对话/12) | 综合多场景的躯干 / 头部 Twist 控制（最复杂的瞄准事件） | 🟢 |
| 703 | FixedRotationDirection | 固定旋转方向 | `IsEnable` | 锁定旋转方向（避免随相机改） | 🟢 |
| 704 | ChrTurnSpeed Hks/Engine Flag 0x00020000 | 角色转身速度（带引擎标志） | `SpeedDefault`、`SpeedExtra`、`SpeedBoost` | 与 224 不同，附加引擎标志 | 🟢 |
| 705 | FacingAngleCorrection, Hks/Engine flag 0x04000000 | 朝向角度修正（带引擎标志） | `CorrectionRate` | 🟡 |
| 706 | ChrTurnSpeed_ForLock | 角色转身速度（锁定时） | `TurnSpeed` | 锁定状态下专用转身速度 | 🟢 |
| 707 | ManualAttackAiming?? | 手动攻击瞄准（推断） | 全 padding | 标记位 | 🟡 |

---

# §14 苇名新增系列 700+

| ID | 英文名 | 中文译名 | 关键参数 | 置信度 |
| --- | --- | --- | --- | --- |
| 708 | NewSekiro708 | 苇名新事件 708 | 多 s32 + f32 + u8（13 字段，多 padding） | 🔴 |
| 709 | NewSekiroFlag709 | 苇名新标志 709 | 全 padding | 🔴 |
| 720 | SekiroNew720 | 苇名新事件 720 | `CultType`、未知 u8 | 🟡 |
| 730 | OnlyForNon\_c0000Enemies | 仅敌人（非玩家） | 2×f32 + `pad` s32 | 玩家不会触发；c0000 = 玩家 | 🟢 |
| 731 | Event731 | 事件 731 | 1×s32 | 🔴 |
| 750 | NewengineFlag8 | 新引擎标志 8 | 全 padding | 🔴 |

---

# §15 武器外观 / 隐藏 / 收鞘

| ID | 英文名 | 中文译名 | 关键参数 | 说明 | 置信度 |
| --- | --- | --- | --- | --- | --- |
| 710 | HideEquippedWeapon | 隐藏装备的武器 | `LeftHand`、`RightHand`、`LeftHand_WithScabbard`、`RightHand_WithScabbard` | 选择隐藏哪只手 / 是否连同鞘。 | 🟢 |
| 711 | HideModelMask | 隐藏模型遮罩 | 32 个 b Mask | 按遮罩隐藏模型部件。 | 🟢 |
| 712 | WeaponShealthFlags | 收鞘标志组合 | 多组 `WepAbsorpPosConditionN` + `ShealthIndexN`（OneHand_Left/Right、BothHand、Shealth、DontUpdate、Friede Scythe、Other、Default=-1） | 切换武器吸附 / 收鞘姿态（共 8 组条件） | 🟡 |
| 713 | ShowModelMask | 显示模型遮罩 | 32 个 b Mask | 与 711 反向。 | 🟢 |
| 714 | DamageLevelFunction | 伤害等级函数 | 1×b | 触发某类伤害等级判定。 | 🟡 |
| 715 | OverrideWeaponModelLocation | 覆写武器模型位置 | `WeaponModelType`(0 右武器/1 左武器/2 楔丸/3 钩绳)、`Model0~3DummyPolyID` | 把武器模型贴到指定挂点（用于过场 / 收纳）。 | 🟢 |
| 716 | Event716 | 事件 716 | 5×b | 状态位组合 | 🔴 |
| 717 | WireModelEventUnk | 钩绳模型事件（未知） | 1×s32 | 与 §18 钩绳系统配合 | 🔴 |
| 790 | DisableDefaultWeaponTrail | 关闭默认武器拖尾 | 全 padding | 🟢 |
| 791 | PartDamageAdditiveBlendInvalid | 部位伤害附加混合无效 | 全 padding | 🟡 |

---

# §16 骨骼修改

| ID | 英文名 | 中文译名 | 关键参数 | 置信度 |
| --- | --- | --- | --- | --- |
| 770 | ChangeBonePos | 改变骨骼位置 | 1×s32 + f32 + u8 | 🟡 |
| 771 | FixBone | 固定骨骼 | 1×u8 | 🟡 |
| 772 | ChangeBonePosEX | 改变骨骼位置（扩展） | 同 770 | 🟡 |
| 780 | AddHeight | 增加高度 | `Height` (f32) | 把胶囊体抬高，避免高地形卡。 | 🟢 |
| 781 | TurnLowerBody | 下半身转身 | `TurnState` (u8) | 上下半身独立旋转控制。 | 🟢 |

---

# §17 AI / NPC 行为

| ID | 英文名 | 中文译名 | 关键参数 | 置信度 |
| --- | --- | --- | --- | --- |
| 229 | CreateAISound1 | 制造 AI 声响 1 | `AiSoundID` | 引起 NPC 听觉警戒。 | 🟢 |
| 237 | CreateAISound2 | 制造 AI 声响 2 | `AISoundID` | 同上的另一通路。 | 🟢 |
| 782 | AiReplanningCtrlReset | AI 重规划控制重置 | 全 padding | 让 AI 行为树重新决策。 | 🟢 |
| 785 | SpawnChrFinderBullet | 生成搜敌子弹 | `DetectionRange`、`DummyPointID`、`BulletID`、`IsCompareChrType`、`TargetNum` | 发射一发"寻敌弹"（无伤害，用作 AI 感知 / 目标筛选）。 | 🟡 |

---

# §18 钩绳系统 Wire

| ID | 英文名 | 中文译名 | 关键参数 | 置信度 |
| --- | --- | --- | --- | --- |
| 900 | WireSyncWithTarget_Start | 钩绳同步：开始 | 1×f32 | 🟢 |
| 901 | WireSyncWithTarget_Travel | 钩绳同步：飞行 | 全 padding | 🟢 |
| 902 | WireLookAtTarget | 钩绳：看向目标 | 全 padding | 🟢 |
| 903 | WireEventUnk01 | 钩绳事件（未知 01） | 1×s32 | 🔴 |
| 904 | WireSlideToStartPoint | 钩绳：滑回起点 | 全 padding | 🟢 |
| 905 | WireDisableFalling | 钩绳：抑制坠落 | 全 padding | 钩绳中段不受坠落处理。 | 🟢 |

---

# §19 物理速度 / 引擎标志

| ID | 英文名 | 中文译名 | 关键参数 | 置信度 |
| --- | --- | --- | --- | --- |
| 920 | ChrPhysicsVelosityChange | 角色物理速度变更 | `ChrPhysicsVelocityParam ID` | 🟢 |
| 921 | Event921 | 事件 921 | 1×u8 + 1×s32 | 🔴 |
| 922 | ChrPhysicsVelosityScale | 角色物理速度缩放 | `ChrPhysicsVelocityParam ID`、4×u8 | 🟢 |
| 910 | NewEngineFlag1 | 新引擎标志 1 | 全 padding | 🔴 |
| 911 | NewEngineFlag2 | 新引擎标志 2 | 全 padding | 🔴 |
| 912 | NewEngineFlag3 | 新引擎标志 3 | 全 padding | 🔴 |
| 913 | NewEngineFlag4 | 新引擎标志 4 | 全 padding | 🔴 |
| 946 | NewEngineFlag5 | 新引擎标志 5 | `State` (b) | 🔴 |
| 750 | NewengineFlag8 | 新引擎标志 8 | 全 padding | 🔴 |

---

# §20 杂项事件 930+

| ID | 英文名 | 中文译名 | 关键参数 | 置信度 |
| --- | --- | --- | --- | --- |
| 930 | Event930 | 事件 930 | 3×u8 | 🔴 |
| 931 | Event931 | 事件 931 | 1×u8 | 🔴 |
| 932 | Event932 | 事件 932 | 1×u8 + 3×s32(pad) | 🔴 |
| 933 | Event933 | 事件 933 | 全 padding | 🔴 |
| 934 | Action_ForThrowCutsceneSE | 投掷过场音效 | 2×s32 | 🟢 |
| 935 | Action_ForThrowCutsceneSE_DummyPolyFollowing | 投掷过场音效（跟随 DummyPoly） | 3×s32 | 🟢 |
| 936 | Action_ForThrowCutsceneDecal_SpecificDummyPoly | 投掷过场印迹（指定 DummyPoly） | 3×s32 | 🟢 |
| 942 | Event942 | 事件 942 | 1×u8 | 🔴 |
| 943 | Event943 | 事件 943 | 全 padding | 🔴 |
| 944 | Event944 | 事件 944 | 2×f32 + 1×s32 | 🔴 |
| 945 | Event945 | 事件 945 | 2×f32 + 2×u8 + 1×b | 🔴 |
| 947 | Event947 | 事件 947 | 1×f32 | 🔴 |

---

# §21 无敌帧 IFrames

| ID | 英文名 | 中文译名 | 关键参数 | 说明 | 置信度 |
| --- | --- | --- | --- | --- | --- |
| 950 | IFrames_MistRaven | 无敌帧（雾乌） | 全 padding | 道具：神食 / 雾乌的羽毛特效期。 | 🟢 |
| 951 | IFrames_DuringAction | 无敌帧（动作中） | 全 padding | 标准动作中的无敌帧。 | 🟢 |
| 952 | IFrames_ThrowAtkStillHurts | 无敌帧（投掷攻击仍受伤） | 全 padding | 普通无敌但抓取仍可命中。 | 🟢 |
| 953 | IFrames_Unk953 | 无敌帧（未知 953） | 全 padding | 🔴 |
| 954 | IFrames | 无敌帧（带类型） | `IFrameType`(1 Sweeps 横扫/2 General 通用/6 Thrusts 突刺/7 Grabs 抓取) | 按伤害分类的无敌（如"看破突刺"是 6 类对应的反应窗口）。 | 🟢 |

---

# §22 体力 / 其他

| ID | 英文名 | 中文译名 | 关键参数 | 说明 | 置信度 |
| --- | --- | --- | --- | --- | --- |
| 960 | StaminaControlParam | 体力控制参数 | `StaminaRatioType` (u8) | 体力比例分类 | 🟢 |
| 795 | DS3Poise | DS3 韧性参数（残留） | `ToughnessParamID`、`ToughnessType`、`DamageRatio` | SDT 中韧性体系大改，此事件多为占位/兼容。 | 🟡 |

---

# §23 调试 / Debug

| ID | 英文名 | 中文译名 | 备注 |
| --- | --- | --- | --- |
| 603 | DebugAnimSpeed | 调试动画速度 | 见 §9 |
| 604 | TestParam | 测试参数 | 见 §12 |
| 800 | DebugMovementMultiplier | 调试移动倍率 | 见 §9 |
| 970 | OldSoundDebug | 旧音效调试 | 见 §6 |
| 10137 | DebugDecal1 | 调试印迹 1 | 见 §6 |
| 10138 | DebugDecal2 | 调试印迹 2 | 见 §6 |
| 196 | DebugStringPrint_C_ARSN_BumpBlendDecal | 调试字符串输出 | 见 §8 |
| 192 | DebugFadeOut | 调试用淡出 | 见 §8 |

---

# 附录 A：与脚本侧的关联

虽然 TAE 事件由 Havok 在动画时间轴上触发，Lua 侧并不直接发起 TAE，但下列对接点常见：

- `env(3036, SP_EF_REF_*)` —— 查询某条 SpEffect 是否被当前 TAE / 行为激活（参见 [doc/env.md §SP_EF_REF_*](../env.md#sp_ef_refspeffect-引用-id)）。`AddSpEffect` 系列（§4）即是 TAE 一侧的写入端，`env(3036, …)` 是 Lua 一侧的读取端。
- `hkbIsNodeActive("...")` —— 检查 Havok 行为图节点是否激活；许多 TAE 事件（如 `EnableBehavior` ID 600、`ChrActionFlag.AnimCancelStart_*`）的"间接效果"可以在脚本中通过该 API 观测。
- `hkbGetVariable("...")` / `act(148, …)` —— Havok 变量；`SetTimeActEditorHavokVariable`（ID 605）就是 TAE 期间按曲线驱动此类变量的入口。
- `BehaviorJudgeID` —— 频繁出现于 §2 攻击行为、§4 BehaviorParam_AddSpEffect 中，对应 BehaviorParam 表（外部 csv），用于把"动画上一个时间点"与"行为/伤害/特效"绑定到一张参数表里的一行。

# 附录 B：解读限制

1. 模板由社区逆向产出，部分英文名带 `?`、`??`、`Unk*`、`EventNNN` 表示作者也不确定语义，本文对应位置一律标 🔴。
2. SDT 模板复用了 DS3 / Bloodborne 的字段（如 `Ember`、`CrossbowBolt`、`Friede Scythe`、`Aldrich`、`FarronWolf`），并不代表 SDT 中真的有这些内容——属于历史遗留命名。
3. 模板中 `assert="0"` 的字段是"模板验证用的恒零占位"，实际数据无意义，文档统一以"全 padding"或"…padding"注明。
4. 中文译名仅为方便检索，不应替代英文 name 作为脚本/工程引用——本文档不创造新标识符。
