import SwiftUI

/// Small round button left of play/pause: back to the start of this block.
struct RestartButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.counterclockwise")
                .font(Theme.Fonts.restartIcon)
                .foregroundStyle(Theme.Colors.text)
                .frame(width: Theme.Sizes.restartButton, height: Theme.Sizes.restartButton)
                .background(Circle().fill(Theme.Colors.track))
                .contentShape(Circle())
        }
        .buttonStyle(PressableButtonStyle())
        .help("Restart this block")
        .accessibilityLabel("Restart")
    }
}
