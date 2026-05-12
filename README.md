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
- `TsumikiTheme` — `TsumikiTheme` protocol + `DefaultTheme` + tokens + env injection.
- `TsumikiComponents` — SwiftUI components.
- `TsumikiAnimations` — reusable animations + view modifiers.
- `TsumikiServices` — analytics, ads, paywall, notifications protocols + defaults.

See `docs/PRD.md` for scope and `docs/components/` for per-component reference.

## Custom theme

```swift
let pinkTheme = DefaultTheme.light.with(\.colors.accent, .pink)
ContentView().tsumikiTheme(pinkTheme)
```

## Status

P0 + P1 complete: scanner pipeline, modular package skeleton, full TsumikiTheme,
reference TsumikiToast component. Plan B (component port wave) and Plan C
(catalog + first migration) tracked in `docs/superpowers/plans/`.

## Repo layout
See `directory-tree.md`.
