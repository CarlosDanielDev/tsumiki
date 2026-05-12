# TsumikiSplash

Logo + optional title + tagline with spring/fade entry animation and timed
auto-dismiss. Lives in `TsumikiComponents`. Reads theme via
`@Environment(\.tsumikiTheme)`. Honours `accessibilityReduceMotion`.

## API

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

## Example

```swift
import SwiftUI
import TsumikiComponents
import TsumikiTheme

struct RootView: View {
    @State private var splashVisible = true
    var body: some View {
        ContentView()
            .tsumikiSplash(
                isPresented: $splashVisible,
                logo: Image("AppIcon"),
                title: "Tsumiki",
                tagline: "Plug and play SwiftUI"
            )
            .tsumikiTheme(DefaultTheme.light)
    }
}
```

## Theme tokens consumed
- `colors.background`, `colors.textPrimary`, `colors.textSecondary`
- `spacing.md`, `spacing.lg`, `radius.lg`
- `typography.title`, `typography.body`

## Notes
- Entry animation: spring scale on logo + ease-in opacity. Skipped when
  `accessibilityReduceMotion` is on.
- Auto-dismiss uses `Task.sleep`; `hasCompleted` flag prevents double-fire.
- Custom backgrounds (animated waves, particles) are intentionally out of scope —
  consumers can layer custom views behind `TsumikiSplash` or build their own.
