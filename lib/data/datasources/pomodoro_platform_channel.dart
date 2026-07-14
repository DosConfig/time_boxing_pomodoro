import 'package:flutter/services.dart';

class PomodoroPlatformChannel {
  static const _channel = MethodChannel('com.pomodoro/timer');

  // Callback for timer tick updates
  static void setMethodCallHandler(Function(int remainingTime)? onTick, Function()? onComplete) {
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

  static Future<bool> startTimer(int seconds, {int sessionCount = 0}) async {
    try {
      final result = await _channel.invokeMethod('startTimer', {
        'seconds': seconds,
        'sessionCount': sessionCount,
      });
      return result == true;
    } catch (e) {
      print('Error starting timer: $e');
      return false;
    }
  }

  static Future<bool> pauseTimer() async {
    try {
      final result = await _channel.invokeMethod('pauseTimer');
      return result == true;
    } catch (e) {
      print('Error pausing timer: $e');
      return false;
    }
  }

  static Future<bool> resumeTimer() async {
    try {
      final result = await _channel.invokeMethod('resumeTimer');
      return result == true;
    } catch (e) {
      print('Error resuming timer: $e');
      return false;
    }
  }

  static Future<bool> stopTimer() async {
    try {
      final result = await _channel.invokeMethod('stopTimer');
      return result == true;
    } catch (e) {
      print('Error stopping timer: $e');
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
      print('Error getting remaining time: $e');
      return 0;
    }
  }
}
