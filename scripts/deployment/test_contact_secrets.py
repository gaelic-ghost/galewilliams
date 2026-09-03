"""Regression checks using synthetic values only; never connect to a host."""

import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch


SCRIPT = Path(__file__).with_name("contact-secrets.py")
spec = importlib.util.spec_from_file_location("contact_secrets", SCRIPT)
secrets = importlib.util.module_from_spec(spec)
spec.loader.exec_module(secrets)
VALUES = {
    "TURNSTILE_SECRET_KEY": "synthetic-turnstile-key",
    "CONTACT_FORM_SECRET": "synthetic-signing-secret-for-tests-only-1234567890",
}


class ContactSecretsTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.path = Path(self.directory.name) / ".env"
        self.path.write_text("# Preserve operator configuration\nIMAGE_TAG=v0.8.1\nDATABASE_PASSWORD=synthetic-database-value\n")

    def run_installer(self, payload):
        return subprocess.run(
            [sys.executable, str(SCRIPT), "install", str(self.path)],
            input=payload, text=True, capture_output=True, check=False,
        )

    def test_replace_preserves_unrelated_values_and_is_idempotent(self):
        previous = self.path.read_text()
        self.path.write_text(previous + 'TURNSTILE_SECRET_KEY=old\nexport CONTACT_FORM_SECRET="old"\n TURNSTILE_SECRET_KEY = duplicate\n')
        secrets.install(self.path, VALUES)
        installed = self.path.read_text()
        self.assertTrue(installed.startswith(previous))
        for name, value in VALUES.items():
            self.assertEqual(installed.count(name + "="), 1)
            self.assertIn(secrets.dotenv_value(value), installed)
        secrets.install(self.path, VALUES)
        self.assertEqual(self.path.read_text(), installed)
        self.assertEqual(self.path.stat().st_mode & 0o777, 0o600)
        self.assertEqual(list(self.path.parent.glob(".contact-env-*")), [])

    def test_missing_short_and_multiline_input_leave_file_unchanged(self):
        previous = self.path.read_text()
        invalid_values = [
            {}, {**VALUES, "CONTACT_FORM_SECRET": "short"},
            {**VALUES, "TURNSTILE_SECRET_KEY": "bad\nvalue"},
            {**VALUES, "TURNSTILE_SECRET_KEY": " leading-whitespace"},
            {**VALUES, "CONTACT_FORM_SECRET": None},
            {**VALUES, "UNEXPECTED": "value"},
        ]
        for values in invalid_values:
            result = self.run_installer(json.dumps(values))
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(self.path.read_text(), previous)
            self.assertNotIn(VALUES["TURNSTILE_SECRET_KEY"], result.stderr)
        for payload in ["not-json", "[]", "null", ""]:
            self.assertNotEqual(self.run_installer(payload).returncode, 0)
            self.assertEqual(self.path.read_text(), previous)

    def test_existing_multiline_target_is_rejected(self):
        previous = 'TURNSTILE_SECRET_KEY="unfinished\nsecret-fragment"\n'
        self.path.write_text(previous)
        self.assertNotEqual(self.run_installer(json.dumps(VALUES)).returncode, 0)
        self.assertEqual(self.path.read_text(), previous)

    def test_unrelated_multiline_value_cannot_be_partially_rewritten(self):
        previous = 'UNRELATED="first line\nCONTACT_FORM_SECRET=inside-another-value\nlast line"\n'
        self.path.write_text(previous)
        self.assertNotEqual(self.run_installer(json.dumps(VALUES)).returncode, 0)
        self.assertEqual(self.path.read_text(), previous)

    def test_missing_file_and_symlink_are_rejected(self):
        self.path.unlink()
        with self.assertRaises(ValueError):
            secrets.install(self.path, VALUES)
        target = self.path.parent / "target.env"
        target.write_text("untouched")
        self.path.symlink_to(target)
        with self.assertRaises(ValueError):
            secrets.install(self.path, VALUES)
        self.assertEqual(target.read_text(), "untouched")

    def test_failed_atomic_replace_preserves_original_and_cleans_temporary(self):
        previous = self.path.read_bytes()
        with patch.object(secrets.os, "replace", side_effect=OSError("synthetic failure")):
            with self.assertRaises(OSError):
                secrets.install(self.path, VALUES)
        self.assertEqual(self.path.read_bytes(), previous)
        self.assertEqual(list(self.path.parent.glob(".contact-env-*")), [])

    def test_unrelated_crlf_lines_are_preserved(self):
        previous = b"# operator settings\r\nIMAGE_TAG=v0.8.1\r\n"
        self.path.write_bytes(previous)
        secrets.install(self.path, VALUES)
        self.assertTrue(self.path.read_bytes().startswith(previous))

    def test_emit_to_install_pipeline_does_not_log_values(self):
        emitted = subprocess.run(
            [sys.executable, str(SCRIPT), "emit"],
            env={**os.environ, **VALUES}, capture_output=True, text=True, check=True,
        )
        self.assertEqual(json.loads(emitted.stdout), VALUES)
        installed = self.run_installer(emitted.stdout)
        self.assertEqual(installed.returncode, 0)
        for value in VALUES.values():
            self.assertNotIn(value, installed.stdout + installed.stderr + emitted.stderr)

    def test_compose_round_trip_preserves_special_characters(self):
        if not shutil.which("docker") or subprocess.run(
            ["docker", "compose", "version"], capture_output=True, check=False,
        ).returncode:
            self.skipTest("Docker Compose is unavailable; run this check before deployment.")
        values = {
            "TURNSTILE_SECRET_KEY": "synthetic-$dollar-${REFERENCE}-#hash-'quote-\"double-\\backslash",
            "CONTACT_FORM_SECRET": VALUES["CONTACT_FORM_SECRET"] + "-\\-$$-end\\",
        }
        secrets.install(self.path, values)
        environment = {key: value for key, value in os.environ.items() if key not in secrets.SECRET_NAMES}
        result = subprocess.run(
            ["docker", "compose", "--env-file", str(self.path), "-f",
             str(SCRIPT.parents[2] / "docker-compose.production.yml"), "config", "--format", "json"],
            env=environment, capture_output=True, text=True, check=True,
        )
        services = json.loads(result.stdout)["services"]
        for service in ["app", "worker", "scheduler", "migrate"]:
            for name, value in values.items():
                # Canonical Compose output re-escapes dollars for reuse as a
                # Compose file. Check the actual interpolation inputs below.
                self.assertEqual(services[service]["environment"][name], value.replace("$", "$$"))
        resolved = subprocess.run(
            ["docker", "compose", "--env-file", str(self.path), "-f",
             str(SCRIPT.parents[2] / "docker-compose.production.yml"), "config", "--environment"],
            env=environment, capture_output=True, text=True, check=True,
        )
        resolved_values = dict(line.split("=", 1) for line in resolved.stdout.splitlines() if "=" in line)
        for name, value in values.items():
            self.assertEqual(resolved_values[name], value)


if __name__ == "__main__":
    unittest.main()
