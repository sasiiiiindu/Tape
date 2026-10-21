# Tape — visual spec
Reference: docs/design/tape-mockup.png. Minimal, native, calm. One accent per mode.

## Colours (dark first; light mode comes in Phase 8)
focus #F2685A | break #8CC4A4 | text #F5F5F7 | secondary #A8A8B0
track/button fill = white 10% | divider = white 9% | icon on accent #1C1C1E
Panel background: the native MenuBarExtra window material. Never paint a
solid colour over it.

## Type
- Countdown: .system(size: 56, weight: .light, design: .rounded),
  monospaced digits.
- Header 13 pt semibold; secondary 12 pt; tape labels 10 pt medium.

## Panel
- Width 320 pt; padding 18 top, 20 sides, 16 bottom; 18 pt between sections.
- Play/pause: 48 pt circle, accent fill, dark icon. Restart: 34 pt circle,
  track fill. Skip: text button, 28 pt tall, radius 8, track fill.
- Mode colour changes animate over 0.6 s ease.

## The tape
- Window 280 x 70 pt, clipped; both edges fade out over 14% of the width.
- 1 minute = 7 pt. Needle fixed at x = 84 pt (about 12 min past visible,
  28 min ahead).
- Ticks: 2 pt wide, rounded, bottom-aligned at y = 56. Minute 10 pt tall,
  every 5th minute 18 pt, block boundaries 30 pt in text colour.
- Tick colour = its block's colour. Opacity: past 22%, minute 50%,
  5-minute 95%, boundary 85%.
- Under the ticks: a 5 pt rounded band per block (2 pt inset each end).
  Opacity past 25%, current 100%, future 60%.
- Above each block: "Focus 1", "Break"... 10 pt medium. Current block in text
  colour, others secondary.
- Needle: 2 x 38 pt line in text colour with an 8 pt dot on top.
- Motion: the strip moves continuously (redraw about once a second with a 1 s
  linear animation, or smoother if CPU stays low). Skip/restart slide the
  strip with a ~0.4 s ease.

## Menu bar mini strip
40 x 4 pt, 1.5 pt gaps, radius 2. Future blocks white 30% (black 25% on a
light menu bar); finished blocks solid in their colour; current block fills
left to right. Then mm:ss in the menu bar font, monospaced digits.
Idle: empty strip + the first block's length (25:00).