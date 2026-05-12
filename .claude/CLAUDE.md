# Tsumiki Orchestrator — CLAUDE.md

## YOU ARE THE ONLY AGENT THAT WRITES CODE
Subagents in `.claude/agents/` are consultive. They read JSON manifests in
`manifests/` and return Markdown digests. They never write code, never edit
project files, and never delegate writes back to themselves.

Exception: `subagent-docs-analyst` may create or edit files under `docs/`,
`README.md`, and `directory-tree.md`.

## Modes
- **Vibe Coding (default)** — orchestrator works directly. Use for small edits
  and exploratory work.
- **Subagents Orchestrator** — use for component port waves. Sequence:
  1. `subagent-project-mapper` × 5 (parallel, one per source project)
  2. `subagent-concept-classifier` (once)
  3. `subagent-overlap-arbiter` × N (parallel, one per concept)
  4. `subagent-theme-extractor` (once, when consolidating theme tokens)
  5. `subagent-architect` (once)
  6. `subagent-qa` (per module being ported)
  7. orchestrator implements (TDD: RED → GREEN → refactor)
  8. `subagent-docs-analyst` at end of wave

## Manifests
Subagents read `manifests/*.json`. Never give them raw Swift paths from the
source projects. If a subagent needs raw Swift, the orchestrator opens the file
and pastes the snippet into the prompt — this keeps source-project file reads
bounded to the orchestrator and saves context.

## Source projects (read-only)
- `/Users/carlos/projects/aquabrew`
- `/Users/carlos/projects/pulselog`
- `/Users/carlos/projects/lucidmate`
- `/Users/carlos/projects/warrantyreminder`
- `/Users/carlos/projects/zeroblock`

Never edit a source project from within Tsumiki work — migrations happen in the
source project's repo, not here.

## Build / test / lint
| Command | Purpose |
|---|---|
| `/usr/bin/swift build` | Build all targets (use Xcode-bundled swift, not swiftly) |
| `/usr/bin/swift test`  | Run all XCTest targets on macOS host |
| `/usr/bin/swift test --filter <Name>` | Run a single test class |
| `python3 -m unittest discover scripts/tests` | Run scanner tests |
| `python3 -m scripts.lint_no_hardcoded Sources/TsumikiComponents` | Theme-literal lint |
| `python3 -m scripts.scan_project <name> <root> -o manifests/<name>.json` | Re-scan one project |

**Toolchain note**: `which swift` resolves to `/Users/carlos/.swiftly/bin/swift`
(Swift 6.1) which is incompatible with macOS 26 SDK. Always invoke
`/usr/bin/swift` (Xcode 6.2 toolchain) for build/test.

## Public-API rules
- Every type, view, and modifier exported from a target is `public`.
- No `@_spi`. No internal singletons. No globals.
- Components read theme via `@Environment(\.tsumikiTheme)`. Hardcoded `Color`,
  spacing, font, or radius literals are forbidden in `Sources/TsumikiComponents`
  and enforced by `scripts/lint_no_hardcoded.py` in CI.

## Caveman mode
Read `.claude/settings.json`. If `behavior.caveman_mode === true`, apply the
caveman compression rules to user-facing prose (not to code, commits, or PRs).
Default: `false`.
