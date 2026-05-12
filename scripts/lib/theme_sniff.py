"""Sniffs theme-token literals out of Swift source text.

Returns a dict shaped like:
    {"colors":   [{"name": str, "hex": str | None}],
     "fonts":    [{"style": str, "weight": str | None}],
     "spacings": [int], "radii": [int]}
"""
from __future__ import annotations

import re
from typing import Dict, Any, List

_COLOR_DECL_RE = re.compile(
    r"static\s+let\s+(?P<name>[A-Za-z_]\w*)\s*=\s*Color"
    r"(?:\(\s*hex\s*:\s*\"(?P<hex>#[0-9A-Fa-f]{3,8})\"|\([^)]*\))",
)
_PADDING_RE = re.compile(r"\.padding\(\s*(?:\.[a-zA-Z]+\s*,\s*)?(?P<n>\d+)\s*\)")
_RADIUS_RE  = re.compile(r"\.cornerRadius\(\s*(?P<n>\d+)\s*\)")
_FONT_RE    = re.compile(r"\.font\(\s*(?P<style>\.[A-Za-z]+)(?:\.(?P<weight>[A-Za-z]+)\(\))?")


def sniff(source: str) -> Dict[str, Any]:
    colors: List[Dict[str, Any]] = []
    for m in _COLOR_DECL_RE.finditer(source):
        colors.append({"name": m.group("name"), "hex": m.group("hex")})
    spacings = sorted({int(m.group("n")) for m in _PADDING_RE.finditer(source)})
    radii    = sorted({int(m.group("n")) for m in _RADIUS_RE.finditer(source)})
    fonts: List[Dict[str, Any]] = []
    for m in _FONT_RE.finditer(source):
        fonts.append({"style": m.group("style"), "weight": m.group("weight")})
    return {"colors": colors, "fonts": fonts, "spacings": spacings, "radii": radii}
