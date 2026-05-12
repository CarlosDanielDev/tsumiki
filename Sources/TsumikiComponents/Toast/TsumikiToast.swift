import SwiftUI
import TsumikiTheme

public struct TsumikiToast: View {
    public enum Style: Sendable, Equatable {
        case info, success, warning, danger
    }

    public let title: String
    public let icon: Image?
    public let duration: TimeInterval
    public let style: Style

    @Environment(\.tsumikiTheme) private var theme

    public init(title: String,
                icon: Image? = nil,
                duration: TimeInterval = 2.0,
                style: Style = .info) {
        self.title = title
        self.icon = icon
        self.duration = duration
        self.style = style
    }

    public var body: some View {
        HStack(spacing: theme.spacing.sm) {
            if let icon { icon }
            Text(title).font(theme.typography.body)
        }
        .padding(.horizontal, theme.spacing.lg)
        .padding(.vertical,   theme.spacing.md)
        .background(backgroundColor)
        .foregroundStyle(theme.colors.textPrimary)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous))
        .shadow(color: theme.shadow.soft.color,
                radius: theme.shadow.soft.radius,
                x: theme.shadow.soft.x,
                y: theme.shadow.soft.y)
    }

    private var backgroundColor: Color {
        switch style {
        case .info:    return theme.colors.surface
        case .success: return theme.colors.success
        case .warning: return theme.colors.warning
        case .danger:  return theme.colors.danger
        }
    }
}
