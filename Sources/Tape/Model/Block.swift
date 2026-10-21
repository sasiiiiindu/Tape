import Foundation

/// One stretch of the session. Times are seconds measured from the start of
/// the session, not clock times, so a plan never changes when you pause.
struct Block: Codable, Equatable {
    let kind: BlockKind
    /// 1-based. A break shares the round of the focus block before it.
    let round: Int
    /// Seconds from the start of the session to the start of this block.
    let start: TimeInterval
    let duration: TimeInterval

    var end: TimeInterval { start + duration }
}
