#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "SekiroEnemyCharacter.generated.h"

class USekiroEnemyAnimBridgeComponent;
class USekiroEnemyScriptBrainComponent;
class USkeletalMeshComponent;

UENUM(BlueprintType)
enum class ESekiroEnemyWeaponStyle : uint8
{
	None UMETA(DisplayName = "None"),
	OneHand UMETA(DisplayName = "One Hand Katana"),
	Hassou UMETA(DisplayName = "Hassou Dual Katana"),
	Spear UMETA(DisplayName = "Spear"),
	Matchlock UMETA(DisplayName = "Matchlock")
};

UCLASS()
class SEKIRODEMO_API ASekiroEnemyCharacter : public ACharacter
{
	GENERATED_BODY()

public:
	ASekiroEnemyCharacter();

	virtual void BeginPlay() override;
	virtual void OnConstruction(const FTransform& Transform) override;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Enemy")
	TObjectPtr<USekiroEnemyAnimBridgeComponent> EnemyAnimBridge;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Enemy")
	TObjectPtr<USekiroEnemyScriptBrainComponent> EnemyScriptBrain;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Enemy|Weapon")
	TObjectPtr<USkeletalMeshComponent> WeaponKatana;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Enemy|Weapon")
	TObjectPtr<USkeletalMeshComponent> WeaponSet;

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy|Weapon")
	void SetEnemyWeaponStyle(ESekiroEnemyWeaponStyle WeaponStyle);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy|Weapon")
	void SetEnemyWeaponStyleByName(FName WeaponStyleName);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy|Weapon")
	void RefreshEnemyWeaponAttachment();

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy|TAE")
	void HandleSekiroEnemyAnimEvent(FName EventName, bool bActive, int32 TaeType, int32 BehaviorJudgeID, const FString& SourceArguments);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy|Combat")
	void ApplyPlayerAttackHit(float Damage, FName AttackID, AActor* InstigatorActor);

	UFUNCTION(BlueprintPure, Category = "Sekiro|Enemy|Deathblow")
	bool IsFrontDeathblowAvailable(const AActor* InstigatorActor, float MaxRangeCm, float FrontAngleDegrees) const;

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy|Deathblow")
	void BeginFrontDeathblow(AActor* InstigatorActor);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy|Deathblow")
	void ConfirmFrontDeathblowKill(AActor* InstigatorActor);

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy|Weapon")
	ESekiroEnemyWeaponStyle SelectedEnemyWeaponStyle = ESekiroEnemyWeaponStyle::OneHand;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy|Combat")
	float MaxHealth = 200.0f;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Enemy|Combat")
	float CurrentHealth = 200.0f;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Enemy|Combat")
	bool bDead = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy|Deathblow")
	bool bDeathblowOpen = false;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Enemy|Deathblow")
	bool bDeathblowInProgress = false;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Enemy|TAE")
	bool bEnemyAttackBehaviorActive = false;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Enemy|TAE")
	int32 ActiveEnemyAttackBehaviorJudgeID = INDEX_NONE;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Enemy|TAE")
	FName ActiveEnemyAttackID = NAME_None;

private:
	void ApplyWeaponSetVisibility();
};
