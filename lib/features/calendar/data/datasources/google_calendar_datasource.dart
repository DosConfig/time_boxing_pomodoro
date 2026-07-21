import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:time_boxing_pomodoro/shared/integrations/google_sign_in_initializer.dart';

import '../../domain/entities/calendar_export.dart';
import '../dtos/calendar_export_dto.dart';

class GoogleCalendarDataSource {
  static const _calendarEventsScope =
      'https://www.googleapis.com/auth/calendar.events';
  static const _scopes = <String>[_calendarEventsScope];

  final GoogleCalendarRestClient restClient;

  GoogleCalendarDataSource({GoogleCalendarRestClient? restClient})
    : restClient = restClient ?? GoogleCalendarRestClient();

  Future<CalendarExportResultDto> exportEvents(
    CalendarExportRequest request,
  ) async {
    final exportedAt = DateTime.now();
    final mappings = <CalendarEventMappingDto>[];
    try {
      await GoogleSignInInitializer.ensureInitialized();
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        return const CalendarExportResultDto(status: 'unavailable');
      }

      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: _scopes,
      );
      final authorization =
          await account.authorizationClient.authorizationForScopes(_scopes) ??
          await account.authorizationClient.authorizeScopes(_scopes);
      for (final item in request.items) {
        final eventId = await restClient.insertPrimaryEvent(
          accessToken: authorization.accessToken,
          item: item,
          dateKey: request.dateKey,
        );
        if (eventId == null || eventId.isEmpty) {
          continue;
        }
        mappings.add(
          CalendarEventMappingDto(
            dateKey: request.dateKey,
            provider: request.provider.name,
            timeBoxId: item.timeBoxId,
            eventId: eventId,
            exportedAtIso: exportedAt.toIso8601String(),
          ),
        );
      }

      return CalendarExportResultDto(status: 'success', events: mappings);
    } on GoogleSignInException catch (error) {
      debugPrint('Google Calendar authorization failed: $error');
      return CalendarExportResultDto(
        status: _statusFromGoogleError(error),
        events: mappings,
      );
    } on DioException catch (error) {
      debugPrint('Google Calendar export failed: $error');
      return CalendarExportResultDto(
        status: _statusFromGoogleApiStatus(error.response?.statusCode),
        message: _messageFromDioError(error),
        events: mappings,
      );
    } catch (error) {
      debugPrint('Google Calendar export failed: $error');
      return CalendarExportResultDto(
        status: 'failed',
        message: '$error',
        events: mappings,
      );
    }
  }

  String _statusFromGoogleError(GoogleSignInException error) {
    return switch (error.code) {
      GoogleSignInExceptionCode.canceled ||
      GoogleSignInExceptionCode.interrupted => 'denied',
      GoogleSignInExceptionCode.uiUnavailable => 'unavailable',
      _ => 'failed',
    };
  }

  String _messageFromDioError(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final errorBody = data['error'];
      if (errorBody is Map<String, dynamic>) {
        return errorBody['message'] as String? ?? error.message ?? '';
      }
      return data['message'] as String? ?? error.message ?? '';
    }
    if (data is String && data.isNotEmpty) {
      return data;
    }
    return error.message ?? '';
  }

  String _statusFromGoogleApiStatus(int? status) {
    return switch (status) {
      401 || 403 => 'denied',
      _ => 'failed',
    };
  }
}

class GoogleCalendarRestClient {
  final Dio dio;

  GoogleCalendarRestClient({Dio? dio})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://www.googleapis.com/calendar/v3',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
              headers: const {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            ),
          );

  Future<String?> insertPrimaryEvent({
    required String accessToken,
    required CalendarExportItem item,
    required String dateKey,
  }) async {
    final eventId = GoogleCalendarEventId.from(dateKey, item.timeBoxId);
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/calendars/primary/events',
        queryParameters: const {'sendUpdates': 'none'},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        data: GoogleCalendarEventPayload.fromItem(item, eventId: eventId),
      );
      return response.data?['id'] as String? ?? eventId;
    } on DioException catch (error) {
      if (error.response?.statusCode == 409) {
        return eventId;
      }
      rethrow;
    }
  }
}

@visibleForTesting
class GoogleCalendarEventId {
  static String from(String dateKey, String timeBoxId) {
    final bytes = utf8.encode('$dateKey:$timeBoxId');
    final encoded = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return 'tm$encoded';
  }
}

@visibleForTesting
class GoogleCalendarEventPayload {
  static Map<String, dynamic> fromItem(
    CalendarExportItem item, {
    required String eventId,
  }) {
    return {
      'id': eventId,
      'summary': item.title,
      if (item.notes.isNotEmpty) 'description': item.notes,
      'start': {'dateTime': item.startAt.toUtc().toIso8601String()},
      'end': {'dateTime': item.endAt.toUtc().toIso8601String()},
    };
  }
}
