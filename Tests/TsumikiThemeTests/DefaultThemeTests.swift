import XCTest
import SwiftUI
@testable import TsumikiTheme

final class DefaultThemeTests: XCTestCase {
    func testLightAndDarkAreDistinct() {
        XCTAssertNotEqual(DefaultTheme.light.colors.accent,
                          DefaultTheme.dark.colors.accent)
    }

    func testWithReturnsMutatedCopy() {
        let original = DefaultTheme.light
        let modified = original.with(\.colors.accent, .pink)
        XCTAssertEqual(modified.colors.accent, .pink)
        XCTAssertEqual(original.colors.accent, DefaultTheme.light.colors.accent)
    }

    func testSpacingDefaultsAreSane() {
        XCTAssertEqual(DefaultTheme.light.spacing.lg, 16)
        XCTAssertEqual(DefaultTheme.light.spacing.xxl, 32)
    }
}
