import argparse
import json
from pathlib import Path

from build_sekiro_master_subset_abp import (
    ASSET_PATH,
    MACHINE_SPECS,
    TOP_LEVEL_MACHINE,
    TOP_LEVEL_TRANSITIONS,
    get_machine_transitions,
    save_asset_with_fallback,
)
from sekiro_monolith_client import MCPClient, MCPError


PROJECT_ROOT = Path(__file__).resolve().parent.parent
REPORT_PATH = PROJECT_ROOT / "Saved" / "SekiroImportReports" / "c0000_transition_coverage_repair.json"


def transition_pairs(transitions: list[dict]) -> set[tuple[str, str]]:
    return {
        (str(item.get("from", "")), str(item.get("to", "")))
        for item in transitions
        if item.get("from") and item.get("to")
    }


def summarize_changes(results: list[dict]) -> list[dict]:
    changed: list[dict] = []
    for result in results:
        add_result = result.get("add_result") or {}
        rule_result = result.get("rule_result") or {}
        add_changed = not add_result.get("skipped", False)
        rule_changed = not rule_result.get("skipped", False)
        if not add_changed and not rule_changed:
            continue
        changed.append(
            {
                "from": result.get("from"),
                "to": result.get("to"),
                "variable": result.get("variable"),
                "compare_value": result.get("compare_value"),
                "add_result": add_result,
                "rule_result": rule_result,
            }
        )
    return changed


def transition_has_rule(transition: dict, variable_name: str, compare_value: int | None) -> bool:
    rule_nodes = transition.get("rule_nodes", [])
    getter_title = f"Get {variable_name}"
    has_getter = any(node.get("title") == getter_title for node in rule_nodes)
    if not has_getter:
        return False
    if compare_value is None:
        return True
    return any(node.get("title") == "Equal (Integer)" for node in rule_nodes)


def ensure_machine_transition_fast(
    client: MCPClient,
    machine_name: str,
    transition_index: dict[tuple[str, str], dict],
    transition_spec: dict,
) -> dict:
    from_state = transition_spec["from"]
    to_state = transition_spec["to"]
    variable_name = transition_spec["var"]
    compare_value = transition_spec.get("compare_value")
    pair = (from_state, to_state)

    existing = transition_index.get(pair)
    add_result = {"skipped": True, "message": "transition already exists"}

    if existing is None:
        try:
            add_result = client.call(
                "animation_query",
                "add_transition",
                {
                    "asset_path": ASSET_PATH,
                    "machine_name": machine_name,
                    "from_state": from_state,
                    "to_state": to_state,
                },
            )
        except MCPError as exc:
            message = str(exc)
            if any(marker in message for marker in ("already be connected", "already connected", "already exists")):
                add_result = {"skipped": True, "message": message}
            else:
                raise

        existing = {"from": from_state, "to": to_state, "rule_nodes": []}
        transition_index[pair] = existing

    rule_result = {"skipped": True, "message": f"rule already uses {variable_name}"}
    if not transition_has_rule(existing, variable_name, compare_value):
        rule_params = {
            "asset_path": ASSET_PATH,
            "machine_name": machine_name,
            "from_state": from_state,
            "to_state": to_state,
            "variable_name": variable_name,
            "compile": False,
        }
        if compare_value is not None:
            rule_params["compare_value"] = compare_value
        rule_result = client.call("animation_query", "set_transition_rule", rule_params)
        existing["rule_nodes"] = [{"title": f"Get {variable_name}"}]
        if compare_value is not None:
            existing["rule_nodes"].append({"title": "Equal (Integer)"})

    return {
        "from": from_state,
        "to": to_state,
        "variable": variable_name,
        "compare_value": compare_value,
        "add_result": add_result,
        "rule_result": rule_result,
    }


def repair_machine(client: MCPClient, machine_name: str, transitions_spec: list[dict]) -> dict:
    filtered_spec = [
        transition
        for transition in transitions_spec
        if transition["from"] != transition["to"]
    ]
    before_transitions = get_machine_transitions(client, machine_name)
    before_pairs = transition_pairs(before_transitions)
    transition_index = {
        (str(item.get("from", "")), str(item.get("to", ""))): item
        for item in before_transitions
        if item.get("from") and item.get("to")
    }

    results = []
    for transition in filtered_spec:
        results.append(ensure_machine_transition_fast(client, machine_name, transition_index, transition))

    after_transitions = get_machine_transitions(client, machine_name)
    after_pairs = transition_pairs(after_transitions)
    expected_pairs = {
        (transition["from"], transition["to"])
        for transition in filtered_spec
    }

    return {
        "machine_name": machine_name,
        "expected_transition_count": len(filtered_spec),
        "skipped_self_pairs": sorted(
            [
                (transition["from"], transition["to"])
                for transition in transitions_spec
                if transition["from"] == transition["to"]
            ]
        ),
        "before_count": len(before_transitions),
        "after_count": len(after_transitions),
        "before_missing_pairs": sorted(list(expected_pairs - before_pairs)),
        "after_missing_pairs": sorted(list(expected_pairs - after_pairs)),
        "changed": summarize_changes(results),
    }


def parse_args():
    parser = argparse.ArgumentParser(
        description="Repair missing HKX-derived transition coverage in ABP_Sekiro_C0000_Master."
    )
    parser.add_argument(
        "--machine",
        dest="machines",
        action="append",
        help="Only repair the named state machine. Repeat to include multiple machines.",
    )
    parser.add_argument(
        "--all",
        action="store_true",
        help="Repair every machine described in build_sekiro_master_subset_abp.py.",
    )
    return parser.parse_args()


def main():
    args = parse_args()
    client = MCPClient()
    selected_machine_names = (
        [machine_spec["machine_name"] for machine_spec in MACHINE_SPECS]
        if args.all
        else (args.machines or ["StandMove_SM", "StandMoveLower_SM"])
    )
    selected_specs = [
        machine_spec
        for machine_spec in MACHINE_SPECS
        if machine_spec["machine_name"] in selected_machine_names
    ]
    missing_specs = sorted(set(selected_machine_names) - {spec["machine_name"] for spec in selected_specs})
    if missing_specs:
        raise SystemExit(f"Unknown machine names: {', '.join(missing_specs)}")

    report = {
        "asset_path": ASSET_PATH,
        "selected_machines": selected_machine_names,
        "top_level": {},
        "machines": [],
    }

    top_level_spec = [
        {
            "from": transition["from"],
            "to": transition["to"],
            "var": transition["var"],
            "compare_value": transition.get("compare_value"),
        }
        for transition in TOP_LEVEL_TRANSITIONS
    ]
    report["top_level"] = repair_machine(client, TOP_LEVEL_MACHINE, top_level_spec)

    for machine_spec in selected_specs:
        report["machines"].append(
            repair_machine(client, machine_spec["machine_name"], machine_spec["transitions"])
        )

    compile_result = client.call(
        "blueprint_query",
        "compile_blueprint",
        {"asset_path": ASSET_PATH},
    )
    save_result = save_asset_with_fallback(client, ASSET_PATH)

    report["compile"] = compile_result
    report["save"] = save_result

    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
