#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "TimerManager.h"
#include "SekiroEnemyTypes.h"
#include "SekiroEnemyAnimBridgeComponent.generated.h"

UCLASS(ClassGroup = (Sekiro), meta = (BlueprintSpawnableComponent))
class SEKIRODEMO_API USekiroEnemyAnimBridgeComponent : public UActorComponent
{
	GENERATED_BODY()

public:
	USekiroEnemyAnimBridgeComponent();

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy")
	void SendAnimCommand(const FSekiroEnemyAnimCommand& Command);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy")
	void SendAttackCommand(int32 AttackId, float ExpectedDuration = 1.2f);

	UFUNCTION(BlueprintCallable, Category = "Sekiro|Enemy")
	void SendMoveCommand(float MoveSpeedLevel, float MoveDirection);

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Enemy")
	TObjectPtr<USekiroEnemyAnimProfile> AnimProfile;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|Enemy")
	FSekiroEnemyAnimCommand LastCommand;

private:
	UAnimInstance* GetOwnerAnimInstance() const;
	bool SetAnimInt(FName Name, int32 Value) const;
	bool SetAnimFloat(FName Name, float Value) const;
	bool SetAnimBool(FName Name, bool bValue) const;
	void Pulse(FName Name) const;
	void PulseAny(FName PrimaryName, FName CompatibilityName) const;

	FTimerHandle DamageRequestTimerHandle;
	FTimerHandle DamageClearRequestTimerHandle;
	FTimerHandle DamageReturnTimerHandle;
	FTimerHandle DamageClearReturnTimerHandle;
	FTimerHandle ThrowDefRequestTimerHandle;
	FTimerHandle ThrowDefClearRequestTimerHandle;
	FTimerHandle ThrowDefDeathRequestTimerHandle;
	FTimerHandle ThrowDefDeathClearRequestTimerHandle;
};
