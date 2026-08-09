import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/calendar_export.dart';
import '../../di/calendar_providers.dart';

export '../../di/calendar_providers.dart';

part 'calendar_export_controller.g.dart';

@riverpod
class CalendarExportController extends _$CalendarExportController {
  @override
  Future<CalendarExportResult?> build(CalendarProvider provider) async => null;

  Future<CalendarExportResult> exportToday(
    CalendarExportRequest request,
  ) async {
    state = const AsyncLoading();
    try {
      final result = switch (provider) {
        CalendarProvider.apple =>
          await ref
              .read(exportTodayPlanToAppleCalendarUseCaseProvider)
              .call(request),
        CalendarProvider.google =>
          await ref
              .read(exportTodayPlanToGoogleCalendarUseCaseProvider)
              .call(request),
      };
      state = AsyncData(result);
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<CalendarAppOpenResult> openCalendar() {
    return ref.read(openCalendarAppUseCaseProvider).call(provider);
  }
}
