// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_export_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CalendarExportItemDto _$CalendarExportItemDtoFromJson(
  Map<String, dynamic> json,
) => _CalendarExportItemDto(
  timeBoxId: json['timeBoxId'] as String,
  title: json['title'] as String,
  startAtMillis: (json['startAtMillis'] as num).toInt(),
  endAtMillis: (json['endAtMillis'] as num).toInt(),
  notes: json['notes'] as String? ?? '',
);

Map<String, dynamic> _$CalendarExportItemDtoToJson(
  _CalendarExportItemDto instance,
) => <String, dynamic>{
  'timeBoxId': instance.timeBoxId,
  'title': instance.title,
  'startAtMillis': instance.startAtMillis,
  'endAtMillis': instance.endAtMillis,
  'notes': instance.notes,
};

_CalendarEventMappingDto _$CalendarEventMappingDtoFromJson(
  Map<String, dynamic> json,
) => _CalendarEventMappingDto(
  dateKey: json['dateKey'] as String,
  provider: json['provider'] as String,
  timeBoxId: json['timeBoxId'] as String,
  eventId: json['eventId'] as String,
  exportedAtIso: json['exportedAtIso'] as String,
);

Map<String, dynamic> _$CalendarEventMappingDtoToJson(
  _CalendarEventMappingDto instance,
) => <String, dynamic>{
  'dateKey': instance.dateKey,
  'provider': instance.provider,
  'timeBoxId': instance.timeBoxId,
  'eventId': instance.eventId,
  'exportedAtIso': instance.exportedAtIso,
};

_CalendarExportResultDto _$CalendarExportResultDtoFromJson(
  Map<String, dynamic> json,
) => _CalendarExportResultDto(
  status: json['status'] as String? ?? 'failed',
  events:
      (json['events'] as List<dynamic>?)
          ?.map(
            (e) => CalendarEventMappingDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <CalendarEventMappingDto>[],
  message: json['message'] as String? ?? '',
);

Map<String, dynamic> _$CalendarExportResultDtoToJson(
  _CalendarExportResultDto instance,
) => <String, dynamic>{
  'status': instance.status,
  'events': instance.events,
  'message': instance.message,
};
