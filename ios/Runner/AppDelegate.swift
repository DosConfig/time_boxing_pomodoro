import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let CHANNEL = "com.pomodoro/timer"
  private var pomodoroTimer: PomodoroTimerManager?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Setup Method Channel
    guard let controller = window?.rootViewController as? FlutterViewController else {
      fatalError("rootViewController is not type FlutterViewController")
    }

    let timerChannel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)
    pomodoroTimer = PomodoroTimerManager(channel: timerChannel)

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
          self.pomodoroTimer?.startTimer(
            duration: seconds,
            sessionCount: sessionCount,
            sessionGoal: sessionGoal,
            phase: phase,
            notificationsEnabled: notificationsEnabled,
            soundEnabled: soundEnabled,
            topPriorities: topPriorities,
            currentTimeBoxTitle: currentTimeBoxTitle,
            currentTimeBoxTimeRange: currentTimeBoxTimeRange
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
        let remaining = self.pomodoroTimer?.getRemainingTime() ?? 0
        result(remaining)

      case "getActivityStatus":
        result(self.pomodoroTimer?.lastActivityStatus ?? "no-manager")

      case "restoreState":
        result(self.pomodoroTimer?.restoreState() ?? ["status": "idle"])

      default:
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
