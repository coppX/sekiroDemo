#include "SekiroEnemyScriptBrainComponent.h"

#include "SekiroEnemyAnimBridgeComponent.h"
#include "SekiroEnemyCharacter.h"
#include "Components/CapsuleComponent.h"
#include "AIController.h"
#include "GameFramework/Character.h"
#include "GameFramework/CharacterMovementComponent.h"
#include "GameFramework/Pawn.h"
#include "Kismet/GameplayStatics.h"
#include "Navigation/PathFollowingComponent.h"
#include "LuaEnv.h"
#include "UnLuaLegacy.h"
#include "UnLuaModule.h"

namespace
{
	const TCHAR* SekiroBrainStateName(const ESekiroEnemyBrainState State)
	{
		switch (State)
		{
		case ESekiroEnemyBrainState::Idle: return TEXT("Idle");
		case ESekiroEnemyBrainState::Battle: return TEXT("Battle");
		case ESekiroEnemyBrainState::Dead: return TEXT("Dead");
		case ESekiroEnemyBrainState::Caution: return TEXT("Caution");
		case ESekiroEnemyBrainState::Find: return TEXT("Find");
		default: return TEXT("Unknown");
		}
	}
}

USekiroEnemyScriptBrainComponent::USekiroEnemyScriptBrainComponent()
{
	PrimaryComponentTick.bCanEverTick = true;
	PrimaryComponentTick.bStartWithTickEnabled = true;
	bAutoActivate = true;
}

void USekiroEnemyScriptBrainComponent::BeginPlay()
{
	Super::BeginPlay();
	Activate(true);
	HomeLocation = GetOwner() ? GetOwner()->GetActorLocation() : FVector::ZeroVector;
	LastPatrolLocation = HomeLocation;

	if (ACharacter* Character = Cast<ACharacter>(GetOwner()))
	{
		if (!Character->GetController())
		{
			Character->SpawnDefaultController();
		}
		if (UCharacterMovementComponent* Movement = Character->GetCharacterMovement())
		{
			Movement->bRunPhysicsWithNoController = true;
			Movement->SetMovementMode(MOVE_Walking);
		}
	}

	if (EnemyDefinition)
	{
		CombatProfile = EnemyDefinition->CombatProfile;
		if (USekiroEnemyAnimBridgeComponent* Bridge = GetAnimBridge())
		{
			Bridge->AnimProfile = EnemyDefinition->AnimProfile;
		}
	}
}

void USekiroEnemyScriptBrainComponent::TickComponent(
	const float DeltaTime,
	const ELevelTick TickType,
	FActorComponentTickFunction* ThisTickFunction)
{
	Super::TickComponent(DeltaTime, TickType, ThisTickFunction);

	if (const ASekiroEnemyCharacter* Enemy = Cast<ASekiroEnemyCharacter>(GetOwner()); Enemy && Enemy->bDead)
	{
		BrainState = ESekiroEnemyBrainState::Dead;
		StopMove();
		return;
	}

	for (auto It = AttackCooldownRemainingById.CreateIterator(); It; ++It)
	{
		const float Remaining = It.Value() - DeltaTime;
		if (Remaining <= 0.0f)
		{
			It.RemoveCurrent();
		}
		else
		{
			It.Value() = Remaining;
		}
	}
	for (auto It = ScriptTimers.CreateIterator(); It; ++It)
	{
		const float Remaining = It.Value() - DeltaTime;
		if (Remaining <= 0.0f)
		{
			It.RemoveCurrent();
		}
		else
		{
			It.Value() = Remaining;
		}
	}
	WaitRemaining = FMath::Max(0.0f, WaitRemaining - DeltaTime);
	AttackedTargetMemoryRemaining = FMath::Max(0.0f, AttackedTargetMemoryRemaining - DeltaTime);

	if (WaitRemaining > 0.0f)
	{
		StopMove();
		return;
	}

	ThinkAccumulator += DeltaTime;
	if (ThinkAccumulator >= NativeThinkInterval)
	{
		Think(ThinkAccumulator);
		ThinkAccumulator = 0.0f;
	}
	ApplyRequestedMove(DeltaTime);
}

void USekiroEnemyScriptBrainComponent::SetCombatTarget(AActor* NewTarget)
{
	CombatTarget = NewTarget;
}

void USekiroEnemyScriptBrainComponent::ForceAcquireTarget()
{
	AcquireDefaultTarget();
	LastDecisionDebug = CombatTarget
		? FString::Printf(TEXT("TargetAcquired:%s Dist=%.0f"), *CombatTarget->GetName(), GetDistToTarget())
		: TEXT("TargetAcquireFailed");
}

void USekiroEnemyScriptBrainComponent::NotifyAttackedBy(AActor* Attacker)
{
	if (!Attacker || BrainState == ESekiroEnemyBrainState::Dead)
	{
		return;
	}

	CombatTarget = Attacker;
	AttackedTargetMemoryRemaining = FMath::Max(AttackedTargetMemoryRemaining, AttackedTargetMemorySeconds);
	WaitRemaining = 0.0f;
	BrainState = CanSeeCombatTarget() ? ESekiroEnemyBrainState::Battle : ESekiroEnemyBrainState::Find;
	LastDecisionDebug = FString::Printf(TEXT("HitAggro Target=%s Dist=%.0f LOS=%d"),
		*Attacker->GetName(),
		GetDistToTarget(),
		CanSeeCombatTarget() ? 1 : 0);
	if (bDebugScriptBrain)
	{
		UE_LOG(LogTemp, Warning, TEXT("[EnemyAI] HitAggro Enemy=%s Target=%s State=%s Dist=%.0f LOS=%d Memory=%.2f"),
			*GetNameSafe(GetOwner()),
			*GetNameSafe(Attacker),
			SekiroBrainStateName(BrainState),
			GetDistToTarget(),
			CanSeeCombatTarget() ? 1 : 0,
			AttackedTargetMemoryRemaining);
	}
}

float USekiroEnemyScriptBrainComponent::GetDistToTarget() const
{
	const AActor* Owner = GetOwner();
	return Owner && CombatTarget ? FVector::Dist(Owner->GetActorLocation(), CombatTarget->GetActorLocation()) : BIG_NUMBER;
}

void USekiroEnemyScriptBrainComponent::PushInterruptDeath()
{
	BrainState = ESekiroEnemyBrainState::Dead;
	if (USekiroEnemyAnimBridgeComponent* Bridge = GetAnimBridge())
	{
		FSekiroEnemyAnimCommand Command;
		Command.Type = ESekiroEnemyAnimCommandType::Death;
		Command.bCanBeInterrupted = false;
		Bridge->SendAnimCommand(Command);
	}
	LastDecisionDebug = TEXT("Interrupt:Death");
}

void USekiroEnemyScriptBrainComponent::PushInterruptReaction(const int32 StateId)
{
	if (BrainState == ESekiroEnemyBrainState::Dead)
	{
		return;
	}
	if (USekiroEnemyAnimBridgeComponent* Bridge = GetAnimBridge())
	{
		FSekiroEnemyAnimCommand Command;
		Command.Type = ESekiroEnemyAnimCommandType::Reaction;
		Command.StateId = StateId;
		Bridge->SendAnimCommand(Command);
	}
	LastDecisionDebug = FString::Printf(TEXT("Interrupt:Reaction State=%d"), StateId);
}

bool USekiroEnemyScriptBrainComponent::IsDead() const
{
	return BrainState == ESekiroEnemyBrainState::Dead;
}

bool USekiroEnemyScriptBrainComponent::HasBattleTarget() const
{
	const float LoseRadius = CombatProfile ? CombatProfile->LoseTargetRadiusCm : 2000.0f;
	const float Distance = GetDistToTarget();
	if (CombatTarget && AttackedTargetMemoryRemaining > 0.0f)
	{
		return Distance <= FMath::Max(LoseRadius, AttackedTargetChaseRadiusCm);
	}
	return CombatTarget != nullptr
		&& Distance <= LoseRadius
		&& CanSeeCombatTarget();
}

bool USekiroEnemyScriptBrainComponent::HasLineOfSightToTarget() const
{
	return CanSeeCombatTarget();
}

bool USekiroEnemyScriptBrainComponent::IsBattleState() const
{
	return BrainState == ESekiroEnemyBrainState::Battle;
}

bool USekiroEnemyScriptBrainComponent::IsFindState() const
{
	return BrainState == ESekiroEnemyBrainState::Find;
}

bool USekiroEnemyScriptBrainComponent::IsCautionState() const
{
	return BrainState == ESekiroEnemyBrainState::Caution;
}

void USekiroEnemyScriptBrainComponent::PushDeath()
{
	PushInterruptDeath();
}

bool USekiroEnemyScriptBrainComponent::IsAttackCoolingDown(const int32 AttackId) const
{
	return AttackId != INDEX_NONE && AttackCooldownRemainingById.Contains(AttackId);
}

int32 USekiroEnemyScriptBrainComponent::GetRandam_Int(const int32 Min, const int32 Max) const
{
	return FMath::RandRange(Min, Max);
}

float USekiroEnemyScriptBrainComponent::GetRandam_Float(const float Min, const float Max) const
{
	return FMath::FRandRange(Min, Max);
}

int32 USekiroEnemyScriptBrainComponent::DbgGetForceActIdx() const
{
	return 0;
}

void USekiroEnemyScriptBrainComponent::DbgSetLastActIdx(const int32 ActId)
{
	SetLastSelectedAct(ActId);
}

float USekiroEnemyScriptBrainComponent::GetDist(const FName TargetKey) const
{
	const float DistanceCm = TargetKey == TEXT("TARGET_ENE_0") ? GetDistToTarget() : BIG_NUMBER;
	return bUseOriginalSekiroLuaScripts ? DistanceCm * 0.01f : DistanceCm;
}

float USekiroEnemyScriptBrainComponent::GetActRate(const int32 ActId) const
{
	if (CombatProfile)
	{
		if (const float* Rate = CombatProfile->ActRateOverrides.Find(ActId))
		{
			return *Rate;
		}
	}
	return 1.0f;
}

FString USekiroEnemyScriptBrainComponent::GetBattleScriptModule() const
{
	return EnemyDefinition && !EnemyDefinition->BattleScript.IsEmpty()
		? EnemyDefinition->BattleScript
		: FString();
}

void USekiroEnemyScriptBrainComponent::SetTimer(const int32 TimerId, const float Seconds)
{
	if (TimerId != INDEX_NONE && Seconds > 0.0f)
	{
		ScriptTimers.FindOrAdd(TimerId) = Seconds;
	}
}

bool USekiroEnemyScriptBrainComponent::IsFinishTimer(const int32 TimerId) const
{
	return !ScriptTimers.Contains(TimerId);
}

void USekiroEnemyScriptBrainComponent::SetNumber(const int32 Index, const int32 Value)
{
	ScriptNumbers.FindOrAdd(Index) = Value;
}

int32 USekiroEnemyScriptBrainComponent::GetNumber(const int32 Index) const
{
	if (const int32* Value = ScriptNumbers.Find(Index))
	{
		return *Value;
	}
	return 0;
}

void USekiroEnemyScriptBrainComponent::SetStringIndexedNumber(const FName Key, const float Value)
{
	ScriptNamedNumbers.FindOrAdd(Key) = Value;
}

float USekiroEnemyScriptBrainComponent::GetStringIndexedNumber(const FName Key) const
{
	if (const float* Value = ScriptNamedNumbers.Find(Key))
	{
		return *Value;
	}
	return 0.0f;
}

float USekiroEnemyScriptBrainComponent::GetHpRate(const FName TargetKey) const
{
	const ASekiroEnemyCharacter* Enemy = Cast<ASekiroEnemyCharacter>(GetOwner());
	if (TargetKey == TEXT("TARGET_SELF") && Enemy && Enemy->MaxHealth > 0.0f)
	{
		return Enemy->CurrentHealth / Enemy->MaxHealth;
	}
	return 1.0f;
}

float USekiroEnemyScriptBrainComponent::GetSpRate(const FName TargetKey) const
{
	return 1.0f;
}

float USekiroEnemyScriptBrainComponent::GetSp(const FName TargetKey) const
{
	return 100.0f;
}

float USekiroEnemyScriptBrainComponent::GetMapHitRadius(const FName TargetKey) const
{
	const ACharacter* Character = Cast<ACharacter>(TargetKey == TEXT("TARGET_ENE_0") ? CombatTarget.Get() : GetOwner());
	const UCapsuleComponent* Capsule = Character ? Character->GetCapsuleComponent() : nullptr;
	const float RadiusCm = Capsule ? Capsule->GetScaledCapsuleRadius() : 42.0f;
	return bUseOriginalSekiroLuaScripts ? RadiusCm * 0.01f : RadiusCm;
}

int32 USekiroEnemyScriptBrainComponent::GetExcelParam(const int32 ParamId) const
{
	return 0;
}

bool USekiroEnemyScriptBrainComponent::HasSpecialEffectId(const FName TargetKey, const int32 EffectId) const
{
	if (bUseOriginalSekiroLuaScripts
		&& TargetKey == TEXT("TARGET_SELF")
		&& OriginalSekiroFallbackSelfSpecialEffect != INDEX_NONE
		&& EffectId == OriginalSekiroFallbackSelfSpecialEffect)
	{
		return true;
	}
	return false;
}

bool USekiroEnemyScriptBrainComponent::IsTargetGuard(const FName TargetKey) const
{
	return false;
}

bool USekiroEnemyScriptBrainComponent::IsInsideTarget(const FName TargetKey, const FName Direction, const float AngleDegrees) const
{
	const AActor* Owner = GetOwner();
	const AActor* Target = TargetKey == TEXT("TARGET_ENE_0") ? CombatTarget.Get() : Owner;
	if (!Owner || !Target)
	{
		return false;
	}

	FVector Basis = Owner->GetActorForwardVector().GetSafeNormal2D();
	if (Direction == TEXT("AI_DIR_TYPE_B"))
	{
		Basis *= -1.0f;
	}
	else if (Direction == TEXT("AI_DIR_TYPE_L"))
	{
		Basis = -Owner->GetActorRightVector().GetSafeNormal2D();
	}
	else if (Direction == TEXT("AI_DIR_TYPE_R"))
	{
		Basis = Owner->GetActorRightVector().GetSafeNormal2D();
	}

	const FVector ToTarget = (Target->GetActorLocation() - Owner->GetActorLocation()).GetSafeNormal2D();
	const float Dot = FVector::DotProduct(Basis, ToTarget);
	return Dot >= FMath::Cos(FMath::DegreesToRadians(FMath::Clamp(AngleDegrees, 0.0f, 360.0f) * 0.5f));
}

bool USekiroEnemyScriptBrainComponent::IsInsideTargetEx(
	const FName TargetKey,
	const FName BaseTargetKey,
	const FName Direction,
	const float AngleDegrees,
	const float MaxDistanceCm) const
{
	return GetDist(TargetKey) <= MaxDistanceCm && IsInsideTarget(BaseTargetKey == TEXT("TARGET_SELF") ? TargetKey : BaseTargetKey, Direction, AngleDegrees);
}

bool USekiroEnemyScriptBrainComponent::CheckDoesExistPath(
	const FName TargetKey,
	const FName Direction,
	const float AngleDegrees,
	const float DistanceCm) const
{
	if (TargetKey == TEXT("TARGET_ENE_0"))
	{
		return CanSeeCombatTarget();
	}
	return SpaceCheck(AngleDegrees, DistanceCm);
}

bool USekiroEnemyScriptBrainComponent::SpaceCheck(const float AngleDegrees, const float DistanceCm) const
{
	const AActor* Owner = GetOwner();
	const UWorld* World = Owner ? Owner->GetWorld() : nullptr;
	if (!Owner || !World)
	{
		return false;
	}

	const float Distance = DistanceCm > 20.0f ? DistanceCm : DistanceCm * 100.0f;
	const FVector Direction = Owner->GetActorForwardVector().RotateAngleAxis(AngleDegrees, FVector::UpVector).GetSafeNormal2D();
	const FVector Start = Owner->GetActorLocation() + FVector(0.0f, 0.0f, 50.0f);
	const FVector End = Start + Direction * Distance;
	FCollisionQueryParams Params(SCENE_QUERY_STAT(SekiroEnemySpaceCheck), false);
	Params.AddIgnoredActor(Owner);
	if (CombatTarget)
	{
		Params.AddIgnoredActor(CombatTarget);
	}
	FHitResult Hit;
	return !World->LineTraceSingleByChannel(Hit, Start, End, ECC_Visibility, Params);
}

void USekiroEnemyScriptBrainComponent::SetLastSelectedAct(const int32 ActId)
{
	LastSelectedAct = ActId;
}

void USekiroEnemyScriptBrainComponent::ScriptApproach(const float StopDistanceCm)
{
	const float Distance = GetDistToTarget();
	if (Distance > StopDistanceCm)
	{
		TickApproach(NativeThinkInterval, Distance);
		LastDecisionDebug = FString::Printf(TEXT("Lua:Approach Act=%d Dist=%.0f"), LastSelectedAct, Distance);
		if (bDebugScriptBrain)
		{
			UE_LOG(LogTemp, Warning, TEXT("[EnemyAI] Approach Enemy=%s Act=%d Dist=%.0f Stop=%.0f Target=%s"),
				*GetNameSafe(GetOwner()),
				LastSelectedAct,
				Distance,
				StopDistanceCm,
				*GetNameSafe(CombatTarget.Get()));
		}
	}
}

void USekiroEnemyScriptBrainComponent::ScriptAttack(const int32 AttackId)
{
	const float MaxAttackDistance = (CombatProfile ? CombatProfile->PreferredDistanceCm : 320.0f) + 120.0f;
	ScriptAttackAtRange(AttackId, MaxAttackDistance);
}

void USekiroEnemyScriptBrainComponent::ScriptAttackAtRange(const int32 AttackId, const float MaxDistanceCm)
{
	const float Distance = GetDistToTarget();
	const float MaxAttackDistance = FMath::Max(100.0f, MaxDistanceCm);
	if (IsAttackCoolingDown(AttackId))
	{
		if (Distance <= MaxAttackDistance)
		{
			StopMove();
		}
		LastDecisionDebug = FString::Printf(TEXT("Lua:AttackCooldown Act=%d AttackId=%d"), LastSelectedAct, AttackId);
		return;
	}
	if (Distance > MaxAttackDistance)
	{
		LastDecisionDebug = FString::Printf(TEXT("Lua:AttackDeferred Act=%d AttackId=%d"), LastSelectedAct, AttackId);
		if (bDebugScriptBrain)
		{
			UE_LOG(LogTemp, Warning, TEXT("[EnemyAI] AttackDeferred Enemy=%s Act=%d AttackId=%d Dist=%.0f Max=%.0f"),
				*GetNameSafe(GetOwner()), LastSelectedAct, AttackId, Distance, MaxAttackDistance);
		}
		return;
	}
	StopMove();
	if (USekiroEnemyAnimBridgeComponent* Bridge = GetAnimBridge())
	{
		Bridge->SendAttackCommand(AttackId);
	}
	AttackCooldownRemainingById.FindOrAdd(AttackId) = GetAttackCooldown(AttackId);
	LastDecisionDebug = FString::Printf(TEXT("Lua:Attack Act=%d AttackId=%d"), LastSelectedAct, AttackId);
	if (bDebugScriptBrain)
	{
		UE_LOG(LogTemp, Warning, TEXT("[EnemyAI] Attack Enemy=%s Act=%d AttackId=%d Dist=%.0f"),
			*GetNameSafe(GetOwner()), LastSelectedAct, AttackId, Distance);
	}
}

void USekiroEnemyScriptBrainComponent::ScriptSidewayMove(const int32 Direction)
{
	if (ACharacter* Character = Cast<ACharacter>(GetOwner()))
	{
		const FVector Right = Character->GetActorRightVector() * (Direction == 0 ? -1.0f : 1.0f);
		RequestMove(Right, 0.7f, 180.0f);
	}
	if (USekiroEnemyAnimBridgeComponent* Bridge = GetAnimBridge())
	{
		Bridge->SendMoveCommand(0.5f, Direction == 0 ? -1.0f : 1.0f);
	}
	LastDecisionDebug = FString::Printf(TEXT("Lua:Sideway Act=%d Dir=%d"), LastSelectedAct, Direction);
}

void USekiroEnemyScriptBrainComponent::ScriptLeaveTarget(const float KeepDistanceCm)
{
	ACharacter* Character = Cast<ACharacter>(GetOwner());
	if (!Character || !CombatTarget)
	{
		return;
	}

	const FVector Away = (Character->GetActorLocation() - CombatTarget->GetActorLocation()).GetSafeNormal2D();
	RequestMove(Away, 0.8f, 220.0f);
	if (USekiroEnemyAnimBridgeComponent* Bridge = GetAnimBridge())
	{
		Bridge->SendMoveCommand(0.5f, 0.0f);
	}
	LastDecisionDebug = FString::Printf(TEXT("Lua:Leave Act=%d Keep=%.0f"), LastSelectedAct, KeepDistanceCm);
}

void USekiroEnemyScriptBrainComponent::ScriptTurnToTarget()
{
	TurnToTarget(NativeThinkInterval);
	LastDecisionDebug = FString::Printf(TEXT("Lua:Turn Act=%d Dist=%.0f"), LastSelectedAct, GetDistToTarget());
}

void USekiroEnemyScriptBrainComponent::ScriptWait(const float Seconds)
{
	WaitRemaining = FMath::Max(WaitRemaining, Seconds);
	StopMove();
	LastDecisionDebug = FString::Printf(TEXT("Lua:Wait Act=%d Seconds=%.2f"), LastSelectedAct, Seconds);
}

void USekiroEnemyScriptBrainComponent::ScriptPatrol()
{
	TickPatrol(NativeThinkInterval);
}

void USekiroEnemyScriptBrainComponent::ClearSubGoal()
{
	LastSelectedAct = 0;
}

void USekiroEnemyScriptBrainComponent::ScriptSetWeaponStyle(const FName WeaponStyle)
{
	if (ASekiroEnemyCharacter* Enemy = Cast<ASekiroEnemyCharacter>(GetOwner()))
	{
		Enemy->SetEnemyWeaponStyleByName(WeaponStyle);
		Enemy->RefreshEnemyWeaponAttachment();
		LastDecisionDebug = FString::Printf(TEXT("Lua:WeaponStyle %s"), *WeaponStyle.ToString());
	}
}

void USekiroEnemyScriptBrainComponent::Think(const float DeltaTime)
{
	if (!CombatTarget)
	{
		AcquireDefaultTarget();
	}
	RefreshPerceptionState();
	if (bUseLuaScript && TryRunLuaLogic(DeltaTime))
	{
		return;
	}
	NativeThink(DeltaTime);
}

void USekiroEnemyScriptBrainComponent::AcquireDefaultTarget()
{
	CombatTarget = UGameplayStatics::GetPlayerPawn(this, 0);
	if (CombatTarget)
	{
		return;
	}

	TArray<AActor*> Pawns;
	UGameplayStatics::GetAllActorsOfClass(this, APawn::StaticClass(), Pawns);
	AActor* BestTarget = nullptr;
	float BestDistSq = BIG_NUMBER;
	for (AActor* Pawn : Pawns)
	{
		if (!Pawn || Pawn == GetOwner())
		{
			continue;
		}
		const float DistSq = FVector::DistSquared(Pawn->GetActorLocation(), GetOwner()->GetActorLocation());
		if (DistSq < BestDistSq)
		{
			BestTarget = Pawn;
			BestDistSq = DistSq;
		}
	}
	CombatTarget = BestTarget;
}

void USekiroEnemyScriptBrainComponent::RefreshPerceptionState()
{
	if (BrainState == ESekiroEnemyBrainState::Dead)
	{
		return;
	}

	const float LoseRadius = CombatProfile ? CombatProfile->LoseTargetRadiusCm : 2000.0f;
	const float Distance = GetDistToTarget();
	const bool bHasAttackMemory = CombatTarget && AttackedTargetMemoryRemaining > 0.0f;
	const float EffectiveLoseRadius = bHasAttackMemory ? FMath::Max(LoseRadius, AttackedTargetChaseRadiusCm) : LoseRadius;
	if (!CombatTarget || Distance > EffectiveLoseRadius)
	{
		BrainState = ESekiroEnemyBrainState::Idle;
	}
	else if (!CanSeeCombatTarget())
	{
		BrainState = AttackedTargetMemoryRemaining > 0.0f
			? ESekiroEnemyBrainState::Find
			: ESekiroEnemyBrainState::Caution;
	}
	else
	{
		BrainState = ESekiroEnemyBrainState::Battle;
	}

	if (bDebugScriptBrain && BrainState != LastLoggedBrainState)
	{
		UE_LOG(LogTemp, Warning, TEXT("[EnemyAI] State Enemy=%s %s->%s Target=%s Dist=%.0f LOS=%d Memory=%.2f Lose=%.0f"),
			*GetNameSafe(GetOwner()),
			SekiroBrainStateName(LastLoggedBrainState),
			SekiroBrainStateName(BrainState),
			*GetNameSafe(CombatTarget.Get()),
			Distance,
			CanSeeCombatTarget() ? 1 : 0,
			AttackedTargetMemoryRemaining,
			EffectiveLoseRadius);
		LastLoggedBrainState = BrainState;
	}
}

bool USekiroEnemyScriptBrainComponent::TryRunLuaLogic(const float DeltaTime)
{
	const FString ModuleName = bUseOriginalSekiroLuaScripts
		? TEXT("Sekiro.Enemy.OriginalRuntime")
		: (EnemyDefinition ? EnemyDefinition->LogicScript : FString());
	if (ModuleName.IsEmpty())
	{
		return false;
	}

	IUnLuaModule& UnLuaModule = IUnLuaModule::Get();
	if (!UnLuaModule.IsActive())
	{
#if WITH_EDITOR
		UnLuaModule.SetActive(true);
#else
		return false;
#endif
	}

	UnLua::FLuaEnv* LuaEnv = UnLuaModule.GetEnv(this);
	if (!LuaEnv)
	{
		LuaEnv = UnLuaModule.GetEnv();
	}
	lua_State* LuaState = LuaEnv ? LuaEnv->GetMainState() : nullptr;
	if (!LuaState)
	{
		return false;
	}

	const int32 OriginalTop = lua_gettop(LuaState);
	bool bSucceeded = false;
	lua_getglobal(LuaState, "require");
	lua_pushstring(LuaState, TCHAR_TO_UTF8(*ModuleName));
	if (lua_pcall(LuaState, 1, 1, 0) == LUA_OK && lua_istable(LuaState, -1))
	{
		lua_getfield(LuaState, -1, "Main");
		if (lua_isfunction(LuaState, -1))
		{
			UnLua::PushUObject(LuaState, this);
			if (bUseOriginalSekiroLuaScripts)
			{
				lua_pushinteger(LuaState, OriginalSekiroLogicId);
			}
			else
			{
				UnLua::PushUObject(LuaState, this);
			}
			if (lua_pcall(LuaState, 2, 0, 0) == LUA_OK)
			{
				bSucceeded = true;
			}
			else
			{
				const char* Error = lua_tostring(LuaState, -1);
				LastDecisionDebug = FString::Printf(TEXT("Lua:MainFailed %s"), Error ? UTF8_TO_TCHAR(Error) : TEXT("unknown"));
			}
		}
	}
	else
	{
		const char* Error = lua_tostring(LuaState, -1);
		LastDecisionDebug = FString::Printf(TEXT("Lua:RequireFailed %s"), Error ? UTF8_TO_TCHAR(Error) : TEXT("unknown"));
	}
	lua_settop(LuaState, OriginalTop);
	if (bSucceeded)
	{
		RefreshPerceptionState();
		if (BrainState == ESekiroEnemyBrainState::Battle || BrainState == ESekiroEnemyBrainState::Find)
		{
			TurnToTarget(DeltaTime);
		}
	}
	return bSucceeded;
}

void USekiroEnemyScriptBrainComponent::NativeThink(const float DeltaTime)
{
	if (BrainState == ESekiroEnemyBrainState::Dead)
	{
		StopMove();
		return;
	}

	AActor* Owner = GetOwner();
	if (!Owner)
	{
		return;
	}

	if (!CombatTarget)
	{
		CombatTarget = UGameplayStatics::GetPlayerPawn(this, 0);
	}

	const float Distance = GetDistToTarget();
	const float BattleRadius = CombatProfile ? CombatProfile->BattleRadiusCm : 1200.0f;
	const float LoseRadius = CombatProfile ? CombatProfile->LoseTargetRadiusCm : 2000.0f;
	if (!CombatTarget || Distance > LoseRadius || !CanSeeCombatTarget())
	{
		BrainState = ESekiroEnemyBrainState::Idle;
		TickPatrol(DeltaTime);
		LastDecisionDebug = !CombatTarget || Distance > LoseRadius
			? FString::Printf(TEXT("Patrol:NoTarget Dist=%.0f"), Distance)
			: FString::Printf(TEXT("Patrol:TargetOccluded Dist=%.0f"), Distance);
		return;
	}

	if (Distance > BattleRadius)
	{
		BrainState = ESekiroEnemyBrainState::Battle;
		TurnToTarget(DeltaTime);
		TickApproach(DeltaTime, Distance);
		LastDecisionDebug = FString::Printf(TEXT("Battle:ChaseFar Dist=%.0f"), Distance);
		return;
	}

	BrainState = ESekiroEnemyBrainState::Battle;
	TurnToTarget(DeltaTime);

	const float PreferredDistance = CombatProfile ? CombatProfile->PreferredDistanceCm : 320.0f;
	if (Distance > PreferredDistance)
	{
		TickApproach(DeltaTime, Distance);
		LastDecisionDebug = FString::Printf(TEXT("Battle:Approach Dist=%.0f"), Distance);
		return;
	}

	if (!IsAttackCoolingDown(DefaultAttackId))
	{
		StopMove();
		if (USekiroEnemyAnimBridgeComponent* Bridge = GetAnimBridge())
		{
			Bridge->SendAttackCommand(DefaultAttackId);
		}
		AttackCooldownRemainingById.FindOrAdd(DefaultAttackId) = GetAttackCooldown(DefaultAttackId);
		LastDecisionDebug = FString::Printf(TEXT("Battle:Act01 AttackId=%d Dist=%.0f"), DefaultAttackId, Distance);
	}
	else
	{
		StopMove();
	}
}

void USekiroEnemyScriptBrainComponent::TickApproach(const float DeltaTime, const float Distance)
{
	ACharacter* Character = Cast<ACharacter>(GetOwner());
	if (!Character || !CombatTarget)
	{
		return;
	}

	const FVector ToTarget = (CombatTarget->GetActorLocation() - Character->GetActorLocation()).GetSafeNormal2D();
	const float MoveSpeed = Distance > 600.0f ? 300.0f : 180.0f;
	RequestMove(ToTarget, 1.0f, MoveSpeed);
	if (AAIController* AIController = Cast<AAIController>(Character->GetController()))
	{
		const EPathFollowingRequestResult::Type Result = AIController->MoveToActor(
			CombatTarget.Get(),
			FMath::Max(20.0f, CombatProfile ? CombatProfile->PreferredDistanceCm : 180.0f),
			true,
			true,
			true,
			nullptr,
			true);
		bRequestedMoveUsesNavigation = Result == EPathFollowingRequestResult::RequestSuccessful
			|| Result == EPathFollowingRequestResult::AlreadyAtGoal;
	}
	if (UCharacterMovementComponent* Movement = Character->GetCharacterMovement())
	{
		Movement->bRunPhysicsWithNoController = true;
		if (Movement->MovementMode == MOVE_None)
		{
			Movement->SetMovementMode(MOVE_Walking);
		}
		Movement->MaxWalkSpeed = MoveSpeed;
	}
	if (USekiroEnemyAnimBridgeComponent* Bridge = GetAnimBridge())
	{
		Bridge->SendMoveCommand(Distance > 600.0f ? 1.0f : 0.5f, 0.0f);
	}
}

void USekiroEnemyScriptBrainComponent::TickPatrol(const float DeltaTime)
{
	ACharacter* Character = Cast<ACharacter>(GetOwner());
	if (!Character || !bEnablePatrol)
	{
		StopMove();
		LastDecisionDebug = TEXT("Patrol:Disabled");
		return;
	}

	const FVector Current = Character->GetActorLocation();
	const float DistanceToPatrol = bHasPatrolTarget ? FVector::Dist2D(Current, PatrolTargetLocation) : BIG_NUMBER;
	if (bHasPatrolTarget && DistanceToPatrol > PatrolAcceptRadiusCm)
	{
		const float MovedDistance = FVector::Dist2D(Current, LastPatrolLocation);
		PatrolStuckTimer = MovedDistance <= PatrolStuckDistanceCm ? PatrolStuckTimer + DeltaTime : 0.0f;
		if (PatrolStuckTimer >= PatrolStuckSeconds)
		{
			bHasPatrolTarget = false;
			PatrolStuckTimer = 0.0f;
			LastDecisionDebug = TEXT("Patrol:StuckRepath");
		}
	}
	else
	{
		PatrolStuckTimer = 0.0f;
	}
	LastPatrolLocation = Current;

	if (!bHasPatrolTarget || FVector::Dist2D(Current, PatrolTargetLocation) <= PatrolAcceptRadiusCm)
	{
		const UWorld* World = Character->GetWorld();
		FVector Candidate = Current;
		for (int32 Attempt = 0; Attempt < 8; ++Attempt)
		{
			const FVector2D Rand = FMath::RandPointInCircle(PatrolRadiusCm);
			Candidate = HomeLocation + FVector(Rand.X, Rand.Y, 0.0f);
			if (!World)
			{
				break;
			}

			FHitResult Hit;
			FCollisionQueryParams Params(SCENE_QUERY_STAT(SekiroEnemyPatrol), false);
			Params.AddIgnoredActor(Character);
			const bool bBlocked = World->LineTraceSingleByChannel(
				Hit,
				Current + FVector(0.0f, 0.0f, 50.0f),
				Candidate + FVector(0.0f, 0.0f, 50.0f),
				ECC_Visibility,
				Params);
			if (!bBlocked)
			{
				break;
			}
		}
		PatrolTargetLocation = Candidate;
		bHasPatrolTarget = true;
	}

	const FVector ToPatrol = PatrolTargetLocation - Current;
	const FVector Direction = ToPatrol.GetSafeNormal2D();
	if (!Direction.IsNearlyZero())
	{
		RequestMove(Direction, 0.5f, PatrolSpeedCm);
		if (AAIController* AIController = Cast<AAIController>(Character->GetController()))
		{
			const EPathFollowingRequestResult::Type Result = AIController->MoveToLocation(
				PatrolTargetLocation,
				PatrolAcceptRadiusCm,
				true,
				true,
				true,
				true,
				nullptr,
				true);
			bRequestedMoveUsesNavigation = Result == EPathFollowingRequestResult::RequestSuccessful
				|| Result == EPathFollowingRequestResult::AlreadyAtGoal;
		}
		const FRotator Desired(0.0f, Direction.Rotation().Yaw, 0.0f);
		Character->SetActorRotation(FMath::RInterpTo(Character->GetActorRotation(), Desired, DeltaTime, 4.0f));
	}

	if (UCharacterMovementComponent* Movement = Character->GetCharacterMovement())
	{
		Movement->bRunPhysicsWithNoController = true;
		if (Movement->MovementMode == MOVE_None)
		{
			Movement->SetMovementMode(MOVE_Walking);
		}
		Movement->MaxWalkSpeed = PatrolSpeedCm;
	}
	if (USekiroEnemyAnimBridgeComponent* Bridge = GetAnimBridge())
	{
		Bridge->SendMoveCommand(0.5f, 0.0f);
	}
	LastDecisionDebug = FString::Printf(TEXT("Patrol:Move Dist=%.0f"), FVector::Dist2D(Current, PatrolTargetLocation));
}

void USekiroEnemyScriptBrainComponent::RequestMove(const FVector& Direction, const float Scale, const float Speed)
{
	RequestedMoveDirection = Direction.GetSafeNormal2D();
	RequestedMoveScale = Scale;
	RequestedMoveSpeed = Speed;
	bHasRequestedMove = !RequestedMoveDirection.IsNearlyZero() && Scale > 0.0f;
	bRequestedMoveUsesNavigation = false;
}

void USekiroEnemyScriptBrainComponent::StopMove()
{
	bHasRequestedMove = false;
	RequestedMoveDirection = FVector::ZeroVector;
	RequestedMoveScale = 0.0f;
	RequestedMoveSpeed = 0.0f;
	bRequestedMoveUsesNavigation = false;
	if (ACharacter* Character = Cast<ACharacter>(GetOwner()))
	{
		if (AAIController* AIController = Cast<AAIController>(Character->GetController()))
		{
			AIController->StopMovement();
		}
	}
	if (USekiroEnemyAnimBridgeComponent* Bridge = GetAnimBridge())
	{
		Bridge->SendMoveCommand(0.0f, 0.0f);
	}
}

void USekiroEnemyScriptBrainComponent::ApplyRequestedMove(const float DeltaTime)
{
	ACharacter* Character = Cast<ACharacter>(GetOwner());
	if (!Character || !bHasRequestedMove)
	{
		return;
	}

	if (!bRequestedMoveUsesNavigation)
	{
		Character->AddMovementInput(RequestedMoveDirection, RequestedMoveScale, true);
	}
	if (UCharacterMovementComponent* Movement = Character->GetCharacterMovement())
	{
		Movement->bRunPhysicsWithNoController = true;
		if (Movement->MovementMode == MOVE_None)
		{
			Movement->SetMovementMode(MOVE_Walking);
		}
		if (RequestedMoveSpeed > 0.0f)
		{
			Movement->MaxWalkSpeed = RequestedMoveSpeed;
		}
	}
}

void USekiroEnemyScriptBrainComponent::TurnToTarget(const float DeltaTime)
{
	AActor* Owner = GetOwner();
	if (!Owner || !CombatTarget)
	{
		return;
	}

	const FVector ToTarget = CombatTarget->GetActorLocation() - Owner->GetActorLocation();
	if (ToTarget.IsNearlyZero())
	{
		return;
	}

	const FRotator Desired(0.0f, ToTarget.Rotation().Yaw, 0.0f);
	Owner->SetActorRotation(FMath::RInterpTo(Owner->GetActorRotation(), Desired, DeltaTime, 8.0f));
}

bool USekiroEnemyScriptBrainComponent::CanSeeCombatTarget() const
{
	if (!bRequireLineOfSightForBattle)
	{
		return CombatTarget != nullptr;
	}

	const AActor* Owner = GetOwner();
	const UWorld* World = Owner ? Owner->GetWorld() : nullptr;
	if (!Owner || !CombatTarget || !World)
	{
		return false;
	}

	const FVector Start = Owner->GetActorLocation() + FVector(0.0f, 0.0f, SightStartHeightCm);
	const FVector End = CombatTarget->GetActorLocation() + FVector(0.0f, 0.0f, SightTargetHeightCm);

	FCollisionQueryParams Params(SCENE_QUERY_STAT(SekiroEnemySight), false);
	Params.AddIgnoredActor(Owner);
	Params.AddIgnoredActor(CombatTarget);

	FHitResult Hit;
	const bool bBlocked = World->LineTraceSingleByChannel(Hit, Start, End, ECC_Visibility, Params);
	return !bBlocked;
}

float USekiroEnemyScriptBrainComponent::GetAttackCooldown(const int32 AttackId) const
{
	if (CombatProfile)
	{
		if (const float* Cooldown = CombatProfile->AttackCooldowns.Find(AttackId))
		{
			return *Cooldown;
		}
	}
	return 3.0f;
}

USekiroEnemyAnimBridgeComponent* USekiroEnemyScriptBrainComponent::GetAnimBridge() const
{
	return GetOwner() ? GetOwner()->FindComponentByClass<USekiroEnemyAnimBridgeComponent>() : nullptr;
}
