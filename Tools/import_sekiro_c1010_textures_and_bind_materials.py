import os
import sys


TOOLS_DIR = os.path.dirname(__file__)
if TOOLS_DIR not in sys.path:
    sys.path.append(TOOLS_DIR)

import import_sekiro_c0000_textures_and_bind_materials as base


PROJECT_ROOT = os.path.abspath(os.path.join(TOOLS_DIR, ".."))

base.MANIFEST_PATH = os.path.join(PROJECT_ROOT, "Saved", "SekiroImportReports", "c1010_texture_manifest.json")
base.REPORT_PATH = os.path.join(PROJECT_ROOT, "Saved", "SekiroImportReports", "c1010_texture_import_summary.json")
base.TEXTURE_DESTINATION = "/Game/Animation/Sekiro/Enemy/C1010/Textures"
base.BASE_MATERIAL_DIR = "/Game/Animation/Sekiro/Enemy/C1010/Base"


if __name__ == "__main__":
    base.main()
