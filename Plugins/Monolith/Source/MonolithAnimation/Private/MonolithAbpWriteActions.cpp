#include "MonolithAbpWriteActions.h"
#include "MonolithAssetUtils.h"
#include "MonolithParamSchema.h"

#include "Animation/AnimBlueprint.h"
#include "Animation/AnimSequence.h"
#include "Animation/BlendSpace.h"
#include "Animation/AnimationAsset.h"
#include "AnimGraphNode_Base.h"
#include "AnimGraphNode_AssetPlayerBase.h"
#include "AnimGraphNode_SequencePlayer.h"
#include "AnimGraphNode_BlendSpacePlayer.h"
#include "AnimGraphNode_TwoWayBlend.h"
#include "AnimGraphNode_BlendListByBool.h"
#include "AnimGraphNode_LayeredBoneBlend.h"
#include "AnimGraphNode_StateMachine.h"
#include "AnimGraphNode_StateResult.h"
#include "AnimGraphNode_TwoBoneIK.h"
#include "AnimGraphNode_ModifyBone.h"
#include "AnimGraphNode_LocalToComponentSpace.h"
#include "AnimGraphNode_ComponentToLocalSpace.h"
#include "K2Node_VariableGet.h"
#include "BoneControllers/AnimNode_SkeletalControlBase.h"
#include "Engine/MemberReference.h"
#include "AnimationGraph.h"
#include "AnimationStateGraph.h"
#include "AnimationStateMachineGraph.h"
#include "AnimationGraphSchema.h"
#include "AnimationStateMachineSchema.h"
#include "AnimStateAliasNode.h"
#include "AnimStateNode.h"
#include "AnimStateTransitionNode.h"
#include "EdGraphSchema_K2_Actions.h"
#include "Kismet2/BlueprintEditorUtils.h"
#include "Kismet2/KismetEditorUtilities.h"
#include "Dom/JsonObject.h"
#include "Dom/JsonValue.h"
#include "Editor.h"

// PoseSearchEditor module — provides UAnimGraphNode_MotionMatching
#include "AnimGraphNode_MotionMatching.h"

// ---------------------------------------------------------------------------
// Registration
// ---------------------------------------------------------------------------

void FMonolithAbpWriteActions::RegisterActions(FMonolithToolRegistry& Registry)
{
	// --- add_anim_graph_node ---
	Registry.RegisterAction(TEXT("animation"), TEXT("add_anim_graph_node"),
		TEXT("Place an animation graph node (SequencePlayer, BlendSpacePlayer, TwoWayBlend, BlendListByBool, LayeredBoneBlend, MotionMatching, TwoBoneIK, ModifyBone, LocalToComponentSpace, ComponentToLocalSpace) in a state or the main AnimGraph"),
		FMonolithActionHandler::CreateStatic(&HandleAddAnimGraphNode),
		FParamSchemaBuilder()
			.Required(TEXT("asset_path"), TEXT("string"), TEXT("Animation Blueprint asset path"))
			.Required(TEXT("node_type"), TEXT("string"), TEXT("Node type: SequencePlayer, BlendSpacePlayer, TwoWayBlend, BlendListByBool, LayeredBoneBlend, MotionMatching, TwoBoneIK, ModifyBone, LocalToComponentSpace, ComponentToLocalSpace"))
			.Optional(TEXT("graph_name"), TEXT("string"), TEXT("Target graph name — 'AnimGraph' for top-level, or a state name for state inner graphs (default: AnimGraph)"), TEXT("AnimGraph"))
			.Optional(TEXT("state_name"), TEXT("string"), TEXT("State name — if set, node is placed inside this state's inner graph (searched within the state machine found via graph_name if graph_name is a SM name, otherwise searches all SMs)"))
			.Optional(TEXT("position_x"), TEXT("number"), TEXT("Node X position (default: 200)"), TEXT("200"))
			.Optional(TEXT("position_y"), TEXT("number"), TEXT("Node Y position (default: 0)"), TEXT("0"))
			.Optional(TEXT("anim_asset"), TEXT("string"), TEXT("Animation/BlendSpace asset path — for SequencePlayer and BlendSpacePlayer nodes"))
			.Optional(TEXT("ik_bone"), TEXT("string"), TEXT("TwoBoneIK only: end-of-chain bone name (e.g. 'hand_l')"))
			.Optional(TEXT("effector_space"), TEXT("string"), TEXT("TwoBoneIK only: EffectorLocationSpace — WorldSpace, ComponentSpace (default), ParentBoneSpace, BoneSpace"))
			.Optional(TEXT("joint_target_space"), TEXT("string"), TEXT("TwoBoneIK only: JointTargetLocationSpace — WorldSpace, ComponentSpace (default), ParentBoneSpace, BoneSpace"))
			.Optional(TEXT("bone_to_modify"), TEXT("string"), TEXT("ModifyBone only: bone to modify (e.g. 'spine_01')"))
			.Optional(TEXT("expose_pins"), TEXT("array"), TEXT("Names of optional properties to expose as input pins (e.g. ['EffectorLocation','JointTargetLocation','Alpha']). TwoBoneIK exposes these three by default."))
			.Build());

	// --- connect_anim_graph_pins ---
	Registry.RegisterAction(TEXT("animation"), TEXT("connect_anim_graph_pins"),
		TEXT("Wire two node pins together in an ABP anim graph. Use after add_anim_graph_node to connect pose outputs to inputs."),
		FMonolithActionHandler::CreateStatic(&HandleConnectAnimGraphPins),
		FParamSchemaBuilder()
			.Required(TEXT("asset_path"), TEXT("string"), TEXT("Animation Blueprint asset path"))
			.Required(TEXT("source_node"), TEXT("string"), TEXT("Source node name (UObject name from add_anim_graph_node response, or class-based like AnimGraphNode_SequencePlayer_0)"))
			.Required(TEXT("source_pin"), TEXT("string"), TEXT("Source pin name, e.g. 'Pose' (output pin)"))
			.Required(TEXT("target_node"), TEXT("string"), TEXT("Target node name"))
			.Required(TEXT("target_pin"), TEXT("string"), TEXT("Target pin name, e.g. 'Result', 'A', 'B', 'BlendPose_0'"))
			.Optional(TEXT("graph_name"), TEXT("string"), TEXT("Graph name to search in (default: searches all graphs)"))
			.Optional(TEXT("state_name"), TEXT("string"), TEXT("State name to search in — narrows to a specific state's inner graph"))
			.Optional(TEXT("compile"), TEXT("bool"), TEXT("Compile ABP after wiring (default: true)"), TEXT("true"))
			.Build());

	// --- set_state_animation ---
	Registry.RegisterAction(TEXT("animation"), TEXT("set_state_animation"),
		TEXT("High-level shortcut: set which animation a state plays by spawning the right player node and wiring it to the state result. Handles SequencePlayer vs BlendSpacePlayer automatically."),
		FMonolithActionHandler::CreateStatic(&HandleSetStateAnimation),
		FParamSchemaBuilder()
			.Required(TEXT("asset_path"), TEXT("string"), TEXT("Animation Blueprint asset path"))
			.Required(TEXT("machine_name"), TEXT("string"), TEXT("State machine name (as shown in get_state_machines)"))
			.Required(TEXT("state_name"), TEXT("string"), TEXT("State name to set animation for"))
			.Required(TEXT("anim_asset_path"), TEXT("string"), TEXT("AnimSequence or BlendSpace asset path"))
			.Optional(TEXT("loop"), TEXT("bool"), TEXT("Set loop flag on the player node"), TEXT("false"))
			.Optional(TEXT("clear_existing"), TEXT("bool"), TEXT("Remove existing animation nodes wired to the state result (default: true)"), TEXT("true"))
			.Build());

	// --- add_variable_get ---
	Registry.RegisterAction(TEXT("animation"), TEXT("add_variable_get"),
		TEXT("Place a variable Get node (K2Node_VariableGet) in the AnimGraph — used to drive AnimGraph pins from AnimInstance members."),
		FMonolithActionHandler::CreateStatic(&HandleAddVariableGet),
		FParamSchemaBuilder()
			.Required(TEXT("asset_path"), TEXT("string"), TEXT("Animation Blueprint asset path"))
			.Required(TEXT("variable_name"), TEXT("string"), TEXT("Variable name as exposed on the AnimInstance (C++ UPROPERTY or BP variable)"))
			.Optional(TEXT("graph_name"), TEXT("string"), TEXT("Target graph name (default: AnimGraph)"), TEXT("AnimGraph"))
			.Optional(TEXT("state_name"), TEXT("string"), TEXT("Optional state name to scope the search to a state inner graph"))
			.Optional(TEXT("position_x"), TEXT("number"), TEXT("Node X position (default: 0)"), TEXT("0"))
			.Optional(TEXT("position_y"), TEXT("number"), TEXT("Node Y position (default: 0)"), TEXT("0"))
			.Build());

	// --- set_anim_graph_node_property ---
	// Mutates a property on the *source* UAnimGraphNode's inner FAnimNode struct.
	// Writing via blueprint.set_cdo_property is wiped on compile because the AnimBP's
	// CDO is regenerated from the graph nodes — this action edits the authoritative
	// source so the change persists.
	Registry.RegisterAction(TEXT("animation"), TEXT("set_anim_graph_node_property"),
		TEXT("Mutate a property on an existing anim graph node's internal FAnimNode struct (e.g. ModifyBone.BoneToModify.BoneName, ModifyBone.RotationMode, TwoBoneIK.EffectorLocationSpace). Persists across compile — writes to the source UAnimGraphNode, not the CDO."),
		FMonolithActionHandler::CreateStatic(&HandleSetAnimGraphNodeProperty),
		FParamSchemaBuilder()
			.Required(TEXT("asset_path"), TEXT("string"), TEXT("Animation Blueprint asset path"))
			.Required(TEXT("node_id"), TEXT("string"), TEXT("Node UObject name (e.g. 'AnimGraphNode_ModifyBone_7') — same id surfaced by get_graph_summary / add_anim_graph_node response"))
			.Required(TEXT("property_path"), TEXT("string"), TEXT("Dotted property path inside the node's inner FAnimNode struct (e.g. 'BoneToModify.BoneName', 'RotationMode', 'EffectorLocationSpace', 'Alpha'). Do NOT prefix with 'Node.'."))
			.Required(TEXT("value"), TEXT("string"), TEXT("Value as text — same format as ImportText in the Details panel. Enums: bare name (e.g. 'BMM_Additive', 'BCS_ComponentSpace'). FName: bare name. Struct: '(Field=Value,...)'."))
			.Optional(TEXT("graph_name"), TEXT("string"), TEXT("Graph name to scope the search (default: searches all graphs)"))
			.Optional(TEXT("state_name"), TEXT("string"), TEXT("State name to narrow the search to a specific state's inner graph"))
			.Build());

	Registry.RegisterAction(TEXT("animation"), TEXT("rename_state_machine"),
		TEXT("Rename an animation blueprint state machine graph without rebuilding its states"),
		FMonolithActionHandler::CreateStatic(&HandleRenameStateMachine),
		FParamSchemaBuilder()
			.Required(TEXT("asset_path"), TEXT("string"), TEXT("Animation Blueprint asset path"))
			.Required(TEXT("old_name"), TEXT("string"), TEXT("Existing state machine name"))
			.Required(TEXT("new_name"), TEXT("string"), TEXT("New state machine name"))
			.Build());

	Registry.RegisterAction(TEXT("animation"), TEXT("move_state_machine_to_state"),
		TEXT("Move an existing state machine node into a state graph and preserve its internal state machine graph"),
		FMonolithActionHandler::CreateStatic(&HandleMoveStateMachineToState),
		FParamSchemaBuilder()
			.Required(TEXT("asset_path"), TEXT("string"), TEXT("Animation Blueprint asset path"))
			.Required(TEXT("machine_name"), TEXT("string"), TEXT("State machine to move"))
			.Required(TEXT("target_machine_name"), TEXT("string"), TEXT("Parent state machine containing target state"))
			.Required(TEXT("target_state_name"), TEXT("string"), TEXT("State whose inner graph will receive the moved state machine"))
			.Optional(TEXT("position_x"), TEXT("number"), TEXT("Node X position in target state graph"), TEXT("0"))
			.Optional(TEXT("position_y"), TEXT("number"), TEXT("Node Y position in target state graph"), TEXT("0"))
			.Build());
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

namespace
{

/** Map a user-facing node type string to UClass. Returns nullptr on unknown type. */
UClass* ResolveNodeClass(const FString& NodeType)
{
	if (NodeType.Equals(TEXT("SequencePlayer"), ESearchCase::IgnoreCase))
		return UAnimGraphNode_SequencePlayer::StaticClass();
	if (NodeType.Equals(TEXT("BlendSpacePlayer"), ESearchCase::IgnoreCase))
		return UAnimGraphNode_BlendSpacePlayer::StaticClass();
	if (NodeType.Equals(TEXT("TwoWayBlend"), ESearchCase::IgnoreCase))
		return UAnimGraphNode_TwoWayBlend::StaticClass();
	if (NodeType.Equals(TEXT("BlendListByBool"), ESearchCase::IgnoreCase))
		return UAnimGraphNode_BlendListByBool::StaticClass();
	if (NodeType.Equals(TEXT("LayeredBoneBlend"), ESearchCase::IgnoreCase))
		return UAnimGraphNode_LayeredBoneBlend::StaticClass();
	if (NodeType.Equals(TEXT("MotionMatching"), ESearchCase::IgnoreCase))
		return UAnimGraphNode_MotionMatching::StaticClass();
	if (NodeType.Equals(TEXT("TwoBoneIK"), ESearchCase::IgnoreCase))
		return UAnimGraphNode_TwoBoneIK::StaticClass();
	if (NodeType.Equals(TEXT("ModifyBone"), ESearchCase::IgnoreCase))
		return UAnimGraphNode_ModifyBone::StaticClass();
	if (NodeType.Equals(TEXT("LocalToComponentSpace"), ESearchCase::IgnoreCase))
		return UAnimGraphNode_LocalToComponentSpace::StaticClass();
	if (NodeType.Equals(TEXT("ComponentToLocalSpace"), ESearchCase::IgnoreCase))
		return UAnimGraphNode_ComponentToLocalSpace::StaticClass();
	if (NodeType.Equals(TEXT("StateMachine"), ESearchCase::IgnoreCase))
		return UAnimGraphNode_StateMachine::StaticClass();
	return nullptr;
}

/** Parse a bone-control-space string. Defaults to ComponentSpace when missing/unrecognized. */
EBoneControlSpace ParseBoneControlSpace(const FString& Str, EBoneControlSpace Default = BCS_ComponentSpace)
{
	if (Str.Equals(TEXT("WorldSpace"), ESearchCase::IgnoreCase))      return BCS_WorldSpace;
	if (Str.Equals(TEXT("ComponentSpace"), ESearchCase::IgnoreCase))  return BCS_ComponentSpace;
	if (Str.Equals(TEXT("ParentBoneSpace"), ESearchCase::IgnoreCase)) return BCS_ParentBoneSpace;
	if (Str.Equals(TEXT("BoneSpace"), ESearchCase::IgnoreCase))       return BCS_BoneSpace;
	return Default;
}

/** Find a state machine graph by its display title (same lookup as Wave 10 add_state_to_machine). */
UAnimationStateMachineGraph* FindSMGraphByName(UAnimBlueprint* ABP, const FString& MachineName)
{
	TSet<UEdGraph*> VisitedGraphs;
	TFunction<UAnimationStateMachineGraph*(UEdGraph*)> SearchGraph = [&](UEdGraph* Graph) -> UAnimationStateMachineGraph*
	{
		if (!Graph || VisitedGraphs.Contains(Graph)) return nullptr;
		VisitedGraphs.Add(Graph);

		for (UEdGraphNode* Node : Graph->Nodes)
		{
			UAnimGraphNode_StateMachine* SMNode = Cast<UAnimGraphNode_StateMachine>(Node);
			if (!SMNode) continue;

			FString SMTitle = SMNode->GetNodeTitle(ENodeTitleType::FullTitle).ToString();
			int32 NewlineIdx = INDEX_NONE;
			if (SMTitle.FindChar(TEXT('\n'), NewlineIdx))
			{
				SMTitle.LeftInline(NewlineIdx);
			}

			UAnimationStateMachineGraph* SMGraph = Cast<UAnimationStateMachineGraph>(SMNode->EditorStateMachineGraph);
			if (SMTitle == MachineName)
			{
				return SMGraph;
			}
			if (UAnimationStateMachineGraph* Found = SearchGraph(SMGraph))
			{
				return Found;
			}
			if (SMGraph)
			{
				for (UEdGraphNode* ChildNode : SMGraph->Nodes)
				{
					if (UAnimStateNode* StateNode = Cast<UAnimStateNode>(ChildNode))
					{
						if (UAnimationStateMachineGraph* Found = SearchGraph(StateNode->BoundGraph))
						{
							return Found;
						}
					}
				}
			}
		}
		return nullptr;
	};

	for (UEdGraph* Graph : ABP->FunctionGraphs)
	{
		if (UAnimationStateMachineGraph* Found = SearchGraph(Graph))
		{
			return Found;
		}
	}
	return nullptr;
}

UAnimGraphNode_StateMachine* FindSMNodeByName(UAnimBlueprint* ABP, const FString& MachineName)
{
	TSet<UEdGraph*> VisitedGraphs;
	TFunction<UAnimGraphNode_StateMachine*(UEdGraph*)> SearchGraph = [&](UEdGraph* Graph) -> UAnimGraphNode_StateMachine*
	{
		if (!Graph || VisitedGraphs.Contains(Graph)) return nullptr;
		VisitedGraphs.Add(Graph);

		for (UEdGraphNode* Node : Graph->Nodes)
		{
			UAnimGraphNode_StateMachine* SMNode = Cast<UAnimGraphNode_StateMachine>(Node);
			if (!SMNode) continue;

			FString SMTitle = SMNode->GetNodeTitle(ENodeTitleType::FullTitle).ToString();
			int32 NewlineIdx = INDEX_NONE;
			if (SMTitle.FindChar(TEXT('\n'), NewlineIdx))
			{
				SMTitle.LeftInline(NewlineIdx);
			}
			if (SMTitle == MachineName)
			{
				return SMNode;
			}

			UAnimationStateMachineGraph* SMGraph = Cast<UAnimationStateMachineGraph>(SMNode->EditorStateMachineGraph);
			if (UAnimGraphNode_StateMachine* Found = SearchGraph(SMGraph))
			{
				return Found;
			}
			if (SMGraph)
			{
				for (UEdGraphNode* ChildNode : SMGraph->Nodes)
				{
					if (UAnimStateNode* StateNode = Cast<UAnimStateNode>(ChildNode))
					{
						if (UAnimGraphNode_StateMachine* Found = SearchGraph(StateNode->BoundGraph))
						{
							return Found;
						}
					}
				}
			}
		}
		return nullptr;
	};

	for (UEdGraph* Graph : ABP->FunctionGraphs)
	{
		if (UAnimGraphNode_StateMachine* Found = SearchGraph(Graph))
		{
			return Found;
		}
	}
	return nullptr;
}

/** Find a state node by name within a state machine graph. */
UAnimStateNode* FindStateByName(UAnimationStateMachineGraph* SMGraph, const FString& StateName)
{
	for (UEdGraphNode* Node : SMGraph->Nodes)
	{
		UAnimStateNode* StateNode = Cast<UAnimStateNode>(Node);
		if (StateNode && StateNode->GetStateName() == StateName)
		{
			return StateNode;
		}
	}
	return nullptr;
}

UAnimStateNodeBase* FindStateNodeBaseByName(UAnimationStateMachineGraph* SMGraph, const FString& StateName)
{
	for (UEdGraphNode* Node : SMGraph->Nodes)
	{
		UAnimStateNodeBase* StateNode = Cast<UAnimStateNodeBase>(Node);
		if (StateNode && StateNode->GetStateName() == StateName)
		{
			return StateNode;
		}
	}
	return nullptr;
}

/** Find a state node by name below a graph, including state machines nested in state graphs. */
UAnimStateNode* FindStateByNameRecursive(UEdGraph* Graph, const FString& StateName, const FString& MachineName, TSet<UEdGraph*>& VisitedGraphs)
{
	if (!Graph || VisitedGraphs.Contains(Graph))
	{
		return nullptr;
	}
	VisitedGraphs.Add(Graph);

	for (UEdGraphNode* Node : Graph->Nodes)
	{
		UAnimGraphNode_StateMachine* SMNode = Cast<UAnimGraphNode_StateMachine>(Node);
		if (!SMNode)
		{
			continue;
		}

		FString SMTitle = SMNode->GetNodeTitle(ENodeTitleType::FullTitle).ToString();
		int32 NewlineIdx = INDEX_NONE;
		if (SMTitle.FindChar(TEXT('\n'), NewlineIdx))
		{
			SMTitle.LeftInline(NewlineIdx);
		}

		UAnimationStateMachineGraph* SMGraph = Cast<UAnimationStateMachineGraph>(SMNode->EditorStateMachineGraph);
		if (!SMGraph)
		{
			continue;
		}

		if (MachineName.IsEmpty() || SMTitle == MachineName)
		{
			if (UAnimStateNode* FoundState = FindStateByName(SMGraph, StateName))
			{
				return FoundState;
			}
		}

		if (UAnimStateNode* FoundState = FindStateByNameRecursive(SMGraph, StateName, MachineName, VisitedGraphs))
		{
			return FoundState;
		}

		for (UEdGraphNode* ChildNode : SMGraph->Nodes)
		{
			if (UAnimStateNode* ChildState = Cast<UAnimStateNode>(ChildNode))
			{
				if (UAnimStateNode* FoundState = FindStateByNameRecursive(ChildState->BoundGraph, StateName, MachineName, VisitedGraphs))
				{
					return FoundState;
				}
			}
		}
	}

	return nullptr;
}

/**
 * Resolve the target graph from graph_name and state_name parameters.
 * - If state_name is provided, searches all state machines for that state and returns its inner graph.
 * - If graph_name is "AnimGraph", returns the top-level AnimGraph.
 * - Otherwise treats graph_name as a state machine name and looks for state_name within it.
 */
UEdGraph* ResolveTargetGraph(UAnimBlueprint* ABP, const FString& GraphName, const FString& StateName, FString& OutError)
{
	// If state_name is specified, find the state and return its inner graph
	if (!StateName.IsEmpty())
	{
		// Search all state machines for this state, including state machines nested in state graphs.
		for (UEdGraph* Graph : ABP->FunctionGraphs)
		{
			TSet<UEdGraph*> VisitedGraphs;
			UAnimStateNode* StateNode = FindStateByNameRecursive(Graph, StateName, GraphName, VisitedGraphs);
			if (!StateNode)
			{
				continue;
			}

			UAnimationStateGraph* StateGraph = Cast<UAnimationStateGraph>(StateNode->BoundGraph);
			if (!StateGraph)
			{
				OutError = FString::Printf(TEXT("State '%s' has no inner animation graph (BoundGraph is null)"), *StateName);
				return nullptr;
			}
			return StateGraph;
		}
		OutError = FString::Printf(TEXT("State '%s' not found in any state machine"), *StateName);
		return nullptr;
	}

	// No state_name — use graph_name
	if (GraphName.Equals(TEXT("AnimGraph"), ESearchCase::IgnoreCase) || GraphName.IsEmpty())
	{
		// Find the main AnimGraph (first UAnimationGraph in FunctionGraphs)
		for (UEdGraph* Graph : ABP->FunctionGraphs)
		{
			if (UAnimationGraph* AG = Cast<UAnimationGraph>(Graph))
			{
				return AG;
			}
		}
		OutError = TEXT("No AnimGraph found in this Animation Blueprint");
		return nullptr;
	}

	if (UAnimationStateMachineGraph* SMGraph = FindSMGraphByName(ABP, GraphName))
	{
		return SMGraph;
	}

	// Treat graph_name as a named function graph
	for (UEdGraph* Graph : ABP->FunctionGraphs)
	{
		if (Graph && Graph->GetName() == GraphName)
		{
			return Graph;
		}
	}
	OutError = FString::Printf(TEXT("Graph '%s' not found. Use 'AnimGraph' for the main graph, or provide state_name to target a state's inner graph."), *GraphName);
	return nullptr;
}

/** Find a node by UObject name across all graphs in an ABP, or within a specific graph. */
UEdGraphNode* FindNodeByName(UAnimBlueprint* ABP, const FString& NodeName, UEdGraph* InGraph = nullptr)
{
	auto SearchGraph = [&](UEdGraph* Graph) -> UEdGraphNode*
	{
		if (!Graph) return nullptr;
		for (UEdGraphNode* Node : Graph->Nodes)
		{
			if (Node && Node->GetName() == NodeName)
			{
				return Node;
			}
		}
		return nullptr;
	};

	if (InGraph)
	{
		return SearchGraph(InGraph);
	}

	// Search all function graphs and their subgraphs
	for (UEdGraph* Graph : ABP->FunctionGraphs)
	{
		if (UEdGraphNode* Found = SearchGraph(Graph))
			return Found;

		// Search inside state machine graphs
		if (!Graph) continue;
		for (UEdGraphNode* Node : Graph->Nodes)
		{
			UAnimGraphNode_StateMachine* SMNode = Cast<UAnimGraphNode_StateMachine>(Node);
			if (!SMNode) continue;

			UAnimationStateMachineGraph* SMGraph = Cast<UAnimationStateMachineGraph>(SMNode->EditorStateMachineGraph);
			if (!SMGraph) continue;

			if (UEdGraphNode* Found = SearchGraph(SMGraph))
				return Found;

			// Search inside each state's inner graph
			for (UEdGraphNode* SMChild : SMGraph->Nodes)
			{
				UAnimStateNode* StateNode = Cast<UAnimStateNode>(SMChild);
				if (!StateNode || !StateNode->BoundGraph) continue;

				if (UEdGraphNode* Found = SearchGraph(StateNode->BoundGraph))
					return Found;
			}
		}
	}
	return nullptr;
}

/** Build a JSON array describing a node's pins. */
TArray<TSharedPtr<FJsonValue>> BuildPinList(UEdGraphNode* Node)
{
	TArray<TSharedPtr<FJsonValue>> PinsArr;
	for (UEdGraphPin* Pin : Node->Pins)
	{
		if (!Pin) continue;

		TSharedPtr<FJsonObject> PinObj = MakeShared<FJsonObject>();
		PinObj->SetStringField(TEXT("name"), Pin->PinName.ToString());
		PinObj->SetStringField(TEXT("direction"), Pin->Direction == EGPD_Input ? TEXT("Input") : TEXT("Output"));
		PinObj->SetBoolField(TEXT("is_pose"), UAnimationGraphSchema::IsPosePin(Pin->PinType));
		PinObj->SetBoolField(TEXT("is_connected"), Pin->LinkedTo.Num() > 0);
		PinObj->SetStringField(TEXT("type"), Pin->PinType.PinCategory.ToString());

		PinsArr.Add(MakeShared<FJsonValueObject>(PinObj));
	}
	return PinsArr;
}

} // anonymous namespace

// ---------------------------------------------------------------------------
// Action: add_anim_graph_node
// ---------------------------------------------------------------------------

FMonolithActionResult FMonolithAbpWriteActions::HandleAddAnimGraphNode(const TSharedPtr<FJsonObject>& Params)
{
	FString AssetPath = Params->GetStringField(TEXT("asset_path"));
	FString NodeType  = Params->GetStringField(TEXT("node_type"));
	FString GraphName = Params->HasField(TEXT("graph_name")) ? Params->GetStringField(TEXT("graph_name")) : TEXT("AnimGraph");
	FString StateName = Params->HasField(TEXT("state_name")) ? Params->GetStringField(TEXT("state_name")) : TEXT("");
	FString AnimAsset = Params->HasField(TEXT("anim_asset")) ? Params->GetStringField(TEXT("anim_asset")) : TEXT("");
	FString MachineName = Params->HasField(TEXT("machine_name")) ? Params->GetStringField(TEXT("machine_name")) : TEXT("");

	double TempVal;
	float PosX = 200.f;
	float PosY = 0.f;
	if (Params->TryGetNumberField(TEXT("position_x"), TempVal)) PosX = static_cast<float>(TempVal);
	if (Params->TryGetNumberField(TEXT("position_y"), TempVal)) PosY = static_cast<float>(TempVal);

	if (NodeType.IsEmpty()) return FMonolithActionResult::Error(TEXT("Missing required parameter: node_type"));

	UAnimBlueprint* ABP = FMonolithAssetUtils::LoadAssetByPath<UAnimBlueprint>(AssetPath);
	if (!ABP) return FMonolithActionResult::Error(FString::Printf(TEXT("AnimBlueprint not found: %s"), *AssetPath));

	// Resolve the node class
	UClass* NodeClass = ResolveNodeClass(NodeType);
	if (!NodeClass)
	{
		return FMonolithActionResult::Error(FString::Printf(
			TEXT("Unknown node_type '%s'. Supported: SequencePlayer, BlendSpacePlayer, TwoWayBlend, BlendListByBool, LayeredBoneBlend, MotionMatching, TwoBoneIK, ModifyBone, LocalToComponentSpace, ComponentToLocalSpace, StateMachine"),
			*NodeType));
	}
	if (NodeClass == UAnimGraphNode_StateMachine::StaticClass() && !MachineName.IsEmpty() && FindSMGraphByName(ABP, MachineName))
	{
		return FMonolithActionResult::Error(FString::Printf(TEXT("State machine '%s' already exists in ABP"), *MachineName));
	}

	// Resolve the target graph
	FString GraphError;
	UEdGraph* TargetGraph = ResolveTargetGraph(ABP, GraphName, StateName, GraphError);
	if (!TargetGraph) return FMonolithActionResult::Error(GraphError);

	// Create the template node on the transient package (will be duplicated by PerformAction)
	UAnimGraphNode_Base* Template = Cast<UAnimGraphNode_Base>(NewObject<UObject>(GetTransientPackage(), NodeClass));
	if (!Template)
	{
		return FMonolithActionResult::Error(FString::Printf(TEXT("Failed to create node template for type '%s'"), *NodeType));
	}

	// Set animation asset before spawning (gets duplicated with the node)
	if (!AnimAsset.IsEmpty())
	{
		UAnimGraphNode_AssetPlayerBase* AssetPlayer = Cast<UAnimGraphNode_AssetPlayerBase>(Template);
		if (AssetPlayer)
		{
			UAnimationAsset* Asset = FMonolithAssetUtils::LoadAssetByPath<UAnimationAsset>(AnimAsset);
			if (!Asset)
			{
				return FMonolithActionResult::Error(FString::Printf(TEXT("Animation asset not found: %s"), *AnimAsset));
			}
			AssetPlayer->SetAnimationAsset(Asset);
		}
		else
		{
			// Non-asset-player node doesn't support anim_asset — just warn via log, don't fail
			UE_LOG(LogTemp, Warning, TEXT("Monolith: Node type '%s' does not support anim_asset parameter — ignored"), *NodeType);
		}
	}

	// Skeletal control node configuration (set on template before spawn)
	if (UAnimGraphNode_TwoBoneIK* IKTemplate = Cast<UAnimGraphNode_TwoBoneIK>(Template))
	{
		FString IKBone;
		if (Params->TryGetStringField(TEXT("ik_bone"), IKBone) && !IKBone.IsEmpty())
		{
			IKTemplate->Node.IKBone.BoneName = FName(*IKBone);
		}
		FString EffectorSpace;
		if (Params->TryGetStringField(TEXT("effector_space"), EffectorSpace))
		{
			IKTemplate->Node.EffectorLocationSpace = ParseBoneControlSpace(EffectorSpace);
		}
		FString JointTargetSpace;
		if (Params->TryGetStringField(TEXT("joint_target_space"), JointTargetSpace))
		{
			IKTemplate->Node.JointTargetLocationSpace = ParseBoneControlSpace(JointTargetSpace);
		}
	}
	else if (UAnimGraphNode_ModifyBone* ModifyTemplate = Cast<UAnimGraphNode_ModifyBone>(Template))
	{
		FString ModifyBoneName;
		if (Params->TryGetStringField(TEXT("bone_to_modify"), ModifyBoneName) && !ModifyBoneName.IsEmpty())
		{
			ModifyTemplate->Node.BoneToModify.BoneName = FName(*ModifyBoneName);
		}
	}

	GEditor->BeginTransaction(FText::FromString(TEXT("Add Anim Graph Node")));
	TargetGraph->Modify();

	// Spawn via FEdGraphSchemaAction_K2NewNode — same path as the editor
	FEdGraphSchemaAction_K2NewNode Action;
	Action.NodeTemplate = Template;
	UEdGraphNode* SpawnedNode = Action.PerformAction(TargetGraph, /*FromPin=*/nullptr, FVector2f(PosX, PosY), /*bSelectNewNode=*/false);

	GEditor->EndTransaction();

	if (!SpawnedNode)
	{
		return FMonolithActionResult::Error(TEXT("PerformAction failed — node was not spawned. Check that the target graph supports this node type."));
	}

	if (UAnimGraphNode_StateMachine* SpawnedSM = Cast<UAnimGraphNode_StateMachine>(SpawnedNode))
	{
		if (!MachineName.IsEmpty() && SpawnedSM->EditorStateMachineGraph)
		{
			SpawnedSM->Modify();
			SpawnedSM->EditorStateMachineGraph->Modify();
			FBlueprintEditorUtils::RenameGraph(SpawnedSM->EditorStateMachineGraph, MachineName);
			SpawnedSM->ReconstructNode();
		}
	}

	// Expose optional-pin properties (e.g. EffectorLocation, JointTargetLocation, Alpha on TwoBoneIK)
	{
		UAnimGraphNode_Base* SpawnedAnim = Cast<UAnimGraphNode_Base>(SpawnedNode);
		if (SpawnedAnim)
		{
			TArray<FName> PinsToExpose;

			const TArray<TSharedPtr<FJsonValue>>* ExposePinsArr = nullptr;
			if (Params->TryGetArrayField(TEXT("expose_pins"), ExposePinsArr) && ExposePinsArr)
			{
				for (const TSharedPtr<FJsonValue>& V : *ExposePinsArr)
				{
					if (V.IsValid()) PinsToExpose.AddUnique(FName(*V->AsString()));
				}
			}

			// TwoBoneIK defaults: auto-expose common input pins
			if (Cast<UAnimGraphNode_TwoBoneIK>(SpawnedAnim) && PinsToExpose.Num() == 0)
			{
				PinsToExpose.Add(TEXT("EffectorLocation"));
				PinsToExpose.Add(TEXT("JointTargetLocation"));
				PinsToExpose.Add(TEXT("Alpha"));
			}

			bool bAnyExposed = false;
			for (FOptionalPinFromProperty& OptPin : SpawnedAnim->ShowPinForProperties)
			{
				if (PinsToExpose.Contains(OptPin.PropertyName) && !OptPin.bShowPin)
				{
					OptPin.bShowPin = true;
					bAnyExposed = true;
				}
			}
			if (bAnyExposed)
			{
				SpawnedAnim->ReconstructNode();
			}
		}
	}

	// Do NOT compile here — caller should batch node adds then wire, then compile once.
	// Just mark dirty.
	ABP->MarkPackageDirty();

	// Build response
	TSharedPtr<FJsonObject> Root = MakeShared<FJsonObject>();
	Root->SetStringField(TEXT("node_name"), SpawnedNode->GetName());
	Root->SetStringField(TEXT("node_class"), SpawnedNode->GetClass()->GetName());
	Root->SetStringField(TEXT("node_guid"), SpawnedNode->NodeGuid.ToString());
	Root->SetNumberField(TEXT("position_x"), SpawnedNode->NodePosX);
	Root->SetNumberField(TEXT("position_y"), SpawnedNode->NodePosY);
	Root->SetArrayField(TEXT("pins"), BuildPinList(SpawnedNode));
	return FMonolithActionResult::Success(Root);
}

// ---------------------------------------------------------------------------
// Action: connect_anim_graph_pins
// ---------------------------------------------------------------------------

FMonolithActionResult FMonolithAbpWriteActions::HandleConnectAnimGraphPins(const TSharedPtr<FJsonObject>& Params)
{
	FString AssetPath  = Params->GetStringField(TEXT("asset_path"));
	FString SourceNode = Params->GetStringField(TEXT("source_node"));
	FString SourcePin  = Params->GetStringField(TEXT("source_pin"));
	FString TargetNode = Params->GetStringField(TEXT("target_node"));
	FString TargetPin  = Params->GetStringField(TEXT("target_pin"));
	FString GraphName  = Params->HasField(TEXT("graph_name")) ? Params->GetStringField(TEXT("graph_name")) : TEXT("");
	FString StateName  = Params->HasField(TEXT("state_name")) ? Params->GetStringField(TEXT("state_name")) : TEXT("");

	bool bCompile = true;
	if (Params->HasField(TEXT("compile")))
	{
		bCompile = Params->GetBoolField(TEXT("compile"));
	}

	if (SourceNode.IsEmpty()) return FMonolithActionResult::Error(TEXT("Missing required parameter: source_node"));
	if (SourcePin.IsEmpty())  return FMonolithActionResult::Error(TEXT("Missing required parameter: source_pin"));
	if (TargetNode.IsEmpty()) return FMonolithActionResult::Error(TEXT("Missing required parameter: target_node"));
	if (TargetPin.IsEmpty())  return FMonolithActionResult::Error(TEXT("Missing required parameter: target_pin"));

	UAnimBlueprint* ABP = FMonolithAssetUtils::LoadAssetByPath<UAnimBlueprint>(AssetPath);
	if (!ABP) return FMonolithActionResult::Error(FString::Printf(TEXT("AnimBlueprint not found: %s"), *AssetPath));

	// Optionally resolve to a specific graph for scoping the search
	UEdGraph* ScopeGraph = nullptr;
	if (!StateName.IsEmpty() || (!GraphName.IsEmpty() && !GraphName.Equals(TEXT("AnimGraph"), ESearchCase::IgnoreCase)))
	{
		FString GraphError;
		ScopeGraph = ResolveTargetGraph(ABP, GraphName, StateName, GraphError);
		// If scope resolution fails, we still search globally as fallback
	}

	// Find source and target nodes
	UEdGraphNode* SrcNode = FindNodeByName(ABP, SourceNode, ScopeGraph);
	if (!SrcNode)
	{
		return FMonolithActionResult::Error(FString::Printf(TEXT("Source node '%s' not found in ABP"), *SourceNode));
	}

	UEdGraphNode* DstNode = FindNodeByName(ABP, TargetNode, ScopeGraph);
	if (!DstNode)
	{
		return FMonolithActionResult::Error(FString::Printf(TEXT("Target node '%s' not found in ABP"), *TargetNode));
	}

	// Find output pin on source
	UEdGraphPin* OutPin = SrcNode->FindPin(FName(*SourcePin), EGPD_Output);
	if (!OutPin)
	{
		// List available output pins for debugging
		FString AvailPins;
		for (UEdGraphPin* P : SrcNode->Pins)
		{
			if (P && P->Direction == EGPD_Output)
			{
				if (!AvailPins.IsEmpty()) AvailPins += TEXT(", ");
				AvailPins += P->PinName.ToString();
			}
		}
		return FMonolithActionResult::Error(FString::Printf(
			TEXT("Output pin '%s' not found on node '%s'. Available output pins: [%s]"),
			*SourcePin, *SourceNode, *AvailPins));
	}

	// Find input pin on target
	UEdGraphPin* InPin = DstNode->FindPin(FName(*TargetPin), EGPD_Input);
	if (!InPin)
	{
		FString AvailPins;
		for (UEdGraphPin* P : DstNode->Pins)
		{
			if (P && P->Direction == EGPD_Input)
			{
				if (!AvailPins.IsEmpty()) AvailPins += TEXT(", ");
				AvailPins += P->PinName.ToString();
			}
		}
		return FMonolithActionResult::Error(FString::Printf(
			TEXT("Input pin '%s' not found on node '%s'. Available input pins: [%s]"),
			*TargetPin, *TargetNode, *AvailPins));
	}

	// Verify both nodes are in the same graph
	if (SrcNode->GetGraph() != DstNode->GetGraph())
	{
		return FMonolithActionResult::Error(FString::Printf(
			TEXT("Source node '%s' and target node '%s' are in different graphs — connections must be within the same graph"),
			*SourceNode, *TargetNode));
	}

	GEditor->BeginTransaction(FText::FromString(TEXT("Connect Anim Graph Pins")));
	SrcNode->GetGraph()->Modify();

	// Use the graph's own schema for the connection (UAnimationGraphSchema or UAnimationStateGraphSchema)
	const UEdGraphSchema* Schema = SrcNode->GetGraph()->GetSchema();
	const bool bConnected = Schema->TryCreateConnection(OutPin, InPin);

	GEditor->EndTransaction();

	if (!bConnected)
	{
		return FMonolithActionResult::Error(FString::Printf(
			TEXT("TryCreateConnection failed: '%s.%s' -> '%s.%s'. Pin types may be incompatible."),
			*SourceNode, *SourcePin, *TargetNode, *TargetPin));
	}

	if (bCompile)
	{
		FBlueprintEditorUtils::MarkBlueprintAsStructurallyModified(ABP);
		FKismetEditorUtilities::CompileBlueprint(ABP);
	}

	ABP->MarkPackageDirty();

	TSharedPtr<FJsonObject> Root = MakeShared<FJsonObject>();
	Root->SetStringField(TEXT("asset_path"), AssetPath);
	Root->SetStringField(TEXT("source_node"), SourceNode);
	Root->SetStringField(TEXT("source_pin"), SourcePin);
	Root->SetStringField(TEXT("target_node"), TargetNode);
	Root->SetStringField(TEXT("target_pin"), TargetPin);
	Root->SetBoolField(TEXT("compiled"), bCompile);
	return FMonolithActionResult::Success(Root);
}

// ---------------------------------------------------------------------------
// Action: set_state_animation
// ---------------------------------------------------------------------------

FMonolithActionResult FMonolithAbpWriteActions::HandleSetStateAnimation(const TSharedPtr<FJsonObject>& Params)
{
	FString AssetPath    = Params->GetStringField(TEXT("asset_path"));
	FString MachineName  = Params->GetStringField(TEXT("machine_name"));
	FString StateName    = Params->GetStringField(TEXT("state_name"));
	FString AnimAssetPath = Params->GetStringField(TEXT("anim_asset_path"));

	bool bLoop = false;
	if (Params->HasField(TEXT("loop")))
	{
		bLoop = Params->GetBoolField(TEXT("loop"));
	}

	bool bClearExisting = true;
	if (Params->HasField(TEXT("clear_existing")))
	{
		bClearExisting = Params->GetBoolField(TEXT("clear_existing"));
	}

	if (MachineName.IsEmpty())  return FMonolithActionResult::Error(TEXT("Missing required parameter: machine_name"));
	if (StateName.IsEmpty())    return FMonolithActionResult::Error(TEXT("Missing required parameter: state_name"));
	if (AnimAssetPath.IsEmpty()) return FMonolithActionResult::Error(TEXT("Missing required parameter: anim_asset_path"));

	UAnimBlueprint* ABP = FMonolithAssetUtils::LoadAssetByPath<UAnimBlueprint>(AssetPath);
	if (!ABP) return FMonolithActionResult::Error(FString::Printf(TEXT("AnimBlueprint not found: %s"), *AssetPath));

	// Find the state machine and state
	UAnimationStateMachineGraph* SMGraph = FindSMGraphByName(ABP, MachineName);
	if (!SMGraph) return FMonolithActionResult::Error(FString::Printf(TEXT("State machine '%s' not found in ABP"), *MachineName));

	UAnimStateNode* StateNode = FindStateByName(SMGraph, StateName);
	if (!StateNode) return FMonolithActionResult::Error(FString::Printf(TEXT("State '%s' not found in machine '%s'"), *StateName, *MachineName));

	UAnimationStateGraph* StateGraph = Cast<UAnimationStateGraph>(StateNode->BoundGraph);
	if (!StateGraph) return FMonolithActionResult::Error(FString::Printf(TEXT("State '%s' has no inner animation graph"), *StateName));

	UAnimGraphNode_StateResult* ResultNode = StateGraph->MyResultNode;
	if (!ResultNode) return FMonolithActionResult::Error(FString::Printf(TEXT("State '%s' has no result node — state graph may be corrupt"), *StateName));

	// Load the animation asset
	UAnimationAsset* AnimAsset = FMonolithAssetUtils::LoadAssetByPath<UAnimationAsset>(AnimAssetPath);
	if (!AnimAsset) return FMonolithActionResult::Error(FString::Printf(TEXT("Animation asset not found: %s"), *AnimAssetPath));

	// Determine node class using the engine's own mapping
	UClass* NodeClass = GetNodeClassForAsset(AnimAsset->GetClass());
	if (!NodeClass)
	{
		return FMonolithActionResult::Error(FString::Printf(
			TEXT("No animation player node type for asset class '%s'. Supported: AnimSequence, BlendSpace."),
			*AnimAsset->GetClass()->GetName()));
	}

	GEditor->BeginTransaction(FText::FromString(TEXT("Set State Animation")));
	StateGraph->Modify();

	// Find the Result input pin
	UEdGraphPin* ResultInputPin = ResultNode->FindPin(TEXT("Result"), EGPD_Input);
	if (!ResultInputPin)
	{
		GEditor->EndTransaction();
		return FMonolithActionResult::Error(TEXT("Could not find 'Result' input pin on state result node"));
	}

	// Optionally clear existing nodes wired to the result
	if (bClearExisting)
	{
		// Collect nodes currently connected to the result pin
		TArray<UEdGraphNode*> NodesToRemove;
		for (UEdGraphPin* LinkedPin : ResultInputPin->LinkedTo)
		{
			if (LinkedPin && LinkedPin->GetOwningNode())
			{
				NodesToRemove.Add(LinkedPin->GetOwningNode());
			}
		}

		// Break all connections to the result pin
		ResultInputPin->BreakAllPinLinks();

		// Remove the previously-wired nodes (but not the result node itself)
		for (UEdGraphNode* OldNode : NodesToRemove)
		{
			if (OldNode && OldNode != ResultNode)
			{
				OldNode->BreakAllNodeLinks();
				StateGraph->RemoveNode(OldNode);
			}
		}
	}

	// Create template node on transient package
	UAnimGraphNode_AssetPlayerBase* Template = Cast<UAnimGraphNode_AssetPlayerBase>(
		NewObject<UObject>(GetTransientPackage(), NodeClass));
	if (!Template)
	{
		GEditor->EndTransaction();
		return FMonolithActionResult::Error(TEXT("Failed to create animation player node template"));
	}

	Template->SetAnimationAsset(AnimAsset);
	Template->CopySettingsFromAnimationAsset(AnimAsset);

	// Set loop flag if requested — need to access the FAnimNode struct via reflection
	if (bLoop)
	{
		// Try to set bLoopAnimation via the runtime node struct
		FStructProperty* NodeProp = Template->GetFNodeProperty();
		if (NodeProp)
		{
			void* NodePtr = NodeProp->ContainerPtrToValuePtr<void>(Template);
			FProperty* LoopProp = NodeProp->Struct->FindPropertyByName(FName(TEXT("bLoopAnimation")));
			if (LoopProp)
			{
				FBoolProperty* BoolProp = CastField<FBoolProperty>(LoopProp);
				if (BoolProp)
				{
					BoolProp->SetPropertyValue(BoolProp->ContainerPtrToValuePtr<void>(NodePtr), true);
				}
			}
		}
	}

	// Spawn into the state graph, positioned to the left of the result node
	float SpawnX = static_cast<float>(ResultNode->NodePosX - 300);
	float SpawnY = static_cast<float>(ResultNode->NodePosY);

	FEdGraphSchemaAction_K2NewNode Action;
	Action.NodeTemplate = Template;
	UEdGraphNode* SpawnedNode = Action.PerformAction(StateGraph, /*FromPin=*/nullptr, FVector2f(SpawnX, SpawnY), /*bSelectNewNode=*/false);

	if (!SpawnedNode)
	{
		GEditor->EndTransaction();
		return FMonolithActionResult::Error(TEXT("PerformAction failed — animation player node was not spawned"));
	}

	// Wire the pose output to the result input
	UEdGraphPin* PoseOutput = SpawnedNode->FindPin(TEXT("Pose"), EGPD_Output);
	if (!PoseOutput)
	{
		GEditor->EndTransaction();
		return FMonolithActionResult::Error(TEXT("Spawned node has no 'Pose' output pin — cannot wire to state result"));
	}

	const UEdGraphSchema* Schema = StateGraph->GetSchema();
	const bool bWired = Schema->TryCreateConnection(PoseOutput, ResultInputPin);

	GEditor->EndTransaction();

	if (!bWired)
	{
		return FMonolithActionResult::Error(TEXT("TryCreateConnection failed wiring Pose -> Result. The node was spawned but not connected."));
	}

	// Compile
	FBlueprintEditorUtils::MarkBlueprintAsStructurallyModified(ABP);
	FKismetEditorUtilities::CompileBlueprint(ABP);
	ABP->MarkPackageDirty();

	// Build response
	TSharedPtr<FJsonObject> Root = MakeShared<FJsonObject>();
	Root->SetStringField(TEXT("asset_path"), AssetPath);
	Root->SetStringField(TEXT("machine_name"), MachineName);
	Root->SetStringField(TEXT("state_name"), StateName);
	Root->SetStringField(TEXT("anim_asset_path"), AnimAssetPath);
	Root->SetStringField(TEXT("node_name"), SpawnedNode->GetName());
	Root->SetStringField(TEXT("node_class"), SpawnedNode->GetClass()->GetName());
	Root->SetBoolField(TEXT("loop"), bLoop);
	Root->SetBoolField(TEXT("cleared_existing"), bClearExisting);
	Root->SetArrayField(TEXT("pins"), BuildPinList(SpawnedNode));
	return FMonolithActionResult::Success(Root);
}

// ---------------------------------------------------------------------------
// Action: add_variable_get
// ---------------------------------------------------------------------------

FMonolithActionResult FMonolithAbpWriteActions::HandleAddVariableGet(const TSharedPtr<FJsonObject>& Params)
{
	FString AssetPath = Params->GetStringField(TEXT("asset_path"));
	FString VarName   = Params->GetStringField(TEXT("variable_name"));
	FString GraphName = Params->HasField(TEXT("graph_name")) ? Params->GetStringField(TEXT("graph_name")) : TEXT("AnimGraph");
	FString StateName = Params->HasField(TEXT("state_name")) ? Params->GetStringField(TEXT("state_name")) : TEXT("");

	double TempVal;
	float PosX = 0.f;
	float PosY = 0.f;
	if (Params->TryGetNumberField(TEXT("position_x"), TempVal)) PosX = static_cast<float>(TempVal);
	if (Params->TryGetNumberField(TEXT("position_y"), TempVal)) PosY = static_cast<float>(TempVal);

	if (VarName.IsEmpty()) return FMonolithActionResult::Error(TEXT("Missing required parameter: variable_name"));

	UAnimBlueprint* ABP = FMonolithAssetUtils::LoadAssetByPath<UAnimBlueprint>(AssetPath);
	if (!ABP) return FMonolithActionResult::Error(FString::Printf(TEXT("AnimBlueprint not found: %s"), *AssetPath));

	FString GraphError;
	UEdGraph* TargetGraph = ResolveTargetGraph(ABP, GraphName, StateName, GraphError);
	if (!TargetGraph) return FMonolithActionResult::Error(GraphError);

	// Validate variable exists on skeleton class (BP-declared or C++ UPROPERTY)
	const FName VarFName(*VarName);
	UClass* SkeletonClass = ABP->SkeletonGeneratedClass ? ABP->SkeletonGeneratedClass : ABP->GeneratedClass;
	if (SkeletonClass && !SkeletonClass->FindPropertyByName(VarFName))
	{
		return FMonolithActionResult::Error(FString::Printf(
			TEXT("Variable '%s' not found on %s — check spelling and BlueprintReadOnly/ReadWrite on the UPROPERTY."),
			*VarName, *SkeletonClass->GetName()));
	}

	UK2Node_VariableGet* Template = NewObject<UK2Node_VariableGet>(GetTransientPackage());
	Template->VariableReference.SetSelfMember(VarFName);

	GEditor->BeginTransaction(FText::FromString(TEXT("Add Variable Get")));
	TargetGraph->Modify();

	FEdGraphSchemaAction_K2NewNode Action;
	Action.NodeTemplate = Template;
	UEdGraphNode* SpawnedNode = Action.PerformAction(TargetGraph, /*FromPin=*/nullptr, FVector2f(PosX, PosY), /*bSelectNewNode=*/false);

	GEditor->EndTransaction();

	if (!SpawnedNode)
	{
		return FMonolithActionResult::Error(TEXT("PerformAction failed for K2Node_VariableGet."));
	}

	ABP->MarkPackageDirty();

	TSharedPtr<FJsonObject> Root = MakeShared<FJsonObject>();
	Root->SetStringField(TEXT("node_name"), SpawnedNode->GetName());
	Root->SetStringField(TEXT("node_class"), SpawnedNode->GetClass()->GetName());
	Root->SetStringField(TEXT("node_guid"), SpawnedNode->NodeGuid.ToString());
	Root->SetStringField(TEXT("variable_name"), VarName);
	Root->SetNumberField(TEXT("position_x"), SpawnedNode->NodePosX);
	Root->SetNumberField(TEXT("position_y"), SpawnedNode->NodePosY);
	Root->SetArrayField(TEXT("pins"), BuildPinList(SpawnedNode));
	return FMonolithActionResult::Success(Root);
}

// ---------------------------------------------------------------------------
// Action: set_anim_graph_node_property
// ---------------------------------------------------------------------------

namespace
{
/**
 * Resolve a dotted property path inside a container (struct value).
 * On success, `OutProperty` is the final property, `OutContainer` is the
 * address of the immediately-enclosing struct/object where that property lives.
 *
 *   path="BoneToModify.BoneName"  →  Prop=FNameProperty, Container=&Node.BoneToModify
 *   path="RotationMode"            →  Prop=FEnumProperty,  Container=&Node
 */
bool ResolvePropertyPath(UStruct* StructType, void* StructAddr, const FString& Path,
                         FProperty*& OutProperty, void*& OutContainer, FString& OutError)
{
	TArray<FString> Tokens;
	Path.ParseIntoArray(Tokens, TEXT("."));
	if (Tokens.Num() == 0)
	{
		OutError = TEXT("property_path is empty");
		return false;
	}

	UStruct* Cursor = StructType;
	void*    Addr   = StructAddr;

	for (int32 i = 0; i < Tokens.Num(); ++i)
	{
		const FString& Tok = Tokens[i];
		FProperty* Prop = Cursor ? Cursor->FindPropertyByName(FName(*Tok)) : nullptr;
		if (!Prop)
		{
			OutError = FString::Printf(TEXT("Property '%s' not found on %s"),
				*Tok, Cursor ? *Cursor->GetName() : TEXT("<null>"));
			return false;
		}

		if (i == Tokens.Num() - 1)
		{
			OutProperty  = Prop;
			OutContainer = Addr;
			return true;
		}

		// Descend into nested structs.
		FStructProperty* StructProp = CastField<FStructProperty>(Prop);
		if (!StructProp)
		{
			OutError = FString::Printf(TEXT("Cannot descend into '%s' — not a struct property"), *Tok);
			return false;
		}
		Cursor = StructProp->Struct;
		Addr   = StructProp->ContainerPtrToValuePtr<void>(Addr);
	}

	OutError = TEXT("unreachable");
	return false;
}
} // anonymous namespace

FMonolithActionResult FMonolithAbpWriteActions::HandleSetAnimGraphNodeProperty(const TSharedPtr<FJsonObject>& Params)
{
	FString AssetPath    = Params->GetStringField(TEXT("asset_path"));
	FString NodeId       = Params->GetStringField(TEXT("node_id"));
	FString PropertyPath = Params->GetStringField(TEXT("property_path"));
	FString Value        = Params->GetStringField(TEXT("value"));
	FString GraphName    = Params->HasField(TEXT("graph_name")) ? Params->GetStringField(TEXT("graph_name")) : TEXT("");
	FString StateName    = Params->HasField(TEXT("state_name")) ? Params->GetStringField(TEXT("state_name")) : TEXT("");

	if (NodeId.IsEmpty())       return FMonolithActionResult::Error(TEXT("Missing required parameter: node_id"));
	if (PropertyPath.IsEmpty()) return FMonolithActionResult::Error(TEXT("Missing required parameter: property_path"));

	UAnimBlueprint* ABP = FMonolithAssetUtils::LoadAssetByPath<UAnimBlueprint>(AssetPath);
	if (!ABP) return FMonolithActionResult::Error(FString::Printf(TEXT("AnimBlueprint not found: %s"), *AssetPath));

	// Optional graph scope — same resolution as connect_anim_graph_pins.
	UEdGraph* ScopeGraph = nullptr;
	if (!StateName.IsEmpty() || (!GraphName.IsEmpty() && !GraphName.Equals(TEXT("AnimGraph"), ESearchCase::IgnoreCase)))
	{
		FString GraphError;
		ScopeGraph = ResolveTargetGraph(ABP, GraphName, StateName, GraphError);
	}

	if (PropertyPath == TEXT("__RenameStateMachine"))
	{
		UAnimGraphNode_StateMachine* SMNode = FindSMNodeByName(ABP, NodeId);
		if (!SMNode || !SMNode->EditorStateMachineGraph)
		{
			return FMonolithActionResult::Error(FString::Printf(TEXT("State machine '%s' not found in ABP"), *NodeId));
		}
		if (!NodeId.Equals(Value, ESearchCase::CaseSensitive) && FindSMGraphByName(ABP, Value))
		{
			return FMonolithActionResult::Error(FString::Printf(TEXT("State machine '%s' already exists in ABP"), *Value));
		}

		GEditor->BeginTransaction(FText::FromString(TEXT("Rename State Machine")));
		ABP->Modify();
		SMNode->Modify();
		SMNode->EditorStateMachineGraph->Modify();
		FBlueprintEditorUtils::RenameGraph(SMNode->EditorStateMachineGraph, Value);
		SMNode->ReconstructNode();
		GEditor->EndTransaction();

		FKismetEditorUtilities::CompileBlueprint(ABP);
		ABP->MarkPackageDirty();

		TSharedPtr<FJsonObject> Root = MakeShared<FJsonObject>();
		Root->SetStringField(TEXT("asset_path"), AssetPath);
		Root->SetStringField(TEXT("old_name"), NodeId);
		Root->SetStringField(TEXT("new_name"), Value);
		Root->SetStringField(TEXT("node_id"), SMNode->GetName());
		return FMonolithActionResult::Success(Root);
	}

	if (PropertyPath == TEXT("__MoveStateMachineToState"))
	{
		TArray<FString> Parts;
		Value.ParseIntoArray(Parts, TEXT("|"), false);
		if (Parts.Num() < 2)
		{
			return FMonolithActionResult::Error(TEXT("Value must be 'TargetMachine|TargetState|PosX|PosY'"));
		}

		const FString TargetMachineName = Parts[0];
		const FString TargetStateName = Parts[1];
		int32 PosX = Parts.Num() > 2 ? FCString::Atoi(*Parts[2]) : 0;
		int32 PosY = Parts.Num() > 3 ? FCString::Atoi(*Parts[3]) : 0;

		UAnimGraphNode_StateMachine* SMNode = FindSMNodeByName(ABP, NodeId);
		if (!SMNode || !SMNode->EditorStateMachineGraph)
		{
			return FMonolithActionResult::Error(FString::Printf(TEXT("State machine '%s' not found in ABP"), *NodeId));
		}

		UAnimationStateMachineGraph* TargetSMGraph = FindSMGraphByName(ABP, TargetMachineName);
		if (!TargetSMGraph)
		{
			return FMonolithActionResult::Error(FString::Printf(TEXT("Target state machine '%s' not found in ABP"), *TargetMachineName));
		}

		UAnimStateNode* TargetState = FindStateByName(TargetSMGraph, TargetStateName);
		if (!TargetState || !TargetState->BoundGraph)
		{
			return FMonolithActionResult::Error(FString::Printf(TEXT("Target state '%s' not found or has no bound graph"), *TargetStateName));
		}

		UEdGraph* SourceGraph = SMNode->GetGraph();
		UEdGraph* TargetGraph = TargetState->BoundGraph;
		if (!SourceGraph || !TargetGraph)
		{
			return FMonolithActionResult::Error(TEXT("Source or target graph is null"));
		}

		GEditor->BeginTransaction(FText::FromString(TEXT("Move State Machine To State")));
		ABP->Modify();
		SourceGraph->Modify();
		TargetGraph->Modify();
		SMNode->Modify();
		SMNode->BreakAllNodeLinks();
		SourceGraph->RemoveNode(SMNode);
		SMNode->Rename(nullptr, TargetGraph, REN_DontCreateRedirectors | REN_NonTransactional);
		TargetGraph->AddNode(SMNode, false, false);
		SMNode->NodePosX = PosX;
		SMNode->NodePosY = PosY;
		SMNode->ReconstructNode();
		GEditor->EndTransaction();

		FBlueprintEditorUtils::MarkBlueprintAsStructurallyModified(ABP);
		FKismetEditorUtilities::CompileBlueprint(ABP);
		ABP->MarkPackageDirty();

		TSharedPtr<FJsonObject> Root = MakeShared<FJsonObject>();
		Root->SetStringField(TEXT("asset_path"), AssetPath);
		Root->SetStringField(TEXT("machine_name"), NodeId);
		Root->SetStringField(TEXT("target_machine_name"), TargetMachineName);
		Root->SetStringField(TEXT("target_state_name"), TargetStateName);
		Root->SetStringField(TEXT("node_id"), SMNode->GetName());
		return FMonolithActionResult::Success(Root);
	}

	if (PropertyPath == TEXT("__RemoveEmptyDuplicateTransition"))
	{
		TArray<FString> Parts;
		Value.ParseIntoArray(Parts, TEXT("|"), false);
		if (Parts.Num() < 2)
		{
			return FMonolithActionResult::Error(TEXT("Value must be 'FromState|ToState'"));
		}

		UAnimationStateMachineGraph* SMGraph = FindSMGraphByName(ABP, NodeId);
		if (!SMGraph)
		{
			return FMonolithActionResult::Error(FString::Printf(TEXT("State machine '%s' not found in ABP"), *NodeId));
		}

		TArray<UAnimStateTransitionNode*> Matches;
		for (UEdGraphNode* GraphNode : SMGraph->Nodes)
		{
			UAnimStateTransitionNode* TransitionNode = Cast<UAnimStateTransitionNode>(GraphNode);
			if (!TransitionNode) continue;

			auto* PrevState = TransitionNode->GetPreviousState();
			auto* NextState = TransitionNode->GetNextState();
			if (PrevState && NextState &&
				PrevState->GetStateName() == Parts[0] &&
				NextState->GetStateName() == Parts[1])
			{
				Matches.Add(TransitionNode);
			}
		}

		if (Matches.Num() <= 1)
		{
			TSharedPtr<FJsonObject> Root = MakeShared<FJsonObject>();
			Root->SetStringField(TEXT("asset_path"), AssetPath);
			Root->SetStringField(TEXT("machine_name"), NodeId);
			Root->SetNumberField(TEXT("removed_count"), 0);
			return FMonolithActionResult::Success(Root);
		}

		int32 KeepIndex = 0;
		for (int32 Index = 0; Index < Matches.Num(); ++Index)
		{
			UEdGraph* RuleGraph = Matches[Index]->GetBoundGraph();
			if (RuleGraph && RuleGraph->Nodes.Num() > 1)
			{
				KeepIndex = Index;
				break;
			}
		}

		int32 RemovedCount = 0;
		GEditor->BeginTransaction(FText::FromString(TEXT("Remove Empty Duplicate Transition")));
		ABP->Modify();
		SMGraph->Modify();
		for (int32 Index = Matches.Num() - 1; Index >= 0; --Index)
		{
			if (Index == KeepIndex) continue;
			UAnimStateTransitionNode* TransitionNode = Matches[Index];
			if (!TransitionNode) continue;
			FBlueprintEditorUtils::RemoveNode(ABP, TransitionNode, /*bDontRecompile=*/true);
			++RemovedCount;
		}
		GEditor->EndTransaction();

		FBlueprintEditorUtils::MarkBlueprintAsStructurallyModified(ABP);
		FKismetEditorUtilities::CompileBlueprint(ABP);
		ABP->MarkPackageDirty();

		TSharedPtr<FJsonObject> Root = MakeShared<FJsonObject>();
		Root->SetStringField(TEXT("asset_path"), AssetPath);
		Root->SetStringField(TEXT("machine_name"), NodeId);
		Root->SetStringField(TEXT("from_state"), Parts[0]);
		Root->SetStringField(TEXT("to_state"), Parts[1]);
		Root->SetNumberField(TEXT("removed_count"), RemovedCount);
		return FMonolithActionResult::Success(Root);
	}

	if (PropertyPath == TEXT("__AddStateAlias"))
	{
		TArray<FString> Parts;
		Value.ParseIntoArray(Parts, TEXT("|"), false);
		if (Parts.Num() < 2)
		{
			return FMonolithActionResult::Error(TEXT("Value must be 'AliasName|StateA,StateB|PosX|PosY|Global'"));
		}

		UAnimationStateMachineGraph* SMGraph = FindSMGraphByName(ABP, NodeId);
		if (!SMGraph)
		{
			return FMonolithActionResult::Error(FString::Printf(TEXT("State machine '%s' not found in ABP"), *NodeId));
		}

		const FString AliasName = Parts[0];
		TArray<FString> StateNames;
		Parts[1].ParseIntoArray(StateNames, TEXT(","), true);
		const int32 PosX = Parts.Num() > 2 ? FCString::Atoi(*Parts[2]) : 0;
		const int32 PosY = Parts.Num() > 3 ? FCString::Atoi(*Parts[3]) : 0;
		const bool bGlobalAlias = Parts.Num() > 4
			&& (Parts[4].Equals(TEXT("true"), ESearchCase::IgnoreCase) || Parts[4] == TEXT("1"));

		TArray<UAnimStateNodeBase*> AliasedStates;
		for (FString AliasedStateName : StateNames)
		{
			AliasedStateName.TrimStartAndEndInline();
			if (AliasedStateName.IsEmpty())
			{
				continue;
			}

			UAnimStateNodeBase* StateNode = FindStateNodeBaseByName(SMGraph, AliasedStateName);
			if (!StateNode)
			{
				return FMonolithActionResult::Error(FString::Printf(
					TEXT("Aliased state '%s' not found in machine '%s'"), *AliasedStateName, *NodeId));
			}
			AliasedStates.Add(StateNode);
		}

		UAnimStateAliasNode* AliasNode = Cast<UAnimStateAliasNode>(FindStateNodeBaseByName(SMGraph, AliasName));
		const bool bCreated = AliasNode == nullptr;

		GEditor->BeginTransaction(FText::FromString(TEXT("Add State Alias")));
		ABP->Modify();
		SMGraph->Modify();

		if (!AliasNode)
		{
			FGraphNodeCreator<UAnimStateAliasNode> AliasNodeCreator(*SMGraph);
			AliasNode = AliasNodeCreator.CreateNode();
			AliasNode->StateAliasName = AliasName;
			AliasNodeCreator.Finalize();
		}

		AliasNode->Modify();
		AliasNode->StateAliasName = AliasName;
		AliasNode->bGlobalAlias = bGlobalAlias;
		AliasNode->GetAliasedStates().Empty();
		if (!bGlobalAlias)
		{
			for (UAnimStateNodeBase* StateNode : AliasedStates)
			{
				AliasNode->GetAliasedStates().Add(StateNode);
			}
		}
		AliasNode->SetNodePosX(PosX);
		AliasNode->SetNodePosY(PosY);
		AliasNode->ReconstructNode();
		GEditor->EndTransaction();

		FBlueprintEditorUtils::MarkBlueprintAsStructurallyModified(ABP);
		FKismetEditorUtilities::CompileBlueprint(ABP);
		ABP->MarkPackageDirty();

		TSharedPtr<FJsonObject> Root = MakeShared<FJsonObject>();
		Root->SetStringField(TEXT("asset_path"), AssetPath);
		Root->SetStringField(TEXT("machine_name"), NodeId);
		Root->SetStringField(TEXT("alias_name"), AliasName);
		Root->SetBoolField(TEXT("created"), bCreated);
		Root->SetBoolField(TEXT("global_alias"), bGlobalAlias);
		Root->SetNumberField(TEXT("aliased_state_count"), bGlobalAlias ? 0 : AliasedStates.Num());
		Root->SetNumberField(TEXT("position_x"), AliasNode->NodePosX);
		Root->SetNumberField(TEXT("position_y"), AliasNode->NodePosY);
		return FMonolithActionResult::Success(Root);
	}

	if (PropertyPath == TEXT("__AddTransitionByName"))
	{
		TArray<FString> Parts;
		Value.ParseIntoArray(Parts, TEXT("|"), false);
		if (Parts.Num() < 2)
		{
			return FMonolithActionResult::Error(TEXT("Value must be 'FromStateOrAlias|ToStateOrAlias'"));
		}

		UAnimationStateMachineGraph* SMGraph = FindSMGraphByName(ABP, NodeId);
		if (!SMGraph)
		{
			return FMonolithActionResult::Error(FString::Printf(TEXT("State machine '%s' not found in ABP"), *NodeId));
		}

		UAnimStateNodeBase* FromNode = FindStateNodeBaseByName(SMGraph, Parts[0]);
		UAnimStateNodeBase* ToNode = FindStateNodeBaseByName(SMGraph, Parts[1]);
		if (!FromNode || !ToNode)
		{
			return FMonolithActionResult::Error(FString::Printf(
				TEXT("Could not find transition endpoints '%s' -> '%s' in machine '%s'"),
				*Parts[0], *Parts[1], *NodeId));
		}

		UEdGraphPin* OutputPin = FromNode->GetOutputPin();
		UEdGraphPin* InputPin = ToNode->GetInputPin();
		if (!OutputPin || !InputPin)
		{
			return FMonolithActionResult::Error(TEXT("Transition endpoint is missing an input or output pin"));
		}

		const UAnimationStateMachineSchema* Schema = Cast<UAnimationStateMachineSchema>(SMGraph->GetSchema());
		if (!Schema)
		{
			return FMonolithActionResult::Error(TEXT("State machine graph has unexpected or null schema"));
		}

		GEditor->BeginTransaction(FText::FromString(TEXT("Add Transition By Name")));
		ABP->Modify();
		SMGraph->Modify();
		const bool bConnected = Schema->TryCreateConnection(OutputPin, InputPin);
		GEditor->EndTransaction();

		if (bConnected)
		{
			FBlueprintEditorUtils::MarkBlueprintAsStructurallyModified(ABP);
			FKismetEditorUtilities::CompileBlueprint(ABP);
			ABP->MarkPackageDirty();
		}

		TSharedPtr<FJsonObject> Root = MakeShared<FJsonObject>();
		Root->SetStringField(TEXT("asset_path"), AssetPath);
		Root->SetStringField(TEXT("machine_name"), NodeId);
		Root->SetStringField(TEXT("from_state"), Parts[0]);
		Root->SetStringField(TEXT("to_state"), Parts[1]);
		Root->SetBoolField(TEXT("connected"), bConnected);
		return FMonolithActionResult::Success(Root);
	}

	if (PropertyPath == TEXT("__RemoveTransitionByName"))
	{
		TArray<FString> Parts;
		Value.ParseIntoArray(Parts, TEXT("|"), false);
		if (Parts.Num() < 2)
		{
			return FMonolithActionResult::Error(TEXT("Value must be 'FromStateOrAlias|ToStateOrAlias'"));
		}

		UAnimationStateMachineGraph* SMGraph = FindSMGraphByName(ABP, NodeId);
		if (!SMGraph)
		{
			return FMonolithActionResult::Error(FString::Printf(TEXT("State machine '%s' not found in ABP"), *NodeId));
		}

		TArray<UAnimStateTransitionNode*> Matches;
		for (UEdGraphNode* GraphNode : SMGraph->Nodes)
		{
			UAnimStateTransitionNode* TransitionNode = Cast<UAnimStateTransitionNode>(GraphNode);
			if (!TransitionNode) continue;

			UAnimStateNodeBase* PrevState = TransitionNode->GetPreviousState();
			UAnimStateNodeBase* NextState = TransitionNode->GetNextState();
			if (PrevState && NextState &&
				PrevState->GetStateName() == Parts[0] &&
				NextState->GetStateName() == Parts[1])
			{
				Matches.Add(TransitionNode);
			}
		}

		int32 RemovedCount = 0;
		if (Matches.Num() > 0)
		{
			GEditor->BeginTransaction(FText::FromString(TEXT("Remove Transition By Name")));
			ABP->Modify();
			SMGraph->Modify();
			for (UAnimStateTransitionNode* TransitionNode : Matches)
			{
				FBlueprintEditorUtils::RemoveNode(ABP, TransitionNode, /*bDontRecompile=*/true);
				++RemovedCount;
			}
			GEditor->EndTransaction();

			FBlueprintEditorUtils::MarkBlueprintAsStructurallyModified(ABP);
			FKismetEditorUtilities::CompileBlueprint(ABP);
			ABP->MarkPackageDirty();
		}

		TSharedPtr<FJsonObject> Root = MakeShared<FJsonObject>();
		Root->SetStringField(TEXT("asset_path"), AssetPath);
		Root->SetStringField(TEXT("machine_name"), NodeId);
		Root->SetStringField(TEXT("from_state"), Parts[0]);
		Root->SetStringField(TEXT("to_state"), Parts[1]);
		Root->SetNumberField(TEXT("removed_count"), RemovedCount);
		return FMonolithActionResult::Success(Root);
	}

	if (PropertyPath == TEXT("__RemoveStateAlias"))
	{
		UAnimationStateMachineGraph* SMGraph = FindSMGraphByName(ABP, NodeId);
		if (!SMGraph)
		{
			return FMonolithActionResult::Error(FString::Printf(TEXT("State machine '%s' not found in ABP"), *NodeId));
		}

		UAnimStateAliasNode* AliasNode = Cast<UAnimStateAliasNode>(FindStateNodeBaseByName(SMGraph, Value));
		int32 RemovedCount = 0;
		if (AliasNode)
		{
			GEditor->BeginTransaction(FText::FromString(TEXT("Remove State Alias")));
			ABP->Modify();
			SMGraph->Modify();
			FBlueprintEditorUtils::RemoveNode(ABP, AliasNode, /*bDontRecompile=*/true);
			RemovedCount = 1;
			GEditor->EndTransaction();

			FBlueprintEditorUtils::MarkBlueprintAsStructurallyModified(ABP);
			FKismetEditorUtilities::CompileBlueprint(ABP);
			ABP->MarkPackageDirty();
		}

		TSharedPtr<FJsonObject> Root = MakeShared<FJsonObject>();
		Root->SetStringField(TEXT("asset_path"), AssetPath);
		Root->SetStringField(TEXT("machine_name"), NodeId);
		Root->SetStringField(TEXT("alias_name"), Value);
		Root->SetNumberField(TEXT("removed_count"), RemovedCount);
		return FMonolithActionResult::Success(Root);
	}

	UEdGraphNode* FoundNode = FindNodeByName(ABP, NodeId, ScopeGraph);
	if (!FoundNode)
	{
		return FMonolithActionResult::Error(FString::Printf(TEXT("Node '%s' not found"), *NodeId));
	}

	UAnimGraphNode_Base* AnimNode = Cast<UAnimGraphNode_Base>(FoundNode);
	if (!AnimNode)
	{
		return FMonolithActionResult::Error(FString::Printf(
			TEXT("Node '%s' is not a UAnimGraphNode_Base (class: %s) — this action only mutates anim graph nodes"),
			*NodeId, *FoundNode->GetClass()->GetName()));
	}

	// Find the inner `Node` FStructProperty on the UAnimGraphNode subclass. Every
	// UAnimGraphNode_X has a UPROPERTY-tagged FAnimNode_X field — conventionally
	// named "Node", but some subclasses rename it, so we scan for any FStructProperty
	// whose struct inherits from FAnimNode_Base.
	FStructProperty* NodeStructProp = nullptr;
	for (TFieldIterator<FStructProperty> It(AnimNode->GetClass()); It; ++It)
	{
		FStructProperty* P = *It;
		if (!P || !P->Struct) continue;
		// Heuristic: accept any struct derived from FAnimNode_Base.
		if (P->Struct->IsChildOf(FAnimNode_Base::StaticStruct()))
		{
			NodeStructProp = P;
			break;
		}
	}
	if (!NodeStructProp)
	{
		return FMonolithActionResult::Error(FString::Printf(
			TEXT("Could not locate FAnimNode struct on '%s' — does the class inherit from FAnimNode_Base?"),
			*AnimNode->GetClass()->GetName()));
	}

	void* NodeStructAddr = NodeStructProp->ContainerPtrToValuePtr<void>(AnimNode);

	FProperty* TargetProp   = nullptr;
	void*      TargetContainer = nullptr;
	FString    ResolveError;
	if (!ResolvePropertyPath(NodeStructProp->Struct, NodeStructAddr, PropertyPath, TargetProp, TargetContainer, ResolveError))
	{
		return FMonolithActionResult::Error(ResolveError);
	}

	// Capture old value for diff.
	FString OldValueText;
	TargetProp->ExportText_InContainer(0, OldValueText, TargetContainer, TargetContainer, nullptr, PPF_None);

	// Write via ImportText — same parser the Details panel uses.
	AnimNode->Modify();
	const TCHAR* Buffer = *Value;
	void* TargetValue = TargetProp->ContainerPtrToValuePtr<void>(TargetContainer);
	const TCHAR* ImportResult = TargetProp->ImportText_Direct(Buffer, TargetValue, AnimNode, PPF_None);
	if (!ImportResult)
	{
		return FMonolithActionResult::Error(FString::Printf(
			TEXT("ImportText failed for property '%s' with value '%s'"),
			*PropertyPath, *Value));
	}

	FString NewValueText;
	TargetProp->ExportText_InContainer(0, NewValueText, TargetContainer, TargetContainer, nullptr, PPF_None);

	// Refresh the node's UI and notify the BP so the change isn't lost on next save.
	AnimNode->ReconstructNode();
	ABP->MarkPackageDirty();
	FBlueprintEditorUtils::MarkBlueprintAsStructurallyModified(ABP);

	TSharedPtr<FJsonObject> Root = MakeShared<FJsonObject>();
	Root->SetStringField(TEXT("asset_path"), AssetPath);
	Root->SetStringField(TEXT("node_id"), AnimNode->GetName());
	Root->SetStringField(TEXT("property_path"), PropertyPath);
	Root->SetStringField(TEXT("old_value"), OldValueText);
	Root->SetStringField(TEXT("new_value"), NewValueText);
	return FMonolithActionResult::Success(Root);
}

FMonolithActionResult FMonolithAbpWriteActions::HandleRenameStateMachine(const TSharedPtr<FJsonObject>& Params)
{
	FString AssetPath = Params->GetStringField(TEXT("asset_path"));
	FString OldName = Params->GetStringField(TEXT("old_name"));
	FString NewName = Params->GetStringField(TEXT("new_name"));

	if (OldName.IsEmpty()) return FMonolithActionResult::Error(TEXT("Missing required parameter: old_name"));
	if (NewName.IsEmpty()) return FMonolithActionResult::Error(TEXT("Missing required parameter: new_name"));

	UAnimBlueprint* ABP = FMonolithAssetUtils::LoadAssetByPath<UAnimBlueprint>(AssetPath);
	if (!ABP) return FMonolithActionResult::Error(FString::Printf(TEXT("AnimBlueprint not found: %s"), *AssetPath));

	UAnimGraphNode_StateMachine* SMNode = FindSMNodeByName(ABP, OldName);
	if (!SMNode || !SMNode->EditorStateMachineGraph)
	{
		return FMonolithActionResult::Error(FString::Printf(TEXT("State machine '%s' not found in ABP"), *OldName));
	}
	if (!OldName.Equals(NewName, ESearchCase::CaseSensitive) && FindSMGraphByName(ABP, NewName))
	{
		return FMonolithActionResult::Error(FString::Printf(TEXT("State machine '%s' already exists in ABP"), *NewName));
	}

	GEditor->BeginTransaction(FText::FromString(TEXT("Rename State Machine")));
	ABP->Modify();
	SMNode->Modify();
	SMNode->EditorStateMachineGraph->Modify();
	FBlueprintEditorUtils::RenameGraph(SMNode->EditorStateMachineGraph, NewName);
	SMNode->ReconstructNode();
	GEditor->EndTransaction();

	FKismetEditorUtilities::CompileBlueprint(ABP);
	ABP->MarkPackageDirty();

	TSharedPtr<FJsonObject> Root = MakeShared<FJsonObject>();
	Root->SetStringField(TEXT("asset_path"), AssetPath);
	Root->SetStringField(TEXT("old_name"), OldName);
	Root->SetStringField(TEXT("new_name"), NewName);
	Root->SetStringField(TEXT("node_name"), SMNode->GetName());
	return FMonolithActionResult::Success(Root);
}

FMonolithActionResult FMonolithAbpWriteActions::HandleMoveStateMachineToState(const TSharedPtr<FJsonObject>& Params)
{
	FString AssetPath = Params->GetStringField(TEXT("asset_path"));
	FString MachineName = Params->GetStringField(TEXT("machine_name"));
	FString TargetMachineName = Params->GetStringField(TEXT("target_machine_name"));
	FString TargetStateName = Params->GetStringField(TEXT("target_state_name"));

	double TempVal;
	int32 PosX = 0;
	int32 PosY = 0;
	if (Params->TryGetNumberField(TEXT("position_x"), TempVal)) PosX = static_cast<int32>(TempVal);
	if (Params->TryGetNumberField(TEXT("position_y"), TempVal)) PosY = static_cast<int32>(TempVal);

	if (MachineName.IsEmpty()) return FMonolithActionResult::Error(TEXT("Missing required parameter: machine_name"));
	if (TargetMachineName.IsEmpty()) return FMonolithActionResult::Error(TEXT("Missing required parameter: target_machine_name"));
	if (TargetStateName.IsEmpty()) return FMonolithActionResult::Error(TEXT("Missing required parameter: target_state_name"));

	UAnimBlueprint* ABP = FMonolithAssetUtils::LoadAssetByPath<UAnimBlueprint>(AssetPath);
	if (!ABP) return FMonolithActionResult::Error(FString::Printf(TEXT("AnimBlueprint not found: %s"), *AssetPath));

	UAnimGraphNode_StateMachine* SMNode = FindSMNodeByName(ABP, MachineName);
	if (!SMNode || !SMNode->EditorStateMachineGraph)
	{
		return FMonolithActionResult::Error(FString::Printf(TEXT("State machine '%s' not found in ABP"), *MachineName));
	}

	UAnimationStateMachineGraph* TargetSMGraph = FindSMGraphByName(ABP, TargetMachineName);
	if (!TargetSMGraph)
	{
		return FMonolithActionResult::Error(FString::Printf(TEXT("Target state machine '%s' not found in ABP"), *TargetMachineName));
	}

	UAnimStateNode* TargetState = FindStateByName(TargetSMGraph, TargetStateName);
	if (!TargetState || !TargetState->BoundGraph)
	{
		return FMonolithActionResult::Error(FString::Printf(TEXT("Target state '%s' not found or has no bound graph"), *TargetStateName));
	}

	UEdGraph* SourceGraph = SMNode->GetGraph();
	UEdGraph* TargetGraph = TargetState->BoundGraph;
	if (!SourceGraph || !TargetGraph)
	{
		return FMonolithActionResult::Error(TEXT("Source or target graph is null"));
	}
	if (SourceGraph == TargetGraph)
	{
		return FMonolithActionResult::Success(MakeShared<FJsonObject>());
	}

	GEditor->BeginTransaction(FText::FromString(TEXT("Move State Machine To State")));
	ABP->Modify();
	SourceGraph->Modify();
	TargetGraph->Modify();
	SMNode->Modify();

	SMNode->BreakAllNodeLinks();
	SourceGraph->RemoveNode(SMNode);
	SMNode->Rename(nullptr, TargetGraph, REN_DontCreateRedirectors | REN_NonTransactional);
	TargetGraph->AddNode(SMNode, false, false);
	SMNode->NodePosX = PosX;
	SMNode->NodePosY = PosY;
	SMNode->ReconstructNode();

	GEditor->EndTransaction();

	FBlueprintEditorUtils::MarkBlueprintAsStructurallyModified(ABP);
	FKismetEditorUtilities::CompileBlueprint(ABP);
	ABP->MarkPackageDirty();

	TSharedPtr<FJsonObject> Root = MakeShared<FJsonObject>();
	Root->SetStringField(TEXT("asset_path"), AssetPath);
	Root->SetStringField(TEXT("machine_name"), MachineName);
	Root->SetStringField(TEXT("target_machine_name"), TargetMachineName);
	Root->SetStringField(TEXT("target_state_name"), TargetStateName);
	Root->SetStringField(TEXT("node_name"), SMNode->GetName());
	Root->SetNumberField(TEXT("position_x"), SMNode->NodePosX);
	Root->SetNumberField(TEXT("position_y"), SMNode->NodePosY);
	return FMonolithActionResult::Success(Root);
}
