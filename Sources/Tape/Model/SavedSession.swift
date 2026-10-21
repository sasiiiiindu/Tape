import Foundation

/// A session in progress, saved so it can come back after Tape quits (or
/// the Mac restarts). It comes back paused where it was, unless it's too old.
struct SavedSession: Codable, Equatable {
    /// The session's own plan, not the current settings: settings changed
    /// during a session belong to the next one.
    let plan: SessionPlan
    let blockIndex: Int
    /// Session seconds left in the block.
    let remaining: TimeInterval
    let savedAt: Date

    /// After this long a saved session is dropped and Tape starts fresh.
    static let maxAge: TimeInterval = 12 * 60 * 60

    /// Whether to bring it back at `now`: recent enough, and makes sense.
    func isRestorable(at now: Date) -> Bool {
        guard now.timeIntervalSince(savedAt) < Self.maxAge,
              plan.isValid,
              plan.blocks.indices.contains(blockIndex) else { return false }
        return remaining > 0 && remaining <= plan.blocks[blockIndex].duration
    }
}
