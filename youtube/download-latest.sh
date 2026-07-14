#!/usr/bin/env bash
# Downloads the latest TeslaTracking video package to your computer.
# Usage:  ./youtube/download-latest.sh [target-folder]
# Default target: ~/Movies/TeslaTracking/<date of package>
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ASSETS_FILE="$REPO_DIR/youtube/upload-package/assets.txt"

if [[ ! -f "$ASSETS_FILE" ]]; then
  echo "No assets.txt found at $ASSETS_FILE — pull the latest branch first (git pull)." >&2
  exit 1
fi

PKG_DATE="$(head -1 "$ASSETS_FILE" | sed 's/^# *//')"
TARGET="${1:-$HOME/Movies/TeslaTracking/$PKG_DATE}"
mkdir -p "$TARGET"

echo "Downloading package '$PKG_DATE' into: $TARGET"

# Download every "name url" line from assets.txt
grep -v '^#' "$ASSETS_FILE" | while read -r NAME URL; do
  [[ -z "${NAME:-}" || -z "${URL:-}" ]] && continue
  echo "  -> $NAME"
  curl -fSL --retry 3 -o "$TARGET/$NAME" "$URL"
done

# Copy the text deliverables from the repo too
cp "$REPO_DIR/youtube/upload-package/description.txt" \
   "$REPO_DIR/youtube/upload-package/captions.srt" \
   "$REPO_DIR/youtube/upload-package/UPLOAD-CHECKLIST.md" \
   "$TARGET/" 2>/dev/null || true

echo ""
echo "Done. Contents of $TARGET:"
ls -lh "$TARGET"
