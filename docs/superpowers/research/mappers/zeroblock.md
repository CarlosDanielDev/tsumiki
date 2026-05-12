# Project: zeroblock

## Summary
- Swift files: 270
- Components: 33
- Concepts: 6 (Button×6, Card×19, Dialog×2, Loading×2, OnboardingPage×2, Paywall×1)
- Theme tokens: 0 colours extracted, 17 fonts, 24 spacings, 9 radii
- Animations/Services: none

## Components (33)

| concept | name | loc |
|---|---|---|
| Button | BoostButton, CircularFloatingButton, LeaderboardButtonExample, ModeButton, ModeTabButton, RewardedUndoButton | 17-123 |
| Card | ActiveMatchCard, BoostPreviewCard, BoostShopCard, BotDifficultyCard, CategoryBoostCard, CoinStatsCard, DailyLimitCard, FeaturedBoostCard, GameModeListCard, MatchmakingStateCard, MilestoneStatCard, ModeCard, OpponentProfileCard, PlayerStatsCard, ScoreCard, StatCard, StreakCard, ThemePreviewCard, TimelineCompletionCard, WeeklyLoginCard | 25-285 |
| Dialog | ConfirmationDialogControls, DialogOverlay | 17-239 |
| Loading | AppLoadingIndicator, LeaderboardLoadingView | 37-53 |
| OnboardingPage | OnboardingStepView, OnboardingView | 131-277 |
| Paywall | PaywallSheetView | 77 |

## Theme tokens
- Colours: 0 extracted (manifest empty despite ThemePreviewCard implying rich theme — scanner limitation).
- Spacings (24): 0, 2, 3, 4, 5, 6, 8, 10, 12, 14, 15, 16, 18, 20, 24, 30, 32, 40, 48, 52, 56, 60, 76, 110
- Radii (9): 4, 6, 8, 10, 12, 14, 16, 20, 24
- Fonts (17): full Apple type scale × regular/bold/monospaced/monospacedDigit variants.

## Notable observations
- Cards dominate (19/33, 58%). Several large (FeaturedBoost 285, CategoryBoost 241, MatchmakingState 238, ModeCard 180) — decompose into generic Card primitive + content slots.
- Every public_init_params empty — apps use internal state, Tsumiki extraction needs API design from scratch.
- Spacing scale noisy (24 values, odd ones 3, 5, 14, 18, 52, 76, 110).
- Naming collisions: ModeButton/ModeCard same file; StatCard/MilestoneStatCard/PlayerStatsCard/CoinStatsCard overlap; Boost-card family (BoostShop/BoostPreview/Featured/Category).
- Colour palette absent from manifest — scanner needs improvement before colour reconciliation.
