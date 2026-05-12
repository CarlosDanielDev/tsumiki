import SwiftUI
import TsumikiTheme

public struct TsumikiDialog<Content: View>: View {
    public enum Kind: Sendable, Equatable {
        case info, confirmation, success, warning, destructive
    }

    public let kind: Kind
    public let icon: Image?
    public let title: String
    public let message: String?
    public let actions: [TsumikiDialogAction]
    public let content: Content
    let onDismiss: () -> Void

    @Environment(\.tsumikiTheme) private var theme

    public init(kind: Kind = .info,
                icon: Image? = nil,
                title: String,
                message: String? = nil,
                actions: [TsumikiDialogAction] = [],
                @ViewBuilder content: () -> Content = { EmptyView() },
                onDismiss: @escaping () -> Void = {}) {
        self.kind = kind
        self.icon = icon
        self.title = title
        self.message = message
        self.actions = actions
        self.content = content()
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(spacing: theme.spacing.lg) {
            if let icon {
                icon
                    .font(theme.typography.title)
                    .foregroundStyle(headerTint)
                    .padding(theme.spacing.md)
                    .background(headerTint.opacity(0.15))
                    .clipShape(Circle())
                    .padding(.top, theme.spacing.lg)
            }
            VStack(spacing: theme.spacing.sm) {
                Text(title)
                    .font(theme.typography.title)
                    .foregroundStyle(theme.colors.textPrimary)
                    .multilineTextAlignment(.center)
                if let message {
                    Text(message)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, theme.spacing.lg)

            content

            VStack(spacing: theme.spacing.sm) {
                ForEach(actions) { action in
                    Button {
                        action.handler()
                        onDismiss()
                    } label: {
                        Text(action.title)
                            .font(theme.typography.body)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, theme.spacing.md)
                            .foregroundStyle(buttonForeground(action.style))
                            .background(buttonBackground(action.style))
                            .clipShape(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                                    .stroke(buttonStroke(action.style), lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.bottom, theme.spacing.lg)
        }
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))
        .shadow(color: theme.shadow.elevated.color,
                radius: theme.shadow.elevated.radius,
                x: theme.shadow.elevated.x,
                y: theme.shadow.elevated.y)
        .padding(theme.spacing.xl)
    }

    private var headerTint: Color {
        switch kind {
        case .info, .confirmation: return theme.colors.accent
        case .success:             return theme.colors.success
        case .warning:             return theme.colors.warning
        case .destructive:         return theme.colors.danger
        }
    }

    private func buttonBackground(_ style: TsumikiDialogAction.Style) -> Color {
        switch style {
        case .primary:     return theme.colors.accent
        case .destructive: return theme.colors.danger
        case .secondary, .cancel: return Color.clear
        }
    }

    private func buttonForeground(_ style: TsumikiDialogAction.Style) -> Color {
        switch style {
        case .primary, .destructive: return theme.colors.background
        case .secondary:             return theme.colors.accent
        case .cancel:                return theme.colors.textSecondary
        }
    }

    private func buttonStroke(_ style: TsumikiDialogAction.Style) -> Color {
        switch style {
        case .secondary: return theme.colors.accent
        default:         return Color.clear
        }
    }

    /// Tap-outside-to-dismiss is allowed only when a `.cancel` action exists
    /// AND `kind != .destructive`.
    public var allowsTapOutsideDismiss: Bool {
        guard kind != .destructive else { return false }
        return actions.contains { $0.style == .cancel }
    }
}
