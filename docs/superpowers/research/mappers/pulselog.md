# Project: pulselog

## Summary
- Swift files: 149
- Components: 21
- Concepts: 5 (Button, Card, OnboardingPage, Toast)
- Theme tokens: 7 semantic colours, 13 font styles, 11 spacings, 0 radii
- Animations/Services: none

## Components

| concept | name | path | loc |
|---|---|---|---|
| Button | QuickLogButton | Views/Dashboard/Components/QuickLogButton.swift | 31 |
| Card | BestDayCard, CalendarDayCard, DayCompositionCard, EnergyCurveCard, LastEnergyScoreCard, MisalignmentCard, NoiseAuditCard, PowerWindowsCard, SprintProgressCard | Views/Insights+Calendar+Dashboard/Components | 26-72 |
| OnboardingPage | OnboardingBackgroundView, OnboardingBottomBar, OnboardingConfigSlide, OnboardingDotIndicator, OnboardingGreetingSlide, OnboardingNotificationSlide, OnboardingPageView, OnboardingProgressBar, OnboardingView, OnboardingWelcomeSlide | Views/Onboarding | 31-145 |
| Toast | CSVCopiedToastView | Views/Shared/CSVCopiedToastView.swift | 16 |

## Theme tokens
- Colours (semantic, hex null in manifest): primary, secondary, tertiary, card, cardElevated, cardSelected, placeholder
- Spacings: 2, 4, 6, 8, 10, 12, 14, 16, 24, 40, 68
- Fonts: 13 distinct style+weight combos; heavy use of .monospaced/.monospacedDigit on caption/headline/subheadline (numeric data display)

## Notable observations
- Onboarding largest cluster (10 files, ~928 LOC). Strong candidate for OnboardingKit: page, dots, progress bar, bottom bar, background.
- 9 cards are concrete data-bound views; need a generic `Card` container before any can promote.
- Theme palette small + semantic; maps cleanly to neutral+surface scheme. No hexes to reconcile.
- Spacing skips 20/32/48/56 — atypical ladder.
- Tsumiki should expose `.numeric`/monospacedDigit token for stat displays.
