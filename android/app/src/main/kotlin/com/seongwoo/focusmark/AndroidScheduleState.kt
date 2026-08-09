package com.seongwoo.focusmark

import android.content.Context
import io.flutter.plugin.common.MethodCall
import org.json.JSONArray
import org.json.JSONObject

data class AndroidScheduleEntry(
    val id: String,
    val title: String,
    val timeRange: String,
    val startTimeMs: Long,
    val endTimeMs: Long,
) {
    fun contains(nowMs: Long): Boolean = nowMs >= startTimeMs && nowMs < endTimeMs
}

data class AndroidScheduleState(
    val enabled: Boolean,
    val dateKey: String,
    val notificationsEnabled: Boolean,
    val soundEnabled: Boolean,
    val topPriorities: List<String>,
    val focusCompleteTitle: String,
    val focusCompleteBody: String,
    val entries: List<AndroidScheduleEntry>,
) {
    fun currentEntry(nowMs: Long): AndroidScheduleEntry? =
        entries.firstOrNull { it.contains(nowMs) }

    fun nextEntry(nowMs: Long): AndroidScheduleEntry? =
        entries.firstOrNull { it.startTimeMs > nowMs }

    fun hasCurrentOrFutureEntry(nowMs: Long): Boolean =
        currentEntry(nowMs) != null || nextEntry(nowMs) != null

    companion object {
        private const val PREFS = "pomodoro.android.schedule"
        private const val PAYLOAD = "payload"

        fun empty() = AndroidScheduleState(
            enabled = false,
            dateKey = "",
            notificationsEnabled = true,
            soundEnabled = true,
            topPriorities = emptyList(),
            focusCompleteTitle = "Focus complete",
            focusCompleteBody = "The next scheduled timer is starting.",
            entries = emptyList(),
        )

        fun read(context: Context): AndroidScheduleState {
            val encoded = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                .getString(PAYLOAD, null) ?: return empty()
            return runCatching { fromJson(JSONObject(encoded)) }.getOrElse { empty() }
        }

        fun write(context: Context, call: MethodCall): AndroidScheduleState {
            val localizedCopy = call.argument<Map<String, String>>("localizedCopy").orEmpty()
            val rawEntries = call.argument<List<Map<String, Any?>>>("entries").orEmpty()
            val state = AndroidScheduleState(
                enabled = call.argument<Boolean>("enabled") ?: false,
                dateKey = call.argument<String>("dateKey").orEmpty(),
                notificationsEnabled = call.argument<Boolean>("notificationsEnabled") ?: true,
                soundEnabled = call.argument<Boolean>("soundEnabled") ?: true,
                topPriorities = call.argument<List<String>>("topPriorities").orEmpty(),
                focusCompleteTitle = localizedCopy["focusCompleteTitle"] ?: "Focus complete",
                focusCompleteBody = localizedCopy["focusCompleteBody"]
                    ?: "The next scheduled timer is starting.",
                entries = rawEntries.mapNotNull(::entryFromMap)
                    .sortedBy(AndroidScheduleEntry::startTimeMs),
            )
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                .edit()
                .putString(PAYLOAD, state.toJson().toString())
                .apply()
            return state
        }

        private fun entryFromMap(value: Map<String, Any?>): AndroidScheduleEntry? {
            val start = (value["startTimeMs"] as? Number)?.toLong() ?: return null
            val end = (value["endTimeMs"] as? Number)?.toLong() ?: return null
            if (end <= start) return null
            return AndroidScheduleEntry(
                id = value["id"]?.toString().orEmpty(),
                title = value["title"]?.toString().orEmpty(),
                timeRange = value["timeRange"]?.toString().orEmpty(),
                startTimeMs = start,
                endTimeMs = end,
            )
        }

        private fun fromJson(json: JSONObject): AndroidScheduleState {
            val prioritiesJson = json.optJSONArray("topPriorities") ?: JSONArray()
            val entriesJson = json.optJSONArray("entries") ?: JSONArray()
            val entries = buildList {
                for (index in 0 until entriesJson.length()) {
                    val item = entriesJson.optJSONObject(index) ?: continue
                    val start = item.optLong("startTimeMs")
                    val end = item.optLong("endTimeMs")
                    if (end <= start) continue
                    add(
                        AndroidScheduleEntry(
                            id = item.optString("id"),
                            title = item.optString("title"),
                            timeRange = item.optString("timeRange"),
                            startTimeMs = start,
                            endTimeMs = end,
                        ),
                    )
                }
            }.sortedBy(AndroidScheduleEntry::startTimeMs)
            return AndroidScheduleState(
                enabled = json.optBoolean("enabled"),
                dateKey = json.optString("dateKey"),
                notificationsEnabled = json.optBoolean("notificationsEnabled", true),
                soundEnabled = json.optBoolean("soundEnabled", true),
                topPriorities = buildList {
                    for (index in 0 until prioritiesJson.length()) {
                        add(prioritiesJson.optString(index))
                    }
                },
                focusCompleteTitle = json.optString("focusCompleteTitle", "Focus complete"),
                focusCompleteBody = json.optString(
                    "focusCompleteBody",
                    "The next scheduled timer is starting.",
                ),
                entries = entries,
            )
        }
    }

    private fun toJson(): JSONObject = JSONObject().apply {
        put("enabled", enabled)
        put("dateKey", dateKey)
        put("notificationsEnabled", notificationsEnabled)
        put("soundEnabled", soundEnabled)
        put("topPriorities", JSONArray(topPriorities))
        put("focusCompleteTitle", focusCompleteTitle)
        put("focusCompleteBody", focusCompleteBody)
        put(
            "entries",
            JSONArray().apply {
                entries.forEach { entry ->
                    put(
                        JSONObject().apply {
                            put("id", entry.id)
                            put("title", entry.title)
                            put("timeRange", entry.timeRange)
                            put("startTimeMs", entry.startTimeMs)
                            put("endTimeMs", entry.endTimeMs)
                        },
                    )
                }
            },
        )
    }
}
