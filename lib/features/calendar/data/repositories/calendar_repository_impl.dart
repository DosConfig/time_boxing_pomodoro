import '../../domain/entities/calendar_export.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../datasources/apple_calendar_platform_channel.dart';
import '../datasources/calendar_app_platform_channel.dart';
import '../datasources/calendar_mapping_local_datasource.dart';
import '../datasources/google_calendar_datasource.dart';
import '../dtos/calendar_export_dto.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final AppleCalendarPlatformChannel appleCalendarPlatformChannel;
  final GoogleCalendarDataSource googleCalendarDataSource;
  final CalendarMappingLocalDataSource mappingLocalDataSource;
  final CalendarAppPlatformChannel calendarAppPlatformChannel;

  CalendarRepositoryImpl({
    required this.appleCalendarPlatformChannel,
    required this.googleCalendarDataSource,
    required this.mappingLocalDataSource,
    required this.calendarAppPlatformChannel,
  });

  @override
  Future<CalendarExportResult> exportToAppleCalendar(
    CalendarExportRequest request,
  ) async {
    return _export(request, appleCalendarPlatformChannel.exportEvents);
  }

  @override
  Future<CalendarExportResult> exportToGoogleCalendar(
    CalendarExportRequest request,
  ) async {
    return _export(request, googleCalendarDataSource.exportEvents);
  }

  Future<CalendarExportResult> _export(
    CalendarExportRequest request,
    Future<CalendarExportResultDto> Function(CalendarExportRequest request)
    exporter,
  ) async {
    final provider = request.provider.name;
    final existing = await mappingLocalDataSource.loadMappings(
      provider,
      request.dateKey,
    );
    final mappingsByTimeBoxId = {
      for (final mapping in existing) mapping.timeBoxId: mapping,
    };
    final pendingItems = request.items
        .where((item) => !mappingsByTimeBoxId.containsKey(item.timeBoxId))
        .toList();

    if (pendingItems.isEmpty) {
      return CalendarExportResult(
        status: CalendarExportStatus.success,
        exportedCount: 0,
        mappings: existing.map((mapping) => mapping.toEntity()).toList(),
      );
    }

    final resultDto = await exporter(request.copyWith(items: pendingItems));
    if (resultDto.events.isNotEmpty) {
      await mappingLocalDataSource.saveMappings(
        provider,
        request.dateKey,
        resultDto.events,
      );
      for (final mapping in resultDto.events) {
        mappingsByTimeBoxId[mapping.timeBoxId] = mapping;
      }
    }

    final exportedCount = resultDto.events.length;
    return resultDto
        .copyWith(events: mappingsByTimeBoxId.values.toList())
        .toEntity()
        .copyWith(exportedCount: exportedCount);
  }

  @override
  Future<CalendarAppOpenResult> openCalendarApp(CalendarProvider provider) {
    return calendarAppPlatformChannel.open(provider);
  }
}
