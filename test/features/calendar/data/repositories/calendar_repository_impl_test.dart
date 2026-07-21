import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:time_boxing_pomodoro/features/calendar/data/datasources/apple_calendar_platform_channel.dart';
import 'package:time_boxing_pomodoro/features/calendar/data/datasources/calendar_app_platform_channel.dart';
import 'package:time_boxing_pomodoro/features/calendar/data/datasources/calendar_mapping_local_datasource.dart';
import 'package:time_boxing_pomodoro/features/calendar/data/datasources/google_calendar_datasource.dart';
import 'package:time_boxing_pomodoro/features/calendar/data/dtos/calendar_export_dto.dart';
import 'package:time_boxing_pomodoro/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:time_boxing_pomodoro/features/calendar/domain/entities/calendar_export.dart';

import 'calendar_repository_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<AppleCalendarPlatformChannel>(),
  MockSpec<GoogleCalendarDataSource>(),
  MockSpec<CalendarMappingLocalDataSource>(),
  MockSpec<CalendarAppPlatformChannel>(),
])
void main() {
  group('CalendarRepositoryImpl', () {
    late MockAppleCalendarPlatformChannel appleCalendarPlatformChannel;
    late MockGoogleCalendarDataSource googleCalendarDataSource;
    late MockCalendarMappingLocalDataSource mappingLocalDataSource;
    late MockCalendarAppPlatformChannel calendarAppPlatformChannel;
    late CalendarRepositoryImpl repository;

    setUp(() {
      appleCalendarPlatformChannel = MockAppleCalendarPlatformChannel();
      googleCalendarDataSource = MockGoogleCalendarDataSource();
      mappingLocalDataSource = MockCalendarMappingLocalDataSource();
      calendarAppPlatformChannel = MockCalendarAppPlatformChannel();
      repository = CalendarRepositoryImpl(
        appleCalendarPlatformChannel: appleCalendarPlatformChannel,
        googleCalendarDataSource: googleCalendarDataSource,
        mappingLocalDataSource: mappingLocalDataSource,
        calendarAppPlatformChannel: calendarAppPlatformChannel,
      );
    });

    test('stores Apple event mappings after a successful export', () async {
      final request = _request(CalendarProvider.apple);
      final mapping = _mappingDto(CalendarProvider.apple);
      final resultDto = CalendarExportResultDto(
        status: 'success',
        events: [mapping],
      );

      when(
        appleCalendarPlatformChannel.exportEvents(request),
      ).thenAnswer((_) async => resultDto);
      when(
        mappingLocalDataSource.saveMappings(
          CalendarProvider.apple.name,
          request.dateKey,
          [mapping],
        ),
      ).thenAnswer((_) async {});

      final result = await repository.exportToAppleCalendar(request);

      expect(result.status, CalendarExportStatus.success);
      expect(result.exportedCount, 1);
      expect(result.mappings.single.eventId, 'event-box-0900');
      verify(
        mappingLocalDataSource.saveMappings(
          CalendarProvider.apple.name,
          request.dateKey,
          [mapping],
        ),
      ).called(1);
      verifyNever(googleCalendarDataSource.exportEvents(any));
    });

    test('does not store mappings when Google export is denied', () async {
      final request = _request(CalendarProvider.google);

      when(googleCalendarDataSource.exportEvents(request)).thenAnswer(
        (_) async => const CalendarExportResultDto(status: 'denied'),
      );

      final result = await repository.exportToGoogleCalendar(request);

      expect(result.status, CalendarExportStatus.denied);
      verifyNever(mappingLocalDataSource.saveMappings(any, any, any));
      verifyNever(appleCalendarPlatformChannel.exportEvents(any));
    });

    test('does not export an event that already has a mapping', () async {
      final request = _request(CalendarProvider.google);
      final mapping = _mappingDto(CalendarProvider.google);
      when(
        mappingLocalDataSource.loadMappings(
          CalendarProvider.google.name,
          request.dateKey,
        ),
      ).thenAnswer((_) async => [mapping]);

      final result = await repository.exportToGoogleCalendar(request);

      expect(result.status, CalendarExportStatus.success);
      expect(result.exportedCount, 0);
      expect(result.mappings.single.eventId, mapping.eventId);
      verifyNever(googleCalendarDataSource.exportEvents(any));
      verifyNever(mappingLocalDataSource.saveMappings(any, any, any));
    });

    test(
      'persists partial mappings so a retry cannot duplicate them',
      () async {
        final first = _request(CalendarProvider.google).items.single;
        final second = first.copyWith(
          timeBoxId: 'box-0930',
          title: 'Second box',
          startAt: DateTime(2026, 7, 19, 9, 30),
          endAt: DateTime(2026, 7, 19, 10),
        );
        final request = _request(
          CalendarProvider.google,
        ).copyWith(items: [first, second]);
        final partialMapping = _mappingDto(CalendarProvider.google);
        when(googleCalendarDataSource.exportEvents(request)).thenAnswer(
          (_) async => CalendarExportResultDto(
            status: 'failed',
            events: [partialMapping],
          ),
        );

        final result = await repository.exportToGoogleCalendar(request);

        expect(result.status, CalendarExportStatus.failed);
        expect(result.exportedCount, 1);
        expect(result.mappings.single.timeBoxId, first.timeBoxId);
        verify(
          mappingLocalDataSource.saveMappings(
            CalendarProvider.google.name,
            request.dateKey,
            [partialMapping],
          ),
        ).called(1);
      },
    );
  });
}

CalendarExportRequest _request(CalendarProvider provider) {
  return CalendarExportRequest(
    provider: provider,
    dateKey: '2026-07-19',
    items: [
      CalendarExportItem(
        timeBoxId: 'box-0900',
        title: 'Launch planning',
        startAt: DateTime(2026, 7, 19, 9),
        endAt: DateTime(2026, 7, 19, 9, 30),
      ),
    ],
  );
}

CalendarEventMappingDto _mappingDto(CalendarProvider provider) {
  return CalendarEventMappingDto(
    dateKey: '2026-07-19',
    provider: provider.name,
    timeBoxId: 'box-0900',
    eventId: 'event-box-0900',
    exportedAtIso: DateTime(2026, 7, 19, 9, 1).toIso8601String(),
  );
}
