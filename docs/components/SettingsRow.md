# TsumikiSettingsRow

A row for settings screens with tinted icon tile, title, optional subtitle,
and one of five trailing accessories. Lives in `TsumikiComponents`.

## API

```swift
public struct TsumikiSettingsRow: View {
    public enum Trailing {
        case chevron(action: () -> Void)
        case link(URL)                          // shows arrow.up.right
        case toggle(isOn: Binding<Bool>)
        case value(String, tone: ValueTone = .secondary)
        case none
    }
    public enum ValueTone { case primary, secondary, success, warning, danger }
    public enum IconTint { case accent, success, warning, danger; case custom(Color) }

    public init(icon: Image,
                iconTint: IconTint = .accent,
                title: String,
                subtitle: String? = nil,
                trailing: Trailing = .none)
}
```

## Example

```swift
import SwiftUI
import TsumikiComponents
import TsumikiTheme

struct SettingsView: View {
    @State private var darkMode = false
    var body: some View {
        VStack(spacing: 0) {
            TsumikiSettingsRow(
                icon: Image(systemName: "moon.fill"),
                iconTint: .accent,
                title: "Dark Mode",
                trailing: .toggle(isOn: $darkMode)
            )
            TsumikiSettingsRow(
                icon: Image(systemName: "bell.fill"),
                iconTint: .warning,
                title: "Notifications",
                subtitle: "Daily reminder at 9 AM",
                trailing: .chevron(action: { /* navigate */ })
            )
            TsumikiSettingsRow(
                icon: Image(systemName: "link"),
                title: "Privacy Policy",
                trailing: .link(URL(string: "https://example.com/privacy")!)
            )
            TsumikiSettingsRow(
                icon: Image(systemName: "info.circle"),
                title: "Version",
                trailing: .value("1.0.0")
            )
        }
        .tsumikiTheme(DefaultTheme.light)
    }
}
```

## Theme tokens consumed
- `colors.accent`, `colors.success`, `colors.warning`, `colors.danger`
- `colors.textPrimary`, `colors.textSecondary`
- `spacing.xs`, `spacing.sm`, `spacing.md`, `spacing.lg`
- `radius.sm` (icon tile)
- `typography.body`, `typography.caption`

## Notes
- Icon tile is a fixed 28×28 with a 10 % tint background — a deliberate v1 constant.
- Toggle tint follows `colors.accent` (not the per-app brand colour).
- `.link` opens externally via SwiftUI `Link`. For in-app routing, use `.chevron`.
- Future `TsumikiSettingsSection` will add divider grouping; for now stack rows in a
  `VStack` and add separators in consumer code if needed.
