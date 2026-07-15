# App Store Review Preparation

## Current Submission Posture

The app can be built for iOS release without codesigning:

```bash
flutter build ios --release --no-codesign
```

Final TestFlight or App Store submission still requires Apple signing credentials.

## Required Before Submission

- Apple Developer Team set for `Runner`
- Apple Developer Team set for `PomodoroWidgetExtensionExtension`
- Available bundle IDs:
  - `com.seongwoo.focusmark`
  - `com.seongwoo.focusmark.PomodoroWidgetExtension`
- App icon present in all required iOS sizes
- Privacy Policy URL
- Support URL
- App Store screenshots
- App description
- App privacy answers in App Store Connect

## Privacy Policy

Apple requires a publicly accessible privacy policy URL in App Store Connect.

For the current local-first version, the privacy posture can be simple:

- timer state is stored on device,
- local notification preferences are stored on device,
- no account is required,
- no calendar data is collected unless calendar sync is added,
- no remote push is sent unless a server push feature is added.

When Firebase/Auth/Calendar is added, update the privacy policy before submission.

## Permission Prompts

### Notifications

Use after the user starts or configures a focus session.

Suggested purpose:

```text
Timebox Mark sends local alerts when a focus block or break ends.
```

### Calendar

Add only when calendar export/sync is implemented.

Suggested purpose:

```text
Timebox Mark adds selected time boxes to your calendar so your daily plan stays visible in your schedule.
```

### Sign In

Add only when cloud sync or Google Calendar is implemented.

Suggested purpose:

```text
Sign in to sync your time boxes and connect calendar providers across devices.
```

## App Review Notes Draft

```text
Timebox Mark is a local-first timeboxing and focus timer app. It uses local notifications to alert users when a focus block or break ends. Live Activity displays the active timer on the Lock Screen and Dynamic Island. The current version does not require an account and does not send remote push notifications.
```

If calendar sync is added:

```text
Calendar access is requested only when the user chooses to export or sync time boxes. The app creates calendar events selected by the user and does not require calendar access for the timer itself.
```

## Known Technical Note

Flutter currently emits a warning that UIScene lifecycle support will soon be required. The build succeeds, but the migration should be completed before a long-lived App Store release.

## References

- App Store privacy details: https://developer.apple.com/app-store/app-privacy-details/
- App Store Connect app privacy: https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/
- Apple User Notifications: https://developer.apple.com/documentation/usernotifications
- Apple EventKit calendar access: https://developer.apple.com/documentation/eventkit/accessing-calendar-using-eventkit-and-eventkitui
