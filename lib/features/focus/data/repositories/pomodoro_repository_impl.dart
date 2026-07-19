import '../../domain/entities/pomodoro.dart';
import '../../domain/entities/native_timer_copy.dart';
import '../../domain/entities/daily_plan_summary.dart';
import '../../domain/repositories/pomodoro_repository.dart';
import '../datasources/pomodoro_local_datasource.dart';

class PomodoroRepositoryImpl implements PomodoroRepository {
  final PomodoroLocalDataSource localDataSource;

  PomodoroRepositoryImpl(this.localDataSource);

  @override
  Pomodoro getPomodoro() => localDataSource.getPomodoro();

  @override
  void updatePomodoro(Pomodoro pomodoro) =>
      localDataSource.updatePomodoro(pomodoro);

  @override
  Future<Pomodoro> restoreTodayPlan(Pomodoro fallback) {
    return localDataSource.restoreTodayPlan(fallback);
  }

  @override
  Future<List<DailyPlanSummary>> loadDailyPlanHistory({int days = 7}) {
    return localDataSource.loadDailyPlanHistory(days: days);
  }

  @override
  Stream<int> startTimer({
    required String phase,
    required bool notificationsEnabled,
    required bool soundEnabled,
    required List<String> topPriorities,
    required String currentTimeBoxTitle,
    required String currentTimeBoxTimeRange,
    required NativeTimerCopy nativeCopy,
  }) => localDataSource.startTimer(
    phase: phase,
    notificationsEnabled: notificationsEnabled,
    soundEnabled: soundEnabled,
    topPriorities: topPriorities,
    currentTimeBoxTitle: currentTimeBoxTitle,
    currentTimeBoxTimeRange: currentTimeBoxTimeRange,
    nativeCopy: nativeCopy,
  );

  @override
  Future<void> pauseTimer() => localDataSource.pauseTimer();

  @override
  Future<void> resumeTimer() => localDataSource.resumeTimer();

  @override
  Future<void> stopTimer() => localDataSource.stopTimer();

  @override
  Stream<int> ticks() => localDataSource.ticks();

  @override
  Future<TimerSnapshot> restoreState(Pomodoro fallback) async {
    final dto = await localDataSource.restoreState(fallback);
    return dto.toEntity();
  }

  @override
  Future<void> updateNotificationSettings({
    required bool notificationsEnabled,
    required bool soundEnabled,
  }) => localDataSource.updateNotificationSettings(
    notificationsEnabled: notificationsEnabled,
    soundEnabled: soundEnabled,
  );
}
