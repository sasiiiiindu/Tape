import AppKit
import Combine
import SwiftUI

/// Owns the menu bar item and opens/closes the panel under it.
///
/// AppKit (NSStatusItem) instead of SwiftUI's MenuBarExtra: MenuBarExtra turns
/// its label into a one-colour icon plus plain text, which can't show the
/// coloured session strip or keep the digits monospaced.
///
/// The item is the mini session strip followed by mm:ss (unless that's
/// turned off in Settings). Before a session starts it shows an empty strip
/// and the first block's full length (25:00).
@MainActor
final class StatusItemController: NSObject {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let panel: MenuBarPanel
    private let updates: PanelUpdates
    private let timer: SessionTimer
    private let settings: SettingsStore
    private var subscriptions: Set<AnyCancellable> = []
    private var appearanceObservation: NSKeyValueObservation?
    /// What the strip image was last drawn from, so it's only redrawn on change.
    private var drawnStrip: MenuBarStrip?
    private var drawnOnDark = false
    private var drawnWithText = true
    /// Each page's natural height. Both are the same in every state (see
    /// TimerView), so they're measured once.
    private let pageHeights: [PanelPage: CGFloat]

    /// When the panel last closed. Clicking the menu bar item while the panel
    /// is open can close it (focus moves away) just before the click arrives;
    /// without this check that click would immediately reopen it.
    private var lastClosed = Date.distantPast

    init(timer: SessionTimer, settings: SettingsStore, notifier: Notifier, loginItem: LoginItem,
         shortcut: GlobalShortcut) {
        self.timer = timer
        self.settings = settings
        updates = PanelUpdates(timer: timer)
        panel = MenuBarPanel(content: PanelView(timer: timer, settings: settings, notifier: notifier,
                                                loginItem: loginItem, shortcut: shortcut, updates: updates))
        pageHeights = [
            .timer: Self.height(of: TimerView(timer: timer, updates: updates, onSettings: {})),
            .settings: Self.height(of: SettingsView(settings: settings, notifier: notifier,
                                                    loginItem: loginItem, shortcut: shortcut,
                                                    sessionInProgress: false, accent: Theme.Colors.focus,
                                                    onBack: {})),
        ]
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

        // The timer and settings announce changes just before making them,
        // so read their new values on the next main-queue pass.
        timer.objectWillChange.merge(with: settings.objectWillChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &subscriptions)
        refresh()

        // Fit the window to the page, now and whenever it changes.
        updates.$page
            .sink { [weak self] page in self?.fitPanel(to: page) }
            .store(in: &subscriptions)

        panel.onClose = { [weak self] in
            self?.lastClosed = Date()
            self?.updates.isOpen = false
            // Always open on the timer page.
            self?.updates.page = .timer
            self?.statusItem.button?.highlight(false)
        }
        panel.onKeyDown = { [weak self] event in self?.handleKey(event) ?? false }
    }

    /// Space and S on the timer page. Settings has switches and steppers of
    /// its own, so keys are left alone there.
    private func handleKey(_ event: NSEvent) -> Bool {
        guard updates.page == .timer,
              event.modifierFlags.intersection([.command, .option, .control]).isEmpty else { return false }
        let command: PanelCommand
        switch event.charactersIgnoringModifiers?.lowercased() {
        case " ": command = .playPause
        case "s": command = .skip
        default: return false
        }
        // Holding the key down shouldn't flick between start and pause.
        if !event.isARepeat {
            updates.commands.send(command)
        }
        return true
    }

    /// Bring the strip and mm:ss up to date, touching only what changed.
    private func refresh() {
        guard let button = statusItem.button else { return }

        let withText = settings.showCountdownInMenuBar
        let title = withText ? TimeFormat.minutesSeconds(timer.remaining) : ""
        if button.title != title {
            button.title = title
        }
        let position: NSControl.ImagePosition = withText ? .imageLeading : .imageOnly
        if button.imagePosition != position {
            button.imagePosition = position
        }

        let strip = MenuBarStrip(plan: timer.plan, current: timer.blockIndex, remaining: timer.remaining)
        let onDark = button.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
        guard strip != drawnStrip || onDark != drawnOnDark || withText != drawnWithText else { return }
        button.image = MenuBarStripImage.make(strip, onDarkMenuBar: onDark, withTextGap: withText)
        drawnStrip = strip
        drawnOnDark = onDark
        drawnWithText = withText
    }

    private func fitPanel(to page: PanelPage) {
        guard let height = pageHeights[page] else { return }
        panel.setContentHeight(height, animated: panel.isVisible)
    }

    private static func height(of page: some View) -> CGFloat {
        NSHostingView(rootView: page).fittingSize.height
    }

    /// Also called by the global shortcut.
    @objc func togglePanel() {
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
