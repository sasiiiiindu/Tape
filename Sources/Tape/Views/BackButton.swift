import SwiftUI

/// The chevron at the top left of the settings page: back to the timer.
struct BackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(Theme.Fonts.backIcon)
                .foregroundStyle(Theme.Colors.text)
                .frame(width: Theme.Settings.backButton, height: Theme.Settings.backButton)
                .background(Circle().fill(Theme.Colors.track))
                .contentShape(Circle())
        }
        .buttonStyle(PressableButtonStyle())
        .help("Back")
        .accessibilityLabel("Back")
    }
}
