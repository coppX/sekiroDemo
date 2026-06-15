#pragma once

#include "CoreMinimal.h"
#include "Animation/AnimNotifies/AnimNotifyState.h"
#include "SekiroMovementAnimNotifyState.generated.h"

UENUM(BlueprintType)
enum class ESekiroMovementAnimEventType : uint8
{
	LSMoveQueued UMETA(DisplayName = "LS Move Queued"),
	DisableTurning UMETA(DisplayName = "Disable Turning"),
	DisableMovement UMETA(DisplayName = "Disable Movement"),
	SetTurnSpeed UMETA(DisplayName = "Set Turn Speed"),
	MoveMultiplier UMETA(DisplayName = "Move Multiplier"),
	LimitMoveSpeedToWalk UMETA(DisplayName = "Limit Move Speed To Walk"),
	LimitMoveSpeedToDash UMETA(DisplayName = "Limit Move Speed To Dash"),
	DisableDirectionChange UMETA(DisplayName = "Disable Direction Change"),
	Other UMETA(DisplayName = "Other"),
};

UCLASS(Blueprintable, BlueprintType, HideCategories = Object)
class SEKIRODEMO_API USekiroMovementAnimNotifyState : public UAnimNotifyState
{
	GENERATED_BODY()

public:
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Movement Event")
	ESekiroMovementAnimEventType EventType = ESekiroMovementAnimEventType::Other;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Movement Event")
	FName EventName = NAME_None;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|TAE")
	FName RawEventName = NAME_None;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|TAE")
	int32 TaeType = INDEX_NONE;

	UPROPERTY()
	FString TaeParameterSummary;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Movement Event")
	float NumericValue = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, AdvancedDisplay, Category = "Sekiro|Internal")
	FString SourceArguments;

	virtual void NotifyBegin(
		USkeletalMeshComponent* MeshComp,
		UAnimSequenceBase* Animation,
		float TotalDuration,
		const FAnimNotifyEventReference& EventReference) override;

	virtual void NotifyEnd(
		USkeletalMeshComponent* MeshComp,
		UAnimSequenceBase* Animation,
		const FAnimNotifyEventReference& EventReference) override;

	virtual FString GetNotifyName_Implementation() const override;

	virtual int32 GetTaeJumpTableID() const;
	virtual int32 GetSpEffectID() const;
	virtual int32 GetAttackBehaviorJudgeID() const;
	virtual int32 GetAnimID() const;
	virtual float GetTaeUnk00() const;
};

UCLASS(Blueprintable, BlueprintType, HideCategories = Object)
class SEKIRODEMO_API USekiroTaeJumpTableNotifyState : public USekiroMovementAnimNotifyState
{
	GENERATED_BODY()

public:
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro")
	int32 JumpTableID = INDEX_NONE;

	virtual int32 GetTaeJumpTableID() const override;
};

UCLASS(Blueprintable, BlueprintType, HideCategories = Object)
class SEKIRODEMO_API USekiroTaeAttackBehaviorNotifyState : public USekiroMovementAnimNotifyState
{
	GENERATED_BODY()

public:
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro")
	int32 AttackType = INDEX_NONE;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro")
	int32 Field1 = INDEX_NONE;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro")
	int32 BehaviorJudgeID = INDEX_NONE;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro")
	int32 DirectionType = INDEX_NONE;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro")
	int32 AttackSource = INDEX_NONE;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro")
	int32 StateInfo = INDEX_NONE;

	virtual int32 GetAttackBehaviorJudgeID() const override;
};

UCLASS(Blueprintable, BlueprintType, HideCategories = Object)
class SEKIRODEMO_API USekiroTaeSpEffectNotifyState : public USekiroMovementAnimNotifyState
{
	GENERATED_BODY()

public:
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro")
	int32 SpEffectID = INDEX_NONE;

	virtual int32 GetSpEffectID() const override;
};

UCLASS(Blueprintable, BlueprintType, HideCategories = Object)
class SEKIRODEMO_API USekiroTaeParameterizedNotifyState : public USekiroMovementAnimNotifyState
{
	GENERATED_BODY()

public:
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Params")
	FName TaeParamName0 = NAME_None;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Params")
	FString TaeParamValue0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Params")
	float TaeParamNumber0 = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Params")
	FName TaeParamName1 = NAME_None;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Params")
	FString TaeParamValue1;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Params")
	float TaeParamNumber1 = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Params")
	FName TaeParamName2 = NAME_None;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Params")
	FString TaeParamValue2;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Params")
	float TaeParamNumber2 = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Params")
	FName TaeParamName3 = NAME_None;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Params")
	FString TaeParamValue3;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Params")
	float TaeParamNumber3 = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Params")
	FName TaeParamName4 = NAME_None;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Params")
	FString TaeParamValue4;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Params")
	float TaeParamNumber4 = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Params")
	FName TaeParamName5 = NAME_None;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Params")
	FString TaeParamValue5;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Params")
	float TaeParamNumber5 = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Params")
	FName TaeParamName6 = NAME_None;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Params")
	FString TaeParamValue6;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Params")
	float TaeParamNumber6 = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Params")
	FName TaeParamName7 = NAME_None;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Params")
	FString TaeParamValue7;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Params")
	float TaeParamNumber7 = 0.0f;
};

UCLASS(Blueprintable, BlueprintType, HideCategories = Object)
class SEKIRODEMO_API USekiroTaeAnimBlendNotifyState : public USekiroMovementAnimNotifyState
{
	GENERATED_BODY()

public:
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Anim")
	bool bIsFemaleAnim = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Anim")
	int32 AnimID = INDEX_NONE;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Anim")
	float AnimWeightAtEventStart = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Anim")
	float AnimWeightAtEventEnd = 0.0f;

	virtual int32 GetAnimID() const override;
};

UCLASS(Blueprintable, BlueprintType, HideCategories = Object)
class SEKIRODEMO_API USekiroTaeUnknownVectorNotifyState : public USekiroMovementAnimNotifyState
{
	GENERATED_BODY()

public:
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Unknown")
	float TaeUnk00 = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Unknown")
	float TaeUnk04 = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Unknown")
	float TaeUnk08 = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Sekiro|Unknown")
	float TaeUnk0C = 0.0f;

	virtual float GetTaeUnk00() const override;
};
