import SwiftUI

/// Contents of the drop-down panel. Temporary, unstyled layout for checking
/// the timer; the real design arrives in a later phase.
///
/// Every row is shown in every state so the panel never changes height.
struct PanelView: View {
    @ObservedObject var timer: SessionTimer

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(header)
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Text("Round \(timer.currentBlock.round) of \(timer.plan.rounds)")
                    .foregroundStyle(.secondary)
            }

            Text(TimeFormat.minutesSeconds(timer.remaining))
                .font(.system(size: 40, weight: .light, design: .rounded).monospacedDigit())

            Text(untilLine)
                .foregroundStyle(.secondary)

            HStack {
                Button(primaryTitle, action: primaryAction)
                    .keyboardShortcut(.defaultAction)
                Button("Restart", action: timer.restartBlock)
                    .disabled(timer.state == .idle || timer.state == .finished)
                Button(skipTitle, action: timer.skip)
                    .disabled(timer.state == .finished)
            }

            Divider()

            HStack {
                Text(doneLine)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Quit Tape") {
                    NSApp.terminate(nil)
                }
                .keyboardShortcut("q")
            }
        }
        .font(.system(size: 12))
        .padding(.top, 18)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .frame(width: 320, alignment: .leading)
    }

    private var header: String {
        timer.state == .finished ? "Session complete" : timer.currentBlock.kind.title
    }

    private var untilLine: String {
        if timer.state == .finished { return "Nice work." }
        let at = TimeFormat.clock(timer.nextBlockStart)
        guard let next = timer.nextBlock else { return "until done at \(at)" }
        return "until \(next.kind.title.lowercased()) at \(at)"
    }

    private var doneLine: String {
        timer.state == .finished ? "All rounds done" : "Done at \(TimeFormat.clock(timer.sessionEnd))"
    }

    private var primaryTitle: String {
        switch timer.state {
        case .idle: "Start"
        case .running: "Pause"
        case .paused: "Resume"
        case .finished: "New session"
        }
    }

    private func primaryAction() {
        switch timer.state {
        case .idle, .paused: timer.start()
        case .running: timer.pause()
        case .finished: timer.newSession()
        }
    }

    private var skipTitle: String {
        guard let next = timer.nextBlock else { return "Finish" }
        return "Skip to \(next.kind.title.lowercased())"
    }
}
