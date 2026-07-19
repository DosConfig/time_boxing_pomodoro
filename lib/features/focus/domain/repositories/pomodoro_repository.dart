import '../entities/pomodoro.dart';
import '../entities/native_timer_copy.dart';
import '../entities/daily_plan_summary.dart';

abstract class PomodoroRepository {
  Pomodoro getPomodoro();
  void updatePomodoro(Pomodoro pomodoro);
  Future<Pomodoro> restoreTodayPlan(Pomodoro fallback);
  Future<List<DailyPlanSummary>> loadDailyPlanHistory({int days = 7});
  Stream<int> startTimer({
    required String phase,
    required bool notificationsEnabled,
    required bool soundEnabled,
    required List<String> topPriorities,
    required String currentTimeBoxTitle,
    required String currentTimeBoxTimeRange,
    required NativeTimerCopy nativeCopy,
  });
  Stream<int> ticks();
  Future<void> pauseTimer();
  Future<void> resumeTimer();
  Future<void> stopTimer();
  Future<TimerSnapshot> restoreState(Pomodoro fallback);
  Future<void> updateNotificationSettings({
    required bool notificationsEnabled,
    required bool soundEnabled,
  });
}
