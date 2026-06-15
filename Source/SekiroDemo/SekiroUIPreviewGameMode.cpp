#include "SekiroUIPreviewGameMode.h"

#include "SekiroUIPreviewController.h"

ASekiroUIPreviewGameMode::ASekiroUIPreviewGameMode()
{
	PlayerControllerClass = ASekiroUIPreviewController::StaticClass();
}
