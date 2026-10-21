import SwiftUI

/// The 280 x 70 tape window: the session strip sliding under a fixed needle,
/// with both edges faded out.
///
/// Motion comes from a TimelineView that only runs while the panel is open
/// and the tape is moving (running, or sliding after Skip/Restart). Its
/// rate follows the speed: about once a second normally, when the strip
/// moves a quarter of a pixel per second; faster in fast mode.
///
/// With Reduce Motion on (System Settings > Accessibility > Display) the
/// strip doesn't slide: it steps once a minute, and Skip and Restart jump.
struct TapeView: View {
    let timer: SessionTimer
    let slide: TapeSlide?
    @ObservedObject var updates: PanelUpdates
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        moving
            // Clip and fade the fixed window, not the strip, so the fade
            // stays put while the strip moves through it.
            .frame(width: Theme.Sizes.tapeWidth, height: Theme.Sizes.tapeHeight, alignment: .leading)
            .clipped()
            .mask(edgeFade)
            .overlay(alignment: .topLeading) {
                TapeNeedle()
                    .offset(
                        x: Theme.Tape.needleX - Theme.Tape.needleDot / 2,
                        y: Theme.Tape.tickBaseline - Theme.Tape.needleHeight - Theme.Tape.needleDot / 2
                    )
            }
            .accessibilityElement()
            .accessibilityLabel(SessionText.spoken(
                state: timer.state, block: timer.currentBlock, next: timer.nextBlock,
                rounds: timer.plan.rounds, remaining: timer.remaining, nextStart: timer.nextBlockStart
            ))
    }

    @ViewBuilder private var moving: some View {
        if reduceMotion {
            // Redrawn with the panel (twice a second), but the strip only
            // moves when a whole minute has passed.
            let elapsed = timer.elapsedInSession
            strip(at: (elapsed / 60).rounded(.down) * 60, elapsed: elapsed)
        } else {
            let sliding = slide?.isActive(at: Date()) ?? false
            let moving = updates.isOpen && (timer.state == .running || sliding)

            TimelineView(.animation(minimumInterval: frameInterval(sliding: sliding), paused: !moving)) { context in
                // After a pause or a closed panel the timeline's date can be
                // old; never draw a moment earlier than now.
                let date = max(context.date, Date())
                let elapsed = TapeSlide.shownElapsed(of: timer, slide: slide, at: date)
                strip(at: elapsed, elapsed: elapsed)
            }
        }
    }

    /// The strip placed so `position` session seconds sit under the needle.
    /// Ticks before `elapsed` are drawn as past.
    private func strip(at position: TimeInterval, elapsed: TimeInterval) -> some View {
        let strip = TapeStrip(
            plan: timer.plan,
            current: timer.plan.position(at: elapsed)?.index,
            pastBefore: (elapsed / 60).rounded(.up) * 60,
            colorScheme: colorScheme
        )
        return strip
            .equatable()
            .offset(x: Theme.Tape.needleX - strip.x(at: position))
    }

    private var edgeFade: some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .black, location: Theme.Tape.edgeFade),
                .init(color: .black, location: 1 - Theme.Tape.edgeFade),
                .init(color: .clear, location: 1),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    /// Seconds between redraws: just often enough that each step is too small
    /// to see.
    private func frameInterval(sliding: Bool) -> TimeInterval {
        if sliding { return Theme.Tape.fastestFrame }
        let pointsPerSecond = Theme.Tape.minuteWidth / 60 * timer.speed
        let interval = Theme.Tape.stepPerFrame / pointsPerSecond
        return min(max(interval, Theme.Tape.fastestFrame), Theme.Tape.slowestFrame)
    }
}
