#!/usr/bin/env python3
import os
import pathlib
import plistlib
import sys


def main() -> int:
    root = os.environ.get("PATCH_ROOT")
    if not root:
        sys.exit("[ytlite patch] PATCH_ROOT environment variable is missing.")

    bundle = pathlib.Path(root) / "Library" / "Application Support" / "YTLite.bundle"
    if not bundle.exists():
        sys.exit(f"[ytlite patch] Bundle not found at {bundle}. Ensure the downloaded package layout matches expectations.")

    localizations = list(bundle.glob("*.lproj/Localizable.strings"))
    if not localizations:
        sys.exit(f"[ytlite patch] No localization files found under {bundle}. Verify the YTLite bundle contents.")

    for strings_path in localizations:
        try:
            with strings_path.open("rb") as handle:
                data = plistlib.load(handle)
        except (OSError, plistlib.InvalidFileException, ValueError) as exc:
            sys.exit(f"[ytlite patch] Failed to read {strings_path}: {exc}")
        if "Both" in data:
            data["Both"] = "New Button"
        # Add third option label for Shorts speed activation that allows either side
        data.setdefault("LeftRightSide", "Either side")
        try:
            with strings_path.open("wb") as handle:
                plistlib.dump(data, handle, fmt=plistlib.FMT_BINARY)
        except OSError as exc:
            sys.exit(f"[ytlite patch] Failed to write {strings_path}: {exc}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
