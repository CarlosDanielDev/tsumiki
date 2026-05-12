import SwiftUI
import TsumikiTheme

public extension View {
    func tsumikiSplash(
        isPresented: Binding<Bool>,
        logo: Image,
        title: String? = nil,
        tagline: String? = nil,
        duration: TimeInterval = 2.0
    ) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                TsumikiSplash(
                    logo: logo,
                    title: title,
                    tagline: tagline,
                    duration: duration
                ) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isPresented.wrappedValue = false
                    }
                }
                .transition(.opacity)
            }
        }
    }
}
