import SwiftUI
import TsumikiComponents
import TsumikiTheme

struct PaywallGallery: View {
    @Environment(\.tsumikiTheme) private var theme

    var body: some View {
        TsumikiPaywall(
            title: "Tsumiki Pro",
            subtitle: "Unlock the full library.",
            features: [
                TsumikiPaywallFeature(icon: Image(systemName: "infinity"),
                                     title: "Unlimited projects",
                                     subtitle: "No caps, no upsells."),
                TsumikiPaywallFeature(icon: Image(systemName: "paintbrush"),
                                     title: "Custom themes",
                                     subtitle: "Bring your brand tokens."),
                TsumikiPaywallFeature(icon: Image(systemName: "icloud"),
                                     title: "iCloud sync",
                                     subtitle: "Pick up across devices."),
            ],
            price: TsumikiPaywallPrice(
                headline: "$2.99/month",
                caption: "Cancel anytime. Renews monthly.",
                badge: "BEST VALUE"
            ),
            ctaTitle: "Subscribe",
            onPurchase: {},
            onRestore:  {},
            onDismiss:  {}
        )
        .frame(height: 600)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg))
    }
}
