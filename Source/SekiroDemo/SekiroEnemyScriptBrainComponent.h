#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "SekiroEnemyTypes.h"
#include "SekiroEnemyScriptBrainComponent.generated.h"

class USekiroEnemyAnimBridgeComponent;

UENUM(BlueprintType)
enum class ESekiroEnemyBrainState : uint8
{
	Idle = 0,
	Battle = 1,
	Dead = 2,
	Caution = 3,
	Find = 4
};

UCLASS(ClassGroup = (Sekiro), meta = (BlueprintSpawnableComponent))
class SEKIRODEMO_API USekiroEnemyScriptBrainComponent : public UActorComponent
{
	GENERATED_BODY()

public:
	USekiroEnemyScriptBrainComponent();

	virtual void BeginPlay() override;
	virtual void TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction) override;

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy")
	void SetCombatTarget(AActor* NewTarget);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy")
	void ForceAcquireTarget();

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy")
	void NotifyAttackedBy(AActor* Attacker);

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy")
	float GetDistToTarget() const;

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy")
	void PushInterruptDeath();

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy")
	void PushInterruptReaction(int32 StateId);

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	bool IsDead() const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	bool HasBattleTarget() const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	bool HasLineOfSightToTarget() const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	bool IsBattleState() const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	bool IsFindState() const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	bool IsCautionState() const;

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy|Script")
	void PushDeath();

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	bool IsAttackCoolingDown(int32 AttackId) const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	int32 GetRandam_Int(int32 Min, int32 Max) const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	float GetRandam_Float(float Min, float Max) const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	int32 DbgGetForceActIdx() const;

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy|Script")
	void DbgSetLastActIdx(int32 ActId);

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	float GetDist(FName TargetKey) const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	float GetAttackCooldown(int32 AttackId) const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	FString GetBattleScriptModule() const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	float GetActRate(int32 ActId) const;

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy|Script")
	void SetTimer(int32 TimerId, float Seconds);

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	bool IsFinishTimer(int32 TimerId) const;

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy|Script")
	void SetNumber(int32 Index, int32 Value);

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	int32 GetNumber(int32 Index) const;

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy|Script")
	void SetStringIndexedNumber(FName Key, float Value);

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	float GetStringIndexedNumber(FName Key) const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	float GetHpRate(FName TargetKey) const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	float GetSpRate(FName TargetKey) const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	float GetSp(FName TargetKey) const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	float GetMapHitRadius(FName TargetKey) const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	int32 GetExcelParam(int32 ParamId) const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	bool HasSpecialEffectId(FName TargetKey, int32 EffectId) const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	bool IsTargetGuard(FName TargetKey) const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	bool IsInsideTarget(FName TargetKey, FName Direction, float AngleDegrees) const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	bool IsInsideTargetEx(FName TargetKey, FName BaseTargetKey, FName Direction, float AngleDegrees, float MaxDistanceCm) const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	bool CheckDoesExistPath(FName TargetKey, FName Direction, float AngleDegrees, float DistanceCm) const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Script")
	bool SpaceCheck(float AngleDegrees, float DistanceCm) const;

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy|Script")
	void SetLastSelectedAct(int32 ActId);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy|Script")
	void ScriptApproach(float StopDistanceCm);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy|Script")
	void ScriptAttack(int32 AttackId);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy|Script")
	void ScriptAttackAtRange(int32 AttackId, float MaxDistanceCm);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy|Script")
	void ScriptSidewayMove(int32 Direction);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy|Script")
	void ScriptLeaveTarget(float KeepDistanceCm);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy|Script")
	void ScriptTurnToTarget();

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy|Script")
	void ScriptWait(float Seconds);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy|Script")
	void ScriptPatrol();

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy|Script")
	void ClearSubGoal();

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy|Script")
	void ScriptSetWeaponStyle(FName WeaponStyle);

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy")
	TObjectPtr<USekiroEnemyDefinition> EnemyDefinition;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy")
	TObjectPtr<USekiroEnemyCombatProfile> CombatProfile;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy")
	TObjectPtr<AActor> CombatTarget;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy")
	int32 DefaultAttackId = 3000;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy")
	float NativeThinkInterval = 0.25f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy")
	bool bUseLuaScript = true;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy")
	bool bUseOriginalSekiroLuaScripts = true;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy")
	int32 OriginalSekiroLogicId = 101200;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy")
	int32 OriginalSekiroFallbackSelfSpecialEffect = 310100;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy")
	float AttackedTargetMemorySeconds = 8.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy")
	float AttackedTargetChaseRadiusCm = 6000.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy|Debug")
	bool bDebugScriptBrain = true;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy|Sight")
	bool bRequireLineOfSightForBattle = true;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy|Sight")
	float SightStartHeightCm = 90.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy|Sight")
	float SightTargetHeightCm = 90.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy|Patrol")
	bool bEnablePatrol = true;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy|Patrol")
	float PatrolRadiusCm = 350.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy|Patrol")
	float PatrolSpeedCm = 120.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy|Patrol")
	float PatrolAcceptRadiusCm = 80.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy|Patrol")
	float PatrolStuckDistanceCm = 5.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy|Patrol")
	float PatrolStuckSeconds = 0.75f;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Enemy")
	ESekiroEnemyBrainState BrainState = ESekiroEnemyBrainState::Idle;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Enemy")
	FString LastDecisionDebug;

private:
	void Think(float DeltaTime);
	void NativeThink(float DeltaTime);
	bool TryRunLuaLogic(float DeltaTime);
	void AcquireDefaultTarget();
	void RefreshPerceptionState();
	void TickApproach(float DeltaTime, float Distance);
	void TickPatrol(float DeltaTime);
	void TurnToTarget(float DeltaTime);
	bool CanSeeCombatTarget() const;
	void RequestMove(const FVector& Direction, float Scale, float Speed);
	void StopMove();
	void ApplyRequestedMove(float DeltaTime);
	USekiroEnemyAnimBridgeComponent* GetAnimBridge() const;

	float ThinkAccumulator = 0.0f;
	float WaitRemaining = 0.0f;
	float AttackedTargetMemoryRemaining = 0.0f;
	int32 LastSelectedAct = 0;
	FVector HomeLocation = FVector::ZeroVector;
	FVector PatrolTargetLocation = FVector::ZeroVector;
	FVector LastPatrolLocation = FVector::ZeroVector;
	FVector RequestedMoveDirection = FVector::ZeroVector;
	float RequestedMoveScale = 0.0f;
	float RequestedMoveSpeed = 0.0f;
	float PatrolStuckTimer = 0.0f;
	bool bHasPatrolTarget = false;
	bool bHasRequestedMove = false;
	bool bRequestedMoveUsesNavigation = false;
	ESekiroEnemyBrainState LastLoggedBrainState = ESekiroEnemyBrainState::Idle;
	TMap<int32, float> AttackCooldownRemainingById;
	TMap<int32, float> ScriptTimers;
	TMap<int32, int32> ScriptNumbers;
	TMap<FName, float> ScriptNamedNumbers;
};
