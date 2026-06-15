#pragma once

#include "CoreMinimal.h"
#include "Animation/AnimInstance.h"
#include "SekiroSimpleMovementAnimInstance.generated.h"

UCLASS(Blueprintable, BlueprintType)
class SEKIRODEMO_API USekiroSimpleMovementAnimInstance : public UAnimInstance
{
	GENERATED_BODY()

public:
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement")
	int32 LayerId = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement")
	int32 StateId = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement")
	int32 PreviousStateId = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement")
	int32 DirectionId = -1;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement")
	float StateElapsedSeconds = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement")
	float MoveSpeedLevel = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement")
	float MoveSpeedLevelReal = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement")
	float LocomotionWeaponBlend = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement")
	int32 MoveSpeedIndex = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement")
	int32 NightvisionMoveSpeedIndex = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement")
	float MoveDirection = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement")
	int32 MoveDirectionIndex = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement")
	float MoveAngle = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement")
	float TurnAngle = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement")
	float TwistLowerRootAngle = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement|HKX")
	float TwistUpperRootAngle = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement|HKX")
	float TwistMasterAngle = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement|HKX")
	float MoveTwistAngle_Yaw = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement|HKX")
	float MoveTwistAngle_Roll = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement|HKX")
	int32 TurnType = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement|HKX")
	int32 QuickTurnState = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement|HKX")
	int32 Selector_UseTransitionEffect = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement|HKX")
	int32 Selector_UseStaterToStateTransitionEffect = 1;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement|HKX")
	bool IsTurnTwist = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement")
	int32 MoveType = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement")
	int32 StanceMoveType = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement")
	bool bSprintHeld = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement|Requests")
	bool Req_W_Idle = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement|Requests")
	bool Req_W_Event3018 = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement|Requests")
	bool Req_Event26021_to_EventDummy = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|SimpleMovement|Requests")
	bool Req_W_Event3026 = false;

	UFUNCTION(BlueprintCallable, Category = "Sekiro|SimpleMovement")
	void SetSimpleMovementState(
		int32 InLayerId,
		int32 InStateId,
		int32 InPreviousStateId,
		int32 InDirectionId,
		float InStateElapsedSeconds);
};
