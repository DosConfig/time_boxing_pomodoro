import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/pomodoro.dart';

part 'native_timer_state_dto.freezed.dart';
part 'native_timer_state_dto.g.dart';

@freezed
abstract class NativeTimerStateDto with _$NativeTimerStateDto {
  const NativeTimerStateDto._();

  const factory NativeTimerStateDto({
    @Default('idle') String status,
    @Default(0) int sessionCount,
    @Default(5) int sessionGoal,
    @Default('focus') String phase,
    @Default(25 * 60) int remainingTime,
    @Default(true) bool notificationsEnabled,
    @Default(true) bool soundEnabled,
    @Default(<String>[]) List<String> topPriorities,
    @Default('') String currentTimeBoxTitle,
    @Default('') String currentTimeBoxTimeRange,
  }) = _NativeTimerStateDto;

  factory NativeTimerStateDto.fromJson(Map<String, dynamic> json) =>
      _$NativeTimerStateDtoFromJson(json);

  factory NativeTimerStateDto.fromPlatformMap(
    Map<String, dynamic> map, {
    required Pomodoro fallback,
  }) {
    return NativeTimerStateDto.fromJson({
      'status': _asString(map['status'], 'idle'),
      'sessionCount': _asInt(map['sessionCount'], 0),
      'sessionGoal': _asInt(
        map['sessionGoal'],
        fallback.sessionsUntilLongBreak,
      ),
      'phase': _asString(map['phase'], fallback.phaseValue),
      'remainingTime': _asInt(map['remainingTime'], fallback.remainingTime),
      'notificationsEnabled': _asBool(
        map['notificationsEnabled'],
        fallback.notificationsEnabled,
      ),
      'soundEnabled': _asBool(map['soundEnabled'], fallback.soundEnabled),
      'topPriorities': _asStringList(
        map['topPriorities'],
        fallback.topPriorities,
      ),
      'currentTimeBoxTitle': _asString(
        map['currentTimeBoxTitle'],
        fallback.currentTimeBoxTitle,
      ),
      'currentTimeBoxTimeRange': _asString(
        map['currentTimeBoxTimeRange'],
        fallback.currentTimeBoxTimeRange,
      ),
    });
  }

  TimerSnapshot toEntity() {
    final priorities = topPriorities.take(3).toList();
    while (priorities.length < 3) {
      priorities.add('');
    }

    return TimerSnapshot(
      status: status,
      sessionCount: sessionCount,
      sessionGoal: sessionGoal,
      phase: Pomodoro.phaseFromValue(phase),
      remainingTime: remainingTime,
      notificationsEnabled: notificationsEnabled,
      soundEnabled: soundEnabled,
      topPriorities: priorities,
      currentTimeBoxTitle: currentTimeBoxTitle,
      currentTimeBoxTimeRange: currentTimeBoxTimeRange,
    );
  }

  static int _asInt(Object? value, int fallback) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return fallback;
  }

  static bool _asBool(Object? value, bool fallback) {
    if (value is bool) {
      return value;
    }
    return fallback;
  }

  static String _asString(Object? value, String fallback) {
    if (value is String) {
      return value;
    }
    return fallback;
  }

  static List<String> _asStringList(Object? value, List<String> fallback) {
    if (value is List) {
      final strings = value.whereType<String>().take(3).toList();
      while (strings.length < 3) {
        strings.add('');
      }
      return strings;
    }
    return fallback.take(3).toList();
  }
}
