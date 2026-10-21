import Carbon.HIToolbox
import Foundation

/// ⌃⌥T from any app opens or closes the panel. Off unless turned on in
/// Settings.
///
/// Carbon's RegisterEventHotKey because it's the one way to catch a key
/// combination in every app without asking for Accessibility or Input
/// Monitoring permission. SwiftUI and NSEvent only see keys in Tape's own
/// windows, or need that permission.
@MainActor
final class GlobalShortcut: ObservableObject {
    /// Shown in Settings.
    static let title = "⌃⌥T"

    /// Turned on, but macOS wouldn't set it up.
    @Published private(set) var failed = false

    private let action: () -> Void
    private var hotKey: EventHotKeyRef?
    private var handler: EventHandlerRef?

    init(action: @escaping () -> Void) {
        self.action = action
    }

    func setEnabled(_ enabled: Bool) {
        enabled ? enable() : disable()
    }

    private func enable() {
        guard hotKey == nil else { return }

        var pressed = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let me = Unmanaged.passUnretained(self).toOpaque()
        let installed = InstallEventHandler(GetApplicationEventTarget(), { _, _, userData in
            guard let userData else { return OSStatus(eventNotHandledErr) }
            let shortcut = Unmanaged<GlobalShortcut>.fromOpaque(userData).takeUnretainedValue()
            Task { @MainActor in shortcut.action() }
            return noErr
        }, 1, &pressed, me, &handler)

        // "TAPE" as four bytes; it only has to tell our hotkey apart.
        let id = EventHotKeyID(signature: OSType(0x5441_5045), id: 1)
        let registered = RegisterEventHotKey(UInt32(kVK_ANSI_T), UInt32(controlKey | optionKey), id,
                                             GetApplicationEventTarget(), 0, &hotKey)

        if installed != noErr || registered != noErr {
            NSLog("Tape: couldn't set up the %@ shortcut (%d, %d)", Self.title, installed, registered)
            disable()
            failed = true
        }
    }

    private func disable() {
        if let hotKey {
            UnregisterEventHotKey(hotKey)
        }
        if let handler {
            RemoveEventHandler(handler)
        }
        hotKey = nil
        handler = nil
        failed = false
    }
}
