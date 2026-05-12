import SwiftUI
import TsumikiTheme

public struct TsumikiSplash: View {
    public let logo: Image
    public let title: String?
    public let tagline: String?
    public let duration: TimeInterval
    public let logoSize: CGFloat
    public let onComplete: () -> Void

    @Environment(\.tsumikiTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    @State private var hasCompleted = false

    public init(
        logo: Image,
        title: String? = nil,
        tagline: String? = nil,
        duration: TimeInterval = 2.0,
        logoSize: CGFloat = 120,
        onComplete: @escaping () -> Void
    ) {
        self.logo = logo
        self.title = title
        self.tagline = tagline
        self.duration = duration
        self.logoSize = logoSize
        self.onComplete = onComplete
    }

    public var body: some View {
        ZStack {
            theme.colors.background.ignoresSafeArea()

            VStack(spacing: theme.spacing.md) {
                logo
                    .resizable()
                    .scaledToFit()
                    .frame(width: logoSize, height: logoSize)
                    .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))
                    .scaleEffect(scale)
                    .opacity(opacity)

                if let title {
                    Text(title)
                        .font(theme.typography.title)
                        .foregroundStyle(theme.colors.textPrimary)
                        .opacity(opacity)
                }

                if let tagline {
                    Text(tagline)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .opacity(opacity)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, theme.spacing.lg)
                }
            }
        }
        .task { await runLifecycle() }
    }

    private func runLifecycle() async {
        if reduceMotion {
            scale = 1.0
            opacity = 1.0
        } else {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { scale = 1.0 }
            withAnimation(.easeIn(duration: 0.4).delay(0.2))           { opacity = 1.0 }
        }
        try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
        guard !hasCompleted else { return }
        hasCompleted = true
        onComplete()
    }
}
