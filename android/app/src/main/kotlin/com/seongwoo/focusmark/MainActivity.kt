package com.seongwoo.focusmark

import android.Manifest
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val handler = Handler(Looper.getMainLooper())
    private lateinit var timerChannel: MethodChannel
    private var completionDelivered = false

    private val ticker = object : Runnable {
        override fun run() {
            val state = PomodoroTimerState.read(this@MainActivity)
            if (!state.active || state.paused) return

            val remaining = state.remainingSeconds()
            timerChannel.invokeMethod("onTick", mapOf("remainingTime" to remaining))
            if (remaining <= 0) {
                if (!completionDelivered) {
                    completionDelivered = true
                    timerChannel.invokeMethod("onComplete", null)
                    sendTimerAction(PomodoroTimerService.ACTION_COMPLETE)
                }
                return
            }
            handler.postDelayed(this, 1_000L)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        timerChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            TIMER_CHANNEL,
        )
        timerChannel.setMethodCallHandler(::handleTimerCall)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CALENDAR_CHANNEL,
        ).setMethodCallHandler(::handleCalendarCall)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (PomodoroTimerState.read(this).isRunning) {
            startTicker()
        } else if (AndroidScheduleState.read(this).enabled) {
            reconcileTimerService()
        }
    }

    override fun onDestroy() {
        handler.removeCallbacks(ticker)
        super.onDestroy()
    }

    private fun handleTimerCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startTimer" -> {
                val seconds = call.argument<Number>("seconds")?.toInt() ?: 0
                if (seconds <= 0) {
                    result.success(false)
                    return
                }
                requestNotificationPermissionIfNeeded()
                PomodoroTimerState.start(this, call, seconds)
                completionDelivered = false
                sendTimerAction(PomodoroTimerService.ACTION_START)
                startTicker()
                result.success(true)
            }
            "pauseTimer" -> {
                PomodoroTimerState.pause(this)
                handler.removeCallbacks(ticker)
                sendTimerAction(PomodoroTimerService.ACTION_PAUSE)
                result.success(true)
            }
            "resumeTimer" -> {
                val resumed = PomodoroTimerState.resume(this)
                if (resumed) {
                    completionDelivered = false
                    sendTimerAction(PomodoroTimerService.ACTION_RESUME)
                    startTicker()
                }
                result.success(resumed)
            }
            "stopTimer" -> {
                handler.removeCallbacks(ticker)
                PomodoroTimerState.stop(this)
                sendTimerAction(PomodoroTimerService.ACTION_STOP)
                result.success(true)
            }
            "restoreState" -> result.success(restoreState())
            "updateNotificationSettings" -> {
                PomodoroTimerState.updateNotificationSettings(this, call)
                reconcileTimerService()
                result.success(true)
            }
            "syncAndroidSchedule" -> {
                val schedule = AndroidScheduleState.write(this, call)
                if (schedule.enabled) requestNotificationPermissionIfNeeded()
                reconcileTimerService(schedule)
                result.success(
                    mapOf(
                        "enabled" to schedule.enabled,
                        "entryCount" to schedule.entries.size,
                    ),
                )
            }
            "getActivityStatus" -> {
                val state = PomodoroTimerState.read(this)
                result.success(
                    when {
                        state.isRunning -> "running"
                        state.active && state.paused -> "paused"
                        else -> "idle"
                    },
                )
            }
            "getRemainingTime" -> {
                result.success(PomodoroTimerState.read(this).remainingSeconds())
            }
            else -> result.notImplemented()
        }
    }

    private fun handleCalendarCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "openCalendar" -> openCalendar(
                provider = call.argument<String>("provider").orEmpty(),
                result = result,
            )
            else -> result.notImplemented()
        }
    }

    private fun openCalendar(provider: String, result: MethodChannel.Result) {
        if (provider != "google") {
            result.success(mapOf("status" to "unavailable"))
            return
        }

        packageManager.getLaunchIntentForPackage(GOOGLE_CALENDAR_PACKAGE)?.let { intent ->
            startActivity(intent)
            result.success(mapOf("status" to "opened"))
            return
        }

        try {
            startActivity(
                Intent(
                    Intent.ACTION_VIEW,
                    Uri.parse("market://details?id=$GOOGLE_CALENDAR_PACKAGE"),
                ),
            )
        } catch (_: ActivityNotFoundException) {
            val fallbackIntent = Intent(
                Intent.ACTION_VIEW,
                Uri.parse("https://play.google.com/store/apps/details?id=$GOOGLE_CALENDAR_PACKAGE"),
            )
            try {
                startActivity(fallbackIntent)
            } catch (_: ActivityNotFoundException) {
                result.success(mapOf("status" to "unavailable"))
                return
            }
        } catch (_: SecurityException) {
            result.success(mapOf("status" to "unavailable"))
            return
        }
        result.success(mapOf("status" to "storeOpened"))
    }

    private fun restoreState(): Map<String, Any> {
        val state = PomodoroTimerState.read(this)
        if (!state.active) return state.payload("idle", 0)
        if (state.paused) return state.payload("paused", state.remainingSeconds())
        if (state.remainingSeconds() <= 0) {
            PomodoroTimerState.complete(this)
            return state.payload("completed", 0)
        }

        completionDelivered = false
        sendTimerAction(PomodoroTimerService.ACTION_RESUME)
        startTicker()
        return state.payload("running", state.remainingSeconds())
    }

    private fun startTicker() {
        handler.removeCallbacks(ticker)
        handler.post(ticker)
    }

    private fun reconcileTimerService(
        schedule: AndroidScheduleState = AndroidScheduleState.read(this),
    ) {
        val timer = PomodoroTimerState.read(this)
        when {
            timer.isRunning || (timer.active && timer.paused) -> {
                sendTimerAction(PomodoroTimerService.ACTION_UPDATE)
            }
            schedule.enabled && schedule.hasCurrentOrFutureEntry(System.currentTimeMillis()) -> {
                sendTimerAction(PomodoroTimerService.ACTION_SYNC_SCHEDULE)
            }
            else -> stopService(Intent(this, PomodoroTimerService::class.java))
        }
    }

    private fun sendTimerAction(action: String) {
        val intent = Intent(this, PomodoroTimerService::class.java).setAction(action)
        val mustEnterForeground =
            action == PomodoroTimerService.ACTION_START ||
                action == PomodoroTimerService.ACTION_RESUME
        if (
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
            mustEnterForeground
        ) {
            startForegroundService(intent)
        } else {
            // Sync/update can legitimately decide that no timer remains. Starting
            // those actions as foreground services would make Android require a
            // notification even when the correct outcome is to stop immediately.
            startService(intent)
        }
    }

    private fun requestNotificationPermissionIfNeeded() {
        if (
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 4102)
        }
    }

    companion object {
        private const val TIMER_CHANNEL = "com.pomodoro/timer"
        private const val CALENDAR_CHANNEL = "com.pomodoro/calendar"
        private const val GOOGLE_CALENDAR_PACKAGE = "com.google.android.calendar"
    }
}
