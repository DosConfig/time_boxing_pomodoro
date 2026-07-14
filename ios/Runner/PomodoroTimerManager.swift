import Foundation
import Flutter
import UserNotifications
import ActivityKit

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

    // LA 진단용 — 마지막 시도 결과를 채널로 노출
    var lastActivityStatus: String = "not-attempted"

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
        NSLog("[Pomodoro] native startTimer called — duration=%d session=%d", duration, sessionCount)
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

        // 순서 중요: isPaused를 먼저 세우면 getRemainingTime()이
        // 갱신 전의 pausedRemainingTime(첫 pause 시 0)을 반환해 남은 시간이 오염됨
        pausedRemainingTime = getRemainingTime()
        isPaused = true

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

        // 1초 후부터 반복 (초기값은 startTimer에서 이미 보냄)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.sendTick()
        }
    }

    private func sendTick() {
        let remaining = Int(self.getRemainingTime())

        // 네이티브 타이머가 진실의 원천 — 매초 Flutter UI에 잔여 시간 전달
        // (Live Activity는 Text(timerInterval:)로 OS가 자체 카운트다운)
        channel.invokeMethod("onTick", arguments: ["remainingTime": remaining])

        if remaining <= 0 {
            self.onTimerComplete()
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
        let endTime = Date().addingTimeInterval(TimeInterval(duration))
        let contentState = PomodoroActivityAttributes.ContentState(
            endTime: endTime,
            status: "running",
            sessionCount: sessionCount,
            pausedRemainingSeconds: nil
        )

        // Check if Live Activities are enabled
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            lastActivityStatus = "DISABLED — 설정에서 Live Activities 꺼짐"
            NSLog("[Pomodoro] ⚠️ Live Activities are NOT enabled (ActivityAuthorizationInfo)")
            return
        }

        do {
            let activity = try Activity.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil
            )
            currentActivity = activity
            lastActivityStatus = "STARTED — id=\(activity.id.prefix(8))"
            NSLog("[Pomodoro] ✅ Live Activity started — id=%@ duration=%d", activity.id, duration)
        } catch {
            lastActivityStatus = "ERROR — \(error.localizedDescription)"
            NSLog("[Pomodoro] ❌ Live Activity request failed: %@", String(describing: error))
        }
    }

    @available(iOS 16.1, *)
    private func updateLiveActivity(status: String) {
        guard let activity = currentActivity as? Activity<PomodoroActivityAttributes> else { return }

        let contentState: PomodoroActivityAttributes.ContentState

        if status == "paused" {
            // 일시정지: 남은 시간을 초로 저장
            let remaining = Int(getRemainingTime())
            contentState = PomodoroActivityAttributes.ContentState(
                endTime: Date(), // paused일 때는 의미 없음
                status: status,
                sessionCount: sessionCount,
                pausedRemainingSeconds: remaining
            )
        } else if status == "running" {
            // 재개: 새로운 종료 시각 계산
            let remaining = getRemainingTime()
            let newEndTime = Date().addingTimeInterval(remaining)
            contentState = PomodoroActivityAttributes.ContentState(
                endTime: newEndTime,
                status: status,
                sessionCount: sessionCount,
                pausedRemainingSeconds: nil
            )
        } else {
            // break 등
            let remaining = getRemainingTime()
            let endTime = Date().addingTimeInterval(remaining)
            contentState = PomodoroActivityAttributes.ContentState(
                endTime: endTime,
                status: status,
                sessionCount: sessionCount,
                pausedRemainingSeconds: nil
            )
        }

        Task {
            await activity.update(using: contentState)
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
