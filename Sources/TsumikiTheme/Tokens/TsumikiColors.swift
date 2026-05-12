import SwiftUI

public struct TsumikiColors: Sendable {
    public var accent: Color
    public var background: Color
    public var surface: Color
    public var textPrimary: Color
    public var textSecondary: Color
    public var success: Color
    public var warning: Color
    public var danger: Color

    public init(accent: Color, background: Color, surface: Color,
                textPrimary: Color, textSecondary: Color,
                success: Color, warning: Color, danger: Color) {
        self.accent = accent
        self.background = background
        self.surface = surface
        self.textPrimary = textPrimary
        self.textSecondary = textSecondary
        self.success = success
        self.warning = warning
        self.danger = danger
    }
}
