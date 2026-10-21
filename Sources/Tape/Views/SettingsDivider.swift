import SwiftUI

/// The thin line between two rows of a SettingsGroup.
struct SettingsDivider: View {
    var body: some View {
        Rectangle()
            .fill(Theme.Colors.divider)
            .frame(height: 1)
            .padding(.leading, Theme.Settings.rowPadding)
    }
}
