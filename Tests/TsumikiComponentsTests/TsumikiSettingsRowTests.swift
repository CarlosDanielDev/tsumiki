import XCTest
import SwiftUI
@testable import TsumikiComponents
import TsumikiTheme

#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class TsumikiSettingsRowTests: XCTestCase {
    func testInitMinimal() {
        let row = TsumikiSettingsRow(icon: Image(systemName: "gear"), title: "Settings")
        XCTAssertEqual(row.title, "Settings")
        XCTAssertNil(row.subtitle)
    }

    func testInitWithSubtitle() {
        let row = TsumikiSettingsRow(
            icon: Image(systemName: "bell"),
            iconTint: .warning,
            title: "Notifications",
            subtitle: "Daily 9am reminder"
        )
        XCTAssertEqual(row.subtitle, "Daily 9am reminder")
    }

    func testValueToneDefault() {
        let trailing: TsumikiSettingsRow.Trailing = .value("v1.0")
        if case .value(let text, let tone) = trailing {
            XCTAssertEqual(text, "v1.0")
            XCTAssertEqual(tone, .secondary)
        } else {
            XCTFail("expected .value")
        }
    }

    #if canImport(UIKit)
    func testEachTrailingRendersWithoutCrash() {
        let trailings: [TsumikiSettingsRow.Trailing] = [
            .none,
            .chevron(action: {}),
            .link(URL(string: "https://example.com")!),
            .value("100%"),
            .value("danger", tone: .danger),
        ]
        for t in trailings {
            let row = TsumikiSettingsRow(
                icon: Image(systemName: "gear"),
                title: "Title",
                trailing: t
            ).tsumikiTheme(DefaultTheme.light)
            let host = UIHostingController(rootView: row)
            host.view.layoutIfNeeded()
            XCTAssertNotNil(host.view)
        }
    }

    func testToggleTrailingRendersWithoutCrash() {
        var on = false
        let binding = Binding(get: { on }, set: { on = $0 })
        let row = TsumikiSettingsRow(
            icon: Image(systemName: "moon"),
            title: "Dark Mode",
            trailing: .toggle(isOn: binding)
        ).tsumikiTheme(DefaultTheme.light)
        let host = UIHostingController(rootView: row)
        host.view.layoutIfNeeded()
        XCTAssertNotNil(host.view)
    }
    #endif
}
