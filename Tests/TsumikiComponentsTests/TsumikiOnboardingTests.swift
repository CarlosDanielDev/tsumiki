import XCTest
import SwiftUI
@testable import TsumikiComponents
import TsumikiTheme

#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class TsumikiOnboardingActionTests: XCTestCase {
    func testInitStoresTitleAndAction() {
        var fired = 0
        let action = TsumikiOnboardingAction(title: "Continue") { fired += 1 }
        XCTAssertEqual(action.title, "Continue")
        action.action()
        XCTAssertEqual(fired, 1)
    }
}

@MainActor
final class TsumikiOnboardingPageTests: XCTestCase {
    func testSymbolInitMapsToSymbolIllustration() {
        let primary = TsumikiOnboardingAction(title: "Next") {}
        let page = TsumikiOnboardingPage(
            systemImage: "drop.fill",
            title: "Stay hydrated",
            body: "Track every glass.",
            subtitle: "Hydration",
            primaryAction: primary
        )
        XCTAssertEqual(page.title, "Stay hydrated")
        XCTAssertEqual(page.bodyText, "Track every glass.")
        XCTAssertEqual(page.subtitle, "Hydration")
        XCTAssertEqual(page.primaryAction.title, "Next")
        XCTAssertNil(page.secondaryAction)
        XCTAssertTrue(page.isActive)
    }

    func testSecondaryActionOptional() {
        let primary = TsumikiOnboardingAction(title: "Next") {}
        let secondary = TsumikiOnboardingAction(title: "Skip") {}
        let page = TsumikiOnboardingPage(
            systemImage: "bell",
            title: "Stay in the loop",
            body: "Optional reminders.",
            primaryAction: primary,
            secondaryAction: secondary
        )
        XCTAssertEqual(page.secondaryAction?.title, "Skip")
    }

    func testGenericIllustrationInit() {
        let primary = TsumikiOnboardingAction(title: "Begin") {}
        let page = TsumikiOnboardingPage(
            illustration: { Color.clear },
            title: "Hello",
            body: "World",
            subtitle: nil,
            primaryAction: primary,
            isActive: false
        )
        XCTAssertNil(page.subtitle)
        XCTAssertFalse(page.isActive)
    }

    #if canImport(UIKit)
    func testRendersWithAndWithoutSecondary() {
        let primary = TsumikiOnboardingAction(title: "Continue") {}
        let secondary = TsumikiOnboardingAction(title: "Skip") {}
        for sec in [secondary, nil] {
            let page = TsumikiOnboardingPage(
                systemImage: "sparkles",
                title: "Welcome",
                body: "Get started in seconds.",
                subtitle: "Tsumiki",
                primaryAction: primary,
                secondaryAction: sec
            )
            .tsumikiTheme(DefaultTheme.light)
            .frame(width: 320, height: 640)
            let host = UIHostingController(rootView: page)
            host.view.layoutIfNeeded()
            XCTAssertNotNil(host.view)
        }
    }
    #endif
}

@MainActor
final class TsumikiOnboardingDotsTests: XCTestCase {
    func testInitStoresCounts() {
        let d = TsumikiOnboardingDots(total: 4, current: 2)
        XCTAssertEqual(d.total, 4)
        XCTAssertEqual(d.current, 2)
        XCTAssertNil(d.onSelect)
    }

    func testClampedCurrentNeverExceedsBounds() {
        XCTAssertEqual(TsumikiOnboardingDots.clampedCurrent(-5, total: 3), 0)
        XCTAssertEqual(TsumikiOnboardingDots.clampedCurrent(99, total: 3), 2)
        XCTAssertEqual(TsumikiOnboardingDots.clampedCurrent(1, total: 3), 1)
        XCTAssertEqual(TsumikiOnboardingDots.clampedCurrent(0, total: 0), 0)
    }

    func testOnSelectClosureStored() {
        var picked: Int = -1
        let d = TsumikiOnboardingDots(total: 3, current: 0, onSelect: { picked = $0 })
        d.onSelect?(2)
        XCTAssertEqual(picked, 2)
    }

    #if canImport(UIKit)
    func testRendersAcrossPositions() {
        for current in 0..<4 {
            let view = TsumikiOnboardingDots(total: 4, current: current)
                .tsumikiTheme(DefaultTheme.light)
                .frame(width: 200, height: 32)
            let host = UIHostingController(rootView: view)
            host.view.layoutIfNeeded()
            XCTAssertNotNil(host.view)
        }
    }
    #endif
}

@MainActor
final class TsumikiOnboardingProgressBarTests: XCTestCase {
    func testInitStoresProgress() {
        let p = TsumikiOnboardingProgressBar(progress: 0.42)
        XCTAssertEqual(p.progress, 0.42, accuracy: 0.0001)
        XCTAssertTrue(p.showsTipGlow)
    }

    func testClampedProgressBoundaries() {
        XCTAssertEqual(TsumikiOnboardingProgressBar.clampedProgress(-1), 0, accuracy: 0.0001)
        XCTAssertEqual(TsumikiOnboardingProgressBar.clampedProgress(2.0), 1, accuracy: 0.0001)
        XCTAssertEqual(TsumikiOnboardingProgressBar.clampedProgress(0.75), 0.75, accuracy: 0.0001)
    }

    #if canImport(UIKit)
    func testRendersAcrossProgressValues() {
        for v in [-0.5, 0.0, 0.25, 0.5, 0.99, 1.5] {
            let view = TsumikiOnboardingProgressBar(progress: v, showsTipGlow: v < 1.5)
                .tsumikiTheme(DefaultTheme.light)
                .frame(width: 240, height: 8)
            let host = UIHostingController(rootView: view)
            host.view.layoutIfNeeded()
            XCTAssertNotNil(host.view)
        }
    }
    #endif
}
