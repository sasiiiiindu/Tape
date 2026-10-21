import Foundation

/// A short slide of the tape after Skip, Restart or New session, from where
/// the tape was on screen to where the timer now is, so it doesn't jump.
struct TapeSlide {
    /// Session seconds the tape was showing when the button was pressed.
    let from: TimeInterval
    let start: Date

    func isActive(at date: Date) -> Bool {
        date.timeIntervalSince(start) < Theme.Motion.tapeSlide
    }

    /// Session seconds the tape shows at `date`, with any slide applied. Both
    /// the tape (every frame) and the buttons (to start the next slide from
    /// where the tape really is) use this.
    @MainActor
    static func shownElapsed(of timer: SessionTimer, slide: TapeSlide?, at date: Date) -> TimeInterval {
        let target = timer.elapsed(at: date)
        guard let slide, slide.isActive(at: date) else { return target }
        let progress = min(max(date.timeIntervalSince(slide.start) / Theme.Motion.tapeSlide, 0), 1)
        return slide.from + (target - slide.from) * easeInOut(progress)
    }

    /// Slow start, fast middle, slow finish.
    private static func easeInOut(_ t: Double) -> Double {
        t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2
    }
}
