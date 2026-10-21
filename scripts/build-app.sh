#!/usr/bin/env bash
# Release build of Tape, assembled into dist/Tape.app and ad-hoc signed.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VERSION="$(tr -d '[:space:]' < VERSION)"
APP="$ROOT/dist/Tape.app"

# arm64 only: building a universal binary needs full Xcode.
swift build -c release
BIN_DIR="$(swift build -c release --show-bin-path)"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cp "$BIN_DIR/Tape" "$APP/Contents/MacOS/Tape"

cp Resources/Info.plist "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy \
    -c "Set :CFBundleShortVersionString $VERSION" \
    -c "Set :CFBundleVersion $VERSION" \
    "$APP/Contents/Info.plist"

# Everything else in Resources/ (sounds, icon, ...) goes into Contents/Resources.
rsync -a --exclude 'Info.plist' --exclude '.DS_Store' Resources/ "$APP/Contents/Resources/"

# Sign last, once every file is in place.
codesign --force --deep -s - "$APP"

echo "Built Tape $VERSION -> $APP"
