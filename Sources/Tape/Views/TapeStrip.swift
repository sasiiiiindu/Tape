import SwiftUI

/// The whole session drawn as one picture: a tick for every minute, a band
/// under each block and a label above it. TapeView slides it sideways.
///
/// Drawn with a single Canvas rather than a view per tick. It's Equatable, so
/// SwiftUI only redraws it when what it shows changes (a tick passes the
/// needle, or the block changes), about once a minute. Sliding an already
/// drawn picture costs almost nothing.
struct TapeStrip: View, Equatable {
    let plan: SessionPlan
    /// The block under the needle; nil once the session is over.
    let current: Int?
    /// Ticks before this many session seconds are drawn as past.
    let pastBefore: TimeInterval

    /// Where `seconds` into the session sits on the strip.
    static func x(at seconds: TimeInterval) -> CGFloat {
        Theme.Tape.stripPadding + seconds / 60 * Theme.Tape.minuteWidth
    }

    var body: some View {
        Canvas { context, _ in
            for (index, block) in plan.blocks.enumerated() {
                drawBand(block, index: index, in: context)
                drawTicks(block, in: context)
                drawLabel(block, index: index, in: context)
            }
            // Closing boundary at the very end of the session.
            drawTick(at: plan.totalDuration, height: Theme.Tape.boundaryTickHeight,
                     color: Theme.Colors.text, opacity: Theme.Tape.boundaryTickOpacity, in: context)
        }
        .frame(width: Self.x(at: plan.totalDuration) + Theme.Tape.stripPadding,
               height: Theme.Sizes.tapeHeight)
    }

    private func drawBand(_ block: Block, index: Int, in context: GraphicsContext) {
        let minX = Self.x(at: block.start) + Theme.Tape.bandInset
        let maxX = Self.x(at: block.end) - Theme.Tape.bandInset
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

    /// One tick per minute of the block. The first is the block boundary.
    private func drawTicks(_ block: Block, in context: GraphicsContext) {
        let blockColor = Theme.Colors.accent(for: block.kind)
        for (minute, seconds) in stride(from: block.start, to: block.end, by: 60).enumerated() {
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
        let rect = CGRect(x: Self.x(at: seconds) - width / 2, y: Theme.Tape.tickBaseline - height,
                          width: width, height: height)
        let shown = seconds < pastBefore ? Theme.Tape.pastTickOpacity : opacity
        context.fill(Path(roundedRect: rect, cornerRadius: width / 2), with: .color(color.opacity(shown)))
    }

    private func drawLabel(_ block: Block, index: Int, in context: GraphicsContext) {
        let title = block.kind == .focus ? "Focus \(block.round)" : block.kind.title
        var label = context.resolve(Text(title).font(Theme.Fonts.tapeLabel))
        label.shading = .color(index == current ? Theme.Colors.text : Theme.Colors.secondary)
        context.draw(
            label,
            at: CGPoint(x: Self.x(at: block.start) + Theme.Tape.labelInset, y: Theme.Tape.labelCenterY),
            anchor: .leading
        )
    }
}
