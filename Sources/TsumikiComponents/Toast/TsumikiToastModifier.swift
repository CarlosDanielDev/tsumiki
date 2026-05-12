import SwiftUI
import TsumikiTheme

public extension View {
    func tsumikiToast<Toast: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder toast: @escaping () -> Toast
    ) -> some View {
        modifier(TsumikiToastModifier(isPresented: isPresented, toast: toast))
    }
}

private struct TsumikiToastModifier<Toast: View>: ViewModifier {
    @Binding var isPresented: Bool
    let toast: () -> Toast
    @Environment(\.tsumikiTheme) private var theme

    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                VStack {
                    Spacer()
                    toast()
                        .padding(.bottom, theme.spacing.xl)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.spring(duration: 0.3), value: isPresented)
            }
        }
    }
}
