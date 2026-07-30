# Project Maintenance Status

Last audited: 2026-07-21

This document distinguishes code that exists from flows that have been proven
on production accounts and physical devices.

## Implemented And Covered Locally

- Feature-first Flutter structure with Riverpod 3 code generation, Freezed
  entities/DTOs, repository interfaces, implementations, use cases, and DI.
- First-run onboarding, Firebase auth gate, Apple sign-in, Google sign-in, and
  account deletion that returns to the auth gate and clears local plan data.
  Firebase can still require the user to sign in again before a sensitive
  deletion; the app preserves the session and reports the failure in that case.
- Local-first daily plan persistence plus Firestore backup at
  `users/{uid}/days/{yyyy-MM-dd}`.
- Timestamp conflict resolution, serialized writes, lifecycle flush, midnight
  rollover, daily carry-over, and recurring time boxes.
- Brain dump, reminders, top priorities, 30-minute time-box grid, long-press
  card movement, edge auto-scroll, tap actions, and 30-minute resize mode.
- Current-time timeline, Focus state synchronized to the current time box,
  local notification settings, and iOS Live Activity timer rendering.
- iOS `UIScene` lifecycle registration with platform channels attached to the
  implicit Flutter engine rather than `window.rootViewController`.
- Provider-specific Apple Calendar and Google Calendar one-way export screens,
  independent loading states, persisted event-id mappings, and retry
  de-duplication. Google event IDs are deterministic, so the same dated
  timebox is also protected from duplicate creation on another device.
- Post-export actions open Apple Calendar or Google Calendar, with an App Store
  or Play Store fallback when Google Calendar is not installed.
- Android native foreground timer service with an OS-rendered Chronometer
  countdown and Kotlin restoration tests.
- Korean, English, Japanese, Simplified Chinese, Spanish, French, and German
  app localization.
- Mockito unit tests, Flutter widget tests, Patrol smoke-test scaffolding,
  GitHub Actions/CircleCI quality gates, Fastlane lanes, and Codemagic YAML.
- A single app-icon source is used for iOS, Android, splash, and Firebase
  Hosting assets.

## External Verification Still Required

- Run Apple and Google sign-in, edit a daily plan, then confirm both the user
  document and dated plan document in the production Firestore console.
- Sign in on a second device and verify the dated plan restores before making
  edits; then test offline edits and reconnection.
- Exercise notification permission, sound/silent completion, Live Activity,
  Apple Calendar permission, and Google Calendar OAuth on physical devices.
- Create the App Store Connect app record, configure both signing targets,
  upload the first IPA, and complete an internal TestFlight smoke test.
- Configure Codemagic signing and encrypted environment variables.
- Configure an Android upload key and register its SHA certificates with
  Firebase before a Play release.
- Trigger one disposable test crash on a physical release build, verify iOS
  symbolication and Android stack traces, and confirm actual alert delivery
  before rollout. Email channels and `1% + 10 users` Velocity thresholds are
  already configured for both Firebase apps.
- Accept the Google Analytics terms and choose the Analytics account location
  in Firebase Console. SDK integration is complete, but project-level Analytics
  activation cannot be completed on the user's behalf.

## Recently Implemented

- Firebase Analytics and Crashlytics SDK integration, Flutter/async fatal
  handlers, targeted timer/Live Activity non-fatals, iOS dSYM upload, Android
  Gradle plugin, and Firebase email/Velocity Alert settings.

## Planned, Not Implemented

- Apple Watch and Wear OS apps.
- Billing, subscriptions, entitlements, and invite-code Cloud Functions.
- Android 16 `Notification.ProgressStyle` Live Updates.
- Bidirectional calendar import/update/delete synchronization.
- Morning planning and end-of-day review notification scheduling. Timebox
  start/progress and completion notifications are already implemented for the
  actively tracked block.
- Shorebird release `1.0.0+9` and the first Dart-only OTA patch are verified
  through Codemagic. Native changes still require a new store binary.

## Toolchain Watch Items

- Patrol 4.7.1 still applies the legacy Kotlin Gradle Plugin. Flutter currently
  builds it through compatibility mode, but a future Flutter release will
  remove that path. Upgrade Patrol when a built-in Kotlin compatible release is
  available, then remove the compatibility flags from `android/gradle.properties`.
- Fastlane 2.237.0 currently runs with Ruby 3.2.2, but warns that a future
  release will require Ruby 3.3 or newer. Upgrade the local/CI Ruby runtime
  before the next Fastlane dependency update.

## Maintenance Gate

Run before reporting a code change complete:

```bash
bash gates/flutter_check.sh quick
bash gates/flutter_check.sh standard
```

The gate scans tracked and untracked worktree files for secret patterns without
printing matched values, scans reachable Git history, checks
documentation/duplication rules, analyzes and tests Flutter code, runs code
generation, and builds both iOS and Android on macOS. The receipt is bound to
the verified worktree state.

The latest receipt is emitted after each successful gate run and stored in the
ignored `.bridle/receipts.log` file. It is intentionally not hard-coded here
because every source or documentation change invalidates the previous receipt.

Source-control audit notes:

- No credential-pattern value or forbidden credential file was found in the
  reachable history. Local Firebase client files remain ignored.
- Historical commits still use `John Doe <qlqjsdmsz8@gmail.com>`. Both local
  repositories now use `Seongwoo Do <seongwoo@10xkeleton.com>` for future
  commits; rewriting published authorship requires a coordinated force-push.
- Previously tracked `ios/build` output is staged for removal and ignored for
  future builds.
