# Project: aquabrew

## Summary
- Swift files: 164
- Components: 37
- Concepts: 10
- Theme tokens: 17 colours, 8 font styles, 24 spacings, 8 radii
- Animations: none
- Services: none

## Components

| concept | name | path | params | loc |
|---|---|---|---|---|
| Button | AquaBlenderActionButtons | Views/AquaBlender/AquaBlenderActionButtons.swift | 0 | 65 |
| Button | DetectionBoxButton | Views/CameraScan/OCRResultReviewView.swift | 0 | 90 |
| Button | ModernActionButton | Views/Home/HomeView.swift | 0 | 45 |
| Button | SocialLinkButton | Views/Settings/AboutView.swift | 0 | 29 |
| CameraScan | CameraScanView | Views/CameraScan/CameraScanView.swift | 0 | 365 |
| CameraScan | ScannerOverlayView | Views/CameraScan/ScannerOverlayView.swift | 0 | 149 |
| Card | (19 cards, see manifests/aquabrew.json) | Views/Home, Views/AquaBlender, Views/Components/Cards | 0 | 27-260 |
| Dialog | AquaBrewDialog | Views/Components/Dialogs/AquaBrewDialog.swift | 0 | 225 |
| Loading | AquaLoadingView | Views/Components/Loading/AquaLoadingView.swift | 0 | 210 |
| Loading | HomeSkeleton | Views/Components/Loading/HomeSkeleton.swift | 0 | 103 |
| Loading | SkeletonShape | Views/Components/Loading/ShimmerModifier.swift | 0 | 33 |
| OnboardingPage | OnboardingContainerView | Views/Onboarding/OnboardingContainerView.swift | 0 | 277 |
| OnboardingPage | OnboardingDotsProgress | Views/Onboarding/OnboardingDotsProgress.swift | 0 | 39 |
| OnboardingPage | OnboardingGreetingView | Views/Onboarding/OnboardingGreetingView.swift | 0 | 211 |
| OnboardingPage | OnboardingPageView | Views/Onboarding/OnboardingPageView.swift | 0 | 427 |
| OnboardingPage | OnboardingProgressBar | Views/Onboarding/OnboardingProgressBar.swift | 0 | 93 |
| SettingsRow | SettingsRow | Views/Settings/SettingsView.swift | 0 | 34 |
| Splash | AquaBrewSplashView | Views/Splash/AquaBrewSplashView.swift | 0 | 146 |
| Toast | AquaBrewToast | Views/Components/Toast/AquaBrewToast.swift | 0 | 136 |

## Theme tokens

### Colours (17)
coffeeBrown #6B4423, darkCoffee #4A2F17, waterBlue #1565C0, primaryText #1A1A1A,
secondaryText #525252, tertiaryText #757575, backgroundPrimary #FFFFFF,
backgroundAlt #F8F8F8, borderPrimary #E5E5E5, borderLight #F0F0F0, success #4CAF50,
error #F44336, premium #FFB74D; plus 4 mineral colours (calcium/magnesium/
bicarbonate/sodium) without hex (domain-specific, not framework material).

### Spacings (24)
0, 2, 3, 4, 5, 6, 8, 10, 12, 14, 16, 18, 20, 24, 28, 32, 40, 52, 60, 68, 100, 120, 140, 160

### Radii (8)
4, 8, 10, 12, 16, 20, 24, 28

### Font styles (8)
.system, .largeTitle, .subheadline, .headline, .caption, .title, .body, .caption (bold)

## Notable observations
- Card concept dominates: 19 of 37 components are Cards, heavy concentration in HomeView.swift and AquaBlender cluster.
- Onboarding is unusually heavy: 5 distinct OnboardingPage components totalling ~1,047 LOC.
- All components report `public_init_params: []` — manifest extractor doesn't capture internal init.
- Spacing scale wide and irregular — needs tightening in Tsumiki.
- 4 mineral colours are domain-specific; only 13 semantic colours are framework candidates.
- Domain-specific concepts (CameraScan with OCR, AquaBlender water-mixing cards) tightly coupled, not reusable.
