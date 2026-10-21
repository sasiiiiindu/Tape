import SwiftUI

/// "Quit Tape" at the bottom of the settings page. Tape has no Dock icon or
/// app menu, so this and ⌘Q in the panel are the only ways to quit.
struct QuitButton: View {
    var body: some View {
        Button {
            NSApp.terminate(nil)
        } label: {
            SettingsRow(title: "Quit Tape") {
                Text("⌘Q")
                    .font(Theme.Fonts.row)
                    .foregroundStyle(Theme.Colors.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
    }
}
