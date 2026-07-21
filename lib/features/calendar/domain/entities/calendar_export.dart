import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_export.freezed.dart';

enum CalendarProvider { apple, google }

enum CalendarExportStatus { idle, success, denied, unavailable, failed }

enum CalendarAppOpenStatus { opened, storeOpened, unavailable, failed }

@freezed
abstract class CalendarExportItem with _$CalendarExportItem {
  const factory CalendarExportItem({
    required String timeBoxId,
    required String title,
    required DateTime startAt,
    required DateTime endAt,
    @Default('') String notes,
  }) = _CalendarExportItem;
}

@freezed
abstract class CalendarExportRequest with _$CalendarExportRequest {
  const factory CalendarExportRequest({
    required CalendarProvider provider,
    required String dateKey,
    required List<CalendarExportItem> items,
  }) = _CalendarExportRequest;
}

@freezed
abstract class TimeBoxCalendarEventMapping with _$TimeBoxCalendarEventMapping {
  const factory TimeBoxCalendarEventMapping({
    required String dateKey,
    required CalendarProvider provider,
    required String timeBoxId,
    required String eventId,
    required DateTime exportedAt,
  }) = _TimeBoxCalendarEventMapping;
}

@freezed
abstract class CalendarExportResult with _$CalendarExportResult {
  const CalendarExportResult._();

  const factory CalendarExportResult({
    @Default(CalendarExportStatus.idle) CalendarExportStatus status,
    @Default(0) int exportedCount,
    @Default(<TimeBoxCalendarEventMapping>[])
    List<TimeBoxCalendarEventMapping> mappings,
    @Default('') String message,
  }) = _CalendarExportResult;

  bool get isSuccess => status == CalendarExportStatus.success;
}

@freezed
abstract class CalendarAppOpenResult with _$CalendarAppOpenResult {
  const factory CalendarAppOpenResult({
    @Default(CalendarAppOpenStatus.failed) CalendarAppOpenStatus status,
  }) = _CalendarAppOpenResult;
}
