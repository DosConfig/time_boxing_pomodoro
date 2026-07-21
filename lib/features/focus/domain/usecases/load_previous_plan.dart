import '../entities/pomodoro.dart';
import '../repositories/pomodoro_repository.dart';

class LoadPreviousPlanUseCase {
  final PomodoroRepository repository;

  const LoadPreviousPlanUseCase(this.repository);

  Future<Pomodoro?> call(Pomodoro fallback) {
    return repository.loadPreviousPlan(fallback);
  }
}
