import XCTest
import SwiftUI
@testable import TsumikiComponents
import TsumikiTheme

#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class TsumikiButtonTests: XCTestCase {
    func testInitDefaults() {
        let b = TsumikiButton("Tap", action: {})
        XCTAssertEqual(b.title, "Tap")
        XCTAssertNil(b.icon)
        XCTAssertEqual(b.style, .primary)
        XCTAssertEqual(b.size, .medium)
        XCTAssertEqual(b.shape, .rounded)
        XCTAssertEqual(b.layout, .horizontal)
        XCTAssertFalse(b.isLoading)
        XCTAssertFalse(b.isFullWidth)
        XCTAssertNil(b.badge)
    }

    func testInitFullParams() {
        let b = TsumikiButton(
            "Save",
            subtitle: "+1 reward",
            icon: Image(systemName: "checkmark"),
            trailingIcon: Image(systemName: "chevron.right"),
            style: .secondary,
            size: .large,
            shape: .pill,
            layout: .horizontal,
            isLoading: true,
            isFullWidth: true,
            badge: "3",
            action: {}
        )
        XCTAssertEqual(b.subtitle, "+1 reward")
        XCTAssertEqual(b.style, .secondary)
        XCTAssertEqual(b.size, .large)
        XCTAssertEqual(b.shape, .pill)
        XCTAssertTrue(b.isLoading)
        XCTAssertTrue(b.isFullWidth)
        XCTAssertEqual(b.badge, "3")
    }

    #if canImport(UIKit)
    func testRendersForEveryStyle() {
        for style in [TsumikiButtonStyle.primary, .secondary, .tertiary, .destructive, .ghost] {
            let view = TsumikiButton("Hi", icon: Image(systemName: "star"), style: style, action: {})
                .tsumikiTheme(DefaultTheme.light)
            let host = UIHostingController(rootView: view)
            host.view.layoutIfNeeded()
            XCTAssertNotNil(host.view)
        }
    }

    func testRendersForEveryShape() {
        for shape in [TsumikiButtonShape.rounded, .pill, .circle] {
            let view = TsumikiButton("Go", icon: Image(systemName: "arrow.right"), shape: shape, action: {})
                .tsumikiTheme(DefaultTheme.light)
            let host = UIHostingController(rootView: view)
            host.view.layoutIfNeeded()
            XCTAssertNotNil(host.view)
        }
    }

    func testIconOnlyLayout() {
        let view = TsumikiButton(
            icon: Image(systemName: "heart.fill"),
            shape: .circle,
            layout: .iconOnly,
            action: {}
        ).tsumikiTheme(DefaultTheme.light)
        let host = UIHostingController(rootView: view)
        host.view.layoutIfNeeded()
        XCTAssertNotNil(host.view)
    }

    func testLoadingState() {
        let view = TsumikiButton("Save", isLoading: true, action: {})
            .tsumikiTheme(DefaultTheme.light)
        let host = UIHostingController(rootView: view)
        host.view.layoutIfNeeded()
        XCTAssertNotNil(host.view)
    }

    func testWithBadge() {
        let view = TsumikiButton("Inbox", icon: Image(systemName: "envelope"), badge: "12", action: {})
            .tsumikiTheme(DefaultTheme.light)
        let host = UIHostingController(rootView: view)
        host.view.layoutIfNeeded()
        XCTAssertNotNil(host.view)
    }
    #endif
}
