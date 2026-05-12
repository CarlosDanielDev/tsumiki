# Tsumiki MVP — Plan C: P3 Catalog + Services + First Migration (v0.1.0 → v0.3.0)

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development or superpowers:executing-plans. Steps use `- [ ]` checkboxes.

**Goal:** Close the MVP gap left after Plan B. Four phases, four releasable tags:

| Tag | Scope |
|---|---|
| **v0.1.0** | Plan B baseline (already shipped). Plus: `TsumikiTextField` port + arbiter spec (P2 carry-over). |
| **v0.2.0** | `Examples/TsumikiCatalog` example app + `TsumikiServices` protocol surfaces (no-op defaults). |
| **v0.2.1** | `TsumikiPaywallController` StoreKit 2 implementation behind protocol. |
| **v0.3.0** | `warrantyreminder` migrated to Tsumiki + `docs/MIGRATION.md`. |

**Architecture rules** (unchanged from Plan B):
- Per-concept Swift files under `Sources/TsumikiComponents/<Concept>/`.
- Services under `Sources/TsumikiServices/<Service>/`.
- Components read theme via `@Environment(\.tsumikiTheme)`. Zero hardcoded `Color` / spacing / radius literals (lint-enforced).
- Public API only. No `@_spi`, no internal singletons, no globals.

**Tech Stack:** Swift 5.9+, SwiftUI, iOS 17 (macOS 14 for `swift test`), XCTest, StoreKit 2.

**Toolchain note:** use `/usr/bin/swift` (Xcode 6.2). `which swift` resolves to swiftly 6.1 which is incompatible with macOS 26 SDK.

**Subagent flow reminder** (from `.claude/CLAUDE.md`): orchestrator is the only agent that writes code. Subagents read `manifests/*.json` and return digests. For a new concept (TextField), follow: `subagent-overlap-arbiter` → write spec under `docs/superpowers/research/arbiters/` → `subagent-architect` (optional, for sizing) → orchestrator TDD port.

---

## Pre-flight (do once before Task 1)

- [ ] Re-run `/usr/bin/swift test` to confirm baseline 51 tests pass.
- [ ] Re-run `python3 -m unittest discover scripts/tests` to confirm 18 tests pass.
- [ ] Re-run `python3 -m scripts.lint_no_hardcoded Sources/TsumikiComponents` (exit 0).
- [ ] Confirm `manifests/_overlaps.json` exists and lists `TextField` entries (re-scan if missing: see `manifests/HOWTO.md` once written; otherwise run `python3 -m scripts.scan_project <name> <root> -o manifests/<name>.json` for the 5 source projects and `python3 -m scripts.diff_overlaps`).

---

## Phase 0 — v0.1.0: TsumikiTextField port (P2 carry-over)

Plan B left TextField out of the MVP wave because no arbiter spec existed. The PRD lists `TsumikiTextField` in the MVP component set; closing this gap unblocks WR migration (search bar, manual entry form, OCR review).

### Task 0.1: Run overlap-arbiter for TextField

Subagent: `subagent-overlap-arbiter` with input `{ concept: "TextField" }`.

Candidate evidence (from initial scan; the arbiter should verify and rank):
- `warrantyreminder/Views/Vault/VaultSearchBar.swift` — search field with leading magnifier icon and clear button.
- `warrantyreminder/Views/AddWarranty/ManualEntryFormView.swift` — `Form`-embedded fields with `.autocorrectionDisabled()`, `.keyboardType(.decimalPad)`, `axis: .vertical` for notes.
- `warrantyreminder/Views/CameraScan/OCRResultReviewView.swift` — labelled field-stack with validation indicators.
- `aquabrew/Views/Components/Fields/MineralFieldInput.swift` — labelled numeric input with unit suffix.
- `aquabrew/Views/WaterCatalog/WaterSearchBarView.swift` — themed search field.
- `pulselog/Views/Energy/EnergyEntrySheet.swift`, `pulselog/Views/Sprint/NewSprintSheet.swift`, `pulselog/Views/Chaos/ChaosEntrySheet.swift` — sheet form fields.
- `pulselog/Views/Onboarding/OnboardingConfigSlide.swift` — onboarding input with focus state.

- [ ] **Step 1:** orchestrator opens the 5 representative files above, pastes snippets into the arbiter prompt (NEVER hand the subagent raw filesystem access to source projects).
- [ ] **Step 2:** arbiter returns winner + merged param list + variants subsumed + risks.
- [ ] **Step 3:** orchestrator writes `docs/superpowers/research/arbiters/TextField.md` using the same shape as `docs/superpowers/research/arbiters/Button.md`:
  - Winner
  - Why
  - Proposed Tsumiki API (init signature with all merged params)
  - Style/variant → token mapping table (if styles exist)
  - Theme tokens consumed
  - Variants subsumed (one bullet per source candidate)
  - Not subsumed
  - Risks / open questions
- [ ] **Step 4:** commit `docs(research): persist TextField arbiter spec`.

**Expected API skeleton** (the arbiter finalises; this is just a sanity sketch):

```swift
public struct TsumikiTextField: View {
    public enum Style: Sendable { case plain, bordered, filled, search }
    public enum Validation: Sendable {
        case none
        case error(String)
        case success
    }

    public init(
        _ placeholder: String,
        text: Binding<String>,
        label: String? = nil,
        helperText: String? = nil,
        leadingIcon: Image? = nil,
        trailingIcon: Image? = nil,
        style: Style = .bordered,
        validation: Validation = .none,
        isSecure: Bool = false,
        axis: Axis = .horizontal,
        lineLimit: ClosedRange<Int>? = nil,
        keyboardType: UIKeyboardType = .default,
        autocorrection: Bool = true,
        textContentType: UITextContentType? = nil,
        submitLabel: SubmitLabel = .return,
        onSubmit: (() -> Void)? = nil
    )
}
```

Risks to flag in the arbiter doc:
- `UIKeyboardType` and `UITextContentType` are UIKit-only — gate macOS host via `#if canImport(UIKit)` or use SwiftUI's platform-agnostic alternatives where available.
- `SecureField` vs `TextField` swap: API offers `isSecure: Bool` flag; body switches internally. Validate this isn't observable from the outside.
- Search style needs a clear-button affordance and optional leading magnifier — confirm both as built-in or as caller-provided icons.

### Task 0.2: Port TsumikiTextField (TDD)

**Files:**
- Create `Sources/TsumikiComponents/TextField/TsumikiTextField.swift`
- Create `Sources/TsumikiComponents/TextField/TsumikiTextFieldStyle.swift` (Style enum + token mapping helpers if extracted)
- Create `Tests/TsumikiComponentsTests/TsumikiTextFieldTests.swift`
- Create `docs/components/TextField.md`

- [ ] **Step 1:** Write failing tests covering: every `Style` case constructs; `validation` enum cases construct; `isSecure` flips internal field type (observable via accessibility identifier or render-without-crash); search style renders clear button when text is non-empty; helperText vs validation.error precedence is defined (validation wins).
- [ ] **Step 2:** Run `/usr/bin/swift test --filter TsumikiTextFieldTests`. Expect build error (`TsumikiTextField` undefined).
- [ ] **Step 3:** Implement per arbiter spec. Use:
  - `colors.surface` for filled fill, `colors.background` for bordered fill.
  - `colors.accent` for focus ring (1.5 pt stroke).
  - `colors.danger` for validation error, `colors.success` if/when added (else `colors.accent`).
  - `colors.textPrimary` for input text, `colors.textSecondary` for placeholder/helper, `colors.textPrimary.opacity(theme.opacity.disabled)` for disabled.
  - `radius.sm` for bordered/filled, `radius.pill` for search style.
  - `spacing.sm`/`md` for internal padding.
- [ ] **Step 4:** Run tests, lint, write `docs/components/TextField.md` (shape: API, example, theme tokens consumed, notes — match `docs/components/Button.md`).
- [ ] **Step 5:** Commit `feat(components): add TsumikiTextField with Style/Validation/secure-toggle`.

### Phase 0 acceptance (tag v0.1.0)

- [ ] `/usr/bin/swift test` — all targets green (≥ 53 tests after Phase 0).
- [ ] Lint exit 0 on `Sources/TsumikiComponents`.
- [ ] `docs/components/TextField.md` published.
- [ ] `docs/superpowers/research/arbiters/TextField.md` published.
- [ ] Tag `v0.1.0` cut from master.

**Phase 0 blockers:**
- TextField arbiter may discover the 9 candidates split into two distinct concepts (e.g. "form field" vs "search bar"). If so, split into `TsumikiTextField` + `TsumikiSearchField` and update this plan before porting.
- If candidates rely on `@FocusState` plumbing that doesn't compose, the API may need `@FocusState.Binding` exposure — flag in arbiter risks section.

---

## Phase 1 — v0.2.0: TsumikiCatalog example app

A SwiftUI app shipped under `Examples/TsumikiCatalog/` that lists every Tsumiki component, lets the user toggle themes, and renders an "all states" gallery per component. **Doubles as the manual visual smoke test** while the MVP has no snapshot tests (PRD §Non-Goals).

### Architecture

```
Examples/TsumikiCatalog/
├── Package.swift                       # local SwiftPM example, depends on ../..
├── TsumikiCatalogApp.swift             # @main app, hosts CatalogRoot
├── CatalogRoot.swift                   # NavigationStack + sidebar list
├── CatalogTheme.swift                  # built-in themes + ThemePicker logic
├── Themes/
│   ├── HighContrastTheme.swift         # custom theme #1 (proves consumer override)
│   └── PastelTheme.swift               # custom theme #2
├── Screens/
│   ├── ButtonScreen.swift              # one file per component
│   ├── CardScreen.swift
│   ├── DialogScreen.swift
│   ├── LoadingScreen.swift
│   ├── OnboardingScreen.swift
│   ├── PaywallScreen.swift
│   ├── ScannerReticleScreen.swift
│   ├── SettingsRowScreen.swift
│   ├── SplashScreen.swift
│   ├── TextFieldScreen.swift           # depends on Phase 0
│   └── ToastScreen.swift
└── Support/
    ├── ScreenScaffold.swift            # shared chrome (theme picker, dark/light toggle, state-gallery toggle)
    └── StateGalleryView.swift          # renders "all states" matrix for a component
```

### Catalog design rules

- **One screen per component.** Naming: `<Concept>Screen`. Each screen renders a *minimal happy-path* example plus, when the gallery toggle is on, a `StateGalleryView` that shows every documented Style/Size/State combination.
- **Theme picker:** a single `Picker` in the toolbar listing `DefaultTheme.light`, `DefaultTheme.dark`, `HighContrastTheme()`, `PastelTheme()`. Selection is held in `@AppStorage("catalog.theme")` so the choice persists across launches.
- **Dark/Light system toggle:** independent of the theme picker — toggles `colorScheme: .light/.dark` for the rendered subview only (does NOT change `DefaultTheme.light` → `.dark` automatically; the two axes are intentionally orthogonal so we can verify the theme renders correctly under both system appearances).
- **Gallery toggle:** a `Toggle` in the toolbar. Off → minimal example. On → `StateGalleryView` renders every variant (e.g. Button: 5 styles × 3 sizes × 3 shapes = 45 tiles).
- **No domain code.** The catalog uses Tsumiki primitives only. No state machines, no networking, no analytics calls. Bindings are local `@State` to make interactions live.

### Task 1.1: Bootstrap the catalog package

- [ ] **Step 1:** Create `Examples/TsumikiCatalog/Package.swift` with `path: "../.."` dependency on Tsumiki, iOS 17 platform, app target.
- [ ] **Step 2:** Add `Examples/` to `.gitignore` checks — it MUST be tracked but should NOT be a SwiftPM target of the root package (keeps `/usr/bin/swift test` from compiling the catalog on every test run).
- [ ] **Step 3:** Verify catalog builds standalone: `cd Examples/TsumikiCatalog && /usr/bin/swift build`.
- [ ] **Step 4:** Commit `feat(catalog): bootstrap TsumikiCatalog example app`.

### Task 1.2: Catalog chrome (ScreenScaffold + theme picker + toggles)

- [ ] **Step 1:** Implement `ScreenScaffold<Content: View>` — provides a `NavigationStack` toolbar with: theme picker, dark/light toggle, gallery toggle. Hands the content a `ScreenScaffoldContext { theme, colorScheme, showGallery }`.
- [ ] **Step 2:** Implement `StateGalleryView` — a generic `Grid` that takes a `LabelledExamples` collection and renders each tile with its label below.
- [ ] **Step 3:** Implement two custom themes (`HighContrastTheme`, `PastelTheme`) that override at least `colors.accent`, `colors.surface`, `colors.background`, `colors.textPrimary`. Proves third-party themeability works as documented.
- [ ] **Step 4:** Commit `feat(catalog): add ScreenScaffold + ThemePicker + state-gallery toggle`.

### Task 1.3: One screen per component (11 screens)

For each of the 11 components (10 from Plan B + TextField from Phase 0), write `<Concept>Screen.swift`:

- [ ] ButtonScreen — 5 styles × 3 sizes × 3 shapes × 4 layouts (subset in gallery; minimal = primary/medium/rounded/horizontal "Hello").
- [ ] CardScreen — 4 paddings × 3 elevations.
- [ ] DialogScreen — 4 action kinds × scrim-tap-dismiss permutations. Triggered by a button in the minimal view.
- [ ] LoadingScreen — TsumikiLoading sizes + TsumikiSkeleton shapes + `.tsumikiShimmer()` on a sample card.
- [ ] OnboardingScreen — TsumikiOnboardingPage + Dots + ProgressBar composed in a 3-page demo flow.
- [ ] PaywallScreen — 0/1/5 features, isPurchasing toggle, onDismiss nil vs present.
- [ ] ScannerReticleScreen — 3 shape variants + 3 state variants. Uses a placeholder background image (bundled in catalog assets) since the actual camera feed isn't wired in v1.
- [ ] SettingsRowScreen — every Trailing case stacked in a `List`.
- [ ] SplashScreen — minimal example + full (with title + tagline). Note: the splash auto-completes — gallery view shows a snapshot rather than re-triggering animations.
- [ ] TextFieldScreen — every Style × every Validation, plus a search variant and a secure variant.
- [ ] ToastScreen — every kind × every position; triggered by buttons.
- [ ] **Step:** Commit each screen separately: `feat(catalog): add <Concept>Screen`. 11 commits.

### Task 1.4: CatalogRoot wiring

- [ ] **Step 1:** `CatalogRoot.swift` — `NavigationStack` with a `List` of 11 entries; tapping pushes the matching screen. Persist last-visited screen in `@AppStorage`.
- [ ] **Step 2:** `TsumikiCatalogApp.swift` — `@main` shell, applies the persisted theme at the root via `.tsumikiTheme(...)`.
- [ ] **Step 3:** Run on iOS simulator; manually verify every screen renders and theme switching works. **There is no automated test for the catalog itself.**
- [ ] **Step 4:** Commit `feat(catalog): wire CatalogRoot + persist theme/screen selection`.

### Phase 1 acceptance (tag v0.2.0 after Phase 2 also done)

- [ ] `cd Examples/TsumikiCatalog && /usr/bin/swift build` exits 0.
- [ ] All 11 component screens reachable from the root list.
- [ ] Theme picker offers 4 themes (2 default, 2 custom), dark/light toggle and gallery toggle work on every screen.
- [ ] Root `/usr/bin/swift test` still 51+ green (catalog is NOT a test target).
- [ ] README "Examples" section added pointing to `Examples/TsumikiCatalog`.

**Phase 1 blockers:**
- Catalog dragging in transitive deps (StoreKit, RevenueCat, AdMob) by accident. The catalog must NOT depend on `TsumikiServices` until Phase 2 ships protocol-only surfaces; until then, PaywallScreen uses local `@State` for `isPurchasing` and no controller.
- Custom themes that fail the lint (because they're outside `Sources/TsumikiComponents/`) — confirm `scripts/lint_no_hardcoded.py` scope explicitly excludes `Examples/`.

---

## Phase 2 — v0.2.0: TsumikiServices protocol surfaces

Populate `Sources/TsumikiServices/` with four protocol-first services. Each ships with: protocol, no-op default implementation, optional sample implementation, public init. **No concrete vendor SDK dependencies in TsumikiServices** — adapters live in consumer apps or in optional supplemental targets later.

### Task 2.1: TsumikiAnalytics

**Files:**
- Create `Sources/TsumikiServices/Analytics/TsumikiAnalytics.swift`
- Create `Sources/TsumikiServices/Analytics/TsumikiAnalyticsEvent.swift`
- Create `Sources/TsumikiServices/Analytics/NoopTsumikiAnalytics.swift`
- Create `Tests/TsumikiServicesTests/TsumikiAnalyticsTests.swift`
- Create `docs/services/Analytics.md`

**API sketch:**

```swift
public protocol TsumikiAnalytics: Sendable {
    func track(_ event: TsumikiAnalyticsEvent) async
    func setUserProperty(_ key: String, value: String?) async
    func startSession() async
    func endSession() async
}

public struct TsumikiAnalyticsEvent: Sendable, Equatable {
    public let name: String
    public let parameters: [String: TsumikiAnalyticsValue]
    public init(_ name: String, parameters: [String: TsumikiAnalyticsValue] = [:])
}

public enum TsumikiAnalyticsValue: Sendable, Equatable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
}

public struct NoopTsumikiAnalytics: TsumikiAnalytics {
    public init() {}
    public func track(_ event: TsumikiAnalyticsEvent) async {}
    public func setUserProperty(_ key: String, value: String?) async {}
    public func startSession() async {}
    public func endSession() async {}
}
```

- [ ] **Step 1:** Write failing tests covering: event init, parameter types round-trip, noop calls don't crash, a spy implementation captures the last event.
- [ ] **Step 2:** Implement per sketch, refining param types if needed.
- [ ] **Step 3:** Write doc.
- [ ] **Step 4:** Commit `feat(services): add TsumikiAnalytics protocol + no-op + event value types`.

### Task 2.2: TsumikiAdsCoordinator

**Files:**
- Create `Sources/TsumikiServices/Ads/TsumikiAdsCoordinator.swift`
- Create `Sources/TsumikiServices/Ads/TsumikiAdPlacement.swift`
- Create `Sources/TsumikiServices/Ads/NoopTsumikiAdsCoordinator.swift`
- Create `Tests/TsumikiServicesTests/TsumikiAdsCoordinatorTests.swift`
- Create `docs/services/Ads.md`

**API sketch:**

```swift
public protocol TsumikiAdsCoordinator: Sendable {
    func preload(_ placement: TsumikiAdPlacement) async
    func showInterstitial(from placement: TsumikiAdPlacement) async -> TsumikiAdResult
    func showRewarded(from placement: TsumikiAdPlacement) async -> TsumikiAdResult
    var isPremium: Bool { get async }    // gates suppression of ads
}

public struct TsumikiAdPlacement: Sendable, Hashable {
    public let id: String
    public init(_ id: String)
}

public enum TsumikiAdResult: Sendable, Equatable {
    case shown
    case skipped
    case rewarded(Int)         // reward count
    case failed(reason: String)
    case suppressed            // premium / privacy / quota
}

public struct NoopTsumikiAdsCoordinator: TsumikiAdsCoordinator {
    public init(isPremium: Bool = false) { _isPremium = isPremium }
    private let _isPremium: Bool
    public var isPremium: Bool { get async { _isPremium } }
    public func preload(_ placement: TsumikiAdPlacement) async {}
    public func showInterstitial(from placement: TsumikiAdPlacement) async -> TsumikiAdResult { .suppressed }
    public func showRewarded(from placement: TsumikiAdPlacement) async -> TsumikiAdResult { .suppressed }
}
```

- [ ] **Step 1:** Tests — placement equality, result enum cases, noop suppresses unconditionally.
- [ ] **Step 2:** Implement.
- [ ] **Step 3:** Doc.
- [ ] **Step 4:** Commit `feat(services): add TsumikiAdsCoordinator protocol + no-op (premium-aware)`.

### Task 2.3: TsumikiNotifications

**Files:**
- Create `Sources/TsumikiServices/Notifications/TsumikiNotifications.swift`
- Create `Sources/TsumikiServices/Notifications/TsumikiNotificationRequest.swift`
- Create `Sources/TsumikiServices/Notifications/NoopTsumikiNotifications.swift`
- Create `Sources/TsumikiServices/Notifications/UserNotificationCenterTsumikiNotifications.swift`  (UN-default behind `#if canImport(UserNotifications)`)
- Create `Tests/TsumikiServicesTests/TsumikiNotificationsTests.swift`
- Create `docs/services/Notifications.md`

**API sketch** (modelled on `warrantyreminder/Services/NotificationCenterProtocol.swift` but Sendable-friendly and vendor-neutral):

```swift
public protocol TsumikiNotifications: Sendable {
    func requestAuthorization(options: TsumikiNotificationAuthOptions) async throws -> Bool
    func currentAuthorizationStatus() async -> TsumikiNotificationAuthStatus
    func schedule(_ request: TsumikiNotificationRequest) async throws
    func cancel(identifiers: [String]) async
    func pendingIdentifiers() async -> [String]
    func setBadgeCount(_ count: Int) async throws
}

public struct TsumikiNotificationRequest: Sendable, Identifiable {
    public let id: String
    public let title: String
    public let body: String
    public let trigger: TsumikiNotificationTrigger
    public let categoryIdentifier: String?
    public let userInfo: [String: String]      // string-only for Sendable
    public let badge: Int?
}

public enum TsumikiNotificationTrigger: Sendable, Equatable {
    case timeInterval(TimeInterval, repeats: Bool)
    case calendar(DateComponents, repeats: Bool)
}

public struct TsumikiNotificationAuthOptions: OptionSet, Sendable {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static let alert  = TsumikiNotificationAuthOptions(rawValue: 1 << 0)
    public static let badge  = TsumikiNotificationAuthOptions(rawValue: 1 << 1)
    public static let sound  = TsumikiNotificationAuthOptions(rawValue: 1 << 2)
}

public enum TsumikiNotificationAuthStatus: Sendable {
    case notDetermined, denied, authorized, provisional, ephemeral
}
```

- [ ] **Step 1:** Tests — request init, trigger enum cases, noop returns `.notDetermined`, `pendingIdentifiers()` empty.
- [ ] **Step 2:** Implement noop. Implement `UserNotificationCenterTsumikiNotifications` that bridges to `UNUserNotificationCenter` (gated `#if canImport(UserNotifications)`). The UN-bridge maps `TsumikiNotificationTrigger` → `UNTimeIntervalNotificationTrigger` / `UNCalendarNotificationTrigger` and `TsumikiNotificationAuthStatus` from `UNAuthorizationStatus`.
- [ ] **Step 3:** Doc.
- [ ] **Step 4:** Commit `feat(services): add TsumikiNotifications protocol + UN-default + no-op`.

### Task 2.4: TsumikiPaywallController (protocol surface only — implementation in Phase 2.5)

**Files for this task:**
- Create `Sources/TsumikiServices/Paywall/TsumikiPaywallController.swift`  (protocol + state struct)
- Create `Sources/TsumikiServices/Paywall/TsumikiPaywallState.swift`
- Create `Sources/TsumikiServices/Paywall/NoopTsumikiPaywallController.swift`
- Create `Tests/TsumikiServicesTests/TsumikiPaywallControllerTests.swift`
- Create `docs/services/PaywallController.md`

**API sketch:**

```swift
public protocol TsumikiPaywallController: Observable, Sendable, AnyObject {
    var state: TsumikiPaywallState { get }
    func load() async
    func purchase(productId: String) async throws
    func restore() async throws
    func dismiss() async
}

@Observable
public final class TsumikiPaywallState: Sendable {
    public var products: [TsumikiPaywallProduct]
    public var isPurchasing: Bool
    public var lastError: String?
    public var isEntitled: Bool
    public init(products: [TsumikiPaywallProduct] = [], isPurchasing: Bool = false, lastError: String? = nil, isEntitled: Bool = false) {
        self.products = products
        self.isPurchasing = isPurchasing
        self.lastError = lastError
        self.isEntitled = isEntitled
    }
}

public struct TsumikiPaywallProduct: Sendable, Identifiable, Equatable {
    public let id: String           // App Store product ID
    public let displayName: String
    public let displayPrice: String // already localised
    public let period: String?      // "month", "year", or nil for lifetime
}

public final class NoopTsumikiPaywallController: TsumikiPaywallController { /* … */ }
```

- [ ] **Step 1:** Tests — product equality, noop transitions: load → empty products, purchase → unsupported error, restore → no-op, dismiss → state untouched.
- [ ] **Step 2:** Implement protocol + Noop.
- [ ] **Step 3:** Doc.
- [ ] **Step 4:** Commit `feat(services): add TsumikiPaywallController protocol + Noop + state`.

### Task 2.5: Wire PaywallScreen in Catalog to use the protocol

- [ ] **Step 1:** Update `Examples/TsumikiCatalog/Screens/PaywallScreen.swift` to use `NoopTsumikiPaywallController` so the catalog demonstrates protocol-driven state binding. Add a "force entitled" toggle in the screen to exercise the success path manually.
- [ ] **Step 2:** Commit `chore(catalog): drive PaywallScreen via NoopTsumikiPaywallController`.

### Phase 2 acceptance (tag v0.2.0 — bundle Phase 1 + Phase 2)

- [ ] `/usr/bin/swift test` — services suite added (target +12 tests minimum). Total ≥ 65 tests green.
- [ ] `Sources/TsumikiServices/Empty.swift` deleted (no longer needed).
- [ ] All four service docs published under `docs/services/`.
- [ ] Catalog's PaywallScreen consumes `NoopTsumikiPaywallController`.
- [ ] Tag `v0.2.0` cut from master.

**Phase 2 blockers:**
- `Observable` on a protocol with `AnyObject` requirement — the macro generates per-class observation registrars, not per-protocol. The state object holds `@Observable` instead; the protocol just exposes `var state: TsumikiPaywallState { get }`. If that pattern fights SwiftUI's tracking, fall back to `ObservableObject` + `@Published` for the state class.
- `UNUserNotificationCenter` API surface drift between iOS 17 and 18 — pin to iOS 17 deployment target and test on both.

---

## Phase 2.5 — v0.2.1: StoreKit 2 paywall controller implementation

A real `StoreKit2TsumikiPaywallController` so WR migration in Phase 3 has a working subscription flow.

### Task 2.5.1: StoreKit2TsumikiPaywallController

**Files:**
- Create `Sources/TsumikiServices/Paywall/StoreKit2TsumikiPaywallController.swift`
- Create `Tests/TsumikiServicesTests/StoreKit2PaywallControllerTests.swift`  (StoreKit Testing with `.storekit` config)
- Update `docs/services/PaywallController.md` with StoreKit 2 example

- [ ] **Step 1:** Tests against a `.storekit` test config (fixture in `Tests/TsumikiServicesTests/Fixtures/`): load returns 2 products; purchase resolves `isEntitled = true`; restore is idempotent.
- [ ] **Step 2:** Implement using `StoreKit.Product`, `Product.purchase()`, `Transaction.currentEntitlements`. No RevenueCat dependency in the core target — RC adapter lives elsewhere if needed.
- [ ] **Step 3:** Hand-test on simulator with the catalog's PaywallScreen by swapping `Noop…` for `StoreKit2…`.
- [ ] **Step 4:** Commit `feat(services): add StoreKit2TsumikiPaywallController behind protocol`.

### Phase 2.5 acceptance (tag v0.2.1)

- [ ] StoreKit Testing suite passes against `.storekit` config.
- [ ] Catalog PaywallScreen optionally drives StoreKit 2 controller (gated by a debug-only flag — default stays Noop so the test target doesn't require StoreKit Testing entitlement).
- [ ] Tag `v0.2.1` cut from master.

**Phase 2.5 blockers:**
- StoreKit Testing requires Xcode signing config — verify CI build can run the StoreKit test target (likely needs `xcodebuild` rather than `swift test`; document fallback to skip on Linux/CI-without-Xcode).
- RevenueCat parity is out-of-scope for v0.2.1. WR currently uses RC; the migration in Phase 3 will keep WR on `RevenueCatService` initially and only replace the *paywall view* (not the purchase backend) with Tsumiki — `TsumikiPaywall` view consumes whatever `TsumikiPaywallController` WR's RC service is wrapped behind. The wrapper itself lives in WR (not Tsumiki) because it's vendor-specific.

---

## Phase 3 — v0.3.0: warrantyreminder migration

WR is the smallest of the five source apps and the most direct mapping (one WR component ↔ one Tsumiki component for most cases). Migrating it validates the public API and produces `docs/MIGRATION.md`.

### Migration order (lowest risk → highest)

1. **TsumikiToast** ← `Views/Components/WRToast.swift`
2. **TsumikiDialog** ← `Views/Components/WRDialog.swift`
3. **TsumikiSettingsRow** ← `Views/Components/WRSettingsRow.swift`
4. **TsumikiSplash** ← `Views/Splash/SplashView.swift`
5. **TsumikiOnboardingPage + Dots + ProgressBar** ← `Views/Onboarding/OnboardingPageView.swift` + `OnboardingContainerView.swift`
6. **TsumikiTextField** ← `Views/Vault/VaultSearchBar.swift`, `Views/AddWarranty/ManualEntryFormView.swift`, `Views/CameraScan/OCRResultReviewView.swift`, `Views/AddWarranty/ReceiptReviewFormView.swift`, `Views/Detail/WarrantyDetailView.swift`
7. **TsumikiButton** ← every CTA in the app (Settings, AboutView, AddWarranty save buttons, etc.)
8. **TsumikiPaywall** ← `Views/Paywall/PaywallView.swift` + `PremiumOfferSheet.swift` (paywall view only; RC subscription backend stays)

Rationale for the order:
- **Atomic components first** (Toast, Dialog, SettingsRow) — drop-in replacements with no layout shift.
- **Splash + Onboarding** — only run on first launch, so any regression is caught before the rest is touched.
- **TextField + Button** — high-fan-out, touches the most files. Done after the easier surfaces validate the API.
- **Paywall last** — drives revenue. Migrate the *view* only; keep RC's purchase flow untouched in v0.3.0.

### Task 3.0: Add Tsumiki SwiftPM dependency to WR

- [ ] **Step 1:** In WR's `Package.swift` (or Xcode project Package Dependencies), add `.package(url: "<tsumiki-git-url>", from: "0.2.1")`.
- [ ] **Step 2:** Add `TsumikiComponents`, `TsumikiTheme`, `TsumikiServices` as link dependencies of WR's main target.
- [ ] **Step 3:** Add `import TsumikiTheme` + `.tsumikiTheme(DefaultTheme.light)` (or a WR custom theme) at WR's root view.
- [ ] **Step 4:** WR builds + launches on simulator unchanged.
- [ ] **Step 5:** Commit in WR's repo (NOT Tsumiki's). `chore: depend on Tsumiki 0.2.1`.

**Note from `.claude/CLAUDE.md`:** "Never edit a source project from within Tsumiki work — migrations happen in the source project's repo, not here." All Phase 3 work below happens in `/Users/carlos/projects/warrantyreminder`, NOT in Tsumiki. The deliverable that lands in *this* repo is `docs/MIGRATION.md`.

### Task 3.1 → 3.8: Per-component swap (one PR per step in WR's repo)

For each component in the migration order:

- [ ] **Step 1:** In WR, find every call site of the WR component via `grep -rln`. Note any per-call-site quirks (custom colors, modifiers).
- [ ] **Step 2:** Replace call sites with Tsumiki equivalents. Map WR custom colors to nearest theme tokens; if a token doesn't exist, file a Tsumiki issue rather than patching WR.
- [ ] **Step 3:** Delete the WR component file once all call sites are migrated.
- [ ] **Step 4:** Run WR's existing tests (whatever it has). Manually verify on simulator (see "Manual verification strategy" below).
- [ ] **Step 5:** Commit in WR: `refactor(ui): replace WR<X> with Tsumiki<X>` (one commit per concept).

### Manual verification strategy (no snapshot tests in MVP)

PRD §Non-Goals confirms no snapshot tests for v1. WR migration uses **manual visual diff**:

1. **Before each swap:** Take screenshots of the affected screens on iPhone 15 simulator in both light and dark mode. Save under `/Users/carlos/projects/warrantyreminder/migration-baseline/<concept>/`.
2. **After each swap:** Re-take the same screenshots. Compare side-by-side in Preview. Note any deltas in the migration log.
3. **Acceptable deltas:** Padding shifts ≤ 4 pt, color shifts within the theme's intended palette (e.g. WR's accent → Tsumiki's accent even if slightly different hue), font weight changes from custom → system.
4. **Unacceptable deltas:** Missing elements, completely broken layouts, illegible text, missing tap targets, accessibility regressions.
5. **For interactive flows** (Add Warranty form, Paywall, Onboarding): record a screen capture of the happy path before and after.
6. **Migration log** lives at `/Users/carlos/projects/warrantyreminder/MIGRATION-LOG.md`, one section per concept. Captures the screenshot pair locations and any decisions.

### Task 3.9: Write docs/MIGRATION.md (in Tsumiki repo)

After all WR call sites are migrated, distil the experience into `docs/MIGRATION.md` in *this* repo (Tsumiki). Section per concept:

```markdown
## Migrating to Tsumiki<Concept>

### Before (consumer code)
```swift
// 5–10 line snippet from WR pre-migration
```

### After
```swift
// 5–10 line snippet using Tsumiki
```

### Param mapping
| Before | After | Notes |
|---|---|---|

### Gotchas
- …
```

- [ ] **Step 1:** Draft `docs/MIGRATION.md` with 8 sections (one per concept ported to WR).
- [ ] **Step 2:** Update README "Migrating from app-specific components" section with a link.
- [ ] **Step 3:** Commit in Tsumiki: `docs: add MIGRATION.md drawn from warrantyreminder port`.

### Phase 3 acceptance (tag v0.3.0)

- [ ] WR `xcodebuild -scheme warrantyreminder build` succeeds.
- [ ] WR app runs end-to-end on iPhone 15 simulator without visible visual regression (per the manual verification strategy above).
- [ ] WR's `Views/Components/WR*` files for migrated concepts are deleted.
- [ ] `docs/MIGRATION.md` shipped in Tsumiki repo.
- [ ] PRD Success Criterion #3 ("warrantyreminder migrated to Tsumiki without visible visual regression") closed.
- [ ] Tag `v0.3.0` cut from master.

**Phase 3 blockers:**
- WR's custom RC paywall view structure may diverge from `TsumikiPaywall`'s value-driven model. Mitigation: wrap RC's `Offering`/`Package` into `TsumikiPaywallProduct` in WR-side glue code; do NOT modify `TsumikiPaywall` to accept RC types.
- WR's `WarrantyProgressBar` and `StatusBadgeView` are domain-specific and stay in WR. Don't try to absorb them into Tsumiki.
- Theme token gaps surfaced by migration (e.g. WR uses a "warning" amber that Tsumiki currently only has via `colors.warning` — verify the hue matches before swapping; if not, add a WR custom theme that overrides `warning` rather than mutating `DefaultTheme`).

---

## End-of-plan verification (run before tagging v0.3.0)

- [ ] `/usr/bin/swift build` — all 5 Tsumiki targets compile.
- [ ] `/usr/bin/swift test` — all tests across all modules pass (target ≥ 75 tests after Phase 0/2/2.5).
- [ ] `python3 -m unittest discover scripts/tests` — 18 scanner tests still pass.
- [ ] `python3 -m scripts.lint_no_hardcoded Sources/TsumikiComponents` — exit 0.
- [ ] `cd Examples/TsumikiCatalog && /usr/bin/swift build` — exit 0.
- [ ] `directory-tree.md` regenerated (see Plan B end-of-plan command).
- [ ] `README.md` Modules + Examples sections updated.
- [ ] `docs/MIGRATION.md` published.
- [ ] All four service docs published under `docs/services/`.
- [ ] Tags `v0.1.0`, `v0.2.0`, `v0.2.1`, `v0.3.0` exist on master.

---

## Notes for the executor

- **Trust the arbiter spec for TextField** (Phase 0) the same way Plan B trusted the existing 8 arbiter specs. Don't second-guess the merged param list by re-reading source — that's what the arbiter pass is for.
- **Catalog is a manual smoke test, not an automated one.** It is OK to ship it without unit tests; its job is to render every component under every theme so a human can eyeball regressions. The 51-test Swift suite still gates merges.
- **Services target was empty until Phase 2.** Deleting `Sources/TsumikiServices/Empty.swift` is part of Task 2.1 (or the first service to ship, whichever first). Do not leave both a placeholder and real code in the target.
- **Paywall split:** `TsumikiPaywall` (view, in `TsumikiComponents`) and `TsumikiPaywallController` (state + lifecycle, in `TsumikiServices`) are intentionally separate. The view never knows about StoreKit; the controller never knows about colors. Bind them via state at the call site.
- **Source project edits go in source repos.** Tsumiki's repo only ever holds the library, the catalog example, and migration docs. WR-side commits land in `/Users/carlos/projects/warrantyreminder`.
- **No `Co-Authored-By: Claude …` trailers.** Conventional Commits, human author only. See `.claude/CLAUDE.md` for the rule.

---

## Cross-references

- PRD: `docs/PRD.md` (phases P2 TextField gap + P3 catalog/migration).
- Design spec: `docs/superpowers/specs/2026-05-11-tsumiki-mvp-design.md`.
- Plan A (executed): `docs/superpowers/plans/2026-05-11-tsumiki-mvp-p0-p1.md`.
- Plan B (executed): `docs/superpowers/plans/2026-05-11-tsumiki-mvp-p2.md`.
- Arbiter templates: `docs/superpowers/research/arbiters/Button.md`, `…/Onboarding.md`, etc.
- Orchestrator playbook: `.claude/CLAUDE.md`.
- Resume guide: `NEXT-SESSION.md`.
