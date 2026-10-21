import AppKit
import Combine

/// Owns the menu bar item and opens/closes the panel under it.
///
/// AppKit (NSStatusItem) instead of SwiftUI's MenuBarExtra: MenuBarExtra turns
/// its label into a one-colour icon plus plain text, which can't show the
/// coloured session strip or keep the digits monospaced.
///
/// The item is the mini session strip followed by mm:ss. Before a session
/// starts it shows an empty strip and the first block's full length (25:00).
@MainActor
final class StatusItemController: NSObject {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let panel: MenuBarPanel
    private let updates: PanelUpdates
    private let timer: SessionTimer
    private var timerSubscription: AnyCancellable?
    private var appearanceObservation: NSKeyValueObservation?
    /// What the strip image was last drawn from, so it's only redrawn on change.
    private var drawnStrip: MenuBarStrip?
    private var drawnOnDark = false

    /// When the panel last closed. Clicking the menu bar item while the panel
    /// is open can close it (focus moves away) just before the click arrives;
    /// without this check that click would immediately reopen it.
    private var lastClosed = Date.distantPast

    init(timer: SessionTimer) {
        self.timer = timer
        updates = PanelUpdates(timer: timer)
        panel = MenuBarPanel(content: PanelView(timer: timer, updates: updates))
        super.init()

        if let button = statusItem.button {
            let size = NSFont.menuBarFont(ofSize: 0).pointSize
            button.font = .monospacedDigitSystemFont(ofSize: size, weight: .regular)
            button.imagePosition = .imageLeading
            button.target = self
            button.action = #selector(togglePanel)

            // The strip's empty blocks follow the menu bar's text colour, which
            // flips with light/dark mode and with the wallpaper behind it.
            appearanceObservation = button.observe(\.effectiveAppearance) { [weak self] _, _ in
                Task { @MainActor in self?.refresh() }
            }
        }

        // The timer announces changes just before making them, so read its
        // new values on the next main-queue pass.
        timerSubscription = timer.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.refresh() }
        refresh()

        panel.onClose = { [weak self] in
            self?.lastClosed = Date()
            self?.updates.isOpen = false
            self?.statusItem.button?.highlight(false)
        }
    }

    /// Bring the strip and mm:ss up to date, touching only what changed.
    private func refresh() {
        guard let button = statusItem.button else { return }

        let title = TimeFormat.minutesSeconds(timer.remaining)
        if button.title != title {
            button.title = title
        }

        let strip = MenuBarStrip(plan: timer.plan, current: timer.blockIndex, remaining: timer.remaining)
        let onDark = button.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
        guard strip != drawnStrip || onDark != drawnOnDark else { return }
        button.image = MenuBarStripImage.make(strip, onDarkMenuBar: onDark)
        drawnStrip = strip
        drawnOnDark = onDark
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

        updates.isOpen = true

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
