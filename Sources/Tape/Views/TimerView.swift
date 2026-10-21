import SwiftUI

/// The panel's main page: header, countdown and controls, tape, footer.
/// Sizes and colours live in Theme.
///
/// Every row keeps its height in every state: the window's height for this
/// page is measured once (see StatusItemController), so a row that grew or
/// shrank would be clipped.
struct TimerView: View {
    let timer: SessionTimer
    /// Redraws the page when the timer changes, but only while it's open.
    @ObservedObject var updates: PanelUpdates
    let onSettings: () -> Void
    /// Set by Skip, Restart and New session so the tape slides, not jumps.
    @State private var slide: TapeSlide?

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Sizes.sectionSpacing) {
            HeaderView(
                title: isComplete ? "Done" : timer.currentBlock.kind.title,
                round: "Round \(timer.currentBlock.round) of \(timer.plan.rounds)",
                accent: accent,
                onSettings: onSettings
            )

            HStack(alignment: .center) {
                CountdownView(
                    time: TimeFormat.minutesSeconds(timer.remaining),
                    subline: untilLine,
                    isComplete: isComplete
                )
                Spacer()
                if !isComplete {
                    HStack(spacing: Theme.Sizes.controlSpacing) {
                        RestartButton { slideTape(timer.restartBlock) }
                            .disabled(timer.state == .idle)
                        PlayPauseButton(
                            isRunning: timer.state == .running,
                            playLabel: playLabel,
                            accent: accent,
                            action: playPause
                        )
                    }
                }
            }

            TapeView(timer: timer, slide: slide, updates: updates)

            FooterView(trailing: doneLine) {
                if isComplete {
                    NewSessionButton(accent: accent) { slideTape(timer.newSession) }
                } else {
                    SkipButton(title: skipTitle) { slideTape(timer.skip) }
                }
            }
        }
        .padding(Theme.Sizes.panelPadding)
        .frame(width: Theme.Sizes.panelWidth, alignment: .leading)
        .onReceive(updates.commands, perform: perform)
    }

    private var isComplete: Bool { timer.state == .finished }

    /// "Resume" partway through a block. "Start" at the beginning of one,
    /// including when auto-continue is off and the timer waits at a boundary.
    private var playLabel: String {
        timer.state == .paused && timer.remaining < timer.currentBlock.duration ? "Resume" : "Start"
    }

    private var accent: Color { Theme.Colors.accent(for: timer.currentBlock.kind) }

    private var untilLine: String {
        if isComplete { return "Nice work." }
        return "until " + SessionText.upNext(timer.nextBlock, at: timer.nextBlockStart)
    }

    private var doneLine: String {
        isComplete ? "" : "Done at \(TimeFormat.clock(timer.sessionEnd))"
    }

    /// Run a button's action, then slide the tape from where it was showing
    /// to the new position.
    private func slideTape(_ action: () -> Void) {
        let now = Date()
        let from = TapeSlide.shownElapsed(of: timer, slide: slide, at: now)
        action()
        slide = TapeSlide(from: from, start: now)
    }

    /// Space and S do what the buttons do, so the tape slides the same way.
    private func perform(_ command: PanelCommand) {
        switch command {
        case .playPause:
            if isComplete {
                slideTape(timer.newSession)
            } else {
                playPause()
            }
        case .skip:
            if !isComplete {
                slideTape(timer.skip)
            }
        }
    }

    private func playPause() {
        if timer.state == .running {
            timer.pause()
        } else {
            timer.start()
        }
    }

    private var skipTitle: String {
        guard let next = timer.nextBlock else { return "Finish" }
        return "Skip to \(next.kind.title.lowercased())"
    }
}
