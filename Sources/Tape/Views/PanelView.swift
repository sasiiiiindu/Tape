import SwiftUI

/// Contents of the drop-down panel: header, countdown and controls, tape,
/// footer. Sizes and colours live in Theme.
///
/// Every row keeps its height in every state: the window is only sized when
/// it opens, so a row that grew or shrank while it's open would be clipped.
struct PanelView: View {
    @ObservedObject var timer: SessionTimer

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Sizes.sectionSpacing) {
            HeaderView(
                title: isComplete ? "Done" : timer.currentBlock.kind.title,
                round: "Round \(timer.currentBlock.round) of \(timer.plan.rounds)",
                accent: accent
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
                        RestartButton(action: timer.restartBlock)
                            .disabled(timer.state == .idle)
                        PlayPauseButton(
                            isRunning: timer.state == .running,
                            playLabel: timer.state == .paused ? "Resume" : "Start",
                            accent: accent,
                            action: playPause
                        )
                    }
                }
            }

            TapePlaceholder()

            FooterView(trailing: doneLine) {
                if isComplete {
                    NewSessionButton(accent: accent, action: timer.newSession)
                } else {
                    SkipButton(title: skipTitle, action: timer.skip)
                }
            }
        }
        .padding(Theme.Sizes.panelPadding)
        .frame(width: Theme.Sizes.panelWidth, alignment: .leading)
    }

    private var isComplete: Bool { timer.state == .finished }

    private var accent: Color { Theme.Colors.accent(for: timer.currentBlock.kind) }

    private var untilLine: String {
        if isComplete { return "Nice work." }
        let at = TimeFormat.clock(timer.nextBlockStart)
        guard let next = timer.nextBlock else { return "until done at \(at)" }
        return "until \(next.kind.title.lowercased()) at \(at)"
    }

    private var doneLine: String {
        isComplete ? "" : "Done at \(TimeFormat.clock(timer.sessionEnd))"
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
