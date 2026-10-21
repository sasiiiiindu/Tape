import SwiftUI

/// A settings row with a value and up/down arrows, e.g. "Focus   25 min".
struct StepperRow: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    var step = 1
    /// How the value reads: 25 -> "25 min".
    let format: (Int) -> String

    var body: some View {
        SettingsRow(title: title) {
            Text(format(value))
                .font(Theme.Fonts.rowValue)
                .foregroundStyle(Theme.Colors.secondary)
                .frame(width: Theme.Settings.valueWidth, alignment: .trailing)
            Stepper(title, value: $value, in: range, step: step)
                .labelsHidden()
                .accessibilityValue(format(value))
        }
    }
}
