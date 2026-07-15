enum PomodoroStatus { idle, running, paused, break_ }

enum PomodoroPhase { focus, shortBreak, longBreak }

enum PomodoroPreset { classic, deepWork, sprint }

class TimeBox {
  final String id;
  final String title;
  final String timeRange;
  final int durationSeconds;

  const TimeBox({
    required this.id,
    required this.title,
    required this.timeRange,
    required this.durationSeconds,
  });

  TimeBox copyWith({
    String? id,
    String? title,
    String? timeRange,
    int? durationSeconds,
  }) {
    return TimeBox(
      id: id ?? this.id,
      title: title ?? this.title,
      timeRange: timeRange ?? this.timeRange,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  int? get startMinutes => _clockMinutes(timeRange.split('-').first);

  int? get endMinutes {
    final parts = timeRange.split('-');
    if (parts.length < 2) {
      return null;
    }
    final start = startMinutes;
    final end = _clockMinutes(parts.last);
    if (start == null || end == null) {
      return null;
    }
    return end <= start ? end + (24 * 60) : end;
  }

  int? get rangeDurationSeconds {
    final start = startMinutes;
    final end = endMinutes;
    if (start == null || end == null) {
      return null;
    }
    return (end - start) * 60;
  }

  static int? _clockMinutes(String value) {
    final match = RegExp(r'^\s*(\d{1,2}):(\d{2})\s*$').firstMatch(value);
    if (match == null) {
      return null;
    }

    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null || hour > 23 || minute > 59) {
      return null;
    }
    return (hour * 60) + minute;
  }

  static const List<TimeBox> defaultDay = [
    TimeBox(
      id: 'box-0900',
      title: 'Top priority',
      timeRange: '09:00-09:30',
      durationSeconds: 30 * 60,
    ),
    TimeBox(
      id: 'box-1000',
      title: 'Deep work',
      timeRange: '10:00-10:30',
      durationSeconds: 30 * 60,
    ),
    TimeBox(
      id: 'box-1100',
      title: 'Admin',
      timeRange: '11:00-11:30',
      durationSeconds: 30 * 60,
    ),
    TimeBox(
      id: 'box-1330',
      title: 'Second priority',
      timeRange: '13:30-14:00',
      durationSeconds: 30 * 60,
    ),
    TimeBox(
      id: 'box-1500',
      title: 'Follow-up',
      timeRange: '15:00-15:30',
      durationSeconds: 30 * 60,
    ),
  ];
}

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
  final List<String> brainDump;
  final List<String> topPriorities;
  final String currentTimeBoxTitle;
  final String currentTimeBoxTimeRange;
  final List<TimeBox> timeBoxes;
  final String activeTimeBoxId;

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
    required this.brainDump,
    required this.topPriorities,
    required this.currentTimeBoxTitle,
    required this.currentTimeBoxTimeRange,
    required this.timeBoxes,
    required this.activeTimeBoxId,
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
      brainDump: [],
      topPriorities: ['', '', ''],
      currentTimeBoxTitle: '',
      currentTimeBoxTimeRange: '',
      timeBoxes: TimeBox.defaultDay,
      activeTimeBoxId: 'box-0900',
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
    List<String>? brainDump,
    List<String>? topPriorities,
    String? currentTimeBoxTitle,
    String? currentTimeBoxTimeRange,
    List<TimeBox>? timeBoxes,
    String? activeTimeBoxId,
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
      brainDump: brainDump ?? this.brainDump,
      topPriorities: topPriorities ?? this.topPriorities,
      currentTimeBoxTitle: currentTimeBoxTitle ?? this.currentTimeBoxTitle,
      currentTimeBoxTimeRange:
          currentTimeBoxTimeRange ?? this.currentTimeBoxTimeRange,
      timeBoxes: timeBoxes ?? this.timeBoxes,
      activeTimeBoxId: activeTimeBoxId ?? this.activeTimeBoxId,
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

  List<String> get visibleTopPriorities => topPriorities
      .map((priority) => priority.trim())
      .where((priority) => priority.isNotEmpty)
      .take(3)
      .toList();

  String get liveActivityTimeBoxTitle {
    final trimmed = currentTimeBoxTitle.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    final box = activeTimeBox;
    if (box != null) {
      return box.title;
    }
    return isBreakPhase ? 'Break block' : 'Focus block';
  }

  String get liveActivityTimeBoxRange {
    final trimmed = currentTimeBoxTimeRange.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    return activeTimeBox?.timeRange ?? '';
  }

  TimeBox? get activeTimeBox {
    for (final box in timeBoxes) {
      if (box.id == activeTimeBoxId) {
        return box;
      }
    }
    return timeBoxes.isEmpty ? null : timeBoxes.first;
  }

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
