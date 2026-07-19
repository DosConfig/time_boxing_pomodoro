import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_sync_options.freezed.dart';

enum CalendarSyncMode { manual, automatic }

@freezed
abstract class CalendarSyncOptions with _$CalendarSyncOptions {
  const factory CalendarSyncOptions({
    @Default(CalendarSyncMode.manual) CalendarSyncMode mode,
    @Default(false) bool topPrioritiesOnly,
    @Default(true) bool conflictCheck,
    @Default(true) bool dedicatedCalendar,
    @Default(false) bool includeBreaks,
  }) = _CalendarSyncOptions;
}
