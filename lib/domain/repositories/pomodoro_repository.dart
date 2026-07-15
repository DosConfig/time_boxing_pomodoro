import '../entities/pomodoro.dart';

abstract class PomodoroRepository {
  Pomodoro getPomodoro();
  void updatePomodoro(Pomodoro pomodoro);
  Stream<int> startTimer({
    required String phase,
    required bool notificationsEnabled,
    required bool soundEnabled,
  });
  Stream<int> ticks();
  Future<void> pauseTimer();
  Future<void> resumeTimer();
  Future<void> stopTimer();
  Future<Map<String, dynamic>> restoreState();
  Future<void> updateNotificationSettings({
    required bool notificationsEnabled,
    required bool soundEnabled,
  });
}
