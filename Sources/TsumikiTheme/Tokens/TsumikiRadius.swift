import CoreGraphics

public struct TsumikiRadius: Sendable {
    public var sm: CGFloat
    public var md: CGFloat
    public var lg: CGFloat
    public var pill: CGFloat

    public init(sm: CGFloat, md: CGFloat, lg: CGFloat, pill: CGFloat) {
        self.sm = sm; self.md = md; self.lg = lg; self.pill = pill
    }
}
