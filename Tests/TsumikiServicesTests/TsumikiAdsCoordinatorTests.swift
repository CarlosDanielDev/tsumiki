import XCTest
import SwiftUI
@testable import TsumikiServices

final class TsumikiAdsCoordinatorTests: XCTestCase {
    func testNoopConformsToProtocol() {
        let ads: any TsumikiAdsCoordinator = NoopTsumikiAdsCoordinator()
        ads.loadInterstitial()
        ads.showInterstitialIfReady()
        _ = ads.isReady
        ads.setPaywallActive(true)
        ads.setPaywallActive(false)
    }

    func testNoopIsNeverReady() {
        let ads = NoopTsumikiAdsCoordinator()
        XCTAssertFalse(ads.isReady)
        ads.loadInterstitial()
        XCTAssertFalse(ads.isReady, "Noop must never report ready — there is no inventory.")
    }

    func testCustomWitnessReceivesCalls() {
        let spy = SpyAdsCoordinator()
        let ads: any TsumikiAdsCoordinator = spy

        ads.loadInterstitial()
        ads.loadInterstitial()
        ads.showInterstitialIfReady()
        ads.setPaywallActive(true)

        XCTAssertEqual(spy.loadCount, 2)
        XCTAssertEqual(spy.showCount, 1)
        XCTAssertEqual(spy.paywallStates, [true])
    }

    func testWitnessIsReadyReflectsState() {
        let spy = SpyAdsCoordinator()
        XCTAssertFalse(spy.isReady)
        spy.readyOverride = true
        XCTAssertTrue(spy.isReady)
    }

    func testPaywallGateSuppressesShowOnWitness() {
        let spy = SpyAdsCoordinator()
        spy.readyOverride = true
        spy.setPaywallActive(true)

        spy.showInterstitialIfReady()

        XCTAssertEqual(spy.showCount, 1, "Witness still receives the call…")
        XCTAssertEqual(spy.presentedCount, 0, "…but presentation is gated by paywall.")
    }

    func testEnvironmentDefaultIsNoop() {
        let env = EnvironmentValues()
        XCTAssertTrue(env.tsumikiAdsCoordinator is NoopTsumikiAdsCoordinator)
    }

    func testEnvironmentInjection() {
        var env = EnvironmentValues()
        let spy = SpyAdsCoordinator()
        env.tsumikiAdsCoordinator = spy

        env.tsumikiAdsCoordinator.loadInterstitial()

        XCTAssertEqual(spy.loadCount, 1)
    }

    func testNoopIsSendable() {
        let noop = NoopTsumikiAdsCoordinator()
        let sendable: @Sendable () -> Void = { noop.loadInterstitial() }
        sendable()
    }
}

// MARK: - Helpers

private final class SpyAdsCoordinator: TsumikiAdsCoordinator, @unchecked Sendable {
    var readyOverride = false
    private(set) var loadCount = 0
    private(set) var showCount = 0
    private(set) var presentedCount = 0
    private(set) var paywallStates: [Bool] = []
    private var paywallActive = false

    var isReady: Bool { readyOverride }

    func loadInterstitial() {
        loadCount += 1
    }

    func showInterstitialIfReady() {
        showCount += 1
        guard isReady, !paywallActive else { return }
        presentedCount += 1
    }

    func setPaywallActive(_ active: Bool) {
        paywallStates.append(active)
        paywallActive = active
    }
}
