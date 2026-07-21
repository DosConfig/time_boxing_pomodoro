package com.seongwoo.focusmark

import org.junit.Assert.assertEquals
import org.junit.Test

class PomodoroTimerStateTest {
    @Test
    fun runningTimerRoundsRemainingTimeUpFromAbsoluteEndTime() {
        val state = timerState(endTimeMs = 31_001L)

        assertEquals(31, state.remainingSeconds(nowMs = 1_000L))
        assertEquals(1, state.remainingSeconds(nowMs = 30_001L))
        assertEquals(0, state.remainingSeconds(nowMs = 31_001L))
    }

    @Test
    fun pausedTimerUsesPersistedRemainingTime() {
        val state = timerState(
            paused = true,
            endTimeMs = 0L,
            pausedRemainingSeconds = 90,
        )

        assertEquals(90, state.remainingSeconds(nowMs = 999_999L))
    }

    private fun timerState(
        paused: Boolean = false,
        endTimeMs: Long,
        pausedRemainingSeconds: Int = 0,
    ) = PomodoroTimerState(
        active = true,
        paused = paused,
        endTimeMs = endTimeMs,
        pausedRemainingSeconds = pausedRemainingSeconds,
        targetDurationSeconds = 1_800,
        phase = "focus",
        sessionCount = 0,
        sessionGoal = 5,
        notificationsEnabled = true,
        soundEnabled = true,
        topPriorities = emptyList(),
        currentTimeBoxTitle = "Focus",
        currentTimeBoxTimeRange = "09:00-09:30",
        focusCompleteTitle = "Focus complete",
        breakCompleteTitle = "Break complete",
        focusCompleteBody = "Done",
        breakCompleteBody = "Done",
    )
}
