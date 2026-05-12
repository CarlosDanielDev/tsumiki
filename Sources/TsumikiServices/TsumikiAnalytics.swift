import Foundation

public protocol TsumikiAnalytics: Sendable {
    func track(_ event: String, properties: [String: Any]?)
    func screen(_ name: String, properties: [String: Any]?)
    func identify(_ userID: String, traits: [String: Any]?)
}

public extension TsumikiAnalytics {
    func track(_ event: String) {
        track(event, properties: nil)
    }

    func screen(_ name: String) {
        screen(name, properties: nil)
    }

    func identify(_ userID: String) {
        identify(userID, traits: nil)
    }
}
