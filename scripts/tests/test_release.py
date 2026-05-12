"""Tests for scripts/release.py.

Unit-tests the pure semver/classification logic and integration-tests the
script invocation against ephemeral git repos created in tempdirs.
"""
from __future__ import annotations

import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

from scripts.release import (
    Commit,
    Version,
    build_plan,
    classify_bump,
    is_dirty,
    next_version,
    render_changelog_section,
    update_changelog,
)


REPO_ROOT = Path(__file__).resolve().parents[2]
RELEASE_PY = REPO_ROOT / "scripts" / "release.py"


def _git(repo: Path, *args: str, check: bool = True) -> subprocess.CompletedProcess:
    return subprocess.run(
        ["git", *args],
        cwd=str(repo),
        check=check,
        text=True,
        capture_output=True,
    )


def _init_repo(repo: Path) -> None:
    repo.mkdir(parents=True, exist_ok=True)
    _git(repo, "init", "-q", "-b", "main")
    _git(repo, "config", "user.email", "test@example.com")
    _git(repo, "config", "user.name", "Test")
    _git(repo, "config", "commit.gpgsign", "false")
    _git(repo, "config", "tag.gpgsign", "false")


def _commit(repo: Path, msg: str, file: str = "f.txt", content: str | None = None) -> None:
    p = repo / file
    p.write_text(content if content is not None else msg + "\n")
    _git(repo, "add", file)
    _git(repo, "commit", "-q", "-m", msg)


def _run_release(repo: Path, *extra: str) -> subprocess.CompletedProcess:
    env = os.environ.copy()
    env["PYTHONPATH"] = str(REPO_ROOT) + os.pathsep + env.get("PYTHONPATH", "")
    return subprocess.run(
        [sys.executable, str(RELEASE_PY), "--repo-root", str(repo), *extra],
        check=False,
        text=True,
        capture_output=True,
        env=env,
    )


def _mk(subject: str, body: str = "") -> Commit:
    return Commit(sha="0" * 40, subject=subject, body=body)


class SemverLogicTests(unittest.TestCase):
    def test_feat_bumps_minor(self):
        self.assertEqual(classify_bump([_mk("feat: add x")]), "minor")

    def test_fix_bumps_patch(self):
        self.assertEqual(classify_bump([_mk("fix: bug")]), "patch")

    def test_chore_bumps_patch(self):
        self.assertEqual(classify_bump([_mk("chore: deps")]), "patch")

    def test_breaking_bang_is_major(self):
        self.assertEqual(classify_bump([_mk("feat!: drop api")]), "major")

    def test_breaking_footer_is_major(self):
        self.assertEqual(
            classify_bump([_mk("feat: rework", body="BREAKING CHANGE: removed Foo")]),
            "major",
        )

    def test_highest_wins(self):
        commits = [_mk("fix: a"), _mk("feat: b"), _mk("chore: c")]
        self.assertEqual(classify_bump(commits), "minor")

    def test_no_conventional_commits_returns_none(self):
        self.assertIsNone(classify_bump([_mk("random subject")]))

    def test_first_release_floor_is_0_1_0(self):
        self.assertEqual(str(next_version(None, "patch")), "0.1.0")
        self.assertEqual(str(next_version(None, "minor")), "0.1.0")
        self.assertEqual(str(next_version(None, "major")), "0.1.0")

    def test_bump_from_existing(self):
        v = Version(1, 2, 3)
        self.assertEqual(str(v.bump("patch")), "1.2.4")
        self.assertEqual(str(v.bump("minor")), "1.3.0")
        self.assertEqual(str(v.bump("major")), "2.0.0")

    def test_version_parse(self):
        self.assertEqual(Version.parse("v1.2.3"), Version(1, 2, 3))
        with self.assertRaises(ValueError):
            Version.parse("1.2.3")
        with self.assertRaises(ValueError):
            Version.parse("vX.Y.Z")


class ChangelogTests(unittest.TestCase):
    def test_render_groups_by_type(self):
        commits = [
            _mk("feat(button): pill style"),
            _mk("fix(card): padding"),
            _mk("chore: deps"),
        ]
        section = render_changelog_section(Version(0, 1, 0), commits, "2026-05-12")
        self.assertIn("## [0.1.0] - 2026-05-12", section)
        self.assertIn("### Added", section)
        self.assertIn("pill style", section)
        self.assertIn("### Fixed", section)
        self.assertIn("padding", section)
        self.assertIn("### Changed", section)
        self.assertIn("deps", section)

    def test_update_changelog_creates_file(self):
        with tempfile.TemporaryDirectory() as td:
            repo = Path(td)
            section = "## [0.1.0] - 2026-05-12\n\n### Added\n- x\n"
            update_changelog(repo, section)
            text = (repo / "CHANGELOG.md").read_text()
            self.assertIn("# Changelog", text)
            self.assertIn("## [0.1.0]", text)

    def test_update_changelog_prepends(self):
        with tempfile.TemporaryDirectory() as td:
            repo = Path(td)
            update_changelog(repo, "## [0.1.0] - 2026-05-12\n\n### Added\n- a\n")
            update_changelog(repo, "## [0.2.0] - 2026-05-13\n\n### Added\n- b\n")
            text = (repo / "CHANGELOG.md").read_text()
            i_new = text.index("[0.2.0]")
            i_old = text.index("[0.1.0]")
            self.assertLess(i_new, i_old)


class IntegrationDryRunTests(unittest.TestCase):
    def test_first_release_dry_run_emits_v0_1_0(self):
        with tempfile.TemporaryDirectory() as td:
            repo = Path(td) / "r"
            _init_repo(repo)
            _commit(repo, "feat: initial component")
            res = _run_release(repo, "--dry-run")
            self.assertEqual(res.returncode, 0, msg=res.stderr)
            self.assertIn("Next version: 0.1.0", res.stdout)
            self.assertIn("[dry-run]", res.stdout)
            tags = _git(repo, "tag", "-l").stdout.strip()
            self.assertEqual(tags, "")

    def test_dry_run_leaves_status_clean(self):
        with tempfile.TemporaryDirectory() as td:
            repo = Path(td) / "r"
            _init_repo(repo)
            _commit(repo, "feat: a")
            res = _run_release(repo, "--dry-run")
            self.assertEqual(res.returncode, 0, msg=res.stderr)
            status = _git(repo, "status", "--porcelain").stdout
            self.assertEqual(status, "")

    def test_chore_only_emits_patch_bump(self):
        with tempfile.TemporaryDirectory() as td:
            repo = Path(td) / "r"
            _init_repo(repo)
            _commit(repo, "feat: seed")
            _git(repo, "tag", "-a", "v0.1.0", "-m", "seed")
            _commit(repo, "chore: tidy", file="b.txt")
            res = _run_release(repo, "--dry-run")
            self.assertEqual(res.returncode, 0, msg=res.stderr)
            self.assertIn("Next version: 0.1.1", res.stdout)
            self.assertIn("Bump: patch", res.stdout)

    def test_zero_commits_since_tag_skips(self):
        with tempfile.TemporaryDirectory() as td:
            repo = Path(td) / "r"
            _init_repo(repo)
            _commit(repo, "feat: seed")
            _git(repo, "tag", "-a", "v0.1.0", "-m", "seed")
            res = _run_release(repo, "--dry-run")
            self.assertEqual(res.returncode, 0, msg=res.stderr)
            self.assertIn("No releasable commits since v0.1.0", res.stdout)

    def test_dirty_tree_exits_nonzero_when_not_dry_run(self):
        with tempfile.TemporaryDirectory() as td:
            repo = Path(td) / "r"
            _init_repo(repo)
            _commit(repo, "feat: seed")
            (repo / "dirty.txt").write_text("uncommitted")
            res = _run_release(repo)
            self.assertNotEqual(res.returncode, 0)
            self.assertIn("dirty", res.stderr.lower())

    def test_breaking_change_bumps_major(self):
        with tempfile.TemporaryDirectory() as td:
            repo = Path(td) / "r"
            _init_repo(repo)
            _commit(repo, "feat: seed")
            _git(repo, "tag", "-a", "v1.2.3", "-m", "seed")
            _commit(repo, "feat!: drop API", file="b.txt")
            res = _run_release(repo, "--dry-run")
            self.assertEqual(res.returncode, 0, msg=res.stderr)
            self.assertIn("Next version: 2.0.0", res.stdout)

    def test_build_plan_returns_none_on_zero_commits(self):
        with tempfile.TemporaryDirectory() as td:
            repo = Path(td) / "r"
            _init_repo(repo)
            _commit(repo, "feat: seed")
            _git(repo, "tag", "-a", "v0.1.0", "-m", "seed")
            self.assertIsNone(build_plan(repo))

    def test_is_dirty_detects_untracked(self):
        with tempfile.TemporaryDirectory() as td:
            repo = Path(td) / "r"
            _init_repo(repo)
            _commit(repo, "feat: seed")
            self.assertFalse(is_dirty(repo))
            (repo / "x.txt").write_text("x")
            self.assertTrue(is_dirty(repo))


if __name__ == "__main__":
    unittest.main()
