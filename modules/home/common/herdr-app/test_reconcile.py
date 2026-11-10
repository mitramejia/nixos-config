import json
import os
from pathlib import Path
import tempfile
import unittest

from reconcile import reconcile


class ReconcileTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        root = Path(self.temporary.name)
        self.home = root / "config"
        self.state = root / "state" / "defaults.json"
        self.defaults = root / "defaults.json"
        self.keys_seed = root / "keys-seed.json"
        self.write(self.keys_seed, {"global": {"ctrl-shift-t": "tab.new"}})
        self.intent = {
            "settings.json": {"theme": "catppuccin"},
            "keys.json": {"global": {"ctrl-space c": "tab.new"}},
        }

    def write(self, path, value):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(value))

    def read(self, name):
        return json.loads((self.home / name).read_text())

    def apply(self):
        self.write(self.defaults, self.intent)
        reconcile(self.home, self.state, self.defaults, self.keys_seed)

    def test_fresh_install_creates_writable_regular_files(self):
        self.apply()
        self.assertEqual(self.read("settings.json"), self.intent["settings.json"])
        path = self.home / "settings.json"
        self.assertFalse(path.is_symlink())
        self.assertTrue(path.stat().st_mode & 0o200)
        self.assertEqual(self.read("keys.json")["global"]["ctrl-shift-t"], "tab.new")

    def test_first_port_merges_with_existing_app_files(self):
        self.write(self.home / "settings.json", {"theme": "ink", "zoom": 1.5})
        self.write(
            self.home / "keys.json", {"terminal": {"ctrl-v": "terminal.paste_image"}}
        )
        self.apply()
        self.assertEqual(
            self.read("settings.json"), {"theme": "catppuccin", "zoom": 1.5}
        )
        self.assertEqual(
            self.read("keys.json")["terminal"]["ctrl-v"], "terminal.paste_image"
        )

    def test_app_edits_and_deletions_survive_unchanged_rebuild(self):
        self.apply()
        self.write(self.home / "settings.json", {"theme": "paper", "zoom": 2})
        self.write(self.home / "keys.json", {"global": {}})
        before = (self.home / "settings.json").stat().st_mtime_ns
        self.apply()
        self.assertEqual(self.read("settings.json"), {"theme": "paper", "zoom": 2})
        self.assertEqual(self.read("keys.json"), {"global": {}})
        self.assertEqual((self.home / "settings.json").stat().st_mtime_ns, before)

    def test_changed_nix_default_wins_without_resetting_other_app_edits(self):
        self.apply()
        self.write(self.home / "settings.json", {"theme": "paper", "zoom": 2})
        self.intent["settings.json"]["theme"] = "moss"
        self.apply()
        self.assertEqual(self.read("settings.json"), {"theme": "moss", "zoom": 2})

    def test_removed_defaults_only_remove_unedited_values(self):
        self.apply()
        self.write(self.home / "settings.json", {"theme": "paper"})
        self.intent = {}
        self.apply()
        self.assertEqual(self.read("settings.json"), {"theme": "paper"})
        self.assertEqual(
            self.read("keys.json"), {"global": {"ctrl-shift-t": "tab.new"}}
        )

    def test_nested_changes_preserve_local_siblings(self):
        self.apply()
        self.write(
            self.home / "keys.json",
            {"global": {"ctrl-space c": "app.help", "f2": "tab.rename"}},
        )
        self.intent["keys.json"]["global"]["ctrl-space c"] = "space.new"
        self.apply()
        self.assertEqual(
            self.read("keys.json")["global"],
            {"ctrl-space c": "space.new", "f2": "tab.rename"},
        )

    def test_invalid_json_fails_without_overwriting_files(self):
        self.home.mkdir()
        path = self.home / "settings.json"
        path.write_text("invalid json")
        with self.assertRaises(json.JSONDecodeError):
            self.apply()
        self.assertEqual(path.read_text(), "invalid json")
        self.assertFalse((self.home / "keys.json").exists())
        self.assertFalse(self.state.exists())

    def test_symlinks_are_not_replaced(self):
        self.home.mkdir()
        target = self.home / "external.json"
        self.write(target, {"theme": "paper"})
        (self.home / "settings.json").symlink_to(target)
        with self.assertRaisesRegex(ValueError, "symlink"):
            self.apply()
        self.assertEqual(json.loads(target.read_text()), {"theme": "paper"})

    def test_removed_nested_default_keeps_local_siblings(self):
        self.apply()
        self.write(
            self.home / "keys.json",
            {"global": {"ctrl-space c": "tab.new", "f2": "tab.rename"}},
        )
        del self.intent["keys.json"]
        self.apply()
        self.assertEqual(self.read("keys.json"), {"global": {"f2": "tab.rename"}})

    def test_missing_file_is_reseeded(self):
        self.apply()
        (self.home / "keys.json").unlink()
        self.apply()
        self.assertEqual(
            self.read("keys.json")["global"],
            {"ctrl-shift-t": "tab.new", "ctrl-space c": "tab.new"},
        )

    @unittest.skipUnless(os.environ.get("HERDR_APP_DEFAULTS"), "Nix declaration fixture")
    def test_real_declaration_preserves_shipped_keys_and_local_app_changes(self):
        self.intent = json.loads(Path(os.environ["HERDR_APP_DEFAULTS"]).read_text())
        self.keys_seed = Path(os.environ["HERDR_APP_KEYS_SEED"])
        self.apply()
        self.assertEqual(self.read("keys.json")["global"]["ctrl-space c"], "tab.new")
        seed = json.loads(self.keys_seed.read_text())
        for section, bindings in seed.items():
            for key, action in bindings.items():
                self.assertEqual(self.read("keys.json")[section][key], action)
        palette = self.read("themes/nix-catppuccin-mocha.json")
        self.assertEqual(len(palette["ansi"]), 16)
        self.write(self.home / "settings.json", {"theme": "paper", "zoom": 1.5})
        self.apply()
        self.assertEqual(self.read("settings.json"), {"theme": "paper", "zoom": 1.5})


if __name__ == "__main__":
    unittest.main()
