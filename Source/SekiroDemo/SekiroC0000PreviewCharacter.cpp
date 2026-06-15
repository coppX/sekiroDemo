#include "SekiroC0000PreviewCharacter.h"

#include "SekiroEnvQueryComponent.h"
#include "SekiroEnemyCharacter.h"
#include "SekiroLayeredStateMachineComponent.h"

#include "Animation/AnimationAsset.h"
#include "Animation/AnimClassInterface.h"
#include "Animation/AnimInstance.h"
#include "Animation/AnimNode_AssetPlayerBase.h"
#include "Animation/AnimSequenceBase.h"
#include "Animation/BlendSpace.h"
#include "Camera/CameraComponent.h"
#include "Components/CapsuleComponent.h"
#include "Components/SkeletalMeshComponent.h"
#include "Components/StaticMeshComponent.h"
#include "Components/InputComponent.h"
#include "Engine/StaticMesh.h"
#include "GameFramework/CharacterMovementComponent.h"
#include "GameFramework/PlayerController.h"
#include "GameFramework/SpringArmComponent.h"
#include "InputCoreTypes.h"
#include "Kismet/GameplayStatics.h"
#include "Math/UnrealMathUtility.h"
#include "Engine/World.h"
#include "TimerManager.h"
#include "LuaEnv.h"
#include "UObject/SoftObjectPath.h"
#include "UObject/ConstructorHelpers.h"
#include "UObject/UnrealType.h"
#include "UnLuaLegacy.h"
#include "UnLuaModule.h"
#include "AnimNodes/AnimNode_BlendSpacePlayer.h"

namespace
{
	const FRotator PreviewMeshFacingRotation(0.0f, -90.0f, 0.0f);
	const FName BackWeaponAttachSocketName(TEXT("C0000_FLVERDummy_044_Ref047_A_Spine2"));
	const FName BackWeaponAimSocketName(TEXT("C0000_FLVERDummy_528_Ref015_A_LargeSheath"));
	const FName BackWeaponLeftSocketName(TEXT("socket1"));
	const FName BackWeaponRightSocketName(TEXT("socket2"));
	const FName NTCEventActiveAnimVar(TEXT("FSM_NTCEventActive"));
	const FName NTCEventFinishedAnimVar(TEXT("FSM_NTCEventFinished"));
	TMap<const ASekiroC0000PreviewCharacter*, int32> GLastPreviewForwardPressByCharacter;
	TMap<const ASekiroC0000PreviewCharacter*, int32> GLastPreviewLateralPressByCharacter;

	int32 GetLastPreviewForwardPress(const ASekiroC0000PreviewCharacter* Character)
	{
		const int32* LastPress = GLastPreviewForwardPressByCharacter.Find(Character);
		return LastPress ? *LastPress : 0;
	}

	void SetLastPreviewForwardPress(const ASekiroC0000PreviewCharacter* Character, const int32 Direction)
	{
		GLastPreviewForwardPressByCharacter.FindOrAdd(Character) = Direction;
	}

	int32 GetLastPreviewLateralPress(const ASekiroC0000PreviewCharacter* Character)
	{
		const int32* LastPress = GLastPreviewLateralPressByCharacter.Find(Character);
		return LastPress ? *LastPress : 0;
	}

	void SetLastPreviewLateralPress(const ASekiroC0000PreviewCharacter* Character, const int32 Direction)
	{
		GLastPreviewLateralPressByCharacter.FindOrAdd(Character) = Direction;
	}

	bool ExtractTaeParamFloat(const FString& SourceArguments, const FString& ParamName, float& OutValue)
	{
		TArray<FString> Pairs;
		SourceArguments.ParseIntoArray(Pairs, TEXT(";"), true);
		for (const FString& Pair : Pairs)
		{
			FString Key;
			FString Value;
			if (!Pair.Split(TEXT("="), &Key, &Value))
			{
				continue;
			}

			Key.TrimStartAndEndInline();
			Value.TrimStartAndEndInline();
			if (Key == ParamName && Value.IsNumeric())
			{
				OutValue = FCString::Atof(*Value);
				return true;
			}
		}
		return false;
	}

	int32 ExtractTaeParamIntOrDefault(const FString& SourceArguments, const TCHAR* ParamName, const int32 DefaultValue = INDEX_NONE)
	{
		float Value = 0.0f;
		return ExtractTaeParamFloat(SourceArguments, ParamName, Value)
			? FMath::RoundToInt(Value)
			: DefaultValue;
	}

	bool ExtractTagFloat(const UActorComponent* Component, const FString& Prefix, float& OutValue)
	{
		if (!Component)
		{
			return false;
		}

		for (const FName& Tag : Component->ComponentTags)
		{
			const FString TagText = Tag.ToString();
			if (TagText.StartsWith(Prefix))
			{
				OutValue = FCString::Atof(*TagText.RightChop(Prefix.Len()));
				return true;
			}
		}
		return false;
	}

	bool ExtractTagInt(const UActorComponent* Component, const FString& Prefix, int32& OutValue)
	{
		if (!Component)
		{
			return false;
		}

		for (const FName& Tag : Component->ComponentTags)
		{
			const FString TagText = Tag.ToString();
			if (TagText.StartsWith(Prefix))
			{
				OutValue = FCString::Atoi(*TagText.RightChop(Prefix.Len()));
				return true;
			}
		}
		return false;
	}

	FName ExtractAttackIDFromComponent(const UActorComponent* Component)
	{
		if (!Component)
		{
			return NAME_None;
		}

		for (const FName& Tag : Component->ComponentTags)
		{
			if (Tag.ToString().StartsWith(TEXT("ATK")))
			{
				return Tag;
			}
		}
		return NAME_None;
	}

	void ApplyPreviewAttackHitFromCollision(UPrimitiveComponent* Collision, ASekiroEnemyCharacter* Enemy, AActor* InstigatorActor)
	{
		if (!Collision)
		{
			UE_LOG(LogTemp, Warning, TEXT("[C0000Hitbox] Skip hit: Collision=null Enemy=%s"),
				Enemy ? *Enemy->GetName() : TEXT("null"));
			return;
		}
		if (!Enemy)
		{
			UE_LOG(LogTemp, Warning, TEXT("[C0000Hitbox] Skip hit: Enemy=null Collision=%s"),
				*Collision->GetName());
			return;
		}
		if (Enemy == InstigatorActor)
		{
			UE_LOG(LogTemp, Warning, TEXT("[C0000Hitbox] Skip hit: self overlap Collision=%s Enemy=%s"),
				*Collision->GetName(),
				*Enemy->GetName());
			return;
		}
		if (Enemy->bDead)
		{
			UE_LOG(LogTemp, Warning, TEXT("[C0000Hitbox] Skip hit: enemy dead Collision=%s Enemy=%s"),
				*Collision->GetName(),
				*Enemy->GetName());
			return;
		}

		int32 Field1 = 0;
		ExtractTagInt(Collision, TEXT("Field1:"), Field1);
		if (Field1 != 0)
		{
			UE_LOG(LogTemp, Warning, TEXT("[C0000Hitbox] Pickup only: Field1=%d Collision=%s Enemy=%s"),
				Field1,
				*Collision->GetName(),
				*Enemy->GetName());
			return;
		}

		const FName HitTag(*FString::Printf(TEXT("HitActor:%s"), *Enemy->GetFName().ToString()));
		if (Collision->ComponentTags.Contains(HitTag))
		{
			UE_LOG(LogTemp, Warning, TEXT("[C0000Hitbox] Skip hit: duplicate Collision=%s Enemy=%s"),
				*Collision->GetName(),
				*Enemy->GetName());
			return;
		}
		Collision->ComponentTags.AddUnique(HitTag);

		float Damage = 30.0f;
		ExtractTagFloat(Collision, TEXT("Damage:"), Damage);
		const FName AttackID = ExtractAttackIDFromComponent(Collision);
		UE_LOG(LogTemp, Warning, TEXT("[C0000Hitbox] HIT Collision=%s Attack=%s Enemy=%s Damage=%.1f EnemyLoc=%s HitboxLoc=%s"),
			*Collision->GetName(),
			*AttackID.ToString(),
			*Enemy->GetName(),
			Damage,
			*Enemy->GetActorLocation().ToString(),
			*Collision->GetComponentLocation().ToString());
		Enemy->ApplyPlayerAttackHit(Damage, AttackID, InstigatorActor);
	}

	void PickupPreviewAttackOverlaps(ASekiroC0000PreviewCharacter* Character, UCapsuleComponent* Collision)
	{
		if (!Character || !Collision)
		{
			return;
		}

		Collision->UpdateOverlaps();

		TArray<AActor*> OverlappingEnemies;
		Collision->GetOverlappingActors(OverlappingEnemies, ASekiroEnemyCharacter::StaticClass());
		UE_LOG(LogTemp, Warning, TEXT("[C0000Hitbox] Pickup overlaps Collision=%s Count=%d Loc=%s Radius=%.1f HalfHeight=%.1f"),
			*Collision->GetName(),
			OverlappingEnemies.Num(),
			*Collision->GetComponentLocation().ToString(),
			Collision->GetScaledCapsuleRadius(),
			Collision->GetScaledCapsuleHalfHeight());
		for (AActor* Actor : OverlappingEnemies)
		{
			UE_LOG(LogTemp, Warning, TEXT("[C0000Hitbox] Pickup candidate Collision=%s Actor=%s Class=%s"),
				*Collision->GetName(),
				Actor ? *Actor->GetName() : TEXT("null"),
				Actor ? *Actor->GetClass()->GetName() : TEXT("null"));
			ApplyPreviewAttackHitFromCollision(Collision, Cast<ASekiroEnemyCharacter>(Actor), Character);
		}
	}

	bool HasLineOfSightToEnemy(const AActor* SourceActor, const AActor* TargetActor)
	{
		const UWorld* World = SourceActor ? SourceActor->GetWorld() : nullptr;
		if (!World || !TargetActor)
		{
			return false;
		}

		const FVector Start = SourceActor->GetActorLocation() + FVector(0.0f, 0.0f, 90.0f);
		const FVector End = TargetActor->GetActorLocation() + FVector(0.0f, 0.0f, 90.0f);
		FCollisionQueryParams Params(SCENE_QUERY_STAT(SekiroPlayerTargeting), false);
		Params.AddIgnoredActor(SourceActor);
		Params.AddIgnoredActor(TargetActor);

		FHitResult Hit;
		return !World->LineTraceSingleByChannel(Hit, Start, End, ECC_Visibility, Params);
	}

	ASekiroEnemyCharacter* FindNearestVisibleEnemy(const AActor* SourceActor, const float MaxDistanceCm)
	{
		UWorld* World = SourceActor ? SourceActor->GetWorld() : nullptr;
		if (!World || MaxDistanceCm <= 0.0f)
		{
			return nullptr;
		}

		TArray<AActor*> Actors;
		UGameplayStatics::GetAllActorsWithTag(World, TEXT("Enemy"), Actors);
		TArray<AActor*> EnemyClassActors;
		UGameplayStatics::GetAllActorsOfClass(World, ASekiroEnemyCharacter::StaticClass(), EnemyClassActors);
		for (AActor* Actor : EnemyClassActors)
		{
			Actors.AddUnique(Actor);
		}

		ASekiroEnemyCharacter* BestEnemy = nullptr;
		float BestDistanceSq = FMath::Square(MaxDistanceCm);
		const FVector SourceLocation = SourceActor->GetActorLocation();
		for (AActor* Actor : Actors)
		{
			ASekiroEnemyCharacter* Enemy = Cast<ASekiroEnemyCharacter>(Actor);
			if (!Enemy || Enemy == SourceActor || Enemy->bDead)
			{
				continue;
			}

			const float DistanceSq = FVector::DistSquared2D(SourceLocation, Enemy->GetActorLocation());
			if (DistanceSq <= BestDistanceSq && HasLineOfSightToEnemy(SourceActor, Enemy))
			{
				BestEnemy = Enemy;
				BestDistanceSq = DistanceSq;
			}
		}
		return BestEnemy;
	}

	struct FPreviewAttackCollisionConfig
	{
		int32 AtkParamID = INDEX_NONE;
		int32 BehaviorJudgeID = INDEX_NONE;
		int32 DmyPoly1 = 120;
		int32 DmyPoly2 = 100;
		int32 Field1 = 0;
		float RadiusCm = 40.0f;
		float Damage = 30.0f;
		float LengthCm = 90.0f;
		FName AttachBoneName = TEXT("R_Weapon");
		FName StartSocketName = TEXT("C0000_FLVERDummy_073_Ref120_A_R_Weapon");
		FName EndSocketName = TEXT("C0000_FLVERDummy_060_Ref100_A_R_Weapon");
		FVector LocalLocation = FVector::ZeroVector;
		FVector LocalForward = FVector(0.0f, 0.0f, 1.0f);
		FVector LocalUp = FVector(1.0f, 0.0f, 0.0f);
	};

	bool ResolvePreviewAttackCollisionConfig(const int32 BehaviorJudgeID, FPreviewAttackCollisionConfig& OutConfig)
	{
		if (BehaviorJudgeID == INDEX_NONE)
		{
			return false;
		}

		OutConfig.BehaviorJudgeID = BehaviorJudgeID;
		OutConfig.AtkParamID = 5000000 + BehaviorJudgeID;
		OutConfig.DmyPoly1 = 120;
		OutConfig.DmyPoly2 = 100;
		OutConfig.RadiusCm = 40.0f;
		OutConfig.Damage = 30.0f;
		OutConfig.LengthCm = 90.0f;
		return true;
	}

	FName MakePreviewAttackID(const FPreviewAttackCollisionConfig& Config)
	{
		return Config.AtkParamID != INDEX_NONE
			? FName(*FString::Printf(TEXT("ATK%d"), Config.AtkParamID))
			: NAME_None;
	}

	FName MakePreviewAttackCollisionComponentName(const FName AttackID)
	{
		return FName(*FString::Printf(TEXT("PreviewAttackCollision_%s"), *AttackID.ToString()));
	}

	UCapsuleComponent* FindPreviewAttackCollision(ASekiroC0000PreviewCharacter* Character, const FName AttackID)
	{
		if (!Character || AttackID.IsNone())
		{
			return nullptr;
		}

		TArray<UCapsuleComponent*> CapsuleComponents;
		Character->GetComponents<UCapsuleComponent>(CapsuleComponents);
		const FName ComponentName = MakePreviewAttackCollisionComponentName(AttackID);
		for (UCapsuleComponent* CapsuleComponent : CapsuleComponents)
		{
			if (CapsuleComponent && CapsuleComponent->GetFName() == ComponentName)
			{
				return CapsuleComponent;
			}
		}
		return nullptr;
	}

	void DestroyPreviewAttackCollision(ASekiroC0000PreviewCharacter* Character, const FName AttackID)
	{
		if (UCapsuleComponent* Collision = FindPreviewAttackCollision(Character, AttackID))
		{
			UE_LOG(LogTemp, Warning, TEXT("[C0000Hitbox] Destroy Collision=%s Attack=%s"),
				*Collision->GetName(),
				*AttackID.ToString());
			Collision->SetCollisionEnabled(ECollisionEnabled::NoCollision);
			Collision->SetGenerateOverlapEvents(false);
			Collision->DestroyComponent();
		}
	}

	FRotator MakePreviewAttackRotation(const FPreviewAttackCollisionConfig& Config)
	{
		const FVector CapsuleAxis = Config.LocalForward.GetSafeNormal(UE_SMALL_NUMBER, FVector::UpVector);
		const FVector UpAxis = Config.LocalUp.GetSafeNormal(UE_SMALL_NUMBER, FVector::ForwardVector);
		return FRotationMatrix::MakeFromZX(CapsuleAxis, UpAxis).Rotator();
	}

	bool BeginPreviewAttackCollisionFromSockets(ASekiroC0000PreviewCharacter* Character, UCapsuleComponent* Collision, const FPreviewAttackCollisionConfig& Config)
	{
		USkeletalMeshComponent* BodyMesh = Character ? Character->GetMesh() : nullptr;
		if (!BodyMesh
			|| !BodyMesh->DoesSocketExist(Config.StartSocketName)
			|| !BodyMesh->DoesSocketExist(Config.EndSocketName))
		{
			return false;
		}

		const FVector StartLocation = BodyMesh->GetSocketLocation(Config.StartSocketName);
		const FVector EndLocation = BodyMesh->GetSocketLocation(Config.EndSocketName);
		const FVector Axis = EndLocation - StartLocation;
		const float SpanLength = Axis.Length();
		if (SpanLength <= UE_KINDA_SMALL_NUMBER)
		{
			return false;
		}

		const FRotator WorldRotation = FRotationMatrix::MakeFromZX(Axis.GetSafeNormal(), BodyMesh->GetUpVector()).Rotator();
		const FVector WorldCenter = StartLocation + Axis * 0.5f;
		const float HalfHeight = FMath::Max(Config.RadiusCm, SpanLength * 0.5f + Config.RadiusCm);
		Collision->SetCapsuleSize(Config.RadiusCm, HalfHeight);
		Collision->SetWorldLocationAndRotation(WorldCenter, WorldRotation);
		Collision->AttachToComponent(BodyMesh, FAttachmentTransformRules::KeepWorldTransform, Config.StartSocketName);
		Collision->ComponentTags.AddUnique(FName(*FString::Printf(TEXT("DmyPoly1:%d"), Config.DmyPoly1)));
		Collision->ComponentTags.AddUnique(FName(*FString::Printf(TEXT("DmyPoly2:%d"), Config.DmyPoly2)));
		UE_LOG(LogTemp, Warning, TEXT("[C0000Hitbox] Socket placement Collision=%s Start=%s End=%s Center=%s Span=%.1f Radius=%.1f HalfHeight=%.1f"),
			*Collision->GetName(),
			*StartLocation.ToString(),
			*EndLocation.ToString(),
			*WorldCenter.ToString(),
			SpanLength,
			Config.RadiusCm,
			HalfHeight);
		return true;
	}

	void BeginPreviewAttackCollision(ASekiroC0000PreviewCharacter* Character, const FPreviewAttackCollisionConfig& Config)
	{
		const FName AttackID = MakePreviewAttackID(Config);
		if (!Character || AttackID.IsNone())
		{
			return;
		}

		DestroyPreviewAttackCollision(Character, AttackID);

		UCapsuleComponent* Collision = NewObject<UCapsuleComponent>(
			Character,
			UCapsuleComponent::StaticClass(),
			MakePreviewAttackCollisionComponentName(AttackID));
		if (!Collision)
		{
			return;
		}

		Character->AddInstanceComponent(Collision);
		Collision->SetCapsuleSize(Config.RadiusCm, FMath::Max(Config.RadiusCm, Config.LengthCm * 0.5f + Config.RadiusCm));
		Collision->SetCollisionObjectType(ECC_WorldDynamic);
		Collision->SetCollisionResponseToAllChannels(ECR_Ignore);
		Collision->SetCollisionResponseToChannel(ECC_Pawn, ECR_Overlap);
		Collision->SetCanEverAffectNavigation(false);
		Collision->SetMobility(EComponentMobility::Movable);
		Collision->SetHiddenInGame(false);
		Collision->SetVisibility(true);
		Collision->SetGenerateOverlapEvents(true);
		Collision->SetCollisionEnabled(ECollisionEnabled::QueryOnly);
		Collision->ComponentTags.AddUnique(AttackID);
		Collision->ComponentTags.AddUnique(TEXT("InvokeAttackBehavior"));
		Collision->ComponentTags.AddUnique(FName(*FString::Printf(TEXT("AtkParam:%d"), Config.AtkParamID)));
		Collision->ComponentTags.AddUnique(FName(*FString::Printf(TEXT("BehaviorJudgeID:%d"), Config.BehaviorJudgeID)));
		Collision->ComponentTags.AddUnique(FName(*FString::Printf(TEXT("Field1:%d"), Config.Field1)));
		Collision->ComponentTags.AddUnique(FName(*FString::Printf(TEXT("Damage:%.0f"), Config.Damage)));
		Collision->OnComponentBeginOverlap.AddDynamic(Character, &ASekiroC0000PreviewCharacter::HandlePreviewAttackOverlap);
		Collision->RegisterComponent();
		UE_LOG(LogTemp, Warning, TEXT("[C0000Hitbox] Create Collision=%s Attack=%s BehaviorJudgeID=%d AtkParam=%d Damage=%.1f"),
			*Collision->GetName(),
			*AttackID.ToString(),
			Config.BehaviorJudgeID,
			Config.AtkParamID,
			Config.Damage);

		if (BeginPreviewAttackCollisionFromSockets(Character, Collision, Config))
		{
			Collision->UpdateComponentToWorld();
			PickupPreviewAttackOverlaps(Character, Collision);
			return;
		}

		USceneComponent* AttachComponent = nullptr;
		TArray<UStaticMeshComponent*> StaticMeshComponents;
		Character->GetComponents<UStaticMeshComponent>(StaticMeshComponents);
		for (UStaticMeshComponent* StaticMeshComponent : StaticMeshComponents)
		{
			if (StaticMeshComponent && StaticMeshComponent->GetFName() == TEXT("RightHandDrawBlade"))
			{
				AttachComponent = StaticMeshComponent;
				break;
			}
		}
		if (!AttachComponent)
		{
			AttachComponent = Character->GetMesh();
		}
		if (!AttachComponent)
		{
			UE_LOG(LogTemp, Warning, TEXT("[C0000Hitbox] Destroy: no fallback attach component Collision=%s Attack=%s"),
				*Collision->GetName(),
				*AttackID.ToString());
			Collision->DestroyComponent();
			return;
		}

		const FName AttachSocket = AttachComponent == Character->GetMesh() ? Config.AttachBoneName : NAME_None;
		Collision->AttachToComponent(AttachComponent, FAttachmentTransformRules::SnapToTargetNotIncludingScale, AttachSocket);
		const FVector CapsuleCenter = Config.LocalLocation + Config.LocalForward.GetSafeNormal() * (Config.LengthCm * 0.5f);
		Collision->SetRelativeLocationAndRotation(CapsuleCenter, MakePreviewAttackRotation(Config));
		Collision->UpdateComponentToWorld();
		UE_LOG(LogTemp, Warning, TEXT("[C0000Hitbox] Fallback placement Collision=%s Attach=%s Socket=%s WorldLoc=%s Radius=%.1f HalfHeight=%.1f"),
			*Collision->GetName(),
			*AttachComponent->GetName(),
			*AttachSocket.ToString(),
			*Collision->GetComponentLocation().ToString(),
			Collision->GetScaledCapsuleRadius(),
			Collision->GetScaledCapsuleHalfHeight());
		PickupPreviewAttackOverlaps(Character, Collision);
	}

	void HandlePreviewInvokeAttackBehavior(
		ASekiroC0000PreviewCharacter* Character,
		const bool bActive,
		const int32 NotifyTaeType,
		const int32 NotifyBehaviorJudgeID,
		const FString& SourceArguments)
	{
		const int32 TaeType = NotifyTaeType != INDEX_NONE
			? NotifyTaeType
			: ExtractTaeParamIntOrDefault(SourceArguments, TEXT("TaeType"));
		if (TaeType != 1)
		{
			return;
		}

		const int32 BehaviorJudgeID = NotifyBehaviorJudgeID != INDEX_NONE
			? NotifyBehaviorJudgeID
			: ExtractTaeParamIntOrDefault(SourceArguments, TEXT("BehaviorJudgeID"));
		FPreviewAttackCollisionConfig Config;
		if (!ResolvePreviewAttackCollisionConfig(BehaviorJudgeID, Config))
		{
			return;
		}
		Config.Field1 = ExtractTaeParamIntOrDefault(SourceArguments, TEXT("field_1"), ExtractTaeParamIntOrDefault(SourceArguments, TEXT("Field1"), 0));
		if (Config.Field1 != 0)
		{
			UE_LOG(LogTemp, Verbose, TEXT("[C0000Hitbox] Skip non-damage InvokeAttackBehavior BehaviorJudgeID=%d Field1=%d"),
				BehaviorJudgeID,
				Config.Field1);
			return;
		}

		const FName AttackID = MakePreviewAttackID(Config);
		if (bActive)
		{
			Character->FaceNearestVisibleEnemyForAttack();
			UE_LOG(LogTemp, Warning, TEXT("[C0000Hitbox] Notify Begin TaeType=%d BehaviorJudgeID=%d Args=%s"),
				TaeType,
				BehaviorJudgeID,
				*SourceArguments);
			BeginPreviewAttackCollision(Character, Config);
		}
		else
		{
			UE_LOG(LogTemp, Warning, TEXT("[C0000Hitbox] Notify End TaeType=%d BehaviorJudgeID=%d Attack=%s"),
				TaeType,
				BehaviorJudgeID,
				*AttackID.ToString());
			DestroyPreviewAttackCollision(Character, AttackID);
		}
	}

	FString NormalizeObjectPath(const FString& AssetPath)
	{
		if (!AssetPath.StartsWith(TEXT("/")))
		{
			return AssetPath;
		}

		if (AssetPath.Contains(TEXT(".")))
		{
			return AssetPath;
		}

		FString PackagePath;
		FString AssetName;
		if (!AssetPath.Split(TEXT("/"), &PackagePath, &AssetName, ESearchCase::IgnoreCase, ESearchDir::FromEnd))
		{
			return AssetPath;
		}

		return FString::Printf(TEXT("%s.%s"), *AssetPath, *AssetName);
	}

	template <typename PropertyType>
	PropertyType* FindAnimProperty(const UAnimInstance* AnimInstance, const FName VarName)
	{
		if (!AnimInstance)
		{
			return nullptr;
		}

		return FindFProperty<PropertyType>(AnimInstance->GetClass(), VarName);
	}

	bool IsGroundAttackActionState(const int32 ActionStateId)
	{
		return ActionStateId == 11200 || ActionStateId == 11201 ||
			ActionStateId == 11202 || ActionStateId == 11203 ||
			ActionStateId == 11204 || ActionStateId == 11206 ||
			ActionStateId == 11208 || ActionStateId == 11213 ||
			ActionStateId == 11214 || ActionStateId == 11215 ||
			ActionStateId == 11216;
	}

	bool IsBaseQuickTurnState(const int32 BaseStateId)
	{
		return BaseStateId == 4 || BaseStateId == 5 || BaseStateId == 6 || BaseStateId == 7;
	}

	bool IsGroundAttackNoTurnActive(const USekiroLayeredStateMachineComponent* StateMachine)
	{
		constexpr int32 ActionLayerId = 1;
		return StateMachine && IsGroundAttackActionState(StateMachine->GetLayerStateId(ActionLayerId));
	}

	bool ShouldLogPreviewAnimBoolWrite(const FName VarName)
	{
		return VarName == TEXT("IsTurnTwist");
	}

	bool ShouldLogPreviewAnimIntWrite(const FName VarName)
	{
		return VarName == TEXT("StateId") ||
			VarName == TEXT("FSM_StateId") ||
			VarName == TEXT("FSM_AnimStateId") ||
			VarName == TEXT("StateStateId_StandMoveableAction") ||
			VarName == TEXT("QuickTurnState") ||
			VarName == TEXT("TurnType");
	}

	bool ShouldLogPreviewAnimFloatWrite(const FName VarName)
	{
		return VarName == TEXT("TurnAngle") ||
			VarName == TEXT("TwistLowerRootAngle") ||
			VarName == TEXT("TwistMasterAngle") ||
			VarName == TEXT("TwistUpperRootAngle") ||
			VarName == TEXT("MoveTwistAngle_Yaw") ||
			VarName == TEXT("MoveTwistAngle_Roll");
	}

	void LogPreviewAnimWrite(
		const ASekiroC0000PreviewCharacter* Character,
		const TCHAR* Type,
		const FName VarName,
		const FString& RequestedValue,
		const FString& FinalValue)
	{
		const USekiroLayeredStateMachineComponent* StateMachine =
			Character ? Character->GetSekiroLayeredStateMachine() : nullptr;
		const int32 BaseState = StateMachine ? StateMachine->GetLayerStateId(0) : INDEX_NONE;
		const int32 ActionState = StateMachine ? StateMachine->GetLayerStateId(1) : INDEX_NONE;
		const float ActorYaw = Character ? Character->GetActorRotation().Yaw : 0.0f;
		UE_LOG(
			LogTemp,
			Warning,
			TEXT("[SekiroFSM] AnimVar %s %s requested=%s final=%s Base=%d Action=%d ActorYaw=%.2f"),
			Type,
			*VarName.ToString(),
			*RequestedValue,
			*FinalValue,
			BaseState,
			ActionState,
			ActorYaw);
	}

	void SuppressBaseQuickTurnDuringGroundAttack(USekiroLayeredStateMachineComponent* StateMachine)
	{
		constexpr int32 BaseLayerId = 0;
		constexpr int32 BaseIdleStateId = 0;
		constexpr int32 MoveDirectionNone = -1;
		if (IsGroundAttackNoTurnActive(StateMachine) &&
			IsBaseQuickTurnState(StateMachine->GetLayerStateId(BaseLayerId)))
		{
			StateMachine->SetLayerState(
				BaseLayerId,
				BaseIdleStateId,
				TEXT("Idle"),
				TEXT("W_BaseIdle"),
				MoveDirectionNone);
		}
	}

	float GetSignedHorizontalAngleDegrees(const FVector& ReferenceDirection, const FVector& SampleDirection)
	{
		const FVector Ref = ReferenceDirection.GetSafeNormal2D();
		const FVector Sample = SampleDirection.GetSafeNormal2D();
		if (Ref.IsNearlyZero() || Sample.IsNearlyZero())
		{
			return 0.0f;
		}

		const float Dot = FMath::Clamp(FVector::DotProduct(Ref, Sample), -1.0f, 1.0f);
		const float CrossZ = FVector::CrossProduct(Ref, Sample).Z;
		return FMath::RadiansToDegrees(FMath::Atan2(CrossZ, Dot));
	}

	UnLua::FLuaEnv* ResolveLuaEnv(UObject* TargetObject)
	{
		if (!TargetObject)
		{
			return nullptr;
		}

		IUnLuaModule& UnLuaModule = IUnLuaModule::Get();
		if (!UnLuaModule.IsActive())
		{
#if WITH_EDITOR
			// Preview stepping runs in the editor world, where UnLua is normally
			// activated only for PIE. Enable it on demand so manual preview tests
			// keep working after restarting the editor.
			UnLuaModule.SetActive(true);
#else
			return nullptr;
#endif
		}

		UnLua::FLuaEnv* LuaEnv = UnLuaModule.GetEnv(TargetObject);
		if (!LuaEnv)
		{
			LuaEnv = UnLuaModule.GetEnv();
		}
		if (!LuaEnv)
		{
			return nullptr;
		}
		return LuaEnv;
	}

	bool CallBoundLuaBoolMethod(UObject* TargetObject, const char* FunctionName, const FString& StringArg, bool& bOutReturnValue)
	{
		bOutReturnValue = false;

		if (!TargetObject || !FunctionName)
		{
			return false;
		}

		UnLua::FLuaEnv* LuaEnv = ResolveLuaEnv(TargetObject);
		if (!LuaEnv)
		{
			return false;
		}

		lua_State* LuaState = LuaEnv->GetMainState();
		if (!LuaState)
		{
			return false;
		}

		const int32 OriginalTop = lua_gettop(LuaState);
		bool bCallSucceeded = false;
		{
			UnLua::PushUObject(LuaState, TargetObject);
			UnLua::FLuaTable SelfTable(LuaState, -1);
			UnLua::FLuaRetValues ReturnValues = UnLua::CallTableFunc(LuaState, SelfTable, FunctionName, TargetObject, StringArg);
			bCallSucceeded = ReturnValues.IsValid();
			if (bCallSucceeded && ReturnValues.Num() > 0)
			{
				const UnLua::FLuaValue& ReturnValue = ReturnValues[0];
				if (ReturnValue.GetType() == LUA_TBOOLEAN)
				{
					bOutReturnValue = ReturnValue.Value<bool>();
				}
				else if (ReturnValue.GetType() == LUA_TNUMBER)
				{
					bOutReturnValue = !FMath::IsNearlyZero(static_cast<float>(ReturnValue.Value<double>()));
				}
			}
		}

		lua_settop(LuaState, OriginalTop);
		return bCallSucceeded;
	}

	bool CallBoundLuaTickMethod(UObject* TargetObject, const char* FunctionName, const float DeltaSeconds)
	{
		if (!TargetObject || !FunctionName)
		{
			return false;
		}

		UnLua::FLuaEnv* LuaEnv = ResolveLuaEnv(TargetObject);
		if (!LuaEnv)
		{
			return false;
		}

		lua_State* LuaState = LuaEnv->GetMainState();
		if (!LuaState)
		{
			return false;
		}

		const int32 OriginalTop = lua_gettop(LuaState);
		bool bCallSucceeded = false;
		{
			UnLua::PushUObject(LuaState, TargetObject);
			UnLua::FLuaTable SelfTable(LuaState, -1);
			UnLua::FLuaRetValues ReturnValues = UnLua::CallTableFunc(
				LuaState,
				SelfTable,
				FunctionName,
				TargetObject,
				DeltaSeconds);
			bCallSucceeded = ReturnValues.IsValid();
		}

		lua_settop(LuaState, OriginalTop);
		return bCallSucceeded;
	}

	bool CallBoundLuaMovementAnimEvent(
		UObject* TargetObject,
		const char* FunctionName,
		const FName EventName,
		const bool bActive,
		const float NumericValue,
		const FString& SourceArguments)
	{
		if (!TargetObject || !FunctionName)
		{
			return false;
		}

		UnLua::FLuaEnv* LuaEnv = ResolveLuaEnv(TargetObject);
		if (!LuaEnv)
		{
			return false;
		}

		lua_State* LuaState = LuaEnv->GetMainState();
		if (!LuaState)
		{
			return false;
		}

		const int32 OriginalTop = lua_gettop(LuaState);
		bool bCallSucceeded = false;
		{
			UnLua::PushUObject(LuaState, TargetObject);
			UnLua::FLuaTable SelfTable(LuaState, -1);
			UnLua::FLuaRetValues ReturnValues = UnLua::CallTableFunc(
				LuaState,
				SelfTable,
				FunctionName,
				TargetObject,
				EventName.ToString(),
				bActive,
				NumericValue,
				SourceArguments);
			bCallSucceeded = ReturnValues.IsValid();
		}

		lua_settop(LuaState, OriginalTop);
		return bCallSucceeded;
	}

	void AppendBlendSpaceSampleDebug(
		FString& OutDebug,
		const UBlendSpace* BlendSpace,
		const FVector& BlendInput)
	{
		if (!BlendSpace)
		{
			return;
		}

		TArray<FBlendSampleData> SampleDataList;
		int32 CachedTriangulationIndex = INDEX_NONE;
		if (!BlendSpace->GetSamplesFromBlendInput(BlendInput, SampleDataList, CachedTriangulationIndex, true))
		{
			return;
		}

		OutDebug += TEXT(" Samples=");
		if (SampleDataList.IsEmpty())
		{
			OutDebug += TEXT("none");
			return;
		}

		for (int32 SampleIndex = 0; SampleIndex < SampleDataList.Num(); ++SampleIndex)
		{
			const FBlendSampleData& SampleData = SampleDataList[SampleIndex];
			if (SampleIndex > 0)
			{
				OutDebug += TEXT(",");
			}

			OutDebug += FString::Printf(
				TEXT("%s:%.2f"),
				*GetNameSafe(SampleData.Animation),
				SampleData.GetClampedWeight());
		}
	}
}

ASekiroC0000PreviewCharacter::ASekiroC0000PreviewCharacter()
{
	PrimaryActorTick.bCanEverTick = true;
	AutoPossessPlayer = EAutoReceiveInput::Player0;
	ApplyPreviewMovementSettings();

	PreviewLoadInitPose = -1;
	PreviewSafePosReturnType = -1;
	bPreviewAllowStandEnter = true;
	bPreviewForceCrouch = false;
	bPreviewAgingActive = false;
	bPreviewRedoBellReturn = false;
	bUseSimpleMovementAnimBlueprint = true;
	SimpleMovementAnimClass = TSoftClassPtr<UAnimInstance>(
		FSoftObjectPath(TEXT("/Game/Animation/Sekiro/C0000/Blueprints/ABP_Sekiro_C0000_SimpleMovement_MoveStartSubSM_HKXQuickTurnStart.ABP_Sekiro_C0000_SimpleMovement_MoveStartSubSM_HKXQuickTurnStart_C")));
	PreviewResolvedEntryMode = 0;
	PreviewResolvedEntryEventName = TEXT("W_GroundMapEnter");

	CameraBoom = CreateDefaultSubobject<USpringArmComponent>(TEXT("CameraBoom"));
	CameraBoom->SetupAttachment(RootComponent);
	CameraBoom->TargetArmLength = 320.0f;
	CameraBoom->SetRelativeLocation(FVector(0.0f, 0.0f, 92.0f));
	CameraBoom->bUsePawnControlRotation = true;

	FollowCamera = CreateDefaultSubobject<UCameraComponent>(TEXT("FollowCamera"));
	FollowCamera->SetupAttachment(CameraBoom, USpringArmComponent::SocketName);
	FollowCamera->bUsePawnControlRotation = false;

	BackSheathedWeapon = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("BackSheathedWeapon"));
	BackSheathedWeapon->SetupAttachment(GetMesh(), BackWeaponAttachSocketName);
	BackSheathedWeapon->SetCollisionEnabled(ECollisionEnabled::NoCollision);
	BackSheathedWeapon->SetGenerateOverlapEvents(false);
	BackSheathedWeapon->SetRelativeRotation(FRotator(0.0f, -90.0f, 0.0f));
	BackSheathedWeapon->SetVisibility(true);
	BackSheathedWeapon->SetHiddenInGame(false);

	LeftHandScabbard = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("LeftHandScabbard"));
	LeftHandScabbard->SetupAttachment(GetMesh(), TEXT("L_Wepon_Case"));
	LeftHandScabbard->SetCollisionEnabled(ECollisionEnabled::NoCollision);
	LeftHandScabbard->SetGenerateOverlapEvents(false);
	LeftHandScabbard->SetRelativeLocation(FVector(-0.162336f, 27.25194f, -0.498029f));
	LeftHandScabbard->SetRelativeRotation(FRotator(0.0f, -14.0f, -180.0f));
	LeftHandScabbard->SetVisibility(true);
	LeftHandScabbard->SetHiddenInGame(false);

	RightHandDrawBlade = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("RightHandDrawBlade"));
	RightHandDrawBlade->SetupAttachment(GetMesh(), TEXT("R_Weapon"));
	RightHandDrawBlade->SetCollisionEnabled(ECollisionEnabled::NoCollision);
	RightHandDrawBlade->SetGenerateOverlapEvents(false);
	RightHandDrawBlade->SetRelativeRotation(FRotator(0.0f, 180.0f, 0.0f));
	RightHandDrawBlade->SetVisibility(false);
	RightHandDrawBlade->SetHiddenInGame(true);
	
	static ConstructorHelpers::FObjectFinder<UStaticMesh> BackSheathedWeaponMesh(
		TEXT("/Game/Animation/Sekiro/C0000/Weapons/SM_WP_A_0300_L_Sheathed.SM_WP_A_0300_L_Sheathed"));
	if (BackSheathedWeaponMesh.Succeeded())
	{
		BackSheathedWeapon->SetStaticMesh(BackSheathedWeaponMesh.Object);
		AlignBackSheathedWeaponToBackCaseSockets();
	}

	static ConstructorHelpers::FObjectFinder<UStaticMesh> MortalBladeScabbardMesh(
		TEXT("/Game/Animation/Sekiro/C0000/Weapons/SM_WP_A_0310_MortalBlade_Sheathed.SM_WP_A_0310_MortalBlade_Sheathed"));
	if (MortalBladeScabbardMesh.Succeeded())
	{
		MortalBladeRightHandMesh = MortalBladeScabbardMesh.Object;
		RightHandDrawBlade->SetStaticMesh(MortalBladeRightHandMesh);
	}

	static ConstructorHelpers::FObjectFinder<UStaticMesh> MortalBladeWaistSheathedMeshFinder(
		TEXT("/Game/Animation/Sekiro/C0000/Weapons/SM_WP_A_0310_MortalBlade.SM_WP_A_0310_MortalBlade"));
	if (MortalBladeWaistSheathedMeshFinder.Succeeded())
	{
		MortalBladeWaistSheathedMesh = MortalBladeWaistSheathedMeshFinder.Object;
		LeftHandScabbard->SetStaticMesh(MortalBladeWaistSheathedMesh);
	}

	static ConstructorHelpers::FObjectFinder<UStaticMesh> MortalBladeWaistDrawnMeshFinder(
		TEXT("/Game/Animation/Sekiro/C0000/Weapons/SM_WP_A_0310_MortalBlade_DrawBlade.SM_WP_A_0310_MortalBlade_DrawBlade"));
	if (MortalBladeWaistDrawnMeshFinder.Succeeded())
	{
		MortalBladeWaistDrawnMesh = MortalBladeWaistDrawnMeshFinder.Object;
	}
	SetMortalBladeDrawn(false);

	EnvQuery = CreateDefaultSubobject<USekiroEnvQueryComponent>(TEXT("SekiroEnvQuery"));
	LayeredStateMachine = CreateDefaultSubobject<USekiroLayeredStateMachineComponent>(TEXT("SekiroLayeredStateMachine"));
}

void ASekiroC0000PreviewCharacter::OnConstruction(const FTransform& Transform)
{
	Super::OnConstruction(Transform);
	AlignBackSheathedWeaponToBackCaseSockets();
}

void ASekiroC0000PreviewCharacter::AlignBackSheathedWeaponToBackCaseSockets()
{
	USkeletalMeshComponent* CharacterMesh = GetMesh();
	if (!CharacterMesh || !BackSheathedWeapon || !BackSheathedWeapon->GetStaticMesh())
	{
		return;
	}

	if (BackSheathedWeapon->GetAttachParent() != CharacterMesh
		|| BackSheathedWeapon->GetAttachSocketName() != BackWeaponAttachSocketName)
	{
		BackSheathedWeapon->AttachToComponent(
			CharacterMesh,
			FAttachmentTransformRules::KeepRelativeTransform,
			BackWeaponAttachSocketName);
	}

	if (!CharacterMesh->DoesSocketExist(BackWeaponAttachSocketName)
		|| !CharacterMesh->DoesSocketExist(BackWeaponAimSocketName)
		|| !BackSheathedWeapon->DoesSocketExist(BackWeaponLeftSocketName)
		|| !BackSheathedWeapon->DoesSocketExist(BackWeaponRightSocketName))
	{
		return;
	}

	const FTransform BackAttachWorld = CharacterMesh->GetSocketTransform(BackWeaponAttachSocketName, RTS_World);
	const FTransform BackAimWorld = CharacterMesh->GetSocketTransform(BackWeaponAimSocketName, RTS_World);
	const FTransform WeaponLeftLocal = BackSheathedWeapon->GetSocketTransform(BackWeaponLeftSocketName, RTS_Component);
	const FTransform WeaponRightLocal = BackSheathedWeapon->GetSocketTransform(BackWeaponRightSocketName, RTS_Component);

	const FVector WeaponSocketSpan = WeaponRightLocal.GetLocation() - WeaponLeftLocal.GetLocation();
	const FVector BackSocketSpan = BackAimWorld.GetLocation() - BackAttachWorld.GetLocation();
	const FVector WeaponSocketDirection = WeaponSocketSpan.GetSafeNormal();
	const FVector BackSocketDirection = BackSocketSpan.GetSafeNormal();
	if (WeaponSocketDirection.IsNearlyZero() || BackSocketDirection.IsNearlyZero())
	{
		return;
	}

	FQuat DesiredWorldRotation = BackAttachWorld.GetRotation() * WeaponLeftLocal.GetRotation().Inverse();
	const FVector CurrentWorldDirection = DesiredWorldRotation.RotateVector(WeaponSocketDirection).GetSafeNormal();
	if (!CurrentWorldDirection.IsNearlyZero())
	{
		DesiredWorldRotation = FQuat::FindBetweenNormals(CurrentWorldDirection, BackSocketDirection) * DesiredWorldRotation;
		DesiredWorldRotation.Normalize();
	}

	const FVector DesiredWorldScale = FVector::OneVector;
	const FVector DesiredWorldLocation =
		BackAttachWorld.GetLocation() - DesiredWorldRotation.RotateVector(WeaponLeftLocal.GetLocation() * DesiredWorldScale);
	const FTransform DesiredWorldTransform(
		DesiredWorldRotation,
		DesiredWorldLocation,
		DesiredWorldScale);
	const FTransform DesiredRelativeTransform = DesiredWorldTransform.GetRelativeTransform(BackAttachWorld);
	BackSheathedWeapon->SetRelativeTransform(DesiredRelativeTransform);
}

void ASekiroC0000PreviewCharacter::SetMortalBladeDrawn(const bool bDrawn)
{
	bMortalBladeDrawn = bDrawn;
	if (const UWorld* World = GetWorld(); World && World->HasBegunPlay())
	{
		SetAnimFloatVar(TEXT("LocomotionWeaponBlend"), bMortalBladeDrawn ? 1.0f : 0.0f);
	}

	if (BackSheathedWeapon)
	{
		BackSheathedWeapon->SetVisibility(true, true);
		BackSheathedWeapon->SetHiddenInGame(false, true);
	}

	if (LeftHandScabbard)
	{
		if (UStaticMesh* DesiredWaistMesh = bDrawn ? MortalBladeWaistDrawnMesh.Get() : MortalBladeWaistSheathedMesh.Get())
		{
			LeftHandScabbard->SetStaticMesh(DesiredWaistMesh);
		}
		LeftHandScabbard->SetVisibility(true, true);
		LeftHandScabbard->SetHiddenInGame(false, true);
	}

	if (RightHandDrawBlade)
	{
		SetMortalBladeRightHandVisible(bDrawn);
	}
}

void ASekiroC0000PreviewCharacter::SetMortalBladeRightHandVisible(const bool bVisible)
{
	if (!RightHandDrawBlade)
	{
		return;
	}

	if (MortalBladeRightHandMesh && RightHandDrawBlade->GetStaticMesh() != MortalBladeRightHandMesh)
	{
		RightHandDrawBlade->SetStaticMesh(MortalBladeRightHandMesh);
	}

	RightHandDrawBlade->SetVisibility(bVisible, true);
	RightHandDrawBlade->SetHiddenInGame(!bVisible, true);
}

bool ASekiroC0000PreviewCharacter::IsMortalBladeDrawn() const
{
	return bMortalBladeDrawn;
}

void ASekiroC0000PreviewCharacter::HandlePreviewAttackOverlap(
	UPrimitiveComponent* OverlappedComponent,
	AActor* OtherActor,
	UPrimitiveComponent* OtherComp,
	int32 OtherBodyIndex,
	bool bFromSweep,
	const FHitResult& SweepResult)
{
	UE_LOG(LogTemp, Warning, TEXT("[C0000Hitbox] BeginOverlap Collision=%s Other=%s OtherComp=%s Sweep=%d"),
		OverlappedComponent ? *OverlappedComponent->GetName() : TEXT("null"),
		OtherActor ? *OtherActor->GetName() : TEXT("null"),
		OtherComp ? *OtherComp->GetName() : TEXT("null"),
		bFromSweep ? 1 : 0);
	ASekiroEnemyCharacter* Enemy = Cast<ASekiroEnemyCharacter>(OtherActor);
	LockPreviewAttackFaceTarget(Enemy, 2.0f);
	ApplyPreviewAttackHitFromCollision(OverlappedComponent, Enemy, this);
}

bool ASekiroC0000PreviewCharacter::HasVisibleEnemyInAutoWeaponRange() const
{
	return FindNearestVisibleEnemy(this, EnemyAutoWeaponDistanceCm) != nullptr;
}

bool ASekiroC0000PreviewCharacter::FaceNearestVisibleEnemyForAttack()
{
	ASekiroEnemyCharacter* Enemy = FindNearestVisibleEnemy(this, AttackFaceTargetDistanceCm);
	if (!Enemy)
	{
		UE_LOG(LogTemp, Warning, TEXT("[C0000Targeting] FaceTarget skipped: no visible enemy Range=%.1f ActorLoc=%s"),
			AttackFaceTargetDistanceCm,
			*GetActorLocation().ToString());
		return false;
	}

	PreviewAttackFaceTarget = Enemy;
	PreviewAttackFaceTimeRemaining = 2.0f;
	return FacePreviewActorTowardTarget(Enemy);
}

ASekiroEnemyCharacter* ASekiroC0000PreviewCharacter::FindFrontDeathblowTarget() const
{
	ASekiroEnemyCharacter* Enemy = FindNearestVisibleEnemy(this, DeathblowMaxRangeCm);
	if (!Enemy || !Enemy->IsFrontDeathblowAvailable(this, DeathblowMaxRangeCm, DeathblowFrontAngleDegrees))
	{
		return nullptr;
	}
	return Enemy;
}

bool ASekiroC0000PreviewCharacter::TryStartFrontDeathblow()
{
	ASekiroEnemyCharacter* Enemy = FindFrontDeathblowTarget();
	if (!Enemy)
	{
		return false;
	}

	return StartFrontDeathblowOnEnemy(Enemy);
}

bool ASekiroC0000PreviewCharacter::StartFrontDeathblowOnEnemy(ASekiroEnemyCharacter* Enemy)
{
	if (!Enemy || Enemy->bDead || Enemy->bDeathblowInProgress)
	{
		return false;
	}

	Enemy->BeginFrontDeathblow(this);
	FrontDeathblowTarget = Enemy;
	FrontDeathblowAlignTimeRemaining = FMath::Max(FrontDeathblowAlignSeconds, FrontDeathblowThrowKillStartSeconds);
	UpdateFrontDeathblowAlignment(0.0f);
	LockPreviewAttackFaceTarget(Enemy, FrontDeathblowAlignTimeRemaining);
	if (UCharacterMovementComponent* Movement = GetCharacterMovement())
	{
		Movement->StopMovementImmediately();
	}

	ClearPreviewQueuedEvents();
	if (LayeredStateMachine)
	{
		LayeredStateMachine->SetLayerState(1, 0, TEXT("ActionIdle"), TEXT("ActionCanceledByThrow"), -1);
	}
	SetAnimBoolVar(TEXT("FSM_ActionActive"), false);
	SetAnimBoolVar(TEXT("FSM_ActionIdleActive"), true);
	SetAnimIntVar(TEXT("FSM_ActionStateId"), 0);
	SetAnimBoolVar(TEXT("FSM_GroundAttackActive"), false);
	SetAnimBoolVar(TEXT("FSM_GroundAttackCombo1Active"), false);
	SetAnimBoolVar(TEXT("FSM_GroundAttackCombo1ReleaseActive"), false);
	SetAnimBoolVar(TEXT("FSM_GroundAttackCombo1ReverseActive"), false);
	SetAnimBoolVar(TEXT("FSM_GroundAttackCombo1ReverseReleaseActive"), false);
	SetAnimBoolVar(TEXT("FSM_GroundAttackCombo2Active"), false);
	SetAnimBoolVar(TEXT("FSM_GroundAttackCombo2ReleaseActive"), false);
	SetAnimBoolVar(TEXT("FSM_GroundAttackCombo2ReverseActive"), false);
	SetAnimBoolVar(TEXT("FSM_GroundAttackCombo2ReverseReleaseActive"), false);
	SetAnimBoolVar(TEXT("FSM_GroundAttackCombo3Active"), false);
	SetAnimBoolVar(TEXT("FSM_GroundAttackCombo4Active"), false);
	SetAnimBoolVar(TEXT("FSM_GroundAttackCombo5Active"), false);
	SetAnimBoolVar(TEXT("FSM_NewThrowAtkFinished"), false);
	SetAnimBoolVar(TEXT("FSM_NewThrowAtkCancel"), false);
	SetAnimBoolVar(TEXT("FSM_NewThrowKillFinished"), false);

	if (EnvQuery)
	{
		EnvQuery->ThrowAnimationId = 512500;
		EnvQuery->bThrowKillRequested = false;
		EnvQuery->bThrowDeathRequested = false;
		EnvQuery->bThrowEscapeRequested = false;
		EnvQuery->bThrowActive = true;
	}

	ClearAnimBoolVarsByPrefix(TEXT("Req_W_ThrowAtk"));
	ClearAnimBoolVarsByPrefix(TEXT("Req_W_ThrowKill"));
	const bool bSetThrowId = SetAnimIntVar(TEXT("Selector_ThrowId"), 512500);
	const bool bSetThrowRequest = SetAnimBoolVar(TEXT("Req_W_ThrowAtk512500"), true);
	UE_LOG(LogTemp, Warning, TEXT("[Deathblow] AnimRequest ThrowAtk512500 SetThrowId=%d SetReq=%d"),
		bSetThrowId ? 1 : 0,
		bSetThrowRequest ? 1 : 0);
	if (UWorld* World = GetWorld())
	{
		FTimerHandle ClearThrowAtkRequestHandle;
		World->GetTimerManager().SetTimer(
			ClearThrowAtkRequestHandle,
			FTimerDelegate::CreateWeakLambda(this, [this]()
			{
				SetAnimBoolVar(TEXT("Req_W_ThrowAtk512500"), false);
			}),
			0.22f,
			false);

		TWeakObjectPtr<ASekiroEnemyCharacter> WeakEnemy = Enemy;
		FTimerHandle StartThrowKillHandle;
		World->GetTimerManager().SetTimer(
			StartThrowKillHandle,
			FTimerDelegate::CreateWeakLambda(this, [this, WeakEnemy]()
			{
				SetAnimIntVar(TEXT("Selector_ThrowId"), 512501);
				SetAnimBoolVar(TEXT("FSM_NewThrowAtkFinished"), true);
				SetAnimBoolVar(TEXT("Req_W_ThrowKill512501"), true);
				if (ASekiroEnemyCharacter* TargetEnemy = WeakEnemy.Get())
				{
					UpdateFrontDeathblowAlignment(0.0f);
					TargetEnemy->ConfirmFrontDeathblowKill(this);
				}
				if (EnvQuery)
				{
					EnvQuery->ThrowAnimationId = 512501;
					EnvQuery->bThrowKillRequested = true;
				}
				UE_LOG(LogTemp, Warning, TEXT("[Deathblow] AnimRequest ThrowKill512501 after ThrowAtk512500"));
			}),
			FMath::Max(0.01f, FrontDeathblowThrowKillStartSeconds),
			false);

		FTimerHandle ClearThrowKillRequestHandle;
		World->GetTimerManager().SetTimer(
			ClearThrowKillRequestHandle,
			FTimerDelegate::CreateWeakLambda(this, [this]()
			{
				SetAnimBoolVar(TEXT("Req_W_ThrowKill512501"), false);
				if (EnvQuery)
				{
					EnvQuery->bThrowKillRequested = false;
				}
			}),
			4.42f,
			false);

		FTimerHandle ClearThrowActiveHandle;
		World->GetTimerManager().SetTimer(
			ClearThrowActiveHandle,
			FTimerDelegate::CreateWeakLambda(this, [this]()
			{
				if (EnvQuery)
				{
					EnvQuery->bThrowActive = false;
				}
				FrontDeathblowTarget.Reset();
				FrontDeathblowAlignTimeRemaining = 0.0f;
			}),
			7.0f,
			false);
	}

	UE_LOG(LogTemp, Warning, TEXT("[Deathblow] Player=%s FrontThrowAtk512500->ThrowKill512501 Target=%s Dist=%.1f"),
		*GetName(),
		*Enemy->GetName(),
		FVector::Dist2D(GetActorLocation(), Enemy->GetActorLocation()));
	return true;
}

void ASekiroC0000PreviewCharacter::UpdateFrontDeathblowAlignment(const float DeltaSeconds)
{
	ASekiroEnemyCharacter* Enemy = FrontDeathblowTarget.Get();
	if (!Enemy || !Enemy->bDeathblowInProgress)
	{
		FrontDeathblowTarget.Reset();
		FrontDeathblowAlignTimeRemaining = 0.0f;
		return;
	}

	FrontDeathblowAlignTimeRemaining = FMath::Max(0.0f, FrontDeathblowAlignTimeRemaining - FMath::Max(0.0f, DeltaSeconds));
	if (FrontDeathblowAlignTimeRemaining <= 0.0f)
	{
		return;
	}

	FVector ToPlayer = GetActorLocation() - Enemy->GetActorLocation();
	if (ToPlayer.SizeSquared2D() <= UE_KINDA_SMALL_NUMBER)
	{
		ToPlayer = Enemy->GetActorForwardVector();
	}
	const float EnemyYaw = ToPlayer.Rotation().Yaw;
	Enemy->SetActorRotation(FRotator(0.0f, EnemyYaw, 0.0f), ETeleportType::TeleportPhysics);

	const FVector DesiredPlayerLocation = Enemy->GetActorLocation()
		+ Enemy->GetActorForwardVector().GetSafeNormal2D() * FMath::Max(0.0f, FrontDeathblowAlignDistanceCm);
	const FRotator DesiredPlayerRotation(0.0f, (Enemy->GetActorLocation() - DesiredPlayerLocation).Rotation().Yaw, 0.0f);
	SetActorLocationAndRotation(DesiredPlayerLocation, DesiredPlayerRotation, false, nullptr, ETeleportType::TeleportPhysics);
	PreviewControlYaw = DesiredPlayerRotation.Yaw;

	if (UCharacterMovementComponent* Movement = GetCharacterMovement())
	{
		Movement->StopMovementImmediately();
	}
}

void ASekiroC0000PreviewCharacter::LockPreviewAttackFaceTarget(ASekiroEnemyCharacter* Enemy, const float HoldSeconds)
{
	if (!Enemy || Enemy->bDead)
	{
		return;
	}

	PreviewAttackFaceTarget = Enemy;
	PreviewAttackFaceTimeRemaining = FMath::Max(PreviewAttackFaceTimeRemaining, HoldSeconds);
	UE_LOG(LogTemp, Warning, TEXT("[C0000Targeting] LockAttackTarget Target=%s Hold=%.2f Dist=%.1f"),
		*Enemy->GetName(),
		HoldSeconds,
		FVector::Dist2D(GetActorLocation(), Enemy->GetActorLocation()));
	FacePreviewActorTowardTarget(Enemy);
}

bool ASekiroC0000PreviewCharacter::FacePreviewActorTowardTarget(const AActor* TargetActor)
{
	if (!TargetActor)
	{
		return false;
	}

	const FVector ToTarget = TargetActor->GetActorLocation() - GetActorLocation();
	if (ToTarget.SizeSquared2D() <= UE_KINDA_SMALL_NUMBER)
	{
		return false;
	}

	const FRotator OldRotation = GetActorRotation();
	const FRotator NewRotation(0.0f, ToTarget.Rotation().Yaw, 0.0f);
	SetActorRotation(NewRotation, ETeleportType::TeleportPhysics);
	PreviewControlYaw = NewRotation.Yaw;
	UE_LOG(LogTemp, Warning, TEXT("[C0000Targeting] FaceTarget Actor=%s Target=%s Yaw %.2f -> %.2f Dist=%.1f"),
		*GetName(),
		*TargetActor->GetName(),
		OldRotation.Yaw,
		NewRotation.Yaw,
		ToTarget.Size2D());
	return true;
}

void ASekiroC0000PreviewCharacter::UpdatePreviewAttackFacing(const float DeltaSeconds)
{
	const bool bGroundAttackActive = IsGroundAttackNoTurnActive(LayeredStateMachine);
	if (!bGroundAttackActive && PreviewAttackFaceTimeRemaining <= 0.0f)
	{
		return;
	}

	PreviewAttackFaceTimeRemaining = FMath::Max(PreviewAttackFaceTimeRemaining - DeltaSeconds, 0.0f);
	ASekiroEnemyCharacter* Enemy = PreviewAttackFaceTarget.Get();
	if (!Enemy || Enemy->bDead || FVector::DistSquared2D(GetActorLocation(), Enemy->GetActorLocation()) > FMath::Square(AttackFaceTargetDistanceCm))
	{
		Enemy = bGroundAttackActive ? FindNearestVisibleEnemy(this, AttackFaceTargetDistanceCm) : nullptr;
		PreviewAttackFaceTarget = Enemy;
		if (!Enemy)
		{
			return;
		}
	}

	if (bGroundAttackActive)
	{
		PreviewAttackFaceTimeRemaining = FMath::Max(PreviewAttackFaceTimeRemaining, 0.1f);
	}

	FacePreviewActorTowardTarget(Enemy);
}

void ASekiroC0000PreviewCharacter::SetPreviewAutoAimTargetValid(const bool bValid)
{
	if (EnvQuery)
	{
		EnvQuery->bAutoAimTargetValid = bValid;
	}
}

bool ASekiroC0000PreviewCharacter::EnsurePreviewLuaBinding(const bool bForceRebind)
{
	if (bPreviewLuaBindingReady && !bForceRebind)
	{
		return true;
	}

	UnLua::FLuaEnv* LuaEnv = ResolveLuaEnv(this);
	if (!LuaEnv)
	{
		return false;
	}

#if WITH_EDITOR
	// The preview actor often survives module edits in the editor world. Force one
	// clean rebind when runtime starts so ReceiveBeginPlay/ReceiveTick stop using
	// stale closures from an older PreviewCharacter.lua chunk.
	if (bForceRebind || !bPreviewLuaBindingReady)
	{
		LuaEnv->NotifyUObjectDeleted(this, INDEX_NONE);
		bPreviewLuaBindingReady = false;
	}
#endif

	if (!LuaEnv->TryBind(this))
	{
		UE_LOG(LogTemp, Warning, TEXT("Failed to bind UnLua module for preview character %s"), *GetName());
		return false;
	}

	bPreviewLuaBindingReady = true;
	return true;
}

void ASekiroC0000PreviewCharacter::BeginPlay()
{
	EnsurePreviewLuaBinding(true);
	Super::BeginPlay();

	ApplyPreviewMovementSettings();
	PreviewControlYaw = GetActorRotation().Yaw;
	if (USkeletalMeshComponent* MeshComponent = GetMesh())
	{
		MeshComponent->SetRelativeRotation(PreviewMeshFacingRotation);
		DefaultPreviewAnimClass = MeshComponent->GetAnimClass();
	}
	AlignBackSheathedWeaponToBackCaseSockets();
	SetMortalBladeDrawn(bMortalBladeDrawn);
	SetAnimBoolVar(NTCEventActiveAnimVar, false);
	SetAnimBoolVar(NTCEventFinishedAnimVar, false);
	if (bUseSimpleMovementAnimBlueprint)
	{
		ApplySimpleMovementAnimBlueprint();
	}
	ClearPreviewQueuedEvents();
	UpdatePreviewInputStateFromController();
	RefreshPreviewMovementIntent();
	SyncEnvQueryFromPreviewInput(0.0f);
	if (LayeredStateMachine)
	{
		LayeredStateMachine->ResetLayerStates();
	}
}

void ASekiroC0000PreviewCharacter::Tick(const float DeltaSeconds)
{
	Super::Tick(DeltaSeconds);

	AlignBackSheathedWeaponToBackCaseSockets();
	UpdatePreviewInputStateFromController();
	UpdateEnemyProximityAutoDraw(DeltaSeconds);
	SyncEnvQueryFromPreviewInput(DeltaSeconds);
	UpdatePreviewAttackFacing(DeltaSeconds);
	UpdateFrontDeathblowAlignment(DeltaSeconds);
}

void ASekiroC0000PreviewCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
	Super::SetupPlayerInputComponent(PlayerInputComponent);

	if (!PlayerInputComponent)
	{
		return;
	}

	PlayerInputComponent->BindKey(EKeys::W, IE_Pressed, this, &ASekiroC0000PreviewCharacter::HandlePreviewForwardPressed);
	PlayerInputComponent->BindKey(EKeys::W, IE_Released, this, &ASekiroC0000PreviewCharacter::HandlePreviewForwardReleased);
	PlayerInputComponent->BindKey(EKeys::S, IE_Pressed, this, &ASekiroC0000PreviewCharacter::HandlePreviewBackwardPressed);
	PlayerInputComponent->BindKey(EKeys::S, IE_Released, this, &ASekiroC0000PreviewCharacter::HandlePreviewBackwardReleased);
	PlayerInputComponent->BindKey(EKeys::A, IE_Pressed, this, &ASekiroC0000PreviewCharacter::HandlePreviewLeftPressed);
	PlayerInputComponent->BindKey(EKeys::A, IE_Released, this, &ASekiroC0000PreviewCharacter::HandlePreviewLeftReleased);
	PlayerInputComponent->BindKey(EKeys::D, IE_Pressed, this, &ASekiroC0000PreviewCharacter::HandlePreviewRightPressed);
	PlayerInputComponent->BindKey(EKeys::D, IE_Released, this, &ASekiroC0000PreviewCharacter::HandlePreviewRightReleased);
	PlayerInputComponent->BindKey(EKeys::LeftShift, IE_Pressed, this, &ASekiroC0000PreviewCharacter::HandlePreviewSprintPressed);
	PlayerInputComponent->BindKey(EKeys::LeftShift, IE_Released, this, &ASekiroC0000PreviewCharacter::HandlePreviewSprintReleased);
	PlayerInputComponent->BindKey(EKeys::Q, IE_Pressed, this, &ASekiroC0000PreviewCharacter::HandlePreviewUseItemPressed);
	PlayerInputComponent->BindKey(EKeys::E, IE_Pressed, this, &ASekiroC0000PreviewCharacter::HandlePreviewSubWeaponPressed);
	PlayerInputComponent->BindKey(EKeys::R, IE_Pressed, this, &ASekiroC0000PreviewCharacter::HandlePreviewLeftWaistDrawSheathePressed);
	PlayerInputComponent->BindKey(EKeys::F, IE_Pressed, this, &ASekiroC0000PreviewCharacter::HandlePreviewReactionPressed);
	PlayerInputComponent->BindKey(EKeys::LeftMouseButton, IE_Pressed, this, &ASekiroC0000PreviewCharacter::HandlePreviewGroundAttackPressed);
	PlayerInputComponent->BindKey(EKeys::LeftMouseButton, IE_Released, this, &ASekiroC0000PreviewCharacter::HandlePreviewGroundAttackReleased);
	PlayerInputComponent->BindKey(EKeys::RightMouseButton, IE_Pressed, this, &ASekiroC0000PreviewCharacter::HandlePreviewGuardPressed);
	PlayerInputComponent->BindKey(EKeys::RightMouseButton, IE_Released, this, &ASekiroC0000PreviewCharacter::HandlePreviewGuardReleased);
	bPreviewDebugInputBound = true;
}

FString ASekiroC0000PreviewCharacter::GetModuleName_Implementation() const
{
	return TEXT("Sekiro.C0000.PreviewCharacter");
}

void ASekiroC0000PreviewCharacter::ApplyPreviewMovementSettings()
{
	bUseControllerRotationPitch = false;
	bUseControllerRotationYaw = false;
	bUseControllerRotationRoll = false;

	if (USkeletalMeshComponent* MeshComponent = GetMesh())
	{
		MeshComponent->SetRelativeRotation(PreviewMeshFacingRotation);
	}

	if (UCharacterMovementComponent* MovementComponent = GetCharacterMovement())
	{
		MovementComponent->bOrientRotationToMovement = false;
		MovementComponent->bUseControllerDesiredRotation = false;
		MovementComponent->RotationRate = FRotator::ZeroRotator;
		MovementComponent->MaxWalkSpeed = 260.0f;
		if (MovementComponent->MovementMode == MOVE_None)
		{
			MovementComponent->SetMovementMode(MOVE_Walking);
		}
	}
}

void ASekiroC0000PreviewCharacter::RefreshPreviewMovementIntent()
{
	if (bPreviewForwardPressed && bPreviewBackwardPressed)
	{
		const int32 LastPreviewForwardPress = GetLastPreviewForwardPress(this);
		PreviewForwardIntent = LastPreviewForwardPress != 0 ? LastPreviewForwardPress : -1;
	}
	else
	{
		PreviewForwardIntent = (bPreviewForwardPressed ? 1 : 0) - (bPreviewBackwardPressed ? 1 : 0);
		if (PreviewForwardIntent != 0)
		{
			SetLastPreviewForwardPress(this, PreviewForwardIntent);
		}
	}

	if (bPreviewLeftPressed && bPreviewRightPressed)
	{
		const int32 LastPreviewLateralPress = GetLastPreviewLateralPress(this);
		PreviewRightIntent = LastPreviewLateralPress != 0 ? LastPreviewLateralPress : 1;
	}
	else
	{
		PreviewRightIntent = (bPreviewRightPressed ? 1 : 0) - (bPreviewLeftPressed ? 1 : 0);
		if (PreviewRightIntent != 0)
		{
			SetLastPreviewLateralPress(this, PreviewRightIntent);
		}
	}
}

void ASekiroC0000PreviewCharacter::UpdatePreviewInputStateFromController()
{
	if (bPreviewInputOverrideActive)
	{
		bPreviewForwardPressed = PreviewOverrideForward > 0 || PreviewOverrideForward == -2;
		bPreviewBackwardPressed = PreviewOverrideForward < 0 || PreviewOverrideForward == 2;
		bPreviewLeftPressed = PreviewOverrideRight < 0;
		bPreviewRightPressed = PreviewOverrideRight > 0;
		bPreviewSprintPressed = bPreviewOverrideSprint;
		if (FMath::Abs(PreviewOverrideForward) == 2)
		{
			SetLastPreviewForwardPress(this, PreviewOverrideForward < 0 ? -1 : 1);
		}
		RefreshPreviewMovementIntent();
		return;
	}

	APlayerController* PlayerController = Cast<APlayerController>(GetController());
	if (!PlayerController)
	{
		PlayerController = GetWorld() ? GetWorld()->GetFirstPlayerController() : nullptr;
	}

	if (!PlayerController || !PlayerController->IsLocalController())
	{
		return;
	}

	PreviewControlYaw = PlayerController->GetControlRotation().Yaw;
	bPreviewForwardPressed = PlayerController->IsInputKeyDown(EKeys::W);
	bPreviewBackwardPressed = PlayerController->IsInputKeyDown(EKeys::S);
	bPreviewLeftPressed = PlayerController->IsInputKeyDown(EKeys::A);
	bPreviewRightPressed = PlayerController->IsInputKeyDown(EKeys::D);
	bPreviewSprintPressed = PlayerController->IsInputKeyDown(EKeys::LeftShift);
	RefreshPreviewMovementIntent();
}

void ASekiroC0000PreviewCharacter::SyncEnvQueryFromPreviewInput(const float DeltaSeconds)
{
	if (!EnvQuery)
	{
		return;
	}

	EnvQuery->SetMovementInputIntent(PreviewForwardIntent, PreviewRightIntent, bPreviewSprintPressed, DeltaSeconds);
}

void ASekiroC0000PreviewCharacter::HandlePreviewForwardPressed()
{
	bPreviewForwardPressed = true;
	SetLastPreviewForwardPress(this, 1);
	RefreshPreviewMovementIntent();
	SyncEnvQueryFromPreviewInput(0.0f);
}

void ASekiroC0000PreviewCharacter::HandlePreviewForwardReleased()
{
	bPreviewForwardPressed = false;
	RefreshPreviewMovementIntent();
	SyncEnvQueryFromPreviewInput(0.0f);
}

void ASekiroC0000PreviewCharacter::HandlePreviewBackwardPressed()
{
	bPreviewBackwardPressed = true;
	SetLastPreviewForwardPress(this, -1);
	RefreshPreviewMovementIntent();
	SyncEnvQueryFromPreviewInput(0.0f);
}

void ASekiroC0000PreviewCharacter::HandlePreviewBackwardReleased()
{
	bPreviewBackwardPressed = false;
	RefreshPreviewMovementIntent();
	SyncEnvQueryFromPreviewInput(0.0f);
}

void ASekiroC0000PreviewCharacter::HandlePreviewLeftPressed()
{
	bPreviewLeftPressed = true;
	SetLastPreviewLateralPress(this, -1);
	RefreshPreviewMovementIntent();
	SyncEnvQueryFromPreviewInput(0.0f);
}

void ASekiroC0000PreviewCharacter::HandlePreviewLeftReleased()
{
	bPreviewLeftPressed = false;
	RefreshPreviewMovementIntent();
	SyncEnvQueryFromPreviewInput(0.0f);
}

void ASekiroC0000PreviewCharacter::HandlePreviewRightPressed()
{
	bPreviewRightPressed = true;
	SetLastPreviewLateralPress(this, 1);
	RefreshPreviewMovementIntent();
	SyncEnvQueryFromPreviewInput(0.0f);
}

void ASekiroC0000PreviewCharacter::HandlePreviewRightReleased()
{
	bPreviewRightPressed = false;
	RefreshPreviewMovementIntent();
	SyncEnvQueryFromPreviewInput(0.0f);
}

void ASekiroC0000PreviewCharacter::HandlePreviewSprintPressed()
{
	bPreviewSprintPressed = true;
	SyncEnvQueryFromPreviewInput(0.0f);
}

void ASekiroC0000PreviewCharacter::HandlePreviewSprintReleased()
{
	bPreviewSprintPressed = false;
	SyncEnvQueryFromPreviewInput(0.0f);
}

void ASekiroC0000PreviewCharacter::HandlePreviewUseItemPressed()
{
	QueuePreviewActionEvent(TEXT("ActionItemGourdDrink"));
}

void ASekiroC0000PreviewCharacter::HandlePreviewSubWeaponPressed()
{
	QueuePreviewActionEvent(TEXT("ActionSubWeaponExpand"));
}

void ASekiroC0000PreviewCharacter::HandlePreviewLeftWaistDrawSheathePressed()
{
	QueuePreviewActionEvent(bMortalBladeDrawn ? TEXT("ActionLeftWaistSheathe") : TEXT("ActionLeftWaistDraw"));
}

void ASekiroC0000PreviewCharacter::UpdateEnemyProximityAutoDraw(const float DeltaSeconds)
{
	(void)DeltaSeconds;
	if (EnvQuery && EnvQuery->bThrowActive)
	{
		bEnemyAutoDrawQueued = false;
		bEnemyAutoSheatheQueued = false;
		return;
	}

	bEnemyAutoDrawQueued = false;
	bEnemyAutoSheatheQueued = false;
	bEnemyAutoDrawHadEnemyInRange = HasVisibleEnemyInAutoWeaponRange();
	if (EnvQuery)
	{
		SetPreviewAutoAimTargetValid(bEnemyAutoDrawHadEnemyInRange);
	}

	if (bEnemyAutoDrawHadEnemyInRange)
	{
		bEnemyAutoSheatheQueued = false;
		if (!bMortalBladeDrawn && !bEnemyAutoDrawActive)
		{
			bEnemyAutoDrawQueued = true;
			bEnemyAutoDrawActive = true;
			QueuePreviewActionEvent(TEXT("ActionLeftWaistDraw"));
		}
		return;
	}

	bEnemyAutoDrawActive = false;
	if (bMortalBladeDrawn)
	{
		bEnemyAutoSheatheQueued = true;
		QueuePreviewActionEvent(TEXT("ActionLeftWaistSheathe"));
	}
}

void ASekiroC0000PreviewCharacter::HandlePreviewReactionPressed()
{
	QueuePreviewReactionEvent(TEXT("ReactionDeflectGuard"));
}

void ASekiroC0000PreviewCharacter::HandlePreviewGroundAttackPressed()
{
	if (!bMortalBladeDrawn)
	{
		return;
	}
	if (EnvQuery && EnvQuery->bThrowActive)
	{
		return;
	}

	if (TryStartFrontDeathblow())
	{
		return;
	}

	FaceNearestVisibleEnemyForAttack();
	QueuePreviewActionEvent(TEXT("GroundAttack"));
}

void ASekiroC0000PreviewCharacter::HandlePreviewGroundAttackReleased()
{
	if (!bMortalBladeDrawn)
	{
		return;
	}
	if (EnvQuery && EnvQuery->bThrowActive)
	{
		return;
	}

	FaceNearestVisibleEnemyForAttack();
	QueuePreviewActionEvent(TEXT("GroundAttackRelease"));
}

void ASekiroC0000PreviewCharacter::HandlePreviewGuardPressed()
{
	QueuePreviewActionEvent(TEXT("DeflectGuard"));
}

void ASekiroC0000PreviewCharacter::HandlePreviewGuardReleased()
{
	QueuePreviewActionEvent(TEXT("DeflectGuardRelease"));
}

UAnimInstance* ASekiroC0000PreviewCharacter::GetSekiroAnimInstance() const
{
	const USkeletalMeshComponent* MeshComponent = GetMesh();
	return MeshComponent ? MeshComponent->GetAnimInstance() : nullptr;
}

USekiroEnvQueryComponent* ASekiroC0000PreviewCharacter::GetSekiroEnvQuery() const
{
	return EnvQuery;
}

USekiroLayeredStateMachineComponent* ASekiroC0000PreviewCharacter::GetSekiroLayeredStateMachine() const
{
	return LayeredStateMachine;
}

bool ASekiroC0000PreviewCharacter::HasAnimVariable(const FName VarName) const
{
	return FindAnimProperty<FProperty>(GetSekiroAnimInstance(), VarName) != nullptr;
}

bool ASekiroC0000PreviewCharacter::SetAnimBoolVar(const FName VarName, const bool bValue)
{
	UAnimInstance* AnimInstance = GetSekiroAnimInstance();
	FBoolProperty* Property = FindAnimProperty<FBoolProperty>(AnimInstance, VarName);
	if (!Property)
	{
		return false;
	}

	bool bFinalValue = bValue;
	if (LayeredStateMachine)
	{
		SuppressBaseQuickTurnDuringGroundAttack(LayeredStateMachine);
		if (IsGroundAttackNoTurnActive(LayeredStateMachine) && VarName == TEXT("IsTurnTwist"))
		{
			bFinalValue = false;
		}
	}

	Property->SetPropertyValue_InContainer(AnimInstance, bFinalValue);
	if (ShouldLogPreviewAnimBoolWrite(VarName))
	{
		LogPreviewAnimWrite(
			this,
			TEXT("bool"),
			VarName,
			bValue ? TEXT("true") : TEXT("false"),
			bFinalValue ? TEXT("true") : TEXT("false"));
	}
	return true;
}

bool ASekiroC0000PreviewCharacter::GetAnimBoolVar(const FName VarName) const
{
	const UAnimInstance* AnimInstance = GetSekiroAnimInstance();
	const FBoolProperty* Property = FindAnimProperty<FBoolProperty>(AnimInstance, VarName);
	return Property ? Property->GetPropertyValue_InContainer(AnimInstance) : false;
}

bool ASekiroC0000PreviewCharacter::SetAnimIntVar(const FName VarName, const int32 Value)
{
	UAnimInstance* AnimInstance = GetSekiroAnimInstance();
	FIntProperty* Property = FindAnimProperty<FIntProperty>(AnimInstance, VarName);
	if (!Property)
	{
		return false;
	}

	int32 FinalValue = Value;
	if (LayeredStateMachine)
	{
		SuppressBaseQuickTurnDuringGroundAttack(LayeredStateMachine);
		if (IsGroundAttackNoTurnActive(LayeredStateMachine) &&
			(VarName == TEXT("StateId") ||
			 VarName == TEXT("FSM_StateId") ||
			 VarName == TEXT("FSM_AnimStateId") ||
			 VarName == TEXT("MoveDirectionIndex") ||
			 VarName == TEXT("QuickTurnState") ||
			 VarName == TEXT("TurnType")))
		{
			FinalValue = 0;
		}
	}

	Property->SetPropertyValue_InContainer(AnimInstance, FinalValue);
	if (ShouldLogPreviewAnimIntWrite(VarName))
	{
		LogPreviewAnimWrite(
			this,
			TEXT("int"),
			VarName,
			FString::FromInt(Value),
			FString::FromInt(FinalValue));
	}
	return true;
}

int32 ASekiroC0000PreviewCharacter::GetAnimIntVar(const FName VarName) const
{
	const UAnimInstance* AnimInstance = GetSekiroAnimInstance();
	const FIntProperty* Property = FindAnimProperty<FIntProperty>(AnimInstance, VarName);
	return Property ? Property->GetPropertyValue_InContainer(AnimInstance) : 0;
}

bool ASekiroC0000PreviewCharacter::SetAnimFloatVar(const FName VarName, const float Value)
{
	UAnimInstance* AnimInstance = GetSekiroAnimInstance();
	FFloatProperty* Property = FindAnimProperty<FFloatProperty>(AnimInstance, VarName);
	if (!Property)
	{
		return false;
	}

	float FinalValue = Value;
	if (LayeredStateMachine)
	{
		SuppressBaseQuickTurnDuringGroundAttack(LayeredStateMachine);
		if (IsGroundAttackNoTurnActive(LayeredStateMachine) &&
			(VarName == TEXT("MoveDirection") ||
			 VarName == TEXT("MoveAngle") ||
			 VarName == TEXT("MoveLoopMotionSelectorAngle") ||
			 VarName == TEXT("MoveLoopAnimeSelectorAngle") ||
			 VarName == TEXT("MoveStartMotionSelectorAngle") ||
			 VarName == TEXT("MoveStartAnimeSelectorAngle") ||
			 VarName == TEXT("TurnAngle") ||
			 VarName == TEXT("TwistLowerRootAngle") ||
			 VarName == TEXT("TwistMasterAngle") ||
			 VarName == TEXT("TwistUpperRootAngle") ||
			 VarName == TEXT("MoveTwistAngle_Yaw") ||
			 VarName == TEXT("MoveTwistAngle_Roll")))
		{
			FinalValue = 0.0f;
		}
	}

	Property->SetPropertyValue_InContainer(AnimInstance, FinalValue);
	if (ShouldLogPreviewAnimFloatWrite(VarName))
	{
		LogPreviewAnimWrite(
			this,
			TEXT("float"),
			VarName,
			FString::Printf(TEXT("%.2f"), Value),
			FString::Printf(TEXT("%.2f"), FinalValue));
	}
	return true;
}

float ASekiroC0000PreviewCharacter::GetAnimFloatVar(const FName VarName) const
{
	const UAnimInstance* AnimInstance = GetSekiroAnimInstance();
	const FFloatProperty* Property = FindAnimProperty<FFloatProperty>(AnimInstance, VarName);
	return Property ? Property->GetPropertyValue_InContainer(AnimInstance) : 0.0f;
}

int32 ASekiroC0000PreviewCharacter::ClearAnimBoolVarsByPrefix(const FString& Prefix)
{
	UAnimInstance* AnimInstance = GetSekiroAnimInstance();
	if (!AnimInstance)
	{
		return 0;
	}

	int32 ClearedCount = 0;
	for (TFieldIterator<FBoolProperty> It(AnimInstance->GetClass(), EFieldIteratorFlags::IncludeSuper); It; ++It)
	{
		FBoolProperty* Property = *It;
		const FString PropertyName = Property->GetName();
		if (!PropertyName.StartsWith(Prefix, ESearchCase::CaseSensitive))
		{
			continue;
		}

		Property->SetPropertyValue_InContainer(AnimInstance, false);
		++ClearedCount;
	}

	return ClearedCount;
}

void ASekiroC0000PreviewCharacter::ResetSekiroTransientVars()
{
	bEnemyAutoDrawQueued = false;
	bEnemyAutoSheatheQueued = false;
	bEnemyAutoDrawHadEnemyInRange = false;
	bEnemyAutoDrawActive = false;
	EnemyAutoDrawElapsedSeconds = 0.0f;

	ClearAnimBoolVarsByPrefix(TEXT("Req_"));
	ClearAnimBoolVarsByPrefix(TEXT("Return_"));

	SetAnimIntVar(TEXT("StateStateId_StandMoveableAction"), -1);
	SetAnimIntVar(TEXT("MoveType"), 0);
	SetAnimIntVar(TEXT("StanceMoveType"), 0);
	SetAnimIntVar(TEXT("MoveSpeedIndex"), 0);
	SetAnimIntVar(TEXT("FSM_MoveStartSelectorId"), 10);
	SetAnimIntVar(TEXT("FSM_MoveStartMotionSelectorId"), 10);
	SetAnimIntVar(TEXT("FSM_MoveStartAnimeSelectorId"), 10);
	SetAnimIntVar(TEXT("NightvisionMoveSpeedIndex"), 0);
	SetAnimIntVar(TEXT("Selector_UseTransitionEffect"), 0);
	SetAnimIntVar(TEXT("Selector_UseStaterToStateTransitionEffect"), 1);
	SetAnimIntVar(TEXT("TurnType"), 0);
	SetAnimIntVar(TEXT("QuickTurnState"), 0);

	SetAnimFloatVar(TEXT("MoveSpeedLevel"), 0.0f);
	SetAnimFloatVar(TEXT("MoveSpeedLevelReal"), 0.0f);
	SetAnimFloatVar(TEXT("LocomotionWeaponBlend"), bMortalBladeDrawn ? 1.0f : 0.0f);
	SetAnimFloatVar(TEXT("MoveDirection"), 0.0f);
	SetAnimFloatVar(TEXT("MoveAngle"), 0.0f);
	SetAnimFloatVar(TEXT("TurnAngle"), 0.0f);
	SetAnimFloatVar(TEXT("TwistLowerRootAngle"), 0.0f);
	SetAnimFloatVar(TEXT("MoveStartMotionSelectorAngle"), 0.0f);
	SetAnimFloatVar(TEXT("MoveStartAnimeSelectorAngle"), 0.0f);
	SetAnimFloatVar(TEXT("TwistUpperRootAngle"), 0.0f);
	SetAnimFloatVar(TEXT("TwistMasterAngle"), 0.0f);
	SetAnimFloatVar(TEXT("MoveTwistAngle_Yaw"), 0.0f);
	SetAnimFloatVar(TEXT("MoveTwistAngle_Roll"), 0.0f);
	SetAnimBoolVar(TEXT("IsTurnTwist"), false);
	SetAnimBoolVar(NTCEventActiveAnimVar, false);
	SetAnimBoolVar(NTCEventFinishedAnimVar, false);
	SetAnimFloatVar(TEXT("StartTime_01"), 0.0f);
	SetAnimFloatVar(TEXT("StartTime_02"), 0.0f);
	SetAnimFloatVar(TEXT("StartTime_03"), 0.0f);
}

float ASekiroC0000PreviewCharacter::GetAnimSequenceLengthByPath(const FString& AssetPath) const
{
	const FString NormalizedPath = NormalizeObjectPath(AssetPath);
	if (NormalizedPath.IsEmpty())
	{
		return 0.0f;
	}

	const FSoftObjectPath SoftPath(NormalizedPath);
	UObject* LoadedObject = SoftPath.TryLoad();
	const UAnimSequenceBase* Sequence = Cast<UAnimSequenceBase>(LoadedObject);
	return Sequence ? Sequence->GetPlayLength() : 0.0f;
}

float ASekiroC0000PreviewCharacter::GetHorizontalSpeed() const
{
	const FVector Velocity = GetVelocity();
	return FVector(Velocity.X, Velocity.Y, 0.0f).Size();
}

float ASekiroC0000PreviewCharacter::GetMoveInputStrength() const
{
	FVector InputVector = GetPendingMovementInputVector();
	if (InputVector.IsNearlyZero())
	{
		InputVector = GetLastMovementInputVector();
	}

	return FMath::Clamp(InputVector.Size2D(), 0.0f, 1.0f);
}

float ASekiroC0000PreviewCharacter::GetVelocityAngleDegrees() const
{
	const FVector HorizontalVelocity(GetVelocity().X, GetVelocity().Y, 0.0f);
	return GetSignedHorizontalAngleDegrees(GetActorForwardVector(), HorizontalVelocity);
}

FVector ASekiroC0000PreviewCharacter::GetPreviewInputWorldVector() const
{
	if (PreviewForwardIntent == 0 && PreviewRightIntent == 0)
	{
		return FVector::ZeroVector;
	}

	FRotator BasisRotation(0.0f, PreviewControlYaw, 0.0f);
	APlayerController* PlayerController = Cast<APlayerController>(GetController());
	if (!PlayerController || !PlayerController->IsLocalController())
	{
		PlayerController = GetWorld() ? GetWorld()->GetFirstPlayerController() : nullptr;
	}

	if (PlayerController && PlayerController->IsLocalController())
	{
		BasisRotation = PlayerController->GetControlRotation();
	}

	BasisRotation.Pitch = 0.0f;
	BasisRotation.Roll = 0.0f;

	const FRotationMatrix BasisMatrix(BasisRotation);
	FVector InputVector =
		BasisMatrix.GetUnitAxis(EAxis::X) * static_cast<float>(PreviewForwardIntent)
		+ BasisMatrix.GetUnitAxis(EAxis::Y) * static_cast<float>(PreviewRightIntent);
	InputVector.Z = 0.0f;
	return InputVector.GetSafeNormal2D();
}

float ASekiroC0000PreviewCharacter::GetMoveInputAngleDegrees() const
{
	FVector InputVector = GetPreviewInputWorldVector();
	if (InputVector.IsNearlyZero())
	{
		InputVector = GetPendingMovementInputVector();
	}
	if (InputVector.IsNearlyZero())
	{
		InputVector = GetLastMovementInputVector();
	}

	return GetSignedHorizontalAngleDegrees(GetActorForwardVector(), InputVector);
}

void ASekiroC0000PreviewCharacter::ApplyPreviewMovementInput(const float Scale)
{
	if (FMath::IsNearlyZero(Scale))
	{
		return;
	}

	if (IsGroundAttackNoTurnActive(LayeredStateMachine))
	{
		return;
	}

	if (UCharacterMovementComponent* MovementComponent = GetCharacterMovement())
	{
		if (MovementComponent->MovementMode == MOVE_None)
		{
			MovementComponent->SetMovementMode(MOVE_Walking);
		}
	}

	const FVector InputVector = GetPreviewInputWorldVector();
	if (InputVector.IsNearlyZero())
	{
		return;
	}

	AddMovementInput(InputVector, Scale, true);
}

void ASekiroC0000PreviewCharacter::AddPreviewFacingYaw(const float DeltaYawDegrees)
{
	if (FMath::IsNearlyZero(DeltaYawDegrees))
	{
		return;
	}

	if (LayeredStateMachine)
	{
		SuppressBaseQuickTurnDuringGroundAttack(LayeredStateMachine);
		if (IsGroundAttackNoTurnActive(LayeredStateMachine))
		{
			UE_LOG(
				LogTemp,
				Warning,
				TEXT("[SekiroFSM] AddPreviewFacingYaw blocked delta=%.2f Base=%d Action=%d ActorYaw=%.2f"),
				DeltaYawDegrees,
				LayeredStateMachine->GetLayerStateId(0),
				LayeredStateMachine->GetLayerStateId(1),
				GetActorRotation().Yaw);
			return;
		}
	}

	const FRotator OldRotation = GetActorRotation();
	FRotator NewRotation = OldRotation;
	NewRotation.Yaw = FRotator::NormalizeAxis(NewRotation.Yaw + DeltaYawDegrees);
	SetActorRotation(NewRotation);
	UE_LOG(
		LogTemp,
		Warning,
		TEXT("[SekiroFSM] AddPreviewFacingYaw applied delta=%.2f yaw %.2f -> %.2f Base=%d Action=%d"),
		DeltaYawDegrees,
		OldRotation.Yaw,
		NewRotation.Yaw,
		LayeredStateMachine ? LayeredStateMachine->GetLayerStateId(0) : INDEX_NONE,
		LayeredStateMachine ? LayeredStateMachine->GetLayerStateId(1) : INDEX_NONE);
}

bool ASekiroC0000PreviewCharacter::HandleSekiroMovementAnimEvent(
	const FName EventName,
	const bool bActive,
	const float NumericValue,
	const FString& SourceArguments,
	const int32 TaeType,
	const int32 BehaviorJudgeID)
{
	if (EventName == TEXT("TAE_1"))
	{
		HandlePreviewInvokeAttackBehavior(this, bActive, TaeType, BehaviorJudgeID, SourceArguments);
	}

	if (bActive && EventName == TEXT("TAE_32"))
	{
		float WeaponStyle = 0.0f;
		if (ExtractTaeParamFloat(SourceArguments, TEXT("WeaponStyle"), WeaponStyle))
		{
			SetMortalBladeDrawn(WeaponStyle >= 1.0f);
		}
	}
	else if (EventName == TEXT("TAE_715"))
	{
		float WeaponModelType = 0.0f;
		if (ExtractTaeParamFloat(SourceArguments, TEXT("WeaponModelType"), WeaponModelType) && FMath::IsNearlyZero(WeaponModelType))
		{
			if (bActive)
			{
				SetMortalBladeRightHandVisible(true);
			}
			else if (!bMortalBladeDrawn)
			{
				SetMortalBladeRightHandVisible(false);
			}
		}
	}

	if (!EnsurePreviewLuaBinding(false))
	{
		return false;
	}

	return CallBoundLuaMovementAnimEvent(
		this,
		"OnSekiroMovementAnimEvent",
		EventName,
		bActive,
		NumericValue,
		SourceArguments);
}

bool ASekiroC0000PreviewCharacter::HandleSekiroAct(const int32 ActId, const FString& Args)
{
	switch (ActId)
	{
	case 101:
		return true;
	case 9100:
	case 9101:
		ClearPreviewQueuedEvents();
		return true;
	default:
		UE_LOG(
			LogTemp,
			Verbose,
			TEXT("Unhandled Sekiro act(%d, %s) on %s"),
			ActId,
			*Args,
			*GetName());
		return false;
	}
}

int32 ASekiroC0000PreviewCharacter::GetPreviewForwardIntent() const
{
	return PreviewForwardIntent;
}

int32 ASekiroC0000PreviewCharacter::GetPreviewRightIntent() const
{
	return PreviewRightIntent;
}

bool ASekiroC0000PreviewCharacter::IsPreviewSprintHeld() const
{
	return bPreviewSprintPressed;
}

int32 ASekiroC0000PreviewCharacter::GetPreviewDominantMoveDirection() const
{
	if (PreviewForwardIntent == 0 && PreviewRightIntent == 0)
	{
		return -1;
	}

	if (FMath::Abs(PreviewForwardIntent) >= FMath::Abs(PreviewRightIntent) && PreviewForwardIntent != 0)
	{
		return PreviewForwardIntent > 0 ? 0 : 1;
	}

	return PreviewRightIntent < 0 ? 2 : 3;
}

void ASekiroC0000PreviewCharacter::SetPreviewInputOverride(const int32 Forward, const int32 Right, const bool bSprintHeld)
{
	PreviewOverrideForward = FMath::Clamp(Forward, -2, 2);
	PreviewOverrideRight = FMath::Clamp(Right, -1, 1);
	bPreviewOverrideSprint = bSprintHeld;
	bPreviewInputOverrideActive = true;
	UpdatePreviewInputStateFromController();
	SyncEnvQueryFromPreviewInput(0.0f);
}

void ASekiroC0000PreviewCharacter::ClearPreviewInputOverride()
{
	PreviewOverrideForward = 0;
	PreviewOverrideRight = 0;
	bPreviewOverrideSprint = false;
	bPreviewInputOverrideActive = false;

	bPreviewForwardPressed = false;
	bPreviewBackwardPressed = false;
	bPreviewLeftPressed = false;
	bPreviewRightPressed = false;
	bPreviewSprintPressed = false;
	RefreshPreviewMovementIntent();
	SyncEnvQueryFromPreviewInput(0.0f);
}

void ASekiroC0000PreviewCharacter::QueuePreviewActionEvent(const FString& EventName)
{
	if (EnvQuery && EnvQuery->bThrowActive)
	{
		return;
	}

	if (!EventName.IsEmpty())
	{
		QueuedPreviewActionEventNames.Add(EventName);
	}
	QueuedPreviewActionEventName = QueuedPreviewActionEventNames.Num() > 0
		? QueuedPreviewActionEventNames[0]
		: FString();
	PreviewDebugQueuedActionEventName = QueuedPreviewActionEventName;
}

FString ASekiroC0000PreviewCharacter::ConsumePreviewActionEvent()
{
	FString Result;
	if (QueuedPreviewActionEventNames.Num() > 0)
	{
		Result = QueuedPreviewActionEventNames[0];
		QueuedPreviewActionEventNames.RemoveAt(0);
	}

	QueuedPreviewActionEventName = QueuedPreviewActionEventNames.Num() > 0
		? QueuedPreviewActionEventNames[0]
		: FString();
	PreviewDebugQueuedActionEventName = QueuedPreviewActionEventName;
	return Result;
}

void ASekiroC0000PreviewCharacter::QueuePreviewReactionEvent(const FString& EventName)
{
	QueuedPreviewReactionEventName = EventName;
	PreviewDebugQueuedReactionEventName = EventName;
}

FString ASekiroC0000PreviewCharacter::ConsumePreviewReactionEvent()
{
	const FString Result = QueuedPreviewReactionEventName;
	QueuedPreviewReactionEventName.Reset();
	PreviewDebugQueuedReactionEventName.Reset();
	return Result;
}

void ASekiroC0000PreviewCharacter::ClearPreviewQueuedEvents()
{
	QueuedPreviewActionEventName.Reset();
	QueuedPreviewActionEventNames.Reset();
	QueuedPreviewReactionEventName.Reset();
	PreviewDebugQueuedActionEventName.Reset();
	PreviewDebugQueuedReactionEventName.Reset();
}

bool ASekiroC0000PreviewCharacter::StepPreviewRuntime(const float DeltaSeconds)
{
	if (!EnsurePreviewLuaBinding(false))
	{
		return false;
	}

	UpdateEnemyProximityAutoDraw(DeltaSeconds);

	const bool bTickSucceeded = CallBoundLuaTickMethod(this, "ReceiveTick", DeltaSeconds);
	if (!bTickSucceeded)
	{
		return false;
	}

	FVector PendingInput = ConsumeMovementInputVector().GetClampedToMaxSize(1.0f);
	if (PendingInput.IsNearlyZero())
	{
		PendingInput = GetPreviewInputWorldVector().GetClampedToMaxSize(1.0f);
	}

	if (!PendingInput.IsNearlyZero())
	{
		const UCharacterMovementComponent* MovementComponent = GetCharacterMovement();
		const float MaxSpeed = FMath::Max(MovementComponent ? MovementComponent->MaxWalkSpeed : 0.0f, 260.0f);
		const FVector Delta = PendingInput * FMath::Max(MaxSpeed, 0.0f) * FMath::Max(DeltaSeconds, 0.0f);
		if (!Delta.IsNearlyZero())
		{
			SetActorLocation(GetActorLocation() + Delta, false);
		}
	}

	return true;
}

bool ASekiroC0000PreviewCharacter::TriggerPreviewSekiroEvent(const FString& EventName)
{
	if (!EnsurePreviewLuaBinding(false))
	{
		return false;
	}

	bool bLuaReturnValue = false;
	if (!CallBoundLuaBoolMethod(this, "TriggerSekiroEvent", EventName, bLuaReturnValue))
	{
		return false;
	}

	return bLuaReturnValue;
}

void ASekiroC0000PreviewCharacter::SetPreviewDebugInput(const int32 Forward, const int32 Right, const bool bSprint)
{
	PreviewDebugInputForward = Forward;
	PreviewDebugInputRight = Right;
	bPreviewDebugSprintHeld = bSprint;
}

void ASekiroC0000PreviewCharacter::SetPreviewDebugLastEvent(const FString& EventName, const float EventTimeSeconds)
{
	PreviewDebugLastEventName = EventName;
	PreviewDebugLastEventTimeSeconds = EventTimeSeconds;
}

FString ASekiroC0000PreviewCharacter::GetCurrentLocomotionRuntimeAnimDebug() const
{
	const UAnimInstance* AnimInstance = GetSekiroAnimInstance();
	if (!AnimInstance)
	{
		return TEXT("RuntimeAnim=none(no AnimInstance)");
	}

	const IAnimClassInterface* AnimClassInterface = IAnimClassInterface::GetFromClass(AnimInstance->GetClass());
	if (!AnimClassInterface)
	{
		return FString::Printf(TEXT("RuntimeAnim=none(class=%s)"), *GetNameSafe(AnimInstance->GetClass()));
	}

	const float MoveAngle = GetAnimFloatVar(TEXT("MoveAngle"));
	const float WeaponBlend = GetAnimFloatVar(TEXT("LocomotionWeaponBlend"));
	const FVector BlendInput(MoveAngle, WeaponBlend, 0.0f);

	TArray<FString> PlayerDebugLines;
	auto AppendAssetPlayerDebug = [this, &PlayerDebugLines](
		const FString& PlayerLabel,
		const FAnimNode_AssetPlayerBase* Player,
		const FVector& PlayerBlendInput)
	{
		if (!Player)
		{
			return;
		}

		UAnimationAsset* Asset = Player->GetAnimAsset();
		const float Weight = Player->GetCachedBlendWeight();
		if (!Asset || Weight <= 0.001f)
		{
			return;
		}

		FString PlayerDebug = FString::Printf(
			TEXT("%s=%s w=%.2f"),
			*PlayerLabel,
			*GetNameSafe(Asset),
			Weight);

		if (const UBlendSpace* BlendSpace = Cast<UBlendSpace>(Asset))
		{
			AppendBlendSpaceSampleDebug(PlayerDebug, BlendSpace, PlayerBlendInput);
		}

		PlayerDebugLines.Add(PlayerDebug);
	};

	const TMap<FName, FGraphAssetPlayerInformation>& GraphInfoMap = AnimClassInterface->GetGraphAssetPlayerInformation();
	for (const TPair<FName, FGraphAssetPlayerInformation>& GraphInfoPair : GraphInfoMap)
	{
		const FName GraphName = GraphInfoPair.Key;
		TArray<const FAnimNode_AssetPlayerBase*> AssetPlayers = AnimInstance->GetInstanceAssetPlayers(GraphName);
		for (int32 PlayerIndex = 0; PlayerIndex < AssetPlayers.Num(); ++PlayerIndex)
		{
			AppendAssetPlayerDebug(
				FString::Printf(
					TEXT("%s[%d]"),
					*GraphName.ToString(),
					PlayerIndex),
				AssetPlayers[PlayerIndex],
				BlendInput);
		}
	}

	const TArray<FStructProperty*>& AnimNodeProperties = AnimClassInterface->GetAnimNodeProperties();
	for (const FStructProperty* AnimNodeProperty : AnimNodeProperties)
	{
		if (!AnimNodeProperty || !AnimNodeProperty->Struct
			|| !AnimNodeProperty->Struct->IsChildOf(FAnimNode_AssetPlayerBase::StaticStruct()))
		{
			continue;
		}

		FVector PlayerBlendInput = BlendInput;
		if (AnimNodeProperty->Struct->IsChildOf(FAnimNode_BlendSpacePlayerBase::StaticStruct()))
		{
			if (const FAnimNode_BlendSpacePlayerBase* BlendSpacePlayer =
				AnimNodeProperty->ContainerPtrToValuePtr<FAnimNode_BlendSpacePlayerBase>(AnimInstance))
			{
				PlayerBlendInput = BlendSpacePlayer->GetPosition();
			}
		}

		const FAnimNode_AssetPlayerBase* Player =
			AnimNodeProperty->ContainerPtrToValuePtr<FAnimNode_AssetPlayerBase>(AnimInstance);
		AppendAssetPlayerDebug(
			FString::Printf(
				TEXT("%s(pos=%.2f,%.2f)"),
				*AnimNodeProperty->GetName(),
				PlayerBlendInput.X,
				PlayerBlendInput.Y),
			Player,
			PlayerBlendInput);
	}

	if (PlayerDebugLines.IsEmpty())
	{
		TArray<FString> GraphNames;
		for (const TPair<FName, FGraphAssetPlayerInformation>& GraphInfoPair : GraphInfoMap)
		{
			GraphNames.Add(GraphInfoPair.Key.ToString());
		}

		return FString::Printf(
			TEXT("RuntimeAnim=none(active player not found; class=%s graphs=%s anim_nodes=%d)"),
			*GetNameSafe(AnimInstance->GetClass()),
			GraphNames.IsEmpty() ? TEXT("none") : *FString::Join(GraphNames, TEXT(",")),
			AnimNodeProperties.Num());
	}

	return FString::Printf(
		TEXT("RuntimeAnim=%s Input(MoveAngle=%.1f,DrawBlend=%.2f)"),
		*FString::Join(PlayerDebugLines, TEXT(" | ")),
		MoveAngle,
		WeaponBlend);
}

bool ASekiroC0000PreviewCharacter::PlayPreviewSequenceByPath(const FString& AssetPath, const bool bLooping, const float PlayRate)
{
	USkeletalMeshComponent* MeshComponent = GetMesh();
	if (!MeshComponent)
	{
		return false;
	}

	const FString NormalizedPath = NormalizeObjectPath(AssetPath);
	if (NormalizedPath.IsEmpty())
	{
		return false;
	}

	const FSoftObjectPath SoftPath(NormalizedPath);
	UAnimationAsset* AnimationAsset = Cast<UAnimationAsset>(SoftPath.TryLoad());
	if (!AnimationAsset)
	{
		return false;
	}

	if (!DefaultPreviewAnimClass)
	{
		DefaultPreviewAnimClass = MeshComponent->GetAnimClass();
	}

	MeshComponent->SetAnimationMode(EAnimationMode::AnimationSingleNode);
	MeshComponent->PlayAnimation(AnimationAsset, bLooping);
	MeshComponent->SetPlayRate(FMath::Max(PlayRate, KINDA_SMALL_NUMBER));
	return true;
}

void ASekiroC0000PreviewCharacter::RestorePreviewAnimBlueprint()
{
	USkeletalMeshComponent* MeshComponent = GetMesh();
	if (!MeshComponent)
	{
		return;
	}

	if (DefaultPreviewAnimClass)
	{
		MeshComponent->SetAnimInstanceClass(DefaultPreviewAnimClass);
	}
	MeshComponent->SetAnimationMode(EAnimationMode::AnimationBlueprint, true);
}

void ASekiroC0000PreviewCharacter::SetPreviewMoveSpeed(const float MaxWalkSpeed)
{
	if (UCharacterMovementComponent* MovementComponent = GetCharacterMovement())
	{
		MovementComponent->MaxWalkSpeed = FMath::Max(MaxWalkSpeed, 0.0f);
	}
}

bool ASekiroC0000PreviewCharacter::ApplySimpleMovementAnimBlueprint()
{
	USkeletalMeshComponent* MeshComponent = GetMesh();
	if (!MeshComponent || SimpleMovementAnimClass.IsNull())
	{
		return false;
	}

	UClass* LoadedClass = SimpleMovementAnimClass.LoadSynchronous();
	if (!LoadedClass)
	{
		return false;
	}

	MeshComponent->SetAnimInstanceClass(LoadedClass);
	MeshComponent->SetAnimationMode(EAnimationMode::AnimationBlueprint, true);
	DefaultPreviewAnimClass = LoadedClass;
	PreloadSimpleMovementAnimationAssets();
	return true;
}

void ASekiroC0000PreviewCharacter::PreloadSimpleMovementAnimationAssets()
{
	static const TCHAR* MovementAssetPaths[] = {
		TEXT("/Game/Animation/Sekiro/C0000/Blueprints/BS_StandMoveStart_DrawSelector.BS_StandMoveStart_DrawSelector"),
		TEXT("/Game/Animation/Sekiro/C0000/Blueprints/BS_StandMoveLoop_DrawSelector.BS_StandMoveLoop_DrawSelector"),
		TEXT("/Game/Animation/Sekiro/C0000/StandMove_SM/a010_000400.a010_000400"),
		TEXT("/Game/Animation/Sekiro/C0000/StandMove_SM/a010_000500.a010_000500"),
		TEXT("/Game/Animation/Sekiro/C0000/StandMove_SM/a000_000400.a000_000400"),
		TEXT("/Game/Animation/Sekiro/C0000/StandMove_SM/a000_000401.a000_000401"),
		TEXT("/Game/Animation/Sekiro/C0000/StandMove_SM/a000_000402.a000_000402"),
		TEXT("/Game/Animation/Sekiro/C0000/StandMove_SM/a000_000403.a000_000403"),
		TEXT("/Game/Animation/Sekiro/C0000/StandMove_SM/a000_000500.a000_000500"),
		TEXT("/Game/Animation/Sekiro/C0000/StandMove_SM/a000_000501.a000_000501"),
		TEXT("/Game/Animation/Sekiro/C0000/StandMove_SM/a000_000502.a000_000502"),
		TEXT("/Game/Animation/Sekiro/C0000/StandMove_SM/a000_000503.a000_000503"),
	};

	PreloadedMovementAnimationAssets.Reset();
	for (const TCHAR* AssetPath : MovementAssetPaths)
	{
		if (UAnimationAsset* AnimationAsset = Cast<UAnimationAsset>(FSoftObjectPath(AssetPath).TryLoad()))
		{
			if (UBlendSpace* BlendSpace = Cast<UBlendSpace>(AnimationAsset))
			{
				BlendSpace->ValidateSampleData();
				BlendSpace->ResampleData();
			}
			PreloadedMovementAnimationAssets.Add(AnimationAsset);
		}
	}

	USkeletalMeshComponent* MeshComponent = GetMesh();
	UAnimInstance* AnimInstance = MeshComponent ? MeshComponent->GetAnimInstance() : nullptr;
	if (!MeshComponent || !AnimInstance)
	{
		return;
	}

	const int32 SavedAnimStateId = GetAnimIntVar(TEXT("FSM_AnimStateId"));
	const float SavedMoveAngle = GetAnimFloatVar(TEXT("MoveAngle"));
	const float SavedMoveSpeedLevel = GetAnimFloatVar(TEXT("MoveSpeedLevel"));
	const float SavedMoveSpeedLevelReal = GetAnimFloatVar(TEXT("MoveSpeedLevelReal"));
	const float SavedLocomotionWeaponBlend = GetAnimFloatVar(TEXT("LocomotionWeaponBlend"));

	SetAnimIntVar(TEXT("FSM_AnimStateId"), 20);
	SetAnimFloatVar(TEXT("MoveAngle"), 0.0f);
	SetAnimFloatVar(TEXT("MoveSpeedLevel"), 1.0f);
	SetAnimFloatVar(TEXT("MoveSpeedLevelReal"), 1.0f);
	SetAnimFloatVar(TEXT("LocomotionWeaponBlend"), 1.0f);
	MeshComponent->TickAnimation(1.0f / 60.0f, false);

	SetAnimIntVar(TEXT("FSM_AnimStateId"), SavedAnimStateId);
	SetAnimFloatVar(TEXT("MoveAngle"), SavedMoveAngle);
	SetAnimFloatVar(TEXT("MoveSpeedLevel"), SavedMoveSpeedLevel);
	SetAnimFloatVar(TEXT("MoveSpeedLevelReal"), SavedMoveSpeedLevelReal);
	SetAnimFloatVar(TEXT("LocomotionWeaponBlend"), SavedLocomotionWeaponBlend);
	MeshComponent->TickAnimation(0.0f, false);
}

bool ASekiroC0000PreviewCharacter::IsUsingPreviewAnimationAsset() const
{
	const USkeletalMeshComponent* MeshComponent = GetMesh();
	return MeshComponent && MeshComponent->GetAnimationMode() == EAnimationMode::AnimationSingleNode;
}
