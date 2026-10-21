#!/usr/bin/env bash
# Turn the icon art into Resources/AppIcon.icns, the app icon macOS shows in
# Finder, the DMG, Login Items and notifications. Run it again whenever the
# art changes, and commit the new AppIcon.icns.
#
#   make-icon.sh [art.png] [--allow-opaque]
#
# The art (default art/icon-1024.png) must be a square PNG of at least
# 1024 x 1024, with a transparent background around the icon shape: macOS
# draws the icon exactly as given, so a solid background shows as a square.
# The script refuses art whose corners aren't transparent; --allow-opaque
# builds it anyway, with a warning.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SOURCE="art/icon-1024.png"
ALLOW_OPAQUE=0
for arg in "$@"; do
    case "$arg" in
        --allow-opaque) ALLOW_OPAQUE=1 ;;
        -*) echo "Unknown option: $arg (usage: make-icon.sh [art.png] [--allow-opaque])" >&2; exit 1 ;;
        *) SOURCE="$arg" ;;
    esac
done
OUTPUT="Resources/AppIcon.icns"

if [[ ! -f "$SOURCE" ]]; then
    echo "No icon art at $SOURCE." >&2
    exit 1
fi

WIDTH="$(sips -g pixelWidth "$SOURCE" | awk '/pixelWidth/ { print $2 }')"
HEIGHT="$(sips -g pixelHeight "$SOURCE" | awk '/pixelHeight/ { print $2 }')"
if [[ "$WIDTH" != "$HEIGHT" || "$WIDTH" -lt 1024 ]]; then
    echo "$SOURCE is ${WIDTH}x${HEIGHT}. It needs to be square and at least 1024x1024." >&2
    exit 1
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# sips can't read a pixel's transparency, so a few lines of Swift check the
# top-left corner, which is always outside the icon shape.
cat > "$WORK/corner.swift" <<'SWIFT'
import AppKit
let url = URL(fileURLWithPath: CommandLine.arguments[1])
guard let data = try? Data(contentsOf: url), let image = NSBitmapImageRep(data: data),
      let corner = image.colorAt(x: 0, y: 0) else { exit(2) }
exit(corner.alphaComponent < 0.01 ? 0 : 1)
SWIFT
if ! swift "$WORK/corner.swift" "$SOURCE"; then
    if [[ $ALLOW_OPAQUE == 1 ]]; then
        echo "Warning: $SOURCE has a solid background, so the icon will show as a square." >&2
    else
        echo "$SOURCE has a solid background (its corners aren't transparent), so the icon" >&2
        echo "would show as a square in Finder. Export it with a transparent background (a" >&2
        echo "soft shadow on transparency is fine), or pass --allow-opaque to build it anyway." >&2
        exit 1
    fi
fi

# Every size macOS asks for, each at 1x and 2x (Retina), named as iconutil expects.
ICONSET="$WORK/AppIcon.iconset"
mkdir "$ICONSET"
for size in 16 32 128 256 512; do
    sips -z "$size" "$size" -s format png "$SOURCE" --out "$ICONSET/icon_${size}x${size}.png" > /dev/null
    double=$((size * 2))
    sips -z "$double" "$double" -s format png "$SOURCE" --out "$ICONSET/icon_${size}x${size}@2x.png" > /dev/null
done

iconutil -c icns "$ICONSET" -o "$OUTPUT"
echo "Built $OUTPUT from $SOURCE"
