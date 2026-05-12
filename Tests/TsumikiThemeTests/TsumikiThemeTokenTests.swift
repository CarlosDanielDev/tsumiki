import XCTest
import SwiftUI
@testable import TsumikiTheme

final class TsumikiThemeTokenTests: XCTestCase {
    func testColorsExposesEightSemanticSlots() {
        let c = TsumikiColors(
            accent: .blue, background: .white, surface: .gray,
            textPrimary: .black, textSecondary: .gray,
            success: .green, warning: .yellow, danger: .red
        )
        XCTAssertEqual(c.accent, .blue)
        XCTAssertEqual(c.danger, .red)
    }

    func testSpacingHasSixSlotsAscending() {
        let s = TsumikiSpacing(xs: 4, sm: 8, md: 12, lg: 16, xl: 24, xxl: 32)
        XCTAssertLessThan(s.xs, s.sm)
        XCTAssertLessThan(s.lg, s.xl)
    }

    func testRadiusPillIsLarge() {
        let r = TsumikiRadius(sm: 6, md: 12, lg: 20, pill: 999)
        XCTAssertGreaterThan(r.pill, r.lg)
    }

    func testShadowStyleStoresColorAndOffsets() {
        let s = ShadowStyle(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        XCTAssertEqual(s.radius, 4)
        XCTAssertEqual(s.y, 2)
    }
}
