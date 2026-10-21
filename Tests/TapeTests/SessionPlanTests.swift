import Testing
@testable import Tape

struct SessionPlanTests {
    let plan = SessionPlan.standard

    @Test func standardPlanIsFocusBreakAlternatingAndEndsOnFocus() {
        #expect(plan.blocks.map(\.kind) == [.focus, .break, .focus, .break, .focus, .break, .focus])
        #expect(plan.blocks.map(\.round) == [1, 1, 2, 2, 3, 3, 4])
        #expect(plan.rounds == 4)
    }

    @Test func standardPlanOffsetsAndTotal() {
        #expect(plan.blocks.map { $0.start / 60 } == [0, 25, 30, 55, 60, 85, 90])
        #expect(plan.blocks.map { $0.duration / 60 } == [25, 5, 25, 5, 25, 5, 25])
        #expect(plan.totalDuration == 115 * 60)
    }

    @Test func oneRoundIsASingleFocusBlock() {
        let single = SessionPlan(focus: 600, breakLength: 60, rounds: 1)
        #expect(single.blocks == [Block(kind: .focus, round: 1, start: 0, duration: 600)])
    }

    @Test func longBreakEverySecondRound() {
        let plan = SessionPlan(focus: 25 * 60, breakLength: 5 * 60, rounds: 4,
                               longBreak: 15 * 60, longBreakEvery: 2)
        #expect(plan.blocks.map(\.kind) == [.focus, .break, .focus, .longBreak, .focus, .break, .focus])
        #expect(plan.blocks.map(\.round) == [1, 1, 2, 2, 3, 3, 4])
        #expect(plan.blocks.map { $0.start / 60 } == [0, 25, 30, 55, 70, 95, 100])
        #expect(plan.totalDuration == 125 * 60)
        #expect(plan.hasLongBreak)
    }

    @Test func noLongBreakAfterTheLastRound() {
        let plan = SessionPlan(focus: 25 * 60, breakLength: 5 * 60, rounds: 4, longBreakEvery: 4)
        #expect(!plan.blocks.contains { $0.kind == .longBreak })
        #expect(!plan.hasLongBreak)
        #expect(plan == .standard)
    }

    @Test func longBreaksRepeat() {
        let plan = SessionPlan(focus: 25 * 60, breakLength: 5 * 60, rounds: 8, longBreakEvery: 3)
        let longAfter = plan.blocks.filter { $0.kind == .longBreak }.map(\.round)
        #expect(longAfter == [3, 6])
        #expect(plan.blocks.count == 15)
    }

    @Test func focusDuration() {
        #expect(plan.focusDuration == 100 * 60)
        let long = SessionPlan(focus: 50 * 60, breakLength: 10 * 60, rounds: 3, longBreakEvery: 2)
        #expect(long.focusDuration == 150 * 60)
    }

    @Test func positionFindsTheBlockAndTimeLeft() {
        #expect(plan.position(at: 0)! == (0, 25 * 60))
        #expect(plan.position(at: 24 * 60)! == (0, 60))
        #expect(plan.position(at: 25 * 60)! == (1, 5 * 60))   // a boundary belongs to the next block
        #expect(plan.position(at: 31 * 60)! == (2, 24 * 60))
        #expect(plan.position(at: 115 * 60) == nil)
    }

    @Test func timeFormat() {
        #expect(TimeFormat.minutesSeconds(1500) == "25:00")
        #expect(TimeFormat.minutesSeconds(1499.2) == "25:00")
        #expect(TimeFormat.minutesSeconds(59.01) == "01:00")
        #expect(TimeFormat.minutesSeconds(0) == "00:00")
        #expect(TimeFormat.minutesSeconds(-3) == "00:00")
    }

    @Test func hoursMinutes() {
        #expect(TimeFormat.hoursMinutes(115 * 60) == "1h 55m")
        #expect(TimeFormat.hoursMinutes(100 * 60) == "1h 40m")
        #expect(TimeFormat.hoursMinutes(45 * 60) == "45m")
        #expect(TimeFormat.hoursMinutes(120 * 60) == "2h")
        #expect(TimeFormat.hoursMinutes(0) == "0m")
        #expect(TimeFormat.hoursMinutes(935 * 60) == "15h 35m")
    }
}
