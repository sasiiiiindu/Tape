import SwiftUI

@main
struct TapeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // The menu bar item and its panel are created by AppDelegate.
        // SwiftUI needs at least one scene, so this one stays empty.
        Settings {
            EmptyView()
        }
    }
}
