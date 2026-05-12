import SwiftUI

public struct DefaultTheme: TsumikiTheme {
    public var colors: TsumikiColors
    public var typography: TsumikiTypography
    public var spacing: TsumikiSpacing
    public var radius: TsumikiRadius
    public var shadow: TsumikiShadow
    public var opacity: TsumikiOpacity

    public init(colors: TsumikiColors, typography: TsumikiTypography,
                spacing: TsumikiSpacing, radius: TsumikiRadius,
                shadow: TsumikiShadow,
                opacity: TsumikiOpacity = TsumikiOpacity()) {
        self.colors = colors
        self.typography = typography
        self.spacing = spacing
        self.radius = radius
        self.shadow = shadow
        self.opacity = opacity
    }

    public func with<V>(_ keyPath: WritableKeyPath<DefaultTheme, V>, _ value: V) -> DefaultTheme {
        var copy = self
        copy[keyPath: keyPath] = value
        return copy
    }
}

public extension DefaultTheme {
    static let light = DefaultTheme(
        colors: TsumikiColors(
            accent: .blue,
            background: Color(white: 1.0),
            surface: Color(white: 0.95),
            textPrimary: .primary,
            textSecondary: .secondary,
            success: .green,
            warning: .yellow,
            danger: .red,
            scrim: .black.opacity(0.4)
        ),
        typography: TsumikiTypography(
            largeTitle: .largeTitle,
            title: .title,
            headline: .headline,
            body: .body,
            caption: .caption
        ),
        spacing: TsumikiSpacing(xs: 4, sm: 8, md: 12, lg: 16, xl: 24, xxl: 32),
        radius:  TsumikiRadius(sm: 6, md: 12, lg: 20, pill: 999),
        shadow:  TsumikiShadow(
            soft:     ShadowStyle(color: .black.opacity(0.08), radius: 4,  x: 0, y: 2),
            elevated: ShadowStyle(color: .black.opacity(0.16), radius: 12, x: 0, y: 6)
        )
    )

    static let dark: DefaultTheme = {
        var t = DefaultTheme.light
        t.colors.background = .black
        t.colors.surface    = Color(white: 0.12)
        t.colors.accent     = .teal
        t.colors.scrim      = .black.opacity(0.6)
        return t
    }()
}
