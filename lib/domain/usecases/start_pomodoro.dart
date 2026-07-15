import '../repositories/pomodoro_repository.dart';

class StartPomodoroUseCase {
  final PomodoroRepository repository;

  StartPomodoroUseCase(this.repository);

  Stream<int> call({
    required String phase,
    required bool notificationsEnabled,
    required bool soundEnabled,
    required List<String> topPriorities,
    required String currentTimeBoxTitle,
    required String currentTimeBoxTimeRange,
  }) {
    return repository.startTimer(
      phase: phase,
      notificationsEnabled: notificationsEnabled,
      soundEnabled: soundEnabled,
      topPriorities: topPriorities,
      currentTimeBoxTitle: currentTimeBoxTitle,
      currentTimeBoxTimeRange: currentTimeBoxTimeRange,
    );
  }
}
