import AppKit
import SwiftUI

/// The borderless window that drops down from the menu bar item and hosts the
/// SwiftUI panel. AppKit because we replaced MenuBarExtra (see
/// StatusItemController); NSPopover was ruled out because it always draws an
/// arrow, which the design doesn't have.
///
/// Closes on Esc or when the user clicks anywhere else.
final class MenuBarPanel: NSPanel {
    var onClose: (() -> Void)?
    /// Keys nothing in the panel used. Returns true if it used the key.
    var onKeyDown: ((NSEvent) -> Bool)?
    private let hostingView: NSView

    init<Content: View>(content: Content) {
        let hostingView = NSHostingView(rootView: content)
        // The window's height is set with setContentHeight, never by the
        // SwiftUI content: while the pages slide, the content is briefly both
        // pages at once, and the panel shouldn't grow to fit both.
        hostingView.sizingOptions = []
        self.hostingView = hostingView
        super.init(
            contentRect: .zero,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: true
        )
        isFloatingPanel = true
        level = .popUpMenu
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        isReleasedWhenClosed = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        animationBehavior = .utilityWindow
        // Dark only until light mode (Phase 8). Set on the window, not in
        // SwiftUI, because the blur below is AppKit and SwiftUI's colour
        // scheme doesn't reach it.
        appearance = NSAppearance(named: .darkAqua)

        // System blur material, rounded with a mask, like the native menu bar window.
        let background = NSVisualEffectView()
        background.material = .popover
        background.blendingMode = .behindWindow
        background.state = .active
        background.maskImage = Self.roundedMask(radius: 12)

        hostingView.translatesAutoresizingMaskIntoConstraints = false
        background.addSubview(hostingView)
        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: background.trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: background.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: background.bottomAnchor),
        ])

        contentView = background
    }

    /// Make the panel `height` tall, keeping its top edge where it is, since
    /// it hangs from the menu bar. Animated while open, so it grows or shrinks
    /// along with the pages sliding.
    func setContentHeight(_ height: CGFloat, animated: Bool) {
        var frame = self.frame
        frame.origin.y = frame.maxY - height
        frame.size = NSSize(width: Theme.Sizes.panelWidth, height: height)
        guard animated else {
            setFrame(frame, display: false)
            return
        }
        NSAnimationContext.runAnimationGroup { context in
            context.duration = Theme.Motion.pageSlide
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animator().setFrame(frame, display: true)
        }
    }

    // Borderless windows can't take keyboard focus by default; we need it for
    // Esc and for "click elsewhere to close".
    override var canBecomeKey: Bool { true }

    override func resignKey() {
        super.resignKey()
        close()
    }

    override func cancelOperation(_ sender: Any?) {
        close()
    }

    override func keyDown(with event: NSEvent) {
        if onKeyDown?(event) == true { return }
        super.keyDown(with: event)
    }

    // ⌘Q while the panel is open. There's no app menu to give Quit a
    // shortcut, since Tape has no Dock icon.
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        // Only these four, so Caps Lock being on doesn't stop the match.
        if event.modifierFlags.intersection([.command, .shift, .option, .control]) == .command,
           event.charactersIgnoringModifiers == "q" {
            NSApp.terminate(nil)
            return true
        }
        return super.performKeyEquivalent(with: event)
    }

    // Closing gives up focus, which calls resignKey(), which calls close()
    // again. The flag makes that second call do nothing.
    private var isClosing = false

    override func close() {
        guard !isClosing else { return }
        isClosing = true
        super.close()
        onClose?()
        isClosing = false
    }

    private static func roundedMask(radius: CGFloat) -> NSImage {
        let edge = radius * 2 + 1
        let image = NSImage(size: NSSize(width: edge, height: edge), flipped: false) { rect in
            NSColor.black.setFill()
            NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius).fill()
            return true
        }
        image.capInsets = NSEdgeInsets(top: radius, left: radius, bottom: radius, right: radius)
        image.resizingMode = .stretch
        return image
    }
}
