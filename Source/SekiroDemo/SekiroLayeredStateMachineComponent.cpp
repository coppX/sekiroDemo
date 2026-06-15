#include "SekiroLayeredStateMachineComponent.h"

USekiroLayeredStateMachineComponent::USekiroLayeredStateMachineComponent()
{
	PrimaryComponentTick.bCanEverTick = true;
}

void USekiroLayeredStateMachineComponent::BeginPlay()
{
	Super::BeginPlay();
	ResetLayerStates();
}

void USekiroLayeredStateMachineComponent::TickComponent(
	const float DeltaTime,
	const ELevelTick TickType,
	FActorComponentTickFunction* ThisTickFunction)
{
	Super::TickComponent(DeltaTime, TickType, ThisTickFunction);

	for (TPair<int32, FSekiroLayerStateRuntime>& LayerPair : Layers)
	{
		LayerPair.Value.StateElapsedSeconds += FMath::Max(DeltaTime, 0.0f);
		LayerPair.Value.bChangedThisFrame = false;
	}
}

void USekiroLayeredStateMachineComponent::ResetLayerStates()
{
	Layers.Reset();
	EnsureLayer(0, 0, TEXT("Idle"));
	EnsureLayer(1, 0, TEXT("ActionIdle"));
	EnsureLayer(2, 0, TEXT("ReactionIdle"));
}

bool USekiroLayeredStateMachineComponent::EnsureLayer(
	const int32 LayerId,
	const int32 DefaultStateId,
	const FString& DefaultStateName)
{
	if (Layers.Contains(LayerId))
	{
		return false;
	}

	FSekiroLayerStateRuntime Runtime;
	Runtime.LayerId = LayerId;
	Runtime.StateId = DefaultStateId;
	Runtime.PreviousStateId = DefaultStateId;
	Runtime.StateName = DefaultStateName.IsEmpty() ? TEXT("Idle") : DefaultStateName;
	Layers.Add(LayerId, Runtime);
	return true;
}

bool USekiroLayeredStateMachineComponent::SetLayerState(
	const int32 LayerId,
	const int32 StateId,
	const FString& StateName,
	const FString& EventName,
	const int32 DirectionId)
{
	EnsureLayer(LayerId);

	FSekiroLayerStateRuntime& Runtime = Layers.FindChecked(LayerId);
	const bool bStateChanged = Runtime.StateId != StateId || Runtime.LastEventName != EventName;
	const bool bDirectionChanged = Runtime.DirectionId != DirectionId;
	const bool bChanged = bStateChanged || bDirectionChanged;

	if (!bChanged)
	{
		return false;
	}

	Runtime.PreviousDirectionId = Runtime.DirectionId;
	Runtime.DirectionId = DirectionId;
	if (bStateChanged)
	{
		Runtime.PreviousStateId = Runtime.StateId;
		Runtime.StateId = StateId;
		Runtime.StateElapsedSeconds = 0.0f;
		Runtime.StateName = StateName.IsEmpty() ? FString::Printf(TEXT("State_%d"), StateId) : StateName;
		Runtime.LastEventName = EventName;
	}
	Runtime.bChangedThisFrame = true;
	return true;
}

FSekiroLayerStateRuntime USekiroLayeredStateMachineComponent::GetLayerState(const int32 LayerId) const
{
	if (const FSekiroLayerStateRuntime* Runtime = Layers.Find(LayerId))
	{
		return *Runtime;
	}

	FSekiroLayerStateRuntime EmptyRuntime;
	EmptyRuntime.LayerId = LayerId;
	return EmptyRuntime;
}

int32 USekiroLayeredStateMachineComponent::GetLayerStateId(const int32 LayerId) const
{
	if (const FSekiroLayerStateRuntime* Runtime = Layers.Find(LayerId))
	{
		return Runtime->StateId;
	}
	return 0;
}

int32 USekiroLayeredStateMachineComponent::GetLayerDirectionId(const int32 LayerId) const
{
	if (const FSekiroLayerStateRuntime* Runtime = Layers.Find(LayerId))
	{
		return Runtime->DirectionId;
	}
	return -1;
}

float USekiroLayeredStateMachineComponent::GetLayerStateElapsedSeconds(const int32 LayerId) const
{
	if (const FSekiroLayerStateRuntime* Runtime = Layers.Find(LayerId))
	{
		return Runtime->StateElapsedSeconds;
	}
	return 0.0f;
}

FString USekiroLayeredStateMachineComponent::GetLayerStateName(const int32 LayerId) const
{
	if (const FSekiroLayerStateRuntime* Runtime = Layers.Find(LayerId))
	{
		return Runtime->StateName;
	}
	return TEXT("Idle");
}

FString USekiroLayeredStateMachineComponent::GetLayerLastEventName(const int32 LayerId) const
{
	if (const FSekiroLayerStateRuntime* Runtime = Layers.Find(LayerId))
	{
		return Runtime->LastEventName;
	}
	return TEXT("W_BaseIdle");
}
