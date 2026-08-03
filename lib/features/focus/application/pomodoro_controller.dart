import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/diagnostics/app_diagnostics.dart';
import '../../settings/application/app_preferences_controller.dart';
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
import '../domain/usecases/load_plan_for_date.dart';
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

/// 슬롯 간격별 슬롯 휴식 길이(분): 15분→1분, 30분→3분, 60분→5분.
int slotBreakMinutesForInterval(int intervalMinutes) {
  return switch (intervalMinutes) {
    15 => 1,
    30 => 3,
    _ => 5,
  };
}

/// 현재 시각(자정 기준 초)에서 다음 슬롯 휴식 창까지의 거리.
///
/// 휴식 창은 각 슬롯 경계의 마지막 [breakMinutes]분이다.
/// 예: 간격 30분·휴식 3분이면 창은 매시 27~30분, 57~60분.
/// [secondsToBreakStart]가 0 이하이면 지금이 휴식 창 안이다.
({int secondsToBreakStart, int secondsToBoundary}) slotBreakWindow(
  int nowSeconds,
  int intervalMinutes,
  int breakMinutes,
) {
  final intervalSeconds = intervalMinutes * 60;
  final boundary = ((nowSeconds ~/ intervalSeconds) + 1) * intervalSeconds;
  final breakStart = boundary - (breakMinutes * 60);
  return (
    secondsToBreakStart: breakStart - nowSeconds,
    secondsToBoundary: boundary - nowSeconds,
  );
}

@riverpod
Future<List<DailyPlanSummary>> dailyPlanHistory(Ref ref, {int days = 7}) {
  return ref.watch(loadDailyPlanHistoryUseCaseProvider).call(days: days);
}

/// 특정 날짜 키(yyyy-MM-dd)의 저장된 플랜 원문. 과거 기록 열람 UI가 사용한다.
/// doc: docs/architecture/DATA_LIFECYCLE.md
@riverpod
Future<Pomodoro?> planForDate(Ref ref, {required String dateKey}) {
  return ref
      .watch(loadPlanForDateUseCaseProvider)
      .call(dateKey, Pomodoro.initial());
}

@Riverpod(keepAlive: true)
class PomodoroController extends _$PomodoroController
    with WidgetsBindingObserver {
  static const int _slotDurationSeconds = 30 * 60;

  PomodoroRepository get repository => ref.read(pomodoroRepositoryProvider);
  AppDiagnostics get diagnostics => ref.read(appDiagnosticsProvider);
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
  LoadPlanForDateUseCase get loadPlanForDateUseCase =>
      ref.read(loadPlanForDateUseCaseProvider);

  StreamSubscription? _timerSubscription;
  StreamSubscription? _liveActivityRegistrationSubscription;
  StreamSubscription? _liveActivityEndedSubscription;
  Timer? _clockSyncTimer;
  Future<void>? _localRestoreFuture;
  bool _hasRestoredLocalPlan = false;
  bool _initialRestoreCompleted = false;

  /// 현재 세션이 추적(자동 시작)으로 시작됐는지. 추적을 꺼도 수동 세션은
  /// 유지하기 위해 세션 기원을 구분한다.
  bool _activeSessionAutoStarted = false;

  /// 추적 모드에서 사용자가 정지를 택한 박스 id. 그 박스가 끝날 때까지
  /// 1초 클록 동기화가 세션을 되살리지 않게 한다.
  String _skippedAutoStartBoxId = '';

  /// 슬롯 휴식이 진행 중인 박스 id. 휴식이 끝나면 같은 박스의 다음
  /// 집중 세그먼트로 자동 복귀한다.
  String _slotBreakBoxId = '';
  final _nativeRestore = _SingleFlight();
  final _dayRollover = _SingleFlight();
  final _scheduledAutoStart = _SingleFlight();
  NativeTimerCopy _nativeCopy = const NativeTimerCopy();
  late String _activeDateKey;

  @override
  Pomodoro build() {
    _activeDateKey = _dateKey(_now());
    WidgetsBinding.instance.addObserver(this);
    _liveActivityRegistrationSubscription = repository
        .liveActivityRegistrations()
        .listen((registration) {
          unawaited(
            _captureNonFatal(
              'live_activity_token_registration_failed',
              () => repository.registerLiveActivityPushToken(registration),
            ),
          );
        }, onError: _recordLiveActivityStreamError);
    _liveActivityEndedSubscription = repository.endedLiveActivityIds().listen((
      activityId,
    ) {
      unawaited(
        _captureNonFatal(
          'live_activity_token_removal_failed',
          () => repository.removeLiveActivityPushToken(activityId),
        ),
      );
    }, onError: _recordLiveActivityStreamError);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _timerSubscription?.cancel();
      _liveActivityRegistrationSubscription?.cancel();
      _liveActivityEndedSubscription?.cancel();
      _clockSyncTimer?.cancel();
    });
    Future.microtask(() async {
      await _captureNonFatal(
        'initial_live_activity_token_sync_failed',
        repository.syncLiveActivityPushTokens,
      );
      await _captureNonFatal(
        'initial_local_plan_restore_failed',
        _restoreFromLocalPlan,
      );
      await _captureNonFatal(
        'initial_native_timer_restore_failed',
        _restoreFromNative,
      );
      _completeInitialRestore();
    });
    return Pomodoro.initial();
  }

  Future<void> syncTodayPlanWithDatabase() async {
    await _restoreFromLocalPlan(force: true);
    _completeInitialRestore();
    ref.invalidate(dailyPlanHistoryProvider);
  }

  Future<void> flushPendingPlanWrites() => repository.flushPendingWrites();

  Future<void> clearLocalPlanForSignOut() async {
    await _timerSubscription?.cancel();
    _timerSubscription = null;
    await repository.clearLocalPlanData();
  }

  Future<void> persistCurrentPlan() async {
    repository.updatePomodoro(state);
    await repository.flushPendingWrites();
  }

  void updateNativeCopy(NativeTimerCopy nativeCopy) {
    _nativeCopy = nativeCopy;
  }

  Future<void> _restoreFromLocalPlan({bool force = false}) async {
    final pendingRestore = _localRestoreFuture;
    if (pendingRestore != null) {
      return pendingRestore;
    }
    if (!force && _hasRestoredLocalPlan) {
      return;
    }

    late final Future<void> restoreFuture;
    restoreFuture = _doRestoreFromLocalPlan().whenComplete(() {
      if (identical(_localRestoreFuture, restoreFuture)) {
        _hasRestoredLocalPlan = true;
        _localRestoreFuture = null;
      }
    });
    _localRestoreFuture = restoreFuture;
    return restoreFuture;
  }

  Future<void> _doRestoreFromLocalPlan() async {
    state = await restoreTodayPlanUseCase(state);
  }

  void _completeInitialRestore() {
    if (!_initialRestoreCompleted) {
      _initialRestoreCompleted = true;
      _startClockSyncTimer();
    }
    syncDayBoundaryAndFocus();
  }

  Future<void> _restoreFromNative() => _nativeRestore.run(_doRestoreFromNative);

  Future<void> _captureNonFatal(
    String reason,
    Future<void> Function() operation, {
    Map<String, Object> attributes = const {},
  }) async {
    try {
      await operation();
    } catch (error, stackTrace) {
      await diagnostics.recordNonFatal(
        error,
        stackTrace,
        reason: reason,
        attributes: attributes,
      );
    }
  }

  void _recordLiveActivityStreamError(Object error, StackTrace stackTrace) {
    unawaited(
      diagnostics.recordNonFatal(
        error,
        stackTrace,
        reason: 'live_activity_platform_stream_failed',
      ),
    );
  }

  void _recordTimerBreadcrumb(String event) {
    unawaited(diagnostics.setContext('timer_status', state.status.name));
    unawaited(diagnostics.setContext('timer_phase', state.phase.name));
    unawaited(
      diagnostics.breadcrumb(
        event,
        attributes: {
          'timer_status': state.status.name,
          'timer_phase': state.phase.name,
          'schedule_tracking': state.autoStartFocus ? 1 : 0,
        },
      ),
    );
  }

  Future<void> _doRestoreFromNative() async {
    final restored = await restoreUseCase(state);
    state = state.copyWith(
      notificationsEnabled: restored.notificationsEnabled,
      soundEnabled: restored.soundEnabled,
    );

    switch (restored.status) {
      case 'running':
        state = state.copyWith(
          status: PomodoroStatus.running,
          remainingTime: restored.remainingTime,
          completedSessions: restored.sessionCount,
          sessionsUntilLongBreak: restored.sessionGoal,
          phase: restored.phase,
          currentTimeBoxTitle: restored.currentTimeBoxTitle.trim().isEmpty
              ? state.currentTimeBoxTitle
              : restored.currentTimeBoxTitle,
          currentTimeBoxTimeRange:
              restored.currentTimeBoxTimeRange.trim().isEmpty
              ? state.currentTimeBoxTimeRange
              : restored.currentTimeBoxTimeRange,
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
          currentTimeBoxTitle: restored.currentTimeBoxTitle.trim().isEmpty
              ? state.currentTimeBoxTitle
              : restored.currentTimeBoxTitle,
          currentTimeBoxTimeRange:
              restored.currentTimeBoxTimeRange.trim().isEmpty
              ? state.currentTimeBoxTimeRange
              : restored.currentTimeBoxTimeRange,
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
      unawaited(_reconcileAfterResume());
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(
        _captureNonFatal(
          'background_pending_write_flush_failed',
          repository.flushPendingWrites,
        ),
      );
    }
  }

  Future<void> _reconcileAfterResume() async {
    await _captureNonFatal(
      'resume_live_activity_token_sync_failed',
      repository.syncLiveActivityPushTokens,
    );
    await _captureNonFatal(
      'resume_native_timer_restore_failed',
      _restoreFromNative,
    );
    syncDayBoundaryAndFocus();
  }

  void _startClockSyncTimer() {
    _clockSyncTimer?.cancel();
    _clockSyncTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      syncDayBoundaryAndFocus();
    });
  }

  void syncDayBoundaryAndFocus() {
    if (!_initialRestoreCompleted) {
      return;
    }
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
    _timerSubscription = repository.ticks().listen(
      (remainingTime) {
        state = state.copyWith(remainingTime: remainingTime);
        if (remainingTime == 0) {
          _onTimerComplete();
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        unawaited(
          diagnostics.recordNonFatal(
            error,
            stackTrace,
            reason: 'native_timer_tick_stream_failed',
          ),
        );
      },
    );
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
    ).listen(
      (remainingTime) {
        state = state.copyWith(remainingTime: remainingTime);

        if (remainingTime == 0) {
          _onTimerComplete();
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        unawaited(
          diagnostics.recordNonFatal(
            error,
            stackTrace,
            reason: 'native_timer_start_stream_failed',
          ),
        );
      },
    );
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
      _recordTimerBreadcrumb('focus_resumed');
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
      // 사용자가 직접 시작을 택했으므로 이 박스의 정지(스킵) 선택은 해제한다.
      _skippedAutoStartBoxId = '';
      syncFocusWithClock();
      if (state.remainingTime <= 0) {
        debugPrint(
          '[Pomodoro/Dart] start() skipped - no active timebox time left',
        );
        return;
      }

      if (_startSlotBreakIfInWindow(
        boxRemaining: state.remainingTime,
        autoOrigin: false,
      )) {
        return;
      }

      _activeSessionAutoStarted = false;
      state = state.copyWith(
        status: PomodoroStatus.running,
        remainingTime: _focusSegmentRemaining(state.remainingTime),
      );
      repository.updatePomodoro(state);

      _timerSubscription?.cancel();
      _timerSubscription = _startNativeTimer(nativeCopy);
      _recordTimerBreadcrumb('focus_started');
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
    _recordTimerBreadcrumb('focus_paused');
  }

  Future<void> reset() async {
    final previous = state;
    // 추적 모드에서 사용자가 정지를 택했다면, 이 박스는 끝날 때까지
    // 클록 동기화가 자동으로 되살리지 않는다.
    if (previous.autoStartFocus && previous.activeTimeBoxId.isNotEmpty) {
      _skippedAutoStartBoxId = previous.activeTimeBoxId;
    }
    _activeSessionAutoStarted = false;
    _slotBreakBoxId = '';
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
    _recordTimerBreadcrumb('focus_reset');
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

  /// 타임박스 실시간 추적(알림·Live Activity) on/off — 순수 정책 스위치.
  ///
  /// 켜면 추적 세션(자동 시작)이 활성화되고, 끄면 추적으로 시작된 세션과
  /// 그 알림/Live Activity만 내린다. 사용자가 직접 시작한 세션은 어느
  /// 시점에 꺼도 유지된다.
  Future<void> setScheduleTrackingEnabled(
    bool enabled,
    NativeTimerCopy nativeCopy,
  ) async {
    _nativeCopy = nativeCopy;
    if (state.autoStartFocus == enabled) {
      if (enabled) {
        syncFocusWithClock();
      }
      return;
    }

    state = state.copyWith(autoStartFocus: enabled);
    repository.updatePomodoro(state);

    if (enabled) {
      _skippedAutoStartBoxId = '';
      syncFocusWithClock();
      return;
    }

    final trackedSessionActive =
        _activeSessionAutoStarted &&
        (state.status == PomodoroStatus.running ||
            state.status == PomodoroStatus.paused);
    if (trackedSessionActive) {
      await _timerSubscription?.cancel();
      _timerSubscription = null;
      _slotBreakBoxId = '';
      await resetUseCase();
      state = state.copyWith(
        status: PomodoroStatus.idle,
        phase: PomodoroPhase.focus,
      );
      repository.updatePomodoro(state);
      syncFocusWithClock();
    }
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

  /// 카테고리와 무관하게 데일리 플랜 항목의 텍스트를 제자리 수정한다.
  /// 공용 편집 시트(탭 → 수정)가 사용하는 단일 진입점이다.
  bool updateDailyPlanItem(
    DailyPlanItemCategory category,
    int index,
    String value,
  ) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return false;
    }

    switch (category) {
      case DailyPlanItemCategory.topPriority:
        if (index < 0 || index >= 3) {
          return false;
        }
        setTopPriority(index, trimmed);
        return true;
      case DailyPlanItemCategory.brainDump:
        if (index < 0 || index >= state.brainDump.length) {
          return false;
        }
        final items = List<String>.from(state.brainDump);
        items[index] = trimmed;
        state = state.copyWith(brainDump: items);
      case DailyPlanItemCategory.reminder:
        if (index < 0 || index >= state.reminders.length) {
          return false;
        }
        final items = List<String>.from(state.reminders);
        items[index] = trimmed;
        state = state.copyWith(reminders: items);
    }
    repository.updatePomodoro(state);
    return true;
  }

  bool moveBrainDumpItemToReminder(int index) {
    return moveDailyPlanItem(
      source: DailyPlanItemCategory.brainDump,
      index: index,
      target: DailyPlanItemCategory.reminder,
    );
  }

  /// 빈 우선순위 슬롯이 없으면 덮어쓰지 않고 false를 반환한다.
  /// 직접 추가/드래그 경로와 동일한 3개 제한 정책을 공유한다.
  bool promoteBrainDumpItem(int index) {
    return moveDailyPlanItem(
      source: DailyPlanItemCategory.brainDump,
      index: index,
      target: DailyPlanItemCategory.topPriority,
    );
  }

  /// 같은 카테고리 안에서 항목 순서를 변경한다. 성공 시 true.
  bool reorderDailyPlanItem({
    required DailyPlanItemCategory category,
    required int fromIndex,
    required int toIndex,
  }) {
    if (fromIndex == toIndex) {
      return false;
    }

    switch (category) {
      case DailyPlanItemCategory.brainDump:
        final items = List<String>.from(state.brainDump);
        if (!_reorderWithin(items, fromIndex, toIndex)) {
          return false;
        }
        state = state.copyWith(brainDump: items);
      case DailyPlanItemCategory.reminder:
        final items = List<String>.from(state.reminders);
        if (!_reorderWithin(items, fromIndex, toIndex)) {
          return false;
        }
        state = state.copyWith(reminders: items);
      case DailyPlanItemCategory.topPriority:
        final slots = state.topPrioritySlots;
        if (!_reorderWithin(slots, fromIndex, toIndex)) {
          return false;
        }
        state = state.copyWith(topPriorities: slots.take(3).toList());
    }
    repository.updatePomodoro(state);
    return true;
  }

  bool _reorderWithin(List<String> items, int fromIndex, int toIndex) {
    if (fromIndex < 0 ||
        fromIndex >= items.length ||
        toIndex < 0 ||
        toIndex >= items.length) {
      return false;
    }
    final moved = items.removeAt(fromIndex);
    items.insert(toIndex, moved);
    return true;
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
    int durationStepMinutes = _slotDurationSeconds ~/ 60,
    List<int> repeatWeekdays = const [],
  }) {
    return _commitAddedTimeBox(
      startMinutes: startMinutes,
      title: title,
      durationSeconds: durationSeconds,
      durationStepMinutes: durationStepMinutes,
      repeatWeekdays: repeatWeekdays,
    );
  }

  TimeBox? scheduleBrainDumpItemAtStart(
    int index,
    int startMinutes, {
    int durationMinutes = _slotDurationSeconds ~/ 60,
  }) {
    if (index < 0 || index >= state.brainDump.length) {
      return null;
    }

    final brainDump = List<String>.from(state.brainDump);
    final title = brainDump.removeAt(index);
    return _commitAddedTimeBox(
      startMinutes: startMinutes,
      title: title,
      durationSeconds: durationMinutes * 60,
      durationStepMinutes: durationMinutes,
      brainDump: brainDump,
    );
  }

  TimeBox? scheduleTopPriorityAtStart(
    int index,
    int startMinutes, {
    int durationMinutes = _slotDurationSeconds ~/ 60,
  }) {
    if (index < 0 || index >= 3 || index >= state.topPriorities.length) {
      return null;
    }

    final title = state.topPriorities[index].trim();
    if (title.isEmpty) {
      return null;
    }

    return _commitAddedTimeBox(
      startMinutes: startMinutes,
      title: title,
      durationSeconds: durationMinutes * 60,
      durationStepMinutes: durationMinutes,
    );
  }

  TimeBox? scheduleReminderAtStart(
    int index,
    int startMinutes, {
    int durationMinutes = _slotDurationSeconds ~/ 60,
  }) {
    if (index < 0 || index >= state.reminders.length) {
      return null;
    }

    final reminders = List<String>.from(state.reminders);
    final title = reminders.removeAt(index);
    return _commitAddedTimeBox(
      startMinutes: startMinutes,
      title: title,
      durationSeconds: durationMinutes * 60,
      durationStepMinutes: durationMinutes,
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
    int durationStepMinutes = _slotDurationSeconds ~/ 60,
    List<String>? brainDump,
    List<String>? reminders,
    List<int> repeatWeekdays = const [],
  }) {
    final boxes = List<TimeBox>.from(state.timeBoxes);
    final normalizedDuration = _normalizedDurationSeconds(
      durationSeconds,
      stepMinutes: durationStepMinutes,
    );
    final uniqueId = DateTime.now().microsecondsSinceEpoch;
    final normalizedRepeatWeekdays = _normalizedWeekdays(repeatWeekdays);
    final nextBox = TimeBox(
      id: 'box-$uniqueId',
      title: title.trim().isEmpty ? 'New time box' : title.trim(),
      timeRange: _formatTimeRange(startMinutes, normalizedDuration),
      durationSeconds: normalizedDuration,
      repeatWeekdays: normalizedRepeatWeekdays,
      recurrenceId: normalizedRepeatWeekdays.isEmpty
          ? ''
          : 'recurrence-$uniqueId',
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
      // Registering a card opts the schedule into Live tracking. The user can
      // still turn it off afterwards, but adding every new card no longer
      // requires a second trip to Focus just to activate its Live Activity.
      autoStartFocus: true,
    );
    repository.updatePomodoro(state);
    _skippedAutoStartBoxId = '';
    syncFocusWithClock();
    return nextBox;
  }

  Future<void> removeTimeBox(String id) async {
    final boxes = List<TimeBox>.from(state.timeBoxes);
    final removeIndex = boxes.indexWhere((box) => box.id == id);
    if (removeIndex == -1) {
      return;
    }

    final removingBox = boxes[removeIndex];
    final removingActiveBox = id == state.activeTimeBoxId;
    if (removingActiveBox &&
        (state.status == PomodoroStatus.running ||
            state.status == PomodoroStatus.paused)) {
      await reset();
    }

    boxes.removeAt(removeIndex);
    final cancelledRecurrenceKeys = <String>{
      ...state.cancelledRecurrenceKeys,
      if (removingBox.repeatWeekdays.isNotEmpty ||
          removingBox.recurrenceId.isNotEmpty)
        removingBox.recurrenceCancellationKey,
    }.toList()..sort();

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
        cancelledRecurrenceKeys: cancelledRecurrenceKeys,
      );
      repository.updatePomodoro(state);
      return;
    }

    if (!removingActiveBox) {
      state = state.copyWith(
        timeBoxes: boxes,
        cancelledRecurrenceKeys: cancelledRecurrenceKeys,
      );
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
      cancelledRecurrenceKeys: cancelledRecurrenceKeys,
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
    final previousBox = boxes[index];
    final normalizedRepeatWeekdays = repeatWeekdays == null
        ? previousBox.repeatWeekdays
        : _normalizedWeekdays(repeatWeekdays);
    final recurrenceStopped =
        previousBox.repeatWeekdays.isNotEmpty &&
        normalizedRepeatWeekdays.isEmpty;
    final recurrenceStarted =
        previousBox.recurrenceId.isEmpty && normalizedRepeatWeekdays.isNotEmpty;
    final nextBox = previousBox.copyWith(
      title: trimmedTitle == null || trimmedTitle.isEmpty
          ? boxes[index].title
          : trimmedTitle,
      timeRange: nextStart == null
          ? boxes[index].timeRange
          : _formatTimeRange(nextStart, currentDuration),
      durationSeconds: currentDuration,
      repeatWeekdays: normalizedRepeatWeekdays,
      recurrenceId: recurrenceStopped
          ? ''
          : recurrenceStarted
          ? 'recurrence-${DateTime.now().microsecondsSinceEpoch}'
          : previousBox.recurrenceId,
    );
    boxes[index] = nextBox;
    if (_timeBoxOverlapsAny(boxes, box: nextBox, ignoreId: id)) {
      return;
    }
    _sortTimeBoxes(boxes);
    final remainingTime = _remainingForTimeBox(nextBox);

    final updatingActiveBox = id == state.activeTimeBoxId;
    final cancelledRecurrenceKeys = <String>{
      ...state.cancelledRecurrenceKeys,
      if (recurrenceStopped) previousBox.recurrenceCancellationKey,
    }.toList()..sort();
    state = state.copyWith(
      timeBoxes: boxes,
      cancelledRecurrenceKeys: cancelledRecurrenceKeys,
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

    // 실행 중인 활성 카드의 제목/시간이 바뀌면 Flutter state만 바꾸지 않고
    // 같은 절대 시각 기준으로 Native Timer와 Live Activity도 즉시 갱신한다.
    _syncAfterScheduleMutation(activeBoxChanged: updatingActiveBox);
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
    _syncAfterScheduleMutation(activeBoxChanged: updatingActiveBox);
  }

  void resizeTimeBoxEnd(
    String id,
    int endMinutes, {
    int? maxEndMinutes,
    int stepMinutes = _slotDurationSeconds ~/ 60,
  }) {
    final boxes = List<TimeBox>.from(state.timeBoxes);
    final index = boxes.indexWhere((box) => box.id == id);
    if (index == -1) {
      return;
    }

    final box = boxes[index];
    final start = box.startMinutes;
    final currentEnd = box.endMinutes;
    if (start == null || currentEnd == null) {
      return;
    }

    final normalizedStepMinutes = _normalizedDurationStepMinutes(stepMinutes);
    final currentDurationMinutes = currentEnd - start;
    final minimumDurationMinutes =
        currentDurationMinutes < normalizedStepMinutes
        ? currentDurationMinutes
        : normalizedStepMinutes;
    final minEnd = start + minimumDurationMinutes;
    final nextStart = _nextStartAfter(boxes, id, start);
    // 자정 넘김 창을 지원하므로 하드 캡은 다음날 04:00(28*60)까지 허용한다.
    // 실제 상한은 호출부가 넘기는 maxEndMinutes(깨어있는 시간 끝)가 정한다.
    const scheduleCapMinutes = 28 * 60;
    final upperBound = [maxEndMinutes, nextStart, scheduleCapMinutes]
        .whereType<int>()
        .where((value) => value > start)
        .fold<int>(
          scheduleCapMinutes,
          (current, value) => value < current ? value : current,
        );
    if (upperBound < minEnd) {
      return;
    }
    final requestedStepCount =
        ((endMinutes - currentEnd) / normalizedStepMinutes).round();
    final snappedEnd =
        currentEnd + (requestedStepCount * normalizedStepMinutes);
    final cappedEnd = snappedEnd.clamp(minEnd, upperBound).toInt();
    final nextDurationMinutes = cappedEnd - start;
    final nextDuration = nextDurationMinutes * 60;

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
    _syncAfterScheduleMutation(activeBoxChanged: updatingActiveBox);
  }

  void resizeTimeBoxStart(
    String id,
    int startMinutes, {
    int? minStartMinutes,
    int stepMinutes = _slotDurationSeconds ~/ 60,
  }) {
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
    final normalizedStepMinutes = _normalizedDurationStepMinutes(stepMinutes);
    final currentDurationMinutes = end - currentStart;
    final minimumDurationMinutes =
        currentDurationMinutes < normalizedStepMinutes
        ? currentDurationMinutes
        : normalizedStepMinutes;
    final maxStart = end - minimumDurationMinutes;
    if (lowerBound > maxStart) {
      return;
    }
    final requestedStepCount =
        ((startMinutes - currentStart) / normalizedStepMinutes).round();
    final requestedStart =
        currentStart + (requestedStepCount * normalizedStepMinutes);
    final snappedStart = requestedStart.clamp(lowerBound, maxStart).toInt();
    if (snappedStart == currentStart) {
      return;
    }

    final nextDuration = (end - snappedStart) * 60;
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
    _syncAfterScheduleMutation(activeBoxChanged: updatingActiveBox);
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

  /// 선택형 가져오기 시트가 사용하는 가장 최근 과거 플랜 스냅샷.
  /// doc: docs/architecture/DATA_LIFECYCLE.md
  Future<Pomodoro?> loadPreviousPlanSnapshot() {
    return loadPreviousPlanUseCase(state);
  }

  /// 특정 날짜 키(yyyy-MM-dd)의 저장된 플랜 전체를 조회한다(읽기 전용).
  Future<Pomodoro?> loadPlanSnapshotForDate(String dateKey) {
    return loadPlanForDateUseCase(dateKey, Pomodoro.initial());
  }

  /// 최근 날짜부터 역순으로 조회해 중복되지 않는 타임박스를 최대 [limit]개
  /// 반환한다. 오늘 일정은 제외하고 제목+시간대가 같은 카드는 한 번만 보인다.
  Future<List<TimeBox>> loadRecentTimeBoxes({
    int limit = 20,
    int days = 30,
  }) async {
    if (limit <= 0 || days <= 0) {
      return const [];
    }

    final summaries = await repository.loadDailyPlanHistory(days: days);
    final todayKey = _dateKey(DateTime.now());
    final dateKeys =
        summaries
            .map((summary) => summary.dateKey)
            .where((dateKey) => dateKey.compareTo(todayKey) < 0)
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));
    final recent = <TimeBox>[];
    final seen = <String>{};

    for (final dateKey in dateKeys) {
      final plan = await repository.loadPlanForDate(
        dateKey,
        Pomodoro.initial(),
      );
      if (plan == null) {
        continue;
      }
      final boxes = [...plan.timeBoxes]
        ..sort((a, b) {
          final startA = a.startMinutes ?? -1;
          final startB = b.startMinutes ?? -1;
          return startB.compareTo(startA);
        });
      for (final box in boxes) {
        final fingerprint = '${box.timeRange}.${box.title.trim()}';
        if (!seen.add(fingerprint)) {
          continue;
        }
        recent.add(box);
        if (recent.length >= limit) {
          return recent;
        }
      }
    }
    return recent;
  }

  /// 선택형 가져오기: 텍스트 항목들을 카테고리 규칙에 맞게 병합한다.
  /// 우선순위는 빈 슬롯 채움(최대 3개), 덤프/기억할 것은 중복 없는 병합.
  bool importDailyPlanItems(
    DailyPlanItemCategory category,
    List<String> items,
  ) {
    final incoming = items
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (incoming.isEmpty) {
      return false;
    }

    switch (category) {
      case DailyPlanItemCategory.topPriority:
        final priorities = List<String>.from(state.topPriorities.take(3));
        while (priorities.length < 3) {
          priorities.add('');
        }
        var sourceIndex = 0;
        var changed = false;
        for (var index = 0; index < priorities.length; index += 1) {
          if (priorities[index].trim().isNotEmpty ||
              sourceIndex >= incoming.length) {
            continue;
          }
          priorities[index] = incoming[sourceIndex];
          sourceIndex += 1;
          changed = true;
        }
        if (!changed) {
          return false;
        }
        state = state.copyWith(topPriorities: priorities.take(3).toList());
      case DailyPlanItemCategory.brainDump:
        final merged = _mergedTextList(state.brainDump, incoming);
        if (merged.length == state.brainDump.length) {
          return false;
        }
        state = state.copyWith(brainDump: merged);
      case DailyPlanItemCategory.reminder:
        final merged = _mergedTextList(state.reminders, incoming);
        if (merged.length == state.reminders.length) {
          return false;
        }
        state = state.copyWith(reminders: merged);
    }
    repository.updatePomodoro(state);
    return true;
  }

  /// 선택한 타임박스들을 시간대·제목 지문 기준 중복 없이 복제 추가한다.
  bool importTimeBoxes(List<TimeBox> boxes) {
    if (boxes.isEmpty) {
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
      final copiedId = _copiedTimeBoxId(box.id);
      final copied = box.copyWith(
        id: copiedId,
        recurrenceId: box.repeatWeekdays.isEmpty
            ? ''
            : 'recurrence-${DateTime.now().microsecondsSinceEpoch}-${nextBoxes.length}',
      );
      if (_timeBoxOverlapsAny(nextBoxes, box: copied, ignoreId: copied.id)) {
        continue;
      }
      nextBoxes.add(copied);
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
    if (!_initialRestoreCompleted) {
      return;
    }
    if (state.phase != PomodoroPhase.focus) {
      return;
    }

    final currentBox = _currentTimeBoxForNow();
    if (state.status == PomodoroStatus.running && state.autoStartFocus) {
      if (currentBox == null) {
        unawaited(_stopTrackedTimerOutsideSchedule());
        return;
      }

      final scheduleChanged =
          state.activeTimeBoxId != currentBox.id ||
          state.currentTimeBoxTitle != _titleForTimeBox(currentBox) ||
          state.currentTimeBoxTimeRange != currentBox.timeRange ||
          state.workDuration != currentBox.durationSeconds;
      if (scheduleChanged) {
        unawaited(_restartRunningTrackedTimer(box: currentBox));
      }
      return;
    }

    if (state.status != PomodoroStatus.idle) {
      return;
    }

    if (currentBox != null) {
      // 다른 박스로 넘어가면 이전 박스의 정지(스킵) 선택은 해제한다.
      if (_skippedAutoStartBoxId.isNotEmpty &&
          _skippedAutoStartBoxId != currentBox.id) {
        _skippedAutoStartBoxId = '';
      }
      _applyClockSyncedTimeBox(
        currentBox,
        _clockRemainingForTimeBox(currentBox),
      );
      if (state.autoStartFocus &&
          state.canStartFocus &&
          currentBox.id != _skippedAutoStartBoxId) {
        unawaited(_scheduledAutoStart.run(_startScheduledTimeBox));
      }
      return;
    }

    _clearClockSyncedTimeBox();
  }

  void _syncAfterScheduleMutation({required bool activeBoxChanged}) {
    if (activeBoxChanged && state.status == PomodoroStatus.running) {
      unawaited(_restartRunningTrackedTimer());
      return;
    }
    syncFocusWithClock();
  }

  Future<void> _restartRunningTrackedTimer({TimeBox? box}) async {
    final currentBox = box ?? _currentTimeBoxForNow();
    if (currentBox == null ||
        state.status != PomodoroStatus.running ||
        state.phase != PomodoroPhase.focus) {
      return;
    }

    final clockRemaining = _clockRemainingForTimeBox(currentBox);
    if (clockRemaining <= 0) {
      await _stopTrackedTimerOutsideSchedule();
      return;
    }

    state = state.copyWith(
      activeTimeBoxId: currentBox.id,
      currentTimeBoxTitle: _titleForTimeBox(currentBox),
      currentTimeBoxTimeRange: currentBox.timeRange,
      workDuration: currentBox.durationSeconds,
      remainingTime: _focusSegmentRemaining(clockRemaining),
      status: PomodoroStatus.running,
      phase: PomodoroPhase.focus,
    );
    repository.updatePomodoro(state);

    await _timerSubscription?.cancel();
    _timerSubscription = _startNativeTimer(_nativeCopy);
  }

  Future<void> _stopTrackedTimerOutsideSchedule() async {
    if (state.status != PomodoroStatus.running || !state.autoStartFocus) {
      return;
    }
    await _timerSubscription?.cancel();
    _timerSubscription = null;
    await repository.stopTimer();
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
    if (state.activeTimeBoxId == _skippedAutoStartBoxId &&
        _skippedAutoStartBoxId.isNotEmpty) {
      return;
    }

    if (_startSlotBreakIfInWindow(
      boxRemaining: state.remainingTime,
      autoOrigin: true,
    )) {
      return;
    }

    _activeSessionAutoStarted = true;
    state = state.copyWith(
      status: PomodoroStatus.running,
      remainingTime: _focusSegmentRemaining(state.remainingTime),
    );
    repository.updatePomodoro(state);
    await _timerSubscription?.cancel();
    _timerSubscription = _startNativeTimer(_nativeCopy);
    _recordTimerBreadcrumb('scheduled_focus_started');
  }

  /// 슬롯 휴식 정책(설정 기반). 간격별 휴식 길이는
  /// [slotBreakMinutesForInterval]을 따른다.
  ({bool enabled, int intervalMinutes, int breakMinutes}) get _slotBreakPolicy {
    final preferences = ref.read(appPreferencesControllerProvider);
    final intervalMinutes = preferences.timeSlotInterval.minutes;
    return (
      enabled: preferences.slotBreakEnabled,
      intervalMinutes: intervalMinutes,
      breakMinutes: slotBreakMinutesForInterval(intervalMinutes),
    );
  }

  int _nowSecondsOfDay() {
    final now = _now();
    return (now.hour * 3600) + (now.minute * 60) + now.second;
  }

  /// 지금이 슬롯 휴식 창 안이고 박스가 그 뒤로도 이어지면
  /// 집중 대신 휴식 세그먼트를 시작한다. 시작했으면 true.
  bool _startSlotBreakIfInWindow({
    required int boxRemaining,
    required bool autoOrigin,
  }) {
    final policy = _slotBreakPolicy;
    if (!policy.enabled || state.activeTimeBoxId.isEmpty || boxRemaining <= 0) {
      return false;
    }

    final window = slotBreakWindow(
      _nowSecondsOfDay(),
      policy.intervalMinutes,
      policy.breakMinutes,
    );
    // 세그먼트 완료 시점의 1~2초 오차를 흡수한다.
    if (window.secondsToBreakStart > 2 || window.secondsToBoundary <= 0) {
      return false;
    }
    // 박스가 휴식 창이 끝나기 전에 끝나면 휴식 없이 박스를 마저 소화한다.
    if (window.secondsToBoundary >= boxRemaining) {
      return false;
    }

    _slotBreakBoxId = state.activeTimeBoxId;
    _activeSessionAutoStarted = autoOrigin;
    state = state.copyWith(
      phase: PomodoroPhase.shortBreak,
      status: PomodoroStatus.running,
      remainingTime: window.secondsToBoundary,
    );
    repository.updatePomodoro(state);
    _timerSubscription?.cancel();
    _timerSubscription = _startNativeTimer(_nativeCopy);
    return true;
  }

  /// 슬롯 휴식이 켜져 있으면 집중 세그먼트를 다음 휴식 시작까지로 자른다.
  int _focusSegmentRemaining(int fullRemaining) {
    final policy = _slotBreakPolicy;
    if (!policy.enabled || fullRemaining <= 0) {
      return fullRemaining;
    }

    final window = slotBreakWindow(
      _nowSecondsOfDay(),
      policy.intervalMinutes,
      policy.breakMinutes,
    );
    if (window.secondsToBreakStart <= 2) {
      return fullRemaining;
    }
    return window.secondsToBreakStart < fullRemaining
        ? window.secondsToBreakStart
        : fullRemaining;
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
      return rangeDuration.clamp(60, 24 * 60 * 60);
    }
    return box.durationSeconds.clamp(60, 24 * 60 * 60);
  }

  int _normalizedDurationSeconds(
    int durationSeconds, {
    int stepMinutes = _slotDurationSeconds ~/ 60,
  }) {
    final normalizedStepMinutes = _normalizedDurationStepMinutes(stepMinutes);
    final stepSeconds = normalizedStepMinutes * 60;
    final maximumSlotCount = (24 * 60) ~/ normalizedStepMinutes;
    final slotCount = (durationSeconds / stepSeconds)
        .round()
        .clamp(1, maximumSlotCount)
        .toInt();
    return slotCount * stepSeconds;
  }

  int _normalizedDurationStepMinutes(int stepMinutes) {
    return switch (stepMinutes) {
      15 || 30 || 60 => stepMinutes,
      _ => _slotDurationSeconds ~/ 60,
    };
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
    _recordTimerBreadcrumb('timer_segment_completed');

    if (state.phase == PomodoroPhase.focus) {
      // 슬롯 휴식: 박스가 아직 안 끝났으면 세션 완료가 아니라
      // 휴식 세그먼트로 전환한다.
      final activeBox = _timeBoxById(state.activeTimeBoxId);
      if (activeBox != null &&
          _startSlotBreakIfInWindow(
            boxRemaining: _clockRemainingForTimeBox(activeBox),
            autoOrigin: _activeSessionAutoStarted,
          )) {
        return;
      }

      final completedSessions = state.completedSessions + 1;
      state = _stateAfterCompletedTodayBox(completedSessions);
      repository.updatePomodoro(state);

      if (state.autoStartFocus &&
          state.remainingTime > 0 &&
          state.activeTimeBoxId != _skippedAutoStartBoxId) {
        _activeSessionAutoStarted = true;
        state = state.copyWith(
          status: PomodoroStatus.running,
          remainingTime: _focusSegmentRemaining(state.remainingTime),
        );
        repository.updatePomodoro(state);
        _timerSubscription = _startNativeTimer(_nativeCopy);
      }
      return;
    }

    // 휴식 완료: 슬롯 휴식이었다면 같은 박스의 다음 집중 세그먼트로 복귀한다.
    final resumeBoxId = _slotBreakBoxId;
    _slotBreakBoxId = '';
    if (resumeBoxId.isNotEmpty) {
      final box = _timeBoxById(resumeBoxId);
      final boxRemaining = box == null ? 0 : _clockRemainingForTimeBox(box);
      if (box != null && boxRemaining > 0) {
        state = state.copyWith(
          phase: PomodoroPhase.focus,
          status: PomodoroStatus.running,
          activeTimeBoxId: box.id,
          currentTimeBoxTitle: _titleForTimeBox(box),
          currentTimeBoxTimeRange: box.timeRange,
          workDuration: box.durationSeconds,
          remainingTime: _focusSegmentRemaining(boxRemaining),
        );
        repository.updatePomodoro(state);
        _timerSubscription = _startNativeTimer(_nativeCopy);
        return;
      }
    }

    state = _stateAfterCompletedTodayBox(state.completedSessions);
    repository.updatePomodoro(state);
  }

  TimeBox? _timeBoxById(String id) {
    if (id.isEmpty) {
      return null;
    }
    for (final box in state.timeBoxes) {
      if (box.id == id) {
        return box;
      }
    }
    return null;
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
