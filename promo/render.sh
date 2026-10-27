#!/bin/zsh
# Render the promo: ./render.sh [version] [vertical]
#   ->  ../dist/Tape-promo-<version>.mp4, or Tape-promo-<version>-vertical.mp4 (9:16, for stories)
set -e
cd "$(dirname "$0")"
V=${1:-v6}
FMT=${2:-}
OUT=../dist/Tape-promo-$V${FMT:+-$FMT}.mp4
FF=$(.venv/bin/python -c "import imageio_ffmpeg; print(imageio_ffmpeg.get_ffmpeg_exe())")
node timeline.js > timeline.json
.venv/bin/python -I score.py timeline.json score.wav
node capture.js video silent.mp4 "$FF" $FMT
mkdir -p ../dist
"$FF" -y -v error -i silent.mp4 -i score.wav -c:v copy -c:a aac -b:a 256k -shortest -movflags +faststart $OUT
rm silent.mp4 score.wav timeline.json
echo "$OUT"
