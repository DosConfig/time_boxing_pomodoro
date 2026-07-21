import '../repositories/pomodoro_repository.dart';

class ClearLocalPlanDataUseCase {
  final PomodoroRepository repository;

  ClearLocalPlanDataUseCase(this.repository);

  Future<void> call() {
    return repository.clearLocalPlanData();
  }
}
