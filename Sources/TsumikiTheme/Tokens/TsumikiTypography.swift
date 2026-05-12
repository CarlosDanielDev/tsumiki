import SwiftUI

public struct TsumikiTypography: Sendable {
    public var largeTitle: Font
    public var title: Font
    public var headline: Font
    public var body: Font
    public var caption: Font

    public init(largeTitle: Font, title: Font, headline: Font, body: Font, caption: Font) {
        self.largeTitle = largeTitle
        self.title = title
        self.headline = headline
        self.body = body
        self.caption = caption
    }
}
