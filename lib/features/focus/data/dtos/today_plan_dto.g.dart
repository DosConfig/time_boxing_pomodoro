// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_plan_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TimeBoxDto _$TimeBoxDtoFromJson(Map<String, dynamic> json) => _TimeBoxDto(
  id: json['id'] as String? ?? '',
  title: json['title'] as String? ?? '',
  timeRange: json['timeRange'] as String? ?? '',
  durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 30 * 60,
  repeatWeekdays:
      (json['repeatWeekdays'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const <int>[],
);

Map<String, dynamic> _$TimeBoxDtoToJson(_TimeBoxDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'timeRange': instance.timeRange,
      'durationSeconds': instance.durationSeconds,
      'repeatWeekdays': instance.repeatWeekdays,
    };

_TodayPlanDto _$TodayPlanDtoFromJson(
  Map<String, dynamic> json,
) => _TodayPlanDto(
  schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
  dateKey: json['dateKey'] as String? ?? '',
  updatedAtEpochMs: (json['updatedAtEpochMs'] as num?)?.toInt() ?? 0,
  brainDump:
      (json['brainDump'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  reminders:
      (json['reminders'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  topPriorities:
      (json['topPriorities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>['', '', ''],
  timeBoxes:
      (json['timeBoxes'] as List<dynamic>?)
          ?.map((e) => TimeBoxDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <TimeBoxDto>[],
  activeTimeBoxId: json['activeTimeBoxId'] as String? ?? '',
  completedSessions: (json['completedSessions'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TodayPlanDtoToJson(_TodayPlanDto instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'dateKey': instance.dateKey,
      'updatedAtEpochMs': instance.updatedAtEpochMs,
      'brainDump': instance.brainDump,
      'reminders': instance.reminders,
      'topPriorities': instance.topPriorities,
      'timeBoxes': instance.timeBoxes,
      'activeTimeBoxId': instance.activeTimeBoxId,
      'completedSessions': instance.completedSessions,
    };
