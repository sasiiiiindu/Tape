import SwiftUI

/// The session the settings describe, as a strip of its blocks in their
/// colours, with its length underneath. Under way, a note says changes wait
/// for the next session.
struct SessionPreview: View {
    let plan: SessionPlan
    let sessionInProgress: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Settings.previewToCaption) {
            Canvas { context, _ in
                let strip = MenuBarStrip(
                    plan: plan, current: 0, remaining: plan.blocks[0].duration,
                    width: Theme.Settings.previewWidth, gap: Theme.Settings.previewGap
                )
                for segment in strip.segments {
                    let rect = CGRect(x: segment.x, y: 0, width: segment.width, height: Theme.Settings.previewHeight)
                    let radius = min(Theme.Settings.previewHeight, segment.width) / 2
                    context.fill(Path(roundedRect: rect, cornerRadius: radius),
                                 with: .color(Theme.Colors.accent(for: segment.kind)))
                }
            }
            .frame(width: Theme.Settings.previewWidth, height: Theme.Settings.previewHeight)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text("Total \(TimeFormat.hoursMinutes(plan.totalDuration)) · "
                     + "\(TimeFormat.hoursMinutes(plan.focusDuration)) focus")
                    .foregroundStyle(Theme.Colors.secondary)
                // Always laid out, so the page keeps its height.
                Text("Applies to your next session")
                    .foregroundStyle(Theme.Colors.text)
                    .opacity(sessionInProgress ? 1 : 0)
                    .accessibilityHidden(!sessionInProgress)
            }
            .font(Theme.Fonts.secondary)
        }
    }
}
