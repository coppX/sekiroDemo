#include "SekiroSimpleMovementAnimInstance.h"

void USekiroSimpleMovementAnimInstance::SetSimpleMovementState(
	const int32 InLayerId,
	const int32 InStateId,
	const int32 InPreviousStateId,
	const int32 InDirectionId,
	const float InStateElapsedSeconds)
{
	LayerId = InLayerId;
	PreviousStateId = InPreviousStateId;
	StateId = InStateId;
	DirectionId = InDirectionId;
	StateElapsedSeconds = FMath::Max(InStateElapsedSeconds, 0.0f);
}
