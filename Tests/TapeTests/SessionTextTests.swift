import Foundation
import Testing
@testable import Tape

/// The sentence VoiceOver reads for the tape and the menu bar item.
struct SessionTextTests {
    let plan = SessionPlan.standard
    let at = Calendar.current.date(bySettingHour: 19, minute: 50, second: 0, of: Date())!
    var clock: String { TimeFormat.clock(at) }

    func spoken(_ state: TimerState, block: Int, remaining: TimeInterval) -> String {
        let next = block + 1 < plan.blocks.count ? plan.blocks[block + 1] : nil
        return SessionText.spoken(state: state, block: plan.blocks[block], next: next, rounds: plan.rounds,
                                  remaining: remaining, nextStart: at)
    }

    @Test func readsLikeTheSpec() {
        #expect(spoken(.running, block: 2, remaining: 18 * 60)
                == "Focus, round 2 of 4, 18 minutes left, break at \(clock)")
    }

    @Test func minutesMatchTheCountdown() {
        // The countdown shows 18:30, so 18 minutes.
        #expect(spoken(.running, block: 0, remaining: 18 * 60 + 30).contains("18 minutes left"))
        #expect(spoken(.running, block: 0, remaining: 60).contains("1 minute left"))
        #expect(spoken(.running, block: 0, remaining: 40).contains("less than a minute left"))
    }

    @Test func saysWhatComesNext() {
        #expect(spoken(.running, block: 1, remaining: 4 * 60)
                == "Break, round 1 of 4, 4 minutes left, focus at \(clock)")
        #expect(spoken(.running, block: 6, remaining: 10 * 60)
                == "Focus, round 4 of 4, 10 minutes left, done at \(clock)")
        let long = SessionPlan(focus: 1500, breakLength: 300, rounds: 4, longBreakEvery: 2)
        #expect(SessionText.spoken(state: .running, block: long.blocks[2], next: long.blocks[3], rounds: 4,
                                   remaining: 60, nextStart: at).hasSuffix("long break at \(clock)"))
    }

    @Test func saysWhenPausedOrNotStarted() {
        #expect(spoken(.paused, block: 0, remaining: 600).contains("10 minutes left, paused, break"))
        #expect(spoken(.idle, block: 0, remaining: 1500).contains("25 minutes left, not started, break"))
        #expect(spoken(.finished, block: 6, remaining: 0) == "Session complete")
    }
}
