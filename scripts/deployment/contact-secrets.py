#!/usr/bin/env python3
"""Stream contact secrets to SSH, or atomically install them in the host env.

The emit command is only for a pipe to the install command, never a terminal.
No secret values are accepted as command arguments or included in diagnostics.
"""

import json
import os
from pathlib import Path
import re
import stat
import sys
import tempfile


SECRET_NAMES = ("TURNSTILE_SECRET_KEY", "CONTACT_FORM_SECRET")


def validate(values):
    for name in SECRET_NAMES:
        value = values.get(name)
        if not isinstance(value, str) or not value or value != value.strip():
            raise ValueError(f"{name} must be nonempty with no surrounding whitespace in GitHub Actions secrets.")
        if any(ord(character) < 32 or ord(character) == 127 for character in value):
            raise ValueError(f"{name} must be a single-line value without control characters.")
        if name == "CONTACT_FORM_SECRET" and len(value.encode("utf-8")) < 32:
            raise ValueError("CONTACT_FORM_SECRET must contain at least 32 bytes; use a separately generated random secret.")
    return {name: values[name] for name in SECRET_NAMES}


def dotenv_value(value):
    # Compose double-quoted dotenv syntax: escape backslashes and quotes, and
    # double dollars so interpolation cannot change the supplied secret.
    return '"' + value.replace("\\", "\\\\").replace('"', '\\"').replace("$", "$$") + '"'


def install(destination, values):
    values = validate(values)
    destination = Path(destination)
    if destination.is_symlink() or not destination.is_file():
        raise ValueError("The host environment must already exist as a regular file, not a symlink; no configuration was changed.")
    previous = destination.read_bytes().decode("utf-8")
    pattern = re.compile(r"^\s*(?:export\s+)?(" + "|".join(SECRET_NAMES) + r")\s*=")
    assignment = re.compile(r"^\s*(?:export\s+)?[A-Za-z_][A-Za-z0-9_]*\s*=")
    retained = []
    for line in previous.splitlines(keepends=True):
        existing = assignment.match(line)
        if existing:
            # Reject multiline values anywhere, so an apparent assignment in
            # another value's continuation cannot be mistaken for a target.
            old_value = line[existing.end():].strip()
            if old_value.startswith(("'", '"')) and not re.fullmatch(
                r'''(?s)(?:"(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*')\s*(?:#.*)?''', old_value
            ):
                raise ValueError("The host environment contains an unsupported multiline/quoted value; convert it to a single-line dotenv value first.")
        if not pattern.match(line):
            retained.append(line)
    content = "".join(retained)
    if content and not content.endswith("\n"):
        content += "\n"
    content += "".join(f"{name}={dotenv_value(values[name])}\n" for name in SECRET_NAMES)
    descriptor, temporary = tempfile.mkstemp(prefix=".contact-env-", dir=destination.parent)
    try:
        with os.fdopen(descriptor, "w") as output:
            os.fchmod(output.fileno(), stat.S_IRUSR | stat.S_IWUSR)
            if os.geteuid() == 0:
                os.fchown(output.fileno(), 0, 0)
            output.write(content)
            output.flush()
            os.fsync(output.fileno())
        os.replace(temporary, destination)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def main():
    try:
        if sys.argv[1:] == ["emit"]:
            if sys.stdout.isatty():
                raise ValueError("Refusing to print secrets to a terminal; pipe emit directly to the remote installer.")
            json.dump(validate(os.environ), sys.stdout)
        elif len(sys.argv) == 3 and sys.argv[1] == "install":
            try:
                values = json.load(sys.stdin)
            except (ValueError, UnicodeError):
                raise ValueError("Contact secret input is not valid JSON; no configuration was changed.") from None
            if not isinstance(values, dict) or set(values) != set(SECRET_NAMES):
                raise ValueError("Contact secret input must contain exactly the two configured secret names.")
            install(sys.argv[2], values)
            print("Installed both contact secrets atomically; secret values were not logged.")
        else:
            raise ValueError("Usage: contact-secrets.py emit | [SSH] contact-secrets.py install ENV_PATH")
    except ValueError as error:
        print(f"Contact secret configuration failed: {error}", file=sys.stderr)
        return 1
    except (OSError, UnicodeError):
        print("Contact secret configuration failed: could not read or replace the host environment; check file permissions and available disk space.", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
