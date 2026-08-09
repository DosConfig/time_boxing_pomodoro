import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/calendar_sync_options.dart';

part 'calendar_sync_options_controller.g.dart';

@riverpod
class CalendarSyncOptionsController extends _$CalendarSyncOptionsController {
  @override
  CalendarSyncOptions build() => const CalendarSyncOptions();

  void setMode(CalendarSyncMode mode) {
    state = state.copyWith(mode: mode);
  }

  void setTopPrioritiesOnly(bool enabled) {
    state = state.copyWith(topPrioritiesOnly: enabled);
  }

  void setConflictCheck(bool enabled) {
    state = state.copyWith(conflictCheck: enabled);
  }

  void setDedicatedCalendar(bool enabled) {
    state = state.copyWith(dedicatedCalendar: enabled);
  }

  void setIncludeBreaks(bool enabled) {
    state = state.copyWith(includeBreaks: enabled);
  }
}
