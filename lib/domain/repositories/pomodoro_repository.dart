import '../entities/pomodoro.dart';

abstract class PomodoroRepository {
  Pomodoro getPomodoro();
  void updatePomodoro(Pomodoro pomodoro);
  Stream<int> startTimer();
  Future<void> pauseTimer();
  Future<void> resumeTimer();
  Future<void> stopTimer();
}
