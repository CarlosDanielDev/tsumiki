import SwiftUI

private struct TsumikiAdsCoordinatorKey: EnvironmentKey {
    static let defaultValue: any TsumikiAdsCoordinator = NoopTsumikiAdsCoordinator()
}

public extension EnvironmentValues {
    var tsumikiAdsCoordinator: any TsumikiAdsCoordinator {
        get { self[TsumikiAdsCoordinatorKey.self] }
        set { self[TsumikiAdsCoordinatorKey.self] = newValue }
    }
}

public extension View {
    func tsumikiAdsCoordinator(_ coordinator: any TsumikiAdsCoordinator) -> some View {
        environment(\.tsumikiAdsCoordinator, coordinator)
    }
}
