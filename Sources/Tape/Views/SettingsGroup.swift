import SwiftUI

/// A rounded box of settings rows, like a group in System Settings. Put a
/// SettingsDivider between rows.
struct SettingsGroup<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(
            RoundedRectangle(cornerRadius: Theme.Settings.groupRadius)
                .fill(Theme.Colors.track)
        )
    }
}
