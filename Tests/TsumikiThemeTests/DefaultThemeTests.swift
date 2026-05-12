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

    func testOpacityTokenIsExposedOnLightAndDark() {
        XCTAssertEqual(DefaultTheme.light.opacity.disabled, 0.4)
        XCTAssertEqual(DefaultTheme.dark.opacity.scrim, 0.5)
    }

    func testOpacityOverrideViaWithKeyPath() {
        let modified = DefaultTheme.light.with(\.opacity.disabled, 0.25)
        XCTAssertEqual(modified.opacity.disabled, 0.25)
        XCTAssertEqual(DefaultTheme.light.opacity.disabled, 0.4)
    }
}
