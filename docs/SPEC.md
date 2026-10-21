# Tape — product spec

## Session model
- A session is an ordered list of blocks: Focus, Break, Focus, Break ... ending
  on the last Focus.
- Defaults: focus 25 min, break 5 min, 4 rounds = 115 min. Long break is off by
  default.
- Long break: when on, the break after every Nth round is a long break instead
  (e.g. every 2 rounds: Focus, Break, Focus, Long break, Focus ...). There is
  never a long break after the last round, so "every 4" with 4 rounds has none.
- States: idle (not started), running, paused, finished.

## Controls
- Primary button: Start / Pause / Resume.
- Restart: back to the start of the current block, paused.
- Skip: jump to the start of the next block (keeps running if it was running).
  On the last block it reads "Finish".
- Auto-continue (default on): when a block ends, the next starts. Off = stop at
  the start of the next block, paused, and wait for Start. After a long sleep
  it stops at the first boundary it passed, never further.
- Session finished: panel says "Session complete"; primary button becomes
  "New session".

## Panel, top to bottom
1. Header: coloured dot + "Focus"/"Break"/"Long break", "Round 2 of 4",
   settings button.
2. Big mm:ss countdown + sub-line "until break at 7:50 PM" (wall-clock start of
   the next block; "until done at ..." on the last block). Large play/pause and
   small restart buttons on the right.
3. The tape (see DESIGN.md).
4. Footer: Skip button on the left ("Skip to break" / "Skip to focus" /
   "Finish"), "Done at 8:50 PM" on the right.
- Clock times are live: pausing pushes them later.

## Settings
- Inside the same panel. The settings button in the header slides the timer
  page out to the left and the settings page in from the right; a back chevron
  at the top left slides back. The panel grows or shrinks to fit each page,
  keeping its top edge under the menu bar. Closing the panel always returns to
  the timer page.
- Steppers, in a grouped box:
  - Focus: 5-90 min, steps of 5. Default 25.
  - Break: 1-30 min, steps of 1. Default 5.
  - Rounds: 1-8. Default 4.
  - Long break: 5-45 min, steps of 5. Default 15. Dimmed when the planned
    session has no long break in it.
  - Long break every: Off / 2 / 3 / 4 rounds. Default Off.
- Live preview under the steppers: a mini tape of the planned session (blocks
  in their colours, widths proportional to length), then
  "Total 1h 55m · 1h 40m focus".
- Toggles, in a second box: Auto-continue to next block (on), Show countdown
  in menu bar (on).
- Quit Tape, in a third box (⌘Q also works while the panel is open).
- Saved in UserDefaults the moment they change. Out-of-range saved values are
  pulled back into range on launch.
- When changes apply:
  - Session shape (the steppers): at once while idle. Once a session has
    started (running, paused or finished), the current session keeps its shape,
    a note under the preview says "Applies to your next session", and the new
    shape starts with New session.
  - Toggles: at once, including mid-session. Auto-continue takes effect at the
    end of the current block.

## Menu bar item
- A 40x4 pt mini strip of the whole session (block widths proportional to
  duration; finished blocks filled, current block partly filled), then the
  mm:ss countdown in monospaced digits.
- With "Show countdown in menu bar" off, only the strip shows.

## Out of scope for now
Statistics history, task lists, iCloud sync, Focus mode integration, iOS.