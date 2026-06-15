# c1010 敌人架构分析：落武者（八双）

> 本文档以 c1010（落武者·八双流派）为例，完整解析只狼敌人 AI 的四层架构设计，包括场景逻辑、战斗决策、角色行为和 Havok 状态机的协同工作机制。
>
> **分析对象**：
> - 场景逻辑：[script/m11_02_00_00-luabnd-dcx/lua/101000_logic.dec.lua](../../script/m11_02_00_00-luabnd-dcx/lua/101000_logic.dec.lua)
> - 战斗决策：[script/m11_02_00_00-luabnd-dcx/lua/101010_battle.dec.lua](../../script/m11_02_00_00-luabnd-dcx/lua/101010_battle.dec.lua)
> - 角色行为：[action/script/c1010.dec.lua](../../action/script/c1010.dec.lua)
> - Havok 状态机：[chr/c1010-behbnd-dcx/Behaviors/c1010.hkx.xml](../../chr/c1010-behbnd-dcx/Behaviors/c1010.hkx.xml)、[chr/c1010-behbnd-dcx/Behaviors/c9997.hkx.xml](../../chr/c1010-behbnd-dcx/Behaviors/c9997.hkx.xml)

---

## 1. 架构总览：四层协同模型

只狼的敌人 AI 采用**分层解耦**设计，每层负责不同抽象级别的决策与执行：

```
┌─────────────────────────────────────────────────────────────────┐
│  第一层：场景逻辑层 (101000_logic.dec.lua)                        │
│  职责：高层路由、事件响应、特殊状态处理                            │
│  输出：决定当前应该执行哪个 TopGoal                                │
└────────────────────┬────────────────────────────────────────────┘
                     │ ai:AddTopGoal(GOAL_Ochimusha_hassou_101010_Battle, ...)
                     ↓
┌─────────────────────────────────────────────────────────────────┐
│  第二层：战斗决策层 (101010_battle.dec.lua)                       │
│  职责：根据距离/状态/环境选择具体攻击动作                          │
│  输出：动画 ID（如 3000, 3002, 3007）                             │
└────────────────────┬────────────────────────────────────────────┘
                     │ goal:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3000, ...)
                     ↓
┌─────────────────────────────────────────────────────────────────┐
│  第三层：角色行为层 (c1010.dec.lua)                               │
│  职责：状态节点回调、通用反应处理（受击/弹反/死亡）                 │
│  输出：Fire("W_Idle") 等 Havok 事件                               │
└────────────────────┬────────────────────────────────────────────┘
                     │ FireEvent("W_Idle") / hkbFireEvent(...)
                     ↓
┌─────────────────────────────────────────────────────────────────┐
│  第四层：Havok 状态机层 (c1010.hkx.xml + c9997.hkx.xml)          │
│  职责：状态转换规则、动画播放、物理碰撞                            │
│  输出：实际播放的动画帧                                            │
└─────────────────────────────────────────────────────────────────┘
```

### 1.1 层间通信机制

| 通信方向 | 接口 | 数据类型 | 示例 |
|---------|------|---------|------|
| 逻辑层 → 决策层 | `ai:AddTopGoal(goalID, ...)` | Goal 栈操作 | `GOAL_Ochimusha_hassou_101010_Battle` |
| 决策层 → 行为层 | `goal:AddSubGoal(GOAL_COMMON_AttackTunableSpin, life, animID, ...)` | 动画 ID + 参数 | `3000`（普通斩击）、`3002`（突进斩） |
| 行为层 → 状态机 | `Fire("W_EventName")` / `hkbFireEvent(...)` | 事件名称 | `"W_Idle"`、`"W_Event21001"` |
| 状态机 → 行为层 | 状态节点激活回调 | 函数调用 | `Event20000_onUpdate()` |

---

## 2. 第一层：场景逻辑层 (101000_logic.dec.lua)

### 2.1 职责定位

场景逻辑层是**敌人实例的入口点**，负责：
1. **高优先级事件处理**：玩家死亡、复活、忍杀、烟雾弹等全局事件
2. **特殊状态路由**：傀儡咒、念珠反应、关卡事件请求
3. **兜底决策**：根据 AI 状态（Caution/Find/Battle）选择合适的 TopGoal

### 2.2 核心执行流程

```lua
Logic.Main = function (self, ai)
    -- 1. 注册观察目标（SpEffect、区域触发）
    ai:AddObserveSpecialEffectAttribute(TARGET_SELF, 200299)
    ai:AddObserveRegion(30, TARGET_SELF, COMMON_REGION_FORCE_WALK_M11_0)
    
    -- 2. 锁定检测（触发剧情 flag）
    if ai:IsLockOnTarget(TARGET_LOCALPLAYER, TARGET_SELF) and 
       ai:HasSpecialEffectId(TARGET_SELF, 3101110) then
        ai:SetEventFlag(11125650, true)  -- 玩家锁定落武者时设置剧情标记
    end
    
    -- 3. 高优先级短路（玩家死亡/忍杀/烟雾等）
    if COMMON_HiPrioritySetup(ai, COMMON_FLAG_EXPERIMENT) then
        return true  -- 被高优先级逻辑接管，跳过后续
    end
    
    -- 4. 特殊状态：傀儡咒
    if ai:HasSpecialEffectId(TARGET_SELF, 220020) then
        if self.KugutsuAct(ai, goal) then return true end
    
    -- 5. 特殊状态：念珠反应（玩家获得新念珠时的演出）
    elseif ai:IsFinishTimer(AI_TIMER_TEKIMAWASHI_REACTION) == false then
        JuzuReaction(ai, goal, 0, 20105, 20107)
        return true
    end
    
    -- 6. 关卡事件请求（场景脚本明令"去哪里/做什么"）
    local eventRequest = ai:GetEventRequest()
    if eventRequest == 10 then
        ai:SetEventMoveTarget(9622490)
        if ai:GetDist_Point(POINT_EVENT) > 3 then
            ai:AddTopGoal(GOAL_COMMON_ApproachTarget, 3, POINT_EVENT, 0, TARGET_SELF, false, -1)
        end
    elseif eventRequest == 12 then
        if not ai:HasSpecialEffectId(TARGET_SELF, 200004) then
            ai:AddTopGoal(GOAL_COMMON_AttackTunableSpin, 1, 1040, TARGET_ENE_0, 9999, 0, 0, 0, 0)
        end
        ai:SetEventMoveTarget(9622492)
        -- ... 更多事件分支
    end
    
    -- 7. 兜底：根据 Caution/Find/Battle 状态选择 TopGoal
    COMMON_EzSetup(ai, COMMON_FLAG_EXPERIMENT)
end
```

### 2.3 关键机制解析

#### 2.3.1 COMMON_HiPrioritySetup

这是**所有敌人共享的紧急事件处理器**（定义于 `aicommon-luabnd-dcx/lua/common_logic_func.dec.lua`），处理：

| SpEffect ID | 含义 | 行为 |
|------------|------|------|
| 110060 | 玩家死亡 | 清除目标，播放胜利动画 |
| 120 | 玩家复活 | 重新搜索玩家 |
| 110030 | 玩家被忍杀 | 清除目标 |
| 110125 | 玩家破防 | 可能触发追击 |
| 8300 | 烟花散弹 | 进入搜索状态 |
| 220010 | 自身被血雾致盲 | 播放致盲动画 |

#### 2.3.2 COMMON_EzSetup

兜底路由器，根据 AI 状态选择 TopGoal：

```lua
-- 伪代码简化
if ai:IsBattleState() then
    _COMMON_SetBattleGoal(ai)  -- 进入战斗决策层
elseif ai:IsFindState() then
    ai:AddTopGoal(GOAL_COMMON_ApproachTarget, ...)  -- 追击玩家
elseif ai:IsCautionState() then
    ai:AddTopGoal(GOAL_COMMON_NonBattleAct, ...)  -- 警戒巡逻
end
```

---

## 3. 第二层：战斗决策层 (101010_battle.dec.lua)

### 3.1 职责定位

战斗决策层是**敌人 AI 的大脑**，负责：
1. **距离感知**：根据与玩家的距离选择合适的攻击
2. **权重决策**：为每个可用动作分配概率权重
3. **冷却管理**：防止同一招式短时间内重复使用
4. **空间检测**：避免在墙角使用需要空间的招式

### 3.2 核心决策流程

```lua
Goal.Activate = function (self, ai, goal)
    Init_Pseudo_Global(ai, goal)
    local probabilities, acts, paramTbls = {}, {}, {}
    Common_Clear_Param(probabilities, acts, paramTbls)
    
    local distanceEnemy = ai:GetDist(TARGET_ENE_0)
    
    -- ===== 特殊状态优先级 =====
    if ai:HasSpecialEffectId(TARGET_ENE_0, 3170200) then  -- 玩家处决态
        probabilities[25] = 1000  -- 后撤
        probabilities[1] = 1
    
    -- ===== 距离分段决策 =====
    elseif distanceEnemy >= 7 then
        probabilities[1] = 1      -- 普通斩击（低权重）
        probabilities[2] = 200    -- 突进斩
        probabilities[5] = 100    -- 冲刺攻击
        probabilities[23] = 600   -- 侧步移动（最高权重）
    
    elseif distanceEnemy >= 5 then
        probabilities[1] = 100
        probabilities[2] = 200
        probabilities[5] = 100
        probabilities[23] = 1200  -- 侧步权重进一步提升
    
    elseif distanceEnemy >= 3 then
        probabilities[1] = 100
        probabilities[2] = 200
        probabilities[6] = 300    -- 近距离连击
        probabilities[23] = 1200
    
    elseif distanceEnemy >= 1 then
        probabilities[1] = 200
        probabilities[4] = 100    -- 快速斩
        probabilities[6] = 200
        probabilities[23] = 0     -- 太近不侧步
    
    else  -- 贴身
        probabilities[1] = 100
        probabilities[4] = 200
        probabilities[6] = 400    -- 贴身连击权重最高
    end
    
    -- ===== 空间约束 =====
    if SpaceCheck(ai, goal, 90, 1) == false and 
       SpaceCheck(ai, goal, -90, 1) == false then
        probabilities[23] = 0  -- 左右都没空间，取消侧步
    end
    
    if SpaceCheck(ai, goal, 180, 2) == false then
        probabilities[24] = 0  -- 后方没空间，取消后跳
    end
    
    -- ===== 冷却修正 =====
    probabilities[1] = SetCoolTime(ai, goal, 3000, 5, probabilities[1], 1)
    probabilities[2] = SetCoolTime(ai, goal, 3002, 10, probabilities[2], 1)
    
    -- ===== 绑定动作实现 =====
    acts[1] = REGIST_FUNC(ai, goal, self.Act01)  -- 普通斩击
    acts[2] = REGIST_FUNC(ai, goal, self.Act02)  -- 突进斩
    acts[6] = REGIST_FUNC(ai, goal, self.Act06)  -- 近距离连击
    acts[23] = REGIST_FUNC(ai, goal, self.Act23) -- 侧步移动
    -- ... 更多动作
    
    -- ===== 加权随机选择并执行 =====
    local actAfter = REGIST_FUNC(ai, goal, self.ActAfter_AdjustSpace)
    Common_Battle_Activate(ai, goal, probabilities, acts, actAfter, paramTbls)
end
```

### 3.3 典型动作实现

#### Act01：普通斩击（动画 3000）

```lua
Goal.Act01 = function (ai, goal, paramTbl)
    local stopDist = 3.5 - ai:GetMapHitRadius(TARGET_SELF)
    local canRunDist = stopDist + 2
    local forceRunMinDist = stopDist + 2
    
    -- 接近玩家
    Approach_Act_Flex(ai, goal, stopDist, canRunDist, forceRunMinDist, 
                      100, 0, 1.5, 3)
    
    -- 播放攻击动画（两段连击）
    goal:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10, 3000, 
                    TARGET_ENE_0, 3, 0.5, 90, 0, 0)
    goal:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3001, 
                    TARGET_ENE_0, 9999, 0, 0)
    
    return 100  -- GetWellSpace_Odds（攻击后拉开距离的概率）
end
```

#### Act23：侧步移动（带防御）

```lua
Goal.Act23 = function (ai, goal, paramTbl)
    local guardStateId = -1
    if ai:IsFinishTimer(0) == false then
        guardStateId = 9910  -- 侧步时保持防御姿态
    end
    
    -- 决定左移还是右移
    local right = 0
    if SpaceCheck(ai, goal, -90, 1) == true then
        if SpaceCheck(ai, goal, 90, 1) == true then
            -- 两边都有空间，选择远离玩家的方向
            if ai:IsInsideTargetEx(TARGET_ENE_0, TARGET_SELF, AI_DIR_TYPE_R, 180, 999) then
                right = 1
            else
                right = 0
            end
        else
            right = 0  -- 只有左边有空间
        end
    elseif SpaceCheck(ai, goal, 90, 1) == true then
        right = 1  -- 只有右边有空间
    end
    
    ai:SetNumber(10, right)
    ai:SetTimer(2, 3)
    goal:AddSubGoal(GOAL_COMMON_SidewayMove, 3, TARGET_ENE_0, right, 
                    ai:GetRandam_Int(30, 45), true, true, guardStateId)
    
    return 100
end
```

### 3.4 剑击反应系统（Kengeki）

落武者具备**剑击反应能力**，可以在被玩家攻击时做出即时反击：

```lua
Goal.Kengeki_Activate = function (self, ai, goal)
    local kengekiEffect = ReturnKengekiSpecialEffect(ai)
    if kengekiEffect == 0 then return false end
    
    local probabilities, acts = {}, {}
    local distanceEnemy = ai:GetDist(TARGET_ENE_0)
    
    -- 根据剑击类型选择反击
    if kengekiEffect == 200200 or kengekiEffect == 200205 then  -- 上段攻击
        if distanceEnemy >= 2 then
            probabilities[50] = 100  -- 距离远，不反击
        else
            probabilities[1] = 100   -- 反击斩 3050
            probabilities[2] = 100   -- 反击斩 3051
            probabilities[50] = 50
        end
    
    elseif kengekiEffect == 200210 or kengekiEffect == 200215 then  -- 下段攻击
        if distanceEnemy >= 2 then
            probabilities[50] = 100
        else
            probabilities[10] = 20   -- 特殊反击 3076
            probabilities[24] = 0    -- 禁用后跳
        end
    end
    
    acts[1] = REGIST_FUNC(ai, goal, self.Kengeki01)  -- 反击动画 3050
    acts[10] = REGIST_FUNC(ai, goal, self.Kengeki10) -- 反击动画 3076
    acts[50] = REGIST_FUNC(ai, goal, self.NoAction)  -- 不反击
    
    return Common_Kengeki_Activate(ai, goal, probabilities, acts, actAfter, paramTbls)
end
```

---

## 4. 第三层：角色行为层 (c1010.dec.lua)

### 4.1 职责定位

角色行为层是**Havok 状态机与 Lua 脚本的桥梁**，负责：
1. **状态节点回调**：每个 Havok 状态节点对应一个 `EventXXXXX_onUpdate()` 函数
2. **通用反应处理**：通过 `EventCommonFunction()` 处理受击、弹反、死亡等共享逻辑
3. **状态转换触发**：通过 `Fire("W_XXX")` 驱动 Havok 状态机跳转

### 4.2 典型状态节点实现

#### Event20000_onUpdate：对话/自杀辅助状态

```lua
function Event20000_onUpdate()
    SetThrowFlag(STATE_NORMAL)  -- 设置可被投技标志
    
    if EventCommonFunction(20000) == TRUE then
        return  -- 被通用逻辑接管（如被攻击）
    end
    
    -- 检查特殊效果：自杀辅助武器
    if env(3036, SP_EFFECT_REF_WEAPON_4) == TRUE then
        if env(339, 1) == TRUE then  -- 动画结束
            Fire("W_Event21001")
            return
        end
        act(3029, TALK_REF_C1010_SUICIDE_ASSISTANT)  -- 触发对话
    end
end
```

#### Event21000_onUpdate：待机/对话分发状态

```lua
function Event21000_onUpdate()
    SetThrowFlag(STATE_NORMAL)
    
    -- 根据当前对话 ID 分发到不同状态
    if env(3036, 1000024) == TRUE then  -- 检查特定 SpEffect
        if env(3054) == TALK_REF_C1010_SUICIDE_ASSISTANT then
            Fire("W_Event20000")
            return
        end
    elseif env(3054) == TALK_REF_C1010_DEATH_START then
        Fire("W_Event20010")
        return
    elseif env(3054) == TALK_REF_C1010_TALK_START then
        Fire("W_Event21003")
        return
    end
    
    if EventCommonFunction(21000) == TRUE then
        return
    end
end
```

### 4.3 EventCommonFunction 通用处理

`EventCommonFunction(stateId)` 是**所有敌人共享的反应处理器**，处理：

| 反应类型 | 触发条件 | 行为 |
|---------|---------|------|
| 受击硬直 | `env(...)` 检测到伤害 | 播放受击动画，可能打断当前动作 |
| 弹反 | 玩家成功弹反 | 播放弹反硬直动画 |
| 破防 | 架势值耗尽 | 播放破防动画，进入可处决状态 |
| 死亡 | 生命值归零 | 播放死亡动画，清理 AI |
| 忍杀 | 玩家触发忍杀 | 播放忍杀受身动画 |

### 4.4 特殊对话转换

c1010 具备**对话转换逻辑**（`ExecTalkTransitionIndividual`），用于剧情演出：

```lua
function ExecTalkTransitionIndividual(anim_id, talk_ref_Id)
    if anim_id == 21000 and talk_ref_Id == TALK_BEH_IDENTIFIER__TALK_PLAY_00 then
        Fire("W_Event20010")  -- 对话结束后转到死亡状态
        return TRUE
    elseif anim_id == 21003 and talk_ref_Id == TALK_BEH_IDENTIFIER__TALK_PLAY_00 then
        Fire("W_Event20010")
        return TRUE
    end
    return FALSE
end
```

---

## 5. 第四层：Havok 状态机层 (c1010.hkx.xml + c9997.hkx.xml)

### 5.1 职责定位

Havok 状态机是**最底层的动画与物理引擎**，负责：
1. **状态转换规则**：定义哪些事件可以触发状态跳转
2. **动画播放**：驱动骨骼动画系统
3. **碰撞检测**：攻击判定、受击判定
4. **物理模拟**：根骨骼运动、IK 约束

### 5.2 文件分工

| 文件 | 规模 | 职责 |
|------|------|------|
| **c1010.hkx.xml** | ~3000 行 | c1010 **专属**状态节点（对话、特殊演出） |
| **c9997.hkx.xml** | ~55000 行 | **通用**敌人状态机（攻击、移动、受击、死亡） |

c1010 的状态机是**组合式**的：
- 特殊状态（Event20000~21099）在 `c1010.hkx.xml` 中定义
- 通用状态（攻击动画 3000~3099、移动、受击）复用 `c9997.hkx.xml`

### 5.3 状态机结构

```xml
<object id="object3" typeid="type98"> <!-- hkbStateMachine -->
  <record>
    <field name="userData"><int value="0"/></field>
    <field name="name"><string value=""/></field>
    <field name="startStateId"><int value="0"/></field>
    <field name="startStateMode"><byte value="0"/></field>
    <field name="selfTransitionMode"><byte value="0"/></field>
    
    <!-- 状态列表 -->
    <field name="states">
      <array count="1" elementtypeid="type111">
        <pointer id="object5"/> <!-- StateInfo -->
      </array>
    </field>
    
    <!-- 通配符转换（全局事件） -->
    <field name="wildcardTransitions">
      <pointer id="object4"/>
    </field>
  </record>
</object>

<!-- 状态节点定义 -->
<object id="object5" typeid="type115"> <!-- hkbStateMachine::StateInfo -->
  <record>
    <field name="stateId"><int value="0"/></field>
    <field name="name"><string value="Root"/></field>
    
    <!-- 进入状态时触发的事件 -->
    <field name="enterNotifyEvents">
      <pointer id="null"/>
    </field>
    
    <!-- 退出状态时触发的事件 -->
    <field name="exitNotifyEvents">
      <pointer id="null"/>
    </field>
    
    <!-- 该状态的转换规则 -->
    <field name="transitions">
      <pointer id="object6"/>
    </field>
    
    <!-- 状态内执行的生成器（动画、脚本回调） -->
    <field name="generator">
      <pointer id="object7"/>
    </field>
  </record>
</object>
```

### 5.4 状态转换规则

每个状态可以定义多个转换条件：

```xml
<object id="object6" typeid="type113"> <!-- TransitionInfoArray -->
  <record>
    <field name="transitions">
      <array count="3" elementtypeid="type121">
        <!-- 转换 1：收到 "W_Idle" 事件 → 跳转到状态 1 -->
        <record>
          <field name="triggerInterval">
            <record>
              <field name="enterEventId"><int value="-1"/></field>
              <field name="exitEventId"><int value="-1"/></field>
              <field name="enterTime"><float value="0.0"/></field>
              <field name="exitTime"><float value="0.0"/></field>
            </record>
          </field>
          <field name="initiateInterval">...</field>
          <field name="transition">
            <pointer id="object8"/> <!-- 转换条件 -->
          </field>
          <field name="condition">
            <pointer id="object9"/> <!-- hkbStringEventPayloadExpression -->
          </field>
          <field name="eventId"><int value="123"/></field> <!-- "W_Idle" 的 ID -->
          <field name="toStateId"><int value="1"/></field>
          <field name="fromNestedStateId"><int value="0"/></field>
          <field name="toNestedStateId"><int value="0"/></field>
          <field name="priority"><int value="0"/></field>
          <field name="flags"><short value="0"/></field>
        </record>
        
        <!-- 转换 2：收到 "W_Event21001" 事件 → 跳转到状态 21001 -->
        <record>
          ...
          <field name="eventId"><int value="456"/></field>
          <field name="toStateId"><int value="21001"/></field>
          ...
        </record>
      </array>
    </field>
  </record>
</object>
```

### 5.5 Lua 脚本回调节点

Havok 状态机通过 `hkbScriptGenerator` 节点回调 Lua 脚本：

```xml
<object id="object7" typeid="type150"> <!-- hkbScriptGenerator -->
  <record>
    <field name="scriptName"><string value="Event20000_onUpdate"/></field>
    <field name="locals">
      <pointer id="null"/>
    </field>
  </record>
</object>
```

当状态机进入该状态时，每帧调用 `c1010.dec.lua` 中的 `Event20000_onUpdate()` 函数。

---

## 6. 端到端执行流程：落武者挥刀攻击玩家

以下是一次完整的攻击流程，展示四层如何协同工作：

```
┌─ 帧 N：引擎 AI Tick ────────────────────────────────────────────┐
│ ExecTableLogic(ai, 101000)                                      │
│   Logic.Main(self, ai)  [101000_logic.dec.lua]                 │
│     COMMON_HiPrioritySetup → 玩家未死亡，继续                    │
│     COMMON_EzSetup(ai, COMMON_FLAG_EXPERIMENT)                  │
│       _COMMON_SetBattleGoal(ai)                                 │
│         ai:AddTopGoal(GOAL_Ochimusha_hassou_101010_Battle, -1)  │
└─────────────────────────────────────────────────────────────────┘
                     ↓
┌─ 帧 N+1：Goal Activate ─────────────────────────────────────────┐
│ ActivateTableGoal(ai, goal, GOAL_Ochimusha_hassou_101010_Battle)│
│   Goal.Activate(self, ai, goal)  [101010_battle.dec.lua]       │
│     distanceEnemy = 4.5  （玩家距离 4.5 米）                     │
│     probabilities[1] = 100   （普通斩击）                        │
│     probabilities[2] = 200   （突进斩）                          │
│     probabilities[6] = 300   （近距离连击，权重最高）            │
│     probabilities[23] = 1200 （侧步移动）                        │
│                                                                 │
│     SetCoolTime 修正：                                           │
│       probabilities[1] = 50  （5 秒内刚用过，降权）              │
│                                                                 │
│     Common_Battle_Activate → 加权随机选中 Act06                 │
│       Approach_Act_Flex(...)  （接近到 2.8 米）                  │
│       goal:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10,        │
│                      3007, TARGET_ENE_0, 9999, 0.5, 90, 0, 0)  │
└─────────────────────────────────────────────────────────────────┘
                     ↓
┌─ 帧 N+2~N+10：SubGoal 执行 ─────────────────────────────────────┐
│ GOAL_COMMON_AttackTunableSpin.Update()                          │
│   引擎接收到动画 ID = 3007                                       │
│   查询 Havok 状态机：找到状态节点 3007                           │
│   进入状态 3007，开始播放动画                                    │
└─────────────────────────────────────────────────────────────────┘
                     ↓
┌─ 帧 N+11~N+50：Havok 状态机 Tick ───────────────────────────────┐
│ hkbBehaviorGraph.Update()  [c9997.hkx.xml]                      │
│   当前状态：3007（近距离连击动画）                               │
│   每帧回调：Event3007_onUpdate()  [c1010.dec.lua]               │
│     EventCommonFunction(3007)                                   │
│       检测玩家是否弹反 → 否                                      │
│       检测是否被攻击 → 否                                        │
│       检测动画是否结束 → env(339, 1) == FALSE（未结束）          │
│     继续播放动画                                                 │
└─────────────────────────────────────────────────────────────────┘
                     ↓
┌─ 帧 N+51：动画结束 ─────────────────────────────────────────────┐
│ Event3007_onUpdate()                                            │
│   env(339, 1) == TRUE  （动画播放完毕）                          │
│   Fire("W_Idle")  → 触发 Havok 事件                             │
│                                                                 │
│ hkbStateMachine 接收到 "W_Idle" 事件                             │
│   查找转换规则：状态 3007 → 状态 0（待机）                       │
│   进入状态 0，播放待机动画                                       │
└─────────────────────────────────────────────────────────────────┘
                     ↓
┌─ 帧 N+52：回到决策层 ───────────────────────────────────────────┐
│ Goal.Activate 再次被调用（SubGoal 已完成）                      │
│   重新评估距离、权重，选择下一个动作                             │
└─────────────────────────────────────────────────────────────────┘
```

### 6.1 关键时间点

| 帧 | 层 | 事件 |
|----|----|----|
| N | 逻辑层 | `Logic.Main` 决定进入战斗状态 |
| N+1 | 决策层 | `Goal.Activate` 选择动画 3007 |
| N+2 | 行为层 | 引擎驱动 Havok 进入状态 3007 |
| N+11~N+50 | 状态机 | 每帧回调 `Event3007_onUpdate()`，播放动画 |
| N+51 | 行为层 | 动画结束，`Fire("W_Idle")` 返回待机 |
| N+52 | 决策层 | 重新选择下一个动作 |

---

## 7. 与玩家（c0000）的对比

| 维度 | 敌人（c1010） | 玩家（c0000） |
|------|-------------|-------------|
| **决策层** | 有（101000_logic + 101010_battle） | **无**（决策来自输入） |
| **行为层** | 有（c1010.dec.lua） | 有（c0000.dec.lua + c0000_transition.dec.lua） |
| **状态机** | 有（c1010.hkx.xml + c9997.hkx.xml） | 有（c0000.hkx.xml） |
| **转换规则** | 在 Havok 状态机中定义 | 在 `c0000_transition.dec.lua` 的 `Validate()` 中定义 |
| **反应处理** | `EventCommonFunction()` | `g_ValidateReactionTable` |
| **文件数量** | 4 个（logic + battle + 角色 + 状态机） | 4 个（主 + transition + define + cmsg） |

**核心差异**：
- 敌人的"想做什么"由 AI 脚本决定（logic + battle）
- 玩家的"想做什么"由玩家输入决定（键盘/手柄）
- 两者的"正在做什么"都由 Havok 状态机 + 角色行为脚本管理

---

## 8. 设计模式总结

### 8.1 分层解耦

每层只关心自己的职责，通过明确的接口通信：
- **逻辑层**不知道具体攻击动画 ID，只知道"进入战斗状态"
- **决策层**不知道 Havok 状态机结构，只知道"播放动画 3007"
- **行为层**不知道 AI 决策逻辑，只知道"当前在状态 3007，检测是否结束"
- **状态机**不知道 Lua 脚本内容，只知道"回调 Event3007_onUpdate"

### 8.2 表驱动决策

战斗决策层使用**权重表 + 加权随机**，而非硬编码的 if-else：
- 易于调整：修改权重即可改变 AI 行为倾向
- 易于扩展：添加新动作只需增加一个 Act 函数和权重槽位
- 易于调试：可以记录每次决策的权重分布

### 8.3 事件驱动状态机

Havok 状态机通过**事件触发转换**，而非轮询：
- Lua 脚本通过 `Fire("W_Idle")` 主动触发转换
- 状态机通过转换规则表查找目标状态
- 避免了复杂的状态轮询逻辑

### 8.4 组合复用

c1010 的状态机是**组合式**的：
- 特殊状态（对话、演出）在 `c1010.hkx.xml` 中定义
- 通用状态（攻击、移动）复用 `c9997.hkx.xml`
- 避免了重复定义，减少了维护成本

---

## 9. 关键数据流

### 9.1 距离感知 → 动作选择

```
ai:GetDist(TARGET_ENE_0) = 4.5
    ↓
101010_battle.dec.lua : Goal.Activate
    distanceEnemy >= 3 分支
    ↓
probabilities[1] = 100  (普通斩击)
probabilities[6] = 300  (近距离连击，权重最高)
    ↓
Common_Battle_Activate 加权随机
    ↓
选中 Act06 → 动画 3007
```

### 9.2 玩家状态 → AI 反应

```
玩家触发处决态 (SpEffect 3170200)
    ↓
101010_battle.dec.lua : Goal.Activate
    if ai:HasSpecialEffectId(TARGET_ENE_0, 3170200)
    ↓
probabilities[25] = 1000  (后撤，权重压倒性)
probabilities[1] = 1      (其他动作几乎不可能)
    ↓
选中 Act25 → 后撤动画
```

### 9.3 剑击检测 → 即时反击

```
玩家攻击命中 → 引擎设置 SpEffect (200200)
    ↓
101010_battle.dec.lua : Goal.Kengeki_Activate
    kengekiEffect = 200200 (上段攻击)
    distanceEnemy < 2
    ↓
probabilities[1] = 100  (反击斩 3050)
probabilities[2] = 100  (反击斩 3051)
    ↓
选中 Kengeki01 → 反击动画 3050
    ↓
goal:ClearSubGoal()  (清空当前动作)
goal:AddSubGoal(GOAL_COMMON_ComboFinal, 1, 3050, ...)
```

---

## 10. 调试与扩展指南

### 10.1 修改 AI 行为倾向

**场景**：让落武者更激进，增加突进斩的使用频率

**修改位置**：`101010_battle.dec.lua : Goal.Activate`

```lua
-- 原始权重
elseif distanceEnemy >= 7 then
    probabilities[2] = 200    -- 突进斩
    probabilities[23] = 600   -- 侧步移动

-- 修改后
elseif distanceEnemy >= 7 then
    probabilities[2] = 800    -- 突进斩权重提升 4 倍
    probabilities[23] = 200   -- 侧步权重降低
```

### 10.2 添加新攻击动作

**步骤**：
1. 在 `101010_battle.dec.lua` 中添加 `Goal.Act50`
2. 在 `Goal.Activate` 中分配权重 `probabilities[50] = 300`
3. 绑定实现 `acts[50] = REGIST_FUNC(ai, goal, self.Act50)`
4. 在 Havok 状态机中添加对应的状态节点（如果需要新动画）
5. 在 `c1010.dec.lua` 中添加 `Event50000_onUpdate()`（如果需要特殊逻辑）

### 10.3 调试 AI 决策

**方法 1**：记录权重分布

```lua
-- 在 Common_Battle_Activate 之前添加
for i = 1, 50 do
    if probabilities[i] and probabilities[i] > 0 then
        print(string.format("Act%02d: %d", i, probabilities[i]))
    end
end
```

**方法 2**：强制选择特定动作

```lua
-- 在 Goal.Activate 末尾添加
probabilities = {}  -- 清空所有权重
probabilities[6] = 100  -- 强制使用 Act06
```

### 10.4 追踪状态转换

在 `c1010.dec.lua` 的 `Fire()` 调用处添加日志：

```lua
function Fire(eventName)
    print(string.format("[c1010] Fire: %s", eventName))
    hkbFireEvent(eventName)
end
```

---

## 11. 常见问题

### Q1：为什么敌人有时会"发呆"？

**原因**：所有动作的权重都被 `SetCoolTime` 降为 0，或者空间检测失败导致所有移动动作被禁用。

**解决**：
- 检查 `SetCoolTime` 的冷却时间是否过长
- 检查 `SpaceCheck` 是否过于严格
- 添加兜底动作（如 `Act26: Wait`）确保总有可用动作

### Q2：如何让敌人使用特定武器的动画？

**答案**：动画 ID 由战斗决策层（battle.dec.lua）决定。不同武器的敌人使用不同的 battle 文件：
- `101000_battle.dec.lua` → 一手刀（动画 3000~3099）
- `101010_battle.dec.lua` → 八双（动画 3000~3099，但具体动画不同）
- `101020_battle.dec.lua` → 枪（动画 3000~3099）

同一个 `c1010.dec.lua` 可以被多个 battle 文件复用。

### Q3：EventCommonFunction 在哪里定义？

**答案**：`EventCommonFunction` 是**引擎提供的 C++ 函数**，在 Lua 中直接调用。它的实现不在反编译脚本中，但可以通过观察其行为推断功能：
- 处理受击硬直
- 处理弹反
- 处理破防
- 处理死亡
- 检测动画结束

### Q4：c9997.hkx.xml 为什么这么大？

**答案**：c9997 是**通用敌人状态机**，包含：
- 所有基础攻击动画（3000~3099）
- 所有移动动画（走、跑、侧步、后跳）
- 所有受击动画（轻击、重击、弹反、破防）
- 所有死亡动画（正常死亡、忍杀、坠落死亡）

多个敌人（c1010、c1020、c1030 等）共享这个状态机，只需定义各自的特殊状态（对话、演出）。

---

## 12. 参考资料

- [AI_Script_Framework.md](AI_Script_Framework.md) - 敌人 AI 脚本框架总览
- [doc/Lua env.md](../../doc/Lua%20env.md) - `env(id, ...)` API 完整参考
- [doc/Havok_Behavior_状态机文档.md](../../doc/Havok_Behavior_%E7%8A%B6%E6%80%81%E6%9C%BA%E6%96%87%E6%A1%A3.md) - Havok 状态机节点类型
- [action/eventnameid.txt](../../action/eventnameid.txt) - 事件名称 ID 映射
- [action/statenameid.txt](../../action/statenameid.txt) - 状态节点 ID 映射

---

## 附录 A：c1010 动画 ID 速查

| 动画 ID | 名称 | 用途 | 定义位置 |
|--------|------|------|---------|
| 3000 | 普通斩击（第一段） | 基础攻击 | Act01 |
| 3001 | 普通斩击（第二段） | 连击收尾 | Act01 |
| 3002 | 突进斩 | 远距离接近 | Act02 |
| 3004 | 快速斩（第一段） | 近距离快攻 | Act04 |
| 3005 | 快速斩（第二段） | 连击收尾 | Act04 |
| 3006 | 冲刺攻击 | 中距离突进 | Act05 |
| 3007 | 近距离连击 | 贴身压制 | Act06 |
| 3009 | 转身攻击 | 玩家在背后 | Act10 |
| 3050~3057 | 剑击反击系列 | 被攻击时反击 | Kengeki01~06 |
| 3076 | 下段反击 | 应对下段攻击 | Kengeki10 |
| 5201 | 后跳 | 拉开距离 | Act24 |
| 5202/5203 | 左/右侧步 | 环绕移动 | Act22 |
| 9910 | 防御姿态 | 侧步时保持防御 | Act23 |

## 附录 B：关键 SpEffect ID

| SpEffect ID | 含义 | 来源 |
|------------|------|------|
| 200299 | 观察目标（自身） | 101000_logic.dec.lua |
| 3101110 | 可被锁定 | 101000_logic.dec.lua |
| 220020 | 傀儡咒 | 101000_logic.dec.lua |
| 3170200 | 玩家处决态 | 101010_battle.dec.lua |
| 200200/200205 | 上段攻击（剑击） | Kengeki_Activate |
| 200210/200215 | 下段攻击（剑击） | Kengeki_Activate |
| 5020/5021 | 特殊状态（侧步触发） | 101010_battle.dec.lua |

