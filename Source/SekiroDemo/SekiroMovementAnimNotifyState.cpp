#include "SekiroMovementAnimNotifyState.h"

#include "SekiroC0000PreviewCharacter.h"
#include "SekiroEnemyCharacter.h"

#include "Components/SkeletalMeshComponent.h"

namespace
{
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

	int32 ResolveTaeIntParam(const int32 StructuredValue, const FString& SourceArguments, const TCHAR* ParamName)
	{
		if (StructuredValue != INDEX_NONE)
		{
			return StructuredValue;
		}

		float ParsedValue = 0.0f;
		return ExtractTaeParamFloat(SourceArguments, ParamName, ParsedValue)
			? FMath::RoundToInt(ParsedValue)
			: INDEX_NONE;
	}

	float ResolveTaeFloatParam(const float StructuredValue, const FString& SourceArguments, const TCHAR* ParamName)
	{
		float ParsedValue = 0.0f;
		return ExtractTaeParamFloat(SourceArguments, ParamName, ParsedValue)
			? ParsedValue
			: StructuredValue;
	}

	bool ParseTaeEventName(const FName EventName, int32& OutType, int32& OutJumpTableId)
	{
		OutType = INDEX_NONE;
		OutJumpTableId = INDEX_NONE;

		FString Text = EventName.ToString();
		if (!Text.RemoveFromStart(TEXT("TAE_")))
		{
			return false;
		}

		FString TypeText;
		FString JumpTableText;
		if (Text.Split(TEXT("_"), &TypeText, &JumpTableText))
		{
			if (!TypeText.IsNumeric() || !JumpTableText.IsNumeric())
			{
				return false;
			}

			OutType = FCString::Atoi(*TypeText);
			OutJumpTableId = FCString::Atoi(*JumpTableText);
			return true;
		}

		if (!Text.IsNumeric())
		{
			return false;
		}

		OutType = FCString::Atoi(*Text);
		return true;
	}

	FString ResolveTaeJumpTableDisplayName(const int32 JumpTableId)
	{
		switch (JumpTableId)
		{
		case 1: return TEXT("CancelStart_R1_R2_LightKick_HeavyKick");
		case 5: return TEXT("InvokeParriedState");
		case 6: return TEXT("Cancel_KeyboardKey");
		case 7: return TEXT("DisableTurning");
		case 9: return TEXT("CancelStart_L1_L2");
		case 10: return TEXT("CancelStart_MagicR_MagicL");
		case 11: return TEXT("EndIf_LSMoveQueued");
		case 21: return TEXT("CancelStart_Guard");
		case 25: return TEXT("CancelStart_StepRollJump");
		case 26: return TEXT("EndIf_DodgeQueued");
		case 30: return TEXT("CancelStart_UseItem");
		case 31: return TEXT("Cancel_UseItem");
		case 32: return TEXT("EndIf_WeaponSwitchQueued");
		case 34: return TEXT("Cancel_General");
		case 51: return TEXT("DontCancelIfFalling");
		case 56: return TEXT("SetStartbit13_DamageModule");
		case 63: return TEXT("RequestAiState");
		case 72: return TEXT("KnockbackValue");
		case 87: return TEXT("InvokeAttackAction_Complex");
		case 103: return TEXT("Cancel_L2");
		case 104: return TEXT("Cancel_L2_HksSet2011");
		case 105: return TEXT("CancelStart_L2");
		case 107: return TEXT("Cancel_UseItem_ByGoodsParam");
		case 108: return TEXT("CancelStart_UseItem_ByGoodsParam");
		case 111: return TEXT("CancelStart_EmergencyStep");
		case 112: return TEXT("Cancel_EmergencyStep");
		case 115: return TEXT("Cancel_R1_LightKick");
		case 116: return TEXT("Cancel_R2_HeavyKick");
		case 117: return TEXT("Cancel_L1");
		case 118: return TEXT("Cancel_L2");
		case 119: return TEXT("TryForceParryMode");
		case 120: return TEXT("CancelStart_L1_L2_ByWeaponParam");
		case 121: return TEXT("CancelExtra_L1_L2_ByWeaponParam");
		case 133: return TEXT("ProstheticSwitchBuffer");
		case 134: return TEXT("ProstheticSwitch");
		case 137: return TEXT("Cancel_R2_Prosthetic");
		case 150: return TEXT("SetLockCamParam");
		case 151: return TEXT("CameraLookAtTarget");
		case 154: return TEXT("Cancel_Deathblow");
		default: return FString();
		}
	}

	bool IsSpEffectTaeType(const int32 TaeType)
	{
		return TaeType == 66
			|| TaeType == 67
			|| TaeType == 302
			|| TaeType == 401
			|| TaeType == 797
			|| TaeType == 940;
	}

	FString FormatParamDisplayName(const TCHAR* Name, const int32 Value)
	{
		return Value != INDEX_NONE
			? FString::Printf(TEXT("%s(%d)"), Name, Value)
			: FString(Name);
	}

	FString ResolveTaeDisplayName(const USekiroMovementAnimNotifyState& Notify)
	{
		if (Notify.EventName == FName(TEXT("Gate_SpEffect")))
		{
			return FormatParamDisplayName(TEXT("Gate_SpEffect"), Notify.GetSpEffectID());
		}

		int32 TaeType = Notify.TaeType;
		int32 JumpTableId = Notify.GetTaeJumpTableID();
		if (TaeType == INDEX_NONE)
		{
			const FName TaeEventName = Notify.RawEventName.IsNone() ? Notify.EventName : Notify.RawEventName;
			if (!ParseTaeEventName(TaeEventName, TaeType, JumpTableId))
			{
				TaeType = FMath::RoundToInt(Notify.NumericValue);
			}
		}
		if (TaeType == 0)
		{
			float ParsedJumpTableId = 0.0f;
			const int32 EffectiveJumpTableId =
				Notify.GetTaeJumpTableID() != INDEX_NONE
					? Notify.GetTaeJumpTableID()
					: ExtractTaeParamFloat(Notify.SourceArguments, TEXT("JumpTableID"), ParsedJumpTableId)
					? FMath::RoundToInt(ParsedJumpTableId)
					: JumpTableId;
			return ResolveTaeJumpTableDisplayName(EffectiveJumpTableId);
		}

		if (TaeType == 16)
		{
			return TEXT("Blend");
		}
		if (TaeType == 1)
		{
			return TEXT("InvokeAttackBehavior");
		}
		if (TaeType == 2)
		{
			return TEXT("InvokeBulletBehavior");
		}
		if (TaeType == 32)
		{
			return TEXT("WeaponStyle");
		}
		if (TaeType == 96)
		{
			return TEXT("SpawnOneShotFFX");
		}
		if (TaeType == 112)
		{
			return TEXT("SpawnFFX_ByFloor");
		}
		if (TaeType == 128)
		{
			return TEXT("PlaySound_General");
		}
		if (TaeType == 129)
		{
			return TEXT("PlaySound_ByStateInfo");
		}
		if (TaeType == 224)
		{
			return TEXT("SetTurnSpeed");
		}
		if (TaeType == 226)
		{
			return TEXT("SetKnockbackPercent");
		}
		if (TaeType == 232)
		{
			return TEXT("Toughness");
		}
		if (TaeType == 307)
		{
			return TEXT("PCBehavior");
		}
		if (TaeType == 605)
		{
			return FormatParamDisplayName(
				TEXT("BlendToIdleOrMovementAnim"),
				ResolveTaeIntParam(Notify.GetAnimID(), Notify.SourceArguments, TEXT("AnimID")));
		}
		if (TaeType == 607)
		{
			const int32 FaceAnimType = FMath::RoundToInt(
				ResolveTaeFloatParam(Notify.GetTaeUnk00(), Notify.SourceArguments, TEXT("Unk00")));
			return FormatParamDisplayName(TEXT("FacialExpressionAdditive"), FaceAnimType);
		}
		if (TaeType == 700)
		{
			return TEXT("CustomLookAtTwist");
		}
		if (TaeType == 715)
		{
			return TEXT("WeaponModel");
		}
		if (TaeType == 760)
		{
			return TEXT("MoveMultiplier");
		}
		if (TaeType == 792)
		{
			return TEXT("FootSfx_Entity");
		}
		if (TaeType == 960)
		{
			return TEXT("StaminaControl");
		}
		if (IsSpEffectTaeType(TaeType))
		{
			float SpEffectId = 0.0f;
			const int32 EffectiveSpEffectId =
				Notify.GetSpEffectID() != INDEX_NONE
					? Notify.GetSpEffectID()
					: (ExtractTaeParamFloat(Notify.SourceArguments, TEXT("SpEffectID"), SpEffectId)
						|| ExtractTaeParamFloat(Notify.SourceArguments, TEXT("SpEffectId"), SpEffectId)
						|| ExtractTaeParamFloat(Notify.SourceArguments, TEXT("BehaviorJudgeId"), SpEffectId))
					? FMath::RoundToInt(SpEffectId)
					: INDEX_NONE;
			if (EffectiveSpEffectId != INDEX_NONE)
			{
				return FormatParamDisplayName(TEXT("Gate_SpEffect"), EffectiveSpEffectId);
			}
			return TEXT("Gate_SpEffect");
		}

		return FString();
	}

	void DispatchSekiroMovementAnimEvent(
		USkeletalMeshComponent* MeshComp,
		const USekiroMovementAnimNotifyState* Notify,
		const bool bActive)
	{
		if (!MeshComp || !Notify)
		{
			return;
		}

		ASekiroC0000PreviewCharacter* PreviewCharacter =
			Cast<ASekiroC0000PreviewCharacter>(MeshComp->GetOwner());
		if (PreviewCharacter)
		{
			PreviewCharacter->HandleSekiroMovementAnimEvent(
				Notify->EventName,
				bActive,
				Notify->NumericValue,
				Notify->SourceArguments,
				Notify->TaeType,
				Notify->GetAttackBehaviorJudgeID());
			return;
		}

		ASekiroEnemyCharacter* EnemyCharacter = Cast<ASekiroEnemyCharacter>(MeshComp->GetOwner());
		if (EnemyCharacter)
		{
			EnemyCharacter->HandleSekiroEnemyAnimEvent(
				Notify->EventName,
				bActive,
				Notify->TaeType,
				Notify->GetAttackBehaviorJudgeID(),
				Notify->SourceArguments);
		}
	}
}

void USekiroMovementAnimNotifyState::NotifyBegin(
	USkeletalMeshComponent* MeshComp,
	UAnimSequenceBase* Animation,
	float TotalDuration,
	const FAnimNotifyEventReference& EventReference)
{
	Super::NotifyBegin(MeshComp, Animation, TotalDuration, EventReference);
	DispatchSekiroMovementAnimEvent(MeshComp, this, true);
}

void USekiroMovementAnimNotifyState::NotifyEnd(
	USkeletalMeshComponent* MeshComp,
	UAnimSequenceBase* Animation,
	const FAnimNotifyEventReference& EventReference)
{
	Super::NotifyEnd(MeshComp, Animation, EventReference);
	DispatchSekiroMovementAnimEvent(MeshComp, this, false);
}

FString USekiroMovementAnimNotifyState::GetNotifyName_Implementation() const
{
	if (!EventName.IsNone())
	{
		const FString DisplayName = ResolveTaeDisplayName(*this);
		if (!DisplayName.IsEmpty())
		{
			return DisplayName;
		}

		return EventName.ToString();
	}

	return StaticEnum<ESekiroMovementAnimEventType>()->GetNameStringByValue(
		static_cast<int64>(EventType)
	);
}

int32 USekiroMovementAnimNotifyState::GetSpEffectID() const
{
	return INDEX_NONE;
}

int32 USekiroMovementAnimNotifyState::GetTaeJumpTableID() const
{
	return INDEX_NONE;
}

int32 USekiroMovementAnimNotifyState::GetAttackBehaviorJudgeID() const
{
	return INDEX_NONE;
}

int32 USekiroMovementAnimNotifyState::GetAnimID() const
{
	return INDEX_NONE;
}

float USekiroMovementAnimNotifyState::GetTaeUnk00() const
{
	return 0.0f;
}

int32 USekiroTaeAttackBehaviorNotifyState::GetAttackBehaviorJudgeID() const
{
	return BehaviorJudgeID;
}

int32 USekiroTaeJumpTableNotifyState::GetTaeJumpTableID() const
{
	return JumpTableID;
}

int32 USekiroTaeSpEffectNotifyState::GetSpEffectID() const
{
	return SpEffectID;
}

int32 USekiroTaeAnimBlendNotifyState::GetAnimID() const
{
	return AnimID;
}

float USekiroTaeUnknownVectorNotifyState::GetTaeUnk00() const
{
	return TaeUnk00;
}
