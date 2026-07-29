export type TimeBox = {
  id?: string;
  title?: string;
  timeRange?: string;
  durationSeconds?: number;
};

export type LiveActivityDocument = {
  sessionCount?: number;
  sessionGoal?: number;
  localizedFocusTitle?: string;
  localizedShortBreakTitle?: string;
  localizedLongBreakTitle?: string;
  localizedPausedTitle?: string;
  localizedTopPriorityLabel?: string;
};

export type Plan = {
  updatedAtEpochMs?: number;
  topPriorities?: string[];
  timeBoxes?: TimeBox[];
};

export type ScheduledContent = {
  signature: string;
  contentState: Record<string, unknown>;
};

const appleReferenceDateOffsetSeconds = 978_307_200;

export function scheduledContent(
  now: Date,
  timeZone: string,
  plan: Plan,
  registration: LiveActivityDocument,
): ScheduledContent {
  const clock = clockParts(now, timeZone);
  const box = (plan.timeBoxes ?? []).find((candidate) => {
    const range = parseRange(candidate.timeRange ?? "");
    return range !== null &&
      clock.minutes >= range.start &&
      clock.minutes < range.end;
  });
  const priorities = (plan.topPriorities ?? [])
    .map((value) => value.trim())
    .filter(Boolean)
    .slice(0, 3);

  if (box === undefined) {
    return {
      signature: `idle:${clock.dateKey}:${plan.updatedAtEpochMs ?? 0}`,
      contentState: baseContent(registration, priorities, {
        endTime: now.getTime() / 1000 - appleReferenceDateOffsetSeconds,
        status: "paused",
        phase: "focus",
        totalDuration: 1,
        pausedRemainingSeconds: 0,
        currentTimeBoxTitle: "",
        currentTimeBoxTimeRange: "",
      }),
    };
  }

  const range = parseRange(box.timeRange ?? "")!;
  const remainingSeconds = Math.max(
    0,
    (range.end - clock.minutes) * 60 - clock.second,
  );
  const endUnixSeconds = now.getTime() / 1000 + remainingSeconds;
  const durationSeconds = box.durationSeconds ??
    Math.max(1, (range.end - range.start) * 60);
  return {
    signature: [
      "running",
      clock.dateKey,
      box.id ?? "",
      box.title ?? "",
      box.timeRange ?? "",
      plan.updatedAtEpochMs ?? 0,
    ].join(":"),
    contentState: baseContent(registration, priorities, {
      // ActivityKit uses Codable's default Date strategy: seconds since 2001-01-01.
      endTime: endUnixSeconds - appleReferenceDateOffsetSeconds,
      status: "running",
      phase: "focus",
      totalDuration: durationSeconds,
      pausedRemainingSeconds: null,
      currentTimeBoxTitle: box.title?.trim() ?? "",
      currentTimeBoxTimeRange: box.timeRange ?? "",
    }),
  };
}

function baseContent(
  registration: LiveActivityDocument,
  topPriorities: string[],
  dynamic: Record<string, unknown>,
): Record<string, unknown> {
  return {
    ...dynamic,
    sessionCount: registration.sessionCount ?? 0,
    sessionGoal: registration.sessionGoal ?? 5,
    topPriorities,
    localizedFocusTitle: registration.localizedFocusTitle ?? "Focus",
    localizedShortBreakTitle:
      registration.localizedShortBreakTitle ?? "Short Break",
    localizedLongBreakTitle:
      registration.localizedLongBreakTitle ?? "Long Break",
    localizedPausedTitle: registration.localizedPausedTitle ?? "Paused",
    localizedTopPriorityLabel:
      registration.localizedTopPriorityLabel ?? "Top priority",
  };
}

function parseRange(value: string): {start: number; end: number} | null {
  const match = /^(\d{1,2}):(\d{2})-(\d{1,2}):(\d{2})$/.exec(value.trim());
  if (match === null) return null;
  const start = Number(match[1]) * 60 + Number(match[2]);
  let end = Number(match[3]) * 60 + Number(match[4]);
  if (end <= start) end += 24 * 60;
  return {start, end};
}

function clockParts(
  date: Date,
  timeZone: string,
): {dateKey: string; minutes: number; second: number} {
  const parts = new Intl.DateTimeFormat("en-US", {
    timeZone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
    hourCycle: "h23",
  }).formatToParts(date);
  const value = (type: Intl.DateTimeFormatPartTypes) =>
    Number(parts.find((part) => part.type === type)?.value ?? 0);
  const year = value("year");
  const month = value("month");
  const day = value("day");
  const hour = value("hour");
  const minute = value("minute");
  return {
    dateKey: `${year.toString().padStart(4, "0")}-${month
      .toString()
      .padStart(2, "0")}-${day.toString().padStart(2, "0")}`,
    minutes: hour * 60 + minute,
    second: value("second"),
  };
}
