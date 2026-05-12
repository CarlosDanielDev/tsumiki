import SwiftUI
import TsumikiComponents
import TsumikiTheme

struct ToastGallery: View {
    @Environment(\.tsumikiTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            TsumikiToast(title: "Info message",    icon: Image(systemName: "info.circle"),       style: .info)
            TsumikiToast(title: "Saved",           icon: Image(systemName: "checkmark.circle"), style: .success)
            TsumikiToast(title: "Heads up",        icon: Image(systemName: "exclamationmark.triangle"), style: .warning)
            TsumikiToast(title: "Something broke", icon: Image(systemName: "xmark.octagon"),    style: .danger)
        }
    }
}
