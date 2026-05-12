import json
import tempfile
import unittest
from pathlib import Path
from scripts.scan_project import scan

FIXTURES = Path(__file__).parent / "fixtures"


class ScanProjectTests(unittest.TestCase):
    def test_emits_components_and_theme_tokens(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td) / "fakeproj"
            (root / "Views" / "Components" / "Toast").mkdir(parents=True)
            (root / "Views" / "Components" / "Card").mkdir(parents=True)
            (root / "Views" / "Components" / "Toast" / "ToastView.swift").write_text(
                (FIXTURES / "ToastView.swift").read_text()
            )
            (root / "Views" / "Components" / "Card" / "CardView.swift").write_text(
                (FIXTURES / "CardView.swift").read_text()
            )
            out_path = Path(td) / "manifest.json"
            scan(project_name="fakeproj", root=root, out_path=out_path)

            data = json.loads(out_path.read_text())
            self.assertEqual(data["project"], "fakeproj")
            self.assertEqual(data["swift_files"], 2)
            concepts = {c["concept"] for c in data["components"]}
            self.assertEqual(concepts, {"Toast", "Card"})
            for comp in data["components"]:
                self.assertIn("path", comp)
                self.assertGreater(comp["loc"], 0)
            spacings = data["theme_tokens"]["spacings"]
            self.assertIn(12, spacings)
            self.assertIn(16, spacings)
