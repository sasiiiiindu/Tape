import SwiftUI

/// The big round accent button: play when idle or paused, pause when running.
struct PlayPauseButton: View {
    let isRunning: Bool
    /// "Start" or "Resume", for VoiceOver and the hover tooltip.
    let playLabel: String
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isRunning ? "pause.fill" : "play.fill")
                .font(Theme.Fonts.playIcon)
                .foregroundStyle(Theme.Colors.onAccent)
                // The play triangle looks off-centre to the left when
                // centred mathematically; nudge it right.
                .offset(x: isRunning ? 0 : 1)
                .frame(width: Theme.Sizes.playButton, height: Theme.Sizes.playButton)
                .background(
                    Circle()
                        .fill(accent)
                        .animation(Theme.Motion.accentChange, value: accent)
                )
                .contentShape(Circle())
        }
        .buttonStyle(PressableButtonStyle())
        .keyboardShortcut(.defaultAction)
        .help("\(isRunning ? "Pause" : playLabel) (Space)")
        .accessibilityLabel(isRunning ? "Pause" : playLabel)
    }
}
