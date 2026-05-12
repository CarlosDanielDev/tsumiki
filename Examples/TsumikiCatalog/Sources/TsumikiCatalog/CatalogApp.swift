import SwiftUI
import TsumikiTheme

@main
struct CatalogApp: App {
    @State private var themeChoice: CatalogThemeChoice = .light

    var body: some Scene {
        WindowGroup {
            CatalogRootView(themeChoice: $themeChoice)
                .tsumikiTheme(themeChoice.theme)
        }
    }
}
