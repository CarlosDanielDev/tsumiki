import SwiftUI
import TsumikiTheme

public struct TsumikiShimmerModifier: ViewModifier {
    @Environment(\.tsumikiTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: CGFloat = 0

    public let duration: Double

    public init(duration: Double = 1.5) {
        self.duration = duration
    }

    public func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [
                            theme.colors.surface,
                            theme.colors.accent.opacity(0.25),
                            theme.colors.surface
                        ],
                        startPoint: .leading, endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 2)
                    .offset(x: -geo.size.width + (geo.size.width * 2 * phase))
                    .opacity(reduceMotion ? 0 : 1)
                }
                .mask(content)
            )
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

public extension View {
    func tsumikiShimmer(duration: Double = 1.5) -> some View {
        modifier(TsumikiShimmerModifier(duration: duration))
    }
}
