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
- [x] Document menu structure.
- [x] Keep photo capture out of the current primary flow.

## P1 - Local Timeboxing Planner

- [ ] Build Today screen.
- [ ] Add fast Brain Dump list with minimal typing friction.
- [ ] Add Top 3 Priorities editor with one-tap promote from Brain Dump.
- [ ] Add day time-box grid with quick add and drag-to-adjust.
- [x] Let users select a box and start Focus mode from it.
- [ ] Persist Today Plan locally.
- [ ] Add Review screen for planned versus completed boxes.
- [ ] Add default templates so users do not start from an empty screen.

## P2 - Calendar Sync

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
- [ ] Store user plans and provider tokens securely.
- [ ] Add account deletion flow for store review.

## P4 - Notebook Capture

- [ ] Design paper notebook template with OCR-friendly sections.
- [ ] Add camera capture flow.
- [ ] Add crop and perspective correction.
- [ ] Extract date, Top 3, Brain Dump, and Time Box Grid.
- [ ] Add OCR correction UI before saving.
- [ ] Add confidence scores and manual fallback.

## P5 - Notebook Commerce

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
