import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_plan_summary.freezed.dart';

@freezed
abstract class DailyPlanSummary with _$DailyPlanSummary {
  const DailyPlanSummary._();

  const factory DailyPlanSummary({
    required String dateKey,
    @Default(0) int priorityCount,
    @Default(0) int plannedBoxCount,
    @Default(0) int completedBoxCount,
  }) = _DailyPlanSummary;

  double get completionRatio {
    if (plannedBoxCount <= 0) {
      return 0;
    }
    return (completedBoxCount / plannedBoxCount).clamp(0, 1).toDouble();
  }
}
