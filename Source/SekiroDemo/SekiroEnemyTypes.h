#pragma once

#include "CoreMinimal.h"
#include "Engine/DataAsset.h"
#include "SekiroEnemyTypes.generated.h"

UENUM(BlueprintType)
enum class ESekiroEnemyAnimCommandType : uint8
{
	None,
	Move,
	Attack,
	Damage,
	Reaction,
	SpecialEvent,
	ThrowDef,
	ThrowDefDeath,
	Death
};

USTRUCT(BlueprintType)
struct FSekiroEnemyAnimCommand
{
	GENERATED_BODY()

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy")
	ESekiroEnemyAnimCommandType Type = ESekiroEnemyAnimCommandType::None;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy")
	int32 AttackId = INDEX_NONE;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy")
	int32 StateId = INDEX_NONE;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy")
	FName EventName;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy")
	float ExpectedDuration = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy")
	bool bCanBeInterrupted = true;
};

UCLASS(BlueprintType)
class SEKIRODEMO_API USekiroEnemyCombatProfile : public UDataAsset
{
	GENERATED_BODY()

public:
	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Sekiro|Enemy")
	float BattleRadiusCm = 1200.0f;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Sekiro|Enemy")
	float PreferredDistanceCm = 320.0f;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Sekiro|Enemy")
	float LoseTargetRadiusCm = 2000.0f;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Sekiro|Enemy")
	TMap<int32, float> AttackCooldowns;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Sekiro|Enemy")
	TMap<int32, float> ActRateOverrides;
};

UCLASS(BlueprintType)
class SEKIRODEMO_API USekiroEnemyAnimProfile : public UDataAsset
{
	GENERATED_BODY()

public:
	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Sekiro|Enemy")
	FName EnemyCode = TEXT("C9997");

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Sekiro|Enemy")
	TMap<int32, int32> AttackToStateId;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy")
	int32 ResolveAttackStateId(int32 AttackId) const
	{
		if (const int32* StateId = AttackToStateId.Find(AttackId))
		{
			return *StateId;
		}
		return AttackId;
	}
};

UCLASS(BlueprintType)
class SEKIRODEMO_API USekiroEnemyDefinition : public UDataAsset
{
	GENERATED_BODY()

public:
	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Sekiro|Enemy")
	FName EnemyId = TEXT("101000");

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Sekiro|Enemy")
	FName EnemyCode = TEXT("C1010");

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Sekiro|Enemy")
	TObjectPtr<USekiroEnemyAnimProfile> AnimProfile;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Sekiro|Enemy")
	TObjectPtr<USekiroEnemyCombatProfile> CombatProfile;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Sekiro|Enemy")
	FString LogicScript = TEXT("Sekiro.Enemy.OriginalRuntime");

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Sekiro|Enemy")
	FString BattleScript;
};
