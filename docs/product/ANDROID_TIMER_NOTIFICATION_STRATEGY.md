# Android Timer Notification Strategy

## Principle

Android should use the same timer model as the current iOS implementation:

```text
source of truth = absolute endTime
visible countdown = rendered by the operating system
Flutter tick = only for the foreground app UI
```

The app should not repost an Android notification every second to keep a timer fresh.

## Why

Android notifications can be rate-limited when an app updates them too often. Notification progress updates were specifically one of the cases that led to stricter limits on Android Nougat and later. Android 16 Live Updates also move progress-centric experiences into a more structured system surface with promoted notification requirements.

That means Android has the same design pressure as iOS Live Activity: use a stable absolute timestamp and delegate time rendering to the system.

## Implemented Android Phone Foundation

- `PomodoroTimerService` runs active sessions as a foreground service.
- `PomodoroTimerState` persists the absolute `endTime`, phase, status, pause
  state, settings, and localized notification copy.
- The ongoing notification uses `setWhen`, `setUsesChronometer`, and
  `setChronometerCountDown`; it is not reposted every second.
- The MethodChannel supports start, pause, resume, stop, restore, and settings
  updates from the shared Flutter domain layer.
- Flutter also sends the complete Today schedule when its cards or tracking
  setting changes. `AndroidScheduleState` persists that compact payload in
  native `SharedPreferences`, using absolute start/end timestamps.
- While schedule tracking is enabled, the foreground service selects the card
  containing `now`. At a card boundary it completes the old timer, starts the
  next contiguous card, and replaces the ongoing notification. During a gap it
  keeps a low-cost "Next" notification and schedules only one Handler callback
  for the next start time; it does not execute a one-second background loop.
- `autoStartFocus` is stored in the daily-plan schema so the Flutter toggle and
  native schedule cannot disagree after process recreation.
- Android 13 notification permission and foreground-service manifest entries
  are configured.
- Kotlin unit tests cover timer restoration and start-inclusive/end-exclusive
  schedule boundary selection.

Verified on a Pixel API 35 emulator:

1. Flutter/Kotlin debug build installs and launches.
2. The first native schedule entry creates the foreground notification.
3. With Flutter no longer driving the transition, the service persists and
   changes from the first entry to the second entry at the absolute boundary.
4. After the final entry, the timer becomes inactive and the service stops.

Still pending:

- Android 16 `Notification.ProgressStyle` promoted Live Updates.
- Release upload-key and Play App Signing setup.
- Wear OS companion UI and Data Layer synchronization.
- Reboot rescheduling. A persisted schedule is restored when the app process is
  relaunched, but there is no `BOOT_COMPLETED` receiver in this version.
- Slot-break segmentation while Dart is suspended. Native fallback tracks the
  card's full wall-clock range; when Flutter is active, the existing controller
  still owns the finer focus/break segment policy.

## Android 16 Live Updates

For Android 16+, evaluate `Notification.ProgressStyle` for a richer progress-centric surface.

Use it only when the app can satisfy the platform expectations:

- promoted notification permission and policy,
- ongoing notification behavior,
- status-chip text constraints,
- meaningful progress state instead of decorative animation.

The fallback remains the foreground-service chronometer notification.

## Interview Answer

```text
The timer is not coupled to per-second notification updates. On iOS, Live Activity receives an end time and the system renders Text(timerInterval:). On Android, the same model maps to a foreground-service notification using Chronometer. I also persist today's card start and end timestamps natively, so a contiguous next card can start even if the Dart isolate is suspended. During a schedule gap the service waits for one boundary callback and shows the next card instead of running a one-second background loop. Android 16 ProgressStyle remains an optional presentation enhancement; timer correctness still comes from absolute timestamps.
```

## References

- Android Live Update notifications: https://developer.android.com/develop/ui/compose/notifications/live-update
- Android 16 progress-centric notifications: https://developer.android.com/about/versions/16/features/progress-centric-notifications
- Android Nougat notification update rate limiting: https://saket.me/android-7-nougat-rate-limiting-notifications/
