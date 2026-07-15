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
- [x] Replace visible edit/delete buttons with swipe actions on time boxes.
- [x] Add foreground in-app completion banner and iOS foreground notification presentation.
- [x] Document menu structure.
- [x] Keep photo capture out of the current primary flow.

## P1 - Local Timeboxing Planner

- [x] Build Today screen.
- [x] Add fast Brain Dump list with minimal typing friction.
- [x] Add Top 3 Priorities editor with one-tap promote from Brain Dump.
- [x] Add calendar-style 30-minute time-slot board.
- [x] Add long-press drag placement for 30-minute time boxes.
- [ ] Add time-box duration adjustment after fixed-slot MVP is validated.
- [x] Let users select a box and start Focus mode from it.
- [ ] Persist Today Plan locally.
- [ ] Add Review screen for planned versus completed boxes.
- [ ] Add default templates so users do not start from an empty screen.

## P2 - Calendar Sync

- [x] Add Calendar tab and provider connection hub.
- [ ] Add Apple Calendar write-only export with EventKit.
- [ ] Add calendar event mapping for TimeBox.
- [ ] Add conflict detection against existing calendars.
- [ ] Add Google Calendar integration.
- [ ] Evaluate Nylas and Cronofy as multi-provider calendar layers.
- [ ] Add Outlook / Microsoft 365 provider path.
- [ ] Track external calendar event IDs for update/delete.

## P3 - Cloud and Auth

- [ ] Add Firebase project.
- [ ] Add Firebase Auth.
- [ ] Use Sign in with Apple as the primary iOS login.
- [ ] Use Google sign-in where Google Calendar is connected.
- [ ] Add anonymous/local user migration path into Firebase account.
- [ ] Add local-first repository boundary for free local mode versus paid sync mode.
- [ ] Add Firestore data model for days, time boxes, settings, devices, and entitlements.
- [ ] Store user plans and provider tokens securely.
- [ ] Add account deletion flow for store review.

## P4 - Watch Companion Apps

- [ ] Add entitlement gate for watch sync.
- [ ] Add Apple Watch SwiftUI companion target.
- [ ] Sync current timer snapshot from iPhone to Apple Watch through WatchConnectivity.
- [ ] Add Apple Watch controls for pause, resume, skip, and mark done.
- [ ] Add Apple Watch haptic completion feedback.
- [ ] Add Android app foundation before Wear OS work.
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
- Watch, Firebase, and billing plan: `docs/product/WATCH_FIREBASE_BILLING_PLAN.md`.
