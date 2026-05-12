# Tsumiki

A SwiftUI component library that consolidates the reusable surface area of five
iOS apps (aquabrew, pulselog, lucidmate, warrantyreminder, zeroblock) into one
plug-and-play, theme-extensible Swift package.

## Install

In `Package.swift`:

```swift
.package(url: "https://github.com/<owner>/tsumiki.git", from: "0.1.0")
```

Then add the modules you need to your target:

```swift
.product(name: "TsumikiTheme",      package: "tsumiki"),
.product(name: "TsumikiComponents", package: "tsumiki"),
```

## Quickstart

```swift
import SwiftUI
import TsumikiComponents
import TsumikiTheme

@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().tsumikiTheme(DefaultTheme.light)
        }
    }
}

struct ContentView: View {
    @State private var saved = false
    var body: some View {
        Button("Save") { saved = true }
            .tsumikiToast(isPresented: $saved) {
                TsumikiToast(title: "Saved", style: .success)
            }
    }
}
```

## Modules
- `TsumikiCore` — shared protocols + env keys.
- `TsumikiTheme` — `TsumikiTheme` protocol, `DefaultTheme.light/.dark`, tokens
  (colours / typography / spacing / radius / shadow / opacity), env injection,
  `.with(\\.kp, value)` override helper.
- `TsumikiComponents` — `TsumikiToast`, `TsumikiSplash`, `TsumikiSettingsRow`,
  `TsumikiLoading` + `TsumikiSkeleton` + `.tsumikiShimmer()`, `TsumikiDialog`
  (+ `TsumikiDialogAction`), `TsumikiCard`, `TsumikiButton`, `TsumikiPaywall`
  (+ `TsumikiPaywallFeature`, `TsumikiPaywallPrice`), `TsumikiScannerReticle`
  (+ `TsumikiReticleRectKey`), `TsumikiOnboardingPage`, `TsumikiOnboardingDots`,
  `TsumikiOnboardingProgressBar`, `TsumikiTextField`
  (+ `TsumikiTextFieldStyle`, `TsumikiTextFieldValidation`, `TsumikiKeyboardType`).
- `TsumikiAnimations` — reusable animations + view modifiers (placeholder; populated by Plan C).
- `TsumikiServices` — analytics, ads, paywall (StoreKit 2), notifications protocols + defaults (placeholder; populated by Plan C).

Per-component docs: `docs/components/`. Scope: `docs/PRD.md`. Design + plans: `docs/superpowers/`.

## Catalog (showcase app)

`Examples/TsumikiCatalog/` is a SwiftUI app that browses every shipped
component with a theme picker (Light / Dark / Sakura). See
[`Examples/TsumikiCatalog/README.md`](Examples/TsumikiCatalog/README.md) for
build and run instructions.

## Releasing

`scripts/release.py` automates semver bump → tag → GitHub Release based on
Conventional Commits since the last tag. See [CHANGELOG.md](CHANGELOG.md).

```bash
python3 scripts/release.py --dry-run    # preview
python3 scripts/release.py              # cut release (requires gh + clean tree)
```

## Custom theme

```swift
let pinkTheme = DefaultTheme.light.with(\.colors.accent, .pink)
ContentView().tsumikiTheme(pinkTheme)
```

## Status

- **P0 — scanner pipeline + manifests:** ✅ done. 5 source projects scanned (115 components mapped across 10 concepts).
- **P1 — package scaffolding + theme + reference Toast:** ✅ done.
- **P2 — component port wave:** ✅ done. All 9 concepts shipped (Splash, SettingsRow, Loading, Dialog, Card, Button, Paywall, ScannerReticle, OnboardingKit). `TsumikiOpacity` token landed alongside the scanner reticle.
- **P3 — TsumikiCatalog + first migration (warrantyreminder):** Phase 0 ✅ done (`TsumikiTextField` ported, closes the PRD MVP component set). Catalog + Services + WR migration in Plan C.

57 Swift tests + 18 Python tests, all green on iOS sim (51 on macOS host). Lint (`scripts/lint_no_hardcoded.py`) clean on `Sources/TsumikiComponents`.

## Repo layout
See `directory-tree.md`.
