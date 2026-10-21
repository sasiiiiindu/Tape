import Foundation

/// The ordered list of blocks in a session: Focus, Break, Focus, ... ending
/// on the last Focus.
struct SessionPlan: Equatable {
    let blocks: [Block]
    let rounds: Int

    /// 25 min focus, 5 min break, 4 rounds. Phase 6 replaces this with the
    /// user's settings by calling `init(focus:breakLength:rounds:)`.
    static let standard = SessionPlan(focus: 25 * 60, breakLength: 5 * 60, rounds: 4)

    init(focus: TimeInterval, breakLength: TimeInterval, rounds: Int) {
        precondition(rounds >= 1 && focus > 0 && breakLength > 0)
        var blocks: [Block] = []
        var offset: TimeInterval = 0
        for round in 1...rounds {
            blocks.append(Block(kind: .focus, round: round, start: offset, duration: focus))
            offset += focus
            if round < rounds {
                blocks.append(Block(kind: .break, round: round, start: offset, duration: breakLength))
                offset += breakLength
            }
        }
        self.blocks = blocks
        self.rounds = rounds
    }

    var totalDuration: TimeInterval { blocks.last?.end ?? 0 }

    /// The block containing `offset` seconds into the session, and the seconds
    /// left in it. Nil once the session is over.
    func position(at offset: TimeInterval) -> (index: Int, remaining: TimeInterval)? {
        guard let index = blocks.firstIndex(where: { offset < $0.end }) else { return nil }
        let block = blocks[index]
        return (index, block.end - max(offset, block.start))
    }
}
