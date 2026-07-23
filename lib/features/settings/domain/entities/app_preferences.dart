import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_preferences.freezed.dart';

enum TimeSlotInterval {
  fifteenMinutes(15),
  thirtyMinutes(30),
  oneHour(60);

  const TimeSlotInterval(this.minutes);

  final int minutes;

  static TimeSlotInterval fromMinutes(int? minutes) {
    return TimeSlotInterval.values.firstWhere(
      (interval) => interval.minutes == minutes,
      orElse: () => TimeSlotInterval.thirtyMinutes,
    );
  }
}

@freezed
abstract class AppPreferences with _$AppPreferences {
  const factory AppPreferences({
    @Default(false) bool isLoaded,
    @Default(false) bool introCompleted,
    @Default(false) bool onboardingCompleted,
    @Default(7 * 60) int awakeStartMinutes,
    @Default(23 * 60) int awakeEndMinutes,
    @Default(TimeSlotInterval.thirtyMinutes) TimeSlotInterval timeSlotInterval,

    /// 슬롯 휴식: 슬롯 간격마다 마지막 몇 분을 휴식으로 쓴다
    /// (15분→1분, 30분→3분, 60분→5분).
    @Default(false) bool slotBreakEnabled,
    @Default('') String localeCode,
  }) = _AppPreferences;

  factory AppPreferences.initial() => const AppPreferences();
}
