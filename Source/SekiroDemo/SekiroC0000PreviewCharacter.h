#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "UnLuaInterface.h"
#include "SekiroC0000PreviewCharacter.generated.h"

class UAnimInstance;
class UAnimationAsset;
class UCameraComponent;
class UInputComponent;
class USekiroLayeredStateMachineComponent;
class USekiroEnvQueryComponent;
class UPrimitiveComponent;
class USpringArmComponent;
class UStaticMesh;
class UStaticMeshComponent;
class ASekiroEnemyCharacter;

UCLASS()
class SEKIRODEMO_API ASekiroC0000PreviewCharacter : public ACharacter, public IUnLuaInterface
{
	GENERATED_BODY()

public:
	ASekiroC0000PreviewCharacter();

	virtual FString GetModuleName_Implementation() const override;
	virtual void OnConstruction(const FTransform& Transform) override;
	virtual void BeginPlay() override;
	virtual void Tick(float DeltaSeconds) override;
	virtual void SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) override;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Animation")
	UAnimInstance* GetSekiroAnimInstance() const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Env")
	USekiroEnvQueryComponent* GetSekiroEnvQuery() const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|StateMachine")
	USekiroLayeredStateMachineComponent* GetSekiroLayeredStateMachine() const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Animation")
	bool HasAnimVariable(FName VarName) const;

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Animation")
	bool SetAnimBoolVar(FName VarName, bool bValue);

	UFUNCTION(BlueprintPure, Category = "Sekiro|Animation")
	bool GetAnimBoolVar(FName VarName) const;

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Animation")
	bool SetAnimIntVar(FName VarName, int32 Value);

	UFUNCTION(BlueprintPure, Category = "Sekiro|Animation")
	int32 GetAnimIntVar(FName VarName) const;

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Animation")
	bool SetAnimFloatVar(FName VarName, float Value);

	UFUNCTION(BlueprintPure, Category = "Sekiro|Animation")
	float GetAnimFloatVar(FName VarName) const;

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Animation")
	int32 ClearAnimBoolVarsByPrefix(const FString& Prefix);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Animation")
	void ResetSekiroTransientVars();

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Animation")
	float GetAnimSequenceLengthByPath(const FString& AssetPath) const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Movement")
	float GetHorizontalSpeed() const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Movement")
	float GetMoveInputStrength() const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Movement")
	float GetVelocityAngleDegrees() const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Movement")
	float GetMoveInputAngleDegrees() const;

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Movement")
	void ApplyPreviewMovementInput(float Scale);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Movement")
	void AddPreviewFacingYaw(float DeltaYawDegrees);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Movement|Animation")
	bool HandleSekiroMovementAnimEvent(
		FName EventName,
		bool bActive,
		float NumericValue,
		const FString& SourceArguments,
		int32 TaeType,
		int32 BehaviorJudgeID);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Behavior")
	bool HandleSekiroAct(int32 ActId, const FString& Args);

	UFUNCTION(BlueprintPure, Category = "Sekiro|Input")
	int32 GetPreviewForwardIntent() const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Input")
	int32 GetPreviewRightIntent() const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Input")
	bool IsPreviewSprintHeld() const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|Input")
	int32 GetPreviewDominantMoveDirection() const;

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Input")
	void SetPreviewInputOverride(int32 Forward, int32 Right, bool bSprintHeld);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Input")
	void ClearPreviewInputOverride();

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Input")
	void QueuePreviewActionEvent(const FString& EventName);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Input")
	FString ConsumePreviewActionEvent();

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Input")
	void QueuePreviewReactionEvent(const FString& EventName);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Input")
	FString ConsumePreviewReactionEvent();

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Input")
	void ClearPreviewQueuedEvents();

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Deathblow")
	bool StartFrontDeathblowOnEnemy(ASekiroEnemyCharacter* Enemy);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Debug")
	bool StepPreviewRuntime(float DeltaSeconds);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Debug")
	bool TriggerPreviewSekiroEvent(const FString& EventName);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Debug")
	void SetPreviewDebugInput(int32 Forward, int32 Right, bool bSprint);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Debug")
	void SetPreviewDebugLastEvent(const FString& EventName, float EventTimeSeconds);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Debug")
	FString GetCurrentLocomotionRuntimeAnimDebug() const;

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Preview")
	bool PlayPreviewSequenceByPath(const FString& AssetPath, bool bLooping, float PlayRate = 1.0f);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Preview")
	void RestorePreviewAnimBlueprint();

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Preview")
	void SetPreviewMoveSpeed(float MaxWalkSpeed);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Preview")
	bool ApplySimpleMovementAnimBlueprint();

	UFUNCTION(BlueprintPure, Category = "Sekiro|Preview")
	bool IsUsingPreviewAnimationAsset() const;

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Weapon")
	void SetMortalBladeDrawn(bool bDrawn);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Weapon")
	void SetMortalBladeRightHandVisible(bool bVisible);

	UFUNCTION()
	void HandlePreviewAttackOverlap(
		UPrimitiveComponent* OverlappedComponent,
		AActor* OtherActor,
		UPrimitiveComponent* OtherComp,
		int32 OtherBodyIndex,
		bool bFromSweep,
		const FHitResult& SweepResult);

	UFUNCTION(BlueprintPure, Category = "Sekiro|Weapon")
	bool IsMortalBladeDrawn() const;

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Targeting")
	bool HasVisibleEnemyInAutoWeaponRange() const;

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Targeting")
	void SetPreviewAutoAimTargetValid(bool bValid);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Targeting")
	bool FaceNearestVisibleEnemyForAttack();

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|InitState")
	int32 PreviewLoadInitPose = -1;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|InitState")
	int32 PreviewSafePosReturnType = -1;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|InitState")
	bool bPreviewAllowStandEnter = true;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|InitState")
	bool bPreviewForceCrouch = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|InitState")
	bool bPreviewAgingActive = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|InitState")
	bool bPreviewRedoBellReturn = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Preview")
	bool bUseSimpleMovementAnimBlueprint = true;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Preview")
	TSoftClassPtr<UAnimInstance> SimpleMovementAnimClass;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Targeting")
	float EnemyAutoWeaponDistanceCm = 1000.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Targeting")
	float AttackFaceTargetDistanceCm = 2500.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Deathblow")
	float DeathblowMaxRangeCm = 180.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Deathblow")
	float DeathblowFrontAngleDegrees = 130.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Deathblow")
	float FrontDeathblowAlignDistanceCm = 72.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Deathblow")
	float FrontDeathblowAlignSeconds = 2.35f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Deathblow")
	float FrontDeathblowThrowKillStartSeconds = 2.20f;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|InitState")
	int32 PreviewResolvedEntryMode = 0;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|InitState")
	FString PreviewResolvedEntryEventName;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Camera")
	TObjectPtr<USpringArmComponent> CameraBoom;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Camera")
	TObjectPtr<UCameraComponent> FollowCamera;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Env")
	TObjectPtr<USekiroEnvQueryComponent> EnvQuery;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|StateMachine")
	TObjectPtr<USekiroLayeredStateMachineComponent> LayeredStateMachine;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Weapon")
	TObjectPtr<UStaticMeshComponent> BackSheathedWeapon;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Weapon")
	TObjectPtr<UStaticMeshComponent> LeftHandScabbard;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Weapon")
	TObjectPtr<UStaticMeshComponent> RightHandDrawBlade;

	UPROPERTY(Transient)
	TObjectPtr<UStaticMesh> MortalBladeWaistSheathedMesh;

	UPROPERTY(Transient)
	TObjectPtr<UStaticMesh> MortalBladeWaistDrawnMesh;

	UPROPERTY(Transient)
	TObjectPtr<UStaticMesh> MortalBladeRightHandMesh;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Debug")
	int32 PreviewDebugInputForward = 0;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Debug")
	int32 PreviewDebugInputRight = 0;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Debug")
	bool bPreviewDebugSprintHeld = false;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Debug")
	FString PreviewDebugLastEventName;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Debug")
	float PreviewDebugLastEventTimeSeconds = 0.0f;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Debug")
	bool bPreviewDebugInputBound = false;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Debug")
	FString PreviewDebugQueuedActionEventName;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Debug")
	FString PreviewDebugQueuedReactionEventName;

private:
	void ApplyPreviewMovementSettings();
	void PreloadSimpleMovementAnimationAssets();
	bool EnsurePreviewLuaBinding(bool bForceRebind);
	void AlignBackSheathedWeaponToBackCaseSockets();
	void RefreshPreviewMovementIntent();
	void UpdatePreviewInputStateFromController();
	void SyncEnvQueryFromPreviewInput(float DeltaSeconds);
	FVector GetPreviewInputWorldVector() const;

	void HandlePreviewForwardPressed();
	void HandlePreviewForwardReleased();
	void HandlePreviewBackwardPressed();
	void HandlePreviewBackwardReleased();
	void HandlePreviewLeftPressed();
	void HandlePreviewLeftReleased();
	void HandlePreviewRightPressed();
	void HandlePreviewRightReleased();
	void HandlePreviewSprintPressed();
	void HandlePreviewSprintReleased();
	void HandlePreviewUseItemPressed();
	void HandlePreviewSubWeaponPressed();
	void HandlePreviewLeftWaistDrawSheathePressed();
	void HandlePreviewReactionPressed();
	void HandlePreviewGroundAttackPressed();
	void HandlePreviewGroundAttackReleased();
	void HandlePreviewGuardPressed();
	void HandlePreviewGuardReleased();
	void UpdateEnemyProximityAutoDraw(float DeltaSeconds);
	void LockPreviewAttackFaceTarget(ASekiroEnemyCharacter* Enemy, float HoldSeconds);
	bool FacePreviewActorTowardTarget(const AActor* TargetActor);
	void UpdatePreviewAttackFacing(float DeltaSeconds);
	ASekiroEnemyCharacter* FindFrontDeathblowTarget() const;
	bool TryStartFrontDeathblow();
	void UpdateFrontDeathblowAlignment(float DeltaSeconds);

	bool bPreviewForwardPressed = false;
	bool bPreviewBackwardPressed = false;
	bool bPreviewLeftPressed = false;
	bool bPreviewRightPressed = false;
	bool bPreviewSprintPressed = false;
	bool bPreviewInputOverrideActive = false;
	bool bPreviewLuaBindingReady = false;
	int32 PreviewForwardIntent = 0;
	int32 PreviewRightIntent = 0;
	float PreviewControlYaw = 0.0f;
	int32 PreviewOverrideForward = 0;
	int32 PreviewOverrideRight = 0;
	bool bPreviewOverrideSprint = false;
	bool bMortalBladeDrawn = false;
	bool bEnemyAutoDrawQueued = false;
	bool bEnemyAutoSheatheQueued = false;
	bool bEnemyAutoDrawHadEnemyInRange = false;
	bool bEnemyAutoDrawActive = false;
	float EnemyAutoDrawElapsedSeconds = 0.0f;
	float PreviewAttackFaceTimeRemaining = 0.0f;
	TWeakObjectPtr<ASekiroEnemyCharacter> PreviewAttackFaceTarget;
	TWeakObjectPtr<ASekiroEnemyCharacter> FrontDeathblowTarget;
	float FrontDeathblowAlignTimeRemaining = 0.0f;
	FString QueuedPreviewActionEventName;
	TArray<FString> QueuedPreviewActionEventNames;
	FString QueuedPreviewReactionEventName;
	TSubclassOf<UAnimInstance> DefaultPreviewAnimClass;

	UPROPERTY(Transient)
	TArray<TObjectPtr<UAnimationAsset>> PreloadedMovementAnimationAssets;
};
