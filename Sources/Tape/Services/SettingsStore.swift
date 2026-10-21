import Combine
import Foundation

/// The user's settings, saved in UserDefaults. Every change is saved at once.
///
/// One shared object rather than @AppStorage in the views, because the timer
/// and the menu bar item need the values too, and they aren't views.
@MainActor
final class SettingsStore: ObservableObject {
    @Published var session: SessionSettings {
        didSet { save(session) }
    }
    /// When a block ends, start the next one straight away.
    @Published var autoContinue: Bool {
        didSet { defaults.set(autoContinue, forKey: Key.autoContinue) }
    }
    @Published var showCountdownInMenuBar: Bool {
        didSet { defaults.set(showCountdownInMenuBar, forKey: Key.showCountdown) }
    }

    private let defaults: UserDefaults

    private enum Key {
        static let focus = "focusMinutes"
        static let breakLength = "breakMinutes"
        static let rounds = "rounds"
        static let longBreak = "longBreakMinutes"
        static let longBreakEvery = "longBreakEvery"
        static let autoContinue = "autoContinue"
        static let showCountdown = "showCountdownInMenuBar"
    }

    /// Tests pass their own UserDefaults so they never touch the app's.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let standard = SessionSettings()
        defaults.register(defaults: [
            Key.focus: standard.focusMinutes,
            Key.breakLength: standard.breakMinutes,
            Key.rounds: standard.rounds,
            Key.longBreak: standard.longBreakMinutes,
            Key.longBreakEvery: standard.longBreakEvery,
            Key.autoContinue: true,
            Key.showCountdown: true,
        ])
        session = SessionSettings(
            focusMinutes: defaults.integer(forKey: Key.focus),
            breakMinutes: defaults.integer(forKey: Key.breakLength),
            rounds: defaults.integer(forKey: Key.rounds),
            longBreakMinutes: defaults.integer(forKey: Key.longBreak),
            longBreakEvery: defaults.integer(forKey: Key.longBreakEvery)
        ).clamped()
        autoContinue = defaults.bool(forKey: Key.autoContinue)
        showCountdownInMenuBar = defaults.bool(forKey: Key.showCountdown)
    }

    private func save(_ session: SessionSettings) {
        defaults.set(session.focusMinutes, forKey: Key.focus)
        defaults.set(session.breakMinutes, forKey: Key.breakLength)
        defaults.set(session.rounds, forKey: Key.rounds)
        defaults.set(session.longBreakMinutes, forKey: Key.longBreak)
        defaults.set(session.longBreakEvery, forKey: Key.longBreakEvery)
    }
}
