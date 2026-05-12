# TsumikiDialog

Branded modal with header icon, title, optional message, action buttons, and an
optional custom content slot. Drives via `.tsumikiDialog(isPresented:)` modifier.

## API

```swift
public struct TsumikiDialog<Content: View>: View {
    public enum Kind { case info, confirmation, success, warning, destructive }

    public init(kind: Kind = .info,
                icon: Image? = nil,
                title: String,
                message: String? = nil,
                actions: [TsumikiDialogAction] = [],
                @ViewBuilder content: () -> Content = { EmptyView() },
                onDismiss: @escaping () -> Void = {})
}

public struct TsumikiDialogAction: Identifiable {
    public enum Style { case primary, secondary, destructive, cancel }

    public init(_ title: String, style: Style = .primary, handler: @escaping () -> Void = {})

    public static func primary(_ title: String, _ handler: @escaping () -> Void) -> TsumikiDialogAction
    public static func secondary(_ title: String, _ handler: @escaping () -> Void) -> TsumikiDialogAction
    public static func destructive(_ title: String, _ handler: @escaping () -> Void) -> TsumikiDialogAction
    public static func cancel(_ title: String = "Cancel", _ handler: @escaping () -> Void = {}) -> TsumikiDialogAction
}

public extension View {
    func tsumikiDialog<C: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder dialog: @escaping () -> TsumikiDialog<C>
    ) -> some View
}
```

## Tap-outside-to-dismiss rules
- Allowed only when `actions` contains a `.cancel` action AND `kind != .destructive`.
- Destructive dialogs always require an explicit button tap.

## Example

```swift
struct DeleteFlow: View {
    @State private var showConfirm = false
    var body: some View {
        Button("Delete account", role: .destructive) { showConfirm = true }
            .tsumikiDialog(isPresented: $showConfirm) {
                TsumikiDialog<EmptyView>(
                    kind: .destructive,
                    icon: Image(systemName: "trash.fill"),
                    title: "Delete account?",
                    message: "This cannot be undone.",
                    actions: [
                        .destructive("Delete", { /* delete */ }),
                        .cancel(),
                    ]
                )
            }
            .tsumikiTheme(DefaultTheme.light)
    }
}
```

## Theme tokens consumed
- `colors.surface` (card), `colors.background` (button text on filled actions),
  `colors.scrim` (backdrop), `colors.textPrimary`, `colors.textSecondary`
- `colors.accent` (info/confirmation header + primary button)
- `colors.success` / `colors.warning` / `colors.danger` (header by kind)
- `spacing.sm`, `spacing.md`, `spacing.lg`, `spacing.xl`
- `radius.md` (action buttons), `radius.lg` (card)
- `shadow.elevated`
- `typography.title`, `typography.body`

## Notes
- Custom content slot lets DialogOverlay-style game-end screens inject bonus
  breakdowns or rich middle content while keeping the standard chrome.
- Header icon pulse animation deliberately omitted in v1 — adds CPU and complicates
  reduce-motion. Add via theme animation tokens later if needed.
