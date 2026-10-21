import Combine
import Foundation

/// Keeps the session in progress saved in UserDefaults, and brings it back
/// at launch, paused, if Tape quit (or the Mac restarted) in the middle of it.
///
/// Saved whenever the timer starts, pauses or changes block, every 15
/// seconds while running, and at quit. So even after a crash or a force
/// quit it comes back within 15 seconds of where it was.
@MainActor
final class SessionSaver {
    private let timer: SessionTimer
    private let defaults: UserDefaults
    private var lastSaved: SavedSession?
    private var subscription: AnyCancellable?

    private static let key = "savedSession"
    /// While running, how much the time left may change before saving again.
    private static let interval: TimeInterval = 15

    /// Restores the saved session, if there's a recent one, then starts
    /// watching the timer. Tests pass their own UserDefaults.
    init(timer: SessionTimer, defaults: UserDefaults = .standard) {
        self.timer = timer
        self.defaults = defaults

        if let data = defaults.data(forKey: Self.key),
           let session = try? JSONDecoder().decode(SavedSession.self, from: data),
           session.isRestorable(at: timer.now) {
            timer.restore(session)
        }
        save()

        // The timer announces changes just before making them, so read its
        // new values on the next main-queue pass.
        subscription = timer.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.saveIfChanged() }
    }

    /// Called at quit, so the session comes back exactly where it was.
    func saveNow() {
        timer.update()
        save()
    }

    private func save() {
        let session = timer.saved()
        lastSaved = session
        if let session, let data = try? JSONEncoder().encode(session) {
            defaults.set(data, forKey: Self.key)
        } else {
            defaults.removeObject(forKey: Self.key)
        }
    }

    /// Ticks arrive twice a second; only save when something that matters changed.
    private func saveIfChanged() {
        guard let session = timer.saved(), let last = lastSaved,
              session.plan == last.plan, session.blockIndex == last.blockIndex else {
            // Started, finished, new session or a new block.
            if timer.saved() != nil || lastSaved != nil { save() }
            return
        }
        // Within the same block: any change once paused (pause, restart),
        // but only every 15 seconds while it counts down.
        let change = abs(session.remaining - last.remaining)
        if change >= Self.interval || (timer.state != .running && change > 0) {
            save()
        }
    }
}
