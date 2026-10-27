# Tape promo film

A 55-second motion-graphics promo, drawn frame by frame on an HTML canvas and
rendered with headless Chrome. The music and sound design are synthesised from
scratch in `score.py`, so there are no licensed samples.

- `film.html`: the whole film. `render(t)` draws the frame at `t` seconds.
- `score.py`: the original soundtrack, timed to the film.
- `capture.js`: renders stills (`node capture.js stills 4,12.5 outdir`) or the video.
- `timeline.js`: exports the minute-tick times that the sound effects sync to.

First time: `./setup.sh`. Then `./render.sh v6` writes `dist/Tape-promo-v6.mp4`.
