import '../entities/pomodoro.dart';
import '../repositories/pomodoro_repository.dart';

class PausePomodoroUseCase {
  final PomodoroRepository repository;

  PausePomodoroUseCase(this.repository);

  void call() {
    final pomodoro = repository.getPomodoro();
    repository.updatePomodoro(
      pomodoro.copyWith(status: PomodoroStatus.paused),
    );
  }
}
