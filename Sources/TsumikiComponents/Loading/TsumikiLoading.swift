import SwiftUI
import TsumikiTheme

public struct TsumikiLoading: View {
    public enum Size: Sendable, Equatable { case compact, regular, large }

    public let label: String?
    public let size: Size
    public let onCancel: (() -> Void)?

    @Environment(\.tsumikiTheme) private var theme

    public init(label: String? = nil,
                size: Size = .regular,
                onCancel: (() -> Void)? = nil) {
        self.label = label
        self.size = size
        self.onCancel = onCancel
    }

    public var body: some View {
        VStack(spacing: theme.spacing.md) {
            ProgressView()
                .tint(theme.colors.accent)
                .scaleEffect(scale)
            if let label {
                Text(label)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
            }
            if let onCancel {
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.accent)
                        .padding(.horizontal, theme.spacing.lg)
                        .padding(.vertical, theme.spacing.sm)
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                                .stroke(theme.colors.accent, lineWidth: 2)
                        )
                }
                .padding(.top, theme.spacing.xs)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label ?? "Loading")
    }

    private var scale: CGFloat {
        switch size {
        case .compact: return 0.7
        case .regular: return 1.0
        case .large:   return 1.5
        }
    }
}
