import AppKit

/// Owns the menu bar item and opens/closes the panel under it.
///
/// AppKit (NSStatusItem) instead of SwiftUI's MenuBarExtra: MenuBarExtra turns
/// its label into a one-colour icon plus plain text, which can't show the
/// coloured session strip or keep the digits monospaced (Phase 5).
@MainActor
final class StatusItemController: NSObject {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let panel = MenuBarPanel(content: PanelView())

    /// When the panel last closed. Clicking the menu bar item while the panel
    /// is open can close it (focus moves away) just before the click arrives;
    /// without this check that click would immediately reopen it.
    private var lastClosed = Date.distantPast

    override init() {
        super.init()

        if let button = statusItem.button {
            let size = NSFont.menuBarFont(ofSize: 0).pointSize
            button.font = .monospacedDigitSystemFont(ofSize: size, weight: .regular)
            button.title = "25:00"
            button.target = self
            button.action = #selector(togglePanel)
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
