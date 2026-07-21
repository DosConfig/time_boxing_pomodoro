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
- Android 13 notification permission and foreground-service manifest entries
  are configured.
- Kotlin unit tests cover running, paused, and completed timer restoration.

Still pending:

- Android 16 `Notification.ProgressStyle` promoted Live Updates.
- Release upload-key and Play App Signing setup.
- Wear OS companion UI and Data Layer synchronization.

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
The timer is not coupled to per-second notification updates. On iOS, Live Activity receives an end time and the system renders Text(timerInterval:). On Android, the same model maps to a foreground-service notification using Chronometer, or Android 16 ProgressStyle where available. If the OS rate-limits notification updates, the timer is still correct because remaining time is derived from endTime minus now.
```

## References

- Android Live Update notifications: https://developer.android.com/develop/ui/compose/notifications/live-update
- Android 16 progress-centric notifications: https://developer.android.com/about/versions/16/features/progress-centric-notifications
- Android Nougat notification update rate limiting: https://saket.me/android-7-nougat-rate-limiting-notifications/
