// Copyright Epic Games, Inc. All Rights Reserved.

using UnrealBuildTool;

public class SekiroDemo : ModuleRules
{
	public SekiroDemo(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;
	
		PublicDependencyModuleNames.AddRange(new string[] { "Core", "CoreUObject", "Engine", "AIModule", "InputCore", "EnhancedInput", "UMG", "UnLua", "Lua" });

		PrivateDependencyModuleNames.AddRange(new string[] { "Slate", "SlateCore", "AnimGraphRuntime" });

		// Uncomment if you are using online features
		// PrivateDependencyModuleNames.Add("OnlineSubsystem");

		// To include OnlineSubsystemSteam, add it to the plugins section in your uproject file with the Enabled attribute set to true
	}
}
