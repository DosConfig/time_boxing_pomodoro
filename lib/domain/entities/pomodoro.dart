enum PomodoroStatus { idle, running, paused, break_ }

enum PomodoroPhase { focus, shortBreak, longBreak }

enum PomodoroPreset { classic, deepWork, sprint }

class Pomodoro {
  final int workDuration; // in seconds
  final int breakDuration; // in seconds
  final int longBreakDuration; // in seconds
  final int sessionsUntilLongBreak;
  final int remainingTime; // in seconds
  final int completedSessions;
  final PomodoroStatus status;
  final PomodoroPhase phase;
  final PomodoroPreset preset;
  final bool autoStartBreaks;
  final bool autoStartFocus;
  final bool notificationsEnabled;
  final bool soundEnabled;

  const Pomodoro({
    required this.workDuration,
    required this.breakDuration,
    required this.longBreakDuration,
    required this.sessionsUntilLongBreak,
    required this.remainingTime,
    required this.completedSessions,
    required this.status,
    required this.phase,
    required this.preset,
    required this.autoStartBreaks,
    required this.autoStartFocus,
    required this.notificationsEnabled,
    required this.soundEnabled,
  });

  factory Pomodoro.initial() {
    return const Pomodoro(
      workDuration: 25 * 60,
      breakDuration: 5 * 60,
      longBreakDuration: 15 * 60,
      sessionsUntilLongBreak: 5,
      remainingTime: 25 * 60,
      completedSessions: 0,
      status: PomodoroStatus.idle,
      phase: PomodoroPhase.focus,
      preset: PomodoroPreset.classic,
      autoStartBreaks: true,
      autoStartFocus: false,
      notificationsEnabled: true,
      soundEnabled: true,
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
    PomodoroPhase? phase,
    PomodoroPreset? preset,
    bool? autoStartBreaks,
    bool? autoStartFocus,
    bool? notificationsEnabled,
    bool? soundEnabled,
  }) {
    return Pomodoro(
      workDuration: workDuration ?? this.workDuration,
      breakDuration: breakDuration ?? this.breakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      sessionsUntilLongBreak:
          sessionsUntilLongBreak ?? this.sessionsUntilLongBreak,
      remainingTime: remainingTime ?? this.remainingTime,
      completedSessions: completedSessions ?? this.completedSessions,
      status: status ?? this.status,
      phase: phase ?? this.phase,
      preset: preset ?? this.preset,
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartFocus: autoStartFocus ?? this.autoStartFocus,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  int get minutes => remainingTime ~/ 60;
  int get seconds => remainingTime % 60;

  int get activeDuration {
    switch (phase) {
      case PomodoroPhase.focus:
        return workDuration;
      case PomodoroPhase.shortBreak:
        return breakDuration;
      case PomodoroPhase.longBreak:
        return longBreakDuration;
    }
  }

  bool get isBreakPhase =>
      phase == PomodoroPhase.shortBreak || phase == PomodoroPhase.longBreak;

  double get progress {
    if (activeDuration <= 0) {
      return 0;
    }
    return (1 - (remainingTime / activeDuration)).clamp(0, 1);
  }

  bool get nextBreakIsLong =>
      (completedSessions + 1) % sessionsUntilLongBreak == 0;

  String get phaseValue {
    switch (phase) {
      case PomodoroPhase.focus:
        return 'focus';
      case PomodoroPhase.shortBreak:
        return 'shortBreak';
      case PomodoroPhase.longBreak:
        return 'longBreak';
    }
  }

  String get presetLabel {
    switch (preset) {
      case PomodoroPreset.classic:
        return 'Classic';
      case PomodoroPreset.deepWork:
        return 'Deep Work';
      case PomodoroPreset.sprint:
        return 'Sprint';
    }
  }

  static PomodoroPhase phaseFromValue(Object? value) {
    switch (value) {
      case 'shortBreak':
        return PomodoroPhase.shortBreak;
      case 'longBreak':
        return PomodoroPhase.longBreak;
      default:
        return PomodoroPhase.focus;
    }
  }

  Pomodoro applyPreset(PomodoroPreset nextPreset) {
    switch (nextPreset) {
      case PomodoroPreset.classic:
        return copyWith(
          workDuration: 25 * 60,
          breakDuration: 5 * 60,
          longBreakDuration: 15 * 60,
          sessionsUntilLongBreak: 5,
          remainingTime: 25 * 60,
          completedSessions: 0,
          status: PomodoroStatus.idle,
          phase: PomodoroPhase.focus,
          preset: nextPreset,
        );
      case PomodoroPreset.deepWork:
        return copyWith(
          workDuration: 50 * 60,
          breakDuration: 10 * 60,
          longBreakDuration: 25 * 60,
          sessionsUntilLongBreak: 4,
          remainingTime: 50 * 60,
          completedSessions: 0,
          status: PomodoroStatus.idle,
          phase: PomodoroPhase.focus,
          preset: nextPreset,
        );
      case PomodoroPreset.sprint:
        return copyWith(
          workDuration: 15 * 60,
          breakDuration: 3 * 60,
          longBreakDuration: 10 * 60,
          sessionsUntilLongBreak: 6,
          remainingTime: 15 * 60,
          completedSessions: 0,
          status: PomodoroStatus.idle,
          phase: PomodoroPhase.focus,
          preset: nextPreset,
        );
    }
  }
}
