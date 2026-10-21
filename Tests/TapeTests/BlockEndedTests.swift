import Combine
import Foundation
import Testing
@testable import Tape

/// `blockEnded` drives the chime and the notification, so it must fire once
/// per natural block end and never for the buttons.
@MainActor
struct BlockEndedTests {
    let clock = FakeClock()

    func makeTimer(autoContinue: Bool = true) -> SessionTimer {
        let timer = SessionTimer(plan: .standard, clock: { [clock] in clock.now },
                                 uptime: { [clock] in clock.uptime }, live: false)
        timer.autoContinue = autoContinue
        return timer
    }

    /// Counts `blockEnded` while `body` runs.
    func countEnds(of timer: SessionTimer, during body: () -> Void) -> Int {
        var count = 0
        let subscription = timer.blockEnded.sink { count += 1 }
        body()
        subscription.cancel()
        return count
    }

    func wait(_ timer: SessionTimer, minutes: Double) {
        clock.advance(minutes: minutes)
        timer.update()
    }

    @Test func firesOnceWhenABlockRunsOut() {
        let timer = makeTimer()
        timer.start()
        let ends = countEnds(of: timer) {
            wait(timer, minutes: 24)
            wait(timer, minutes: 1)
            wait(timer, minutes: 1)
        }
        #expect(ends == 1)
        #expect(timer.currentBlock.kind == .break)
    }

    @Test func doesNotFireForTheButtons() {
        let timer = makeTimer()
        let ends = countEnds(of: timer) {
            timer.start()
            wait(timer, minutes: 10)
            timer.skip()
            timer.restartBlock()
            timer.start()
            timer.pause()
            for _ in 0..<10 { timer.skip() }   // ends with Finish
        }
        #expect(ends == 0)
        #expect(timer.state == .finished)
    }

    @Test func firesOnceAfterASleepThatPassedSeveralBlocks() {
        let timer = makeTimer()
        timer.start()
        let ends = countEnds(of: timer) { wait(timer, minutes: 70) }
        #expect(ends == 1)
        #expect(timer.blockIndex == 4)
    }

    @Test func firesOnceAfterSleepWithoutAutoContinue() {
        let timer = makeTimer(autoContinue: false)
        timer.start()
        let ends = countEnds(of: timer) {
            wait(timer, minutes: 70)
            wait(timer, minutes: 10)   // waiting paused: nothing more
        }
        #expect(ends == 1)
        #expect(timer.state == .paused)
    }

    @Test func firesWhenTheSessionRunsOut() {
        let timer = makeTimer()
        timer.start()
        let ends = countEnds(of: timer) { wait(timer, minutes: 200) }
        #expect(ends == 1)
        #expect(timer.state == .finished)
    }
}
