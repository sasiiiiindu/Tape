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
        static let tapeLabel = Font.system(size: 10, weight: .medium)
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

    /// The tape: a strip of minute ticks sliding under a fixed needle.
    /// All y values are measured down from the top of the 70 pt window.
    enum Tape {
        static let minuteWidth: CGFloat = 7
        /// Where the needle sits, from the left edge of the window.
        static let needleX: CGFloat = 84
        /// How much of each edge fades out (0.14 = 14% of the width).
        static let edgeFade: CGFloat = 0.14

        static let tickWidth: CGFloat = 2
        /// Ticks stand on this line.
        static let tickBaseline: CGFloat = 56
        static let minuteTickHeight: CGFloat = 10
        static let fiveMinuteTickHeight: CGFloat = 18
        static let boundaryTickHeight: CGFloat = 30

        static let pastTickOpacity: Double = 0.22
        static let minuteTickOpacity: Double = 0.50
        static let fiveMinuteTickOpacity: Double = 0.95
        static let boundaryTickOpacity: Double = 0.85

        static let bandTop: CGFloat = 60
        static let bandHeight: CGFloat = 5
        /// Gap left at each end of a band, so neighbouring blocks don't touch.
        static let bandInset: CGFloat = 2
        static let pastBandOpacity: Double = 0.25
        static let currentBandOpacity: Double = 1
        static let futureBandOpacity: Double = 0.60

        /// Vertical centre of the "Focus 1" / "Break" labels.
        static let labelCenterY: CGFloat = 8
        /// Gap between a block's start and its label.
        static let labelInset: CGFloat = 4

        static let needleWidth: CGFloat = 2
        static let needleHeight: CGFloat = 38
        static let needleDot: CGFloat = 8

        /// Extra room drawn on both ends of the strip, for the end ticks and
        /// the last label.
        static let stripPadding: CGFloat = 60
        /// How far the strip should move between redraws while running. The
        /// redraw rate follows from it: about once a second at normal speed,
        /// about 28 times a second in fast mode.
        static let stepPerFrame: CGFloat = 0.25
        static let fastestFrame: TimeInterval = 1.0 / 60
        static let slowestFrame: TimeInterval = 1
    }

    enum Motion {
        /// Focus <-> break colour change.
        static let accentChange = Animation.easeInOut(duration: 0.6)
        /// Skip, Restart and New session slide the tape instead of jumping.
        static let tapeSlide: TimeInterval = 0.4
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
