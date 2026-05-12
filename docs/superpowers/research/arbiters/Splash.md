# Arbiter: Splash

## Winner
WarrantyReminder `SplashView` as structural base, with dismissal-binding pattern from AquaBrew.

## Why
- Minimal generic structure (logo + title + tagline + fade/scale + timer) maps cleanly.
- AquaBrew's wave background, droplets, AquaBrewLogoView are app-specific decoration; not framework material.
- Both share animation grammar (spring scale + ease-in opacity + 2.0s auto-dismiss).
- AquaBrew's `accessibilityReduceMotion` handling worth lifting.
- WR uses injectable `Image` — fits library API.

## Proposed Tsumiki API

```swift
public struct TsumikiSplash: View {
    public init(
        logo: Image,
        title: String? = nil,
        tagline: String? = nil,
        duration: TimeInterval = 2.0,
        logoSize: CGFloat = 120,
        onComplete: @escaping () -> Void
    )
}

public extension View {
    func tsumikiSplash(
        isPresented: Binding<Bool>,
        logo: Image,
        title: String? = nil,
        tagline: String? = nil,
        duration: TimeInterval = 2.0
    ) -> some View
}
```

## Theme tokens consumed
- colors.background, colors.textPrimary, colors.textSecondary
- spacing.md, spacing.lg, radius.lg
- typography.title, typography.body

## Variants subsumed
- WR SplashView (solid colour + logo + title + tagline) → direct match
- AquaBrew animated wave + droplet → NOT subsumed (app-specific decoration); v2 may add `background:` slot
- Reduce-motion fallback (instant present) → built-in

## Risks / open questions
- `theme.radius.lg` and `theme.typography.title` referenced — confirm tokens exist (yes, used by Toast).
- AquaBrew owners may push back on losing wave/droplet motif.
- `DispatchQueue.main.asyncAfter` works but `Task.sleep + .task` more idiomatic iOS 17+.
- Timer leak if view disappears early — gate via `hasCompleted` flag or `.onDisappear`.
- Title/tagline `String` only; consider `LocalizedStringKey` overload.
