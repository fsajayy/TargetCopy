from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
addon = root
toc = (addon / "TargetCopy.toc").read_text(encoding="utf-8")

required = [
    "Core.lua", "Compat.lua",
    "Modules\\Unit.lua", "Modules\\Marker.lua",
    "Modules\\Macro.lua", "Modules\\QuickCopy.lua",
    "UI\\MainWindow.lua", "UI\\QuickCopyPopup.lua",
    "UI\\FloatingButton.lua", "UI\\Settings.lua", "UI\\DebugPanel.lua",
    "Bindings.lua", "Bindings.xml"
]

toc_required = [
    "Core.lua", "Compat.lua",
    "Modules\\Unit.lua", "Modules\\Marker.lua",
    "Modules\\Macro.lua", "Modules\\QuickCopy.lua",
    "UI\\MainWindow.lua", "UI\\QuickCopyPopup.lua",
    "UI\\FloatingButton.lua", "UI\\Settings.lua", "UI\\DebugPanel.lua",
    "Bindings.lua"
]

missing = []

for rel in required:
    p = addon / Path(rel.replace("\\", "/"))
    if not p.exists():
        missing.append(str(p.relative_to(root)))

for rel in toc_required:
    if rel not in toc:
        missing.append("TOC:" + rel)

if "Bindings.xml" in toc:
    missing.append("TOC:Bindings.xml must not be explicitly loaded")

if "## Interface: 16001" not in toc:
    missing.append("Interface 16001")

if "## SavedVariables: TargetCopyDB" not in toc:
    missing.append("SavedVariables")

if missing:
    print("FAIL")
    print("\n".join(missing))
    sys.exit(1)

print("PASS: package structure and TOC references")
