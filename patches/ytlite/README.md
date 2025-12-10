# YTLite (YouTube Plus) Patches

This directory contains patches that are applied to the downloaded YouTube Plus (YTLite) .deb file during the build process.

## What Gets Patched

The `apply_ytlite_patch.sh` script modifies the official YouTube Plus to add custom features:

### 1. Downloading Button Placement
- **What changed**: Replaced the "Both" option with a new "New Button" option
- **Description**: The "New Button" option adds a separate "Save" button under the video with the same download icon
- **Location in settings**: YouTube Plus > Downloading > Downloading button placement

### 2. Shorts Speed Up Activation Location
- **What changed**: Added "Both sides" option to speed up activation location
- **Description**: Combines left and right side activation into one unified button
- **Location in settings**: YouTube Plus > Shorts > Speed up activation location

## How It Works

The patch script:
1. Extracts the downloaded YTLite .deb file
2. Finds all `Localizable.strings` files in all language bundles
3. Modifies the localization strings to add the new options
4. Repackages the .deb file

This approach ensures that:
- You always get the latest official YouTube Plus features
- Custom modifications are applied automatically during build
- Changes work across all supported languages

## Technical Details

The script uses `dpkg-deb` to extract and repackage the .deb file, and `sed` to perform text replacements in the localization files.

## Usage

The patch is automatically applied during the GitHub Actions build workflow. No manual intervention is required.

If you want to apply the patch manually:
```bash
bash patches/ytlite/apply_ytlite_patch.sh path/to/ytplus.deb
```

## Future Enhancements

To add full functionality for these features (beyond just UI labels), you would need to:
- Add hooks to implement the "New Button" that appears under videos
- Add hooks to implement the combined "Both sides" speed activation

These implementations would require additional code in the tweak itself or a companion tweak.
