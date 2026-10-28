"""Update only mismatched Zen handlers, then verify the LaunchServices state."""

from __future__ import annotations

import argparse
import ctypes
import subprocess
import sys
from collections.abc import Callable


HANDLERS = (
    ("scheme", "http"),
    ("scheme", "https"),
    ("uti", "public.html"),
    ("uti", "public.xhtml"),
)
UTF8 = 0x08000100
ALL_ROLES = 0xFFFFFFFF


class LaunchServices:
    def __init__(self) -> None:
        self.cf = ctypes.CDLL(
            "/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation"
        )
        self.ls = ctypes.CDLL(
            "/System/Library/Frameworks/CoreServices.framework/CoreServices"
        )
        self.cf.CFStringCreateWithCString.argtypes = [
            ctypes.c_void_p, ctypes.c_char_p, ctypes.c_uint32
        ]
        self.cf.CFStringCreateWithCString.restype = ctypes.c_void_p
        self.cf.CFStringGetLength.argtypes = [ctypes.c_void_p]
        self.cf.CFStringGetLength.restype = ctypes.c_long
        self.cf.CFStringGetCString.argtypes = [
            ctypes.c_void_p, ctypes.c_char_p, ctypes.c_long, ctypes.c_uint32
        ]
        self.cf.CFStringGetCString.restype = ctypes.c_bool
        self.cf.CFRelease.argtypes = [ctypes.c_void_p]
        self.cf.CFRelease.restype = None
        self.ls.LSCopyDefaultHandlerForURLScheme.argtypes = [ctypes.c_void_p]
        self.ls.LSCopyDefaultHandlerForURLScheme.restype = ctypes.c_void_p
        self.ls.LSCopyDefaultRoleHandlerForContentType.argtypes = [
            ctypes.c_void_p, ctypes.c_uint32
        ]
        self.ls.LSCopyDefaultRoleHandlerForContentType.restype = ctypes.c_void_p

    def read_handler(self, kind: str, target: str) -> str | None:
        key = self.cf.CFStringCreateWithCString(None, target.encode(), UTF8)
        if not key:
            raise RuntimeError(f"Cannot create LaunchServices query for {target}")
        try:
            if kind == "scheme":
                handler = self.ls.LSCopyDefaultHandlerForURLScheme(key)
            else:
                handler = self.ls.LSCopyDefaultRoleHandlerForContentType(key, ALL_ROLES)
        finally:
            self.cf.CFRelease(key)
        if not handler:
            return None
        try:
            buffer = ctypes.create_string_buffer(
                self.cf.CFStringGetLength(handler) * 4 + 1
            )
            if not self.cf.CFStringGetCString(handler, buffer, len(buffer), UTF8):
                raise RuntimeError(f"Cannot read LaunchServices handler for {target}")
            return buffer.value.decode()
        finally:
            self.cf.CFRelease(handler)


def ensure_handlers(
    bundle_id: str,
    read_handler: Callable[[str, str], str | None],
    set_handler: Callable[[str, str], int],
) -> list[str]:
    failures = []
    for kind, target in HANDLERS:
        if read_handler(kind, target) == bundle_id:
            continue
        status = set_handler(kind, target)
        actual = read_handler(kind, target)
        if actual != bundle_id:
            failures.append(
                f"{target}: expected {bundle_id}, found {actual or 'no handler'} "
                f"(duti exited {status})"
            )
    return failures


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("bundle_id")
    parser.add_argument("duti")
    args = parser.parse_args()

    def set_handler(kind: str, target: str) -> int:
        command = [args.duti, "-s", args.bundle_id, target]
        if kind == "uti":
            command.append("all")
        return subprocess.run(command, check=False).returncode

    failures = ensure_handlers(args.bundle_id, LaunchServices().read_handler, set_handler)
    if failures:
        for failure in failures:
            print(f"Zen: {failure}", file=sys.stderr)
        print(
            "Zen: confirm Zen in System Settings > Desktop & Dock > Default web "
            "browser, then verify HTML/XHTML via Finder Get Info > Open with.",
            file=sys.stderr,
        )
        return 1
    print("Zen: verified HTTP/HTTPS/HTML/XHTML handlers.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
