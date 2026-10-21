import AppKit
import Combine

/// Runs a session: which block we're in, how long is left, and the controls.
///
/// Timing is date-based. While running we store the real moment the current
/// block ends and work out what's left from the clock; nothing is counted
/// down by subtraction, so sleep, wake and late timer ticks can't make it drift.
@MainActor
final class SessionTimer: ObservableObject {
    @Published private(set) var state: TimerState = .idle
    @Published private(set) var blockIndex = 0
    /// Session seconds left in the current block.
    @Published private(set) var remaining: TimeInterval
    /// The time of the last update. Refreshed every tick in every state, so
    /// clock times keep moving while paused (pausing pushes them later).
    @Published private(set) var now: Date
    /// The blocks of this session. Only changes between sessions.
    @Published private(set) var plan: SessionPlan

    /// When a block ends: true starts the next one straight away, false stops
    /// at the start of the next one, paused, and waits for Start.
    var autoContinue = true
    /// Session seconds per real second. 1 except in fast mode.
    let speed: Double

    private let clock: () -> Date
    /// What the next session will look like. Settings change this; it only
    /// becomes `plan` while idle, so a session never changes shape mid-way.
    private var nextPlan: SessionPlan
    /// Real moment the current block ends. Only set while running.
    private var blockEnd: Date?
    private var ticker: Timer?
    private var wakeObserver: NSObjectProtocol?

    /// `clock` and `live` exist for tests: a fake clock, and no real timer or
    /// wake notifications.
    init(
        plan: SessionPlan = .standard,
        speed: Double = 1,
        clock: @escaping () -> Date = Date.init,
        live: Bool = true
    ) {
        self.plan = plan
        self.nextPlan = plan
        self.speed = speed
        self.clock = clock
        self.remaining = plan.blocks[0].duration
        self.now = clock()
        if live {
            startTicking()
        }
    }

    // MARK: - What the views read

    var currentBlock: Block { plan.blocks[blockIndex] }

    var nextBlock: Block? {
        blockIndex + 1 < plan.blocks.count ? plan.blocks[blockIndex + 1] : nil
    }

    /// Session seconds done so far, across all blocks.
    var elapsedInSession: TimeInterval {
        state == .finished ? plan.totalDuration : currentBlock.end - remaining
    }

    /// Session seconds done at `date`, which may fall between ticks. The tape
    /// uses this to move smoothly instead of in half-second steps. Stays
    /// inside the current block; the next tick moves on to the next one.
    func elapsed(at date: Date) -> TimeInterval {
        guard state == .running, let blockEnd else { return elapsedInSession }
        let left = blockEnd.timeIntervalSince(date) * speed
        return currentBlock.end - min(max(left, 0), currentBlock.duration)
    }

    /// Clock time the next block starts (or the session ends, on the last block).
    var nextBlockStart: Date {
        now.addingTimeInterval(remaining / speed)
    }

    /// Clock time the whole session ends.
    var sessionEnd: Date {
        now.addingTimeInterval((plan.totalDuration - elapsedInSession) / speed)
    }

    // MARK: - Actions

    /// Start from idle, or resume when paused.
    func start() {
        switch state {
        case .idle: run()
        case .paused: resume()
        case .running, .finished: break
        }
    }

    func pause() {
        update()
        guard state == .running else { return }
        blockEnd = nil
        state = .paused
    }

    func resume() {
        guard state == .paused else { return }
        run()
    }

    /// Back to the start of the current block, paused.
    func restartBlock() {
        update()
        guard state == .running || state == .paused else { return }
        remaining = currentBlock.duration
        blockEnd = nil
        state = .paused
    }

    /// Jump to the start of the next block, still running if it was. On the
    /// last block this finishes the session. From idle it lands paused.
    func skip() {
        update()
        guard state != .finished else { return }
        guard let next = nextBlock else {
            finish()
            return
        }
        move(toSessionOffset: next.start, running: state == .running)
    }

    /// Back to idle at the start of a session, using the latest settings.
    func newSession() {
        plan = nextPlan
        blockEnd = nil
        blockIndex = 0
        remaining = currentBlock.duration
        state = .idle
        now = clock()
    }

    /// Use `plan` for the next session. Applies at once while idle; during a
    /// session (or once it's finished) it waits for New session.
    func setNextPlan(_ plan: SessionPlan) {
        nextPlan = plan
        if state == .idle && plan != self.plan {
            newSession()
        }
    }

    // MARK: - Timekeeping

    /// Bring everything up to date with the clock. Called on every tick, after
    /// wake, and before each action.
    func update() {
        now = clock()
        guard state == .running, let blockEnd else { return }

        let left = blockEnd.timeIntervalSince(now) * speed
        if left > 0 {
            remaining = min(left, currentBlock.duration)
        } else if autoContinue {
            // The block is over. Carry the overrun on into the following
            // blocks; after a long sleep that can be several of them.
            move(toSessionOffset: currentBlock.end - left, running: true)
        } else {
            // Stop at the start of the next block, however long ago this one
            // ended (even after a long sleep).
            move(toSessionOffset: currentBlock.end, running: false)
        }
    }

    private func run() {
        now = clock()
        blockEnd = now.addingTimeInterval(remaining / speed)
        state = .running
    }

    private func move(toSessionOffset offset: TimeInterval, running: Bool) {
        guard let position = plan.position(at: offset) else {
            finish()
            return
        }
        blockIndex = position.index
        remaining = position.remaining
        if running {
            run()
        } else {
            blockEnd = nil
            state = .paused
        }
    }

    private func finish() {
        blockEnd = nil
        blockIndex = plan.blocks.count - 1
        remaining = 0
        state = .finished
    }

    private func startTicking() {
        // Twice a second normally so mm:ss never lags; faster in fast mode.
        let interval = max(0.5 / speed, 0.05)
        let timer = Timer(timeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.update() }
        }
        timer.tolerance = interval / 10
        // .common keeps it ticking while a button is held down.
        RunLoop.main.add(timer, forMode: .common)
        ticker = timer

        // Timers don't fire during sleep, so catch up as soon as we wake.
        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification, object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.update() }
        }
    }
}
