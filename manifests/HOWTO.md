# manifests/ — re-scan HOWTO

Per-project JSON manifests under `manifests/` are **regenerated** from the
source apps; they are not source of truth. Re-scan whenever a source app's
layout, theme tokens, or component surface changes, then re-run the aggregator
chain so subagents see a consistent snapshot.

## Why these files are gitignored

`manifests/*.json` is listed in `.gitignore` (only `.gitkeep` is tracked).
Manifests are deterministic outputs of the scanner pipeline — checking them in
would create merge conflicts and rot. Re-scan on demand; the scripts are fast.

## 1. Scan each source project

Run once per source app. Outputs `manifests/<name>.json`.

```bash
python3 -m scripts.scan_project aquabrew         /Users/carlos/projects/aquabrew         -o manifests/aquabrew.json
python3 -m scripts.scan_project pulselog         /Users/carlos/projects/pulselog         -o manifests/pulselog.json
python3 -m scripts.scan_project lucidmate        /Users/carlos/projects/lucidmate        -o manifests/lucidmate.json
python3 -m scripts.scan_project warrantyreminder /Users/carlos/projects/warrantyreminder -o manifests/warrantyreminder.json
python3 -m scripts.scan_project zeroblock        /Users/carlos/projects/zeroblock        -o manifests/zeroblock.json
```

## 2. Aggregate across all manifests

Each aggregator reads `manifests/` (skipping `_`-prefixed files) and writes a
single combined artifact:

```bash
python3 -m scripts.diff_overlaps       manifests/ -o manifests/_overlaps.json
python3 -m scripts.classify_components manifests/ -o manifests/_concepts.json
python3 -m scripts.build_catalog --concepts manifests/_concepts.json \
                                 --overlaps manifests/_overlaps.json \
                                 -o manifests/_tsumiki_plan.json
```

## 3. Verify

```bash
/usr/bin/swift build                                              # macOS 26 SDK
/usr/bin/swift test                                               # all targets
python3 -m unittest discover scripts/tests                        # scanner tests
python3 -m scripts.lint_no_hardcoded Sources/TsumikiComponents    # theme-literal lint
```

Green lint + green tests after a cold re-run = manifests valid.

## Toolchain note

`which swift` resolves to `/Users/carlos/.swiftly/bin/swift` (Swift 6.1) which
is incompatible with the macOS 26 SDK. Always invoke `/usr/bin/swift` (Xcode
6.2 toolchain) for build/test. See [`NEXT-SESSION.md`](../NEXT-SESSION.md) for
the full toolchain rationale.
