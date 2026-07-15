import '../repositories/pomodoro_repository.dart';

class StartPomodoroUseCase {
  final PomodoroRepository repository;

  StartPomodoroUseCase(this.repository);

  Stream<int> call({
    required String phase,
    required bool notificationsEnabled,
    required bool soundEnabled,
  }) {
    return repository.startTimer(
      phase: phase,
      notificationsEnabled: notificationsEnabled,
      soundEnabled: soundEnabled,
    );
  }
}
