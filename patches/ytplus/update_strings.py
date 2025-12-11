#!/usr/bin/env python3
import os
import pathlib
import plistlib
import sys


def main() -> int:
    root = os.environ.get("PATCH_ROOT")
    if not root:
        sys.exit("[ytplus patch] PATCH_ROOT environment variable is missing.")

    DOWNLOAD_BOTH_KEY = "Both"  # Existing download button placement option label
    EITHER_SIDE_KEY = "LeftRightSide"  # New Shorts speed activation option label (either side)
    NEW_BUTTON_LABEL = "New Button"
    EITHER_SIDE_LABEL = "Either side"

    bundle = pathlib.Path(root) / "Library" / "Application Support" / "YTLite.bundle"
    if not bundle.exists():
        sys.exit(f"[ytplus patch] Bundle not found at {bundle}. Ensure the downloaded package layout matches expectations.")

    localizations = list(bundle.glob("*.lproj/Localizable.strings"))
    if not localizations:
        sys.exit(f"[ytplus patch] No localization files found under {bundle}. Verify the YTLite bundle contents.")

    for strings_path in localizations:
        try:
            with strings_path.open("rb") as handle:
                data = plistlib.load(handle)
        except (OSError, plistlib.InvalidFileException, ValueError) as exc:
            sys.exit(f"[ytplus patch] Failed to read {strings_path}: {exc}")
        if DOWNLOAD_BOTH_KEY in data:
            data[DOWNLOAD_BOTH_KEY] = NEW_BUTTON_LABEL
        # Add third option label for Shorts speed activation that allows either side
        data.setdefault(EITHER_SIDE_KEY, EITHER_SIDE_LABEL)
        try:
            with strings_path.open("wb") as handle:
                plistlib.dump(data, handle, fmt=plistlib.FMT_BINARY)
        except OSError as exc:
            sys.exit(f"[ytplus patch] Failed to write {strings_path}: {exc}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
