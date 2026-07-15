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
- Firebase Auth federated sign-in: https://firebase.google.com/docs/auth/flutter/federated-auth
- Google Calendar create events: https://developers.google.com/workspace/calendar/api/guides/create-events
