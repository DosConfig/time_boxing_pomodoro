package com.seongwoo.focusmark

import android.content.Context
import io.flutter.plugin.common.MethodCall
import kotlin.math.ceil

data class PomodoroTimerState(
    val active: Boolean,
    val paused: Boolean,
    val endTimeMs: Long,
    val pausedRemainingSeconds: Int,
    val targetDurationSeconds: Int,
    val phase: String,
    val sessionCount: Int,
    val sessionGoal: Int,
    val notificationsEnabled: Boolean,
    val soundEnabled: Boolean,
    val topPriorities: List<String>,
    val currentTimeBoxTitle: String,
    val currentTimeBoxTimeRange: String,
    val focusCompleteTitle: String,
    val breakCompleteTitle: String,
    val focusCompleteBody: String,
    val breakCompleteBody: String,
) {
    val isRunning: Boolean
        get() = active && !paused && remainingSeconds() > 0

    fun remainingSeconds(nowMs: Long = System.currentTimeMillis()): Int {
        if (!active) return 0
        if (paused) return pausedRemainingSeconds.coerceAtLeast(0)
        return ceil((endTimeMs - nowMs).coerceAtLeast(0L) / 1_000.0).toInt()
    }

    fun payload(status: String, remainingTime: Int): Map<String, Any> = mapOf(
        "status" to status,
        "remainingTime" to remainingTime,
        "sessionCount" to sessionCount,
        "sessionGoal" to sessionGoal,
        "phase" to phase,
        "notificationsEnabled" to notificationsEnabled,
        "soundEnabled" to soundEnabled,
        "topPriorities" to topPriorities,
        "currentTimeBoxTitle" to currentTimeBoxTitle,
        "currentTimeBoxTimeRange" to currentTimeBoxTimeRange,
    )

    companion object {
        private const val PREFS = "pomodoro.timer"
        private const val ACTIVE = "active"
        private const val PAUSED = "paused"
        private const val END_TIME = "endTimeMs"
        private const val PAUSED_REMAINING = "pausedRemainingSeconds"
        private const val TARGET_DURATION = "targetDurationSeconds"
        private const val PHASE = "phase"
        private const val SESSION_COUNT = "sessionCount"
        private const val SESSION_GOAL = "sessionGoal"
        private const val NOTIFICATIONS = "notificationsEnabled"
        private const val SOUND = "soundEnabled"
        private const val TOP_PRIORITIES = "topPriorities"
        private const val TITLE = "currentTimeBoxTitle"
        private const val RANGE = "currentTimeBoxTimeRange"
        private const val FOCUS_COMPLETE_TITLE = "focusCompleteTitle"
        private const val BREAK_COMPLETE_TITLE = "breakCompleteTitle"
        private const val FOCUS_COMPLETE_BODY = "focusCompleteBody"
        private const val BREAK_COMPLETE_BODY = "breakCompleteBody"
        private const val LIST_SEPARATOR = "\u001F"

        fun read(context: Context): PomodoroTimerState {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            return PomodoroTimerState(
                active = prefs.getBoolean(ACTIVE, false),
                paused = prefs.getBoolean(PAUSED, false),
                endTimeMs = prefs.getLong(END_TIME, 0L),
                pausedRemainingSeconds = prefs.getInt(PAUSED_REMAINING, 0),
                targetDurationSeconds = prefs.getInt(TARGET_DURATION, 0),
                phase = prefs.getString(PHASE, "focus") ?: "focus",
                sessionCount = prefs.getInt(SESSION_COUNT, 0),
                sessionGoal = prefs.getInt(SESSION_GOAL, 5).coerceAtLeast(1),
                notificationsEnabled = prefs.getBoolean(NOTIFICATIONS, true),
                soundEnabled = prefs.getBoolean(SOUND, true),
                topPriorities = (prefs.getString(TOP_PRIORITIES, "") ?: "")
                    .split(LIST_SEPARATOR)
                    .filter(String::isNotBlank),
                currentTimeBoxTitle = prefs.getString(TITLE, "") ?: "",
                currentTimeBoxTimeRange = prefs.getString(RANGE, "") ?: "",
                focusCompleteTitle = prefs.getString(FOCUS_COMPLETE_TITLE, "Focus complete")
                    ?: "Focus complete",
                breakCompleteTitle = prefs.getString(BREAK_COMPLETE_TITLE, "Break complete")
                    ?: "Break complete",
                focusCompleteBody = prefs.getString(
                    FOCUS_COMPLETE_BODY,
                    "The next scheduled timer is starting.",
                ) ?: "The next scheduled timer is starting.",
                breakCompleteBody = prefs.getString(
                    BREAK_COMPLETE_BODY,
                    "The next scheduled timer is starting.",
                ) ?: "The next scheduled timer is starting.",
            )
        }

        fun start(context: Context, call: MethodCall, seconds: Int) {
            val localizedCopy = call.argument<Map<String, String>>("localizedCopy").orEmpty()
            val priorities = call.argument<List<String>>("topPriorities").orEmpty()
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
                .putBoolean(ACTIVE, true)
                .putBoolean(PAUSED, false)
                .putLong(END_TIME, System.currentTimeMillis() + seconds * 1_000L)
                .putInt(PAUSED_REMAINING, seconds)
                .putInt(TARGET_DURATION, seconds)
                .putString(PHASE, call.argument<String>("phase") ?: "focus")
                .putInt(SESSION_COUNT, call.argument<Number>("sessionCount")?.toInt() ?: 0)
                .putInt(SESSION_GOAL, call.argument<Number>("sessionGoal")?.toInt() ?: 5)
                .putBoolean(NOTIFICATIONS, call.argument<Boolean>("notificationsEnabled") ?: true)
                .putBoolean(SOUND, call.argument<Boolean>("soundEnabled") ?: true)
                .putString(TOP_PRIORITIES, priorities.joinToString(LIST_SEPARATOR))
                .putString(TITLE, call.argument<String>("currentTimeBoxTitle") ?: "")
                .putString(RANGE, call.argument<String>("currentTimeBoxTimeRange") ?: "")
                .putString(FOCUS_COMPLETE_TITLE, localizedCopy[FOCUS_COMPLETE_TITLE])
                .putString(BREAK_COMPLETE_TITLE, localizedCopy[BREAK_COMPLETE_TITLE])
                .putString(FOCUS_COMPLETE_BODY, localizedCopy[FOCUS_COMPLETE_BODY])
                .putString(BREAK_COMPLETE_BODY, localizedCopy[BREAK_COMPLETE_BODY])
                .apply()
        }

        fun startScheduled(
            context: Context,
            entry: AndroidScheduleEntry,
            schedule: AndroidScheduleState,
        ) {
            val remainingSeconds = ceil(
                (entry.endTimeMs - System.currentTimeMillis()).coerceAtLeast(0L) / 1_000.0,
            ).toInt()
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
                .putBoolean(ACTIVE, true)
                .putBoolean(PAUSED, false)
                .putLong(END_TIME, entry.endTimeMs)
                .putInt(PAUSED_REMAINING, remainingSeconds)
                .putInt(TARGET_DURATION, remainingSeconds)
                .putString(PHASE, "focus")
                .putBoolean(NOTIFICATIONS, schedule.notificationsEnabled)
                .putBoolean(SOUND, schedule.soundEnabled)
                .putString(TOP_PRIORITIES, schedule.topPriorities.joinToString(LIST_SEPARATOR))
                .putString(TITLE, entry.title)
                .putString(RANGE, entry.timeRange)
                .putString(FOCUS_COMPLETE_TITLE, schedule.focusCompleteTitle)
                .putString(FOCUS_COMPLETE_BODY, schedule.focusCompleteBody)
                .apply()
        }

        fun pause(context: Context) {
            val current = read(context)
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
                .putBoolean(PAUSED, true)
                .putInt(PAUSED_REMAINING, current.remainingSeconds())
                .putLong(END_TIME, 0L)
                .apply()
        }

        fun resume(context: Context): Boolean {
            val current = read(context)
            val remaining = current.remainingSeconds()
            if (!current.active || remaining <= 0) return false
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
                .putBoolean(PAUSED, false)
                .putLong(END_TIME, System.currentTimeMillis() + remaining * 1_000L)
                .apply()
            return true
        }

        fun stop(context: Context) {
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
                .putBoolean(ACTIVE, false)
                .putBoolean(PAUSED, false)
                .putLong(END_TIME, 0L)
                .putInt(PAUSED_REMAINING, 0)
                .apply()
        }

        fun complete(context: Context) = stop(context)

        fun updateNotificationSettings(context: Context, call: MethodCall) {
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
                .putBoolean(NOTIFICATIONS, call.argument<Boolean>("notificationsEnabled") ?: true)
                .putBoolean(SOUND, call.argument<Boolean>("soundEnabled") ?: true)
                .apply()
        }
    }
}
