#!/usr/bin/env bash
# Package dist/Tape.app into dist/Tape-<version>.dmg: the app plus an
# Applications shortcut to drag it onto. Run scripts/build-app.sh first.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VERSION="$(tr -d '[:space:]' < VERSION)"
APP="$ROOT/dist/Tape.app"
DMG="$ROOT/dist/Tape-$VERSION.dmg"

if [[ ! -d "$APP" ]]; then
    echo "No $APP. Run scripts/build-app.sh first." >&2
    exit 1
fi

# Catches a VERSION bump without a rebuild.
APP_VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Contents/Info.plist")"
if [[ "$APP_VERSION" != "$VERSION" ]]; then
    echo "dist/Tape.app is version $APP_VERSION but VERSION says $VERSION. Run scripts/build-app.sh first." >&2
    exit 1
fi

STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT

# ditto keeps the code signature and file attributes intact.
ditto "$APP" "$STAGING/Tape.app"
ln -s /Applications "$STAGING/Applications"

hdiutil create \
    -volname "Tape $VERSION" \
    -srcfolder "$STAGING" \
    -fs HFS+ \
    -format UDZO \
    -ov \
    "$DMG" > /dev/null

echo "Built $DMG"
echo "SHA-256: $(shasum -a 256 "$DMG" | cut -d ' ' -f 1)"
