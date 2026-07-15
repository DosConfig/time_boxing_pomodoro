import '../entities/pomodoro.dart';

abstract class PomodoroRepository {
  Pomodoro getPomodoro();
  void updatePomodoro(Pomodoro pomodoro);
  Stream<int> startTimer({required String phase});
  Stream<int> ticks();
  Future<void> pauseTimer();
  Future<void> resumeTimer();
  Future<void> stopTimer();
  Future<Map<String, dynamic>> restoreState();
}
