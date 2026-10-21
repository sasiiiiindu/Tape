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

    init<Content: View>(content: Content) {
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

        // System blur material, rounded with a mask, like the native menu bar window.
        let background = NSVisualEffectView()
        background.material = .popover
        background.blendingMode = .behindWindow
        background.state = .active
        background.maskImage = Self.roundedMask(radius: 12)

        let hostingView = NSHostingView(rootView: content)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        background.addSubview(hostingView)
        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: background.trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: background.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: background.bottomAnchor),
        ])

        contentView = background
        setContentSize(hostingView.fittingSize)
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
