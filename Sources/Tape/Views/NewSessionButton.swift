import SwiftUI

/// Takes Skip's place in the footer once the session is complete. Accent
/// fill because it's now the main action.
struct NewSessionButton: View {
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("New session")
                .font(Theme.Fonts.button)
                .foregroundStyle(Theme.Colors.onAccent)
                .padding(.horizontal, Theme.Sizes.footerButtonPadding)
                .frame(height: Theme.Sizes.footerButtonHeight)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Sizes.footerButtonRadius)
                        .fill(accent)
                )
                .contentShape(RoundedRectangle(cornerRadius: Theme.Sizes.footerButtonRadius))
        }
        .buttonStyle(PressableButtonStyle())
        .keyboardShortcut(.defaultAction)
    }
}
