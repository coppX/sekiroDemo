#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "SekiroLayeredStateMachineComponent.generated.h"

USTRUCT(BlueprintType)
struct FSekiroLayerStateRuntime
{
	GENERATED_BODY()

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|StateMachine")
	int32 LayerId = 0;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|StateMachine")
	int32 StateId = 0;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|StateMachine")
	int32 PreviousStateId = 0;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|StateMachine")
	int32 DirectionId = -1;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|StateMachine")
	int32 PreviousDirectionId = -1;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|StateMachine")
	float StateElapsedSeconds = 0.0f;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|StateMachine")
	FString StateName = TEXT("Idle");

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|StateMachine")
	FString LastEventName = TEXT("W_BaseIdle");

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|StateMachine")
	bool bChangedThisFrame = false;
};

UCLASS(ClassGroup = (Sekiro), meta = (BlueprintSpawnableComponent))
class SEKIRODEMO_API USekiroLayeredStateMachineComponent : public UActorComponent
{
	GENERATED_BODY()

public:
	USekiroLayeredStateMachineComponent();

	virtual void BeginPlay() override;
	virtual void TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction) override;

	UFUNCTION(BlueprintCallable, Category = "Sekiro|StateMachine")
	void ResetLayerStates();

	UFUNCTION(BlueprintCallable, Category = "Sekiro|StateMachine")
	bool EnsureLayer(int32 LayerId, int32 DefaultStateId = 0, const FString& DefaultStateName = TEXT("Idle"));

	UFUNCTION(BlueprintCallable, Category = "Sekiro|StateMachine")
	bool SetLayerState(int32 LayerId, int32 StateId, const FString& StateName, const FString& EventName, int32 DirectionId);

	UFUNCTION(BlueprintPure, Category = "Sekiro|StateMachine")
	FSekiroLayerStateRuntime GetLayerState(int32 LayerId) const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|StateMachine")
	int32 GetLayerStateId(int32 LayerId) const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|StateMachine")
	int32 GetLayerDirectionId(int32 LayerId) const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|StateMachine")
	float GetLayerStateElapsedSeconds(int32 LayerId) const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|StateMachine")
	FString GetLayerStateName(int32 LayerId) const;

	UFUNCTION(BlueprintPure, Category = "Sekiro|StateMachine")
	FString GetLayerLastEventName(int32 LayerId) const;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sekiro|StateMachine")
	TMap<int32, FSekiroLayerStateRuntime> Layers;
};
