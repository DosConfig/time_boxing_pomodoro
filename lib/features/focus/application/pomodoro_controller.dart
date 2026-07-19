import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/datasources/pomodoro_local_datasource.dart';
import '../data/repositories/pomodoro_repository_impl.dart';
import '../domain/entities/native_timer_copy.dart';
import '../domain/entities/pomodoro.dart';
import '../domain/entities/daily_plan_summary.dart';
import '../domain/repositories/pomodoro_repository.dart';
import '../domain/usecases/pause_pomodoro.dart';
import '../domain/usecases/reset_pomodoro.dart';
import '../domain/usecases/restore_pomodoro_state.dart';
import '../domain/usecases/restore_today_plan.dart';
import '../domain/usecases/load_daily_plan_history.dart';
import '../domain/usecases/start_pomodoro.dart';

part 'pomodoro_controller.g.dart';

@Riverpod(keepAlive: true)
PomodoroLocalDataSource pomodoroLocalDataSource(Ref ref) {
  return PomodoroLocalDataSource();
}

@Riverpod(keepAlive: true)
PomodoroRepository pomodoroRepository(Ref ref) {
  return PomodoroRepositoryImpl(ref.watch(pomodoroLocalDataSourceProvider));
}

@Riverpod(keepAlive: true)
StartPomodoroUseCase startPomodoroUseCase(Ref ref) {
  return StartPomodoroUseCase(ref.watch(pomodoroRepositoryProvider));
}

@Riverpod(keepAlive: true)
PausePomodoroUseCase pausePomodoroUseCase(Ref ref) {
  return PausePomodoroUseCase(ref.watch(pomodoroRepositoryProvider));
}

@Riverpod(keepAlive: true)
ResetPomodoroUseCase resetPomodoroUseCase(Ref ref) {
  return ResetPomodoroUseCase(ref.watch(pomodoroRepositoryProvider));
}

@Riverpod(keepAlive: true)
RestorePomodoroStateUseCase restorePomodoroStateUseCase(Ref ref) {
  return RestorePomodoroStateUseCase(ref.watch(pomodoroRepositoryProvider));
}

@Riverpod(keepAlive: true)
RestoreTodayPlanUseCase restoreTodayPlanUseCase(Ref ref) {
  return RestoreTodayPlanUseCase(ref.watch(pomodoroRepositoryProvider));
}

@Riverpod(keepAlive: true)
LoadDailyPlanHistoryUseCase loadDailyPlanHistoryUseCase(Ref ref) {
  return LoadDailyPlanHistoryUseCase(ref.watch(pomodoroRepositoryProvider));
}

@riverpod
Future<List<DailyPlanSummary>> dailyPlanHistory(Ref ref, {int days = 7}) {
  return ref.watch(loadDailyPlanHistoryUseCaseProvider).call(days: days);
}

@Riverpod(keepAlive: true)
class PomodoroController extends _$PomodoroController
    with WidgetsBindingObserver {
  static const int _slotDurationSeconds = 30 * 60;

  PomodoroRepository get repository => ref.read(pomodoroRepositoryProvider);
  StartPomodoroUseCase get startUseCase =>
      ref.read(startPomodoroUseCaseProvider);
  PausePomodoroUseCase get pauseUseCase =>
      ref.read(pausePomodoroUseCaseProvider);
  ResetPomodoroUseCase get resetUseCase =>
      ref.read(resetPomodoroUseCaseProvider);
  RestorePomodoroStateUseCase get restoreUseCase =>
      ref.read(restorePomodoroStateUseCaseProvider);
  RestoreTodayPlanUseCase get restoreTodayPlanUseCase =>
      ref.read(restoreTodayPlanUseCaseProvider);

  StreamSubscription? _timerSubscription;
  Timer? _clockSyncTimer;
  Future<void>? _localRestoreFuture;
  Future<void>? _restoreFuture;
  NativeTimerCopy _nativeCopy = const NativeTimerCopy();

  @override
  Pomodoro build() {
    WidgetsBinding.instance.addObserver(this);
    _startClockSyncTimer();
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _timerSubscription?.cancel();
      _clockSyncTimer?.cancel();
    });
    Future.microtask(() async {
      await _restoreFromLocalPlan();
      // 프로세스 재시작 대비: 네이티브에 이전 상태 질의 후 복원
      await _restoreFromNative();
      syncFocusWithClock();
    });
    return Pomodoro.initial();
  }

  Future<void> _restoreFromLocalPlan() async {
    final pendingRestore = _localRestoreFuture;
    if (pendingRestore != null) {
      return pendingRestore;
    }

    late final Future<void> restoreFuture;
    restoreFuture = _doRestoreFromLocalPlan().whenComplete(() {
      if (identical(_localRestoreFuture, restoreFuture)) {
        _localRestoreFuture = Future.value();
      }
    });
    _localRestoreFuture = restoreFuture;
    return restoreFuture;
  }

  Future<void> _doRestoreFromLocalPlan() async {
    state = await restoreTodayPlanUseCase(state);
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
    final restored = await restoreUseCase(state);
    state = state.copyWith(
      notificationsEnabled: restored.notificationsEnabled,
      soundEnabled: restored.soundEnabled,
      topPriorities: restored.topPriorities,
      currentTimeBoxTitle: restored.currentTimeBoxTitle,
      currentTimeBoxTimeRange: restored.currentTimeBoxTimeRange,
    );

    switch (restored.status) {
      case 'running':
        state = state.copyWith(
          status: PomodoroStatus.running,
          remainingTime: restored.remainingTime,
          completedSessions: restored.sessionCount,
          sessionsUntilLongBreak: restored.sessionGoal,
          phase: restored.phase,
        );
        repository.updatePomodoro(state);
        _subscribeTicks(); // 네이티브 타이머는 이미 재가동됨 — tick 구독만
        break;
      case 'paused':
        state = state.copyWith(
          status: PomodoroStatus.paused,
          remainingTime: restored.remainingTime,
          completedSessions: restored.sessionCount,
          sessionsUntilLongBreak: restored.sessionGoal,
          phase: restored.phase,
        );
        repository.updatePomodoro(state);
        _subscribeTicks(); // 재개 시 같은 통로로 tick 수신
        break;
      case 'completed':
        // 앱이 죽어 있는 동안 세션 완료됨
        state = state.copyWith(sessionsUntilLongBreak: restored.sessionGoal);
        state = _stateAfterCompletedPhase(
          restored.phase,
          restored.sessionCount,
        );
        repository.updatePomodoro(state);
        break;
      default:
        break; // idle — 그대로
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Future.microtask(() async {
        await _restoreFromNative();
        syncFocusWithClock();
      });
    }
  }

  void _startClockSyncTimer() {
    _clockSyncTimer?.cancel();
    _clockSyncTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      syncFocusWithClock();
    });
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

  StreamSubscription<int> _startNativeTimer(NativeTimerCopy nativeCopy) {
    return startUseCase(
      phase: state.phaseValue,
      notificationsEnabled: state.notificationsEnabled,
      soundEnabled: state.soundEnabled,
      topPriorities: state.visibleTopPriorities,
      currentTimeBoxTitle: state.liveActivityTimeBoxTitle,
      currentTimeBoxTimeRange: state.liveActivityTimeBoxRange,
      nativeCopy: nativeCopy,
    ).listen((remainingTime) {
      state = state.copyWith(remainingTime: remainingTime);

      if (remainingTime == 0) {
        _onTimerComplete();
      }
    });
  }

  Future<void> start(NativeTimerCopy nativeCopy) async {
    _nativeCopy = nativeCopy;
    await _restoreFromLocalPlan();
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
      if (state.phase != PomodoroPhase.focus) {
        state = state.copyWith(
          status: PomodoroStatus.idle,
          phase: PomodoroPhase.focus,
        );
      }
      syncFocusWithClock();
      if (state.remainingTime <= 0) {
        debugPrint(
          '[Pomodoro/Dart] start() skipped - no active timebox time left',
        );
        return;
      }
      state = state.copyWith(status: PomodoroStatus.running);
      repository.updatePomodoro(state);

      _timerSubscription?.cancel();
      _timerSubscription = _startNativeTimer(nativeCopy);
    }
  }

  Future<void> pause() async {
    await _restoreFromLocalPlan();
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
      brainDump: previous.brainDump,
      reminders: previous.reminders,
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

  void addBrainDumpItem(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return;
    }

    state = state.copyWith(brainDump: [...state.brainDump, trimmed]);
    repository.updatePomodoro(state);
  }

  void removeBrainDumpItem(int index) {
    if (index < 0 || index >= state.brainDump.length) {
      return;
    }

    final items = List<String>.from(state.brainDump)..removeAt(index);
    state = state.copyWith(brainDump: items);
    repository.updatePomodoro(state);
  }

  void addReminder(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return;
    }

    state = state.copyWith(reminders: [...state.reminders, trimmed]);
    repository.updatePomodoro(state);
  }

  void removeReminder(int index) {
    if (index < 0 || index >= state.reminders.length) {
      return;
    }

    final items = List<String>.from(state.reminders)..removeAt(index);
    state = state.copyWith(reminders: items);
    repository.updatePomodoro(state);
  }

  void moveBrainDumpItemToReminder(int index) {
    if (index < 0 || index >= state.brainDump.length) {
      return;
    }

    final brainDump = List<String>.from(state.brainDump);
    final reminder = brainDump.removeAt(index);
    state = state.copyWith(
      brainDump: brainDump,
      reminders: [...state.reminders, reminder],
    );
    repository.updatePomodoro(state);
  }

  void promoteBrainDumpItem(int index) {
    if (index < 0 || index >= state.brainDump.length) {
      return;
    }

    final priorities = List<String>.from(state.topPriorities);
    while (priorities.length < 3) {
      priorities.add('');
    }

    var targetIndex = priorities.indexWhere(
      (priority) => priority.trim().isEmpty,
    );
    if (targetIndex == -1) {
      targetIndex = 2;
    }

    final items = List<String>.from(state.brainDump);
    final promoted = items.removeAt(index);
    priorities[targetIndex] = promoted;

    state = state.copyWith(
      brainDump: items,
      topPriorities: priorities.take(3).toList(),
    );
    repository.updatePomodoro(state);

    if (targetIndex == 0 || targetIndex == 1) {
      setTopPriority(targetIndex, promoted);
    }
  }

  void setTopPriority(int index, String value) {
    if (index < 0 || index >= 3) {
      return;
    }

    final priorities = List<String>.from(state.topPriorities);
    while (priorities.length < 3) {
      priorities.add('');
    }
    final previousPriority = priorities[index].trim();
    priorities[index] = value;

    var nextTitle = state.currentTimeBoxTitle;
    final activePriorityBox =
        (index == 0 && state.activeTimeBoxId == 'box-0900') ||
        (index == 1 && state.activeTimeBoxId == 'box-1330');
    if (activePriorityBox &&
        (nextTitle.trim().isEmpty ||
            nextTitle == 'Top priority' ||
            nextTitle == 'Second priority' ||
            nextTitle == previousPriority)) {
      nextTitle = value.trim();
    }

    state = state.copyWith(
      topPriorities: priorities.take(3).toList(),
      currentTimeBoxTitle: nextTitle,
    );
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

  TimeBox addTimeBox() {
    final boxes = List<TimeBox>.from(state.timeBoxes);
    final start = _nextStartMinutes(boxes);
    return addTimeBoxAtStart(start);
  }

  TimeBox addTimeBoxAtStart(int startMinutes, {String title = 'New time box'}) {
    final boxes = List<TimeBox>.from(state.timeBoxes);
    final nextBox = TimeBox(
      id: 'box-${DateTime.now().microsecondsSinceEpoch}',
      title: title.trim().isEmpty ? 'New time box' : title.trim(),
      timeRange: _formatTimeRange(startMinutes, _slotDurationSeconds),
      durationSeconds: _slotDurationSeconds,
    );
    boxes.add(nextBox);
    _sortTimeBoxes(boxes);

    state = state.copyWith(
      timeBoxes: boxes,
      activeTimeBoxId: state.activeTimeBoxId.isEmpty
          ? nextBox.id
          : state.activeTimeBoxId,
    );
    repository.updatePomodoro(state);
    return nextBox;
  }

  Future<void> removeTimeBox(String id) async {
    final boxes = List<TimeBox>.from(state.timeBoxes);
    if (boxes.length <= 1) {
      return;
    }

    final removeIndex = boxes.indexWhere((box) => box.id == id);
    if (removeIndex == -1) {
      return;
    }

    final removingActiveBox = id == state.activeTimeBoxId;
    if (removingActiveBox &&
        (state.status == PomodoroStatus.running ||
            state.status == PomodoroStatus.paused)) {
      await reset();
    }

    boxes.removeAt(removeIndex);

    if (!removingActiveBox) {
      state = state.copyWith(timeBoxes: boxes);
      repository.updatePomodoro(state);
      return;
    }

    final nextIndex = removeIndex.clamp(0, boxes.length - 1);
    final nextBox = boxes[nextIndex];
    final remainingTime = _remainingForTimeBox(nextBox);
    state = state.copyWith(
      timeBoxes: boxes,
      activeTimeBoxId: nextBox.id,
      currentTimeBoxTitle: _titleForTimeBox(nextBox),
      currentTimeBoxTimeRange: nextBox.timeRange,
      workDuration: nextBox.durationSeconds,
      remainingTime: remainingTime,
      status: PomodoroStatus.idle,
      phase: PomodoroPhase.focus,
    );
    repository.updatePomodoro(state);
  }

  void reorderTimeBox(int oldIndex, int newIndex) {
    final boxes = List<TimeBox>.from(state.timeBoxes);
    if (oldIndex < 0 || oldIndex >= boxes.length) {
      return;
    }

    final targetIndex = newIndex.clamp(0, boxes.length - 1);
    if (oldIndex == targetIndex) {
      return;
    }

    final moved = boxes.removeAt(oldIndex);
    boxes.insert(targetIndex, moved);
    state = state.copyWith(timeBoxes: boxes);
    repository.updatePomodoro(state);
  }

  void updateTimeBox(String id, {String? title, String? timeRange}) {
    final boxes = List<TimeBox>.from(state.timeBoxes);
    final index = boxes.indexWhere((box) => box.id == id);
    if (index == -1) {
      return;
    }

    final nextTimeRange = timeRange?.trim();
    final nextStart = nextTimeRange == null || nextTimeRange.isEmpty
        ? boxes[index].startMinutes
        : TimeBox(
            id: boxes[index].id,
            title: boxes[index].title,
            timeRange: nextTimeRange,
            durationSeconds: _slotDurationSeconds,
          ).startMinutes;
    final trimmedTitle = title?.trim();
    final nextBox = boxes[index].copyWith(
      title: trimmedTitle == null || trimmedTitle.isEmpty
          ? boxes[index].title
          : trimmedTitle,
      timeRange: nextStart == null
          ? boxes[index].timeRange
          : _formatTimeRange(nextStart, _slotDurationSeconds),
      durationSeconds: _slotDurationSeconds,
    );
    boxes[index] = nextBox;
    _sortTimeBoxes(boxes);
    final remainingTime = _remainingForTimeBox(nextBox);

    final updatingActiveBox = id == state.activeTimeBoxId;
    state = state.copyWith(
      timeBoxes: boxes,
      currentTimeBoxTitle: updatingActiveBox
          ? _titleForTimeBox(nextBox)
          : state.currentTimeBoxTitle,
      currentTimeBoxTimeRange: updatingActiveBox
          ? nextBox.timeRange
          : state.currentTimeBoxTimeRange,
      workDuration: updatingActiveBox && state.status == PomodoroStatus.idle
          ? nextBox.durationSeconds
          : state.workDuration,
      remainingTime: updatingActiveBox && state.status == PomodoroStatus.idle
          ? remainingTime
          : state.remainingTime,
    );
    repository.updatePomodoro(state);
  }

  void moveTimeBoxToStart(String id, int startMinutes) {
    final boxes = List<TimeBox>.from(state.timeBoxes);
    final index = boxes.indexWhere((box) => box.id == id);
    if (index == -1) {
      return;
    }

    final box = boxes[index];
    final nextBox = box.copyWith(
      timeRange: _formatTimeRange(startMinutes, _slotDurationSeconds),
      durationSeconds: _slotDurationSeconds,
    );
    boxes[index] = nextBox;
    _sortTimeBoxes(boxes);
    final updatingActiveBox = id == state.activeTimeBoxId;
    final remainingTime = _remainingForTimeBox(nextBox);

    state = state.copyWith(
      timeBoxes: boxes,
      currentTimeBoxTimeRange: updatingActiveBox
          ? nextBox.timeRange
          : state.currentTimeBoxTimeRange,
      workDuration: updatingActiveBox && state.status == PomodoroStatus.idle
          ? nextBox.durationSeconds
          : state.workDuration,
      remainingTime: updatingActiveBox && state.status == PomodoroStatus.idle
          ? remainingTime
          : state.remainingTime,
    );
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
      currentTimeBoxTitle: _titleForTimeBox(selected),
      currentTimeBoxTimeRange: selected.timeRange,
      workDuration: selected.durationSeconds,
      remainingTime: _remainingForTimeBox(selected),
      status: PomodoroStatus.idle,
      phase: PomodoroPhase.focus,
    );
    repository.updatePomodoro(state);
  }

  Future<void> selectCurrentTimeBoxForNow() async {
    if (state.status == PomodoroStatus.running ||
        state.status == PomodoroStatus.paused) {
      return;
    }

    syncFocusWithClock();
  }

  void syncFocusWithClock() {
    if (state.status != PomodoroStatus.idle ||
        state.phase != PomodoroPhase.focus) {
      return;
    }

    final currentBox = _currentTimeBoxForNow();
    if (currentBox != null) {
      _applyClockSyncedTimeBox(
        currentBox,
        _clockRemainingForTimeBox(currentBox),
      );
      return;
    }

    final nextBox = _nextUpcomingTimeBox();
    if (nextBox != null) {
      _applyClockSyncedTimeBox(nextBox, nextBox.durationSeconds);
      return;
    }

    final activeBox = state.activeTimeBox;
    if (activeBox == null || !_timeBoxHasEnded(activeBox)) {
      return;
    }

    _applyClockSyncedTimeBox(activeBox, 0);
  }

  void _applyClockSyncedTimeBox(TimeBox box, int remainingTime) {
    final nextRemainingTime = remainingTime
        .clamp(0, box.durationSeconds)
        .toInt();
    final nextTitle = _titleForTimeBox(box);
    final nextRange = box.timeRange;
    final isAlreadySynced =
        state.activeTimeBoxId == box.id &&
        state.currentTimeBoxTitle == nextTitle &&
        state.currentTimeBoxTimeRange == nextRange &&
        state.workDuration == box.durationSeconds &&
        state.remainingTime == nextRemainingTime;

    if (isAlreadySynced) {
      return;
    }

    state = state.copyWith(
      activeTimeBoxId: box.id,
      currentTimeBoxTitle: nextTitle,
      currentTimeBoxTimeRange: nextRange,
      workDuration: box.durationSeconds,
      remainingTime: nextRemainingTime,
      status: PomodoroStatus.idle,
      phase: PomodoroPhase.focus,
    );
    repository.updatePomodoro(state);
  }

  TimeBox? _currentTimeBoxForNow() {
    for (final box in state.timeBoxes) {
      if (_timeBoxContainsNow(box)) {
        return box;
      }
    }
    return null;
  }

  TimeBox? _nextUpcomingTimeBox() {
    final now = DateTime.now();
    final upcomingBoxes = state.timeBoxes.where((box) {
      final start = box.startMinutes;
      final end = box.endMinutes;
      if (start == null || end == null) {
        return false;
      }
      return _normalizedNowMinutes(start, end, now) < start;
    }).toList()..sort((a, b) => a.startMinutes!.compareTo(b.startMinutes!));

    return upcomingBoxes.isEmpty ? null : upcomingBoxes.first;
  }

  TimeBox? _nextTimeBoxAfter(TimeBox box) {
    final start = box.startMinutes;
    if (start == null) {
      return _nextUpcomingTimeBox();
    }

    final nextBoxes = state.timeBoxes.where((candidate) {
      final candidateStart = candidate.startMinutes;
      return candidateStart != null && candidateStart > start;
    }).toList()..sort((a, b) => a.startMinutes!.compareTo(b.startMinutes!));

    return nextBoxes.isEmpty ? null : nextBoxes.first;
  }

  String _titleForTimeBox(TimeBox box) {
    if (box.id == 'box-0900' && state.topPriorities.isNotEmpty) {
      final priority = state.topPriorities[0].trim();
      if (priority.isNotEmpty) {
        return priority;
      }
    }

    if (box.id == 'box-1330' && state.topPriorities.length > 1) {
      final priority = state.topPriorities[1].trim();
      if (priority.isNotEmpty) {
        return priority;
      }
    }

    return box.title;
  }

  int _nextStartMinutes(List<TimeBox> boxes) {
    final lastEnd = boxes.isEmpty ? null : boxes.last.endMinutes;
    return lastEnd ?? (9 * 60);
  }

  void _sortTimeBoxes(List<TimeBox> boxes) {
    boxes.sort((a, b) {
      final startA = a.startMinutes ?? (24 * 60);
      final startB = b.startMinutes ?? (24 * 60);
      return startA.compareTo(startB);
    });
  }

  String _formatClock(int minutes) {
    final dayMinutes = minutes % (24 * 60);
    final hour = dayMinutes ~/ 60;
    final minute = dayMinutes % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String _formatTimeRange(int startMinutes, int durationSeconds) {
    final endMinutes = startMinutes + (durationSeconds / 60).round();
    return '${_formatClock(startMinutes)}-${_formatClock(endMinutes)}';
  }

  int _remainingForTimeBox(TimeBox box) {
    final remainingTime = _clockRemainingForTimeBox(box);
    if (remainingTime == 0 && !_timeBoxContainsNow(box)) {
      return box.durationSeconds;
    }
    return remainingTime;
  }

  int _clockRemainingForTimeBox(TimeBox box) {
    final start = box.startMinutes;
    final end = box.endMinutes;
    if (start == null || end == null) {
      return box.durationSeconds;
    }

    final now = DateTime.now();
    final nowMinutes = _normalizedNowMinutes(start, end, now);

    if (nowMinutes >= start && nowMinutes < end) {
      return (((end - nowMinutes) * 60) - now.second)
          .clamp(0, box.durationSeconds)
          .toInt();
    }
    if (nowMinutes >= end) {
      return 0;
    }
    return box.durationSeconds;
  }

  bool _timeBoxContainsNow(TimeBox box) {
    final start = box.startMinutes;
    final end = box.endMinutes;
    if (start == null || end == null) {
      return false;
    }

    final now = DateTime.now();
    final nowMinutes = _normalizedNowMinutes(start, end, now);
    return nowMinutes >= start && nowMinutes < end;
  }

  bool _timeBoxHasEnded(TimeBox box) {
    final start = box.startMinutes;
    final end = box.endMinutes;
    if (start == null || end == null) {
      return false;
    }

    return _normalizedNowMinutes(start, end, DateTime.now()) >= end;
  }

  int _normalizedNowMinutes(int start, int end, DateTime now) {
    var nowMinutes = (now.hour * 60) + now.minute;
    if (end >= 24 * 60 && nowMinutes < start) {
      nowMinutes += 24 * 60;
    }
    return nowMinutes;
  }

  void _onTimerComplete() {
    _timerSubscription?.cancel();

    if (state.phase == PomodoroPhase.focus) {
      final completedSessions = state.completedSessions + 1;
      state = _stateAfterCompletedTodayBox(completedSessions);
      repository.updatePomodoro(state);

      if (state.autoStartFocus && state.remainingTime > 0) {
        state = state.copyWith(status: PomodoroStatus.running);
        repository.updatePomodoro(state);
        _timerSubscription = _startNativeTimer(_nativeCopy);
      }
      return;
    }

    state = _stateAfterCompletedTodayBox(state.completedSessions);
    repository.updatePomodoro(state);
  }

  Pomodoro _stateAfterCompletedPhase(PomodoroPhase phase, int sessions) {
    if (phase == PomodoroPhase.focus) {
      return _stateAfterCompletedTodayBox(sessions + 1);
    }

    return state.copyWith(
      status: PomodoroStatus.idle,
      phase: PomodoroPhase.focus,
      remainingTime: state.workDuration,
      completedSessions: sessions,
    );
  }

  Pomodoro _stateAfterCompletedTodayBox(int completedSessions) {
    final activeBox = state.activeTimeBox;
    final nextAfterActive = activeBox == null
        ? null
        : _nextTimeBoxAfter(activeBox);
    final nextBox =
        nextAfterActive != null && !_timeBoxHasEnded(nextAfterActive)
        ? nextAfterActive
        : _nextUpcomingTimeBox();

    if (nextBox == null) {
      return state.copyWith(
        status: PomodoroStatus.idle,
        phase: PomodoroPhase.focus,
        remainingTime: 0,
        completedSessions: completedSessions,
      );
    }

    return state.copyWith(
      activeTimeBoxId: nextBox.id,
      currentTimeBoxTitle: _titleForTimeBox(nextBox),
      currentTimeBoxTimeRange: nextBox.timeRange,
      workDuration: nextBox.durationSeconds,
      remainingTime: _remainingForTimeBox(nextBox),
      status: PomodoroStatus.idle,
      phase: PomodoroPhase.focus,
      completedSessions: completedSessions,
    );
  }
}
