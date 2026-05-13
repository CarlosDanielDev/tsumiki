import Foundation

/// Provider-neutral coordinator for interstitial ads.
///
/// Concrete adapters (Google Mobile Ads, AppLovin, etc.) live in apps — Tsumiki
/// imports no ad SDKs. The protocol exposes load/show lifecycle, a readiness
/// probe, and a paywall gating hook so premium users skip ads without each
/// adapter re-inventing the rule.
public protocol TsumikiAdsCoordinator: Sendable {
    /// `true` when an interstitial is loaded and presentable.
    var isReady: Bool { get }

    /// Prefetch an interstitial. Idempotent.
    func loadInterstitial()

    /// Present a loaded interstitial. No-op when `isReady` is false or paywall
    /// is active.
    func showInterstitialIfReady()

    /// Paywall gating hook. Call when premium/paywall state changes — adapters
    /// suppress ads while `active` is `true`.
    func setPaywallActive(_ active: Bool)
}
