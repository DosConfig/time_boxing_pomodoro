import '../entities/pomodoro.dart';
import '../repositories/pomodoro_repository.dart';

class ResetPomodoroUseCase {
  final PomodoroRepository repository;

  ResetPomodoroUseCase(this.repository);

  void call() {
    repository.updatePomodoro(Pomodoro.initial());
  }
}
