# Arbiter: Onboarding

## Strategy
Ship three composable visual primitives — `TsumikiOnboardingPage`,
`TsumikiOnboardingDots`, `TsumikiOnboardingProgressBar` — that render a
single onboarding slide (illustration + text + CTAs) and the two progress
chrome elements. Container, paging, persistence, and side-effects stay in
apps.

## Why
- All five apps render the same conceptual slide: hero illustration (SF
  Symbol or vector), accent-tinted subtitle, large title, body copy, and one
  or two CTAs. Everything *outside* that is divergent state machinery that
  doesn't belong in a design system.
- AquaBrew's 427-LOC `OnboardingPageView` packs three orthogonal concerns:
  (a) slide content, (b) a per-step `BackgroundElements` enum with
  waves/bubbles/gradient decorations, (c) bobbing parallax. (b) and (c) are
  aquabrew-specific aquatic motif — explicitly out of scope.
- PulseLog's 95-LOC slide is the cleanest shape: VStack of icon → subtitle
  → title → description with staggered fade/offset entrance. WR's variant
  adds a hard-coded "notification hint" on the last page — that is
  app-coordination state, not chrome.
- WR + PulseLog both wrap the hero in two concentric tinted circles;
  aquabrew adds a third "glow ring". Two-circle pattern is the genuinely
  shared visual; the glow ring is decoration.
- Dots: pulselog `OnboardingDotIndicator` (31 LOC) and aquabrew
  `OnboardingDotsProgress` (39 LOC) are near-identical: `HStack`,
  current dot filled, prior dots accent @ 50%, future dots outlined,
  spring on change. PulseLog adds tap-to-jump + a11y traits which is
  strictly better — bring those forward.
- Progress bar: pulselog (36 LOC) and aquabrew (93 LOC) agree on capsule
  track + gradient fill + glow dot at the tip. AquaBrew's
  `animatedProgress` `@State` is redundant — the consumer already owns
  `progress` and SwiftUI implicit animation handles tween.
- CTAs: pulselog ships them in a sibling `OnboardingBottomBar`; aquabrew
  puts them in the container. Apps disagree on chrome (primary-only vs
  primary + secondary). Modelling primary + optional secondary covers all
  five.
- Entrance grammar across apps converges on `spring(response: 0.5,
  dampingFraction: 0.8)` staggered ~0.10 / 0.15 / 0.10s. Hardcode it.
  Respect `accessibilityReduceMotion`.

## Proposed Tsumiki API

```swift
import SwiftUI

// MARK: - Slide

public struct TsumikiOnboardingAction: Sendable {
    public let title: String
    public let action: @MainActor () -> Void
    public init(title: String, action: @escaping @MainActor () -> Void)
}

public struct TsumikiOnboardingPage<Illustration: View>: View {
    public init(
        @ViewBuilder illustration: () -> Illustration,
        title: String,
        body: String,
        subtitle: String? = nil,
        accentTint: Color? = nil,                       // nil -> theme.colors.accent
        primaryAction: TsumikiOnboardingAction,
        secondaryAction: TsumikiOnboardingAction? = nil,
        isActive: Bool = true                           // drives entrance animation
    )
}

// Convenience: SF Symbol illustration (covers 4/5 apps).
public extension TsumikiOnboardingPage where Illustration == TsumikiOnboardingSymbolIllustration {
    init(
        systemImage: String,
        title: String,
        body: String,
        subtitle: String? = nil,
        accentTint: Color? = nil,
        primaryAction: TsumikiOnboardingAction,
        secondaryAction: TsumikiOnboardingAction? = nil,
        isActive: Bool = true
    )
}

public struct TsumikiOnboardingSymbolIllustration: View {
    public init(systemImage: String, tint: Color? = nil)
}

// MARK: - Dots

public struct TsumikiOnboardingDots: View {
    public init(
        total: Int,
        current: Int,
        accentTint: Color? = nil,
        onSelect: ((Int) -> Void)? = nil
    )
}

// MARK: - Progress bar

public struct TsumikiOnboardingProgressBar: View {
    public init(
        progress: Double,                               // clamped 0...1
        accentTint: Color? = nil,
        showsTipGlow: Bool = true
    )
}
```

### Behavior contracts

- `TsumikiOnboardingPage`:
  - Layout: `Spacer` → illustration → `subtitle` (accent, headline) → `title`
    (largeTitle, textPrimary) → `body` (body font, textSecondary, centered)
    → `Spacer` → primary button (filled, full-width) → secondary button
    (text-only, accent).
  - `TsumikiOnboardingSymbolIllustration`: two concentric circles (tint @
    12 % then 20 % opacity) with an SF Symbol at hierarchical rendering.
  - Entrance: icon (0.10 s) → subtitle (0.15 s) → title (0.25 s) → body
    (0.35 s). Skip the stagger when `accessibilityReduceMotion` is on.
  - Combined accessibility element with label
    `"<subtitle>. <title>. <body>"`.
- `TsumikiOnboardingDots`:
  - Current dot ≈ 10 pt filled accent. Past ≈ 7 pt accent @ 50 %. Future
    ≈ 7 pt outlined with `accent.opacity(0.25)`.
  - `spring(response: 0.35, dampingFraction: 0.7)` on `current` change.
  - 44 × 44 hit target when `onSelect != nil`; otherwise
    `accessibilityHidden(true)`.
- `TsumikiOnboardingProgressBar`:
  - 4 pt capsule, track = `accent.opacity(0.2)`, fill = linear gradient
    `accent @ 80 %` → `accent`, optional tip glow 8 pt circle.
  - `min(max(progress, 0), 1)`. `accessibilityHidden(true)`.

## Theme tokens consumed

`TsumikiOnboardingPage`:
- `colors.accent`, `colors.textPrimary`, `colors.textSecondary`,
  `colors.background`
- `spacing.sm`, `spacing.md`, `spacing.lg`, `spacing.xl`
- `radius.lg` (button)
- `typography.largeTitle` (title), `typography.headline` (subtitle),
  `typography.body`

`TsumikiOnboardingDots`:
- `colors.accent`
- `spacing.sm` (dot gap)

`TsumikiOnboardingProgressBar`:
- `colors.accent`
- `radius.pill` (capsule)

## What stays in apps
- `TabView(selection:)` / paging, swipe gestures, page-index `@State`,
  dismissal, has-completed persistence to `UserDefaults` / SwiftData.
- Per-step model arrays (`OnboardingStep`, `OnboardingPage`) and any
  step-specific side effects (e.g. requesting notification authorization
  on the last page — WR).
- Background decoration motifs: aquabrew waves/bubbles, pulselog purple
  gradient, zeroblock checklist demos. Apps wrap `TsumikiOnboardingPage`
  in their own `ZStack` with a decorative background underneath.
- Coordinator analytics (`onboarding_step_viewed`, `onboarding_completed`).
- Skip routing decisions; the secondary action closure is the only
  contract.
- Localization: callers pass already-localized strings.

## Risks / open questions
- `LocalizedStringKey` overloads: brief uses `String`; consider adding
  `LocalizedStringKey` initializers in a follow-up — same pattern flagged
  on `Splash`.
- `accentTint` parameter intentionally overrides theme accent per-slide
  (pulselog/aquabrew vary tint per step to signal section). Confirmed this
  doesn't violate the "theme is the only source of color" rule — the param
  is opt-in and defaults to `theme.colors.accent`.
- Custom illustrations: the generic `Illustration` `@ViewBuilder` covers
  Lottie / vector / image cases without dragging assets into Tsumiki.
- Reduce-motion: skipping the staggered entrance is enough; consumers that
  animate the slide *transition* (TabView swipe) are unaffected.
- Dots `onSelect` is optional to keep parity with aquabrew's
  non-interactive variant; a11y traits stay either way.
- No glow / breathing ring on the hero (aquabrew-only). If design pushes
  back, add `glow: Bool = false` in v2 rather than re-architecting.
