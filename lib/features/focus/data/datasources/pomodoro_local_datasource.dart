import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/daily_plan_summary.dart';
import '../../domain/entities/pomodoro.dart';
import '../../domain/entities/native_timer_copy.dart';
import '../dtos/native_timer_copy_dto.dart';
import '../dtos/native_timer_state_dto.dart';
import '../dtos/today_plan_dto.dart';
import 'pomodoro_platform_channel.dart';

class PomodoroLocalDataSource {
  static const _todayPlanKeyPrefix = 'today.plan.';
  static const _todayPlanKeysKey = 'today.plan.keys';

  Pomodoro _currentPomodoro = Pomodoro.initial();
  String? _lastPersistedPlanJson;
  bool _lastRestoreFoundTodayPlan = false;
  Future<void> _persistQueue = Future.value();

  // 네이티브 onTick을 UI로 흘리는 단일 통로 (진실의 원천 = 네이티브 타이머)
  final StreamController<int> _tickController =
      StreamController<int>.broadcast();

  PomodoroLocalDataSource() {
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
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey(todayKey));
    if (encoded == null || encoded.isEmpty) {
      _lastRestoreFoundTodayPlan = false;
      _lastPersistedPlanJson = null;
      return null;
    }

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic>) {
        _lastRestoreFoundTodayPlan = false;
        _lastPersistedPlanJson = null;
        return null;
      }

      var dto = TodayPlanDto.fromJson(decoded);
      if (dto.dateKey != todayKey) {
        _lastRestoreFoundTodayPlan = false;
        _lastPersistedPlanJson = null;
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
      _lastPersistedPlanJson = encoded;
      return dto;
    } catch (_) {
      _lastRestoreFoundTodayPlan = false;
      _lastPersistedPlanJson = null;
      return null;
    }
  }

  Future<List<DailyPlanSummary>> loadDailyPlanHistory({int days = 7}) async {
    final preferences = await SharedPreferences.getInstance();
    final indexedKeys = preferences.getStringList(_todayPlanKeysKey) ?? [];
    final requestedKeys = _recentDateKeys(DateTime.now(), days).toSet();
    final summaries = <DailyPlanSummary>[];

    for (final dateKey in indexedKeys.where(requestedKeys.contains)) {
      final encoded = preferences.getString(_storageKey(dateKey));
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
    final preferences = await SharedPreferences.getInstance();
    final todayKey = _dateKey(DateTime.now());
    final indexedKeys = preferences.getStringList(_todayPlanKeysKey) ?? [];
    final previousKeys =
        indexedKeys.where((dateKey) => dateKey.compareTo(todayKey) < 0).toList()
          ..sort((a, b) => b.compareTo(a));

    for (final dateKey in previousKeys) {
      final encoded = preferences.getString(_storageKey(dateKey));
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

  Future<NativeTimerStateDto> restoreState(Pomodoro fallback) async {
    final state = await PomodoroPlatformChannel.restoreState();
    return NativeTimerStateDto.fromPlatformMap(state, fallback: fallback);
  }

  void updatePomodoro(Pomodoro pomodoro, {int? updatedAtEpochMs}) {
    _currentPomodoro = pomodoro;
    final todayKey = _dateKey(DateTime.now());
    final dto = TodayPlanDto.fromEntity(
      pomodoro,
      dateKey: todayKey,
      updatedAtEpochMs:
          updatedAtEpochMs ?? DateTime.now().millisecondsSinceEpoch,
    );
    _persistQueue = _persistQueue.then((_) => _persistTodayPlan(dto));
  }

  Future<void> flushPendingWrites() => _persistQueue;

  Future<void> clearPlanData() async {
    await _persistQueue;
    final preferences = await SharedPreferences.getInstance();
    final indexedKeys = preferences.getStringList(_todayPlanKeysKey) ?? [];
    for (final dateKey in indexedKeys) {
      await preferences.remove(_storageKey(dateKey));
    }
    await preferences.remove(_todayPlanKeysKey);

    _currentPomodoro = Pomodoro.initial();
    _lastPersistedPlanJson = null;
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

  Future<void> _persistTodayPlan(TodayPlanDto dto) async {
    final encoded = jsonEncode(dto.toStorageJson());
    if (encoded == _lastPersistedPlanJson) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey(dto.dateKey), encoded);
    await _indexDateKey(preferences, dto.dateKey);
    _lastPersistedPlanJson = encoded;
  }

  String _storageKey(String dateKey) => '$_todayPlanKeyPrefix$dateKey';

  Future<void> _indexDateKey(
    SharedPreferences preferences,
    String dateKey,
  ) async {
    final keys = preferences.getStringList(_todayPlanKeysKey) ?? [];
    final nextKeys = <String>{...keys, dateKey}.toList()..sort();
    if (nextKeys.length > 60) {
      nextKeys.removeRange(0, nextKeys.length - 60);
    }
    await preferences.setStringList(_todayPlanKeysKey, nextKeys);
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
}
