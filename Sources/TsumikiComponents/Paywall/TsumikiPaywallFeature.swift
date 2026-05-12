import SwiftUI

public struct TsumikiPaywallFeature: Identifiable {
    public let id: UUID
    public let icon: Image
    public let title: String
    public let subtitle: String?

    public init(id: UUID = UUID(), icon: Image, title: String, subtitle: String? = nil) {
        self.id = id
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }
}
