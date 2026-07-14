import 'dart:async';
import 'package:flutter/foundation.dart';
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

  Future<void> start() async {
    debugPrint('[Pomodoro/Dart] start() — status=${state.status}');
    if (state.status == PomodoroStatus.paused) {
      // 재개: 네이티브 resume — Live Activity를 끊지 않고 이어감.
      // tick은 유지 중인 구독으로 계속 흘러옴 (네이티브가 재개되면 onTick 재개)
      await repository.resumeTimer();
      state = state.copyWith(status: PomodoroStatus.running);
      repository.updatePomodoro(state);
      return;
    }

    if (state.status == PomodoroStatus.idle) {
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

  Future<void> pause() async {
    // 구독은 유지 — 네이티브 타이머가 멈추면 tick이 안 오는 것뿐.
    // 재개 시 같은 구독으로 tick이 다시 흐른다.
    await pauseUseCase();
    state = state.copyWith(status: PomodoroStatus.paused);
    repository.updatePomodoro(state);
  }

  Future<void> reset() async {
    _timerSubscription?.cancel();
    await resetUseCase(); // 네이티브 stop + Live Activity 종료 포함
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
