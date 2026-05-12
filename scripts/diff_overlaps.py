"""Detect duplicate concepts across per-project manifests.

Reads manifests/*.json (skipping files prefixed with `_`) and writes
`<out>/_overlaps.json` keyed by concept.

Usage:
    python -m scripts.diff_overlaps manifests/ -o manifests/_overlaps.json
"""
from __future__ import annotations

import argparse
import json
from collections import defaultdict
from pathlib import Path
from typing import Any, Dict, List


def _score(loc: int, n_params: int) -> float:
    return round(min(loc, 400) / 500 + min(n_params, 8) / 16, 3)


def build_overlaps(manifest_dir: Path, out_path: Path) -> Dict[str, Any]:
    by_concept: Dict[str, List[Dict[str, Any]]] = defaultdict(list)
    for mf in sorted(manifest_dir.glob("*.json")):
        if mf.name.startswith("_"):
            continue
        data = json.loads(mf.read_text())
        for comp in data["components"]:
            by_concept[comp["concept"]].append({
                "project": data["project"],
                "path": comp["path"],
                "loc": comp["loc"],
                "params": comp["public_init_params"],
                "score": _score(comp["loc"], len(comp["public_init_params"])),
            })

    overlaps: Dict[str, Any] = {}
    for concept, candidates in by_concept.items():
        candidates.sort(key=lambda c: c["score"], reverse=True)
        winner = candidates[0]
        union_params: List[str] = []
        seen_param_names: set[str] = set()
        for c in candidates:
            for p in c["params"]:
                pname = p.split(":", 1)[0]
                if pname not in seen_param_names:
                    union_params.append(p)
                    seen_param_names.add(pname)
        winner_param_names = {p.split(":", 1)[0] for p in winner["params"]}
        merge_params = [p for p in union_params if p.split(":", 1)[0] not in winner_param_names]
        overlaps[concept] = {
            "candidates": [
                {"project": c["project"], "path": c["path"], "loc": c["loc"],
                 "params": len(c["params"]), "score": c["score"]}
                for c in candidates
            ],
            "winner_hint": winner["project"],
            "merge_params": [p.split(":", 1)[0] for p in merge_params],
        }
    out_path.write_text(json.dumps(overlaps, indent=2, sort_keys=True))
    return overlaps


def _main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("manifest_dir", type=Path)
    ap.add_argument("-o", "--out", type=Path, required=True)
    args = ap.parse_args()
    build_overlaps(args.manifest_dir, args.out)


if __name__ == "__main__":
    _main()
