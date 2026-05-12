import SwiftUI
import TsumikiTheme

public enum TsumikiButtonStyle: Sendable, Equatable {
    case primary, secondary, tertiary, destructive, ghost
}

public enum TsumikiButtonSize: Sendable, Equatable {
    case small, medium, large
}

public enum TsumikiButtonShape: Sendable, Equatable {
    case rounded, pill, circle
}

public enum TsumikiButtonLayout: Sendable, Equatable {
    case horizontal, vertical, iconOnly
}

public struct TsumikiButton: View {
    public let title: String?
    public let subtitle: String?
    public let icon: Image?
    public let trailingIcon: Image?
    public let style: TsumikiButtonStyle
    public let size: TsumikiButtonSize
    public let shape: TsumikiButtonShape
    public let layout: TsumikiButtonLayout
    public let isLoading: Bool
    public let isFullWidth: Bool
    public let badge: String?
    public let action: () -> Void

    @Environment(\.tsumikiTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    public init(
        _ title: String? = nil,
        subtitle: String? = nil,
        icon: Image? = nil,
        trailingIcon: Image? = nil,
        style: TsumikiButtonStyle = .primary,
        size: TsumikiButtonSize = .medium,
        shape: TsumikiButtonShape = .rounded,
        layout: TsumikiButtonLayout = .horizontal,
        isLoading: Bool = false,
        isFullWidth: Bool = false,
        badge: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.trailingIcon = trailingIcon
        self.style = style
        self.size = size
        self.shape = shape
        self.layout = layout
        self.isLoading = isLoading
        self.isFullWidth = isFullWidth
        self.badge = badge
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            labelContent
                .frame(maxWidth: isFullWidth ? .infinity : nil)
                .frame(width: shape == .circle ? circleEdge : nil,
                       height: shape == .circle ? circleEdge : nil)
                .padding(.horizontal, shape == .circle ? 0 : horizontalPadding)
                .padding(.vertical,   shape == .circle ? 0 : verticalPadding)
                .background(backgroundColor)
                .foregroundStyle(foregroundColor)
                .overlay(strokeOverlay)
                .clipShape(clipShape)
                .opacity(isEnabled ? 1.0 : theme.opacity.disabled)
                .overlay(alignment: .topTrailing) { badgeView }
        }
        .buttonStyle(.plain)
        .disabled(isLoading || !isEnabled)
    }

    @ViewBuilder
    private var labelContent: some View {
        if isLoading {
            ProgressView().tint(foregroundColor)
        } else {
            switch layout {
            case .horizontal:
                HStack(spacing: theme.spacing.sm) {
                    if let icon { icon }
                    if let title { titleStack }
                    if let trailingIcon { trailingIcon }
                }
            case .vertical:
                VStack(spacing: theme.spacing.xs) {
                    if let icon { icon }
                    if let title { titleStack }
                }
            case .iconOnly:
                icon ?? Image(systemName: "questionmark")
            }
        }
    }

    @ViewBuilder
    private var titleStack: some View {
        if let title {
            if let subtitle {
                VStack(alignment: .leading, spacing: 0) {
                    Text(title).font(titleFont)
                    Text(subtitle).font(theme.typography.caption)
                        .foregroundStyle(foregroundColor.opacity(0.8))
                }
            } else {
                Text(title).font(titleFont)
            }
        }
    }

    @ViewBuilder
    private var badgeView: some View {
        if let badge {
            Text(badge)
                .font(theme.typography.caption)
                .padding(.horizontal, theme.spacing.xs)
                .padding(.vertical, 0)
                .background(theme.colors.warning)
                .foregroundStyle(theme.colors.textPrimary)
                .clipShape(Capsule())
                .offset(x: theme.spacing.xs, y: -theme.spacing.xs)
        }
    }

    private var titleFont: Font {
        switch size {
        case .small:  return theme.typography.caption
        case .medium: return theme.typography.body
        case .large:  return theme.typography.headline
        }
    }

    private var horizontalPadding: CGFloat {
        switch size {
        case .small:  return theme.spacing.md
        case .medium: return theme.spacing.lg
        case .large:  return theme.spacing.xl
        }
    }

    private var verticalPadding: CGFloat {
        switch size {
        case .small:  return theme.spacing.xs
        case .medium: return theme.spacing.sm
        case .large:  return theme.spacing.md
        }
    }

    private var circleEdge: CGFloat {
        switch size {
        case .small:  return 32
        case .medium: return 44
        case .large:  return 56
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:     return theme.colors.accent
        case .secondary:   return theme.colors.surface
        case .tertiary:    return Color.clear
        case .destructive: return theme.colors.danger
        case .ghost:       return Color.clear
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary, .destructive: return theme.colors.background
        case .secondary, .tertiary:  return theme.colors.accent
        case .ghost:                 return theme.colors.textSecondary
        }
    }

    @ViewBuilder
    private var strokeOverlay: some View {
        if style == .secondary {
            clipShape.stroke(theme.colors.accent, lineWidth: 2)
        }
    }

    private var clipShape: AnyShape {
        switch shape {
        case .rounded: AnyShape(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous))
        case .pill:    AnyShape(RoundedRectangle(cornerRadius: theme.radius.pill, style: .continuous))
        case .circle:  AnyShape(Circle())
        }
    }
}
