# Arbiter: Dialog

## Winner
`aquabrew/Views/Components/Dialogs/AquaBrewDialog.swift`

## Why
- Richest, cleanest API: `kind` + `icon` + `title` + `message` + `[buttons]`.
- WR adopts the same shape, adding defensive `isDismissing` guard + destructive-blocks-tap-outside (port both rules).
- DialogButton already enumerates the four real-world styles seen everywhere (`.primary/.secondary/.destructive/.cancel`).
- DialogOverlay's bespoke game-end content slots in via `content:` ViewBuilder.

## Proposed Tsumiki API

```swift
public struct TsumikiDialog<Content: View>: View {
    public enum Kind: Sendable { case info, confirmation, success, warning, destructive }

    public struct Action: Identifiable {
        public enum Style: Sendable { case primary, secondary, destructive, cancel }
        public init(_ title: String, style: Style = .primary, handler: @escaping () -> Void = {})
        public static func primary(_:_:) / secondary(_:_:) / destructive(_:_:) / cancel(_:_:)
    }

    public init(kind: Kind = .info,
                icon: Image? = nil,
                title: String,
                message: String? = nil,
                actions: [Action] = [],
                @ViewBuilder content: () -> Content = { EmptyView() },
                onDismiss: @escaping () -> Void = {})
}

public extension View {
    func tsumikiDialog<C: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder dialog: @escaping () -> TsumikiDialog<C>
    ) -> some View
}
```

### Tap-outside rules
- Dismisses ONLY when `actions` contains a `.cancel` AND `kind != .destructive`.
- Destructive dialogs always require explicit button tap.

## Theme tokens consumed
- colors.surface (card fill), colors.background (scrim base)
- colors.textPrimary, colors.textSecondary
- colors.accent (info/confirmation header), colors.success, colors.warning, colors.danger
- spacing.sm/md/lg/xl, radius.lg (card), radius.md (action button)
- shadow.soft (card drop, tinted by kind)
- typography.title, typography.body

## Variants subsumed
- AquaBrewDialog (all kinds) → direct mapping
- WRDialog → identical, vaultBlue → accent, coralRed → danger
- DialogOverlay (game won/lost) → kind: .success or .destructive + custom `content:` slot for bonus breakdown
- ConfirmationDialogControls → replace native sheet with branded dialog

## Risks / open questions
- Backdrop scrim hardcoded `Color.black.opacity(0.4)`. Add `theme.colors.scrim` token (recommended).
- Pulse animation on icon: respect `accessibilityReduceMotion` (originals do).
- Generic Content slot needs explicit type at call site; ship `EmptyView` overload.
