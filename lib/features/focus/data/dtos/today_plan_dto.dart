import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/daily_plan_summary.dart';
import '../../domain/entities/pomodoro.dart';

part 'today_plan_dto.freezed.dart';
part 'today_plan_dto.g.dart';

@freezed
abstract class TimeBoxDto with _$TimeBoxDto {
  const TimeBoxDto._();

  const factory TimeBoxDto({
    @Default('') String id,
    @Default('') String title,
    @Default('') String timeRange,
    @Default(30 * 60) int durationSeconds,
  }) = _TimeBoxDto;

  factory TimeBoxDto.fromJson(Map<String, dynamic> json) =>
      _$TimeBoxDtoFromJson(json);

  factory TimeBoxDto.fromEntity(TimeBox box) {
    return TimeBoxDto(
      id: box.id,
      title: box.title,
      timeRange: box.timeRange,
      durationSeconds: box.durationSeconds,
    );
  }

  TimeBox toEntity() {
    return TimeBox(
      id: id,
      title: title,
      timeRange: timeRange,
      durationSeconds: durationSeconds,
    );
  }
}

@freezed
abstract class TodayPlanDto with _$TodayPlanDto {
  const TodayPlanDto._();

  const factory TodayPlanDto({
    @Default(1) int schemaVersion,
    @Default('') String dateKey,
    @Default(<String>[]) List<String> brainDump,
    @Default(<String>[]) List<String> reminders,
    @Default(<String>['', '', '']) List<String> topPriorities,
    @Default(<TimeBoxDto>[]) List<TimeBoxDto> timeBoxes,
    @Default('') String activeTimeBoxId,
    @Default(0) int completedSessions,
  }) = _TodayPlanDto;

  factory TodayPlanDto.fromJson(Map<String, dynamic> json) =>
      _$TodayPlanDtoFromJson(json);

  Map<String, dynamic> toStorageJson() {
    final json = toJson();
    json['timeBoxes'] = timeBoxes.map((box) => box.toJson()).toList();
    return json;
  }

  factory TodayPlanDto.fromEntity(
    Pomodoro pomodoro, {
    required String dateKey,
  }) {
    return TodayPlanDto(
      dateKey: dateKey,
      brainDump: pomodoro.brainDump,
      reminders: pomodoro.reminders,
      topPriorities: _normalizedPriorities(pomodoro.topPriorities),
      timeBoxes: pomodoro.timeBoxes.map(TimeBoxDto.fromEntity).toList(),
      activeTimeBoxId: pomodoro.activeTimeBoxId,
      completedSessions: pomodoro.completedSessions,
    );
  }

  Pomodoro toEntity(Pomodoro fallback) {
    final boxes = timeBoxes
        .map((box) => box.toEntity())
        .where((box) => box.id.isNotEmpty && box.timeRange.isNotEmpty)
        .toList();
    final nextBoxes = boxes.isEmpty ? fallback.timeBoxes : boxes;
    final nextActiveBoxId = _normalizedActiveBoxId(nextBoxes, activeTimeBoxId);
    final activeBox = nextBoxes.firstWhere(
      (box) => box.id == nextActiveBoxId,
      orElse: () => nextBoxes.first,
    );

    return fallback.copyWith(
      brainDump: brainDump,
      reminders: reminders,
      topPriorities: _normalizedPriorities(topPriorities),
      timeBoxes: nextBoxes,
      activeTimeBoxId: nextActiveBoxId,
      completedSessions: completedSessions < 0 ? 0 : completedSessions,
      currentTimeBoxTitle: activeBox.title,
      currentTimeBoxTimeRange: activeBox.timeRange,
      workDuration: activeBox.durationSeconds,
      remainingTime: activeBox.durationSeconds,
      status: PomodoroStatus.idle,
      phase: PomodoroPhase.focus,
    );
  }

  DailyPlanSummary toSummary() {
    return DailyPlanSummary(
      dateKey: dateKey,
      priorityCount: topPriorities
          .where((priority) => priority.trim().isNotEmpty)
          .length
          .clamp(0, 3)
          .toInt(),
      plannedBoxCount: timeBoxes.length,
      completedBoxCount: completedSessions.clamp(0, timeBoxes.length).toInt(),
    );
  }

  static List<String> _normalizedPriorities(List<String> priorities) {
    final nextPriorities = priorities.take(3).toList();
    while (nextPriorities.length < 3) {
      nextPriorities.add('');
    }
    return nextPriorities;
  }

  static String _normalizedActiveBoxId(List<TimeBox> boxes, String id) {
    if (boxes.any((box) => box.id == id)) {
      return id;
    }
    return boxes.isEmpty ? '' : boxes.first.id;
  }
}
