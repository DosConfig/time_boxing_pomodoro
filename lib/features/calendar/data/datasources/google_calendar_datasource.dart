import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:http/http.dart' as http;

import '../../domain/entities/calendar_export.dart';
import '../dtos/calendar_export_dto.dart';

class GoogleCalendarDataSource {
  static const _scopes = <String>[calendar.CalendarApi.calendarEventsScope];
  static Future<void>? _initializeFuture;

  Future<CalendarExportResultDto> exportEvents(
    CalendarExportRequest request,
  ) async {
    try {
      await _ensureInitialized();
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        return const CalendarExportResultDto(status: 'unavailable');
      }

      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: _scopes,
      );
      final authorization =
          await account.authorizationClient.authorizationForScopes(_scopes) ??
          await account.authorizationClient.authorizeScopes(_scopes);
      final client = _GoogleAuthorizationClient(authorization.accessToken);

      try {
        final api = calendar.CalendarApi(client);
        final exportedAt = DateTime.now();
        final mappings = <CalendarEventMappingDto>[];
        for (final item in request.items) {
          final event = await api.events.insert(
            _GoogleCalendarEventFactory.fromItem(item),
            'primary',
            sendUpdates: 'none',
          );
          final eventId = event.id;
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
      } finally {
        client.close();
      }
    } on GoogleSignInException catch (error) {
      debugPrint('Google Calendar authorization failed: $error');
      return CalendarExportResultDto(status: _statusFromGoogleError(error));
    } on calendar.DetailedApiRequestError catch (error) {
      debugPrint('Google Calendar export failed: $error');
      return CalendarExportResultDto(
        status: _statusFromGoogleApiStatus(error.status),
        message: error.message ?? '',
      );
    } on calendar.ApiRequestError catch (error) {
      debugPrint('Google Calendar export failed: $error');
      return CalendarExportResultDto(
        status: 'failed',
        message: error.message ?? '',
      );
    } catch (error) {
      debugPrint('Google Calendar export failed: $error');
      return CalendarExportResultDto(status: 'failed', message: '$error');
    }
  }

  Future<void> _ensureInitialized() async {
    try {
      _initializeFuture ??= GoogleSignIn.instance.initialize();
      await _initializeFuture;
    } catch (_) {
      _initializeFuture = null;
      rethrow;
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

  String _statusFromGoogleApiStatus(int? status) {
    return switch (status) {
      401 || 403 => 'denied',
      _ => 'failed',
    };
  }
}

class _GoogleAuthorizationClient extends http.BaseClient {
  final String accessToken;
  final http.Client _inner;

  _GoogleAuthorizationClient(this.accessToken) : _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $accessToken';
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}

class _GoogleCalendarEventFactory {
  static calendar.Event fromItem(CalendarExportItem item) {
    return calendar.Event(
      summary: item.title,
      description: item.notes.isEmpty ? null : item.notes,
      start: calendar.EventDateTime(dateTime: item.startAt),
      end: calendar.EventDateTime(dateTime: item.endAt),
    );
  }
}
