/// The sound played when a block ends, chosen in Settings.
enum AlertSound: String, CaseIterable {
    case softChime
    case bell
    case none

    var title: String {
        switch self {
        case .softChime: "Soft chime"
        case .bell: "Bell"
        case .none: "None"
        }
    }

    /// One of the sounds built into macOS (in /System/Library/Sounds), so
    /// Tape ships no audio files. Nil plays nothing.
    var systemName: String? {
        switch self {
        case .softChime: "Glass"
        case .bell: "Ping"
        case .none: nil
        }
    }
}
