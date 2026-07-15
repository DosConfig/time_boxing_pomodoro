import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/pomodoro_local_datasource.dart';
import '../../data/repositories/pomodoro_repository_impl.dart';
import '../../domain/entities/pomodoro.dart';
import '../../domain/repositories/pomodoro_repository.dart';
import '../../domain/usecases/start_pomodoro.dart';
import '../../domain/usecases/pause_pomodoro.dart';
import '../../domain/usecases/reset_pomodoro.dart';

// Data Source Provider
final pomodoroLocalDataSourceProvider = Provider<PomodoroLocalDataSource>((
  ref,
) {
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
class PomodoroNotifier extends Notifier<Pomodoro> with WidgetsBindingObserver {
  PomodoroRepository get repository => ref.read(pomodoroRepositoryProvider);
  StartPomodoroUseCase get startUseCase =>
      ref.read(startPomodoroUseCaseProvider);
  PausePomodoroUseCase get pauseUseCase =>
      ref.read(pausePomodoroUseCaseProvider);
  ResetPomodoroUseCase get resetUseCase =>
      ref.read(resetPomodoroUseCaseProvider);

  StreamSubscription? _timerSubscription;
  Future<void>? _restoreFuture;

  @override
  Pomodoro build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _timerSubscription?.cancel();
    });
    // 프로세스 재시작 대비: 네이티브에 이전 상태 질의 후 복원
    Future.microtask(_restoreFromNative);
    return Pomodoro.initial();
  }

  Future<void> _restoreFromNative() async {
    final pendingRestore = _restoreFuture;
    if (pendingRestore != null) {
      return pendingRestore;
    }

    late final Future<void> restoreFuture;
    restoreFuture = _doRestoreFromNative().whenComplete(() {
      if (identical(_restoreFuture, restoreFuture)) {
        _restoreFuture = null;
      }
    });
    _restoreFuture = restoreFuture;
    return restoreFuture;
  }

  Future<void> _doRestoreFromNative() async {
    final restored = await repository.restoreState();
    final status = restored['status'] as String? ?? 'idle';
    final sessions = _asInt(restored['sessionCount'], 0);
    final sessionGoal = _asInt(
      restored['sessionGoal'],
      state.sessionsUntilLongBreak,
    );
    final phase = Pomodoro.phaseFromValue(restored['phase']);
    final remainingTime = _asInt(
      restored['remainingTime'],
      state.remainingTime,
    );
    state = state.copyWith(
      notificationsEnabled: _asBool(
        restored['notificationsEnabled'],
        state.notificationsEnabled,
      ),
      soundEnabled: _asBool(restored['soundEnabled'], state.soundEnabled),
      topPriorities: _asStringList(
        restored['topPriorities'],
        state.topPriorities,
      ),
      currentTimeBoxTitle: _asString(
        restored['currentTimeBoxTitle'],
        state.currentTimeBoxTitle,
      ),
      currentTimeBoxTimeRange: _asString(
        restored['currentTimeBoxTimeRange'],
        state.currentTimeBoxTimeRange,
      ),
    );

    switch (status) {
      case 'running':
        state = state.copyWith(
          status: PomodoroStatus.running,
          remainingTime: remainingTime,
          completedSessions: sessions,
          sessionsUntilLongBreak: sessionGoal,
          phase: phase,
        );
        repository.updatePomodoro(state);
        _subscribeTicks(); // 네이티브 타이머는 이미 재가동됨 — tick 구독만
        break;
      case 'paused':
        state = state.copyWith(
          status: PomodoroStatus.paused,
          remainingTime: remainingTime,
          completedSessions: sessions,
          sessionsUntilLongBreak: sessionGoal,
          phase: phase,
        );
        repository.updatePomodoro(state);
        _subscribeTicks(); // 재개 시 같은 통로로 tick 수신
        break;
      case 'completed':
        // 앱이 죽어 있는 동안 세션 완료됨
        state = state.copyWith(sessionsUntilLongBreak: sessionGoal);
        state = _stateAfterCompletedPhase(phase, sessions);
        repository.updatePomodoro(state);
        break;
      default:
        break; // idle — 그대로
    }
  }

  int _asInt(Object? value, int fallback) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return fallback;
  }

  bool _asBool(Object? value, bool fallback) {
    if (value is bool) {
      return value;
    }
    return fallback;
  }

  String _asString(Object? value, String fallback) {
    if (value is String) {
      return value;
    }
    return fallback;
  }

  List<String> _asStringList(Object? value, List<String> fallback) {
    if (value is List) {
      final strings = value.whereType<String>().take(3).toList();
      while (strings.length < 3) {
        strings.add('');
      }
      return strings;
    }
    return fallback;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Future.microtask(_restoreFromNative);
    }
  }

  void _subscribeTicks() {
    _timerSubscription?.cancel();
    _timerSubscription = repository.ticks().listen((remainingTime) {
      state = state.copyWith(remainingTime: remainingTime);
      if (remainingTime == 0) {
        _onTimerComplete();
      }
    });
  }

  StreamSubscription<int> _startNativeTimer() {
    return startUseCase(
      phase: state.phaseValue,
      notificationsEnabled: state.notificationsEnabled,
      soundEnabled: state.soundEnabled,
      topPriorities: state.visibleTopPriorities,
      currentTimeBoxTitle: state.liveActivityTimeBoxTitle,
      currentTimeBoxTimeRange: state.liveActivityTimeBoxRange,
    ).listen((remainingTime) {
      state = state.copyWith(remainingTime: remainingTime);

      if (remainingTime == 0) {
        _onTimerComplete();
      }
    });
  }

  Future<void> start() async {
    await _restoreFromNative();
    debugPrint('[Pomodoro/Dart] start() — status=${state.status}');
    if (state.status == PomodoroStatus.paused) {
      // 재개: 네이티브 resume — Live Activity를 끊지 않고 이어감.
      // tick은 유지 중인 구독으로 계속 흘러옴 (네이티브가 재개되면 onTick 재개)
      await repository.resumeTimer();
      state = state.copyWith(status: PomodoroStatus.running);
      repository.updatePomodoro(state);
      _subscribeTicks();
      return;
    }

    if (state.status == PomodoroStatus.idle ||
        state.status == PomodoroStatus.break_) {
      state = state.copyWith(status: PomodoroStatus.running);
      repository.updatePomodoro(state);

      _timerSubscription?.cancel();
      _timerSubscription = _startNativeTimer();
    }
  }

  Future<void> pause() async {
    await _restoreFromNative();
    // 구독은 유지 — 네이티브 타이머가 멈추면 tick이 안 오는 것뿐.
    // 재개 시 같은 구독으로 tick이 다시 흐른다.
    await pauseUseCase();
    state = state.copyWith(status: PomodoroStatus.paused);
    repository.updatePomodoro(state);
  }

  Future<void> reset() async {
    final previous = state;
    _timerSubscription?.cancel();
    await resetUseCase(); // 네이티브 stop + Live Activity 종료 포함
    state = Pomodoro.initial().copyWith(
      workDuration: previous.workDuration,
      breakDuration: previous.breakDuration,
      longBreakDuration: previous.longBreakDuration,
      sessionsUntilLongBreak: previous.sessionsUntilLongBreak,
      preset: previous.preset,
      autoStartBreaks: previous.autoStartBreaks,
      autoStartFocus: previous.autoStartFocus,
      notificationsEnabled: previous.notificationsEnabled,
      soundEnabled: previous.soundEnabled,
      topPriorities: previous.topPriorities,
      currentTimeBoxTitle: previous.currentTimeBoxTitle,
      currentTimeBoxTimeRange: previous.currentTimeBoxTimeRange,
      timeBoxes: previous.timeBoxes,
      activeTimeBoxId: previous.activeTimeBoxId,
    );
    repository.updatePomodoro(state);
  }

  Future<void> applyPreset(PomodoroPreset preset) async {
    if (state.status == PomodoroStatus.running ||
        state.status == PomodoroStatus.paused) {
      await reset();
    }
    state = state.applyPreset(preset);
    repository.updatePomodoro(state);
  }

  void setAutoStartBreaks(bool enabled) {
    state = state.copyWith(autoStartBreaks: enabled);
    repository.updatePomodoro(state);
  }

  void setAutoStartFocus(bool enabled) {
    state = state.copyWith(autoStartFocus: enabled);
    repository.updatePomodoro(state);
  }

  void setNotificationsEnabled(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
    repository.updatePomodoro(state);
    unawaited(
      repository.updateNotificationSettings(
        notificationsEnabled: state.notificationsEnabled,
        soundEnabled: state.soundEnabled,
      ),
    );
  }

  void setSoundEnabled(bool enabled) {
    state = state.copyWith(soundEnabled: enabled);
    repository.updatePomodoro(state);
    unawaited(
      repository.updateNotificationSettings(
        notificationsEnabled: state.notificationsEnabled,
        soundEnabled: state.soundEnabled,
      ),
    );
  }

  void setTopPriority(int index, String value) {
    if (index < 0 || index >= 3) {
      return;
    }

    final priorities = List<String>.from(state.topPriorities);
    while (priorities.length < 3) {
      priorities.add('');
    }
    priorities[index] = value;

    state = state.copyWith(topPriorities: priorities.take(3).toList());
    repository.updatePomodoro(state);
  }

  void setCurrentTimeBoxTitle(String value) {
    state = state.copyWith(currentTimeBoxTitle: value);
    repository.updatePomodoro(state);
  }

  void setCurrentTimeBoxTimeRange(String value) {
    state = state.copyWith(currentTimeBoxTimeRange: value);
    repository.updatePomodoro(state);
  }

  Future<void> selectTimeBox(String id) async {
    TimeBox? selected;
    for (final box in state.timeBoxes) {
      if (box.id == id) {
        selected = box;
        break;
      }
    }
    if (selected == null) {
      return;
    }

    if (state.status == PomodoroStatus.running ||
        state.status == PomodoroStatus.paused) {
      _timerSubscription?.cancel();
      await resetUseCase();
    }

    state = state.copyWith(
      activeTimeBoxId: selected.id,
      currentTimeBoxTitle: selected.title,
      currentTimeBoxTimeRange: selected.timeRange,
      workDuration: selected.durationSeconds,
      remainingTime: selected.durationSeconds,
      status: PomodoroStatus.idle,
      phase: PomodoroPhase.focus,
    );
    repository.updatePomodoro(state);
  }

  void _onTimerComplete() {
    _timerSubscription?.cancel();

    if (state.phase == PomodoroPhase.focus) {
      final completedSessions = state.completedSessions + 1;
      final nextPhase = completedSessions % state.sessionsUntilLongBreak == 0
          ? PomodoroPhase.longBreak
          : PomodoroPhase.shortBreak;
      final nextDuration = nextPhase == PomodoroPhase.longBreak
          ? state.longBreakDuration
          : state.breakDuration;

      state = state.copyWith(
        status: state.autoStartBreaks
            ? PomodoroStatus.running
            : PomodoroStatus.break_,
        phase: nextPhase,
        remainingTime: nextDuration,
        completedSessions: completedSessions,
      );
      repository.updatePomodoro(state);

      if (state.autoStartBreaks) {
        _timerSubscription = _startNativeTimer();
      }
      return;
    }

    state = state.copyWith(
      status: state.autoStartFocus
          ? PomodoroStatus.running
          : PomodoroStatus.idle,
      phase: PomodoroPhase.focus,
      remainingTime: state.workDuration,
    );
    repository.updatePomodoro(state);

    if (state.autoStartFocus) {
      _timerSubscription = _startNativeTimer();
    }
  }

  Pomodoro _stateAfterCompletedPhase(PomodoroPhase phase, int sessions) {
    if (phase == PomodoroPhase.focus) {
      final completedSessions = sessions + 1;
      final nextPhase = completedSessions % state.sessionsUntilLongBreak == 0
          ? PomodoroPhase.longBreak
          : PomodoroPhase.shortBreak;
      return state.copyWith(
        status: PomodoroStatus.break_,
        phase: nextPhase,
        remainingTime: nextPhase == PomodoroPhase.longBreak
            ? state.longBreakDuration
            : state.breakDuration,
        completedSessions: completedSessions,
      );
    }

    return state.copyWith(
      status: PomodoroStatus.idle,
      phase: PomodoroPhase.focus,
      remainingTime: state.workDuration,
      completedSessions: sessions,
    );
  }
}

// Notifier Provider
final pomodoroProvider = NotifierProvider<PomodoroNotifier, Pomodoro>(() {
  return PomodoroNotifier();
});
