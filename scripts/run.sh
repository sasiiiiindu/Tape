#!/usr/bin/env bash
# Quit any running Tape, rebuild it and open the fresh copy.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/dist/Tape.app"

pkill -x Tape || true
# Give the old copy up to 2 seconds to exit.
for _ in {1..20}; do
    pgrep -x Tape > /dev/null || break
    sleep 0.1
done

"$ROOT/scripts/build-app.sh"
open "$APP"

echo "Opened $APP"
