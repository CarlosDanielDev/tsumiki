# Tsumiki MVP — Plan B: P2 Component Port Wave

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development or superpowers:executing-plans. Steps use `- [ ]` checkboxes.

**Goal:** Port 9 remaining MVP concepts (Toast already shipped in Plan A) into `TsumikiComponents` and `TsumikiTheme` (where new tokens are needed), one concept per task. Each port is TDD: tests first, impl second, lint, commit.

**Architecture:** Per-concept Swift files under `Sources/TsumikiComponents/<Concept>/`. All components read theme via `@Environment(\.tsumikiTheme)`. Zero hardcoded `Color` / spacing / radius literals (lint-enforced).

**Source of truth for each concept's API:** `docs/superpowers/research/arbiters/<Concept>.md` (read FIRST before each task).

**Tech Stack:** Swift 5.9+, SwiftUI, iOS 17 (macOS 14 for `swift test`), XCTest.

**Toolchain note:** use `/usr/bin/swift` (Xcode 6.2). `which swift` resolves to swiftly 6.1 which is incompatible with macOS 26 SDK.

---

## Pre-flight (do once before Task 1)

- [ ] Read `docs/superpowers/research/arbiters/Splash.md` (smallest concept, gentle warm-up).
- [ ] Re-run `/usr/bin/swift test` to confirm baseline 11 tests pass.
- [ ] Re-run `python3 -m unittest discover scripts/tests` to confirm 18 tests pass.
- [ ] Re-run `python3 -m scripts.lint_no_hardcoded Sources/TsumikiComponents` (exit 0).

---

## Concept order (lowest → highest complexity)

1. Splash — pure view, no extra tokens.
2. SettingsRow — value-types only, well-bounded.
3. Loading + Skeleton + Shimmer (one task — small triple).
4. Dialog — needs new `colors.scrim` token first.
5. Button — large API surface, no exotic deps.
6. Paywall — value types + view; no controller (controller is Plan C / TsumikiServices).
7. CameraScan / Reticle — adds new `TsumikiOpacity` token + PreferenceKey, biggest standalone.
8. Card (generic container) — primitive only; 57 source cards stay app-side composing Tsumiki primitives.
9. OnboardingPage / OnboardingDots / OnboardingProgressBar (one task — kit).

---

## Task 1: TsumikiSplash

**Spec:** `docs/superpowers/research/arbiters/Splash.md`.

**Files:**
- Create `Sources/TsumikiComponents/Splash/TsumikiSplash.swift`
- Create `Sources/TsumikiComponents/Splash/TsumikiSplashModifier.swift`
- Create `Tests/TsumikiComponentsTests/TsumikiSplashTests.swift`
- Create `docs/components/Splash.md`

- [ ] **Step 1: Write failing test `Tests/TsumikiComponentsTests/TsumikiSplashTests.swift`**

```swift
import XCTest
import SwiftUI
@testable import TsumikiComponents
import TsumikiTheme

#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class TsumikiSplashTests: XCTestCase {
    func testInitDefaults() {
        let s = TsumikiSplash(logo: Image(systemName: "leaf"), onComplete: {})
        XCTAssertNil(s.title)
        XCTAssertNil(s.tagline)
        XCTAssertEqual(s.duration, 2.0)
        XCTAssertEqual(s.logoSize, 120)
    }

    func testInitFull() {
        let s = TsumikiSplash(
            logo: Image(systemName: "leaf"),
            title: "Tsumiki",
            tagline: "Plug and play",
            duration: 3.5,
            logoSize: 96,
            onComplete: {}
        )
        XCTAssertEqual(s.title, "Tsumiki")
        XCTAssertEqual(s.tagline, "Plug and play")
        XCTAssertEqual(s.duration, 3.5)
        XCTAssertEqual(s.logoSize, 96)
    }

    #if canImport(UIKit)
    func testRendersWithoutCrash() {
        let s = TsumikiSplash(logo: Image(systemName: "leaf"), onComplete: {})
            .tsumikiTheme(DefaultTheme.light)
        let host = UIHostingController(rootView: s)
        host.view.layoutIfNeeded()
        XCTAssertNotNil(host.view)
    }
    #endif
}
```

- [ ] **Step 2: Run test to verify it fails** — `/usr/bin/swift test --filter TsumikiSplashTests`. Expected: build error (TsumikiSplash undefined).
- [ ] **Step 3: Write `Sources/TsumikiComponents/Splash/TsumikiSplash.swift`** — full impl per arbiter Splash.md "Proposed Tsumiki API" section. Use `Task.sleep` over `DispatchQueue.main.asyncAfter` (idiomatic iOS 17). Gate completion via `@State hasCompleted` to prevent double-fire.
- [ ] **Step 4: Write `Sources/TsumikiComponents/Splash/TsumikiSplashModifier.swift`** — `.tsumikiSplash(isPresented:logo:title:tagline:duration:)` per spec.
- [ ] **Step 5: Run tests** — expected pass.
- [ ] **Step 6: Lint** — `python3 -m scripts.lint_no_hardcoded Sources/TsumikiComponents` exit 0.
- [ ] **Step 7: Write `docs/components/Splash.md`** — same shape as `docs/components/Toast.md` (API, example, theme tokens consumed, notes).
- [ ] **Step 8: Commit** — `git add Sources/TsumikiComponents/Splash Tests/TsumikiComponentsTests/TsumikiSplashTests.swift docs/components/Splash.md && git commit -m "feat(components): add TsumikiSplash"`

---

## Task 2: TsumikiSettingsRow

**Spec:** `docs/superpowers/research/arbiters/SettingsRow.md`.

**Files:**
- Create `Sources/TsumikiComponents/SettingsRow/TsumikiSettingsRow.swift`
- Create `Tests/TsumikiComponentsTests/TsumikiSettingsRowTests.swift`
- Create `docs/components/SettingsRow.md`

- [ ] **Step 1: Write tests** — assert each `Trailing` case constructs (chevron/link/toggle/value/none). Render-without-crash for each. Bonus: `.tsumikiSettingsRow.value(_, tone:)` defaults to `.secondary`.
- [ ] **Step 2: Verify fail.**
- [ ] **Step 3: Write impl** per arbiter spec. Body switches on `trailing` to wrap in `Button`/`Link`/plain. `iconTile` is fixed 28x28 (intentional v1 constant).
- [ ] **Step 4: Run tests, lint, commit.**

---

## Task 3: TsumikiLoading + TsumikiSkeleton + .tsumikiShimmer()

**Spec:** `docs/superpowers/research/arbiters/Loading.md`.

**Files:**
- Create `Sources/TsumikiComponents/Loading/TsumikiLoading.swift`
- Create `Sources/TsumikiComponents/Loading/TsumikiSkeleton.swift`
- Create `Sources/TsumikiComponents/Loading/TsumikiShimmerModifier.swift`
- Create `Tests/TsumikiComponentsTests/TsumikiLoadingTests.swift`
- Create `docs/components/Loading.md`

- [ ] **Step 1: Write tests** — TsumikiLoading inits (compact/regular/large + onCancel optional). TsumikiSkeleton inits (.rectangle/.circle/.capsule). Shimmer modifier composes on Color view.
- [ ] **Step 2: Verify fail.**
- [ ] **Step 3: Write impls** per arbiter spec. Honour `accessibilityReduceMotion` in shimmer (skip animation, optionally hide overlay).
- [ ] **Step 4: Run tests, lint, commit.**

---

## Task 4: Add `colors.scrim` theme token, then TsumikiDialog

**Spec:** `docs/superpowers/research/arbiters/Dialog.md`.

**Sub-task 4a — extend `TsumikiColors`:**

- [ ] **Step 1:** Add `public var scrim: Color` field to `TsumikiColors` (init param, default `.black.opacity(0.4)` recommendation per arbiter).
- [ ] **Step 2:** Update `DefaultTheme.light` and `.dark` to set `scrim: .black.opacity(0.4)` and `.black.opacity(0.6)` respectively.
- [ ] **Step 3:** Update `TsumikiThemeTokenTests.testColorsExposesEightSemanticSlots` → rename to `Nine`, add scrim assertion.
- [ ] **Step 4:** `swift test --filter TsumikiThemeTokenTests` passes; commit `feat(theme): add colors.scrim for dialog/overlay backdrops`.

**Sub-task 4b — TsumikiDialog:**

**Files:**
- Create `Sources/TsumikiComponents/Dialog/TsumikiDialog.swift`
- Create `Sources/TsumikiComponents/Dialog/TsumikiDialogAction.swift` (separate file: `Action` struct + helpers)
- Create `Sources/TsumikiComponents/Dialog/TsumikiDialogModifier.swift`
- Create `Tests/TsumikiComponentsTests/TsumikiDialogTests.swift`
- Create `docs/components/Dialog.md`

- [ ] **Step 1: Write tests** — Action.primary/secondary/destructive/cancel constructors return expected styles. Dialog inits with EmptyView content. Tap-outside dismisses ONLY when `.cancel` action present AND `kind != .destructive`.
- [ ] **Step 2: Verify fail.**
- [ ] **Step 3: Write impls** per arbiter spec. Respect `accessibilityReduceMotion` for header pulse animation.
- [ ] **Step 4: Run tests, lint, commit.**

---

## Task 5: TsumikiButton

**Spec:** `docs/superpowers/research/arbiters/Button.md`.

**Files:**
- Create `Sources/TsumikiComponents/Button/TsumikiButton.swift`
- Create `Sources/TsumikiComponents/Button/TsumikiButtonStyles.swift` (Style/Size/Shape/LabelLayout enums + token mapping helpers)
- Create `Tests/TsumikiComponentsTests/TsumikiButtonTests.swift`
- Create `docs/components/Button.md`

- [ ] **Step 1: Write tests** — every Style enum value renders without crash (use UIHostingController + DefaultTheme.light). isLoading swaps to ProgressView. badge overlays. shape == .circle uses square frame.
- [ ] **Step 2: Verify fail.**
- [ ] **Step 3: Write impls.** Use `.sensoryFeedback(.impact, trigger:)` for haptics (iOS 17+). Disabled state via system `.disabled()` + reduced opacity from `colors.surface`.
- [ ] **Step 4: Run tests, lint, commit.**

---

## Task 6: TsumikiPaywall

**Spec:** `docs/superpowers/research/arbiters/Paywall.md`.

**Files:**
- Create `Sources/TsumikiComponents/Paywall/TsumikiPaywallFeature.swift` (value type + Identifiable conformance)
- Create `Sources/TsumikiComponents/Paywall/TsumikiPaywallPrice.swift` (value type, Equatable)
- Create `Sources/TsumikiComponents/Paywall/TsumikiPaywall.swift` (the View)
- Create `Tests/TsumikiComponentsTests/TsumikiPaywallTests.swift`
- Create `docs/components/Paywall.md`

- [ ] **Step 1: Write tests** — value types init + equality. View renders with 0, 1, 5 features. `isPurchasing` swaps CTA to ProgressView. `onDismiss` nil hides X button.
- [ ] **Step 2: Verify fail.**
- [ ] **Step 3: Write impls.** No StoreKit/RevenueCat dependencies. Pure value-driven view.
- [ ] **Step 4: Run tests, lint, commit.**

---

## Task 7: Add `TsumikiOpacity` token + TsumikiScannerReticle

**Spec:** `docs/superpowers/research/arbiters/CameraScan.md`.

**Sub-task 7a — extend theme with TsumikiOpacity:**

- [ ] **Step 1:** Create `Sources/TsumikiTheme/Tokens/TsumikiOpacity.swift` — `public struct TsumikiOpacity { public var scrim: CGFloat (default 0.5); public var overlay: CGFloat (default 0.85); public var disabled: CGFloat (default 0.4); public init(scrim:,overlay:,disabled:) }`.
- [ ] **Step 2:** Add `var opacity: TsumikiOpacity { get }` to `TsumikiTheme` protocol.
- [ ] **Step 3:** Add `public var opacity: TsumikiOpacity` to `DefaultTheme`. Both light/dark use defaults.
- [ ] **Step 4:** Update `TsumikiThemeTokenTests` with opacity assertion. Update `DefaultThemeTests`.
- [ ] **Step 5:** Run tests; commit `feat(theme): add TsumikiOpacity (scrim/overlay/disabled)`.

**Sub-task 7b — TsumikiScannerReticle:**

**Files:**
- Create `Sources/TsumikiComponents/Scanner/TsumikiScannerReticle.swift`
- Create `Sources/TsumikiComponents/Scanner/TsumikiReticleRectKey.swift` (PreferenceKey + `normalized(in:)` helper)
- Create `Tests/TsumikiComponentsTests/TsumikiScannerReticleTests.swift`
- Create `docs/components/ScannerReticle.md`

- [ ] **Step 1: Write tests** — Shape/State/CornerStyle enums init. Reticle renders for each shape variant. `normalized(in:)` returns expected CGRect for known input.
- [ ] **Step 2: Verify fail.**
- [ ] **Step 3: Write impls** per arbiter spec. Use `Canvas` + `.destinationOut` (lucidmate's pattern) for cutout. `.compositingGroup()` to keep alpha math sound.
- [ ] **Step 4: Run tests, lint, commit.**

---

## Task 8: TsumikiCard (generic container only)

**No arbiter spec — Card has 57 source candidates, all domain-bound. Tsumiki provides ONLY the primitive container; source cards stay in apps composing the primitive.**

**Files:**
- Create `Sources/TsumikiComponents/Card/TsumikiCard.swift`
- Create `Tests/TsumikiComponentsTests/TsumikiCardTests.swift`
- Create `docs/components/Card.md`

**API sketch** (orchestrator finalises):

```swift
public struct TsumikiCard<Content: View>: View {
    public enum Padding: Sendable { case none, compact, regular, generous }
    public enum Elevation: Sendable { case flat, soft, elevated }

    public init(padding: Padding = .regular,
                elevation: Elevation = .soft,
                @ViewBuilder content: () -> Content)
}
```

- [ ] **Step 1:** Write tests for each Padding/Elevation case. Render-without-crash with arbitrary content.
- [ ] **Step 2:** Verify fail.
- [ ] **Step 3:** Impl reads `colors.surface` (background), `radius.md` (corners), `shadow.soft`/`shadow.elevated` for elevation.
- [ ] **Step 4:** Run tests, lint.
- [ ] **Step 5:** Write `docs/components/Card.md` — explicitly note: this is a primitive; source-app cards (BoostShopCard, CalendarDayCard, etc.) compose `TsumikiCard { ... }`. No automatic migration.
- [ ] **Step 6:** Commit.

---

## Task 9: OnboardingKit (TsumikiOnboardingPage + Dots + ProgressBar)

**Files:**
- Create `Sources/TsumikiComponents/Onboarding/TsumikiOnboardingPage.swift`
- Create `Sources/TsumikiComponents/Onboarding/TsumikiOnboardingDots.swift`
- Create `Sources/TsumikiComponents/Onboarding/TsumikiOnboardingProgressBar.swift`
- Create `Tests/TsumikiComponentsTests/TsumikiOnboardingTests.swift`
- Create `docs/components/Onboarding.md`

**API sketch** (orchestrator finalises after consulting `aquabrew/Views/Onboarding/OnboardingPageView.swift` and `pulselog/Views/Onboarding/OnboardingPageView.swift`):

```swift
public struct TsumikiOnboardingPage: View {
    public init(
        illustration: Image,
        title: String,
        body: String,
        primaryAction: (label: String, action: () -> Void),
        secondaryAction: (label: String, action: () -> Void)? = nil
    )
}

public struct TsumikiOnboardingDots: View {
    public init(total: Int, current: Int, accentTint: Color? = nil)
}

public struct TsumikiOnboardingProgressBar: View {
    public init(progress: Double)  // 0...1
}
```

- [ ] **Step 1:** Read `aquabrew` and `pulselog` `OnboardingPageView.swift` to confirm API shape.
- [ ] **Step 2:** Write tests for all three views.
- [ ] **Step 3:** Verify fail.
- [ ] **Step 4:** Implement.
- [ ] **Step 5:** Run tests, lint, commit.

---

## End-of-plan verification

- [ ] `/usr/bin/swift test` — all tests across all modules pass.
- [ ] `python3 -m unittest discover scripts/tests` — 18 tests still pass (unchanged).
- [ ] `python3 -m scripts.lint_no_hardcoded Sources/TsumikiComponents` — exit 0.
- [ ] `python3 -m scripts.lint_no_hardcoded Sources/TsumikiTheme` — exit 0 (Theme can have raw Colors; lint scope is Components-only by design — this command should EXPECT violations on `DefaultTheme.swift` but is NOT required to pass; it's a sanity check that lint covers the right scope).
- [ ] Update `directory-tree.md`: `{ echo '# Tsumiki directory tree'; echo; echo '\`\`\`'; find Sources Tests scripts docs .claude .github -type f | sort; echo '\`\`\`'; } > directory-tree.md`.
- [ ] Update `README.md` Modules section to list newly available components.
- [ ] Final commit: `chore: refresh directory-tree and README after Plan B`.

---

## Notes for the executor

- **Trust the arbiter specs.** They were written by reading the actual Swift files. If you find a discrepancy between an arbiter spec and the source, prefer the arbiter (it's the API for Tsumiki, not a recap of source).
- **Skip a concept if its arbiter spec opens with "all 3 candidates were RC wrappers"** style caveat — for Paywall, that means the API is invented, so verify with the user before locking the public surface.
- **macOS host limitation:** UIHostingController-based render tests are gated by `#if canImport(UIKit)` and skip on macOS. They WILL run on iOS sim via `xcodebuild`. Don't try to "fix" them on macOS.
- **Lint pre-existing files:** `DefaultTheme.swift` legitimately uses `Color(white: ...)` and `.black.opacity(...)` literals. Lint scope is `Sources/TsumikiComponents/` only — don't expand it.
