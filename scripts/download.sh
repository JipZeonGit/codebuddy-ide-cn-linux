#!/bin/bash
# Download the official CodeBuddy package (DMG or DEB) into downloads/.
# Usage: download.sh <url>
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DOWNLOADS_DIR="$SCRIPT_DIR/downloads"
BACKUPS_DIR="$DOWNLOADS_DIR/backups"

. "$SCRIPT_DIR/scripts/lib/common.sh"

[ $# -ge 1 ] || error "Usage: $0 <package-url>"

PKG_URL="$1"
PKG_FILENAME="${PKG_URL##*/}"

# 1. Ensure downloads/ exists
mkdir -p "$DOWNLOADS_DIR"

# 2. If the exact file already exists, nothing to do
if [ -f "$DOWNLOADS_DIR/$PKG_FILENAME" ]; then
    info "$PKG_FILENAME already exists in downloads/, skipping download."
    exit 0
fi

# 3. Move any existing .dmg or .deb files (except the target we want to download) to backups/
for f in "$DOWNLOADS_DIR"/*.dmg "$DOWNLOADS_DIR"/*.deb; do
    [ -f "$f" ] || continue
    [ "$(basename "$f")" != "$PKG_FILENAME" ] || continue
    mkdir -p "$BACKUPS_DIR"
    info "Moving old package to backups/: $(basename "$f")"
    mv "$f" "$BACKUPS_DIR/"
done

# 4. Download the new package
info "Downloading $PKG_FILENAME ..."
curl -fSL --progress-bar -o "$DOWNLOADS_DIR/$PKG_FILENAME" "$PKG_URL"

info "Download complete: downloads/$PKG_FILENAME"
