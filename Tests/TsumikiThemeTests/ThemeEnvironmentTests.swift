import XCTest
import SwiftUI
@testable import TsumikiTheme

@MainActor
final class ThemeEnvironmentTests: XCTestCase {
    struct Probe: View {
        @Environment(\.tsumikiTheme) var theme
        let onResolve: (any TsumikiTheme) -> Void
        var body: some View {
            Color.clear.onAppear { onResolve(theme) }
        }
    }

    #if canImport(UIKit)
    func testDefaultThemeIsLight() {
        let exp = expectation(description: "resolve")
        let view = Probe { resolved in
            XCTAssertEqual(resolved.spacing.lg, DefaultTheme.light.spacing.lg)
            exp.fulfill()
        }
        let host = UIHostingController(rootView: view)
        host.view.layoutIfNeeded()
        wait(for: [exp], timeout: 1)
    }

    func testInjectedThemeOverridesDefault() {
        let exp = expectation(description: "resolve")
        let custom = DefaultTheme.light.with(\.spacing.lg, 99)
        let view = Probe { resolved in
            XCTAssertEqual(resolved.spacing.lg, 99)
            exp.fulfill()
        }.tsumikiTheme(custom)
        let host = UIHostingController(rootView: view)
        host.view.layoutIfNeeded()
        wait(for: [exp], timeout: 1)
    }
    #endif
}
