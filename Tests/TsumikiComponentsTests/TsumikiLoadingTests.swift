import XCTest
import SwiftUI
@testable import TsumikiComponents
import TsumikiTheme

#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class TsumikiLoadingTests: XCTestCase {
    func testLoadingInitDefaults() {
        let l = TsumikiLoading()
        XCTAssertNil(l.label)
        XCTAssertEqual(l.size, .regular)
        XCTAssertNil(l.onCancel)
    }

    func testLoadingInitFull() {
        let l = TsumikiLoading(label: "Fetching", size: .large, onCancel: {})
        XCTAssertEqual(l.label, "Fetching")
        XCTAssertEqual(l.size, .large)
        XCTAssertNotNil(l.onCancel)
    }

    func testSkeletonInitDefaults() {
        let s = TsumikiSkeleton(height: 20)
        XCTAssertNil(s.width)
        XCTAssertEqual(s.height, 20)
        if case .rectangle = s.shape {} else { XCTFail("expected .rectangle") }
    }

    func testSkeletonShapeVariants() {
        XCTAssertEqual(TsumikiSkeleton.Shape.circle, .circle)
        XCTAssertEqual(TsumikiSkeleton.Shape.capsule, .capsule)
    }

    #if canImport(UIKit)
    func testLoadingRendersForEachSize() {
        for size in [TsumikiLoading.Size.compact, .regular, .large] {
            let view = TsumikiLoading(label: "Loading", size: size)
                .tsumikiTheme(DefaultTheme.light)
            let host = UIHostingController(rootView: view)
            host.view.layoutIfNeeded()
            XCTAssertNotNil(host.view)
        }
    }

    func testSkeletonRendersForEachShape() {
        let shapes: [TsumikiSkeleton.Shape] = [
            .rectangle(),
            .rectangle(cornerRadius: 12),
            .circle,
            .capsule,
        ]
        for shape in shapes {
            let view = TsumikiSkeleton(shape, width: 100, height: 20)
                .tsumikiTheme(DefaultTheme.light)
            let host = UIHostingController(rootView: view)
            host.view.layoutIfNeeded()
            XCTAssertNotNil(host.view)
        }
    }

    func testShimmerComposesOnView() {
        let view = Color.clear
            .frame(width: 100, height: 20)
            .tsumikiShimmer()
            .tsumikiTheme(DefaultTheme.light)
        let host = UIHostingController(rootView: view)
        host.view.layoutIfNeeded()
        XCTAssertNotNil(host.view)
    }
    #endif
}
