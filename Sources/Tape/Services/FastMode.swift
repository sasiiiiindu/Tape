import Foundation

/// How many session seconds pass per real second. Always 1 in a normal build.
///
/// Fast mode only exists in builds made with `scripts/build-app.sh --fast`,
/// which compiles with the TAPE_FAST flag. The shipped app doesn't contain
/// this code at all, so no setting or environment can speed it up.
enum FastMode {
    static let speed: Double = {
        #if TAPE_FAST
        if let value = ProcessInfo.processInfo.environment["TAPE_SPEED"],
           let speed = Double(value), speed > 0 {
            return speed
        }
        #endif
        return 1
    }()
}
