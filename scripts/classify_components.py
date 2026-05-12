"""Aggregate every component across manifests/*.json into manifests/_concepts.json."""
from __future__ import annotations

import argparse
import json
from collections import defaultdict
from pathlib import Path


def build_concepts(manifest_dir: Path, out_path: Path) -> None:
    concepts: dict[str, list[dict]] = defaultdict(list)
    for mf in sorted(manifest_dir.glob("*.json")):
        if mf.name.startswith("_"):
            continue
        data = json.loads(mf.read_text())
        for comp in data["components"]:
            concepts[comp["concept"]].append({
                "project": data["project"],
                "name": comp["name"],
                "path": comp["path"],
            })
    out_path.write_text(json.dumps(dict(sorted(concepts.items())), indent=2))


def _main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("manifest_dir", type=Path)
    ap.add_argument("-o", "--out", type=Path, required=True)
    args = ap.parse_args()
    build_concepts(args.manifest_dir, args.out)


if __name__ == "__main__":
    _main()
