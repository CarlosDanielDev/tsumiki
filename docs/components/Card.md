# TsumikiCard

A primitive container with configurable padding and elevation. **App-specific
cards (BoostShopCard, CalendarDayCard, BrewTipCard, etc.) compose `TsumikiCard`
rather than being replaced by it** — the framework owns the chrome, apps own
the content.

## API

```swift
public enum TsumikiCardPadding { case none, compact, regular, generous }
public enum TsumikiCardElevation { case flat, soft, elevated }

public struct TsumikiCard<Content: View>: View {
    public init(padding: TsumikiCardPadding = .regular,
                elevation: TsumikiCardElevation = .soft,
                @ViewBuilder content: () -> Content)
}
```

## Example

```swift
struct DashboardWidget: View {
    var body: some View {
        TsumikiCard(padding: .generous, elevation: .elevated) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Today").font(.headline)
                Text("12 reps · 1.2 km").font(.title)
            }
        }
        .tsumikiTheme(DefaultTheme.light)
    }
}
```

## Theme tokens consumed
- `colors.surface` — fill
- `radius.md` — corners
- `shadow.soft` (elevation == .soft), `shadow.elevated` (elevation == .elevated)
- `spacing.sm`, `spacing.md`, `spacing.lg` — padding scale

## Notes
- 57 source-app cards across the 5 apps stay in apps. They will be migrated to
  compose `TsumikiCard` rather than reimplement chrome.
- No corner-radius override knob. If a v2 needs `.smallRadius`/`.largeRadius`,
  add an enum rather than exposing CGFloat (keep the API token-aligned).
- `.flat` elevation skips the shadow modifier entirely.
