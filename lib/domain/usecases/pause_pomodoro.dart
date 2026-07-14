import '../entities/pomodoro.dart';
import '../repositories/pomodoro_repository.dart';

class PausePomodoroUseCase {
  final PomodoroRepository repository;

  PausePomodoroUseCase(this.repository);

  Future<void> call() async {
    // 네이티브 타이머·Live Activity에 즉시 반영 (도메인 상태만 바꾸면 OS 쪽은 계속 돈다)
    await repository.pauseTimer();

    final pomodoro = repository.getPomodoro();
    repository.updatePomodoro(
      pomodoro.copyWith(status: PomodoroStatus.paused),
    );
  }
}
