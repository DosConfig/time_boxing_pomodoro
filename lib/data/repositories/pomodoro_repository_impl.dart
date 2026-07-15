import '../../domain/entities/pomodoro.dart';
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
  Stream<int> startTimer({
    required String phase,
    required bool notificationsEnabled,
    required bool soundEnabled,
  }) => localDataSource.startTimer(
    phase: phase,
    notificationsEnabled: notificationsEnabled,
    soundEnabled: soundEnabled,
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
  Future<Map<String, dynamic>> restoreState() => localDataSource.restoreState();

  @override
  Future<void> updateNotificationSettings({
    required bool notificationsEnabled,
    required bool soundEnabled,
  }) => localDataSource.updateNotificationSettings(
    notificationsEnabled: notificationsEnabled,
    soundEnabled: soundEnabled,
  );
}
