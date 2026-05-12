import SwiftUI
import TsumikiComponents
import TsumikiTheme

struct SplashGallery: View {
    @Environment(\.tsumikiTheme) private var theme
    @State private var counter = 0

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            Text("Tap to replay the splash animation (duration 1.5s).")
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)

            TsumikiSplash(
                logo: Image(systemName: "cube.transparent.fill"),
                title: "Tsumiki",
                tagline: "A library of stacked SwiftUI primitives.",
                duration: 1.5
            ) {
                counter += 1
            }
            .frame(height: 320)
            .id(counter)

            Text("Completed \(counter) time(s).")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
        }
    }
}
