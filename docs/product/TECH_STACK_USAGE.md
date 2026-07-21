# Tech Stack Usage

Status: practical usage only. This document avoids resume-padding claims.

## Used In The Current App

- Flutter/Dart: main app UI, navigation, local state presentation, tests.
- Riverpod 3 codegen: dependency injection and feature controllers.
- Freezed: immutable domain entities and DTOs.
- Clean Architecture: feature-first `domain`, `data`, `application`, and
  `presentation` boundaries.
- Swift: iOS timer source of truth, notifications, ActivityKit Live Activity,
  EventKit Apple Calendar export, and Firebase local config wiring.
- Kotlin: Android MethodChannel timer bridge, absolute-end-time persistence,
  foreground service, Chronometer notifications, and native unit tests.
- Firebase Auth: Apple and Google sign-in.
- Cloud Firestore: signed-in Today Plan sync under `users/{uid}/days/{date}`.
- Firebase Hosting: public privacy, terms, and support pages.
- Dio: Google Calendar REST event creation after Google Sign-In authorization.
- Mockito: repository and Dio REST client behavior tests.
- Patrol: first-launch onboarding smoke test for simulator/device runs.
- CircleCI: Linux pull-request quality workflow.
- Codemagic: signed iOS/TestFlight workflow skeleton.
- Fastlane: local/CI iOS verification, build, metadata, and TestFlight lanes.
- Shorebird: documented and guarded patch workflow, not initialized in the
  first submitted binary.

## Intentionally Not Forced

- BLoC/Cubit: excluded because this app's state management standard is
  Riverpod 3 codegen. Mixing BLoC for no product reason would weaken the
  architecture.
- WebSocket: excluded until there is a real-time collaboration, live device
  pairing, or server session feature that needs bidirectional transport.
- Maps SDK: excluded from scope.

## Future Practical Targets

- Android 16 `ProgressStyle` and wearable sync remain follow-up Kotlin work;
  the Android phone timer and Chronometer notification path are implemented.
- WebSocket becomes meaningful if watch/web/desktop companion sessions need
  live cross-device control beyond Firestore sync.
- Shorebird becomes active only after the first normal App Store/TestFlight
  binary exists and only for review-safe Dart hotfixes.
