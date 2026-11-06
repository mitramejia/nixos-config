"""Focused activation helper checks; no real Herdr server is started."""

import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


SCRIPT = Path(__file__).with_name("link-herdr-plugin")


class PluginLinkTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.client = self.root / "herdr"
        self.client.write_text(
            f"#!{sys.executable}\n"
            "import json, os, pathlib, sys\n"
            "socket = os.environ.get('HERDR_SOCKET_PATH')\n"
            "offline = socket != 'live.sock'\n"
            "with open(os.environ['CALLS'], 'a') as log:\n"
            "    log.write(json.dumps([sys.argv[1:], socket, "
            "os.environ['HOME'], os.environ['XDG_CONFIG_HOME']]) + '\\n')\n"
            "if offline:\n"
            "    assert not pathlib.Path(socket).exists()\n"
            "    assert pathlib.Path(socket).parent.is_dir()\n"
            "mode = os.environ['MODE']\n"
            "if not offline and mode != 'success':\n"
            "    if mode == 'malformed':\n"
            "        print('not JSON: protocol_mismatch', file=sys.stderr)\n"
            "    else:\n"
            "        code = 'permission_denied' if mode == 'failure' else 'protocol_mismatch'\n"
            "        print(json.dumps({'error': {'code': code}}), file=sys.stderr)\n"
            "    sys.exit(7)\n"
            "if offline and mode == 'fallback_failure':\n"
            "    print('invalid manifest', file=sys.stderr)\n"
            "    sys.exit(9)\n"
            "print('linked')\n"
        )
        self.client.chmod(0o755)
        self.env = {
            **os.environ,
            "HERDR_SOCKET_PATH": "live.sock",
            "HOME": str(self.root / "home"),
            "XDG_CONFIG_HOME": str(self.root / "config"),
            "TMPDIR": str(self.root),
            "CALLS": str(self.root / "calls"),
            "DRY_RUN": "",
        }

    def run_helper(self, mode, dry_run=""):
        result = subprocess.run(
            ["bash", str(SCRIPT), str(self.client), "plugin with spaces"],
            env={**self.env, "MODE": mode, "DRY_RUN": dry_run},
            capture_output=True,
            text=True,
        )
        calls_path = self.root / "calls"
        calls = [json.loads(line) for line in calls_path.read_text().splitlines()] if calls_path.exists() else []
        self.assertEqual(list(self.root.glob("herdr-link.*")), [])
        for args, _, home, config in calls:
            self.assertEqual(args, ["plugin", "link", "plugin with spaces"])
            self.assertEqual(home, self.env["HOME"])
            self.assertEqual(config, self.env["XDG_CONFIG_HOME"])
        return result, calls

    def test_compatible_server_needs_no_fallback(self):
        result, calls = self.run_helper("success")
        self.assertEqual(result.returncode, 0)
        self.assertEqual(len(calls), 1)
        self.assertEqual(calls[0][1], "live.sock")

    def test_protocol_mismatch_uses_offline_socket_and_real_config(self):
        result, calls = self.run_helper("mismatch")
        self.assertEqual(result.returncode, 0)
        self.assertEqual(len(calls), 2)
        self.assertEqual(calls[0][1], "live.sock")
        self.assertNotEqual(calls[1][1], "live.sock")
        self.assertIn("leaving the running server unchanged", result.stderr)

    def test_genuine_errors_do_not_retry(self):
        for mode in ("failure", "malformed"):
            with self.subTest(mode=mode):
                (self.root / "calls").unlink(missing_ok=True)
                result, calls = self.run_helper(mode)
                self.assertEqual(result.returncode, 7)
                self.assertEqual(len(calls), 1)

    def test_offline_failure_propagates(self):
        result, calls = self.run_helper("fallback_failure")
        self.assertEqual(result.returncode, 9)
        self.assertEqual(len(calls), 2)
        self.assertIn("invalid manifest", result.stderr)

    def test_dry_run_does_not_call_herdr_or_create_files(self):
        before = set(self.root.iterdir())
        result, calls = self.run_helper("mismatch", dry_run="1")
        self.assertEqual(result.returncode, 0)
        self.assertEqual(calls, [])
        self.assertEqual(set(self.root.iterdir()), before)


if __name__ == "__main__":
    unittest.main()
