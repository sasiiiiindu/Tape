# Tape — notes for Claude Code

## What this is
A minimal macOS menu bar Pomodoro timer. The panel shows a horizontal "tape" of
minute ticks sliding past a fixed needle. Behaviour: docs/SPEC.md.
Visuals: docs/DESIGN.md and docs/design/tape-mockup.png.

## Who you're working with
The owner is a product person, not a Swift developer. He directs; you write all
the code. Explain decisions in plain language, keep changes small, and always
say exactly how to test each step.

## Hard constraints
- Swift Package Manager only. No .xcodeproj. Must build with Command Line Tools
  (`swift build`), no full Xcode.
- macOS 13+ deployment target. SwiftUI first; use AppKit only when SwiftUI
  can't do it, and say why.
- No third-party dependencies unless asked.
- Zero cost: no paid Apple Developer account. The app is ad-hoc signed
  (`codesign --force --deep -s -`) and shipped unsigned as a DMG.
- Menu bar only: LSUIElement = true (no Dock icon).
- Timer accuracy: never count down by decrementing a number. Store the block's
  end Date and compute remaining = end - now. Must stay correct across sleep,
  wake and pauses.

## Layout
- Package.swift
- Sources/Tape/        app code (App, Model, Views, Services folders)
- Resources/           Info.plist, sounds, AppIcon.icns
- scripts/build-app.sh release build -> dist/Tape.app
- scripts/run.sh       build + open the app for testing
- scripts/make-dmg.sh  dist/Tape.app -> dist/Tape-<version>.dmg
- VERSION              single source of truth for the version number

## Commands
- Run:     ./scripts/run.sh
- Package: ./scripts/build-app.sh && ./scripts/make-dmg.sh

## Working rules
- Work only on the current phase. Do not add features from later phases.
- After every change run `swift build` and fix all errors and warnings.
- Finish each phase with: what changed, a step-by-step test list, and a
  suggested commit message.
- Never commit, tag, push or create releases unless asked.
- One view per file; small, clearly named files.
- Resources: do NOT use SPM `Bundle.module`. build-app.sh copies resources
  into Tape.app/Contents/Resources; load them with `Bundle.main`.