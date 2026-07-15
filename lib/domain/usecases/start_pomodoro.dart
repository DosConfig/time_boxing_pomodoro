import '../repositories/pomodoro_repository.dart';

class StartPomodoroUseCase {
  final PomodoroRepository repository;

  StartPomodoroUseCase(this.repository);

  Stream<int> call({required String phase}) {
    return repository.startTimer(phase: phase);
  }
}
