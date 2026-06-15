# Havok Behavior 2018 行为树状态机文档

## 目录
1. [概述](#概述)
2. [系统架构](#系统架构)
3. [核心概念](#核心概念)
4. [节点类型详解](#节点类型详解)
5. [状态机运行原理](#状态机运行原理)
6. [FromSoft 游戏中的应用](#fromsoft-游戏中的应用)

---

## 概述

**Havok Behavior** 是 Havok Animation Studio 的一部分，是一个用于控制游戏角色动画的运行时 SDK。它使用**有限状态机（Finite State Machine）**在高层次上管理角色行为。

在 FromSoftware 的游戏中（Dark Souls 3、Bloodborne、Sekiro、Elden Ring、Nightreign），Havok Behavior 用于控制所有角色的动画行为。

### 文件格式
- **`.hkx`**: Havok 二进制格式，包含行为图数据
- **`.xml`**: 反编译后的 XML 格式，便于编辑
- **`.hks`**: Havok 脚本文件，用于触发行为文件中的行为
- **`.behbnd.dcx`**: 绑定档案，包含多个行为文件

---

## 系统架构

### 文件结构层次

```
hkRootLevelContainer (ID #90)
└── hkbBehaviorGraph (ID #91)
    ├── hkbBehaviorGraphData (行为图数据)
    └── Root Generator (根级生成器)
        └── hkbStateMachine "Root" (根状态机)
            └── hkbStateMachine "Master_SM" (主状态机)
                ├── 子状态机 1
                ├── 子状态机 2
                └── ...
```

### 核心组件

1. **hkRootLevelContainer**: 所有行为文件的起点
2. **hkbBehaviorGraph**: 行为图，包含整个行为树结构
3. **hkbBehaviorGraphData**: 存储事件、变量、动画等数据
4. **hkbStateMachine**: 状态机节点，组织和管理状态

---

## 核心概念

### 1. 状态（State）

**状态**是角色所处的条件，例如：
- 潜行（Sneaking）
- 战斗（Combat）
- 行走（Walking）
- 奔跑（Running）
- 跳跃（Jumping）

状态可以**嵌套**。例如，可能有一个默认的"站立"状态，其中包含：
- 战斗状态
- 奔跑状态
- 跳跃状态

### 2. 生成器（Generator）

**生成器**负责生成动画姿态。它是行为树中的核心节点类型。

常见生成器类型：
- `hkbStateMachine`: 状态机生成器
- `hkbClipGenerator`: 动画片段生成器
- `hkbManualSelectorGenerator`: 手动选择器生成器
- `hkbBlenderGenerator`: 混合生成器
- `CustomManualSelectorGenerator`: FromSoft 自定义选择器（见下文）

### 3. 修改器（Modifier）

**修改器**是状态的特殊属性，应用于该状态及其所有嵌套状态。

常见修改器类型：
- `hkbEvaluateExpressionModifier`: 用于改变变量值
- `hkbFootIkModifier`: 脚部 IK 修改器
- `hkbGetHandleOnBoneModifier`: 获取骨骼句柄
- `hkbRotateCharacterModifier`: 旋转角色
- `hkbTwistModifier`: 扭曲修改器

### 4. 转换（Transition）

**转换**定义了状态之间的切换规则。

转换类型：
- **普通转换**: 从一个特定状态到另一个状态
- **通配符转换（Wildcard Transition）**: 从任意状态到目标状态
- **条件转换**: 基于事件或变量触发

### 5. 转换效果（Transition Effect）

**转换效果**控制状态切换时的过渡动画。

常见转换效果：
- `hkbBlendingTransitionEffect`: 混合过渡效果

---

## 节点类型详解

### 生成器（Generators）

#### hkbStateMachine（状态机）

状态机是组织行为的核心节点。

**关键属性**：
- `states`: 状态列表（`hkbStateMachineStateInfo` 数组）
- `wildcardTransitions`: 通配符转换数组
- `startStateId`: 起始状态 ID
- `userData`: 用户数据，用于映射到脚本函数

**子对象**：
- `hkbStateMachineStateInfo`: 状态信息对象

#### hkbStateMachineStateInfo（状态信息）

定义状态机中的单个状态。

**关键属性**：
- `stateId`: 状态 ID（在状态机内唯一）
- `name`: 状态名称
- `generator`: 子生成器引用
- `transitions`: 转换信息数组
- `enterNotifyEvents`: 进入状态时触发的事件
- `exitNotifyEvents`: 退出状态时触发的事件

**命名约定**：
- 状态名称不带前缀或后缀
- 子对象使用后缀表示功能（如 `_CMSG`、`_Blend`）

#### hkbClipGenerator（动画片段生成器）

播放单个动画片段。

**关键属性**：
- `animationName`: 动画名称
- `cropStartAmountLocalTime`: 裁剪起始时间
- `cropEndAmountLocalTime`: 裁剪结束时间
- `startTime`: 开始时间
- `playbackSpeed`: 播放速度
- `mode`: 播放模式（循环、单次等）

#### CustomManualSelectorGenerator（FromSoft 自定义选择器）

**这是 FromSoftware 的自定义生成器类**，基于 `hkbManualSelectorGenerator`。

**特殊功能**：
1. 根据玩家的 TAE（TimeAct Editor）段自动选择子生成器
2. 包含 `hkbScriptGenerator` 的所有功能
3. 自动生成形式为 `[state name]_on[function type]` 的脚本函数

**关键属性**：
- `generators`: 子生成器列表（通常是 `hkbClipGenerator`）
- `offsetType`: 决定使用哪种 TAE 段类型
- `animId`: 动画 ID
- `animeEndEventType`: 动画结束时的行为
- `enableScript`: 是否启用脚本生成功能
- `userData`: 映射到 HKS 脚本中的 `onUpdate` 函数

**命名约定**：
- 用作选择器时：通常带 `_CMSG` 后缀（如 `Rolling_CMSG`）
- 仅用作脚本生成器时：命名不一致（如 `Move Selector`）

#### hkbBlenderGenerator（混合生成器）

混合多个子生成器的输出。

**关键属性**：
- `children`: 子生成器数组（`hkbBlenderGeneratorChild`）
- `blendParameter`: 混合参数（通常绑定到变量）

#### hkbManualSelectorGenerator（手动选择器）

根据索引手动选择一个子生成器。

**关键属性**：
- `generators`: 子生成器列表
- `selectedGeneratorIndex`: 当前选中的生成器索引

### 修改器（Modifiers）

修改器应用于生成器，修改其输出的姿态或行为。

#### hkbEvaluateExpressionModifier（表达式求值修改器）

用于计算表达式并修改变量值。

**关键属性**：
- `expressions`: 表达式数组
- `assignmentVariableIndex`: 赋值目标变量索引

#### hkbFootIkModifier（脚部 IK 修改器）

应用脚部反向运动学（IK）。

**关键属性**：
- `legs`: 腿部配置数组
- `raycastDistanceUp`: 向上射线检测距离
- `raycastDistanceDown`: 向下射线检测距离

### 转换效果（Transition Effects）

#### hkbBlendingTransitionEffect（混合转换效果）

在状态转换时平滑混合动画。

**关键属性**：
- `duration`: 混合持续时间
- `toGeneratorStartTimeFraction`: 目标生成器起始时间比例
- `blendCurve`: 混合曲线类型

---

## 状态机运行原理

### 节点激活顺序

1. **激活（Activation）**: 父节点优先于子节点激活
   - 节点必须先激活才能使用

2. **更新（Update）**: 子节点优先于父节点更新
   - 从叶节点向根节点传播

3. **生成（Generate）**: 调用活动节点的 `generate()` 方法
   - 生成根姿态（root pose）

4. **修改（Modify）**: 调用活动节点的 `modify()` 方法
   - 应用修改器

### 状态转换流程

```
当前状态
    ↓
检查转换条件（事件/变量）
    ↓
条件满足？
    ├─ 是 → 触发转换
    │       ↓
    │   执行退出事件
    │       ↓
    │   应用转换效果（混合）
    │       ↓
    │   进入目标状态
    │       ↓
    │   执行进入事件
    │
    └─ 否 → 保持当前状态
```

### 通配符转换

通配符转换允许状态机定义一个事件，该事件可以从图中的**任何位置**触发转换到特定状态。

**用途**：
- 紧急中断（如受击、死亡）
- 全局状态切换

### userData 系统

每个 `hkbStateMachine` 和 `CustomManualSelectorGenerator` 都有一个 `userData` 值：

- **用途**: 映射到 HKS 脚本中的函数
- **唯一性**: 在同一父状态机内必须唯一
- **范围**: 每个状态机有相对于其他状态机的偏移量
- **最佳实践**: 取父状态机中最后一个生成器的 `userData` 值 +1

---

## FromSoft 游戏中的应用

### 典型层次结构

```
Root (根状态机)
└── Master_SM (主状态机)
    ├── Idle_SM (待机状态机)
    │   ├── Stand_CMSG
    │   └── Crouch_CMSG
    ├── Move_SM (移动状态机)
    │   ├── Walk_CMSG
    │   └── Run_CMSG
    ├── Attack_SM (攻击状态机)
    │   ├── LightAttack_CMSG
    │   └── HeavyAttack_CMSG
    ├── Rolling_SM (翻滚状态机)
    │   └── Rolling_CMSG
    └── Damage_SM (受伤状态机)
        ├── Hit_CMSG
        └── Death_CMSG
```

### 命名约定

- **状态机**: `[Name]_SM`
- **CMSG**: `[Name]_CMSG`
- **混合器**: `[Name]_Blend`
- **状态信息**: 无后缀，直接使用名称

### 变量系统

Havok 变量类似于编程语言中的变量，用于：
- 在 HKS 脚本和行为文件之间传递信息
- 控制混合参数
- 存储状态信息

**变量类型**：
- `VARIABLE_TYPE_BOOL`: 布尔值
- `VARIABLE_TYPE_INT8/16/32`: 整数
- `VARIABLE_TYPE_REAL`: 浮点数
- `VARIABLE_TYPE_POINTER`: 指针
- `VARIABLE_TYPE_VECTOR3`: 三维向量
- `VARIABLE_TYPE_VECTOR4`: 四维向量
- `VARIABLE_TYPE_QUATERNION`: 四元数

### 事件系统

事件用于触发状态转换和通知。

**事件类型**：
- **Notify Events**: 通知事件，用于触发脚本函数
- **Transition Events**: 转换事件，用于触发状态切换

**事件触发时机**：
- 进入状态时（`enterNotifyEvents`）
- 退出状态时（`exitNotifyEvents`）
- 动画特定帧（通过 TAE 定义）

### TAE 集成

**TAE（TimeAct Editor）** 是 FromSoft 的动画事件编辑器。

**集成方式**：
- `CustomManualSelectorGenerator` 根据 TAE 段选择子生成器
- `offsetType` 参数决定使用哪种 TAE 段类型
- 动画事件在 TAE 中定义，触发 Havok 行为

---

## 参考资料

本文档基于以下来源整理：

- [Havok Behavior Editing - Souls Modding Wiki](http://soulsmodding.wikidot.com/topics:havok-behavior-editing)
- [Havok Behavior Reference - Souls Modding Wiki](http://soulsmodding.wikidot.com/reference:havok-behavior-reference)
- [Project Anarchy - Havok SDK Source Code](https://github.com/Bewolf2/projectanarchy)
- [Notes on Behavior Editing - Skyrim Nexus](https://www.nexusmods.com/skyrim/articles/50508)

---

## 附录：常用节点速查表

### 生成器（Generators）

| 节点类型 | 用途 | 关键属性 |
|---------|------|---------|
| `hkbStateMachine` | 状态机 | `states`, `wildcardTransitions` |
| `hkbClipGenerator` | 播放动画片段 | `animationName`, `playbackSpeed` |
| `CustomManualSelectorGenerator` | FromSoft 自定义选择器 | `animId`, `offsetType`, `enableScript` |
| `hkbManualSelectorGenerator` | 手动选择器 | `selectedGeneratorIndex` |
| `hkbBlenderGenerator` | 混合生成器 | `children`, `blendParameter` |
| `hkbPoseMatchingGenerator` | 姿态匹配生成器 | `worldFromModelRotation` |

### 修改器（Modifiers）

| 节点类型 | 用途 | 关键属性 |
|---------|------|---------|
| `hkbEvaluateExpressionModifier` | 表达式求值 | `expressions` |
| `hkbFootIkModifier` | 脚部 IK | `legs`, `raycastDistance` |
| `hkbGetHandleOnBoneModifier` | 获取骨骼句柄 | `handlePositionOut`, `handleRotationOut` |
| `hkbRotateCharacterModifier` | 旋转角色 | `degreesPerSecond`, `axisOfRotation` |
| `hkbTwistModifier` | 扭曲修改器 | `twistAngle`, `startBoneIndex` |

### 转换效果（Transition Effects）

| 节点类型 | 用途 | 关键属性 |
|---------|------|---------|
| `hkbBlendingTransitionEffect` | 混合过渡 | `duration`, `blendCurve` |

---

**文档版本**: 1.0  
**最后更新**: 2026-05-10  
**适用版本**: Havok 2018 (HK2018)
