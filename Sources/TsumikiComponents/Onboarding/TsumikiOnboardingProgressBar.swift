import SwiftUI
import TsumikiTheme

public struct TsumikiOnboardingProgressBar: View {
    public let progress: Double
    public let accentTint: Color?
    public let showsTipGlow: Bool

    @Environment(\.tsumikiTheme) private var theme

    public init(progress: Double,
                accentTint: Color? = nil,
                showsTipGlow: Bool = true) {
        self.progress = progress
        self.accentTint = accentTint
        self.showsTipGlow = showsTipGlow
    }

    public static func clampedProgress(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }

    public var body: some View {
        let accent = accentTint ?? theme.colors.accent
        let p = Self.clampedProgress(progress)

        GeometryReader { proxy in
            let w = proxy.size.width
            let h = max(proxy.size.height, 4)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(accent.opacity(0.2))
                    .frame(height: h)

                Capsule()
                    .fill(LinearGradient(
                        colors: [accent.opacity(0.8), accent],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: w * p, height: h)

                if showsTipGlow && p > 0 {
                    Circle()
                        .fill(accent)
                        .frame(width: h * 2, height: h * 2)
                        .shadow(color: accent.opacity(0.6), radius: 4, x: 0, y: 0)
                        .offset(x: max(w * p - h, 0))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: p)
        }
        .frame(height: 4)
        .accessibilityHidden(true)
    }
}
