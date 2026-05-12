# NEXT-SESSION.md — Tsumiki resume guide

**Last updated:** 2026-05-12 17:15 (P2 component wave complete, 51 swift + 18 py tests green; Plan C drafted for P3)

> **Active milestone driver:** [`docs/superpowers/plans/2026-05-12-tsumiki-mvp-p3.md`](docs/superpowers/plans/2026-05-12-tsumiki-mvp-p3.md) — Plan C covers v0.1.0 → v0.3.0 (TsumikiTextField port, TsumikiCatalog example app, TsumikiServices population, warrantyreminder migration).

This file is the single source of truth for what's done, what's next, and the
exact commands to verify state before resuming. Read it top-to-bottom in a fresh
context and you have everything you need.

---

## State of the repo

```
git log --oneline (most recent first):
6a7479e feat(components): add TsumikiOnboardingKit (page + dots + progress bar)
4612dc0 feat(components): add TsumikiScannerReticle (overlay chrome)
fe22176 feat(theme): add TsumikiOpacity (scrim/overlay/disabled)
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
`tsumiki.xcodeproj/`. That's Carlos's earlier Xcode skeleton — leave it alone
unless asked.

## Verify state in a fresh session

```bash
# All four MUST pass before adding anything new.
/usr/bin/swift build                                                    # iOS 17 + macOS 14, all 5 targets
/usr/bin/swift test                                                     # 51 tests green
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
- TsumikiTheme tokens: 9-slot colours (incl. scrim), typography, spacing,
  radius, shadow, **opacity** (scrim / overlay / disabled).
- DefaultTheme.light / .dark, `.with(\.kp, value)` override helper.
- TsumikiToast + `.tsumikiToast(isPresented:)` modifier.

### P2 — Component port wave (9 of 9 concepts) ✅
| # | Concept | Files | Tests | Doc |
|---|---|---|---|---|
| 1 | Splash | `Sources/TsumikiComponents/Splash/` | TsumikiSplashTests | `docs/components/Splash.md` |
| 2 | SettingsRow | `Sources/TsumikiComponents/SettingsRow/` | TsumikiSettingsRowTests | `docs/components/SettingsRow.md` |
| 3 | Loading + Skeleton + Shimmer | `Sources/TsumikiComponents/Loading/` | TsumikiLoadingTests | `docs/components/Loading.md` |
| 4 | Dialog (+ scrim token) | `Sources/TsumikiComponents/Dialog/` | TsumikiDialogTests | `docs/components/Dialog.md` |
| 5 | Card | `Sources/TsumikiComponents/Card/` | TsumikiCardTests | `docs/components/Card.md` |
| 6 | Button | `Sources/TsumikiComponents/Button/` | TsumikiButtonTests | `docs/components/Button.md` |
| 7 | Paywall | `Sources/TsumikiComponents/Paywall/` | TsumikiPaywallTests | `docs/components/Paywall.md` |
| 8 | ScannerReticle (+ opacity token) | `Sources/TsumikiComponents/Scanner/` | TsumikiScannerReticleTests | `docs/components/ScannerReticle.md` |
| 9 | OnboardingKit (Page + Dots + ProgressBar) | `Sources/TsumikiComponents/Onboarding/` | TsumikiOnboardingTests | `docs/components/Onboarding.md` |

### Subagent infrastructure ✅
- `.claude/CLAUDE.md` — orchestrator playbook (Vibe vs Subagents modes).
- `.claude/agents/` — 7 subagents (project-mapper, concept-classifier,
  overlap-arbiter, theme-extractor, architect, qa, docs-analyst).
- `.claude/settings.json` — `behavior.caveman_mode` flag.

### Research persistence ✅
- `docs/superpowers/research/mappers/<project>.md` — one digest per source app.
- `docs/superpowers/research/arbiters/<concept>.md` — one API spec per concept
  (Button, CameraScan, Dialog, Loading, Onboarding, Paywall, SettingsRow,
  Splash). The arbiter spec for each concept is the source of truth for the
  matching port.

### Spec + Plans ✅
- `docs/superpowers/specs/2026-05-11-tsumiki-mvp-design.md` — MVP design with mermaid diagrams (module graph, scanner pipeline, subagent flow).
- `docs/superpowers/plans/2026-05-11-tsumiki-mvp-p0-p1.md` — Plan A (executed).
- `docs/superpowers/plans/2026-05-11-tsumiki-mvp-p2.md` — Plan B (executed in full: Tasks 1-9 + Card all shipped).
- `docs/superpowers/plans/2026-05-12-tsumiki-mvp-p3.md` — Plan C (drafted, **active milestone driver**: TextField + Catalog + Services + WR migration).

---

## What's next (in priority order)

### Plan C — Catalog app, services population, first migration

**Drafted:** `docs/superpowers/plans/2026-05-12-tsumiki-mvp-p3.md`. Execute next.

Plan C splits the work into four releasable tags:

| Tag | Phase | Scope |
|---|---|---|
| **v0.1.0** | Phase 0 | TsumikiTextField port (arbiter spec → TDD port). Carry-over from P2. |
| **v0.2.0** | Phase 1 + 2 | `Examples/TsumikiCatalog` example app + TsumikiServices protocol surfaces (Analytics, Ads, Notifications, PaywallController) with no-op defaults. |
| **v0.2.1** | Phase 2.5 | StoreKit 2 implementation of `TsumikiPaywallController` behind the protocol. |
| **v0.3.0** | Phase 3 | `warrantyreminder` migration (8 concept swaps, manual visual diff) + `docs/MIGRATION.md`. |

Read the plan top-to-bottom before starting; it includes per-phase blockers, acceptance criteria, and a recommended migration order for WR.

### Followups noted along the way (small, can land anytime)

- **`manifests/HOWTO.md`** — write a tiny note on how to re-scan when source
  apps change. Just a one-liner per project + the aggregator commands.
- **`TsumikiDialog` header pulse animation** (the original AquaBrew/WR icons
  had pulsing) was deliberately omitted — revisit if/when adding
  `theme.animations` tokens.
- **`colors.skeleton`** follow-up (currently `colors.surface` doubles for
  skeleton fill — invisible on light themes if surface ≈ background).
- **L10N strategy** — `TsumikiLoading.Cancel`, `TsumikiPaywall.Restore
  Purchases`, `TsumikiDialogAction.cancel("Cancel")`, and the onboarding
  CTAs are all hardcoded English. Pick a framework-wide strategy
  (`LocalizedStringKey` initializers vs Bundle lookup) before localising.
- **`TsumikiOnboardingContainer`** — only worth adding if 2+ apps actually
  compose Page + Dots + ProgressBar identically. Defer until measured.
- **`TsumikiScannerReticle` glow ring** — aquabrew-only decoration was
  omitted. If design pushes back, add `glow: Bool = false` flag in v2
  rather than re-architecting.
- **`TsumikiPage` reduce-motion test coverage** — only the page entrance
  is reduce-motion-gated; the `accessibilityReduceMotion` toggle path is
  not currently asserted.

---

## Conventions (read before editing)

- **TDD:** every component port writes failing tests first, runs to confirm fail, then writes the impl. See any of the 9 ported concepts' commit history for the pattern.
- **Theme-aware only:** Components NEVER use raw `Color(...)`, `.padding(16)`, `.cornerRadius(12)`, etc. Lint blocks merge. Only theme tokens.
- **UIKit gating:** Render tests use `UIHostingController` and are gated by `#if canImport(UIKit)` so they skip on macOS host. They WILL run on iOS sim via `xcodebuild`.
- **Public API rules:** `public` everywhere on exported surface. No `@_spi`. No internal singletons.
- **Commit messages:** Conventional Commits (`feat(...)`, `fix(...)`, `docs(...)`, `chore(...)`, `refactor(...)`, `test(...)`). **NEVER** add `Co-Authored-By: Claude …` or `🤖 Generated with Claude Code` trailers — commits and PRs are authored as the human user only. AI assistance is a tool, not a co-author.
- **No batching:** one concept per commit. Lints + tests run before each commit.
- **Subagents are read-only.** Only the orchestrator and `subagent-docs-analyst` write files. If you spawn a new subagent, give it the path to manifests/research, NEVER the source-project Swift files (saves context). Exception: `subagent-overlap-arbiter` has a Read tool and CAN read the candidate Swift paths listed in `manifests/_overlaps.json`.

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
- **A test references `theme.opacity.disabled` and fails:** Fine — `TsumikiOpacity` is shipped. If a test still uses the old `theme.opacity_disabled` private extension, that extension was removed in `fe22176` — update the test to use `theme.opacity.disabled`.
