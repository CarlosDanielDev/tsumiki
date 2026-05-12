import SwiftUI
import TsumikiComponents
import TsumikiTheme

struct OnboardingGallery: View {
    @Environment(\.tsumikiTheme) private var theme
    @State private var pageIndex = 0
    @State private var progress: Double = 0.0

    private let totalPages = 3

    var body: some View {
        VStack(spacing: theme.spacing.lg) {
            TsumikiOnboardingPage(
                systemImage: pageImage,
                title: pageTitle,
                body: pageBody,
                subtitle: "STEP \(pageIndex + 1)",
                primaryAction: TsumikiOnboardingAction(title: "Next") {
                    advance()
                },
                secondaryAction: TsumikiOnboardingAction(title: "Skip") {
                    pageIndex = totalPages - 1
                    progress = 1.0
                },
                isActive: true
            )
            .frame(height: 480)
            .id(pageIndex)

            TsumikiOnboardingProgressBar(progress: progress)
                .padding(.horizontal, theme.spacing.lg)

            TsumikiOnboardingDots(
                total: totalPages,
                current: pageIndex,
                onSelect: { i in
                    pageIndex = i
                    progress = Double(i) / Double(totalPages - 1)
                }
            )
        }
    }

    private func advance() {
        let next = (pageIndex + 1) % totalPages
        pageIndex = next
        progress = Double(next) / Double(totalPages - 1)
    }

    private var pageImage: String {
        ["sparkles", "wand.and.stars", "checkmark.seal.fill"][pageIndex]
    }
    private var pageTitle: String {
        ["Welcome", "Compose with primitives", "You're all set"][pageIndex]
    }
    private var pageBody: String {
        [
            "Tsumiki ships SwiftUI building blocks themed by a single environment value.",
            "Stack cards, dialogs, toasts and splashes to assemble feature flows.",
            "Pick a theme and start composing — the Catalog only consumes public API.",
        ][pageIndex]
    }
}
