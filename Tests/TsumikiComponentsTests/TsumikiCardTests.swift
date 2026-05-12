import XCTest
import SwiftUI
@testable import TsumikiComponents
import TsumikiTheme

#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class TsumikiCardTests: XCTestCase {
    func testInitDefaults() {
        let c = TsumikiCard { Text("Hi") }
        XCTAssertEqual(c.padding, .regular)
        XCTAssertEqual(c.elevation, .soft)
    }

    func testInitFull() {
        let c = TsumikiCard(padding: .generous, elevation: .elevated) { Text("Hi") }
        XCTAssertEqual(c.padding, .generous)
        XCTAssertEqual(c.elevation, .elevated)
    }

    #if canImport(UIKit)
    func testRendersForEachConfiguration() {
        let paddings: [TsumikiCardPadding] = [.none, .compact, .regular, .generous]
        let elevations: [TsumikiCardElevation] = [.flat, .soft, .elevated]
        for p in paddings {
            for e in elevations {
                let card = TsumikiCard(padding: p, elevation: e) {
                    Text("Hello")
                }.tsumikiTheme(DefaultTheme.light)
                let host = UIHostingController(rootView: card)
                host.view.layoutIfNeeded()
                XCTAssertNotNil(host.view)
            }
        }
    }
    #endif
}
