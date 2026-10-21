import SwiftUI

/// Dashed stand-in for the tape, at its final size. Replaced in Phase 4.
struct TapePlaceholder: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .strokeBorder(Theme.Colors.placeholder, style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
            .overlay(
                Text("Tape")
                    .font(Theme.Fonts.placeholder)
                    .foregroundStyle(Theme.Colors.secondary)
            )
            .frame(width: Theme.Sizes.tapeWidth, height: Theme.Sizes.tapeHeight)
    }
}
