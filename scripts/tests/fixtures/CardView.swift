import SwiftUI

public struct CardView: View {
    public let title: String

    public init(title: String) { self.title = title }

    public var body: some View {
        Text(title)
            .padding(16)
            .cornerRadius(12)
    }
}
