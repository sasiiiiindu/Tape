#!/usr/bin/env bash
# Release build of Tape, assembled into dist/Tape.app and ad-hoc signed.
#
# A universal app: it builds for Apple silicon (arm64) and Intel (x86_64)
# separately, then joins the two with lipo. If the Intel build fails, the
# app is built for Apple silicon only and the script says so.
#
#   --fast   Testing build with fast mode compiled in (see Services/FastMode.swift).
#            Written to .build/fast/Tape.app, never to dist/, so it can't end
#            up in a DMG. Kept in its own build folder so switching between
#            the two builds doesn't recompile everything. This Mac's
#            architecture only, to keep it quick.
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

# Builds Tape for one architecture in its own build folder and prints the
# path of the binary. (Building both at once needs full Xcode; one at a time
# works with the Command Line Tools.)
build_arch() {
    local flags=(-c release --triple "$1-apple-macosx13.0" --build-path ".build/$1")
    # Checked by hand: set -e is off inside the `if` this is called from.
    swift build "${flags[@]}" >&2 || return 1
    echo "$(swift build "${flags[@]}" --show-bin-path)/Tape"
}

if [[ $FAST == 1 ]]; then
    APP="$ROOT/.build/fast/Tape.app"
    BUILD_FLAGS=(-c release --build-path .build/fast -Xswiftc -DTAPE_FAST)
    swift build "${BUILD_FLAGS[@]}"
    BINARY="$(swift build "${BUILD_FLAGS[@]}" --show-bin-path)/Tape"
else
    APP="$ROOT/dist/Tape.app"
    ARM_BINARY="$(build_arch arm64)"
    if INTEL_BINARY="$(build_arch x86_64)"; then
        BINARY="$ROOT/.build/Tape-universal"
        lipo -create "$ARM_BINARY" "$INTEL_BINARY" -output "$BINARY"
        ARCHS="Apple silicon + Intel"
    else
        echo "" >&2
        echo "The Intel (x86_64) build failed, so this Tape.app runs on Apple silicon only." >&2
        echo "The error is above. Apple silicon Macs aren't affected." >&2
        echo "" >&2
        BINARY="$ARM_BINARY"
        ARCHS="Apple silicon only"
    fi
fi

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cp "$BINARY" "$APP/Contents/MacOS/Tape"

cp Resources/Info.plist "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy \
    -c "Set :CFBundleShortVersionString $VERSION" \
    -c "Set :CFBundleVersion $VERSION" \
    "$APP/Contents/Info.plist"

# Everything else in Resources/ (sounds, icon, ...) goes into Contents/Resources.
rsync -a --exclude 'Info.plist' --exclude '.DS_Store' Resources/ "$APP/Contents/Resources/"

# Sign last, once every file is in place.
codesign --force --deep -s - "$APP"

echo "Built Tape $VERSION ($(lipo -archs "$APP/Contents/MacOS/Tape")${ARCHS:+, $ARCHS}) -> $APP"
