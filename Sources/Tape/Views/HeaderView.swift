import SwiftUI

/// Top row: coloured dot and mode name on the left, round and the settings
/// button on the right.
struct HeaderView: View {
    let title: String
    let round: String
    let accent: Color
    let onSettings: () -> Void

    var body: some View {
        HStack(spacing: Theme.Sizes.modeDotSpacing) {
            Circle()
                .fill(accent)
                .frame(width: Theme.Sizes.modeDot, height: Theme.Sizes.modeDot)
                .animation(Theme.Motion.accentChange, value: accent)
            Text(title)
                .font(Theme.Fonts.header)
                .foregroundStyle(Theme.Colors.text)

            Spacer()

            HStack(spacing: Theme.Sizes.settingsSpacing) {
                Text(round)
                    .font(Theme.Fonts.secondary)
                    .foregroundStyle(Theme.Colors.secondary)
                SettingsButton(action: onSettings)
            }
        }
    }
}
