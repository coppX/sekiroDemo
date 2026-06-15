#include "SekiroEnemyCharacter.h"

#include "SekiroC0000PreviewCharacter.h"
#include "SekiroEnemyAIController.h"
#include "SekiroEnemyAnimBridgeComponent.h"
#include "SekiroEnemyScriptBrainComponent.h"
#include "Components/CapsuleComponent.h"
#include "Components/SkeletalMeshComponent.h"
#include "GameFramework/CharacterMovementComponent.h"
#include "UObject/ConstructorHelpers.h"

namespace
{
	struct FSekiroAttackCollisionConfig
	{
		int32 AtkParamID = INDEX_NONE;
		int32 AttackDummyPolyID = INDEX_NONE;
		int32 HitIndex = 0;
		int32 DmyPoly1 = INDEX_NONE;
		int32 DmyPoly2 = INDEX_NONE;
		float RadiusCm = 5.0f;
		float Damage = 0.0f;
		FName AttachBoneName = NAME_None;
		FVector LocalLocation = FVector::ZeroVector;
		FVector LocalForward = FVector::ForwardVector;
		FVector LocalUp = FVector::UpVector;
		float LengthCm = 90.0f;
	};

	bool ExtractTaeParamInt(const FString& SourceArguments, const FString& ParamName, int32& OutValue)
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
			if (Key.Equals(ParamName, ESearchCase::IgnoreCase) && Value.IsNumeric())
			{
				OutValue = FCString::Atoi(*Value);
				return true;
			}
		}
		return false;
	}

	bool ResolveAttackCollisionConfig(const ASekiroEnemyCharacter* EnemyCharacter, const int32 BehaviorJudgeID, FSekiroAttackCollisionConfig& OutConfig)
	{
		if (BehaviorJudgeID == 100)
		{
			OutConfig.AtkParamID = 10100100;
			OutConfig.AttackDummyPolyID = 10100100;
			OutConfig.HitIndex = 0;
			OutConfig.DmyPoly1 = INDEX_NONE;
			OutConfig.DmyPoly2 = INDEX_NONE;
			OutConfig.RadiusCm = 20.0f;
			OutConfig.Damage = 80.0f;
			OutConfig.AttachBoneName = TEXT("Wakizashi");
			OutConfig.LocalLocation = FVector::ZeroVector;
			OutConfig.LocalForward = FVector(1.0f, 0.0f, 0.0f);
			OutConfig.LocalUp = FVector(0.0f, 0.0f, 1.0f);
			OutConfig.LengthCm = 90.0f;
			return true;
		}

		OutConfig.AttachBoneName = TEXT("Kodachi");
		OutConfig.RadiusCm = 5.0f;
			OutConfig.LocalLocation = FVector::ZeroVector;
		OutConfig.LocalForward = FVector(0.0f, 1.0f, 0.0f);
		OutConfig.LocalUp = FVector::UpVector;
		OutConfig.LengthCm = 48.0f;
		return true;
	}

	FRotator MakeAttackDummyPolyRotation(const FSekiroAttackCollisionConfig& Config)
	{
		const FVector CapsuleAxis = Config.LocalForward.GetSafeNormal(UE_SMALL_NUMBER, FVector::ForwardVector);
		const FVector UpAxis = Config.LocalUp.GetSafeNormal(UE_SMALL_NUMBER, FVector::UpVector);
		return FRotationMatrix::MakeFromZX(CapsuleAxis, UpAxis).Rotator();
	}

	FName MakeAttackID(const FSekiroAttackCollisionConfig& Config)
	{
		const int32 AttackID = Config.AtkParamID != INDEX_NONE ? Config.AtkParamID : Config.AttackDummyPolyID;
		return AttackID != INDEX_NONE
			? FName(*FString::Printf(TEXT("ATK%d"), AttackID))
			: NAME_None;
	}

	FName MakeAttackCollisionComponentName(const FName AttackID)
	{
		return FName(*FString::Printf(TEXT("AttackCollision_%s"), *AttackID.ToString()));
	}

	USkeletalMeshComponent* ResolveAttackCollisionAttachComponent(ASekiroEnemyCharacter* EnemyCharacter, const FName BoneName)
	{
		if (!EnemyCharacter)
		{
			return nullptr;
		}

		USkeletalMeshComponent* BodyMesh = EnemyCharacter->GetMesh();
		if (BodyMesh && BodyMesh->DoesSocketExist(BoneName))
		{
			return BodyMesh;
		}

		return EnemyCharacter->WeaponSet && EnemyCharacter->WeaponSet->DoesSocketExist(BoneName)
			? EnemyCharacter->WeaponSet
			: nullptr;
	}

	UCapsuleComponent* FindAttackCollision(ASekiroEnemyCharacter* EnemyCharacter, const FName AttackID)
	{
		if (!EnemyCharacter || AttackID.IsNone())
		{
			return nullptr;
		}

		TArray<UCapsuleComponent*> CapsuleComponents;
		EnemyCharacter->GetComponents<UCapsuleComponent>(CapsuleComponents);
		const FName ComponentName = MakeAttackCollisionComponentName(AttackID);
		for (UCapsuleComponent* CapsuleComponent : CapsuleComponents)
		{
			if (CapsuleComponent && CapsuleComponent->GetFName() == ComponentName)
			{
				return CapsuleComponent;
			}
		}

		return nullptr;
	}

	void DestroyAttackCollision(ASekiroEnemyCharacter* EnemyCharacter, const FName AttackID)
	{
		if (UCapsuleComponent* Collision = FindAttackCollision(EnemyCharacter, AttackID))
		{
			Collision->SetCollisionEnabled(ECollisionEnabled::NoCollision);
			Collision->SetGenerateOverlapEvents(false);
			Collision->DestroyComponent();
		}
	}

	UCapsuleComponent* CreateAttackCollision(ASekiroEnemyCharacter* EnemyCharacter, const FName AttackID, const FSekiroAttackCollisionConfig& Config)
	{
		if (!EnemyCharacter || AttackID.IsNone())
		{
			return nullptr;
		}

		DestroyAttackCollision(EnemyCharacter, AttackID);

		UCapsuleComponent* Collision = NewObject<UCapsuleComponent>(
			EnemyCharacter,
			UCapsuleComponent::StaticClass(),
			MakeAttackCollisionComponentName(AttackID));
		if (!Collision)
		{
			return nullptr;
		}

		EnemyCharacter->AddInstanceComponent(Collision);
		Collision->SetCapsuleSize(Config.RadiusCm, Config.RadiusCm);
		Collision->SetCollisionObjectType(ECC_WorldDynamic);
		Collision->SetCollisionResponseToAllChannels(ECR_Ignore);
		Collision->SetCollisionResponseToChannel(ECC_Pawn, ECR_Overlap);
		Collision->SetCanEverAffectNavigation(false);
		Collision->SetMobility(EComponentMobility::Movable);
		Collision->SetRelativeTransform(FTransform::Identity);
		Collision->SetHiddenInGame(true);
		Collision->SetVisibility(false);
		Collision->SetGenerateOverlapEvents(false);
		Collision->SetCollisionEnabled(ECollisionEnabled::NoCollision);
		Collision->ComponentTags.AddUnique(AttackID);
		Collision->ComponentTags.AddUnique(TEXT("InvokeAttackBehavior"));
		Collision->ComponentTags.AddUnique(FName(*FString::Printf(TEXT("AtkParam:%d"), Config.AtkParamID)));
		Collision->ComponentTags.AddUnique(FName(*FString::Printf(TEXT("AttackDummyPoly:%d"), Config.AttackDummyPolyID)));
		Collision->ComponentTags.AddUnique(FName(*FString::Printf(TEXT("Damage:%.0f"), Config.Damage)));
		Collision->RegisterComponent();

		return Collision;
	}

	void BeginAttackCollision(ASekiroEnemyCharacter* EnemyCharacter, const FName AttackID)
	{
		FSekiroAttackCollisionConfig Config;
		if (!ResolveAttackCollisionConfig(EnemyCharacter, EnemyCharacter ? EnemyCharacter->ActiveEnemyAttackBehaviorJudgeID : INDEX_NONE, Config))
		{
			return;
		}

		UCapsuleComponent* Collision = CreateAttackCollision(EnemyCharacter, AttackID, Config);
		if (!EnemyCharacter || !Collision)
		{
			return;
		}

		const FName BoneName = Config.AttachBoneName;
		USkeletalMeshComponent* AttachComponent = ResolveAttackCollisionAttachComponent(EnemyCharacter, BoneName);
		if (!AttachComponent)
		{
			Collision->DestroyComponent();
			return;
		}

		Collision->AttachToComponent(
			AttachComponent,
			FAttachmentTransformRules::SnapToTargetNotIncludingScale,
			AttachComponent->DoesSocketExist(AttackID) ? AttackID : BoneName);
		const float HalfHeight = FMath::Max(Config.RadiusCm, Config.LengthCm * 0.5f + Config.RadiusCm);
		Collision->SetCapsuleSize(Config.RadiusCm, HalfHeight);
		if (AttachComponent->DoesSocketExist(AttackID))
		{
			Collision->SetRelativeLocationAndRotation(FVector::ZeroVector, FRotator::ZeroRotator);
		}
		else
		{
			const FVector CapsuleAxis = Config.LocalForward.GetSafeNormal(UE_SMALL_NUMBER, FVector::ForwardVector);
			const FVector CapsuleCenter = Config.LocalLocation + CapsuleAxis * (Config.LengthCm * 0.5f);
			Collision->SetRelativeLocationAndRotation(CapsuleCenter, MakeAttackDummyPolyRotation(Config));
		}
		Collision->UpdateComponentToWorld();
		Collision->SetCollisionEnabled(ECollisionEnabled::QueryOnly);
		Collision->SetGenerateOverlapEvents(true);
		Collision->SetVisibility(true);
		Collision->SetHiddenInGame(false);
	}
}

ASekiroEnemyCharacter::ASekiroEnemyCharacter()
{
	AutoPossessAI = EAutoPossessAI::PlacedInWorldOrSpawned;
	AIControllerClass = ASekiroEnemyAIController::StaticClass();
	Tags.AddUnique(TEXT("Enemy"));

	EnemyAnimBridge = CreateDefaultSubobject<USekiroEnemyAnimBridgeComponent>(TEXT("EnemyAnimBridge"));
	EnemyScriptBrain = CreateDefaultSubobject<USekiroEnemyScriptBrainComponent>(TEXT("EnemyScriptBrain"));

	WeaponSet = CreateDefaultSubobject<USkeletalMeshComponent>(TEXT("Weapon_Set"));
	WeaponSet->SetupAttachment(GetMesh());
	WeaponSet->SetCollisionEnabled(ECollisionEnabled::NoCollision);
	WeaponSet->SetGenerateOverlapEvents(false);
	WeaponSet->SetRelativeTransform(FTransform::Identity);
	WeaponSet->SetVisibility(true, true);
	WeaponSet->SetHiddenInGame(false, true);

	static ConstructorHelpers::FObjectFinder<USkeletalMesh> WeaponSetMesh(
		TEXT("/Game/Animation/Sekiro/Enemy/C1010/Base/c1010_bindpose.c1010_bindpose"));
	if (WeaponSetMesh.Succeeded())
	{
		WeaponSet->SetSkeletalMesh(WeaponSetMesh.Object);
	}

	if (UCharacterMovementComponent* Movement = GetCharacterMovement())
	{
		Movement->bRunPhysicsWithNoController = true;
		Movement->MaxWalkSpeed = 300.0f;
	}
}

void ASekiroEnemyCharacter::BeginPlay()
{
	Super::BeginPlay();
	Tags.AddUnique(TEXT("Enemy"));
	CurrentHealth = FMath::Max(1.0f, MaxHealth);
	bDead = false;
	bDeathblowInProgress = false;

	if (!GetController())
	{
		SpawnDefaultController();
	}

	if (UCharacterMovementComponent* Movement = GetCharacterMovement())
	{
		Movement->bRunPhysicsWithNoController = true;
		if (Movement->MovementMode == MOVE_None)
		{
			Movement->SetMovementMode(MOVE_Walking);
		}
	}
	RefreshEnemyWeaponAttachment();
	SetEnemyWeaponStyle(SelectedEnemyWeaponStyle);
}

void ASekiroEnemyCharacter::ApplyPlayerAttackHit(const float Damage, const FName AttackID, AActor* InstigatorActor)
{
	if (bDead || bDeathblowInProgress || Damage <= 0.0f)
	{
		return;
	}

	CurrentHealth = FMath::Max(0.0f, CurrentHealth - Damage);
	if (EnemyScriptBrain && InstigatorActor)
	{
		EnemyScriptBrain->NotifyAttackedBy(InstigatorActor);
	}
	UE_LOG(LogTemp, Log, TEXT("Enemy %s hit by %s damage=%.1f health=%.1f"),
		*GetName(),
		*AttackID.ToString(),
		Damage,
		CurrentHealth);

	FSekiroEnemyAnimCommand Command;
	Command.StateId = 0;
	Command.EventName = AttackID;
	Command.bCanBeInterrupted = true;

	if (CurrentHealth <= 0.0f)
	{
		if (ASekiroC0000PreviewCharacter* PreviewCharacter = Cast<ASekiroC0000PreviewCharacter>(InstigatorActor))
		{
			if (PreviewCharacter->StartFrontDeathblowOnEnemy(this))
			{
				return;
			}
		}

		bDead = true;
		Command.Type = ESekiroEnemyAnimCommandType::Death;
		if (UCharacterMovementComponent* Movement = GetCharacterMovement())
		{
			Movement->StopMovementImmediately();
			Movement->DisableMovement();
		}
	}
	else
	{
		const FVector ToInstigator = InstigatorActor
			? (InstigatorActor->GetActorLocation() - GetActorLocation()).GetSafeNormal2D()
			: GetActorForwardVector();
		const bool bHitFromBack = FVector::DotProduct(GetActorForwardVector(), ToInstigator) < 0.0f;
		const bool bBlowDamage = Damage >= 45.0f;

		Command.Type = ESekiroEnemyAnimCommandType::Damage;
		Command.StateId = bBlowDamage
			? (bHitFromBack ? 8121 : 8120)
			: (bHitFromBack ? 8051 : 8050);
		Command.ExpectedDuration = bBlowDamage ? 1.2f : 0.75f;
		if (UCharacterMovementComponent* Movement = GetCharacterMovement())
		{
			Movement->StopMovementImmediately();
		}
	}

	if (EnemyAnimBridge)
	{
		EnemyAnimBridge->SendAnimCommand(Command);
	}
}

bool ASekiroEnemyCharacter::IsFrontDeathblowAvailable(
	const AActor* InstigatorActor,
	const float MaxRangeCm,
	const float FrontAngleDegrees) const
{
	if (!InstigatorActor || bDead || bDeathblowInProgress || !bDeathblowOpen || MaxRangeCm <= 0.0f)
	{
		return false;
	}

	const FVector ToEnemy = GetActorLocation() - InstigatorActor->GetActorLocation();
	if (ToEnemy.SizeSquared2D() > FMath::Square(MaxRangeCm))
	{
		return false;
	}

	const FVector PlayerForward = InstigatorActor->GetActorForwardVector().GetSafeNormal2D();
	const FVector DirectionToEnemy = ToEnemy.GetSafeNormal2D();
	const float HalfAngleRadians = FMath::DegreesToRadians(FMath::Clamp(FrontAngleDegrees, 0.0f, 360.0f) * 0.5f);
	return FVector::DotProduct(PlayerForward, DirectionToEnemy) >= FMath::Cos(HalfAngleRadians);
}

void ASekiroEnemyCharacter::BeginFrontDeathblow(AActor* InstigatorActor)
{
	if (!InstigatorActor || bDead || bDeathblowInProgress)
	{
		return;
	}

	bDeathblowInProgress = true;
	bDeathblowOpen = false;
	CurrentHealth = FMath::Max(1.0f, CurrentHealth);

	const FVector ToInstigator = InstigatorActor->GetActorLocation() - GetActorLocation();
	if (ToInstigator.SizeSquared2D() > UE_KINDA_SMALL_NUMBER)
	{
		SetActorRotation(FRotator(0.0f, ToInstigator.Rotation().Yaw, 0.0f), ETeleportType::TeleportPhysics);
	}

	if (EnemyScriptBrain)
	{
		EnemyScriptBrain->Deactivate();
	}
	if (UCharacterMovementComponent* Movement = GetCharacterMovement())
	{
		Movement->StopMovementImmediately();
		Movement->DisableMovement();
	}

	if (EnemyAnimBridge)
	{
		FSekiroEnemyAnimCommand Command;
		Command.Type = ESekiroEnemyAnimCommandType::ThrowDef;
		Command.StateId = 12000;
		Command.EventName = TEXT("ThrowDef12000");
		Command.bCanBeInterrupted = false;
		EnemyAnimBridge->SendAnimCommand(Command);
	}

	UE_LOG(LogTemp, Warning, TEXT("[Deathblow] Enemy=%s BeginFrontDeathblow ThrowDef12000 Instigator=%s"),
		*GetName(),
		*InstigatorActor->GetName());
}

void ASekiroEnemyCharacter::ConfirmFrontDeathblowKill(AActor* InstigatorActor)
{
	if (!bDeathblowInProgress || bDead)
	{
		return;
	}

	bDead = true;
	CurrentHealth = 0.0f;

	if (EnemyAnimBridge)
	{
		FSekiroEnemyAnimCommand Command;
		Command.Type = ESekiroEnemyAnimCommandType::ThrowDefDeath;
		Command.StateId = 12001;
		Command.EventName = TEXT("ThrowDefDeath12001");
		Command.bCanBeInterrupted = false;
		EnemyAnimBridge->SendAnimCommand(Command);
	}

	UE_LOG(LogTemp, Warning, TEXT("[Deathblow] Enemy=%s ConfirmFrontDeathblowKill ThrowDefDeath12001 Instigator=%s"),
		*GetName(),
		InstigatorActor ? *InstigatorActor->GetName() : TEXT("None"));
}

void ASekiroEnemyCharacter::OnConstruction(const FTransform& Transform)
{
	Super::OnConstruction(Transform);
	RefreshEnemyWeaponAttachment();
	ApplyWeaponSetVisibility();
}

void ASekiroEnemyCharacter::SetEnemyWeaponStyle(const ESekiroEnemyWeaponStyle WeaponStyle)
{
	SelectedEnemyWeaponStyle = WeaponStyle;
	RefreshEnemyWeaponAttachment();
	ApplyWeaponSetVisibility();
}

void ASekiroEnemyCharacter::SetEnemyWeaponStyleByName(const FName WeaponStyleName)
{
	if (WeaponStyleName == TEXT("None"))
	{
		SetEnemyWeaponStyle(ESekiroEnemyWeaponStyle::None);
	}
	else if (WeaponStyleName == TEXT("Hassou"))
	{
		SetEnemyWeaponStyle(ESekiroEnemyWeaponStyle::Hassou);
	}
	else if (WeaponStyleName == TEXT("Spear"))
	{
		SetEnemyWeaponStyle(ESekiroEnemyWeaponStyle::Spear);
	}
	else if (WeaponStyleName == TEXT("Matchlock"))
	{
		SetEnemyWeaponStyle(ESekiroEnemyWeaponStyle::Matchlock);
	}
	else
	{
		SetEnemyWeaponStyle(ESekiroEnemyWeaponStyle::OneHand);
	}
}

void ASekiroEnemyCharacter::ApplyWeaponSetVisibility()
{
	TArray<USkeletalMeshComponent*> SkeletalComponents;
	GetComponents<USkeletalMeshComponent>(SkeletalComponents);
	for (USkeletalMeshComponent* Component : SkeletalComponents)
	{
		if (Component && Component->GetFName().ToString().Contains(TEXT("Weapon_Katana")))
		{
			Component->SetVisibility(false, true);
			Component->SetHiddenInGame(true, true);
		}
		if (Component && Component != WeaponSet && Component->GetFName().ToString().Contains(TEXT("Weapon_Set")))
		{
			Component->SetVisibility(false, true);
			Component->SetHiddenInGame(true, true);
		}
	}

	if (!WeaponSet)
	{
		return;
	}

	WeaponSet->SetVisibility(SelectedEnemyWeaponStyle != ESekiroEnemyWeaponStyle::None, true);
	WeaponSet->SetHiddenInGame(SelectedEnemyWeaponStyle == ESekiroEnemyWeaponStyle::None, true);
	for (int32 MaterialIndex = 0; MaterialIndex < WeaponSet->GetNumMaterials(); ++MaterialIndex)
	{
		WeaponSet->ShowMaterialSection(MaterialIndex, 0, false, 0);
	}

	auto ShowMaterialNames = [this](const TArray<FName>& MaterialNames)
	{
		for (const FName& MaterialName : MaterialNames)
		{
			const int32 MaterialIndex = WeaponSet->GetMaterialIndex(MaterialName);
			if (MaterialIndex != INDEX_NONE)
			{
				WeaponSet->ShowMaterialSection(MaterialIndex, 0, true, 0);
			}
		}
	};

	switch (SelectedEnemyWeaponStyle)
	{
	case ESekiroEnemyWeaponStyle::OneHand:
		ShowMaterialNames({TEXT("f0__00_"), TEXT("f0__01_"), TEXT("f0__30_"), TEXT("c1010_katana_rope_decal")});
		break;
	case ESekiroEnemyWeaponStyle::Hassou:
		ShowMaterialNames({TEXT("f0__00_"), TEXT("f0__01_"), TEXT("f0__02_"), TEXT("f0__03_"), TEXT("f0__30_"), TEXT("c1010_katana_rope_decal")});
		break;
	case ESekiroEnemyWeaponStyle::Spear:
		ShowMaterialNames({TEXT("f0__04_"), TEXT("_04__cloth")});
		break;
	case ESekiroEnemyWeaponStyle::Matchlock:
		ShowMaterialNames({TEXT("_05_"), TEXT("_07_")});
		break;
	case ESekiroEnemyWeaponStyle::None:
	default:
		break;
	}

}

void ASekiroEnemyCharacter::RefreshEnemyWeaponAttachment()
{
	USkeletalMeshComponent* BodyMesh = GetMesh();
	if (!BodyMesh)
	{
		return;
	}

	TArray<USkeletalMeshComponent*> SkeletalComponents;
	GetComponents<USkeletalMeshComponent>(SkeletalComponents);
	if (WeaponSet)
	{
		if (WeaponSet->GetAttachParent() != BodyMesh)
		{
			WeaponSet->AttachToComponent(BodyMesh, FAttachmentTransformRules::SnapToTargetNotIncludingScale);
		}
		WeaponSet->SetRelativeTransform(FTransform::Identity);
		WeaponSet->SetLeaderPoseComponent(BodyMesh);
		WeaponSet->bUseBoundsFromLeaderPoseComponent = true;
	}

	for (USkeletalMeshComponent* Component : SkeletalComponents)
	{
		if (Component && Component != WeaponSet && Component->GetFName().ToString().Contains(TEXT("Weapon_Set")))
		{
			Component->SetVisibility(false, true);
			Component->SetHiddenInGame(true, true);
		}
	}
}

void ASekiroEnemyCharacter::HandleSekiroEnemyAnimEvent(
	const FName EventName,
	const bool bActive,
	const int32 TaeType,
	const int32 BehaviorJudgeID,
	const FString& SourceArguments)
{
	if (TaeType != 1 && EventName != FName(TEXT("TAE_1")))
	{
		return;
	}

	int32 ResolvedBehaviorJudgeID = BehaviorJudgeID;
	if (ResolvedBehaviorJudgeID == INDEX_NONE)
	{
		ExtractTaeParamInt(SourceArguments, TEXT("BehaviorJudgeID"), ResolvedBehaviorJudgeID);
	}

	if (bActive)
	{
		bEnemyAttackBehaviorActive = true;
		ActiveEnemyAttackBehaviorJudgeID = ResolvedBehaviorJudgeID;
		FSekiroAttackCollisionConfig Config;
		ActiveEnemyAttackID = ResolveAttackCollisionConfig(this, ResolvedBehaviorJudgeID, Config)
			? MakeAttackID(Config)
			: NAME_None;
		BeginAttackCollision(this, ActiveEnemyAttackID);
	}
	else if (ResolvedBehaviorJudgeID == INDEX_NONE || ResolvedBehaviorJudgeID == ActiveEnemyAttackBehaviorJudgeID)
	{
		DestroyAttackCollision(this, ActiveEnemyAttackID);
		bEnemyAttackBehaviorActive = false;
		ActiveEnemyAttackBehaviorJudgeID = INDEX_NONE;
		ActiveEnemyAttackID = NAME_None;
	}
}
