import importlib.util
import json
import re
import sys
import xml.etree.ElementTree as ET
from collections import defaultdict
from pathlib import Path


TOOLS_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = TOOLS_DIR.parent
HKX_PATH = Path(r"E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE\chr\c0000-behbnd-dcx\Behaviors\c0000.hkx.xml")
EVENTNAME_PATH = Path(r"E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE\action\eventnameid.txt")
EVENTSPECS_PATH = PROJECT_ROOT / "Content" / "Script" / "Sekiro" / "C0000" / "EventSpecs.lua"
MAPPING_PATH = PROJECT_ROOT / "Saved" / "SekiroImportReports" / "c0000_master_animbp_mapping.json"
REPORT_PATH = PROJECT_ROOT / "Saved" / "SekiroImportReports" / "c0000_state_match_audit.json"
BUILD_SCRIPT_PATH = TOOLS_DIR / "build_sekiro_master_subset_abp.py"

TARGET_MACHINES = (
    "StandMove_SM",
    "StandMoveLower_SM",
    "StandMoveUpper_SM",
    "StandMoveableAction_SM",
)

SYNTHETIC_STATES = {
    "StandMoveUpper_SM": "StandMoveUpperIdle",
    "StandMoveableAction_SM": "StandMoveableActionIdle",
}

STANDMOVE_EVENT_TO_STATE = {
    "W_StandMoveStart": "StandMoveStart",
    "W_StandMoveStartFromFreeFall": "StandMoveStartFromFreeFall",
    "W_StandMoveStartFromFreeFallShortStiff": "StandMoveStartFromFreeFallShortStiff",
    "W_StandMoveStartFromLandGroundPositioningJump": "StandMoveStartFromLandGroundPositioningJump",
    "W_StandWalkStop": "StandWalkStop",
    "W_StandRunStop": "StandRunStop",
    "W_StandQuickTurnRight180": "StandQuickTurnRight180",
    "W_StandQuickTurnLeft180": "StandQuickTurnLeft180",
    "W_StandQuickTurnMoveStartLeft180": "StandQuickTurnMoveStartLeft180",
    "W_StandQuickTurnMoveStartRight180": "StandQuickTurnMoveStartRight180",
    "W_StandMoveQuickTurnLeft180": "StandMoveQuickTurnLeft180",
    "W_StandMoveQuickTurnRight180": "StandMoveQuickTurnRight180",
    "W_StandQuickTurnLeft90": "StandQuickTurnLeft90",
    "W_StandQuickTurnRight90": "StandQuickTurnRight90",
    "W_StandMoveStartFromSprint": "StandMoveStartFromSprint",
}

PULSE_ONLY_EVENT_TO_STATE = {
    "W_StandMoveLoop": "StandMoveLoop",
    "W_StandMoveLoopSync": "StandMoveLoop",
    "W_StandMoveLoopFromSprint": "StandMoveLoopFromSprint",
}


def stem_from_asset_path(asset_path: str | None) -> str | None:
    if not asset_path:
        return None
    leaf = asset_path.rsplit("/", 1)[-1]
    return leaf.split(".", 1)[0]


def req_var_from_event_name(event_name: str | None) -> str | None:
    if not event_name:
        return None
    return f"Req_{event_name}"


def load_build_module():
    sys.path.insert(0, str(TOOLS_DIR))
    spec = importlib.util.spec_from_file_location("build_sekiro_master_subset_abp", BUILD_SCRIPT_PATH)
    module = importlib.util.module_from_spec(spec)
    assert spec and spec.loader
    spec.loader.exec_module(module)
    return module


def parse_event_names() -> dict[int, str]:
    text = EVENTNAME_PATH.read_text(encoding="utf-8-sig", errors="ignore")
    event_names: dict[int, str] = {}
    for line in text.splitlines():
        match = re.match(r'\s*(\d+)\s*=\s*"([^"]+)"', line)
        if match:
            event_names[int(match.group(1))] = match.group(2)
    return event_names


def parse_event_specs() -> dict[str, dict[str, dict]]:
    sections: dict[str, dict[str, dict]] = {}
    current_section: str | None = None
    current_event: str | None = None

    for raw_line in EVENTSPECS_PATH.read_text(encoding="utf-8").splitlines():
        stripped = raw_line.strip()
        if not stripped or stripped.startswith("--"):
            continue

        if current_section is None:
            match = re.match(r"M\.(\w+)\s*=\s*{", stripped)
            if match:
                current_section = match.group(1)
                sections[current_section] = {}
            continue

        if current_event is None:
            if stripped == "}":
                current_section = None
                continue
            match = re.match(r"([A-Za-z0-9_]+)\s*=\s*{", stripped)
            if match:
                current_event = match.group(1)
                sections[current_section][current_event] = {}
            continue

        if stripped.startswith("},") or stripped == "}":
            current_event = None
            continue

        match = re.match(r"([A-Za-z0-9_]+)\s*=\s*(.+?)(,)?$", stripped)
        if not match:
            continue

        key = match.group(1)
        value_text = match.group(2).strip()
        if value_text.startswith('"') and value_text.endswith('"'):
            value = value_text[1:-1]
        elif re.fullmatch(r"-?\d+", value_text):
            value = int(value_text)
        else:
            value = value_text
        sections[current_section][current_event][key] = value

    return sections


def get_object_name(obj) -> str | None:
    field = obj.find("./record/field[@name='name']")
    if field is None:
        return None
    string_node = field.find("string")
    return string_node.attrib.get("value") if string_node is not None else None


def get_pointer_id(obj, field_name: str) -> str:
    field = obj.find(f"./record/field[@name='{field_name}']")
    if field is None:
        return "object0"
    pointer = field.find("pointer")
    return pointer.attrib.get("id", "object0") if pointer is not None else "object0"


def get_int_field(obj, field_name: str, default: int | None = None) -> int | None:
    field = obj.find(f"./record/field[@name='{field_name}']")
    if field is None:
        return default
    integer = field.find("integer")
    return int(integer.attrib["value"]) if integer is not None else default


def collect_animation_names(objects: dict[str, ET.Element], object_id: str, seen: set[str] | None = None) -> set[str]:
    if object_id == "object0":
        return set()
    if seen is None:
        seen = set()
    if object_id in seen:
        return set()
    seen.add(object_id)

    obj = objects[object_id]
    record = obj.find("record")
    if record is None:
        return set()

    names: set[str] = set()
    animation_name = record.find("field[@name='animationName']/string")
    if animation_name is not None:
        names.add(animation_name.attrib["value"])

    for field in record.findall("field"):
        for pointer in field.findall(".//pointer"):
            target_id = pointer.attrib.get("id")
            if target_id and target_id != "object0":
                names.update(collect_animation_names(objects, target_id, seen))

    return names


def parse_hkx_machines(event_names: dict[int, str]) -> dict[str, dict]:
    root = ET.parse(HKX_PATH).getroot()
    objects = {obj.attrib["id"]: obj for obj in root.iter("object")}

    def transition_from_record(record: ET.Element) -> dict:
        event_id = int(record.find("field[@name='eventId']/integer").attrib["value"])
        return {
            "event_id": event_id,
            "event_name": event_names.get(event_id, f"<event:{event_id}>"),
            "to_state_id": int(record.find("field[@name='toStateId']/integer").attrib["value"]),
            "flags": int(record.find("field[@name='flags']/integer").attrib["value"]),
        }

    machines: dict[str, dict] = {}
    for machine_name in TARGET_MACHINES:
        machine_obj = next(obj for obj in objects.values() if get_object_name(obj) == machine_name)
        state_ptrs = machine_obj.find("./record/field[@name='states']/array").findall("pointer")

        states_by_id: dict[int, dict] = {}
        states_by_name: dict[str, dict] = {}
        for state_ptr in state_ptrs:
            state_obj = objects[state_ptr.attrib["id"]]
            state_name = get_object_name(state_obj)
            state_id = get_int_field(state_obj, "stateId", -1)
            local_transition_ptr = get_pointer_id(state_obj, "transitions")
            local_transitions: list[dict] = []
            if local_transition_ptr != "object0":
                local_array = objects[local_transition_ptr].find("./record/field[@name='transitions']/array")
                local_transitions = [transition_from_record(record) for record in local_array.findall("record")]

            state_info = {
                "state_id": state_id,
                "name": state_name,
                "animations": sorted(collect_animation_names(objects, get_pointer_id(state_obj, "generator"))),
                "local_transitions": local_transitions,
            }
            states_by_id[state_id] = state_info
            states_by_name[state_name] = state_info

        wildcard_ptr = get_pointer_id(machine_obj, "wildcardTransitions")
        wildcard_transitions: list[dict] = []
        if wildcard_ptr != "object0":
            wildcard_array = objects[wildcard_ptr].find("./record/field[@name='transitions']/array")
            wildcard_transitions = [transition_from_record(record) for record in wildcard_array.findall("record")]

        machines[machine_name] = {
            "name": machine_name,
            "start_state_id": get_int_field(machine_obj, "startStateId", -1),
            "states_by_id": states_by_id,
            "states_by_name": states_by_name,
            "wildcard_transitions": wildcard_transitions,
        }

    return machines


def load_mapping_snapshot() -> dict[str, dict]:
    data = json.loads(MAPPING_PATH.read_text(encoding="utf-8"))
    machines = {}
    for machine in data["state_machine_snapshot"]["state_machines"]:
        name = machine["name"]
        if name in TARGET_MACHINES:
            machines[name] = machine
    return machines


def compare_machine(machine_name: str, hkx_machine: dict, ue_machine: dict, build_machine: dict) -> dict:
    hkx_state_names = sorted(hkx_machine["states_by_name"])
    ue_state_names = sorted(state["name"] for state in ue_machine["states"])
    hkx_state_set = set(hkx_state_names)
    ue_state_set = set(ue_state_names)

    extra_states = sorted(ue_state_set - hkx_state_set)
    missing_states = sorted(hkx_state_set - ue_state_set)
    synthetic_state = SYNTHETIC_STATES.get(machine_name)
    synthetic_extra_states = [state for state in extra_states if state == synthetic_state]
    non_synthetic_extra_states = [state for state in extra_states if state != synthetic_state]

    ue_transition_pairs = {(transition["from"], transition["to"]) for transition in ue_machine["transitions"]}
    missing_local_transitions = []
    for state_name, state_info in sorted(hkx_machine["states_by_name"].items()):
        for transition in state_info["local_transitions"]:
            to_state = hkx_machine["states_by_id"][transition["to_state_id"]]["name"]
            if (state_name, to_state) not in ue_transition_pairs:
                missing_local_transitions.append(
                    {
                        "from": state_name,
                        "to": to_state,
                        "event_name": transition["event_name"],
                    }
                )

    ue_sources_by_target: dict[str, set[str]] = defaultdict(set)
    for transition in ue_machine["transitions"]:
        ue_sources_by_target[transition["to"]].add(transition["from"])

    wildcard_coverage_gaps = []
    for transition in hkx_machine["wildcard_transitions"]:
        target_state = hkx_machine["states_by_id"][transition["to_state_id"]]["name"]
        actual_sources = sorted(ue_sources_by_target.get(target_state, set()))
        missing_sources = sorted(hkx_state_set - set(actual_sources))
        if missing_sources:
            wildcard_coverage_gaps.append(
                {
                    "event_name": transition["event_name"],
                    "to_state": target_state,
                    "expected_source_count": len(hkx_state_names),
                    "actual_source_count": len(actual_sources),
                    "missing_sources": missing_sources,
                }
            )

    build_state_assets = {state["name"]: stem_from_asset_path(state["anim"]) for state in build_machine["states"]}
    build_asset_mismatches = []
    representative_state_assets = []
    for state_name in hkx_state_names:
        hkx_anims = hkx_machine["states_by_name"][state_name]["animations"]
        build_asset = build_state_assets.get(state_name)
        if build_asset is None:
            continue
        if build_asset not in hkx_anims:
            build_asset_mismatches.append(
                {
                    "state": state_name,
                    "build_asset": build_asset,
                    "hkx_animations": hkx_anims,
                }
            )
        elif len(hkx_anims) > 1:
            representative_state_assets.append(
                {
                    "state": state_name,
                    "build_asset": build_asset,
                    "hkx_animation_count": len(hkx_anims),
                }
            )

    return {
        "hkx_state_count": len(hkx_state_names),
        "ue_state_count": len(ue_state_names),
        "missing_states": missing_states,
        "synthetic_extra_states": synthetic_extra_states,
        "non_synthetic_extra_states": non_synthetic_extra_states,
        "missing_local_transitions": missing_local_transitions,
        "wildcard_coverage_gaps": wildcard_coverage_gaps,
        "build_asset_mismatches": build_asset_mismatches,
        "representative_state_assets": representative_state_assets,
    }


def audit_standmove_event_specs(event_specs: dict, hkx_machine: dict) -> list[dict]:
    findings: list[dict] = []
    wildcard_by_target = defaultdict(list)
    for transition in hkx_machine["wildcard_transitions"]:
        wildcard_by_target[transition["to_state_id"]].append(transition["event_name"])

    for event_name, state_name in STANDMOVE_EVENT_TO_STATE.items():
        spec = event_specs["StandMovePulseEvents"].get(event_name)
        if not spec:
            findings.append({"event": event_name, "issue": "missing_event_spec"})
            continue

        state_info = hkx_machine["states_by_name"][state_name]
        hkx_anims = state_info["animations"]
        asset_stem = stem_from_asset_path(spec.get("asset"))
        if asset_stem not in hkx_anims:
            findings.append(
                {
                    "event": event_name,
                    "issue": "asset_mismatch",
                    "asset": asset_stem,
                    "hkx_animations": hkx_anims,
                }
            )

        request_candidates = wildcard_by_target.get(state_info["state_id"], [])
        if len(request_candidates) == 1:
            expected_request = req_var_from_event_name(request_candidates[0])
            if spec.get("request") != expected_request:
                findings.append(
                    {
                        "event": event_name,
                        "issue": "request_mismatch",
                        "expected_request": expected_request,
                        "actual_request": spec.get("request"),
                    }
                )

    for event_name, state_name in PULSE_ONLY_EVENT_TO_STATE.items():
        spec = event_specs["PulseOnlyEvents"].get(event_name)
        if not spec:
            findings.append({"event": event_name, "issue": "missing_event_spec"})
            continue

        state_info = hkx_machine["states_by_name"][state_name]
        wildcard_candidates = wildcard_by_target.get(state_info["state_id"], [])
        if event_name != "W_StandMoveLoop" and len(wildcard_candidates) == 1:
            expected_request = req_var_from_event_name(wildcard_candidates[0])
            if spec.get("request") != expected_request:
                findings.append(
                    {
                        "event": event_name,
                        "issue": "request_mismatch",
                        "expected_request": expected_request,
                        "actual_request": spec.get("request"),
                    }
                )

        asset_stem = stem_from_asset_path(spec.get("asset"))
        if asset_stem and asset_stem not in state_info["animations"]:
            findings.append(
                {
                    "event": event_name,
                    "issue": "asset_mismatch",
                    "asset": asset_stem,
                    "hkx_animations": state_info["animations"],
                }
            )

    lower_spec = event_specs["OverwriteLowerEvents"].get("W_StandMoveLowerStart")
    if lower_spec:
        lower_state = hkx_machines["StandMoveLower_SM"]["states_by_name"]["StandMoveLowerStart"]
        lower_asset = stem_from_asset_path(lower_spec.get("asset"))
        if lower_asset not in lower_state["animations"]:
            findings.append(
                {
                    "event": "W_StandMoveLowerStart",
                    "issue": "asset_mismatch",
                    "asset": lower_asset,
                    "hkx_animations": lower_state["animations"],
                }
            )

    return findings


def audit_action_event_specs(section_name: str, machine_name: str, event_specs: dict, hkx_machine: dict) -> list[dict]:
    findings: list[dict] = []
    for event_name, spec in event_specs[section_name].items():
        state_id = spec.get("state_id")
        state_info = hkx_machine["states_by_id"].get(state_id)
        if state_info is None:
            findings.append({"event": event_name, "issue": "unknown_state_id", "state_id": state_id})
            continue

        asset_stem = stem_from_asset_path(spec.get("asset"))
        if asset_stem not in state_info["animations"]:
            findings.append(
                {
                    "event": event_name,
                    "machine": machine_name,
                    "issue": "asset_mismatch",
                    "state_id": state_id,
                    "state": state_info["name"],
                    "asset": asset_stem,
                    "hkx_animations": state_info["animations"],
                }
            )
    return findings


build_module = load_build_module()
hkx_machines = parse_hkx_machines(parse_event_names())
mapping_machines = load_mapping_snapshot()
event_specs = parse_event_specs()
build_machines = {
    machine_spec["machine_name"]: machine_spec
    for machine_spec in build_module.MACHINE_SPECS
    if machine_spec["machine_name"] in TARGET_MACHINES
}

report = {
    "sources": {
        "hkx_xml": str(HKX_PATH),
        "event_names": str(EVENTNAME_PATH),
        "event_specs": str(EVENTSPECS_PATH),
        "mapping_snapshot": str(MAPPING_PATH),
        "build_script": str(BUILD_SCRIPT_PATH),
    },
    "machine_audit": {},
    "event_spec_audit": {
        "standmove": audit_standmove_event_specs(event_specs, hkx_machines["StandMove_SM"]),
        "standmoveable_action": audit_action_event_specs(
            "ActionIdleEvents",
            "StandMoveableAction_SM",
            event_specs,
            hkx_machines["StandMoveableAction_SM"],
        ),
        "standmove_upper": audit_action_event_specs(
            "ActionMoveEvents",
            "StandMoveUpper_SM",
            event_specs,
            hkx_machines["StandMoveUpper_SM"],
        ),
    },
    "notes": [
        "StandMoveUpper_SM and StandMoveableAction_SM in HKX are wildcard-driven and have no explicit idle state.",
        "UE keeps a synthetic idle parking state for those two machines, but concrete-state selector transitions should still mirror HKX wildcard coverage aside from unsupported self-transitions.",
        "Representative state assets are acceptable when the chosen UE asset still belongs to the HKX selector's animation set.",
    ],
}

for machine_name in TARGET_MACHINES:
    report["machine_audit"][machine_name] = compare_machine(
        machine_name,
        hkx_machines[machine_name],
        mapping_machines[machine_name],
        build_machines[machine_name],
    )

REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
REPORT_PATH.write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
print(json.dumps(report, indent=2, ensure_ascii=False))
