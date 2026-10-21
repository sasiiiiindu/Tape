import SwiftUI

/// The big mm:ss and the "until break at ..." line under it. Once the session
/// is over it shows "Session complete" in the same space, so the panel keeps
/// its height.
struct CountdownView: View {
    let time: String
    let subline: String
    let isComplete: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Sizes.countdownToSubline) {
            ZStack(alignment: .leading) {
                // Always laid out, so the row is countdown-tall in every state.
                Text(time)
                    .font(Theme.Fonts.countdown)
                    .foregroundStyle(Theme.Colors.text)
                    .opacity(isComplete ? 0 : 1)
                if isComplete {
                    Text("Session complete")
                        .font(Theme.Fonts.complete)
                        .foregroundStyle(Theme.Colors.text)
                        .lineLimit(1)
                        .fixedSize()
                }
            }
            Text(subline)
                .font(Theme.Fonts.secondary)
                .foregroundStyle(Theme.Colors.secondary)
        }
    }
}
