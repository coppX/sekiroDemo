#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "SekiroEnvQueryComponent.generated.h"

UENUM(BlueprintType)
enum class ESekiroEnvValueType : uint8
{
	Bool,
	Int,
	Float,
	StringKey,
	Unknown
};

UENUM(BlueprintType)
enum class ESekiroEnvConfidence : uint8
{
	High,
	Medium,
	Low
};

USTRUCT(BlueprintType)
struct FSekiroEnvIdInfo
{
	GENERATED_BODY()

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env")
	int32 Id = INDEX_NONE;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env")
	FString Key;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env")
	FString Name;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env")
	FString Meaning;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env")
	FString ArgumentFamily;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env")
	FString ReturnType;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env")
	FString SourceHint;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env")
	ESekiroEnvValueType ValueType = ESekiroEnvValueType::Unknown;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env")
	ESekiroEnvConfidence Confidence = ESekiroEnvConfidence::Low;
};

USTRUCT(BlueprintType)
struct FSekiroEnvQueryResult
{
	GENERATED_BODY()

	UPROPERTY(BlueprintReadOnly, Category = "Sekiro|Env")
	bool bHandled = false;

	UPROPERTY(BlueprintReadOnly, Category = "Sekiro|Env")
	bool bBoolValue = false;

	UPROPERTY(BlueprintReadOnly, Category = "Sekiro|Env")
	int32 IntValue = 0;

	UPROPERTY(BlueprintReadOnly, Category = "Sekiro|Env")
	float FloatValue = 0.0f;

	UPROPERTY(BlueprintReadOnly, Category = "Sekiro|Env")
	FString DebugName;
};

UCLASS(ClassGroup = (Sekiro), meta = (BlueprintSpawnableComponent))
class SEKIRODEMO_API USekiroEnvQueryComponent : public UActorComponent
{
	GENERATED_BODY()

public:
	USekiroEnvQueryComponent();

	virtual void BeginPlay() override;
	virtual void TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction) override;

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Env")
	void ResetEnvRuntimeState();

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Env")
	void SyncBasicOwnerState();

	UFUNCTION(BlueprintPure, Category = "Sekiro|Env")
	FSekiroEnvQueryResult EnvValue(int32 Id, int32 SubKey = 0) const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Env")
	bool EnvBool(int32 Id, int32 SubKey = 0) const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Env")
	int32 EnvInt(int32 Id, int32 SubKey = 0) const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Env")
	float EnvFloat(int32 Id, int32 SubKey = 0) const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Env")
	bool EnvNamedBool(const FString& QueryName, int32 SubKey = 0) const;

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Env")
	bool GetEnvIdInfo(int32 Id, FSekiroEnvIdInfo& OutInfo) const;

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Env")
	void GetAllEnvIdInfos(TArray<FSekiroEnvIdInfo>& OutInfos) const;

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Env|Input")
	void SetActionPressed(int32 ActionArmId, bool bPressed);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Env|Input")
	void SetActionHoldMilliseconds(int32 ActionArmId, float HoldMilliseconds);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Env|Input")
	void SetMovementInputIntent(int32 Forward, int32 Right, bool bSprintHeld, float DeltaSeconds);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Env|Input")
	void SetActionUnlocked(int32 ActionUnlockType, bool bUnlocked);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Env|Input")
	void SetActionEnabled(int32 ActionArmId, bool bEnabled);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Env|Effects")
	void SetBehaviorRefActive(int32 BehaviorRefId, bool bActive);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Env|Effects")
	void SetBehaviorIdentificationActive(int32 BehaviorIdentificationValue, bool bActive);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Env|Effects")
	void SetSpEffectActive(int32 SpEffectId, bool bActive);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Env|Weapon")
	void SetWeaponMotionCategory(int32 HandId, int32 WeaponMotionCategory);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Env|Weapon")
	void SetNextWeaponMotionCategory(int32 HandId, int32 WeaponMotionCategory);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Env|Timing")
	void SetStartTimeMilliseconds(int32 Slot, float TimeMilliseconds);

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Runtime")
	bool bAutoSyncOwnerMovement = true;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Runtime")
	int32 PendingEventId = INDEX_NONE;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Item")
	bool bItemUseFixedRequest = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Item")
	bool bItemUseRequestInvalid = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Item")
	bool bItemUseEnable = true;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Item")
	int32 ItemAnimeType = -1;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Damage")
	int32 DamageType = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Damage")
	int32 DamageLevel = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Damage")
	int32 DamageElement = 1;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Damage")
	int32 DamageAngle = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Damage")
	int32 DamageAngleFrontBack = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Damage")
	int32 AttackDirection = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Damage")
	float DamageDirectionSign = 1.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Damage")
	int32 GuardDamageAmount = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Damage")
	bool bDamageAnimationGateActive = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Damage")
	bool bDamageReactionSuppressed = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Damage")
	bool bDamageBreakSuppressedByEnchant = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Vitals")
	int32 CurrentHp = 100;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Vitals")
	bool bHpAutoChargeActive = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Vitals")
	bool bHpAutoChargeBlocked = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Weapon")
	int32 WeaponChangeType = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Weapon")
	int32 SpecialAttackTypeRight = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Throw")
	int32 ThrowAnimationId = -1;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Throw")
	bool bThrowKillRequested = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Throw")
	bool bThrowDeathRequested = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Throw")
	bool bThrowEscapeRequested = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Throw")
	bool bThrowActive = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Throw")
	bool bRevivalRequested = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Throw")
	TMap<int32, bool> ThrowFinishedBySide;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Movement")
	bool bIsStandby = true;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Movement")
	bool bIsMoveable = false;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Env|Movement")
	int32 MoveInputForward = 0;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Env|Movement")
	int32 MoveInputRight = 0;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Env|Movement")
	float MoveInputStrength = 0.0f;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Env|Movement")
	bool bSprintHeld = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Movement")
	bool bIsFalling = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Movement")
	bool bJustLanded = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Movement")
	bool bLandReady = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Movement")
	float FallHeightRaw = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Movement")
	float FallVerticalSpeed = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Movement")
	bool bSpecialMoveStyleActive = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Movement")
	bool bWireTargetAvailable = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Movement")
	bool bWaterContact = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Movement")
	bool bEnemyJumpAvailable = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Movement")
	bool bWallJumpAvailable = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Movement")
	bool bNoLandOrThrowReset = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Target")
	bool bAutoAimTargetValid = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Docking")
	int32 DockingTargetEndType = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Docking")
	int32 EdgeType = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Docking")
	int32 EasyDeflectedReactionType = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Docking")
	int32 HardDeflectedReactionType = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Docking")
	bool bDockingBreakRequested = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Docking")
	int32 AirHangType = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Docking")
	TMap<int32, int32> DockingTargetEdgeTypeByRequest;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Docking")
	bool bHangOuterCornerLeftAvailable = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Docking")
	bool bHangOuterCornerRightAvailable = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Docking")
	bool bHangClimbAvailable = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Docking")
	bool bDockingLeftBlocked = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Docking")
	bool bDockingRightBlocked = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Docking")
	bool bHangInsideCornerLeftAvailable = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Docking")
	bool bHangInsideCornerRightAvailable = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|World")
	int32 MapVisibilityType = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|World")
	bool bCanStartCover = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|World")
	bool bCanStartGroundHang = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|World")
	bool bCanSwimToDive = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|World")
	bool bCanDiveToSwim = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Event")
	int32 TalkParamRefId = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Event")
	int32 EzStateRefId = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Event")
	int32 LoadInitPose = -1;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Event")
	int32 SafePosReturnType = -1;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Event")
	bool bAllowStandEnter = true;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Event")
	int32 AddBlendSpeakState = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Deflect")
	int32 EasyDeflectAttackDirection = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Deflect")
	int32 HardDeflectAttackDirection = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Input")
	TMap<int32, bool> ActionPressed;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Input")
	TMap<int32, float> ActionHoldMilliseconds;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Input")
	TMap<int32, bool> ActionUnlocked;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Input")
	TMap<int32, bool> ActionEnabled;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Effects")
	TMap<int32, bool> ActiveBehaviorRefs;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Effects")
	TMap<int32, bool> BehaviorIdentificationFlags;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Effects")
	TMap<int32, bool> ActiveSpEffects;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Weapon")
	TMap<int32, int32> WeaponMotionCategoryByHand;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Weapon")
	TMap<int32, int32> NextWeaponMotionCategoryByHand;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Env|Timing")
	TMap<int32, float> StartTimeMillisecondsBySlot;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Env|Timing")
	float LastDeltaTimeMilliseconds = 0.0f;

private:
	static const TArray<FSekiroEnvIdInfo>& GetEnvInfoTable();

	FSekiroEnvQueryResult QueryEnvValue(int32 Id, int32 SubKey) const;

	bool bWasOwnerFalling = false;
};
