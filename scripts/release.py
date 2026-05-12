#!/usr/bin/env python3
"""Automated release script for the Tsumiki SwiftPM library.

Inspects commits since the last semver tag, derives the next version using
Conventional Commits rules, updates CHANGELOG.md, creates and pushes an
annotated git tag, and creates a GitHub Release via `gh`.

Usage:
    python3 scripts/release.py [--dry-run] [--repo-root PATH] [--remote NAME]

Semver-bump policy (Conventional Commits):
    - any commit with `!` after type/scope OR a `BREAKING CHANGE:` footer => major
    - any `feat` commit                                                  => minor
    - any `fix`/`perf`/`refactor`/`chore`/`docs`/`test`/`build`/`ci`     => patch
    - no qualifying commits                                              => skip

First release (no prior tag): treats full history as the range and emits
`v0.1.0` (or the bump derived from history, whichever is greater than 0.0.0;
the minimum first release floor is 0.1.0).
"""
from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
from dataclasses import dataclass
from datetime import date
from pathlib import Path
from typing import Iterable, Sequence


SEMVER_TAG_RE = re.compile(r"^v(\d+)\.(\d+)\.(\d+)$")
CC_HEADER_RE = re.compile(
    r"^(?P<type>[a-zA-Z]+)(?:\((?P<scope>[^)]+)\))?(?P<bang>!)?: (?P<subject>.+)$"
)

MINOR_TYPES = {"feat"}
PATCH_TYPES = {"fix", "perf", "refactor", "chore", "docs", "test", "build", "ci", "style"}


@dataclass(frozen=True)
class Commit:
    sha: str
    subject: str
    body: str

    @property
    def header_type(self) -> str | None:
        m = CC_HEADER_RE.match(self.subject)
        return m.group("type").lower() if m else None

    @property
    def is_breaking(self) -> bool:
        m = CC_HEADER_RE.match(self.subject)
        if m and m.group("bang"):
            return True
        return "BREAKING CHANGE:" in self.body or "BREAKING-CHANGE:" in self.body


@dataclass(frozen=True)
class Version:
    major: int
    minor: int
    patch: int

    def __str__(self) -> str:
        return f"{self.major}.{self.minor}.{self.patch}"

    @property
    def tag(self) -> str:
        return f"v{self}"

    @classmethod
    def parse(cls, s: str) -> "Version":
        m = SEMVER_TAG_RE.match(s)
        if not m:
            raise ValueError(f"not a semver tag: {s}")
        return cls(int(m.group(1)), int(m.group(2)), int(m.group(3)))

    def bump(self, kind: str) -> "Version":
        if kind == "major":
            return Version(self.major + 1, 0, 0)
        if kind == "minor":
            return Version(self.major, self.minor + 1, 0)
        if kind == "patch":
            return Version(self.major, self.minor, self.patch + 1)
        raise ValueError(f"unknown bump kind: {kind}")


class ReleaseError(Exception):
    pass


def run(cmd: Sequence[str], cwd: Path, check: bool = True, capture: bool = True) -> subprocess.CompletedProcess:
    return subprocess.run(
        list(cmd),
        cwd=str(cwd),
        check=check,
        text=True,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.PIPE if capture else None,
    )


def latest_tag(repo: Path) -> str | None:
    res = run(["git", "tag", "--list", "v*", "--sort=-v:refname"], repo, check=False)
    for line in res.stdout.splitlines():
        line = line.strip()
        if SEMVER_TAG_RE.match(line):
            return line
    return None


def commits_since(repo: Path, tag: str | None) -> list[Commit]:
    rev_range = f"{tag}..HEAD" if tag else "HEAD"
    sep = "<<<COMMIT>>>"
    fmt = f"%H%n%s%n%b%n{sep}"
    res = run(["git", "log", rev_range, f"--pretty=format:{fmt}"], repo, check=False)
    out = res.stdout
    commits: list[Commit] = []
    for chunk in out.split(sep):
        chunk = chunk.strip("\n")
        if not chunk:
            continue
        lines = chunk.split("\n")
        if len(lines) < 2:
            continue
        sha = lines[0]
        subject = lines[1]
        body = "\n".join(lines[2:]).strip()
        commits.append(Commit(sha=sha, subject=subject, body=body))
    return commits


def classify_bump(commits: Iterable[Commit]) -> str | None:
    bump: str | None = None
    rank = {"patch": 1, "minor": 2, "major": 3}
    for c in commits:
        kind: str | None = None
        if c.is_breaking:
            kind = "major"
        else:
            t = c.header_type
            if t in MINOR_TYPES:
                kind = "minor"
            elif t in PATCH_TYPES:
                kind = "patch"
            else:
                continue
        if bump is None or rank[kind] > rank[bump]:
            bump = kind
    return bump


def next_version(current: Version | None, bump: str) -> Version:
    if current is None:
        # First-release floor: v0.1.0 regardless of bump kind.
        return Version(0, 1, 0)
    return current.bump(bump)


def is_dirty(repo: Path) -> bool:
    res = run(["git", "status", "--porcelain"], repo)
    return bool(res.stdout.strip())


def tag_exists_local(repo: Path, tag: str) -> bool:
    res = run(["git", "tag", "--list", tag], repo)
    return tag in res.stdout.split()


def tag_exists_remote(repo: Path, remote: str, tag: str) -> bool:
    res = run(["git", "ls-remote", "--tags", remote, f"refs/tags/{tag}"], repo, check=False)
    return bool(res.stdout.strip())


def render_changelog_section(version: Version, commits: Sequence[Commit], today: str) -> str:
    groups: dict[str, list[str]] = {
        "Added": [],
        "Changed": [],
        "Fixed": [],
        "Removed": [],
        "Other": [],
    }
    for c in commits:
        t = c.header_type or "other"
        line = f"- {c.subject} ({c.sha[:7]})"
        if c.is_breaking:
            groups["Changed"].append(line + " — **BREAKING**")
        elif t == "feat":
            groups["Added"].append(line)
        elif t == "fix":
            groups["Fixed"].append(line)
        elif t in {"refactor", "perf", "chore", "build", "ci", "style"}:
            groups["Changed"].append(line)
        elif t in {"docs", "test"}:
            groups["Other"].append(line)
        else:
            groups["Other"].append(line)

    lines = [f"## [{version}] - {today}", ""]
    for name, items in groups.items():
        if not items:
            continue
        lines.append(f"### {name}")
        lines.extend(items)
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


HEADER_MARKER = "<!-- releases -->"


def update_changelog(repo: Path, section: str) -> Path:
    path = repo / "CHANGELOG.md"
    if not path.exists():
        body = (
            "# Changelog\n\n"
            "All notable changes to this project will be documented in this file.\n\n"
            "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),\n"
            "and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).\n\n"
            f"{HEADER_MARKER}\n\n"
        )
        path.write_text(body)
    text = path.read_text()
    if HEADER_MARKER in text:
        new_text = text.replace(HEADER_MARKER, HEADER_MARKER + "\n\n" + section.rstrip() + "\n", 1)
    else:
        new_text = text.rstrip() + "\n\n" + section
    path.write_text(new_text)
    return path


def changelog_diff_preview(repo: Path, section: str) -> str:
    path = repo / "CHANGELOG.md"
    if not path.exists():
        return f"(new) CHANGELOG.md:\n\n{section}"
    return f"--- inserting into CHANGELOG.md ---\n{section}"


@dataclass
class Plan:
    previous_tag: str | None
    previous_version: Version | None
    bump: str
    next_version: Version
    commits: list[Commit]


def build_plan(repo: Path) -> Plan | None:
    prev_tag = latest_tag(repo)
    prev = Version.parse(prev_tag) if prev_tag else None
    commits = commits_since(repo, prev_tag)
    if not commits:
        return None
    bump = classify_bump(commits)
    if bump is None:
        return None
    nv = next_version(prev, bump)
    return Plan(prev_tag, prev, bump, nv, commits)


def execute(plan: Plan, repo: Path, remote: str, dry_run: bool) -> int:
    today = date.today().isoformat()
    section = render_changelog_section(plan.next_version, plan.commits, today)
    tag = plan.next_version.tag

    print(f"Previous tag: {plan.previous_tag or '(none)'}")
    print(f"Bump: {plan.bump}")
    print(f"Next version: {plan.next_version}")
    print(f"Tag: {tag}")
    print(f"Commits in range: {len(plan.commits)}")
    print()
    print(changelog_diff_preview(repo, section))

    if dry_run:
        print("\n[dry-run] no mutations performed.")
        return 0

    if is_dirty(repo):
        raise ReleaseError("working tree dirty; commit or stash before releasing")

    if tag_exists_local(repo, tag):
        raise ReleaseError(f"tag {tag} already exists locally")
    if tag_exists_remote(repo, remote, tag):
        raise ReleaseError(f"tag {tag} already exists on remote {remote!r}")

    update_changelog(repo, section)
    run(["git", "add", "CHANGELOG.md"], repo)
    run(["git", "commit", "-m", f"chore(release): {plan.next_version}"], repo)
    run(["git", "tag", "-a", tag, "-m", f"Release {plan.next_version}"], repo)

    push_branch = run(["git", "rev-parse", "--abbrev-ref", "HEAD"], repo).stdout.strip()
    run(["git", "push", remote, push_branch], repo)
    run(["git", "push", remote, tag], repo)

    notes_path = repo / ".release-notes.md"
    notes_path.write_text(section)
    try:
        run(
            [
                "gh", "release", "create", tag,
                "--title", f"Tsumiki {plan.next_version}",
                "--notes-file", str(notes_path),
            ],
            repo,
        )
    except subprocess.CalledProcessError as e:
        msg = (
            f"gh release create failed: {e.stderr or e.stdout}\n"
            f"tag {tag} pushed; re-run to create the GitHub Release"
        )
        print(msg, file=sys.stderr)
        return 2
    finally:
        try:
            notes_path.unlink()
        except FileNotFoundError:
            pass

    print(f"\nReleased {plan.next_version} ({tag}).")
    return 0


def main(argv: Sequence[str] | None = None) -> int:
    p = argparse.ArgumentParser(description="Cut a semver release.")
    p.add_argument("--dry-run", action="store_true", help="Print actions without mutating state.")
    p.add_argument("--repo-root", default=os.getcwd(), help="Repository root.")
    p.add_argument("--remote", default="origin", help="Git remote to push to.")
    args = p.parse_args(argv)

    repo = Path(args.repo_root).resolve()

    if not args.dry_run and is_dirty(repo):
        print("error: working tree dirty; commit or stash before releasing", file=sys.stderr)
        return 1

    plan = build_plan(repo)
    if plan is None:
        prev = latest_tag(repo) or "(no prior tag)"
        print(f"No releasable commits since {prev} — skipping.")
        return 0

    try:
        return execute(plan, repo, args.remote, args.dry_run)
    except ReleaseError as e:
        print(f"error: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
