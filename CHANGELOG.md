# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- releases -->

## [0.1.0] - 2026-05-12

### Added
- feat: implement unified changes for #33, #4 (f57d09e)
- feat: add release automation + TsumikiCatalog showcase app (3d1fb11)
- feat: implement changes for issue #3 (cfd09fe)
- feat(components): add TsumikiTextField with Style/Validation/secure-toggle (1e7e200)
- feat: implement changes for issue #2 (9ff6c11)
- feat(components): add TsumikiOnboardingKit (page + dots + progress bar) (6a7479e)
- feat(components): add TsumikiScannerReticle (overlay chrome) (4612dc0)
- feat(theme): add TsumikiOpacity (scrim/overlay/disabled) (fe22176)
- feat(components): add TsumikiPaywall + value types (Feature, Price) (1a9b5d6)
- feat(components): add TsumikiButton with full Style/Size/Shape/Layout matrix (14a6eea)
- feat(components): add TsumikiCard generic container primitive (31ee501)
- feat(theme,components): add colors.scrim token and TsumikiDialog (1dfe87b)
- feat(components): add TsumikiLoading + TsumikiSkeleton + .tsumikiShimmer() (d03ee4a)
- feat(components): add TsumikiSettingsRow with Trailing enum subsuming 5 variants (530ebd4)
- feat(components): add TsumikiSplash with reduce-motion-safe entry animation (e1d29b7)
- feat(theme,components): add TsumikiTheme + reference TsumikiToast (ac78fe8)
- feat(scripts): add scanner pipeline + lint with TDD coverage (e172bf7)
- feat: initialize Tsumiki SwiftPM package with five modular targets (57d8dbb)

### Changed
- chore: add to gitignore (6586976)
- chore: enable caveman bydefault (e586a3b)
- chore(maestro): expand config + ignore runtime/Xcode artifacts (c9a4fac)
- chore: add maestro.toml for multi-agent orchestration (9d6360a)
- chore: remove legacy Xcode skeleton, SwiftPM is canonical (b3fc55a)
- chore: preserve original Xcode project skeleton (e47fcd3)
- chore: expand .gitignore with Xcode + Package.resolved + editor entries (ee62ba1)
- chore: add CI, .claude orchestrator+subagents, docs, README, directory-tree (c308912)

### Fixed
- fix(scripts): swift_lex include internal visibility (was public-only) (1c0da44)

### Other
- Merge pull request #34 from CarlosDanielDev/maestro/unified-4-33 (702f202)
- Merge pull request #32 from CarlosDanielDev/maestro/issue-3 (cee4b43)
- docs(research): persist TextField arbiter spec (b49d74e)
- Merge pull request #31 from CarlosDanielDev/maestro/issue-2 (c191987)
- docs(manifests): add HOWTO for re-scan + aggregator chain (89288b7)
- Merge pull request #30 from CarlosDanielDev/chore/maestro-config-gitignore (beb8630)
- Merge pull request #29 from CarlosDanielDev/docs/p3-plan-c (ac44614)
- docs(plans): add Plan C for P3 (TextField, Catalog, Services, WR migration) (e96f097)
- docs: mandate human-only commit authorship (no AI trailer) (3095b40)
- docs: close P2 wave (9/9), refresh status + resume guide (150f9d8)
- docs: add NEXT-SESSION.md with full resume guide (415cf52)
- docs: refresh README modules + status, regenerate directory-tree (7e96728)
- docs(plans): add Plan B for P2 component port wave (a64681a)
- docs(research): persist 5 mapper digests + 7 arbiter API specs (350fef6)
- docs: refine spec with mermaids and self-review fixes (f40c357)
- docs: add Tsumiki MVP design spec (ad2ed4f)

