#!/bin/zsh
# One-time setup for rendering the promo. Needs Google Chrome and Node.
set -e
cd "$(dirname "$0")"
npm install --silent
python3 -m venv .venv && .venv/bin/pip -q install numpy scipy fonttools imageio-ffmpeg
# SF Pro is not redistributable: make local cuts from the copy that ships with macOS
cp /System/Library/Fonts/SFNS.ttf /System/Library/Fonts/SFNSRounded.ttf .
.venv/bin/python -c "
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont
for name, op in [('SFD', 96), ('SFS', 40), ('SFT', 17)]:
    f = TTFont('SFNS.ttf'); instantiateVariableFont(f, {'opsz': op, 'wdth': 100, 'GRAD': 400}, inplace=True); f.save(name + '.ttf')
"
cp ../art/icon-1024.png .
