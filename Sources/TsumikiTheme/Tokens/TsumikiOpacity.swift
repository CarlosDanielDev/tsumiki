import CoreGraphics

public struct TsumikiOpacity: Sendable {
    public var scrim: CGFloat
    public var overlay: CGFloat
    public var disabled: CGFloat

    public init(scrim: CGFloat = 0.5,
                overlay: CGFloat = 0.85,
                disabled: CGFloat = 0.4) {
        self.scrim = scrim
        self.overlay = overlay
        self.disabled = disabled
    }
}
