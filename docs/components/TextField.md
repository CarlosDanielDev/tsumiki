# TsumikiTextField

A theme-aware text input covering form fields, labelled bordered/filled inputs,
and search bars — with built-in validation messaging, a secure-text toggle, and
optional leading/trailing icons. Subsumes `VaultSearchBar`, `WaterSearchBarView`,
`MineralFieldInput`, `OnboardingConfigSlide` input, and the bare `TextField`
usages from `ManualEntryFormView` and `OCRResultReviewView`.

## API

```swift
public enum TsumikiTextFieldStyle: Sendable, Equatable {
    case plain, bordered, filled, search
}

public enum TsumikiTextFieldValidation: Sendable, Equatable {
    case none
    case error(String)
    case success
}

public enum TsumikiKeyboardType: Sendable, Equatable {
    case `default`, asciiCapable, numbersAndPunctuation, URL,
         numberPad, phonePad, namePhonePad, emailAddress, decimalPad,
         twitter, webSearch
}

public struct TsumikiTextField: View {
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
    )
}
```

## Style → token mapping

| Style       | Background           | Idle stroke              | Focused stroke      | Shape         |
|-------------|----------------------|--------------------------|---------------------|---------------|
| `.plain`    | clear                | —                        | —                   | rect          |
| `.bordered` | `colors.background`  | `colors.textSecondary` 1 | `colors.accent` 1   | `radius.sm`   |
| `.filled`   | `colors.surface`     | —                        | `colors.accent` 1   | `radius.sm`   |
| `.search`   | `colors.surface`     | —                        | `colors.accent` 1   | `radius.pill` |

Validation overrides the focused/idle stroke:
- `.error(_)` → `colors.danger`, 1 pt.
- `.success`  → `colors.success`, 1 pt.

## Examples

```swift
@State private var query = ""

// Search bar (auto clear-button on non-empty text)
TsumikiTextField(
    "Search warranties",
    text: $query,
    leadingIcon: Image(systemName: "magnifyingglass"),
    style: .search,
    autocorrection: false,
    submitLabel: .search
)

// Labelled bordered field with inline validation
TsumikiTextField(
    "you@example.com",
    text: $email,
    label: "Email",
    helperText: "We never share your email",
    style: .bordered,
    validation: emailIsValid ? .success : .error("Invalid format"),
    keyboardType: .emailAddress,
    autocorrection: false
)

// Filled multiline notes
TsumikiTextField(
    "Notes",
    text: $notes,
    label: "Notes",
    style: .filled,
    axis: .vertical,
    lineLimit: 2...6
)

// Secure password field
TsumikiTextField(
    "Password",
    text: $password,
    label: "Password",
    style: .bordered,
    isSecure: true,
    submitLabel: .done,
    onSubmit: signIn
)

// Bare form field (plain style — sits inside SwiftUI Form)
Form {
    Section("Product") {
        TsumikiTextField("Product name", text: $productName,
                         style: .plain, autocorrection: false)
    }
}
```

## Theme tokens consumed

- `colors.accent`, `colors.background`, `colors.surface`,
  `colors.textPrimary`, `colors.textSecondary`,
  `colors.success`, `colors.danger`
- `spacing.xs`, `spacing.sm`, `spacing.md`
- `radius.sm` (bordered/filled), `radius.pill` (search)
- `typography.body` (input), `typography.caption` (label/helper/error)
- `opacity.disabled` (via `.disabled()` modifier)

## Notes

- **Validation precedence.** When `validation == .error(msg)`, `msg` renders
  below the field in `colors.danger` and the `helperText` is suppressed for
  that frame. `.success` keeps `helperText` visible.
- **Search clear-button.** Auto-rendered when `style == .search` and `text`
  is non-empty. Tapping clears the binding. Accessible label: "Clear text".
- **Secure toggle.** `isSecure: true` swaps `TextField` for `SecureField`
  internally; recreate the view with the flag flipped to switch at runtime.
- **Keyboard type on macOS.** `TsumikiKeyboardType` is a framework-owned enum.
  On iOS it maps to `UIKeyboardType`; on macOS the hint is ignored, the field
  still renders.
- **Focus.** Internal `@FocusState` drives stroke colouring. A future
  `@FocusState.Binding` parameter may be added if call sites need to push
  focus programmatically.
- **`textContentType`** is intentionally not exposed in v1 — wait for a
  concrete call-site need before adding.
