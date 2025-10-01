import '../entities/pomodoro.dart';

abstract class PomodoroRepository {
  Pomodoro getPomodoro();
  void updatePomodoro(Pomodoro pomodoro);
  Stream<int> startTimer();
}
