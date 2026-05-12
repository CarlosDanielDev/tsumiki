# Tsumiki MVP — Design Spec

**Date**: 2026-05-11
**Status**: Draft (pending user approval)
**Owner**: Carlos
**Source projects**: aquabrew, pulselog, lucidmate, warrantyreminder, zeroblock

---

## 1. Problem

Five iOS/SwiftUI apps re-implement the same building blocks: cards, toasts, loading
indicators, dialogs, text fields, splash, onboarding pages, paywalls, camera scanners,
settings rows, theme tokens, analytics, ads, StoreKit paywall flows, notifications.

Result: visual drift, duplicated bug-fixes, no shared upgrade path.

## 2. Goal

Ship a single Swift Package, **Tsumiki**, that consolidates the reusable surface area
of all five apps into a plug-and-play, theme-extensible library. A consumer adds the
package URL, imports the modules they want, optionally injects a custom theme, and is
done.

## 3. Non-Goals

- Backend, server, or cloud code.
- Multiplatform support (macOS / visionOS / watchOS) for v1.
- UIKit components — SwiftUI only.
- Code-generation tooling for consumers.
- Snapshot-testing infrastructure in the MVP.
- Domain logic from source apps (chess engine, water-quality rules, warranty schema, etc.).

## 4. Personas

Carlos is the sole consumer. He maintains all five source apps and will adopt Tsumiki
incrementally, starting with `warrantyreminder` (smallest surface).

## 5. Architecture

### 5.1 Package layout

```
Tsumiki/
├── Package.swift
├── Sources/
│   ├── TsumikiCore/         # Protocols, env keys, shared utilities
│   ├── TsumikiTheme/        # Theme protocol + DefaultTheme + tokens + env injection
│   ├── TsumikiComponents/   # SwiftUI components
│   ├── TsumikiAnimations/   # Reusable animations + view modifiers
│   └── TsumikiServices/     # Analytics, Ads, Paywall (StoreKit 2), Notifications
├── Tests/
│   ├── TsumikiCoreTests/
│   ├── TsumikiThemeTests/
│   ├── TsumikiComponentsTests/
│   ├── TsumikiAnimationsTests/
│   └── TsumikiServicesTests/
├── Examples/
│   └── TsumikiCatalog/      # SwiftUI demo app browsing every component
├── scripts/                 # Python scanners + helpers
├── manifests/               # Generated JSON outputs
└── docs/
    ├── PRD.md
    ├── MIGRATION.md
    └── components/<Concept>.md
```

### 5.2 Module dependency graph

```
TsumikiCore  ←  TsumikiTheme  ←  TsumikiComponents
                              ←  TsumikiAnimations
TsumikiCore  ←  TsumikiServices
```

### 5.3 Targets (Package.swift)

```swift
.library(name: "TsumikiCore",       targets: ["TsumikiCore"]),
.library(name: "TsumikiTheme",      targets: ["TsumikiTheme"]),
.library(name: "TsumikiComponents", targets: ["TsumikiComponents"]),
.library(name: "TsumikiAnimations", targets: ["TsumikiAnimations"]),
.library(name: "TsumikiServices",   targets: ["TsumikiServices"]),
```

Platforms: `iOS(.v17)`. Swift tools 5.9+. Zero external dependencies for v1.

### 5.4 Public-API rules

- All exported types, views, and modifiers are `public`.
- No `@_spi`. No internal singletons. No globals.
- Components hold no state outside `@State`/`@Binding`/env.
- Services are protocols + a default implementation; consumers may swap.
- Components read theme via `@Environment(\.tsumikiTheme)`. Hardcoded `Color`,
  spacing, font, radius literals are forbidden inside `TsumikiComponents` and
  enforced by `scripts/lint_no_hardcoded.py`.

## 6. Theme Extension API

```swift
public protocol TsumikiTheme {
    var colors:     TsumikiColors      { get }
    var typography: TsumikiTypography  { get }
    var spacing:    TsumikiSpacing     { get }
    var radius:     TsumikiRadius      { get }
    var shadow:     TsumikiShadow      { get }
}

public struct TsumikiColors {
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
                success: Color, warning: Color, danger: Color)
}

public struct TsumikiTypography {
    public var largeTitle: Font
    public var title: Font
    public var headline: Font
    public var body: Font
    public var caption: Font
}

public struct TsumikiSpacing {
    public var xs: CGFloat   //  4
    public var sm: CGFloat   //  8
    public var md: CGFloat   // 12
    public var lg: CGFloat   // 16
    public var xl: CGFloat   // 24
    public var xxl: CGFloat  // 32
}

public struct TsumikiRadius {
    public var sm: CGFloat   //  6
    public var md: CGFloat   // 12
    public var lg: CGFloat   // 20
    public var pill: CGFloat // 999
}

public struct TsumikiShadow {
    public var soft: ShadowStyle
    public var elevated: ShadowStyle
}
public struct ShadowStyle {
    public var color: Color
    public var radius: CGFloat
    public var x: CGFloat
    public var y: CGFloat
}

public struct DefaultTheme: TsumikiTheme {
    public static let light: DefaultTheme
    public static let dark:  DefaultTheme
}

private struct TsumikiThemeKey: EnvironmentKey {
    static let defaultValue: TsumikiTheme = DefaultTheme.light
}

public extension EnvironmentValues {
    var tsumikiTheme: TsumikiTheme {
        get { self[TsumikiThemeKey.self] }
        set { self[TsumikiThemeKey.self] = newValue }
    }
}

public extension View {
    func tsumikiTheme(_ theme: TsumikiTheme) -> some View {
        environment(\.tsumikiTheme, theme)
    }
}
```

**Override convenience**: `DefaultTheme.light.with(\.colors.accent, .pink)` returns a
mutated copy without re-declaring all tokens. Implemented via a `with(_:_:)` helper
on the concrete struct.

**Consumer pattern**:

```swift
struct AquaBrewTheme: TsumikiTheme { /* override only what differs */ }

@main struct AquaBrewApp: App {
    var body: some Scene {
        WindowGroup { RootView().tsumikiTheme(AquaBrewTheme()) }
    }
}
```

## 7. Scanner Pipeline (Python)

**Location**: `scripts/`. Python 3.11+. Standard library only.

```
scripts/
├── scan_project.py           # one project → manifests/<name>.json
├── classify_components.py    # cluster concepts across manifests → manifests/_concepts.json
├── diff_overlaps.py          # duplicate detection + winner hint → manifests/_overlaps.json
├── build_catalog.py          # final tsumiki plan → manifests/_tsumiki_plan.json
├── lint_no_hardcoded.py      # CI gate: no Color/spacing literals in TsumikiComponents
├── lib/
│   ├── swift_lex.py          # regex Swift symbol extractor
│   ├── theme_sniff.py        # Color/font/spacing/radius literal detector
│   └── classifier.py         # name heuristics (Toast|Card|Loading|Dialog|Onboarding|...)
└── tests/                    # python -m unittest
```

### 7.1 Per-project manifest schema

```json
{
  "project": "aquabrew",
  "root": "/Users/carlos/projects/aquabrew/aquabrew",
  "swift_files": 312,
  "components": [
    {
      "name": "ToastView",
      "path": "aquabrew/Views/Components/Toast/ToastView.swift",
      "kind": "View",
      "concept": "Toast",
      "public_init_params": ["title:String", "icon:Image?", "duration:TimeInterval"],
      "depends_on": ["Color.aquaBlue", "Font.system(.body)"],
      "loc": 84
    }
  ],
  "theme_tokens": {
    "colors":   [{"name": "aquaBlue", "hex": "#0EA5E9", "files": 3}],
    "fonts":    [{"style": ".largeTitle", "weight": ".bold", "files": 7}],
    "spacings": [8, 12, 16, 24],
    "radii":    [8, 12, 20]
  },
  "animations": [{"name": "bubblePulse", "modifier": ".bubblePulse()", "file": "..."}],
  "services":   [{"name": "AnalyticsManager", "protocol": null, "file": "..."}]
}
```

### 7.2 Overlap report schema

```json
{
  "Toast": {
    "candidates": [
      {"project": "aquabrew",         "path": "...", "loc": 84, "params": 3, "score": 0.82},
      {"project": "warrantyreminder", "path": "...", "loc": 61, "params": 2, "score": 0.71}
    ],
    "winner_hint": "aquabrew",
    "merge_params": ["icon", "duration"]
  }
}
```

### 7.3 Why this saves context

Subagents read `manifests/*.json` (≤30 KB each) instead of hundreds of `.swift`
files. The architect only opens raw Swift for files referenced in `_overlaps.json`
winner-hint paths. Total raw-file reads in main context drop ~95% vs naive
exploration.

## 8. Subagent Roster

Defined in `.claude/agents/`. Distinct from Maestro (no DOR / gatekeeper /
contracts — Tsumiki is a library, not an API service).

| Subagent | Trigger | Reads | Writes | Returns |
|---|---|---|---|---|
| `subagent-project-mapper` | Per source project, parallel × 5 | `manifests/<project>.json` only | nothing | per-project component digest (Markdown table, ≤200 lines) |
| `subagent-concept-classifier` | After all 5 mappers done | all 5 manifests + `_concepts.json` | nothing | unified concept list with candidates |
| `subagent-overlap-arbiter` | Per concept, parallel × N | `_overlaps.json` + raw Swift of candidates only | nothing | winner + merged param list |
| `subagent-theme-extractor` | Once | all 5 `theme_tokens` blocks | nothing | proposed `DefaultTheme` token table |
| `subagent-architect` | Once, after arbiters | merged plan | nothing | module layout, public-API sketch, file plan |
| `subagent-qa` | Per module | architect output | nothing | XCTest blueprint |
| `subagent-docs-analyst` | End | everything | `README.md`, `docs/components/*.md`, `directory-tree.md` | minimal docs |

**Orchestrator** (`Tsumiki/.claude/CLAUDE.md`) is the only writer of code. Default
mode is Vibe Coding; switch to Subagents Orchestrator mode for component-port
waves.

## 9. MVP Component Set

Concepts in scope for v1 (others deferred to vNext):

**Components** — `TsumikiCard`, `TsumikiToast`, `TsumikiLoading`, `TsumikiDialog`,
`TsumikiTextField`, `TsumikiButton`, `TsumikiSplash`, `TsumikiOnboardingPage`,
`TsumikiPaywall`, `TsumikiCameraScan`, `TsumikiSettingsRow`.

**Animations** — `bubblePulse`, `shimmerLoading`, `confettiBurst`,
`slideOnboarding`. Names tentative; the arbiter finalises after seeing source.

**Services** — `TsumikiAnalytics` (protocol), `TsumikiAdsCoordinator` (protocol),
`TsumikiPaywallController` (StoreKit 2), `TsumikiNotifications`. Each ships with
a default no-op or sample implementation.

**Theme** — `DefaultTheme` (`light`, `dark`) + `ThemeProvider` env injection.

**Out of MVP** — chess-board widgets (lucidmate), water-quality logic (aquabrew),
warranty Core Data (warrantyreminder), pulselog Watch app, zeroblock engine.
Domain code stays in apps.

## 10. MVP Success Criteria

1. All 5 projects map ≥80 % of their `Views/Components/**` files to a Tsumiki
   concept (measured by `_overlaps.json` coverage).
2. Each in-scope concept ships with at least one runnable example in
   `Examples/TsumikiCatalog`.
3. `warrantyreminder` migrated to Tsumiki without visible visual regression
   (manual diff against pre-migration screenshots).
4. `swift build`, `swift test`, and `python -m unittest scripts.tests` all green
   on iOS 17 and iOS 18 simulators.

## 11. Phases

| Phase | Output |
|---|---|
| **P0** Scanner + manifests | `scripts/`, `manifests/*.json`, lint script |
| **P1** Architect plan + scaffolding | All 5 modules empty + `TsumikiTheme` complete + 1 reference component (`TsumikiToast`) end-to-end |
| **P2** Component port wave | Parallel arbiters → orchestrator implements remaining concepts module by module |
| **P3** Catalog + first migration | `Examples/TsumikiCatalog` complete, `warrantyreminder` migrated, `MIGRATION.md` written |

## 12. Testing Strategy

- `swift test` per module. `XCTest` only — zero test-framework dependencies.
- **Theme tests**: tokens non-nil; `light` ≠ `dark`; `with(_:_:)` mutates copy.
- **Component tests**: render in `UIHostingController`; assert no crash; key
  subviews present via `Mirror` reflection on `body`. If too brittle, fall back
  to Catalog smoke test.
- **Animation tests**: compile-time verification that modifier composes on `AnyView`.
- **Service tests**: protocol conformance + default impl returns expected sentinel.
- **Python tests**: `python -m unittest discover scripts/tests`.
- **CI**: GitHub Actions matrix iOS 17 + iOS 18 simulator.
- **No snapshot tests in MVP.** Rely on Catalog app + manual check on first migration.

## 13. Documentation Strategy

Strictly minimal — Tsumiki is a small library, no ADRs, no per-PR notes.

- `README.md` — install URL, import map, 30-line quickstart with theme override and
  one component.
- `docs/PRD.md` — sections 1-4 of this spec, condensed.
- `docs/MIGRATION.md` — step-by-step with before/after diff snippet.
- `docs/components/<Concept>.md` — one page per concept, ≤80 lines: API signature,
  one SwiftUI example, theme tokens consumed. Generated by `subagent-docs-analyst`.
- `directory-tree.md` — auto-maintained at root.

## 14. Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Source projects use incompatible APIs (e.g. iOS 17 vs 16 features) | Pin Tsumiki to iOS 17; reject candidates that need older symbols |
| Theme tokens diverge wildly across apps | `subagent-theme-extractor` proposes a consolidated set; consumers override what differs |
| Naming conflicts (multiple `Card` impls) | Arbiter picks winner via score (LOC / param richness / dependency cleanliness) |
| Scanner regex misses edge cases (multi-line decls) | Tests in `scripts/tests/` with fixtures from each project |
| Catalog app drifts from real components | CI builds Catalog; broken build fails PR |
| Hardcoded literals leak into components | `lint_no_hardcoded.py` runs in CI; failing build blocks merge |

## 15. Open Questions

None — all four design questions resolved with the user before drafting:

- Scope: Components + Theme + Animations + Services
- Packaging: single SwiftPM package, modular targets
- Overlaps: pick best, merge variants as configuration
- Pipeline: per-project scanner → JSON manifests → subagents
