import SwiftUI
import TsumikiTheme

public struct TsumikiSkeleton: View {
    public enum Shape: Sendable, Equatable {
        case rectangle(cornerRadius: CGFloat? = nil)
        case circle
        case capsule
    }

    @Environment(\.tsumikiTheme) private var theme

    public let shape: Shape
    public let width: CGFloat?
    public let height: CGFloat

    public init(_ shape: Shape = .rectangle(),
                width: CGFloat? = nil,
                height: CGFloat) {
        self.shape = shape
        self.width = width
        self.height = height
    }

    public var body: some View {
        Group {
            switch shape {
            case .rectangle(let r):
                RoundedRectangle(cornerRadius: r ?? theme.radius.sm, style: .continuous)
                    .fill(theme.colors.surface)
            case .circle:
                Circle().fill(theme.colors.surface)
            case .capsule:
                Capsule().fill(theme.colors.surface)
            }
        }
        .frame(width: width, height: height)
        .tsumikiShimmer()
    }
}
