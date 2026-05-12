import SwiftUI
import TsumikiTheme

public struct TsumikiPaywall: View {
    public let title: String
    public let subtitle: String?
    public let features: [TsumikiPaywallFeature]
    public let price: TsumikiPaywallPrice
    public let ctaTitle: String
    public let isPurchasing: Bool
    public let onPurchase: () -> Void
    public let onRestore: () -> Void
    public let onDismiss: (() -> Void)?

    @Environment(\.tsumikiTheme) private var theme

    public init(title: String,
                subtitle: String? = nil,
                features: [TsumikiPaywallFeature],
                price: TsumikiPaywallPrice,
                ctaTitle: String = "Continue",
                isPurchasing: Bool = false,
                onPurchase: @escaping () -> Void,
                onRestore: @escaping () -> Void,
                onDismiss: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.features = features
        self.price = price
        self.ctaTitle = ctaTitle
        self.isPurchasing = isPurchasing
        self.onPurchase = onPurchase
        self.onRestore = onRestore
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    header
                    featureList
                    priceCard
                    cta
                    restoreButton
                }
                .padding(theme.spacing.lg)
            }
            if let onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(theme.typography.body)
                        .padding(theme.spacing.md)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
        }
        .background(theme.colors.background.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text(title)
                .font(theme.typography.title)
                .foregroundStyle(theme.colors.textPrimary)
            if let subtitle {
                Text(subtitle)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            ForEach(features) { f in
                HStack(alignment: .top, spacing: theme.spacing.md) {
                    f.icon
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.accent)
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Text(f.title)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textPrimary)
                        if let s = f.subtitle {
                            Text(s)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                    }
                }
            }
        }
    }

    private var priceCard: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            if let badge = price.badge {
                Text(badge)
                    .font(theme.typography.caption)
                    .padding(.horizontal, theme.spacing.sm)
                    .padding(.vertical, 0)
                    .foregroundStyle(theme.colors.background)
                    .background(theme.colors.accent)
                    .clipShape(Capsule())
            }
            Text(price.headline)
                .font(theme.typography.title)
                .foregroundStyle(theme.colors.textPrimary)
            if let caption = price.caption {
                Text(caption)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.md)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous))
    }

    private var cta: some View {
        Button(action: onPurchase) {
            Group {
                if isPurchasing {
                    ProgressView().tint(theme.colors.background)
                } else {
                    Text(ctaTitle)
                        .font(theme.typography.body)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, theme.spacing.md)
        }
        .background(theme.colors.accent)
        .foregroundStyle(theme.colors.background)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous))
        .disabled(isPurchasing)
    }

    private var restoreButton: some View {
        Button("Restore Purchases", action: onRestore)
            .font(theme.typography.caption)
            .foregroundStyle(theme.colors.textSecondary)
            .frame(maxWidth: .infinity)
    }
}
