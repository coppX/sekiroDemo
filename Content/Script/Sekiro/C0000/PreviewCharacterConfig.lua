local M = {}

-- Toggle this when checking runtime animation/state asset logs.
M.EnableRuntimeAnimLog = true

-- Enemy proximity threshold in centimeters. Draw at or below this distance,
-- sheathe above it.
M.EnemyAutoWeaponDistanceCm = 1000.0

-- Max target search distance for TAE-driven attack facing.
M.AttackFaceTargetDistanceCm = 2500.0

-- Front combat deathblow range/sector.
M.DeathblowMaxRangeCm = 180.0
M.DeathblowFrontAngleDegrees = 130.0

M.LocomotionWeaponBlendRate = 6.0

_G.EnemyAutoWeaponDistanceCm = M.EnemyAutoWeaponDistanceCm
_G.AttackFaceTargetDistanceCm = M.AttackFaceTargetDistanceCm
_G.DeathblowMaxRangeCm = M.DeathblowMaxRangeCm
_G.DeathblowFrontAngleDegrees = M.DeathblowFrontAngleDegrees
_G.LocomotionWeaponBlendRate = M.LocomotionWeaponBlendRate

return M
