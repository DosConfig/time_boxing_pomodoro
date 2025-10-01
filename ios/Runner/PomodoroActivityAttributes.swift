import Foundation
import ActivityKit

// MARK: - Activity Attributes

struct PomodoroActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var remainingTime: Int  // in seconds
        var status: String      // "running", "paused", "break"
        var sessionCount: Int
    }

    var totalDuration: Int  // in seconds
}
