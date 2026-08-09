import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/daily_plan_summary.dart';
import '../../domain/entities/pomodoro.dart';
import '../../domain/entities/native_timer_copy.dart';
import '../../domain/entities/live_activity_push_registration.dart';
import '../dtos/native_timer_copy_dto.dart';
import '../dtos/native_timer_state_dto.dart';
import '../dtos/today_plan_dto.dart';
import 'pomodoro_platform_channel.dart';

class PomodoroLocalDataSource {
  static const _todayPlanKeyPrefix = 'today.plan.';
  static const _legacyTodayPlanKeysKey = 'today.plan.keys';

  final String Function() _storageScope;
  Pomodoro _currentPomodoro = Pomodoro.initial();
  final Map<String, String> _lastPersistedPlanJsonByScope = {};
  final Set<String> _migratedScopes = {};
  bool _lastRestoreFoundTodayPlan = false;
  Future<void> _persistQueue = Future.value();

  // 네이티브 onTick을 UI로 흘리는 단일 통로 (진실의 원천 = 네이티브 타이머)
  final StreamController<int> _tickController =
      StreamController<int>.broadcast();

  PomodoroLocalDataSource({String Function()? storageScope})
    : _storageScope = storageScope ?? _defaultStorageScope {
    PomodoroPlatformChannel.setMethodCallHandler(
      (remainingTime) {
        _currentPomodoro = _currentPomodoro.copyWith(
          remainingTime: remainingTime,
        );
        _tickController.add(remainingTime);
      },
      () {
        // 완료: 0을 흘려 provider의 완료 처리를 트리거
        _currentPomodoro = _currentPomodoro.copyWith(remainingTime: 0);
        _tickController.add(0);
      },
    );
  }

  Pomodoro getPomodoro() => _currentPomodoro;

  bool get lastRestoreFoundTodayPlan => _lastRestoreFoundTodayPlan;

  /// 네이티브 tick 스트림 (startTimer 없이 구독만 — 상태 복원 시 사용)
  Stream<int> ticks() => _tickController.stream;

  Stream<LiveActivityPushRegistration> liveActivityRegistrations() =>
      PomodoroPlatformChannel.liveActivityRegistrations;

  Stream<String> endedLiveActivityIds() =>
      PomodoroPlatformChannel.endedLiveActivityIds;

  Future<void> syncLiveActivityPushTokens() =>
      PomodoroPlatformChannel.syncLiveActivityPushTokens();

  Future<Pomodoro> restoreTodayPlan(Pomodoro fallback) async {
    final dto = await loadTodayPlanDto();
    if (dto == null) {
      _currentPomodoro = fallback;
      return fallback;
    }

    final restored = dto.toEntity(fallback);
    _currentPomodoro = restored;
    return restored;
  }

  Future<TodayPlanDto?> loadTodayPlanDto() async {
    final todayKey = _dateKey(DateTime.now());
    final scope = _scopeKey;
    final preferences = await SharedPreferences.getInstance();
    await _migrateLegacyPlans(preferences, scope);
    final encoded = preferences.getString(_storageKey(scope, todayKey));
    if (encoded == null || encoded.isEmpty) {
      _lastRestoreFoundTodayPlan = false;
      _lastPersistedPlanJsonByScope.remove(scope);
      return null;
    }

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic>) {
        _lastRestoreFoundTodayPlan = false;
        _lastPersistedPlanJsonByScope.remove(scope);
        return null;
      }

      var dto = TodayPlanDto.fromJson(decoded);
      if (dto.dateKey != todayKey) {
        _lastRestoreFoundTodayPlan = false;
        _lastPersistedPlanJsonByScope.remove(scope);
        return null;
      }

      // Legacy local plans predate conflict metadata. Treat an existing local
      // plan as the newest source once, then persist the migrated timestamp.
      if (dto.updatedAtEpochMs <= 0) {
        dto = dto.copyWith(
          updatedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        );
      }

      _lastRestoreFoundTodayPlan = true;
      _lastPersistedPlanJsonByScope[scope] = encoded;
      return dto;
    } catch (_) {
      _lastRestoreFoundTodayPlan = false;
      _lastPersistedPlanJsonByScope.remove(scope);
      return null;
    }
  }

  Future<List<DailyPlanSummary>> loadDailyPlanHistory({int days = 7}) async {
    final scope = _scopeKey;
    final preferences = await SharedPreferences.getInstance();
    await _migrateLegacyPlans(preferences, scope);
    final indexedKeys = preferences.getStringList(_dateIndexKey(scope)) ?? [];
    final requestedKeys = _recentDateKeys(DateTime.now(), days).toSet();
    final summaries = <DailyPlanSummary>[];

    for (final dateKey in indexedKeys.where(requestedKeys.contains)) {
      final encoded = preferences.getString(_storageKey(scope, dateKey));
      if (encoded == null || encoded.isEmpty) {
        continue;
      }

      try {
        final decoded = jsonDecode(encoded);
        if (decoded is Map<String, dynamic>) {
          summaries.add(TodayPlanDto.fromJson(decoded).toSummary());
        }
      } catch (_) {
        continue;
      }
    }

    summaries.sort((a, b) => a.dateKey.compareTo(b.dateKey));
    return summaries;
  }

  Future<Pomodoro?> loadPreviousPlan(Pomodoro fallback) async {
    final scope = _scopeKey;
    final preferences = await SharedPreferences.getInstance();
    await _migrateLegacyPlans(preferences, scope);
    final todayKey = _dateKey(DateTime.now());
    final indexedKeys = preferences.getStringList(_dateIndexKey(scope)) ?? [];
    final previousKeys =
        indexedKeys.where((dateKey) => dateKey.compareTo(todayKey) < 0).toList()
          ..sort((a, b) => b.compareTo(a));

    for (final dateKey in previousKeys) {
      final encoded = preferences.getString(_storageKey(scope, dateKey));
      if (encoded == null || encoded.isEmpty) {
        continue;
      }

      try {
        final decoded = jsonDecode(encoded);
        if (decoded is Map<String, dynamic>) {
          return TodayPlanDto.fromJson(decoded).toEntity(fallback);
        }
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  /// 오늘 반복 타임박스 주입이 이미 실행된 날짜 키를 반환한다.
  /// 하루 한 번만 주입해, 사용자가 지운 당일 인스턴스가 같은 날
  /// 다시 살아나는 것을 막는다.
  Future<String?> loadRecurringAppliedDateKey() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_recurringAppliedKey(_scopeKey));
  }

  Future<void> saveRecurringAppliedDateKey(String dateKey) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_recurringAppliedKey(_scopeKey), dateKey);
  }

  String _recurringAppliedKey(String scope) => 'today.recurring.applied.$scope';

  /// 특정 날짜 키(yyyy-MM-dd)의 저장된 플랜 원문을 반환한다.
  /// doc: docs/architecture/DATA_LIFECYCLE.md
  Future<Pomodoro?> loadPlanForDate(String dateKey, Pomodoro fallback) async {
    final scope = _scopeKey;
    final preferences = await SharedPreferences.getInstance();
    await _migrateLegacyPlans(preferences, scope);
    final encoded = preferences.getString(_storageKey(scope, dateKey));
    if (encoded == null || encoded.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is Map<String, dynamic>) {
        return TodayPlanDto.fromJson(decoded).toEntity(fallback);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<NativeTimerStateDto> restoreState(Pomodoro fallback) async {
    final state = await PomodoroPlatformChannel.restoreState();
    return NativeTimerStateDto.fromPlatformMap(state, fallback: fallback);
  }

  void updatePomodoro(Pomodoro pomodoro, {int? updatedAtEpochMs}) {
    _currentPomodoro = pomodoro;
    unawaited(PomodoroPlatformChannel.syncAndroidSchedule(pomodoro));
    final scope = _scopeKey;
    final todayKey = _dateKey(DateTime.now());
    final dto = TodayPlanDto.fromEntity(
      pomodoro,
      dateKey: todayKey,
      updatedAtEpochMs:
          updatedAtEpochMs ?? DateTime.now().millisecondsSinceEpoch,
    );
    _persistQueue = _persistQueue.then((_) => _persistTodayPlan(dto, scope));
  }

  Future<void> flushPendingWrites() => _persistQueue;

  Future<void> clearPlanData() async {
    await _persistQueue;
    final scope = _scopeKey;
    final preferences = await SharedPreferences.getInstance();
    final indexedKeys = preferences.getStringList(_dateIndexKey(scope)) ?? [];
    for (final dateKey in indexedKeys) {
      await preferences.remove(_storageKey(scope, dateKey));
    }
    await preferences.remove(_dateIndexKey(scope));

    _currentPomodoro = Pomodoro.initial();
    unawaited(PomodoroPlatformChannel.syncAndroidSchedule(_currentPomodoro));
    _lastPersistedPlanJsonByScope.remove(scope);
    _lastRestoreFoundTodayPlan = false;
    _persistQueue = Future.value();
  }

  Stream<int> startTimer({
    required String phase,
    required bool notificationsEnabled,
    required bool soundEnabled,
    required List<String> topPriorities,
    required String currentTimeBoxTitle,
    required String currentTimeBoxTimeRange,
    required NativeTimerCopy nativeCopy,
  }) async* {
    final nativeCopyDto = NativeTimerCopyDto(nativeCopy);

    // 네이티브 타이머 시작 (Live Activity 포함)
    await PomodoroPlatformChannel.startTimer(
      _currentPomodoro.remainingTime,
      sessionCount: _currentPomodoro.completedSessions,
      sessionGoal: _currentPomodoro.sessionsUntilLongBreak,
      phase: phase,
      notificationsEnabled: notificationsEnabled,
      soundEnabled: soundEnabled,
      topPriorities: topPriorities,
      currentTimeBoxTitle: currentTimeBoxTitle,
      currentTimeBoxTimeRange: currentTimeBoxTimeRange,
      localizedCopy: nativeCopyDto.toPlatformMap(),
    );

    // 이후의 모든 tick은 네이티브 onTick에서 공급됨
    yield* _tickController.stream;
  }

  Future<void> pauseTimer() async {
    await PomodoroPlatformChannel.pauseTimer();
  }

  Future<void> resumeTimer() async {
    await PomodoroPlatformChannel.resumeTimer();
  }

  Future<void> stopTimer() async {
    await PomodoroPlatformChannel.stopTimer();
  }

  Future<void> updateNotificationSettings({
    required bool notificationsEnabled,
    required bool soundEnabled,
  }) async {
    await PomodoroPlatformChannel.updateNotificationSettings(
      notificationsEnabled: notificationsEnabled,
      soundEnabled: soundEnabled,
    );
  }

  Future<void> _persistTodayPlan(TodayPlanDto dto, String scope) async {
    final encoded = jsonEncode(dto.toStorageJson());
    if (encoded == _lastPersistedPlanJsonByScope[scope]) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    await _migrateLegacyPlans(preferences, scope);
    await preferences.setString(_storageKey(scope, dto.dateKey), encoded);
    await _indexDateKey(preferences, scope, dto.dateKey);
    _lastPersistedPlanJsonByScope[scope] = encoded;
  }

  String get _scopeKey => Uri.encodeComponent(_storageScope().trim());

  String _dateIndexKey(String scope) => '$_legacyTodayPlanKeysKey.$scope';

  String _storageKey(String scope, String dateKey) =>
      '$_todayPlanKeyPrefix$scope.$dateKey';

  String _legacyStorageKey(String dateKey) => '$_todayPlanKeyPrefix$dateKey';

  Future<void> _migrateLegacyPlans(
    SharedPreferences preferences,
    String scope,
  ) async {
    if (_migratedScopes.contains(scope) || scope == 'signed-out') {
      return;
    }

    final legacyDateKeys =
        preferences.getStringList(_legacyTodayPlanKeysKey) ?? const <String>[];
    if (legacyDateKeys.isEmpty) {
      _migratedScopes.add(scope);
      return;
    }

    final scopedDateKeys =
        preferences.getStringList(_dateIndexKey(scope))?.toSet() ?? <String>{};
    for (final dateKey in legacyDateKeys) {
      final legacyPlan = preferences.getString(_legacyStorageKey(dateKey));
      if (legacyPlan == null || legacyPlan.isEmpty) {
        continue;
      }
      final scopedKey = _storageKey(scope, dateKey);
      if (!preferences.containsKey(scopedKey)) {
        await preferences.setString(scopedKey, legacyPlan);
      }
      scopedDateKeys.add(dateKey);
      await preferences.remove(_legacyStorageKey(dateKey));
    }

    final sortedDateKeys = scopedDateKeys.toList()..sort();
    await preferences.setStringList(_dateIndexKey(scope), sortedDateKeys);
    await preferences.remove(_legacyTodayPlanKeysKey);
    _migratedScopes.add(scope);
  }

  Future<void> _indexDateKey(
    SharedPreferences preferences,
    String scope,
    String dateKey,
  ) async {
    final keys = preferences.getStringList(_dateIndexKey(scope)) ?? [];
    final nextKeys = <String>{...keys, dateKey}.toList()..sort();
    if (nextKeys.length > 60) {
      nextKeys.removeRange(0, nextKeys.length - 60);
    }
    await preferences.setStringList(_dateIndexKey(scope), nextKeys);
  }

  List<String> _recentDateKeys(DateTime endDate, int days) {
    final safeDays = days < 1 ? 1 : days;
    return List.generate(safeDays, (index) {
      final date = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
      ).subtract(Duration(days: safeDays - index - 1));
      return _dateKey(date);
    });
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String _defaultStorageScope() => 'default';
}
