import '../../domain/entities/pomodoro.dart';
import '../../domain/repositories/pomodoro_repository.dart';
import '../datasources/pomodoro_local_datasource.dart';

class PomodoroRepositoryImpl implements PomodoroRepository {
  final PomodoroLocalDataSource localDataSource;

  PomodoroRepositoryImpl(this.localDataSource);

  @override
  Pomodoro getPomodoro() => localDataSource.getPomodoro();

  @override
  void updatePomodoro(Pomodoro pomodoro) => localDataSource.updatePomodoro(pomodoro);

  @override
  Stream<int> startTimer() => localDataSource.startTimer();
}
