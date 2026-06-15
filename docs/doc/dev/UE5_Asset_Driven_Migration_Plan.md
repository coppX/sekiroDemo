# UE5.7 只狼资产驱动迁移方案

## 核心理念

**最大化复用解包资产，最小化手动工作**

- ✅ 直接使用 Lua 脚本（通过解释器）
- ✅ 批量导入动画文件
- ✅ 自动化添加动画事件
- ✅ 数据驱动的配置系统

---

## 整体架构

```
┌─────────────────────────────────────────────────┐
│ 资产层（解包资产）                               │
│ - Lua 脚本（action/script/, script/）            │
│ - 动画文件（.hkx → FBX）                         │
│ - TAE 数据（动画事件定义）                       │
│ - 配置表（NpcThinkParam 等）                     │
└─────────────────┬───────────────────────────────┘
                  ↓
┌─────────────────────────────────────────────────┐
│ 导入工具层（Editor Utility）                     │
│ - Lua 脚本解析器                                 │
│ - 动画批量导入工具                               │
│ - TAE 事件批量添加工具                           │
│ - 配置表转换工具                                 │
└─────────────────┬───────────────────────────────┘
                  ↓
┌─────────────────────────────────────────────────┐
│ 运行时层（C++ + Lua VM）                         │
│ - Lua 虚拟机（LuaJIT）                           │
│ - Lua 桥接层（env() / act() / hkbXXX()）         │
│ - 动画事件系统                                   │
│ - 战斗系统                                       │
└─────────────────────────────────────────────────┘
```

---

## 第一阶段：资产准备与分析

### 1.1 解包资产清单

**已有资产**：
```
SekiroDecompile/
├── action/
│   ├── script/                    # 玩家行为脚本
│   │   ├── c0000.dec.lua
│   │   ├── c0000_transition.dec.lua
│   │   ├── c0000_define.dec.lua
│   │   └── c0000_cmsg.dec.lua
│   ├── eventnameid.txt            # 事件名映射（4381 条）
│   ├── statenameid.txt            # 状态名映射（3225 条）
│   └── variablenameid.txt         # 变量名映射（503 条）
├── script/
│   ├── aicommon-luabnd-dcx/lua/   # 公共 AI 框架
│   └── m11_02_00_00-luabnd-dcx/   # 地图敌人 AI
├── chr/
│   ├── c0000-behbnd-dcx/          # 玩家 Havok 行为树
│   └── c1010-behbnd-dcx/          # 敌人 Havok 行为树
└── doc/
    └── TAE/                       # TAE 动画事件文档
```

**需要转换的资产**：
- `.hkx` 动画文件 → FBX（使用 HKXPack 或 DSAnimStudio）
- TAE 事件数据 → UE Anim Notify 配置
- Lua 脚本 → 保持原样，运行时解释执行

### 1.2 TAE 事件类型分析

从 `doc/TAE/SDT_TAE_动画事件对照表.md` 提取核心事件类型：

| TAE Type | 名称 | 用途 | UE 对应 |
|----------|------|------|---------|
| 0 | JumpTable | 跳转表 | AnimNotify_JumpTable |
| 67 | AllowedToTurn | 允许转身窗口 | AnimNotifyState_AllowTurn |
| 112 | PlayFootstepSound | 脚步声 | AnimNotify_PlaySound |
| 237 | MovementParam_TurnSpeed | 转向速度 | AnimNotifyState_TurnSpeed |
| 700 | DefaultRootMotionParams | 根运动参数 | AnimNotifyState_RootMotion |
| 946 | FootstepStrike | 脚步落地标记 | AnimNotify_Footstep |
| 300 | AttackWindow | 攻击判定窗口 | AnimNotifyState_AttackWindow |
| 301 | DeflectWindow | 弹反窗口 | AnimNotifyState_DeflectWindow |
| 302 | IFrameWindow | 无敌窗口 | AnimNotifyState_IFrame |

**完整事件列表**（需要定义约 50+ 种）：
- 攻击判定类（AttackWindow, ThrowWindow, GrabWindow）
- 防御类（DeflectWindow, GuardWindow, SuperArmorWindow）
- 移动类（RootMotion, TurnSpeed, AllowedToTurn）
- 音效类（PlaySound, PlayVoice, PlayWeaponSound）
- 特效类（SpawnVFX, SpawnProjectile, CameraShake）
- 标志类（SetTAEFlag, EnableInput, DisableInput）

---

## 第二阶段：UE 动画事件系统设计

### 2.1 统一事件基类

```cpp
// SekiroAnimNotifyBase.h
UCLASS(Abstract)
class USekiroAnimNotifyBase : public UAnimNotify
{
    GENERATED_BODY()

public:
    // TAE 事件 ID（对应原版 Type）
    UPROPERTY(EditAnywhere, Category = "TAE")
    int32 TAETypeId;
    
    // 事件参数（JSON 字符串，灵活存储）
    UPROPERTY(EditAnywhere, Category = "TAE")
    FString Parameters;
    
    // 从 TAE 数据创建
    static USekiroAnimNotifyBase* CreateFromTAE(int32 TypeId, const FString& Params);
};

// 状态类事件基类
UCLASS(Abstract)
class USekiroAnimNotifyStateBase : public UAnimNotifyState
{
    GENERATED_BODY()

public:
    UPROPERTY(EditAnywhere, Category = "TAE")
    int32 TAETypeId;
    
    UPROPERTY(EditAnywhere, Category = "TAE")
    FString Parameters;
};
```

### 2.2 核心事件类定义

```cpp
// ===== 攻击判定类 =====

UCLASS()
class UAnimNotifyState_AttackWindow : public USekiroAnimNotifyStateBase
{
    GENERATED_BODY()

public:
    UPROPERTY(EditAnywhere, Category = "Attack")
    int32 AttackID;  // 对应 Lua 的 animID
    
    UPROPERTY(EditAnywhere, Category = "Attack")
    float Damage;
    
    UPROPERTY(EditAnywhere, Category = "Attack")
    float PostureDamage;
    
    virtual void NotifyBegin(USkeletalMeshComponent* MeshComp, UAnimSequenceBase* Animation, 
                             float TotalDuration) override;
    virtual void NotifyEnd(USkeletalMeshComponent* MeshComp, UAnimSequenceBase* Animation) override;
};

// ===== 防御类 =====

UCLASS()
class UAnimNotifyState_DeflectWindow : public USekiroAnimNotifyStateBase
{
    GENERATED_BODY()

public:
    UPROPERTY(EditAnywhere, Category = "Defense")
    float DeflectWindowStart;  // 弹反窗口开始时间（秒）
    
    UPROPERTY(EditAnywhere, Category = "Defense")
    float DeflectWindowEnd;
    
    virtual void NotifyBegin(USkeletalMeshComponent* MeshComp, UAnimSequenceBase* Animation, 
                             float TotalDuration) override;
    virtual void NotifyEnd(USkeletalMeshComponent* MeshComp, UAnimSequenceBase* Animation) override;
};

// ===== TAE 标志类 =====

UCLASS()
class UAnimNotify_SetTAEFlag : public USekiroAnimNotifyBase
{
    GENERATED_BODY()

public:
    // SP_EF_REF_TAE_* 标志 ID
    UPROPERTY(EditAnywhere, Category = "TAE")
    int32 FlagID;
    
    UPROPERTY(EditAnywhere, Category = "TAE")
    bool bValue;
    
    virtual void Notify(USkeletalMeshComponent* MeshComp, UAnimSequenceBase* Animation) override;
};

// ===== 音效类 =====

UCLASS()
class UAnimNotify_PlaySound : public USekiroAnimNotifyBase
{
    GENERATED_BODY()

public:
    UPROPERTY(EditAnywhere, Category = "Sound")
    USoundBase* Sound;
    
    UPROPERTY(EditAnywhere, Category = "Sound")
    float VolumeMultiplier = 1.0f;
    
    virtual void Notify(USkeletalMeshComponent* MeshComp, UAnimSequenceBase* Animation) override;
};

// ===== 根运动类 =====

UCLASS()
class UAnimNotifyState_RootMotion : public USekiroAnimNotifyStateBase
{
    GENERATED_BODY()

public:
    UPROPERTY(EditAnywhere, Category = "RootMotion")
    bool bEnableRootMotion = true;
    
    UPROPERTY(EditAnywhere, Category = "RootMotion")
    float SpeedMultiplier = 1.0f;
    
    virtual void NotifyBegin(USkeletalMeshComponent* MeshComp, UAnimSequenceBase* Animation, 
                             float TotalDuration) override;
    virtual void NotifyEnd(USkeletalMeshComponent* MeshComp, UAnimSequenceBase* Animation) override;
};
```

### 2.3 事件注册表

```cpp
// TAEEventRegistry.h
UCLASS()
class UTAEEventRegistry : public UObject
{
    GENERATED_BODY()

public:
    // TAE Type ID → UE Notify Class 映射
    static TMap<int32, TSubclassOf<USekiroAnimNotifyBase>> NotifyClassMap;
    static TMap<int32, TSubclassOf<USekiroAnimNotifyStateBase>> NotifyStateClassMap;
    
    // 初始化映射表
    static void InitializeRegistry();
    
    // 根据 TAE Type 创建 Notify
    static USekiroAnimNotifyBase* CreateNotify(int32 TAETypeId);
    static USekiroAnimNotifyStateBase* CreateNotifyState(int32 TAETypeId);
};

// TAEEventRegistry.cpp
void UTAEEventRegistry::InitializeRegistry()
{
    // 注册所有事件类型
    NotifyClassMap.Add(112, UAnimNotify_PlaySound::StaticClass());
    NotifyClassMap.Add(946, UAnimNotify_Footstep::StaticClass());
    // ... 注册所有 50+ 种事件
    
    NotifyStateClassMap.Add(67, UAnimNotifyState_AllowTurn::StaticClass());
    NotifyStateClassMap.Add(300, UAnimNotifyState_AttackWindow::StaticClass());
    NotifyStateClassMap.Add(301, UAnimNotifyState_DeflectWindow::StaticClass());
    NotifyStateClassMap.Add(700, UAnimNotifyState_RootMotion::StaticClass());
    // ... 注册所有状态类事件
}
```

---

## 第三阶段：批量导入工具开发

### 3.1 TAE 数据解析器

```cpp
// TAEDataParser.h
USTRUCT()
struct FTAEEvent
{
    GENERATED_BODY()
    
    int32 TypeId;
    float StartTime;
    float EndTime;
    FString Parameters;  // JSON 格式
};

USTRUCT()
struct FTAEAnimationData
{
    GENERATED_BODY()
    
    FString AnimationName;
    TArray<FTAEEvent> Events;
};

UCLASS()
class UTAEDataParser : public UObject
{
    GENERATED_BODY()

public:
    // 解析 TAE 文件（假设已转换为 JSON）
    static TArray<FTAEAnimationData> ParseTAEFile(const FString& FilePath);
    
    // 解析单个事件
    static FTAEEvent ParseEvent(const FJsonObject& EventJson);
};
```

### 3.2 动画批量导入工具（Editor Utility Widget）

```cpp
// AnimationBatchImporter.h
UCLASS()
class UAnimationBatchImporter : public UEditorUtilityWidget
{
    GENERATED_BODY()

public:
    // 批量导入动画
    UFUNCTION(BlueprintCallable, Category = "Import")
    void BatchImportAnimations(const FString& SourceFolder, const FString& TargetFolder);
    
    // 批量添加 TAE 事件
    UFUNCTION(BlueprintCallable, Category = "Import")
    void BatchAddTAEEvents(const FString& TAEDataFolder, const FString& AnimationFolder);
    
private:
    // 为单个动画添加事件
    void AddEventsToAnimation(UAnimSequence* AnimSequence, const TArray<FTAEEvent>& Events);
};

// AnimationBatchImporter.cpp
void UAnimationBatchImporter::BatchAddTAEEvents(const FString& TAEDataFolder, 
                                                 const FString& AnimationFolder)
{
    // 1. 扫描 TAE 数据文件
    TArray<FString> TAEFiles;
    IFileManager::Get().FindFiles(TAEFiles, *(TAEDataFolder / TEXT("*.json")), true, false);
    
    for (const FString& TAEFile : TAEFiles)
    {
        // 2. 解析 TAE 数据
        FString FullPath = TAEDataFolder / TAEFile;
        TArray<FTAEAnimationData> AnimDataList = UTAEDataParser::ParseTAEFile(FullPath);
        
        for (const FTAEAnimationData& AnimData : AnimDataList)
        {
            // 3. 查找对应的 UAnimSequence
            FString AnimPath = AnimationFolder / AnimData.AnimationName + TEXT(".") + AnimData.AnimationName;
            UAnimSequence* AnimSequence = LoadObject<UAnimSequence>(nullptr, *AnimPath);
            
            if (AnimSequence)
            {
                // 4. 添加事件
                AddEventsToAnimation(AnimSequence, AnimData.Events);
                
                // 5. 保存资产
                AnimSequence->MarkPackageDirty();
                UPackage* Package = AnimSequence->GetOutermost();
                FString PackageFileName = FPackageName::LongPackageNameToFilename(
                    Package->GetName(), FPackageName::GetAssetPackageExtension());
                UPackage::SavePackage(Package, AnimSequence, RF_Public | RF_Standalone, 
                                     *PackageFileName);
                
                UE_LOG(LogTemp, Log, TEXT("Added TAE events to: %s"), *AnimData.AnimationName);
            }
            else
            {
                UE_LOG(LogTemp, Warning, TEXT("Animation not found: %s"), *AnimData.AnimationName);
            }
        }
    }
}

void UAnimationBatchImporter::AddEventsToAnimation(UAnimSequence* AnimSequence, 
                                                     const TArray<FTAEEvent>& Events)
{
    for (const FTAEEvent& Event : Events)
    {
        // 根据 TAE Type 创建对应的 Notify
        if (Event.EndTime > Event.StartTime)
        {
            // 状态类事件（有持续时间）
            USekiroAnimNotifyStateBase* NotifyState = 
                UTAEEventRegistry::CreateNotifyState(Event.TypeId);
            
            if (NotifyState)
            {
                NotifyState->TAETypeId = Event.TypeId;
                NotifyState->Parameters = Event.Parameters;
                
                // 添加到动画
                FAnimNotifyEvent& NewEvent = AnimSequence->Notifies.AddDefaulted_GetRef();
                NewEvent.NotifyStateClass = NotifyState->GetClass();
                NewEvent.NotifyName = FName(*FString::Printf(TEXT("TAE_%d"), Event.TypeId));
                NewEvent.Link(AnimSequence, Event.StartTime);
                NewEvent.Duration = Event.EndTime - Event.StartTime;
                NewEvent.NotifyStateClass = NotifyState->GetClass();
            }
        }
        else
        {
            // 瞬时事件
            USekiroAnimNotifyBase* Notify = UTAEEventRegistry::CreateNotify(Event.TypeId);
            
            if (Notify)
            {
                Notify->TAETypeId = Event.TypeId;
                Notify->Parameters = Event.Parameters;
                
                // 添加到动画
                FAnimNotifyEvent& NewEvent = AnimSequence->Notifies.AddDefaulted_GetRef();
                NewEvent.Notify = Notify;
                NewEvent.NotifyName = FName(*FString::Printf(TEXT("TAE_%d"), Event.TypeId));
                NewEvent.Link(AnimSequence, Event.StartTime);
            }
        }
    }
    
    // 刷新动画
    AnimSequence->RefreshCacheData();
}
```

---

## 第四阶段：Lua 运行时集成

### 4.1 Lua 虚拟机集成

使用 **LuaJIT** 或 **sol2** 库：

```cpp
// LuaVMComponent.h
#include "sol/sol.hpp"  // 或 extern "C" { #include "lua.h" }

UCLASS()
class ULuaVMComponent : public UActorComponent
{
    GENERATED_BODY()

public:
    ULuaVMComponent();
    virtual void BeginPlay() override;
    virtual void TickComponent(float DeltaTime, ELevelTick TickType, 
                               FActorComponentTickFunction* ThisTickFunction) override;

protected:
    // Lua 虚拟机
    sol::state LuaState;
    
    // 加载 Lua 脚本
    UFUNCTION(BlueprintCallable, Category = "Lua")
    bool LoadLuaScript(const FString& ScriptPath);
    
    // 调用 Lua 函数
    UFUNCTION(BlueprintCallable, Category = "Lua")
    void CallLuaFunction(const FString& FunctionName);
    
    // 注册 C++ 函数到 Lua
    void RegisterCppFunctions();
    
private:
    // ===== 桥接函数（暴露给 Lua） =====
    
    // env() 函数族
    int32 Lua_env_1param(int32 typeId);
    int32 Lua_env_2param(int32 typeId, int32 subKey);
    
    // act() 函数
    void Lua_act(int32 actionId, int32 param1 = 0, int32 param2 = 0);
    
    // hkbGetVariable()
    float Lua_hkbGetVariable(const std::string& varName);
    
    // hkbSetVariable()
    void Lua_hkbSetVariable(const std::string& varName, float value);
    
    // FireEvent()
    void Lua_FireEvent(const std::string& eventName);
};

// LuaVMComponent.cpp
ULuaVMComponent::ULuaVMComponent()
{
    PrimaryComponentTick.bCanEverTick = true;
}

void ULuaVMComponent::BeginPlay()
{
    Super::BeginPlay();
    
    // 初始化 Lua 虚拟机
    LuaState.open_libraries(sol::lib::base, sol::lib::math, sol::lib::table);
    
    // 注册 C++ 函数
    RegisterCppFunctions();
    
    // 加载玩家脚本
    LoadLuaScript(TEXT("action/script/c0000.dec.lua"));
    LoadLuaScript(TEXT("action/script/c0000_transition.dec.lua"));
    LoadLuaScript(TEXT("action/script/c0000_define.dec.lua"));
    LoadLuaScript(TEXT("action/script/c0000_cmsg.dec.lua"));
}

void ULuaVMComponent::RegisterCppFunctions()
{
    // 注册 env() 函数
    LuaState.set_function("env", sol::overload(
        [this](int32 typeId) { return Lua_env_1param(typeId); },
        [this](int32 typeId, int32 subKey) { return Lua_env_2param(typeId, subKey); }
    ));
    
    // 注册 act() 函数
    LuaState.set_function("act", [this](int32 actionId, sol::variadic_args va) {
        int32 param1 = va.size() > 0 ? va[0] : 0;
        int32 param2 = va.size() > 1 ? va[1] : 0;
        Lua_act(actionId, param1, param2);
    });
    
    // 注册 hkbGetVariable()
    LuaState.set_function("hkbGetVariable", [this](const std::string& varName) {
        return Lua_hkbGetVariable(varName);
    });
    
    // 注册 SetVariable()
    LuaState.set_function("SetVariable", [this](const std::string& varName, float value) {
        Lua_hkbSetVariable(varName, value);
    });
    
    // 注册 FireEvent()
    LuaState.set_function("FireEvent", [this](const std::string& eventName) {
        Lua_FireEvent(eventName);
    });
    
    // 注册常量
    LuaState["TRUE"] = 1;
    LuaState["FALSE"] = 0;
    LuaState["INVALID"] = -1;
}

bool ULuaVMComponent::LoadLuaScript(const FString& ScriptPath)
{
    // 读取 Lua 文件
    FString FullPath = FPaths::ProjectDir() / TEXT("SekiroAssets") / ScriptPath;
    FString LuaCode;
    
    if (FFileHelper::LoadFileToString(LuaCode, *FullPath))
    {
        try
        {
            LuaState.script(TCHAR_TO_UTF8(*LuaCode));
            UE_LOG(LogTemp, Log, TEXT("Loaded Lua script: %s"), *ScriptPath);
            return true;
        }
        catch (const sol::error& e)
        {
            UE_LOG(LogTemp, Error, TEXT("Lua error: %s"), UTF8_TO_TCHAR(e.what()));
            return false;
        }
    }
    
    UE_LOG(LogTemp, Error, TEXT("Failed to load Lua script: %s"), *ScriptPath);
    return false;
}

void ULuaVMComponent::TickComponent(float DeltaTime, ELevelTick TickType, 
                                     FActorComponentTickFunction* ThisTickFunction)
{
    Super::TickComponent(DeltaTime, TickType, ThisTickFunction);
    
    // 调用 Lua 的 Update() 函数
    try
    {
        sol::protected_function UpdateFunc = LuaState["Update"];
        if (UpdateFunc.valid())
        {
            auto result = UpdateFunc();
            if (!result.valid())
            {
                sol::error err = result;
                UE_LOG(LogTemp, Error, TEXT("Lua Update error: %s"), UTF8_TO_TCHAR(err.what()));
            }
        }
    }
    catch (const sol::error& e)
    {
        UE_LOG(LogTemp, Error, TEXT("Lua tick error: %s"), UTF8_TO_TCHAR(e.what()));
    }
}
```

### 4.2 env() 函数实现

```cpp
int32 ULuaVMComponent::Lua_env_1param(int32 typeId)
{
    // 根据 typeId 返回对应的状态
    // 参考 doc/Lua env.md
    
    ACharacter* Character = Cast<ACharacter>(GetOwner());
    if (!Character) return 0;
    
    switch (typeId)
    {
        case 1105:  // 摇杆有输入
            return HasMoveInput() ? 1 : 0;
            
        case 1118:  // 锁定中
            return IsLockedOn() ? 1 : 0;
            
        case 337:   // 投技中
            return IsInThrow() ? 1 : 0;
            
        case 339:   // 动作结束
            return IsActionFinished() ? 1 : 0;
            
        // ... 更多 env 查询
        
        default:
            UE_LOG(LogTemp, Warning, TEXT("Unknown env typeId: %d"), typeId);
            return 0;
    }
}

int32 ULuaVMComponent::Lua_env_2param(int32 typeId, int32 subKey)
{
    ACharacter* Character = Cast<ACharacter>(GetOwner());
    if (!Character) return 0;
    
    switch (typeId)
    {
        case 1106:  // 按键单帧按下
            return IsButtonJustPressed(subKey) ? 1 : 0;
            
        case 1108:  // 按键长按时长
            return GetButtonHoldTime(subKey);
            
        case 3035:  // TAE 允许输入
            return IsTAEInputAllowed(subKey) ? 1 : 0;
            
        case 3036:  // TAE 标志查询
            return GetTAEFlag(subKey) ? 1 : 0;
            
        // ... 更多双参数查询
        
        default:
            UE_LOG(LogTemp, Warning, TEXT("Unknown env typeId: %d, subKey: %d"), typeId, subKey);
            return 0;
    }
}
```

### 4.3 act() 函数实现

```cpp
void ULuaVMComponent::Lua_act(int32 actionId, int32 param1, int32 param2)
{
    // 根据 actionId 执行对应的动作
    // 参考 doc/Lua act.md
    
    ACharacter* Character = Cast<ACharacter>(GetOwner());
    if (!Character) return;
    
    switch (actionId)
    {
        case 101:  // 设置移动类型
            SetMoveType(param1);
            break;
            
        case 136:  // 清理投技状态
            ClearThrowState();
            break;
            
        case 148:  // 设置变量
            // SetVariable 已经单独实现
            break;
            
        case 3029:  // 打断 NPC 对话
            InterruptNPCTalk(param1);
            break;
            
        case 3030:  // 显示动作提示
            ShowActionGuide(param1, param2);
            break;
            
        // ... 更多 act 指令
        
        default:
            UE_LOG(LogTemp, Warning, TEXT("Unknown act actionId: %d"), actionId);
            break;
    }
}
```

### 4.4 Havok 变量桥接

```cpp
float ULuaVMComponent::Lua_hkbGetVariable(const std::string& varName)
{
    // 从 AnimInstance 获取变量
    ACharacter* Character = Cast<ACharacter>(GetOwner());
    if (Character && Character->GetMesh())
    {
        UAnimInstance* AnimInstance = Character->GetMesh()->GetAnimInstance();
        if (AnimInstance)
        {
            // 假设 AnimInstance 有这些变量
            FString VarNameFString = UTF8_TO_TCHAR(varName.c_str());
            
            if (VarNameFString == TEXT("MoveSpeedLevel"))
            {
                return GetMoveSpeedLevel();
            }
            else if (VarNameFString == TEXT("MoveSpeedIndex"))
            {
                return GetMoveSpeedIndex();
            }
            else if (VarNameFString == TEXT("TurnAngle"))
            {
                return GetTurnAngle();
            }
            // ... 更多变量
        }
    }
    
    return 0.0f;
}

void ULuaVMComponent::Lua_hkbSetVariable(const std::string& varName, float value)
{
    // 设置 AnimInstance 变量
    ACharacter* Character = Cast<ACharacter>(GetOwner());
    if (Character && Character->GetMesh())
    {
        UAnimInstance* AnimInstance = Character->GetMesh()->GetAnimInstance();
        if (AnimInstance)
        {
            FString VarNameFString = UTF8_TO_TCHAR(varName.c_str());
            
            // 通过 Blueprint 接口设置
            // AnimInstance->SetVariableValue(VarNameFString, value);
        }
    }
}

void ULuaVMComponent::Lua_FireEvent(const std::string& eventName)
{
    // 触发动画事件
    ACharacter* Character = Cast<ACharacter>(GetOwner());
    if (Character && Character->GetMesh())
    {
        UAnimInstance* AnimInstance = Character->GetMesh()->GetAnimInstance();
        if (AnimInstance)
        {
            FString EventNameFString = UTF8_TO_TCHAR(eventName.c_str());
            
            // 查找对应的 Montage 并播放
            // 或者通过状态机转换
            // AnimInstance->TriggerEvent(EventNameFString);
        }
    }
}
```

---

## 第五阶段：工作流程与工具链

### 5.1 资产导入流程

```
1. 准备阶段
   ├─ 使用 HKXPack 转换 .hkx → FBX
   ├─ 提取 TAE 数据为 JSON
   └─ 复制 Lua 脚本到项目目录

2. 导入阶段（使用 Editor Utility Widget）
   ├─ 批量导入 FBX 动画
   ├─ 批量添加 TAE 事件
   └─ 验证导入结果

3. 配置阶段
   ├─ 创建 Animation Blueprint
   ├─ 配置状态机
   └─ 绑定 Lua 脚本

4. 测试阶段
   ├─ 测试单个动画
   ├─ 测试 Lua 脚本执行
   └─ 测试动画事件触发
```

### 5.2 Editor Utility Widget 界面

创建一个可视化工具界面：

```
┌─────────────────────────────────────────────┐
│ Sekiro Asset Importer                       │
├─────────────────────────────────────────────┤
│                                             │
│ [Step 1: Import Animations]                │
│   Source Folder: [Browse...] [Import]      │
│   Target Folder: [Browse...]               │
│   Progress: ████████░░ 80%                  │
│                                             │
│ [Step 2: Add TAE Events]                   │
│   TAE Data Folder: [Browse...] [Process]   │
│   Animation Folder: [Browse...]            │
│   Progress: ████████████ 100%              │
│                                             │
│ [Step 3: Verify]                           │
│   [Check All Animations]                   │
│   [Generate Report]                        │
│                                             │
│ Log:                                        │
│ ┌─────────────────────────────────────────┐│
│ │ [INFO] Imported 150 animations          ││
│ │ [INFO] Added 2341 TAE events            ││
│ │ [WARN] Missing TAE data for a000_12345  ││
│ └─────────────────────────────────────────┘│
└─────────────────────────────────────────────┘
```

### 5.3 TAE 数据转换工具

创建 Python 脚本转换 TAE 数据：

```python
# tae_to_json.py
import json
import struct

def parse_tae_file(tae_path):
    """解析 TAE 文件，转换为 JSON"""
    animations = []
    
    with open(tae_path, 'rb') as f:
        # 读取 TAE 文件头
        # 这里需要根据实际 TAE 格式解析
        # 参考 DSAnimStudio 的解析逻辑
        
        # 示例结构
        anim_data = {
            "animation_name": "a000_000100",
            "events": [
                {
                    "type_id": 67,
                    "start_time": 0.0,
                    "end_time": 2.767,
                    "parameters": {
                        "allow_turn": True
                    }
                },
                {
                    "type_id": 946,
                    "start_time": 0.067,
                    "end_time": 0.067,
                    "parameters": {
                        "foot": "left"
                    }
                }
            ]
        }
        animations.append(anim_data)
    
    return animations

def convert_tae_folder(input_folder, output_folder):
    """批量转换 TAE 文件夹"""
    import os
    
    for filename in os.listdir(input_folder):
        if filename.endswith('.tae'):
            tae_path = os.path.join(input_folder, filename)
            animations = parse_tae_file(tae_path)
            
            # 保存为 JSON
            json_path = os.path.join(output_folder, filename.replace('.tae', '.json'))
            with open(json_path, 'w', encoding='utf-8') as f:
                json.dump(animations, f, indent=2, ensure_ascii=False)
            
            print(f"Converted: {filename} -> {os.path.basename(json_path)}")

if __name__ == '__main__':
    convert_tae_folder('SekiroDecompile/chr/c0000-behbnd-dcx/', 'TAE_JSON/')
```

---

## 第六阶段：实施计划

### 阶段 1：基础设施（第 1-2 周）

**目标**：搭建核心框架

**任务清单**：
- [ ] 集成 LuaJIT 到 UE 项目
  - 添加 ThirdParty/LuaJIT 模块
  - 配置 Build.cs
  - 测试基础 Lua 执行
  
- [ ] 定义所有 TAE 事件类（50+ 个）
  - 创建基类 `USekiroAnimNotifyBase`
  - 创建核心事件类（攻击、防御、移动、音效、特效）
  - 注册到 `UTAEEventRegistry`
  
- [ ] 实现 `ULuaVMComponent`
  - 注册 env() / act() / hkbXXX() 函数
  - 加载 Lua 脚本
  - 测试基础调用

**验收标准**：
- ✅ Lua 脚本能成功加载并执行
- ✅ 能从 Lua 调用 C++ 函数
- ✅ 能从 C++ 调用 Lua 函数
- ✅ 所有 TAE 事件类定义完成

---

### 阶段 2：批量导入工具（第 3-4 周）

**目标**：实现自动化导入流程

**任务清单**：
- [ ] 开发 TAE 数据解析器
  - 编写 Python 脚本转换 TAE → JSON
  - 实现 C++ TAE JSON 解析器
  - 测试数据完整性
  
- [ ] 开发动画批量导入工具
  - 创建 Editor Utility Widget
  - 实现批量 FBX 导入
  - 实现批量 TAE 事件添加
  - 添加进度显示和日志
  
- [ ] 转换所有动画资产
  - 使用 HKXPack 转换 .hkx → FBX
  - 转换 TAE 数据为 JSON
  - 批量导入到 UE

**验收标准**：
- ✅ 能批量导入 100+ 个动画
- ✅ 每个动画自动添加对应的 TAE 事件
- ✅ 事件参数正确解析
- ✅ 导入日志清晰可追溯

---

### 阶段 3：玩家系统（第 5-6 周）

**目标**：实现玩家行为系统

**任务清单**：
- [ ] 复制 Lua 脚本到项目
  - action/script/c0000*.dec.lua
  - 验证脚本完整性
  
- [ ] 实现 env() 函数族
  - 输入查询（1105, 1106, 1108）
  - 状态查询（337, 339, 1118）
  - TAE 标志查询（3035, 3036）
  - 测试所有查询
  
- [ ] 实现 act() 函数族
  - 移动控制（101）
  - 状态设置（136, 148）
  - UI 提示（3030）
  - 测试所有指令
  
- [ ] 实现 Havok 变量桥接
  - MoveSpeedLevel, MoveSpeedIndex
  - TurnAngle, MoveDirection
  - 其他关键变量
  
- [ ] 创建玩家 Animation Blueprint
  - 配置状态机
  - 绑定 Lua 事件
  - 测试状态转换

**验收标准**：
- ✅ 玩家能正常移动（Idle → Walk → Run → Stop）
- ✅ 玩家能正常攻击
- ✅ 玩家能正常跳跃
- ✅ Lua 脚本正确驱动动画
- ✅ TAE 事件正确触发

---

### 阶段 4：敌人系统（第 7-8 周）

**目标**：实现敌人 AI 系统

**任务清单**：
- [ ] 复制敌人 Lua 脚本
  - script/aicommon-luabnd-dcx/
  - script/m11_02_00_00-luabnd-dcx/
  - 验证脚本完整性
  
- [ ] 实现敌人 AI 接口
  - ai:GetDist()
  - ai:GetHpRate()
  - ai:IsInsideTarget()
  - ai:AddSubGoal()
  - 其他 AI 函数
  
- [ ] 创建敌人 Animation Blueprint
  - 配置状态机
  - 绑定 Lua 事件
  
- [ ] 实现 1-2 个测试敌人
  - 落武者（101000）
  - 村民僵尸（150000）
  - 测试 AI 决策和攻击

**验收标准**：
- ✅ 敌人能正常巡逻
- ✅ 敌人能发现玩家并进入战斗
- ✅ 敌人能根据距离选择攻击
- ✅ 敌人攻击动画正确播放
- ✅ Lua AI 脚本正确执行

---

### 阶段 5：战斗系统（第 9-10 周）

**目标**：实现核心战斗机制

**任务清单**：
- [ ] 实现攻击判定系统
  - 攻击碰撞检测
  - 伤害计算
  - 命中反馈
  
- [ ] 实现防御系统
  - 格挡判定
  - 弹反判定
  - 架势系统
  
- [ ] 实现受击反应
  - 普通受击
  - 破防
  - 死亡
  
- [ ] 实现特殊机制
  - 处决
  - 忍杀
  - 钩锁

**验收标准**：
- ✅ 玩家攻击能命中敌人
- ✅ 敌人攻击能命中玩家
- ✅ 弹反系统正常工作
- ✅ 架势系统正常工作
- ✅ 处决系统正常工作

---

### 阶段 6：优化与完善（第 11-12 周）

**目标**：优化性能和完善细节

**任务清单**：
- [ ] 性能优化
  - Lua 脚本缓存
  - 动画事件优化
  - 碰撞检测优化
  
- [ ] 添加更多敌人
  - 至少 5 种不同敌人
  - 测试 AI 多样性
  
- [ ] 完善动画细节
  - 根运动调整
  - 转身优化
  - 动画混合
  
- [ ] Bug 修复
  - 收集测试反馈
  - 修复已知问题

**验收标准**：
- ✅ 帧率稳定在 60 FPS
- ✅ 无明显卡顿
- ✅ 动画流畅自然
- ✅ 核心玩法完整

---

## 第七阶段：工具与脚本清单

### 必需工具

1. **HKXPack**
   - 用途：转换 .hkx 动画文件为 FBX
   - 下载：https://github.com/PredatorCZ/HavokLib
   
2. **DSAnimStudio**
   - 用途：查看和导出 TAE 数据
   - 下载：https://github.com/Meowmaritus/DSAnimStudio
   
3. **LuaJIT**
   - 用途：Lua 虚拟机
   - 下载：https://luajit.org/
   
4. **sol2**（可选）
   - 用途：C++ Lua 绑定库
   - 下载：https://github.com/ThePhD/sol2

### 自定义脚本

1. **tae_to_json.py**
   - 转换 TAE 数据为 JSON
   
2. **batch_convert_hkx.bat**
   - 批量转换 .hkx 为 FBX
   
3. **verify_animations.py**
   - 验证动画和 TAE 数据完整性

---

## 优势与挑战

### 优势

✅ **最大化复用原版资产**
- Lua 脚本直接使用，无需重写
- 动画文件直接导入
- TAE 数据自动转换

✅ **自动化程度高**
- 批量导入工具
- 自动添加事件
- 减少手动工作

✅ **保真度高**
- 逻辑完全一致
- 动画完全一致
- 数据完全一致

✅ **易于调试**
- Lua 脚本可热重载
- 动画事件可视化
- 日志清晰

### 挑战

❌ **Lua 集成复杂**
- 需要深入理解 Lua C API
- 桥接函数工作量大
- 调试跨语言栈困难

❌ **TAE 数据格式**
- 需要逆向 TAE 文件格式
- 或依赖第三方工具
- 数据完整性需验证

❌ **动画转换**
- .hkx 转 FBX 可能有损
- 根运动需要调整
- 骨骼映射需要处理

❌ **性能开销**
- Lua 虚拟机有性能开销
- 每帧调用 Lua 需要优化
- 大量动画事件需要优化

---

## 风险缓解策略

### 风险 1：Lua 集成失败

**缓解方案**：
- 先实现最小 Lua 集成（只加载脚本）
- 逐步添加桥接函数
- 准备 Plan B：用 C++ 重写核心逻辑

### 风险 2：TAE 数据无法解析

**缓解方案**：
- 使用 DSAnimStudio 手动导出
- 或手动配置关键动画的事件
- 优先处理核心动画

### 风险 3：动画转换质量差

**缓解方案**：
- 测试多种转换工具
- 手动调整关键动画
- 使用 UE 的动画重定向

### 风险 4：性能不达标

**缓解方案**：
- Lua 脚本缓存和预编译
- 动画事件池化
- 碰撞检测优化
- 降级到 C++ 实现

---

## 总结

这个方案的核心优势是：

**最大化利用解包资产，最小化手动工作**

### 关键决策

1. **使用 Lua 虚拟机**：直接运行原版脚本
2. **批量导入工具**：自动化处理动画和事件
3. **TAE 数据驱动**：事件配置完全来自原版数据
4. **分阶段实施**：12 周完成核心系统

### 与其他方案对比

| 特性 | 资产驱动方案 | 快速方案 | 混合架构方案 |
|------|-------------|----------|-------------|
| 开发时间 | 12 周 | 4 周 | 10 周 |
| 保真度 | 最高 | 中等 | 高 |
| 复用资产 | 最多 | 少 | 中等 |
| 学习曲线 | 中等（Lua） | 低 | 高（StateTree+GAS） |
| 可维护性 | 中等 | 低 | 高 |
| 性能 | 良好 | 良好 | 优秀 |

### 适用场景

✅ **适合**：
- 想要高保真复刻只狼
- 有大量解包资产可用
- 团队有 Lua 经验或愿意学习
- 时间充裕（12 周）

❌ **不适合**：
- 需要快速原型（用快速方案）
- 需要高度定制化（用混合架构）
- 团队完全不懂 Lua（用快速方案）

---

## 参考资料

- [doc/c0000_transition.md](../c0000_transition.md) - 玩家行为逻辑
- [doc/Lua env.md](../Lua%20env.md) - env() 函数参考
- [doc/Lua act.md](../Lua%20act.md) - act() 函数参考
- [doc/dev/enemy/AI_Script_Framework.md](enemy/AI_Script_Framework.md) - 敌人 AI
- [doc/TAE/SDT_TAE_动画事件对照表.md](../TAE/SDT_TAE_动画事件对照表.md) - TAE 事件
- [action/script/](../../action/script/) - 原始 Lua 脚本
- [script/](../../script/) - 原始 AI 脚本

---

## 下一步行动

1. **评估方案**：与团队讨论，确认是否采用此方案
2. **准备环境**：安装必需工具（HKXPack, DSAnimStudio, LuaJIT）
3. **测试转换**：转换 1-2 个动画，验证流程
4. **开始实施**：按阶段 1 开始开发