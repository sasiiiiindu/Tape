#!/usr/bin/env bash
# Quit any running Tape, rebuild it and open the fresh copy.
#
#   --fast   Build the fast-mode app and run it at 60x speed (a whole session
#            in about 2 minutes). It runs in this terminal: Ctrl-C or the
#            Quit button stops it.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

FAST=0
for arg in "$@"; do
    case "$arg" in
        --fast) FAST=1 ;;
        *) echo "Unknown option: $arg (usage: run.sh [--fast])" >&2; exit 1 ;;
    esac
done

pkill -x Tape || true
# Give the old copy up to 2 seconds to exit.
for _ in {1..20}; do
    pgrep -x Tape > /dev/null || break
    sleep 0.1
done

if [[ $FAST == 1 ]]; then
    "$ROOT/scripts/build-app.sh" --fast
    APP="$ROOT/.build/fast/Tape.app"
    echo "Running $APP at 60x speed. Ctrl-C to stop."
    TAPE_SPEED=60 exec "$APP/Contents/MacOS/Tape"
fi

"$ROOT/scripts/build-app.sh"
open "$ROOT/dist/Tape.app"

echo "Opened $ROOT/dist/Tape.app"
