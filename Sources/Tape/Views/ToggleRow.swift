import SwiftUI

/// A settings row with an on/off switch, and an optional short note left of
/// the switch, e.g. "Couldn't turn on".
struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    let accent: Color
    var note: String? = nil
    /// Makes the note a button, e.g. to open System Settings.
    var onNote: (() -> Void)? = nil

    var body: some View {
        SettingsRow(title: title) {
            if let note {
                RowNote(text: note, action: onNote)
            }
            Toggle(title, isOn: $isOn)
                .toggleStyle(.switch)
                .controlSize(.mini)
                .tint(accent)
                .labelsHidden()
        }
    }
}
