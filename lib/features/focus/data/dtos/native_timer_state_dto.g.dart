// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'native_timer_state_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NativeTimerStateDto _$NativeTimerStateDtoFromJson(Map<String, dynamic> json) =>
    _NativeTimerStateDto(
      status: json['status'] as String? ?? 'idle',
      sessionCount: (json['sessionCount'] as num?)?.toInt() ?? 0,
      sessionGoal: (json['sessionGoal'] as num?)?.toInt() ?? 5,
      phase: json['phase'] as String? ?? 'focus',
      remainingTime: (json['remainingTime'] as num?)?.toInt() ?? 25 * 60,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      topPriorities:
          (json['topPriorities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      currentTimeBoxTitle: json['currentTimeBoxTitle'] as String? ?? '',
      currentTimeBoxTimeRange: json['currentTimeBoxTimeRange'] as String? ?? '',
    );

Map<String, dynamic> _$NativeTimerStateDtoToJson(
  _NativeTimerStateDto instance,
) => <String, dynamic>{
  'status': instance.status,
  'sessionCount': instance.sessionCount,
  'sessionGoal': instance.sessionGoal,
  'phase': instance.phase,
  'remainingTime': instance.remainingTime,
  'notificationsEnabled': instance.notificationsEnabled,
  'soundEnabled': instance.soundEnabled,
  'topPriorities': instance.topPriorities,
  'currentTimeBoxTitle': instance.currentTimeBoxTitle,
  'currentTimeBoxTimeRange': instance.currentTimeBoxTimeRange,
};
