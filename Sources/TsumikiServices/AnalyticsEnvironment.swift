import SwiftUI

private struct TsumikiAnalyticsKey: EnvironmentKey {
    static let defaultValue: any TsumikiAnalytics = NoopTsumikiAnalytics()
}

public extension EnvironmentValues {
    var tsumikiAnalytics: any TsumikiAnalytics {
        get { self[TsumikiAnalyticsKey.self] }
        set { self[TsumikiAnalyticsKey.self] = newValue }
    }
}

public extension View {
    func tsumikiAnalytics(_ analytics: any TsumikiAnalytics) -> some View {
        environment(\.tsumikiAnalytics, analytics)
    }
}
