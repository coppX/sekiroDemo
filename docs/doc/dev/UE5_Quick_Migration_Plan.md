# UE5.7 只狼动画系统快速移植方案

## 目标

**快速移植**，避免复杂系统，直接利用解包的资产和逻辑：
- ❌ 不用 StateTree（不熟悉）
- ❌ 不用 GAS（不熟悉）
- ✅ 用 C++ + Blueprint + Animation Blueprint
- ✅ 直接翻译 Lua 逻辑到 C++
- ✅ 利用现有的动画资产和数据

## 核心思路

**最小改动，最快上手**：
1. 用 C++ 类直接翻译 Lua 脚本结构
2. 用 Data Table 存储配置数据
3. 用 Animation Blueprint 状态机播放动画
4. 用 Anim Notifies 处理时序事件

---

## 整体架构（简化版）

```
┌─────────────────────────────────────────────────┐
│ 输入层                                           │
│ - Enhanced Input（玩家）                         │
│ - AIController + Behavior Tree（敌人）           │
└─────────────────┬───────────────────────────────┘
                  ↓
┌─────────────────────────────────────────────────┐
│ 行为选择层（C++ Component）                      │
│ - UPlayerBehaviorComponent（翻译 c0000）         │
│ - UEnemyBehaviorComponent（翻译 c1010）          │
│ - 直接移植 Validate() 逻辑                       │
└─────────────────┬───────────────────────────────┘
                  ↓
┌─────────────────────────────────────────────────┐
│ 动画播放层                                       │
│ - Animation Blueprint State Machine              │
│ - Montage 播放                                   │
└─────────────────┬───────────────────────────────┘
                  ↓
┌─────────────────────────────────────────────────┐
│ 事件层                                           │
│ - Anim Notifies（攻击判定、取消窗口等）          │
└─────────────────────────────────────────────────┘
```

---

## 第一步：核心数据结构（C++）

### 1. 行为枚举（翻译 BEH_*）

```cpp
// SekiroTypes.h
UENUM(BlueprintType)
enum class EBehaviorId : uint8
{
    BEH_NONE = 0,
    
    // 反应类（BEH_R_*）
    BEH_R_DEATH = 1,
    BEH_R_HIT_DAMAGE = 2,
    BEH_R_GUARD_DAMAGE = 3,
    BEH_R_FALL = 4,
    BEH_R_LAND = 5,
    
    // 动作类（BEH_A_*）
    BEH_A_GROUND_MOVE_START = 100,
    BEH_A_GROUND_MOVE_STOP = 101,
    BEH_A_GROUND_ATTACK = 102,
    BEH_A_GROUND_JUMP = 103,
    BEH_A_DEFLECT_GUARD_START = 104,
    
    // ... 根据需要添加更多
};

UENUM(BlueprintType)
enum class EStyleType : uint8
{
    STYLE_TYPE_STAND = 0,
    STYLE_TYPE_CROUCH = 1,
    STYLE_TYPE_GROUND_GUARD = 2,
    STYLE_TYPE_FREE_FALL = 3,
    STYLE_TYPE_SWIM = 4,
    // ... 共 16 种
};
```

### 2. 行为验证函数签名

```cpp
// 验证函数类型（翻译 Lua validFunc）
DECLARE_DELEGATE_RetVal_OneParam(bool, FBehaviorValidateFunc, class UBehaviorComponent*);

// 行为条目（翻译 g_behaviorValidateOrder 的条目）
USTRUCT(BlueprintType)
struct FBehaviorEntry
{
    GENERATED_BODY()
    
    UPROPERTY(EditAnywhere)
    EBehaviorId BehaviorId;
    
    // 验证函数（C++ 绑定）
    FBehaviorValidateFunc ValidateFunc;
    
    UPROPERTY(EditAnywhere)
    int32 Priority;  // 优先级（数字越小越优先）
};
```

### 3. 行为配置表（Data Table）

```cpp
// 行为配置（替代 g_behaviorTable）
USTRUCT(BlueprintType)
struct FBehaviorConfig : public FTableRowBase
{
    GENERATED_BODY()
    
    UPROPERTY(EditAnywhere)
    EBehaviorId BehaviorId;
    
    // 允许的姿态（16 位掩码，对应 STYLE_TYPE）
    UPROPERTY(EditAnywhere)
    int32 AllowedStyleMask;
    
    UPROPERTY(EditAnywhere)
    UAnimMontage* Montage;
    
    UPROPERTY(EditAnywhere)
    float CooldownTime;
    
    UPROPERTY(EditAnywhere)
    bool bCanCancel;  // 是否可取消
};
```

---

## 第二步：玩家行为组件（翻译 c0000_transition.dec.lua）

### UPlayerBehaviorComponent.h

```cpp
#pragma once
#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "SekiroTypes.h"
#include "PlayerBehaviorComponent.generated.h"

UCLASS(ClassGroup=(Custom), meta=(BlueprintSpawnableComponent))
class YOURGAME_API UPlayerBehaviorComponent : public UActorComponent
{
    GENERATED_BODY()

public:
    UPlayerBehaviorComponent();
    virtual void TickComponent(float DeltaTime, ELevelTick TickType, 
                               FActorComponentTickFunction* ThisTickFunction) override;

protected:
    virtual void BeginPlay() override;

private:
    // ===== 核心数据（翻译 Lua 全局变量） =====
    
    // 优先级表（翻译 g_behaviorValidateOrder）
    TArray<FBehaviorEntry> BehaviorValidateOrder;
    
    // 按姿态分组（翻译 g_behaviorValidateOrderByStyle）
    TMap<EStyleType, TArray<FBehaviorEntry>> OrderByStyle;
    
    // 当前姿态
    UPROPERTY()
    EStyleType CurrentStyle;
    
    // 输入缓冲队列
    TQueue<EBehaviorId> InputBuffer;
    
    // 冷却时间记录
    TMap<EBehaviorId, float> CooldownTimers;
    
    // ===== 核心方法（翻译 Lua 函数） =====
    
    // 初始化优先级表（翻译 ValidateOrderTableInit）
    void InitValidateOrder();
    
    // 主验证函数（翻译 Validate）
    EBehaviorId Validate();
    
    // 激活行为（翻译 _ActivateBehavior）
    void ActivateBehavior(EBehaviorId BehaviorId);
    
    // ===== 验证函数（翻译 g_ValidateActionTable / g_ValidateReactionTable） =====
    
    bool Validate_GroundMoveStart();
    bool Validate_GroundMoveStop();
    bool Validate_GroundAttack();
    bool Validate_GroundJump();
    bool Validate_DeflectGuardStart();
    bool Validate_HitDamage();
    bool Validate_Death();
    // ... 更多验证函数
    
    // ===== 辅助方法（翻译 Lua 辅助函数） =====
    
    // 获取移动类型（翻译 GetLocomotionType）
    int32 GetLocomotionType() const;
    
    // 检查输入（翻译 env(1105) / env(1106) 等）
    bool HasMoveInput() const;
    bool IsButtonPressed(int32 ActionArm) const;
    float GetMoveSpeedLevel() const;
    
    // 检查 TAE 标志（翻译 env(3036, SP_EF_REF_TAE_*)）
    bool CheckTAEFlag(int32 FlagId) const;

public:
    // Blueprint 可调用接口
    UFUNCTION(BlueprintCallable)
    void RequestAction(EBehaviorId BehaviorId);
    
    UFUNCTION(BlueprintCallable)
    void SetCurrentStyle(EStyleType NewStyle);
};
```

### UPlayerBehaviorComponent.cpp（核心实现）

```cpp
#include "PlayerBehaviorComponent.h"

void UPlayerBehaviorComponent::BeginPlay()
{
    Super::BeginPlay();
    InitValidateOrder();
    CurrentStyle = EStyleType::STYLE_TYPE_STAND;
}

void UPlayerBehaviorComponent::TickComponent(float DeltaTime, ELevelTick TickType, 
                                              FActorComponentTickFunction* ThisTickFunction)
{
    Super::TickComponent(DeltaTime, TickType, ThisTickFunction);
    
    // 更新冷却
    for (auto& Pair : CooldownTimers)
    {
        Pair.Value -= DeltaTime;
    }
    
    // 主验证（翻译 Lua 的 Validate()）
    EBehaviorId NextBehavior = Validate();
    if (NextBehavior != EBehaviorId::BEH_NONE)
    {
        ActivateBehavior(NextBehavior);
    }
}

void UPlayerBehaviorComponent::InitValidateOrder()
{
    // 翻译 g_behaviorValidateOrder
    // 按优先级从高到低排列
    
    // 反应类（高优先级）
    FBehaviorEntry Entry;
    
    Entry.BehaviorId = EBehaviorId::BEH_R_DEATH;
    Entry.ValidateFunc.BindUObject(this, &UPlayerBehaviorComponent::Validate_Death);
    Entry.Priority = 1;
    BehaviorValidateOrder.Add(Entry);
    
    Entry.BehaviorId = EBehaviorId::BEH_R_HIT_DAMAGE;
    Entry.ValidateFunc.BindUObject(this, &UPlayerBehaviorComponent::Validate_HitDamage);
    Entry.Priority = 2;
    BehaviorValidateOrder.Add(Entry);
    
    // 动作类（低优先级）
    Entry.BehaviorId = EBehaviorId::BEH_A_GROUND_JUMP;
    Entry.ValidateFunc.BindUObject(this, &UPlayerBehaviorComponent::Validate_GroundJump);
    Entry.Priority = 10;
    BehaviorValidateOrder.Add(Entry);
    
    Entry.BehaviorId = EBehaviorId::BEH_A_GROUND_ATTACK;
    Entry.ValidateFunc.BindUObject(this, &UPlayerBehaviorComponent::Validate_GroundAttack);
    Entry.Priority = 11;
    BehaviorValidateOrder.Add(Entry);
    
    Entry.BehaviorId = EBehaviorId::BEH_A_GROUND_MOVE_START;
    Entry.ValidateFunc.BindUObject(this, &UPlayerBehaviorComponent::Validate_GroundMoveStart);
    Entry.Priority = 20;
    BehaviorValidateOrder.Add(Entry);
    
    Entry.BehaviorId = EBehaviorId::BEH_A_GROUND_MOVE_STOP;
    Entry.ValidateFunc.BindUObject(this, &UPlayerBehaviorComponent::Validate_GroundMoveStop);
    Entry.Priority = 21;
    BehaviorValidateOrder.Add(Entry);
    
    // ... 添加更多行为
    
    // 按姿态分组（翻译 ValidateOrderTableInit 的逻辑）
    // 这里简化：直接按 Priority 排序
    BehaviorValidateOrder.Sort([](const FBehaviorEntry& A, const FBehaviorEntry& B) {
        return A.Priority < B.Priority;
    });
}

EBehaviorId UPlayerBehaviorComponent::Validate()
{
    // 翻译 Lua 的 Validate() 函数
    // 按优先级遍历，第一个满足条件的胜出
    
    for (const FBehaviorEntry& Entry : BehaviorValidateOrder)
    {
        // 检查冷却
        if (CooldownTimers.Contains(Entry.BehaviorId))
        {
            if (CooldownTimers[Entry.BehaviorId] > 0.0f)
            {
                continue;
            }
        }
        
        // 调用验证函数
        if (Entry.ValidateFunc.Execute(this))
        {
            return Entry.BehaviorId;
        }
    }
    
    return EBehaviorId::BEH_NONE;
}

void UPlayerBehaviorComponent::ActivateBehavior(EBehaviorId BehaviorId)
{
    // 翻译 _ActivateBehavior
    // 这里简化：直接通知 Animation Blueprint
    
    // 设置冷却
    CooldownTimers.Add(BehaviorId, 1.0f);  // 默认 1 秒冷却
    
    // 通知动画系统（通过 Blueprint 接口或直接调用 AnimInstance）
    // 示例：通过 Character 的 AnimInstance
    ACharacter* Character = Cast<ACharacter>(GetOwner());
    if (Character && Character->GetMesh())
    {
        UAnimInstance* AnimInstance = Character->GetMesh()->GetAnimInstance();
        if (AnimInstance)
        {
            // 调用 AnimInstance 的 Blueprint 函数
            // AnimInstance->PlayBehavior(BehaviorId);
        }
    }
}

// ===== 验证函数实现（翻译 Lua 的 g_ValidateActionTable） =====

bool UPlayerBehaviorComponent::Validate_GroundMoveStart()
{
    // 翻译 c0000_transition.dec.lua:5984
    // if (env(1105) == TRUE or env(2000) == TRUE) and GetLocomotionType() ~= LOCOMOTION_TYPE_MOVE ...
    
    if (HasMoveInput() && GetLocomotionType() != 1 && GetMoveSpeedLevel() > 0.0f)
    {
        return true;
    }
    return false;
}

bool UPlayerBehaviorComponent::Validate_GroundMoveStop()
{
    // 翻译 c0000_transition.dec.lua:5989
    if (GetLocomotionType() == 1 && GetMoveSpeedLevel() <= 0.0f)
    {
        return true;
    }
    return false;
}

bool UPlayerBehaviorComponent::Validate_GroundAttack()
{
    // 翻译攻击验证逻辑
    if (IsButtonPressed(0) && CurrentStyle == EStyleType::STYLE_TYPE_STAND)
    {
        return true;
    }
    return false;
}

bool UPlayerBehaviorComponent::Validate_GroundJump()
{
    // 翻译跳跃验证逻辑
    if (IsButtonPressed(4) && CurrentStyle == EStyleType::STYLE_TYPE_STAND)
    {
        return true;
    }
    return false;
}

bool UPlayerBehaviorComponent::Validate_HitDamage()
{
    // 检查是否受击（需要从战斗系统获取）
    // 这里简化
    return false;
}

bool UPlayerBehaviorComponent::Validate_Death()
{
    // 检查是否死亡
    ACharacter* Character = Cast<ACharacter>(GetOwner());
    if (Character)
    {
        // 假设有 Health 组件
        // return Character->GetHealth() <= 0.0f;
    }
    return false;
}

// ===== 辅助方法实现 =====

int32 UPlayerBehaviorComponent::GetLocomotionType() const
{
    // 0 = Idle, 1 = Move
    // 从 Character Movement 获取
    ACharacter* Character = Cast<ACharacter>(GetOwner());
    if (Character)
    {
        FVector Velocity = Character->GetVelocity();
        return Velocity.Size() > 10.0f ? 1 : 0;
    }
    return 0;
}

bool UPlayerBehaviorComponent::HasMoveInput() const
{
    // 检查是否有移动输入
    ACharacter* Character = Cast<ACharacter>(GetOwner());
    if (Character)
    {
        APlayerController* PC = Cast<APlayerController>(Character->GetController());
        if (PC)
        {
            // 从 Enhanced Input 获取
            // return PC->GetInputAxisValue("Move") != 0.0f;
        }
    }
    return false;
}

bool UPlayerBehaviorComponent::IsButtonPressed(int32 ActionArm) const
{
    // 检查按键是否按下
    // ActionArm 对应 ACTION_ARM_* 常量
    // 0 = Attack, 4 = Jump, 等
    
    ACharacter* Character = Cast<ACharacter>(GetOwner());
    if (Character)
    {
        APlayerController* PC = Cast<APlayerController>(Character->GetController());
        if (PC)
        {
            // 从 Enhanced Input 获取
            // 示例：return PC->WasInputKeyJustPressed(EKeys::LeftMouseButton);
        }
    }
    return false;
}

float UPlayerBehaviorComponent::GetMoveSpeedLevel() const
{
    // 获取移动速度等级（0.0 - 1.0）
    ACharacter* Character = Cast<ACharacter>(GetOwner());
    if (Character)
    {
        // 从输入获取摇杆推力
        // return InputComponent->GetAxisValue("MoveForward");
    }
    return 0.0f;
}

bool UPlayerBehaviorComponent::CheckTAEFlag(int32 FlagId) const
{
    // 检查 TAE 标志（从 AnimInstance 获取）
    ACharacter* Character = Cast<ACharacter>(GetOwner());
    if (Character && Character->GetMesh())
    {
        UAnimInstance* AnimInstance = Character->GetMesh()->GetAnimInstance();
        if (AnimInstance)
        {
            // 从 AnimInstance 的变量获取
            // return AnimInstance->GetTAEFlag(FlagId);
        }
    }
    return false;
}
```

---

## 第三步：Animation Blueprint 集成

### 1. 创建自定义 AnimInstance

```cpp
// SekiroAnimInstance.h
UCLASS()
class USekiroAnimInstance : public UAnimInstance
{
    GENERATED_BODY()

public:
    // 当前行为 ID（从 BehaviorComponent 接收）
    UPROPERTY(BlueprintReadWrite, Category = "Sekiro")
    EBehaviorId CurrentBehaviorId;
    
    // TAE 标志（Anim Notify 设置）
    UPROPERTY(BlueprintReadWrite, Category = "Sekiro")
    TMap<int32, bool> TAEFlags;
    
    // 播放行为动画
    UFUNCTION(BlueprintCallable, Category = "Sekiro")
    void PlayBehavior(EBehaviorId BehaviorId);
    
    // 设置 TAE 标志（从 Anim Notify 调用）
    UFUNCTION(BlueprintCallable, Category = "Sekiro")
    void SetTAEFlag(int32 FlagId, bool bValue);
    
    // 获取 TAE 标志
    UFUNCTION(BlueprintCallable, Category = "Sekiro")
    bool GetTAEFlag(int32 FlagId) const;
};
```

### 2. Animation Blueprint 设置

在 Animation Blueprint 中：

1. **创建状态机**：
   - Idle State
   - Move State
   - Attack State
   - Jump State
   - Hit State
   - Death State

2. **状态转换条件**：
   - 从 `CurrentBehaviorId` 变量判断
   - 例如：`CurrentBehaviorId == BEH_A_GROUND_ATTACK` → 进入 Attack State

3. **在每个 State 中**：
   - 播放对应的 Montage 或动画序列
   - 使用 Anim Notifies 触发事件

---

## 第四步：敌人 AI（简化版）

### 1. 敌人行为组件

```cpp
// EnemyBehaviorComponent.h
UCLASS()
class UEnemyBehaviorComponent : public UActorComponent
{
    GENERATED_BODY()

public:
    virtual void TickComponent(float DeltaTime, ELevelTick TickType, 
                               FActorComponentTickFunction* ThisTickFunction) override;

protected:
    // 加权选择攻击（翻译 Lua 的 Goal.Activate）
    int32 SelectAttack();
    
    // 执行攻击
    void ExecuteAttack(int32 AttackID);

private:
    // 攻击权重表（从 Data Table 加载）
    UPROPERTY()
    UDataTable* AttackWeightTable;
    
    // 当前目标
    UPROPERTY()
    AActor* CurrentTarget;
    
    // 冷却记录
    TMap<int32, float> AttackCooldowns;
};

// 攻击权重配置（Data Table Row）
USTRUCT(BlueprintType)
struct FEnemyAttackConfig : public FTableRowBase
{
    GENERATED_BODY()
    
    UPROPERTY(EditAnywhere)
    int32 AttackID;
    
    UPROPERTY(EditAnywhere)
    UAnimMontage* Montage;
    
    UPROPERTY(EditAnywhere)
    float MinDistance;
    
    UPROPERTY(EditAnywhere)
    float MaxDistance;
    
    UPROPERTY(EditAnywhere)
    int32 BaseWeight;  // 基础权重
    
    UPROPERTY(EditAnywhere)
    float Cooldown;
};
```

### 2. 敌人 AI 实现

```cpp
// EnemyBehaviorComponent.cpp
void UEnemyBehaviorComponent::TickComponent(float DeltaTime, ELevelTick TickType, 
                                             FActorComponentTickFunction* ThisTickFunction)
{
    Super::TickComponent(DeltaTime, TickType, ThisTickFunction);
    
    // 更新冷却
    for (auto& Pair : AttackCooldowns)
    {
        Pair.Value -= DeltaTime;
    }
    
    // 如果当前没有在播放动画，选择下一个攻击
    // 这里简化：每 2 秒选择一次
    static float Timer = 0.0f;
    Timer += DeltaTime;
    if (Timer >= 2.0f)
    {
        Timer = 0.0f;
        int32 AttackID = SelectAttack();
        if (AttackID > 0)
        {
            ExecuteAttack(AttackID);
        }
    }
}

int32 UEnemyBehaviorComponent::SelectAttack()
{
    // 翻译 Lua 的加权选择逻辑
    if (!AttackWeightTable || !CurrentTarget)
    {
        return 0;
    }
    
    // 获取距离
    float Distance = FVector::Dist(GetOwner()->GetActorLocation(), 
                                   CurrentTarget->GetActorLocation());
    
    // 构建权重数组
    TArray<int32> AttackIDs;
    TArray<int32> Weights;
    
    TArray<FEnemyAttackConfig*> Rows;
    AttackWeightTable->GetAllRows<FEnemyAttackConfig>("", Rows);
    
    for (FEnemyAttackConfig* Row : Rows)
    {
        // 检查距离
        if (Distance < Row->MinDistance || Distance > Row->MaxDistance)
        {
            continue;
        }
        
        // 检查冷却
        if (AttackCooldowns.Contains(Row->AttackID))
        {
            if (AttackCooldowns[Row->AttackID] > 0.0f)
            {
                continue;
            }
        }
        
        AttackIDs.Add(Row->AttackID);
        Weights.Add(Row->BaseWeight);
    }
    
    // 加权随机选择
    if (AttackIDs.Num() == 0)
    {
        return 0;
    }
    
    int32 TotalWeight = 0;
    for (int32 Weight : Weights)
    {
        TotalWeight += Weight;
    }
    
    int32 RandomValue = FMath::RandRange(0, TotalWeight - 1);
    int32 CurrentSum = 0;
    for (int32 i = 0; i < Weights.Num(); ++i)
    {
        CurrentSum += Weights[i];
        if (RandomValue < CurrentSum)
        {
            return AttackIDs[i];
        }
    }
    
    return AttackIDs[0];
}

void UEnemyBehaviorComponent::ExecuteAttack(int32 AttackID)
{
    // 播放对应的 Montage
    ACharacter* Character = Cast<ACharacter>(GetOwner());
    if (Character && Character->GetMesh())
    {
        UAnimInstance* AnimInstance = Character->GetMesh()->GetAnimInstance();
        if (AnimInstance)
        {
            // 从 Data Table 获取 Montage
            TArray<FEnemyAttackConfig*> Rows;
            AttackWeightTable->GetAllRows<FEnemyAttackConfig>("", Rows);
            
            for (FEnemyAttackConfig* Row : Rows)
            {
                if (Row->AttackID == AttackID)
                {
                    AnimInstance->Montage_Play(Row->Montage);
                    AttackCooldowns.Add(AttackID, Row->Cooldown);
                    break;
                }
            }
        }
    }
}
```

### 3. Behavior Tree（可选，更简单）

如果你熟悉 Behavior Tree，可以用它替代上面的 Component：

1. **创建 Behavior Tree**：
   - Selector 节点
     - Sequence: 检查距离 → 选择攻击 → 播放动画
     - Sequence: 接近目标
     - Sequence: 巡逻

2. **自定义 Task**：
   - `BTTask_SelectAttack`：调用 `SelectAttack()` 逻辑
   - `BTTask_PlayAttackMontage`：播放选中的攻击动画

---

## 第五步：Anim Notifies（时序事件）

### 1. 自定义 Anim Notify

```cpp
// AnimNotify_SetTAEFlag.h
UCLASS()
class UAnimNotify_SetTAEFlag : public UAnimNotify
{
    GENERATED_BODY()

public:
    UPROPERTY(EditAnywhere, Category = "TAE")
    int32 FlagID;
    
    UPROPERTY(EditAnywhere, Category = "TAE")
    bool bValue;
    
    virtual void Notify(USkeletalMeshComponent* MeshComp, UAnimSequenceBase* Animation) override;
};

// AnimNotify_SetTAEFlag.cpp
void UAnimNotify_SetTAEFlag::Notify(USkeletalMeshComponent* MeshComp, UAnimSequenceBase* Animation)
{
    if (MeshComp)
    {
        USekiroAnimInstance* AnimInstance = Cast<USekiroAnimInstance>(MeshComp->GetAnimInstance());
        if (AnimInstance)
        {
            AnimInstance->SetTAEFlag(FlagID, bValue);
        }
    }
}
```

### 2. 常用 Anim Notify 类型

创建以下 Notify：

1. **AnimNotify_AttackStart**：开启攻击判定
2. **AnimNotify_AttackEnd**：关闭攻击判定
3. **AnimNotifyState_CancelWindow**：取消窗口（开始/结束）
4. **AnimNotifyState_InputBuffer**：输入缓冲窗口
5. **AnimNotify_PlaySound**：播放音效
6. **AnimNotify_SpawnVFX**：生成特效

### 3. 在动画中添加 Notifies

在导入的动画资产中：
1. 打开动画序列
2. 在时间轴上添加 Notify
3. 配置参数（例如 FlagID = 100 表示取消窗口开启）

---

## 第六步：数据配置（Data Table）

### 1. 创建 Data Table

在 UE 编辑器中：
1. 右键 → Miscellaneous → Data Table
2. 选择 Row Structure：`FBehaviorConfig` 或 `FEnemyAttackConfig`
3. 填充数据

### 2. 玩家行为配置示例

| BehaviorId | AllowedStyleMask | Montage | CooldownTime | bCanCancel |
|------------|------------------|---------|--------------|------------|
| BEH_A_GROUND_ATTACK | 1 (STAND) | AM_Attack_Light | 0.5 | true |
| BEH_A_GROUND_JUMP | 1 (STAND) | AM_Jump | 1.0 | false |
| BEH_A_DEFLECT_GUARD_START | 1 (STAND) | AM_Guard_Start | 0.2 | true |

### 3. 敌人攻击配置示例

| AttackID | Montage | MinDistance | MaxDistance | BaseWeight | Cooldown |
|----------|---------|-------------|-------------|------------|----------|
| 3000 | AM_Enemy_Attack_1 | 0 | 3 | 500 | 2.0 |
| 3010 | AM_Enemy_Attack_2 | 2 | 5 | 300 | 3.0 |
| 3020 | AM_Enemy_Thrust | 3 | 7 | 200 | 5.0 |

---

## 第七步：快速测试流程

### 1. 创建测试角色

1. 创建 Blueprint 继承自 `ACharacter`
2. 添加 `UPlayerBehaviorComponent`
3. 设置 Animation Blueprint 为 `ABP_Sekiro`
4. 配置 Enhanced Input

### 2. 测试玩家移动

1. 按 WASD → 触发 `BEH_A_GROUND_MOVE_START`
2. 松开 → 触发 `BEH_A_GROUND_MOVE_STOP`
3. 检查 AnimInstance 的 `CurrentBehaviorId` 变量

### 3. 测试玩家攻击

1. 按鼠标左键 → 触发 `BEH_A_GROUND_ATTACK`
2. 播放攻击 Montage
3. Anim Notify 触发攻击判定

### 4. 测试敌人 AI

1. 创建敌人 Blueprint
2. 添加 `UEnemyBehaviorComponent`
3. 设置 `AttackWeightTable`
4. 放置在场景中，靠近玩家
5. 观察敌人自动选择攻击

---

## 优势与劣势

### 优势

✅ **快速上手**：不需要学习 StateTree 和 GAS
✅ **直接翻译**：Lua 逻辑 1:1 对应 C++ 代码
✅ **易于调试**：C++ 断点、日志清晰
✅ **利用现有资产**：直接使用解包的动画和数据
✅ **灵活扩展**：可以随时添加新行为

### 劣势

❌ **代码量大**：每个验证函数都要手写
❌ **不够数据驱动**：逻辑硬编码在 C++ 中
❌ **缺少可视化**：策划无法直接调整
❌ **性能一般**：每帧遍历优先级表

---

## 迁移优先级

### 第一阶段（1 周）：核心框架
1. ✅ 实现 `UPlayerBehaviorComponent`
2. ✅ 实现 3-5 个基础行为（移动、攻击、跳跃）
3. ✅ 集成 Animation Blueprint
4. ✅ 测试玩家基础操作

### 第二阶段（1 周）：扩展玩家
1. ✅ 添加 10+ 个玩家行为
2. ✅ 实现输入缓冲
3. ✅ 实现取消窗口
4. ✅ 添加 Anim Notifies

### 第三阶段（1 周）：敌人 AI
1. ✅ 实现 `UEnemyBehaviorComponent`
2. ✅ 配置 Data Table
3. ✅ 实现 1-2 个敌人
4. ✅ 测试战斗

### 第四阶段（1 周）：优化
1. ✅ 性能优化
2. ✅ 添加更多敌人
3. ✅ 完善战斗系统
4. ✅ Bug 修复

---

## 后续优化方向

当你熟悉了基础流程后，可以考虑：

1. **引入 Data Asset**：把验证函数配置化
2. **引入 Gameplay Tags**：替代硬编码的枚举
3. **引入 GAS**：统一管理 Buff/Debuff
4. **引入 StateTree**：优化敌人高层决策

但这些都是**可选的**，基础方案已经足够实现只狼的核心玩法。

---

## 参考文件

- [doc/c0000_transition.md](../c0000_transition.md) - 玩家行为逻辑
- [doc/move/idle_walk_run_stop_turn.md](../move/idle_walk_run_stop_turn.md) - 移动系统
- [doc/dev/enemy/AI_Script_Framework.md](enemy/AI_Script_Framework.md) - 敌人 AI
- [action/script/c0000_transition.dec.lua](../../action/script/c0000_transition.dec.lua) - 原始 Lua 脚本

---

## 总结

这个方案的核心思路是：

**用最简单的方式，最快速度实现只狼的核心机制**

- 不用复杂的框架（StateTree、GAS）
- 直接翻译 Lua 逻辑到 C++
- 用 Data Table 配置数据
- 用 Animation Blueprint 播放动画
- 用 Anim Notifies 处理时序

等你熟悉了流程，再考虑引入更高级的系统。先把游戏跑起来最重要！

