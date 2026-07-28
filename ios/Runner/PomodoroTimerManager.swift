import Foundation
import Flutter
import UserNotifications
import ActivityKit

struct NativeTimerCopy {
    let focusTitle: String
    let shortBreakTitle: String
    let longBreakTitle: String
    let pausedTitle: String
    let focusBlockTitle: String
    let breakBlockTitle: String
    let topPriorityLabel: String
    let focusInProgressTitle: String
    let shortBreakInProgressTitle: String
    let longBreakInProgressTitle: String
    let remainingTimeFormat: String
    let focusCompleteTitle: String
    let breakCompleteTitle: String
    let focusCompleteBody: String
    let breakCompleteBody: String

    init(dictionary: [String: String] = [:]) {
        func value(_ key: String, fallback: String) -> String {
            let raw = dictionary[key]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return raw.isEmpty ? fallback : raw
        }

        focusTitle = value("focusTitle", fallback: "Focus")
        shortBreakTitle = value("shortBreakTitle", fallback: "Short break")
        longBreakTitle = value("longBreakTitle", fallback: "Long break")
        pausedTitle = value("pausedTitle", fallback: "Paused")
        focusBlockTitle = value("focusBlockTitle", fallback: "Focus block")
        breakBlockTitle = value("breakBlockTitle", fallback: "Break block")
        topPriorityLabel = value("topPriorityLabel", fallback: "Top")
        focusInProgressTitle = value("focusInProgressTitle", fallback: "Focus in progress")
        shortBreakInProgressTitle = value("shortBreakInProgressTitle", fallback: "Short break in progress")
        longBreakInProgressTitle = value("longBreakInProgressTitle", fallback: "Long break in progress")
        remainingTimeFormat = value("remainingTimeFormat", fallback: "%@ remaining")
        focusCompleteTitle = value("focusCompleteTitle", fallback: "Focus complete")
        breakCompleteTitle = value("breakCompleteTitle", fallback: "Break complete")
        focusCompleteBody = value("focusCompleteBody", fallback: "Step away before the next block.")
        breakCompleteBody = value("breakCompleteBody", fallback: "Your next focus block is ready.")
    }

    var dictionary: [String: String] {
        return [
            "focusTitle": focusTitle,
            "shortBreakTitle": shortBreakTitle,
            "longBreakTitle": longBreakTitle,
            "pausedTitle": pausedTitle,
            "focusBlockTitle": focusBlockTitle,
            "breakBlockTitle": breakBlockTitle,
            "topPriorityLabel": topPriorityLabel,
            "focusInProgressTitle": focusInProgressTitle,
            "shortBreakInProgressTitle": shortBreakInProgressTitle,
            "longBreakInProgressTitle": longBreakInProgressTitle,
            "remainingTimeFormat": remainingTimeFormat,
            "focusCompleteTitle": focusCompleteTitle,
            "breakCompleteTitle": breakCompleteTitle,
            "focusCompleteBody": focusCompleteBody,
            "breakCompleteBody": breakCompleteBody
        ]
    }

    func inProgressTitle(for phase: String) -> String {
        switch phase {
        case "shortBreak":
            return shortBreakInProgressTitle
        case "longBreak":
            return longBreakInProgressTitle
        default:
            return focusInProgressTitle
        }
    }

    func remainingBody(time: String) -> String {
        return String(format: remainingTimeFormat, time)
    }
}

class PomodoroTimerManager: NSObject {
    private var channel: FlutterMethodChannel
    private var timer: Timer?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    private var endTime: Date?
    private var targetDuration: TimeInterval = 0
    private var pausedRemainingTime: TimeInterval = 0
    private var isPaused: Bool = false
    private var sessionCount: Int = 0
    private var sessionGoal: Int = 5
    private var currentPhase: String = "focus"
    private var notificationsEnabled: Bool = true
    private var soundEnabled: Bool = true
    private var topPriorities: [String] = []
    private var currentTimeBoxTitle: String = ""
    private var currentTimeBoxTimeRange: String = ""
    private var localizedCopy = NativeTimerCopy()

    private var currentActivity: Any?

    // LA 진단용 — 마지막 시도 결과를 채널로 노출
    var lastActivityStatus: String = "not-attempted"

    // MARK: - State Persistence
    // 앱 프로세스는 백그라운드에서 언제든 종료될 수 있지만 Live Activity는 살아남는다.
    // 타이머 상태를 UserDefaults에 영속화해 재실행 시 복원한다.

    private enum PersistKeys {
        static let isActive = "pomodoro.isActive"
        static let startTime = "pomodoro.startTime"
        static let endTime = "pomodoro.endTime"
        static let targetDuration = "pomodoro.targetDuration"
        static let isPaused = "pomodoro.isPaused"
        static let pausedRemaining = "pomodoro.pausedRemaining"
        static let sessionCount = "pomodoro.sessionCount"
        static let sessionGoal = "pomodoro.sessionGoal"
        static let phase = "pomodoro.phase"
        static let notificationsEnabled = "pomodoro.notificationsEnabled"
        static let soundEnabled = "pomodoro.soundEnabled"
        static let topPriorities = "pomodoro.topPriorities"
        static let currentTimeBoxTitle = "pomodoro.currentTimeBoxTitle"
        static let currentTimeBoxTimeRange = "pomodoro.currentTimeBoxTimeRange"
        static let localizedCopy = "pomodoro.localizedCopy"
    }

    private func persistState() {
        let d = UserDefaults.standard
        d.set(true, forKey: PersistKeys.isActive)
        d.set(endTime?.timeIntervalSince1970 ?? 0, forKey: PersistKeys.endTime)
        d.set(targetDuration, forKey: PersistKeys.targetDuration)
        d.set(isPaused, forKey: PersistKeys.isPaused)
        d.set(pausedRemainingTime, forKey: PersistKeys.pausedRemaining)
        d.set(sessionCount, forKey: PersistKeys.sessionCount)
        d.set(sessionGoal, forKey: PersistKeys.sessionGoal)
        d.set(currentPhase, forKey: PersistKeys.phase)
        d.set(topPriorities, forKey: PersistKeys.topPriorities)
        d.set(currentTimeBoxTitle, forKey: PersistKeys.currentTimeBoxTitle)
        d.set(currentTimeBoxTimeRange, forKey: PersistKeys.currentTimeBoxTimeRange)
        d.set(localizedCopy.dictionary, forKey: PersistKeys.localizedCopy)
        persistNotificationSettings()
    }

    private func persistNotificationSettings() {
        let d = UserDefaults.standard
        d.set(notificationsEnabled, forKey: PersistKeys.notificationsEnabled)
        d.set(soundEnabled, forKey: PersistKeys.soundEnabled)
    }

    private func restoreNotificationSettings() {
        let d = UserDefaults.standard
        if d.object(forKey: PersistKeys.notificationsEnabled) == nil {
            notificationsEnabled = true
        } else {
            notificationsEnabled = d.bool(forKey: PersistKeys.notificationsEnabled)
        }

        if d.object(forKey: PersistKeys.soundEnabled) == nil {
            soundEnabled = true
        } else {
            soundEnabled = d.bool(forKey: PersistKeys.soundEnabled)
        }
    }

    private var notificationSettingsPayload: [String: Any] {
        return [
            "notificationsEnabled": notificationsEnabled,
            "soundEnabled": soundEnabled,
            "topPriorities": topPriorities,
            "currentTimeBoxTitle": currentTimeBoxTitle,
            "currentTimeBoxTimeRange": currentTimeBoxTimeRange
        ]
    }

    private func clearPersistedState() {
        let d = UserDefaults.standard
        d.set(false, forKey: PersistKeys.isActive)
        d.removeObject(forKey: PersistKeys.startTime)
        d.removeObject(forKey: PersistKeys.endTime)
        d.removeObject(forKey: PersistKeys.targetDuration)
        d.removeObject(forKey: PersistKeys.isPaused)
        d.removeObject(forKey: PersistKeys.pausedRemaining)
        d.removeObject(forKey: PersistKeys.sessionCount)
        d.removeObject(forKey: PersistKeys.sessionGoal)
        d.removeObject(forKey: PersistKeys.phase)
        d.removeObject(forKey: PersistKeys.topPriorities)
        d.removeObject(forKey: PersistKeys.currentTimeBoxTitle)
        d.removeObject(forKey: PersistKeys.currentTimeBoxTimeRange)
        d.removeObject(forKey: PersistKeys.localizedCopy)
    }

    private func restoredEndTime(from defaults: UserDefaults) -> Date? {
        let storedEndTime = defaults.double(forKey: PersistKeys.endTime)
        if storedEndTime > 0 {
            return Date(timeIntervalSince1970: storedEndTime)
        }

        // 이전 빌드에서 저장한 startTime + duration 형식도 복원한다.
        let storedStartTime = defaults.double(forKey: PersistKeys.startTime)
        let storedDuration = defaults.double(forKey: PersistKeys.targetDuration)
        guard storedStartTime > 0, storedDuration > 0 else { return nil }
        return Date(timeIntervalSince1970: storedStartTime + storedDuration)
    }

    /// 앱 재실행 시 이전 타이머 상태 복원.
    /// 반환: Flutter 초기 상태 구성용 딕셔너리 (status: idle/running/paused/completed)
    func restoreState() -> [String: Any] {
        let d = UserDefaults.standard
        restoreNotificationSettings()

        guard d.bool(forKey: PersistKeys.isActive) else {
            // 저장된 타이머가 없는데 화면에 Activity가 남아 있으면 고아 — 정리
            if #available(iOS 16.1, *) { Task { await endAllActivities() } }
            return notificationSettingsPayload.merging(["status": "idle"]) { _, new in new }
        }

        sessionCount = d.integer(forKey: PersistKeys.sessionCount)
        if d.object(forKey: PersistKeys.sessionGoal) == nil {
            sessionGoal = 5
        } else {
            sessionGoal = max(1, d.integer(forKey: PersistKeys.sessionGoal))
        }
        isPaused = d.bool(forKey: PersistKeys.isPaused)
        currentPhase = d.string(forKey: PersistKeys.phase) ?? "focus"
        topPriorities = d.stringArray(forKey: PersistKeys.topPriorities) ?? []
        currentTimeBoxTitle = d.string(forKey: PersistKeys.currentTimeBoxTitle) ?? ""
        currentTimeBoxTimeRange = d.string(forKey: PersistKeys.currentTimeBoxTimeRange) ?? ""
        localizedCopy = NativeTimerCopy(dictionary: d.dictionary(forKey: PersistKeys.localizedCopy) as? [String: String] ?? [:])

        if isPaused {
            pausedRemainingTime = d.double(forKey: PersistKeys.pausedRemaining)
            guard pausedRemainingTime > 0 else {
                clearPersistedState()
                if #available(iOS 16.1, *) { Task { await endAllActivities() } }
                return notificationSettingsPayload.merging(["status": "completed", "sessionCount": sessionCount, "sessionGoal": sessionGoal, "phase": currentPhase]) { _, new in new }
            }
            endTime = nil
            targetDuration = pausedRemainingTime
            if #available(iOS 16.1, *) {
                reattachOrRecreateActivity()
                updateLiveActivity(status: "paused")
            }
            NSLog("[Pomodoro] restored: paused, remaining=%d", Int(pausedRemainingTime))
            return notificationSettingsPayload.merging(["status": "paused", "remainingTime": remainingSecondsRoundedUp(), "sessionCount": sessionCount, "sessionGoal": sessionGoal, "phase": currentPhase]) { _, new in new }
        }

        targetDuration = d.double(forKey: PersistKeys.targetDuration)
        guard let restoredEndTime = restoredEndTime(from: d) else {
            clearPersistedState()
            if #available(iOS 16.1, *) { Task { await endAllActivities() } }
            return notificationSettingsPayload.merging(["status": "idle"]) { _, new in new }
        }
        endTime = restoredEndTime
        let remaining = getRemainingTime()

        if remaining <= 0 {
            // 앱이 죽어 있는 동안 완료됨
            endTime = nil
            clearPersistedState()
            if #available(iOS 16.1, *) { Task { await endAllActivities() } }
            NSLog("[Pomodoro] restored: completed while away")
            return notificationSettingsPayload.merging(["status": "completed", "sessionCount": sessionCount, "sessionGoal": sessionGoal, "phase": currentPhase]) { _, new in new }
        }

        // 진행 중이던 타이머 재가동
        if notificationsEnabled {
            scheduleLocalNotification(after: remainingSecondsRoundedUp())
        }
        startRepeatingTimer()
        if #available(iOS 16.1, *) { reattachOrRecreateActivity() }
        NSLog("[Pomodoro] restored: running, remaining=%d", remainingSecondsRoundedUp())
        return notificationSettingsPayload.merging(["status": "running", "remainingTime": remainingSecondsRoundedUp(), "sessionCount": sessionCount, "sessionGoal": sessionGoal, "phase": currentPhase]) { _, new in new }
    }

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

    func startTimer(
        duration: Int,
        sessionCount: Int = 0,
        sessionGoal: Int = 5,
        phase: String = "focus",
        notificationsEnabled: Bool = true,
        soundEnabled: Bool = true,
        topPriorities: [String] = [],
        currentTimeBoxTitle: String = "",
        currentTimeBoxTimeRange: String = "",
        localizedCopy: NativeTimerCopy = NativeTimerCopy()
    ) {
        NSLog("[Pomodoro] native startTimer called — duration=%d session=%d", duration, sessionCount)
        // 다음 focus/break 구간으로 넘어갈 때 기존 Live Activity는 종료하지 않는다.
        // timer/notification만 교체하고 같은 Activity의 ContentState를 갱신한다.
        timer?.invalidate()
        timer = nil
        cancelLocalNotification()
        endBackgroundTask()

        endTime = Date().addingTimeInterval(TimeInterval(duration))
        targetDuration = TimeInterval(duration)
        pausedRemainingTime = 0
        isPaused = false
        self.sessionCount = sessionCount
        self.sessionGoal = max(1, sessionGoal)
        currentPhase = phase
        self.notificationsEnabled = notificationsEnabled
        self.soundEnabled = soundEnabled
        self.localizedCopy = localizedCopy
        self.topPriorities = topPriorities
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .prefix(3)
            .map { String($0) }
        self.currentTimeBoxTitle = currentTimeBoxTitle.isEmpty ? defaultTimeBoxTitle(for: phase) : currentTimeBoxTitle
        self.currentTimeBoxTimeRange = currentTimeBoxTimeRange

        if notificationsEnabled {
            requestNotificationAuthorizationIfNeeded()
            scheduleLocalNotification(after: duration)
        }
        startRepeatingTimer()
        persistState()

        if #available(iOS 16.1, *) {
            Task { await startLiveActivity(duration: duration, sessionCount: sessionCount, endTime: endTime) }
        }
    }

    func pauseTimer() {
        guard !isPaused, endTime != nil else { return }

        // 순서 중요: isPaused를 먼저 세우면 getRemainingTime()이
        // 갱신 전의 pausedRemainingTime(첫 pause 시 0)을 반환해 남은 시간이 오염됨
        pausedRemainingTime = getRemainingTime()
        isPaused = true
        endTime = nil

        timer?.invalidate()
        timer = nil

        cancelLocalNotification()
        persistState()

        if #available(iOS 16.1, *) {
            updateLiveActivity(status: "paused")
        }
    }

    func resumeTimer() {
        guard isPaused else { return }

        isPaused = false
        endTime = Date().addingTimeInterval(pausedRemainingTime)

        if notificationsEnabled {
            scheduleLocalNotification(after: remainingSecondsRoundedUp())
        }
        startRepeatingTimer()
        persistState()

        if #available(iOS 16.1, *) {
            updateLiveActivity(status: "running")
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        endTime = nil
        pausedRemainingTime = 0
        isPaused = false
        sessionGoal = 5
        currentPhase = "focus"
        topPriorities = []
        currentTimeBoxTitle = ""
        currentTimeBoxTimeRange = ""

        cancelLocalNotification()
        endBackgroundTask()
        clearPersistedState()

        if #available(iOS 16.1, *) {
            Task { await endAllActivities() }
        }
    }

    func getRemainingTime() -> TimeInterval {
        if isPaused {
            return pausedRemainingTime
        }

        guard let endTime = endTime else { return 0 }
        return max(0, endTime.timeIntervalSinceNow)
    }

    func updateNotificationSettings(notificationsEnabled: Bool, soundEnabled: Bool) {
        self.notificationsEnabled = notificationsEnabled
        self.soundEnabled = soundEnabled
        persistNotificationSettings()

        if !notificationsEnabled {
            cancelLocalNotification()
        } else if !isPaused, endTime != nil {
            scheduleLocalNotification(after: remainingSecondsRoundedUp())
        }
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
        let remaining = remainingSecondsRoundedUp()

        // 네이티브 타이머가 진실의 원천 — 매초 Flutter UI에 잔여 시간 전달
        // (Live Activity는 Text(timerInterval:)로 OS가 자체 카운트다운)
        channel.invokeMethod("onTick", arguments: ["remainingTime": remaining])

        if remaining <= 0 {
            self.onTimerComplete()
        }
    }

    private func onTimerComplete() {
        // 타이머 상태만 정리하고 LA는 살려둔다.
        // Dart가 다음 phase의 startTimer()를 보내면
        // startLiveActivity() 안에서 기존 LA를 update한다.
        timer?.invalidate()
        timer = nil
        endTime = nil
        pausedRemainingTime = 0
        isPaused = false
        cancelLocalNotification()
        endBackgroundTask()
        clearPersistedState()

        channel.invokeMethod("onComplete", arguments: nil)
    }

    // MARK: - Local Notification

    private func requestNotificationAuthorizationIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    NSLog("[Pomodoro] notification permission error: %@", error.localizedDescription)
                } else {
                    NSLog("[Pomodoro] notification permission granted=%@", granted ? "true" : "false")
                }
            }
        }
    }

    private func scheduleLocalNotification(after seconds: Int) {
        guard notificationsEnabled else { return }
        cancelLocalNotification()
        let safeSeconds = max(1, seconds)

        let content = UNMutableNotificationContent()
        content.title = notificationTitle
        content.body = notificationBody
        content.sound = soundEnabled ? .default : nil
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(safeSeconds), repeats: false)
        let request = UNNotificationRequest(identifier: "pomodoro_complete", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }

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
        if !isPaused, endTime != nil {
            let remaining = getRemainingTime()
            channel.invokeMethod("onTick", arguments: ["remainingTime": remainingSecondsRoundedUp()])

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
    private func startLiveActivity(duration: Int, sessionCount: Int, endTime activityEndTime: Date? = nil) async {
        let endTime = activityEndTime ?? Date().addingTimeInterval(TimeInterval(duration))
        let contentState = PomodoroActivityAttributes.ContentState(
            endTime: endTime,
            status: "running",
            phase: currentPhase,
            sessionCount: sessionCount,
            sessionGoal: sessionGoal,
            totalDuration: duration,
            pausedRemainingSeconds: nil,
            topPriorities: topPriorities,
            currentTimeBoxTitle: currentTimeBoxTitle,
            currentTimeBoxTimeRange: currentTimeBoxTimeRange,
            localizedFocusTitle: localizedCopy.focusTitle,
            localizedShortBreakTitle: localizedCopy.shortBreakTitle,
            localizedLongBreakTitle: localizedCopy.longBreakTitle,
            localizedPausedTitle: localizedCopy.pausedTitle,
            localizedTopPriorityLabel: localizedCopy.topPriorityLabel
        )

        // Check if Live Activities are enabled
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            lastActivityStatus = "DISABLED — 설정에서 Live Activities 꺼짐"
            NSLog("[Pomodoro] ⚠️ Live Activities are NOT enabled (ActivityAuthorizationInfo)")
            return
        }

        // 같은 Pomodoro 세션에서는 새 LA를 만들지 않고 기존 LA를 갱신한다.
        // 프로세스가 재시작돼 currentActivity가 비어 있어도 OS 목록에서 재연결한다.
        let existing = Activity<PomodoroActivityAttributes>.activities
        if let activity = existing.first {
            currentActivity = activity
            await activity.update(using: contentState)
            for extra in existing.dropFirst() {
                await extra.end(dismissalPolicy: .immediate)
            }
            lastActivityStatus = "UPDATED — id=\(activity.id.prefix(8))"
            NSLog("[Pomodoro] ✅ Live Activity updated — id=%@ duration=%d", activity.id, duration)
            return
        }

        do {
            let attributes = PomodoroActivityAttributes(sessionID: UUID().uuidString)
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
            let remaining = remainingSecondsRoundedUp()
            contentState = PomodoroActivityAttributes.ContentState(
                endTime: Date(), // paused일 때는 의미 없음
                status: status,
                phase: currentPhase,
                sessionCount: sessionCount,
                sessionGoal: sessionGoal,
                totalDuration: max(1, Int(targetDuration)),
                pausedRemainingSeconds: remaining,
                topPriorities: topPriorities,
                currentTimeBoxTitle: currentTimeBoxTitle,
                currentTimeBoxTimeRange: currentTimeBoxTimeRange,
                localizedFocusTitle: localizedCopy.focusTitle,
                localizedShortBreakTitle: localizedCopy.shortBreakTitle,
                localizedLongBreakTitle: localizedCopy.longBreakTitle,
                localizedPausedTitle: localizedCopy.pausedTitle,
                localizedTopPriorityLabel: localizedCopy.topPriorityLabel
            )
        } else if status == "running" {
            // 재개: 새로운 종료 시각 계산
            contentState = PomodoroActivityAttributes.ContentState(
                endTime: endTime ?? Date().addingTimeInterval(getRemainingTime()),
                status: status,
                phase: currentPhase,
                sessionCount: sessionCount,
                sessionGoal: sessionGoal,
                totalDuration: max(1, Int(targetDuration)),
                pausedRemainingSeconds: nil,
                topPriorities: topPriorities,
                currentTimeBoxTitle: currentTimeBoxTitle,
                currentTimeBoxTimeRange: currentTimeBoxTimeRange,
                localizedFocusTitle: localizedCopy.focusTitle,
                localizedShortBreakTitle: localizedCopy.shortBreakTitle,
                localizedLongBreakTitle: localizedCopy.longBreakTitle,
                localizedPausedTitle: localizedCopy.pausedTitle,
                localizedTopPriorityLabel: localizedCopy.topPriorityLabel
            )
        } else {
            // break 등
            contentState = PomodoroActivityAttributes.ContentState(
                endTime: endTime ?? Date().addingTimeInterval(getRemainingTime()),
                status: status,
                phase: currentPhase,
                sessionCount: sessionCount,
                sessionGoal: sessionGoal,
                totalDuration: max(1, Int(targetDuration)),
                pausedRemainingSeconds: nil,
                topPriorities: topPriorities,
                currentTimeBoxTitle: currentTimeBoxTitle,
                currentTimeBoxTimeRange: currentTimeBoxTimeRange,
                localizedFocusTitle: localizedCopy.focusTitle,
                localizedShortBreakTitle: localizedCopy.shortBreakTitle,
                localizedLongBreakTitle: localizedCopy.longBreakTitle,
                localizedPausedTitle: localizedCopy.pausedTitle,
                localizedTopPriorityLabel: localizedCopy.topPriorityLabel
            )
        }

        Task {
            await activity.update(using: contentState)
        }
    }

    @available(iOS 16.1, *)
    private func endAllActivities() async {
        for activity in Activity<PomodoroActivityAttributes>.activities {
            await activity.end(dismissalPolicy: .immediate)
        }
        currentActivity = nil
    }

    /// 프로세스 재시작 후: 살아있는 Activity가 있으면 재연결, 없으면 새로 생성.
    /// 여러 개 발견 시 첫 번째만 남기고 정리.
    @available(iOS 16.1, *)
    private func reattachOrRecreateActivity() {
        let existing = Activity<PomodoroActivityAttributes>.activities
        if let first = existing.first {
            currentActivity = first
            for extra in existing.dropFirst() {
                Task { await extra.end(dismissalPolicy: .immediate) }
            }
            // 재연결 후 현재 상태 기준으로 표시 갱신 (endTime 재계산)
            updateLiveActivity(status: isPaused ? "paused" : "running")
            NSLog("[Pomodoro] reattached to activity %@ (extra %d ended)", first.id, existing.count - 1)
        } else {
            let remaining = remainingSecondsRoundedUp()
            Task {
                await startLiveActivity(duration: remaining, sessionCount: sessionCount, endTime: endTime)
                if isPaused {
                    updateLiveActivity(status: "paused")
                }
            }
            NSLog("[Pomodoro] no live activity found — recreated")
        }
    }

    // MARK: - Utility

    private func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }

    private func remainingSecondsRoundedUp() -> Int {
        return max(0, Int(ceil(getRemainingTime())))
    }

    private var phaseTitle: String {
        switch currentPhase {
        case "shortBreak":
            return localizedCopy.shortBreakTitle
        case "longBreak":
            return localizedCopy.longBreakTitle
        default:
            return localizedCopy.focusTitle
        }
    }

    private func defaultTimeBoxTitle(for phase: String) -> String {
        switch phase {
        case "shortBreak", "longBreak":
            return localizedCopy.breakBlockTitle
        default:
            return localizedCopy.focusBlockTitle
        }
    }

    private var notificationTitle: String {
        switch currentPhase {
        case "shortBreak", "longBreak":
            return localizedCopy.breakCompleteTitle
        default:
            return localizedCopy.focusCompleteTitle
        }
    }

    private var notificationBody: String {
        let completionBody: String
        switch currentPhase {
        case "shortBreak", "longBreak":
            completionBody = localizedCopy.breakCompleteBody
        default:
            completionBody = localizedCopy.focusCompleteBody
        }
        return [currentTimeBoxTitle, currentTimeBoxTimeRange, completionBody]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }
}
