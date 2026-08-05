# App Store Review Preparation — iOS 1.0.0+15

Status: code and metadata preparation for the first iOS App Store review.
Calendar export is deliberately excluded from this version.

This document is a release checklist, not legal advice.

## Submitted Product Scope

- Today: brain dump, top priorities, and the daily timebox board
- Focus: current timebox timer, pause/resume/stop, and completion state
- iOS Live Activity: Lock Screen and Dynamic Island timer presentation
- Local notifications: current-timebox completion alerts
- Firebase Auth: Sign in with Apple and Google sign-in
- Firestore: signed-in daily-plan synchronization
- Settings: notification controls, legal links, sign out, and account deletion
- Crashlytics and Analytics: release stability monitoring with redacted context

Not included in this build:

- Apple Calendar or Google Calendar access
- EventKit permission prompts
- Google Calendar OAuth scopes
- Android, Wear OS, or Play Store distribution

## Local Verification

```bash
flutter analyze
flutter test
flutter build ios --release --no-codesign
bash scripts/ci/verify_release_guardrails.sh
```

Release automation:

- Codemagic workflow: `ios-testflight`
- App Store Connect app ID: `6792788166`
- Bundle ID: `com.seongwoo.focusmark`
- Widget extension: `com.seongwoo.focusmark.PomodoroWidgetExtension`
- TestFlight build target: `1.0.0+15`

## Required Before Submission

- [ ] Build `1.0.0+15` appears as processed in App Store Connect
- [ ] Apple and Google sign-in both work in the submitted build
- [ ] Firestore plan creation and restoration work on a physical device
- [ ] Live Activity appears on a supported physical iPhone
- [ ] Notification permission, timer completion, and background/resume are tested
- [ ] Account deletion succeeds from Settings
- [ ] Public Privacy, Terms, and Support pages show the no-calendar policy
- [ ] App Store description, keywords, screenshots, and review notes contain no calendar claim
- [ ] App Privacy answers match the data practices below
- [ ] Export compliance answer confirms no non-exempt custom encryption
- [ ] Age rating and category are completed

## Permissions

### Sign In

The app requires sign-in because the submitted version stores and restores the
user's daily plan through Firebase. Sign in with Apple and Google sign-in are
both available on iOS.

Account deletion is available at Settings > Account > Delete account. It
deletes the Firebase Auth user and synced plan data under `users/{uid}`.

### Notifications and Live Activity

Notification permission is requested when the user starts a timer, not on first
launch. Notifications report the current timebox completion. ActivityKit presents
the active timer on the Lock Screen and Dynamic Island. A Live Activity update
token may be stored only to update or end the current activity; it is not used
for marketing.

### Calendar

The submitted build does not show a Calendar tab, request EventKit permission,
or request the Google Calendar scope.

## App Privacy Answers

Declare according to the actual App Store Connect form:

- Contact Info > Email Address: authentication and app functionality; linked to
  the user; not used for tracking
- User Content > Other User Content: brain dump, reminder, priority, and
  timebox-plan synchronization; linked to the user; not used for tracking
- Diagnostics > Crash Data: stability analysis; not used for tracking
- Usage Data > Product Interaction: limited screen/lifecycle/timer events for
  release stability; not used for tracking
- Identifiers > Device ID: Firebase installation/session identifier for
  stability measurement; not used for advertising or tracking

Do not declare Calendar Events for `1.0.0+15`. The app also does not collect
location, contacts, photos, browsing history, or advertising identifiers.

Diagnostic context must not include email, Firebase UID, user-entered plan
text, credentials, or Live Activity push tokens.

## Review Notes

```text
Timebox Mark is a timeboxing and focus-timer app.

Sign in with Apple and Google sign-in are both available. Sign-in is required
so the user's daily timebox plan can be restored through Firebase. Account
deletion is available in Settings > Account > Delete account.

To verify the core iOS feature:
1. Sign in.
2. On Today, create a timebox that includes the current time.
3. Open Focus and tap Start Focus.
4. Lock the device or expand the Dynamic Island.

The running timer appears as a Live Activity on supported devices. Local
notification permission is requested when a timer starts. This version does
not access Apple Calendar or Google Calendar. Remote push is limited to
updating or ending the active Live Activity and is not used for marketing.
```

## Screenshot Set

1. Today — priorities and current plan
2. Today — timebox board
3. Focus — running timer
4. Settings — notification controls

Do not include a Calendar screenshot or calendar-related caption.

## App Store Connect Manual Tasks

- Select the processed `1.0.0+15` build
- Enter category: Productivity; optional secondary category: Lifestyle
- Complete the 4+ age-rating questionnaire based on actual content
- Enter Privacy Policy: https://timebox-mark-prod.web.app/privacy/
- Enter Support: https://timebox-mark-prod.web.app/support/
- Enter Marketing URL: https://timebox-mark-prod.web.app/
- Upload the required iPhone screenshots
- Paste the review notes above
- Complete App Privacy answers
- Save each section and resolve every missing-metadata warning
- Submit for review only after the final physical-device smoke test

## Official References

- Apple App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Apple App Privacy Details: https://developer.apple.com/app-store/app-privacy-details/
- App Store Connect privacy URL help: https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/
