import SwiftUI
import TsumikiComponents
import TsumikiTheme

struct DialogGallery: View {
    @Environment(\.tsumikiTheme) private var theme

    var body: some View {
        VStack(spacing: theme.spacing.xl) {
            TsumikiDialog(
                kind: .info,
                icon: Image(systemName: "info.circle"),
                title: "Heads up",
                message: "An informational dialog with a single dismiss action.",
                actions: [.primary("OK") {}]
            )

            TsumikiDialog(
                kind: .confirmation,
                icon: Image(systemName: "questionmark.circle"),
                title: "Confirm changes?",
                message: "Saving will overwrite the existing draft.",
                actions: [
                    .cancel(),
                    .primary("Save") {},
                ]
            )

            TsumikiDialog(
                kind: .destructive,
                icon: Image(systemName: "trash"),
                title: "Delete project?",
                message: "This action cannot be undone.",
                actions: [
                    .cancel(),
                    .destructive("Delete") {},
                ]
            )
        }
    }
}
