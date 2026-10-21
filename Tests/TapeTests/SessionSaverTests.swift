import Foundation
import Testing
@testable import Tape

/// Quitting mid-session: it comes back paused where it was, unless it's
/// more than 12 hours old, finished, or never started.
@MainActor
struct SessionSaverTests {
    let clock = FakeClock()
    let suite = "TapeTests.\(UUID().uuidString)"
    var defaults: UserDefaults { UserDefaults(suiteName: suite)! }

    func makeTimer(plan: SessionPlan = .standard) -> SessionTimer {
        SessionTimer(plan: plan, clock: { [clock] in clock.now },
                     uptime: { [clock] in clock.uptime }, live: false)
    }

    func wait(_ timer: SessionTimer, minutes: Double) {
        clock.advance(minutes: minutes)
        timer.update()
    }

    /// Runs a session for 32 minutes (2 minutes into Focus 2), then quits.
    func quitMidSession() {
        let timer = makeTimer()
        let saver = SessionSaver(timer: timer, defaults: defaults)
        timer.start()
        wait(timer, minutes: 32)
        saver.saveNow()
    }

    @Test func comesBackPausedWhereItWas() {
        quitMidSession()
        clock.advance(minutes: 60)   // reopened an hour later
        let timer = makeTimer()
        _ = SessionSaver(timer: timer, defaults: defaults)
        #expect(timer.state == .paused)
        #expect(timer.blockIndex == 2)
        #expect(timer.remaining == 23 * 60)
        defaults.removePersistentDomain(forName: suite)
    }

    @Test func keepsTheSessionsOwnPlan() {
        quitMidSession()
        // Settings changed since: the restored session keeps its shape and
        // the new one waits for New session.
        let short = SessionPlan(focus: 50 * 60, breakLength: 10 * 60, rounds: 2)
        let timer = makeTimer(plan: short)
        _ = SessionSaver(timer: timer, defaults: defaults)
        #expect(timer.plan == .standard)
        timer.setNextPlan(short)
        #expect(timer.plan == .standard)
        defaults.removePersistentDomain(forName: suite)
    }

    @Test func startsFreshAfter12Hours() {
        quitMidSession()
        clock.advance(minutes: 12 * 60 + 1)
        let timer = makeTimer()
        _ = SessionSaver(timer: timer, defaults: defaults)
        #expect(timer.state == .idle)
        #expect(timer.remaining == 25 * 60)
        defaults.removePersistentDomain(forName: suite)
    }

    @Test func finishedOrNewSessionStartsFresh() {
        let timer = makeTimer()
        let saver = SessionSaver(timer: timer, defaults: defaults)
        timer.start()
        wait(timer, minutes: 200)
        saver.saveNow()
        let next = makeTimer()
        _ = SessionSaver(timer: next, defaults: defaults)
        #expect(next.state == .idle)
        defaults.removePersistentDomain(forName: suite)
    }

    @Test func pausedSessionKeepsItsExactTime() {
        let timer = makeTimer()
        let saver = SessionSaver(timer: timer, defaults: defaults)
        timer.start()
        wait(timer, minutes: 7.5)
        timer.pause()
        saver.saveNow()
        let next = makeTimer()
        _ = SessionSaver(timer: next, defaults: defaults)
        #expect(next.state == .paused)
        #expect(next.remaining == 17.5 * 60)
        defaults.removePersistentDomain(forName: suite)
    }

    @Test func damagedSaveIsIgnored() {
        let broken = SavedSession(plan: .standard, blockIndex: 9, remaining: 60, savedAt: clock.now)
        #expect(!broken.isRestorable(at: clock.now))
        let tooMuchLeft = SavedSession(plan: .standard, blockIndex: 0, remaining: 99 * 60, savedAt: clock.now)
        #expect(!tooMuchLeft.isRestorable(at: clock.now))
        defaults.set(Data("nonsense".utf8), forKey: "savedSession")
        let timer = makeTimer()
        _ = SessionSaver(timer: timer, defaults: defaults)
        #expect(timer.state == .idle)
        defaults.removePersistentDomain(forName: suite)
    }
}
