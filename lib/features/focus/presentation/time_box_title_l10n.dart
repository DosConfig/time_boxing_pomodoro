import 'package:flutter/widgets.dart';
import 'package:pomodoro_method_channel/l10n/l10n.dart';

import '../domain/entities/pomodoro.dart';

String localizedTimeBoxTitle(BuildContext context, TimeBox box) {
  final l10n = context.l10n;
  return switch (box.id) {
    'box-0900' => l10n.defaultTimeBoxTopPriority,
    'box-1000' => l10n.defaultTimeBoxDeepWork,
    'box-1100' => l10n.defaultTimeBoxAdmin,
    'box-1330' => l10n.defaultTimeBoxSecondPriority,
    'box-1500' => l10n.defaultTimeBoxFollowUp,
    _ => box.title == 'New time box' ? l10n.newTimeBoxDefaultTitle : box.title,
  };
}

String localizedPomodoroTimeBoxTitle(BuildContext context, Pomodoro pomodoro) {
  final activeBox = pomodoro.activeTimeBox;
  final rawTitle = pomodoro.liveActivityTimeBoxTitle;
  if (activeBox == null) {
    return rawTitle;
  }

  final isActiveDefault =
      rawTitle == activeBox.title ||
      rawTitle == 'Top priority' ||
      rawTitle == 'Deep work' ||
      rawTitle == 'Admin' ||
      rawTitle == 'Second priority' ||
      rawTitle == 'Follow-up' ||
      rawTitle == 'New time box';
  return isActiveDefault ? localizedTimeBoxTitle(context, activeBox) : rawTitle;
}
