import Foundation

/// The shape of a session as set in Settings, in whole minutes. A plain
/// value: SettingsStore saves it, `plan` turns it into blocks.
struct SessionSettings: Equatable {
    var focusMinutes = 25
    var breakMinutes = 5
    var rounds = 4
    var longBreakMinutes = 15
    /// Rounds between long breaks. 0 means no long breaks (the default).
    var longBreakEvery = 0

    static let focusRange = 5...90
    static let focusStep = 5
    static let breakRange = 1...30
    static let roundsRange = 1...8
    static let longBreakRange = 5...45
    static let longBreakStep = 5
    /// The choices for "Long break every", in stepper order. 0 is Off.
    static let longBreakEveryOptions = [0, 2, 3, 4]

    var plan: SessionPlan {
        SessionPlan(
            focus: TimeInterval(focusMinutes * 60),
            breakLength: TimeInterval(breakMinutes * 60),
            rounds: rounds,
            longBreak: TimeInterval(longBreakMinutes * 60),
            longBreakEvery: longBreakEvery == 0 ? nil : longBreakEvery
        )
    }

    /// Every value pulled back into its allowed range, in case the saved
    /// settings were edited by hand or came from a different version.
    func clamped() -> SessionSettings {
        var copy = self
        copy.focusMinutes = focusMinutes.clamped(to: Self.focusRange)
        copy.breakMinutes = breakMinutes.clamped(to: Self.breakRange)
        copy.rounds = rounds.clamped(to: Self.roundsRange)
        copy.longBreakMinutes = longBreakMinutes.clamped(to: Self.longBreakRange)
        if !Self.longBreakEveryOptions.contains(longBreakEvery) {
            copy.longBreakEvery = 0
        }
        return copy
    }
}

private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
