import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let CHANNEL = "com.pomodoro/timer"
  private var pomodoroTimer: PomodoroTimerManager?

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

      case "syncLiveActivityPushTokens":
        if #available(iOS 16.1, *) {
          self.pomodoroTimer?.syncLiveActivityPushTokens()
        }
        result(true)

      case "restoreState":
        result(self.pomodoroTimer?.restoreState() ?? ["status": "idle"])

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
