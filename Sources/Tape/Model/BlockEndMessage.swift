import Foundation

/// What the notification says when a block ends, worked out from where the
/// timer landed: "Break" / "Back to focus at 7:55 PM", "Focus" /
/// "Round 3 of 4", or "Session complete".
struct BlockEndMessage: Equatable {
    let title: String
    let body: String

    /// `block` is the block the timer is now in, and `nextStart` the clock
    /// time the one after it starts.
    init(state: TimerState, block: Block, plan: SessionPlan, nextStart: Date) {
        if state == .finished {
            title = "Session complete"
            let rounds = plan.rounds == 1 ? "1 round" : "\(plan.rounds) rounds"
            body = "\(rounds), \(TimeFormat.hoursMinutes(plan.focusDuration)) of focus"
            return
        }

        // With auto-continue off, the new block waits for Start.
        let waiting = state != .running
        title = block.kind.title
        switch block.kind {
        case .focus:
            let round = "Round \(block.round) of \(plan.rounds)"
            body = waiting ? "\(round). Press Start when you're ready." : round
        case .break, .longBreak:
            body = waiting ? "Press Start when you're ready." : "Back to focus at \(TimeFormat.clock(nextStart))"
        }
    }
}
