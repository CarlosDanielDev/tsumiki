"""Walk a project, emit a Tsumiki manifest JSON.

Usage:
    python -m scripts.scan_project <project_name> <project_root> -o manifests/<name>.json
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any, Dict, List

from scripts.lib.swift_lex import extract_symbols
from scripts.lib.theme_sniff import sniff
from scripts.lib.classifier import classify_concept


def _merge_tokens(acc: Dict[str, Any], add: Dict[str, Any]) -> None:
    color_keys = {(c["name"], c.get("hex")) for c in acc["colors"]}
    for c in add["colors"]:
        key = (c["name"], c.get("hex"))
        if key not in color_keys:
            acc["colors"].append({"name": c["name"], "hex": c.get("hex"), "files": 1})
            color_keys.add(key)
        else:
            for existing in acc["colors"]:
                if (existing["name"], existing.get("hex")) == key:
                    existing["files"] = existing.get("files", 1) + 1
                    break
    font_keys = {(f["style"], f.get("weight")) for f in acc["fonts"]}
    for f in add["fonts"]:
        key = (f["style"], f.get("weight"))
        if key not in font_keys:
            acc["fonts"].append({"style": f["style"], "weight": f.get("weight"), "files": 1})
            font_keys.add(key)
    acc["spacings"] = sorted(set(acc["spacings"]) | set(add["spacings"]))
    acc["radii"]    = sorted(set(acc["radii"])    | set(add["radii"]))


def scan(project_name: str, root: Path, out_path: Path) -> Dict[str, Any]:
    components: List[Dict[str, Any]] = []
    tokens: Dict[str, Any] = {"colors": [], "fonts": [], "spacings": [], "radii": []}
    swift_files = list(root.rglob("*.swift"))
    for path in swift_files:
        text = path.read_text(errors="replace")
        for sym in extract_symbols(text):
            if sym["kind"] != "View":
                continue
            concept = classify_concept(sym["name"])
            if concept is None:
                continue
            components.append({
                "name": sym["name"],
                "path": str(path.relative_to(root)),
                "kind": "View",
                "concept": concept,
                "public_init_params": sym["public_init_params"],
                "loc": sym["loc"],
            })
        _merge_tokens(tokens, sniff(text))

    manifest = {
        "project": project_name,
        "root": str(root),
        "swift_files": len(swift_files),
        "components": sorted(components, key=lambda c: (c["concept"], c["name"])),
        "theme_tokens": tokens,
        "animations": [],
        "services": [],
    }
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(manifest, indent=2))
    return manifest


def _main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("project_name")
    ap.add_argument("project_root", type=Path)
    ap.add_argument("-o", "--out", type=Path, required=True)
    args = ap.parse_args()
    scan(args.project_name, args.project_root, args.out)


if __name__ == "__main__":
    _main()
