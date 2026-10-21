import Foundation

/// Sentences about where the session is, shared by the panel and VoiceOver.
enum SessionText {
    /// What comes next and when: "break at 7:50 PM", or "done at 8:50 PM"
    /// on the last block.
    static func upNext(_ next: Block?, at date: Date) -> String {
        let at = TimeFormat.clock(date)
        guard let next else { return "done at \(at)" }
        return "\(next.kind.title.lowercased()) at \(at)"
    }

    /// What VoiceOver reads for the tape and the menu bar item:
    /// "Focus, round 2 of 4, 18 minutes left, break at 7:50 PM".
    static func spoken(state: TimerState, block: Block, next: Block?, rounds: Int,
                       remaining: TimeInterval, nextStart: Date) -> String {
        if state == .finished {
            return "Session complete"
        }
        var parts = [block.kind.title, "round \(block.round) of \(rounds)", minutesLeft(remaining)]
        switch state {
        case .idle: parts.append("not started")
        case .paused: parts.append("paused")
        case .running, .finished: break
        }
        parts.append(upNext(next, at: nextStart))
        return parts.joined(separator: ", ")
    }

    /// The minutes the countdown shows: 18:30 is "18 minutes left".
    private static func minutesLeft(_ seconds: TimeInterval) -> String {
        let minutes = max(0, Int(seconds.rounded(.up))) / 60
        switch minutes {
        case 0: return "less than a minute left"
        case 1: return "1 minute left"
        default: return "\(minutes) minutes left"
        }
    }
}
