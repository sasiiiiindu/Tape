enum TimerState: Equatable {
    /// Session not started yet.
    case idle
    case running
    case paused
    /// Every block has ended.
    case finished
}
