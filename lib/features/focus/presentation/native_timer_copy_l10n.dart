import 'package:time_boxing_pomodoro/l10n/generated/app_localizations.dart';

import '../domain/entities/native_timer_copy.dart';

extension NativeTimerCopyL10n on AppLocalizations {
  NativeTimerCopy get nativeTimerCopy {
    return NativeTimerCopy(
      focusTitle: focusTitle,
      shortBreakTitle: shortBreakLabel,
      longBreakTitle: longBreakLabel,
      pausedTitle: pausedLabel,
      focusBlockTitle: nativeFocusBlockTitle,
      breakBlockTitle: nativeBreakBlockTitle,
      topPriorityLabel: liveActivityTopPriorityLabel,
      focusInProgressTitle: notificationFocusInProgressTitle,
      shortBreakInProgressTitle: notificationShortBreakInProgressTitle,
      longBreakInProgressTitle: notificationLongBreakInProgressTitle,
      remainingTimeFormat: notificationRemainingTimeFormat,
      focusCompleteTitle: notificationFocusCompleteTitle,
      breakCompleteTitle: notificationBreakCompleteTitle,
      focusCompleteBody: notificationFocusCompleteBody,
      breakCompleteBody: notificationBreakCompleteBody,
    );
  }
}
