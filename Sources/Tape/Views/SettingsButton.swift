import SwiftUI

/// The sliders icon in the header: slides the settings page in.
struct SettingsButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "slider.horizontal.3")
                .font(Theme.Fonts.settingsIcon)
                .foregroundStyle(Theme.Colors.secondary)
                .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
        .help("Settings")
        .accessibilityLabel("Settings")
    }
}
