# Tape — visual spec
Reference: docs/design/tape-mockup.png. Minimal, native, calm. One accent per mode.

## Colours
The panel follows the system's light or dark mode.

|              | Dark      | Light     |
|--------------|-----------|-----------|
| focus        | #F2685A   | #D2412F   |
| break        | #8CC4A4   | #2A8458   |
| long break   | #52A07C   | #1D6644   |
| text         | #F5F5F7   | #1D1D1F   |
| secondary    | #A8A8B0   | #545459   |
| track/button fill | white 10% | black 6% |
| divider      | white 9%  | black 10% |
| icon/text on accent | #1C1C1E | white |

Panel background: the native popover window material. Never paint a solid
colour over it.

Light colours are checked against #E0E0E0, a deliberately dark stand-in for
the light material (it varies with the wallpaper):
- Text 12.8:1, secondary 5.7:1 (5.0:1 on the track fill of a settings row).
  Both at least 4.5:1.
- Accents are deeper than in dark mode so they read on a light background:
  focus 3.5:1, break 3.5:1, long break 5.2:1 (at least 3:1 for shapes).
- White on the accents: focus 4.6:1, break 4.6:1, long break 6.9:1, so the
  "New session" text on them passes 4.5:1 too.

The menu bar strip picks its block colours from the menu bar's appearance,
not the system's: the light set on a light menu bar.

## Type
- Countdown: .system(size: 56, weight: .light, design: .rounded),
  monospaced digits.
- Header 13 pt semibold; secondary 12 pt; tape labels 10 pt medium.

## Panel
- Width 320 pt; padding 18 top, 20 sides, 16 bottom; 18 pt between sections.
- Play/pause: 48 pt circle, accent fill, dark icon. Restart: 34 pt circle,
  track fill. Skip: text button, 28 pt tall, radius 8, track fill.
- Mode colour changes animate over 0.6 s ease (instant with Reduce Motion).

## Long breaks
A long break is a deeper, more saturated shade of the break green (#52A07C
against #8CC4A4), so it reads as "still a break, but a bigger one". It is used
everywhere the break colour is: tape ticks and band, the header dot and play
button, the menu bar strip and the settings preview. The dark icon on top
still has about 5:1 contrast. Two more cues back up the colour: it is labelled
"Long break" on the tape, and it is usually 3x as wide as a short break.

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
- Above each block: "Focus 1", "Break", "Long break" 10 pt medium. Current
  block in text colour, others secondary. A label must end 4 pt before the
  next block's label; if it doesn't fit, a shorter one is used ("1", "Long")
  or none at all, so short blocks never overlap.
- Needle: 2 x 38 pt line in text colour with an 8 pt dot on top.
- Motion: the strip moves continuously (redraw about once a second with a 1 s
  linear animation, or smoother if CPU stays low). Skip/restart slide the
  strip with a ~0.4 s ease.
- Reduce Motion (System Settings > Accessibility > Display): the strip steps
  once a minute instead of sliding, and Skip/restart jump.
- VoiceOver reads the tape as one sentence: "Focus, round 2 of 4, 18 minutes
  left, break at 7:50 PM" (plus "paused" or "not started").
- Only the part of the session around the needle is drawn, so a 16-hour
  session costs no more to draw than a 2-hour one.

## Settings page
- Same width and padding as the timer page; 14 pt between sections.
- Header: 22 pt round back button (chevron, track fill) + "Settings" 13 pt
  semibold.
- Groups: rounded boxes, radius 8, track fill (white 10%), 1 pt divider lines
  between rows (inset 10 pt on the left). Rows 32 pt tall, 10 pt side
  padding, name 13 pt in text colour on the left, value 13 pt secondary
  (monospaced digits) and the native stepper or mini switch on the right.
  Switches use the current mode colour.
- Preview: 280 x 6 pt strip of the planned session, 2 pt gaps, fully rounded
  blocks in their colours; 8 pt below it the total in 12 pt secondary, and
  "Applies to your next session" in text colour on the next line (space kept
  even when hidden, so the page never changes height).
- Disabled rows fade to 35%.
- Page change: the pages slide sideways and the panel resizes from the bottom
  edge, both 0.3 s ease-in-out.

## Menu bar mini strip
40 x 4 pt, 1.5 pt gaps, radius 2. Future blocks white 30% (black 25% on a
light menu bar); finished blocks solid in their colour; current block fills
left to right. Then mm:ss in the menu bar font, monospaced digits.
Idle: empty strip + the first block's length (25:00).
With the countdown turned off in Settings: the strip alone, no gap after it.