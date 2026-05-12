# Project: warrantyreminder

## Summary
- Swift files: 89
- Components: 12
- Concepts: 9 (Button, CameraScan, Card, Dialog, OnboardingPage, Paywall, SettingsRow, Splash, Toast)
- Theme tokens: 17 colours, 9 font styles, 20 spacings, 5 radii
- Animations/Services: none

## Components

| concept | name | path | loc |
|---|---|---|---|
| Button | AboutSocialButton | Views/Settings/AboutView.swift | 29 |
| CameraScan | CameraScanFlowView | Views/AddWarranty/AddWarrantyView.swift | 138 |
| CameraScan | CameraScanView | Views/CameraScan/CameraScanView.swift | 329 |
| CameraScan | ScannerOverlayView | Views/CameraScan/ScannerOverlayView.swift | 136 |
| Card | VaultCardView | Views/Vault/VaultCardView.swift | 43 |
| Dialog | WRDialog | Views/Components/WRDialog.swift | 230 |
| OnboardingPage | OnboardingContainerView, OnboardingPageView | Views/Onboarding | 124-169 |
| Paywall | PaywallView | Views/Paywall/PaywallView.swift | 74 |
| SettingsRow | WRSettingsRow | Views/Components/WRSettingsRow.swift | 43 |
| Splash | SplashView | Views/Splash/SplashView.swift | 48 |
| Toast | WRToast | Views/Components/WRToast.swift | 135 |

## Theme tokens
- Colours (17): vaultBlue #1A2B4A, vaultBlueDark #0F1B32, mintGreen #4ECDC4 (==success), amberYellow #F7B731, coralRed #FC5C65 (==error), premium #FFB74D + 11 semantic (no hex).
- Spacings (20): 2, 4, 5, 6, 7, 8, 10, 12, 14, 16, 18, 20, 24, 32, 40, 48, 52, 60, 108, 160
- Radii (5): 8, 10, 12, 16, 20
- Fonts (9): standard SwiftUI styles + .caption (monospaced)

## Notable observations
- Heavy CameraScan surface (3 views, 603 LOC). Strongest CameraScan candidate.
- Semantic colour aliasing: success==mintGreen, error==coralRed. Tsumiki should formalise two-tier scheme.
- "WR" prefix convention (`WRDialog`, `WRToast`, `WRSettingsRow`) suggests internal mini-design-system. Easy lift candidates.
- Spacing scale noisy: 20 distinct values, odd numbers (5, 7, 18), outliers (108, 160).
- All components 0 public init params (scanner limitation).
