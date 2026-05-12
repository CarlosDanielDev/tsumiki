import SwiftUI
import TsumikiTheme

enum CatalogThemeChoice: String, CaseIterable, Identifiable {
    case light
    case dark
    case sakura

    var id: String { rawValue }

    var label: String {
        switch self {
        case .light:  return "Light"
        case .dark:   return "Dark"
        case .sakura: return "Sakura"
        }
    }

    var theme: any TsumikiTheme {
        switch self {
        case .light:
            return DefaultTheme.light
        case .dark:
            return DefaultTheme.dark
        case .sakura:
            return Self.makeSakura()
        }
    }

    private static func makeSakura() -> DefaultTheme {
        var t = DefaultTheme.light
        t.colors.accent      = Color(red: 0.94, green: 0.40, blue: 0.55)
        t.colors.background  = Color(red: 1.00, green: 0.96, blue: 0.97)
        t.colors.surface     = Color(red: 0.99, green: 0.92, blue: 0.94)
        t.colors.textPrimary = Color(red: 0.20, green: 0.10, blue: 0.15)
        t.radius             = TsumikiRadius(sm: 8, md: 16, lg: 24, pill: 999)
        return t
    }
}
