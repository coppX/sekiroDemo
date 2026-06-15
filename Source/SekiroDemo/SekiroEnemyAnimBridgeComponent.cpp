#include "SekiroEnemyAnimBridgeComponent.h"

#include "Animation/AnimInstance.h"
#include "GameFramework/Character.h"
#include "Components/SkeletalMeshComponent.h"
#include "Engine/World.h"
#include "TimerManager.h"
#include "UObject/UnrealType.h"

USekiroEnemyAnimBridgeComponent::USekiroEnemyAnimBridgeComponent()
{
	PrimaryComponentTick.bCanEverTick = false;
	bAutoActivate = true;
}

UAnimInstance* USekiroEnemyAnimBridgeComponent::GetOwnerAnimInstance() const
{
	const ACharacter* Character = Cast<ACharacter>(GetOwner());
	const USkeletalMeshComponent* Mesh = Character ? Character->GetMesh() : nullptr;
	return Mesh ? Mesh->GetAnimInstance() : nullptr;
}

bool USekiroEnemyAnimBridgeComponent::SetAnimInt(const FName Name, const int32 Value) const
{
	UAnimInstance* AnimInstance = GetOwnerAnimInstance();
	FIntProperty* Property = AnimInstance ? FindFProperty<FIntProperty>(AnimInstance->GetClass(), Name) : nullptr;
	if (!Property)
	{
		return false;
	}
	Property->SetPropertyValue_InContainer(AnimInstance, Value);
	return true;
}

bool USekiroEnemyAnimBridgeComponent::SetAnimFloat(const FName Name, const float Value) const
{
	UAnimInstance* AnimInstance = GetOwnerAnimInstance();
	FFloatProperty* Property = AnimInstance ? FindFProperty<FFloatProperty>(AnimInstance->GetClass(), Name) : nullptr;
	if (!Property)
	{
		return false;
	}
	Property->SetPropertyValue_InContainer(AnimInstance, Value);
	return true;
}

bool USekiroEnemyAnimBridgeComponent::SetAnimBool(const FName Name, const bool bValue) const
{
	UAnimInstance* AnimInstance = GetOwnerAnimInstance();
	FBoolProperty* Property = AnimInstance ? FindFProperty<FBoolProperty>(AnimInstance->GetClass(), Name) : nullptr;
	if (!Property)
	{
		return false;
	}
	Property->SetPropertyValue_InContainer(AnimInstance, bValue);
	return true;
}

void USekiroEnemyAnimBridgeComponent::Pulse(const FName Name) const
{
	SetAnimBool(Name, true);
}

void USekiroEnemyAnimBridgeComponent::PulseAny(const FName PrimaryName, const FName CompatibilityName) const
{
	if (!SetAnimBool(PrimaryName, true))
	{
		SetAnimBool(CompatibilityName, true);
	}
}

void USekiroEnemyAnimBridgeComponent::SendAnimCommand(const FSekiroEnemyAnimCommand& Command)
{
	LastCommand = Command;

	switch (Command.Type)
	{
	case ESekiroEnemyAnimCommandType::Move:
		SetAnimInt(TEXT("EnemyLayer"), 0);
		break;
	case ESekiroEnemyAnimCommandType::Attack:
	{
		const int32 ResolvedState = AnimProfile ? AnimProfile->ResolveAttackStateId(Command.AttackId) : Command.AttackId;
		SetAnimInt(TEXT("EnemyAttackId"), Command.AttackId);
		SetAnimInt(TEXT("EnemyStateId"), Command.StateId != INDEX_NONE ? Command.StateId : ResolvedState);
		SetAnimInt(TEXT("EnemyLayer"), 1);
		PulseAny(TEXT("Req_Attack"), TEXT("C9997_Req_Attack"));
		break;
	}
	case ESekiroEnemyAnimCommandType::Damage:
	{
		const int32 DamageStateId = Command.StateId != INDEX_NONE ? Command.StateId : 8050;
		const bool bBlow = DamageStateId == 8120 || DamageStateId == 8121;
		const bool bBack = DamageStateId == 8051 || DamageStateId == 8121;

		SetAnimBool(TEXT("Damage_IsPushFront"), !bBlow && !bBack);
		SetAnimBool(TEXT("Damage_IsPushBack"), !bBlow && bBack);
		SetAnimBool(TEXT("Damage_IsBlowFront"), bBlow && !bBack);
		SetAnimBool(TEXT("Damage_IsBlowBack"), bBlow && bBack);
		SetAnimBool(TEXT("Req_Damage"), false);
		SetAnimBool(TEXT("C9997_Req_Damage"), false);
		SetAnimBool(TEXT("C9997_Return_BattleIdle"), true);
		SetAnimInt(TEXT("EnemyStateId"), DamageStateId);
		SetAnimInt(TEXT("EnemyLayer"), 2);

		if (UWorld* World = GetWorld())
		{
			World->GetTimerManager().ClearTimer(DamageRequestTimerHandle);
			World->GetTimerManager().ClearTimer(DamageClearRequestTimerHandle);
			World->GetTimerManager().ClearTimer(DamageReturnTimerHandle);
			World->GetTimerManager().ClearTimer(DamageClearReturnTimerHandle);

			World->GetTimerManager().SetTimer(
				DamageClearReturnTimerHandle,
				FTimerDelegate::CreateWeakLambda(this, [this]()
				{
					SetAnimBool(TEXT("C9997_Return_BattleIdle"), false);
				}),
				0.02f,
				false);

			World->GetTimerManager().SetTimer(
				DamageRequestTimerHandle,
				FTimerDelegate::CreateWeakLambda(this, [this]()
				{
					PulseAny(TEXT("Req_Damage"), TEXT("C9997_Req_Damage"));
				}),
				0.03f,
				false);

			World->GetTimerManager().SetTimer(
				DamageClearRequestTimerHandle,
				FTimerDelegate::CreateWeakLambda(this, [this]()
				{
					SetAnimBool(TEXT("Req_Damage"), false);
					SetAnimBool(TEXT("C9997_Req_Damage"), false);
				}),
				0.16f,
				false);

			World->GetTimerManager().SetTimer(
				DamageReturnTimerHandle,
				FTimerDelegate::CreateWeakLambda(this, [this]()
				{
					SetAnimBool(TEXT("C9997_Return_BattleIdle"), true);
					if (UWorld* InnerWorld = GetWorld())
					{
						InnerWorld->GetTimerManager().SetTimer(
							DamageClearReturnTimerHandle,
							FTimerDelegate::CreateWeakLambda(this, [this]()
							{
								SetAnimBool(TEXT("C9997_Return_BattleIdle"), false);
							}),
							0.05f,
							false);
					}
				}),
				FMath::Max(0.16f, Command.ExpectedDuration),
				false);
		}
		break;
	}
	case ESekiroEnemyAnimCommandType::Reaction:
		SetAnimInt(TEXT("EnemyStateId"), Command.StateId);
		SetAnimInt(TEXT("EnemyLayer"), 2);
		PulseAny(TEXT("Req_Reaction"), TEXT("C9997_Req_Reaction"));
		break;
	case ESekiroEnemyAnimCommandType::Death:
		SetAnimInt(TEXT("EnemyLayer"), 3);
		PulseAny(TEXT("Req_Death"), TEXT("C9997_Req_Death"));
		break;
	case ESekiroEnemyAnimCommandType::SpecialEvent:
		SetAnimInt(TEXT("EnemyStateId"), Command.StateId);
		SetAnimInt(TEXT("EnemyLayer"), 4);
		PulseAny(TEXT("Req_Event"), TEXT("C9997_Req_Event"));
		break;
	case ESekiroEnemyAnimCommandType::ThrowDef:
	{
		const int32 ThrowStateId = Command.StateId != INDEX_NONE ? Command.StateId : 12000;
		static const FName ThrowDefStateVars[] = {
			TEXT("ThrowDef12000_Selected"),
			TEXT("ThrowDef12100_Selected"),
			TEXT("ThrowDef12110_Selected"),
			TEXT("ThrowDef12120_Selected"),
			TEXT("ThrowDef12200_Selected"),
			TEXT("ThrowDef12210_Selected"),
			TEXT("ThrowDef12220_Selected"),
			TEXT("ThrowDef12230_Selected"),
			TEXT("ThrowDef12300_Selected"),
			TEXT("ThrowDef12310_Selected"),
			TEXT("ThrowDef12600_Selected"),
			TEXT("ThrowDef12700_Selected"),
			TEXT("ThrowDef12800_Selected"),
			TEXT("ThrowDef13000_Selected"),
			TEXT("ThrowDef13100_Selected"),
			TEXT("ThrowDef13110_Selected"),
			TEXT("ThrowDef13120_Selected"),
			TEXT("ThrowDef13400_Selected"),
			TEXT("ThrowDef13510_Selected"),
			TEXT("ThrowDef13800_Selected"),
			TEXT("ThrowDef13900_Selected"),
			TEXT("ThrowDef14300_Selected"),
			TEXT("ThrowDef14500_Selected")
		};

		for (const FName StateVar : ThrowDefStateVars)
		{
			SetAnimBool(StateVar, false);
		}
		SetAnimBool(*FString::Printf(TEXT("ThrowDef%d_Selected"), ThrowStateId), true);
		SetAnimInt(TEXT("EnemyStateId"), ThrowStateId);
		SetAnimInt(TEXT("EnemyLayer"), 4);
		SetAnimBool(TEXT("C9997_Req_ThrowDef"), false);

		if (UWorld* World = GetWorld())
		{
			World->GetTimerManager().ClearTimer(ThrowDefRequestTimerHandle);
			World->GetTimerManager().ClearTimer(ThrowDefClearRequestTimerHandle);
			World->GetTimerManager().SetTimer(
				ThrowDefRequestTimerHandle,
				FTimerDelegate::CreateWeakLambda(this, [this]()
				{
					SetAnimBool(TEXT("C9997_Req_ThrowDef"), true);
				}),
				0.03f,
				false);
			World->GetTimerManager().SetTimer(
				ThrowDefClearRequestTimerHandle,
				FTimerDelegate::CreateWeakLambda(this, [this]()
				{
					SetAnimBool(TEXT("C9997_Req_ThrowDef"), false);
				}),
				0.22f,
				false);
		}
		else
		{
			SetAnimBool(TEXT("C9997_Req_ThrowDef"), true);
		}
		break;
	}
	case ESekiroEnemyAnimCommandType::ThrowDefDeath:
	{
		const int32 ThrowStateId = Command.StateId != INDEX_NONE ? Command.StateId : 12001;
		static const FName ThrowDefDeathStateVars[] = {
			TEXT("ThrowDefDeath12001_Selected"),
			TEXT("ThrowDefDeath12111_Selected"),
			TEXT("ThrowDefDeath12201_Selected"),
			TEXT("ThrowDefDeath12601_Selected"),
			TEXT("ThrowDefDeath12701_Selected"),
			TEXT("ThrowDefDeath13111_Selected"),
			TEXT("ThrowDefDeath13511_Selected"),
			TEXT("ThrowDefDeath14501_Selected"),
			TEXT("ThrowDefDeath12311_Selected")
		};

		for (const FName StateVar : ThrowDefDeathStateVars)
		{
			SetAnimBool(StateVar, false);
		}
		SetAnimBool(*FString::Printf(TEXT("ThrowDefDeath%d_Selected"), ThrowStateId), true);
		SetAnimInt(TEXT("EnemyStateId"), ThrowStateId);
		SetAnimInt(TEXT("EnemyLayer"), 4);
		SetAnimBool(TEXT("C9997_Req_ThrowDefDeath"), false);

		if (UWorld* World = GetWorld())
		{
			World->GetTimerManager().ClearTimer(ThrowDefDeathRequestTimerHandle);
			World->GetTimerManager().ClearTimer(ThrowDefDeathClearRequestTimerHandle);
			World->GetTimerManager().SetTimer(
				ThrowDefDeathRequestTimerHandle,
				FTimerDelegate::CreateWeakLambda(this, [this]()
				{
					SetAnimBool(TEXT("C9997_Req_ThrowDefDeath"), true);
				}),
				0.03f,
				false);
			World->GetTimerManager().SetTimer(
				ThrowDefDeathClearRequestTimerHandle,
				FTimerDelegate::CreateWeakLambda(this, [this]()
				{
					SetAnimBool(TEXT("C9997_Req_ThrowDefDeath"), false);
				}),
				0.22f,
				false);
		}
		else
		{
			SetAnimBool(TEXT("C9997_Req_ThrowDefDeath"), true);
		}
		break;
	}
	default:
		break;
	}
}

void USekiroEnemyAnimBridgeComponent::SendAttackCommand(const int32 AttackId, const float ExpectedDuration)
{
	FSekiroEnemyAnimCommand Command;
	Command.Type = ESekiroEnemyAnimCommandType::Attack;
	Command.AttackId = AttackId;
	Command.ExpectedDuration = ExpectedDuration;
	SendAnimCommand(Command);
}

void USekiroEnemyAnimBridgeComponent::SendMoveCommand(const float MoveSpeedLevel, const float MoveDirection)
{
	SetAnimFloat(TEXT("MoveSpeedLevel"), MoveSpeedLevel);
	SetAnimFloat(TEXT("MoveDirection"), MoveDirection);
	int32 MoveBattleStateId = 1;
	if (MoveSpeedLevel >= 0.95f)
	{
		MoveBattleStateId = 0;
	}
	else if (MoveDirection < -0.5f)
	{
		MoveBattleStateId = 2;
	}
	else if (MoveDirection > 0.5f)
	{
		MoveBattleStateId = 4;
	}
	SetAnimInt(TEXT("MoveBattleStateId"), MoveBattleStateId);
	SetAnimBool(TEXT("MoveBattle_IsRunFront"), MoveBattleStateId == 0);
	SetAnimBool(TEXT("MoveBattle_IsWalkFront"), MoveBattleStateId == 1);
	SetAnimBool(TEXT("MoveBattle_IsWalkLeft"), MoveBattleStateId == 2);
	SetAnimBool(TEXT("MoveBattle_IsWalkBack"), MoveBattleStateId == 3);
	SetAnimBool(TEXT("MoveBattle_IsWalkRight"), MoveBattleStateId == 4);
	SetAnimInt(TEXT("EnemyLayer"), 0);
	if (MoveSpeedLevel > 0.0f)
	{
		PulseAny(TEXT("Req_Move"), TEXT("C9997_Req_Move"));
	}
}
