import CoreGraphics
import Testing
@testable import Tape

struct MenuBarStripTests {
    let plan = SessionPlan.standard

    @Test func blocksAndGapsFillExactly40Points() {
        let strip = MenuBarStrip(plan: plan, current: 0, remaining: 25 * 60)
        let last = strip.segments.last!
        #expect(abs(last.x + last.width - 40) < 0.001)
        // 40 pt minus six 1.5 pt gaps is 31 pt for 115 minutes.
        #expect(abs(strip.segments[0].width - 31 * 25 / 115) < 0.001)
        #expect(abs(strip.segments[1].width - 31 * 5 / 115) < 0.001)
        #expect(abs(strip.segments[1].x - (strip.segments[0].width + 1.5)) < 0.001)
    }

    @Test func idleIsEmpty() {
        let strip = MenuBarStrip(plan: plan, current: 0, remaining: 25 * 60)
        #expect(strip.segments.allSatisfy { $0.filled == 0 })
    }

    @Test func finishedIsFull() {
        let strip = MenuBarStrip(plan: plan, current: plan.blocks.count - 1, remaining: 0)
        #expect(strip.segments.allSatisfy { $0.filled == ($0.width * 2).rounded() / 2 })
        #expect(strip.segments.allSatisfy { $0.filled > 0 })
    }

    @Test func earlierBlocksFullCurrentPartlyLaterEmpty() {
        // Focus 2, 10 of 25 minutes done.
        let strip = MenuBarStrip(plan: plan, current: 2, remaining: 15 * 60)
        let focus2 = strip.segments[2]
        #expect(strip.segments[0].filled > 0 && strip.segments[1].filled > 0)
        #expect(focus2.filled == (focus2.width * 0.4 * 2).rounded() / 2)
        #expect(strip.segments[3...].allSatisfy { $0.filled == 0 })
    }

    @Test func fillMovesInHalfPointSteps() {
        // A second apart is far less than half a point: the same picture.
        let a = MenuBarStrip(plan: plan, current: 0, remaining: 20 * 60)
        let b = MenuBarStrip(plan: plan, current: 0, remaining: 20 * 60 - 1)
        #expect(a == b)
        #expect(a.segments.allSatisfy { ($0.filled * 2).rounded() == $0.filled * 2 })
    }
}
