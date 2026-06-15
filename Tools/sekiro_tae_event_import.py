import os
import re
import xml.etree.ElementTree as ET

import unreal


SP_EFFECT_TAE_TYPES = {66, 67, 302, 401, 797, 940}

SP_EFFECT_BEHAVIOR_REF_IDS = {
    100274: 227,
    100296: 231,
    100338: 208,
    100357: 215,
    100358: 216,
    100360: 217,
    100361: 218,
    100367: 221,
    100368: 311,
    100397: 318,
}


def get_anim_lib():
    return unreal.AnimationLibrary if hasattr(unreal, "AnimationLibrary") else unreal.AnimationBlueprintLibrary


def infer_animation_id(args):
    for value in (args.asset, args.hkx_json, args.fbx, args.tae_xml):
        match = re.search(r"a(\d{3})[_-](\d{6})", str(value or ""), re.IGNORECASE)
        if match:
            return {
                "prefix": match.group(1),
                "anim_id": match.group(2),
                "asset_name": f"a{match.group(1)}_{match.group(2)}",
            }
    return None


def infer_tae_xml_path(args):
    if args.tae_xml:
        return args.tae_xml
    info = infer_animation_id(args)
    if not info:
        return ""
    tae_group = f"a{int(info['prefix']):02d}-tae"
    return os.path.join(args.tae_root, tae_group, f"anim-{info['anim_id']}.xml")


def parse_tae_float(text, default=0.0):
    try:
        return float(text)
    except (TypeError, ValueError):
        return default


def parse_int(value, default=-1):
    try:
        return int(float(value))
    except (TypeError, ValueError):
        return default


def format_tae_value(value):
    text = str(value)
    try:
        number = float(text)
    except ValueError:
        return text
    if number.is_integer():
        return str(int(number))
    return f"{number:.6f}".rstrip("0").rstrip(".")


def make_tae_source_arguments(tae_type, unk04, params):
    pairs = [
        ("TaeType", str(tae_type)),
        ("Unk04", str(unk04)),
    ]
    pairs.extend(params)
    return "; ".join(f"{key}={format_tae_value(value)}" for key, value in pairs)


def normalize_tae_params(tae_type, params):
    if int(tae_type) != 1:
        return params
    return [
        ("field_1" if key in {"Unk04", "Field1"} else key, value)
        for key, value in params
    ]


def parse_source_arguments(source_arguments):
    result = {}
    ordered = []
    for pair in str(source_arguments).split(";"):
        if "=" not in pair:
            continue
        key, value = pair.split("=", 1)
        clean_key = key.strip()
        clean_value = value.strip()
        result[clean_key.lower()] = clean_value
        ordered.append((clean_key, clean_value))
    result["_ordered"] = ordered
    return result


def parse_int_param(params, *names):
    wanted = set(names)
    for key, value in params:
        if key in wanted:
            try:
                return int(float(value))
            except (TypeError, ValueError):
                return None
    return None


def parse_float_param(params, *names):
    wanted = set(names)
    for key, value in params:
        if key in wanted:
            try:
                return float(value)
            except (TypeError, ValueError):
                return None
    return None


def parse_bool_param(params, *names):
    wanted = set(names)
    for key, value in params:
        if key in wanted:
            text = str(value).strip().lower()
            if text in {"true", "1", "yes"}:
                return True
            if text in {"false", "0", "no"}:
                return False
    return None


def make_tae_parameter_summary(params):
    return "; ".join(f"{key}={format_tae_value(value)}" for key, value in params)


def make_tae_parameter_slots(params, max_slots=8):
    slots = []
    for key, value in list(params)[:max_slots]:
        slots.append({
            "name": key,
            "value": format_tae_value(value),
            "number": parse_tae_float(value, 0.0),
        })
    while len(slots) < max_slots:
        slots.append({
            "name": "",
            "value": "",
            "number": 0.0,
        })
    return slots


def make_raw_tae_event_name(tae_type, jump_table_id):
    return f"TAE_{tae_type}_{jump_table_id}" if tae_type == 0 and jump_table_id is not None else f"TAE_{tae_type}"


def make_import_event_name(tae_type, raw_event_name, sp_effect_id):
    if tae_type in SP_EFFECT_TAE_TYPES and sp_effect_id is not None:
        return "Gate_SpEffect"
    return raw_event_name


def resolve_behavior_ref_id(tae_type, jump_table_id, sp_effect_id):
    if tae_type == 0:
        return jump_table_id
    if tae_type in SP_EFFECT_TAE_TYPES and sp_effect_id is not None:
        return SP_EFFECT_BEHAVIOR_REF_IDS.get(sp_effect_id, sp_effect_id)
    return tae_type


def load_tae_events(args):
    if args.tae_events == "skip":
        return {
            "mode": "skip",
            "events": [],
        }

    tae_xml = infer_tae_xml_path(args)
    if not tae_xml:
        return {
            "mode": "import",
            "skipped": "could not infer TAE XML path",
            "events": [],
        }
    if not os.path.isfile(tae_xml):
        return {
            "mode": "import",
            "tae_xml": tae_xml,
            "skipped": "TAE XML not found",
            "events": [],
        }

    root = ET.parse(tae_xml).getroot()
    events = []
    for node in root.findall("./events/event"):
        tae_type_text = node.findtext("type")
        if tae_type_text is None:
            continue
        tae_type = int(float(tae_type_text))
        unk04 = int(float(node.findtext("unk04", "0")))
        start = parse_tae_float(node.findtext("startTime"))
        end = parse_tae_float(node.findtext("endTime"), start)
        params = [
            (param.attrib.get("name", ""), param.attrib.get("value", ""))
            for param in node.findall("./params/param")
            if param.attrib.get("name")
        ]
        params = normalize_tae_params(tae_type, params)

        jump_table_id = parse_int_param(params, "JumpTableID")
        sp_effect_id = parse_int_param(params, "SpEffectID", "SpEffectId", "BehaviorJudgeId")
        raw_event_name = make_raw_tae_event_name(tae_type, jump_table_id)
        behavior_ref_id = resolve_behavior_ref_id(tae_type, jump_table_id, sp_effect_id)
        duration = max(0.001, end - start)
        events.append({
            "event_name": make_import_event_name(tae_type, raw_event_name, sp_effect_id),
            "raw_event_name": raw_event_name,
            "tae_type": tae_type,
            "tae_jump_table_id": jump_table_id,
            "sp_effect_id": sp_effect_id,
            "behavior_ref_id": behavior_ref_id,
            "unk04": unk04,
            "start": start,
            "end": end,
            "duration": duration,
            "tae_parameter_summary": make_tae_parameter_summary(params),
            "tae_parameter_slots": make_tae_parameter_slots(params),
            "is_female_anim": parse_bool_param(params, "IsFemaleAnim"),
            "anim_id": parse_int_param(params, "AnimID"),
            "anim_weight_at_event_start": parse_float_param(params, "AnimWeightAtEventStart"),
            "anim_weight_at_event_end": parse_float_param(params, "AnimWeightAtEventEnd"),
            "tae_unk00": parse_float_param(params, "Unk00"),
            "tae_unk04": parse_float_param(params, "Unk04"),
            "tae_unk08": parse_float_param(params, "Unk08"),
            "tae_unk0c": parse_float_param(params, "Unk0C"),
            "attack_type": parse_int_param(params, "AttackType"),
            "attack_field_1": parse_int_param(params, "field_1", "Field1", "Unk04"),
            "behavior_judge_id": parse_int_param(params, "BehaviorJudgeID", "BehaviorJudgeId"),
            "direction_type": parse_int_param(params, "DirectionType"),
            "attack_source": parse_int_param(params, "Source"),
            "state_info": parse_int_param(params, "StateInfo"),
            "source_arguments": make_tae_source_arguments(tae_type, unk04, params),
        })

    events.sort(key=lambda event: (event["start"], event["end"], event["event_name"]))
    return {
        "mode": "import",
        "tae_xml": tae_xml,
        "events": events,
    }


def get_sekiro_notify_state_class():
    notify_class = getattr(unreal, "SekiroMovementAnimNotifyState", None)
    if notify_class is None:
        raise RuntimeError(
            "SekiroMovementAnimNotifyState is not available in Python. "
            "Compile the project module before importing TAE events."
        )
    return notify_class


def get_notify_class_or_default(class_name, default_class):
    return getattr(unreal, class_name, None) or default_class


def is_sp_effect_tae_type(tae_type):
    return tae_type in SP_EFFECT_TAE_TYPES


def get_sekiro_notify_state_class_for_event(event):
    default_class = get_sekiro_notify_state_class()
    tae_type = int(event.get("tae_type", -1))
    if tae_type == 0:
        return get_notify_class_or_default("SekiroTaeJumpTableNotifyState", default_class)
    if tae_type == 1:
        return get_notify_class_or_default("SekiroTaeAttackBehaviorNotifyState", default_class)
    if is_sp_effect_tae_type(tae_type) or event.get("event_name") == "Gate_SpEffect":
        return get_notify_class_or_default("SekiroTaeSpEffectNotifyState", default_class)
    if tae_type == 605:
        return get_notify_class_or_default("SekiroTaeAnimBlendNotifyState", default_class)
    if tae_type == 607:
        return get_notify_class_or_default("SekiroTaeUnknownVectorNotifyState", default_class)
    if event.get("tae_parameter_summary"):
        return get_notify_class_or_default("SekiroTaeParameterizedNotifyState", default_class)
    return default_class


def is_sekiro_notify_state(notify_state):
    if not notify_state:
        return False
    class_name = notify_state.get_class().get_name()
    return class_name in {
        "SekiroMovementAnimNotifyState",
        "SekiroTaeJumpTableNotifyState",
        "SekiroTaeAttackBehaviorNotifyState",
        "SekiroTaeSpEffectNotifyState",
        "SekiroTaeParameterizedNotifyState",
        "SekiroTaeAnimBlendNotifyState",
        "SekiroTaeUnknownVectorNotifyState",
    }


def set_notify_property_with_fallback(notify, property_names, value):
    errors = []
    for property_name in property_names:
        try:
            notify.set_editor_property(property_name, value)
            return {
                "property": property_name,
                "written": True,
            }
        except Exception as exc:
            errors.append(f"{property_name}: {exc}")
    return {
        "property": property_names[0] if property_names else "",
        "written": False,
        "errors": errors,
    }


def set_notify_property(notify, property_names, value):
    return set_notify_property_with_fallback(notify, property_names, value).get("written", False)


def remove_existing_tae_notify_track(anim, track_name):
    lib = get_anim_lib()
    track = unreal.Name(track_name)
    removed = 0
    try:
        for existing_track in list(lib.get_animation_notify_track_names(anim)):
            events = list(lib.get_animation_notify_events_for_track(anim, existing_track))
            if not events:
                continue
            should_remove = str(existing_track) == str(track_name)
            if not should_remove:
                for event in events:
                    try:
                        notify_state = event.get_editor_property("notify_state_class")
                    except Exception:
                        notify_state = None
                    if is_sekiro_notify_state(notify_state):
                        should_remove = True
                        break
            if should_remove:
                try:
                    removed += int(lib.remove_animation_notify_events_by_track(anim, existing_track))
                except Exception:
                    pass
                try:
                    lib.remove_animation_notify_track(anim, existing_track)
                except Exception:
                    pass
    except Exception:
        pass

    try:
        removed = int(lib.remove_animation_notify_events_by_track(anim, track))
    except Exception:
        pass

    try:
        if lib.is_valid_anim_notify_track_name(anim, track):
            lib.remove_animation_notify_track(anim, track)
    except Exception:
        pass
    return removed


def apply_tae_events(anim, args):
    tae_data = load_tae_events(args)
    events = tae_data.get("events", [])
    removed = 0
    if tae_data.get("mode") == "import":
        removed = remove_existing_tae_notify_track(anim, args.tae_track_name)
    result = {
        "mode": tae_data.get("mode"),
        "tae_xml": tae_data.get("tae_xml", ""),
        "track_name": args.tae_track_name,
        "source_event_count": len(events),
        "removed_existing_track_events": removed,
    }
    if tae_data.get("skipped"):
        result["skipped"] = tae_data["skipped"]
        return result
    if not events:
        return result

    lib = get_anim_lib()
    track = unreal.Name(args.tae_track_name)
    lib.add_animation_notify_track(anim, track, unreal.LinearColor(0.18, 0.45, 1.0, 1.0))

    added = []
    play_length = float(anim.get_play_length())
    for event in events:
        start = max(0.0, min(float(event["start"]), play_length))
        duration = max(0.001, min(float(event["duration"]), max(0.001, play_length - start)))
        notify = lib.add_animation_notify_state_event(
            anim,
            track,
            start,
            duration,
            get_sekiro_notify_state_class_for_event(event),
        )
        if notify is None:
            added.append({
                "event_name": event["event_name"],
                "start": round(start, 6),
                "duration": round(duration, 6),
                "added": False,
            })
            continue
        notify.set_editor_property("event_name", unreal.Name(event["event_name"]))
        notify.set_editor_property("numeric_value", float(event["tae_type"]))
        set_notify_property_with_fallback(
            notify,
            ["source_arguments", "SourceArguments"],
            event["source_arguments"],
        )
        property_writes = {
            "raw_event_name": set_notify_property_with_fallback(
                notify,
                ["raw_event_name", "RawEventName"],
                unreal.Name(event["raw_event_name"]),
            ),
            "tae_type": set_notify_property_with_fallback(notify, ["tae_type", "TaeType"], int(event["tae_type"])),
            "tae_jump_table_id": set_notify_property_with_fallback(
                notify,
                ["jump_table_id", "JumpTableID", "tae_jump_table_id", "TaeJumpTableID"],
                int(event["tae_jump_table_id"]) if event["tae_jump_table_id"] is not None else -1,
            ),
            "sp_effect_id": set_notify_property_with_fallback(
                notify,
                ["sp_effect_id", "SpEffectID"],
                int(event["sp_effect_id"]) if event["sp_effect_id"] is not None else -1,
            ),
            "behavior_ref_id": set_notify_property_with_fallback(
                notify,
                ["behavior_ref_id", "BehaviorRefID"],
                int(event["behavior_ref_id"]) if event["behavior_ref_id"] is not None else -1,
            ),
            "tae_parameter_summary": set_notify_property_with_fallback(
                notify,
                ["tae_parameter_summary", "TaeParameterSummary"],
                event["tae_parameter_summary"],
            ),
            "is_female_anim": set_notify_property_with_fallback(
                notify,
                ["is_female_anim", "b_is_female_anim", "bIsFemaleAnim", "IsFemaleAnim"],
                bool(event["is_female_anim"]) if event["is_female_anim"] is not None else False,
            ),
            "anim_id": set_notify_property_with_fallback(
                notify,
                ["anim_id", "AnimID"],
                int(event["anim_id"]) if event["anim_id"] is not None else -1,
            ),
            "anim_weight_at_event_start": set_notify_property_with_fallback(
                notify,
                ["anim_weight_at_event_start", "AnimWeightAtEventStart"],
                float(event["anim_weight_at_event_start"]) if event["anim_weight_at_event_start"] is not None else 0.0,
            ),
            "anim_weight_at_event_end": set_notify_property_with_fallback(
                notify,
                ["anim_weight_at_event_end", "AnimWeightAtEventEnd"],
                float(event["anim_weight_at_event_end"]) if event["anim_weight_at_event_end"] is not None else 0.0,
            ),
            "tae_unk00": set_notify_property_with_fallback(
                notify,
                ["tae_unk00", "TaeUnk00"],
                float(event["tae_unk00"]) if event["tae_unk00"] is not None else 0.0,
            ),
            "tae_unk04": set_notify_property_with_fallback(
                notify,
                ["tae_unk04", "TaeUnk04"],
                float(event["tae_unk04"]) if event["tae_unk04"] is not None else 0.0,
            ),
            "tae_unk08": set_notify_property_with_fallback(
                notify,
                ["tae_unk08", "TaeUnk08"],
                float(event["tae_unk08"]) if event["tae_unk08"] is not None else 0.0,
            ),
            "tae_unk0c": set_notify_property_with_fallback(
                notify,
                ["tae_unk0c", "TaeUnk0C"],
                float(event["tae_unk0c"]) if event["tae_unk0c"] is not None else 0.0,
            ),
            "attack_type": set_notify_property_with_fallback(
                notify,
                ["attack_type", "AttackType"],
                int(event["attack_type"]) if event["attack_type"] is not None else -1,
            ),
            "attack_field_1": set_notify_property_with_fallback(
                notify,
                ["field1", "field_1", "Field1", "attack_field_1"],
                int(event["attack_field_1"]) if event["attack_field_1"] is not None else -1,
            ),
            "behavior_judge_id": set_notify_property_with_fallback(
                notify,
                ["behavior_judge_id", "BehaviorJudgeID"],
                int(event["behavior_judge_id"]) if event["behavior_judge_id"] is not None else -1,
            ),
            "direction_type": set_notify_property_with_fallback(
                notify,
                ["direction_type", "DirectionType"],
                int(event["direction_type"]) if event["direction_type"] is not None else -1,
            ),
            "attack_source": set_notify_property_with_fallback(
                notify,
                ["attack_source", "AttackSource"],
                int(event["attack_source"]) if event["attack_source"] is not None else -1,
            ),
            "state_info": set_notify_property_with_fallback(
                notify,
                ["state_info", "StateInfo"],
                int(event["state_info"]) if event["state_info"] is not None else -1,
            ),
        }
        for slot_index, slot in enumerate(event["tae_parameter_slots"]):
            property_writes[f"tae_param_name_{slot_index}"] = set_notify_property_with_fallback(
                notify,
                [f"tae_param_name{slot_index}", f"tae_param_name_{slot_index}", f"TaeParamName{slot_index}"],
                unreal.Name(slot["name"]) if slot["name"] else unreal.Name(""),
            )
            property_writes[f"tae_param_value_{slot_index}"] = set_notify_property_with_fallback(
                notify,
                [f"tae_param_value{slot_index}", f"tae_param_value_{slot_index}", f"TaeParamValue{slot_index}"],
                slot["value"],
            )
            property_writes[f"tae_param_number_{slot_index}"] = set_notify_property_with_fallback(
                notify,
                [f"tae_param_number{slot_index}", f"tae_param_number_{slot_index}", f"TaeParamNumber{slot_index}"],
                float(slot["number"]),
            )
        added.append({
            "event_name": event["event_name"],
            "raw_event_name": event["raw_event_name"],
            "tae_type": event["tae_type"],
            "tae_jump_table_id": event["tae_jump_table_id"],
            "sp_effect_id": event["sp_effect_id"],
            "behavior_ref_id": event["behavior_ref_id"],
            "tae_parameter_summary": event["tae_parameter_summary"],
            "tae_parameter_slots": event["tae_parameter_slots"],
            "source_arguments": event["source_arguments"],
            "start": round(start, 6),
            "duration": round(duration, 6),
            "property_writes": property_writes,
            "added": True,
        })

    result["added_event_count"] = sum(1 for event in added if event["added"])
    result["events"] = added
    return result


def postprocess_enemy_attack_notify_params(asset_path):
    anim = unreal.load_asset(asset_path)
    if not anim:
        return {"updated": 0, "missing": "asset not found"}

    lib = get_anim_lib()
    updated = 0
    for track in lib.get_animation_notify_track_names(anim):
        for event in lib.get_animation_notify_events_for_track(anim, track):
            try:
                notify = event.get_editor_property("notify_state_class")
            except Exception:
                notify = None
            if not is_sekiro_notify_state(notify):
                continue

            args = parse_source_arguments(notify.get_editor_property("source_arguments"))
            if parse_int(args.get("taetype")) != 1:
                continue

            behavior_judge_id = parse_int(args.get("behaviorjudgeid"))
            set_notify_property(notify, ["AttackType", "attack_type"], parse_int(args.get("attacktype")))
            set_notify_property(notify, ["Field1", "field1", "field_1", "attack_field_1"], parse_int(args.get("field_1", args.get("field1", args.get("unk04")))))
            set_notify_property(notify, ["BehaviorJudgeID", "behavior_judge_id"], behavior_judge_id)
            set_notify_property(notify, ["DirectionType", "direction_type"], parse_int(args.get("directiontype")))
            set_notify_property(notify, ["AttackSource", "attack_source"], parse_int(args.get("source")))
            set_notify_property(notify, ["StateInfo", "state_info"], parse_int(args.get("stateinfo")))
            set_notify_property(notify, ["SpEffectID", "sp_effect_id"], behavior_judge_id)
            set_notify_property(notify, ["BehaviorRefID", "behavior_ref_id"], behavior_judge_id)
            attack_summary = (
                f"AttackType={args.get('attacktype', '0')}; "
                f"field_1={args.get('field_1', args.get('field1', args.get('unk04', '0')))}; "
                f"BehaviorJudgeID={args.get('behaviorjudgeid', '-1')}; "
                f"DirectionType={args.get('directiontype', '255')}; "
                f"Source={args.get('source', '0')}; "
                f"StateInfo={args.get('stateinfo', '0')}"
            )
            notify.set_editor_property("source_arguments", f"TaeType=1; {attack_summary}")
            set_notify_property(notify, ["TaeParameterSummary", "tae_parameter_summary"], attack_summary)
            updated += 1

    unreal.EditorAssetLibrary.save_loaded_asset(anim)
    return {"updated": updated}
