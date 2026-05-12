import XCTest
import SwiftUI
@testable import TsumikiComponents
import TsumikiTheme

#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class TsumikiPaywallTests: XCTestCase {
    func testFeatureInit() {
        let f = TsumikiPaywallFeature(icon: Image(systemName: "star"),
                                      title: "Pro features",
                                      subtitle: "Unlock everything")
        XCTAssertEqual(f.title, "Pro features")
        XCTAssertEqual(f.subtitle, "Unlock everything")
    }

    func testPriceEquality() {
        let a = TsumikiPaywallPrice(headline: "$4.99 / mo", caption: "7-day trial", badge: "BEST")
        let b = TsumikiPaywallPrice(headline: "$4.99 / mo", caption: "7-day trial", badge: "BEST")
        XCTAssertEqual(a, b)
    }

    func testPaywallInitDefaults() {
        let p = TsumikiPaywall(
            title: "Go Pro",
            features: [],
            price: TsumikiPaywallPrice(headline: "$1"),
            onPurchase: {},
            onRestore: {}
        )
        XCTAssertEqual(p.ctaTitle, "Continue")
        XCTAssertFalse(p.isPurchasing)
        XCTAssertNil(p.onDismiss)
    }

    #if canImport(UIKit)
    func testRendersWithFeatures() {
        let features = (0..<3).map { i in
            TsumikiPaywallFeature(icon: Image(systemName: "checkmark"),
                                  title: "Feature \(i)",
                                  subtitle: i == 0 ? "Subtitle" : nil)
        }
        let view = TsumikiPaywall(
            title: "Tsumiki Pro",
            subtitle: "Build faster",
            features: features,
            price: TsumikiPaywallPrice(headline: "$4.99 / mo", caption: "7-day trial", badge: "BEST VALUE"),
            ctaTitle: "Start Trial",
            isPurchasing: false,
            onPurchase: {}, onRestore: {}, onDismiss: {}
        ).tsumikiTheme(DefaultTheme.light)
        let host = UIHostingController(rootView: view)
        host.view.layoutIfNeeded()
        XCTAssertNotNil(host.view)
    }

    func testRendersWhilePurchasing() {
        let view = TsumikiPaywall(
            title: "Go Pro",
            features: [],
            price: TsumikiPaywallPrice(headline: "$1"),
            isPurchasing: true,
            onPurchase: {}, onRestore: {}
        ).tsumikiTheme(DefaultTheme.light)
        let host = UIHostingController(rootView: view)
        host.view.layoutIfNeeded()
        XCTAssertNotNil(host.view)
    }
    #endif
}
