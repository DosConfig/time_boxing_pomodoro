import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_preferences.freezed.dart';

@freezed
abstract class AppPreferences with _$AppPreferences {
  const factory AppPreferences({
    @Default(false) bool isLoaded,
    @Default(false) bool onboardingCompleted,
    @Default(7 * 60) int awakeStartMinutes,
    @Default(23 * 60) int awakeEndMinutes,
  }) = _AppPreferences;

  factory AppPreferences.initial() => const AppPreferences();
}
