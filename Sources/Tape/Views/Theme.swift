import SwiftUI

/// Every colour, font, size and timing the panel uses, in one place.
/// Values come from docs/DESIGN.md; change them here, not in the views.
enum Theme {
    enum Colors {
        static let focus = Color(hex: 0xF2685A)
        static let breakTime = Color(hex: 0x8CC4A4)
        static let text = Color(hex: 0xF5F5F7)
        static let secondary = Color(hex: 0xA8A8B0)
        /// Fill behind the restart and skip buttons.
        static let track = Color.white.opacity(0.10)
        static let divider = Color.white.opacity(0.09)
        /// Icons and text drawn on top of the accent colour.
        static let onAccent = Color(hex: 0x1C1C1E)
        /// Outline of the stand-in box where the tape will go (Phase 4).
        static let placeholder = Color.white.opacity(0.18)

        static func accent(for kind: BlockKind) -> Color {
            switch kind {
            case .focus: focus
            case .break: breakTime
            }
        }
    }

    enum Fonts {
        static let countdown = Font.system(size: 56, weight: .light, design: .rounded).monospacedDigit()
        /// Takes the countdown's place once the session is over.
        static let complete = Font.system(size: 28, weight: .regular, design: .rounded)
        static let header = Font.system(size: 13, weight: .semibold)
        static let secondary = Font.system(size: 12)
        static let button = Font.system(size: 12, weight: .medium)
        static let playIcon = Font.system(size: 13, weight: .bold)
        static let restartIcon = Font.system(size: 14, weight: .semibold)
        static let settingsIcon = Font.system(size: 13, weight: .medium)
        static let placeholder = Font.system(size: 10, weight: .medium)
    }

    enum Sizes {
        static let panelWidth: CGFloat = 320
        static let panelPadding = EdgeInsets(top: 18, leading: 20, bottom: 16, trailing: 20)
        /// Gap between header, countdown, tape and footer.
        static let sectionSpacing: CGFloat = 18

        static let modeDot: CGFloat = 8
        static let modeDotSpacing: CGFloat = 8
        static let settingsSpacing: CGFloat = 12

        static let countdownToSubline: CGFloat = 2
        static let playButton: CGFloat = 48
        static let restartButton: CGFloat = 34
        static let controlSpacing: CGFloat = 10

        static let tapeWidth: CGFloat = 280
        static let tapeHeight: CGFloat = 70

        static let dividerToFooter: CGFloat = 12
        /// Skip, and New session once the session is complete.
        static let footerButtonHeight: CGFloat = 28
        static let footerButtonRadius: CGFloat = 8
        static let footerButtonPadding: CGFloat = 12

        /// Opacity of a button while it's held down, and while it's disabled.
        static let pressedOpacity: Double = 0.7
        static let disabledOpacity: Double = 0.35
    }

    enum Motion {
        /// Focus <-> break colour change.
        static let accentChange = Animation.easeInOut(duration: 0.6)
    }
}

private extension Color {
    /// `Color(hex: 0xF2685A)`.
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
