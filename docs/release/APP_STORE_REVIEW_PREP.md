# App Store Review Preparation

Status: updated for the signed-in, Firebase-backed, calendar-export build.

This document is a release checklist, not legal advice.

## Build Posture

Local verification:

```bash
flutter analyze
flutter test
flutter build ios --release --no-codesign
```

Release automation:

- Fastlane lanes are defined under `ios/fastlane`.
- Codemagic workflows are defined in `codemagic.yaml`.
- Public-repo secret guardrails are defined in
  `scripts/ci/verify_release_guardrails.sh`.
- Shorebird is not enabled for the first submitted binary. See
  `docs/release/SHOREBIRD_POLICY.md`.

Final TestFlight or App Store upload still requires Apple signing credentials
for both targets:

- `Runner`
- `PomodoroWidgetExtensionExtension`

## Required Before Submission

- App Store Connect app record for bundle ID `com.seongwoo.focusmark`
- App Group / Live Activity capable widget target:
  `com.seongwoo.focusmark.PomodoroWidgetExtension`
- Sign in with Apple capability enabled for the app ID and Runner target
- Firebase Auth providers enabled for Apple and Google
- Firestore rules deployed from `firestore.rules`
- Google Calendar API enabled for project `timebox-mark-prod`
- Google OAuth consent screen configured with privacy policy URL, support
  email, app domain, and test users while in testing
- Public Privacy Policy URL: https://timebox-mark-prod.web.app/privacy/
- Public Support URL: https://timebox-mark-prod.web.app/support/
- Public Terms URL: https://timebox-mark-prod.web.app/terms/
- Reviewer access: either a working demo account or a fully working demo mode
- App screenshots for Today, Focus, Live Activity, Dynamic Island, Calendar,
  and Settings
- App privacy answers matching the current data practices
- In-app legal links in Settings
- In-app account deletion path in Settings

Apple's review guidance requires complete metadata, working URLs, and reviewer
access for account-based features. Apple also requires a publicly accessible
privacy policy URL in App Store Connect.

## Current Permissions

### Sign In

The app requires sign-in before the main app because cloud sync and calendar
features are account-backed.

Review note:

```text
The app requires sign-in to sync the user's daily timebox plan through Firebase
and to connect calendar export providers. Sign in with Apple and Google sign-in
are both available on iOS.
```

Account deletion is available from Settings. It deletes the Firebase Auth user
and the synced Timebox Mark plan data stored under `users/{uid}`.

### Notifications

Local notifications are used for focus completion and break completion. No
remote push server is used in the current build.

Purpose copy:

```text
Timebox Mark sends local alerts when a focus block or break ends.
```

### Calendar

Apple Calendar export uses EventKit write-only access on iOS 17 and later. The
app creates only the events the user chooses to export.

Purpose copy:

```text
Timebox Mark adds only the time boxes you export as events in your calendar.
```

Google Calendar export requests `https://www.googleapis.com/auth/calendar.events`
so the app can create events in the user's primary Google Calendar. It should
not request read scopes unless conflict checking is actually implemented.

## Privacy Label Draft

Declare these as collected only when the related feature is enabled in the
submitted build:

- Contact Info > Email Address: sign-in, app functionality, linked to user, not
  used for tracking
- User Content > Other User Content: timebox plan data stored in Firestore for
  sync, app functionality, linked to user, not used for tracking
- User Content > Calendar Events: only when calendar export is used, app
  functionality, linked to user, not used for tracking

Do not declare location, contacts, photos, browsing history, advertising ID, or
tracking unless those features are added later.

Crashlytics is not part of the current checklist. If added later, update the
privacy label and privacy policy before submission.

## Review Notes Draft

```text
Timebox Mark is a timeboxing and focus timer app. Users sign in before using
the main app so their daily plan can sync through Firebase and so calendar
providers can be connected. Live Activity is the core iOS feature: create or
select a current timebox, tap Start Focus, then lock the device or expand the
Dynamic Island to verify the running timer.

Apple Calendar access is requested only when the user exports today's timeboxes.
On iOS 17 and later the app requests write-only calendar access and creates
only the exported events. Google Calendar export uses the calendar.events scope
to create events in the user's primary calendar. The app does not send remote
push notifications in this build.
```

## Human Tasks

- Publish the privacy policy and support page.
- Add the privacy policy URL to App Store Connect.
- Add reviewer credentials or prepare a demo mode.
- Create the App Store Connect app record.
- Upload a signed archive to TestFlight.
- Capture App Store screenshots on a real device where possible, especially
  Live Activity and Dynamic Island.
- Submit Google OAuth verification if moving beyond test users with the
  Calendar API scope.
- If Shorebird is initialized later, use it only for Dart-only hotfixes that do
  not alter reviewed functionality, monetization, permissions, or privacy
  behavior.

## Official References

- Apple App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Apple App Privacy Details: https://developer.apple.com/app-store/app-privacy-details/
- Apple App Store Connect privacy URL help: https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/
- Apple EventKit access: https://developer.apple.com/documentation/eventkit/accessing-the-event-store
- Google OAuth consent configuration: https://developers.google.com/workspace/guides/configure-oauth-consent
- Google Calendar API scopes: https://developers.google.com/workspace/calendar/api/auth
- Google API Services User Data Policy: https://developers.google.com/terms/api-services-user-data-policy
