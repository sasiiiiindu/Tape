import Combine

/// Passes the timer's changes on to the panel, but only while the panel is
/// open. A closed panel then costs nothing: SwiftUI isn't asked to refresh a
/// window nobody can see, and the tape stops animating. Opening the panel
/// refreshes everything at once.
@MainActor
final class PanelUpdates: ObservableObject {
    @Published var isOpen = false
    private var forwarding: AnyCancellable?

    init(timer: SessionTimer) {
        forwarding = timer.objectWillChange.sink { [weak self] _ in
            guard let self, self.isOpen else { return }
            self.objectWillChange.send()
        }
    }
}
