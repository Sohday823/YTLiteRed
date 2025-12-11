#!/bin/bash
# Script to patch YTLite deb with custom localizations
# This script extracts the deb, replaces the bundle files with our customized versions, 
# and repacks the deb

set -e

# Arguments
DEB_FILE="$1"
BUNDLE_SOURCE_DIR="$2"
OUTPUT_DEB="$3"

if [ -z "$DEB_FILE" ] || [ -z "$BUNDLE_SOURCE_DIR" ]; then
    echo "Usage: $0 <deb_file> <bundle_source_dir> [output_deb]"
    exit 1
fi

# Default output to input file if not specified
if [ -z "$OUTPUT_DEB" ]; then
    OUTPUT_DEB="$DEB_FILE"
fi

# Create temp directory
TEMP_DIR=$(mktemp -d)
echo "Working in temp directory: $TEMP_DIR"

# Extract the deb file
echo "Extracting deb file..."
dpkg-deb -x "$DEB_FILE" "$TEMP_DIR/data"
dpkg-deb -e "$DEB_FILE" "$TEMP_DIR/control"

# Find the YTLite.bundle directory in the extracted data
BUNDLE_DEST=$(find "$TEMP_DIR/data" -type d -name "YTLite.bundle" | head -1)

if [ -z "$BUNDLE_DEST" ]; then
    echo "Error: Could not find YTLite.bundle in the deb"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo "Found bundle at: $BUNDLE_DEST"

# Copy our customized localization files over the original ones
echo "Copying customized localizations..."
for lang_dir in "$BUNDLE_SOURCE_DIR"/*.lproj; do
    if [ -d "$lang_dir" ]; then
        lang_name=$(basename "$lang_dir")
        dest_lang_dir="$BUNDLE_DEST/$lang_name"
        
        if [ -d "$dest_lang_dir" ]; then
            echo "  Updating $lang_name..."
            cp -f "$lang_dir/Localizable.strings" "$dest_lang_dir/" 2>/dev/null || true
        else
            echo "  Creating $lang_name..."
            mkdir -p "$dest_lang_dir"
            cp -f "$lang_dir/Localizable.strings" "$dest_lang_dir/" 2>/dev/null || true
        fi
    fi
done

# Repack the deb
echo "Repacking deb..."
dpkg-deb -b "$TEMP_DIR/data" "$TEMP_DIR/control" "$OUTPUT_DEB" 2>/dev/null || \
dpkg-deb -b "$TEMP_DIR" "$OUTPUT_DEB"

# Cleanup
echo "Cleaning up..."
rm -rf "$TEMP_DIR"

echo "Done! Output: $OUTPUT_DEB"
