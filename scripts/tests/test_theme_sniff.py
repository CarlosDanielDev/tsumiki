import unittest
from pathlib import Path
from scripts.lib.theme_sniff import sniff

FIXTURE = Path(__file__).parent / "fixtures" / "ThemeSample.swift"


class ThemeSniffTests(unittest.TestCase):
    def setUp(self):
        self.tokens = sniff(FIXTURE.read_text())

    def test_finds_named_color_with_hex(self):
        colors = {c["name"]: c for c in self.tokens["colors"]}
        self.assertEqual(colors["aquaBlue"]["hex"], "#0EA5E9")

    def test_finds_named_color_without_hex(self):
        colors = {c["name"]: c for c in self.tokens["colors"]}
        self.assertIn("danger", colors)
        self.assertIsNone(colors["danger"]["hex"])

    def test_collects_spacings(self):
        self.assertEqual(sorted(self.tokens["spacings"]), [16, 24])

    def test_collects_radii(self):
        self.assertEqual(self.tokens["radii"], [12])

    def test_collects_font_styles(self):
        styles = {f["style"] for f in self.tokens["fonts"]}
        self.assertIn(".largeTitle", styles)
