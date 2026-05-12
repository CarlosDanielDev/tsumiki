# Arbiter: Loading

## Decision: TWO APIs
Spinner and shimmer/skeleton are visually + semantically distinct. Splitting:
- `TsumikiLoading` — spinner with optional label + cancel.
- `TsumikiSkeleton` + `.tsumikiShimmer()` — placeholder primitive + shimmer modifier.

## Winners
- Spinner: `zeroblock/Views/Leaderboard/Components/LeaderboardStateViews.swift` (LeaderboardLoadingView).
- Shimmer modifier: `aquabrew/Views/Components/Loading/ShimmerModifier.swift`.

## Why
- LeaderboardLoadingView is the most complete spinner (label + cancel CTA).
- AquaLoadingView is a bespoke splash (waves/droplets) — too app-specific.
- ShimmerModifier already abstracts base/highlight + duration → easy theme-token fit.
- TrainingCategorySkeletonView uses `.redacted(.placeholder)` — third pattern; consumers can combine with shimmer themselves.

## Proposed Tsumiki API

```swift
// MARK: - Spinner
public struct TsumikiLoading: View {
    public enum Size: Sendable { case compact, regular, large }
    public init(label: String? = nil, size: Size = .regular, onCancel: (() -> Void)? = nil)
}

// MARK: - Shimmer
public struct TsumikiShimmerModifier: ViewModifier {
    public init(duration: Double = 1.5)
}
public extension View {
    func tsumikiShimmer(duration: Double = 1.5) -> some View
}

// MARK: - Skeleton
public struct TsumikiSkeleton: View {
    public enum Shape: Sendable {
        case rectangle(cornerRadius: CGFloat? = nil)  // nil → theme.radius.sm
        case circle, capsule
    }
    public init(_ shape: Shape = .rectangle(), width: CGFloat? = nil, height: CGFloat)
}
```

## Theme tokens consumed
- colors.accent (spinner tint, shimmer highlight, cancel)
- colors.textSecondary (label)
- colors.surface (skeleton fill, shimmer base)
- spacing.xs/sm/md/lg, radius.sm
- typography.subheadline, typography.headline

## Variants subsumed
- LeaderboardLoadingView → `TsumikiLoading(label:, size: .large, onCancel:)`
- AppLoadingIndicator (top-trailing pill) → `TsumikiLoading(label:, size: .compact)`
- ShimmerModifier `.shimmer()` → `.tsumikiShimmer()`
- SkeletonShape → `TsumikiSkeleton`
- HomeSkeleton, TrainingCategorySkeletonView → consumer code composing primitives

## Not ported
- AquaLoadingView (water-wave splash) — bespoke, stays in app.

## Risks / open questions
- `colors.surface` doubles as shimmer base; on light themes ~= background → may be invisible. Consider `colors.skeleton` follow-up.
- Cancel button copy "Cancel" hardcoded — L10N decision pending framework-wide.
- Reduce-motion: shimmer halts animation but still draws gradient overlay.
