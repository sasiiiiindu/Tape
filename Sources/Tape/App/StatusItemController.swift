import AppKit
import Combine

/// Owns the menu bar item and opens/closes the panel under it.
///
/// AppKit (NSStatusItem) instead of SwiftUI's MenuBarExtra: MenuBarExtra turns
/// its label into a one-colour icon plus plain text, which can't show the
/// coloured session strip or keep the digits monospaced (Phase 5).
@MainActor
final class StatusItemController: NSObject {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let panel: MenuBarPanel
    private var titleSubscription: AnyCancellable?

    /// When the panel last closed. Clicking the menu bar item while the panel
    /// is open can close it (focus moves away) just before the click arrives;
    /// without this check that click would immediately reopen it.
    private var lastClosed = Date.distantPast

    init(timer: SessionTimer) {
        panel = MenuBarPanel(content: PanelView(timer: timer))
        super.init()

        if let button = statusItem.button {
            let size = NSFont.menuBarFont(ofSize: 0).pointSize
            button.font = .monospacedDigitSystemFont(ofSize: size, weight: .regular)
            button.target = self
            button.action = #selector(togglePanel)
        }

        // Live mm:ss in the menu bar, only touched when the text changes.
        titleSubscription = timer.$remaining
            .map(TimeFormat.minutesSeconds)
            .removeDuplicates()
            .sink { [weak self] title in
                self?.statusItem.button?.title = title
            }

        panel.onClose = { [weak self] in
            self?.lastClosed = Date()
            self?.statusItem.button?.highlight(false)
        }
    }

    @objc private func togglePanel() {
        if panel.isVisible {
            panel.close()
        } else if Date().timeIntervalSince(lastClosed) > 0.3 {
            showPanel()
        }
    }

    private func showPanel() {
        guard let button = statusItem.button, let buttonWindow = button.window else { return }

        // Centre the panel under the menu bar item, kept 8 pt inside the screen.
        panel.fitToContent()
        let buttonFrame = buttonWindow.convertToScreen(button.convert(button.bounds, to: nil))
        let screenFrame = (buttonWindow.screen ?? NSScreen.main)?.visibleFrame ?? .zero
        let size = panel.frame.size
        let x = min(max(buttonFrame.midX - size.width / 2, screenFrame.minX + 8),
                    screenFrame.maxX - size.width - 8)
        let y = buttonFrame.minY - size.height - 6
        panel.setFrameOrigin(NSPoint(x: x, y: y))

        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)

        // The button clears its own highlight after the click, so set it on
        // the next run loop pass.
        DispatchQueue.main.async {
            button.highlight(true)
        }
    }
}
