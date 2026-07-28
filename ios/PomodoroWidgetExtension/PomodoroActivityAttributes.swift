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
        var totalDuration: Int // 구간이 바뀌어도 같은 LA를 재사용하기 위한 동적 값
        var pausedRemainingSeconds: Int?  // 일시정지 시 남은 시간
        var topPriorities: [String]
        var currentTimeBoxTitle: String
        var currentTimeBoxTimeRange: String
        var localizedFocusTitle: String
        var localizedShortBreakTitle: String
        var localizedLongBreakTitle: String
        var localizedPausedTitle: String
        var localizedTopPriorityLabel: String
    }

    // 세션 전체에서 바뀌지 않는 식별자만 attributes에 둔다.
    var sessionID: String
}
