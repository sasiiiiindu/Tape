/// What a block of the session is for.
enum BlockKind: Equatable {
    case focus
    case `break`
    /// Takes the place of a break after every few rounds, if turned on.
    case longBreak

    var title: String {
        switch self {
        case .focus: "Focus"
        case .break: "Break"
        case .longBreak: "Long break"
        }
    }
}
