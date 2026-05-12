import SwiftUI
import TsumikiComponents
import TsumikiTheme

struct CardGallery: View {
    @Environment(\.tsumikiTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            label("Padding")
            TsumikiCard(padding: .none)     { sample("None") }
            TsumikiCard(padding: .compact)  { sample("Compact") }
            TsumikiCard(padding: .regular)  { sample("Regular") }
            TsumikiCard(padding: .generous) { sample("Generous") }

            label("Elevation")
            TsumikiCard(elevation: .flat)     { sample("Flat") }
            TsumikiCard(elevation: .soft)     { sample("Soft") }
            TsumikiCard(elevation: .elevated) { sample("Elevated") }
        }
    }

    @ViewBuilder
    private func sample(_ text: String) -> some View {
        Text(text)
            .font(theme.typography.body)
            .foregroundStyle(theme.colors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func label(_ s: String) -> some View {
        Text(s)
            .font(theme.typography.headline)
            .foregroundStyle(theme.colors.textPrimary)
    }
}
