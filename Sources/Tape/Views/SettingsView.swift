import SwiftUI

/// The settings page: the session's shape with a preview of it, the timer's
/// switches and sound, launch at login and the shortcut, and Quit. Every
/// change is saved straight away.
///
/// Like TimerView, every row keeps its height in every state, because the
/// window's height for this page is measured once.
struct SettingsView: View {
    @ObservedObject var settings: SettingsStore
    @ObservedObject var notifier: Notifier
    @ObservedObject var loginItem: LoginItem
    @ObservedObject var shortcut: GlobalShortcut
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

            timerGroup
            systemGroup

            SettingsGroup {
                QuitButton()
            }
        }
        .padding(Theme.Sizes.panelPadding)
        .frame(width: Theme.Sizes.panelWidth, alignment: .leading)
        // Both may have been changed in System Settings since.
        .onAppear {
            notifier.refresh()
            loginItem.refresh()
        }
    }

    /// What the timer does: the switches and the block-end sound.
    private var timerGroup: some View {
        SettingsGroup {
            ToggleRow(title: "Auto-continue to next block", isOn: $settings.autoContinue, accent: accent)
            SettingsDivider()
            ToggleRow(title: "Show countdown in menu bar", isOn: $settings.showCountdownInMenuBar,
                      accent: accent)
            SettingsDivider()
            StepperRow(title: "Sound", value: soundIndex,
                       range: 0...(AlertSound.allCases.count - 1)) { AlertSound.allCases[$0].title }
            SettingsDivider()
            SettingsRow(title: "Notifications") {
                RowNote(text: notificationsNote, action: notificationsAction)
            }
        }
    }

    /// How Tape fits into macOS: launch at login and the shortcut.
    private var systemGroup: some View {
        SettingsGroup {
            ToggleRow(title: "Launch at login", isOn: launchAtLogin, accent: accent,
                      note: loginItem.note, onNote: loginNoteAction)
            SettingsDivider()
            // Usually because another app already uses the same keys. Kept
            // short: the row has little room beside the shortcut's name.
            ToggleRow(title: "Open Tape with \(GlobalShortcut.title)", isOn: $settings.globalShortcut,
                      accent: accent, note: shortcut.failed ? "In use" : nil)
        }
    }

    private static func minutes(_ value: Int) -> String { "\(value) min" }

    /// "Sound" steps through the choices, playing each one as it's picked.
    private var soundIndex: Binding<Int> {
        Binding {
            AlertSound.allCases.firstIndex(of: settings.alertSound) ?? 0
        } set: {
            settings.alertSound = AlertSound.allCases[$0]
            Chime.play(settings.alertSound)
        }
    }

    private var notificationsNote: String {
        switch notifier.status {
        case .denied: "Off"
        case .notDetermined: "Asks when you start"
        default: "On"
        }
    }

    /// "Off ›" opens Tape's page in System Settings, the only place to turn
    /// them back on.
    private var notificationsAction: (() -> Void)? {
        guard notifier.status == .denied else { return nil }
        return { notifier.openSystemSettings() }
    }

    private var launchAtLogin: Binding<Bool> {
        Binding { loginItem.isOn } set: { loginItem.set($0) }
    }

    /// "Allow in Settings" opens Login Items in System Settings.
    private var loginNoteAction: (() -> Void)? {
        guard loginItem.noteOpensSettings else { return nil }
        return { loginItem.openSystemSettings() }
    }

    /// "Long break every" steps through Off, 2, 3, 4 rounds by position.
    private var longBreakEveryIndex: Binding<Int> {
        Binding {
            SessionSettings.longBreakEveryOptions.firstIndex(of: settings.session.longBreakEvery) ?? 0
        } set: {
            settings.session.longBreakEvery = SessionSettings.longBreakEveryOptions[$0]
        }
    }
}
