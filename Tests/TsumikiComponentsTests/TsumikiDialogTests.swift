import XCTest
import SwiftUI
@testable import TsumikiComponents
import TsumikiTheme

#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class TsumikiDialogTests: XCTestCase {
    func testActionConstructors() {
        XCTAssertEqual(TsumikiDialogAction.primary("OK", {}).style, .primary)
        XCTAssertEqual(TsumikiDialogAction.secondary("Maybe", {}).style, .secondary)
        XCTAssertEqual(TsumikiDialogAction.destructive("Delete", {}).style, .destructive)
        XCTAssertEqual(TsumikiDialogAction.cancel().style, .cancel)
        XCTAssertEqual(TsumikiDialogAction.cancel().title, "Cancel")
    }

    func testInitDefaults() {
        let d = TsumikiDialog<EmptyView>(title: "T")
        XCTAssertEqual(d.kind, .info)
        XCTAssertNil(d.icon)
        XCTAssertNil(d.message)
        XCTAssertEqual(d.actions.count, 0)
    }

    func testTapOutsideDismissRules() {
        // info + cancel → allowed
        let d1 = TsumikiDialog<EmptyView>(
            kind: .info, title: "T",
            actions: [.primary("OK", {}), .cancel()]
        )
        XCTAssertTrue(d1.allowsTapOutsideDismiss)

        // info + no cancel → blocked
        let d2 = TsumikiDialog<EmptyView>(
            kind: .info, title: "T",
            actions: [.primary("OK", {})]
        )
        XCTAssertFalse(d2.allowsTapOutsideDismiss)

        // destructive + cancel → blocked (destructive overrides)
        let d3 = TsumikiDialog<EmptyView>(
            kind: .destructive, title: "T",
            actions: [.destructive("Delete", {}), .cancel()]
        )
        XCTAssertFalse(d3.allowsTapOutsideDismiss)
    }

    #if canImport(UIKit)
    func testRendersForEachKind() {
        for kind in [TsumikiDialog<EmptyView>.Kind.info, .confirmation, .success, .warning, .destructive] {
            let d = TsumikiDialog<EmptyView>(
                kind: kind,
                icon: Image(systemName: "checkmark"),
                title: "Heads up",
                message: "Message body",
                actions: [.primary("OK", {}), .cancel()]
            ).tsumikiTheme(DefaultTheme.light)
            let host = UIHostingController(rootView: d)
            host.view.layoutIfNeeded()
            XCTAssertNotNil(host.view)
        }
    }

    func testModifierRendersWhenPresented() {
        var presented = true
        let binding = Binding(get: { presented }, set: { presented = $0 })
        let view = Color.clear.tsumikiDialog(isPresented: binding) {
            TsumikiDialog<EmptyView>(title: "Hi", actions: [.primary("OK", {})])
        }.tsumikiTheme(DefaultTheme.light)
        let host = UIHostingController(rootView: view)
        host.view.layoutIfNeeded()
        XCTAssertTrue(presented)
        XCTAssertNotNil(host.view)
    }
    #endif
}
