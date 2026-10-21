#!/usr/bin/env bash
# Release build of Tape, assembled into dist/Tape.app and ad-hoc signed.
#
#   --fast   Testing build with fast mode compiled in (see Services/FastMode.swift).
#            Written to .build/fast/Tape.app, never to dist/, so it can't end
#            up in a DMG. Kept in its own build folder so switching between
#            the two builds doesn't recompile everything.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

FAST=0
for arg in "$@"; do
    case "$arg" in
        --fast) FAST=1 ;;
        *) echo "Unknown option: $arg (usage: build-app.sh [--fast])" >&2; exit 1 ;;
    esac
done

VERSION="$(tr -d '[:space:]' < VERSION)"

if [[ $FAST == 1 ]]; then
    APP="$ROOT/.build/fast/Tape.app"
    BUILD_FLAGS=(-c release --build-path .build/fast -Xswiftc -DTAPE_FAST)
else
    APP="$ROOT/dist/Tape.app"
    BUILD_FLAGS=(-c release)
fi

# arm64 only: building a universal binary needs full Xcode.
swift build "${BUILD_FLAGS[@]}"
BIN_DIR="$(swift build "${BUILD_FLAGS[@]}" --show-bin-path)"

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
