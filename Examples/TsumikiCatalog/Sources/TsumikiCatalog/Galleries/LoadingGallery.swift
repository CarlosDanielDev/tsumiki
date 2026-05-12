import SwiftUI
import TsumikiComponents
import TsumikiTheme

struct LoadingGallery: View {
    @Environment(\.tsumikiTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xl) {
            heading("Sizes")
            HStack(spacing: theme.spacing.xl) {
                TsumikiLoading(size: .compact)
                TsumikiLoading(size: .regular)
                TsumikiLoading(size: .large)
            }

            heading("With label")
            TsumikiLoading(label: "Loading data…")

            heading("With cancel")
            TsumikiLoading(label: "Uploading…", onCancel: {})
        }
    }

    @ViewBuilder
    private func heading(_ s: String) -> some View {
        Text(s).font(theme.typography.headline).foregroundStyle(theme.colors.textPrimary)
    }
}
