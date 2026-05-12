# Loading: TsumikiLoading + TsumikiSkeleton + .tsumikiShimmer()

Three primitives. Use `TsumikiLoading` for an indeterminate spinner with optional
label and cancel CTA. Use `TsumikiSkeleton` + `.tsumikiShimmer()` for content
placeholders. Honours `accessibilityReduceMotion` (shimmer overlay opacity → 0).

## API

```swift
public struct TsumikiLoading: View {
    public enum Size { case compact, regular, large }
    public init(label: String? = nil, size: Size = .regular, onCancel: (() -> Void)? = nil)
}

public struct TsumikiSkeleton: View {
    public enum Shape {
        case rectangle(cornerRadius: CGFloat? = nil)   // nil → theme.radius.sm
        case circle, capsule
    }
    public init(_ shape: Shape = .rectangle(), width: CGFloat? = nil, height: CGFloat)
}

public struct TsumikiShimmerModifier: ViewModifier {
    public init(duration: Double = 1.5)
}
public extension View {
    func tsumikiShimmer(duration: Double = 1.5) -> some View
}
```

## Examples

```swift
// Spinner
TsumikiLoading(label: "Fetching matches", size: .large, onCancel: { /* cancel */ })

// Skeleton placeholder
VStack(alignment: .leading, spacing: 8) {
    TsumikiSkeleton(.circle, width: 48, height: 48)
    TsumikiSkeleton(.rectangle(cornerRadius: 6), width: 200, height: 16)
    TsumikiSkeleton(.capsule, width: 120, height: 12)
}

// Shimmer on arbitrary views
Image(systemName: "photo")
    .resizable()
    .frame(width: 80, height: 80)
    .tsumikiShimmer()
```

## Theme tokens consumed
- `colors.accent` — spinner tint, shimmer highlight, cancel button stroke + label
- `colors.textSecondary` — label text
- `colors.surface` — skeleton fill, shimmer base
- `spacing.xs`, `spacing.sm`, `spacing.md`, `spacing.lg`
- `radius.sm` — default rectangle corner + cancel button outline
- `typography.body` — label + cancel text

## Notes
- On light themes where `colors.surface` ≈ `colors.background`, shimmer can appear
  faint. A dedicated `colors.skeleton` token is a planned follow-up.
- Cancel button copy is hardcoded `"Cancel"`. Localisation strategy is pending
  framework-wide.
- Source variants subsumed: `LeaderboardLoadingView`, `AppLoadingIndicator`,
  `ShimmerModifier` / `.shimmer()`, `SkeletonShape`. App-specific compositions
  (`HomeSkeleton`, `TrainingCategorySkeletonView`) stay in apps composing these
  primitives.
