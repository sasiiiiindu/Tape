import AppKit
import SwiftUI

/// Draws a MenuBarStrip as the menu bar item's picture.
///
/// AppKit because a status item only shows an NSImage. The image is not a
/// template, so macOS keeps its colours instead of turning it into a
/// one-colour icon. Because of that macOS also won't adapt it to a light or
/// dark menu bar, so the caller says which one it's drawing for.
enum MenuBarStripImage {
    static func make(_ strip: MenuBarStrip, onDarkMenuBar dark: Bool) -> NSImage {
        let future = (dark ? NSColor.white : NSColor.black).withAlphaComponent(
            dark ? Theme.MenuBar.futureOpacityOnDark : Theme.MenuBar.futureOpacityOnLight
        )
        // Extra width on the right is the gap before the digits.
        let size = NSSize(width: Theme.MenuBar.stripWidth + Theme.MenuBar.stripToText,
                          height: Theme.MenuBar.stripHeight)

        let image = NSImage(size: size, flipped: false) { _ in
            for segment in strip.segments {
                let rect = NSRect(x: segment.x, y: 0, width: segment.width, height: Theme.MenuBar.stripHeight)
                let radius = min(Theme.MenuBar.cornerRadius, segment.width / 2)
                let shape = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)

                future.setFill()
                shape.fill()

                guard segment.filled > 0 else { continue }
                NSGraphicsContext.saveGraphicsState()
                shape.addClip()
                NSColor(Theme.Colors.accent(for: segment.kind)).setFill()
                NSRect(x: segment.x, y: 0, width: segment.filled, height: Theme.MenuBar.stripHeight).fill()
                NSGraphicsContext.restoreGraphicsState()
            }
            return true
        }
        image.isTemplate = false
        image.accessibilityDescription = "Session progress"
        return image
    }
}
