public struct TsumikiShadow: Sendable {
    public var soft: ShadowStyle
    public var elevated: ShadowStyle

    public init(soft: ShadowStyle, elevated: ShadowStyle) {
        self.soft = soft; self.elevated = elevated
    }
}
