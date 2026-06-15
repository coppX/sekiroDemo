# 只狼移动系统：Idle → Walk → Run → 急停 → 转身状态切换逻辑

## 概述

本文档详细分析玩家角色（狼，c0000）的地面移动状态机，涵盖从静止待机到行走、跑步、急停以及转身的完整状态转换流程。移动系统由三层协同工作：

1. **Havok 行为树层**（c0000.hkx.xml）—— 定义状态节点和转换拓扑
2. **Lua 驱动层**（c0000_transition.dec.lua）—— 根据输入和环境条件触发 `FireEvent()` 驱动状态转换
3. **动画事件层**（TAE）—— 在动画播放过程中触发脚步声、根运动、转身窗口等事件

核心设计理念：
- **速度分级**：Walk（MoveSpeedIndex=0）和 Run（MoveSpeedIndex=1）通过摇杆推力阈值切换
- **转身优化**：角度差 >60° 触发快速转身动画（QuickTurn），>120° 触发 180° 转身
- **姿态隔离**：站立（STAND）、蹲伏（CROUCH）、防御（GROUND_GUARD）各有独立的移动/转身动画集

---

## 核心状态定义

### Havok 状态机节点（HKB_STATE_*）

| 状态节点 | 说明 | 对应事件 |
|---------|------|---------|
| `HKB_STATE_IDLE` | 站立待机（循环） | `W_Idle` |
| `HKB_STATE_STAND_MOVE_START` | 站立移动启动 | `W_StandMoveStart` |
| `HKB_STATE_STAND_MOVE_LOOP` | 站立移动循环 | `W_StandMoveLoop` |
| `HKB_STATE_STAND_WALK_STOP` | 行走停止 | `W_StandWalkStop` |
| `HKB_STATE_STAND_RUN_STOP` | 跑步停止 | `W_StandRunStop` |
| `HKB_STATE_CROUCH_IDLE` | 蹲伏待机 | `W_CrouchIdle` |
| `HKB_STATE_CROUCH_MOVE_START` | 蹲伏移动启动 | `W_CrouchMoveStart` |
| `HKB_STATE_CROUCH_MOVE_LOOP` | 蹲伏移动循环 | `W_CrouchMoveLoop` |

### Lua 行为 ID（BEH_A_*）

| 行为 ID | 值 | 触发时机 | 作用 |
|---------|---|---------|------|
| `BEH_A_GROUND_MOVE_START` | 122 | 摇杆推力 >0 且当前非移动状态 | 启动地面移动 |
| `BEH_A_GROUND_MOVE_STOP` | 123 | 摇杆推力 =0 且当前处于移动状态 | 停止移动回到待机 |
| `BEH_A_GROUND_MOVE_SPEED_CHANGE` | 500 | 移动中速度档位变化 | Walk ↔ Run 平滑过渡 |

---

## 转换条件详解

### 1. Idle → Walk/Run（移动启动）

**触发行为**：`BEH_A_GROUND_MOVE_START`

**验证函数**（c0000_transition.dec.lua:5984-5988）：
```lua
g_ValidateActionTable[BEH_A_GROUND_MOVE_START] = function (current_hkb_state)
    if (env(1105) == TRUE or env(2000) == TRUE or env(3036, SP_EF_REF_TAE_ENABLE_ITEM_USE_MOVE) == TRUE) 
       and (GetLocomotionType() ~= LOCOMOTION_TYPE_MOVE or env(2000) == TRUE and env(3036, SP_EF_REF_TAE_ENABLE_ITEM_USE_MOVE) == TRUE) 
       and hkbGetVariable("MoveSpeedLevel") > 0 then
        return TRUE
    end
    return FALSE
end
```

**条件拆解**：
- `env(1105)` —— 摇杆有输入（非零推力）
- `env(2000)` —— 键盘移动键按下
- `GetLocomotionType() ~= LOCOMOTION_TYPE_MOVE` —— 当前不在移动状态
- `hkbGetVariable("MoveSpeedLevel") > 0` —— 移动速度等级 >0（摇杆推力足够）

**执行逻辑**（c0000_transition.dec.lua:2459-2523）：
1. 调用 `_SpeedUpdate()` 计算速度档位（Walk=0 / Run=1）
2. 调用 `_MoveDirectionUpdate()` 计算移动方向（前/后/左/右）
3. 根据当前姿态触发对应事件：
   - **站立姿态**：
     - 大角度转身（>60°）→ 触发 `_GroundQuickTurn()` 快速转身
     - 正常启动 → `FireEvent("W_StandMoveStart")`
   - **蹲伏姿态**：`FireEvent("W_CrouchMoveStart")`
   - **防御姿态**：`FireEvent("W_DeflectGuardMove")`

**速度档位判定**（_SpeedUpdate 函数，c0000_transition.dec.lua:5127-5162）：
```lua
function _SpeedUpdate(current_hkb_state)
    local stick_level = hkbGetVariable("MoveSpeedLevel")  -- 摇杆推力 0.0-1.0
    local moveSpeedIndex = hkbGetVariable("MoveSpeedIndex")  -- 当前档位
    
    if moveSpeedIndex == 0 then  -- 当前是 Walk
        if stick_level > PRM_RUN_STICK_LEVEL_WALK_TO_RUN then
            SetVariable("MoveSpeedIndex", 1)  -- 切换到 Run
        end
    else  -- 当前是 Run
        if stick_level > PRM_RUN_STICK_LEVEL_RUN_TO_WALK then
            SetVariable("MoveSpeedIndex", 1)  -- 保持 Run
        else
            SetVariable("MoveSpeedIndex", 0)  -- 降回 Walk
        end
    end
end
```

**阈值常量**（推测值，未在反编译代码中直接定义）：
- `PRM_RUN_STICK_LEVEL_WALK_TO_RUN` ≈ 0.6-0.7（Walk → Run 触发阈值）
- `PRM_RUN_STICK_LEVEL_RUN_TO_WALK` ≈ 0.5（Run → Walk 回落阈值，带滞后防抖）

---

### 2. Walk/Run → Idle（移动停止）

**触发行为**：`BEH_A_GROUND_MOVE_STOP`

**验证函数**（c0000_transition.dec.lua:5989-6009）：
```lua
g_ValidateActionTable[BEH_A_GROUND_MOVE_STOP] = function (current_hkb_state)
    -- 条件1：当前处于移动状态
    if GetLocomotionType() == LOCOMOTION_TYPE_MOVE 
       -- 条件2：摇杆推力归零
       and 0 >= hkbGetVariable("MoveSpeedLevel") 
       -- 条件3：不在停止动画播放中（防止重复触发）
       and env(3036, SP_EF_REF_TAE_STOPING_WALK) == FALSE 
       and env(3036, SP_EF_REF_TAE_STOPING_RUN) == FALSE then
        return TRUE
    end
    return FALSE
end
```

**执行逻辑**（c0000_transition.dec.lua:2527-2600）：
1. 读取当前转身角度 `TurnAngle` 和扭转角度 `TwistLowerRootAngle`
2. **角度判定**：
   - `|TurnAngle| > 60°` 或 `|TwistAngle| > 0°` → 触发快速转身 `_GroundQuickTurn()`
   - 否则 → 播放正常停止动画
3. **姿态分支**：
   - **蹲伏**：
     - 跑步中 → `FireEvent("W_CrouchRunStop")`
     - 行走中 → `FireEvent("W_CrouchWalkStop")`
   - **站立**：
     - 跑步中 → `FireEvent("W_StandRunStop")`
     - 行走中 → `FireEvent("W_StandWalkStop")`
   - **防御**：`FireEvent("W_DeflectGuardIdle")`

**停止动画特征**（从 TAE 事件推断）：
- 急停动画包含减速根运动（RootMotion），持续 0.3-0.5 秒
- 跑步停止比行走停止有更长的滑行距离
- 停止动画结束后自动转换回对应的 Idle 状态

---

### 3. Walk ↔ Run（速度档位切换）

**触发行为**：`BEH_A_GROUND_MOVE_SPEED_CHANGE`

**验证函数**（c0000_transition.dec.lua:6010-6014）：
```lua
g_ValidateActionTable[BEH_A_GROUND_MOVE_SPEED_CHANGE] = function (current_hkb_state)
    if env(3036, SP_EF_REF_TAE_ENABLE_MOVE_SPEED_CHANGE_CANCEL) == TRUE 
       and hkbGetVariable("MoveSpeedIndex") ~= g_beforeMoveSpeedIndex 
       and hkbGetVariable("MoveSpeedLevel") > 0 then
        return TRUE
    end
    return FALSE
end
```

**条件说明**：
- `SP_EF_REF_TAE_ENABLE_MOVE_SPEED_CHANGE_CANCEL` —— 当前动画允许速度切换（某些攻击动画会禁用）
- `MoveSpeedIndex ~= g_beforeMoveSpeedIndex` —— 速度档位发生变化（0↔1）
- `MoveSpeedLevel > 0` —— 仍在移动中

**执行逻辑**（c0000_transition.dec.lua:2602-2604）：
```lua
SetVariable("Selector_UseTransitionEffect", SELECTOR_USE_TE_TAE_BLEND_SYNC)
FireEventNoReset("W_StandMoveLoopSync")
```

**关键机制**：
- 使用 `FireEventNoReset()` —— 不重置当前状态，保持移动循环
- `SELECTOR_USE_TE_TAE_BLEND_SYNC` —— 启用同步混合，确保 Walk/Run 动画平滑过渡
- 不触发 MoveStart/MoveStop，直接在 MoveLoop 内部切换

---

### 4. 快速转身（QuickTurn）

**触发函数**：`_GroundQuickTurn(current_hkb_state)`（c0000_transition.dec.lua:5242-5298）

**角度判定逻辑**：
```lua
function _GroundQuickTurn(current_hkb_state)
    local turnAngle = hkbGetVariable("TurnAngle")  -- 摇杆方向与角色朝向的夹角
    local twistAngle = -hkbGetVariable("TwistLowerRootAngle")  -- 下半身扭转角度
    local smallTurnAngle = 120  -- 90°/180° 转身分界线
    local smallTwistAngle = 120
    
    -- 站立姿态转身
    if currentStyle == STYLE_TYPE_STAND then
        if turnAngle > 0 or twistAngle > 0 then  -- 向右转
            if math.abs(turnAngle) > 120 or math.abs(twistAngle) > 120 then
                FireEvent("W_StandQuickTurnRight180")  -- 180° 转身
            else
                FireEvent("W_StandQuickTurnRight90")   -- 90° 转身
            end
        else  -- 向左转
            if math.abs(turnAngle) > 120 or math.abs(twistAngle) > 120 then
                FireEvent("W_StandQuickTurnLeft180")
            else
                FireEvent("W_StandQuickTurnLeft90")
            end
        end
    end
    -- 蹲伏/防御姿态有类似逻辑...
end
```

**触发时机**：
1. **移动启动时**（Idle → Move）：角度差 >60° 时优先转身再移动
2. **移动停止时**（Move → Idle）：角度差 >60° 时转身代替停止动画
3. **移动中转向**：通过 `W_StandMoveQuickTurnLeft180/Right180` 事件

**转身动画分类**：
- **90° 转身**（60°-120°）：快速侧身调整，约 0.3 秒
- **180° 转身**（>120°）：完整转身动画，约 0.5 秒
- **移动中转身**：保持移动状态的转身（如 `W_StandMoveQuickTurnLeft180`）

**方向判定**（_MoveDirectionUpdate 函数，c0000_transition.dec.lua:5188-5204）：
```lua
function _MoveDirectionUpdate()
    local angle = hkbGetVariable("TurnAngle")  -- 或 MoveAngle（锁定时）
    
    if math.abs(angle) < 55 then
        SetVariable("MoveDirection", 0)  -- 前方
    elseif math.abs(angle) > 125 then
        SetVariable("MoveDirection", 1)  -- 后方
    elseif angle < 0 then
        SetVariable("MoveDirection", 2)  -- 左侧
    else
        SetVariable("MoveDirection", 3)  -- 右侧
    end
end
```

---

## 动画事件时间轴（TAE）

### Idle 动画事件（a000_000100 StandIdle）

**时长**：3.333 秒（循环）

**关键事件**：
- `type=67 AllowedToTurn`（0.000s-2.767s）—— 允许转身窗口，几乎全程可转身
- `type=237 MovementParam_TurnSpeed`（0.000s-2.767s）—— 转向速度参数（值=1000）
- `type=946 FootstepStrike`（0.067s, 0.600s, 1.233s, 1.933s, 2.567s）—— 脚步落地标记（左右脚交替）
- `type=112 PlayFootstepSound_Generic`（对应脚步落地时刻）—— 脚步声触发
- `type=700 DefaultRootMotionParams`（0.000s-3.333s）—— 根运动参数（Idle 无位移）

**观察**：
- Idle 动画有 4 个变体（a000_000100-000103），随机播放增加自然感
- 每个循环约 4 次脚步声（呼吸/重心转移动作）
- 全程允许转身，响应性极高

---

### Walk/Run 循环动画事件（推断）

**StandMoveLoop 特征**（基于 mindmap 数据）：
- **根运动驱动**：通过 `type=700 DefaultRootMotionParams` 控制移动速度
- **脚步节奏**：Walk 约 1.5 步/秒，Run 约 2.5 步/秒
- **转身窗口**：移动中持续开启 `AllowedToTurn`，允许动态转向
- **速度参数**：`type=607 MovementCharacteristic_Speed` 控制动画播放速率

**停止动画特征**（StandWalkStop / StandRunStop）：
- **减速根运动**：通过负向根运动实现滑行停止
- **时长**：Walk 停止约 0.3s，Run 停止约 0.5s
- **最后脚步**：停止动画包含最后一次 `FootstepStrike` 事件

---

## 完整状态转换流程图

```
┌─────────────────────────────────────────────────────────────────┐
│                        玩家移动状态机                              │
└─────────────────────────────────────────────────────────────────┘

                            ┌──────────┐
                            │  W_Idle  │ ◄─────────┐
                            │ (待机)    │           │
                            └────┬─────┘           │
                                 │                 │
                    摇杆推力 > 0  │                 │ 摇杆推力 = 0
                                 │                 │
                    ┌────────────▼─────────────┐   │
                    │  角度判定                 │   │
                    │  |TurnAngle| > 60°?     │   │
                    └─┬──────────────────────┬─┘   │
                      │ YES                  │ NO  │
                      │                      │     │
              ┌───────▼────────┐    ┌────────▼──────────┐
              │ _GroundQuickTurn│    │ W_StandMoveStart  │
              │  (快速转身)      │    │  (移动启动)        │
              └───────┬─────────┘    └────────┬──────────┘
                      │                       │
                      └───────────┬───────────┘
                                  │
                        ┌─────────▼──────────┐
                        │ W_StandMoveLoop    │ ◄──┐
                        │  (移动循环)         │    │
                        │                    │    │
                        │ MoveSpeedIndex:    │    │
                        │  0 = Walk          │    │ 速度档位变化
                        │  1 = Run           │    │ (BEH_A_GROUND_MOVE_SPEED_CHANGE)
                        └─────────┬──────────┘    │
                                  │               │
                    摇杆推力变化   │               │
                                  ├───────────────┘
                                  │
                    摇杆推力 = 0   │
                                  │
                    ┌─────────────▼─────────────┐
                    │  角度判定                  │
                    │  |TurnAngle| > 60°?      │
                    └─┬──────────────────────┬──┘
                      │ YES                  │ NO
                      │                      │
              ┌───────▼────────┐    ┌────────▼──────────┐
              │ _GroundQuickTurn│    │ W_StandWalkStop / │
              │  (转身回待机)    │    │ W_StandRunStop    │
              └───────┬─────────┘    │  (急停动画)        │
                      │              └────────┬──────────┘
                      │                       │
                      └───────────┬───────────┘
                                  │
                                  ▼
                            ┌──────────┐
                            │  W_Idle  │
                            │ (回到待机)│
                            └──────────┘
```

**关键决策点**：
1. **启动时角度检查**：>60° 先转身，≤60° 直接移动
2. **速度档位切换**：在 MoveLoop 内部通过 `FireEventNoReset` 平滑过渡
3. **停止时角度检查**：>60° 转身代替停止动画，≤60° 播放减速停止

---

## Lua 驱动流程（每帧执行）

### 帧循环调用栈

```
c0000.dec.lua : Update()  (顶层帧刷新)
    ↓
c0000.dec.lua : UpdateState(current_hkb_state)
    ↓
c0000_transition.dec.lua : Control(current_hkb_state)
    ↓
c0000_transition.dec.lua : Validate(current_hkb_state)
    ↓ (按 g_behaviorValidateOrder 优先级遍历)
    ↓
g_ValidateActionTable[BEH_A_GROUND_MOVE_START/STOP/SPEED_CHANGE]()
    ↓ (验证通过)
    ↓
_ActivateBehavior(BEH_A_GROUND_MOVE_*)
    ↓
FireEvent("W_StandMoveStart") / FireEvent("W_StandWalkStop") / ...
    ↓ (触发 Havok 状态机转换)
    ↓
Havok Behavior Graph 执行状态转换
    ↓
播放对应动画 + 触发 TAE 事件（脚步声、根运动等）
```

### 关键变量读取（通过 env() 和 hkbGetVariable()）

| 变量名 | 类型 | 说明 | 典型值 |
|--------|------|------|--------|
| `env(1105)` | 引擎查询 | 摇杆是否有输入 | TRUE/FALSE |
| `env(2000)` | 引擎查询 | 键盘移动键是否按下 | TRUE/FALSE |
| `hkbGetVariable("MoveSpeedLevel")` | Havok 变量 | 摇杆推力（归一化） | 0.0-1.0 |
| `hkbGetVariable("MoveSpeedIndex")` | Havok 变量 | 速度档位 | 0=Walk, 1=Run |
| `hkbGetVariable("TurnAngle")` | Havok 变量 | 摇杆方向与角色朝向夹角 | -180° ~ +180° |
| `hkbGetVariable("TwistLowerRootAngle")` | Havok 变量 | 下半身扭转角度 | -180° ~ +180° |
| `env(3036, SP_EF_REF_TAE_MOVING_RUN)` | 特效查询 | 当前是否在跑步 | TRUE/FALSE |
| `env(3036, SP_EF_REF_TAE_STOPING_WALK)` | 特效查询 | 是否在播放停止动画 | TRUE/FALSE |

### 优先级表（g_behaviorValidateOrder）

移动相关行为在验证表中的优先级（数值越小越优先）：
```lua
-- 推测优先级（实际值需查看完整 g_behaviorValidateOrder 表）
BEH_A_GROUND_MOVE_STOP         -- 优先级较高（停止响应要快）
BEH_A_GROUND_MOVE_SPEED_CHANGE -- 中等优先级
BEH_A_GROUND_MOVE_START        -- 优先级较低（启动可以稍慢）
```

**设计意图**：停止指令优先于启动指令，避免"摇杆归零但角色继续移动"的延迟感。

---

## 姿态差异对比

### 站立（STYLE_TYPE_STAND）

- **移动事件**：`W_StandMoveStart` → `W_StandMoveLoop` → `W_StandWalkStop/W_StandRunStop`
- **转身事件**：`W_StandQuickTurnLeft90/180` / `W_StandQuickTurnRight90/180`
- **特点**：移动速度最快，转身最灵活

### 蹲伏（STYLE_TYPE_CROUCH）

- **移动事件**：`W_CrouchMoveStart` → `W_CrouchMoveLoop` → `W_CrouchWalkStop/W_CrouchRunStop`
- **转身事件**：`W_CrouchQuickTurnLeft90/180` / `W_CrouchQuickTurnRight90/180`
- **特点**：移动速度较慢，转身角度受限，但降低敌人警觉

### 防御（STYLE_TYPE_GROUND_GUARD）

- **移动事件**：`W_DeflectGuardMove` → `W_DeflectGuardIdle`
- **转身事件**：`W_DeflectGuardQuickTurnLeft90/180` / `W_DeflectGuardQuickTurnRight90/180`
- **特点**：只能慢速移动（无 Run 档位），转身最慢，但保持防御姿态

---

## 特殊情况处理

### 1. 冲刺（Sprint）停止

**条件**：`env(3036, SP_EF_REF_TAE_MOVING_SPRINT) == TRUE`

**逻辑**（c0000_transition.dec.lua:2567-2581）：
```lua
if env(3036, SP_EF_REF_TAE_MOVING_SPRINT) == TRUE then
    local angle = hkbGetVariable("TurnAngle")
    if hkbGetVariable("MoveSpeedLevel") > 0 and math.abs(angle) < SPRINT_BRAKE_ANGLE then
        FireEventNoReset("W_StandMoveStartFromSprint")  -- 冲刺降速到跑步
    else
        FireEvent("W_SprintStopReady")  -- 冲刺急停
    end
end
```

**特点**：
- 冲刺停止有专门的减速动画（`W_SprintStopReady`）
- 如果摇杆仍有输入且角度小，可以平滑降速到普通跑步
- `SPRINT_BRAKE_ANGLE` 推测为 45°-60°

### 2. 物品使用中移动

**条件**：`env(3036, SP_EF_REF_TAE_ENABLE_ITEM_USE_MOVE) == TRUE`

**逻辑**：
- 使用 `W_StandMoveLowerStart` / `W_CrouchMoveLowerLoop` 事件
- 只播放下半身移动动画，上半身保持物品使用动作
- 通过 `SetVariable("StartTime_01", ...)` 同步动画时间

### 3. 沼泽/水边区域

**条件**：`env(3036, SP_EF_REF_IN_SWAMP_AREA) == TRUE`

**效果**（_SpeedUpdate 函数）：
- 强制降低移动速度
- 禁用冲刺（Sprint）
- 需要更长的摇杆推力才能触发 Run

---

## 关键常量与阈值总结

| 常量名 | 值 | 说明 |
|--------|---|------|
| `BEH_A_GROUND_MOVE_START` | 122 | 地面移动启动行为 ID |
| `BEH_A_GROUND_MOVE_STOP` | 123 | 地面移动停止行为 ID |
| `BEH_A_GROUND_MOVE_SPEED_CHANGE` | 500 | 速度档位切换行为 ID |
| `STYLE_TYPE_STAND` | （值未知） | 站立姿态类型 |
| `STYLE_TYPE_CROUCH` | （值未知） | 蹲伏姿态类型 |
| `STYLE_TYPE_GROUND_GUARD` | （值未知） | 防御姿态类型 |
| **角度阈值** | | |
| 转身触发角度 | 60° | 移动启动/停止时触发快速转身的最小角度 |
| 90°/180° 分界线 | 120° | 决定播放 90° 还是 180° 转身动画 |
| 方向判定前方 | < 55° | 判定为向前移动 |
| 方向判定后方 | > 125° | 判定为向后移动 |
| **速度阈值（推测）** | | |
| Walk → Run | ~0.6-0.7 | 摇杆推力超过此值切换到跑步 |
| Run → Walk | ~0.5 | 摇杆推力低于此值降回行走（带滞后） |

---

## 参考文件索引

### Lua 脚本
- [action/script/c0000_transition.dec.lua](../../action/script/c0000_transition.dec.lua)
  - 行 97-98：`BEH_A_GROUND_MOVE_START/STOP` 定义
  - 行 2459-2600：移动启动/停止/速度切换执行逻辑
  - 行 5127-5162：`_SpeedUpdate()` 速度档位计算
  - 行 5188-5204：`_MoveDirectionUpdate()` 方向判定
  - 行 5242-5298：`_GroundQuickTurn()` 快速转身逻辑
  - 行 5984-6014：`g_ValidateActionTable` 移动行为验证函数

- [action/script/c0000_define.dec.lua](../../action/script/c0000_define.dec.lua)
  - 姿态类型常量（`STYLE_TYPE_*`）
  - 状态类型常量（`STATE_TYPE_*`）

- [action/script/c0000.dec.lua](../../action/script/c0000.dec.lua)
  - `Update()` / `UpdateState()` 帧循环入口

### Havok 行为树
- [chr/c0000-behbnd-dcx/c0000.hkx.xml](../../chr/c0000-behbnd-dcx/c0000.hkx.xml)
  - 状态节点定义（`W_Idle`, `W_StandMoveLoop` 等）
  - 状态转换拓扑

### 动画事件
- [doc/move/sekiro_movement_full_mindmap.txt](sekiro_movement_full_mindmap.txt)
  - TAE 事件完整解析（脚步声、根运动、转身窗口等）

### ID 映射表
- [action/eventnameid.txt](../../action/eventnameid.txt)
  - 事件名称 ↔ ID 映射（如 `1054 = "W_Idle"`）
- [action/statenameid.txt](../../action/statenameid.txt)
  - 状态节点名称 ↔ ID 映射
- [action/variablenameid.txt](../../action/variablenameid.txt)
  - Havok 变量名称 ↔ ID 映射

---

## 设计亮点分析

### 1. 响应性优化
- **转身优先**：大角度转向时先播放转身动画，避免"滑步转向"的不自然感
- **停止优先级高**：验证表中停止行为优先于启动，确保"松手即停"的即时反馈
- **全程可转身**：Idle 和 MoveLoop 动画几乎全程开启 `AllowedToTurn` 窗口

### 2. 平滑过渡
- **速度档位滞后**：Walk → Run 和 Run → Walk 使用不同阈值，防止临界点抖动
- **同步混合**：速度切换使用 `SELECTOR_USE_TE_TAE_BLEND_SYNC`，保持步伐节奏连续
- **根运动驱动**：所有移动通过动画根运动实现，避免代码硬编码位移

### 3. 姿态隔离
- 每种姿态（站立/蹲伏/防御）有独立的移动/转身动画集
- 姿态切换时自动重置移动状态，避免状态污染

### 4. 环境适应
- 沼泽/水边区域自动降速
- 物品使用中支持下半身移动
- 冲刺停止有专门的减速动画

---

## 未解之谜与推测

### 1. 速度阈值常量
`PRM_RUN_STICK_LEVEL_WALK_TO_RUN` 和 `PRM_RUN_STICK_LEVEL_RUN_TO_WALK` 未在反编译代码中找到定义，可能：
- 定义在引擎侧（C++ 代码）
- 存储在外部参数文件（如 `.param` 文件）
- 硬编码在 `GetMoveSpeed()` 函数内部

### 2. 转身角度的双重判定
代码同时检查 `TurnAngle`（摇杆方向）和 `TwistLowerRootAngle`（下半身扭转），推测：
- `TurnAngle`：玩家输入意图
- `TwistLowerRootAngle`：当前动画姿态的实际扭转
- 双重判定确保转身触发既响应输入，又符合动画状态

### 3. MoveSpeedLevelReal 的作用
`_SpeedUpdate()` 中计算了 `MoveSpeedLevelReal`（通过 `GetMoveSpeed()` 函数），但其用途未在当前代码中明确，可能：
- 传递给动画系统控制播放速率
- 用于根运动缩放
- 影响音效音调（脚步声频率）

---

## 总结

只狼的移动系统通过三层协同（Havok 状态机 + Lua 驱动 + TAE 事件）实现了高响应性和自然流畅的移动体验。核心设计包括：

1. **角度驱动转身**：>60° 触发快速转身，>120° 播放 180° 转身
2. **速度分级控制**：Walk/Run 通过摇杆推力阈值切换，带滞后防抖
3. **姿态独立动画**：站立/蹲伏/防御各有专属移动/转身动画集
4. **优先级调度**：停止 > 速度切换 > 启动，确保即时响应
5. **环境自适应**：沼泽降速、物品使用中移动、冲刺减速等特殊处理

该系统的精妙之处在于**将复杂的状态转换逻辑隐藏在简洁的验证函数和角度判定中**，玩家只需推动摇杆，系统自动选择最合适的动画和转换路径。
