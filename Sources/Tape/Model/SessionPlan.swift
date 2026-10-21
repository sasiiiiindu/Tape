import Foundation

/// The ordered list of blocks in a session: Focus, Break, Focus, ... ending
/// on the last Focus. If long breaks are on, every Nth break is a long one.
struct SessionPlan: Codable, Equatable {
    let blocks: [Block]
    let rounds: Int

    /// 25 min focus, 5 min break, 4 rounds, no long breaks: the default
    /// settings. Settings build the real plan with `init(focus:...)`.
    static let standard = SessionPlan(focus: 25 * 60, breakLength: 5 * 60, rounds: 4)

    /// `longBreakEvery` nil means no long breaks. A long break never comes
    /// after the last round, since the session ends on its last Focus.
    init(focus: TimeInterval, breakLength: TimeInterval, rounds: Int,
         longBreak: TimeInterval = 15 * 60, longBreakEvery: Int? = nil) {
        precondition(rounds >= 1 && focus > 0 && breakLength > 0 && longBreak > 0)
        precondition(longBreakEvery.map { $0 >= 1 } ?? true)
        var blocks: [Block] = []
        var offset: TimeInterval = 0
        for round in 1...rounds {
            blocks.append(Block(kind: .focus, round: round, start: offset, duration: focus))
            offset += focus
            guard round < rounds else { break }
            if let every = longBreakEvery, round % every == 0 {
                blocks.append(Block(kind: .longBreak, round: round, start: offset, duration: longBreak))
                offset += longBreak
            } else {
                blocks.append(Block(kind: .break, round: round, start: offset, duration: breakLength))
                offset += breakLength
            }
        }
        self.blocks = blocks
        self.rounds = rounds
    }

    var totalDuration: TimeInterval { blocks.last?.end ?? 0 }

    /// Time spent in Focus blocks, for the Settings preview.
    var focusDuration: TimeInterval {
        blocks.filter { $0.kind == .focus }.reduce(0) { $0 + $1.duration }
    }

    /// False for a plan that couldn't have been made by `init`, such as a
    /// saved one that was edited by hand: no blocks, gaps, or empty blocks.
    var isValid: Bool {
        guard !blocks.isEmpty, rounds >= 1 else { return false }
        var offset: TimeInterval = 0
        for block in blocks {
            guard block.start == offset, block.duration > 0 else { return false }
            offset = block.end
        }
        return true
    }

    var hasLongBreak: Bool { blocks.contains { $0.kind == .longBreak } }

    /// The block containing `offset` seconds into the session, and the seconds
    /// left in it. Nil once the session is over.
    func position(at offset: TimeInterval) -> (index: Int, remaining: TimeInterval)? {
        guard let index = blocks.firstIndex(where: { offset < $0.end }) else { return nil }
        let block = blocks[index]
        return (index, block.end - max(offset, block.start))
    }
}
