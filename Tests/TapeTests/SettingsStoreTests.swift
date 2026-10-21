import Foundation
import Testing
@testable import Tape

@MainActor
struct SettingsStoreTests {
    /// A fresh, empty defaults domain per test, so the app's real settings
    /// are never read or written.
    let suite = "TapeTests.\(UUID().uuidString)"
    var defaults: UserDefaults { UserDefaults(suiteName: suite)! }

    @Test func defaultsMatchTheSpec() {
        let store = SettingsStore(defaults: defaults)
        #expect(store.session == SessionSettings())
        #expect(store.session.plan == .standard)
        #expect(store.autoContinue)
        #expect(store.showCountdownInMenuBar)
        defaults.removePersistentDomain(forName: suite)
    }

    @Test func changesAreSavedAndReloaded() {
        let store = SettingsStore(defaults: defaults)
        store.session.focusMinutes = 50
        store.session.rounds = 6
        store.session.longBreakEvery = 3
        store.autoContinue = false
        store.showCountdownInMenuBar = false

        let reloaded = SettingsStore(defaults: defaults)
        #expect(reloaded.session.focusMinutes == 50)
        #expect(reloaded.session.rounds == 6)
        #expect(reloaded.session.longBreakEvery == 3)
        #expect(!reloaded.autoContinue)
        #expect(!reloaded.showCountdownInMenuBar)
        defaults.removePersistentDomain(forName: suite)
    }

    @Test func outOfRangeValuesAreClamped() {
        defaults.set(500, forKey: "focusMinutes")
        defaults.set(0, forKey: "rounds")
        defaults.set(7, forKey: "longBreakEvery")
        let store = SettingsStore(defaults: defaults)
        #expect(store.session.focusMinutes == 90)
        #expect(store.session.rounds == 1)
        #expect(store.session.longBreakEvery == 0)
        defaults.removePersistentDomain(forName: suite)
    }

    @Test func settingsBuildThePlan() {
        let settings = SessionSettings(focusMinutes: 30, breakMinutes: 3, rounds: 4,
                                       longBreakMinutes: 20, longBreakEvery: 2)
        #expect(settings.plan.blocks.map { $0.duration / 60 } == [30, 3, 30, 20, 30, 3, 30])
    }
}
