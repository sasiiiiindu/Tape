import Combine

/// The two pages of the panel. Settings slides in over the timer.
enum PanelPage {
    case timer
    case settings
}

/// Keys pressed while the timer page is showing: Space and S.
enum PanelCommand {
    /// Start, pause or resume, or New session once the session is complete.
    case playPause
    /// Skip, or Finish on the last block.
    case skip
}

/// Passes the timer's changes on to the panel, but only while the panel is
/// open. A closed panel then costs nothing: SwiftUI isn't asked to refresh a
/// window nobody can see, and the tape stops animating. Opening the panel
/// refreshes everything at once.
///
/// Also holds which page is showing, so the window (AppKit) can resize to
/// fit it and go back to the timer page when the panel closes, and passes
/// key presses on to the timer page.
@MainActor
final class PanelUpdates: ObservableObject {
    @Published var isOpen = false
    @Published var page = PanelPage.timer
    let commands = PassthroughSubject<PanelCommand, Never>()
    private var forwarding: AnyCancellable?

    init(timer: SessionTimer) {
        forwarding = timer.objectWillChange.sink { [weak self] _ in
            guard let self, self.isOpen else { return }
            self.objectWillChange.send()
        }
    }
}
