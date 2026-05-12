import SwiftUI
import TsumikiTheme

public struct TsumikiTextField: View {
    public let placeholder: String
    private let _text: Binding<String>
    public let label: String?
    public let helperText: String?
    public let leadingIcon: Image?
    public let trailingIcon: Image?
    public let style: TsumikiTextFieldStyle
    public let validation: TsumikiTextFieldValidation
    public let isSecure: Bool
    public let axis: Axis
    public let lineLimit: ClosedRange<Int>?
    public let keyboardType: TsumikiKeyboardType
    public let autocorrection: Bool
    public let submitLabel: SubmitLabel
    public let onSubmit: (() -> Void)?

    public var text: Binding<String> { _text }

    @Environment(\.tsumikiTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var isFocused: Bool

    public init(
        _ placeholder: String,
        text: Binding<String>,
        label: String? = nil,
        helperText: String? = nil,
        leadingIcon: Image? = nil,
        trailingIcon: Image? = nil,
        style: TsumikiTextFieldStyle = .bordered,
        validation: TsumikiTextFieldValidation = .none,
        isSecure: Bool = false,
        axis: Axis = .horizontal,
        lineLimit: ClosedRange<Int>? = nil,
        keyboardType: TsumikiKeyboardType = .default,
        autocorrection: Bool = true,
        submitLabel: SubmitLabel = .return,
        onSubmit: (() -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.label = label
        self.helperText = helperText
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.style = style
        self.validation = validation
        self.isSecure = isSecure
        self.axis = axis
        self.lineLimit = lineLimit
        self.keyboardType = keyboardType
        self.autocorrection = autocorrection
        self.submitLabel = submitLabel
        self.onSubmit = onSubmit
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            if let label {
                Text(label)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }

            fieldRow
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .background(backgroundColor)
                .clipShape(clipShape)
                .overlay(strokeOverlay)

            supportText
        }
        .opacity(isEnabled ? 1.0 : theme.opacity.disabled)
    }

    // MARK: - Field row

    @ViewBuilder
    private var fieldRow: some View {
        HStack(spacing: theme.spacing.sm) {
            if let leadingIcon {
                leadingIcon.foregroundStyle(theme.colors.textSecondary)
            }
            inputField
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textPrimary)
                .focused($isFocused)
            if style == .search && !_text.wrappedValue.isEmpty {
                Button {
                    _text.wrappedValue = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(theme.colors.textSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear text")
            }
            if let trailingIcon {
                trailingIcon.foregroundStyle(theme.colors.textSecondary)
            }
        }
    }

    @ViewBuilder
    private var inputField: some View {
        let field: AnyView = {
            if isSecure {
                return AnyView(
                    SecureField(placeholder, text: _text)
                        .submitLabel(submitLabel)
                        .onSubmit { onSubmit?() }
                )
            } else {
                let textField = TextField(placeholder, text: _text, axis: axis)
                    .submitLabel(submitLabel)
                    .onSubmit { onSubmit?() }
                if let lineLimit {
                    return AnyView(textField.lineLimit(lineLimit))
                }
                return AnyView(textField)
            }
        }()

        field
            .textFieldStyle(.plain)
            .autocorrectionDisabled(!autocorrection)
            #if canImport(UIKit)
            .keyboardType(keyboardType.uiKitValue)
            #endif
    }

    // MARK: - Support text (validation > helper)

    @ViewBuilder
    private var supportText: some View {
        switch validation {
        case .error(let message):
            Text(message)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.danger)
        case .none, .success:
            if let helperText {
                Text(helperText)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
    }

    // MARK: - Padding

    private var horizontalPadding: CGFloat {
        switch style {
        case .plain:    return 0
        case .bordered, .filled, .search: return theme.spacing.md
        }
    }

    private var verticalPadding: CGFloat {
        switch style {
        case .plain:    return 0
        case .bordered, .filled, .search: return theme.spacing.sm
        }
    }

    // MARK: - Background

    private var backgroundColor: Color {
        switch style {
        case .plain:    return Color.clear
        case .bordered: return theme.colors.background
        case .filled:   return theme.colors.surface
        case .search:   return theme.colors.surface
        }
    }

    // MARK: - Shape

    private var clipShape: AnyShape {
        switch style {
        case .plain:
            return AnyShape(Rectangle())
        case .bordered, .filled:
            return AnyShape(RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous))
        case .search:
            return AnyShape(RoundedRectangle(cornerRadius: theme.radius.pill, style: .continuous))
        }
    }

    // MARK: - Stroke

    @ViewBuilder
    private var strokeOverlay: some View {
        let validationColor: Color? = {
            switch validation {
            case .none:       return nil
            case .error:      return theme.colors.danger
            case .success:    return theme.colors.success
            }
        }()

        if let validationColor {
            clipShape.stroke(validationColor, lineWidth: 1)
        } else if isFocused && style != .plain {
            clipShape.stroke(theme.colors.accent, lineWidth: 1)
        } else if style == .bordered {
            clipShape.stroke(theme.colors.textSecondary, lineWidth: 1)
        }
    }
}
