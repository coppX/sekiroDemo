# 只狼敌人 AI 脚本框架分析

> 本文以 `script/m11_02_00_00-luabnd-dcx/`（苇名城本城地图）为切入口，结合 `script/aicommon-luabnd-dcx/` 的公共框架以及 `action/script/c0000.dec.lua` / `c1010.dec.lua`，梳理只狼敌人 AI 脚本的整体结构与执行流。
>
> 命名约定：本文中保留反编译脚本里的原始标识符（`ai`、`goal`、`GOAL_*`、`INTERUPT_*`、`AI_EXCEL_*`、`TARGET_*`、`SP_EFFECT_*` 等）。`fN_localM` 一类是反编译器伪影，无语义。

---

## 1. 两层架构：决策层（script/）vs 动画层（action/script/）

只狼的角色行为由**两套独立的 Lua 脚本**协同：

| 层 | 目录 | 作用 | 调度者 |
|---|---|---|---|
| **决策层（AI）** | `script/` | "想做什么"——选目标、选距离、选技能、选时机 | 引擎 AI tick |
| **动画层（角色行为）** | `action/script/` | "正在做什么"——把 AI 选出的动画 ID 喂给 Havok 行为树，处理具体帧上的反应与状态切换 | Havok 行为树 tick |

玩家（`c0000`）只占动画层，**没有决策层脚本**——决策来自键盘/手柄输入，经 `c0000_transition.dec.lua` 的 `Validate()` 规则表转换成 `BEH_*` 行为。

敌人则两层都有：
- `script/m11_02_00_00-luabnd-dcx/lua/<entityID>_logic.dec.lua` + `<entityID>_battle.dec.lua` 决定"做什么"。
- `action/script/c1010.dec.lua` 等 `cXXXX.dec.lua` 在 Havok 状态机里接住 AI 给出的动画 ID 并播放、检测受击/死亡等。

两层的桥梁是**动画 ID（attack ID）**：决策层选出例如 `3000`、`20011`、`3020` 这些数字，喂给 `GOAL_COMMON_AttackTunableSpin` 等通用 SubGoal；引擎据此驱动 Havok 状态机进入对应的状态节点（节点名见 `action/statenameid.txt`），动画层 `EventXXXXX_onUpdate()` 在该状态被激活的每一帧被回调。

---

## 2. `script/` 目录概览

```
script/
├── aicommon-luabnd-dcx/lua/           # 公共框架与可复用 SubGoal（≈ 4300 行）
│   ├── ai_define.dec.lua              # 全局常量（INTERUPT_*、TARGET_*、SP_EFFECT_TYPE_*…）
│   ├── event_list.dec.lua             # AI_EVENT_* 自定义事件常量
│   ├── logic_list.dec.lua             # LOGIC_ID_* 敌人逻辑编号（≈100 个）
│   ├── goal_list.dec.lua              # GOAL_* 全部 Goal 编号（含 GOAL_COMMON_*、各敌人 GOAL_*_Battle）
│   ├── table_ai_common.dec.lua        # RegisterTableLogic / RegisterTableGoal 注册框架
│   ├── common_logic_func.dec.lua      # COMMON_HiPrioritySetup / COMMON_EzSetup / _COMMON_AddBattleGoal …
│   ├── common_battle_func.dec.lua     # Common_Battle_Activate / _COMMON_SelectEnemyAct（权重选择器）
│   ├── common_func.dec.lua            # 攻击参数读取、ActRate 初始化
│   ├── top_goal.dec.lua               # 所有 Goal 的根中断
│   ├── normal.dec.lua                 # GOAL_COMMON_Normal（最朴素的"靠近/攻击/拉开"循环）
│   ├── attack*.dec.lua, combo*.lua    # GOAL_COMMON_Attack、ComboRepeat、ComboFinal 等具体 SubGoal
│   ├── approach_*.dec.lua, step*.lua  # 移动类 SubGoal
│   ├── enemy_*.dec.lua, after_attack* # 通用敌人 SubGoal（Approach/AfterAttack/SideWalk…）
│   ├── *_platoon.dec.lua              # 团队（小队）协同 AI
│   └── …
│
├── m10_00_00_00-luabnd-dcx/lua/       # 各地图私有 AI（章鱼大头等地图）
├── m11_00_00_00-luabnd-dcx/lua/       # 苇名城外围
├── m11_02_00_00-luabnd-dcx/lua/       # 苇名城本城（本文重点）
└── …
```

`m11_02` 下共 52 个 `.dec.lua` 文件，按"敌人 ID"组织。文件命名规律：

| 文件 | 角色 | 备注 |
|---|---|---|
| `<id>_logic.dec.lua` | 该敌人的"AI 主循环外壳" | 总是定义 `Logic.Main / Logic.Interrupt`，行数小（≈30–100 行） |
| `<id>_battle.dec.lua` | 该敌人的"战斗 Goal 决策表" | 定义 `Goal.Activate / Act01..ActNN`，行数大（数百到上千） |
| `<id1>_battle.dec.lua` 同 ID 派生 | 同一原型的武器变种 | 如 `150000`/`150010`/`150020`… 是村民僵尸的不同武器版本，共用 `150000_logic` |

`m11_02` 下的敌人 ID 与已知角色的对应（参照 `logic_list.dec.lua` 的 `LOGIC_ID_*` 注释）：

| ID 前缀 | 敌人 |
|---|---|
| `011000`、`020000` | `Nanimosinai`（什么都不做）、`PatrolLeader`——通用占位/巡逻 |
| `101xxx` | 落武者（一手刀 / 八双 / 枪 / 火绳枪 / 教学版） |
| `102xxx` | 武士大将 |
| `112000` | 见张番 |
| `115000` | 新狗 |
| `118xxx` | 弦庵（不同武器） |
| `119xxx` | 谷敌（散弹、加农炮） |
| `136000` | 喇叭手 |
| `147000` | 御荣众 |
| `150xxx` | 村民僵尸（赤手 / 熊手 / 菜刀 / 锄 / 竹枪 / 织机 / 主人） |
| `540xxx` | 剑圣（弱体 + 完全版） |
| `710xxx` / `711xxx` | 弦一郎（穿衣 + 半裸两阶段） |
| `720000` | 王子 |
| `740000` | 异性娘 |

---

## 3. 决策层执行流：从帧 tick 到 Havok 状态

引擎每帧对每个 NPC 触发以下顺序（对应 `table_ai_common.dec.lua`）：

```
ExecTableLogic(ai, logicID)          -- 调 Logic.Main → 做"高层路由"
  └─ COMMON_HiPrioritySetup          -- 紧急情况（玩家死亡、复活、忍杀、烟雾……）直接 short-circuit
  └─ Kugutsu / JuzuReaction          -- 傀儡咒、念珠反应等特殊态
  └─ COMMON_EzSetup                  -- 兜底：根据 Caution/Find/Battle 选择
     └─ _COMMON_SetBattleActLogic
        └─ _COMMON_AddBattleGoal     -- 把 GOAL_<敌人>_Battle 顶进 goal 栈
ActivateTableGoal(ai, goal, goalID)  -- 调 Goal.Activate(self, ai, goal)
  └─ Common_Clear_Param              -- 重置 probabilities[1..50] / acts[] / paramTbls[]
  └─ if/elseif 大表 → 给若干 Act 编号填 probabilities（权重）
  └─ SpaceCheck / SetCoolTime         -- 空间检测、冷却扣权重
  └─ acts[N] = REGIST_FUNC(self.ActNN) -- 把每个 Act 的实现挂上
  └─ Common_Battle_Activate          -- 加权随机抽一个 Act 并执行
     └─ ActNN(ai, goal, paramTbl)
        └─ Approach_Act_Flex          -- 必要的接近 SubGoal
        └─ goal:AddSubGoal(GOAL_COMMON_AttackTunableSpin, life, animID, target, …)
UpdateTableGoal(ai, goal, …)         -- 后续帧 tick，由 SubGoal 自管
```

`ai` 是 C++ 端注入的 AI 黑板对象，提供：
- 查询：`ai:GetDist(target)`、`ai:GetHpRate(self)`、`ai:GetRandam_Int(a,b)`、`ai:HasSpecialEffectId(target, sp)`、`ai:IsInsideTarget(target, dir, ang)`、`ai:CheckDoesExistPath(...)`、`ai:GetExcelParam(AI_EXCEL_*)`、`ai:IsBattleState() / IsFindState() / IsCautionState()` 等
- 状态修改：`ai:SetNumber / GetNumber`、`ai:SetStringIndexedNumber("ActRate01", v)`、`ai:AddObserveSpecialEffectAttribute(...)`、`ai:StartIdTimer(id)`、`ai:AddTopGoal(...)`、`ai:Replanning()`、`ai:ReqPlatoonState(PLATOON_STATE_Battle)`
- 中断查询：`ai:IsInterupt(INTERUPT_FindAttack)` 等（约 58 种中断类型，见 `ai_define.dec.lua`）

`goal` 是当前正在执行的 Goal 栈帧，最重要的 API：
- `goal:AddSubGoal(GOAL_*, life, ...args)`、`AddSubGoal_Front(...)`、`ClearSubGoal()`、`GetParam(i)`、`SetManagementGoal()`

---

## 4. Logic 外壳的固定套路

抽样 `101000_logic.dec.lua`（落武者）/ `150000_logic.dec.lua`（村民僵尸）/ `540000_logic.dec.lua`（剑圣）等，`Logic.Main` 都遵循同一模板：

```lua
RegisterTableLogic(101000)

Logic.Main = function (self, ai)
    -- 1) 注册"我关心哪些 SpEffect"作为中断源
    ai:AddObserveSpecialEffectAttribute(TARGET_SELF, 200299)
    ai:AddObserveRegion(30, TARGET_SELF, COMMON_REGION_FORCE_WALK_M11_0)

    -- 2) 紧急 / 共用前置（玩家死、忍杀、烟雾……）
    if COMMON_HiPrioritySetup(ai, COMMON_FLAG_EXPERIMENT) then
        return true
    end

    -- 3) 特殊态：傀儡咒 / 念珠反应 等
    if ai:HasSpecialEffectId(TARGET_SELF, 220020) then          -- 傀儡咒
        if self.KugutsuAct(ai, goal) then return true end
    elseif ai:IsFinishTimer(AI_TIMER_TEKIMAWASHI_REACTION) == false then
        JuzuReaction(ai, goal, 0, 20105)                        -- 玩家拿到念珠时的演出
        return true
    end

    -- 4) 事件请求：被关卡脚本明令"去哪里 / 做什么"
    local eventRequest = ai:GetEventRequest()
    if eventRequest == 10 then
        ai:SetEventMoveTarget(9622490)
        ai:AddTopGoal(GOAL_COMMON_ApproachTarget, 3, POINT_EVENT, 0, TARGET_SELF, false, -1)
    elseif eventRequest == 12 then ...

    -- 5) 兜底：根据 Caution/Find/Battle 状态加入合适的 TopGoal
    COMMON_EzSetup(ai, COMMON_FLAG_EXPERIMENT)
end

Logic.Interrupt = function (self, ai, goal) ... end   -- 整 Goal 栈的全局中断（多数返回 false）
```

特殊敌人会略有不同：

- **`540000`（剑圣）/ `710000`（弦一郎）** 用 `COMMON_FLAG_BOSS`，并把"玩家死亡（110060）/复活（110015）"挂成中断，进 boss 专属处理（清目标、追玩家尸体等）。
- **`720000`（王子）** 跳过 `EzSetup`，直接 `_COMMON_SetBattleGoal(ai)`——很可能因其总是处于强制战斗态。
- **`020000`（PatrolLeader）** 直接 `AddTopGoal(GOAL_COMMON_NonBattleAct, …)`，连战斗 Goal 都不挂。
- **`011000`（Nanimosinai = 什么都不做）** 用旧式裸函数（无 `RegisterTableLogic`），只挂一个 `GOAL_COMMON_Wait`。

---

## 5. Battle 决策表的"加权选择"模式

`<id>_battle.dec.lua` 是真正的战斗"AI 大脑"。所有非平凡敌人都遵循同一表驱动模式（`common_battle_func.dec.lua : Common_Battle_Activate`）：

```lua
RegisterTableGoal(GOAL_MurabitoZombie_sude_150000_Battle, "GOAL_MurabitoZombie_sude_150000_Battle")
REGISTER_GOAL_NO_UPDATE(GOAL_MurabitoZombie_sude_150000_Battle, true)

Goal.Activate = function (self, ai, goal)
    Init_Pseudo_Global(ai, goal)
    local probabilities, acts, paramTbls = {}, {}, {}
    Common_Clear_Param(probabilities, acts, paramTbls)

    local distanceEnemy = ai:GetDist(TARGET_ENE_0)
    local paramDoAdmire = ai:GetExcelParam(AI_EXCEL_THINK_PARAM_TYPE__thinkAttr_doAdmirer)

    -- ===== 决策分支：根据状态/距离填权重 =====
    if ai:HasSpecialEffectId(TARGET_SELF, 3150100) then        -- 处决态
        probabilities[16] = 100
    elseif Common_ActivateAct(ai, goal) then                   -- 让通用预设接管
    elseif ai:CheckDoesExistPath(TARGET_ENE_0, AI_DIR_TYPE_F, 0, 0) == false then
        probabilities[4]  = 100                                -- 无法寻路 → 走特定行为
        probabilities[27] = 100
    elseif ai:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_B, 180) then
        probabilities[21] = 100                                -- 玩家在背后 → 转身
    elseif distanceEnemy >= 10 then
        probabilities[1] = 100
        probabilities[2] = 700
        probabilities[3] = 200
    elseif distanceEnemy >= 5 then
        probabilities[1] = 100
        probabilities[2] = 600
        probabilities[3] = 300
    else
        probabilities[1] = 500
        probabilities[2] = 100
        probabilities[3] = 200
        probabilities[24] = 200
    end

    -- ===== 空间约束：墙角时取消侧步/后跳 =====
    if SpaceCheck(ai, goal, 180, 2) == false then probabilities[24] = 0 end

    -- ===== 攻击冷却 =====
    probabilities[1]  = SetCoolTime(ai, goal, 3000, 5,  probabilities[1],  1)
    probabilities[3]  = SetCoolTime(ai, goal, 3002, 12, probabilities[3],  1)

    -- ===== 绑定 ActNN 实现 =====
    acts[1] = REGIST_FUNC(ai, goal, self.Act01)
    acts[2] = REGIST_FUNC(ai, goal, self.Act02)
    -- … 一直到 self.Act40

    local actAfter = REGIST_FUNC(ai, goal, self.ActAfter_AdjustSpace)
    Common_Battle_Activate(ai, goal, probabilities, acts, actAfter, paramTbls)
end

Goal.Act01 = function (ai, goal, paramTbl)
    local stopDist = 3.2 - ai:GetMapHitRadius(TARGET_SELF) + (ai:GetRandam_Float(0, 2.5) - 0.8)
    Approach_Act_Flex(ai, goal, stopDist, stopDist - 1, stopDist + 1, 100, 0, 1.5, 2)
    goal:AddSubGoal(GOAL_COMMON_AttackTunableSpin, 10, 3000, TARGET_ENE_0, 9999, 0, 0, 0, 0)
    return 100   -- GetWellSpace_Odds
end
```

可以观察到的特征：

1. **`probabilities[N]` 是一个槽位编号**（最多 50 个），N 与 `Act01..Act50` 一一对应。每条分支只是改若干槽位的权重，最后做加权随机。
2. **决策条件三大类**：(a) 状态/SpEffect（被处决、被恐惧、傀儡咒等），(b) 几何（距离、是否在背后、是否能寻路、`SpaceCheck`），(c) 团队角色（`ROLE_TYPE_Torimaki` / `ROLE_TYPE_Kankyaku` 等"围观"角色，让小弟在 boss 战时表演 admire 动作）。
3. **`Common_ActivateAct(ai, goal)` 是"通用预设短路"**——大约对应"有更高优先级的预设动作要打断"，例如被弹反后必出反击等。多数文件以此开头。
4. **`Approach_Act_Flex` + `GOAL_COMMON_AttackTunableSpin`** 是绝大多数普通敌人 Act 的骨架："先走/跑到目标距离，再播放某个攻击动画 ID"。`AttackTunableSpin` 的关键参数：`(life, animationId, target, successDist, turnTime, turnFaceAngle, ...)`。
5. **`SetCoolTime(ai, goal, animID, cd, prob, mode)`**：根据上次播放该 anim 的间隔修正概率，等价于"近期刚出过的招要降权"。
6. **`SetEnemyActRate / GetStringIndexedNumber("ActRate01")`**：游戏 Excel 参数 → 每招的"基线倾向"，可以被剧情/特效动态改写（例如生命值低于阈值开狂暴时把某 Act 的 ActRate 拉到 0 或翻倍）。

> 复杂 boss（剑圣 540300、弦一郎 711000、村民僵尸 150000）的 `Goal.Activate` 都在 ≥40 个 Act 槽位上铺权重，并且会读 `ai:GetHpRate / GetSpRate / GetNinsatsuNum`（忍杀次数）等做阶段切换。

---

## 6. 公共 SubGoal 库（`GOAL_COMMON_*`）

`goal_list.dec.lua` 集中了所有 Goal 编号。常被 `<id>_battle.dec.lua` 直接 `AddSubGoal` 的"叶子动作"：

| Goal | 用途 |
|---|---|
| `GOAL_COMMON_Wait` (2000) | 原地等待 N 秒 |
| `GOAL_COMMON_Turn` (2001) / `TurnAround` (2002) | 转向目标 |
| `GOAL_COMMON_ApproachTarget` (2015) | 走到目标停止距离内（行走 / 跑步） |
| `GOAL_COMMON_LeaveTarget` (2016) | 拉开距离 |
| `GOAL_COMMON_SidewayMove` (2017) / `KeepDist` (2018) | 侧身环绕 / 维持距离 |
| `GOAL_COMMON_MoveToSomewhere` (2019) | 通用点对点移动（可指定方向、是否跑步） |
| `GOAL_COMMON_Attack` (2100) | 单段攻击 |
| `GOAL_COMMON_AttackTunableSpin` (2220) | 带攻击中转向调整的单段攻击（最常用） |
| `GOAL_COMMON_ComboAttack` / `ComboRepeat` / `ComboFinal` | 多段连招 |
| `GOAL_COMMON_Guard` (2101) / `Parry` (2113) | 弹反/防御 |
| `GOAL_COMMON_DashAttack` (2109/2110) | 冲刺攻击 |
| `GOAL_COMMON_BackToHome_With_Parry` (2704) | 受规则约束后返回 Home 点 |
| `GOAL_COMMON_TeamCallHelp` (2116) / `TeamReplyHelp` (2117) | 小队呼救/响应 |

外加每个敌人自己的 `GOAL_<敌人>_Battle`（在 `goal_list.dec.lua` 内 `100000..7999999` 区间）作为"战斗状态机的根 TopGoal"。

`TopGoal_Interupt`（在 `top_goal.dec.lua`）是所有 TopGoal 的根中断处理器：撞到可破坏物 → 强制 `NonspinningAttack` 把它砸开；撞墙 → `BackToHome_With_Parry` 收线；目标超出观察距离 → `Replanning`；路径偏离 → `Wait`。每个 Goal 还可以自定义 `Goal.Interrupt`，用于"被攻击/识破/警戒消失"等场景把 SubGoal 栈推平重排。

---

## 7. 与玩家（`c0000`）的交互点

决策层"看得见"玩家的方式：

1. **目标查询**：`TARGET_ENE_0 = 0` 在战斗态里默认指向玩家（更精确地说"当前敌对目标"）。`ai:GetDist(TARGET_ENE_0)`、`ai:IsInsideTarget(TARGET_ENE_0, AI_DIR_TYPE_F, 90)`、`ai:HasSpecialEffectId(TARGET_ENE_0, 110060)`（110060 = `COMMON_SP_EFFECT_PC_DEAD`） 都是常见用法。
2. **玩家状态的 SpEffect 监听**（参见 `common_logic_func.dec.lua : COMMON_HiPrioritySetup`）：

   | SpEffect ID | 含义 |
   |---|---|
   | 110060 | 玩家死亡（满血归零） |
   | 120 | 玩家复活（`SP_EFFECT_PC_RETURN`） |
   | 110030 | 玩家被忍杀（`PC_NINSATSU`） |
   | 110015 | 玩家原地复活（`PC_REVIVAL`） |
   | 110125 | 玩家破防（`PC_BREAK`） |
   | 109203 | 玩家在草丛里（`HIDE_IN_BUSH`） |
   | 8300  | 烟花散弹（`SMOKE_SCREEN`） |
   | 220010 | 自身被 `BLOOD_SMOKE`（被血雾致盲） |

   `COMMON_HiPrioritySetup` 把这些事件转成"清目标 / 改播搜索动画 / 启动一次环绕观察"等高优先级行为。
3. **锁定关系**：`ai:IsLockOnTarget(TARGET_LOCALPLAYER, TARGET_SELF)` 让脚本能感知"玩家锁定了我没"，进而触发剧情 flag（落武者 `101000` 即据此设置 `EventFlag 11125650`）。

玩家在动画层（`c0000.dec.lua`）则反向消费这些 NPC 的动画 ID：当 NPC 播放一段攻击动画时，玩家通过 `env(...)` 查询"被攻击" → `c0000_transition.dec.lua` 的 `g_ValidateReactionTable` 决定播 `BEH_R_HIT_DAMAGE` / `BEH_R_GUARD` / `BEH_R_DEATH` 之类的反应行为。两边其实是松耦合的——AI 只负责"我要播 anim 3010"，命中/格挡判定由引擎和玩家侧的 transition 规则完成。

---

## 8. 与动画层（`c1010.dec.lua`）的对接

`action/script/c1010.dec.lua` 是弦一郎（敌人 ID `1010`）的 Havok 行为脚本：

```lua
function Event21000_onUpdate()           -- 状态节点 21000 被激活时每帧调用
    SetThrowFlag(STATE_NORMAL)
    if EventCommonFunction(21000) == TRUE then return end
    if env(339, 1) == TRUE then          -- 339 = 动作结束查询
        Fire("W_Idle")                   -- 跳回待机
        return
    end
end
```

它**完全不包含 AI 决策**——它的责任只是：

1. 接住 AI 决策层选出的攻击 ID（如 `3010` 或 `21000`，对应 `statenameid.txt` 的某节点）。
2. 在该状态节点上每帧调用 `EventCommonFunction(...)`（共享逻辑：处理 hitstun、被弹反、被忍杀、强制返回 Idle 等）。
3. 用 `Fire("W_XXX")` 在动画结束时触发 Havok 状态转换返回待机或衔接下一段。

因此**敌人没有 `_transition` 文件**（只有玩家有）——敌人的"反应规则"被并入 `EventCommonFunction` 与 Havok 行为树本身的转换条件。三个 `cXXXX.dec.lua` 的辅助文件：

- `cXXXX_define.dec.lua` —— ID 常量，TRUE/FALSE/INVALID。
- `cXXXX_cmsg.dec.lua` —— 战斗消息（受击、投技）。
- 没有 `cXXXX_transition.dec.lua`（敌人姿态切换走 Havok 内部规则）。

---

## 9. 端到端调用流（举例：弦一郎挥刀打玩家）

```
┌─ AI tick ─────────────────────────────────────────────────────────┐
│ ExecTableLogic(ai, 710000)                                        │
│   Logic.Main(self, ai)  in 710000_logic.dec.lua                   │
│     COMMON_HiPrioritySetup → 玩家未死亡，继续                       │
│     COMMON_EzSetup(ai, COMMON_FLAG_BOSS)                          │
│       _COMMON_AddBattleGoal → ai:AddTopGoal(GOAL_Rival_710000_… ) │
│                                                                   │
│ ActivateTableGoal(ai, goal, GOAL_Rival_710000_Battle)             │
│   Goal.Activate(self, ai, goal)  in 710000_battle.dec.lua         │
│     probabilities[3] = 200 (距离 > 5)                              │
│     probabilities[10] = 100 (HP < 80%)                             │
│     Common_Battle_Activate → 加权随机选中 Act10                     │
│       Approach_Act_Flex(...)                                      │
│         goal:AddSubGoal(GOAL_COMMON_ApproachTarget, ..., 跑过去)    │
│       goal:AddSubGoal(GOAL_COMMON_ComboAttackTunableSpin, 10,     │
│                      3010, TARGET_ENE_0, 2.7, 0, 0, 0, 0)         │
│       goal:AddSubGoal(GOAL_COMMON_ComboFinal, 10, 3011, ...)      │
└───────────────────────────────────────────────────────────────────┘
                ↓ AI 调引擎指令
┌─ Havok 行为树 ────────────────────────────────────────────────────┐
│ hkbBehaviorGraph 接到 anim=3010 → 进入状态节点 3010                 │
│ 每帧调 action/script/c1010.dec.lua : Event3010_onUpdate()         │
│   EventCommonFunction(3010) 处理 hit / parry / stun                │
│   anim 完成 → Fire("W_NextSegment") 或回到 W_Idle                  │
└───────────────────────────────────────────────────────────────────┘
                ↓ 玩家被打中
┌─ 玩家侧 c0000_transition.dec.lua ────────────────────────────────┐
│ Validate(current_hkb_state)                                       │
│   命中 g_ValidateReactionTable[BEH_R_HIT_DAMAGE]                  │
│   _ActivateBehavior(BEH_R_HIT_DAMAGE) → FireEvent("...")          │
└───────────────────────────────────────────────────────────────────┘
```

---

## 10. 阅读这些脚本时的注意事项

- **`fN_localM` 命名是反编译器伪影**，没有语义。带语义的标识符是 `g_*` 全局、`BEH_*` / `GOAL_*` / `TARGET_*` / `SP_EFFECT_TYPE_*` / `STATE_TYPE_*` / `STYLE_TYPE_*` / `INTERUPT_*` 等枚举常量。
- **`probabilities[N]` 的 N 与 `ActNN` 是约定，N 没有跨敌人语义**——同一编号在不同敌人里可能完全是不同的招式。要看 `acts[N] = self.ActNN` 后跟到的具体 `Goal.ActNN` 实现。
- **`paramDoAdmire`、`ROLE_TYPE_Torimaki` / `ROLE_TYPE_Kankyaku`** 是为了"小弟在 boss 面前表演敬慕、围观"的演出参数，不是战斗强度参数。
- **`ai:GetExcelParam(AI_EXCEL_THINK_PARAM_TYPE__*)`** 读取的是 NpcThinkParam.xlsx 里的字段；要追"具体某个敌人的撤退距离/警戒时间/呼救动作 ID"需要去看那张表，脚本里只是消费方。
- **存在多张地图的"同一敌人 ID"**（如 `101000` 在 `m11_00` 和 `m11_02` 都有）——它们的脚本不完全相同，因为不同地图会塞入不同的 `eventRequest` 分支与剧情触发条件。`aicommon` 是真正的"共享"层。
- **不要从 `script/m11_02` 的脚本去推断 Havok 状态机本身**：那些 `3000`、`3010`、`20011` 等数字只是状态节点 ID，对应的实际动画与转换在 `chr/c<id>-behbnd-dcx/Behaviors/` 的 Havok XML 中。

---

## 11. 后续可深入的方向

1. **逐个敌人写战斗策略画像**：把 `<id>_battle.dec.lua` 的距离-权重表反向画出"距离区间 × 招式概率"图，能直观比较"弦一郎 vs 剑圣 vs 落武者"的 AI 差异。
2. **`AI_EXCEL_THINK_PARAM_TYPE_*` 字段→实际 Excel 行**：把 `ai_define.dec.lua` 里这 30+ 个枚举翻成 NpcThinkParam 的列名，将"撤退距离/呼救成员 ID/转向时间"等数值与剧情设定挂钩。
3. **`COMMON_HiPrioritySetup` 完整流程图**：它是所有敌人共用的"反应规则核"，比逐个 Logic.Main 更值得画时序图。
4. **小队 AI（`*_platoon.dec.lua` + `common_platoon_func.dec.lua`）**：本文未展开，但 `PLATOON_STATE_*`、`COORDINATE_TYPE_*`、`ORDER_TYPE_*` 暗示 m11_02 多敌组合（如苇名武士+弓兵）有专门的协同规则。

---

## 附录 A — 核心常量速查

```
GOAL_RESULT_Failed   = -1   GOAL_RESULT_Continue = 0    GOAL_RESULT_Success = 1
TARGET_NONE          = -2   TARGET_SELF          = -1
TARGET_ENE_0         = 0    TARGET_LOCALPLAYER   = 21
DIST_Near = -1   DIST_Middle = -2   DIST_Far = -3   DIST_Out = -4   DIST_None = -5

AI_DIR_TYPE_CENTER = 0   F=1   B=2   L=3   R=4   ToF=5 …

INTERUPT_FindEnemy    = 0       INTERUPT_FindAttack       = 1
INTERUPT_Damaged      = 2       INTERUPT_SuccessGuard     = 5
INTERUPT_GuardBreak   = 9       INTERUPT_TargetOutOfRange = 35
INTERUPT_ActivateSpecialEffect = 43
INTERUPT_AIGuardBroken= 50      INTERUPT_BackstabRisk     = 52

PLATOON_STATE_None = 0  Caution = 1  Find = 2  ReplyHelp = 3  Battle = 4
```

## 附录 B — `m11_02` 文件清单

| 敌人 ID | logic | battle 派生 |
|---|---|---|
| 011000 | √（旧式） | 011000 |
| 020000 | √（旧式） | — |
| 101000 落武者 | √ | 101000 / 101010 / 101020 / 101030 |
| 101100 教学落武者 | — | 101100 / 101110 |
| 101200 战斗教学 | √ | 101200 |
| 102000 武士大将 | √ | 102000 / 102010 / 102020 |
| 112000 见张番 | √ | 112000 |
| 115000 新狗 | √ | 115000 |
| 118000 弦庵 | √ | 118000 / 118020 / 118040 |
| 119000 谷敌 | √ | 119020 / 119030 |
| 136000 喇叭手 | √ | 136000 |
| 147000 御荣众 | √ | 147000 |
| 150000 村民僵尸 | √ | 150000 / 150010 / 150020 / 150030 / 150040 / 150050 / 150060 |
| 540000 剑圣弱体 | √ | 540000 / 540010 |
| 540300 剑圣完全 | √ | 540300 / 540310 |
| 710000 弦一郎 | √ | 710000 |
| 711000 弦一郎裸 | √ | 711000 |
| 720000 王子 | √ | 720000 |
| 740000 异性娘 | √ | 740000 |
