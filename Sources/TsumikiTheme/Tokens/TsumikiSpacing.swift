import CoreGraphics

public struct TsumikiSpacing: Sendable {
    public var xs: CGFloat
    public var sm: CGFloat
    public var md: CGFloat
    public var lg: CGFloat
    public var xl: CGFloat
    public var xxl: CGFloat

    public init(xs: CGFloat, sm: CGFloat, md: CGFloat,
                lg: CGFloat, xl: CGFloat, xxl: CGFloat) {
        self.xs = xs; self.sm = sm; self.md = md
        self.lg = lg; self.xl = xl; self.xxl = xxl
    }
}
