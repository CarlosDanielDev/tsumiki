import SwiftUI
import TsumikiComponents
import TsumikiTheme

struct SettingsRowGallery: View {
    @Environment(\.tsumikiTheme) private var theme
    @State private var notifications = true
    @State private var analytics = false

    var body: some View {
        VStack(spacing: 0) {
            TsumikiSettingsRow(
                icon: Image(systemName: "bell"),
                iconTint: .accent,
                title: "Notifications",
                subtitle: "Daily summary",
                trailing: .toggle(isOn: $notifications)
            )
            divider
            TsumikiSettingsRow(
                icon: Image(systemName: "chart.bar"),
                iconTint: .success,
                title: "Analytics",
                subtitle: "Help improve the app",
                trailing: .toggle(isOn: $analytics)
            )
            divider
            TsumikiSettingsRow(
                icon: Image(systemName: "icloud"),
                iconTint: .accent,
                title: "iCloud",
                trailing: .value("On", tone: .success)
            )
            divider
            TsumikiSettingsRow(
                icon: Image(systemName: "person.crop.circle"),
                iconTint: .accent,
                title: "Account",
                subtitle: "user@example.com",
                trailing: .chevron(action: {})
            )
            divider
            TsumikiSettingsRow(
                icon: Image(systemName: "questionmark.circle"),
                iconTint: .warning,
                title: "Help",
                trailing: .link(URL(string: "https://example.com/help")!)
            )
            divider
            TsumikiSettingsRow(
                icon: Image(systemName: "trash"),
                iconTint: .danger,
                title: "Delete account",
                trailing: .chevron(action: {})
            )
        }
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))
    }

    private var divider: some View {
        Rectangle()
            .fill(theme.colors.textSecondary.opacity(0.15))
            .frame(height: 1)
            .padding(.leading, theme.spacing.lg)
    }
}
