import Flutter
import EventKit
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let CHANNEL = "com.pomodoro/timer"
  private let CALENDAR_CHANNEL = "com.pomodoro/calendar"
  private var pomodoroTimer: PomodoroTimerManager?
  private let calendarExporter = AppleCalendarExportManager()
  private let calendarAppLauncher = CalendarAppLauncher()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let messenger = engineBridge.applicationRegistrar.messenger()

    let timerChannel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: messenger)
    pomodoroTimer = PomodoroTimerManager(channel: timerChannel)
    let calendarChannel = FlutterMethodChannel(name: CALENDAR_CHANNEL, binaryMessenger: messenger)

    timerChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else { return }

      NSLog("[Pomodoro] channel call received: %@", call.method)

      switch call.method {
      case "startTimer":
        if let args = call.arguments as? [String: Any],
           let seconds = args["seconds"] as? Int {
          let sessionCount = args["sessionCount"] as? Int ?? 0
          let sessionGoal = args["sessionGoal"] as? Int ?? 5
          let phase = args["phase"] as? String ?? "focus"
          let notificationsEnabled = args["notificationsEnabled"] as? Bool ?? true
          let soundEnabled = args["soundEnabled"] as? Bool ?? true
          let topPriorities = args["topPriorities"] as? [String] ?? []
          let currentTimeBoxTitle = args["currentTimeBoxTitle"] as? String ?? ""
          let currentTimeBoxTimeRange = args["currentTimeBoxTimeRange"] as? String ?? ""
          let localizedCopy = NativeTimerCopy(dictionary: args["localizedCopy"] as? [String: String] ?? [:])
          self.pomodoroTimer?.startTimer(
            duration: seconds,
            sessionCount: sessionCount,
            sessionGoal: sessionGoal,
            phase: phase,
            notificationsEnabled: notificationsEnabled,
            soundEnabled: soundEnabled,
            topPriorities: topPriorities,
            currentTimeBoxTitle: currentTimeBoxTitle,
            currentTimeBoxTimeRange: currentTimeBoxTimeRange,
            localizedCopy: localizedCopy
          )
          result(true)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "seconds required", details: nil))
        }

      case "updateNotificationSettings":
        if let args = call.arguments as? [String: Any] {
          let notificationsEnabled = args["notificationsEnabled"] as? Bool ?? true
          let soundEnabled = args["soundEnabled"] as? Bool ?? true
          self.pomodoroTimer?.updateNotificationSettings(
            notificationsEnabled: notificationsEnabled,
            soundEnabled: soundEnabled
          )
          result(true)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "settings required", details: nil))
        }

      case "pauseTimer":
        self.pomodoroTimer?.pauseTimer()
        result(true)

      case "resumeTimer":
        self.pomodoroTimer?.resumeTimer()
        result(true)

      case "stopTimer":
        self.pomodoroTimer?.stopTimer()
        result(true)

      case "getRemainingTime":
        let remaining = Int(ceil(self.pomodoroTimer?.getRemainingTime() ?? 0))
        result(remaining)

      case "getActivityStatus":
        result(self.pomodoroTimer?.lastActivityStatus ?? "no-manager")

      case "restoreState":
        result(self.pomodoroTimer?.restoreState() ?? ["status": "idle"])

      default:
        result(FlutterMethodNotImplemented)
      }
    }

    calendarChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else { return }

      switch call.method {
      case "exportEvents":
        self.calendarExporter.exportEvents(arguments: call.arguments, result: result)
      case "openCalendar":
        self.calendarAppLauncher.open(arguments: call.arguments, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .list, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }
}

class CalendarAppLauncher {
  func open(arguments: Any?, result: @escaping FlutterResult) {
    guard let args = arguments as? [String: Any],
          let provider = args["provider"] as? String else {
      result(["status": "failed"])
      return
    }

    switch provider {
    case "apple":
      let timestamp = Date().timeIntervalSinceReferenceDate
      open(URL(string: "calshow:\(timestamp)"), successStatus: "opened", result: result)
    case "google":
      let googleCalendar = URL(string: "comgooglecalendar://")
      if let googleCalendar, UIApplication.shared.canOpenURL(googleCalendar) {
        open(googleCalendar, successStatus: "opened", result: result)
        return
      }
      open(
        URL(string: "itms-apps://itunes.apple.com/app/id909319292"),
        successStatus: "storeOpened",
        result: result
      )
    default:
      result(["status": "unavailable"])
    }
  }

  private func open(
    _ url: URL?,
    successStatus: String,
    result: @escaping FlutterResult
  ) {
    guard let url else {
      result(["status": "failed"])
      return
    }
    UIApplication.shared.open(url, options: [:]) { opened in
      result(["status": opened ? successStatus : "unavailable"])
    }
  }
}

class AppleCalendarExportManager {
  private let eventStore = EKEventStore()

  func exportEvents(arguments: Any?, result: @escaping FlutterResult) {
    guard let args = arguments as? [String: Any],
          let events = args["events"] as? [[String: Any]] else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "events required", details: nil))
      return
    }

    guard !events.isEmpty else {
      result(["status": "success", "events": []])
      return
    }

    requestWriteAccess { [weak self] granted, error in
      guard let self = self else { return }

      if let error = error {
        DispatchQueue.main.async {
          result(["status": "failed", "message": error.localizedDescription])
        }
        return
      }

      guard granted else {
        DispatchQueue.main.async {
          result(["status": "denied", "events": []])
        }
        return
      }

      self.saveEvents(events, result: result)
    }
  }

  private func requestWriteAccess(completion: @escaping (Bool, Error?) -> Void) {
    if #available(iOS 17.0, *) {
      eventStore.requestWriteOnlyAccessToEvents(completion: completion)
    } else {
      eventStore.requestAccess(to: .event, completion: completion)
    }
  }

  private func saveEvents(_ eventPayloads: [[String: Any]], result: @escaping FlutterResult) {
    guard let calendar = eventStore.defaultCalendarForNewEvents else {
      DispatchQueue.main.async {
        result(["status": "failed", "message": "No default calendar is available."])
      }
      return
    }

    var exportedEvents: [[String: String]] = []

    do {
      for payload in eventPayloads {
        guard let timeBoxId = payload["timeBoxId"] as? String,
              let startMillis = millisValue(payload["startAtMillis"]),
              let endMillis = millisValue(payload["endAtMillis"]) else {
          continue
        }

        let startDate = Date(timeIntervalSince1970: TimeInterval(startMillis) / 1000)
        let endDate = Date(timeIntervalSince1970: TimeInterval(endMillis) / 1000)
        guard endDate > startDate else { continue }

        let event = EKEvent(eventStore: eventStore)
        event.title = nonEmptyString(payload["title"]) ?? "Timebox"
        event.notes = nonEmptyString(payload["notes"])
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = calendar

        try eventStore.save(event, span: .thisEvent)
        if let eventId = event.eventIdentifier {
          exportedEvents.append(["timeBoxId": timeBoxId, "eventId": eventId])
        }
      }

      DispatchQueue.main.async {
        result(["status": "success", "events": exportedEvents])
      }
    } catch {
      DispatchQueue.main.async {
        result([
          "status": "failed",
          "message": error.localizedDescription,
          "events": exportedEvents,
        ])
      }
    }
  }

  private func millisValue(_ value: Any?) -> Int64? {
    if let number = value as? NSNumber {
      return number.int64Value
    }
    if let int = value as? Int {
      return Int64(int)
    }
    if let double = value as? Double {
      return Int64(double)
    }
    return nil
  }

  private func nonEmptyString(_ value: Any?) -> String? {
    guard let string = value as? String else { return nil }
    let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }
}
