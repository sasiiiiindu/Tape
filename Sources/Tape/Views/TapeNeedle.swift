import SwiftUI

/// The fixed "now" marker: a thin line with a dot on top.
struct TapeNeedle: View {
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: Theme.Tape.needleWidth / 2)
                .frame(width: Theme.Tape.needleWidth, height: Theme.Tape.needleHeight)
                // The line starts at the dot's centre.
                .padding(.top, Theme.Tape.needleDot / 2)
            Circle()
                .frame(width: Theme.Tape.needleDot, height: Theme.Tape.needleDot)
        }
        .foregroundStyle(Theme.Colors.text)
    }
}
