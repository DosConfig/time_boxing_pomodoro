import 'package:freezed_annotation/freezed_annotation.dart';

part 'native_timer_copy.freezed.dart';

@freezed
abstract class NativeTimerCopy with _$NativeTimerCopy {
  const factory NativeTimerCopy({
    @Default('Focus') String focusTitle,
    @Default('Short break') String shortBreakTitle,
    @Default('Long break') String longBreakTitle,
    @Default('Paused') String pausedTitle,
    @Default('Focus block') String focusBlockTitle,
    @Default('Break block') String breakBlockTitle,
    @Default('Top') String topPriorityLabel,
    @Default('Focus in progress') String focusInProgressTitle,
    @Default('Short break in progress') String shortBreakInProgressTitle,
    @Default('Long break in progress') String longBreakInProgressTitle,
    @Default('%@ remaining') String remainingTimeFormat,
    @Default('Focus complete') String focusCompleteTitle,
    @Default('Break complete') String breakCompleteTitle,
    @Default('The next scheduled timer is starting.')
    String focusCompleteBody,
    @Default('The next scheduled timer is starting.')
    String breakCompleteBody,
  }) = _NativeTimerCopy;
}
