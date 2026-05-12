import SwiftUI

public struct ToastView: View {
    public let title: String
    public var icon: Image?
    public var duration: TimeInterval = 2.0

    public init(title: String, icon: Image? = nil, duration: TimeInterval = 2.0) {
        self.title = title
        self.icon = icon
        self.duration = duration
    }

    public var body: some View {
        HStack {
            if let icon { icon }
            Text(title)
                .font(.body)
                .foregroundStyle(Color.aquaBlue)
                .padding(12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

private struct ToastModifier: ViewModifier {
    func body(content: Content) -> some View { content }
}
