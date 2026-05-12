# Tsumiki MVP — P0+P1 Implementation Plan (Scanner + Scaffolding + Theme + Reference Component)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stand up the Tsumiki Swift package with one fully ported reference component (`TsumikiToast`), a complete theme system, the Python scanner pipeline that produces JSON manifests of the five source projects, the subagent roster, the orchestrator CLAUDE.md, and the PRD.

**Architecture:** Single SwiftPM package with five modular library targets (`TsumikiCore`, `TsumikiTheme`, `TsumikiComponents`, `TsumikiAnimations`, `TsumikiServices`). Components consume theme tokens via `@Environment(\.tsumikiTheme)`. Python 3.11 stdlib-only scanners walk each source project and emit JSON manifests in `manifests/`, which `.claude/agents/` subagents consume to plan the component port without flooding the orchestrator's context with raw Swift files.

**Tech Stack:** Swift 5.9+, SwiftUI, iOS 17, XCTest, Python 3.11 (stdlib only), GitHub Actions.

**Companion plans (out of scope here):**
- Plan B — P2 component-port wave (uses manifests/_overlaps.json produced by this plan).
- Plan C — P3 TsumikiCatalog example app + first consumer migration (warrantyreminder).

---

## File Structure

### Created in this plan

```
Tsumiki/
├── Package.swift
├── .gitignore
├── README.md
├── .github/workflows/ci.yml
├── .claude/
│   ├── CLAUDE.md
│   ├── agents/
│   │   ├── subagent-project-mapper.md
│   │   ├── subagent-concept-classifier.md
│   │   ├── subagent-overlap-arbiter.md
│   │   ├── subagent-theme-extractor.md
│   │   ├── subagent-architect.md
│   │   ├── subagent-qa.md
│   │   └── subagent-docs-analyst.md
│   └── settings.json
├── docs/
│   ├── PRD.md
│   └── components/Toast.md
├── scripts/
│   ├── scan_project.py
│   ├── classify_components.py
│   ├── diff_overlaps.py
│   ├── build_catalog.py
│   ├── lint_no_hardcoded.py
│   ├── lib/
│   │   ├── __init__.py
│   │   ├── swift_lex.py
│   │   ├── theme_sniff.py
│   │   └── classifier.py
│   └── tests/
│       ├── __init__.py
│       ├── fixtures/
│       │   ├── ToastView.swift
│       │   ├── CardView.swift
│       │   └── ThemeSample.swift
│       ├── test_swift_lex.py
│       ├── test_theme_sniff.py
│       ├── test_classifier.py
│       ├── test_scan_project.py
│       ├── test_diff_overlaps.py
│       └── test_lint_no_hardcoded.py
├── manifests/
│   └── .gitkeep
├── Sources/
│   ├── TsumikiCore/Empty.swift
│   ├── TsumikiTheme/
│   │   ├── TsumikiTheme.swift
│   │   ├── Tokens/TsumikiColors.swift
│   │   ├── Tokens/TsumikiTypography.swift
│   │   ├── Tokens/TsumikiSpacing.swift
│   │   ├── Tokens/TsumikiRadius.swift
│   │   ├── Tokens/TsumikiShadow.swift
│   │   ├── Tokens/ShadowStyle.swift
│   │   ├── DefaultTheme.swift
│   │   └── ThemeEnvironment.swift
│   ├── TsumikiComponents/Toast/TsumikiToast.swift
│   ├── TsumikiComponents/Toast/TsumikiToastModifier.swift
│   ├── TsumikiAnimations/Empty.swift
│   └── TsumikiServices/Empty.swift
└── Tests/
    ├── TsumikiCoreTests/TsumikiCoreTests.swift
    ├── TsumikiThemeTests/
    │   ├── DefaultThemeTests.swift
    │   └── ThemeEnvironmentTests.swift
    ├── TsumikiComponentsTests/TsumikiToastTests.swift
    ├── TsumikiAnimationsTests/TsumikiAnimationsTests.swift
    └── TsumikiServicesTests/TsumikiServicesTests.swift
```

### Modified

None — Tsumiki repo currently only has untracked `README.md` (placeholder), `tsumiki.xcodeproj/`, `tsumiki/`, `tsumikiTests/`. The Xcode project artefacts stay untouched; the Swift package layout is the canonical code location going forward. The placeholder `README.md` is overwritten in Task 18.

---

## Task 1: Initialize SwiftPM package and `.gitignore`

**Files:**
- Create: `Package.swift`
- Create: `.gitignore`
- Create: `Sources/TsumikiCore/Empty.swift`
- Create: `Sources/TsumikiTheme/Empty.swift` (temporary, removed in Task 4)
- Create: `Sources/TsumikiComponents/Empty.swift` (temporary, removed in Task 6)
- Create: `Sources/TsumikiAnimations/Empty.swift`
- Create: `Sources/TsumikiServices/Empty.swift`
- Create: `Tests/TsumikiCoreTests/TsumikiCoreTests.swift`
- Create: `Tests/TsumikiThemeTests/TsumikiThemeTests.swift` (temporary, replaced in Task 4)
- Create: `Tests/TsumikiComponentsTests/TsumikiComponentsTests.swift` (temporary, replaced in Task 6)
- Create: `Tests/TsumikiAnimationsTests/TsumikiAnimationsTests.swift`
- Create: `Tests/TsumikiServicesTests/TsumikiServicesTests.swift`

- [ ] **Step 1: Write `Package.swift`**

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Tsumiki",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "TsumikiCore",       targets: ["TsumikiCore"]),
        .library(name: "TsumikiTheme",      targets: ["TsumikiTheme"]),
        .library(name: "TsumikiComponents", targets: ["TsumikiComponents"]),
        .library(name: "TsumikiAnimations", targets: ["TsumikiAnimations"]),
        .library(name: "TsumikiServices",   targets: ["TsumikiServices"]),
    ],
    targets: [
        .target(name: "TsumikiCore"),
        .target(name: "TsumikiTheme",      dependencies: ["TsumikiCore"]),
        .target(name: "TsumikiComponents", dependencies: ["TsumikiCore", "TsumikiTheme"]),
        .target(name: "TsumikiAnimations", dependencies: ["TsumikiCore", "TsumikiTheme"]),
        .target(name: "TsumikiServices",   dependencies: ["TsumikiCore"]),
        .testTarget(name: "TsumikiCoreTests",       dependencies: ["TsumikiCore"]),
        .testTarget(name: "TsumikiThemeTests",      dependencies: ["TsumikiTheme"]),
        .testTarget(name: "TsumikiComponentsTests", dependencies: ["TsumikiComponents"]),
        .testTarget(name: "TsumikiAnimationsTests", dependencies: ["TsumikiAnimations"]),
        .testTarget(name: "TsumikiServicesTests",   dependencies: ["TsumikiServices"]),
    ]
)
```

- [ ] **Step 2: Write `.gitignore`**

```
.DS_Store
.build/
.swiftpm/
DerivedData/
*.xcuserstate
manifests/*.json
!manifests/.gitkeep
__pycache__/
*.pyc
.pytest_cache/
```

- [ ] **Step 3: Create empty source + test stubs so the package compiles**

For each module, create the placeholder Swift file with this content (replace `<Module>` with the module name):

`Sources/TsumikiCore/Empty.swift`:
```swift
// Placeholder so SwiftPM has at least one source file. Replaced as the module grows.
```

Same one-line content for `Sources/TsumikiTheme/Empty.swift`, `Sources/TsumikiComponents/Empty.swift`, `Sources/TsumikiAnimations/Empty.swift`, `Sources/TsumikiServices/Empty.swift`.

For each test target, create:
`Tests/TsumikiCoreTests/TsumikiCoreTests.swift`:
```swift
import XCTest
@testable import TsumikiCore

final class TsumikiCoreTests: XCTestCase {
    func testPackageBuilds() {
        XCTAssertTrue(true)
    }
}
```

Repeat for `TsumikiThemeTests`, `TsumikiComponentsTests`, `TsumikiAnimationsTests`, `TsumikiServicesTests`, replacing `Core` with the matching module name in both the `import` and the class name.

- [ ] **Step 4: Verify build + tests**

Run: `cd /Users/carlos/projects/tsumiki && swift build && swift test`
Expected: build succeeds; 5 tests pass (one per target), all asserting `true`.

- [ ] **Step 5: Commit**

```bash
git add Package.swift .gitignore Sources Tests
git commit -m "feat: initialize Tsumiki SwiftPM package with five empty modular targets"
```

---

## Task 2: Add `manifests/` placeholder + repo-level docs scaffold

**Files:**
- Create: `manifests/.gitkeep`
- Create: `docs/PRD.md`

- [ ] **Step 1: Create `manifests/.gitkeep`**

Empty file. `git add manifests/.gitkeep`.

- [ ] **Step 2: Write `docs/PRD.md`**

```markdown
# Tsumiki PRD

## Problem
Five iOS/SwiftUI apps (aquabrew, pulselog, lucidmate, warrantyreminder, zeroblock)
re-implement the same UI building blocks, theme tokens, and cross-cutting services.
Visual drift, duplicated bug-fixes, no shared upgrade path.

## Goal
A single Swift Package — Tsumiki — that consolidates the reusable surface area of
all five apps into a plug-and-play, theme-extensible library. Consumers add the
package URL, import the modules they want, optionally inject a custom theme, done.

## Non-Goals
- Backend or server code.
- Multiplatform (macOS / visionOS / watchOS) for v1.
- UIKit components.
- Code-generation tooling for consumers.
- Domain logic from source apps.

## MVP Component Set
Components: `TsumikiCard`, `TsumikiToast`, `TsumikiLoading`, `TsumikiDialog`,
`TsumikiTextField`, `TsumikiButton`, `TsumikiSplash`, `TsumikiOnboardingPage`,
`TsumikiPaywall`, `TsumikiCameraScan`, `TsumikiSettingsRow`.

Animations: `bubblePulse`, `shimmerLoading`, `confettiBurst`, `slideOnboarding`.

Services: `TsumikiAnalytics`, `TsumikiAdsCoordinator`, `TsumikiPaywallController`
(StoreKit 2), `TsumikiNotifications`. Each ships with a default no-op or sample
implementation.

Theme: `DefaultTheme.light` / `.dark` plus consumer override via
`.tsumikiTheme(MyTheme())`.

## Success Criteria
1. All five projects map ≥80 % of their `Views/Components/**` files to a Tsumiki
   concept (measured by `manifests/_overlaps.json` coverage).
2. Each in-scope concept ships with at least one runnable example in
   `Examples/TsumikiCatalog`.
3. `warrantyreminder` migrated to Tsumiki without visible visual regression.
4. `swift build`, `swift test`, and `python -m unittest discover scripts/tests`
   all green on iOS 17 and iOS 18 simulators.

## Phases
- P0: Python scanners + manifests + subagent roster + lint + PRD.
- P1: Package scaffolding + complete `TsumikiTheme` + reference `TsumikiToast`.
- P2: Component port wave (per-concept).
- P3: TsumikiCatalog + first consumer migration.

See `docs/superpowers/specs/2026-05-11-tsumiki-mvp-design.md` for full design.
```

- [ ] **Step 3: Commit**

```bash
git add manifests/.gitkeep docs/PRD.md
git commit -m "docs: add PRD and manifests placeholder"
```

---

## Task 3: Python scanner library — `swift_lex.py` (RED → GREEN)

**Files:**
- Create: `scripts/lib/__init__.py`
- Create: `scripts/lib/swift_lex.py`
- Create: `scripts/tests/__init__.py`
- Create: `scripts/tests/fixtures/ToastView.swift`
- Create: `scripts/tests/test_swift_lex.py`

- [ ] **Step 1: Write fixture `scripts/tests/fixtures/ToastView.swift`**

```swift
import SwiftUI

public struct ToastView: View {
    public let title: String
    public var icon: Image?
    public var duration: TimeInterval = 2.0

    public init(title: String, icon: Image? = nil, duration: TimeInterval = 2.0) {
        self.title = title
        self.icon = icon
        self.duration = duration
    }

    public var body: some View {
        HStack {
            if let icon { icon }
            Text(title)
                .font(.body)
                .foregroundStyle(Color.aquaBlue)
                .padding(12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

private struct ToastModifier: ViewModifier {
    func body(content: Content) -> some View { content }
}
```

- [ ] **Step 2: Create `scripts/lib/__init__.py` (empty file) and `scripts/tests/__init__.py` (empty file)**

- [ ] **Step 3: Write the failing test `scripts/tests/test_swift_lex.py`**

```python
import unittest
from pathlib import Path
from scripts.lib.swift_lex import extract_symbols

FIXTURE = Path(__file__).parent / "fixtures" / "ToastView.swift"

class SwiftLexTests(unittest.TestCase):
    def test_extracts_public_struct_view(self):
        symbols = extract_symbols(FIXTURE.read_text())
        names = {s["name"] for s in symbols}
        self.assertIn("ToastView", names)

    def test_classifies_view_kind(self):
        symbols = extract_symbols(FIXTURE.read_text())
        toast = next(s for s in symbols if s["name"] == "ToastView")
        self.assertEqual(toast["kind"], "View")
        self.assertEqual(toast["visibility"], "public")

    def test_extracts_public_init_params(self):
        symbols = extract_symbols(FIXTURE.read_text())
        toast = next(s for s in symbols if s["name"] == "ToastView")
        self.assertEqual(
            toast["public_init_params"],
            ["title:String", "icon:Image?", "duration:TimeInterval"],
        )

    def test_skips_private_types(self):
        symbols = extract_symbols(FIXTURE.read_text())
        names = {s["name"] for s in symbols}
        self.assertNotIn("ToastModifier", names)
```

- [ ] **Step 4: Run test to verify it fails**

Run: `cd /Users/carlos/projects/tsumiki && python -m unittest scripts.tests.test_swift_lex -v`
Expected: ImportError or AttributeError — `extract_symbols` not defined.

- [ ] **Step 5: Write minimal implementation `scripts/lib/swift_lex.py`**

```python
"""Regex-based Swift symbol extractor. Intentionally lightweight — no full parser.

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
        # Strip default value, external label, leading argument label.
        p = re.sub(r"=.*$", "", p).strip()
        # "external internal: Type" -> "internal:Type"; "label: Type" -> "label:Type"
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
        # Slice the body to look for public init.
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
```

- [ ] **Step 6: Run tests to verify they pass**

Run: `python -m unittest scripts.tests.test_swift_lex -v`
Expected: 4 tests pass.

- [ ] **Step 7: Commit**

```bash
git add scripts/lib scripts/tests/__init__.py scripts/tests/fixtures/ToastView.swift scripts/tests/test_swift_lex.py
git commit -m "feat(scripts): add swift_lex regex-based symbol extractor"
```

---

## Task 4: Python scanner library — `theme_sniff.py`

**Files:**
- Create: `scripts/tests/fixtures/ThemeSample.swift`
- Create: `scripts/lib/theme_sniff.py`
- Create: `scripts/tests/test_theme_sniff.py`

- [ ] **Step 1: Write fixture `scripts/tests/fixtures/ThemeSample.swift`**

```swift
import SwiftUI

extension Color {
    static let aquaBlue = Color(hex: "#0EA5E9")
    static let danger   = Color(red: 0.9, green: 0.2, blue: 0.2)
}

struct Sample: View {
    var body: some View {
        Text("hi")
            .font(.largeTitle.bold())
            .padding(16)
            .padding(.horizontal, 24)
            .cornerRadius(12)
    }
}
```

- [ ] **Step 2: Write the failing test `scripts/tests/test_theme_sniff.py`**

```python
import unittest
from pathlib import Path
from scripts.lib.theme_sniff import sniff

FIXTURE = Path(__file__).parent / "fixtures" / "ThemeSample.swift"

class ThemeSniffTests(unittest.TestCase):
    def setUp(self):
        self.tokens = sniff(FIXTURE.read_text())

    def test_finds_named_color_with_hex(self):
        colors = {c["name"]: c for c in self.tokens["colors"]}
        self.assertEqual(colors["aquaBlue"]["hex"], "#0EA5E9")

    def test_finds_named_color_without_hex(self):
        colors = {c["name"]: c for c in self.tokens["colors"]}
        self.assertIn("danger", colors)
        self.assertIsNone(colors["danger"]["hex"])

    def test_collects_spacings(self):
        self.assertEqual(sorted(self.tokens["spacings"]), [12, 16, 24])

    def test_collects_radii(self):
        self.assertEqual(self.tokens["radii"], [12])

    def test_collects_font_styles(self):
        styles = {f["style"] for f in self.tokens["fonts"]}
        self.assertIn(".largeTitle", styles)
```

- [ ] **Step 3: Run test to verify it fails**

Run: `python -m unittest scripts.tests.test_theme_sniff -v`
Expected: ImportError on `scripts.lib.theme_sniff`.

- [ ] **Step 4: Write minimal implementation `scripts/lib/theme_sniff.py`**

```python
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
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `python -m unittest scripts.tests.test_theme_sniff -v`
Expected: 5 tests pass.

- [ ] **Step 6: Commit**

```bash
git add scripts/lib/theme_sniff.py scripts/tests/test_theme_sniff.py scripts/tests/fixtures/ThemeSample.swift
git commit -m "feat(scripts): add theme_sniff for color/font/spacing/radius literals"
```

---

## Task 5: Python scanner library — `classifier.py`

**Files:**
- Create: `scripts/lib/classifier.py`
- Create: `scripts/tests/test_classifier.py`

- [ ] **Step 1: Write the failing test `scripts/tests/test_classifier.py`**

```python
import unittest
from scripts.lib.classifier import classify_concept

class ClassifierTests(unittest.TestCase):
    def test_known_concepts(self):
        cases = [
            ("ToastView",            "Toast"),
            ("ToastBanner",          "Toast"),
            ("CardContainer",        "Card"),
            ("LoadingSpinner",       "Loading"),
            ("LoadingOverlay",       "Loading"),
            ("ConfirmDialog",        "Dialog"),
            ("AlertDialog",          "Dialog"),
            ("PrimaryButton",        "Button"),
            ("CTAButton",            "Button"),
            ("CustomTextField",      "TextField"),
            ("SearchField",          "TextField"),
            ("SplashScreen",         "Splash"),
            ("OnboardingPage1",      "OnboardingPage"),
            ("OnboardingWelcome",    "OnboardingPage"),
            ("PaywallView",          "Paywall"),
            ("CameraScanView",       "CameraScan"),
            ("BarcodeScanner",       "CameraScan"),
            ("SettingsRowToggle",    "SettingsRow"),
        ]
        for name, expected in cases:
            self.assertEqual(classify_concept(name), expected, msg=name)

    def test_unknown_returns_none(self):
        self.assertIsNone(classify_concept("WaterDetailViewModel"))
        self.assertIsNone(classify_concept("ChessBoard"))
```

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m unittest scripts.tests.test_classifier -v`
Expected: ImportError.

- [ ] **Step 3: Write minimal implementation `scripts/lib/classifier.py`**

```python
"""Maps a Swift type name to a Tsumiki concept tag (or None)."""
from __future__ import annotations

import re

_RULES: list[tuple[re.Pattern[str], str]] = [
    (re.compile(r"Toast"),                     "Toast"),
    (re.compile(r"Card"),                      "Card"),
    (re.compile(r"Loading|Spinner|Skeleton"),  "Loading"),
    (re.compile(r"Dialog|Alert|Confirm"),      "Dialog"),
    (re.compile(r"TextField|SearchField"),     "TextField"),
    (re.compile(r"Button|CTA"),                "Button"),
    (re.compile(r"Splash"),                    "Splash"),
    (re.compile(r"Onboarding"),                "OnboardingPage"),
    (re.compile(r"Paywall"),                   "Paywall"),
    (re.compile(r"CameraScan|Scanner|Barcode"),"CameraScan"),
    (re.compile(r"SettingsRow"),               "SettingsRow"),
]

def classify_concept(name: str) -> str | None:
    for pattern, concept in _RULES:
        if pattern.search(name):
            return concept
    return None
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `python -m unittest scripts.tests.test_classifier -v`
Expected: 2 tests pass.

- [ ] **Step 5: Commit**

```bash
git add scripts/lib/classifier.py scripts/tests/test_classifier.py
git commit -m "feat(scripts): add concept classifier with name-heuristic rules"
```

---

## Task 6: Python `scan_project.py` end-to-end

**Files:**
- Create: `scripts/scan_project.py`
- Create: `scripts/tests/fixtures/CardView.swift`
- Create: `scripts/tests/test_scan_project.py`

- [ ] **Step 1: Write fixture `scripts/tests/fixtures/CardView.swift`**

```swift
import SwiftUI

public struct CardView: View {
    public let title: String

    public init(title: String) { self.title = title }

    public var body: some View {
        Text(title)
            .padding(16)
            .cornerRadius(12)
    }
}
```

- [ ] **Step 2: Write the failing test `scripts/tests/test_scan_project.py`**

```python
import json
import tempfile
import unittest
from pathlib import Path
from scripts.scan_project import scan

FIXTURES = Path(__file__).parent / "fixtures"

class ScanProjectTests(unittest.TestCase):
    def test_emits_components_and_theme_tokens(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td) / "fakeproj"
            (root / "Views" / "Components" / "Toast").mkdir(parents=True)
            (root / "Views" / "Components" / "Card").mkdir(parents=True)
            (root / "Views" / "Components" / "Toast" / "ToastView.swift").write_text(
                (FIXTURES / "ToastView.swift").read_text()
            )
            (root / "Views" / "Components" / "Card" / "CardView.swift").write_text(
                (FIXTURES / "CardView.swift").read_text()
            )
            out_path = Path(td) / "manifest.json"
            scan(project_name="fakeproj", root=root, out_path=out_path)

            data = json.loads(out_path.read_text())
            self.assertEqual(data["project"], "fakeproj")
            self.assertEqual(data["swift_files"], 2)
            concepts = {c["concept"] for c in data["components"]}
            self.assertEqual(concepts, {"Toast", "Card"})
            for comp in data["components"]:
                self.assertIn("path", comp)
                self.assertGreater(comp["loc"], 0)
            spacings = data["theme_tokens"]["spacings"]
            self.assertIn(12, spacings)
            self.assertIn(16, spacings)
```

- [ ] **Step 3: Run test to verify it fails**

Run: `python -m unittest scripts.tests.test_scan_project -v`
Expected: ImportError on `scripts.scan_project`.

- [ ] **Step 4: Write minimal implementation `scripts/scan_project.py`**

```python
"""Walk a project, emit a Tsumiki manifest JSON.

Usage:
    python scripts/scan_project.py <project_name> <project_root> -o manifests/<name>.json
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
        "animations": [],   # populated by Plan B; stub here
        "services":   [],   # populated by Plan B; stub here
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
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `python -m unittest scripts.tests.test_scan_project -v`
Expected: 1 test passes. Run full suite: `python -m unittest discover scripts/tests -v` — 12 tests pass.

- [ ] **Step 6: Run the scanner against all 5 real projects**

```bash
python scripts/scan_project.py aquabrew         /Users/carlos/projects/aquabrew/aquabrew                 -o manifests/aquabrew.json
python scripts/scan_project.py pulselog         /Users/carlos/projects/pulselog/pulselog                 -o manifests/pulselog.json
python scripts/scan_project.py lucidmate        /Users/carlos/projects/lucidmate/lucidmate               -o manifests/lucidmate.json
python scripts/scan_project.py warrantyreminder /Users/carlos/projects/warrantyreminder/warrantyreminder -o manifests/warrantyreminder.json
python scripts/scan_project.py zeroblock        /Users/carlos/projects/zeroblock/zeroblock               -o manifests/zeroblock.json
```

Expected: each command exits 0; `manifests/*.json` exists with non-empty `components` array (or empty + low `swift_files` count if a project has no matching components — record either way). Note that `manifests/*.json` is gitignored, so they will not appear in `git status`.

- [ ] **Step 7: Commit**

```bash
git add scripts/scan_project.py scripts/tests/fixtures/CardView.swift scripts/tests/test_scan_project.py
git commit -m "feat(scripts): add scan_project end-to-end manifest generator"
```

---

## Task 7: `diff_overlaps.py` cross-project duplicate detector

**Files:**
- Create: `scripts/diff_overlaps.py`
- Create: `scripts/tests/test_diff_overlaps.py`

- [ ] **Step 1: Write the failing test `scripts/tests/test_diff_overlaps.py`**

```python
import json
import tempfile
import unittest
from pathlib import Path
from scripts.diff_overlaps import build_overlaps

class DiffOverlapsTests(unittest.TestCase):
    def _manifest(self, project: str, components):
        return {
            "project": project,
            "root": "/x",
            "swift_files": 1,
            "components": components,
            "theme_tokens": {"colors": [], "fonts": [], "spacings": [], "radii": []},
            "animations": [],
            "services": [],
        }

    def test_groups_by_concept(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            for name, params, loc in [
                ("aquabrew", ["title:String", "icon:Image?", "duration:TimeInterval"], 84),
                ("warrantyreminder", ["title:String", "icon:Image?"], 61),
            ]:
                (root / f"{name}.json").write_text(json.dumps(self._manifest(name, [{
                    "name": "ToastView", "path": "x.swift", "kind": "View",
                    "concept": "Toast", "public_init_params": params, "loc": loc,
                }])))
            out = root / "_overlaps.json"
            build_overlaps(root, out)
            data = json.loads(out.read_text())
            toast = data["Toast"]
            self.assertEqual(len(toast["candidates"]), 2)
            # winner_hint = highest score (more params + more loc → higher)
            self.assertEqual(toast["winner_hint"], "aquabrew")
            self.assertIn("duration", toast["merge_params"])
```

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m unittest scripts.tests.test_diff_overlaps -v`
Expected: ImportError.

- [ ] **Step 3: Write minimal implementation `scripts/diff_overlaps.py`**

```python
"""Detect duplicate concepts across per-project manifests.

Reads manifests/*.json (skipping files prefixed with `_`) and writes
`<out>/_overlaps.json` keyed by concept.

Usage:
    python scripts/diff_overlaps.py manifests/ -o manifests/_overlaps.json
"""
from __future__ import annotations

import argparse
import json
from collections import defaultdict
from pathlib import Path
from typing import Any, Dict, List


def _score(loc: int, n_params: int) -> float:
    # Larger + richer params -> higher score, capped to keep output stable.
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
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `python -m unittest scripts.tests.test_diff_overlaps -v`
Expected: 1 test passes.

- [ ] **Step 5: Generate `_overlaps.json` against real manifests**

Run: `python scripts/diff_overlaps.py manifests -o manifests/_overlaps.json`
Expected: file is created with at least the `Toast` concept (since most apps have a toast). Inspect briefly: `python -c "import json; print(list(json.load(open('manifests/_overlaps.json')).keys()))"`.

- [ ] **Step 6: Commit**

```bash
git add scripts/diff_overlaps.py scripts/tests/test_diff_overlaps.py
git commit -m "feat(scripts): add diff_overlaps cross-project concept reporter"
```

---

## Task 8: `classify_components.py` and `build_catalog.py` thin wrappers

**Files:**
- Create: `scripts/classify_components.py`
- Create: `scripts/build_catalog.py`

These are thin orchestrators around the libraries already tested. They are kept intentionally tiny because their value is automation, not logic.

- [ ] **Step 1: Write `scripts/classify_components.py`**

```python
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
```

- [ ] **Step 2: Write `scripts/build_catalog.py`**

```python
"""Combine concepts + overlaps into a single Tsumiki port plan.

Output schema:
    {
      "concepts": {
        "<Concept>": {
          "winner": {"project": str, "path": str},
          "candidates": [...],
          "merge_params": [str]
        }
      }
    }
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
```

- [ ] **Step 3: Generate the real catalog**

```bash
python scripts/classify_components.py manifests -o manifests/_concepts.json
python scripts/build_catalog.py --concepts manifests/_concepts.json --overlaps manifests/_overlaps.json -o manifests/_tsumiki_plan.json
```

Expected: both files created. Inspect: `python -c "import json; print(sorted(json.load(open('manifests/_tsumiki_plan.json'))['concepts']))"`.

- [ ] **Step 4: Commit**

```bash
git add scripts/classify_components.py scripts/build_catalog.py
git commit -m "feat(scripts): add classify_components + build_catalog port-plan generator"
```

---

## Task 9: `lint_no_hardcoded.py` — guards `Sources/TsumikiComponents`

**Files:**
- Create: `scripts/lint_no_hardcoded.py`
- Create: `scripts/tests/test_lint_no_hardcoded.py`

- [ ] **Step 1: Write the failing test `scripts/tests/test_lint_no_hardcoded.py`**

```python
import tempfile
import unittest
from pathlib import Path
from scripts.lint_no_hardcoded import lint

class LintTests(unittest.TestCase):
    def _file(self, root: Path, body: str) -> Path:
        p = root / "Bad.swift"
        p.write_text(body)
        return p

    def test_flags_color_literal(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            self._file(root, "let c = Color.red")
            violations = lint(root)
            self.assertEqual(len(violations), 1)
            self.assertEqual(violations[0]["rule"], "color-literal")

    def test_flags_padding_literal(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            self._file(root, "Text(\"x\").padding(16)")
            violations = lint(root)
            self.assertTrue(any(v["rule"] == "spacing-literal" for v in violations))

    def test_allows_theme_access(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            self._file(root, "Text(\"x\").padding(theme.spacing.lg)")
            violations = lint(root)
            self.assertEqual(violations, [])

    def test_allows_zero_and_one(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            self._file(root, "Text(\"x\").padding(0).padding(1)")
            violations = lint(root)
            self.assertEqual(violations, [])
```

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m unittest scripts.tests.test_lint_no_hardcoded -v`
Expected: ImportError.

- [ ] **Step 3: Write minimal implementation `scripts/lint_no_hardcoded.py`**

```python
"""Forbids hardcoded theme values inside TsumikiComponents.

Allowed: theme-derived values (`theme.spacing.lg`, `colors.accent`), the literals
0 and 1 (idiomatic for full opacity / line widths). Everything else is a violation.

Usage:
    python scripts/lint_no_hardcoded.py Sources/TsumikiComponents
Exit code 1 if any violation is found.
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path
from typing import Any, Dict, List

_COLOR_LITERAL_RE = re.compile(r"\bColor\s*\.\s*(?:red|green|blue|black|white|yellow|orange|pink|purple|gray|grey)\b|\bColor\s*\(\s*(?:red|hex|.systemRed)")
_PADDING_RE       = re.compile(r"\.padding\(\s*(?:\.[a-zA-Z]+\s*,\s*)?(\d+)\s*\)")
_RADIUS_RE        = re.compile(r"\.cornerRadius\(\s*(\d+)\s*\)")

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
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `python -m unittest scripts.tests.test_lint_no_hardcoded -v`
Expected: 4 tests pass. Then full suite: `python -m unittest discover scripts/tests -v` — all green.

- [ ] **Step 5: Commit**

```bash
git add scripts/lint_no_hardcoded.py scripts/tests/test_lint_no_hardcoded.py
git commit -m "feat(scripts): add lint_no_hardcoded guard for TsumikiComponents"
```

---

## Task 10: `TsumikiTheme` token types (RED → GREEN, replaces stub)

**Files:**
- Create: `Sources/TsumikiTheme/Tokens/TsumikiColors.swift`
- Create: `Sources/TsumikiTheme/Tokens/TsumikiTypography.swift`
- Create: `Sources/TsumikiTheme/Tokens/TsumikiSpacing.swift`
- Create: `Sources/TsumikiTheme/Tokens/TsumikiRadius.swift`
- Create: `Sources/TsumikiTheme/Tokens/TsumikiShadow.swift`
- Create: `Sources/TsumikiTheme/Tokens/ShadowStyle.swift`
- Create: `Sources/TsumikiTheme/TsumikiTheme.swift`
- Rename + replace: `Tests/TsumikiThemeTests/TsumikiThemeTests.swift` → `Tests/TsumikiThemeTests/TsumikiThemeTokenTests.swift` (rename file, replace contents)
- Delete: `Sources/TsumikiTheme/Empty.swift`

- [ ] **Step 1: Rename and rewrite the placeholder test file**

```bash
git mv Tests/TsumikiThemeTests/TsumikiThemeTests.swift Tests/TsumikiThemeTests/TsumikiThemeTokenTests.swift
```

Then write its contents:

```swift
import XCTest
import SwiftUI
@testable import TsumikiTheme

final class TsumikiThemeTokenTests: XCTestCase {
    func testColorsExposesEightSemanticSlots() {
        let c = TsumikiColors(
            accent: .blue, background: .white, surface: .gray,
            textPrimary: .black, textSecondary: .gray,
            success: .green, warning: .yellow, danger: .red
        )
        XCTAssertEqual(c.accent, .blue)
        XCTAssertEqual(c.danger, .red)
    }

    func testSpacingHasSixSlotsAscending() {
        let s = TsumikiSpacing(xs: 4, sm: 8, md: 12, lg: 16, xl: 24, xxl: 32)
        XCTAssertLessThan(s.xs, s.sm)
        XCTAssertLessThan(s.lg, s.xl)
    }

    func testRadiusPillIsLarge() {
        let r = TsumikiRadius(sm: 6, md: 12, lg: 20, pill: 999)
        XCTAssertGreaterThan(r.pill, r.lg)
    }

    func testShadowStyleStoresColorAndOffsets() {
        let s = ShadowStyle(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        XCTAssertEqual(s.radius, 4)
        XCTAssertEqual(s.y, 2)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift test --filter TsumikiThemeTokenTests`
Expected: build error — `TsumikiColors`, `TsumikiSpacing`, `TsumikiRadius`, `ShadowStyle` undefined.

- [ ] **Step 3: Write `Sources/TsumikiTheme/Tokens/TsumikiColors.swift`**

```swift
import SwiftUI

public struct TsumikiColors: Sendable {
    public var accent: Color
    public var background: Color
    public var surface: Color
    public var textPrimary: Color
    public var textSecondary: Color
    public var success: Color
    public var warning: Color
    public var danger: Color

    public init(accent: Color, background: Color, surface: Color,
                textPrimary: Color, textSecondary: Color,
                success: Color, warning: Color, danger: Color) {
        self.accent = accent
        self.background = background
        self.surface = surface
        self.textPrimary = textPrimary
        self.textSecondary = textSecondary
        self.success = success
        self.warning = warning
        self.danger = danger
    }
}
```

- [ ] **Step 4: Write `Sources/TsumikiTheme/Tokens/TsumikiTypography.swift`**

```swift
import SwiftUI

public struct TsumikiTypography: Sendable {
    public var largeTitle: Font
    public var title: Font
    public var headline: Font
    public var body: Font
    public var caption: Font

    public init(largeTitle: Font, title: Font, headline: Font, body: Font, caption: Font) {
        self.largeTitle = largeTitle
        self.title = title
        self.headline = headline
        self.body = body
        self.caption = caption
    }
}
```

- [ ] **Step 5: Write `Sources/TsumikiTheme/Tokens/TsumikiSpacing.swift`**

```swift
import CoreGraphics

public struct TsumikiSpacing: Sendable {
    public var xs: CGFloat
    public var sm: CGFloat
    public var md: CGFloat
    public var lg: CGFloat
    public var xl: CGFloat
    public var xxl: CGFloat

    public init(xs: CGFloat, sm: CGFloat, md: CGFloat,
                lg: CGFloat, xl: CGFloat, xxl: CGFloat) {
        self.xs = xs; self.sm = sm; self.md = md
        self.lg = lg; self.xl = xl; self.xxl = xxl
    }
}
```

- [ ] **Step 6: Write `Sources/TsumikiTheme/Tokens/TsumikiRadius.swift`**

```swift
import CoreGraphics

public struct TsumikiRadius: Sendable {
    public var sm: CGFloat
    public var md: CGFloat
    public var lg: CGFloat
    public var pill: CGFloat

    public init(sm: CGFloat, md: CGFloat, lg: CGFloat, pill: CGFloat) {
        self.sm = sm; self.md = md; self.lg = lg; self.pill = pill
    }
}
```

- [ ] **Step 7: Write `Sources/TsumikiTheme/Tokens/ShadowStyle.swift`**

```swift
import SwiftUI

public struct ShadowStyle: Sendable {
    public var color: Color
    public var radius: CGFloat
    public var x: CGFloat
    public var y: CGFloat

    public init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        self.color = color; self.radius = radius; self.x = x; self.y = y
    }
}
```

- [ ] **Step 8: Write `Sources/TsumikiTheme/Tokens/TsumikiShadow.swift`**

```swift
public struct TsumikiShadow: Sendable {
    public var soft: ShadowStyle
    public var elevated: ShadowStyle

    public init(soft: ShadowStyle, elevated: ShadowStyle) {
        self.soft = soft; self.elevated = elevated
    }
}
```

- [ ] **Step 9: Write `Sources/TsumikiTheme/TsumikiTheme.swift`**

```swift
public protocol TsumikiTheme: Sendable {
    var colors:     TsumikiColors      { get }
    var typography: TsumikiTypography  { get }
    var spacing:    TsumikiSpacing     { get }
    var radius:     TsumikiRadius      { get }
    var shadow:     TsumikiShadow      { get }
}
```

- [ ] **Step 10: Delete the placeholder `Sources/TsumikiTheme/Empty.swift`**

```bash
git rm Sources/TsumikiTheme/Empty.swift
```

- [ ] **Step 11: Run tests**

Run: `swift test --filter TsumikiThemeTokenTests`
Expected: 4 tests pass.

- [ ] **Step 12: Commit**

```bash
git add Sources/TsumikiTheme Tests/TsumikiThemeTests/TsumikiThemeTests.swift
git commit -m "feat(theme): add token types and TsumikiTheme protocol"
```

---

## Task 11: `DefaultTheme` with `light` / `dark` and `with(_:_:)` override

**Files:**
- Create: `Sources/TsumikiTheme/DefaultTheme.swift`
- Create: `Tests/TsumikiThemeTests/DefaultThemeTests.swift`

- [ ] **Step 1: Write the failing test `Tests/TsumikiThemeTests/DefaultThemeTests.swift`**

`Color` is `Hashable` on iOS 17 but `Color(.systemBackground)` would be equal to itself, so the dark theme MUST use a visibly different colour value (not the same `UIColor` token) for this assertion to be meaningful.

```swift
import XCTest
import SwiftUI
@testable import TsumikiTheme

final class DefaultThemeTests: XCTestCase {
    func testLightAndDarkAreDistinct() {
        XCTAssertNotEqual(DefaultTheme.light.colors.accent,
                          DefaultTheme.dark.colors.accent)
    }

    func testWithReturnsMutatedCopy() {
        let original = DefaultTheme.light
        let modified = original.with(\.colors.accent, .pink)
        XCTAssertEqual(modified.colors.accent, .pink)
        XCTAssertEqual(original.colors.accent, DefaultTheme.light.colors.accent)
    }

    func testSpacingDefaultsAreSane() {
        XCTAssertEqual(DefaultTheme.light.spacing.lg, 16)
        XCTAssertEqual(DefaultTheme.light.spacing.xxl, 32)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift test --filter DefaultThemeTests`
Expected: build error — `DefaultTheme` undefined. (Color equality: `Color` conforms to `Equatable` via SwiftUI; if it does not on the SDK in use, the test compares via raw values — keep the tests as-is and we'll resolve in step 4 by leaning on `Color`'s `Hashable` conformance which exists on iOS 17.)

- [ ] **Step 3: Write `Sources/TsumikiTheme/DefaultTheme.swift`**

```swift
import SwiftUI

public struct DefaultTheme: TsumikiTheme {
    public var colors: TsumikiColors
    public var typography: TsumikiTypography
    public var spacing: TsumikiSpacing
    public var radius: TsumikiRadius
    public var shadow: TsumikiShadow

    public init(colors: TsumikiColors, typography: TsumikiTypography,
                spacing: TsumikiSpacing, radius: TsumikiRadius,
                shadow: TsumikiShadow) {
        self.colors = colors
        self.typography = typography
        self.spacing = spacing
        self.radius = radius
        self.shadow = shadow
    }

    public func with<V>(_ keyPath: WritableKeyPath<DefaultTheme, V>, _ value: V) -> DefaultTheme {
        var copy = self
        copy[keyPath: keyPath] = value
        return copy
    }
}

public extension DefaultTheme {
    static let light = DefaultTheme(
        colors: TsumikiColors(
            accent: .blue,
            background: Color(.systemBackground),
            surface: Color(.secondarySystemBackground),
            textPrimary: .primary,
            textSecondary: .secondary,
            success: .green,
            warning: .yellow,
            danger: .red
        ),
        typography: TsumikiTypography(
            largeTitle: .largeTitle,
            title: .title,
            headline: .headline,
            body: .body,
            caption: .caption
        ),
        spacing: TsumikiSpacing(xs: 4, sm: 8, md: 12, lg: 16, xl: 24, xxl: 32),
        radius:  TsumikiRadius(sm: 6, md: 12, lg: 20, pill: 999),
        shadow:  TsumikiShadow(
            soft:     ShadowStyle(color: .black.opacity(0.08), radius: 4,  x: 0, y: 2),
            elevated: ShadowStyle(color: .black.opacity(0.16), radius: 12, x: 0, y: 6)
        )
    )

    static let dark: DefaultTheme = {
        var t = DefaultTheme.light
        t.colors.background = .black
        t.colors.surface    = Color(white: 0.12)
        t.colors.accent     = .teal
        return t
    }()
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `swift test --filter DefaultThemeTests`
Expected: 3 tests pass.

- [ ] **Step 5: Commit**

```bash
git add Sources/TsumikiTheme/DefaultTheme.swift Tests/TsumikiThemeTests/DefaultThemeTests.swift
git commit -m "feat(theme): add DefaultTheme.light/.dark and with(_:_:) override helper"
```

---

## Task 12: `ThemeEnvironment` — env key + view modifier

**Files:**
- Create: `Sources/TsumikiTheme/ThemeEnvironment.swift`
- Create: `Tests/TsumikiThemeTests/ThemeEnvironmentTests.swift`

- [ ] **Step 1: Write the failing test `Tests/TsumikiThemeTests/ThemeEnvironmentTests.swift`**

```swift
import XCTest
import SwiftUI
@testable import TsumikiTheme

@MainActor
final class ThemeEnvironmentTests: XCTestCase {
    struct Probe: View {
        @Environment(\.tsumikiTheme) var theme
        let onResolve: (TsumikiTheme) -> Void
        var body: some View {
            Color.clear.onAppear { onResolve(theme) }
        }
    }

    func testDefaultThemeIsLight() {
        let exp = expectation(description: "resolve")
        let view = Probe { resolved in
            XCTAssertEqual(resolved.spacing.lg, DefaultTheme.light.spacing.lg)
            exp.fulfill()
        }
        let host = UIHostingController(rootView: view)
        host.view.layoutIfNeeded()
        wait(for: [exp], timeout: 1)
    }

    func testInjectedThemeOverridesDefault() {
        let exp = expectation(description: "resolve")
        let custom = DefaultTheme.light.with(\.spacing.lg, 99)
        let view = Probe { resolved in
            XCTAssertEqual(resolved.spacing.lg, 99)
            exp.fulfill()
        }.tsumikiTheme(custom)
        let host = UIHostingController(rootView: view)
        host.view.layoutIfNeeded()
        wait(for: [exp], timeout: 1)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift test --filter ThemeEnvironmentTests`
Expected: build error — `tsumikiTheme` env key + modifier undefined.

- [ ] **Step 3: Write `Sources/TsumikiTheme/ThemeEnvironment.swift`**

```swift
import SwiftUI

private struct TsumikiThemeKey: EnvironmentKey {
    static let defaultValue: any TsumikiTheme = DefaultTheme.light
}

public extension EnvironmentValues {
    var tsumikiTheme: any TsumikiTheme {
        get { self[TsumikiThemeKey.self] }
        set { self[TsumikiThemeKey.self] = newValue }
    }
}

public extension View {
    func tsumikiTheme(_ theme: any TsumikiTheme) -> some View {
        environment(\.tsumikiTheme, theme)
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `swift test --filter ThemeEnvironmentTests`
Expected: 2 tests pass.

- [ ] **Step 5: Commit**

```bash
git add Sources/TsumikiTheme/ThemeEnvironment.swift Tests/TsumikiThemeTests/ThemeEnvironmentTests.swift
git commit -m "feat(theme): add tsumikiTheme env key + .tsumikiTheme(_:) view modifier"
```

---

## Task 13: Reference component — `TsumikiToast` + `.tsumikiToast(_:)` modifier

**Files:**
- Modify: `Tests/TsumikiComponentsTests/TsumikiComponentsTests.swift` → rename to `TsumikiToastTests.swift` and replace contents
- Delete: `Sources/TsumikiComponents/Empty.swift`
- Create: `Sources/TsumikiComponents/Toast/TsumikiToast.swift`
- Create: `Sources/TsumikiComponents/Toast/TsumikiToastModifier.swift`

- [ ] **Step 1: Write the failing test (replace `Tests/TsumikiComponentsTests/TsumikiComponentsTests.swift` with `Tests/TsumikiComponentsTests/TsumikiToastTests.swift`)**

```bash
git mv Tests/TsumikiComponentsTests/TsumikiComponentsTests.swift Tests/TsumikiComponentsTests/TsumikiToastTests.swift
```

Then write:

```swift
import XCTest
import SwiftUI
@testable import TsumikiComponents
import TsumikiTheme

@MainActor
final class TsumikiToastTests: XCTestCase {
    func testToastInitWithTitleOnly() {
        let toast = TsumikiToast(title: "Saved")
        XCTAssertEqual(toast.title, "Saved")
        XCTAssertNil(toast.icon)
        XCTAssertEqual(toast.duration, 2.0)
        XCTAssertEqual(toast.style, .info)
    }

    func testToastInitWithAllParams() {
        let toast = TsumikiToast(
            title: "Done",
            icon: Image(systemName: "checkmark"),
            duration: 5.0,
            style: .success
        )
        XCTAssertEqual(toast.duration, 5.0)
        XCTAssertEqual(toast.style, .success)
    }

    func testToastRendersWithoutCrash() {
        let view = TsumikiToast(title: "Hi").tsumikiTheme(DefaultTheme.light)
        let host = UIHostingController(rootView: view)
        host.view.layoutIfNeeded()
        XCTAssertNotNil(host.view)
    }

    func testToastModifierRendersWithBinding() {
        var visible = true
        let binding = Binding(get: { visible }, set: { visible = $0 })
        let view = Color.clear.tsumikiToast(isPresented: binding) {
            TsumikiToast(title: "Hello")
        }
        let host = UIHostingController(rootView: view.tsumikiTheme(DefaultTheme.light))
        host.view.layoutIfNeeded()
        XCTAssertTrue(visible)
        XCTAssertNotNil(host.view)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift test --filter TsumikiToastTests`
Expected: build error — `TsumikiToast`, `tsumikiToast`, `TsumikiToast.Style` undefined.

- [ ] **Step 3: Delete `Sources/TsumikiComponents/Empty.swift`**

```bash
git rm Sources/TsumikiComponents/Empty.swift
```

- [ ] **Step 4: Write `Sources/TsumikiComponents/Toast/TsumikiToast.swift`**

The `.style` API consolidates the variants found across aquabrew and warrantyreminder (info / success / warning / danger). `merge_params` from `_overlaps.json` may suggest extra params; for the reference port, keep the API to four fields and call out future work in the docs page (Task 17).

```swift
import SwiftUI
import TsumikiTheme

public struct TsumikiToast: View {
    public enum Style: Sendable, Equatable {
        case info, success, warning, danger
    }

    public let title: String
    public let icon: Image?
    public let duration: TimeInterval
    public let style: Style

    @Environment(\.tsumikiTheme) private var theme

    public init(title: String,
                icon: Image? = nil,
                duration: TimeInterval = 2.0,
                style: Style = .info) {
        self.title = title
        self.icon = icon
        self.duration = duration
        self.style = style
    }

    public var body: some View {
        HStack(spacing: theme.spacing.sm) {
            if let icon { icon }
            Text(title).font(theme.typography.body)
        }
        .padding(.horizontal, theme.spacing.lg)
        .padding(.vertical,   theme.spacing.md)
        .background(backgroundColor)
        .foregroundStyle(theme.colors.textPrimary)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous))
        .shadow(color: theme.shadow.soft.color,
                radius: theme.shadow.soft.radius,
                x: theme.shadow.soft.x,
                y: theme.shadow.soft.y)
    }

    private var backgroundColor: Color {
        switch style {
        case .info:    return theme.colors.surface
        case .success: return theme.colors.success
        case .warning: return theme.colors.warning
        case .danger:  return theme.colors.danger
        }
    }
}
```

- [ ] **Step 5: Write `Sources/TsumikiComponents/Toast/TsumikiToastModifier.swift`**

```swift
import SwiftUI
import TsumikiTheme

public extension View {
    func tsumikiToast<Toast: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder toast: @escaping () -> Toast
    ) -> some View {
        modifier(TsumikiToastModifier(isPresented: isPresented, toast: toast))
    }
}

private struct TsumikiToastModifier<Toast: View>: ViewModifier {
    @Binding var isPresented: Bool
    let toast: () -> Toast
    @Environment(\.tsumikiTheme) private var theme

    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                VStack {
                    Spacer()
                    toast()
                        .padding(.bottom, theme.spacing.xl)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.spring(duration: 0.3), value: isPresented)
            }
        }
    }
}
```

- [ ] **Step 6: Run tests to verify they pass**

Run: `swift test --filter TsumikiToastTests`
Expected: 4 tests pass.

- [ ] **Step 7: Run lint over `Sources/TsumikiComponents`**

Run: `python scripts/lint_no_hardcoded.py Sources/TsumikiComponents`
Expected: exit 0, no output.

- [ ] **Step 8: Run full Swift test suite**

Run: `swift test`
Expected: all tests across all modules pass.

- [ ] **Step 9: Commit**

```bash
git add Sources/TsumikiComponents Tests/TsumikiComponentsTests/TsumikiToastTests.swift
git commit -m "feat(components): add TsumikiToast + .tsumikiToast(_:) modifier as reference component"
```

---

## Task 14: GitHub Actions CI

**Files:**
- Create: `.github/workflows/ci.yml`

- [ ] **Step 1: Write `.github/workflows/ci.yml`**

```yaml
name: CI

on:
  push:
    branches: [main, master]
  pull_request:

jobs:
  swift:
    name: Swift build + test (${{ matrix.ios }})
    runs-on: macos-14
    strategy:
      fail-fast: false
      matrix:
        ios: ["17.5", "18.0"]
    steps:
      - uses: actions/checkout@v4
      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.4.app
      - name: Build
        run: swift build
      - name: Test
        run: swift test
      - name: Lint TsumikiComponents
        run: python3 scripts/lint_no_hardcoded.py Sources/TsumikiComponents

  python:
    name: Python scanner tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - run: python -m unittest discover scripts/tests -v
```

The matrix iOS values are advisory — runner/Xcode versions evolve. Adjust the `xcode-select` path and matrix when the runner image changes; CI failure here is informative, not blocking package use.

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "ci: add GitHub Actions for swift build/test + python scanner tests"
```

---

## Task 15: `.claude/CLAUDE.md` orchestrator + `settings.json`

**Files:**
- Create: `.claude/CLAUDE.md`
- Create: `.claude/settings.json`

- [ ] **Step 1: Write `.claude/CLAUDE.md`**

```markdown
# Tsumiki Orchestrator — CLAUDE.md

## YOU ARE THE ONLY AGENT THAT WRITES CODE
Subagents in `.claude/agents/` are consultive. They read JSON manifests in
`manifests/` and return Markdown digests. They never write code, never edit
project files, and never delegate writes back to themselves.

Exception: `subagent-docs-analyst` may create or edit files under `docs/` and
`README.md`.

## Modes
- **Vibe Coding (default)** — orchestrator works directly. Use for small
  edits and exploratory work.
- **Subagents Orchestrator** — use for component port waves. Sequence:
  1. `subagent-project-mapper` × 5 (parallel, one per source project)
  2. `subagent-concept-classifier` (once)
  3. `subagent-overlap-arbiter` × N (parallel, one per concept)
  4. `subagent-theme-extractor` (once, when porting theme tokens)
  5. `subagent-architect` (once)
  6. `subagent-qa` (per module being ported)
  7. orchestrator implements (TDD: RED → GREEN → refactor)
  8. `subagent-docs-analyst` at end of wave

## Manifests
Subagents read `manifests/*.json`. Never give them raw Swift paths from the
source projects. If a subagent needs raw Swift, the orchestrator opens the
file and pastes the snippet into the prompt — this keeps source-project file
reads bounded to the orchestrator.

## Source projects (read-only)
- `/Users/carlos/projects/aquabrew`
- `/Users/carlos/projects/pulselog`
- `/Users/carlos/projects/lucidmate`
- `/Users/carlos/projects/warrantyreminder`
- `/Users/carlos/projects/zeroblock`

Never edit a source project from within Tsumiki work — migrations happen in
the source project's repo, not here.

## Build / test / lint
| Command | Purpose |
|---|---|
| `swift build` | Build all targets |
| `swift test`  | Run all XCTest targets |
| `swift test --filter <Name>` | Run a single test class |
| `python -m unittest discover scripts/tests` | Run scanner tests |
| `python scripts/lint_no_hardcoded.py Sources/TsumikiComponents` | Theme-literal lint |
| `python scripts/scan_project.py <name> <root> -o manifests/<name>.json` | Re-scan one project |

## Public-API rules
- Every type, view, and modifier exported from a target is `public`.
- No `@_spi`. No internal singletons. No globals.
- Components read theme via `@Environment(\.tsumikiTheme)`. Hardcoded
  `Color`, spacing, font, or radius literals are forbidden in
  `Sources/TsumikiComponents` and enforced by `lint_no_hardcoded.py` in CI.

## Caveman mode
Read `.claude/settings.json`. If `behavior.caveman_mode === true`, apply the
caveman compression rules to user-facing prose (not to code, commits, or PRs).
Default: `false`.
```

- [ ] **Step 2: Write `.claude/settings.json`**

```json
{
  "behavior": {
    "caveman_mode": false
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add .claude/CLAUDE.md .claude/settings.json
git commit -m "chore(claude): add Tsumiki orchestrator CLAUDE.md and settings"
```

---

## Task 16: `.claude/agents/` subagent definitions

**Files:**
- Create: `.claude/agents/subagent-project-mapper.md`
- Create: `.claude/agents/subagent-concept-classifier.md`
- Create: `.claude/agents/subagent-overlap-arbiter.md`
- Create: `.claude/agents/subagent-theme-extractor.md`
- Create: `.claude/agents/subagent-architect.md`
- Create: `.claude/agents/subagent-qa.md`
- Create: `.claude/agents/subagent-docs-analyst.md`

Each file uses the same frontmatter block. Replace `<NAME>`, `<DESCRIPTION>`, and `<TOOLS>` per agent.

Common header template:
```markdown
---
name: <NAME>
description: <DESCRIPTION>
tools: <TOOLS>
---

# <NAME>

## Role
<2-3 sentences>

## Inputs
<exact paths or args the orchestrator passes>

## Process
<numbered steps>

## Output
<exact shape of return value>

## Constraints
- Never write or edit files outside the allowed list.
- Output must fit in <line budget> lines.
```

- [ ] **Step 1: Write `.claude/agents/subagent-project-mapper.md`**

```markdown
---
name: subagent-project-mapper
description: Reads one manifests/<project>.json and returns a Markdown digest of components, theme tokens, animations, and services. Pure read; produces no files.
tools: Read
---

# subagent-project-mapper

## Role
Summarize a single source project's manifest into a compact, scannable digest the
orchestrator and downstream subagents can quote.

## Inputs
- Absolute path to one `manifests/<project>.json`.

## Process
1. Read the manifest.
2. Group components by concept.
3. Tally theme tokens (colour count, spacing values, radii, font styles).
4. Note animations and services.

## Output
Markdown ≤ 200 lines:
- `## Project: <name>` heading
- `## Components` table: concept | name | path | params | loc
- `## Theme tokens` bullet list
- `## Animations` bullet list (or "none")
- `## Services` bullet list (or "none")

## Constraints
- Read only the manifest path provided. Do not open Swift files.
- Do not edit or write any file.
```

- [ ] **Step 2: Write `.claude/agents/subagent-concept-classifier.md`**

```markdown
---
name: subagent-concept-classifier
description: Reads all manifests/*.json and produces a unified concept→candidates table. Read-only.
tools: Read, Glob
---

# subagent-concept-classifier

## Role
Cluster components across the five projects by concept and surface the candidate
set per concept so the orchestrator can dispatch arbiters.

## Inputs
- Absolute path to `manifests/` directory.

## Process
1. Glob `manifests/*.json` skipping files prefixed `_`.
2. For each manifest, read components and group by concept.
3. Note discrepancies (e.g., concept appears in only one project).

## Output
Markdown ≤ 200 lines: one section per concept with candidate list (project, name, path, loc, params).
List concepts that appear in only one project under "## Singletons" — they need no arbiter.

## Constraints
- Read only `manifests/*.json`. No Swift files.
- Do not edit or write any file.
```

- [ ] **Step 3: Write `.claude/agents/subagent-overlap-arbiter.md`**

```markdown
---
name: subagent-overlap-arbiter
description: Picks the canonical implementation for one concept and proposes a unified parameter list. May read raw Swift only for the candidate paths in _overlaps.json.
tools: Read
---

# subagent-overlap-arbiter

## Role
Resolve one concept's duplicate implementations into a single Tsumiki API design.

## Inputs
- Concept name (e.g., "Toast").
- Absolute path to `manifests/_overlaps.json`.
- Permission to read the candidate file paths listed under that concept.

## Process
1. Read `_overlaps.json`, locate the concept entry.
2. Read each candidate Swift file at its `path` (relative to its source project root,
   which the orchestrator provides as a prefix).
3. Compare API shape, dependencies, theme-token usage, accessibility considerations.
4. Pick a winner. Justify in ≤ 5 bullets.
5. Propose a merged init signature (Swift code) plus rationale.

## Output
Markdown ≤ 200 lines:
- `## Winner: <project>` + `## Why` bullets
- `## Merged API` Swift code block
- `## Theme tokens consumed` list
- `## Risks / open questions`

## Constraints
- Read only the candidate paths from `_overlaps.json`. Do not glob the source projects.
- Do not edit or write any file.
```

- [ ] **Step 4: Write `.claude/agents/subagent-theme-extractor.md`**

```markdown
---
name: subagent-theme-extractor
description: Reads theme_tokens blocks from all manifests/*.json and proposes a consolidated DefaultTheme palette. Read-only.
tools: Read, Glob
---

# subagent-theme-extractor

## Role
Recommend a single token set for `DefaultTheme.light` and `DefaultTheme.dark` based
on what the five apps actually use.

## Inputs
- Absolute path to `manifests/` directory.

## Process
1. Glob `manifests/*.json` skipping `_*`.
2. Aggregate `theme_tokens` (colours by hex, font styles, spacings, radii).
3. Cluster colours visually (closest hex per semantic role).
4. Pick a six-step spacing scale and a four-step radius scale that covers ≥ 80 %
   of observed values.

## Output
Markdown ≤ 150 lines:
- `## Colours` table: semantic role | proposed hex | source projects using a near match
- `## Spacing` proposed scale + coverage %
- `## Radii` proposed scale + coverage %
- `## Typography` proposed Font choices
- `## Open questions` (e.g., a project uses Color.aquaBlue exclusively — keep as accent override?)

## Constraints
- Read manifests only.
- Do not edit or write any file.
```

- [ ] **Step 5: Write `.claude/agents/subagent-architect.md`**

```markdown
---
name: subagent-architect
description: Designs Tsumiki module file layout and public API for one component port wave, given the arbiter's merged API decision.
tools: Read
---

# subagent-architect

## Role
Translate arbiter outputs into a concrete file plan and Swift public-API sketch
the orchestrator can implement TDD-style.

## Inputs
- Arbiter output (concept name, merged API, theme tokens consumed).
- Existing `Sources/TsumikiComponents/` directory contents (for layout consistency).

## Process
1. Decide file layout (e.g., `Toast/TsumikiToast.swift` + `Toast/TsumikiToastModifier.swift`).
2. Define public types, init signatures, view modifier signatures.
3. List theme tokens read.
4. Note dependencies on `TsumikiAnimations` or `TsumikiServices` if any.

## Output
Markdown ≤ 200 lines:
- `## File layout` tree
- `## Public API` Swift code block (signatures only)
- `## Theme tokens consumed` list
- `## Dependencies` list
- `## Test plan delegation` — say "delegate to subagent-qa"

## Constraints
- May read existing Tsumiki source for layout reference.
- Do not edit or write any file.
```

- [ ] **Step 6: Write `.claude/agents/subagent-qa.md`**

```markdown
---
name: subagent-qa
description: Produces an XCTest blueprint for one component port — test names, scenarios, fixtures.
tools: Read
---

# subagent-qa

## Role
Design the failing tests the orchestrator will write before implementing.

## Inputs
- Architect output (file layout + public API).

## Process
1. List test classes and methods (one method per behaviour).
2. For each test method, give the assertion in Swift pseudo-code.
3. Note view-rendering tests using `UIHostingController` for crash-free smoke.

## Output
Markdown ≤ 150 lines:
- `## Test classes` list
- For each test: name + 1-line behaviour + Swift snippet of the assertion
- `## Fixtures` (none for views typically)

## Constraints
- Do not write tests — return the blueprint only.
- Do not edit or write any file.
```

- [ ] **Step 7: Write `.claude/agents/subagent-docs-analyst.md`**

```markdown
---
name: subagent-docs-analyst
description: Maintains README.md, docs/components/*.md, docs/MIGRATION.md, and directory-tree.md. The only subagent allowed to write files.
tools: Read, Write, Edit, Glob, Grep, Bash
---

# subagent-docs-analyst

## Role
Keep documentation current at the end of each port wave.

## Inputs
- The change set just landed (architect + arbiter outputs, list of new files).

## Process
1. Update `README.md` quickstart if the public surface changed.
2. Create or update `docs/components/<Concept>.md` (≤ 80 lines: API signature, one
   SwiftUI example, theme tokens consumed).
3. Refresh `directory-tree.md` at root via `find Sources -type f | sort`.
4. Update `docs/MIGRATION.md` if the port enables a new migration step.

## Output
List of files written/modified.

## Constraints
- Write only inside `docs/`, `README.md`, and `directory-tree.md`.
- Never touch `Sources/`, `Tests/`, or `scripts/`.
- Never modify `Package.swift`.
```

- [ ] **Step 8: Commit**

```bash
git add .claude/agents
git commit -m "chore(claude): add Tsumiki subagent roster"
```

---

## Task 17: `docs/components/Toast.md`

**Files:**
- Create: `docs/components/Toast.md`

- [ ] **Step 1: Write `docs/components/Toast.md`**

```markdown
# TsumikiToast

A small banner-style notification with a configurable style and optional icon.
Lives in `TsumikiComponents`. Reads theme via `@Environment(\.tsumikiTheme)`.

## API

```swift
public struct TsumikiToast: View {
    public enum Style { case info, success, warning, danger }

    public init(title: String,
                icon: Image? = nil,
                duration: TimeInterval = 2.0,
                style: Style = .info)
}

public extension View {
    func tsumikiToast<Toast: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder toast: @escaping () -> Toast
    ) -> some View
}
```

## Example

```swift
import SwiftUI
import TsumikiComponents
import TsumikiTheme

struct Demo: View {
    @State private var showing = false
    var body: some View {
        Button("Save") { showing = true }
            .tsumikiToast(isPresented: $showing) {
                TsumikiToast(title: "Saved",
                             icon: Image(systemName: "checkmark"),
                             style: .success)
            }
            .tsumikiTheme(DefaultTheme.light)
    }
}
```

## Theme tokens consumed
- `colors.surface`, `colors.success`, `colors.warning`, `colors.danger`, `colors.textPrimary`
- `typography.body`
- `spacing.sm`, `spacing.md`, `spacing.lg`, `spacing.xl`
- `radius.md`
- `shadow.soft`

## Notes
- Auto-dismiss using the supplied `duration` is a follow-up (Plan B). Today the
  modifier honours the binding only.
- Position is bottom-anchored. Top variant tracked as a follow-up.
```

- [ ] **Step 2: Commit**

```bash
git add docs/components/Toast.md
git commit -m "docs: add TsumikiToast component reference page"
```

---

## Task 18: Repo `README.md` quickstart + `directory-tree.md`

**Files:**
- Modify: `README.md` (overwrite the placeholder noted in `git status`)
- Create: `directory-tree.md`

- [ ] **Step 1: Overwrite `README.md` with Tsumiki quickstart**

```markdown
# Tsumiki

A SwiftUI component library that consolidates the reusable surface area of five
iOS apps (aquabrew, pulselog, lucidmate, warrantyreminder, zeroblock) into one
plug-and-play, theme-extensible Swift package.

## Install

In `Package.swift`:

```swift
.package(url: "https://github.com/<owner>/tsumiki.git", from: "0.1.0")
```

Then add the modules you need to your target:

```swift
.product(name: "TsumikiTheme",      package: "tsumiki"),
.product(name: "TsumikiComponents", package: "tsumiki"),
```

## Quickstart

```swift
import SwiftUI
import TsumikiComponents
import TsumikiTheme

@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().tsumikiTheme(DefaultTheme.light)
        }
    }
}

struct ContentView: View {
    @State private var saved = false
    var body: some View {
        Button("Save") { saved = true }
            .tsumikiToast(isPresented: $saved) {
                TsumikiToast(title: "Saved", style: .success)
            }
    }
}
```

## Modules
- `TsumikiCore` — shared protocols + env keys.
- `TsumikiTheme` — `TsumikiTheme` protocol + `DefaultTheme` + tokens + env injection.
- `TsumikiComponents` — SwiftUI components.
- `TsumikiAnimations` — reusable animations + view modifiers.
- `TsumikiServices` — analytics, ads, paywall, notifications protocols + defaults.

See `docs/PRD.md` for scope and `docs/components/` for per-component reference.

## Custom theme

```swift
let pinkTheme = DefaultTheme.light.with(\.colors.accent, .pink)
ContentView().tsumikiTheme(pinkTheme)
```

## Repo layout
See `directory-tree.md`.
```

- [ ] **Step 2: Generate `directory-tree.md`**

Run:
```bash
{ echo '# Tsumiki directory tree'; echo; echo '```'; find Sources Tests scripts docs .claude -type f | sort; echo '```'; } > directory-tree.md
```

- [ ] **Step 3: Commit**

```bash
git add README.md directory-tree.md
git commit -m "docs: replace placeholder README with Tsumiki quickstart and add directory-tree"
```

---

## Task 19: Final verification

- [ ] **Step 1: Run all Swift tests**

Run: `swift test`
Expected: all tests pass across `TsumikiCoreTests`, `TsumikiThemeTests`,
`TsumikiComponentsTests`, `TsumikiAnimationsTests`, `TsumikiServicesTests`.

- [ ] **Step 2: Run all Python scanner tests**

Run: `python -m unittest discover scripts/tests -v`
Expected: all tests across `test_swift_lex`, `test_theme_sniff`, `test_classifier`,
`test_scan_project`, `test_diff_overlaps`, `test_lint_no_hardcoded` pass.

- [ ] **Step 3: Lint TsumikiComponents**

Run: `python scripts/lint_no_hardcoded.py Sources/TsumikiComponents`
Expected: exit 0, no output.

- [ ] **Step 4: Confirm manifests exist for all five projects**

Run: `ls manifests/`
Expected: `aquabrew.json  lucidmate.json  pulselog.json  warrantyreminder.json  zeroblock.json  _concepts.json  _overlaps.json  _tsumiki_plan.json  .gitkeep` (manifests are gitignored but present locally).

- [ ] **Step 5: Spot-check the port plan**

Run: `python -c "import json; d=json.load(open('manifests/_tsumiki_plan.json'));
print(sorted(d['concepts']))"`
Expected: at minimum `Toast` is present; ideally most of the MVP set
(`Card`, `Loading`, `Dialog`, `Button`, `TextField`, `Splash`, `OnboardingPage`,
`Paywall`, `CameraScan`, `SettingsRow`).

- [ ] **Step 6: No final commit needed** — everything was committed in the prior tasks.
