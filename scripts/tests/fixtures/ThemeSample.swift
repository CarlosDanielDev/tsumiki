import SwiftUI

extension Color {
    static let aquaBlue = Color(hex: "#0EA5E9")
    static let danger   = Color(red: 0.9, green: 0.2, blue: 0.2)
}

struct Sample: View {
    var body: some View {
        Text("hi")
            .font(.largeTitle.bold())
            .padding(16)
            .padding(.horizontal, 24)
            .cornerRadius(12)
    }
}
