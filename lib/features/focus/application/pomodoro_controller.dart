import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../di/focus_providers.dart';
import '../domain/entities/native_timer_copy.dart';
import '../domain/entities/daily_plan_item_category.dart';
import '../domain/entities/pomodoro.dart';
import '../domain/entities/daily_plan_summary.dart';
import '../domain/repositories/pomodoro_repository.dart';
import '../domain/usecases/pause_pomodoro.dart';
import '../domain/usecases/reset_pomodoro.dart';
import '../domain/usecases/restore_pomodoro_state.dart';
import '../domain/usecases/restore_today_plan.dart';
import '../domain/usecases/load_previous_plan.dart';
import '../domain/usecases/start_pomodoro.dart';

export '../di/focus_providers.dart';

part 'pomodoro_controller.g.dart';

class _SingleFlight {
  Future<void>? _pending;

  Future<void> run(Future<void> Function() operation) {
    final pending = _pending;
    if (pending != null) {
      return pending;
    }

    late final Future<void> next;
    next = operation().whenComplete(() {
      if (identical(_pending, next)) {
        _pending = null;
      }
    });
    _pending = next;
    return next;
  }
}

@Riverpod(keepAlive: true)
DateTime Function() pomodoroClock(Ref ref) => DateTime.now;

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
  LoadPreviousPlanUseCase get loadPreviousPlanUseCase =>
      ref.read(loadPreviousPlanUseCaseProvider);

  StreamSubscription? _timerSubscription;
  Timer? _clockSyncTimer;
  Future<void>? _localRestoreFuture;
  final _nativeRestore = _SingleFlight();
  final _dayRollover = _SingleFlight();
  final _scheduledAutoStart = _SingleFlight();
  NativeTimerCopy _nativeCopy = const NativeTimerCopy();
  late String _activeDateKey;

  @override
  Pomodoro build() {
    _activeDateKey = _dateKey(_now());
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
      syncDayBoundaryAndFocus();
    });
    return Pomodoro.initial();
  }

  Future<void> syncTodayPlanWithDatabase() async {
    await _restoreFromLocalPlan(force: true);
    syncFocusWithClock();
    ref.invalidate(dailyPlanHistoryProvider);
  }

  void updateNativeCopy(NativeTimerCopy nativeCopy) {
    _nativeCopy = nativeCopy;
  }

  Future<void> _restoreFromLocalPlan({bool force = false}) async {
    final pendingRestore = _localRestoreFuture;
    if (!force && pendingRestore != null) {
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

  Future<void> _restoreFromNative() => _nativeRestore.run(_doRestoreFromNative);

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
        syncDayBoundaryAndFocus();
      });
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(repository.flushPendingWrites());
    }
  }

  void _startClockSyncTimer() {
    _clockSyncTimer?.cancel();
    _clockSyncTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      syncDayBoundaryAndFocus();
    });
  }

  void syncDayBoundaryAndFocus() {
    final nextDateKey = _dateKey(_now());
    if (nextDateKey != _activeDateKey) {
      _activeDateKey = nextDateKey;
      unawaited(_rolloverToNewDay());
      return;
    }
    syncFocusWithClock();
  }

  Future<void> _rolloverToNewDay() => _dayRollover.run(_doRolloverToNewDay);

  Future<void> _doRolloverToNewDay() async {
    await repository.flushPendingWrites();
    final previous = state;
    final freshDay = Pomodoro.initial().copyWith(
      workDuration: previous.workDuration,
      breakDuration: previous.breakDuration,
      longBreakDuration: previous.longBreakDuration,
      sessionsUntilLongBreak: previous.sessionsUntilLongBreak,
      remainingTime: 0,
      preset: previous.preset,
      autoStartBreaks: previous.autoStartBreaks,
      autoStartFocus: previous.autoStartFocus,
      notificationsEnabled: previous.notificationsEnabled,
      soundEnabled: previous.soundEnabled,
    );
    state = await restoreTodayPlanUseCase(freshDay);
    await _restoreFromNative();
    syncFocusWithClock();
    ref.invalidate(dailyPlanHistoryProvider);
  }

  DateTime _now() => ref.read(pomodoroClockProvider)();

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
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
    unawaited(setScheduleTrackingEnabled(enabled, _nativeCopy));
  }

  Future<void> setScheduleTrackingEnabled(
    bool enabled,
    NativeTimerCopy nativeCopy,
  ) async {
    _nativeCopy = nativeCopy;
    if (state.autoStartFocus == enabled &&
        (enabled || state.status == PomodoroStatus.idle)) {
      if (enabled) {
        syncFocusWithClock();
      }
      return;
    }

    state = state.copyWith(autoStartFocus: enabled);
    repository.updatePomodoro(state);

    if (enabled) {
      syncFocusWithClock();
      await _scheduledAutoStart.run(_startScheduledTimeBox);
      return;
    }

    await _timerSubscription?.cancel();
    _timerSubscription = null;
    await resetUseCase();
    state = state.copyWith(
      status: PomodoroStatus.idle,
      phase: PomodoroPhase.focus,
    );
    syncFocusWithClock();
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

  TimeBox addTimeBoxAtStart(
    int startMinutes, {
    String title = 'New time box',
    int durationSeconds = _slotDurationSeconds,
    List<int> repeatWeekdays = const [],
  }) {
    return _commitAddedTimeBox(
      startMinutes: startMinutes,
      title: title,
      durationSeconds: durationSeconds,
      repeatWeekdays: repeatWeekdays,
    );
  }

  TimeBox? scheduleBrainDumpItemAtStart(int index, int startMinutes) {
    if (index < 0 || index >= state.brainDump.length) {
      return null;
    }

    final brainDump = List<String>.from(state.brainDump);
    final title = brainDump.removeAt(index);
    return _commitAddedTimeBox(
      startMinutes: startMinutes,
      title: title,
      brainDump: brainDump,
    );
  }

  TimeBox? scheduleTopPriorityAtStart(int index, int startMinutes) {
    if (index < 0 || index >= 3 || index >= state.topPriorities.length) {
      return null;
    }

    final title = state.topPriorities[index].trim();
    if (title.isEmpty) {
      return null;
    }

    return _commitAddedTimeBox(startMinutes: startMinutes, title: title);
  }

  TimeBox? scheduleReminderAtStart(int index, int startMinutes) {
    if (index < 0 || index >= state.reminders.length) {
      return null;
    }

    final reminders = List<String>.from(state.reminders);
    final title = reminders.removeAt(index);
    return _commitAddedTimeBox(
      startMinutes: startMinutes,
      title: title,
      reminders: reminders,
    );
  }

  bool canAcceptDailyPlanItem(
    DailyPlanItemCategory target, {
    DailyPlanItemCategory? source,
  }) {
    if (source == target) {
      return false;
    }
    if (target != DailyPlanItemCategory.topPriority) {
      return true;
    }
    return state.topPrioritySlots.any((item) => item.trim().isEmpty);
  }

  bool moveDailyPlanItem({
    required DailyPlanItemCategory source,
    required int index,
    required DailyPlanItemCategory target,
  }) {
    if (!canAcceptDailyPlanItem(target, source: source)) {
      return false;
    }

    final brainDump = List<String>.from(state.brainDump);
    final reminders = List<String>.from(state.reminders);
    final priorities = state.topPrioritySlots;
    late final String title;

    switch (source) {
      case DailyPlanItemCategory.brainDump:
        if (index < 0 || index >= brainDump.length) {
          return false;
        }
        title = brainDump.removeAt(index).trim();
      case DailyPlanItemCategory.topPriority:
        if (index < 0 || index >= priorities.length) {
          return false;
        }
        title = priorities[index].trim();
        priorities[index] = '';
      case DailyPlanItemCategory.reminder:
        if (index < 0 || index >= reminders.length) {
          return false;
        }
        title = reminders.removeAt(index).trim();
    }

    if (title.isEmpty ||
        !_appendDailyPlanItem(
          title: title,
          target: target,
          brainDump: brainDump,
          priorities: priorities,
          reminders: reminders,
        )) {
      return false;
    }

    state = state.copyWith(
      brainDump: brainDump,
      topPriorities: priorities,
      reminders: reminders,
    );
    repository.updatePomodoro(state);
    return true;
  }

  Future<bool> moveTimeBoxToDailyPlanItem(
    String id,
    DailyPlanItemCategory target,
  ) async {
    if (!canAcceptDailyPlanItem(target)) {
      return false;
    }

    var boxes = List<TimeBox>.from(state.timeBoxes);
    var index = boxes.indexWhere((box) => box.id == id);
    if (index == -1) {
      return false;
    }

    final removingActiveBox = id == state.activeTimeBoxId;
    if (removingActiveBox &&
        (state.status == PomodoroStatus.running ||
            state.status == PomodoroStatus.paused)) {
      _timerSubscription?.cancel();
      await resetUseCase();
      boxes = List<TimeBox>.from(state.timeBoxes);
      index = boxes.indexWhere((box) => box.id == id);
      if (index == -1) {
        return false;
      }
    }

    final title = _titleForTimeBox(boxes[index]).trim();
    final brainDump = List<String>.from(state.brainDump);
    final reminders = List<String>.from(state.reminders);
    final priorities = state.topPrioritySlots;
    if (title.isEmpty ||
        !_appendDailyPlanItem(
          title: title,
          target: target,
          brainDump: brainDump,
          priorities: priorities,
          reminders: reminders,
        )) {
      return false;
    }

    boxes.removeAt(index);
    state = state.copyWith(
      brainDump: brainDump,
      topPriorities: priorities,
      reminders: reminders,
      timeBoxes: boxes,
      activeTimeBoxId: removingActiveBox ? '' : state.activeTimeBoxId,
      currentTimeBoxTitle: removingActiveBox ? '' : state.currentTimeBoxTitle,
      currentTimeBoxTimeRange: removingActiveBox
          ? ''
          : state.currentTimeBoxTimeRange,
      remainingTime: removingActiveBox ? 0 : state.remainingTime,
      status: removingActiveBox ? PomodoroStatus.idle : state.status,
      phase: removingActiveBox ? PomodoroPhase.focus : state.phase,
    );
    repository.updatePomodoro(state);
    if (removingActiveBox) {
      syncFocusWithClock();
    }
    return true;
  }

  TimeBox _commitAddedTimeBox({
    required int startMinutes,
    required String title,
    int durationSeconds = _slotDurationSeconds,
    List<String>? brainDump,
    List<String>? reminders,
    List<int> repeatWeekdays = const [],
  }) {
    final boxes = List<TimeBox>.from(state.timeBoxes);
    final normalizedDuration = _normalizedDurationSeconds(durationSeconds);
    final nextBox = TimeBox(
      id: 'box-${DateTime.now().microsecondsSinceEpoch}',
      title: title.trim().isEmpty ? 'New time box' : title.trim(),
      timeRange: _formatTimeRange(startMinutes, normalizedDuration),
      durationSeconds: normalizedDuration,
      repeatWeekdays: _normalizedWeekdays(repeatWeekdays),
    );
    boxes.add(nextBox);
    _sortTimeBoxes(boxes);
    final shouldActivate =
        state.activeTimeBoxId.isEmpty && _timeBoxContainsNow(nextBox);

    state = state.copyWith(
      brainDump: brainDump ?? state.brainDump,
      reminders: reminders ?? state.reminders,
      timeBoxes: boxes,
      activeTimeBoxId: shouldActivate ? nextBox.id : state.activeTimeBoxId,
      currentTimeBoxTitle: shouldActivate
          ? _titleForTimeBox(nextBox)
          : state.currentTimeBoxTitle,
      currentTimeBoxTimeRange: shouldActivate
          ? nextBox.timeRange
          : state.currentTimeBoxTimeRange,
      workDuration: shouldActivate
          ? nextBox.durationSeconds
          : state.workDuration,
      remainingTime: shouldActivate
          ? _remainingForTimeBox(nextBox)
          : state.remainingTime,
    );
    repository.updatePomodoro(state);
    return nextBox;
  }

  Future<void> removeTimeBox(String id) async {
    final boxes = List<TimeBox>.from(state.timeBoxes);
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

    if (boxes.isEmpty) {
      state = state.copyWith(
        timeBoxes: boxes,
        activeTimeBoxId: '',
        currentTimeBoxTitle: '',
        currentTimeBoxTimeRange: '',
        workDuration: _slotDurationSeconds,
        remainingTime: 0,
        status: PomodoroStatus.idle,
        phase: PomodoroPhase.focus,
      );
      repository.updatePomodoro(state);
      return;
    }

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

  void updateTimeBox(
    String id, {
    String? title,
    String? timeRange,
    List<int>? repeatWeekdays,
  }) {
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
    final currentDuration = _durationForTimeBox(boxes[index]);
    final nextBox = boxes[index].copyWith(
      title: trimmedTitle == null || trimmedTitle.isEmpty
          ? boxes[index].title
          : trimmedTitle,
      timeRange: nextStart == null
          ? boxes[index].timeRange
          : _formatTimeRange(nextStart, currentDuration),
      durationSeconds: currentDuration,
      repeatWeekdays: repeatWeekdays == null
          ? boxes[index].repeatWeekdays
          : _normalizedWeekdays(repeatWeekdays),
    );
    boxes[index] = nextBox;
    if (_timeBoxOverlapsAny(boxes, box: nextBox, ignoreId: id)) {
      return;
    }
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
    final duration = _durationForTimeBox(box);
    if (_timeRangeOverlapsAny(
      boxes,
      startMinutes: startMinutes,
      endMinutes: startMinutes + (duration ~/ 60),
      ignoreId: id,
    )) {
      return;
    }

    final nextBox = box.copyWith(
      timeRange: _formatTimeRange(startMinutes, duration),
      durationSeconds: duration,
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

  void resizeTimeBoxEnd(String id, int endMinutes, {int? maxEndMinutes}) {
    final boxes = List<TimeBox>.from(state.timeBoxes);
    final index = boxes.indexWhere((box) => box.id == id);
    if (index == -1) {
      return;
    }

    final box = boxes[index];
    final start = box.startMinutes;
    if (start == null) {
      return;
    }

    final minEnd = start + (_slotDurationSeconds ~/ 60);
    final nextStart = _nextStartAfter(boxes, id, start);
    final upperBound = [maxEndMinutes, nextStart, 24 * 60]
        .whereType<int>()
        .where((value) => value > start)
        .fold<int>(
          24 * 60,
          (current, value) => value < current ? value : current,
        );
    final cappedEnd = endMinutes.clamp(minEnd, upperBound).toInt();
    final snappedEnd = _snapEndMinutes(
      start,
      cappedEnd,
    ).clamp(minEnd, upperBound).toInt();
    final duration = (snappedEnd - start) * 60;
    final nextDuration = _normalizedDurationSeconds(duration);

    if (nextDuration == _durationForTimeBox(box)) {
      return;
    }

    final nextBox = box.copyWith(
      timeRange: _formatTimeRange(start, nextDuration),
      durationSeconds: nextDuration,
    );
    boxes[index] = nextBox;
    _sortTimeBoxes(boxes);

    final updatingActiveBox = id == state.activeTimeBoxId;
    state = state.copyWith(
      timeBoxes: boxes,
      currentTimeBoxTimeRange: updatingActiveBox
          ? nextBox.timeRange
          : state.currentTimeBoxTimeRange,
      workDuration: updatingActiveBox && state.status == PomodoroStatus.idle
          ? nextBox.durationSeconds
          : state.workDuration,
      remainingTime: updatingActiveBox && state.status == PomodoroStatus.idle
          ? _remainingForTimeBox(nextBox)
          : state.remainingTime,
    );
    repository.updatePomodoro(state);
  }

  void resizeTimeBoxStart(String id, int startMinutes, {int? minStartMinutes}) {
    final boxes = List<TimeBox>.from(state.timeBoxes);
    final index = boxes.indexWhere((box) => box.id == id);
    if (index == -1) {
      return;
    }

    final box = boxes[index];
    final currentStart = box.startMinutes;
    final end = box.endMinutes;
    if (currentStart == null || end == null) {
      return;
    }

    final previousEnd = _previousEndBefore(boxes, id, currentStart);
    final lowerBound = [minStartMinutes, previousEnd, 0]
        .whereType<int>()
        .fold<int>(0, (current, value) => value > current ? value : current);
    final maxStart = end - (_slotDurationSeconds ~/ 60);
    final cappedStart = startMinutes.clamp(lowerBound, maxStart).toInt();
    final slotMinutes = _slotDurationSeconds ~/ 60;
    final snappedStart = ((cappedStart / slotMinutes).round() * slotMinutes)
        .clamp(lowerBound, maxStart)
        .toInt();
    if (snappedStart == currentStart) {
      return;
    }

    final nextDuration = _normalizedDurationSeconds((end - snappedStart) * 60);
    final nextBox = box.copyWith(
      timeRange: _formatTimeRange(snappedStart, nextDuration),
      durationSeconds: nextDuration,
    );
    boxes[index] = nextBox;
    _sortTimeBoxes(boxes);

    final updatingActiveBox = id == state.activeTimeBoxId;
    state = state.copyWith(
      timeBoxes: boxes,
      currentTimeBoxTimeRange: updatingActiveBox
          ? nextBox.timeRange
          : state.currentTimeBoxTimeRange,
      workDuration: updatingActiveBox && state.status == PomodoroStatus.idle
          ? nextBox.durationSeconds
          : state.workDuration,
      remainingTime: updatingActiveBox && state.status == PomodoroStatus.idle
          ? _remainingForTimeBox(nextBox)
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

  Future<bool> carryOverPreviousTopPriorities() async {
    final previous = await loadPreviousPlanUseCase(state);
    final previousPriorities = previous?.topPriorities
        .map((priority) => priority.trim())
        .where((priority) => priority.isNotEmpty)
        .take(3)
        .toList();
    if (previousPriorities == null || previousPriorities.isEmpty) {
      return false;
    }

    final priorities = List<String>.from(state.topPriorities.take(3));
    while (priorities.length < 3) {
      priorities.add('');
    }
    var sourceIndex = 0;
    for (var index = 0; index < priorities.length; index += 1) {
      if (priorities[index].trim().isNotEmpty ||
          sourceIndex >= previousPriorities.length) {
        continue;
      }
      priorities[index] = previousPriorities[sourceIndex];
      sourceIndex += 1;
    }

    state = state.copyWith(topPriorities: priorities.take(3).toList());
    repository.updatePomodoro(state);
    return true;
  }

  Future<bool> carryOverPreviousBrainDump() async {
    final previous = await loadPreviousPlanUseCase(state);
    final items = previous?.brainDump
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (items == null || items.isEmpty) {
      return false;
    }

    state = state.copyWith(brainDump: _mergedTextList(state.brainDump, items));
    repository.updatePomodoro(state);
    return true;
  }

  Future<bool> carryOverPreviousReminders() async {
    final previous = await loadPreviousPlanUseCase(state);
    final items = previous?.reminders
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (items == null || items.isEmpty) {
      return false;
    }

    state = state.copyWith(reminders: _mergedTextList(state.reminders, items));
    repository.updatePomodoro(state);
    return true;
  }

  Future<bool> carryOverPreviousTimeBoxes() async {
    final previous = await loadPreviousPlanUseCase(state);
    final boxes = previous?.timeBoxes;
    if (boxes == null || boxes.isEmpty) {
      return false;
    }

    final existingFingerprints = state.timeBoxes
        .map((box) => '${box.timeRange}.${box.title.trim()}')
        .toSet();
    final nextBoxes = List<TimeBox>.from(state.timeBoxes);
    for (final box in boxes) {
      final fingerprint = '${box.timeRange}.${box.title.trim()}';
      if (existingFingerprints.contains(fingerprint)) {
        continue;
      }
      existingFingerprints.add(fingerprint);
      nextBoxes.add(box.copyWith(id: _copiedTimeBoxId(box.id)));
    }
    if (nextBoxes.length == state.timeBoxes.length) {
      return false;
    }

    _sortTimeBoxes(nextBoxes);
    state = state.copyWith(timeBoxes: nextBoxes);
    repository.updatePomodoro(state);
    syncFocusWithClock();
    return true;
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
      if (state.autoStartFocus && state.canStartFocus) {
        unawaited(_scheduledAutoStart.run(_startScheduledTimeBox));
      }
      return;
    }

    _clearClockSyncedTimeBox();
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

  Future<void> _startScheduledTimeBox() async {
    if (!state.autoStartFocus || !state.canStartFocus) {
      return;
    }

    state = state.copyWith(status: PomodoroStatus.running);
    repository.updatePomodoro(state);
    await _timerSubscription?.cancel();
    _timerSubscription = _startNativeTimer(_nativeCopy);
  }

  void _clearClockSyncedTimeBox() {
    final isAlreadyClear =
        state.activeTimeBoxId.isEmpty &&
        state.currentTimeBoxTitle.isEmpty &&
        state.currentTimeBoxTimeRange.isEmpty &&
        state.remainingTime == 0 &&
        state.status == PomodoroStatus.idle &&
        state.phase == PomodoroPhase.focus;

    if (isAlreadyClear) {
      return;
    }

    state = state.copyWith(
      activeTimeBoxId: '',
      currentTimeBoxTitle: '',
      currentTimeBoxTimeRange: '',
      remainingTime: 0,
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

  int _durationForTimeBox(TimeBox box) {
    final rangeDuration = box.rangeDurationSeconds;
    if (rangeDuration != null && rangeDuration > 0) {
      return _normalizedDurationSeconds(rangeDuration);
    }
    return _normalizedDurationSeconds(box.durationSeconds);
  }

  int _normalizedDurationSeconds(int durationSeconds) {
    final slotCount = (durationSeconds / _slotDurationSeconds)
        .round()
        .clamp(1, 48)
        .toInt();
    return slotCount * _slotDurationSeconds;
  }

  int _snapEndMinutes(int startMinutes, int endMinutes) {
    final slotMinutes = _slotDurationSeconds ~/ 60;
    final durationMinutes = (endMinutes - startMinutes)
        .clamp(slotMinutes, 24 * 60)
        .toInt();
    final slotCount = (durationMinutes / slotMinutes)
        .round()
        .clamp(1, 48)
        .toInt();
    return startMinutes + (slotCount * slotMinutes);
  }

  void _sortTimeBoxes(List<TimeBox> boxes) {
    boxes.sort((a, b) {
      final startA = a.startMinutes ?? (24 * 60);
      final startB = b.startMinutes ?? (24 * 60);
      return startA.compareTo(startB);
    });
  }

  bool _timeBoxOverlapsAny(
    List<TimeBox> boxes, {
    required TimeBox box,
    required String ignoreId,
  }) {
    final start = box.startMinutes;
    final end = box.endMinutes;
    if (start == null || end == null) {
      return false;
    }
    return _timeRangeOverlapsAny(
      boxes,
      startMinutes: start,
      endMinutes: end,
      ignoreId: ignoreId,
    );
  }

  bool _timeRangeOverlapsAny(
    List<TimeBox> boxes, {
    required int startMinutes,
    required int endMinutes,
    required String ignoreId,
  }) {
    if (endMinutes <= startMinutes) {
      return false;
    }
    for (final box in boxes) {
      if (box.id == ignoreId) {
        continue;
      }

      final start = box.startMinutes;
      final end = box.endMinutes;
      if (start == null || end == null) {
        continue;
      }
      if (startMinutes < end && endMinutes > start) {
        return true;
      }
    }
    return false;
  }

  int? _nextStartAfter(List<TimeBox> boxes, String id, int startMinutes) {
    int? nextStart;
    for (final box in boxes) {
      if (box.id == id) {
        continue;
      }
      final candidateStart = box.startMinutes;
      if (candidateStart == null || candidateStart <= startMinutes) {
        continue;
      }
      if (nextStart == null || candidateStart < nextStart) {
        nextStart = candidateStart;
      }
    }
    return nextStart;
  }

  int? _previousEndBefore(List<TimeBox> boxes, String id, int startMinutes) {
    int? previousEnd;
    for (final box in boxes) {
      if (box.id == id) {
        continue;
      }
      final candidateEnd = box.endMinutes;
      if (candidateEnd == null || candidateEnd > startMinutes) {
        continue;
      }
      if (previousEnd == null || candidateEnd > previousEnd) {
        previousEnd = candidateEnd;
      }
    }
    return previousEnd;
  }

  bool _appendDailyPlanItem({
    required String title,
    required DailyPlanItemCategory target,
    required List<String> brainDump,
    required List<String> priorities,
    required List<String> reminders,
  }) {
    switch (target) {
      case DailyPlanItemCategory.brainDump:
        brainDump.add(title);
      case DailyPlanItemCategory.topPriority:
        final targetIndex = priorities.indexWhere(
          (priority) => priority.trim().isEmpty,
        );
        if (targetIndex == -1) {
          return false;
        }
        priorities[targetIndex] = title;
      case DailyPlanItemCategory.reminder:
        reminders.add(title);
    }
    return true;
  }

  List<int> _normalizedWeekdays(List<int> weekdays) {
    return weekdays
        .where((weekday) => weekday >= 1 && weekday <= 7)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> _mergedTextList(List<String> current, List<String> previous) {
    final seen = current.map((item) => item.trim()).where((item) {
      return item.isNotEmpty;
    }).toSet();
    final merged = <String>[
      ...current.map((item) => item.trim()).where((item) => item.isNotEmpty),
    ];
    for (final item in previous) {
      final trimmed = item.trim();
      if (trimmed.isEmpty || seen.contains(trimmed)) {
        continue;
      }
      seen.add(trimmed);
      merged.add(trimmed);
    }
    return merged;
  }

  String _copiedTimeBoxId(String sourceId) {
    return 'box-copy-${sourceId.hashCode}-${DateTime.now().microsecondsSinceEpoch}';
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

    final now = _now();
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

    final now = _now();
    final nowMinutes = _normalizedNowMinutes(start, end, now);
    return nowMinutes >= start && nowMinutes < end;
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
    final nextBox = _currentTimeBoxForNow();

    if (nextBox == null) {
      return state.copyWith(
        activeTimeBoxId: '',
        currentTimeBoxTitle: '',
        currentTimeBoxTimeRange: '',
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
