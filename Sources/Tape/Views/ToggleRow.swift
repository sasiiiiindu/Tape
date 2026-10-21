import SwiftUI

/// A settings row with an on/off switch.
struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    let accent: Color

    var body: some View {
        SettingsRow(title: title) {
            Toggle(title, isOn: $isOn)
                .toggleStyle(.switch)
                .controlSize(.mini)
                .tint(accent)
                .labelsHidden()
        }
    }
}
