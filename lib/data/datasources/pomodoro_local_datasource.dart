import '../../domain/entities/pomodoro.dart';
import 'pomodoro_platform_channel.dart';

class PomodoroLocalDataSource {
  Pomodoro _currentPomodoro = Pomodoro.initial();
  Function(int)? _onTickCallback;
  Function()? _onCompleteCallback;

  PomodoroLocalDataSource() {
    // Setup platform channel callbacks
    PomodoroPlatformChannel.setMethodCallHandler(
      (remainingTime) {
        _currentPomodoro = _currentPomodoro.copyWith(remainingTime: remainingTime);
        _onTickCallback?.call(remainingTime);
      },
      () {
        _onCompleteCallback?.call();
      },
    );
  }

  Pomodoro getPomodoro() => _currentPomodoro;

  void updatePomodoro(Pomodoro pomodoro) {
    _currentPomodoro = pomodoro;
  }

  Stream<int> startTimer() async* {
    // Use platform channel for native timer
    await PomodoroPlatformChannel.startTimer(
      _currentPomodoro.remainingTime,
      sessionCount: _currentPomodoro.completedSessions,
    );

    // Setup callbacks
    _onTickCallback = (remainingTime) {
      // This will be called from platform channel
    };

    _onCompleteCallback = () {
      // Timer completed
    };

    // Yield updates when platform channel sends them
    while (_currentPomodoro.remainingTime > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (_currentPomodoro.status == PomodoroStatus.running) {
        yield _currentPomodoro.remainingTime;
      }
    }
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
}
