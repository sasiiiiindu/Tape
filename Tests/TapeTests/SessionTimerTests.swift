import Foundation
import Testing
@testable import Tape

/// A clock the tests move by hand.
final class FakeClock {
    var now = Date(timeIntervalSinceReferenceDate: 0)
    func advance(minutes: Double) { now += minutes * 60 }
}

@MainActor
struct SessionTimerTests {
    let clock = FakeClock()

    func makeTimer(speed: Double = 1) -> SessionTimer {
        SessionTimer(plan: .standard, speed: speed, clock: { [clock] in clock.now }, live: false)
    }

    /// Move the fake clock and let the timer catch up, like a tick would.
    func wait(_ timer: SessionTimer, minutes: Double) {
        clock.advance(minutes: minutes)
        timer.update()
    }

    @Test func startsIdleAtFullFocus() {
        let timer = makeTimer()
        #expect(timer.state == .idle)
        #expect(timer.blockIndex == 0)
        #expect(timer.remaining == 25 * 60)
        timer.update()
        clock.advance(minutes: 3)
        timer.update()
        #expect(timer.remaining == 25 * 60)   // idle doesn't count down
    }

    @Test func countsDownFromTheClock() {
        let timer = makeTimer()
        timer.start()
        wait(timer, minutes: 10)
        #expect(timer.state == .running)
        #expect(timer.remaining == 15 * 60)
        #expect(timer.elapsedInSession == 10 * 60)
    }

    @Test func pauseFreezesAndResumeContinues() {
        let timer = makeTimer()
        timer.start()
        wait(timer, minutes: 10)
        timer.pause()
        wait(timer, minutes: 30)
        #expect(timer.state == .paused)
        #expect(timer.remaining == 15 * 60)

        timer.resume()
        wait(timer, minutes: 5)
        #expect(timer.state == .running)
        #expect(timer.remaining == 10 * 60)
    }

    @Test func clockTimesMoveLaterWhilePaused() {
        let timer = makeTimer()
        timer.start()
        wait(timer, minutes: 10)
        timer.pause()
        let breakAt = timer.nextBlockStart
        let doneAt = timer.sessionEnd
        wait(timer, minutes: 7)
        #expect(timer.nextBlockStart == breakAt + 7 * 60)
        #expect(timer.sessionEnd == doneAt + 7 * 60)
    }

    @Test func nextBlockAndSessionEndTimes() {
        let timer = makeTimer()
        timer.start()
        wait(timer, minutes: 10)
        #expect(timer.nextBlockStart == clock.now + 15 * 60)
        #expect(timer.sessionEnd == clock.now + 105 * 60)
    }

    @Test func runsIntoTheNextBlockAutomatically() {
        let timer = makeTimer()
        timer.start()
        wait(timer, minutes: 27)
        #expect(timer.state == .running)
        #expect(timer.currentBlock.kind == .break)
        #expect(timer.remaining == 3 * 60)
    }

    @Test func catchesUpAcrossSeveralBlocksAfterSleep() {
        let timer = makeTimer()
        timer.start()
        wait(timer, minutes: 62)   // 25 focus + 5 break + 25 focus + 5 break + 2
        #expect(timer.blockIndex == 4)
        #expect(timer.currentBlock.round == 3)
        #expect(timer.remaining == 23 * 60)
        #expect(timer.elapsedInSession == 62 * 60)
    }

    @Test func finishesWhenTheWholeSessionHasPassed() {
        let timer = makeTimer()
        timer.start()
        wait(timer, minutes: 200)
        #expect(timer.state == .finished)
        #expect(timer.remaining == 0)
        #expect(timer.elapsedInSession == 115 * 60)
    }

    @Test func restartGoesBackToBlockStartPaused() {
        let timer = makeTimer()
        timer.start()
        wait(timer, minutes: 28)   // 3 min into the first break
        timer.restartBlock()
        #expect(timer.state == .paused)
        #expect(timer.blockIndex == 1)
        #expect(timer.remaining == 5 * 60)
        wait(timer, minutes: 10)
        #expect(timer.remaining == 5 * 60)
    }

    @Test func restartDoesNothingWhenIdle() {
        let timer = makeTimer()
        timer.restartBlock()
        #expect(timer.state == .idle)
    }

    @Test func skipWhileRunningKeepsRunning() {
        let timer = makeTimer()
        timer.start()
        wait(timer, minutes: 10)
        timer.skip()
        #expect(timer.state == .running)
        #expect(timer.blockIndex == 1)
        #expect(timer.remaining == 5 * 60)
        wait(timer, minutes: 1)
        #expect(timer.remaining == 4 * 60)
    }

    @Test func skipWhilePausedStaysPaused() {
        let timer = makeTimer()
        timer.start()
        timer.pause()
        timer.skip()
        #expect(timer.state == .paused)
        #expect(timer.blockIndex == 1)
        #expect(timer.remaining == 5 * 60)
    }

    @Test func skipFromIdleLandsPausedOnTheBreak() {
        let timer = makeTimer()
        timer.skip()
        #expect(timer.state == .paused)
        #expect(timer.blockIndex == 1)
    }

    @Test func skipOnTheLastBlockFinishes() {
        let timer = makeTimer()
        timer.start()
        for _ in 0..<6 { timer.skip() }
        #expect(timer.blockIndex == 6)
        #expect(timer.nextBlock == nil)
        #expect(timer.state == .running)
        timer.skip()
        #expect(timer.state == .finished)
        timer.skip()
        #expect(timer.state == .finished)
    }

    @Test func skipThenTheNewBlockEndsOnTime() {
        let timer = makeTimer()
        timer.start()
        wait(timer, minutes: 10)
        timer.skip()               // break: 5 min
        wait(timer, minutes: 6)    // 1 min into focus 2
        #expect(timer.currentBlock.kind == .focus)
        #expect(timer.currentBlock.round == 2)
        #expect(timer.remaining == 24 * 60)
    }

    @Test func newSessionResets() {
        let timer = makeTimer()
        timer.start()
        wait(timer, minutes: 200)
        timer.newSession()
        #expect(timer.state == .idle)
        #expect(timer.blockIndex == 0)
        #expect(timer.remaining == 25 * 60)
    }

    @Test func startDoesNothingWhenFinished() {
        let timer = makeTimer()
        timer.start()
        wait(timer, minutes: 200)
        timer.start()
        #expect(timer.state == .finished)
    }

    @Test func fastSpeedRunsSixtyTimesQuicker() {
        let timer = makeTimer(speed: 60)
        timer.start()
        wait(timer, minutes: 1.0 / 60)   // one real second
        #expect(timer.remaining == 24 * 60)
        #expect(timer.nextBlockStart == clock.now + 24)   // 24 real seconds away
        wait(timer, minutes: 2)          // whole 115-min session is under 2 min
        #expect(timer.state == .finished)
    }

    @Test func elapsedAtADateBetweenTicks() {
        let timer = makeTimer()
        #expect(timer.elapsed(at: clock.now + 600) == 0)   // idle: doesn't move
        timer.start()
        wait(timer, minutes: 10)
        // No tick since, but asking about 30 s later still moves on.
        #expect(timer.elapsed(at: clock.now + 30) == 10 * 60 + 30)
        // Past the end of the block it holds at the boundary until a tick.
        #expect(timer.elapsed(at: clock.now + 3600) == 25 * 60)
        timer.pause()
        #expect(timer.elapsed(at: clock.now + 3600) == 10 * 60)
        timer.skip()
        timer.skip()
        #expect(timer.elapsed(at: clock.now) == 30 * 60)
    }

    @Test func elapsedIsTheWholeSessionWhenFinished() {
        let timer = makeTimer()
        timer.start()
        wait(timer, minutes: 200)
        #expect(timer.elapsed(at: clock.now) == 115 * 60)
    }
}
