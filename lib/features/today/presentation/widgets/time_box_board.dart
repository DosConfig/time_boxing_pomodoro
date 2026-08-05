import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_boxing_pomodoro/l10n/l10n.dart';

import '../../../focus/application/pomodoro_controller.dart';
import '../../../focus/domain/entities/daily_plan_item_category.dart';
import '../../../focus/domain/entities/pomodoro.dart';
import '../../../focus/presentation/time_box_title_display.dart';
import '../../../settings/application/app_preferences_controller.dart';
import '../../application/today_ui_controller.dart';
import 'carry_over_picker_sheet.dart';
import 'daily_carry_over_button.dart';
import 'today_section_card.dart';

/// 자정 넘김 창(dayEnd > 24:00)에서 이른 새벽 시각을 창 기준 선형 분으로
/// 보정한다. 예: 창이 09:00~26:00일 때 01:00(60분)은 25:00(1500분)이 된다.
int wrapMinutesForWindow(int minutes, int dayEnd) {
  const dayLength = 24 * 60;
  if (dayEnd > dayLength && minutes < dayEnd - dayLength) {
    return minutes + dayLength;
  }
  return minutes;
}

sealed class TimeBoxBoardDragPayload {
  const TimeBoxBoardDragPayload();

  int get durationSeconds;
}

class ScheduledTimeBoxDragPayload extends TimeBoxBoardDragPayload {
  final String id;
  final int slotMinutes;
  @override
  final int durationSeconds;
  int grabOffsetSlots;

  ScheduledTimeBoxDragPayload({
    required this.id,
    required this.durationSeconds,
    required this.slotMinutes,
    this.grabOffsetSlots = 0,
  });

  void updateGrabOffset(double localDy, double cardHeight) {
    final slotCount = (durationSeconds / (slotMinutes * 60)).ceil().clamp(
      1,
      96,
    );
    final normalizedPosition = cardHeight <= 0
        ? 0.0
        : (localDy / cardHeight).clamp(0.0, 0.9999);
    grabOffsetSlots = (normalizedPosition * slotCount).floor();
  }
}

class DraftTimeBoxDragPayload extends TimeBoxBoardDragPayload {
  final DailyPlanItemCategory source;
  final int index;
  final String title;
  @override
  final int durationSeconds;

  const DraftTimeBoxDragPayload({
    required this.source,
    required this.index,
    required this.title,
    this.durationSeconds = 30 * 60,
  });
}

class TimeBoxBoard extends ConsumerWidget {
  final Pomodoro pomodoro;
  final PomodoroController notifier;
  final DateTime now;
  final int awakeStartMinutes;
  final int awakeEndMinutes;
  final int slotMinutes;
  final CarryOverSection? loadingCarryOverSection;
  final ValueChanged<CarryOverSection> onCarryOverPressed;
  final VoidCallback onDragStarted;
  final ValueChanged<DragUpdateDetails> onDragUpdate;
  final VoidCallback onDragEnd;

  const TimeBoxBoard({
    super.key,
    required this.pomodoro,
    required this.notifier,
    required this.now,
    required this.awakeStartMinutes,
    required this.awakeEndMinutes,
    required this.slotMinutes,
    required this.loadingCarryOverSection,
    required this.onCarryOverPressed,
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  static const _timelineWidth = 58.0;

  double get _slotHeight {
    final baseHeight = slotMinutes == 15 ? 44.0 : 70.0;
    final scheduledDurations = pomodoro.timeBoxes
        .map((box) => box.rangeDurationSeconds ?? box.durationSeconds)
        .where((duration) => duration > 0)
        .map((duration) => duration / 60);
    if (scheduledDurations.isEmpty) {
      return baseHeight;
    }

    final shortestDurationMinutes = scheduledDurations.reduce(
      (shortest, duration) => duration < shortest ? duration : shortest,
    );
    final minimumReadableHeight = 44 * (slotMinutes / shortestDurationMinutes);
    return minimumReadableHeight > baseHeight
        ? minimumReadableHeight
        : baseHeight;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final dayStart = _dayStartMinutes();
    final dayEnd = _dayEndMinutes(dayStart);
    final slotCount = ((dayEnd - dayStart) / slotMinutes).ceil();
    final boardHeight = slotCount * _slotHeight;
    final nowMinutes = wrapMinutesForWindow(_nowMinutes(), dayEnd);
    final actionTimeBoxId = ref.watch(todayTimeBoxActionControllerProvider);
    final resizeTimeBoxId = ref.watch(todayTimeBoxResizeModeControllerProvider);
    final interactionActive =
        actionTimeBoxId.isNotEmpty || resizeTimeBoxId.isNotEmpty;

    return TodaySectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            key: const ValueKey('timebox_board_title'),
            context.l10n.timeBoxesTitle,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.timeBoxesHint,
            style: TextStyle(
              color: colors.onSurface.withValues(alpha: 0.42),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: DailyCarryOverButton(
              label: context.l10n.carryOverPreviousSchedule,
              isLoading: loadingCarryOverSection == CarryOverSection.timeBox,
              onPressed: loadingCarryOverSection == null
                  ? () => onCarryOverPressed(CarryOverSection.timeBox)
                  : null,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: boardHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ...List.generate(slotCount, (index) {
                    final slotStart = dayStart + (index * slotMinutes);
                    final isCurrentSlot =
                        nowMinutes >= slotStart &&
                        nowMinutes < slotStart + slotMinutes;
                    final occupied = !_slotCanFit(slotStart, slotMinutes * 60);

                    return Positioned(
                      top: index * _slotHeight,
                      left: 0,
                      right: 0,
                      height: _slotHeight,
                      child: DragTarget<TimeBoxBoardDragPayload>(
                        onWillAcceptWithDetails: (details) => _slotCanFit(
                          _dropStartMinutes(details.data, slotStart),
                          _effectiveDurationSeconds(details.data),
                          movingBoxId:
                              details.data is ScheduledTimeBoxDragPayload
                              ? (details.data as ScheduledTimeBoxDragPayload).id
                              : null,
                        ),
                        onAcceptWithDetails: (details) {
                          HapticFeedback.mediumImpact();
                          _acceptDragPayload(
                            details.data,
                            _dropStartMinutes(details.data, slotStart),
                          );
                        },
                        builder: (context, candidates, rejected) {
                          final isTargeted = candidates.isNotEmpty;
                          return GestureDetector(
                            key: ValueKey('timebox_slot_$slotStart'),
                            behavior: HitTestBehavior.opaque,
                            onTap: interactionActive
                                ? () => _clearTimeBoxInteraction(ref)
                                : occupied
                                ? null
                                : () =>
                                      _openNewTimeBoxEditor(context, slotStart),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 140),
                              curve: Curves.easeOutCubic,
                              color: isTargeted
                                  ? const Color(
                                      0xFFF6F3EC,
                                    ).withValues(alpha: 0.12)
                                  : rejected.isNotEmpty
                                  ? const Color(
                                      0xFFFF8D8D,
                                    ).withValues(alpha: 0.08)
                                  : isCurrentSlot
                                  ? Colors.white.withValues(alpha: 0.055)
                                  : Colors.transparent,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: _timelineWidth,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 7),
                                      child: Text(
                                        _formatClock(slotStart),
                                        style: TextStyle(
                                          color: isCurrentSlot
                                              ? const Color(0xFFF6F3EC)
                                              : Colors.white.withValues(
                                                  alpha: 0.36,
                                                ),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 13),
                                      height: 1,
                                      color: Colors.white.withValues(
                                        alpha: isCurrentSlot ? 0.2 : 0.08,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  if (interactionActive)
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => _clearTimeBoxInteraction(ref),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ...pomodoro.timeBoxes.map(
                    (box) => _PositionedTimeBox(
                      key: ValueKey(box.id),
                      box: box,
                      title: displayTimeBoxTitle(box),
                      activeTimeBoxId: pomodoro.activeTimeBox?.id,
                      dayStart: dayStart,
                      dayEnd: dayEnd,
                      slotMinutes: slotMinutes,
                      slotHeight: _slotHeight,
                      current: _containsNow(box),
                      actionsActive: actionTimeBoxId == box.id,
                      onDragStarted: onDragStarted,
                      onDragUpdate: onDragUpdate,
                      onDragEnd: onDragEnd,
                      onTap: () => _toggleTimeBoxActions(ref, box.id),
                      onEdit: () => _openTimeBoxEditor(context, box),
                      onResizeStartMinutes: (startMinutes) =>
                          notifier.resizeTimeBoxStart(
                            box.id,
                            wrapMinutesForWindow(startMinutes, dayEnd),
                            minStartMinutes: dayStart,
                            stepMinutes: slotMinutes,
                          ),
                      onResizeEndMinutes: (endMinutes) =>
                          notifier.resizeTimeBoxEnd(
                            box.id,
                            wrapMinutesForWindow(endMinutes, dayEnd),
                            maxEndMinutes: dayEnd,
                            stepMinutes: slotMinutes,
                          ),
                    ),
                  ),
                  if (nowMinutes >= dayStart && nowMinutes <= dayEnd)
                    Positioned(
                      top:
                          ((nowMinutes - dayStart) / slotMinutes) * _slotHeight,
                      left: _timelineWidth - 4,
                      right: 0,
                      child: const _NowTimelineIndicator(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openNewTimeBoxEditor(BuildContext context, int slotStart) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _TimeBoxEditorSheet(
          notifier: notifier,
          startMinutes: slotStart,
          slotMinutes: slotMinutes,
          timeRange: _formatTimeRange(slotStart, slotMinutes),
          fallbackTitle: context.l10n.newTimeBoxDefaultTitle,
        );
      },
    );
  }

  void _openTimeBoxEditor(BuildContext context, TimeBox box) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _TimeBoxEditorSheet(
          box: box,
          notifier: notifier,
          timeRange: box.timeRange,
          fallbackTitle: context.l10n.newTimeBoxDefaultTitle,
        );
      },
    );
  }

  int _dayStartMinutes() {
    return (awakeStartMinutes ~/ slotMinutes) * slotMinutes;
  }

  int _dayEndMinutes(int dayStart) {
    final end =
        ((awakeEndMinutes + slotMinutes - 1) ~/ slotMinutes) * slotMinutes;
    if (end <= dayStart) {
      return dayStart + (4 * 60);
    }
    // 자정 넘김 창(예: 09:00~다음날 01:00)을 지원한다.
    return end.clamp(
      dayStart + slotMinutes,
      AppPreferencesController.maximumAwakeEndMinutes,
    );
  }

  int _nowMinutes() => (now.hour * 60) + now.minute;

  bool _containsNow(TimeBox box) {
    final start = box.startMinutes;
    final end = box.endMinutes;
    if (start == null || end == null) {
      return false;
    }

    var nowMinutes = _nowMinutes();
    if (end >= 24 * 60 && nowMinutes < start) {
      nowMinutes += 24 * 60;
    }
    return nowMinutes >= start && nowMinutes < end;
  }

  String _formatClock(int minutes) {
    final normalized = minutes % (24 * 60);
    final hour = normalized ~/ 60;
    final minute = normalized % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String _formatTimeRange(int startMinutes, int durationMinutes) {
    return '${_formatClock(startMinutes)}-${_formatClock(startMinutes + durationMinutes)}';
  }

  void _acceptDragPayload(TimeBoxBoardDragPayload payload, int startMinutes) {
    switch (payload) {
      case ScheduledTimeBoxDragPayload(:final id):
        notifier.moveTimeBoxToStart(id, startMinutes);
      case DraftTimeBoxDragPayload(:final source, :final index):
        switch (source) {
          case DailyPlanItemCategory.brainDump:
            notifier.scheduleBrainDumpItemAtStart(
              index,
              startMinutes,
              durationMinutes: slotMinutes,
            );
          case DailyPlanItemCategory.topPriority:
            notifier.scheduleTopPriorityAtStart(
              index,
              startMinutes,
              durationMinutes: slotMinutes,
            );
          case DailyPlanItemCategory.reminder:
            notifier.scheduleReminderAtStart(
              index,
              startMinutes,
              durationMinutes: slotMinutes,
            );
        }
    }
  }

  int _dropStartMinutes(TimeBoxBoardDragPayload payload, int hoveredSlotStart) {
    if (payload case ScheduledTimeBoxDragPayload(:final grabOffsetSlots)) {
      return hoveredSlotStart - (grabOffsetSlots * slotMinutes);
    }
    return hoveredSlotStart;
  }

  void _toggleTimeBoxActions(WidgetRef ref, String id) {
    ref.read(todayTimeBoxResizeModeControllerProvider.notifier).clear();
    ref.read(todayTimeBoxResizeDragControllerProvider.notifier).end(id);
    ref.read(todayTimeBoxActionControllerProvider.notifier).toggle(id);
    HapticFeedback.selectionClick();
  }

  void _clearTimeBoxInteraction(WidgetRef ref) {
    ref.read(todayTimeBoxActionControllerProvider.notifier).clear();
    ref.read(todayTimeBoxResizeModeControllerProvider.notifier).clear();
  }

  bool _slotCanFit(int slotStart, int durationSeconds, {String? movingBoxId}) {
    if (slotStart < _dayStartMinutes()) {
      return false;
    }
    final dayEnd = _dayEndMinutes(_dayStartMinutes());
    final durationMinutes = (durationSeconds / 60).round();
    final slotEnd = slotStart + durationMinutes;
    if (slotEnd > dayEnd) {
      return false;
    }
    return !pomodoro.timeBoxes.any((box) {
      if (box.id == movingBoxId) {
        return false;
      }
      final rawStart = box.startMinutes;
      if (rawStart == null || box.endMinutes == null) {
        return false;
      }
      final start = wrapMinutesForWindow(rawStart, dayEnd);
      final end = start + (box.endMinutes! - rawStart);
      return slotStart < end && slotEnd > start;
    });
  }

  int _effectiveDurationSeconds(TimeBoxBoardDragPayload payload) {
    return payload is DraftTimeBoxDragPayload
        ? slotMinutes * 60
        : payload.durationSeconds;
  }
}

class _NowTimelineIndicator extends StatelessWidget {
  const _NowTimelineIndicator();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFF080808),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF6F3EC), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.34),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF080808).withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F3EC),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PositionedTimeBox extends StatelessWidget {
  final TimeBox box;
  final String title;
  final String? activeTimeBoxId;
  final int dayStart;
  final int dayEnd;
  final int slotMinutes;
  final double slotHeight;
  final bool current;
  final bool actionsActive;
  final VoidCallback onDragStarted;
  final ValueChanged<DragUpdateDetails> onDragUpdate;
  final VoidCallback onDragEnd;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final ValueChanged<int> onResizeStartMinutes;
  final ValueChanged<int> onResizeEndMinutes;

  const _PositionedTimeBox({
    super.key,
    required this.box,
    required this.title,
    required this.activeTimeBoxId,
    required this.dayStart,
    required this.dayEnd,
    required this.slotMinutes,
    required this.slotHeight,
    required this.current,
    required this.actionsActive,
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onTap,
    required this.onEdit,
    required this.onResizeStartMinutes,
    required this.onResizeEndMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final rawStart = box.startMinutes;
    final rawEnd = box.endMinutes;
    if (rawStart == null || rawEnd == null) {
      return const SizedBox.shrink();
    }
    // 자정 넘김 창에서 새벽 시각(예: 01:00)을 창 기준 선형 분으로 보정한다.
    final start = wrapMinutesForWindow(rawStart, dayEnd);
    final end = start + (rawEnd - rawStart);
    if (end <= dayStart || start >= dayEnd) {
      return const SizedBox.shrink();
    }

    final visibleStart = start < dayStart ? dayStart : start;
    final visibleEnd = end > dayEnd ? dayEnd : end;
    final minuteHeight = slotHeight / slotMinutes;
    final occupiedHeight = (visibleEnd - visibleStart) * minuteHeight;
    final edgeInset = occupiedHeight < 44 ? 1.0 : 4.0;
    final top = ((visibleStart - dayStart) * minuteHeight) + edgeInset;
    final height = (occupiedHeight - (edgeInset * 2))
        .clamp(24.0, double.infinity)
        .toDouble();

    return Positioned(
      top: top,
      left: TimeBoxBoard._timelineWidth,
      right: 0,
      height: height,
      child: _TimeBoxBoardCard(
        box: box,
        title: title,
        cardHeight: height,
        selected: box.id == activeTimeBoxId,
        current: current,
        actionsActive: actionsActive,
        slotMinutes: slotMinutes,
        resizeStepDragDistance: slotHeight,
        onDragStarted: onDragStarted,
        onDragUpdate: onDragUpdate,
        onDragEnd: onDragEnd,
        onTap: onTap,
        onEdit: onEdit,
        onResizeStartMinutes: onResizeStartMinutes,
        onResizeEndMinutes: onResizeEndMinutes,
      ),
    );
  }
}

class _TimeBoxBoardCard extends ConsumerWidget {
  final TimeBox box;
  final String title;
  final double cardHeight;
  final bool selected;
  final bool current;
  final bool actionsActive;
  final int slotMinutes;
  final double resizeStepDragDistance;
  final VoidCallback onDragStarted;
  final ValueChanged<DragUpdateDetails> onDragUpdate;
  final VoidCallback onDragEnd;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final ValueChanged<int> onResizeStartMinutes;
  final ValueChanged<int> onResizeEndMinutes;

  const _TimeBoxBoardCard({
    required this.box,
    required this.title,
    required this.cardHeight,
    required this.selected,
    required this.current,
    required this.actionsActive,
    required this.slotMinutes,
    required this.resizeStepDragDistance,
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onTap,
    required this.onEdit,
    required this.onResizeStartMinutes,
    required this.onResizeEndMinutes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resizeModeActive =
        ref.watch(todayTimeBoxResizeModeControllerProvider) == box.id;
    final dragPayload = ScheduledTimeBoxDragPayload(
      id: box.id,
      durationSeconds: box.rangeDurationSeconds ?? box.durationSeconds,
      slotMinutes: slotMinutes,
    );
    final surface = _TimeBoxBoardCardSurface(
      title: title,
      selected: selected,
      current: current,
      reserveResizeHandle: resizeModeActive,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: _DraggableTimeBoxCard(
            // The resize handles own only the top and bottom strips. Keep the
            // card body draggable so a tall card never gets stuck in resize
            // mode with an inert middle area.
            enabled: true,
            payload: dragPayload,
            title: title,
            selected: selected,
            current: current,
            feedbackHeight: cardHeight,
            onTap: onTap,
            onDragStarted: () => _handleMoveStart(ref),
            onDragUpdate: onDragUpdate,
            onDragEnd: onDragEnd,
            child: surface,
          ),
        ),
        if (actionsActive && !resizeModeActive)
          Positioned(
            top: cardHeight < 44 ? 1 : 6,
            right: 6,
            child: _TimeBoxCardActionOverlay(
              selected: selected,
              compact: cardHeight < 44,
              onEdit: () => _handleEdit(ref),
              onResize: () => _activateResizeMode(ref),
            ),
          ),
        if (resizeModeActive)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 14,
            child: _TimeBoxResizeHandle(
              selected: selected,
              edge: _ResizeEdge.start,
              onDragStart: () => _handleResizeStart(ref),
              onDragUpdate: (delta) =>
                  _handleResizeUpdate(ref, delta, _ResizeEdge.start),
              onDragEnd: () => _handleResizeEnd(ref),
            ),
          ),
        if (resizeModeActive)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 14,
            child: _TimeBoxResizeHandle(
              selected: selected,
              edge: _ResizeEdge.end,
              onDragStart: () => _handleResizeStart(ref),
              onDragUpdate: (delta) =>
                  _handleResizeUpdate(ref, delta, _ResizeEdge.end),
              onDragEnd: () => _handleResizeEnd(ref),
            ),
          ),
      ],
    );
  }

  void _handleMoveStart(WidgetRef ref) {
    ref.read(todayTimeBoxActionControllerProvider.notifier).clear();
    ref.read(todayTimeBoxResizeModeControllerProvider.notifier).clear();
    ref.read(todayTimeBoxResizeDragControllerProvider.notifier).end(box.id);
    onDragStarted();
  }

  void _handleEdit(WidgetRef ref) {
    ref.read(todayTimeBoxActionControllerProvider.notifier).clear();
    ref.read(todayTimeBoxResizeModeControllerProvider.notifier).clear();
    onEdit();
  }

  void _activateResizeMode(WidgetRef ref) {
    ref.read(todayTimeBoxActionControllerProvider.notifier).clear();
    ref
        .read(todayTimeBoxResizeModeControllerProvider.notifier)
        .activate(box.id);
    ref.read(todayTimeBoxResizeDragControllerProvider.notifier).end(box.id);
    HapticFeedback.selectionClick();
  }

  void _handleResizeStart(WidgetRef ref) {
    ref.read(todayTimeBoxActionControllerProvider.notifier).clear();
    ref
        .read(todayTimeBoxResizeModeControllerProvider.notifier)
        .activate(box.id);
    ref.read(todayTimeBoxResizeDragControllerProvider.notifier).start(box.id);
    HapticFeedback.selectionClick();
  }

  void _handleResizeUpdate(WidgetRef ref, double deltaDy, _ResizeEdge edge) {
    final slotDelta = ref
        .read(todayTimeBoxResizeDragControllerProvider.notifier)
        .consumeSlotDelta(box.id, deltaDy, resizeStepDragDistance);
    if (slotDelta == 0) {
      return;
    }

    switch (edge) {
      case _ResizeEdge.start:
        final start = box.startMinutes;
        if (start == null) {
          return;
        }
        onResizeStartMinutes(start + (slotDelta * slotMinutes));
      case _ResizeEdge.end:
        final end = box.endMinutes;
        if (end == null) {
          return;
        }
        onResizeEndMinutes(end + (slotDelta * slotMinutes));
    }
    HapticFeedback.selectionClick();
  }

  void _handleResizeEnd(WidgetRef ref) {
    ref.read(todayTimeBoxResizeDragControllerProvider.notifier).end(box.id);
  }
}

class _DraggableTimeBoxCard extends StatelessWidget {
  final bool enabled;
  final ScheduledTimeBoxDragPayload payload;
  final String title;
  final bool selected;
  final bool current;
  final double feedbackHeight;
  final VoidCallback onTap;
  final VoidCallback onDragStarted;
  final ValueChanged<DragUpdateDetails> onDragUpdate;
  final VoidCallback onDragEnd;
  final Widget child;

  const _DraggableTimeBoxCard({
    required this.enabled,
    required this.payload,
    required this.title,
    required this.selected,
    required this.current,
    required this.feedbackHeight,
    required this.onTap,
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final feedbackWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - 112;
        final compactFeedbackHeight = feedbackHeight.clamp(36.0, 88.0);

        return Listener(
          onPointerDown: (event) {
            payload.updateGrabOffset(event.localPosition.dy, feedbackHeight);
          },
          child: LongPressDraggable<TimeBoxBoardDragPayload>(
            data: payload,
            maxSimultaneousDrags: enabled ? 1 : 0,
            delay: const Duration(milliseconds: 220),
            dragAnchorStrategy: (draggable, dragContext, globalPosition) {
              final renderBox = dragContext.findRenderObject() as RenderBox;
              final localPosition = renderBox.globalToLocal(globalPosition);
              final sourceHeight = renderBox.size.height;
              final verticalRatio = sourceHeight <= 0
                  ? 0.5
                  : (localPosition.dy / sourceHeight).clamp(0.0, 1.0);
              // 실제 카드는 길어도 feedback은 최대 88px로 줄어든다. 원본
              // 좌표를 그대로 anchor로 쓰면 feedback이 엄지에서 멀어지므로
              // 잡은 비율을 축소된 preview 높이에 맞춰 다시 계산한다.
              return Offset(
                localPosition.dx.clamp(0.0, renderBox.size.width),
                compactFeedbackHeight * verticalRatio,
              );
            },
            feedback: Material(
              color: Colors.transparent,
              child: Transform.rotate(
                angle: -0.025,
                child: SizedBox(
                  key: ValueKey('timeBoxDragFeedback-${payload.id}'),
                  width: feedbackWidth,
                  height: compactFeedbackHeight,
                  child: _TimeBoxBoardCardSurface(
                    title: title,
                    selected: selected,
                    current: current,
                    feedback: true,
                  ),
                ),
              ),
            ),
            // 원래 위치는 잔상으로만 남기고 hit test에서는 제외한다. 높이가 큰
            // 카드 안에서 한 슬롯만 움직여도 아래 DragTarget이 drop을 받아야 한다.
            childWhenDragging: IgnorePointer(
              child: Opacity(opacity: 0.22, child: child),
            ),
            onDragStarted: onDragStarted,
            onDragUpdate: onDragUpdate,
            onDragEnd: (_) => onDragEnd(),
            onDragCompleted: onDragEnd,
            onDraggableCanceled: (_, _) => onDragEnd(),
            child: Tooltip(
              message: context.l10n.dragTimeBoxTooltip,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TimeBoxBoardCardSurface extends StatelessWidget {
  final String title;
  final bool selected;
  final bool current;
  final bool feedback;
  final bool reserveResizeHandle;

  const _TimeBoxBoardCardSurface({
    required this.title,
    required this.selected,
    required this.current,
    this.feedback = false,
    this.reserveResizeHandle = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFFF6F3EC)
            : current
            ? Colors.white.withValues(alpha: 0.16)
            : const Color(0xFF202020),
        border: Border.all(
          color: selected
              ? const Color(0xFFF6F3EC)
              : current
              ? const Color(0xFFF6F3EC).withValues(alpha: 0.46)
              : Colors.white.withValues(alpha: feedback ? 0.3 : 0.14),
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: feedback
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.38),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final veryCompact = constraints.maxHeight < 44;
          final compact = constraints.maxHeight < 70;
          final bottomInset = !reserveResizeHandle
              ? (veryCompact ? 3.0 : 8.0)
              : compact
              ? 10.0
              : 16.0;
          final topInset = !reserveResizeHandle
              ? (veryCompact
                    ? 3.0
                    : compact
                    ? 7.0
                    : 10.0)
              : compact
              ? 10.0
              : 16.0;
          const rightInset = 12.0;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                left: 12,
                top: topInset,
                right: rightInset,
                bottom: bottomInset,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _TimeBoxBoardCardText(
                    title: title,
                    selected: selected,
                    current: current,
                    compact: compact,
                    veryCompact: veryCompact,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TimeBoxBoardCardText extends StatelessWidget {
  final String title;
  final bool selected;
  final bool current;
  final bool compact;
  final bool veryCompact;

  const _TimeBoxBoardCardText({
    required this.title,
    required this.selected,
    required this.current,
    required this.compact,
    required this.veryCompact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (current && !selected && !compact) ...[
          Text(
            context.l10n.nowBadge,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.54),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          title,
          maxLines: compact ? 1 : 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selected ? const Color(0xFF080808) : const Color(0xFFF6F3EC),
            fontSize: veryCompact
                ? 9
                : compact
                ? 14
                : 15,
            fontWeight: FontWeight.w900,
            height: veryCompact
                ? 1.0
                : compact
                ? 1.0
                : 1.08,
          ),
        ),
      ],
    );
  }
}

enum _ResizeEdge { start, end }

class _TimeBoxResizeHandle extends StatelessWidget {
  final bool selected;
  final _ResizeEdge edge;
  final VoidCallback onDragStart;
  final ValueChanged<double> onDragUpdate;
  final VoidCallback onDragEnd;

  const _TimeBoxResizeHandle({
    required this.selected,
    required this.edge,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? const Color(0xFF080808)
        : const Color(0xFFF6F3EC);

    return Tooltip(
      message: context.l10n.resizeTimeBoxActiveTooltip,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) => onDragStart(),
        onPointerMove: (event) => onDragUpdate(event.delta.dy),
        onPointerUp: (_) => onDragEnd(),
        onPointerCancel: (_) => onDragEnd(),
        child: Align(
          alignment: edge == _ResizeEdge.start
              ? Alignment.topCenter
              : Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            width: 36,
            height: 3,
            margin: edge == _ResizeEdge.start
                ? const EdgeInsets.only(top: 3)
                : const EdgeInsets.only(bottom: 3),
            decoration: BoxDecoration(
              color: foreground.withValues(alpha: 0.66),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeBoxCardActionOverlay extends StatelessWidget {
  final bool selected;
  final bool compact;
  final VoidCallback onEdit;
  final VoidCallback onResize;

  const _TimeBoxCardActionOverlay({
    required this.selected,
    required this.compact,
    required this.onEdit,
    required this.onResize,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? const Color(0xFF080808)
        : const Color(0xFFF6F3EC);
    final background = selected
        ? const Color(0xFFF6F3EC).withValues(alpha: 0.88)
        : const Color(0xFF080808).withValues(alpha: 0.72);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: foreground.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TimeBoxCardActionButton(
            icon: Icons.edit_rounded,
            label: context.l10n.editAction,
            foreground: foreground,
            compact: compact,
            onPressed: onEdit,
          ),
          Container(
            width: 1,
            height: compact ? 12 : 18,
            color: foreground.withValues(alpha: 0.12),
          ),
          _TimeBoxCardActionButton(
            icon: Icons.unfold_more_rounded,
            label: context.l10n.resizeTimeBoxTooltip,
            foreground: foreground,
            compact: compact,
            onPressed: onResize,
          ),
        ],
      ),
    );
  }
}

class _TimeBoxCardActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color foreground;
  final bool compact;
  final VoidCallback onPressed;

  const _TimeBoxCardActionButton({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.compact,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: compact ? 14 : 17),
        color: foreground,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tightFor(
          width: compact ? 24 : 34,
          height: compact ? 24 : 34,
        ),
      ),
    );
  }
}

class _TimeBoxEditorSheet extends StatefulWidget {
  final TimeBox? box;
  final PomodoroController notifier;
  final int? startMinutes;
  final int slotMinutes;
  final String timeRange;
  final String fallbackTitle;

  const _TimeBoxEditorSheet({
    this.box,
    required this.notifier,
    this.startMinutes,
    this.slotMinutes = 30,
    required this.timeRange,
    required this.fallbackTitle,
  });

  @override
  State<_TimeBoxEditorSheet> createState() => _TimeBoxEditorSheetState();
}

class _TimeBoxEditorSheetState extends State<_TimeBoxEditorSheet> {
  late final TextEditingController _titleController;
  late Set<int> _repeatWeekdays;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.box?.title ?? '');
    _repeatWeekdays = {...?widget.box?.repeatWeekdays};
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 18, 20, bottomInset + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.box == null
                        ? context.l10n.newTimeBoxTitle
                        : context.l10n.editTimeBoxTitle,
                    style: const TextStyle(
                      color: Color(0xFFF6F3EC),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: const Color(0xFFF6F3EC),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _TimeBoxTextField(
              key: const ValueKey('timebox_title_field'),
              controller: _titleController,
              label: context.l10n.titleLabel,
              textInputAction: TextInputAction.done,
              autofocus: true,
              onSubmitted: (_) => _save(context),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(
                context.l10n.timeBoxRange(widget.timeRange),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.52),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _TimeBoxRepeatSelector(
              selectedWeekdays: _repeatWeekdays,
              onChanged: (weekdays) {
                setState(() {
                  _repeatWeekdays = weekdays;
                });
              },
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const ValueKey('timebox_save'),
              onPressed: () => _save(context),
              icon: const Icon(Icons.check_rounded),
              label: Text(context.l10n.saveAction),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save(BuildContext context) {
    HapticFeedback.lightImpact();
    final box = widget.box;
    if (box == null) {
      final startMinutes = widget.startMinutes;
      if (startMinutes != null) {
        widget.notifier.addTimeBoxAtStart(
          startMinutes,
          durationSeconds: widget.slotMinutes * 60,
          durationStepMinutes: widget.slotMinutes,
          title: _titleController.text.trim().isEmpty
              ? widget.fallbackTitle
              : _titleController.text,
          repeatWeekdays: _repeatWeekdays.toList()..sort(),
        );
      }
    } else {
      widget.notifier.updateTimeBox(
        box.id,
        title: _titleController.text,
        repeatWeekdays: _repeatWeekdays.toList()..sort(),
      );
    }
    Navigator.of(context).pop();
  }
}

class _TimeBoxRepeatSelector extends StatelessWidget {
  final Set<int> selectedWeekdays;
  final ValueChanged<Set<int>> onChanged;

  const _TimeBoxRepeatSelector({
    required this.selectedWeekdays,
    required this.onChanged,
  });

  static const _weekdays = [
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
    DateTime.saturday,
    DateTime.sunday,
  ];

  @override
  Widget build(BuildContext context) {
    final dailySelected = selectedWeekdays.length == 7;
    final weekdaysSelected =
        selectedWeekdays.length == 5 &&
        selectedWeekdays.containsAll(_weekdays.take(5));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.repeatTimeBoxLabel,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.52),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _RepeatPresetButton(
              label: context.l10n.repeatNone,
              selected: selectedWeekdays.isEmpty,
              onTap: () => onChanged(<int>{}),
            ),
            _RepeatPresetButton(
              label: context.l10n.repeatDaily,
              selected: dailySelected,
              onTap: () => onChanged({..._weekdays}),
            ),
            _RepeatPresetButton(
              label: context.l10n.repeatWeekdays,
              selected: weekdaysSelected,
              onTap: () => onChanged({..._weekdays.take(5)}),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final weekday in _weekdays)
              _RepeatWeekdayChip(
                label: _weekdayLabel(context, weekday),
                selected: selectedWeekdays.contains(weekday),
                onTap: () {
                  final nextWeekdays = {...selectedWeekdays};
                  if (nextWeekdays.contains(weekday)) {
                    nextWeekdays.remove(weekday);
                  } else {
                    nextWeekdays.add(weekday);
                  }
                  onChanged(nextWeekdays);
                },
              ),
          ],
        ),
      ],
    );
  }

  String _weekdayLabel(BuildContext context, int weekday) {
    return switch (weekday) {
      DateTime.monday => context.l10n.weekdayMonNarrow,
      DateTime.tuesday => context.l10n.weekdayTueNarrow,
      DateTime.wednesday => context.l10n.weekdayWedNarrow,
      DateTime.thursday => context.l10n.weekdayThuNarrow,
      DateTime.friday => context.l10n.weekdayFriNarrow,
      DateTime.saturday => context.l10n.weekdaySatNarrow,
      DateTime.sunday => context.l10n.weekdaySunNarrow,
      _ => '',
    };
  }
}

class _RepeatPresetButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RepeatPresetButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      selected: selected,
      checkmarkColor: const Color(0xFF080808),
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFFF6F3EC),
      backgroundColor: Colors.white.withValues(alpha: 0.055),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      labelStyle: TextStyle(
        color: selected ? const Color(0xFF080808) : const Color(0xFFF6F3EC),
        fontSize: 12,
        fontWeight: FontWeight.w900,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class _RepeatWeekdayChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RepeatWeekdayChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: const Color(0xFFF6F3EC),
      backgroundColor: Colors.white.withValues(alpha: 0.035),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      labelStyle: TextStyle(
        color: selected ? const Color(0xFF080808) : const Color(0xFFF6F3EC),
        fontSize: 12,
        fontWeight: FontWeight.w900,
      ),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class _TimeBoxTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputAction textInputAction;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;

  const _TimeBoxTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.textInputAction,
    this.autofocus = false,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorColor: const Color(0xFFF6F3EC),
      textInputAction: textInputAction,
      autofocus: autofocus,
      onSubmitted: onSubmitted,
      maxLines: 1,
      style: const TextStyle(
        color: Color(0xFFF6F3EC),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.46),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFF6F3EC)),
        ),
      ),
    );
  }
}
