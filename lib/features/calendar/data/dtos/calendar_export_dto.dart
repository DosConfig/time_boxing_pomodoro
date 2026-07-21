import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/calendar_export.dart';

part 'calendar_export_dto.freezed.dart';
part 'calendar_export_dto.g.dart';

@freezed
abstract class CalendarExportItemDto with _$CalendarExportItemDto {
  const CalendarExportItemDto._();

  const factory CalendarExportItemDto({
    required String timeBoxId,
    required String title,
    required int startAtMillis,
    required int endAtMillis,
    @Default('') String notes,
  }) = _CalendarExportItemDto;

  factory CalendarExportItemDto.fromJson(Map<String, dynamic> json) =>
      _$CalendarExportItemDtoFromJson(json);

  factory CalendarExportItemDto.fromEntity(CalendarExportItem item) {
    return CalendarExportItemDto(
      timeBoxId: item.timeBoxId,
      title: item.title,
      startAtMillis: item.startAt.millisecondsSinceEpoch,
      endAtMillis: item.endAt.millisecondsSinceEpoch,
      notes: item.notes,
    );
  }

  Map<String, dynamic> toPlatformMap() {
    return {
      'timeBoxId': timeBoxId,
      'title': title,
      'startAtMillis': startAtMillis,
      'endAtMillis': endAtMillis,
      'notes': notes,
    };
  }
}

@freezed
abstract class CalendarEventMappingDto with _$CalendarEventMappingDto {
  const CalendarEventMappingDto._();

  const factory CalendarEventMappingDto({
    required String dateKey,
    required String provider,
    required String timeBoxId,
    required String eventId,
    required String exportedAtIso,
  }) = _CalendarEventMappingDto;

  factory CalendarEventMappingDto.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventMappingDtoFromJson(json);

  factory CalendarEventMappingDto.fromEntity(
    TimeBoxCalendarEventMapping mapping,
  ) {
    return CalendarEventMappingDto(
      dateKey: mapping.dateKey,
      provider: mapping.provider.name,
      timeBoxId: mapping.timeBoxId,
      eventId: mapping.eventId,
      exportedAtIso: mapping.exportedAt.toIso8601String(),
    );
  }

  factory CalendarEventMappingDto.fromPlatformMap(
    Map<String, dynamic> map, {
    required String dateKey,
    required CalendarProvider provider,
    required DateTime exportedAt,
  }) {
    return CalendarEventMappingDto(
      dateKey: dateKey,
      provider: provider.name,
      timeBoxId: map['timeBoxId'] as String? ?? '',
      eventId: map['eventId'] as String? ?? '',
      exportedAtIso: exportedAt.toIso8601String(),
    );
  }

  TimeBoxCalendarEventMapping toEntity() {
    return TimeBoxCalendarEventMapping(
      dateKey: dateKey,
      provider: CalendarProvider.values.firstWhere(
        (value) => value.name == provider,
        orElse: () => CalendarProvider.apple,
      ),
      timeBoxId: timeBoxId,
      eventId: eventId,
      exportedAt: DateTime.tryParse(exportedAtIso) ?? DateTime.now(),
    );
  }
}

@freezed
abstract class CalendarExportResultDto with _$CalendarExportResultDto {
  const CalendarExportResultDto._();

  const factory CalendarExportResultDto({
    @Default('failed') String status,
    @Default(<CalendarEventMappingDto>[]) List<CalendarEventMappingDto> events,
    @Default('') String message,
  }) = _CalendarExportResultDto;

  factory CalendarExportResultDto.fromJson(Map<String, dynamic> json) =>
      _$CalendarExportResultDtoFromJson(json);

  factory CalendarExportResultDto.fromPlatformMap(
    Map<String, dynamic> map, {
    required String dateKey,
    required CalendarProvider provider,
    required DateTime exportedAt,
  }) {
    final rawEvents = map['events'];
    return CalendarExportResultDto(
      status: map['status'] as String? ?? 'failed',
      message: map['message'] as String? ?? '',
      events: rawEvents is List
          ? rawEvents
                .whereType<Map>()
                .map(
                  (event) => CalendarEventMappingDto.fromPlatformMap(
                    Map<String, dynamic>.from(event),
                    dateKey: dateKey,
                    provider: provider,
                    exportedAt: exportedAt,
                  ),
                )
                .where(
                  (event) =>
                      event.timeBoxId.isNotEmpty && event.eventId.isNotEmpty,
                )
                .toList()
          : const <CalendarEventMappingDto>[],
    );
  }

  CalendarExportResult toEntity() {
    return CalendarExportResult(
      status: switch (status) {
        'success' => CalendarExportStatus.success,
        'denied' => CalendarExportStatus.denied,
        'unavailable' => CalendarExportStatus.unavailable,
        _ => CalendarExportStatus.failed,
      },
      exportedCount: events.length,
      mappings: events.map((event) => event.toEntity()).toList(),
      message: message,
    );
  }
}
