# Timeboxing Strategy

## Product Thesis

The app should become a daily timeboxing planner, not only a Pomodoro timer.

The current MVP is app-only. Users should be able to create and run a timeboxed day without buying a notebook, taking a photo, or connecting a calendar.

Photo capture and notebook sales are future expansion paths after the app-only workflow becomes fast and trustworthy.

The worksheet reference has a strong product shape:

1. Brain dump everything on the user's mind.
2. Pick the top three priorities.
3. Assign work to a time-boxed day grid.
4. Start the current box.
5. Track the running box through the app, Live Activity, and local alerts.
6. Review what was planned versus what was actually done.

Pomodoro then becomes the execution engine inside a selected time box.

## Elon Musk / Timeboxing Notes

The popular "Elon Musk uses five-minute blocks" claim is widely repeated, but it should not be used as a hard product claim. A safer interpretation is:

- plan work in explicit blocks,
- protect uninterrupted thinking time,
- reduce context switching,
- make the calendar the source of execution intent.

This is a better fit for the product than copying five-minute scheduling. Five-minute granularity would create too much UI friction for most users.

## Proposed App Flow

### Today

- Brain Dump
- Top 3 Priorities
- Time Box Grid
- Current Box

### Focus

- Active timer
- Pause / resume
- Local alert and sound settings
- Live Activity

### Review

- Planned minutes
- Completed minutes
- Interrupted boxes
- Skipped boxes

### Settings

- Default block size
- Pomodoro preset
- Local alerts
- Sound
- Live Activity
- Calendar sync
- Sign in

## Time Box Model

```text
TimeBox
  id
  title
  notes
  startAt
  endAt
  status: planned | active | completed | skipped
  source: manual | calendar | generated
  calendarEventId?
```

## MVP Recommendation

Build in this order:

1. Local Today Plan screen with brain dump, top three priorities, and time grid.
2. Tap a time box to start the focus timer.
3. Save local plan data on-device.
4. Export selected boxes to Apple Calendar.
5. Add Firebase Auth and cloud sync.
6. Add Google Calendar sync.
7. Add notebook capture.

Calendar, login, and notebook capture should not block the first portfolio-ready version. They are strong follow-up features once the local planning loop feels good.
