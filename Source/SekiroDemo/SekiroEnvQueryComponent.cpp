#include "SekiroEnvQueryComponent.h"

#include "GameFramework/Character.h"
#include "GameFramework/CharacterMovementComponent.h"

namespace
{
	constexpr int32 ActionArmSpMove = 5;

	FSekiroEnvIdInfo MakeEnvInfo(
		const int32 Id,
		const TCHAR* Key,
		const TCHAR* Name,
		const TCHAR* Meaning,
		const TCHAR* ArgumentFamily,
		const TCHAR* ReturnType,
		const TCHAR* SourceHint,
		const ESekiroEnvValueType ValueType,
		const ESekiroEnvConfidence Confidence)
	{
		FSekiroEnvIdInfo Info;
		Info.Id = Id;
		Info.Key = Key;
		Info.Name = Name;
		Info.Meaning = Meaning;
		Info.ArgumentFamily = ArgumentFamily;
		Info.ReturnType = ReturnType;
		Info.SourceHint = SourceHint;
		Info.ValueType = ValueType;
		Info.Confidence = Confidence;
		return Info;
	}

	FSekiroEnvQueryResult MakeBoolResult(const TCHAR* DebugName, const bool bValue)
	{
		FSekiroEnvQueryResult Result;
		Result.bHandled = true;
		Result.bBoolValue = bValue;
		Result.IntValue = bValue ? 1 : 0;
		Result.FloatValue = bValue ? 1.0f : 0.0f;
		Result.DebugName = DebugName;
		return Result;
	}

	FSekiroEnvQueryResult MakeIntResult(const TCHAR* DebugName, const int32 Value)
	{
		FSekiroEnvQueryResult Result;
		Result.bHandled = true;
		Result.bBoolValue = Value != 0;
		Result.IntValue = Value;
		Result.FloatValue = static_cast<float>(Value);
		Result.DebugName = DebugName;
		return Result;
	}

	FSekiroEnvQueryResult MakeFloatResult(const TCHAR* DebugName, const float Value)
	{
		FSekiroEnvQueryResult Result;
		Result.bHandled = true;
		Result.bBoolValue = !FMath::IsNearlyZero(Value);
		Result.IntValue = FMath::RoundToInt(Value);
		Result.FloatValue = Value;
		Result.DebugName = DebugName;
		return Result;
	}

	FSekiroEnvQueryResult MakeUnhandledResult(const int32 Id)
	{
		FSekiroEnvQueryResult Result;
		Result.DebugName = FString::Printf(TEXT("Unhandled env(%d)"), Id);
		return Result;
	}

	void SetBoolMapValue(TMap<int32, bool>& Map, const int32 Key, const bool bValue)
	{
		if (bValue)
		{
			Map.FindOrAdd(Key) = true;
		}
		else
		{
			Map.Remove(Key);
		}
	}

	void SetFloatMapValue(TMap<int32, float>& Map, const int32 Key, const float Value)
	{
		if (FMath::IsNearlyZero(Value))
		{
			Map.Remove(Key);
		}
		else
		{
			Map.FindOrAdd(Key) = Value;
		}
	}

	void SetIntMapValue(TMap<int32, int32>& Map, const int32 Key, const int32 Value)
	{
		if (Value == 0)
		{
			Map.Remove(Key);
		}
		else
		{
			Map.FindOrAdd(Key) = Value;
		}
	}
}

USekiroEnvQueryComponent::USekiroEnvQueryComponent()
{
	PrimaryComponentTick.bCanEverTick = true;
	PrimaryComponentTick.bStartWithTickEnabled = true;
}

void USekiroEnvQueryComponent::BeginPlay()
{
	Super::BeginPlay();

	if (bAutoSyncOwnerMovement)
	{
		SyncBasicOwnerState();
	}
}

void USekiroEnvQueryComponent::TickComponent(const float DeltaTime, const ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction)
{
	Super::TickComponent(DeltaTime, TickType, ThisTickFunction);

	LastDeltaTimeMilliseconds = DeltaTime * 1000.0f;
	if (bAutoSyncOwnerMovement)
	{
		SyncBasicOwnerState();
	}
}

void USekiroEnvQueryComponent::ResetEnvRuntimeState()
{
	PendingEventId = INDEX_NONE;
	bItemUseFixedRequest = false;
	bItemUseRequestInvalid = false;
	bItemUseEnable = true;
	ItemAnimeType = -1;

	DamageType = 0;
	DamageLevel = 0;
	DamageElement = 1;
	DamageAngle = 0;
	DamageAngleFrontBack = 0;
	AttackDirection = 0;
	DamageDirectionSign = 1.0f;
	GuardDamageAmount = 0;
	bDamageAnimationGateActive = false;
	bDamageReactionSuppressed = false;
	bDamageBreakSuppressedByEnchant = false;

	CurrentHp = 100;
	bHpAutoChargeActive = false;
	bHpAutoChargeBlocked = false;

	WeaponChangeType = 0;
	SpecialAttackTypeRight = 0;

	ThrowAnimationId = -1;
	bThrowKillRequested = false;
	bThrowDeathRequested = false;
	bThrowEscapeRequested = false;
	bThrowActive = false;
	bRevivalRequested = false;
	ThrowFinishedBySide.Empty();

	bIsStandby = true;
	bIsMoveable = false;
	MoveInputForward = 0;
	MoveInputRight = 0;
	MoveInputStrength = 0.0f;
	bSprintHeld = false;
	bIsFalling = false;
	bJustLanded = false;
	bLandReady = false;
	FallHeightRaw = 0.0f;
	FallVerticalSpeed = 0.0f;
	bSpecialMoveStyleActive = false;
	bWireTargetAvailable = false;
	bWaterContact = false;
	bEnemyJumpAvailable = false;
	bWallJumpAvailable = false;
	bNoLandOrThrowReset = false;
	bAutoAimTargetValid = false;

	DockingTargetEndType = 0;
	EdgeType = 0;
	EasyDeflectedReactionType = 0;
	HardDeflectedReactionType = 0;
	bDockingBreakRequested = false;
	AirHangType = 0;
	DockingTargetEdgeTypeByRequest.Empty();
	bHangOuterCornerLeftAvailable = false;
	bHangOuterCornerRightAvailable = false;
	bHangClimbAvailable = false;
	bDockingLeftBlocked = false;
	bDockingRightBlocked = false;
	bHangInsideCornerLeftAvailable = false;
	bHangInsideCornerRightAvailable = false;

	MapVisibilityType = 0;
	bCanStartCover = false;
	bCanStartGroundHang = false;
	bCanSwimToDive = false;
	bCanDiveToSwim = false;

	TalkParamRefId = 0;
	EzStateRefId = 0;
	LoadInitPose = -1;
	SafePosReturnType = -1;
	bAllowStandEnter = true;
	AddBlendSpeakState = 0;
	EasyDeflectAttackDirection = 0;
	HardDeflectAttackDirection = 0;

	ActionPressed.Empty();
	ActionHoldMilliseconds.Empty();
	ActionUnlocked.Empty();
	ActionEnabled.Empty();
	ActiveBehaviorRefs.Empty();
	BehaviorIdentificationFlags.Empty();
	ActiveSpEffects.Empty();
	WeaponMotionCategoryByHand.Empty();
	NextWeaponMotionCategoryByHand.Empty();
	StartTimeMillisecondsBySlot.Empty();
	LastDeltaTimeMilliseconds = 0.0f;
	bWasOwnerFalling = false;
}

void USekiroEnvQueryComponent::SyncBasicOwnerState()
{
	const ACharacter* OwnerCharacter = Cast<ACharacter>(GetOwner());
	if (!OwnerCharacter)
	{
		return;
	}

	const UCharacterMovementComponent* MovementComponent = OwnerCharacter->GetCharacterMovement();
	const FVector Velocity = OwnerCharacter->GetVelocity();
	const bool bOwnerFalling = MovementComponent ? MovementComponent->IsFalling() : false;
	const bool bHasHorizontalMotion = Velocity.SizeSquared2D() > 1.0f;
	const bool bHasInput = OwnerCharacter->GetLastMovementInputVector().SizeSquared2D() > KINDA_SMALL_NUMBER;
	const bool bHasPreviewInput = MoveInputStrength > KINDA_SMALL_NUMBER;

	bJustLanded = bWasOwnerFalling && !bOwnerFalling;
	bIsFalling = bOwnerFalling;
	FallVerticalSpeed = Velocity.Z;
	bIsMoveable = bHasHorizontalMotion || bHasInput || bHasPreviewInput;
	bIsStandby = !bIsFalling && !bIsMoveable;
	bLandReady = !bIsFalling && (MovementComponent ? MovementComponent->IsMovingOnGround() : bLandReady);
	bWasOwnerFalling = bOwnerFalling;
}

FSekiroEnvQueryResult USekiroEnvQueryComponent::EnvValue(const int32 Id, const int32 SubKey) const
{
	return QueryEnvValue(Id, SubKey);
}

bool USekiroEnvQueryComponent::EnvBool(const int32 Id, const int32 SubKey) const
{
	return QueryEnvValue(Id, SubKey).bBoolValue;
}

int32 USekiroEnvQueryComponent::EnvInt(const int32 Id, const int32 SubKey) const
{
	return QueryEnvValue(Id, SubKey).IntValue;
}

float USekiroEnvQueryComponent::EnvFloat(const int32 Id, const int32 SubKey) const
{
	return QueryEnvValue(Id, SubKey).FloatValue;
}

bool USekiroEnvQueryComponent::EnvNamedBool(const FString& QueryName, const int32 SubKey) const
{
	const bool bIsStrictBehaviorRefQuery =
		QueryName.Equals(TEXT("StrictBehaviorRefLifeExtension"), ESearchCase::IgnoreCase) ||
		QueryName.Equals(TEXT("SpecialEffectActiveStrictByBehaviorRefId"), ESearchCase::IgnoreCase) ||
		QueryName.Contains(TEXT("_Behavior"), ESearchCase::IgnoreCase);

	return bIsStrictBehaviorRefQuery ? ActiveBehaviorRefs.FindRef(SubKey) : false;
}

bool USekiroEnvQueryComponent::GetEnvIdInfo(const int32 Id, FSekiroEnvIdInfo& OutInfo) const
{
	for (const FSekiroEnvIdInfo& Info : GetEnvInfoTable())
	{
		if (Info.Id == Id)
		{
			OutInfo = Info;
			return true;
		}
	}

	return false;
}

void USekiroEnvQueryComponent::GetAllEnvIdInfos(TArray<FSekiroEnvIdInfo>& OutInfos) const
{
	OutInfos = GetEnvInfoTable();
}

void USekiroEnvQueryComponent::SetActionPressed(const int32 ActionArmId, const bool bPressed)
{
	SetBoolMapValue(ActionPressed, ActionArmId, bPressed);
}

void USekiroEnvQueryComponent::SetActionHoldMilliseconds(const int32 ActionArmId, const float HoldMilliseconds)
{
	SetFloatMapValue(ActionHoldMilliseconds, ActionArmId, HoldMilliseconds);
}

void USekiroEnvQueryComponent::SetMovementInputIntent(const int32 Forward, const int32 Right, const bool bInSprintHeld, const float DeltaSeconds)
{
	MoveInputForward = FMath::Clamp(Forward, -1, 1);
	MoveInputRight = FMath::Clamp(Right, -1, 1);
	bSprintHeld = bInSprintHeld;
	MoveInputStrength = FMath::Clamp(FVector2D(static_cast<float>(MoveInputForward), static_cast<float>(MoveInputRight)).Size(), 0.0f, 1.0f);

	const bool bWantsMove = MoveInputStrength > KINDA_SMALL_NUMBER;
	bIsMoveable = bWantsMove;
	bIsStandby = !bIsFalling && !bWantsMove;

	SetActionPressed(ActionArmSpMove, bSprintHeld);
	const float PreviousHoldMs = ActionHoldMilliseconds.FindRef(ActionArmSpMove);
	SetActionHoldMilliseconds(ActionArmSpMove, bSprintHeld ? PreviousHoldMs + FMath::Max(DeltaSeconds, 0.0f) * 1000.0f : 0.0f);
}

void USekiroEnvQueryComponent::SetActionUnlocked(const int32 ActionUnlockType, const bool bUnlocked)
{
	SetBoolMapValue(ActionUnlocked, ActionUnlockType, bUnlocked);
}

void USekiroEnvQueryComponent::SetActionEnabled(const int32 ActionArmId, const bool bEnabled)
{
	SetBoolMapValue(ActionEnabled, ActionArmId, bEnabled);
}

void USekiroEnvQueryComponent::SetBehaviorRefActive(const int32 BehaviorRefId, const bool bActive)
{
	SetBoolMapValue(ActiveBehaviorRefs, BehaviorRefId, bActive);
}

void USekiroEnvQueryComponent::SetBehaviorIdentificationActive(const int32 BehaviorIdentificationValue, const bool bActive)
{
	SetBoolMapValue(BehaviorIdentificationFlags, BehaviorIdentificationValue, bActive);
}

void USekiroEnvQueryComponent::SetSpEffectActive(const int32 SpEffectId, const bool bActive)
{
	SetBoolMapValue(ActiveSpEffects, SpEffectId, bActive);
}

void USekiroEnvQueryComponent::SetWeaponMotionCategory(const int32 HandId, const int32 WeaponMotionCategory)
{
	SetIntMapValue(WeaponMotionCategoryByHand, HandId, WeaponMotionCategory);
}

void USekiroEnvQueryComponent::SetNextWeaponMotionCategory(const int32 HandId, const int32 WeaponMotionCategory)
{
	SetIntMapValue(NextWeaponMotionCategoryByHand, HandId, WeaponMotionCategory);
}

void USekiroEnvQueryComponent::SetStartTimeMilliseconds(const int32 Slot, const float TimeMilliseconds)
{
	SetFloatMapValue(StartTimeMillisecondsBySlot, Slot, TimeMilliseconds);
}

FSekiroEnvQueryResult USekiroEnvQueryComponent::QueryEnvValue(const int32 Id, const int32 SubKey) const
{
	switch (Id)
	{
	case 105: return MakeIntResult(TEXT("event_id"), PendingEventId);
	case 113: return MakeBoolResult(TEXT("item_use_fixed_request"), bItemUseFixedRequest);
	case 115: return MakeBoolResult(TEXT("item_use_request_invalid"), bItemUseRequestInvalid);
	case 200: return MakeBoolResult(TEXT("fall_request"), bIsFalling);
	case 201: return MakeBoolResult(TEXT("land_request"), bJustLanded);
	case 202: return MakeIntResult(TEXT("damage_type"), DamageType);
	case 205: return MakeBoolResult(TEXT("damage_animation_gate"), bDamageAnimationGateActive);
	case 206: return MakeBoolResult(TEXT("damage_reaction_suppressed"), bDamageReactionSuppressed);
	case 207: return MakeIntResult(TEXT("weapon_change_type"), WeaponChangeType);
	case 222: return MakeIntResult(TEXT("damage_angle"), DamageAngle);
	case 224: return MakeFloatResult(TEXT("fall_height_raw"), FallHeightRaw);
	case 225: return MakeIntResult(TEXT("weapon_motion_category"), WeaponMotionCategoryByHand.FindRef(SubKey));
	case 231: return MakeIntResult(TEXT("item_anime_type"), ItemAnimeType);
	case 233: return MakeBoolResult(TEXT("item_use_enable"), bItemUseEnable);
	case 236: return MakeIntResult(TEXT("damage_level"), DamageLevel);
	case 237: return MakeIntResult(TEXT("guard_damage_amount"), GuardDamageAmount);
	case 248: return MakeBoolResult(TEXT("land_ready"), bLandReady);
	case 256: return MakeBoolResult(TEXT("hp_auto_charge_active"), bHpAutoChargeActive);
	case 273: return MakeIntResult(TEXT("throw_animation_id"), ThrowAnimationId);
	case 274: return MakeBoolResult(TEXT("throw_kill_requested"), bThrowKillRequested);
	case 276: return MakeBoolResult(TEXT("throw_death_requested"), bThrowDeathRequested);
	case 277: return MakeBoolResult(TEXT("throw_escape_requested"), bThrowEscapeRequested);
	case 285: return MakeIntResult(TEXT("damage_element"), DamageElement);
	case 333: return MakeFloatResult(TEXT("delta_time_ms"), LastDeltaTimeMilliseconds);
	case 334: return MakeBoolResult(TEXT("behavior_identification"), BehaviorIdentificationFlags.FindRef(SubKey));
	case 337: return MakeBoolResult(TEXT("throw_active"), bThrowActive);
	case 339: return MakeBoolResult(TEXT("throw_finished_by_side"), ThrowFinishedBySide.FindRef(SubKey));
	case 345: return MakeIntResult(TEXT("special_attack_type_right"), SpecialAttackTypeRight);
	case 349: return MakeBoolResult(TEXT("damage_break_suppressed_by_enchant"), bDamageBreakSuppressedByEnchant);
	case 1000: return MakeIntResult(TEXT("current_hp"), CurrentHp);
	case 1007: return MakeBoolResult(TEXT("hp_auto_charge_blocked"), bHpAutoChargeBlocked);
	case 1105: return MakeBoolResult(TEXT("is_standby"), bIsStandby);
	case 1106: return MakeBoolResult(TEXT("action_pressed"), ActionPressed.FindRef(SubKey));
	case 1108: return MakeFloatResult(TEXT("action_hold_ms"), ActionHoldMilliseconds.FindRef(SubKey));
	case 1112: return MakeBoolResult(TEXT("damage_animation_gate"), bDamageAnimationGateActive);
	case 1116: return MakeBoolResult(TEXT("sp_effect_active"), ActiveSpEffects.FindRef(SubKey));
	case 1118: return MakeBoolResult(TEXT("auto_aim_target_valid"), bAutoAimTargetValid);
	case 1119: return MakeIntResult(TEXT("attack_direction"), AttackDirection);
	case 1121: return MakeFloatResult(TEXT("damage_direction_sign"), DamageDirectionSign);
	case 2000: return MakeBoolResult(TEXT("is_moveable"), bIsMoveable);
	case 2004: return MakeBoolResult(TEXT("enemy_jump_available"), bEnemyJumpAvailable);
	case 3000: return MakeBoolResult(TEXT("wire_target_available"), bWireTargetAvailable);
	case 3003: return MakeFloatResult(TEXT("fall_vertical_speed"), FallVerticalSpeed);
	case 3008: return MakeBoolResult(TEXT("special_move_style_active"), bSpecialMoveStyleActive);
	case 3011: return MakeIntResult(TEXT("docking_target_end_type"), DockingTargetEndType);
	case 3017: return MakeIntResult(TEXT("edge_type"), EdgeType);
	case 3018: return MakeIntResult(TEXT("easy_deflected_reaction_type"), EasyDeflectedReactionType);
	case 3019: return MakeIntResult(TEXT("hard_deflected_reaction_type"), HardDeflectedReactionType);
	case 3020: return MakeBoolResult(TEXT("wall_jump_available"), bWallJumpAvailable);
	case 3025: return MakeBoolResult(TEXT("water_contact"), bWaterContact);
	case 3027: return MakeIntResult(TEXT("next_weapon_motion_category"), NextWeaponMotionCategoryByHand.FindRef(SubKey));
	case 3028: return MakeBoolResult(TEXT("revival_requested"), bRevivalRequested);
	case 3029: return MakeBoolResult(TEXT("docking_break_requested"), bDockingBreakRequested);
	case 3031: return MakeBoolResult(TEXT("no_land_or_throw_reset"), bNoLandOrThrowReset);
	case 3032: return MakeIntResult(TEXT("damage_angle_front_back"), DamageAngleFrontBack);
	case 3033: return MakeBoolResult(TEXT("action_unlocked"), ActionUnlocked.FindRef(SubKey));
	case 3035: return MakeBoolResult(TEXT("action_enabled"), ActionEnabled.FindRef(SubKey));
	case 3036: return MakeBoolResult(TEXT("behavior_ref_active"), ActiveBehaviorRefs.FindRef(SubKey));
	case 3037: return MakeBoolResult(TEXT("allow_stand_enter"), bAllowStandEnter);
	case 3038: return MakeBoolResult(TEXT("can_swim_to_dive"), bCanSwimToDive);
	case 3039: return MakeBoolResult(TEXT("can_dive_to_swim"), bCanDiveToSwim);
	case 3040: return MakeIntResult(TEXT("map_visibility_type"), MapVisibilityType);
	case 3043: return MakeBoolResult(TEXT("can_start_cover"), bCanStartCover);
	case 3044: return MakeBoolResult(TEXT("can_start_ground_hang"), bCanStartGroundHang);
	case 3045: return MakeIntResult(TEXT("air_hang_type"), AirHangType);
	case 3046: return MakeIntResult(TEXT("docking_target_edge_type"), DockingTargetEdgeTypeByRequest.FindRef(SubKey));
	case 3048: return MakeBoolResult(TEXT("hang_outer_corner_left_available"), bHangOuterCornerLeftAvailable);
	case 3049: return MakeBoolResult(TEXT("hang_outer_corner_right_available"), bHangOuterCornerRightAvailable);
	case 3050: return MakeBoolResult(TEXT("hang_climb_available"), bHangClimbAvailable);
	case 3051: return MakeBoolResult(TEXT("docking_left_blocked"), bDockingLeftBlocked);
	case 3052: return MakeBoolResult(TEXT("docking_right_blocked"), bDockingRightBlocked);
	case 3053: return MakeIntResult(TEXT("talk_param_ref_id"), TalkParamRefId);
	case 3054: return MakeIntResult(TEXT("ez_state_ref_id"), EzStateRefId);
	case 3055: return MakeIntResult(TEXT("load_init_pose"), LoadInitPose);
	case 3056: return MakeIntResult(TEXT("easy_deflect_attack_direction"), EasyDeflectAttackDirection);
	case 3057: return MakeIntResult(TEXT("hard_deflect_attack_direction"), HardDeflectAttackDirection);
	case 3058: return MakeIntResult(TEXT("add_blend_speak_state"), AddBlendSpeakState);
	case 3059: return MakeBoolResult(TEXT("hang_inside_corner_left_available"), bHangInsideCornerLeftAvailable);
	case 3060: return MakeBoolResult(TEXT("hang_inside_corner_right_available"), bHangInsideCornerRightAvailable);
	case 3061: return MakeIntResult(TEXT("safe_pos_return_type"), SafePosReturnType);
	case 3063: return MakeFloatResult(TEXT("start_time_ms"), StartTimeMillisecondsBySlot.FindRef(SubKey));
	default: return MakeUnhandledResult(Id);
	}
}

const TArray<FSekiroEnvIdInfo>& USekiroEnvQueryComponent::GetEnvInfoTable()
{
	static const TArray<FSekiroEnvIdInfo> Infos = []()
	{
		TArray<FSekiroEnvIdInfo> Result;
		Result.Reserve(82);
		Result.Add(MakeEnvInfo(105, TEXT("env(105, slot)"), TEXT("PendingEventId"), TEXT("Pending EZ/event id."), TEXT("slot index"), TEXT("int"), TEXT("c0000.dec.lua:246"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(113, TEXT("env(113)"), TEXT("ItemUseFixedRequest"), TEXT("Special fixed-item branch before item use."), TEXT("none"), TEXT("bool"), TEXT("c0000_transition.dec.lua:3865"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::Low));
		Result.Add(MakeEnvInfo(115, TEXT("env(115)"), TEXT("ItemUseRequestInvalid"), TEXT("Item request is blocked or invalid."), TEXT("none"), TEXT("bool"), TEXT("c0000_transition.dec.lua:3863"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::Medium));
		Result.Add(MakeEnvInfo(200, TEXT("env(200)"), TEXT("FallRequest"), TEXT("Fall transition request."), TEXT("none"), TEXT("bool"), TEXT("c0000_transition.dec.lua:5612"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(201, TEXT("env(201)"), TEXT("LandRequest"), TEXT("Land/contact transition request."), TEXT("none"), TEXT("bool"), TEXT("c0000_transition.dec.lua:5617"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(202, TEXT("env(202)"), TEXT("DamageType"), TEXT("Damage type enum."), TEXT("none"), TEXT("int DAMAGE_TYPE_*"), TEXT("c0000_transition.dec.lua:5429"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(205, TEXT("env(205)"), TEXT("DamageAnimationGate"), TEXT("Damage/reaction gate used with 1112 and throw state."), TEXT("none"), TEXT("bool"), TEXT("c0000_transition.dec.lua:5432"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::Medium));
		Result.Add(MakeEnvInfo(206, TEXT("env(206)"), TEXT("DamageReactionSuppressed"), TEXT("Suppress death/damage/docking-break reaction when true."), TEXT("none"), TEXT("bool"), TEXT("c0000_transition.dec.lua:5542"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::Medium));
		Result.Add(MakeEnvInfo(207, TEXT("env(207)"), TEXT("WeaponChangeType"), TEXT("Weapon/arm style, compared with ARM_STYLE_SAFE."), TEXT("none"), TEXT("int ARM_STYLE_*"), TEXT("c0000_transition.dec.lua:1550"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(222, TEXT("env(222)"), TEXT("DamageAngle"), TEXT("Horizontal hit direction."), TEXT("none"), TEXT("int DAMAGE_DIR_*"), TEXT("c0000_transition.dec.lua:637"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(224, TEXT("env(224)"), TEXT("FallHeightRaw"), TEXT("Raw fall-height value; Lua multiplies by 0.01."), TEXT("none"), TEXT("float"), TEXT("c0000_transition.dec.lua:1762"), ESekiroEnvValueType::Float, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(225, TEXT("env(225, HAND_*)"), TEXT("WeaponMotionCategory"), TEXT("Weapon motion category by hand."), TEXT("HAND_LEFT/HAND_RIGHT"), TEXT("int WEP_MOTION_CATEGORY_*"), TEXT("c0000_transition.dec.lua:623"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(231, TEXT("env(231)"), TEXT("ItemAnimeType"), TEXT("Item animation type."), TEXT("none"), TEXT("int ITEM_*"), TEXT("c0000_transition.dec.lua:3914"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(233, TEXT("env(233)"), TEXT("ItemUseEnable"), TEXT("Current item can be used."), TEXT("none"), TEXT("bool"), TEXT("c0000_transition.dec.lua:3913"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(236, TEXT("env(236)"), TEXT("DamageLevel"), TEXT("Damage level enum."), TEXT("none"), TEXT("int DAMAGE_LEVEL_*"), TEXT("c0000_transition.dec.lua:779"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(237, TEXT("env(237)"), TEXT("GuardDamageAmount"), TEXT("Guard damage or posture damage amount."), TEXT("none"), TEXT("int"), TEXT("c0000_transition.dec.lua:5585"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::Medium));
		Result.Add(MakeEnvInfo(248, TEXT("env(248)"), TEXT("LandReady"), TEXT("Ground/land-ready flag."), TEXT("none"), TEXT("bool"), TEXT("c0000_transition.dec.lua:5627"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(256, TEXT("env(256)"), TEXT("HpAutoChargeActive"), TEXT("HP auto-charge related state."), TEXT("none"), TEXT("bool"), TEXT("c0000.dec.lua:116"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::Medium));
		Result.Add(MakeEnvInfo(273, TEXT("env(273)"), TEXT("ThrowAnimationId"), TEXT("Throw animation id."), TEXT("none"), TEXT("int"), TEXT("c0000_cmsg.dec.lua:15847"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(274, TEXT("env(274)"), TEXT("ThrowKillRequested"), TEXT("Throw kill request."), TEXT("none"), TEXT("bool"), TEXT("c0000_transition.dec.lua:5531"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(276, TEXT("env(276)"), TEXT("ThrowDeathRequested"), TEXT("Throw death request."), TEXT("none"), TEXT("bool"), TEXT("c0000_transition.dec.lua:5526"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(277, TEXT("env(277)"), TEXT("ThrowEscapeRequested"), TEXT("Throw escape request."), TEXT("none"), TEXT("bool"), TEXT("c0000_transition.dec.lua:5536"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(285, TEXT("env(285)"), TEXT("DamageElement"), TEXT("Damage element enum."), TEXT("none"), TEXT("int DAMAGE_ELEMENT_*"), TEXT("c0000_transition.dec.lua:662"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(333, TEXT("env(333)"), TEXT("DeltaTimeMs"), TEXT("Delta time in milliseconds."), TEXT("none"), TEXT("float"), TEXT("c0000_define.dec.lua:862"), ESekiroEnvValueType::Float, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(334, TEXT("env(334, BEHAVIOR_IDENTIFICATION_VALUE_*)"), TEXT("BehaviorIdentification"), TEXT("Behavior identification flag check."), TEXT("BEHAVIOR_IDENTIFICATION_VALUE_*"), TEXT("bool"), TEXT("c0000_transition.dec.lua:999"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(337, TEXT("env(337)"), TEXT("ThrowActive"), TEXT("Throw/grab active state."), TEXT("none"), TEXT("bool"), TEXT("c0000.dec.lua:238"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::Medium));
		Result.Add(MakeEnvInfo(339, TEXT("env(339, side)"), TEXT("ThrowFinishedBySide"), TEXT("Event/throw side finished flag."), TEXT("0/1"), TEXT("bool"), TEXT("c0000.dec.lua:211"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::Medium));
		Result.Add(MakeEnvInfo(345, TEXT("env(345, HAND_RIGHT)"), TEXT("SpecialAttackTypeRight"), TEXT("Right-hand special attack type."), TEXT("HAND_RIGHT"), TEXT("int SP_ATK_TYPE_*"), TEXT("c0000_transition.dec.lua:1764"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(349, TEXT("env(349)"), TEXT("DamageBreakSuppressedByEnchant"), TEXT("Damage-break extra gate, likely enchant-related."), TEXT("none"), TEXT("bool"), TEXT("c0000_transition.dec.lua:5601"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::Low));
		Result.Add(MakeEnvInfo(1000, TEXT("env(1000)"), TEXT("CurrentHp"), TEXT("Current HP."), TEXT("none"), TEXT("int"), TEXT("c0000_transition.dec.lua:270"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(1007, TEXT("env(1007)"), TEXT("HpAutoChargeBlocked"), TEXT("HP auto-charge exception/block state."), TEXT("none"), TEXT("bool"), TEXT("c0000.dec.lua:116"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::Medium));
		Result.Add(MakeEnvInfo(1105, TEXT("env(1105)"), TEXT("IsStandby"), TEXT("Standby flag."), TEXT("none"), TEXT("bool"), TEXT("c0000.dec.lua:690"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(1106, TEXT("env(1106, ACTION_ARM_*)"), TEXT("ActionPressed"), TEXT("Action input pressed/triggered."), TEXT("ACTION_ARM_*"), TEXT("bool"), TEXT("c0000_transition.dec.lua:2019"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(1108, TEXT("env(1108, ACTION_ARM_*)"), TEXT("ActionHoldMilliseconds"), TEXT("Action input hold/buffer amount."), TEXT("ACTION_ARM_*"), TEXT("float"), TEXT("c0000.dec.lua:265"), ESekiroEnvValueType::Float, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(1112, TEXT("env(1112)"), TEXT("DamageAnimationGate"), TEXT("Damage reaction gate, likely super-armor/no-stagger."), TEXT("none"), TEXT("bool"), TEXT("c0000_transition.dec.lua:5432"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::Medium));
		Result.Add(MakeEnvInfo(1116, TEXT("env(1116, SpEffectId)"), TEXT("SpEffectActive"), TEXT("Real SpEffect id active check."), TEXT("SpEffect id"), TEXT("bool"), TEXT("c0000.dec.lua:62"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(1118, TEXT("env(1118)"), TEXT("AutoAimTargetValid"), TEXT("Lock-on or auto-aim target is valid."), TEXT("none"), TEXT("bool"), TEXT("c0000_transition.dec.lua:427"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::Medium));
		Result.Add(MakeEnvInfo(1119, TEXT("env(1119)"), TEXT("AttackDirection"), TEXT("Incoming attack direction."), TEXT("none"), TEXT("int"), TEXT("c0000_transition.dec.lua:846"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(1121, TEXT("env(1121)"), TEXT("DamageDirectionSign"), TEXT("Damage direction sign; negative flips left/right."), TEXT("none"), TEXT("float"), TEXT("c0000_transition.dec.lua:848"), ESekiroEnvValueType::Float, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(2000, TEXT("env(2000)"), TEXT("IsMoveable"), TEXT("Moveable flag."), TEXT("none"), TEXT("bool"), TEXT("c0000.dec.lua:689"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(2004, TEXT("env(2004)"), TEXT("EnemyJumpAvailable"), TEXT("Kick enemy jump / hit jump condition."), TEXT("none"), TEXT("bool"), TEXT("c0000_transition.dec.lua:5657"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3000, TEXT("env(3000)"), TEXT("WireTargetAvailable"), TEXT("Wire shoot target or range available."), TEXT("none"), TEXT("bool"), TEXT("c0000_transition.dec.lua:3116"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::Medium));
		Result.Add(MakeEnvInfo(3003, TEXT("env(3003)"), TEXT("FallVerticalSpeed"), TEXT("Vertical fall speed."), TEXT("none"), TEXT("float"), TEXT("c0000_transition.dec.lua:5617"), ESekiroEnvValueType::Float, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3008, TEXT("env(3008)"), TEXT("SpecialMoveStyleActive"), TEXT("Special movement/control suppression flag."), TEXT("none"), TEXT("bool"), TEXT("c0000.dec.lua:737"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::Low));
		Result.Add(MakeEnvInfo(3011, TEXT("env(3011)"), TEXT("DockingTargetEndType"), TEXT("Docking target edge-end type."), TEXT("none"), TEXT("int DOCKING_TGT_END_TYPE_*"), TEXT("c0000_transition.dec.lua:2479"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3017, TEXT("env(3017)"), TEXT("EdgeType"), TEXT("Cover/hang edge type."), TEXT("none"), TEXT("int COVER_EDGE_TYPE_* or HANG_EDGE_TYPE_*"), TEXT("c0000.dec.lua:500"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3018, TEXT("env(3018)"), TEXT("EasyDeflectedReactionType"), TEXT("Easy deflect reaction direction/type."), TEXT("none"), TEXT("int DEFLECTED_REACTION_TYPE_*"), TEXT("c0000_transition.dec.lua:1593"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3019, TEXT("env(3019)"), TEXT("HardDeflectedReactionType"), TEXT("Hard deflect reaction direction/type."), TEXT("none"), TEXT("int DEFLECTED_REACTION_TYPE_*"), TEXT("c0000_transition.dec.lua:1586"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3020, TEXT("env(3020)"), TEXT("WallJumpAvailable"), TEXT("Wall jump condition available."), TEXT("none"), TEXT("bool"), TEXT("c0000_transition.dec.lua:5900"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3025, TEXT("env(3025)"), TEXT("WaterContact"), TEXT("Water contact/in water flag."), TEXT("none"), TEXT("bool"), TEXT("c0000_transition.dec.lua:766"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3027, TEXT("env(3027, HAND_LEFT)"), TEXT("NextWeaponMotionCategory"), TEXT("Next sub-weapon category."), TEXT("HAND_LEFT"), TEXT("int WEP_MOTION_CATEGORY_*"), TEXT("c0000_transition.dec.lua:6215"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3028, TEXT("env(3028)"), TEXT("RevivalRequested"), TEXT("Revival input/request."), TEXT("none"), TEXT("bool"), TEXT("c0000_transition.dec.lua:286"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3029, TEXT("env(3029)"), TEXT("DockingBreakRequested"), TEXT("Docking break request."), TEXT("none"), TEXT("bool"), TEXT("c0000_transition.dec.lua:5697"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3031, TEXT("env(3031)"), TEXT("NoLandOrThrowReset"), TEXT("Land/throw reset suppression gate."), TEXT("none"), TEXT("bool"), TEXT("c0000_transition.dec.lua:364"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::Low));
		Result.Add(MakeEnvInfo(3032, TEXT("env(3032)"), TEXT("DamageAngleFrontBack"), TEXT("Front/back damage direction."), TEXT("none"), TEXT("int SELECTOR_DAMAGE_DIR_*"), TEXT("c0000_transition.dec.lua:778"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3033, TEXT("env(3033, ACTION_UNLOCK_TYPE_*)"), TEXT("ActionUnlocked"), TEXT("Action unlock check."), TEXT("ACTION_UNLOCK_TYPE_*"), TEXT("bool"), TEXT("c0000.dec.lua:772"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3035, TEXT("env(3035, ACTION_ARM_*)"), TEXT("ActionEnabled"), TEXT("Action currently enabled by TAE/runtime."), TEXT("ACTION_ARM_*"), TEXT("bool"), TEXT("c0000_transition.dec.lua:624"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3036, TEXT("env(3036, SP_EF_REF_*)"), TEXT("BehaviorRefActive"), TEXT("BehaviorRef/TAE flag active check."), TEXT("SP_EF_REF_* or behaviorRefId"), TEXT("bool"), TEXT("c0000.dec.lua:154"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3037, TEXT("env(3037)"), TEXT("AllowStandEnter"), TEXT("Stand entry / force-crouch permission."), TEXT("none"), TEXT("bool"), TEXT("c0000.dec.lua:154"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::Medium));
		Result.Add(MakeEnvInfo(3038, TEXT("env(3038)"), TEXT("CanSwimToDive"), TEXT("Swim to dive condition."), TEXT("none"), TEXT("bool"), TEXT("c0000.dec.lua:772"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3039, TEXT("env(3039)"), TEXT("CanDiveToSwim"), TEXT("Dive to swim / surface condition."), TEXT("none"), TEXT("bool"), TEXT("c0000.dec.lua:768"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3040, TEXT("env(3040)"), TEXT("MapVisibilityType"), TEXT("Map visibility/darkness type."), TEXT("none"), TEXT("int MAP_VISIBILITY_TYPE_*"), TEXT("c0000_transition.dec.lua:5407"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3043, TEXT("env(3043)"), TEXT("CanStartCover"), TEXT("Cover start available."), TEXT("none"), TEXT("bool"), TEXT("c0000.dec.lua:737"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3044, TEXT("env(3044)"), TEXT("CanStartGroundHang"), TEXT("Ground hang start available."), TEXT("none"), TEXT("bool"), TEXT("c0000.dec.lua:748"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3045, TEXT("env(3045)"), TEXT("AirHangType"), TEXT("Air hang type."), TEXT("none"), TEXT("int AIR_HANG_TYPE_*"), TEXT("c0000.dec.lua:763"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3046, TEXT("env(3046, DOCKING_TGT_EDGE_TYPE_*)"), TEXT("DockingTargetEdgeType"), TEXT("Docking target edge type by request kind."), TEXT("DOCKING_TGT_EDGE_TYPE_*"), TEXT("int HANG_EDGE_TYPE_*"), TEXT("c0000_transition.dec.lua:4570"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3048, TEXT("env(3048)"), TEXT("HangOuterCornerLeftAvailable"), TEXT("Hang outer corner left available."), TEXT("none"), TEXT("bool"), TEXT("c0000_transition.dec.lua:4657"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3049, TEXT("env(3049)"), TEXT("HangOuterCornerRightAvailable"), TEXT("Hang outer corner right available."), TEXT("none"), TEXT("bool"), TEXT("c0000_transition.dec.lua:4663"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3050, TEXT("env(3050)"), TEXT("HangClimbAvailable"), TEXT("Hang climb/return to stand available."), TEXT("none"), TEXT("bool"), TEXT("c0000.dec.lua:753"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3051, TEXT("env(3051)"), TEXT("DockingLeftBlocked"), TEXT("Docking/corner left blocked or end flag."), TEXT("none"), TEXT("bool"), TEXT("c0000_transition.dec.lua:5756"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::Medium));
		Result.Add(MakeEnvInfo(3052, TEXT("env(3052)"), TEXT("DockingRightBlocked"), TEXT("Docking/corner right blocked or end flag."), TEXT("none"), TEXT("bool"), TEXT("c0000_transition.dec.lua:5756"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::Medium));
		Result.Add(MakeEnvInfo(3053, TEXT("env(3053)"), TEXT("TalkParamRefId"), TEXT("Talk param ref id."), TEXT("none"), TEXT("int TALK_PARAM_REF_RCV_*"), TEXT("c0000_transition.dec.lua:2280"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3054, TEXT("env(3054)"), TEXT("EzStateRefId"), TEXT("EZ-state ref id."), TEXT("none"), TEXT("int EZ_STATE_REF_RCV_*"), TEXT("c0000_transition.dec.lua:2208"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3055, TEXT("env(3055)"), TEXT("LoadInitPose"), TEXT("Initial load pose."), TEXT("none"), TEXT("int LOAD_INIT_POSE_*"), TEXT("c0000.dec.lua:159"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3056, TEXT("env(3056)"), TEXT("EasyDeflectAttackDirection"), TEXT("Easy/normal deflect attack direction."), TEXT("none"), TEXT("int DEFLECT_DIR_*"), TEXT("c0000_transition.dec.lua:1257"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3057, TEXT("env(3057)"), TEXT("HardDeflectAttackDirection"), TEXT("Hard/just deflect attack direction."), TEXT("none"), TEXT("int DEFLECT_DIR_*"), TEXT("c0000_transition.dec.lua:1255"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3058, TEXT("env(3058)"), TEXT("AddBlendSpeakState"), TEXT("Add-blend speak state."), TEXT("none"), TEXT("int ADD_BLEND_SPEAK_*"), TEXT("c0000.dec.lua:800"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3059, TEXT("env(3059)"), TEXT("HangInsideCornerLeftAvailable"), TEXT("Hang inside corner left available."), TEXT("none"), TEXT("bool"), TEXT("c0000_transition.dec.lua:4669"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3060, TEXT("env(3060)"), TEXT("HangInsideCornerRightAvailable"), TEXT("Hang inside corner right available."), TEXT("none"), TEXT("bool"), TEXT("c0000_transition.dec.lua:4675"), ESekiroEnvValueType::Bool, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3061, TEXT("env(3061)"), TEXT("SafePosReturnType"), TEXT("Safe-position return type."), TEXT("none"), TEXT("int SAFE_POS_RETURN_TYPE_*"), TEXT("c0000.dec.lua:160"), ESekiroEnvValueType::Int, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(3063, TEXT("env(3063, slot)"), TEXT("StartTimeMilliseconds"), TEXT("TAE/animation start time in milliseconds."), TEXT("0/1/2"), TEXT("float ms"), TEXT("c0000_transition.dec.lua:1805"), ESekiroEnvValueType::Float, ESekiroEnvConfidence::High));
		Result.Add(MakeEnvInfo(INDEX_NONE, TEXT("StrictBehaviorRefLifeExtension"), TEXT("NamedStrictBehaviorRefQuery"), TEXT("Named strict behavior-ref active query used for aging/life-extension checks."), TEXT("SP_EF_REF_AGING"), TEXT("bool"), TEXT("c0000.dec.lua:163"), ESekiroEnvValueType::StringKey, ESekiroEnvConfidence::High));
		return Result;
	}();

	return Infos;
}
