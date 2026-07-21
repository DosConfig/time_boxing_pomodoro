import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:time_boxing_pomodoro/features/calendar/data/datasources/google_calendar_datasource.dart';
import 'package:time_boxing_pomodoro/features/calendar/domain/entities/calendar_export.dart';

import 'google_calendar_rest_client_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Dio>()])
void main() {
  group('GoogleCalendarRestClient', () {
    test(
      'posts a TimeBox as a Google Calendar event with bearer auth',
      () async {
        final dio = MockDio();
        final client = GoogleCalendarRestClient(dio: dio);
        final item = CalendarExportItem(
          timeBoxId: 'box-0900',
          title: 'Deep work',
          notes: 'Draft portfolio case study',
          startAt: DateTime(2026, 7, 19, 9),
          endAt: DateTime(2026, 7, 19, 9, 30),
        );

        when(
          dio.post<Map<String, dynamic>>(
            any,
            queryParameters: anyNamed('queryParameters'),
            options: anyNamed('options'),
            data: anyNamed('data'),
          ),
        ).thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            data: const {'id': 'google-event-0900'},
            requestOptions: RequestOptions(path: '/calendars/primary/events'),
            statusCode: 200,
          ),
        );

        final eventId = await client.insertPrimaryEvent(
          accessToken: 'access-token',
          item: item,
          dateKey: '2026-07-19',
        );

        expect(eventId, 'google-event-0900');
        final captured = verify(
          dio.post<Map<String, dynamic>>(
            captureAny,
            queryParameters: captureAnyNamed('queryParameters'),
            options: captureAnyNamed('options'),
            data: captureAnyNamed('data'),
          ),
        ).captured;
        expect(captured[0], '/calendars/primary/events');
        expect(captured[1], {'sendUpdates': 'none'});
        expect(
          (captured[2] as Options).headers?['Authorization'],
          'Bearer access-token',
        );
        expect(
          captured[3],
          GoogleCalendarEventPayload.fromItem(
            item,
            eventId: GoogleCalendarEventId.from('2026-07-19', item.timeBoxId),
          ),
        );
      },
    );

    test(
      'treats a deterministic event id conflict as already exported',
      () async {
        final dio = MockDio();
        final client = GoogleCalendarRestClient(dio: dio);
        final item = CalendarExportItem(
          timeBoxId: 'box-0900',
          title: 'Deep work',
          startAt: DateTime(2026, 7, 19, 9),
          endAt: DateTime(2026, 7, 19, 9, 30),
        );
        when(
          dio.post<Map<String, dynamic>>(
            any,
            queryParameters: anyNamed('queryParameters'),
            options: anyNamed('options'),
            data: anyNamed('data'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/calendars/primary/events'),
            response: Response<void>(
              requestOptions: RequestOptions(path: '/calendars/primary/events'),
              statusCode: 409,
            ),
          ),
        );

        final eventId = await client.insertPrimaryEvent(
          accessToken: 'access-token',
          item: item,
          dateKey: '2026-07-19',
        );

        expect(
          eventId,
          GoogleCalendarEventId.from('2026-07-19', item.timeBoxId),
        );
      },
    );
  });
}
