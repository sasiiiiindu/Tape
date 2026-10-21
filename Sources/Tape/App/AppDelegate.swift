import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItemController: StatusItemController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let timer = SessionTimer(speed: FastMode.speed)
        statusItemController = StatusItemController(timer: timer)
    }
}
