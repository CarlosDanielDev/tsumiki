import Foundation

public struct NoopTsumikiAnalytics: TsumikiAnalytics {
    public init() {}

    public func track(_ event: String, properties: [String: Any]?) {
        #if DEBUG
        Self.log("track", name: event, payload: properties)
        #endif
    }

    public func screen(_ name: String, properties: [String: Any]?) {
        #if DEBUG
        Self.log("screen", name: name, payload: properties)
        #endif
    }

    public func identify(_ userID: String, traits: [String: Any]?) {
        #if DEBUG
        Self.log("identify", name: userID, payload: traits)
        #endif
    }

    #if DEBUG
    private static func log(_ kind: String, name: String, payload: [String: Any]?) {
        if let payload, !payload.isEmpty {
            print("[TsumikiAnalytics] \(kind): \(name) \(payload)")
        } else {
            print("[TsumikiAnalytics] \(kind): \(name)")
        }
    }
    #endif
}
