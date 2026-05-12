import tempfile
import unittest
from pathlib import Path
from scripts.lint_no_hardcoded import lint


class LintTests(unittest.TestCase):
    def _file(self, root: Path, body: str) -> Path:
        p = root / "Bad.swift"
        p.write_text(body)
        return p

    def test_flags_color_literal(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            self._file(root, "let c = Color.red")
            violations = lint(root)
            self.assertEqual(len(violations), 1)
            self.assertEqual(violations[0]["rule"], "color-literal")

    def test_flags_padding_literal(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            self._file(root, "Text(\"x\").padding(16)")
            violations = lint(root)
            self.assertTrue(any(v["rule"] == "spacing-literal" for v in violations))

    def test_allows_theme_access(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            self._file(root, "Text(\"x\").padding(theme.spacing.lg)")
            violations = lint(root)
            self.assertEqual(violations, [])

    def test_allows_zero_and_one(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            self._file(root, "Text(\"x\").padding(0).padding(1)")
            violations = lint(root)
            self.assertEqual(violations, [])
