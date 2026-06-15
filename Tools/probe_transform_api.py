import json
import os

import unreal


PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
REPORT_PATH = os.path.join(PROJECT_ROOT, "Saved", "SekiroImportReports", "transform_api_probe.json")


def main():
    transform = unreal.Transform()
    vector = unreal.Vector(1.0, 2.0, 3.0)
    report = {
        "transform_dir": [name for name in dir(transform) if "transform" in name.lower() or "inverse" in name.lower() or "rotation" in name.lower()],
        "vector_dir": [name for name in dir(vector) if "rotate" in name.lower() or "transform" in name.lower()],
        "math_dir": [name for name in dir(unreal.MathLibrary) if "transform" in name.lower() or "inverse" in name.lower()],
    }
    os.makedirs(os.path.dirname(REPORT_PATH), exist_ok=True)
    with open(REPORT_PATH, "w", encoding="utf-8") as handle:
        json.dump(report, handle, ensure_ascii=False, indent=2)


main()
