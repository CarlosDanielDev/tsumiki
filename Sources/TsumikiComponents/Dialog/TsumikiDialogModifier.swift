import SwiftUI
import TsumikiTheme

public extension View {
    func tsumikiDialog<C: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder dialog: @escaping () -> TsumikiDialog<C>
    ) -> some View {
        modifier(TsumikiDialogModifier(isPresented: isPresented, dialog: dialog))
    }
}

private struct TsumikiDialogModifier<C: View>: ViewModifier {
    @Binding var isPresented: Bool
    let dialog: () -> TsumikiDialog<C>
    @Environment(\.tsumikiTheme) private var theme

    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                let resolved = dialog()
                theme.colors.scrim
                    .ignoresSafeArea()
                    .onTapGesture {
                        if resolved.allowsTapOutsideDismiss {
                            withAnimation(.easeOut(duration: 0.2)) { isPresented = false }
                        }
                    }
                    .transition(.opacity)
                resolved
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.3), value: isPresented)
    }
}
