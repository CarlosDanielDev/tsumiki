import XCTest
import SwiftUI
@testable import TsumikiServices

final class TsumikiServicesTests: XCTestCase {
    func testPackageBuilds() {
        XCTAssertTrue(true)
    }
}

final class TsumikiAnalyticsTests: XCTestCase {
    func testNoopConformsToProtocol() {
        let analytics: any TsumikiAnalytics = NoopTsumikiAnalytics()
        analytics.track("event_a", properties: nil)
        analytics.track("event_b", properties: ["k": 1])
        analytics.screen("Home", properties: nil)
        analytics.identify("user_42", traits: ["plan": "pro"])
    }

    func testProtocolConvenienceOverloads() {
        let analytics: any TsumikiAnalytics = NoopTsumikiAnalytics()
        analytics.track("login")
        analytics.screen("Settings")
        analytics.identify("user_7")
    }

    func testCustomWitnessReceivesCalls() {
        let spy = SpyAnalytics()
        let analytics: any TsumikiAnalytics = spy

        analytics.track("checkout_started", properties: ["cart_size": 3])
        analytics.screen("Cart", properties: nil)
        analytics.identify("u_1", traits: ["tier": "gold"])

        XCTAssertEqual(spy.events.count, 1)
        XCTAssertEqual(spy.events.first?.name, "checkout_started")
        XCTAssertEqual(spy.screens, ["Cart"])
        XCTAssertEqual(spy.identifiedUserIDs, ["u_1"])
    }

    func testEnvironmentDefaultIsNoop() {
        let env = EnvironmentValues()
        XCTAssertTrue(env.tsumikiAnalytics is NoopTsumikiAnalytics)
    }

    func testEnvironmentInjection() {
        var env = EnvironmentValues()
        let spy = SpyAnalytics()
        env.tsumikiAnalytics = spy

        env.tsumikiAnalytics.track("from_env", properties: nil)

        XCTAssertEqual(spy.events.first?.name, "from_env")
    }

    func testNoopIsSendable() {
        // Compile-time guarantee — capturing in a Sendable closure forces the check.
        let noop = NoopTsumikiAnalytics()
        let sendable: @Sendable () -> Void = { noop.track("x", properties: nil) }
        sendable()
    }

    func testNoopSilentInReleaseBuilds() throws {
        #if DEBUG
        throw XCTSkip("Release-only behavior; DEBUG build intentionally logs.")
        #else
        let output = captureStdout {
            let analytics = NoopTsumikiAnalytics()
            analytics.track("e", properties: ["k": "v"])
            analytics.screen("S", properties: nil)
            analytics.identify("u", traits: nil)
        }
        XCTAssertTrue(output.isEmpty, "Noop must be silent in release. Got: \(output)")
        #endif
    }
}

// MARK: - Helpers

private final class SpyAnalytics: TsumikiAnalytics, @unchecked Sendable {
    struct Event { let name: String; let properties: [String: Any]? }

    private(set) var events: [Event] = []
    private(set) var screens: [String] = []
    private(set) var identifiedUserIDs: [String] = []

    func track(_ event: String, properties: [String: Any]?) {
        events.append(Event(name: event, properties: properties))
    }

    func screen(_ name: String, properties: [String: Any]?) {
        screens.append(name)
    }

    func identify(_ userID: String, traits: [String: Any]?) {
        identifiedUserIDs.append(userID)
    }
}

private func captureStdout(_ body: () -> Void) -> String {
    let pipe = Pipe()
    let original = dup(fileno(stdout))
    fflush(stdout)
    dup2(pipe.fileHandleForWriting.fileDescriptor, fileno(stdout))

    body()
    fflush(stdout)

    dup2(original, fileno(stdout))
    close(original)
    try? pipe.fileHandleForWriting.close()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8) ?? ""
}
