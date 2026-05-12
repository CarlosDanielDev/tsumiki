# TsumikiButton

A theme-aware button covering primary CTAs, secondary outlines, tertiary text
buttons, destructive actions, and ghost/icon-only floating actions, across
small/medium/large sizes and rounded/pill/circle shapes.

## API

```swift
public enum TsumikiButtonStyle  { case primary, secondary, tertiary, destructive, ghost }
public enum TsumikiButtonSize   { case small, medium, large }
public enum TsumikiButtonShape  { case rounded, pill, circle }
public enum TsumikiButtonLayout { case horizontal, vertical, iconOnly }

public struct TsumikiButton: View {
    public init(
        _ title: String? = nil,
        subtitle: String? = nil,
        icon: Image? = nil,
        trailingIcon: Image? = nil,
        style: TsumikiButtonStyle = .primary,
        size: TsumikiButtonSize = .medium,
        shape: TsumikiButtonShape = .rounded,
        layout: TsumikiButtonLayout = .horizontal,
        isLoading: Bool = false,
        isFullWidth: Bool = false,
        badge: String? = nil,
        action: @escaping () -> Void
    )
}
```

## Style → token mapping
| Style | Background | Foreground | Stroke |
|---|---|---|---|
| `.primary` | `colors.accent` | `colors.background` | — |
| `.secondary` | `colors.surface` | `colors.accent` | `colors.accent` |
| `.tertiary` | clear | `colors.accent` | — |
| `.destructive` | `colors.danger` | `colors.background` | — |
| `.ghost` | clear | `colors.textSecondary` | — |

## Examples

```swift
// Primary CTA, full width
TsumikiButton("Save", style: .primary, isFullWidth: true) { /* save */ }

// Secondary outline + icon
TsumikiButton("Retry", icon: Image(systemName: "arrow.clockwise"),
              style: .secondary, shape: .pill) { /* retry */ }

// Floating action, icon-only
TsumikiButton(icon: Image(systemName: "plus"),
              style: .primary, size: .large,
              shape: .circle, layout: .iconOnly) { /* add */ }

// Vertical layout (icon + label) for tab-style grids
TsumikiButton("Boost", icon: Image(systemName: "bolt.fill"),
              style: .secondary, layout: .vertical, badge: "3") { /* boost */ }

// Loading state
TsumikiButton("Watch Ad", subtitle: "+1 Undo",
              isLoading: true) { /* await */ }
```

## Theme tokens consumed
- `colors.accent`, `colors.surface`, `colors.danger`, `colors.warning` (badge),
  `colors.textPrimary`, `colors.textSecondary`, `colors.background`
- `spacing.xs`, `spacing.sm`, `spacing.md`, `spacing.lg`, `spacing.xl`
- `radius.md` (rounded), `radius.pill` (pill)
- `typography.caption`, `typography.body`, `typography.headline`

## Notes
- Disabled state via SwiftUI `.disabled()` reduces opacity to 0.4 (a future
  `TsumikiOpacity.disabled` token will replace the inline literal).
- Subtitle (e.g. "Watch Ad" + "+1 Undo") renders as a two-line label.
- Badge text overlays at top-trailing using `colors.warning` on a Capsule.
- Gradient fills from source variants are intentionally flattened to `colors.accent`.
- Subsumes ModernActionButton, AquaBlenderActionButtons, QuickLogButton, BoostButton,
  CircularFloatingButton, RewardedUndoButton, SocialLinkButton, AboutSocialButton,
  LeaderboardButtonExample, OCR Retry/Accept buttons.
