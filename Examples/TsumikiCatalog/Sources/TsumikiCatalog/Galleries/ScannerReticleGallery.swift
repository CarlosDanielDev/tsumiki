import SwiftUI
import TsumikiComponents
import TsumikiTheme

struct ScannerReticleGallery: View {
    @Environment(\.tsumikiTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xl) {
            heading("Brackets — scanning")
            TsumikiScannerReticle(
                shape: .square,
                state: .scanning,
                cornerStyle: .brackets,
                instructions: "Align QR within the frame",
                status: "Scanning…"
            )
            .frame(height: 320)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))

            heading("Continuous — success")
            TsumikiScannerReticle(
                shape: .rectangle(aspect: 16.0 / 9.0),
                state: .success,
                cornerStyle: .continuous,
                instructions: "Scan complete",
                status: "Decoded successfully"
            )
            .frame(height: 240)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))

            heading("Error state")
            TsumikiScannerReticle(
                shape: .square,
                state: .error,
                cornerStyle: .brackets,
                instructions: "Couldn't read code",
                status: "Try repositioning"
            )
            .frame(height: 280)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))
        }
    }

    @ViewBuilder
    private func heading(_ s: String) -> some View {
        Text(s).font(theme.typography.headline).foregroundStyle(theme.colors.textPrimary)
    }
}
