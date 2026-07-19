import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/datasources/apple_calendar_platform_channel.dart';
import '../data/datasources/calendar_mapping_local_datasource.dart';
import '../data/datasources/google_calendar_datasource.dart';
import '../data/repositories/calendar_repository_impl.dart';
import '../domain/entities/calendar_export.dart';
import '../domain/repositories/calendar_repository.dart';
import '../domain/usecases/export_today_plan_to_apple_calendar.dart';
import '../domain/usecases/export_today_plan_to_google_calendar.dart';

part 'calendar_export_controller.g.dart';

@Riverpod(keepAlive: true)
AppleCalendarPlatformChannel appleCalendarPlatformChannel(Ref ref) {
  return AppleCalendarPlatformChannel();
}

@Riverpod(keepAlive: true)
GoogleCalendarDataSource googleCalendarDataSource(Ref ref) {
  return GoogleCalendarDataSource();
}

@Riverpod(keepAlive: true)
CalendarMappingLocalDataSource calendarMappingLocalDataSource(Ref ref) {
  return CalendarMappingLocalDataSource();
}

@Riverpod(keepAlive: true)
CalendarRepository calendarRepository(Ref ref) {
  return CalendarRepositoryImpl(
    appleCalendarPlatformChannel: ref.watch(
      appleCalendarPlatformChannelProvider,
    ),
    googleCalendarDataSource: ref.watch(googleCalendarDataSourceProvider),
    mappingLocalDataSource: ref.watch(calendarMappingLocalDataSourceProvider),
  );
}

@Riverpod(keepAlive: true)
ExportTodayPlanToAppleCalendarUseCase exportTodayPlanToAppleCalendarUseCase(
  Ref ref,
) {
  return ExportTodayPlanToAppleCalendarUseCase(
    ref.watch(calendarRepositoryProvider),
  );
}

@Riverpod(keepAlive: true)
ExportTodayPlanToGoogleCalendarUseCase exportTodayPlanToGoogleCalendarUseCase(
  Ref ref,
) {
  return ExportTodayPlanToGoogleCalendarUseCase(
    ref.watch(calendarRepositoryProvider),
  );
}

@riverpod
class CalendarExportController extends _$CalendarExportController {
  @override
  Future<CalendarExportResult?> build() async => null;

  Future<CalendarExportResult> exportAppleToday(
    CalendarExportRequest request,
  ) async {
    state = const AsyncLoading();
    final result = await ref
        .read(exportTodayPlanToAppleCalendarUseCaseProvider)
        .call(request);
    state = AsyncData(result);
    return result;
  }

  Future<CalendarExportResult> exportGoogleToday(
    CalendarExportRequest request,
  ) async {
    state = const AsyncLoading();
    final result = await ref
        .read(exportTodayPlanToGoogleCalendarUseCaseProvider)
        .call(request);
    state = AsyncData(result);
    return result;
  }
}
