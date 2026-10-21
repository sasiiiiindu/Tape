# Changelog

All notable changes to Tape are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-10-21

### Added

- Settings, inside the panel: the sliders button slides them in, and a back
  arrow returns to the timer.
- Set the focus length (5–90 min), break length (1–30 min) and number of
  rounds (1–8).
- Long breaks: off by default, or every 2, 3 or 4 rounds, 5–45 min long. They
  show in a deeper green on the tape and in the menu bar.
- A live preview of the planned session with its total length and focus time.
- Auto-continue can be turned off, so the timer stops at the start of each
  block and waits for you.
- The countdown in the menu bar can be hidden, leaving just the strip.
- Settings are remembered between launches. Changes made during a session
  apply to the next one.

### Changed

- Quit has moved to the bottom of Settings. ⌘Q still works while the panel is
  open.
- Labels on the tape that don't fit their block are shortened or left out
  instead of overlapping.

## [0.1.0] - 2026-10-21

First release.

### Added

- Menu bar item: a mini strip of the whole session followed by a live mm:ss
  countdown. Finished blocks are filled in their colour, and the current block
  fills from left to right. It reads well on light and dark menu bars.
- Drop-down panel with the current mode and round, a large countdown, and the
  clock times when the next block starts and the session ends.
- The tape: minute ticks for the whole session sliding past a fixed needle.
- Controls: Start, Pause and Resume; Restart the current block; Skip to the
  next block (Finish on the last one); New session once a session is complete.
- A session of four rounds: 25 minutes focus, 5 minutes break. Each block runs
  straight into the next.
- Clock-based timing that stays correct through sleep, wake and pauses.
- Menu bar only, with no Dock icon. Quit from the panel's settings menu or
  with ⌘Q while the panel is open.

[Unreleased]: https://github.com/sasiiiiindu/Tape/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/sasiiiiindu/Tape/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/sasiiiiindu/Tape/releases/tag/v0.1.0
