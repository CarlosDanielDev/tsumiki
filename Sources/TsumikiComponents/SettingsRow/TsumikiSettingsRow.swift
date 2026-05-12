import SwiftUI
import TsumikiTheme

public struct TsumikiSettingsRow: View {
    public enum Trailing {
        case chevron(action: () -> Void)
        case link(URL)
        case toggle(isOn: Binding<Bool>)
        case value(String, tone: ValueTone = .secondary)
        case none
    }

    public enum ValueTone: Sendable, Equatable {
        case primary, secondary, success, warning, danger
    }

    public enum IconTint: Sendable {
        case accent, success, warning, danger
        case custom(Color)
    }

    public let icon: Image
    public let iconTint: IconTint
    public let title: String
    public let subtitle: String?
    public let trailing: Trailing

    @Environment(\.tsumikiTheme) private var theme

    public init(icon: Image,
                iconTint: IconTint = .accent,
                title: String,
                subtitle: String? = nil,
                trailing: Trailing = .none) {
        self.icon = icon
        self.iconTint = iconTint
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing
    }

    public var body: some View {
        switch trailing {
        case .chevron(let action):
            Button(action: action) { content }.buttonStyle(.plain)
        case .link(let url):
            Link(destination: url) { content }
        default:
            content
        }
    }

    private var content: some View {
        HStack(spacing: theme.spacing.sm) {
            iconTile
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text(title)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
            Spacer()
            trailingView
        }
        .padding(.horizontal, theme.spacing.lg)
        .padding(.vertical, theme.spacing.md)
        .contentShape(Rectangle())
    }

    private var iconTile: some View {
        let tint = resolvedTint
        return icon
            .font(theme.typography.body)
            .foregroundStyle(tint)
            .frame(width: 28, height: 28)
            .background(tint.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous))
    }

    @ViewBuilder
    private var trailingView: some View {
        switch trailing {
        case .chevron:
            Image(systemName: "chevron.right")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
        case .link:
            Image(systemName: "arrow.up.right")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
        case .toggle(let isOn):
            Toggle("", isOn: isOn).labelsHidden().tint(theme.colors.accent)
        case .value(let text, let tone):
            Text(text)
                .font(theme.typography.body)
                .foregroundStyle(color(for: tone))
        case .none:
            EmptyView()
        }
    }

    private var resolvedTint: Color {
        switch iconTint {
        case .accent:        return theme.colors.accent
        case .success:       return theme.colors.success
        case .warning:       return theme.colors.warning
        case .danger:        return theme.colors.danger
        case .custom(let c): return c
        }
    }

    private func color(for tone: ValueTone) -> Color {
        switch tone {
        case .primary:   return theme.colors.textPrimary
        case .secondary: return theme.colors.textSecondary
        case .success:   return theme.colors.success
        case .warning:   return theme.colors.warning
        case .danger:    return theme.colors.danger
        }
    }
}
