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
