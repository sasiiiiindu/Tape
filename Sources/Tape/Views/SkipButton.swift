import SwiftUI

/// "Skip to break" / "Skip to focus" / "Finish" in the footer.
struct SkipButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Fonts.button)
                .foregroundStyle(Theme.Colors.text)
                .padding(.horizontal, Theme.Sizes.footerButtonPadding)
                .frame(height: Theme.Sizes.footerButtonHeight)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Sizes.footerButtonRadius)
                        .fill(Theme.Colors.track)
                )
                .contentShape(RoundedRectangle(cornerRadius: Theme.Sizes.footerButtonRadius))
        }
        .buttonStyle(PressableButtonStyle())
    }
}
