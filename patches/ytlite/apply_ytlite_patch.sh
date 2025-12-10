#!/bin/bash

# YTLite Patch Script
# This script modifies the YouTube Plus (YTLite) .deb file to add custom features:
# 1. Replace "Both" option with "New Button" option in downloading button placement
# 2. Add "Both" option to shorts speed up activation location (combining left and right)

set -e

DEB_FILE="$1"
WORK_DIR="ytlite_patch_work"

if [ -z "$DEB_FILE" ]; then
    echo "Error: No .deb file specified"
    echo "Usage: $0 <path_to_ytlite.deb>"
    exit 1
fi

if [ ! -f "$DEB_FILE" ]; then
    echo "Error: File $DEB_FILE not found"
    exit 1
fi

echo "========================================="
echo "Starting YTLite patch process..."
echo "========================================="

# Create working directory
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"

# Extract the .deb file
echo "Extracting $DEB_FILE..."
dpkg-deb -R "$DEB_FILE" "$WORK_DIR"

# Find all Localizable.strings files
echo ""
echo "Patching localization files..."
echo "----------------------------------------"
find "$WORK_DIR" -name "Localizable.strings" -type f | while read -r file; do
    echo "Processing: $(basename $(dirname "$file"))/$(basename "$file")"

    # Backup original file
    cp "$file" "$file.bak"

    # 1. Modify button placement options: Change "Both" to "NewButton"
    if grep -q '"Both" = "Both";' "$file"; then
        echo "  → Replacing 'Both' with 'New Button' option"
        sed -i '' 's/"Both" = "Both";/"NewButton" = "New Button";/g' "$file" 2>/dev/null || \
        sed -i 's/"Both" = "Both";/"NewButton" = "New Button";/g' "$file"
    fi

    # 2. Add description for New Button option (if not already present)
    if grep -q '"NewButton"' "$file" && ! grep -q '"NewButtonDesc"' "$file"; then
        echo "  → Adding NewButton description"
        # Add description after NewButton line
        sed -i '' '/^"NewButton" = /a\
"NewButtonDesc" = "Adds a separate Save button under the video with the download icon";
' "$file" 2>/dev/null || \
        sed -i '/^"NewButton" = /a\
"NewButtonDesc" = "Adds a separate Save button under the video with the download icon";
' "$file"
    fi

    # 3. Add "Both" and other options to shorts speed location
    if grep -q '"SpeedLocation"' "$file"; then
        if ! grep -q '"SpeedLocationBoth"' "$file"; then
            echo "  → Adding speed location options (Left, Right, Both)"
            # Add all speed location options after SpeedLocation line
            sed -i '' '/^"SpeedLocation" = /a\
"SpeedLocationLeft" = "Left side";\
"SpeedLocationRight" = "Right side";\
"SpeedLocationBoth" = "Both sides";\
"SpeedLocationBothDesc" = "Combined left and right side activation";
' "$file" 2>/dev/null || \
            sed -i '/^"SpeedLocation" = /a\
"SpeedLocationLeft" = "Left side";\
"SpeedLocationRight" = "Right side";\
"SpeedLocationBoth" = "Both sides";\
"SpeedLocationBothDesc" = "Combined left and right side activation";
' "$file"
        fi
    fi

    # Clean up backup if successful
    rm -f "$file.bak"
    echo "  ✓ Patched successfully"
done

echo ""
echo "Localization files patched successfully"
echo "----------------------------------------"

# Repackage the .deb file
echo ""
echo "Repackaging .deb file..."
dpkg-deb -b "$WORK_DIR" "${DEB_FILE}.new"

# Replace original with patched version
mv "${DEB_FILE}.new" "$DEB_FILE"

# Clean up
echo "Cleaning up..."
rm -rf "$WORK_DIR"

echo ""
echo "========================================="
echo "✓ YTLite patch completed successfully!"
echo "========================================="
