# UE 正面忍杀设计

## 范围

当前阶段只实现 C0000 对 C1010 的正面地面忍杀。流程采用只狼 HKX 的双阶段结构：

```text
玩家侧: NewThrowAtk_SM / ThrowAtk512500 -> NewThrowKill_SM / ThrowKill512501
敌人侧: ThrowDef_SM / ThrowDef12000 -> ThrowDefDeath_SM / ThrowDefDeath12001
```

背后潜行忍杀、空中忍杀、大型敌人分支、完整 ThrowCategory 选择表先保留接口，不在本阶段展开。

## 正面地面链路

已确认当前 C1010 正面地面忍杀不应使用 `ThrowAtk516510 -> ThrowKill516511`。`516510` 本身已经包含较完整的刺入/拔出动作，继续接 `516511` 会产生动作重复和衔接错误。

推荐链路如下：

| 阶段 | C0000 状态 | C0000 动画 | C1010/C9997 状态 | C1010 动画 | 作用 |
| --- | --- | --- | --- | --- | --- |
| Atk | `ThrowAtk512500` | `a202_512500` | `ThrowDef12000` | `a000_012000` | 正面地面刺入、双方对齐、敌人进入受制 |
| Kill | `ThrowKill512501` | `a216_512501` | `ThrowDefDeath12001` | `a000_012001` | 后续处决、敌人死亡收尾 |

补充说明：

- `ThrowAtk512500` 在 HKX 中属于 `NewThrowAtk_SM`，其 selector 下包含多个 clip；当前正面地面表现选择 `a202_512500`。
- `ThrowKill512501` 在 HKX 中属于 `NewThrowKill_SM`，对应 clip 为 `a216_512501`。
- C1010 继承 C9997 的敌人侧状态，正面受制使用 `ThrowDef12000`，死亡阶段使用 `ThrowDefDeath12001`。
- C1010 的 `ThrowDef12000` 有 `a000_012000` 和 `a400_012000` 变体；当前先只接 `a000_012000`，暂不处理 `a400`。

## 运行时流程

1. 玩家按攻击键时，先尝试 `TryStartFrontDeathblow`，失败后再回退到普通攻击。
2. 目标必须满足：未死亡、`bDeathblowOpen` 为 true、在 `DeathblowMaxRangeCm` 内、位于玩家正面扇区内、视线可见。
3. 进入 Atk 阶段：
   - 敌人调用 `BeginFrontDeathblow`，停止 AI/移动，进入 `ThrowDef12000`。
   - 玩家写入 `Selector_ThrowId = 512500`。
   - 玩家触发 `Req_W_ThrowAtk512500 = true`。
   - `EnvQuery->ThrowAnimationId = 512500`，`bThrowActive = true`。
4. Atk 阶段持续进行双方对齐：
   - 敌人朝向玩家。
   - 玩家放到敌人正前方 `FrontDeathblowAlignDistanceCm`。
   - 双方移动速度清零，避免 root motion 前的偏移扩大。
5. 到达 Kill 切入时间后：
   - 玩家写入 `Selector_ThrowId = 512501`。
   - 玩家触发 `FSM_NewThrowAtkFinished = true` 和 `Req_W_ThrowKill512501 = true`。
   - 敌人调用 `ConfirmFrontDeathblowKill`，进入 `ThrowDefDeath12001`。
   - `EnvQuery->ThrowAnimationId = 512501`，`bThrowKillRequested = true`。
6. Kill 阶段结束后关闭 `bThrowActive`，清理 `FrontDeathblowTarget`，后续恢复普通状态或进入死亡处理。

## UE 侧动画变量

玩家侧关键变量：

```text
Selector_ThrowId
Req_W_ThrowAtk512500
Req_W_ThrowKill512501
FSM_NewThrowAtkFinished
FSM_NewThrowKillFinished
```

敌人侧关键变量：

```text
EnemyLayer = 4
EnemyStateId = 12000 / 12001
ThrowDef12000_Selected = true
ThrowDefDeath12001_Selected = true
C9997_Req_ThrowDef = true
C9997_Req_ThrowDefDeath = true
```

## 后续工作

- 用正式姿态/架势系统替换临时的 `bDeathblowOpen` 开关。
- 建立 ThrowCategory 到玩家/敌人动画对的配置表，避免再硬编码 `512500/512501/12000/12001`。
- 按 TAE 事件或动画结束事件关闭 throw 状态，而不是完全依赖固定 timer。
- 再接背后潜行忍杀链路，例如 `ThrowKill516411` 相关分支。
