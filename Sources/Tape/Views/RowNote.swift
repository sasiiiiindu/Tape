import SwiftUI

/// A short note in a settings row, such as "Allow in Settings". With an
/// action it's a button and reads as a link.
struct RowNote: View {
    let text: String
    let action: (() -> Void)?

    var body: some View {
        if let action {
            Button(action: action) {
                label(text + " ›")
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel(text)
            .accessibilityHint("Opens System Settings")
        } else {
            label(text)
        }
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(Theme.Fonts.secondary)
            .foregroundStyle(Theme.Colors.secondary)
            .lineLimit(1)
    }
}
