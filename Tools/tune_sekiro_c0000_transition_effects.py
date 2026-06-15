import json
import re
import xml.etree.ElementTree as ET
from pathlib import Path

from sekiro_monolith_client import MCPClient, MCPError


PROJECT_ROOT = Path(__file__).resolve().parent.parent
ASSET_PATH = "/Game/Animation/Sekiro/C0000/Blueprints/ABP_Sekiro_C0000_Master"
HKX_PATH = Path(r"E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE\chr\c0000-behbnd-dcx\Behaviors\c0000.hkx.xml")
REPORT_PATH = PROJECT_ROOT / "Saved" / "SekiroImportReports" / "c0000_transition_effect_tuning_report.json"

HKX_MACHINES = (
    "StandMove_SM",
    "StandMoveLower_SM",
    "StandMoveUpper_SM",
    "StandMoveableAction_SM",
)

TARGET_MACHINES = (
    "Sekiro_MasterSubset_SM",
    "StandMove_SM",
    "StandMoveLower_SM",
    "StandMoveUpper_SM",
    "StandMoveableAction_SM",
)

IDLE_STATE_BY_MACHINE = {
    "StandMoveUpper_SM": "StandMoveUpperIdle",
    "StandMoveableAction_SM": "StandMoveableActionIdle",
}

SYNTHETIC_EFFECTS = {
    "Sekiro_MasterSubset_SM": {
        ("StandMove", "StandMoveableAction"): "TaeBlend",
        ("StandMoveableAction", "StandMove"): "TaeBlend",
        ("StandMoveableAction", "StandMoveOverwrite"): "TaeBlend",
        ("StandMove", "StandMoveOverwrite"): "TaeBlend",
        ("StandMoveOverwrite", "StandMoveableAction"): "TaeBlend",
        ("StandMoveOverwrite", "StandMove"): "TaeBlend",
    },
    "StandMove_SM": {
        ("StandWalkStop", "StandMoveLoop"): "StateToStateBlendIgnoreToWorld",
        ("StandRunStop", "StandMoveLoop"): "StateToStateBlendIgnoreToWorld",
        ("StandQuickTurnLeft180", "StandMoveLoop"): "StateToStateBlendIgnoreToWorld",
        ("StandQuickTurnRight180", "StandMoveLoop"): "StateToStateBlendIgnoreToWorld",
        ("StandQuickTurnLeft90", "StandMoveLoop"): "StateToStateBlendIgnoreToWorld",
        ("StandQuickTurnRight90", "StandMoveLoop"): "StateToStateBlendIgnoreToWorld",
    },
}

EFFECT_TO_UE_SETTINGS = {
    "TaeBlend": {"crossfade_duration": 0.08, "blend_mode": "LINEAR"},
    "TaeBlend_Sync": {"crossfade_duration": 0.06, "blend_mode": "LINEAR"},
    "TaeBlend_IgnorFromGenerator": {"crossfade_duration": 0.08, "blend_mode": "LINEAR"},
    "TaeBlend_NoSrcMotion_IgnorFromGenerator": {"crossfade_duration": 0.10, "blend_mode": "LINEAR"},
    "StateToStateBlend": {"crossfade_duration": 0.08, "blend_mode": "LINEAR"},
    "StateToStateBlendIgnoreToWorld": {"crossfade_duration": 0.08, "blend_mode": "LINEAR"},
    "SelectStateToStateBlend": {"crossfade_duration": 0.08, "blend_mode": "LINEAR"},
    "SelectBlend": {"crossfade_duration": 0.08, "blend_mode": "LINEAR"},
}


def save_asset_with_fallback(client: MCPClient, asset_path: str):
    try:
        return client.call("blueprint_query", "save_asset", {"asset_path": asset_path})
    except MCPError as exc:
        fallback = client.call(
            "editor_query",
            "run_python",
            {
                "command": (
                    "import json\n"
                    "import unreal\n"
                    f"asset = unreal.load_asset({json.dumps(asset_path, ensure_ascii=False)})\n"
                    "if not asset:\n"
                    "    raise RuntimeError('Failed to load asset for fallback save.')\n"
                    "saved = unreal.EditorAssetLibrary.save_loaded_asset(asset, only_if_is_dirty=False)\n"
                    f"if not saved:\n"
                    f"    saved = unreal.EditorAssetLibrary.save_asset({json.dumps(asset_path, ensure_ascii=False)}, only_if_is_dirty=False)\n"
                    "print(json.dumps({'saved': bool(saved), 'asset_path': asset.get_path_name()}, ensure_ascii=False))\n"
                ),
                "mode": "execute_file",
                "unattended": True,
            },
        )
        return {
            "fallback": True,
            "warning": str(exc),
            "editor_save": fallback,
        }


def load_hkx_objects():
    root = ET.parse(HKX_PATH).getroot()
    objects = {obj.attrib["id"]: obj for obj in root.iter("object")}
    types = {
        type_el.attrib["id"]: type_el.find("name").attrib.get("value")
        for type_el in root.iter("type")
        if type_el.attrib.get("id") and type_el.find("name") is not None
    }
    return root, objects, types


def get_object_type(objects: dict[str, ET.Element], types: dict[str, str], object_id: str) -> str | None:
    obj = objects.get(object_id)
    if obj is None:
        return None
    return types.get(obj.attrib.get("typeid"))


def get_object_name(obj: ET.Element) -> str | None:
    field = obj.find("./record/field[@name='name']")
    if field is None:
        return None
    string_node = field.find("string")
    return string_node.attrib.get("value") if string_node is not None else None


def get_field_int(el: ET.Element, field_name: str, default: int | None = None) -> int | None:
    field = el.find(f"field[@name='{field_name}']") if el.tag == "record" else el.find(f"./record/field[@name='{field_name}']")
    if field is None:
        return default
    integer = field.find("integer")
    return int(integer.attrib["value"]) if integer is not None else default


def get_field_ptr(el: ET.Element, field_name: str) -> str:
    field = el.find(f"field[@name='{field_name}']") if el.tag == "record" else el.find(f"./record/field[@name='{field_name}']")
    if field is None:
        return "object0"
    pointer = field.find("pointer")
    return pointer.attrib.get("id", "object0") if pointer is not None else "object0"


def parse_hkx_transition_effects() -> dict[str, dict[tuple[str, str], dict]]:
    _, objects, types = load_hkx_objects()
    report: dict[str, dict[tuple[str, str], dict]] = {}

    for machine_name in HKX_MACHINES:
        machine_obj = next(obj for obj in objects.values() if get_object_name(obj) == machine_name)
        state_ptrs = machine_obj.find("./record/field[@name='states']/array").findall("pointer")
        state_by_id: dict[int, str] = {}
        machine_effects: dict[tuple[str, str], dict] = {}

        for state_ptr in state_ptrs:
            state_obj = objects[state_ptr.attrib["id"]]
            state_by_id[get_field_int(state_obj, "stateId", -1)] = get_object_name(state_obj) or ""

        def register_transition(from_state: str, record: ET.Element, kind: str):
            to_state_id = get_field_int(record, "toStateId", -1)
            to_state = state_by_id.get(to_state_id, str(to_state_id))
            transition_ptr = get_field_ptr(record, "transition")
            transition_obj = objects.get(transition_ptr)
            transition_name = get_object_name(transition_obj) if transition_obj is not None else None
            machine_effects[(from_state, to_state)] = {
                "effect_name": transition_name,
                "effect_type": get_object_type(objects, types, transition_ptr),
                "transition_ptr": transition_ptr,
                "kind": kind,
            }

        for state_ptr in state_ptrs:
            state_obj = objects[state_ptr.attrib["id"]]
            from_state = get_object_name(state_obj) or ""
            transition_array_ptr = get_field_ptr(state_obj, "transitions")
            if transition_array_ptr == "object0":
                continue
            array = objects[transition_array_ptr].find("./record/field[@name='transitions']/array")
            for record in array.findall("record"):
                register_transition(from_state, record, "local")

        wildcard_ptr = get_field_ptr(machine_obj, "wildcardTransitions")
        if wildcard_ptr != "object0":
            wildcard_array = objects[wildcard_ptr].find("./record/field[@name='transitions']/array")
            for record in wildcard_array.findall("record"):
                register_transition("*", record, "wildcard")

        report[machine_name] = machine_effects

    return report


def parse_transition_title(title: str) -> tuple[str, str] | None:
    match = re.fullmatch(r"(.+?) to (.+)", title.strip())
    if not match:
        return None
    return match.group(1), match.group(2)


def resolve_synthetic_effect(machine_name: str, from_state: str, to_state: str) -> str | None:
    machine_synthetic = SYNTHETIC_EFFECTS.get(machine_name, {})
    direct = machine_synthetic.get((from_state, to_state))
    if direct:
        return direct

    idle_state = IDLE_STATE_BY_MACHINE.get(machine_name)
    if idle_state and to_state == idle_state:
        return "TaeBlend"

    return None


def resolve_effect_name(
    hkx_effects: dict[str, dict[tuple[str, str], dict]],
    machine_name: str,
    from_state: str,
    to_state: str,
    prefer_synthetic: bool = False,
) -> tuple[str | None, str]:
    machine_effects = hkx_effects.get(machine_name, {})
    exact = machine_effects.get((from_state, to_state))
    if exact and exact.get("effect_name"):
        return exact["effect_name"], "hkx_exact"

    if prefer_synthetic:
        synthetic = resolve_synthetic_effect(machine_name, from_state, to_state)
        if synthetic:
            return synthetic, "synthetic"

    wildcard = machine_effects.get(("*", to_state))
    if wildcard and wildcard.get("effect_name"):
        return wildcard["effect_name"], "hkx_wildcard"

    synthetic = resolve_synthetic_effect(machine_name, from_state, to_state)
    if synthetic:
        return synthetic, "synthetic"

    return None, "unmatched"


def resolve_ue_settings(machine_name: str, from_state: str, to_state: str, effect_name: str) -> dict | None:
    settings = EFFECT_TO_UE_SETTINGS.get(effect_name)
    if settings is None:
        return None

    crossfade_duration = settings["crossfade_duration"]
    blend_mode = settings["blend_mode"]

    if effect_name == "SelectBlend":
        if to_state == "StandMoveStart":
            crossfade_duration = 0.10
        elif to_state == "StandMoveLoop":
            crossfade_duration = 0.07

    if machine_name == "StandMove_SM" and from_state == "StandMoveStartFromSprint" and to_state == "StandMoveLoop":
        crossfade_duration = 0.06

    if machine_name == "StandMoveLower_SM" and from_state == "StandMoveLowerStart" and to_state == "StandMoveLowerLoop":
        crossfade_duration = 0.07

    return {
        "effect_name": effect_name,
        "crossfade_duration": crossfade_duration,
        "blend_mode": blend_mode,
    }


def build_patch_plan(client: MCPClient, hkx_effects: dict[str, dict[tuple[str, str], dict]]) -> list[dict]:
    patch_plan: list[dict] = []

    for machine_name in TARGET_MACHINES:
        current_transitions = client.call(
            "animation_query",
            "get_transitions",
            {"asset_path": ASSET_PATH, "machine_name": machine_name},
        ).get("transitions", [])
        rule_titles_by_pair: dict[tuple[str, str], list[str]] = {}
        for transition in current_transitions:
            pair = (str(transition.get("from", "")), str(transition.get("to", "")))
            rule_titles_by_pair[pair] = [str(node.get("title", "")) for node in transition.get("rule_nodes", [])]

        graph_data = client.call(
            "blueprint_query",
            "get_graph_data",
            {"asset_path": ASSET_PATH, "graph_name": machine_name},
        )
        for node in graph_data.get("nodes", []):
            if node.get("class") != "AnimStateTransitionNode":
                continue
            title = str(node.get("title", ""))
            parsed_title = parse_transition_title(title)
            if parsed_title is None:
                continue

            from_state, to_state = parsed_title
            rule_titles = rule_titles_by_pair.get((from_state, to_state), [])
            prefer_synthetic = any(title.startswith("Get Return_") for title in rule_titles)
            effect_name, effect_source = resolve_effect_name(
                hkx_effects,
                machine_name,
                from_state,
                to_state,
                prefer_synthetic=prefer_synthetic,
            )
            if not effect_name:
                continue

            settings = resolve_ue_settings(machine_name, from_state, to_state, effect_name)
            if settings is None:
                continue

            patch_plan.append(
                {
                    "machine_name": machine_name,
                    "node_id": node["id"],
                    "title": title,
                    "from_state": from_state,
                    "to_state": to_state,
                    "rule_titles": rule_titles,
                    "effect_source": effect_source,
                    **settings,
                }
            )

    return patch_plan


def apply_patch_plan(client: MCPClient, patch_plan: list[dict]) -> dict:
    ue_script = (
        "import json\n"
        "import re\n"
        "import unreal\n"
        f"asset_path = {json.dumps(ASSET_PATH, ensure_ascii=False)}\n"
        f"patch_plan = json.loads(r'''{json.dumps(patch_plan, ensure_ascii=False)}''')\n"
        "plan_by_key = {}\n"
        "for item in patch_plan:\n"
        "    key = (item['machine_name'], item['node_id'])\n"
        "    plan_by_key[key] = item\n"
        "bp = unreal.load_asset(asset_path)\n"
        "if not bp:\n"
        "    raise RuntimeError(f'Failed to load AnimBP: {asset_path}')\n"
        "results = []\n"
        "matched = set()\n"
        "for graph in bp.get_animation_graphs():\n"
        "    path = graph.get_path_name()\n"
        "    if not path.endswith('.Transition'):\n"
        "        continue\n"
        "    node_match = re.search(r'\\.([A-Za-z0-9_]+_SM)\\.(AnimStateTransitionNode_\\d+)\\.Transition$', path)\n"
        "    if not node_match:\n"
        "        continue\n"
        "    machine_name = node_match.group(1)\n"
        "    node_id = node_match.group(2)\n"
        "    plan = plan_by_key.get((machine_name, node_id))\n"
        "    if plan is None:\n"
        "        continue\n"
        "    node_path = path[:-len('.Transition')]\n"
        "    node = unreal.find_object(None, node_path)\n"
        "    if not node:\n"
        "        node = unreal.load_object(None, node_path)\n"
        "    if not node:\n"
        "        results.append({\n"
        "            'machine_name': machine_name,\n"
        "            'node_id': node_id,\n"
        "            'title': plan['title'],\n"
        "            'found': False,\n"
        "        })\n"
        "        continue\n"
        "    before_duration = float(node.get_editor_property('crossfade_duration'))\n"
        "    before_mode = str(node.get_editor_property('blend_mode'))\n"
        "    node.set_editor_property('crossfade_duration', float(plan['crossfade_duration']))\n"
        "    node.set_editor_property('blend_mode', getattr(unreal.AlphaBlendOption, plan['blend_mode']))\n"
        "    after_duration = float(node.get_editor_property('crossfade_duration'))\n"
        "    after_mode = str(node.get_editor_property('blend_mode'))\n"
        "    matched.add((machine_name, node_id))\n"
        "    results.append({\n"
        "        'machine_name': machine_name,\n"
        "        'node_id': node_id,\n"
        "        'title': plan['title'],\n"
        "        'effect_name': plan['effect_name'],\n"
        "        'effect_source': plan['effect_source'],\n"
        "        'before_duration': before_duration,\n"
        "        'after_duration': after_duration,\n"
        "        'before_blend_mode': before_mode,\n"
        "        'after_blend_mode': after_mode,\n"
        "        'found': True,\n"
        "    })\n"
        "unmatched = []\n"
        "for item in patch_plan:\n"
        "    key = (item['machine_name'], item['node_id'])\n"
        "    if key not in matched:\n"
        "        unmatched.append({\n"
        "            'machine_name': item['machine_name'],\n"
        "            'node_id': item['node_id'],\n"
        "            'title': item['title'],\n"
        "        })\n"
        "print(json.dumps({\n"
        "    'results': results,\n"
        "    'matched_count': len(matched),\n"
        "    'requested_count': len(patch_plan),\n"
        "    'unmatched': unmatched,\n"
        "}, ensure_ascii=False))\n"
    )

    ue_result = client.call(
        "editor_query",
        "run_python",
        {
            "command": ue_script,
            "mode": "execute_file",
            "unattended": True,
        },
    )
    compile_result = client.call(
        "blueprint_query",
        "compile_blueprint",
        {"asset_path": ASSET_PATH},
    )
    save_result = save_asset_with_fallback(client, ASSET_PATH)
    return {
        "ue_patch": ue_result,
        "compile": compile_result,
        "save": save_result,
    }


def main():
    client = MCPClient()
    hkx_effects = parse_hkx_transition_effects()
    patch_plan = build_patch_plan(client, hkx_effects)
    apply_result = apply_patch_plan(client, patch_plan)

    report = {
        "asset_path": ASSET_PATH,
        "patched_transition_count": len(patch_plan),
        "patch_plan": patch_plan,
        "apply_result": apply_result,
    }

    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
