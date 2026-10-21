import SwiftUI

/// The sliders icon in the header. Settings arrive in Phase 6; for now it
/// only holds Quit, which used to sit in the footer and has no other home in
/// the design (there's no Dock icon to quit from).
struct SettingsMenu: View {
    var body: some View {
        Menu {
            Button("Quit Tape") {
                NSApp.terminate(nil)
            }
        } label: {
            Image(systemName: "slider.horizontal.3")
                .font(Theme.Fonts.settingsIcon)
                .foregroundStyle(Theme.Colors.secondary)
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
        .help("Settings")
    }
}
