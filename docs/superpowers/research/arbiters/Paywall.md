# Arbiter: Paywall

## Critical finding
All 3 candidates are **RevenueCatUI wrappers** — they delegate chrome to `RevenueCatUI.PaywallView`. None render custom feature list / price card / CTA. The "visual primitives" the brief asked for don't exist in source.

What DOES exist: loading + error chrome around vendor paywall (best in zeroblock).

**Strategy**: Invent `TsumikiPaywall` from scratch as a generic visual shell. Vendor adapters (RevenueCat, StoreKit 2) sit in `TsumikiServices.TsumikiPaywallController` and feed the view a value-typed `[Feature]` + `Price` + `isPurchasing` flag + closures.

## Winner (structure reference)
`zeroblock/Views/Paywall/PaywallSheetView.swift` — only candidate with custom theme-aware chrome (loading + error states).

## Proposed Tsumiki API

```swift
public struct TsumikiPaywallFeature: Identifiable, Sendable {
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

## Theme tokens consumed
- colors.accent, colors.background, colors.surface, colors.textPrimary, colors.textSecondary
- spacing.xs/sm/md/lg, radius.md
- typography.title, typography.body, typography.caption

## Variants subsumed
- LucidMatePaywallView → controller-driven, render `TsumikiPaywall`
- warrantyreminder PaywallView → controller absorbs analytics + offering loader
- zeroblock PaywallSheetView → loading/error become sibling components `TsumikiPaywallLoading` / `TsumikiPaywallError`

## Risks / open questions
- Brief defers loading/error states; recommend siblings rather than overloading TsumikiPaywall with state enum.
- No real custom-chrome reference exists in 5 apps — primitives inferred. Validate against design mock before locking API.
- Coupling with TsumikiPaywallController (Plan C concern): controller exposes `@Published var state: Loading | Loaded(features, price) | Error(msg) | Purchasing`.
