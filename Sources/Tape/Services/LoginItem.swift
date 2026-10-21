import Foundation
import ServiceManagement

/// "Launch at login", using macOS's own list of login items (SMAppService,
/// macOS 13+).
///
/// The setting lives with macOS, not in Tape's settings, because it can also
/// be changed in System Settings > General > Login Items. So it's read back
/// from macOS each time the settings page appears.
@MainActor
final class LoginItem: ObservableObject {
    @Published private(set) var isOn = false
    /// A short note next to the switch when it isn't doing what was asked.
    @Published private(set) var note: String?
    /// The note opens Login Items in System Settings, where the user can fix it.
    @Published private(set) var noteOpensSettings = false

    /// The last attempt to change it failed, and what it was trying to do.
    private var failure: String?
    private var wanted = false

    init() {
        refresh()
    }

    func refresh() {
        let status = SMAppService.mainApp.status
        // Requires approval: switched on, but turned off in System Settings.
        isOn = status == .enabled || status == .requiresApproval
        // Fixed since, e.g. in System Settings.
        if isOn == wanted {
            failure = nil
        }
        noteOpensSettings = status == .requiresApproval
        if isTemporaryCopy {
            note = "Move to Applications"
        } else if status == .requiresApproval {
            note = "Allow in Settings"
        } else {
            note = failure
        }
    }

    func set(_ on: Bool) {
        failure = nil
        wanted = on
        // Registering a temporary copy would add a login item that points
        // at a disk image or a hidden folder macOS later deletes.
        if !isTemporaryCopy {
            do {
                if on {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                // Visible in Console.app, for finding out why.
                NSLog("Tape: couldn't turn launch at login %@: %@", on ? "on" : "off", error.localizedDescription)
                failure = on ? "Couldn't turn on" : "Couldn't turn off"
            }
        }
        refresh()
    }

    func openSystemSettings() {
        SMAppService.openSystemSettingsLoginItems()
    }

    /// Running straight from the disk image, or from the hidden copy macOS
    /// makes of a downloaded app that hasn't been moved yet (App Translocation).
    private var isTemporaryCopy: Bool {
        let path = Bundle.main.bundlePath
        return path.hasPrefix("/Volumes/") || path.contains("/AppTranslocation/")
    }
}
