# TsumikiCatalog

A minimal SwiftUI showcase app that browses every shipped Tsumiki component.
Doubles as a visual smoke test — no snapshot tests in MVP.

## Layout

```
Examples/TsumikiCatalog/
├── Package.swift                                  # depends on ../../ (the umbrella)
└── Sources/TsumikiCatalog/
    ├── CatalogApp.swift                           # @main App + theme picker state
    ├── CatalogTheme.swift                         # Light / Dark / Sakura override
    ├── CatalogRootView.swift                      # NavigationStack + entries list
    └── Galleries/
        ├── ButtonGallery.swift                    # Style × Size × Shape matrix
        ├── CardGallery.swift                      # padding + elevation states
        ├── ToastGallery.swift                     # info / success / warning / danger
        ├── LoadingGallery.swift                   # sizes + cancel variant
        ├── DialogGallery.swift                    # info / confirm / destructive
        ├── SplashGallery.swift                    # logo + tagline animation
        ├── OnboardingGallery.swift                # Page + Dots + ProgressBar
        ├── PaywallGallery.swift                   # features + price card + CTA
        ├── ScannerReticleGallery.swift            # brackets / continuous / states
        └── SettingsRowGallery.swift               # toggle / value / chevron / link
```

## Components covered (PRD MVP)

- Button (`TsumikiButton`)
- Card (`TsumikiCard`)
- Toast (`TsumikiToast`)
- Loading (`TsumikiLoading`)
- Dialog (`TsumikiDialog`)
- Splash (`TsumikiSplash`)
- OnboardingPage (`TsumikiOnboardingPage` + `TsumikiOnboardingDots` + `TsumikiOnboardingProgressBar`)
- Paywall (`TsumikiPaywall`)
- ScannerReticle (`TsumikiScannerReticle`)
- SettingsRow (`TsumikiSettingsRow`)

`TextField` is intentionally absent — `TsumikiTextField` is tracked under
issue #3 and will be added to the Catalog once it lands.

## Build

The Catalog is a SwiftPM executable that depends on the Tsumiki umbrella package
via a relative `path:` reference. Build it from the Catalog directory:

```bash
cd Examples/TsumikiCatalog
/usr/bin/swift build
```

This compiles the Catalog and all transitively-required Tsumiki targets on the
host. iOS simulator runs require Xcode — open `Package.swift` in Xcode 15+ and
select an iOS 17 simulator destination from the scheme menu, then ⌘R.

```bash
xcodebuild \
  -scheme TsumikiCatalog \
  -destination "platform=iOS Simulator,name=iPhone 15,OS=17.0" \
  build
```

## Theme picker

`CatalogApp` holds a `CatalogThemeChoice` `@State` and propagates the selected
theme via `.tsumikiTheme(_:)`. Switching the segmented picker at the top of the
root list re-renders every gallery instantly.

`CatalogThemeChoice.sakura` shows a custom theme override built off of
`DefaultTheme.light` with a different accent, surface, and radius scale —
demonstrating that downstream apps can compose their own themes from the
default palette.

## Constraints

- The Catalog only consumes **public** Tsumiki APIs. No copy/paste of component
  internals, no `@testable import`, no reaching into private types.
- New components are added by creating a new `*Gallery.swift` under
  `Sources/TsumikiCatalog/Galleries/` and an entry in `CatalogRootView.entries`.
