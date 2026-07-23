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
    var restored = await _restoreTodayPlan(fallback);
    restored = await _applyRecurringBoxesOncePerDay(restored);
    _restoreCompleted = true;
    return restored;
  }

  /// 요일 반복 타임박스를 하루 한 번 오늘 플랜에 주입한다.
  ///
  /// 로그인/오프라인 여부, 오늘 플랜에 이미 콘텐츠가 있는지와 무관하게
  /// 동작한다. 최근 7일의 저장된 플랜에서 오늘 요일에 반복되는 박스를
  /// 수집해 시간대·제목 지문 중복 없이 병합한다. 하루 한 번만 실행되므로
  /// 사용자가 같은 날 지운 반복 인스턴스는 되살아나지 않는다.
  /// doc: docs/product/TIMEBOXING_STRATEGY.md
  Future<Pomodoro> _applyRecurringBoxesOncePerDay(Pomodoro todayPlan) async {
    final now = DateTime.now();
    final todayKey = _dateKey(now);
    final appliedKey = await localDataSource.loadRecurringAppliedDateKey();
    if (appliedKey == todayKey) {
      return todayPlan;
    }

    final weekday = now.weekday;
    final fingerprints = todayPlan.timeBoxes
        .map((box) => '${box.timeRange}.${box.title.trim()}')
        .toSet();
    final additions = <TimeBox>[];
    for (var back = 1; back <= 7; back += 1) {
      final dateKey = _dateKey(now.subtract(Duration(days: back)));
      final plan = await loadPlanForDate(dateKey, Pomodoro.initial());
      if (plan == null) {
        continue;
      }
      for (final box in plan.timeBoxes) {
        if (!box.repeatsOn(weekday)) {
          continue;
        }
        final fingerprint = '${box.timeRange}.${box.title.trim()}';
        if (fingerprints.contains(fingerprint)) {
          continue;
        }
        fingerprints.add(fingerprint);
        additions.add(
          box.copyWith(
            id:
                'box-${now.microsecondsSinceEpoch}'
                '-recurring-${additions.length}',
          ),
        );
      }
    }

    await localDataSource.saveRecurringAppliedDateKey(todayKey);
    if (additions.isEmpty) {
      return todayPlan;
    }

    final boxes = [...todayPlan.timeBoxes, ...additions]
      ..sort((a, b) {
        final startA = a.startMinutes ?? (24 * 60);
        final startB = b.startMinutes ?? (24 * 60);
        return startA.compareTo(startB);
      });
    final merged = todayPlan.copyWith(timeBoxes: boxes);
    await _persistResolvedPlan(
      merged,
      _nextUpdatedAtEpochMs(),
      writeCloud: true,
    );
    return merged;
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
      // 반복 타임박스 주입은 _applyRecurringBoxesOncePerDay가 모든 복원
      // 경로에서 공통으로 수행한다.
      await _persistResolvedPlan(
        localPlan,
        _nextUpdatedAtEpochMs(),
        writeCloud: true,
      );
      return localPlan;
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
  Future<Pomodoro?> loadPlanForDate(String dateKey, Pomodoro fallback) async {
    final localPlan = await localDataSource.loadPlanForDate(dateKey, fallback);
    if (localPlan != null) {
      return localPlan;
    }
    return cloudDataSource.loadPlanForDate(dateKey, fallback);
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
