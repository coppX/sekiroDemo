#include "SekiroUIPreviewController.h"

#include "Blueprint/WidgetBlueprintLibrary.h"
#include "Components/PanelWidget.h"
#include "Components/TextBlock.h"
#include "Engine/GameViewportClient.h"
#include "Engine/World.h"

namespace
{
	UWidget* FindWidgetRecursive(UWidget* Widget, const FName TargetName)
	{
		if (!Widget)
		{
			return nullptr;
		}

		if (Widget->GetFName() == TargetName)
		{
			return Widget;
		}

		const UPanelWidget* PanelWidget = Cast<UPanelWidget>(Widget);
		if (!PanelWidget)
		{
			return nullptr;
		}

		const int32 ChildCount = PanelWidget->GetChildrenCount();
		for (int32 ChildIndex = 0; ChildIndex < ChildCount; ++ChildIndex)
		{
			if (UWidget* FoundWidget = FindWidgetRecursive(PanelWidget->GetChildAt(ChildIndex), TargetName))
			{
				return FoundWidget;
			}
		}

		return nullptr;
	}
}

ASekiroUIPreviewController::ASekiroUIPreviewController()
{
	PrimaryActorTick.bCanEverTick = true;
	bShowMouseCursor = false;
	bEnableClickEvents = false;
	bEnableMouseOverEvents = false;
}

void ASekiroUIPreviewController::BeginPlay()
{
	Super::BeginPlay();

	ApplyGameplayPreviewInputMode();
}

void ASekiroUIPreviewController::SetPawn(APawn* InPawn)
{
	Super::SetPawn(InPawn);

	ApplyGameplayPreviewInputMode();
}

FString ASekiroUIPreviewController::GetModuleName_Implementation() const
{
	return TEXT("Main");
}

void ASekiroUIPreviewController::ApplyGameplayPreviewInputMode()
{
	FInputModeGameOnly InputMode;
	SetInputMode(InputMode);

	bShowMouseCursor = false;
	bEnableClickEvents = false;
	bEnableMouseOverEvents = false;
	SetIgnoreMoveInput(false);
	SetIgnoreLookInput(false);

	UWidgetBlueprintLibrary::SetFocusToGameViewport();

	if (UGameViewportClient* GameViewport = GetWorld() ? GetWorld()->GetGameViewport() : nullptr)
	{
		GameViewport->SetIgnoreInput(false);
	}
}

UWidget* ASekiroUIPreviewController::FindNamedWidget(UUserWidget* WidgetRoot, const FString& WidgetName) const
{
	if (!WidgetRoot || WidgetName.IsEmpty())
	{
		return nullptr;
	}

	return FindWidgetRecursive(WidgetRoot->GetRootWidget(), FName(*WidgetName));
}

void ASekiroUIPreviewController::SetTextBlockLinearColor(UWidget* Widget, const FLinearColor& Color) const
{
	if (UTextBlock* TextBlock = Cast<UTextBlock>(Widget))
	{
		TextBlock->SetColorAndOpacity(FSlateColor(Color));
	}
}
