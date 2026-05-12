import json
import tempfile
import unittest
from pathlib import Path
from scripts.diff_overlaps import build_overlaps


class DiffOverlapsTests(unittest.TestCase):
    def _manifest(self, project: str, components):
        return {
            "project": project,
            "root": "/x",
            "swift_files": 1,
            "components": components,
            "theme_tokens": {"colors": [], "fonts": [], "spacings": [], "radii": []},
            "animations": [],
            "services": [],
        }

    def test_richer_winner_yields_empty_merge_params(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            for name, params, loc in [
                ("aquabrew",         ["title:String", "icon:Image?", "duration:TimeInterval"], 84),
                ("warrantyreminder", ["title:String", "icon:Image?"],                          61),
            ]:
                (root / f"{name}.json").write_text(json.dumps(self._manifest(name, [{
                    "name": "ToastView", "path": "x.swift", "kind": "View",
                    "concept": "Toast", "public_init_params": params, "loc": loc,
                }])))
            out = root / "_overlaps.json"
            build_overlaps(root, out)
            data = json.loads(out.read_text())
            toast = data["Toast"]
            self.assertEqual(len(toast["candidates"]), 2)
            self.assertEqual(toast["winner_hint"], "aquabrew")
            self.assertEqual(toast["merge_params"], [])

    def test_loser_unique_param_lifted_into_merge_params(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            # Winner = bigger LOC + simpler API. Loser contributes a unique `style` param.
            for name, params, loc in [
                ("aquabrew",         ["title:String", "icon:Image?"],                  200),
                ("warrantyreminder", ["title:String", "style:Style"],                  60),
            ]:
                (root / f"{name}.json").write_text(json.dumps(self._manifest(name, [{
                    "name": "ToastView", "path": "x.swift", "kind": "View",
                    "concept": "Toast", "public_init_params": params, "loc": loc,
                }])))
            out = root / "_overlaps.json"
            build_overlaps(root, out)
            data = json.loads(out.read_text())
            toast = data["Toast"]
            self.assertEqual(toast["winner_hint"], "aquabrew")
            self.assertIn("style", toast["merge_params"])
