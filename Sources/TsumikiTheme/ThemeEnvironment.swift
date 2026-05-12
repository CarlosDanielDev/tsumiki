import SwiftUI

private struct TsumikiThemeKey: EnvironmentKey {
    static let defaultValue: any TsumikiTheme = DefaultTheme.light
}

public extension EnvironmentValues {
    var tsumikiTheme: any TsumikiTheme {
        get { self[TsumikiThemeKey.self] }
        set { self[TsumikiThemeKey.self] = newValue }
    }
}

public extension View {
    func tsumikiTheme(_ theme: any TsumikiTheme) -> some View {
        environment(\.tsumikiTheme, theme)
    }
}
