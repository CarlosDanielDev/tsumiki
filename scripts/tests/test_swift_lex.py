import unittest
from pathlib import Path
from scripts.lib.swift_lex import extract_symbols

FIXTURE = Path(__file__).parent / "fixtures" / "ToastView.swift"


class SwiftLexTests(unittest.TestCase):
    def test_extracts_public_struct_view(self):
        symbols = extract_symbols(FIXTURE.read_text())
        names = {s["name"] for s in symbols}
        self.assertIn("ToastView", names)

    def test_classifies_view_kind(self):
        symbols = extract_symbols(FIXTURE.read_text())
        toast = next(s for s in symbols if s["name"] == "ToastView")
        self.assertEqual(toast["kind"], "View")
        self.assertEqual(toast["visibility"], "public")

    def test_extracts_public_init_params(self):
        symbols = extract_symbols(FIXTURE.read_text())
        toast = next(s for s in symbols if s["name"] == "ToastView")
        self.assertEqual(
            toast["public_init_params"],
            ["title:String", "icon:Image?", "duration:TimeInterval"],
        )

    def test_skips_private_types(self):
        symbols = extract_symbols(FIXTURE.read_text())
        names = {s["name"] for s in symbols}
        self.assertNotIn("ToastModifier", names)
