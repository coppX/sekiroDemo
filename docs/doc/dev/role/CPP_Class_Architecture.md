# C++ 类结构设计：c0000（玩家）与 c1010（敌人）

> 基于 Lua 脚本反编译结果，推断 UE5 C++ 层的类结构设计
> 
> 分析日期：2026-05-12

## 目录

1. [核心发现](#核心发现)
2. [类层次结构](#类层次结构)
3. [枚举定义](#枚举定义)
4. [组件设计](#组件设计)
5. [API 绑定层](#api-绑定层)
6. [设计差异对比](#设计差异对比)
7. [实现建议](#实现建议)

---

## 核心发现

### c0000（玩家）的脚本特征

从 `action/script/c0000.dec.lua` 的 `Initialize()` 函数中，发现了 17 个全局运行时变量：

```lua
-- 动作计数器
g_wallJumpCount = 0
g_airSubAttackCount = 0
g_airSpecialAttackCount = 0

-- 状态标志
g_isUpperAction = FALSE
g_AddElectroCharge = FALSE
g_EndSubWeaponChange = FALSE
g_enableTransitSprint = FALSE
g_forceCrouch = FALSE
g_enableSpAttaclkJump = TRUE
g_autoAimFlag = FALSE

-- 历史记录（用于动画变化检测）
g_beforeMoveSpeedIndex = 0
g_beforeMoveDirection = 0
g_beforeFireLand = -1
g_beforeSubAttackType = 0
g_beforeSpAttackNum = 0
g_beforeItemAnmType = 0

-- 自动瞄准
g_autoAimTime = 1
```

**关键特征**：
- 四文件结构：`c0000.dec.lua`（主调度）、`c0000_transition.dec.lua`（转换规则引擎）、`c0000_define.dec.lua`（常量）、`c0000_cmsg.dec.lua`（消息处理）
- 复杂的行为验证系统：`g_behaviorValidateOrder`（优先级表）、`g_ValidateReactionTable`/`g_ValidateActionTable`（规则表）
- 每帧执行流程：`Update() → UpdateState() → Validate() → _ActivateBehavior()`

### c1010（敌人）的脚本特征

c1010 使用完全不同的架构（参见 `action/script/c1010.dec.lua`）：

```lua
-- 仅顶部三个对话引用常量
TALK_REF_C1010_SUICIDE_ASSISTANT = 1101000
TALK_REF_C1010_TALK_START = 1101001
TALK_REF_C1010_DEATH_START = 1101002

-- 每个状态对应一个 Event*_onUpdate() 函数
function Event20001_onUpdate()
    SetThrowFlag(STATE_NORMAL)
    if EventCommonFunction(20001) == TRUE then
        return
    end
    if env(339, 1) == TRUE then
        Fire("W_Idle")
        return
    end
end
```

**关键特征**：
- **单文件结构**：仅有 `c1010.dec.lua`，无 `_transition`、`_define`、`_cmsg`
- **简单事件驱动**：每个状态独立的 `EventNNNNN_onUpdate()` 函数
- **无优先级验证**：直接 `Fire("StateName")` 触发转换
- **共享 AI 逻辑**：依赖 `EventCommonFunction()` 和 `script/aicommon-luabnd-dcx/` 通用脚本
- **极少的运行时状态**：主要是投技标志（`SetThrowFlag`）

---

## 类层次结构

### 1. 顶层抽象基类 `ACharacterBase`

所有角色（玩家与敌人）共享的基础设施。

```cpp
class ACharacterBase : public ACharacter
{
protected:
    // ========== Havok 行为系统接口 ==========
    UPROPERTY()
    UHavokBehaviorComponent* HavokBehavior;
    
    // ========== 当前状态追踪 ==========
    UPROPERTY(BlueprintReadOnly)
    int32 CurrentHkbState;
    
    UPROPERTY(BlueprintReadOnly)
    EStyleType CurrentStyleType;   // STAND, CROUCH, GUARD, ...
    
    UPROPERTY(BlueprintReadOnly)
    EStateType CurrentStateType;   // STANDBY, ACTION, REACTION, ...
    
    // ========== 引擎查询/动作 API（对应 Lua 的 env/act）==========
    virtual bool Env(int32 ID, int32 Param = 0) const;
    virtual void Act(int32 ID, const TArray<FVariant>& Params);
    
    // ========== Havok 事件系统 ==========
    virtual void FireEvent(FName EventName, bool bResetState = true);
    virtual bool IsNodeActive(FName NodeName) const;
    
    // ========== Havok 变量访问 ==========
    virtual float GetHkbVariable(FName VarName) const;
    virtual void SetHkbVariable(FName VarName, float Value);
    
    // ========== 帧循环钩子 ==========
    virtual void UpdateBehavior(float DeltaTime);
    virtual void InitializeState();
};
```

### 2. 玩家特化基类 `APlayerCharacter`（c0000）

实现复杂的行为验证优先级系统。

```cpp
class APlayerCharacter : public ACharacterBase
{
protected:
    // ========== 运行时状态变量（对应 Lua 全局变量）==========
    
    // --- 动作计数器 ---
    UPROPERTY() int32 WallJumpCount;             // g_wallJumpCount
    UPROPERTY() int32 AirSubAttackCount;         // g_airSubAttackCount
    UPROPERTY() int32 AirSpecialAttackCount;     // g_airSpecialAttackCount
    
    // --- 状态标志 ---
    UPROPERTY() bool bIsUpperAction;             // g_isUpperAction
    UPROPERTY() bool bAddElectroCharge;          // g_AddElectroCharge
    UPROPERTY() bool bEndSubWeaponChange;        // g_EndSubWeaponChange
    UPROPERTY() bool bEnableTransitSprint;       // g_enableTransitSprint
    UPROPERTY() bool bForceCrouch;               // g_forceCrouch
    UPROPERTY() bool bEnableSpAttackJump;        // g_enableSpAttaclkJump
    UPROPERTY() bool bAutoAimFlag;               // g_autoAimFlag
    
    // --- 历史记录（动画变化检测）---
    UPROPERTY() int32 BeforeMoveSpeedIndex;      // g_beforeMoveSpeedIndex
    UPROPERTY() int32 BeforeMoveDirection;       // g_beforeMoveDirection
    UPROPERTY() int32 BeforeFireLand;            // g_beforeFireLand
    UPROPERTY() int32 BeforeSubAttackType;       // g_beforeSubAttackType
    UPROPERTY() int32 BeforeSpAttackNum;         // g_beforeSpAttackNum
    UPROPERTY() int32 BeforeItemAnmType;         // g_beforeItemAnmType
    
    // --- 自动瞄准系统 ---
    UPROPERTY() float AutoAimTime;               // g_autoAimTime
    
    UPROPERTY() int32 FrameCount;                // g_FrameCount
};
```

#### 行为验证系统（对应 `c0000_transition.dec.lua`）

```cpp
class APlayerCharacter : public ACharacterBase
{
protected:
    // ========== 行为优先级表（运行时构建）==========
    // 对应 g_behaviorValidateOrder
    TArray<EBehaviorID> BehaviorValidateOrder;
    
    // 对应 g_behaviorValidateOrderByStyle（按姿态分类）
    TMap<EStyleType, TArray<EBehaviorID>> BehaviorValidateOrderByStyle;
    TMap<EStyleType, TArray<EBehaviorID>> AddBehaviorActionValidateOrderByStyle;
    TMap<EStyleType, TArray<EBehaviorID>> AddBehaviorReactionValidateOrderByStyle;
    
    // ========== 验证规则表（函数指针映射）==========
    // 对应 g_ValidateReactionTable
    TMap<EBehaviorID, TFunction<bool(int32 CurrentHkbState)>> ValidateReactionTable;
    
    // 对应 g_ValidateActionTable
    TMap<EBehaviorID, TFunction<bool(int32 CurrentHkbState)>> ValidateActionTable;
    
    // 对应 g_ValidateAddReactionTable / g_ValidateAddActionTable
    TMap<EBehaviorID, TFunction<bool(int32)>> ValidateAddReactionTable;
    TMap<EBehaviorID, TFunction<bool(int32)>> ValidateAddActionTable;
    
    // ========== 核心验证流程 ==========
    // 对应 Lua: Validate(current_hkb_state)
    virtual void ValidateBehaviors(int32 CurrentHkbState);
    
    // 对应 Lua: _ActivateBehavior(BEH_*)
    virtual bool ActivateBehavior(EBehaviorID BehaviorID);
    
    // 对应 Lua: _ActivateAddBehavior(BEH_ADD_*)
    virtual bool ActivateAddBehavior(EBehaviorID AddBehaviorID);
    
    // 对应 Lua: UpdateState(current_hkb_state)
    virtual void UpdateState(int32 CurrentHkbState) override;
    
    // 对应 Lua: SetMoveType()
    virtual void SetMoveType();
    
    // 对应 Lua: _LandReset(current_hkb_state)
    virtual void LandReset(int32 CurrentHkbState);
    
    // 对应 Lua: FireStateEndEvent(current_hkb_state)
    virtual void FireStateEndEvent(int32 CurrentHkbState);
    
public:
    // 对应 Lua: ValidateOrderTableInit()
    virtual void InitializeValidationTables();
};
```

### 3. 敌人特化基类 `AEnemyCharacter`（c1xxx / c5xxx）

简化的事件驱动状态机，无优先级验证系统。

```cpp
class AEnemyCharacter : public ACharacterBase
{
protected:
    // ========== AI 状态机（简化版）==========
    
    // 当前事件状态 ID（对应 statenameid.txt 中的编号）
    UPROPERTY() int32 CurrentEventID;
    
    // 投技状态（对应 Lua 的 SetThrowFlag 参数）
    UPROPERTY() EThrowState ThrowState;
    
    // 对话引用 ID 表（每个具体敌人特化）
    TArray<int32> TalkRefIDs;
    
    // ========== 简化的状态更新 ==========
    
    // 对应 Lua: EventNNNNN_onUpdate()
    // 通常分发到具体的事件处理函数
    virtual void UpdateEvent(int32 EventID, float DeltaTime);
    
    // 对应 Lua: EventCommonFunction(eventId)
    // 处理共用逻辑（AI 中断、强制返回待机等）
    virtual bool EventCommonFunction(int32 EventID);
    
    // 对应 Lua: Fire("StateName")
    // 简化的状态转换，无优先级检查
    virtual void TransitionToState(FName StateName);
    
    // 对应 Lua: SetThrowFlag(state)
    virtual void SetThrowFlag(EThrowState NewState);
    
    // 对应 Lua: FallPreventionAssist()
    virtual void FallPreventionAssist();
    
    // 对应 Lua: ExecTransToDeathIdle(deathType, flag)
    virtual bool ExecTransToDeathIdle(EDeathType DeathType, bool bFlag);
};
```

### 4. 具体角色实现示例

```cpp
// c0000 - 玩家"狼"
class AC0000_Wolf : public APlayerCharacter
{
    // 狼特有的扩展（如忍义手、咒术等）
};

// c1010 - 具体敌人
class AC1010_Enemy : public AEnemyCharacter
{
protected:
    // 对话 ID 常量（对应 Lua 文件顶部）
    static constexpr int32 TALK_REF_SUICIDE_ASSISTANT = 1101000;
    static constexpr int32 TALK_REF_TALK_START = 1101001;
    static constexpr int32 TALK_REF_DEATH_START = 1101002;
    
    // 重写事件分发
    virtual void UpdateEvent(int32 EventID, float DeltaTime) override;
};
```

---

## 枚举定义

### 姿态类型 `EStyleType`（对应 `STYLE_TYPE_*`）

```cpp
UENUM(BlueprintType)
enum class EStyleType : uint8
{
    Stand        = 1,
    Crouch       = 2,
    GroundGuard  = 3,
    Cover        = 4,
    CoverLook    = 5,
    Hang         = 6,
    FreeFall     = 7,
    WireFall     = 8,
    Sprint       = 9,
    Cling        = 10,
    Swim         = 11,
    Dive         = 12,
    AgingStand   = 13,
    AgingFall    = 14,
    AgingSwim    = 15,
    AgingDive    = 16
};
```

### 状态类型 `EStateType`（对应 `STATE_TYPE_*`）

```cpp
UENUM(BlueprintType)
enum class EStateType : uint8
{
    Standby              = 0,
    StandbyAtk           = 1,
    StandbyAtkHold       = 2,
    StandbyGuard         = 3,
    StandbySubGuard      = 4,
    Action               = 10,
    ActionAtk            = 11,
    ActionAtkHold        = 12,
    ActionGuard          = 13,
    ActionSubGuard       = 14,
    ActionThrowAtk       = 15,
    ActionThrowAtkKill   = 16,
    ActionItemUse        = 17,
    Reaction             = 20,
    ReactionAtk          = 21,
    ReactionAtkHold      = 23,
    ReactionGuard        = 24,
    ReactionSubGuard     = 25,
    ReactionThrowDef     = 26,
    ReactionThrowEscape  = 27,
    ReactionDeath        = 29,
    ReactionMapEnter     = 30,
    Event                = 90,
    UpperStandby         = 100,
    UpperAction          = 110,
    Lower                = 120
};
```

### 行为 ID `EBehaviorID`（对应 `BEH_*`）

```cpp
UENUM(BlueprintType)
enum class EBehaviorID : int32
{
    None = 0,
    
    // ===== 反应类（BEH_R_*）=====
    R_Death              = 1,
    R_HitDamage          = 11,
    R_GuardDamage        = 12,
    R_BreakDamage        = 13,
    R_SpecialDamage      = 14,
    R_AgingDamage        = 16,
    R_CureAging          = 17,
    R_Land               = 21,
    R_LandWire           = 22,
    R_LandReady          = 23,
    R_Fall               = 27,
    R_ThrowDeath         = 28,
    R_ThrowEscape        = 29,
    R_ThrowKill          = 30,
    R_LandWater          = 33,
    R_EnemyJump          = 38,
    
    // ===== 动作类（BEH_A_*）=====
    A_WallJump           = 101,
    A_AirSpAttack        = 102,
    A_AirAttack          = 103,
    A_Sprint             = 104,
    A_GroundJump         = 105,
    A_GroundWireShoot    = 107,
    A_AirWireShoot       = 108,
    A_BackGrab           = 109,
    A_GroundAttack       = 110,
    A_GroundSubAttack    = 112,
    A_AirSubAttack       = 113,
    A_CrouchStart        = 114,
    A_CrouchEnd          = 115,
    A_CoverStart         = 116,
    A_CoverEnd           = 117,
    A_GroundMoveStart    = 122,
    A_GroundMoveStop     = 123,
    A_DeflectGuardStart  = 124,
    A_ItemUse            = 150,
    A_SwimMoveStart      = 180,
    A_DiveMoveStart      = 185,
    A_GroundStep         = 194,
    
    // ===== 叠加类（BEH_ADD_*）=====
    ADD_SubWeaponExpand     = 10,
    ADD_NightvisionStart    = 20,
    ADD_NightvisionEnd      = 21,
    ADD_BareHandRightStart  = 25,
    ADD_R_HitDamage         = 30,
    ADD_R_GuardDamage       = 31,
    ADD_R_BreakDamage       = 32,
    ADD_R_SpecialDamage     = 33
};
```

### 投技状态 `EThrowState`（敌人专用）

```cpp
UENUM(BlueprintType)
enum class EThrowState : uint8
{
    Normal,
    Death,
    Escape
};
```

---

## 组件设计

### Havok 行为变量管理组件 `UHavokBehaviorComponent`

管理 503 个 Havok 变量（来自 `action/variablenameid.txt`）。

```cpp
UCLASS()
class UHavokBehaviorComponent : public UActorComponent
{
    GENERATED_BODY()
    
protected:
    // ========== 变量存储 ==========
    // 通用变量表（503 个变量）
    TMap<FName, float> Variables;
    
    // ========== 常用变量的快速访问（避免字符串查找）==========
    float MoveType;
    float StanceMoveType;
    float MoveSpeedLevelReal;
    float MoveSpeedIndex;
    float NightvisionMoveSpeedIndex;
    float DamageDirection;
    float DamageState;
    float DeathState;
    float BlendDamageDir;
    float BlendDamageFire;
    float AttackArrowLeftState;
    float AttackArrowRightState;
    // ... 更多常用变量
    
    // ========== 事件系统 ==========
    // 事件名称映射（4381 条，来自 eventnameid.txt）
    TMap<int32, FName> EventNameMap;
    
    // 状态节点映射（3225 条，来自 statenameid.txt）
    TMap<int32, FName> StateNameMap;
    
public:
    // ========== 变量访问接口 ==========
    UFUNCTION(BlueprintCallable)
    float GetVariable(FName VarName) const;
    
    UFUNCTION(BlueprintCallable)
    void SetVariable(FName VarName, float Value);
    
    // ========== 事件触发 ==========
    UFUNCTION(BlueprintCallable)
    void FireEvent(FName EventName, bool bResetState = true);
    
    UFUNCTION(BlueprintCallable)
    bool IsNodeActive(FName NodeName) const;
    
    // ========== 初始化 ==========
    virtual void InitializeComponent() override;
    
    // 从数据表加载映射
    void LoadEventNameMapping(const FString& FilePath);
    void LoadStateNameMapping(const FString& FilePath);
    void LoadVariableNameMapping(const FString& FilePath);
};
```

---

## API 绑定层

### `env()` API 实现（引擎状态查询）

完整的 env ID 列表参见 [doc/Lua env.md](../../Lua%20env.md)。

```cpp
bool ACharacterBase::Env(int32 ID, int32 Param) const
{
    switch (ID)
    {
    // ===== 输入查询 =====
    case 256:  return bIsInCombat;                  // 是否在战斗中
    case 339:  return IsAnimationFinished(Param);   // 动画是否结束（参数：帧数）
    
    // ===== 特殊效果查询 =====
    case 1007: return CheckSpecialState(Param);     // 是否在特定状态
    case 1116: return HasSpecialEffect(Param);      // 检查特效是否激活
    case 3036: return HasSpecialEffectRef(Param);   // 检查特效引用 ID
    case 3037: return CanStand();                   // 是否可以站立
    
    // ===== 加载/复活查询 =====
    case 3055: return GetLoadInitPoseType();        // 加载初始姿势类型
    case 3061: return GetSafePosReturnType();       // 安全位置返回类型
    
    // ... 更多 env ID
    default:
        UE_LOG(LogSekiro, Warning, TEXT("Unhandled env ID: %d"), ID);
        return false;
    }
}
```

### `act()` API 实现（引擎动作指令）

完整的 act ID 列表参见 [doc/Lua act.md](../../Lua%20act.md)。

```cpp
void ACharacterBase::Act(int32 ID, const TArray<FVariant>& Params)
{
    switch (ID)
    {
    case 101:  // 设置某个引擎标志
        SetEngineFlag(Params[0].GetValue<bool>());
        break;
    case 136:  // 重置某状态
        ResetSomeState(Params[0].GetValue<int32>());
        break;
    case 148:  // SetVariable 的底层实现
        SetHkbVariable(Params[0].GetValue<FName>(), 
                       Params[1].GetValue<float>());
        break;
    case 2002: // 激活/停用特效
        ToggleSpecialEffect(Params[0].GetValue<int32>());
        break;
    case 2015: // 设置某个参数
        SetEngineParameter(Params[0].GetValue<int32>(), 
                           Params[1].GetValue<int32>());
        break;
    case 3029: // 触发对话
        TriggerTalk(Params[0].GetValue<int32>());
        break;
    case 9101: // 重置请求
        ResetRequest();
        break;
    
    // ... 更多 act ID
    default:
        UE_LOG(LogSekiro, Warning, TEXT("Unhandled act ID: %d"), ID);
        break;
    }
}
```

---

## 设计差异对比

| 特性 | c0000（玩家） | c1010（敌人） |
|------|--------------|--------------|
| **脚本文件数** | 4 个（主、转换、定义、消息） | 1 个（主） |
| **状态验证** | 复杂优先级系统（`g_behaviorValidateOrder`） | 简单事件驱动（`Event*_onUpdate`） |
| **行为转换** | `Validate() → _ActivateBehavior()` | 直接 `Fire("StateName")` |
| **全局变量** | 17+ 个运行时状态变量 | 极少（主要依赖 AI 系统） |
| **C++ 成员变量** | 大量（计数器、标志、历史记录） | 极少（事件 ID、投技状态） |
| **继承深度** | `ACharacterBase → APlayerCharacter → AC0000_Wolf` | `ACharacterBase → AEnemyCharacter → AC1010_*` |
| **行为优先级表** | `g_behaviorValidateOrder` 按姿态分类 | 无 |
| **规则函数表** | `g_ValidateReactionTable` / `g_ValidateActionTable` | 无 |
| **复杂度** | 高（验证表、优先级、姿态过滤） | 低（直接状态机） |
| **依赖外部脚本** | 自包含 | 依赖 `aicommon-luabnd-dcx/` |

### 帧循环对比

**c0000 玩家帧循环**：
```
Update()
  ├─ SetMoveType()
  ├─ g_FrameCount++
  └─ UpdateState(current_hkb_state)
       ├─ Control(current_hkb_state)
       ├─ Validate(current_hkb_state)
       │    └─ for each behavior in g_behaviorValidateOrder:
       │         ├─ check rule in g_ValidateReactionTable / g_ValidateActionTable
       │         └─ _ActivateBehavior(BEH_*) → FireEvent(...)
       └─ FireStateEndEvent(current_hkb_state)
```

**c1010 敌人帧循环**：
```
EventNNNNN_onUpdate()  (每个状态独立函数)
  ├─ SetThrowFlag(STATE_NORMAL)
  ├─ EventCommonFunction(eventID)  // 共用 AI 中断逻辑
  └─ if (env(339, 1) == TRUE)      // 动画结束
       └─ Fire("W_Idle")            // 直接转换，无验证
```

---

## 实现建议

### 阶段 1：基础设施（1-2 周）

1. **实现 `ACharacterBase`**
   - Havok 事件系统绑定（`FireEvent`、`IsNodeActive`）
   - env/act API 框架（switch-case 分发）
   - 基础状态追踪（`CurrentHkbState`、`CurrentStyleType`、`CurrentStateType`）

2. **实现 `UHavokBehaviorComponent`**
   - 变量存储与访问（503 个变量）
   - 从 `variablenameid.txt`、`eventnameid.txt`、`statenameid.txt` 加载映射
   - 常用变量的快速访问缓存

3. **数据导入工具**
   - 编写 Python 脚本将 Lua 常量表导出为 UE DataTable
   - 将 `g_behaviorValidateOrder` 导出为 JSON/CSV
   - 将 `g_ValidateReactionTable` / `g_ValidateActionTable` 导出为配置文件

### 阶段 2：玩家系统（2-3 周）

4. **实现 `APlayerCharacter`**
   - 17 个运行时状态变量
   - `SetMoveType()`、`LandReset()` 等辅助函数
   - `UpdateState()` 帧循环

5. **行为验证系统**
   - `InitializeValidationTables()` 从数据表加载规则
   - `ValidateBehaviors()` 优先级遍历
   - `ActivateBehavior()` / `ActivateAddBehavior()` 触发逻辑

6. **规则表实现方式选择**
   - **方案 A（推荐）**：C++ Lambda 表达式 + 数据驱动配置
     ```cpp
     ValidateReactionTable[EBehaviorID::R_Death] = [this](int32 State) {
         return Env(/* 死亡条件 ID */);
     };
     ```
   - **方案 B**：蓝图函数库 + DataTable（更灵活，但性能略低）
   - **方案 C**：直接翻译 Lua 代码为 C++（最快，但难维护）

### 阶段 3：敌人系统（1 周）

7. **实现 `AEnemyCharacter`**
   - 简化的事件驱动状态机
   - `EventCommonFunction()` 共用逻辑
   - `SetThrowFlag()`、`FallPreventionAssist()` 等辅助函数

8. **具体敌人子类**
   - 为每个 c1xxx 创建子类（如 `AC1010_Enemy`）
   - 重写 `UpdateEvent()` 分发到具体事件处理函数
   - 定义对话 ID 常量

### 阶段 4：测试与优化（1-2 周）

9. **单元测试**
   - 测试 env/act API 覆盖率
   - 验证行为优先级表正确性
   - 测试状态转换逻辑

10. **性能优化**
    - 缓存频繁访问的 Havok 变量
    - 优化 `ValidateBehaviors()` 的遍历（提前退出）
    - 使用 `TMap::FindRef()` 避免重复查找

11. **调试工具**
    - 可视化当前状态、姿态、行为 ID
    - 记录状态转换历史（用于回放分析）
    - 实时显示 Havok 变量值

### 关键技术决策

#### 1. 规则表的存储方式

| 方案 | 优点 | 缺点 | 推荐场景 |
|------|------|------|----------|
| **C++ Lambda** | 性能最高，类型安全 | 修改需重新编译 | 核心玩家逻辑 |
| **蓝图函数** | 热更新，设计师友好 | 性能略低，调试困难 | 敌人 AI、实验性功能 |
| **脚本虚拟机** | 完全保留 Lua 逻辑 | 需集成 Lua VM，复杂度高 | 如果需要 100% 还原 |

**推荐**：玩家用 C++ Lambda，敌人用蓝图函数。

#### 2. Havok 行为树的替代方案

原始游戏使用 Havok Behavior，UE5 可选：

| 方案 | 说明 | 工作量 |
|------|------|--------|
| **UE5 State Tree** | 原生支持，性能好 | 需重新设计状态机 |
| **Behavior Tree** | 适合 AI，不适合玩家 | 架构不匹配 |
| **Animation Blueprint** | 适合动画驱动逻辑 | 需与 C++ 深度集成 |
| **自定义状态机** | 完全控制 | 需实现事件系统、变量系统 |

**推荐**：使用 **UE5 State Tree** + 自定义 `UHavokBehaviorComponent` 作为桥接层。

#### 3. env/act API 的实现策略

```cpp
// 方案 A：硬编码 switch-case（性能最高）
bool ACharacterBase::Env(int32 ID, int32 Param) const
{
    switch (ID) { /* ... */ }
}

// 方案 B：函数指针表（更灵活）
TMap<int32, TFunction<bool(int32)>> EnvFunctionTable;

// 方案 C：反射系统（最灵活，但性能低）
UFUNCTION(BlueprintCallable, meta=(EnvID=256))
bool Env_IsInCombat() const;
```

**推荐**：方案 A（switch-case）用于核心 API，方案 B（函数表）用于扩展 API。

---

## 附录：关键文件映射

| Lua 文件 | C++ 类 | 说明 |
|----------|--------|------|
| `c0000.dec.lua` | `APlayerCharacter::UpdateBehavior()` | 主帧循环 |
| `c0000_transition.dec.lua` | `APlayerCharacter::ValidateBehaviors()` | 验证系统 |
| `c0000_define.dec.lua` | `EStyleType`, `EStateType`, `EBehaviorID` | 枚举常量 |
| `c0000_cmsg.dec.lua` | `APlayerCharacter::HandleCombatMessage()` | 战斗消息 |
| `c1010.dec.lua` | `AC1010_Enemy::UpdateEvent()` | 敌人事件循环 |
| `variablenameid.txt` | `UHavokBehaviorComponent::Variables` | 变量映射 |
| `eventnameid.txt` | `UHavokBehaviorComponent::EventNameMap` | 事件映射 |
| `statenameid.txt` | `UHavokBehaviorComponent::StateNameMap` | 状态映射 |

---

## 总结

**核心设计原则**：
1. **分层清晰**：基类（共享）→ 玩家类（复杂验证）→ 敌人类（简单事件）
2. **数据驱动**：优先级表、规则表从配置文件加载，避免硬编码
3. **性能优先**：玩家逻辑用 C++，敌人逻辑可用蓝图
4. **可维护性**：保留 Lua 原始逻辑的语义，便于对照调试

**预估工作量**：
- 基础设施：1-2 周
- 玩家系统：2-3 周
- 敌人系统：1 周
- 测试优化：1-2 周
- **总计**：5-8 周（单人全职）

**风险点**：
- Havok Behavior 的完整语义可能无法 100% 还原
- env/act API 的部分 ID 功能未知（需逆向引擎）
- 规则表的复杂条件可能需要多次迭代调试











