import '../entities/pomodoro.dart';
import '../repositories/pomodoro_repository.dart';

class RestorePomodoroStateUseCase {
  final PomodoroRepository repository;

  RestorePomodoroStateUseCase(this.repository);

  Future<TimerSnapshot> call(Pomodoro fallback) {
    return repository.restoreState(fallback);
  }
}
