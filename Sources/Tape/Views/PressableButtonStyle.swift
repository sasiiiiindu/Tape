import SwiftUI

/// Draws the button exactly as its label looks, dimmed while it's held down
/// or disabled. Our buttons are custom shapes, so the system styles don't fit.
struct PressableButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(opacity(pressed: configuration.isPressed))
    }

    private func opacity(pressed: Bool) -> Double {
        if !isEnabled { return Theme.Sizes.disabledOpacity }
        return pressed ? Theme.Sizes.pressedOpacity : 1
    }
}
