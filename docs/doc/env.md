# Sekiro c0000 env(id) 解读与 UE 映射

本文档记录 `c0000` 相关 HKS/Lua 脚本里出现的 `env(...)` 查询。结论来自已解码脚本的静态阅读，重点文件：

- `docs/doc/script/c0000.dec.lua`
- `docs/doc/script/c0000_transition.dec.lua`
- `docs/doc/script/c0000_cmsg.dec.lua`
- `docs/doc/script/c0000_define.dec.lua`

`env` 本身不是 Lua 函数，而是游戏 native runtime 注入的全局查询接口。脚本侧只看到数字 ID 和少数命名字符串，真实 C++ 分发还需要继续反编译 native 回调。当前工程的 UE 对应实现放在：

- `Source/SekiroDemo/SekiroEnvQueryComponent.h`
- `Source/SekiroDemo/SekiroEnvQueryComponent.cpp`

组件名为 `USekiroEnvQueryComponent`，已挂到 `ASekiroC0000PreviewCharacter::EnvQuery` 上。它提供 `EnvBool`、`EnvInt`、`EnvFloat`、`EnvValue`、`EnvNamedBool`，并用一组运行时字段模拟脚本里的 `env(id, subKey)` 返回值。

## 总览

本轮扫描到 82 个 first-key：

- 81 个数字 ID。
- 1 个字符串 key：`特殊効果発動中か_Behavior参照ID_寿命延長を厳密に取得`。

表内“置信度”含义：

- 高：变量名、常量比较、事件分支都能互相印证。
- 中：用途明确，但 native 字段名不确定。
- 低：只能从 gate 位置推断大概用途。

## env ID 完整表

| ID | 推断含义 | 参数/返回 | UE 字段或查询 | 置信度 |
|---:|---|---|---|---|
| 105 | 待触发事件 ID | `env(105, 1)` -> int | `PendingEventId` | 高 |
| 113 | 道具使用的固定/特殊分支 | bool | `bItemUseFixedRequest` | 低 |
| 115 | 道具使用请求无效或被阻止 | bool | `bItemUseRequestInvalid` | 中 |
| 200 | 下落请求/进入 fall | bool | `bIsFalling` | 高 |
| 201 | 着地请求/接地瞬间 | bool | `bJustLanded` | 高 |
| 202 | 伤害类型 | `DAMAGE_TYPE_*` | `DamageType` | 高 |
| 205 | 伤害动画 gate | bool | `bDamageAnimationGateActive` | 中 |
| 206 | 伤害/死亡反应抑制 | bool | `bDamageReactionSuppressed` | 中 |
| 207 | 武器/手臂安全状态 | `ARM_STYLE_*` | `WeaponChangeType` | 高 |
| 222 | 水平方向受击角 | `DAMAGE_DIR_*` | `DamageAngle` | 高 |
| 224 | 下落高度原始值 | float，脚本乘 `0.01` | `FallHeightRaw` | 高 |
| 225 | 当前武器 motion category | `HAND_LEFT/RIGHT` -> `WEP_MOTION_CATEGORY_*` | `WeaponMotionCategoryByHand` | 高 |
| 231 | 道具动画类型 | `ITEM_*` | `ItemAnimeType` | 高 |
| 233 | 道具是否可用 | bool | `bItemUseEnable` | 高 |
| 236 | 伤害等级 | `DAMAGE_LEVEL_*` | `DamageLevel` | 高 |
| 237 | 防御/架势伤害量 | int，常用 `> 0` | `GuardDamageAmount` | 中 |
| 248 | 落地 ready / ground ready | bool | `bLandReady` | 高 |
| 256 | HP auto-charge 相关状态 | bool | `bHpAutoChargeActive` | 中 |
| 273 | 投技动画 ID | int | `ThrowAnimationId` | 高 |
| 274 | 投技处决请求 | bool | `bThrowKillRequested` | 高 |
| 276 | 投技死亡请求 | bool | `bThrowDeathRequested` | 高 |
| 277 | 投技逃脱请求 | bool | `bThrowEscapeRequested` | 高 |
| 285 | 伤害属性 | `DAMAGE_ELEMENT_*` | `DamageElement` | 高 |
| 333 | 帧间隔 | ms | `LastDeltaTimeMilliseconds` | 高 |
| 334 | 行为识别值检查 | `BEHAVIOR_IDENTIFICATION_VALUE_*` -> bool | `BehaviorIdentificationFlags` | 高 |
| 337 | 投技/抓取 active | bool | `bThrowActive` | 中 |
| 339 | 投技/事件侧别完成 flag | `0/1` -> bool | `ThrowFinishedBySide` | 中 |
| 345 | 右手特殊攻击类型 | `HAND_RIGHT` -> `SP_ATK_TYPE_*` | `SpecialAttackTypeRight` | 高 |
| 349 | damage break 额外 gate，疑似附魔/弹反抑制 | bool | `bDamageBreakSuppressedByEnchant` | 低 |
| 1000 | 当前 HP | int | `CurrentHp` | 高 |
| 1007 | HP auto-charge 例外/阻止 | bool | `bHpAutoChargeBlocked` | 中 |
| 1105 | 是否 standby | bool | `bIsStandby` | 高 |
| 1106 | 动作输入是否触发 | `ACTION_ARM_*` -> bool | `ActionPressed` | 高 |
| 1108 | 动作输入保持/缓冲量 | `ACTION_ARM_*` -> number | `ActionHoldMilliseconds` | 高 |
| 1112 | 伤害反应 gate，疑似霸体/无硬直 | bool | `bDamageAnimationGateActive` | 中 |
| 1116 | 真实 SpEffect ID 是否激活 | SpEffect ID -> bool | `ActiveSpEffects` | 高 |
| 1118 | 锁定/自动瞄准目标有效 | bool | `bAutoAimTargetValid` | 中 |
| 1119 | 攻击来源方向 | int | `AttackDirection` | 高 |
| 1121 | 伤害方向符号，负值翻转左右 | float | `DamageDirectionSign` | 高 |
| 2000 | 是否 moveable | bool | `bIsMoveable` | 高 |
| 2004 | 踢敌跳/命中跳可触发 | bool | `bEnemyJumpAvailable` | 高 |
| 3000 | 钩绳目标可用/射程内 | bool | `bWireTargetAvailable` | 中 |
| 3003 | 垂直速度/下落速度 | float | `FallVerticalSpeed` | 高 |
| 3008 | 特殊移动/控制抑制 flag | bool | `bSpecialMoveStyleActive` | 低 |
| 3011 | docking 目标边缘尽头类型 | `DOCKING_TGT_END_TYPE_*` | `DockingTargetEndType` | 高 |
| 3017 | cover/hang 边缘类型 | `COVER_EDGE_TYPE_*` 或 `HANG_EDGE_TYPE_*` | `EdgeType` | 高 |
| 3018 | easy deflect 反应方向/类型 | `DEFLECTED_REACTION_TYPE_*` | `EasyDeflectedReactionType` | 高 |
| 3019 | hard deflect 反应方向/类型 | `DEFLECTED_REACTION_TYPE_*` | `HardDeflectedReactionType` | 高 |
| 3020 | 墙跳条件可用 | bool | `bWallJumpAvailable` | 高 |
| 3025 | 水面/水中接触 | bool | `bWaterContact` | 高 |
| 3027 | 切换后的副武器类别 | `HAND_LEFT` -> `WEP_MOTION_CATEGORY_*` | `NextWeaponMotionCategoryByHand` | 高 |
| 3028 | 回生/复活请求 | bool | `bRevivalRequested` | 高 |
| 3029 | docking break 请求 | bool | `bDockingBreakRequested` | 高 |
| 3031 | 投技/落地 reset 抑制 gate | bool | `bNoLandOrThrowReset` | 低 |
| 3032 | 前后向受击方向 | `SELECTOR_DAMAGE_DIR_*` | `DamageAngleFrontBack` | 高 |
| 3033 | 动作解锁检查 | `ACTION_UNLOCK_TYPE_*` -> bool | `ActionUnlocked` | 高 |
| 3035 | 当前动作是否可用 | `ACTION_ARM_*` -> bool | `ActionEnabled` | 高 |
| 3036 | BehaviorRef/TAE flag 是否激活 | `SP_EF_REF_*` 或裸 `behaviorRefId` -> bool | `ActiveBehaviorRefs` | 高 |
| 3037 | 允许站立/非强制蹲伏 | bool | `bAllowStandEnter` | 中 |
| 3038 | 游泳转潜水可用 | bool | `bCanSwimToDive` | 高 |
| 3039 | 潜水转游泳/上浮可用 | bool | `bCanDiveToSwim` | 高 |
| 3040 | 地图可见度/暗度类型 | `MAP_VISIBILITY_TYPE_*` | `MapVisibilityType` | 高 |
| 3043 | cover 开始可用 | bool | `bCanStartCover` | 高 |
| 3044 | 地面挂边开始可用 | bool | `bCanStartGroundHang` | 高 |
| 3045 | 空中挂边类型 | `AIR_HANG_TYPE_*` | `AirHangType` | 高 |
| 3046 | 指定 docking 目标边缘类型 | `DOCKING_TGT_EDGE_TYPE_*` -> edge type | `DockingTargetEdgeTypeByRequest` | 高 |
| 3048 | hang 外角左转可用 | bool | `bHangOuterCornerLeftAvailable` | 高 |
| 3049 | hang 外角右转可用 | bool | `bHangOuterCornerRightAvailable` | 高 |
| 3050 | hang 爬上/回到站立可用 | bool | `bHangClimbAvailable` | 高 |
| 3051 | docking/corner 左侧阻挡或尽头 | bool | `bDockingLeftBlocked` | 中 |
| 3052 | docking/corner 右侧阻挡或尽头 | bool | `bDockingRightBlocked` | 中 |
| 3053 | talk param ref id | `TALK_PARAM_REF_RCV_*` | `TalkParamRefId` | 高 |
| 3054 | EZ state ref id | `EZ_STATE_REF_RCV_*` | `EzStateRefId` | 高 |
| 3055 | 地图加载初始姿势 | `LOAD_INIT_POSE_*` | `LoadInitPose` | 高 |
| 3056 | easy/normal deflect 攻击方向 | `DEFLECT_DIR_*` | `EasyDeflectAttackDirection` | 高 |
| 3057 | hard/just deflect 攻击方向 | `DEFLECT_DIR_*` | `HardDeflectAttackDirection` | 高 |
| 3058 | AddBlendSpeak 状态 | `ADD_BLEND_SPEAK_*` | `AddBlendSpeakState` | 高 |
| 3059 | hang 内角左转可用 | bool | `bHangInsideCornerLeftAvailable` | 高 |
| 3060 | hang 内角右转可用 | bool | `bHangInsideCornerRightAvailable` | 高 |
| 3061 | safe position return 类型 | `SAFE_POS_RETURN_TYPE_*` | `SafePosReturnType` | 高 |
| 3063 | TAE/动画起播时间 | `0/1/2` -> ms | `StartTimeMillisecondsBySlot` | 高 |
| 字符串 key | 严格按 BehaviorRef 检查寿命延长/AGING | `SP_EF_REF_AGING` -> bool | `EnvNamedBool` + `ActiveBehaviorRefs` | 高 |

## 重要子键族

### ACTION_ARM

用于 `env(1106, ACTION_ARM_*)`、`env(1108, ACTION_ARM_*)`、`env(3035, ACTION_ARM_*)`。

| 值 | 常量 | 说明 |
|---:|---|---|
| 0 | `ACTION_ARM_ATTACK` | 普攻 |
| 1 | `ACTION_ARM_SUB_ATTACK` | 副武器/义手攻击 |
| 2 | `ACTION_ARM_GUARD` | 防御 |
| 3 | `ACTION_ARM_WIRE_SHOOT` | 钩绳 |
| 4 | `ACTION_ARM_JUMP` | 跳跃 |
| 5 | `ACTION_ARM_SP_MOVE` | 特殊移动/冲刺 |
| 7 | `ACTION_ARM_USE_ITEM` | 使用道具 |
| 10 | `ACTION_ARM_CHANGE_WEAPON_L` | 左手武器切换 |
| 12 | `ACTION_ARM_WALL_HANG` | 扒墙/挂边 |
| 13 | `ACTION_ARM_BACKSTEP` | 后撤 |
| 14 | `ACTION_ARM_ROLLING` | 翻滚 |
| 15 | `ACTION_ARM_CROUCH` | 蹲伏 |
| 18 | `ACTION_ARM_SHINOBI_WEP_ACTION` | 忍具动作 |
| 28 | `ACTION_ARM_SWIM_ACCELERATION` | 游泳加速 |
| 29 | `ACTION_ARM_SWIM_UP` | 上浮 |
| 30 | `ACTION_ARM_SWIM_DOWN` | 下潜 |
| 31 | `ACTION_ARM_EAVESDROP` | 窃听 |
| 32 | `ACTION_ARM_SPECIAL_ATTACK` | 战技/特殊攻击 |

### ACTION_UNLOCK_TYPE

用于 `env(3033, ACTION_UNLOCK_TYPE_*)`。

| 值 | 常量 |
|---:|---|
| 0 | `ACTION_UNLOCK_TYPE_DIVE` |
| 1 | `ACTION_UNLOCK_TYPE_NIGHTVISION` |
| 4 | `ACTION_UNLOCK_TYPE_SUB_WEAPONE` |
| 5 | `ACTION_UNLOCK_TYPE_MAIN_WEAPONE` |
| 14 | `ACTION_UNLOCK_TYPE_WIRE_MOVE_ATTACK` |
| 15 | `ACTION_UNLOCK_TYPE_AIR_DEFLECT_GUARD` |
| 16 | `ACTION_UNLOCK_TYPE_AIR_SUB_ATTACK` |
| 19 | `ACTION_UNLOCK_TYPE_R_ATTACK_RELEASE` |
| 20 | `ACTION_UNLOCK_TYPE_SUB_ATTACK_DIRAVE_ATTACK_1` |
| 21 | `ACTION_UNLOCK_TYPE_SUB_ATTACK_SHOT_ATTACK` |
| 22 | `ACTION_UNLOCK_TYPE_SUB_ATTACK_DIRAVE_ATTACK_2` |
| 23 | `ACTION_UNLOCK_TYPE_SUB_ATTACK_ENCHANT` |
| 24 | `ACTION_UNLOCK_TYPE_AIR_ATTACK` |
| 25 | `ACTION_UNLOCK_TYPE_AIR_SP_ATTACK` |
| 26 | `ACTION_UNLOCK_TYPE_SPRINT_TO_CROUCH` |

### 伤害相关常量

`env(202)` 返回 `DAMAGE_TYPE_*`，`env(236)` 返回 `DAMAGE_LEVEL_*`，`env(285)` 返回 `DAMAGE_ELEMENT_*`。

常见 `DAMAGE_TYPE_*`：

| 值 | 常量 |
|---:|---|
| 2 | `DAMAGE_TYPE_DEATH` |
| 3 | `DAMAGE_TYPE_GUARD` |
| 5 | `DAMAGE_TYPE_PARRY` |
| 6 | `DAMAGE_TYPE_DEATH_FALLING` |
| 7 | `DAMAGE_TYPE_DEATH_RECOVER` |
| 10 | `DAMAGE_TYPE_WEAK_POINT` |
| 14 | `DAMAGE_TYPE_FALL_DEAD_RETURN` |
| 15 | `DAMAGE_TYPE_LAND_DEAD_RETURN` |
| 16 | `DAMAGE_TYPE_LAND_DEAD` |
| 17 | `DAMAGE_TYPE_FORCE_DEATH` |
| 1000 | `DAMAGE_TYPE_GUARDED` |
| 1001 | `DAMAGE_TYPE_GUARDBREAK` |
| 1002 | `DAMAGE_TYPE_BACK` |
| 1004 | `DAMAGE_TYPE_GUARDBREAK_BLAST` |
| 1005 | `DAMAGE_TYPE_GUARDBREAK_FLING` |
| 1027 | `DAMAGE_TYPE_DAMAGEBREAK` |
| 1028 | `DAMAGE_TYPE_GUARDATTACKER_STAMZERO` |

`DAMAGE_LEVEL_*`：`NONE=0`、`SMALL=1`、`MIDDLE=2`、`LARGE=3`、`EXLARGE=4`、`PUSH=5`、`FLING=6`、`SMALL_BLOW=7`、`MINIMUM=8`、`UPPER=9`、`EX_BLAST=10`、`BREATH=11`。

`DAMAGE_ELEMENT_*`：`DEFAULT=0`、`NONE=1`、`FIRE=2`、`LIGHTNING=6`、`BLUE_LIGHTNING=10`。

### 地形、挂边、事件常量

| 族 | 值 |
|---|---|
| `MAP_VISIBILITY_TYPE_*` | `GOOD=0`、`DARK=1`、`PICHDARK=2` |
| `COVER_EDGE_TYPE_*` | `DISABLE_LOOK=0`、`FREE_LOOK=1`、`LEFT_LOOK_ONLY=2`、`RIGHT_LOOK_ONLY=3`、`PEAK_MOVE_DISABLE_LOOK=10`、`PEAK_MOVE_FREE_LOOK=11`、`PEAK_MOVE_LEFT_LOOK_ONLY=12`、`PEAK_MOVE_RIGHT_LOOK_ONLY=13` |
| `HANG_EDGE_TYPE_*` | `DISABLE_HOLD_FOOT=0`、`ENABLE_HOLD_FOOT=1` |
| `AIR_HANG_TYPE_*` | `DISABLE=0`、`SHORT_LANGE=1`、`LONG_LANGE=2` |
| `DOCKING_TGT_END_TYPE_*` | `NONE=0`、`LEFT=1`、`RIGHT=2` |
| `LOAD_INIT_POSE_*` | `NONE=-1`、`STAND=0`、`CROUCH=1`、`SWIM=2`、`DIVE=3` |
| `SAFE_POS_RETURN_TYPE_*` | `NONE=-1`、`STAND=0`、`CROUCH=1`、`SWIM=2`、`DIVE=3` |
| `ADD_BLEND_SPEAK_*` | `NONE=0`、`PLAY=1` |

### SP_EF_REF / behaviorRefId

`env(3036, X)` 是最重要的二级查询。脚本通常传 `SP_EF_REF_*`，但本质上更像按 `behaviorRefId` 查询当前是否激活。因此 UE 组件没有把所有子键硬编码成 C++ 枚举，而是用 `ActiveBehaviorRefs` 这个 `TMap<int32, bool>` 承接任意 `behaviorRefId`。

常见分段：

| 范围 | 用途 |
|---|---|
| `1..22` | 冲刺、锁定角、fall protect、state-to-state blend |
| `90..111` | 移动/停止状态、空中挂边、风暴跳、落地动画 gate |
| `200..235` | 攻击、防御、弹反、战技取消与派生 |
| `280..289` | 右手战技解锁与特殊战技派生 |
| `300..334` | 义手/副武器、机关斧、变若、派生攻击 |
| `400..432` | AddActionInput 追加输入窗口与取消窗口 |
| `500..515` | 毒、倒地死亡、受击取消、电、火、回生 |
| `590..606` | 老化、雷、非战斗区、禁用输入/道具 |
| `700..797` | 游泳/潜水动作 flag |
| `110000..110005` | 强制蹲伏、沼泽、风暴跳区域、水边区域 |

两个裸数值也在脚本中出现：

- `env(3036, 607)`：脚本中使用但 `c0000_define.dec.lua` 没有符号名，暂按未知 behaviorRefId 处理。
- `env(3036, 900)`：用于防御伤害等级覆盖判断，暂保留为裸 behaviorRefId。

## UE C++ 使用方式

组件会自动挂在 `ASekiroC0000PreviewCharacter`：

```cpp
USekiroEnvQueryComponent* Env = PreviewCharacter->GetSekiroEnvQuery();
const bool bAttackPressed = Env->EnvBool(1106, 0);      // ACTION_ARM_ATTACK
const bool bCanUseItem = Env->EnvBool(233);
const int32 DamageType = Env->EnvInt(202);
const float StartTime = Env->EnvFloat(3063, 0) / 1000.0f;
```

设置运行时值：

```cpp
Env->SetActionPressed(0, true);      // ACTION_ARM_ATTACK
Env->SetActionUnlocked(4, true);     // ACTION_UNLOCK_TYPE_SUB_WEAPONE
Env->SetBehaviorRefActive(203, true); // SP_EF_REF_TAE_ENABLE_JUST_DEFLECT
Env->SetSpEffectActive(100130, true);
Env->SetStartTimeMilliseconds(0, 120.0f);
```

蓝图/UnLua 侧可以直接调用同名函数。字符串 key 的老化严格查询可用：

```cpp
Env->EnvNamedBool(TEXT("StrictBehaviorRefLifeExtension"), 591);
```

也支持原始日文 key 的 `_Behavior` 片段匹配，因此从 Lua 侧传原始 query name 时也能命中。

## 当前已接入的动态驱动

当前工程先接入了最小 WASD 输入链路：

- `ASekiroC0000PreviewCharacter` 原生读取 `W/A/S/D` 和 `LeftShift`。
- Lua 侧仍通过 `GetPreviewForwardIntent()`、`GetPreviewRightIntent()`、`IsPreviewSprintHeld()` 驱动预览移动。
- C++ 侧每帧调用 `USekiroEnvQueryComponent::SetMovementInputIntent()`，把同一份输入写入 env 状态。

已经会随 WASD/Shift 变化的 env 值：

| env | 当前驱动 |
|---|---|
| `env(1105)` | 没有移动输入时为 standby |
| `env(2000)` | 有 WASD 移动输入时为 moveable |
| `env(1106, ACTION_ARM_SP_MOVE)` | `LeftShift` 按下时为 true |
| `env(1108, ACTION_ARM_SP_MOVE)` | `LeftShift` 保持时间，单位 ms |
| `env(333)` | 组件 tick 的 delta time，单位 ms |

组件还额外暴露 `MoveInputForward`、`MoveInputRight`、`MoveInputStrength`、`bSprintHeld` 供蓝图或调试查看。Sekiro 原脚本没有单独的 `env(id)` 表示 WASD 方向，移动方向主要通过 HKB/动画变量如 `MoveSpeedLevel`、`MoveAngle`、`MoveDirection` 表达。

## 设计取舍

1. `env` 被建模成只读查询组件，而不是行为执行器。它不直接 FireEvent，也不直接驱动 AnimBP。
2. 运行时字段全部开放为 `EditAnywhere/BlueprintReadWrite`，便于调试、蓝图测试和 UnLua 填值。
3. 3036 子键不硬编码成巨大 enum，因为 `behaviorRefId` 可能来自 TAE/SpEffectParam，未来还会扩展。
4. 低置信 ID 仍保留为可查询字段，但字段名带有 gate/suppressed/available 语义，后续可根据 native 反编译继续改名。

## 仍需 native 确认的 ID

以下 ID 从脚本用途能推断 gate，但 native 字段名仍不确定：

- `113`：道具使用固定/特殊分支。
- `205` / `1112`：伤害反应 gate，可能涉及霸体、无硬直或 damage anim suppress。
- `206`：伤害/死亡/docking break 抑制。
- `3008`：特殊移动/调试移动/普通控制抑制。
- `3031`：投技/落地 reset 抑制。
- `349`：damage break 与附魔/弹反相关 gate。

这些最好继续从 `sekiro.exe` 的 `env` native callback 里反编译确认。
