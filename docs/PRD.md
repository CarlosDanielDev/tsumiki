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
- Multiplatform (visionOS / watchOS) for v1. macOS is a build target only (lets
  `swift test` run on the host); UIKit-specific tests are gated.
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
   all green.

## Phases
- P0: Python scanners + manifests + subagent roster + lint + PRD.
- P1: Package scaffolding + complete `TsumikiTheme` + reference `TsumikiToast`.
- P2: Component port wave (per-concept).
- P3: TsumikiCatalog + first consumer migration.

See `docs/superpowers/specs/2026-05-11-tsumiki-mvp-design.md` for full design.
