import CoreGraphics
import Foundation

/// Where each block sits in the 40 pt menu bar strip and how much of it is
/// filled. Widths follow the blocks' durations. No drawing here, so it can be
/// tested; MenuBarStripImage draws it.
///
/// Finished blocks are full, the current block fills left to right, blocks
/// still ahead are empty. That covers every timer state: idle is block 0 with
/// nothing done, finished is the last block with nothing left.
struct MenuBarStrip: Equatable {
    struct Segment: Equatable {
        let kind: BlockKind
        let x: CGFloat
        let width: CGFloat
        /// Points filled from the left, rounded to half a point (one pixel on
        /// a Retina screen) so the strip only redraws when the fill visibly grows.
        let filled: CGFloat
    }

    let segments: [Segment]

    /// `remaining` is the time left in block `current`.
    init(plan: SessionPlan, current: Int, remaining: TimeInterval) {
        let gaps = Theme.MenuBar.gap * CGFloat(plan.blocks.count - 1)
        let pointsPerSecond = (Theme.MenuBar.stripWidth - gaps) / plan.totalDuration

        var x: CGFloat = 0
        var segments: [Segment] = []
        for (index, block) in plan.blocks.enumerated() {
            let width = block.duration * pointsPerSecond
            let done: Double
            if index < current {
                done = 1
            } else if index == current {
                done = min(max(1 - remaining / block.duration, 0), 1)
            } else {
                done = 0
            }
            segments.append(Segment(kind: block.kind, x: x, width: width,
                                    filled: (width * done * 2).rounded() / 2))
            x += width + Theme.MenuBar.gap
        }
        self.segments = segments
    }
}
