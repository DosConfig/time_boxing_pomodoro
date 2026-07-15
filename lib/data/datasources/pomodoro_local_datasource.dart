import 'dart:async';

import '../../domain/entities/pomodoro.dart';
import 'pomodoro_platform_channel.dart';

class PomodoroLocalDataSource {
  Pomodoro _currentPomodoro = Pomodoro.initial();

  // 네이티브 onTick을 UI로 흘리는 단일 통로 (진실의 원천 = 네이티브 타이머)
  final StreamController<int> _tickController =
      StreamController<int>.broadcast();

  PomodoroLocalDataSource() {
    PomodoroPlatformChannel.setMethodCallHandler(
      (remainingTime) {
        _currentPomodoro = _currentPomodoro.copyWith(
          remainingTime: remainingTime,
        );
        _tickController.add(remainingTime);
      },
      () {
        // 완료: 0을 흘려 provider의 완료 처리를 트리거
        _currentPomodoro = _currentPomodoro.copyWith(remainingTime: 0);
        _tickController.add(0);
      },
    );
  }

  Pomodoro getPomodoro() => _currentPomodoro;

  /// 네이티브 tick 스트림 (startTimer 없이 구독만 — 상태 복원 시 사용)
  Stream<int> ticks() => _tickController.stream;

  Future<Map<String, dynamic>> restoreState() =>
      PomodoroPlatformChannel.restoreState();

  void updatePomodoro(Pomodoro pomodoro) {
    _currentPomodoro = pomodoro;
  }

  Stream<int> startTimer({
    required String phase,
    required bool notificationsEnabled,
    required bool soundEnabled,
  }) async* {
    // 네이티브 타이머 시작 (Live Activity 포함)
    await PomodoroPlatformChannel.startTimer(
      _currentPomodoro.remainingTime,
      sessionCount: _currentPomodoro.completedSessions,
      sessionGoal: _currentPomodoro.sessionsUntilLongBreak,
      phase: phase,
      notificationsEnabled: notificationsEnabled,
      soundEnabled: soundEnabled,
    );

    // 이후의 모든 tick은 네이티브 onTick에서 공급됨
    yield* _tickController.stream;
  }

  Future<void> pauseTimer() async {
    await PomodoroPlatformChannel.pauseTimer();
  }

  Future<void> resumeTimer() async {
    await PomodoroPlatformChannel.resumeTimer();
  }

  Future<void> stopTimer() async {
    await PomodoroPlatformChannel.stopTimer();
  }

  Future<void> updateNotificationSettings({
    required bool notificationsEnabled,
    required bool soundEnabled,
  }) async {
    await PomodoroPlatformChannel.updateNotificationSettings(
      notificationsEnabled: notificationsEnabled,
      soundEnabled: soundEnabled,
    );
  }
}
