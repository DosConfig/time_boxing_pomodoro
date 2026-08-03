import 'dart:convert';

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
    @Default(<int>[]) List<int> repeatWeekdays,
    @Default('') String recurrenceId,
  }) = _TimeBoxDto;

  factory TimeBoxDto.fromJson(Map<String, dynamic> json) =>
      _$TimeBoxDtoFromJson(json);

  factory TimeBoxDto.fromEntity(TimeBox box) {
    return TimeBoxDto(
      id: box.id,
      title: box.title,
      timeRange: box.timeRange,
      durationSeconds: box.durationSeconds,
      repeatWeekdays: _normalizedWeekdays(box.repeatWeekdays),
      recurrenceId: box.recurrenceId,
    );
  }

  TimeBox toEntity() {
    return TimeBox(
      id: id,
      title: title,
      timeRange: timeRange,
      durationSeconds: durationSeconds,
      repeatWeekdays: _normalizedWeekdays(repeatWeekdays),
      recurrenceId: recurrenceId,
    );
  }

  static List<int> _normalizedWeekdays(List<int> weekdays) {
    return weekdays
        .where((weekday) => weekday >= 1 && weekday <= 7)
        .toSet()
        .toList()
      ..sort();
  }
}

@freezed
abstract class TodayPlanDto with _$TodayPlanDto {
  const TodayPlanDto._();

  const factory TodayPlanDto({
    @Default(2) int schemaVersion,
    @Default('') String dateKey,
    @Default(0) int updatedAtEpochMs,
    @Default(<String>[]) List<String> brainDump,
    @Default(<String>[]) List<String> reminders,
    @Default(<String>['', '', '']) List<String> topPriorities,
    @Default(<TimeBoxDto>[]) List<TimeBoxDto> timeBoxes,
    @Default('') String activeTimeBoxId,
    @Default(0) int completedSessions,
    @Default(<String>[]) List<String> cancelledRecurrenceKeys,
  }) = _TodayPlanDto;

  factory TodayPlanDto.fromJson(Map<String, dynamic> json) =>
      _$TodayPlanDtoFromJson(json);

  Map<String, dynamic> toStorageJson() {
    final json = toJson();
    json['timeBoxes'] = timeBoxes.map((box) => box.toJson()).toList();
    return json;
  }

  String contentSignature() {
    final json = toStorageJson()..remove('updatedAtEpochMs');
    return jsonEncode(json);
  }

  factory TodayPlanDto.fromEntity(
    Pomodoro pomodoro, {
    required String dateKey,
    int updatedAtEpochMs = 0,
  }) {
    return TodayPlanDto(
      dateKey: dateKey,
      updatedAtEpochMs: updatedAtEpochMs,
      brainDump: pomodoro.brainDump,
      reminders: pomodoro.reminders,
      topPriorities: _normalizedPriorities(pomodoro.topPriorities),
      timeBoxes: pomodoro.timeBoxes.map(TimeBoxDto.fromEntity).toList(),
      activeTimeBoxId: pomodoro.activeTimeBoxId,
      completedSessions: pomodoro.completedSessions,
      cancelledRecurrenceKeys: pomodoro.cancelledRecurrenceKeys,
    );
  }

  Pomodoro toEntity(Pomodoro fallback) {
    final boxes = timeBoxes
        .map((box) => box.toEntity())
        .where((box) => box.id.isNotEmpty && box.timeRange.isNotEmpty)
        .toList();
    final nextBoxes = boxes;
    final nextActiveBoxId = _normalizedActiveBoxId(nextBoxes, activeTimeBoxId);
    final activeBox = nextActiveBoxId.isEmpty
        ? null
        : nextBoxes.firstWhere((box) => box.id == nextActiveBoxId);

    return fallback.copyWith(
      brainDump: brainDump,
      reminders: reminders,
      topPriorities: _normalizedPriorities(topPriorities),
      timeBoxes: nextBoxes,
      activeTimeBoxId: nextActiveBoxId,
      completedSessions: completedSessions < 0 ? 0 : completedSessions,
      cancelledRecurrenceKeys: cancelledRecurrenceKeys.toSet().toList(),
      currentTimeBoxTitle: activeBox?.title ?? '',
      currentTimeBoxTimeRange: activeBox?.timeRange ?? '',
      workDuration: activeBox?.durationSeconds ?? fallback.workDuration,
      remainingTime: activeBox?.durationSeconds ?? 0,
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
