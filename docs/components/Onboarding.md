# TsumikiOnboarding

Three composable primitives — `TsumikiOnboardingPage`,
`TsumikiOnboardingDots`, `TsumikiOnboardingProgressBar` — that render an
onboarding slide and its two progress-chrome elements. **Tsumiki ships the
visuals only.** Container state, paging, gestures, dismissal, persistence,
and side-effects (notification permission prompts, analytics, etc.) stay
in the consuming app, exactly the same shape used by `TsumikiSplash` and
`TsumikiScannerReticle`.

Background and arbiter rationale:
[`docs/superpowers/research/arbiters/Onboarding.md`](../superpowers/research/arbiters/Onboarding.md).

## API

```swift
public struct TsumikiOnboardingAction {
    public init(title: String, action: @escaping () -> Void)
}

public struct TsumikiOnboardingSymbolIllustration: View {
    public init(systemImage: String, tint: Color? = nil)
}

public struct TsumikiOnboardingPage<Illustration: View>: View {
    public init(
        @ViewBuilder illustration: () -> Illustration,
        title: String,
        body: String,
        subtitle: String? = nil,
        accentTint: Color? = nil,
        primaryAction: TsumikiOnboardingAction,
        secondaryAction: TsumikiOnboardingAction? = nil,
        isActive: Bool = true
    )
}

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

public struct TsumikiOnboardingDots: View {
    public init(total: Int,
                current: Int,
                accentTint: Color? = nil,
                onSelect: ((Int) -> Void)? = nil)

    public static func clampedCurrent(_ value: Int, total: Int) -> Int
}

public struct TsumikiOnboardingProgressBar: View {
    public init(progress: Double,
                accentTint: Color? = nil,
                showsTipGlow: Bool = true)

    public static func clampedProgress(_ value: Double) -> Double
}
```

## Example

```swift
struct OnboardingFlow: View {
    @State private var index = 0
    private let pages = [
        Slide(symbol: "drop.fill", subtitle: "Hydration",
              title: "Stay hydrated", body: "Track every glass."),
        Slide(symbol: "bell",       subtitle: "Reminders",
              title: "Never miss a drink", body: "Optional gentle nudges."),
        Slide(symbol: "chart.bar",  subtitle: "Insights",
              title: "Learn your rhythm",  body: "See your weekly patterns.")
    ]

    var body: some View {
        VStack {
            TsumikiOnboardingProgressBar(progress: Double(index + 1) / Double(pages.count))
                .padding(.horizontal)

            TabView(selection: $index) {
                ForEach(pages.indices, id: \.self) { i in
                    TsumikiOnboardingPage(
                        systemImage: pages[i].symbol,
                        title:    pages[i].title,
                        body:     pages[i].body,
                        subtitle: pages[i].subtitle,
                        primaryAction: TsumikiOnboardingAction(title: i == pages.count - 1 ? "Get Started" : "Continue") {
                            index = min(index + 1, pages.count - 1)
                        },
                        secondaryAction: i == pages.count - 1
                            ? nil
                            : TsumikiOnboardingAction(title: "Skip") { dismissOnboarding() },
                        isActive: i == index
                    )
                    .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            TsumikiOnboardingDots(total: pages.count,
                                  current: index,
                                  onSelect: { index = $0 })
                .padding(.bottom)
        }
        .tsumikiTheme(DefaultTheme.light)
    }
}
```

## Theme tokens consumed

`TsumikiOnboardingPage`:
- `colors.accent`, `colors.background`, `colors.textPrimary`, `colors.textSecondary`
- `spacing.sm`, `spacing.md`, `spacing.lg`
- `radius.lg`
- `typography.largeTitle`, `typography.headline`, `typography.body`

`TsumikiOnboardingSymbolIllustration`:
- `colors.accent` (when no explicit `tint`)

`TsumikiOnboardingDots`:
- `colors.accent`
- `spacing.sm`

`TsumikiOnboardingProgressBar`:
- `colors.accent`

## Notes
- Strings are passed pre-localized — same convention as `TsumikiSplash` and
  `TsumikiDialog`. `LocalizedStringKey` overloads are a follow-up.
- `isActive` drives the staggered entrance: setting it `false → true`
  replays the spring. Honors `accessibilityReduceMotion`.
- `accentTint` opt-in per-instance override lets apps signal sections by
  hue without violating the "theme is the only source of color" rule.
- `TsumikiOnboardingDots.onSelect` makes the dot row tappable (44pt hit
  targets, `.isSelected` a11y trait on the current page). Omit it for
  pure read-only indicators.
- `TsumikiOnboardingProgressBar` clamps `progress` to `0...1` and is
  `accessibilityHidden(true)` (the dot row carries page semantics).
- The hero "breathing glow ring" from AquaBrew is intentionally left out
  — see arbiter doc for the v2 escape hatch.
