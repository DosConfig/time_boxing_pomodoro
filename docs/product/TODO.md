# Product TODO

## P0 - Current App Alignment

- [x] Rename visible app surface toward Timebox Mark.
- [x] Add local alert and sound preferences.
- [x] Stabilize timer screen scroll behavior.
- [x] Lower timer text inside the dial for better optical centering.
- [x] Add Top 3 and current time box metadata path into Live Activity.
- [x] Add default time boxes and one-tap active box selection.
- [x] Split Today, Focus, and Settings into separate tabs.
- [x] Add daily one-by-one priority entry flow.
- [x] Add Daily progress strip for plan/focus completion feedback.
- [x] Debounce Top Priority typing so state is not saved on every keystroke.
- [x] Add quick time box create, edit, delete, and reorder controls.
- [ ] Replace visible edit/delete buttons with swipe actions on time boxes.
- [x] Add foreground in-app completion banner and iOS foreground notification presentation.
- [x] Document menu structure.
- [x] Keep photo capture out of the current primary flow.

## P0 - Codebase Quality

- [x] Move app code toward feature-first structure.
- [x] Replace manual Riverpod providers with Riverpod code generation.
- [x] Add Freezed entities for core app state.
- [x] Separate native restore payload DTO from domain timer snapshot.
- [x] Remove widget-returning helper methods from Today time-box board.
- [x] Extract Today section card and time-box board into widget classes.
- [ ] Continue splitting Today screen into smaller widget files.
- [ ] Keep StatefulWidget usage limited to controller lifecycle boundaries.
- [ ] Add lint rule/process note to prevent widget-building helper methods.

## P1 - Local Timeboxing Planner

- [x] Build Today screen.
- [x] Add fast Brain Dump list with minimal typing friction.
- [x] Add Top 3 Priorities editor with one-tap promote from Brain Dump.
- [x] Add calendar-style 30-minute time-slot board.
- [x] Add long-press drag placement for 30-minute time boxes.
- [ ] Add time-box duration adjustment after fixed-slot MVP is validated.
- [x] Let users select a box and start Focus mode from it.
- [x] Persist Today Plan locally.
- [x] Restore Today Plan on app launch without restoring stale timer runtime state.
- [x] Add seven-day local Daily history strip.
- [ ] Add Review screen for planned versus completed boxes.
- [ ] Add default templates so users do not start from an empty screen.

## P2 - Calendar Sync

- [x] Add Calendar tab without fake provider fallback UI.
- [x] Add Apple Calendar write-only export with EventKit.
- [x] Add calendar event mapping for TimeBox.
- [x] Add Google Calendar primary-calendar export MVP.
- [x] Track external calendar event IDs for exported Apple and Google events.
- [ ] Add conflict detection against existing calendars.
- [ ] Evaluate Nylas and Cronofy as multi-provider calendar layers.
- [ ] Add Outlook / Microsoft 365 provider path.
- [ ] Add update/delete for previously exported external events.

## P3 - Cloud and Auth

- [ ] Add Firebase project.
- [x] Add Firebase Auth app integration.
- [x] Use Sign in with Apple as the primary iOS login.
- [x] Use Google sign-in authorization where Google Calendar is connected.
- [ ] Add anonymous/local user migration path into Firebase account.
- [ ] Add local-first repository boundary for free local mode versus paid sync mode.
- [ ] Add Firestore data model for days, time boxes, settings, devices, and entitlements.
- [ ] Store user plans and provider tokens securely.
- [ ] Add account deletion flow for store review.

## Manual Setup Required

- [ ] Create a Firebase project and register iOS app `com.seongwoo.focusmark`.
- [ ] Add `GoogleService-Info.plist` to `ios/Runner/` and the Runner target in Xcode.
- [ ] Enable Firebase Authentication providers: Apple now, Google before broader Google login.
- [ ] Enable Sign in with Apple capability for the App ID and Runner target.
- [ ] Add the Google reversed client ID URL scheme from `GoogleService-Info.plist` to `ios/Runner/Info.plist`.
- [ ] Enable Google Calendar API in the Google Cloud project linked to Firebase.
- [ ] Configure OAuth consent screen with the Calendar events scope.

## P4 - Android Phone and Watch Companion Apps

- [ ] Add entitlement gate for watch sync.
- [ ] Add Apple Watch SwiftUI companion target.
- [ ] Sync current timer snapshot from iPhone to Apple Watch through WatchConnectivity.
- [ ] Add Apple Watch controls for pause, resume, skip, and mark done.
- [ ] Add Apple Watch haptic completion feedback.
- [ ] Add Android app foundation before Wear OS work.
- [ ] Add Android native foreground service backed by absolute `endTime`.
- [ ] Render Android timer notifications with Chronometer instead of per-second notification reposts.
- [ ] Evaluate Android 16 Live Updates with `Notification.ProgressStyle`.
- [ ] Add Android notification permission strategy for `POST_NOTIFICATIONS` and promoted Live Updates.
- [ ] Add throttling policy for any Android notification updates that are not OS-rendered timers.
- [ ] Add Wear OS / Galaxy Watch companion module.
- [ ] Sync current timer snapshot through the Wear OS Data Layer API.
- [ ] Add Wear OS controls for pause, resume, skip, and mark done.
- [ ] Keep phone app as the source of truth for all watch interactions.

## P5 - Billing and Entitlements

- [ ] Define Free, Pro, and Invite entitlement tiers.
- [ ] Create App Store Connect subscription products.
- [ ] Create Google Play Console subscription products.
- [ ] Add in-app purchase product loading.
- [ ] Add purchase, restore, and subscription status UI.
- [ ] Add server-side purchase verification through Cloud Functions.
- [ ] Store normalized entitlement state in Firestore.
- [ ] Add invite code redemption Cloud Function.
- [ ] Add invite code entry UI.
- [ ] Ensure invite codes are promotional access, not an external paid bypass for digital features.
- [ ] Document paid feature gates in App Store review notes.

## P6 - Notebook Capture

- [ ] Design paper notebook template with OCR-friendly sections.
- [ ] Add camera capture flow.
- [ ] Add crop and perspective correction.
- [ ] Extract date, Top 3, Brain Dump, and Time Box Grid.
- [ ] Add OCR correction UI before saving.
- [ ] Add confidence scores and manual fallback.

## P7 - Notebook Commerce

- [ ] Launch only after app-only timeboxing and capture flows are validated.
- [ ] Define notebook SKU and page templates.
- [ ] Add Notebook Store screen.
- [ ] Add product landing content outside the core app flow.
- [ ] Add purchase provider decision.
- [ ] Add order history and support flow.
- [ ] Add privacy and terms updates for commerce data.

## Provider Notes

- Nylas and Cronofy are closest to the multi-calendar integration layer.
- Calendly is more scheduling-product oriented, but useful for studying provider connection UX.
- Cal.com is useful as an open scheduling platform reference, not necessarily the first integration layer.
- Android timer display should follow the same absolute `endTime` model as iOS Live Activity, with countdown rendering delegated to the OS.
- Watch, Firebase, and billing plan: `docs/product/WATCH_FIREBASE_BILLING_PLAN.md`.
