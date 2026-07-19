import '../entities/pomodoro.dart';
import '../repositories/pomodoro_repository.dart';

class ResetPomodoroUseCase {
  final PomodoroRepository repository;

  ResetPomodoroUseCase(this.repository);

  Future<void> call() async {
    // 네이티브 타이머 정지 + Live Activity 종료까지 함께
    await repository.stopTimer();
    repository.updatePomodoro(Pomodoro.initial());
  }
}
