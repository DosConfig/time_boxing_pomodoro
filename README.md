# Timebox Mark

![Timebox Mark app icon](assets/logo/focus_mark.svg)

Timebox Mark is an app-first timeboxing planner built with Flutter and a native iOS Live Activity integration. The project focuses on one hard product problem: turning a daily timeboxed plan into an executable timer, notification, Live Activity, and calendar workflow.

The product direction is inspired by explicit timeboxing: brain dump, top three priorities, time box grid, focus execution, and review.

## Highlights

- Flutter UI with Riverpod state management
- Native iOS timer source of truth through `MethodChannel`
- ActivityKit Live Activity for Lock Screen and Dynamic Island
- Top priorities and current time box metadata in Live Activity
- Local notifications for focus and break completion
- Session presets: `25/5`, `50/10`, and `15/3`
- Auto-start options for breaks and next focus sessions
- Local alert and sound preferences
- Cold-launch restoration using persisted native `endTime`
- Monotone visual system and custom SVG-based app icon
- Notebook capture and multi-calendar sync roadmap for later expansion

## Why This Project Matters

Flutter does not provide first-party Live Activity support. This app demonstrates how to bridge a Flutter product surface with iOS-only system experiences without a plugin dependency:

```text
Flutter UI / Riverpod
        |
        | MethodChannel
        v
Swift PomodoroTimerManager
        |
        +-- UserNotifications
        +-- ActivityKit Live Activity
```

The native timer owns the authoritative `endTime`. Flutter receives tick updates for the in-app display, while Live Activity renders from the same absolute timestamp. When the app process is killed and reopened, Flutter asks native code to restore the active session instead of resetting to `25:00`.

## Product Decisions

The feature set is intentionally small and portfolio-friendly:

- `25/5` classic Pomodoro reflects the common work/break pattern.
- `50/10` supports deeper work blocks.
- `15/3` supports quick starts when motivation is low.
- Auto-start breaks are enabled by default to protect recovery time.
- Auto-start next focus is off by default so the next work block remains intentional.
- Local alerts can be disabled independently from Live Activity.
- Alert sound can be disabled while keeping visual notifications.
- Notification permission is requested contextually when the user starts a timer, not on first launch.
- Live Activity stays glanceable: top priorities, current time box, remaining time, and progress.

## Product Roadmap

- [Product TODO](docs/product/TODO.md)
- [Menu structure](docs/product/MENU_STRUCTURE.md)
- [Naming direction](docs/product/NAMING.md)
- [Timeboxing strategy](docs/product/TIMEBOXING_STRATEGY.md)
- [Notifications and calendar plan](docs/product/NOTIFICATIONS_AND_CALENDAR.md)
- [App Store review preparation](docs/release/APP_STORE_REVIEW_PREP.md)
- [Privacy policy draft](docs/legal/PRIVACY_POLICY_DRAFT.md)
- [Terms draft](docs/legal/TERMS_DRAFT.md)

References used while shaping the product:

- [Apple Human Interface Guidelines: Live Activities](https://developer.apple.com/design/human-interface-guidelines/live-activities/)
- [Apple ActivityKit documentation](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)
- [Todoist: Pomodoro Technique](https://www.todoist.com/productivity-methods/pomodoro-technique)
- [Pomofocus](https://pomofocus.io/)

## Architecture

```text
lib/
  domain/
    entities/pomodoro.dart
    repositories/pomodoro_repository.dart
    usecases/
  data/
    datasources/pomodoro_platform_channel.dart
    datasources/pomodoro_local_datasource.dart
    repositories/pomodoro_repository_impl.dart
  presentation/
    providers/pomodoro_provider.dart
    screens/timer_screen.dart
    widgets/focus_timer_dial.dart

ios/
  Runner/
    AppDelegate.swift
    PomodoroTimerManager.swift
    PomodoroActivityAttributes.swift
  PomodoroWidgetExtension/
    PomodoroWidgetLiveActivity.swift
    PomodoroActivityAttributes.swift
```

## Timer Lifecycle

1. User starts a focus or break segment.
2. Flutter calls native `startTimer(seconds, phase, sessionGoal)` through MethodChannel.
3. Swift persists `endTime`, phase, session count, pause state, and goal.
4. Swift schedules a completion notification and starts/updates Live Activity.
5. Native sends `onTick` events to Flutter while the app process is alive.
6. On foreground/cold launch, Flutter calls `restoreState`.
7. Swift recomputes remaining time from `endTime - now` and reconnects to any active Live Activity.

## Live Activity Notes

Live Activity uses SwiftUI `Text(timerInterval:countsDown:)`. On the Lock Screen or in Simulator, iOS may temporarily show minute-level placeholders such as `19:--` while throttling second-level rendering. The underlying timer still uses the persisted absolute `endTime`, so this is a display policy rather than a state-sync bug.

## Local Setup

```bash
flutter pub get
flutter analyze
flutter test
flutter build ios --simulator --debug
```

For Live Activity testing, use iOS 16.1+ and preferably a physical device.

## Deployment Checklist

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Set a valid Apple Developer Team for `Runner` and `PomodoroWidgetExtensionExtension`.
3. Confirm the bundle IDs are available in your Apple Developer account:
   - `com.seongwoo.focusmark`
   - `com.seongwoo.focusmark.PomodoroWidgetExtension`
4. Enable Live Activities support for the app target.
5. Build an archive from Xcode or run:

```bash
flutter build ipa --release
```

If the bundle ID is already taken, replace `com.seongwoo.focusmark` with your own reverse-DNS identifier in Xcode.

## Verification

Current verified commands:

```bash
flutter analyze
flutter test
flutter build ios --simulator --debug
flutter build ios --release --no-codesign
```

The iOS release archive requires local Apple signing credentials, so final App Store/TestFlight export should be performed on the developer account that owns the bundle ID.
