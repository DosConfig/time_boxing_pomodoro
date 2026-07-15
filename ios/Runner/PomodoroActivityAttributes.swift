import Foundation
import ActivityKit

// MARK: - Activity Attributes

@available(iOS 16.1, *)
struct PomodoroActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var endTime: Date       // 종료 시각 (절대 시간)
        var status: String      // "running", "paused", "break"
        var phase: String       // "focus", "shortBreak", "longBreak"
        var sessionCount: Int
        var sessionGoal: Int
        var pausedRemainingSeconds: Int?  // 일시정지 시 남은 시간
    }

    var totalDuration: Int  // in seconds
}
