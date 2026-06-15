# UE Player Attack Targeting Minimal

## 目标

把 C0000 主角攻击敌人的目标选择拆成两层：

- 索敌/锁定：决定当前关注哪个敌人，用于镜头、面向、攻击前转向、UI。
- 攻击命中拾取：由动画 TAE `InvokeAttackBehavior` 的有效帧创建攻击碰撞体，碰到敌人才算命中。

这两层不能混在一起。锁定目标不是必定命中目标；未锁定时也能通过攻击碰撞打中敌人。

## 当前最小实现

- C0000 动画 TAE `InvokeAttackBehavior` 生效时创建武器攻击胶囊。
- 攻击胶囊按 `DmyPoly 120 -> 100` 生成，跟随右手武器挂点。
- 胶囊 overlap 到 `ASekiroEnemyCharacter` 后，对同一个敌人只命中一次。
- 伤害从胶囊 `Damage:*` 标签读取，当前默认 `30`。
- 敌人 `CurrentHealth <= 0` 发 `Death` 动画命令，否则发 `Reaction` 动画命令。

## 索敌对象

候选目标必须满足：

- Actor 是敌人，当前先用 `ASekiroEnemyCharacter` 或 `Enemy` Tag。
- 敌人未死亡。
- 距离主角小于 `LockSearchDistanceCm`。
- 位于主角前方扇形内，角度小于 `LockSearchHalfAngleDeg`。
- 主角到敌人视线无遮挡。遮挡检测用 capsule/line trace，忽略主角和目标本身。

后续可把候选接口抽成 `ISekiroTargetable`，敌人、Boss、特殊可锁定对象统一实现。

## 锁定目标选择

每帧或按键触发时扫描候选敌人，计算优先级分数：

```text
Score = DistanceScore + ViewAngleScore + ScreenCenterScore + LastTargetBonus
```

推荐权重：

- 距离越近分越高。
- 越接近屏幕中心分越高。
- 越接近角色正前方分越高。
- 当前锁定目标如果仍合法，加一个稳定性 bonus，避免频繁跳目标。

锁定结果：

- `CurrentLockTarget`：当前锁定敌人。
- `bLockOnActive`：玩家是否进入锁定状态。
- `bAutoAimTargetValid`：对应现有 `env(1118)`，表示有可用自动瞄准/锁定目标。

## 自动索敌

未手动锁定时，攻击前可以使用短距离自动索敌。

触发时机：

- 普通攻击按下。
- 攻击动画起手帧。
- 需要轻微朝向修正的攻击 TAE 事件前。

筛选条件比锁定更宽：

- `AutoAimDistanceCm` 小于锁定距离。
- `AutoAimHalfAngleDeg` 可比锁定角度略大。
- 必须无遮挡。

自动索敌只影响：

- 攻击起手朝向。
- 根运动/移动方向修正。
- 动画里的目标相关 env。

自动索敌不直接造成伤害。

## 攻击命中拾取

攻击是否命中只看攻击有效帧碰撞：

1. TAE `InvokeAttackBehavior` Begin。
2. 根据 `BehaviorJudgeID` 找到 AtkParam。
3. 根据 AtkParam / DummyPoly 创建动态攻击碰撞体。
4. 碰撞体挂到武器或骨骼挂点，跟随动画移动。
5. overlap 到敌人 hurtbox 或 capsule。
6. 根据 AtkParam 执行伤害、硬直、击退、特效。
7. TAE `InvokeAttackBehavior` End 销毁碰撞体。

当前实现先 overlap 敌人的 Pawn capsule。后续应拆成敌人 hurtbox，避免打到 capsule 但视觉上没碰到身体的问题。

## 多敌人规则

AtkParam 应控制攻击能命中几个目标：

| 参数 | 含义 |
| --- | --- |
| `bCanHitMultipleTargets` | 是否允许一次攻击打多个敌人 |
| `MaxHitTargets` | 最大命中数量 |
| `bCanHitSameTargetAgain` | 同一次攻击是否能重复命中同一目标 |
| `SameTargetHitInterval` | 重复命中间隔 |

当前最小实现：

- 同一个攻击碰撞对同一个敌人只命中一次。
- 可以命中多个敌人，直到碰撞结束。

后续如果只狼原始 AtkParam 里能读到多目标/重复命中参数，应替换当前规则。

## 防御和弹反

命中拾取之后再进入战斗判定：

```text
AttackCollision overlaps Enemy
  -> Enemy has active guard/parry window?
    -> yes: Guard / Deflect / Rebound
    -> no: Damage / Reaction / Death
```

需要的数据：

- 攻击方：AtkParamID、攻击方向、攻击等级、削韧、属性。
- 防御方：防御窗口、弹反窗口、面向角、体力、姿态值。
- 双方位置：攻击方向、命中点、相对角度。

当前先只做 `Damage -> Reaction/Death`。

## 和只狼脚本的对应关系

| 只狼概念 | UE 对应 |
| --- | --- |
| `TARGET_ENE_0` | 当前战斗目标 / 自动索敌目标 |
| `IsLockOnTarget` | `CurrentLockTarget == Enemy` |
| `IsInsideTarget` | 角色到目标的角度检测 |
| `GetDist(TARGET_ENE_0)` | 角色到目标距离 |
| `InvokeAttackBehavior` | TAE notify state 创建攻击碰撞 |
| `BehaviorJudgeID` | 查 AtkParam / 攻击行为参数的 key |
| DummyPoly | UE socket / 动态挂点 |

## 建议配置

主角配置放在 `PreviewCharacterConfig.lua` 或后续主角 DataAsset：

| 字段 | 默认值 | 用途 |
| --- | ---: | --- |
| `LockSearchDistanceCm` | `1800` | 手动锁定最大距离 |
| `LockSearchHalfAngleDeg` | `70` | 手动锁定前方半角 |
| `LockLoseDistanceCm` | `2200` | 锁定丢失距离 |
| `AutoAimDistanceCm` | `600` | 攻击自动索敌距离 |
| `AutoAimHalfAngleDeg` | `90` | 攻击自动索敌角度 |
| `AttackTurnSpeedDegPerSec` | `720` | 攻击前转向速度 |
| `RequireLineOfSight` | `true` | 是否需要无遮挡 |

## 实现顺序

1. 保留当前攻击碰撞命中敌人的最小实现。
2. 增加 `USekiroPlayerTargetingComponent`，负责扫描敌人和保存 `CurrentLockTarget`。
3. 把 `env(1118)` 接到 `CurrentLockTarget != nullptr || AutoAimTarget != nullptr`。
4. 攻击按下时做一次自动索敌，只修正朝向，不直接命中。
5. 把伤害参数从固定值改成 AtkParam 数据。
6. 敌人 capsule 命中改成 hurtbox 命中。
7. 加入防御、弹反、姿态、击退。

## 验收

- 主角未锁定时，攻击碰撞碰到敌人能造成伤害。
- 主角锁定 A，但挥刀实际碰到 B 时，B 被命中，A 不会凭空受伤。
- 敌人被墙遮挡时不能成为锁定/自动索敌目标。
- 多个敌人同时在攻击碰撞内时，当前最小实现都能被命中一次。
- 敌人死亡后不会再次被索敌和命中。
