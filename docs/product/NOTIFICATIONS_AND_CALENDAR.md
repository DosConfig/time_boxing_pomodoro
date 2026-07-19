# Notifications, Sound, and Calendar Plan

## Notification Strategy

Use local notifications for the current app.

Local notifications are enough for:

- focus block complete,
- break complete,
- upcoming time box reminder,
- missed start reminder,
- end-of-day review reminder.

Remote push is only needed later for:

- cloud-synced reminders across devices,
- server-generated schedule nudges,
- shared calendars or team workflows,
- reminders that must be created after the app has been inactive for a long time.

## Cross-Platform Timer Display Rule

The timer should be stored as an absolute end time, not as a stream of per-second UI updates.

Platform surfaces should render time themselves:

- iOS Live Activity: SwiftUI `Text(timerInterval:countsDown:)`.
- Android notification: `setWhen`, `setUsesChronometer`, and `setChronometerCountdown`.
- Android 16+ Live Updates: `Notification.ProgressStyle` when the app qualifies for promoted ongoing updates.

This keeps the app resilient when the OS throttles notification or widget rendering. Flutter can tick every second while the app is open, but external system surfaces should not depend on Flutter sending a per-second update.

## Android Notification Strategy

Android should not receive a fresh notification every second for a running timer.

Recommended Android phone implementation:

- Add a native foreground service as the source of timer execution.
- Persist `endTime`, `phase`, `status`, `activeTimeBoxId`, and pause state.
- Build an ongoing notification from that snapshot.
- Use Android chronometer fields for countdown display instead of reposting the notification every second.
- Keep manual notification updates for meaningful state changes only: start, pause, resume, skip, complete, active box change, and permission changes.
- Throttle any non-timer progress updates because Android has package-level notification update rate limiting.
- For Android 16+, evaluate Live Updates with `Notification.ProgressStyle`, promoted notification permission, ongoing behavior, and status-chip constraints.
- Treat OEM battery optimizations as a display-freshness risk, not as a reason to abandon the absolute `endTime` model.

Interview framing:

```text
The timer does not depend on notification update frequency. We store one absolute endTime, then delegate countdown rendering to the OS. iOS uses Text(timerInterval:), and Android should use Chronometer or ProgressStyle. If notification updates are delayed or rate-limited, the source of truth is still correct.
```

## Sound Strategy

The app should support three levels:

1. Alerts off
2. Alerts on, sound off
3. Alerts on, sound on

The current implementation now supports local alert and sound toggles. A future version can add custom bundled sounds such as:

- soft chime,
- analog tick,
- deep bell,
- silent haptic-only mode.

On iOS, custom notification sounds must be packaged with the app and referenced from the notification content.

## Calendar Strategy

Calendar should be optional, not mandatory.

The best product model is:

- local planning works without sign in,
- Apple Calendar export works with on-device permission,
- Google Calendar sync requires Firebase Auth plus Google OAuth,
- users can choose which time boxes become calendar events.

## Apple Calendar

For iOS, use EventKit.

Recommended first permission: write-only calendar access. This lets the app create time box events without reading the user's whole calendar.

Use full access only if the app needs to import existing calendar events into the time box grid.

Required human/product decision:

- Decide whether v1 writes events only or also reads existing events.
- Write the exact permission copy for the calendar prompt.
- Confirm whether generated events should use a dedicated "Timebox Mark" calendar.

Suggested permission copy:

```text
Timebox Mark adds the time boxes you choose to your calendar so your daily plan appears alongside your schedule.
```

## Google Calendar

For Google Calendar, the app needs:

- Google Cloud project,
- Google Calendar API enabled,
- OAuth consent screen,
- iOS OAuth client,
- Android OAuth client if Android is supported,
- calendar write scope,
- token storage and refresh handling.

Human-required setup:

- Create or choose a Google Cloud project.
- Configure OAuth consent screen branding.
- Add support email and privacy policy URL.
- Decide whether the app is internal, testing, or public external.
- Add test users until OAuth verification is complete.

## Firebase Auth

Use Firebase Auth as the account layer.

Recommended login policy:

- iOS: Sign in with Apple first, Google as optional secondary provider.
- Android: Google first, Apple optional only if there is a clear reason.
- Web: Google and Apple can both be offered.

If third-party login is offered on iOS, Sign in with Apple should be included for App Store review alignment.

## References

- Apple User Notifications: https://developer.apple.com/documentation/usernotifications
- Apple custom notification sound: https://developer.apple.com/documentation/usernotifications/unnotificationsound
- Apple EventKit calendar access: https://developer.apple.com/documentation/eventkit/accessing-calendar-using-eventkit-and-eventkitui
- Android Live Update notifications: https://developer.android.com/develop/ui/compose/notifications/live-update
- Android 16 progress-centric notifications: https://developer.android.com/about/versions/16/features/progress-centric-notifications
- Android Nougat notification update rate limiting: https://saket.me/android-7-nougat-rate-limiting-notifications/
- Firebase Auth federated sign-in: https://firebase.google.com/docs/auth/flutter/federated-auth
- Google Calendar create events: https://developers.google.com/workspace/calendar/api/guides/create-events
