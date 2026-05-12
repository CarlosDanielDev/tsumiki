public struct TsumikiPaywallPrice: Sendable, Equatable {
    public let headline: String
    public let caption: String?
    public let badge: String?

    public init(headline: String, caption: String? = nil, badge: String? = nil) {
        self.headline = headline
        self.caption = caption
        self.badge = badge
    }
}
