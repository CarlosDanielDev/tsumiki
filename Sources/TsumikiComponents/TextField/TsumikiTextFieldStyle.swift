import SwiftUI

public enum TsumikiTextFieldStyle: Sendable, Equatable {
    case plain, bordered, filled, search
}

public enum TsumikiTextFieldValidation: Sendable, Equatable {
    case none
    case error(String)
    case success
}

public enum TsumikiKeyboardType: Sendable, Equatable {
    case `default`
    case asciiCapable
    case numbersAndPunctuation
    case URL
    case numberPad
    case phonePad
    case namePhonePad
    case emailAddress
    case decimalPad
    case twitter
    case webSearch
}

#if canImport(UIKit)
import UIKit

extension TsumikiKeyboardType {
    var uiKitValue: UIKeyboardType {
        switch self {
        case .default:               return .default
        case .asciiCapable:          return .asciiCapable
        case .numbersAndPunctuation: return .numbersAndPunctuation
        case .URL:                   return .URL
        case .numberPad:             return .numberPad
        case .phonePad:              return .phonePad
        case .namePhonePad:          return .namePhonePad
        case .emailAddress:          return .emailAddress
        case .decimalPad:            return .decimalPad
        case .twitter:               return .twitter
        case .webSearch:             return .webSearch
        }
    }
}
#endif
