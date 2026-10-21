import AppKit
import UserNotifications

/// Shows a notification when a block ends.
///
/// The notification has no sound of its own: the chime is played by Tape
/// (see Chime), so it still plays if notifications are turned off, and never
/// plays twice.
///
/// Also tells Settings whether notifications are allowed, since macOS only
/// asks once and a "Don't Allow" is otherwise silent.
@MainActor
final class Notifier: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published private(set) var status = UNAuthorizationStatus.notDetermined

    /// Nil when not running from Tape.app (e.g. `swift run`), because the
    /// notification center crashes outside an app bundle.
    private let center: UNUserNotificationCenter?

    /// Every notification uses this, so a new one replaces the last instead
    /// of piling up in Notification Center.
    private static let identifier = "block-end"

    override init() {
        center = Bundle.main.bundleURL.pathExtension == "app" ? .current() : nil
        super.init()
        center?.delegate = self
        refresh()
    }

    /// macOS only asks the user once; after that this just returns their answer.
    func requestPermission() {
        center?.requestAuthorization(options: [.alert]) { [weak self] _, _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    /// Reads whether notifications are allowed. They can be changed in
    /// System Settings at any time, so Settings calls this when it appears.
    func refresh() {
        center?.getNotificationSettings { [weak self] settings in
            let status = settings.authorizationStatus
            Task { @MainActor in self?.status = status }
        }
    }

    /// Tape's page in System Settings > Notifications.
    func openSystemSettings() {
        let id = Bundle.main.bundleIdentifier ?? ""
        guard let url = URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension?id=\(id)")
        else { return }
        NSWorkspace.shared.open(url)
    }

    /// Does nothing if the user said no.
    func show(_ message: BlockEndMessage) {
        guard let center else { return }
        let content = UNMutableNotificationContent()
        content.title = message.title
        content.body = message.body
        center.add(UNNotificationRequest(identifier: Self.identifier, content: content, trigger: nil))
    }

    // Tape counts as the frontmost app while its panel is open, and macOS
    // hides notifications from the frontmost app unless it asks for them.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list]
    }
}
