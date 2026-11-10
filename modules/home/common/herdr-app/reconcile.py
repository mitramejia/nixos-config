"""Apply changed Nix defaults without undoing edits made in Herdr."""

import json
import os
from pathlib import Path
import sys
import tempfile


MISSING = object()


def merge(current, previous, desired):
    """Nix changes win; unchanged defaults leave the live value alone."""
    if desired == previous:
        return current
    if isinstance(desired, dict) or (
        desired is MISSING and isinstance(previous, dict) and isinstance(current, dict)
    ):
        desired = desired if isinstance(desired, dict) else {}
        result = dict(current) if isinstance(current, dict) else {}
        old = previous if isinstance(previous, dict) else {}
        for key in sorted(old.keys() | desired.keys()):
            value = merge(
                result.get(key, MISSING),
                old.get(key, MISSING),
                desired.get(key, MISSING),
            )
            if value is MISSING:
                result.pop(key, None)
            else:
                result[key] = value
        return result
    if desired is MISSING:
        # Stop managing a removed default; retain a locally edited value.
        return MISSING if current == previous else current
    return desired


def read_object(path):
    if path.is_symlink():
        raise ValueError(f"Refusing to replace symlink: {path}")
    if not path.exists():
        return {}
    value = json.loads(path.read_text())
    if not isinstance(value, dict):
        raise ValueError(f"Expected a JSON object: {path}")
    return value


def write_object(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(fd, "w") as stream:
            stream.write(json.dumps(value, indent=2) + "\n")
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def reconcile(home, state, defaults, keys_seed):
    previous = read_object(state)
    desired = read_object(defaults)
    changes = []
    # Validate all files before making any changes; invalid app data is not lost.
    for name in sorted(previous.keys() | desired.keys()):
        relative = Path(name)
        if relative.is_absolute() or ".." in relative.parts:
            raise ValueError(f"Invalid config path: {name}")
        path = home / relative
        exists = path.exists()
        current = read_object(path)
        if not exists and name == "keys.json":
            current = read_object(keys_seed)
        updated = merge(
            current,
            previous.get(name, {}) if exists else {},
            desired.get(name, {}),
        )
        if updated != current or not exists:
            changes.append((path, updated))
    for path, value in changes:
        write_object(path, value)
    if previous != desired or not state.exists():
        write_object(state, desired)


if __name__ == "__main__":
    reconcile(*(Path(argument) for argument in sys.argv[1:]))
