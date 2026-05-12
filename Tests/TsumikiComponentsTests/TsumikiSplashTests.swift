import XCTest
import SwiftUI
@testable import TsumikiComponents
import TsumikiTheme

#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class TsumikiSplashTests: XCTestCase {
    func testInitDefaults() {
        let s = TsumikiSplash(logo: Image(systemName: "leaf"), onComplete: {})
        XCTAssertNil(s.title)
        XCTAssertNil(s.tagline)
        XCTAssertEqual(s.duration, 2.0)
        XCTAssertEqual(s.logoSize, 120)
    }

    func testInitFull() {
        let s = TsumikiSplash(
            logo: Image(systemName: "leaf"),
            title: "Tsumiki",
            tagline: "Plug and play",
            duration: 3.5,
            logoSize: 96,
            onComplete: {}
        )
        XCTAssertEqual(s.title, "Tsumiki")
        XCTAssertEqual(s.tagline, "Plug and play")
        XCTAssertEqual(s.duration, 3.5)
        XCTAssertEqual(s.logoSize, 96)
    }

    #if canImport(UIKit)
    func testRendersWithoutCrash() {
        let s = TsumikiSplash(logo: Image(systemName: "leaf"), onComplete: {})
            .tsumikiTheme(DefaultTheme.light)
        let host = UIHostingController(rootView: s)
        host.view.layoutIfNeeded()
        XCTAssertNotNil(host.view)
    }

    func testModifierRendersWithBinding() {
        var presented = true
        let binding = Binding(get: { presented }, set: { presented = $0 })
        let view = Color.clear.tsumikiSplash(
            isPresented: binding,
            logo: Image(systemName: "leaf"),
            title: "Hi"
        ).tsumikiTheme(DefaultTheme.light)
        let host = UIHostingController(rootView: view)
        host.view.layoutIfNeeded()
        XCTAssertTrue(presented)
        XCTAssertNotNil(host.view)
    }
    #endif
}
