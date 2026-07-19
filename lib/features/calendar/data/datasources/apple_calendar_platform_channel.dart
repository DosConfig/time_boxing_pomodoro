import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/calendar_export.dart';
import '../dtos/calendar_export_dto.dart';

class AppleCalendarPlatformChannel {
  static const _channel = MethodChannel('com.pomodoro/calendar');

  Future<CalendarExportResultDto> exportEvents(
    CalendarExportRequest request,
  ) async {
    try {
      final result = await _channel.invokeMethod('exportEvents', {
        'events': request.items
            .map(CalendarExportItemDto.fromEntity)
            .map((item) => item.toPlatformMap())
            .toList(),
      });

      if (result is Map) {
        return CalendarExportResultDto.fromPlatformMap(
          Map<String, dynamic>.from(result),
          dateKey: request.dateKey,
          provider: request.provider,
          exportedAt: DateTime.now(),
        );
      }

      return CalendarExportResultDto(
        status: 'failed',
        message: 'Unexpected calendar export result.',
      );
    } on MissingPluginException catch (error) {
      debugPrint('Apple Calendar channel unavailable: $error');
      return const CalendarExportResultDto(status: 'unavailable');
    } on PlatformException catch (error) {
      debugPrint('Apple Calendar export failed: $error');
      return CalendarExportResultDto(
        status: error.code == 'CALENDAR_DENIED' ? 'denied' : 'failed',
        message: error.message ?? '',
      );
    } catch (error) {
      debugPrint('Apple Calendar export failed: $error');
      return CalendarExportResultDto(status: 'failed', message: '$error');
    }
  }
}
