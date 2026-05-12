# NEXT-SESSION.md — Tsumiki resume guide

**Last updated:** 2026-05-11 23:40 (autonomous run, ~17 commits, 30 swift + 18 py tests green)

This file is the single source of truth for what's done, what's next, and the
exact commands to verify state before resuming. Read it top-to-bottom in a fresh
context and you have everything you need.

---

## State of the repo

```
git log --oneline (most recent first):
7e96728 docs: refresh README modules + status, regenerate directory-tree
1a9b5d6 feat(components): add TsumikiPaywall + value types (Feature, Price)
14a6eea feat(components): add TsumikiButton with full Style/Size/Shape/Layout matrix
31ee501 feat(components): add TsumikiCard generic container primitive
1dfe87b feat(theme,components): add colors.scrim token and TsumikiDialog
d03ee4a feat(components): add TsumikiLoading + TsumikiSkeleton + .tsumikiShimmer()
530ebd4 feat(components): add TsumikiSettingsRow with Trailing enum subsuming 5 variants
e1d29b7 feat(components): add TsumikiSplash with reduce-motion-safe entry animation
a64681a docs(plans): add Plan B for P2 component port wave
350fef6 docs(research): persist 5 mapper digests + 7 arbiter API specs
c308912 chore: add CI, .claude orchestrator+subagents, docs, README, directory-tree
ac78fe8 feat(theme,components): add TsumikiTheme + reference TsumikiToast
1c0da44 fix(scripts): swift_lex include internal visibility (was public-only)
e172bf7 feat(scripts): add scanner pipeline + lint with TDD coverage
57d8dbb feat: initialize Tsumiki SwiftPM package with five modular targets
f40c357 docs: refine spec with mermaids and self-review fixes
ad2ed4f docs: add Tsumiki MVP design spec
```

Branch: `master`. Untracked but pre-existing (not touched by Tsumiki work):
`tsumiki.xcodeproj/`, `tsumiki/tsumiki.swift`, `tsumikiTests/tsumikiTests.swift`.
These are Carlos's earlier Xcode skeleton — leave them alone unless asked.

## Verify state in a fresh session

```bash
# All four MUST pass before adding anything new.
/usr/bin/swift build                                                    # iOS 17 + macOS 14, all 5 targets
/usr/bin/swift test                                                     # 30 tests green
python3 -m unittest discover scripts/tests                              # 18 tests green
python3 -m scripts.lint_no_hardcoded Sources/TsumikiComponents          # exit 0
```

**Toolchain gotcha:** `which swift` resolves to `/Users/carlos/.swiftly/bin/swift`
(Swift 6.1, incompatible with macOS 26 SDK). Always use `/usr/bin/swift`
(Xcode 6.2 toolchain). Same applies to whatever runs in CI.

## What's done

### P0 — Scanner pipeline ✅
- `scripts/scan_project.py`, `scripts/diff_overlaps.py`,
  `scripts/classify_components.py`, `scripts/build_catalog.py`,
  `scripts/lint_no_hardcoded.py`.
- `scripts/lib/`: `swift_lex.py`, `theme_sniff.py`, `classifier.py`.
- 18 unit tests in `scripts/tests/`.
- Manifests for all 5 source projects emitted to `manifests/*.json`
  (gitignored). Re-run with the loop in `manifests/HOWTO` (NOT YET WRITTEN — see follow-up).

### P1 — Package scaffolding + Theme + reference Toast ✅
- 5 modular targets: TsumikiCore, TsumikiTheme, TsumikiComponents, TsumikiAnimations, TsumikiServices.
- TsumikiTheme: 9-slot colours (incl. scrim), typography, spacing, radius, shadow.
- DefaultTheme.light / .dark, `.with(\.kp, value)` override helper.
- TsumikiToast + `.tsumikiToast(isPresented:)` modifier.

### P2 — Component port wave (7 of 9 concepts) ✅
| # | Concept | Files | Tests | Doc |
|---|---|---|---|---|
| 1 | Splash | `Sources/TsumikiComponents/Splash/` | TsumikiSplashTests | `docs/components/Splash.md` |
| 2 | SettingsRow | `Sources/TsumikiComponents/SettingsRow/` | TsumikiSettingsRowTests | `docs/components/SettingsRow.md` |
| 3 | Loading + Skeleton + Shimmer | `Sources/TsumikiComponents/Loading/` | TsumikiLoadingTests | `docs/components/Loading.md` |
| 4 | Dialog (+ scrim token) | `Sources/TsumikiComponents/Dialog/` | TsumikiDialogTests | `docs/components/Dialog.md` |
| 5 | Card | `Sources/TsumikiComponents/Card/` | TsumikiCardTests | `docs/components/Card.md` |
| 6 | Button | `Sources/TsumikiComponents/Button/` | TsumikiButtonTests | `docs/components/Button.md` |
| 7 | Paywall | `Sources/TsumikiComponents/Paywall/` | TsumikiPaywallTests | `docs/components/Paywall.md` |

### Subagent infrastructure ✅
- `.claude/CLAUDE.md` — orchestrator playbook (Vibe vs Subagents modes).
- `.claude/agents/` — 7 subagents (project-mapper, concept-classifier,
  overlap-arbiter, theme-extractor, architect, qa, docs-analyst).
- `.claude/settings.json` — `behavior.caveman_mode` flag.

### Research persistence ✅
- `docs/superpowers/research/mappers/<project>.md` — one digest per source app.
- `docs/superpowers/research/arbiters/<concept>.md` — one API spec per concept
  (Button, CameraScan, Dialog, Loading, Paywall, SettingsRow, Splash). The
  arbiter spec for each concept is the source of truth for the matching port.

### Spec + Plans ✅
- `docs/superpowers/specs/2026-05-11-tsumiki-mvp-design.md` — MVP design with mermaid diagrams (module graph, scanner pipeline, subagent flow).
- `docs/superpowers/plans/2026-05-11-tsumiki-mvp-p0-p1.md` — Plan A (executed).
- `docs/superpowers/plans/2026-05-11-tsumiki-mvp-p2.md` — Plan B (Tasks 1-6 + Card executed; 7 + 9 remain).

---

## What's next (in priority order)

### Immediate: finish Plan B (2 concepts left)

#### Plan B Task 7: TsumikiOpacity + TsumikiScannerReticle

**Spec:** `docs/superpowers/research/arbiters/CameraScan.md`. **Strategy: (c) overlay chrome only.**

Sub-task 7a — extend theme:
- Create `Sources/TsumikiTheme/Tokens/TsumikiOpacity.swift`:
  ```swift
  public struct TsumikiOpacity: Sendable {
      public var scrim: CGFloat       // default 0.5
      public var overlay: CGFloat     // default 0.85
      public var disabled: CGFloat    // default 0.4
      public init(scrim: CGFloat = 0.5, overlay: CGFloat = 0.85, disabled: CGFloat = 0.4)
  }
  ```
- Add `var opacity: TsumikiOpacity { get }` to `TsumikiTheme` protocol.
- Add stored `public var opacity: TsumikiOpacity` to `DefaultTheme` + thread through init.
- Update light/dark to use defaults.
- Update `TsumikiButton` to use `theme.opacity.disabled` instead of inline `0.4` literal (currently uses `theme.opacity_disabled` private extension — replace).
- Tests + commit `feat(theme): add TsumikiOpacity (scrim/overlay/disabled)`.

Sub-task 7b — TsumikiScannerReticle (per arbiter spec):
- `TsumikiScannerReticle<Instructions, Status>` with Shape (square/rectangle/fill), State (idle/scanning/processing/success/error), CornerStyle (brackets/continuous/none).
- Plain-string convenience overload where `Instructions == Text, Status == Text`.
- `TsumikiReticleRectKey: PreferenceKey` exposing the reticle CGRect + a `normalized(in:)` helper for AVFoundation ROI.
- Cutout via `Canvas` + `.destinationOut` (lucidmate's pattern). Don't forget `.compositingGroup()`.
- Theme tokens: accent/success/warning/danger (state-driven stroke), textPrimary, background (scrim base), spacing.md/lg/xl, radius.md, typography.body/caption, opacity.scrim.

#### Plan B Task 9: OnboardingKit

**No arbiter spec written.** Concept has 19 candidates across aquabrew (5) + pulselog (10) + warrantyreminder (2) + zeroblock (2). Spawn an arbiter subagent first (model the call after the 7 already done — see `docs/superpowers/research/arbiters/Button.md` for shape).

Three views to ship in one task:
- `TsumikiOnboardingPage(illustration:title:body:primaryAction:secondaryAction:)`
- `TsumikiOnboardingDots(total:current:accentTint:)`
- `TsumikiOnboardingProgressBar(progress: Double)`

Likely candidate to study first: `aquabrew/Views/Onboarding/OnboardingPageView.swift` (427 LOC — the richest) and `pulselog/Views/Onboarding/OnboardingPageView.swift` (95 LOC — the cleanest). Pulselog is also worth skimming for the Dots and ProgressBar primitives (`OnboardingDotIndicator.swift`, `OnboardingProgressBar.swift`).

### After P2 wraps: draft Plan C

`docs/superpowers/plans/2026-05-11-tsumiki-mvp-p3.md` should cover:

1. `Examples/TsumikiCatalog/` — minimal SwiftUI app browsing every component
   with a theme picker (light/dark/custom). Doubles as a visual smoke test.
2. `TsumikiServices` population:
   - `TsumikiAnalytics` (protocol + no-op default)
   - `TsumikiAdsCoordinator` (protocol + no-op default)
   - `TsumikiPaywallController` (StoreKit 2 + RC adapter, drives `TsumikiPaywall`'s state)
   - `TsumikiNotifications` (protocol + UNUserNotificationCenter default)
3. `warrantyreminder` migration as the first consumer (smallest surface):
   - Add Tsumiki SwiftPM URL.
   - Replace WRDialog → TsumikiDialog, WRToast → TsumikiToast,
     WRSettingsRow → TsumikiSettingsRow, SplashView → TsumikiSplash,
     PaywallView → TsumikiPaywall (plus a controller).
   - Verify no visual regression manually (no snapshot tests in MVP).
   - Write `docs/MIGRATION.md` from the experience.

### Followups noted along the way

- `manifests/HOWTO.md` — write a tiny note on how to re-scan when source apps change. Just a one-liner per project + the aggregator commands.
- Replace `TsumikiButton`'s `theme.opacity_disabled` private extension with `theme.opacity.disabled` once `TsumikiOpacity` lands.
- `TsumikiDialog` header pulse animation (the original AquaBrew/WR icons had pulsing) was deliberately omitted — revisit if/when adding `theme.animations` tokens.
- `colors.skeleton` follow-up (currently `colors.surface` doubles for skeleton fill — invisible on light themes if surface ≈ background).
- L10N strategy: `TsumikiLoading.Cancel`, `TsumikiPaywall.Restore Purchases`, `TsumikiDialogAction.cancel("Cancel")` defaults are all hardcoded English. Pick a strategy framework-wide before localising.
- `TsumikiOnboardingKit` may want a `TsumikiOnboardingContainer` that takes `[TsumikiOnboardingPage]` + handles paging + dots + progress bar in one. Add only if 2+ apps actually compose them all together.

---

## Conventions (read before editing)

- **TDD:** every component port writes failing tests first, runs to confirm fail, then writes the impl. See any of the 7 ported concepts' commit history for the pattern.
- **Theme-aware only:** Components NEVER use raw `Color(...)`, `.padding(16)`, `.cornerRadius(12)`, etc. Lint blocks merge. Only theme tokens.
- **UIKit gating:** Render tests use `UIHostingController` and are gated by `#if canImport(UIKit)` so they skip on macOS host. They WILL run on iOS sim via `xcodebuild`.
- **Public API rules:** `public` everywhere on exported surface. No `@_spi`. No internal singletons.
- **Commit messages:** Conventional Commits (`feat(...)`, `fix(...)`, `docs(...)`, `chore(...)`). Include `Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>` trailer.
- **No batching:** one concept per commit. Lints + tests run before each commit.
- **Subagents are read-only.** Only the orchestrator and `subagent-docs-analyst` write files. If you spawn a new subagent, give it the path to manifests/research, NEVER the source-project Swift files (saves context).

---

## Caveman mode

Active during the run that produced this state. Re-enable for a continuation
session by setting `.claude/settings.json` `behavior.caveman_mode = true` (the
orchestrator reads this once per session). Off by default.

---

## If something's broken

- **`swift test` fails with "could not build module 'CoreFoundation'":** wrong toolchain. Use `/usr/bin/swift`.
- **`xcodebuild` complains about "scheme Tsumiki-Package":** the pre-existing `tsumiki.xcodeproj` shadows package detection. Either delete the .xcodeproj (only if Carlos OKs it — it predates Tsumiki) or just use `/usr/bin/swift test` for everything.
- **Lint flags a literal in `DefaultTheme.swift`:** scope is wrong. Lint should only target `Sources/TsumikiComponents`. Theme legitimately uses `Color.black.opacity(...)` etc.
- **A test references `theme.opacity.disabled` and fails:** TsumikiOpacity isn't shipped yet — Plan B Task 7 sub-task 7a does it. Until then, `TsumikiButton` uses a private extension fallback (`theme.opacity_disabled` returning 0.4).
