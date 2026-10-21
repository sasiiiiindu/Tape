import SwiftUI

/// One row of a SettingsGroup: the name on the left, anything on the right.
/// Dims its name and value when disabled.
struct SettingsRow<Trailing: View>: View {
    let title: String
    @ViewBuilder let trailing: Trailing
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        HStack(spacing: Theme.Settings.valueToControl) {
            Text(title)
                .font(Theme.Fonts.row)
                .foregroundStyle(Theme.Colors.text)
            Spacer(minLength: 0)
            trailing
        }
        .opacity(isEnabled ? 1 : Theme.Sizes.disabledOpacity)
        .padding(.horizontal, Theme.Settings.rowPadding)
        .frame(height: Theme.Settings.rowHeight)
    }
}
