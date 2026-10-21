import SwiftUI

/// Contents of the drop-down panel. Placeholder until the timer exists.
struct PanelView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Tape")
                .font(.system(size: 13, weight: .semibold))

            Text("The timer arrives in the next phase.")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)

            HStack {
                Spacer()
                Button("Quit Tape") {
                    NSApp.terminate(nil)
                }
                .keyboardShortcut("q")
            }
        }
        .padding(.top, 18)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .frame(width: 320, alignment: .leading)
    }
}
