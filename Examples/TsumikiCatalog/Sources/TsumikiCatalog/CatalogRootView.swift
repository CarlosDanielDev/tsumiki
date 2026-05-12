import SwiftUI
import TsumikiTheme

struct CatalogEntry: Identifiable {
    let id = UUID()
    let title: String
    let systemImage: String
    let view: AnyView
}

struct CatalogRootView: View {
    @Binding var themeChoice: CatalogThemeChoice
    @Environment(\.tsumikiTheme) private var theme

    private var entries: [CatalogEntry] {
        [
            CatalogEntry(title: "Button",         systemImage: "rectangle.and.hand.point.up.left", view: AnyView(ButtonGallery())),
            CatalogEntry(title: "Card",           systemImage: "rectangle.stack",                  view: AnyView(CardGallery())),
            CatalogEntry(title: "Toast",          systemImage: "bell.badge",                       view: AnyView(ToastGallery())),
            CatalogEntry(title: "Loading",        systemImage: "arrow.triangle.2.circlepath",      view: AnyView(LoadingGallery())),
            CatalogEntry(title: "Dialog",         systemImage: "exclamationmark.bubble",           view: AnyView(DialogGallery())),
            CatalogEntry(title: "Splash",         systemImage: "sparkles",                         view: AnyView(SplashGallery())),
            CatalogEntry(title: "OnboardingPage", systemImage: "hand.wave",                        view: AnyView(OnboardingGallery())),
            CatalogEntry(title: "Paywall",        systemImage: "creditcard",                       view: AnyView(PaywallGallery())),
            CatalogEntry(title: "ScannerReticle", systemImage: "qrcode.viewfinder",                view: AnyView(ScannerReticleGallery())),
            CatalogEntry(title: "SettingsRow",    systemImage: "gearshape",                        view: AnyView(SettingsRowGallery())),
        ]
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Theme") {
                    Picker("Theme", selection: $themeChoice) {
                        ForEach(CatalogThemeChoice.allCases) { choice in
                            Text(choice.label).tag(choice)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Components") {
                    ForEach(entries) { entry in
                        NavigationLink {
                            ScrollView {
                                entry.view
                                    .padding(theme.spacing.lg)
                            }
                            .background(theme.colors.background.ignoresSafeArea())
                            .navigationTitle(entry.title)
                        } label: {
                            Label(entry.title, systemImage: entry.systemImage)
                        }
                    }
                }
            }
            .navigationTitle("Tsumiki Catalog")
        }
    }
}
