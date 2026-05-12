"""Combine concepts + overlaps into a single Tsumiki port plan.

Output schema:
    {"concepts": {"<Concept>": {"winner": {...}, "candidates": [...], "merge_params": [...]}}}
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path


def build(concepts_path: Path, overlaps_path: Path, out_path: Path) -> None:
    concepts = json.loads(concepts_path.read_text())
    overlaps = json.loads(overlaps_path.read_text())
    plan: dict = {"concepts": {}}
    for concept, entries in concepts.items():
        ov = overlaps.get(concept, {})
        winner_project = ov.get("winner_hint")
        winner = next(
            (e for e in entries if e["project"] == winner_project),
            entries[0] if entries else None,
        )
        plan["concepts"][concept] = {
            "winner": winner,
            "candidates": ov.get("candidates", []),
            "merge_params": ov.get("merge_params", []),
        }
    out_path.write_text(json.dumps(plan, indent=2, sort_keys=True))


def _main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--concepts", type=Path, required=True)
    ap.add_argument("--overlaps", type=Path, required=True)
    ap.add_argument("-o", "--out",  type=Path, required=True)
    args = ap.parse_args()
    build(args.concepts, args.overlaps, args.out)


if __name__ == "__main__":
    _main()
