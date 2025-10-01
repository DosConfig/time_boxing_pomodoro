import Foundation
import Flutter
import UserNotifications
import ActivityKit

// MARK: - Activity Attributes

@available(iOS 16.1, *)
struct PomodoroActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var remainingTime: Int  // in seconds
        var status: String      // "running", "paused", "break"
        var sessionCount: Int
    }

    var totalDuration: Int  // in seconds
}

class PomodoroTimerManager: NSObject {
    private var channel: FlutterMethodChannel
    private var timer: Timer?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    private var startTime: Date?
    private var targetDuration: TimeInterval = 0
    private var pausedRemainingTime: TimeInterval = 0
    private var isPaused: Bool = false
    private var sessionCount: Int = 0

    private var currentActivity: Any?

    init(channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()

        // Background notification observer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Timer Control

    func startTimer(duration: Int, sessionCount: Int = 0) {
        stopTimer()

        startTime = Date()
        targetDuration = TimeInterval(duration)
        pausedRemainingTime = 0
        isPaused = false
        self.sessionCount = sessionCount

        scheduleLocalNotification(after: duration)
        startRepeatingTimer()

        if #available(iOS 16.1, *) {
            startLiveActivity(duration: duration, sessionCount: sessionCount)
        }
    }

    func pauseTimer() {
        guard !isPaused else { return }

        isPaused = true
        pausedRemainingTime = getRemainingTime()

        timer?.invalidate()
        timer = nil

        cancelLocalNotification()

        if #available(iOS 16.1, *) {
            updateLiveActivity(status: "paused")
        }
    }

    func resumeTimer() {
        guard isPaused else { return }

        isPaused = false
        startTime = Date()
        targetDuration = pausedRemainingTime

        scheduleLocalNotification(after: Int(pausedRemainingTime))
        startRepeatingTimer()

        if #available(iOS 16.1, *) {
            updateLiveActivity(status: "running")
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        startTime = nil
        pausedRemainingTime = 0
        isPaused = false

        cancelLocalNotification()
        endBackgroundTask()

        if #available(iOS 16.1, *) {
            endLiveActivity()
        }
    }

    func getRemainingTime() -> TimeInterval {
        if isPaused {
            return pausedRemainingTime
        }

        guard let start = startTime else { return 0 }

        let elapsed = Date().timeIntervalSince(start)
        let remaining = max(0, targetDuration - elapsed)

        return remaining
    }

    // MARK: - Private Methods

    private func startRepeatingTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            let remaining = self.getRemainingTime()

            // Send update to Flutter
            self.channel.invokeMethod("onTick", arguments: ["remainingTime": Int(remaining)])

            // Update Live Activity
            if #available(iOS 16.1, *) {
                self.updateLiveActivity(status: "running")
            }

            if remaining <= 0 {
                self.onTimerComplete()
            }
        }
    }

    private func onTimerComplete() {
        stopTimer()
        channel.invokeMethod("onComplete", arguments: nil)
    }

    // MARK: - Local Notification

    private func scheduleLocalNotification(after seconds: Int) {
        cancelLocalNotification()

        let content = UNMutableNotificationContent()
        content.title = "Pomodoro Timer"
        content.body = "Time's up! Take a break."
        content.sound = .default
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
        let request = UNNotificationRequest(identifier: "pomodoro_complete", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }

        // Schedule ongoing notification for lock screen
        scheduleOngoingNotification(duration: seconds)
    }

    private func scheduleOngoingNotification(duration: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Pomodoro Running"
        content.body = formatTime(seconds: duration)
        content.sound = nil
        content.categoryIdentifier = "POMODORO_RUNNING"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "pomodoro_running", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    private func cancelLocalNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["pomodoro_complete", "pomodoro_running"])
    }

    // MARK: - Background Task

    @objc private func appDidEnterBackground() {
        beginBackgroundTask()
    }

    @objc private func appWillEnterForeground() {
        // Sync with actual elapsed time
        if !isPaused, let _ = startTime {
            let remaining = getRemainingTime()
            channel.invokeMethod("onTick", arguments: ["remainingTime": Int(remaining)])

            if remaining <= 0 {
                onTimerComplete()
            }
        }
    }

    private func beginBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }

    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }

    // MARK: - Live Activity

    @available(iOS 16.1, *)
    private func startLiveActivity(duration: Int, sessionCount: Int) {
        // End existing activity
        if let activity = currentActivity as? Activity<PomodoroActivityAttributes> {
            Task {
                await activity.end(dismissalPolicy: .immediate)
            }
        }

        let attributes = PomodoroActivityAttributes(totalDuration: duration)
        let contentState = PomodoroActivityAttributes.ContentState(
            remainingTime: duration,
            status: "running",
            sessionCount: sessionCount
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil
            )
            currentActivity = activity
            print("Live Activity started")
        } catch {
            print("Error starting Live Activity: \(error)")
        }
    }

    @available(iOS 16.1, *)
    private func updateLiveActivity(status: String) {
        guard let activity = currentActivity as? Activity<PomodoroActivityAttributes> else { return }

        let remainingTime = Int(getRemainingTime())
        let contentState = PomodoroActivityAttributes.ContentState(
            remainingTime: remainingTime,
            status: status,
            sessionCount: sessionCount
        )

        Task {
            // AlertConfiguration으로 즉시 업데이트 보장
            await activity.update(
                ActivityContent(
                    state: contentState,
                    staleDate: nil
                ),
                alertConfiguration: nil
            )
        }
    }

    @available(iOS 16.1, *)
    private func endLiveActivity() {
        guard let activity = currentActivity as? Activity<PomodoroActivityAttributes> else { return }

        Task {
            await activity.end(dismissalPolicy: .immediate)
            currentActivity = nil
        }
    }

    // MARK: - Utility

    private func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}
