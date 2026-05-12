"""Forbids hardcoded theme values inside TsumikiComponents.

Allowed: theme-derived values (`theme.spacing.lg`, `colors.accent`), the literals
0 and 1 (idiomatic for full opacity / line widths). Everything else is a violation.

Usage:
    python -m scripts.lint_no_hardcoded Sources/TsumikiComponents
Exit code 1 if any violation is found.
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path
from typing import Any, Dict, List

_COLOR_LITERAL_RE = re.compile(
    r"\bColor\s*\.\s*(?:red|green|blue|black|white|yellow|orange|pink|purple|gray|grey)\b"
    r"|\bColor\s*\(\s*(?:red|hex|\.systemRed)"
)
_PADDING_RE = re.compile(r"\.padding\(\s*(?:\.[a-zA-Z]+\s*,\s*)?(\d+)\s*\)")
_RADIUS_RE  = re.compile(r"\.cornerRadius\(\s*(\d+)\s*\)")


def lint(root: Path) -> List[Dict[str, Any]]:
    violations: List[Dict[str, Any]] = []
    for swift in root.rglob("*.swift"):
        text = swift.read_text(errors="replace")
        for m in _COLOR_LITERAL_RE.finditer(text):
            violations.append({"file": str(swift), "rule": "color-literal", "match": m.group(0)})
        for m in _PADDING_RE.finditer(text):
            n = int(m.group(1))
            if n in (0, 1):
                continue
            violations.append({"file": str(swift), "rule": "spacing-literal", "match": m.group(0)})
        for m in _RADIUS_RE.finditer(text):
            n = int(m.group(1))
            if n in (0, 1):
                continue
            violations.append({"file": str(swift), "rule": "radius-literal", "match": m.group(0)})
    return violations


def _main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("root", type=Path)
    args = ap.parse_args()
    violations = lint(args.root)
    for v in violations:
        print(f"{v['file']}: {v['rule']}: {v['match']}")
    return 1 if violations else 0


if __name__ == "__main__":
    sys.exit(_main())
