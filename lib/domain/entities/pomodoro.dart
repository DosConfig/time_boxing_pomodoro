enum PomodoroStatus {
  idle,
  running,
  paused,
  break_,
}

class Pomodoro {
  final int workDuration; // in seconds
  final int breakDuration; // in seconds
  final int longBreakDuration; // in seconds
  final int sessionsUntilLongBreak;
  final int remainingTime; // in seconds
  final int completedSessions;
  final PomodoroStatus status;

  const Pomodoro({
    required this.workDuration,
    required this.breakDuration,
    required this.longBreakDuration,
    required this.sessionsUntilLongBreak,
    required this.remainingTime,
    required this.completedSessions,
    required this.status,
  });

  factory Pomodoro.initial() {
    return const Pomodoro(
      workDuration: 25 * 60, // 25 minutes
      breakDuration: 5 * 60, // 5 minutes
      longBreakDuration: 15 * 60, // 15 minutes
      sessionsUntilLongBreak: 4,
      remainingTime: 25 * 60,
      completedSessions: 0,
      status: PomodoroStatus.idle,
    );
  }

  Pomodoro copyWith({
    int? workDuration,
    int? breakDuration,
    int? longBreakDuration,
    int? sessionsUntilLongBreak,
    int? remainingTime,
    int? completedSessions,
    PomodoroStatus? status,
  }) {
    return Pomodoro(
      workDuration: workDuration ?? this.workDuration,
      breakDuration: breakDuration ?? this.breakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      sessionsUntilLongBreak: sessionsUntilLongBreak ?? this.sessionsUntilLongBreak,
      remainingTime: remainingTime ?? this.remainingTime,
      completedSessions: completedSessions ?? this.completedSessions,
      status: status ?? this.status,
    );
  }

  int get minutes => remainingTime ~/ 60;
  int get seconds => remainingTime % 60;

  bool get isLongBreak => completedSessions % sessionsUntilLongBreak == 0 && completedSessions > 0;
}
