"""Regex-based Swift symbol extractor. Lightweight, not a full parser.

Returns a list of dicts shaped like:
    {"name": str, "kind": "View"|"Struct"|"Class"|"Enum"|"Protocol"|"Extension",
     "visibility": "public"|"internal"|"private"|"fileprivate",
     "public_init_params": [str], "view_conforms": bool, "loc": int}
"""
from __future__ import annotations

import re
from typing import List, Dict, Any

_DECL_RE = re.compile(
    r"(?P<vis>public|internal|private|fileprivate)?\s*"
    r"(?P<kind>struct|class|enum|protocol|extension)\s+"
    r"(?P<name>[A-Za-z_][A-Za-z0-9_]*)"
    r"(?:\s*:\s*(?P<conforms>[^\{]+))?"
    r"\s*\{",
    re.MULTILINE,
)

_INIT_RE = re.compile(
    r"public\s+init\s*\(\s*(?P<params>[^)]*)\)",
    re.DOTALL,
)


def _classify_kind(kind: str, conforms: str | None) -> str:
    if kind == "struct" and conforms and re.search(r"\bView\b", conforms):
        return "View"
    return kind.capitalize()


def _parse_params(raw: str) -> List[str]:
    if not raw.strip():
        return []
    out: List[str] = []
    depth = 0
    buf: List[str] = []
    for ch in raw:
        if ch in "([<":
            depth += 1
        elif ch in ")]>":
            depth -= 1
        if ch == "," and depth == 0:
            out.append("".join(buf).strip())
            buf = []
        else:
            buf.append(ch)
    if buf:
        out.append("".join(buf).strip())
    parsed: List[str] = []
    for p in out:
        p = re.sub(r"=.*$", "", p).strip()
        m = re.match(r"(?:[A-Za-z_]\w*\s+)?([A-Za-z_]\w*)\s*:\s*(.+)$", p)
        if not m:
            continue
        parsed.append(f"{m.group(1)}:{m.group(2).strip()}")
    return parsed


def extract_symbols(source: str) -> List[Dict[str, Any]]:
    out: List[Dict[str, Any]] = []
    for m in _DECL_RE.finditer(source):
        vis = m.group("vis") or "internal"
        if vis != "public":
            continue
        kind_raw = m.group("kind")
        conforms = m.group("conforms")
        kind = _classify_kind(kind_raw, conforms)
        body_start = m.end()
        depth = 1
        i = body_start
        while i < len(source) and depth > 0:
            if source[i] == "{":
                depth += 1
            elif source[i] == "}":
                depth -= 1
            i += 1
        body = source[body_start:i]
        init_params: List[str] = []
        init_match = _INIT_RE.search(body)
        if init_match:
            init_params = _parse_params(init_match.group("params"))
        out.append({
            "name": m.group("name"),
            "kind": kind,
            "visibility": vis,
            "public_init_params": init_params,
            "view_conforms": kind == "View",
            "loc": source.count("\n", 0, i) - source.count("\n", 0, m.start()),
        })
    return out
