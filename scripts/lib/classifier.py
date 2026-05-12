"""Maps a Swift type name to a Tsumiki concept tag (or None)."""
from __future__ import annotations

import re

_RULES: list[tuple[re.Pattern[str], str]] = [
    (re.compile(r"Toast"),                       "Toast"),
    (re.compile(r"Card"),                        "Card"),
    (re.compile(r"Loading|Spinner|Skeleton"),    "Loading"),
    (re.compile(r"Dialog|Alert|Confirm"),        "Dialog"),
    (re.compile(r"TextField|SearchField"),       "TextField"),
    (re.compile(r"Button|CTA"),                  "Button"),
    (re.compile(r"Splash"),                      "Splash"),
    (re.compile(r"Onboarding"),                  "OnboardingPage"),
    (re.compile(r"Paywall"),                     "Paywall"),
    (re.compile(r"CameraScan|Scanner|Barcode"),  "CameraScan"),
    (re.compile(r"SettingsRow|SettingRow"),      "SettingsRow"),
]


def classify_concept(name: str) -> str | None:
    for pattern, concept in _RULES:
        if pattern.search(name):
            return concept
    return None
