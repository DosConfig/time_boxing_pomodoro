import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/pomodoro_local_datasource.dart';
import '../../data/repositories/pomodoro_repository_impl.dart';
import '../../domain/entities/pomodoro.dart';
import '../../domain/repositories/pomodoro_repository.dart';
import '../../domain/usecases/start_pomodoro.dart';
import '../../domain/usecases/pause_pomodoro.dart';
import '../../domain/usecases/reset_pomodoro.dart';

// Data Source Provider
final pomodoroLocalDataSourceProvider = Provider<PomodoroLocalDataSource>((ref) {
  return PomodoroLocalDataSource();
});

// Repository Provider
final pomodoroRepositoryProvider = Provider<PomodoroRepository>((ref) {
  return PomodoroRepositoryImpl(ref.watch(pomodoroLocalDataSourceProvider));
});

// Use Case Providers
final startPomodoroUseCaseProvider = Provider<StartPomodoroUseCase>((ref) {
  return StartPomodoroUseCase(ref.watch(pomodoroRepositoryProvider));
});

final pausePomodoroUseCaseProvider = Provider<PausePomodoroUseCase>((ref) {
  return PausePomodoroUseCase(ref.watch(pomodoroRepositoryProvider));
});

final resetPomodoroUseCaseProvider = Provider<ResetPomodoroUseCase>((ref) {
  return ResetPomodoroUseCase(ref.watch(pomodoroRepositoryProvider));
});

// Notifier
class PomodoroNotifier extends Notifier<Pomodoro> {
  PomodoroRepository get repository => ref.watch(pomodoroRepositoryProvider);
  StartPomodoroUseCase get startUseCase => ref.watch(startPomodoroUseCaseProvider);
  PausePomodoroUseCase get pauseUseCase => ref.watch(pausePomodoroUseCaseProvider);
  ResetPomodoroUseCase get resetUseCase => ref.watch(resetPomodoroUseCaseProvider);

  StreamSubscription? _timerSubscription;

  @override
  Pomodoro build() {
    ref.onDispose(() {
      _timerSubscription?.cancel();
    });
    return Pomodoro.initial();
  }

  void start() {
    if (state.status == PomodoroStatus.idle || state.status == PomodoroStatus.paused) {
      state = state.copyWith(status: PomodoroStatus.running);
      repository.updatePomodoro(state);

      _timerSubscription?.cancel();
      _timerSubscription = startUseCase().listen((remainingTime) {
        state = state.copyWith(remainingTime: remainingTime);

        if (remainingTime == 0) {
          _onTimerComplete();
        }
      });
    }
  }

  void pause() {
    pauseUseCase();
    state = repository.getPomodoro();
    _timerSubscription?.cancel();
  }

  void reset() {
    _timerSubscription?.cancel();
    resetUseCase();
    state = repository.getPomodoro();
  }

  void _onTimerComplete() {
    _timerSubscription?.cancel();

    if (state.status == PomodoroStatus.running) {
      // Work session completed, start break
      final isLongBreak = state.isLongBreak;
      final breakDuration = isLongBreak ? state.longBreakDuration : state.breakDuration;

      state = state.copyWith(
        status: PomodoroStatus.break_,
        remainingTime: breakDuration,
        completedSessions: state.completedSessions + 1,
      );
      repository.updatePomodoro(state);
    } else if (state.status == PomodoroStatus.break_) {
      // Break completed, reset to work
      state = state.copyWith(
        status: PomodoroStatus.idle,
        remainingTime: state.workDuration,
      );
      repository.updatePomodoro(state);
    }
  }
}

// Notifier Provider
final pomodoroProvider = NotifierProvider<PomodoroNotifier, Pomodoro>(() {
  return PomodoroNotifier();
});
