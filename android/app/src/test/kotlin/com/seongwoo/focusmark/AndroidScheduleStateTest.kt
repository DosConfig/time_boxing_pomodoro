package com.seongwoo.focusmark

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class AndroidScheduleStateTest {
    private val schedule = AndroidScheduleState(
        enabled = true,
        dateKey = "2026-08-09",
        notificationsEnabled = true,
        soundEnabled = true,
        topPriorities = emptyList(),
        focusCompleteTitle = "Complete",
        focusCompleteBody = "Next timer starts",
        entries = listOf(
            entry("first", 1_000L, 2_000L),
            entry("second", 3_000L, 4_000L),
        ),
    )

    @Test
    fun currentEntryUsesStartInclusiveAndEndExclusiveBoundaries() {
        assertEquals("first", schedule.currentEntry(1_000L)?.id)
        assertNull(schedule.currentEntry(2_000L))
        assertEquals("second", schedule.currentEntry(3_999L)?.id)
    }

    @Test
    fun nextEntryReturnsTheFirstFutureCardAcrossAGap() {
        assertEquals("first", schedule.nextEntry(0L)?.id)
        assertEquals("second", schedule.nextEntry(2_500L)?.id)
        assertNull(schedule.nextEntry(4_000L))
    }

    @Test
    fun currentOrFutureEntryBecomesFalseAfterTheFinalBoundary() {
        assertTrue(schedule.hasCurrentOrFutureEntry(0L))
        assertTrue(schedule.hasCurrentOrFutureEntry(2_500L))
        assertFalse(schedule.hasCurrentOrFutureEntry(4_000L))
    }

    private fun entry(id: String, start: Long, end: Long) = AndroidScheduleEntry(
        id = id,
        title = id,
        timeRange = "",
        startTimeMs = start,
        endTimeMs = end,
    )
}
