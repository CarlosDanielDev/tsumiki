import Foundation

/// Default `TsumikiAdsCoordinator` that loads nothing and shows nothing.
///
/// Used as the environment default so views that read `\.tsumikiAdsCoordinator`
/// work without an adapter wired up. In DEBUG builds, calls are logged so
/// integrators can see the surface is being exercised.
public struct NoopTsumikiAdsCoordinator: TsumikiAdsCoordinator {
    public init() {}

    public var isReady: Bool { false }

    public func loadInterstitial() {
        #if DEBUG
        Self.log("loadInterstitial")
        #endif
    }

    public func showInterstitialIfReady() {
        #if DEBUG
        Self.log("showInterstitialIfReady")
        #endif
    }

    public func setPaywallActive(_ active: Bool) {
        #if DEBUG
        Self.log("setPaywallActive(\(active))")
        #endif
    }

    #if DEBUG
    private static func log(_ message: String) {
        print("[TsumikiAdsCoordinator] \(message)")
    }
    #endif
}
