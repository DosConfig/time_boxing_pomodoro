# Watch, Firebase, and Billing Plan

## Product Direction

The current app requires an account after onboarding so daily plans can be
restored across devices. A local cache remains the immediate editing store and
offline fallback.

Planned free tier:

- local Today plan,
- local timer,
- Live Activity,
- local notifications,
- local settings.

Planned paid connected tier:

- Apple Watch companion,
- Wear OS / Galaxy Watch companion,
- cloud backup and multi-device sync,
- server calendar integrations,
- cross-device entitlement restore.

This creates a clean value boundary: local-only stays free; anything that needs another device, account, server, or cross-platform state belongs behind a paid entitlement.

## Watch Apps

### Android Phone Foundation

Wear OS should come after the Android phone app, because the phone must remain the source of truth.

Implemented:

- Native Kotlin foreground service for focus and break sessions.
- Absolute `endTime` timer restoration and pause state persistence.
- OS-rendered countdown through notification Chronometer fields.
- Notification updates only on semantic state changes.

Pending:

- Evaluate Android 16 Live Updates with `Notification.ProgressStyle` for progress-centric promoted notifications.
- Add Wear OS synchronization after the phone foundation is release-tested.

This matches the iOS design: iOS Live Activity uses `Text(timerInterval:)`, Android should use Chronometer or ProgressStyle, and both platforms share the same absolute-time model.

### Apple Watch

Recommended implementation:

- Add a native SwiftUI watchOS companion target to the existing iOS project.
- Use WatchConnectivity and `WCSession` between the iPhone app and the Watch app.
- Keep the iPhone app as the source of truth.
- Send absolute timer state to the watch, not per-second ticks.

Watch payload:

```text
TimerSnapshot
  activeTimeBoxId
  title
  timeRange
  phase
  status
  startedAt
  endAt
  remainingWhenPaused
  topPriority
  entitlement
  updatedAt
```

Watch interactions:

- pause / resume,
- start current time box,
- skip current time box,
- mark done,
- haptic alert when a block ends.

The watch should not be a planning surface. It should be a control surface.

Use `updateApplicationContext` for the latest timer snapshot because old snapshots do not matter. Use immediate messages for pause/resume/skip commands when the phone is reachable. Use queued transfer only for low-priority state that can arrive later.

### Wear OS / Galaxy Watch

Recommended implementation:

- Add Wear OS only after the Android phone app exists.
- Use a native Wear OS module with Kotlin + Compose for Wear OS, or a very small Flutter Android wearable build if the product needs faster UI reuse.
- Use the Wear OS Data Layer API for phone-watch synchronization.
- Use `DataClient` for current timer snapshot sync.
- Use `MessageClient` for pause/resume/skip commands.

Important limitation:

Wear OS Data Layer sync works between Android phones and Wear OS watches. It is not the solution for a Wear OS watch paired to an iPhone.

## Firebase Architecture

Implemented Firebase modules:

- Firebase Core,
- Firebase Auth,
- Cloud Firestore.

Pending modules:

- Cloud Functions for trusted entitlement and invite-code operations,
- Firebase Analytics,
- Firebase Crashlytics.

Optional later:

- Firebase Cloud Messaging for server-generated reminders,
- Remote Config for paywall and feature flags.

Auth policy:

- iOS: Sign in with Apple is primary.
- Android: Google sign-in is primary.
- Link providers under one Firebase user when possible.
- The current onboarding flow requires sign-in before entering the app shell.

Firestore shape:

```text
users/{uid}
  displayName
  email
  createdAt
  defaultProvider

users/{uid}/settings/app
  alertsEnabled
  soundEnabled
  defaultBlockMinutes

users/{uid}/days/{yyyy-MM-dd}
  dateKey
  plan
    brainDump
    reminders
    topPriorities
    timeBoxes
    timer/settings snapshot
  clientUpdatedAt
  updatedAt

users/{uid}/devices/{deviceId}
  platform
  pushToken
  watchPaired
  lastSeenAt

entitlements/{uid}
  tier
  source
  activeUntil
  updatedAt

inviteCodes/{code}
  tier
  maxRedemptions
  redeemedCount
  expiresAt
  createdBy
```

Security rules:

- Users can read and write only their own plan/settings documents.
- Clients cannot write `entitlements`.
- Clients cannot directly increment invite redemption counts.
- Invite redemption and entitlement updates must go through Cloud Functions.

## Billing

Recommended tiers:

```text
Free
  local-only planning
  local timer
  Live Activity
  local notifications

Pro
  Apple Watch / Wear OS companion
  cloud backup
  multi-device sync
  Google Calendar / Outlook sync
  advanced review history

Founding / Invite
  same as Pro
  time-limited or lifetime promotional entitlement
```

Implementation options:

1. RevenueCat + Firebase extension
   - Fastest path to cross-platform subscriptions and entitlement sync.
   - Good if the goal is shipping quickly.
   - Adds a paid third-party dependency if the app grows.

2. Official `in_app_purchase` + Cloud Functions verification
   - More engineering work.
   - Better portfolio signal because receipt validation and entitlements are owned by the app.
   - Requires App Store Server API and Google Play Developer API integration.

Recommended first build:

- Use official `in_app_purchase` for the portfolio-grade implementation.
- Keep a repository boundary so RevenueCat can be swapped in later if operational speed becomes more important.

Invite codes:

- Use invite codes only for free promotional access, beta access, reviewers, or founding users.
- Do not sell invite codes outside the app as a way to bypass in-app purchase for digital features.
- Redeem codes through a Cloud Function that grants an entitlement document.

## Implementation Order

1. Done: Firebase project, Auth, local/cloud repository boundary, and daily
   Firestore plan sync.
2. Done: Android phone foreground service and Chronometer notification.
3. Next: release smoke tests and production observability.
4. Add StoreKit / Play Billing product IDs and entitlement restore.
5. Add invite code redemption through Cloud Functions.
6. Add Apple Watch companion app.
7. Add Android 16 Live Update enhancement.
8. Add Wear OS companion.
9. Extend one-way calendar export into bidirectional provider sync.

## Human-Required Setup

- Create Firebase project.
- Register iOS bundle ID and Android package in Firebase.
- Enable Firebase Auth providers.
- Configure Sign in with Apple in Apple Developer.
- Configure Google OAuth consent screen.
- Create App Store Connect subscription products.
- Create Play Console subscription products.
- Decide product IDs.
- Decide initial price.
- Decide invite code policy.
- Provide App Store privacy policy URL and support URL.
- Decide whether Pro has a free trial.

## References

- Apple WatchConnectivity: https://developer.apple.com/documentation/watchconnectivity
- Apple WCSession: https://developer.apple.com/documentation/watchconnectivity/wcsession
- Android Live Update notifications: https://developer.android.com/develop/ui/compose/notifications/live-update
- Android 16 progress-centric notifications: https://developer.android.com/about/versions/16/features/progress-centric-notifications
- Wear OS Data Layer: https://developer.android.com/training/wearables/data/overview
- Wear OS data sync: https://developer.android.com/training/wearables/data/sync
- Firebase Flutter setup: https://firebase.google.com/docs/flutter/setup
- Firebase Auth Flutter: https://firebase.google.com/docs/auth/flutter/start
- Firebase federated auth: https://firebase.google.com/docs/auth/flutter/federated-auth
- Firebase pricing: https://firebase.google.com/pricing
- Firestore quotas: https://firebase.google.com/docs/firestore/quotas
- Flutter in-app purchases: https://docs.flutter.dev/resources/in-app-purchases-overview
- Flutter `in_app_purchase`: https://pub.dev/packages/in_app_purchase
- Apple StoreKit: https://developer.apple.com/storekit/
- Apple subscriptions: https://developer.apple.com/app-store/subscriptions/
- Apple App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Google Play Billing: https://developer.android.com/google/play/billing
- Google Play subscriptions: https://developer.android.com/google/play/billing/subscriptions
- Google Play payments policy: https://support.google.com/googleplay/android-developer/answer/10281818
