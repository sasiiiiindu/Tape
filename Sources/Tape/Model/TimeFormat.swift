import Foundation

enum TimeFormat {
    /// 1499.2 seconds -> "25:00". Rounds up, so "00:00" only shows at the end.
    static func minutesSeconds(_ seconds: TimeInterval) -> String {
        let total = max(0, Int(seconds.rounded(.up)))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }

    /// "7:50 PM" (or "19:50", following the user's system setting).
    static func clock(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }
}
