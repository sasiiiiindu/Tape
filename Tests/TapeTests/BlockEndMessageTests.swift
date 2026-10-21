import Foundation
import Testing
@testable import Tape

struct BlockEndMessageTests {
    let plan = SessionPlan.standard
    let at = Date(timeIntervalSinceReferenceDate: 0)

    @Test func breakSaysWhenFocusIsBack() {
        let message = BlockEndMessage(state: .running, block: plan.blocks[1], plan: plan, nextStart: at)
        #expect(message.title == "Break")
        #expect(message.body == "Back to focus at \(TimeFormat.clock(at))")
    }

    @Test func longBreakSaysWhenFocusIsBack() {
        let plan = SessionPlan(focus: 25 * 60, breakLength: 5 * 60, rounds: 4, longBreakEvery: 2)
        let message = BlockEndMessage(state: .running, block: plan.blocks[3], plan: plan, nextStart: at)
        #expect(message.title == "Long break")
        #expect(message.body.hasPrefix("Back to focus at"))
    }

    @Test func focusSaysTheRound() {
        let message = BlockEndMessage(state: .running, block: plan.blocks[4], plan: plan, nextStart: at)
        #expect(message.title == "Focus")
        #expect(message.body == "Round 3 of 4")
    }

    @Test func waitingForStartSaysSo() {
        let focus = BlockEndMessage(state: .paused, block: plan.blocks[2], plan: plan, nextStart: at)
        #expect(focus.body == "Round 2 of 4. Press Start when you're ready.")
        let breakTime = BlockEndMessage(state: .paused, block: plan.blocks[1], plan: plan, nextStart: at)
        #expect(breakTime.body == "Press Start when you're ready.")
    }

    @Test func sessionComplete() {
        let message = BlockEndMessage(state: .finished, block: plan.blocks[6], plan: plan, nextStart: at)
        #expect(message.title == "Session complete")
        #expect(message.body == "4 rounds, 1h 40m of focus")
    }

    @Test func oneRoundIsSingular() {
        let plan = SessionPlan(focus: 25 * 60, breakLength: 5 * 60, rounds: 1)
        let message = BlockEndMessage(state: .finished, block: plan.blocks[0], plan: plan, nextStart: at)
        #expect(message.body == "1 round, 25m of focus")
    }
}
