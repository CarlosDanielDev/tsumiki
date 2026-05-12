# Arbiter: SettingsRow

## Winner
New unified `TsumikiSettingsRow` subsuming all 5 source variants (`SettingsRow`, `SettingsLinkRow`, `WRSettingsRow`, `WRSettingsToggleRow`, `WRSettingsInfoRow`) via a `Trailing` enum. Neither candidate wins outright; warrantyreminder's set is more complete (toggle + info), aquabrew adds link.

## Why
- Same skeleton: every variant is `HStack { tinted icon tile, title (+optional subtitle), Spacer, trailing }`.
- Only differences are trailing accessory + tap behaviour.
- Hardcoded values everywhere (12, 28x28, cornerRadius 6, opacity 0.1, mintGreen toggle tint) — all become tokens.
- Subtitle optional, used by 2 of 5 — single optional param.
- `Trailing` enum lets row choose Button vs Link vs plain container, removing 3+ types.

## Proposed Tsumiki API

```swift
public struct TsumikiSettingsRow: View {
    public enum Trailing {
        case chevron(action: () -> Void)
        case link(URL)                              // shows arrow.up.right
        case toggle(isOn: Binding<Bool>)
        case value(String, tone: ValueTone = .secondary)
        case none
    }

    public enum ValueTone { case primary, secondary, success, warning, danger }

    public enum IconTint {
        case accent, success, warning, danger
        case custom(Color)
    }

    public init(icon: Image,
                iconTint: IconTint = .accent,
                title: String,
                subtitle: String? = nil,
                trailing: Trailing = .none)
}
```

## Theme tokens consumed
- colors.accent, success, warning, danger
- colors.textPrimary, colors.textSecondary
- spacing.xs (subtitle gap), spacing.sm (HStack), spacing.md (vert padding), spacing.lg (horiz padding)
- radius.sm (icon tile)
- typography.body, typography.caption

## Variants subsumed
| Source | Trailing case |
| --- | --- |
| aquabrew.SettingsRow | `.chevron(action:)` |
| aquabrew.SettingsLinkRow | `.link(url)` |
| WRSettingsRow | `.chevron(action:)` + subtitle |
| WRSettingsToggleRow | `.toggle(isOn:)` |
| WRSettingsInfoRow | `.value(_, tone:)` |

## Risks / open questions
- Icon tile size (28x28) hardcoded across all 5 sources — leave as constant for v1.
- Tile background opacity (0.1) — same.
- Toggle tint mapped to accent (was mintGreen brand colour).
- Future `TsumikiSettingsSection` container for Divider grouping.
- `SettingsLinkRow` opens externally via `Link`; in-app routing → use `.chevron`.
