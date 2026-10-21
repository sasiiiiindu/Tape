import AppKit
import Combine

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItemController: StatusItemController?
    private var settingsSubscriptions: Set<AnyCancellable> = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        let settings = SettingsStore()
        let timer = SessionTimer(plan: settings.session.plan, speed: FastMode.speed)

        // Pass setting changes on to the timer. A new session shape waits
        // for the next session unless the timer is idle; auto-continue
        // applies straight away.
        settings.$session
            .sink { timer.setNextPlan($0.plan) }
            .store(in: &settingsSubscriptions)
        settings.$autoContinue
            .sink { timer.autoContinue = $0 }
            .store(in: &settingsSubscriptions)

        statusItemController = StatusItemController(timer: timer, settings: settings)
    }
}
