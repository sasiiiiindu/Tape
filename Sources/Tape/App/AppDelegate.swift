import AppKit
import Combine

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItemController: StatusItemController?
    private var blockAlerts: BlockAlerts?
    private var shortcut: GlobalShortcut?
    private var sessionSaver: SessionSaver?
    private var settingsSubscriptions: Set<AnyCancellable> = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        let settings = SettingsStore()
        let timer = SessionTimer(plan: settings.session.plan, speed: FastMode.speed)
        // Before anything shows the timer: brings back a session Tape quit
        // in the middle of, paused.
        sessionSaver = SessionSaver(timer: timer)

        // Pass setting changes on to the timer. A new session shape waits
        // for the next session unless the timer is idle; auto-continue
        // applies straight away.
        settings.$session
            .sink { timer.setNextPlan($0.plan) }
            .store(in: &settingsSubscriptions)
        settings.$autoContinue
            .sink { timer.autoContinue = $0 }
            .store(in: &settingsSubscriptions)

        let notifier = Notifier()
        blockAlerts = BlockAlerts(timer: timer, settings: settings, notifier: notifier)

        // The shortcut needs the controller and the controller shows the
        // shortcut's state in Settings, so the action looks it up later.
        let shortcut = GlobalShortcut { [weak self] in self?.statusItemController?.togglePanel() }
        self.shortcut = shortcut
        statusItemController = StatusItemController(timer: timer, settings: settings, notifier: notifier,
                                                    loginItem: LoginItem(), shortcut: shortcut)

        settings.$globalShortcut
            .sink { shortcut.setEnabled($0) }
            .store(in: &settingsSubscriptions)
    }

    func applicationWillTerminate(_ notification: Notification) {
        sessionSaver?.saveNow()
    }
}
