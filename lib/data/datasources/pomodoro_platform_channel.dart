import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PomodoroPlatformChannel {
  static const _channel = MethodChannel('com.pomodoro/timer');

  // Callback for timer tick updates
  static void setMethodCallHandler(
    Function(int remainingTime)? onTick,
    Function()? onComplete,
  ) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onTick':
          if (onTick != null && call.arguments is Map) {
            final args = call.arguments as Map;
            final remainingTime = args['remainingTime'] as int;
            onTick(remainingTime);
          }
          break;
        case 'onComplete':
          if (onComplete != null) {
            onComplete();
          }
          break;
      }
    });
  }

  static Future<bool> startTimer(
    int seconds, {
    int sessionCount = 0,
    int sessionGoal = 5,
    required String phase,
    required bool notificationsEnabled,
    required bool soundEnabled,
    required List<String> topPriorities,
    required String currentTimeBoxTitle,
    required String currentTimeBoxTimeRange,
  }) async {
    try {
      final result = await _channel.invokeMethod('startTimer', {
        'seconds': seconds,
        'sessionCount': sessionCount,
        'sessionGoal': sessionGoal,
        'phase': phase,
        'notificationsEnabled': notificationsEnabled,
        'soundEnabled': soundEnabled,
        'topPriorities': topPriorities,
        'currentTimeBoxTitle': currentTimeBoxTitle,
        'currentTimeBoxTimeRange': currentTimeBoxTimeRange,
      });
      return result == true;
    } catch (e) {
      debugPrint('Error starting timer: $e');
      return false;
    }
  }

  static Future<bool> pauseTimer() async {
    try {
      final result = await _channel.invokeMethod('pauseTimer');
      return result == true;
    } catch (e) {
      debugPrint('Error pausing timer: $e');
      return false;
    }
  }

  static Future<bool> resumeTimer() async {
    try {
      final result = await _channel.invokeMethod('resumeTimer');
      return result == true;
    } catch (e) {
      debugPrint('Error resuming timer: $e');
      return false;
    }
  }

  static Future<bool> stopTimer() async {
    try {
      final result = await _channel.invokeMethod('stopTimer');
      return result == true;
    } catch (e) {
      debugPrint('Error stopping timer: $e');
      return false;
    }
  }

  /// 앱 재실행 시 네이티브에 이전 타이머 상태 질의 (프로세스 종료 대비 복원)
  static Future<Map<String, dynamic>> restoreState() async {
    try {
      final result = await _channel.invokeMethod('restoreState');
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }
      return {'status': 'idle'};
    } catch (e) {
      debugPrint('Error restoring state: $e');
      return {'status': 'idle'};
    }
  }

  static Future<bool> updateNotificationSettings({
    required bool notificationsEnabled,
    required bool soundEnabled,
  }) async {
    try {
      final result = await _channel.invokeMethod('updateNotificationSettings', {
        'notificationsEnabled': notificationsEnabled,
        'soundEnabled': soundEnabled,
      });
      return result == true;
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
      return false;
    }
  }

  static Future<String> getActivityStatus() async {
    try {
      final result = await _channel.invokeMethod('getActivityStatus');
      return result as String? ?? 'null';
    } catch (e) {
      return '채널 에러: $e';
    }
  }

  static Future<int> getRemainingTime() async {
    try {
      final result = await _channel.invokeMethod('getRemainingTime');
      return result as int;
    } catch (e) {
      debugPrint('Error getting remaining time: $e');
      return 0;
    }
  }
}
