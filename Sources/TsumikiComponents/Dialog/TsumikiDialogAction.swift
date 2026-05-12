import SwiftUI

public struct TsumikiDialogAction: Identifiable {
    public enum Style: Sendable, Equatable {
        case primary, secondary, destructive, cancel
    }

    public let id: UUID
    public let title: String
    public let style: Style
    public let handler: () -> Void

    public init(_ title: String,
                style: Style = .primary,
                handler: @escaping () -> Void = {}) {
        self.id = UUID()
        self.title = title
        self.style = style
        self.handler = handler
    }

    public static func primary(_ title: String,
                               _ handler: @escaping () -> Void) -> TsumikiDialogAction {
        .init(title, style: .primary, handler: handler)
    }
    public static func secondary(_ title: String,
                                 _ handler: @escaping () -> Void) -> TsumikiDialogAction {
        .init(title, style: .secondary, handler: handler)
    }
    public static func destructive(_ title: String,
                                   _ handler: @escaping () -> Void) -> TsumikiDialogAction {
        .init(title, style: .destructive, handler: handler)
    }
    public static func cancel(_ title: String = "Cancel",
                              _ handler: @escaping () -> Void = {}) -> TsumikiDialogAction {
        .init(title, style: .cancel, handler: handler)
    }
}
