# Tape — product spec

## Session model
- A session is an ordered list of blocks: Focus, Break, Focus, Break ... ending
  on the last Focus.
- Defaults: focus 25 min, break 5 min, 4 rounds = 115 min. Long break is off by
  default (Phase 6 adds e.g. 15 min every N rounds).
- States: idle (not started), running, paused, finished.

## Controls
- Primary button: Start / Pause / Resume.
- Restart: back to the start of the current block, paused.
- Skip: jump to the start of the next block (keeps running if it was running).
  On the last block it reads "Finish".
- Auto-continue (default on): when a block ends, the next starts. Off = stop at
  the boundary and wait for Start.
- Session finished: panel says "Session complete"; primary button becomes
  "New session".

## Panel, top to bottom
1. Header: coloured dot + "Focus"/"Break", "Round 2 of 4", settings button.
2. Big mm:ss countdown + sub-line "until break at 7:50 PM" (wall-clock start of
   the next block; "until done at ..." on the last block). Large play/pause and
   small restart buttons on the right.
3. The tape (see DESIGN.md).
4. Footer: Skip button on the left ("Skip to break" / "Skip to focus" /
   "Finish"), "Done at 8:50 PM" on the right.
- Clock times are live: pausing pushes them later.

## Menu bar item
- A 40x4 pt mini strip of the whole session (block widths proportional to
  duration; finished blocks filled, current block partly filled), then the
  mm:ss countdown in monospaced digits.

## Out of scope for now
Statistics history, task lists, iCloud sync, Focus mode integration, iOS.