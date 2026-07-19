import '../../domain/entities/calendar_export.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../datasources/apple_calendar_platform_channel.dart';
import '../datasources/calendar_mapping_local_datasource.dart';
import '../datasources/google_calendar_datasource.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final AppleCalendarPlatformChannel appleCalendarPlatformChannel;
  final GoogleCalendarDataSource googleCalendarDataSource;
  final CalendarMappingLocalDataSource mappingLocalDataSource;

  CalendarRepositoryImpl({
    required this.appleCalendarPlatformChannel,
    required this.googleCalendarDataSource,
    required this.mappingLocalDataSource,
  });

  @override
  Future<CalendarExportResult> exportToAppleCalendar(
    CalendarExportRequest request,
  ) async {
    final resultDto = await appleCalendarPlatformChannel.exportEvents(request);
    if (resultDto.status == 'success') {
      await mappingLocalDataSource.saveMappings(
        CalendarProvider.apple.name,
        request.dateKey,
        resultDto.events,
      );
    }
    return resultDto.toEntity();
  }

  @override
  Future<CalendarExportResult> exportToGoogleCalendar(
    CalendarExportRequest request,
  ) async {
    final resultDto = await googleCalendarDataSource.exportEvents(request);
    if (resultDto.status == 'success') {
      await mappingLocalDataSource.saveMappings(
        CalendarProvider.google.name,
        request.dateKey,
        resultDto.events,
      );
    }
    return resultDto.toEntity();
  }
}
