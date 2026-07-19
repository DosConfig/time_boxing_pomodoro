import '../entities/pomodoro.dart';
import '../repositories/pomodoro_repository.dart';

class RestoreTodayPlanUseCase {
  final PomodoroRepository repository;

  RestoreTodayPlanUseCase(this.repository);

  Future<Pomodoro> call(Pomodoro fallback) {
    return repository.restoreTodayPlan(fallback);
  }
}
