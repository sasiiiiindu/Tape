/// What a block of the session is for.
enum BlockKind: Equatable {
    case focus
    case `break`

    var title: String {
        switch self {
        case .focus: "Focus"
        case .break: "Break"
        }
    }
}
