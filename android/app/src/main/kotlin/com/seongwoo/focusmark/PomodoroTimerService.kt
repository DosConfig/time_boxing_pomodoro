package com.seongwoo.focusmark

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper

class PomodoroTimerService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private val completion = Runnable { completeTimer() }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannels()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> stopTimer()
            ACTION_COMPLETE -> completeTimer()
            ACTION_PAUSE -> showPausedNotification()
            ACTION_UPDATE -> refreshNotification()
            ACTION_START, ACTION_RESUME, null -> startRunningTimer()
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        handler.removeCallbacks(completion)
        super.onDestroy()
    }

    private fun startRunningTimer() {
        val state = PomodoroTimerState.read(this)
        if (!state.isRunning) {
            if (state.active && state.remainingSeconds() <= 0) completeTimer() else stopTimer()
            return
        }
        startForeground(ONGOING_NOTIFICATION_ID, runningNotification(state))
        scheduleCompletion(state)
    }

    private fun showPausedNotification() {
        handler.removeCallbacks(completion)
        val state = PomodoroTimerState.read(this)
        if (!state.active) {
            stopTimer()
            return
        }
        startForeground(ONGOING_NOTIFICATION_ID, pausedNotification(state))
    }

    private fun refreshNotification() {
        val state = PomodoroTimerState.read(this)
        when {
            state.isRunning -> startForeground(
                ONGOING_NOTIFICATION_ID,
                runningNotification(state),
            )
            state.active && state.paused -> showPausedNotification()
            else -> stopTimer()
        }
    }

    private fun scheduleCompletion(state: PomodoroTimerState) {
        handler.removeCallbacks(completion)
        val delay = (state.endTimeMs - System.currentTimeMillis()).coerceAtLeast(0L)
        handler.postDelayed(completion, delay)
    }

    private fun completeTimer() {
        handler.removeCallbacks(completion)
        val state = PomodoroTimerState.read(this)
        PomodoroTimerState.complete(this)
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
        if (!state.notificationsEnabled) return

        val manager = getSystemService(NotificationManager::class.java)
        manager.notify(COMPLETION_NOTIFICATION_ID, completionNotification(state))
    }

    private fun stopTimer() {
        handler.removeCallbacks(completion)
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun runningNotification(state: PomodoroTimerState): Notification {
        val builder = notificationBuilder(ONGOING_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle(displayTitle(state))
            .setContentText(displayBody(state))
            .setContentIntent(appPendingIntent())
            .setCategory(Notification.CATEGORY_PROGRESS)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setShowWhen(true)
            .setWhen(state.endTimeMs)
            .setUsesChronometer(true)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            builder.setChronometerCountDown(true)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            builder.setForegroundServiceBehavior(Notification.FOREGROUND_SERVICE_IMMEDIATE)
        }
        return builder.build()
    }

    private fun pausedNotification(state: PomodoroTimerState): Notification {
        val minutes = state.remainingSeconds() / 60
        val seconds = state.remainingSeconds() % 60
        return notificationBuilder(ONGOING_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle(displayTitle(state))
            .setContentText("Paused · %02d:%02d".format(minutes, seconds))
            .setContentIntent(appPendingIntent())
            .setCategory(Notification.CATEGORY_PROGRESS)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .build()
    }

    private fun completionNotification(state: PomodoroTimerState): Notification {
        val isBreak = state.phase != "focus"
        val channelId = if (state.soundEnabled) {
            COMPLETION_CHANNEL_ID
        } else {
            SILENT_COMPLETION_CHANNEL_ID
        }
        return notificationBuilder(channelId)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle(
                if (isBreak) state.breakCompleteTitle else state.focusCompleteTitle,
            )
            .setContentText(
                listOf(
                    state.currentTimeBoxTitle,
                    state.currentTimeBoxTimeRange,
                    if (isBreak) state.breakCompleteBody else state.focusCompleteBody,
                ).filter(String::isNotBlank).joinToString(" · "),
            )
            .setContentIntent(appPendingIntent())
            .setAutoCancel(true)
            .setCategory(Notification.CATEGORY_ALARM)
            .build()
    }

    private fun displayTitle(state: PomodoroTimerState): String {
        return state.currentTimeBoxTitle.ifBlank {
            if (state.phase == "focus") "Focus" else "Break"
        }
    }

    private fun displayBody(state: PomodoroTimerState): String {
        val priority = state.topPriorities.firstOrNull().orEmpty()
        return listOf(state.currentTimeBoxTimeRange, priority)
            .filter(String::isNotBlank)
            .joinToString(" · ")
            .ifBlank { "Timebox Mark" }
    }

    private fun notificationBuilder(channelId: String): Notification.Builder {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, channelId)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
    }

    private fun appPendingIntent(): PendingIntent {
        val intent = packageManager.getLaunchIntentForPackage(packageName)
            ?: Intent(this, MainActivity::class.java)
        return PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(
            NotificationChannel(
                ONGOING_CHANNEL_ID,
                "Running timer",
                NotificationManager.IMPORTANCE_LOW,
            ).apply { description = "Shows the active Timebox Mark countdown." },
        )
        manager.createNotificationChannel(
            NotificationChannel(
                COMPLETION_CHANNEL_ID,
                "Timer completion",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply { description = "Alerts when a focus or break block ends." },
        )
        manager.createNotificationChannel(
            NotificationChannel(
                SILENT_COMPLETION_CHANNEL_ID,
                "Silent timer completion",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "Shows silent alerts when a focus or break block ends."
                setSound(null, null)
                enableVibration(false)
            },
        )
    }

    companion object {
        const val ACTION_START = "com.seongwoo.focusmark.timer.START"
        const val ACTION_PAUSE = "com.seongwoo.focusmark.timer.PAUSE"
        const val ACTION_RESUME = "com.seongwoo.focusmark.timer.RESUME"
        const val ACTION_STOP = "com.seongwoo.focusmark.timer.STOP"
        const val ACTION_COMPLETE = "com.seongwoo.focusmark.timer.COMPLETE"
        const val ACTION_UPDATE = "com.seongwoo.focusmark.timer.UPDATE"

        private const val ONGOING_CHANNEL_ID = "pomodoro_running"
        private const val COMPLETION_CHANNEL_ID = "pomodoro_completion"
        private const val SILENT_COMPLETION_CHANNEL_ID = "pomodoro_completion_silent"
        private const val ONGOING_NOTIFICATION_ID = 4101
        private const val COMPLETION_NOTIFICATION_ID = 4102
    }
}
