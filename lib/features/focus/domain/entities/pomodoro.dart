import 'package:freezed_annotation/freezed_annotation.dart';

part 'pomodoro.freezed.dart';

enum PomodoroStatus { idle, running, paused, break_ }

enum PomodoroPhase { focus, shortBreak, longBreak }

enum PomodoroPreset { classic, deepWork, sprint }

@freezed
abstract class TimeBox with _$TimeBox {
  const TimeBox._();

  const factory TimeBox({
    required String id,
    required String title,
    required String timeRange,
    required int durationSeconds,
    @Default(<int>[]) List<int> repeatWeekdays,
  }) = _TimeBox;

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

  bool repeatsOn(int weekday) => repeatWeekdays.contains(weekday);

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
}

@freezed
abstract class TimerSnapshot with _$TimerSnapshot {
  const factory TimerSnapshot({
    @Default('idle') String status,
    @Default(0) int sessionCount,
    @Default(5) int sessionGoal,
    @Default(PomodoroPhase.focus) PomodoroPhase phase,
    @Default(25 * 60) int remainingTime,
    @Default(true) bool notificationsEnabled,
    @Default(true) bool soundEnabled,
    @Default(['', '', '']) List<String> topPriorities,
    @Default('') String currentTimeBoxTitle,
    @Default('') String currentTimeBoxTimeRange,
  }) = _TimerSnapshot;

  factory TimerSnapshot.fromPomodoro(Pomodoro pomodoro) {
    return TimerSnapshot(
      sessionCount: pomodoro.completedSessions,
      sessionGoal: pomodoro.sessionsUntilLongBreak,
      phase: pomodoro.phase,
      remainingTime: pomodoro.remainingTime,
      notificationsEnabled: pomodoro.notificationsEnabled,
      soundEnabled: pomodoro.soundEnabled,
      topPriorities: pomodoro.topPriorities,
      currentTimeBoxTitle: pomodoro.currentTimeBoxTitle,
      currentTimeBoxTimeRange: pomodoro.currentTimeBoxTimeRange,
    );
  }
}

@freezed
abstract class Pomodoro with _$Pomodoro {
  const Pomodoro._();

  const factory Pomodoro({
    @Default(25 * 60) int workDuration,
    @Default(5 * 60) int breakDuration,
    @Default(15 * 60) int longBreakDuration,
    @Default(5) int sessionsUntilLongBreak,
    @Default(25 * 60) int remainingTime,
    @Default(0) int completedSessions,
    @Default(PomodoroStatus.idle) PomodoroStatus status,
    @Default(PomodoroPhase.focus) PomodoroPhase phase,
    @Default(PomodoroPreset.classic) PomodoroPreset preset,
    @Default(true) bool autoStartBreaks,
    @Default(false) bool autoStartFocus,
    @Default(true) bool notificationsEnabled,
    @Default(true) bool soundEnabled,
    @Default([]) List<String> brainDump,
    @Default([]) List<String> reminders,
    @Default(['', '', '']) List<String> topPriorities,
    @Default('') String currentTimeBoxTitle,
    @Default('') String currentTimeBoxTimeRange,
    @Default(<TimeBox>[]) List<TimeBox> timeBoxes,
    @Default('') String activeTimeBoxId,
  }) = _Pomodoro;

  factory Pomodoro.initial() => const Pomodoro(remainingTime: 0);

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

  bool get canStartFocus =>
      phase == PomodoroPhase.focus &&
      activeTimeBox != null &&
      currentTimeBoxTimeRange.trim().isNotEmpty &&
      remainingTime > 0;

  List<String> get visibleTopPriorities => topPriorities
      .map((priority) => priority.trim())
      .where((priority) => priority.isNotEmpty)
      .take(3)
      .toList();

  List<String> get topPrioritySlots {
    final priorities = List<String>.from(topPriorities.take(3));
    while (priorities.length < 3) {
      priorities.add('');
    }
    return priorities;
  }

  String get liveActivityTimeBoxTitle {
    final trimmed = currentTimeBoxTitle.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    final box = activeTimeBox;
    if (box != null) {
      return box.title;
    }
    return isBreakPhase ? 'Break block' : '';
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
    return null;
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
