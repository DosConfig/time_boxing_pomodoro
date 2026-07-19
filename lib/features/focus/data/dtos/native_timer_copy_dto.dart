import '../../domain/entities/native_timer_copy.dart';

class NativeTimerCopyDto {
  final NativeTimerCopy copy;

  const NativeTimerCopyDto(this.copy);

  Map<String, String> toPlatformMap() {
    return {
      'focusTitle': copy.focusTitle,
      'shortBreakTitle': copy.shortBreakTitle,
      'longBreakTitle': copy.longBreakTitle,
      'pausedTitle': copy.pausedTitle,
      'focusBlockTitle': copy.focusBlockTitle,
      'breakBlockTitle': copy.breakBlockTitle,
      'topPriorityLabel': copy.topPriorityLabel,
      'focusInProgressTitle': copy.focusInProgressTitle,
      'shortBreakInProgressTitle': copy.shortBreakInProgressTitle,
      'longBreakInProgressTitle': copy.longBreakInProgressTitle,
      'remainingTimeFormat': copy.remainingTimeFormat,
      'focusCompleteTitle': copy.focusCompleteTitle,
      'breakCompleteTitle': copy.breakCompleteTitle,
      'focusCompleteBody': copy.focusCompleteBody,
      'breakCompleteBody': copy.breakCompleteBody,
    };
  }
}
