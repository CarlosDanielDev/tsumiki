# Arbiter: TextField

## Winner
Synthesised baseline drawn from `aquabrew/Views/Components/Fields/MineralFieldInput.swift`
(labelled bordered field with focus stroke + validation message) merged with
`warrantyreminder/Views/Vault/VaultSearchBar.swift` (search style with leading
magnifier and conditional clear button). No single source variant covered the
full surface, so the merged spec subsumes both shapes plus the lightweight
form-embedded `TextField` usages from WR's `ManualEntryFormView` and the
filled/dark variant from pulselog's `OnboardingConfigSlide`.

## Why
- `MineralFieldInput` is the cleanest "labelled field with validation" anchor:
  optional title-row above the field, focus-driven stroke, and inline error
  message — every axis other variants need.
- `VaultSearchBar` / `WaterSearchBarView` define the search-bar idiom (leading
  magnifier, clear-button on non-empty text, pill chrome). Folding that into a
  `Style.search` case keeps the API single-component.
- `ManualEntryFormView` calls represent the bare `TextField(placeholder, text:)`
  inside `Form`: that's the `Style.plain` case, no chrome.
- `OnboardingConfigSlide` shows the filled-dark surface variant with a caption
  label above; that's `Style.filled` with `label:` set.
- OCR review fields (`OCRResultReviewView`) wrap each text field with an
  ancestor card + label; the new component folds the label row inside, so
  OCR call sites collapse to one `TsumikiTextField(...)`.

## Proposed Tsumiki API

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

### Style → token mapping

| Style       | Background          | Stroke (idle)            | Stroke (focused)   | Shape                |
|-------------|---------------------|--------------------------|--------------------|----------------------|
| `.plain`    | `.clear`            | —                        | —                  | rect                 |
| `.bordered` | `colors.background` | `colors.textSecondary` 1 | `colors.accent` 1.5| `radius.sm`          |
| `.filled`   | `colors.surface`    | —                        | `colors.accent` 1.5| `radius.sm`          |
| `.search`   | `colors.surface`    | —                        | `colors.accent` 1.5| `radius.pill`        |

Validation overrides the stroke:
- `.error(_)` → `colors.danger`, 1.5pt.
- `.success`  → `colors.success`, 1.5pt.

### Support-text precedence
Validation `.error(msg)` renders `msg` in `colors.danger` below the field and
suppresses `helperText` for that frame (matches `MineralFieldInput`). When
validation is `.none`/`.success`, `helperText` renders in `colors.textSecondary`.

## Theme tokens consumed
- `colors.accent`, `colors.background`, `colors.surface`, `colors.textPrimary`,
  `colors.textSecondary`, `colors.success`, `colors.danger`
- `spacing.xs`, `spacing.sm`, `spacing.md`
- `radius.sm`, `radius.pill`
- `typography.body` (input + placeholder), `typography.caption` (label + helper + error)
- `opacity.disabled` (via `.disabled()` modifier wiring)

## Variants subsumed

- `warrantyreminder/Views/Vault/VaultSearchBar.swift` →
  `style: .search`, `leadingIcon: Image(systemName: "magnifyingglass")`,
  clear-button affordance is automatic when text non-empty.
- `warrantyreminder/Views/AddWarranty/ManualEntryFormView.swift` form fields →
  `style: .plain` inside `Form`, `autocorrection: false` per call site.
- `warrantyreminder/Views/CameraScan/OCRResultReviewView.swift` field cards →
  `style: .filled` or `.bordered` with `label:` set; the ancestor card chrome
  collapses into the component.
- `aquabrew/Views/Components/Fields/MineralFieldInput.swift` →
  `style: .bordered`, `label:` + `validation:` cover title row + error message.
  The unit-suffix ("mg/L") is expressed as `trailingIcon` is text-only — a
  follow-up may introduce `trailingText:` if non-icon trailing affordances are
  common; v1 leaves that to the call site via `.overlay` if needed.
- `aquabrew/Views/WaterCatalog/WaterSearchBarView.swift` → identical to
  `VaultSearchBar` mapping; the focus-coloured magnifier is achieved by the
  focused stroke.
- `pulselog/Views/Onboarding/OnboardingConfigSlide.swift` → `style: .filled`
  + `label:`. White-on-dark colouring is delivered by a consumer theme override
  (caller swaps `DefaultTheme.dark` or supplies a custom theme with adjusted
  `colors.surface` / `colors.textPrimary`).
- `pulselog/Views/Energy/EnergyEntrySheet.swift`, `…/Sprint/NewSprintSheet.swift`,
  `…/Chaos/ChaosEntrySheet.swift` → `style: .filled` form fields with optional
  `label:`. Same shape as `OnboardingConfigSlide`.

## Not subsumed
- `FieldValidationView` (aquabrew) — a separate component that pairs with the
  field; can stay an app-side affordance. The field exposes `validation:` so
  call sites that want a separate indicator can keep `.none` here.
- Decimal/price formatting, currency pickers, autocompletion suggestion chips
  (WR product/store suggestions) — those are form-flow concerns, not field
  primitives. Composition handles them.
- `DatePicker`, `Picker` field cards in OCR/Manual entry — out of scope; future
  `TsumikiFormRow` may wrap them but it's distinct from a text input.

## Risks / open questions
- **UIKeyboardType platform gap.** macOS has no `UIKeyboardType`. We expose a
  framework-owned `TsumikiKeyboardType` enum and apply
  `.keyboardType(...)` only inside `#if canImport(UIKit)`. The macOS path
  silently ignores the keyboard hint — acceptable for a SwiftUI primitive
  that's iOS-first.
- **`@FocusState` exposure.** Each call site in source projects owns its own
  `@FocusState`. The component manages internal focus for stroke colouring;
  if a caller needs to programmatically focus the field (e.g. push focus on
  appear), we defer adding a `@FocusState.Binding` parameter until measured.
- **Search clear-button placement.** Auto-rendered after `text` when `style ==
  .search && !text.isEmpty`. Tappable area uses `Image(systemName:
  "xmark.circle.fill")` for visual parity with both search-bar sources.
- **`isSecure` switch.** Body branches between `TextField` and `SecureField`
  on init's flag. The two SwiftUI views are not interchangeable at runtime
  via a modifier; the `body` rebuilds when the parent re-creates the view
  with a different `isSecure`. Tests assert both branches construct without
  crashing.
- **`textContentType`** intentionally omitted from v1 — most source call
  sites set it inconsistently (some not at all). Reintroduce when WR / pulse
  forms surface a concrete need; deferring keeps the surface lean.
- **Multiline (`axis: .vertical`) lineLimit gating.** Only iOS 17+; package
  targets iOS 17 / macOS 14 so this is fine.
- **Localization.** Placeholder/label/helper/error are plain `String`; future
  L10N work (cross-component) will pick `LocalizedStringKey` vs Bundle lookup
  framework-wide.
