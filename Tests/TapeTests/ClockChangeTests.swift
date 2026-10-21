import Combine
import Foundation
import Testing
@testable import Tape

/// The time left must follow real time passing, not the Mac's clock: setting
/// the clock by hand, or a session running past midnight, changes nothing.
@MainActor
struct ClockChangeTests {
    let clock = FakeClock()

    func makeTimer() -> SessionTimer {
        SessionTimer(plan: .standard, clock: { [clock] in clock.now },
                     uptime: { [clock] in clock.uptime }, live: false)
    }

    func wait(_ timer: SessionTimer, minutes: Double) {
        clock.advance(minutes: minutes)
        timer.update()
    }

    @Test func settingTheClockBackKeepsCountingDown() {
        let timer = makeTimer()
        timer.start()
        wait(timer, minutes: 10)
        clock.changeClock(byMinutes: -60)
        timer.update()
        #expect(timer.remaining == 15 * 60)
        wait(timer, minutes: 5)
        #expect(timer.remaining == 10 * 60)
        // Clock times follow the new clock.
        #expect(timer.nextBlockStart == clock.now + 10 * 60)
    }

    @Test func settingTheClockForwardSkipsNothing() {
        let timer = makeTimer()
        var ends = 0
        let subscription = timer.blockEnded.sink { ends += 1 }
        timer.start()
        wait(timer, minutes: 10)
        clock.changeClock(byMinutes: 60)
        timer.update()
        #expect(timer.blockIndex == 0)
        #expect(timer.remaining == 15 * 60)
        #expect(ends == 0)
        wait(timer, minutes: 16)
        #expect(timer.blockIndex == 1)
        #expect(ends == 1)
        subscription.cancel()
    }

    @Test func clockChangeWhilePausedKeepsTheTimeLeft() {
        let timer = makeTimer()
        timer.start()
        wait(timer, minutes: 10)
        timer.pause()
        clock.changeClock(byMinutes: -90)
        timer.update()
        timer.resume()
        wait(timer, minutes: 5)
        #expect(timer.remaining == 10 * 60)
    }

    @Test func sleepStillCounts() {
        // Sleep moves both clocks, so it isn't mistaken for a clock change.
        let timer = makeTimer()
        timer.start()
        wait(timer, minutes: 70)   // 10 minutes into Focus 3
        #expect(timer.blockIndex == 4)
        #expect(timer.remaining == 15 * 60)
    }

    @Test func runsPastMidnight() {
        // 11:50 PM local time, 10 minutes before midnight.
        var calendar = Calendar.current
        calendar.timeZone = .current
        let evening = calendar.date(bySettingHour: 23, minute: 50, second: 0, of: Date())!
        clock.now = evening
        let timer = makeTimer()
        timer.start()
        #expect(timer.sessionEnd == evening + 115 * 60)
        wait(timer, minutes: 35)   // 12:25 AM, 5 minutes into Focus 2
        #expect(timer.blockIndex == 2)
        #expect(timer.remaining == 20 * 60)
        #expect(timer.sessionEnd == evening + 115 * 60)
    }
}
