import SwiftUI

/// The session around the needle drawn as one picture: a tick for every
/// minute, a band under each block and a label above it. TapeView slides it
/// sideways.
///
/// Drawn with a single Canvas rather than a view per tick. It's Equatable, so
/// SwiftUI only redraws it when what it shows changes (a tick passes the
/// needle, the block changes, or light/dark mode), about once a minute.
/// Sliding an already drawn picture costs almost nothing.
///
/// Only the part of the session near the needle is drawn (see
/// Theme.Tape.drawnBehind), and it moves along with each redraw, so a
/// 16-hour session is as cheap to draw as a 2-hour one.
struct TapeStrip: View, Equatable {
    let plan: SessionPlan
    /// The block under the needle; nil once the session is over.
    let current: Int?
    /// Ticks before this many session seconds are drawn as past. Always a
    /// whole minute, just ahead of the needle.
    let pastBefore: TimeInterval
    /// Not read directly: the colours follow it on their own. Kept here so
    /// switching light/dark mode counts as a change and redraws the strip.
    let colorScheme: ColorScheme

    /// Session seconds at the strip's left edge.
    private var drawnFrom: TimeInterval { pastBefore - Theme.Tape.drawnBehind }
    private var drawnTo: TimeInterval { pastBefore + Theme.Tape.drawnAhead }

    /// Where `seconds` into the session sits on the strip.
    func x(at seconds: TimeInterval) -> CGFloat {
        (seconds - drawnFrom) / 60 * Theme.Tape.minuteWidth
    }

    var body: some View {
        Canvas { context, _ in
            for (index, block) in plan.blocks.enumerated()
            where block.end >= drawnFrom && block.start <= drawnTo {
                drawBand(block, index: index, in: context)
                drawTicks(block, in: context)
                drawLabel(block, index: index, in: context)
            }
            // Closing boundary at the very end of the session.
            drawTick(at: plan.totalDuration, height: Theme.Tape.boundaryTickHeight,
                     color: Theme.Colors.text, opacity: Theme.Tape.boundaryTickOpacity, in: context)
        }
        .frame(width: x(at: drawnTo), height: Theme.Sizes.tapeHeight)
    }

    private func drawBand(_ block: Block, index: Int, in context: GraphicsContext) {
        let minX = x(at: block.start) + Theme.Tape.bandInset
        let maxX = x(at: block.end) - Theme.Tape.bandInset
        let rect = CGRect(x: minX, y: Theme.Tape.bandTop, width: maxX - minX, height: Theme.Tape.bandHeight)
        let opacity: Double
        switch current {
        case index?: opacity = Theme.Tape.currentBandOpacity
        case let current? where index > current: opacity = Theme.Tape.futureBandOpacity
        default: opacity = Theme.Tape.pastBandOpacity   // includes "session over"
        }
        context.fill(
            Path(roundedRect: rect, cornerRadius: Theme.Tape.bandHeight / 2),
            with: .color(Theme.Colors.accent(for: block.kind).opacity(opacity))
        )
    }

    /// One tick per minute of the block, skipping those outside the drawn
    /// part. The first is the block boundary.
    private func drawTicks(_ block: Block, in context: GraphicsContext) {
        let blockColor = Theme.Colors.accent(for: block.kind)
        for (minute, seconds) in stride(from: block.start, to: block.end, by: 60).enumerated()
        where seconds >= drawnFrom && seconds <= drawnTo {
            if minute == 0 {
                drawTick(at: seconds, height: Theme.Tape.boundaryTickHeight,
                         color: Theme.Colors.text, opacity: Theme.Tape.boundaryTickOpacity, in: context)
            } else if minute % 5 == 0 {
                drawTick(at: seconds, height: Theme.Tape.fiveMinuteTickHeight,
                         color: blockColor, opacity: Theme.Tape.fiveMinuteTickOpacity, in: context)
            } else {
                drawTick(at: seconds, height: Theme.Tape.minuteTickHeight,
                         color: blockColor, opacity: Theme.Tape.minuteTickOpacity, in: context)
            }
        }
    }

    /// `opacity` is used for ticks still ahead; ticks already passed are dimmed.
    private func drawTick(at seconds: TimeInterval, height: CGFloat, color: Color,
                          opacity: Double, in context: GraphicsContext) {
        let width = Theme.Tape.tickWidth
        let rect = CGRect(x: x(at: seconds) - width / 2, y: Theme.Tape.tickBaseline - height,
                          width: width, height: height)
        let shown = seconds < pastBefore ? Theme.Tape.pastTickOpacity : opacity
        context.fill(Path(roundedRect: rect, cornerRadius: width / 2), with: .color(color.opacity(shown)))
    }

    /// Draws the longest label that fits before the next block's label, or
    /// none, so short blocks don't run into their neighbours. The last block
    /// has the empty space after the session to spare.
    private func drawLabel(_ block: Block, index: Int, in context: GraphicsContext) {
        let isLast = index == plan.blocks.count - 1
        let room = isLast ? .infinity : block.duration / 60 * Theme.Tape.minuteWidth - Theme.Tape.labelGap
        for title in Self.labels(for: block) {
            var label = context.resolve(Text(title).font(Theme.Fonts.tapeLabel))
            guard label.measure(in: CGSize(width: CGFloat.infinity, height: .infinity)).width <= room else {
                continue
            }
            label.shading = .color(index == current ? Theme.Colors.text : Theme.Colors.secondary)
            context.draw(
                label,
                at: CGPoint(x: x(at: block.start) + Theme.Tape.labelInset, y: Theme.Tape.labelCenterY),
                anchor: .leading
            )
            return
        }
    }

    /// Longest first.
    private static func labels(for block: Block) -> [String] {
        switch block.kind {
        case .focus: ["Focus \(block.round)", "\(block.round)"]
        case .break: ["Break"]
        case .longBreak: ["Long break", "Long"]
        }
    }
}
