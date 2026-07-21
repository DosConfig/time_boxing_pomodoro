import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/calendar_export.dart';

class CalendarAppPlatformChannel {
  static const _channel = MethodChannel('com.pomodoro/calendar');

  Future<CalendarAppOpenResult> open(CalendarProvider provider) async {
    try {
      final rawResult = await _channel.invokeMethod<Object?>('openCalendar', {
        'provider': provider.name,
      });
      final result = rawResult is Map
          ? Map<String, dynamic>.from(rawResult)
          : const <String, dynamic>{};
      return CalendarAppOpenResult(
        status: switch (result['status']) {
          'opened' => CalendarAppOpenStatus.opened,
          'storeOpened' => CalendarAppOpenStatus.storeOpened,
          'unavailable' => CalendarAppOpenStatus.unavailable,
          _ => CalendarAppOpenStatus.failed,
        },
      );
    } on MissingPluginException catch (error) {
      debugPrint('Calendar app channel unavailable: $error');
      return const CalendarAppOpenResult(
        status: CalendarAppOpenStatus.unavailable,
      );
    } on PlatformException catch (error) {
      debugPrint('Calendar app open failed: $error');
      return const CalendarAppOpenResult(status: CalendarAppOpenStatus.failed);
    }
  }
}
