import SwiftUI

/// Contents of the drop-down panel: the timer page, or the settings page
/// slid in over it from the right.
///
/// The window (StatusItemController) resizes to fit each page, growing and
/// shrinking from the bottom while the pages slide.
struct PanelView: View {
    let timer: SessionTimer
    let settings: SettingsStore
    /// Redraws the panel when the timer changes, but only while it's open.
    @ObservedObject var updates: PanelUpdates

    var body: some View {
        ZStack(alignment: .top) {
            switch updates.page {
            case .timer:
                TimerView(timer: timer, updates: updates) { show(.settings) }
                    .pinnedToTop()
                    .transition(.move(edge: .leading))
            case .settings:
                SettingsView(
                    settings: settings,
                    sessionInProgress: timer.state != .idle,
                    accent: Theme.Colors.accent(for: timer.currentBlock.kind)
                ) { show(.timer) }
                    .pinnedToTop()
                    .transition(.move(edge: .trailing))
            }
        }
        .frame(width: Theme.Sizes.panelWidth)
        .clipped()
    }

    private func show(_ page: PanelPage) {
        withAnimation(.easeInOut(duration: Theme.Motion.pageSlide)) {
            updates.page = page
        }
    }
}

private extension View {
    /// Lays a page out at its natural height at the top of the window,
    /// whatever the window's height is right now. Every page then takes up
    /// the whole window, so swapping pages never changes the content's size;
    /// only the sideways slide animates, and the window resizes around it.
    func pinnedToTop() -> some View {
        fixedSize(horizontal: false, vertical: true)
            .frame(minHeight: 0, maxHeight: .infinity, alignment: .top)
    }
}
