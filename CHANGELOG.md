# Changelog

All notable changes to Tape are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-10-21

### Added

- Light mode. Tape follows your Mac's appearance, with deeper colours on the
  light panel so text and accents stay easy to read.
- Reduce Motion support. With it on (System Settings > Accessibility >
  Display), the tape steps once a minute instead of sliding, Skip and Restart
  jump instead of sliding, and colour changes are instant.
- VoiceOver reads every button, and the tape and the menu bar item as a
  sentence: "Focus, round 2 of 4, 18 minutes left, break at 7:50 PM".
- If Tape quits in the middle of a session (or your Mac restarts), the
  session comes back paused where it was when Tape opens again. After 12
  hours it starts fresh instead.
- An app icon.
- Runs on Intel Macs as well as Apple silicon.

### Changed

- If ⌃⌥T can't be turned on because another app uses it, Settings now says
  "In use".

### Fixed

- Changing your Mac's clock by hand no longer changes the time left. Before,
  setting it back froze the countdown, and setting it forward skipped blocks.
- Settings rows no longer wrap onto a second line and get cut off when a note
  shows next to a switch.
- Very long sessions (up to 16 hours) draw on the tape as cheaply as short
  ones.

## [0.3.0] - 2026-10-21

### Added

- A chime and a notification when a block ends: "Break · Back to focus at
  7:55 PM", "Focus · Round 3 of 4", or "Session complete". Tape asks to send
  notifications the first time you press Start, not at launch. The chime
  plays even if notifications are turned off.
- Settings shows whether notifications are on. If they're off, "Off ›" opens
  Tape's page in System Settings, since macOS only asks once.
- Sound setting: Soft chime (default), Bell or None. They're sounds built into
  macOS, and each one plays as you pick it.
- Launch at login. If macOS needs you to allow it, or Tape is running from the
  disk image, a short note next to the switch says so.
- Keys while the panel is open: Space starts, pauses and resumes (or starts a
  new session once one is complete), S skips, Esc closes the panel.
- An optional shortcut, ⌃⌥T, that opens and closes the panel from any app. Off
  by default, and needs no extra permissions.

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

[Unreleased]: https://github.com/sasiiiiindu/Tape/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/sasiiiiindu/Tape/compare/v0.3.0...v1.0.0
[0.3.0]: https://github.com/sasiiiiindu/Tape/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/sasiiiiindu/Tape/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/sasiiiiindu/Tape/releases/tag/v0.1.0
