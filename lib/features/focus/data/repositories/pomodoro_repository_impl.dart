import '../../domain/entities/pomodoro.dart';
import '../../domain/entities/native_timer_copy.dart';
import '../../domain/entities/daily_plan_summary.dart';
import '../../domain/repositories/pomodoro_repository.dart';
import '../datasources/pomodoro_cloud_datasource.dart';
import '../datasources/pomodoro_local_datasource.dart';
import '../dtos/today_plan_dto.dart';

class PomodoroRepositoryImpl implements PomodoroRepository {
  final PomodoroLocalDataSource localDataSource;
  final PomodoroCloudDataSource cloudDataSource;
  Future<void> _cloudWriteQueue = Future.value();
  String? _lastContentSignature;
  int _lastUpdatedAtEpochMs = 0;
  bool _restoreCompleted = false;

  PomodoroRepositoryImpl(this.localDataSource, this.cloudDataSource);

  @override
  Pomodoro getPomodoro() => localDataSource.getPomodoro();

  @override
  void updatePomodoro(Pomodoro pomodoro) {
    if (!_restoreCompleted) {
      return;
    }

    final dto = TodayPlanDto.fromEntity(
      pomodoro,
      dateKey: _dateKey(DateTime.now()),
    );
    final signature = dto.contentSignature();
    final contentChanged = signature != _lastContentSignature;
    if (contentChanged) {
      _lastContentSignature = signature;
      _lastUpdatedAtEpochMs = _nextUpdatedAtEpochMs();
    }

    localDataSource.updatePomodoro(
      pomodoro,
      updatedAtEpochMs: _lastUpdatedAtEpochMs,
    );
    if (contentChanged) {
      _enqueueCloudSave(
        pomodoro,
        _lastUpdatedAtEpochMs,
        cloudDataSource.currentUserId,
      );
    }
  }

  @override
  Future<void> flushPendingWrites() async {
    await localDataSource.flushPendingWrites();
    await _cloudWriteQueue;
  }

  @override
  Future<void> clearLocalPlanData() async {
    await localDataSource.stopTimer();
    await flushPendingWrites();
    await localDataSource.clearPlanData();
    _lastContentSignature = null;
    _lastUpdatedAtEpochMs = 0;
  }

  @override
  Future<Pomodoro> restoreTodayPlan(Pomodoro fallback) async {
    final restored = await _restoreTodayPlan(fallback);
    _restoreCompleted = true;
    return restored;
  }

  Future<Pomodoro> _restoreTodayPlan(Pomodoro fallback) async {
    var localDto = await localDataSource.loadTodayPlanDto();
    final localPlan = localDto?.toEntity(fallback) ?? fallback;
    final cloudResult = await cloudDataSource.loadTodayPlanResult();
    final cloudDto = cloudResult.plan;
    final refreshedLocalDto = await localDataSource.loadTodayPlanDto();
    if (refreshedLocalDto != null &&
        (localDto == null ||
            refreshedLocalDto.updatedAtEpochMs > localDto.updatedAtEpochMs)) {
      localDto = refreshedLocalDto;
    }
    final resolvedLocalPlan = localDto?.toEntity(fallback) ?? localPlan;
    if (cloudResult.status == CloudTodayPlanStatus.unauthenticated ||
        cloudResult.status == CloudTodayPlanStatus.unavailable) {
      if (localDto == null) {
        return fallback;
      }
      await _persistResolvedPlan(
        resolvedLocalPlan,
        _normalizedUpdatedAt(localDto),
      );
      return resolvedLocalPlan;
    }

    if (localDto == null && cloudDto == null) {
      final restoredPlan = await _planForNewDay(
        localPlan,
        localHadTodayPlan: false,
      );
      await _persistResolvedPlan(
        restoredPlan,
        _nextUpdatedAtEpochMs(),
        writeCloud: true,
      );
      return restoredPlan;
    }

    if (cloudDto == null) {
      final updatedAt = _normalizedUpdatedAt(localDto!);
      await _persistResolvedPlan(
        resolvedLocalPlan,
        updatedAt,
        writeCloud: true,
      );
      return resolvedLocalPlan;
    }

    if (localDto == null) {
      final cloudPlan = cloudDto.toEntity(fallback);
      await _persistResolvedPlan(cloudPlan, _normalizedUpdatedAt(cloudDto));
      return cloudPlan;
    }

    final localWins = _localPlanWins(
      localDto,
      cloudDto,
      resolvedLocalPlan,
      fallback,
    );
    final winnerDto = localWins ? localDto : cloudDto;
    final winnerPlan = winnerDto.toEntity(fallback);
    await _persistResolvedPlan(
      winnerPlan,
      _normalizedUpdatedAt(winnerDto),
      writeCloud: localWins,
    );
    return winnerPlan;
  }

  @override
  Future<Pomodoro?> loadPreviousPlan(Pomodoro fallback) async {
    final cloudPlan = await cloudDataSource.loadPreviousPlan(fallback);
    if (cloudPlan != null) {
      return cloudPlan;
    }
    return localDataSource.loadPreviousPlan(fallback);
  }

  @override
  Future<List<DailyPlanSummary>> loadDailyPlanHistory({int days = 7}) async {
    final localHistory = await localDataSource.loadDailyPlanHistory(days: days);
    final cloudHistory = await cloudDataSource.loadDailyPlanHistory(days: days);
    final summariesByDate = <String, DailyPlanSummary>{
      for (final summary in localHistory) summary.dateKey: summary,
      for (final summary in cloudHistory) summary.dateKey: summary,
    };
    final summaries = summariesByDate.values.toList()
      ..sort((a, b) => a.dateKey.compareTo(b.dateKey));
    return summaries;
  }

  @override
  Stream<int> startTimer({
    required String phase,
    required bool notificationsEnabled,
    required bool soundEnabled,
    required List<String> topPriorities,
    required String currentTimeBoxTitle,
    required String currentTimeBoxTimeRange,
    required NativeTimerCopy nativeCopy,
  }) => localDataSource.startTimer(
    phase: phase,
    notificationsEnabled: notificationsEnabled,
    soundEnabled: soundEnabled,
    topPriorities: topPriorities,
    currentTimeBoxTitle: currentTimeBoxTitle,
    currentTimeBoxTimeRange: currentTimeBoxTimeRange,
    nativeCopy: nativeCopy,
  );

  @override
  Future<void> pauseTimer() => localDataSource.pauseTimer();

  @override
  Future<void> resumeTimer() => localDataSource.resumeTimer();

  @override
  Future<void> stopTimer() => localDataSource.stopTimer();

  @override
  Stream<int> ticks() => localDataSource.ticks();

  @override
  Future<TimerSnapshot> restoreState(Pomodoro fallback) async {
    final dto = await localDataSource.restoreState(fallback);
    return dto.toEntity();
  }

  @override
  Future<void> updateNotificationSettings({
    required bool notificationsEnabled,
    required bool soundEnabled,
  }) => localDataSource.updateNotificationSettings(
    notificationsEnabled: notificationsEnabled,
    soundEnabled: soundEnabled,
  );

  Future<Pomodoro> _planForNewDay(
    Pomodoro localPlan, {
    required bool localHadTodayPlan,
  }) async {
    if (localHadTodayPlan || _hasDailyContent(localPlan)) {
      return localPlan;
    }

    final previousPlan = await loadPreviousPlan(localPlan);
    if (previousPlan == null) {
      return localPlan;
    }

    final recurringBoxes = previousPlan.timeBoxes
        .where((box) => box.repeatsOn(DateTime.now().weekday))
        .toList();
    if (recurringBoxes.isEmpty) {
      return localPlan;
    }

    return localPlan.copyWith(
      brainDump: const [],
      reminders: const [],
      topPriorities: const ['', '', ''],
      timeBoxes: recurringBoxes,
      activeTimeBoxId: '',
      currentTimeBoxTitle: '',
      currentTimeBoxTimeRange: '',
      remainingTime: 0,
      completedSessions: 0,
      status: PomodoroStatus.idle,
      phase: PomodoroPhase.focus,
    );
  }

  bool _hasDailyContent(Pomodoro pomodoro) {
    return pomodoro.brainDump.isNotEmpty ||
        pomodoro.reminders.isNotEmpty ||
        pomodoro.topPriorities.any((priority) => priority.trim().isNotEmpty) ||
        pomodoro.timeBoxes.isNotEmpty ||
        pomodoro.completedSessions > 0;
  }

  bool _localPlanWins(
    TodayPlanDto localDto,
    TodayPlanDto cloudDto,
    Pomodoro localPlan,
    Pomodoro fallback,
  ) {
    if (localDto.contentSignature() == cloudDto.contentSignature()) {
      return localDto.updatedAtEpochMs >= cloudDto.updatedAtEpochMs;
    }
    if (localDto.updatedAtEpochMs > 0 || cloudDto.updatedAtEpochMs > 0) {
      return localDto.updatedAtEpochMs >= cloudDto.updatedAtEpochMs;
    }
    final cloudPlan = cloudDto.toEntity(fallback);
    return _hasDailyContent(localPlan) || !_hasDailyContent(cloudPlan);
  }

  Future<void> _persistResolvedPlan(
    Pomodoro plan,
    int updatedAtEpochMs, {
    bool writeCloud = false,
  }) async {
    final dto = TodayPlanDto.fromEntity(
      plan,
      dateKey: _dateKey(DateTime.now()),
      updatedAtEpochMs: updatedAtEpochMs,
    );
    _lastContentSignature = dto.contentSignature();
    _lastUpdatedAtEpochMs = updatedAtEpochMs;
    localDataSource.updatePomodoro(plan, updatedAtEpochMs: updatedAtEpochMs);
    await localDataSource.flushPendingWrites();
    if (writeCloud) {
      try {
        await cloudDataSource.saveTodayPlan(
          plan,
          updatedAtEpochMs: updatedAtEpochMs,
          expectedUserId: cloudDataSource.currentUserId,
        );
      } catch (_) {
        _enqueueCloudSave(
          plan,
          updatedAtEpochMs,
          cloudDataSource.currentUserId,
        );
      }
    }
  }

  void _enqueueCloudSave(
    Pomodoro plan,
    int updatedAtEpochMs,
    String? expectedUserId,
  ) {
    _cloudWriteQueue = _cloudWriteQueue
        .catchError((Object _) {})
        .then(
          (_) => cloudDataSource.saveTodayPlan(
            plan,
            updatedAtEpochMs: updatedAtEpochMs,
            expectedUserId: expectedUserId,
          ),
        )
        .catchError((Object _) {});
  }

  int _normalizedUpdatedAt(TodayPlanDto dto) {
    if (dto.updatedAtEpochMs > 0) {
      return dto.updatedAtEpochMs;
    }
    return _nextUpdatedAtEpochMs();
  }

  int _nextUpdatedAtEpochMs() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return now > _lastUpdatedAtEpochMs ? now : _lastUpdatedAtEpochMs + 1;
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
