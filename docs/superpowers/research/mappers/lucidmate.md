# Project: lucidmate

## Summary
- Swift files: 256
- Components: 12
- Concepts: 4 (Card×8, CameraScan×2, Loading×1, Paywall×1)
- Theme tokens: 14 colours (hex null), 15 fonts, 16 spacings, 0 radii
- Animations/Services: none

## Components

| concept | name | path | loc |
|---|---|---|---|
| CameraScan | QRScannerOverlayView | Views/QRScanner/QRScannerOverlayView.swift | 146 |
| CameraScan | QRScannerView | Views/QRScanner/QRScannerView.swift | 109 |
| Card | DailyStatsCardView, FeatureHighlightCard, GameSummaryCardView, PlayActionCard, PracticeModeCardView, QuickResumeCard, ShareCardContent, SubcategoryCardView | Views/Play, Auth, PostGame, Training, Components | 35-115 |
| Loading | TrainingCategorySkeletonView | Views/Training/TrainingCategorySkeletonView.swift | 67 |
| Paywall | LucidMatePaywallView | Views/Paywall/PaywallView.swift | 19 |

## Theme tokens
- Colours (hex null): cardBackground, engagementCard, elevatedBackground, textTertiary; sign-in palette (signInGradientTop/Bottom, signInGold, signInTitle/Subtitle/CardOverlay/PatternOverlay), boardLightSquare/DarkSquare, featureCardBackground.
- Spacings: 1, 2, 4, 5, 6, 8, 10, 12, 14, 16, 20, 24, 32, 40, 42, 90 (8pt grid majority + odd-balls)
- Fonts: monospacedDigit on headline/subheadline/caption suggests stat/timer UI.

## Notable observations
- Card concept dominates (8/12 components, 5 feature folders). Strongest candidate for unified Card primitive.
- Zero public_init_params; views consume `@EnvironmentObject`/`@StateObject` directly. Tsumiki extraction needs explicit init params.
- Colour palette dominated by sign-in/auth theme (7 of 14). Lacks generic semantic colours.
- Domain-specific: QR scanner pair (~255 LOC) + chess board surfaces; QR could become generic `CameraScanOverlay`.
- Paywall is a thin RevenueCatUI wrapper.
