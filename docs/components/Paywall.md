# TsumikiPaywall

The visual chrome for a subscription paywall — title, optional subtitle, feature
list, price card, primary CTA, restore button, and an optional dismiss X. The
StoreKit 2 / RevenueCat integration lives in `TsumikiServices.TsumikiPaywallController`
(planned for Plan C); the view itself is purely value-driven.

## API

```swift
public struct TsumikiPaywallFeature: Identifiable {
    public init(id: UUID = UUID(), icon: Image, title: String, subtitle: String? = nil)
}

public struct TsumikiPaywallPrice: Sendable, Equatable {
    public init(headline: String, caption: String? = nil, badge: String? = nil)
}

public struct TsumikiPaywall: View {
    public init(title: String,
                subtitle: String? = nil,
                features: [TsumikiPaywallFeature],
                price: TsumikiPaywallPrice,
                ctaTitle: String = "Continue",
                isPurchasing: Bool = false,
                onPurchase: @escaping () -> Void,
                onRestore: @escaping () -> Void,
                onDismiss: (() -> Void)? = nil)
}
```

## Example

```swift
let features = [
    TsumikiPaywallFeature(icon: Image(systemName: "infinity"),
                          title: "Unlimited scans"),
    TsumikiPaywallFeature(icon: Image(systemName: "bell.badge"),
                          title: "Smart reminders",
                          subtitle: "Never miss a renewal"),
    TsumikiPaywallFeature(icon: Image(systemName: "icloud"),
                          title: "Cloud sync"),
]
TsumikiPaywall(
    title: "Tsumiki Pro",
    subtitle: "Build faster with the full design system",
    features: features,
    price: TsumikiPaywallPrice(headline: "$4.99 / month",
                               caption: "7-day free trial · cancel anytime",
                               badge: "BEST VALUE"),
    ctaTitle: "Start Free Trial",
    onPurchase: { /* trigger purchase */ },
    onRestore:  { /* restore */ },
    onDismiss:  { /* close sheet */ }
)
.tsumikiTheme(DefaultTheme.light)
```

## Theme tokens consumed
- `colors.accent`, `colors.background`, `colors.surface`
- `colors.textPrimary`, `colors.textSecondary`
- `spacing.xs`, `spacing.sm`, `spacing.md`, `spacing.lg`
- `radius.md`
- `typography.title`, `typography.body`, `typography.caption`

## Notes
- All 3 source paywalls (lucidmate, warrantyreminder, zeroblock) were
  RevenueCatUI wrappers. Tsumiki's API is invented from the brief, not extracted.
  Validate against a design mock before locking the public surface.
- Loading + error states are deferred to sibling components
  (`TsumikiPaywallLoading`, `TsumikiPaywallError`) rather than overloading
  `TsumikiPaywall` with a state enum.
- "Restore Purchases" string is hardcoded; localisation strategy pending.
