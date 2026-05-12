# Arbiter: Button

## Winner
`aquabrew/Views/Home/HomeView.swift` (`ModernActionButton`)

## Why
- Cleanest tap-target API: icon + title + colour + action — no domain leakage.
- VStack(icon + label) layout generalises to text-only or icon-only via optional params.
- Press-state animation (scaleEffect + long-press gesture) is the most reusable.
- Closest to a "primary CTA" baseline; other variants add one axis (loading, badge, full-width, circular, locked, layout).
- QuickLogButton + RewardedUndoButton add `isLoading`/`isDisabled` — foldable as params.

## Proposed Tsumiki API

```swift
public struct TsumikiButton: View {
    public enum Style: Sendable { case primary, secondary, tertiary, destructive, ghost }
    public enum Size: Sendable { case small, medium, large }
    public enum Shape: Sendable { case rounded, pill, circle }
    public enum LabelLayout: Sendable { case horizontal, vertical, iconOnly }

    public init(
        _ title: String? = nil,
        icon: Image? = nil,
        trailingIcon: Image? = nil,
        subtitle: String? = nil,
        style: Style = .primary,
        size: Size = .medium,
        shape: Shape = .rounded,
        layout: LabelLayout = .horizontal,
        isLoading: Bool = false,
        isFullWidth: Bool = false,
        badge: String? = nil,
        action: @escaping () -> Void
    )
}
```

### Style → token mapping
| Style | Fill | Foreground | Stroke |
|---|---|---|---|
| primary | accent | textPrimary on accent | — |
| secondary | surface | accent | accent |
| tertiary | clear | accent | — |
| destructive | danger | textPrimary on danger | — |
| ghost | clear | textSecondary | — |

## Theme tokens consumed
- colors.accent, colors.surface, colors.danger, colors.warning (badge), colors.textPrimary, colors.textSecondary
- spacing.xs/sm/md/lg/xl
- radius.md, radius.pill
- typography.body, typography.caption
- shadow.soft (primary elevation)

## Variants subsumed
- AquaBlenderActionButtons → primary/medium/rounded/horizontal + isFullWidth
- ModernActionButton → primary/medium/rounded/vertical
- SocialLinkButton, AboutSocialButton → ghost/medium/circle/iconOnly
- QuickLogButton → primary/medium/rounded/horizontal + isFullWidth
- BoostButton → secondary/small/rounded/vertical + badge
- CircularFloatingButton → primary/large/circle/iconOnly (gradient flattened)
- LeaderboardButtonExample → tertiary/medium/rounded/horizontal
- RewardedUndoButton → primary/medium/rounded/horizontal + isLoading + subtitle
- OCR Retry/Accept buttons → secondary/large/pill + primary/large/pill, both isFullWidth

## Not subsumed
- ModeButton, ModeTabButton → belong to Card / SegmentedControl concepts
- DetectionBoxButton → overlay hit-region, domain-specific

## Risks / open questions
- Gradient fills dropped (flatten to accent); add `theme.gradients.accent` later if needed.
- Subtitle (RewardedUndoButton "Watch Ad" + "+1 Undo") added as optional param.
- Haptics: bake `.sensoryFeedback(.impact, trigger: isPressed)` into all styles.
- Badge semantics differ (lock icon vs count) — String for now; future Badge enum.
