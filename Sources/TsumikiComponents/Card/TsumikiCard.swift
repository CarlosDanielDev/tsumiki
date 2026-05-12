import SwiftUI
import TsumikiTheme

public enum TsumikiCardPadding: Sendable, Equatable { case none, compact, regular, generous }
public enum TsumikiCardElevation: Sendable, Equatable { case flat, soft, elevated }

public struct TsumikiCard<Content: View>: View {
    public let padding: TsumikiCardPadding
    public let elevation: TsumikiCardElevation
    public let content: Content

    @Environment(\.tsumikiTheme) private var theme

    public init(padding: TsumikiCardPadding = .regular,
                elevation: TsumikiCardElevation = .soft,
                @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.elevation = elevation
        self.content = content()
    }

    public var body: some View {
        content
            .padding(paddingValue)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous))
            .modifier(TsumikiCardShadowModifier(elevation: elevation))
    }

    private var paddingValue: CGFloat {
        switch padding {
        case .none:     return 0
        case .compact:  return theme.spacing.sm
        case .regular:  return theme.spacing.md
        case .generous: return theme.spacing.lg
        }
    }
}

private struct TsumikiCardShadowModifier: ViewModifier {
    @Environment(\.tsumikiTheme) private var theme
    let elevation: TsumikiCardElevation

    func body(content: Content) -> some View {
        switch elevation {
        case .flat:
            content
        case .soft:
            content.shadow(color: theme.shadow.soft.color,
                           radius: theme.shadow.soft.radius,
                           x: theme.shadow.soft.x,
                           y: theme.shadow.soft.y)
        case .elevated:
            content.shadow(color: theme.shadow.elevated.color,
                           radius: theme.shadow.elevated.radius,
                           x: theme.shadow.elevated.x,
                           y: theme.shadow.elevated.y)
        }
    }
}
