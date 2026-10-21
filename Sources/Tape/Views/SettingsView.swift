import SwiftUI

/// The settings page: the session's shape with a preview of it, two
/// switches, and Quit. Every change is saved straight away.
///
/// Like TimerView, every row keeps its height in every state, because the
/// window's height for this page is measured once.
struct SettingsView: View {
    @ObservedObject var settings: SettingsStore
    /// A session has started, so changes to its shape wait for the next one.
    let sessionInProgress: Bool
    /// The current mode's colour, for the switches.
    let accent: Color
    let onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Settings.sectionSpacing) {
            HStack(spacing: Theme.Sizes.modeDotSpacing) {
                BackButton(action: onBack)
                Text("Settings")
                    .font(Theme.Fonts.header)
                    .foregroundStyle(Theme.Colors.text)
            }

            SettingsGroup {
                StepperRow(title: "Focus", value: $settings.session.focusMinutes,
                           range: SessionSettings.focusRange, step: SessionSettings.focusStep,
                           format: Self.minutes)
                SettingsDivider()
                StepperRow(title: "Break", value: $settings.session.breakMinutes,
                           range: SessionSettings.breakRange, format: Self.minutes)
                SettingsDivider()
                StepperRow(title: "Rounds", value: $settings.session.rounds,
                           range: SessionSettings.roundsRange) { "\($0)" }
                SettingsDivider()
                StepperRow(title: "Long break", value: $settings.session.longBreakMinutes,
                           range: SessionSettings.longBreakRange, step: SessionSettings.longBreakStep,
                           format: Self.minutes)
                    // Dimmed when the planned session has no long break in it.
                    .disabled(!settings.session.plan.hasLongBreak)
                SettingsDivider()
                StepperRow(title: "Long break every", value: longBreakEveryIndex,
                           range: 0...(SessionSettings.longBreakEveryOptions.count - 1)) {
                    let rounds = SessionSettings.longBreakEveryOptions[$0]
                    return rounds == 0 ? "Off" : "\(rounds) rounds"
                }
            }

            SessionPreview(plan: settings.session.plan, sessionInProgress: sessionInProgress)

            SettingsGroup {
                ToggleRow(title: "Auto-continue to next block", isOn: $settings.autoContinue, accent: accent)
                SettingsDivider()
                ToggleRow(title: "Show countdown in menu bar", isOn: $settings.showCountdownInMenuBar,
                          accent: accent)
            }

            SettingsGroup {
                QuitButton()
            }
        }
        .padding(Theme.Sizes.panelPadding)
        .frame(width: Theme.Sizes.panelWidth, alignment: .leading)
    }

    private static func minutes(_ value: Int) -> String { "\(value) min" }

    /// "Long break every" steps through Off, 2, 3, 4 rounds by position.
    private var longBreakEveryIndex: Binding<Int> {
        Binding {
            SessionSettings.longBreakEveryOptions.firstIndex(of: settings.session.longBreakEvery) ?? 0
        } set: {
            settings.session.longBreakEvery = SessionSettings.longBreakEveryOptions[$0]
        }
    }
}
