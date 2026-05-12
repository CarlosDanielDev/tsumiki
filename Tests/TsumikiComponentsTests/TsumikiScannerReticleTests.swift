import XCTest
import SwiftUI
@testable import TsumikiComponents
import TsumikiTheme

#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class TsumikiScannerReticleTests: XCTestCase {
    func testInitDefaults() {
        let r = TsumikiScannerReticle<EmptyView, EmptyView>()
        XCTAssertEqual(r.state, .scanning)
        XCTAssertEqual(r.cornerStyle, .brackets)
        if case .rectangle(let aspect) = r.shape {
            XCTAssertEqual(aspect, 16.0 / 9.0, accuracy: 0.001)
        } else {
            XCTFail("default shape should be .rectangle(16:9)")
        }
    }

    func testStringConvenienceInit() {
        let r = TsumikiScannerReticle(
            shape: .square,
            state: .success,
            cornerStyle: .continuous,
            instructions: "Scan code",
            status: "Found!"
        )
        XCTAssertEqual(r.shape, .square)
        XCTAssertEqual(r.state, .success)
        XCTAssertEqual(r.cornerStyle, .continuous)
    }

    func testShapeEquatability() {
        typealias R = TsumikiScannerReticle<EmptyView, EmptyView>
        XCTAssertEqual(R.Shape.square, R.Shape.square)
        XCTAssertNotEqual(R.Shape.square, R.Shape.rectangle(aspect: 1))
        XCTAssertEqual(R.Shape.fill(widthRatio: 0.5, heightRatio: 0.5),
                       R.Shape.fill(widthRatio: 0.5, heightRatio: 0.5))
        XCTAssertNotEqual(R.Shape.fill(widthRatio: 0.5, heightRatio: 0.5),
                          R.Shape.fill(widthRatio: 0.6, heightRatio: 0.5))
    }

    func testStateEnumerationCoversFiveCases() {
        let all: [TsumikiScannerReticle<EmptyView, EmptyView>.State] =
            [.idle, .scanning, .processing, .success, .error]
        XCTAssertEqual(Set(all).count, 5)
    }

    func testReticleRectKeyDefaultIsZero() {
        XCTAssertEqual(TsumikiReticleRectKey.defaultValue, .zero)
    }

    func testReticleRectKeyReduceUsesNonZeroNext() {
        var v: CGRect = .zero
        let next = CGRect(x: 10, y: 20, width: 100, height: 80)
        TsumikiReticleRectKey.reduce(value: &v, nextValue: { next })
        XCTAssertEqual(v, next)
    }

    func testReticleRectKeyNormalizedComputesFraction() {
        let n = TsumikiReticleRectKey.normalized(
            CGRect(x: 50, y: 100, width: 200, height: 100),
            in: CGSize(width: 500, height: 500)
        )
        XCTAssertEqual(n.minX, 0.1, accuracy: 0.001)
        XCTAssertEqual(n.minY, 0.2, accuracy: 0.001)
        XCTAssertEqual(n.width, 0.4, accuracy: 0.001)
        XCTAssertEqual(n.height, 0.2, accuracy: 0.001)
    }

    func testReticleRectKeyNormalizedZeroSizeReturnsZero() {
        let n = TsumikiReticleRectKey.normalized(
            CGRect(x: 1, y: 1, width: 10, height: 10),
            in: .zero
        )
        XCTAssertEqual(n, .zero)
    }

    #if canImport(UIKit)
    func testRendersAcrossStatesShapesCornerStyles() {
        let shapes: [TsumikiScannerReticle<Text, Text>.Shape] = [
            .square,
            .rectangle(aspect: 4.0 / 3.0),
            .fill(widthRatio: 0.9, heightRatio: 0.6)
        ]
        let states: [TsumikiScannerReticle<Text, Text>.State] =
            [.idle, .scanning, .processing, .success, .error]
        let corners: [TsumikiScannerReticle<Text, Text>.CornerStyle] =
            [.brackets, .continuous, .none]

        for s in shapes {
            for st in states {
                for c in corners {
                    let view = TsumikiScannerReticle(
                        shape: s,
                        state: st,
                        cornerStyle: c,
                        instructions: "Aim at the code",
                        status: ""
                    )
                    .tsumikiTheme(DefaultTheme.light)
                    .frame(width: 320, height: 480)

                    let host = UIHostingController(rootView: view)
                    host.view.layoutIfNeeded()
                    XCTAssertNotNil(host.view)
                }
            }
        }
    }
    #endif
}
