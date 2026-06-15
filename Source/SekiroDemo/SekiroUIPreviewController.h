#pragma once

#include "CoreMinimal.h"
#include "Blueprint/UserWidget.h"
#include "Components/Widget.h"
#include "Math/Color.h"
#include "GameFramework/PlayerController.h"
#include "UnLuaInterface.h"
#include "SekiroUIPreviewController.generated.h"

UCLASS()
class SEKIRODEMO_API ASekiroUIPreviewController : public APlayerController, public IUnLuaInterface
{
	GENERATED_BODY()

public:
	ASekiroUIPreviewController();

	virtual void BeginPlay() override;
	virtual void SetPawn(APawn* InPawn) override;
	virtual FString GetModuleName_Implementation() const override;

	UFUNCTION(BlueprintCallable, Category = "Sekiro UI")
	void ApplyGameplayPreviewInputMode();

	UFUNCTION(BlueprintCallable, Category = "Sekiro UI")
	UWidget* FindNamedWidget(UUserWidget* WidgetRoot, const FString& WidgetName) const;

	UFUNCTION(BlueprintCallable, Category = "Sekiro UI")
	void SetTextBlockLinearColor(UWidget* Widget, const FLinearColor& Color) const;
};
