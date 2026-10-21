import SwiftUI

/// Divider, then a button on the left (Skip, or New session once the session
/// is complete) and "Done at ..." on the right.
struct FooterView<Leading: View>: View {
    let trailing: String
    @ViewBuilder let leading: Leading

    var body: some View {
        VStack(spacing: Theme.Sizes.dividerToFooter) {
            Rectangle()
                .fill(Theme.Colors.divider)
                .frame(height: 1)

            HStack {
                leading
                Spacer()
                Text(trailing)
                    .font(Theme.Fonts.secondary)
                    .foregroundStyle(Theme.Colors.secondary)
            }
            .frame(height: Theme.Sizes.footerButtonHeight)
        }
    }
}
