import assert from "node:assert/strict";
import test from "node:test";

import {scheduledContent} from "./live_activity_state.js";

const registration = {
  sessionCount: 1,
  sessionGoal: 5,
  localizedFocusTitle: "집중",
};

test("현재 시간의 카드와 남은 시간을 content-state로 만든다", () => {
  const result = scheduledContent(
    new Date("2026-07-29T00:10:30Z"),
    "Asia/Seoul",
    {
      updatedAtEpochMs: 1,
      topPriorities: ["Ship it", "", "Review"],
      timeBoxes: [
        {
          id: "box-0900",
          title: "Deep work",
          timeRange: "09:00-09:30",
          durationSeconds: 1800,
        },
      ],
    },
    registration,
  );

  assert.match(result.signature, /box-0900/);
  assert.equal(result.contentState.status, "running");
  assert.equal(result.contentState.currentTimeBoxTitle, "Deep work");
  assert.equal(result.contentState.totalDuration, 1800);
  assert.deepEqual(result.contentState.topPriorities, ["Ship it", "Review"]);
});

test("카드 사이 공백에서는 같은 LA를 paused 상태로 유지한다", () => {
  const result = scheduledContent(
    new Date("2026-07-29T00:40:00Z"),
    "Asia/Seoul",
    {updatedAtEpochMs: 1, timeBoxes: []},
    registration,
  );

  assert.match(result.signature, /^idle:/);
  assert.equal(result.contentState.status, "paused");
  assert.equal(result.contentState.pausedRemainingSeconds, 0);
});
