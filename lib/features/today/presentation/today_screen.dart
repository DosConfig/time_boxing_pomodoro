import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:time_boxing_pomodoro/l10n/l10n.dart';

import '../../../shared/presentation/app_snack.dart';
import '../../focus/application/pomodoro_controller.dart';
import '../../focus/domain/entities/daily_plan_summary.dart';
import '../../focus/domain/entities/daily_plan_item_category.dart';
import '../../focus/domain/entities/pomodoro.dart';
import '../../focus/presentation/native_timer_copy_l10n.dart';
import '../../focus/presentation/time_box_title_display.dart';
import '../../settings/application/app_preferences_controller.dart';
import '../application/today_ui_controller.dart';
import 'widgets/carry_over_picker_sheet.dart';
import 'widgets/daily_carry_over_button.dart';
import 'widgets/daily_plan_item_row.dart';
import 'widgets/daily_plan_item_sheet.dart';
import 'widgets/day_history_sheet.dart';
import 'widgets/time_box_board.dart';
import 'widgets/today_section_card.dart';

class TodayScreen extends ConsumerStatefulWidget {
  final VoidCallback onOpenFocus;

  const TodayScreen({super.key, required this.onOpenFocus});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  Timer? _dragAutoScrollTimer;
  double _dragAutoScrollDelta = 0;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _stopDragAutoScroll();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pomodoro = ref.watch(pomodoroControllerProvider);
    final preferences = ref.watch(appPreferencesControllerProvider);
    final now = ref.watch(todayClockProvider);
    final history = ref.watch(dailyPlanHistoryProvider(days: 7));
    final isTimeBoxDragging = ref.watch(todayTimeBoxDragControllerProvider);
    final isTimeBoxResizing = ref
        .watch(todayTimeBoxResizeDragControllerProvider)
        .isNotEmpty;
    final notifier = ref.read(pomodoroControllerProvider.notifier);
    final priorities = pomodoro.topPrioritySlots;

    return SafeArea(
      child: Stack(
        children: [
          ScrollConfiguration(
            behavior: const _AppScrollBehavior(),
            child: CustomScrollView(
              key: const ValueKey('today_scroll'),
              controller: _scrollController,
              physics: isTimeBoxResizing
                  ? const NeverScrollableScrollPhysics()
                  : const ClampingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 32),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _TodayHeader(),
                        const SizedBox(height: 18),
                        _TopPrioritiesPanel(
                          priorities: priorities,
                          notifier: notifier,
                          onDragStarted: _beginDraftScheduleDrag,
                          onDragUpdate: _handleTimeBoxDragUpdate,
                          onDragEnd: _endDraftScheduleDrag,
                        ),
                        const SizedBox(height: 16),
                        _BrainDumpPanel(
                          pomodoro: pomodoro,
                          notifier: notifier,
                          onDragStarted: _beginDraftScheduleDrag,
                          onDragUpdate: _handleTimeBoxDragUpdate,
                          onDragEnd: _endDraftScheduleDrag,
                        ),
                        const SizedBox(height: 16),
                        _ReminderPanel(
                          pomodoro: pomodoro,
                          notifier: notifier,
                          onDragStarted: _beginDraftScheduleDrag,
                          onDragUpdate: _handleTimeBoxDragUpdate,
                          onDragEnd: _endDraftScheduleDrag,
                        ),
                        const SizedBox(height: 16),
                        TimeBoxBoard(
                          pomodoro: pomodoro,
                          notifier: notifier,
                          now: now,
                          awakeStartMinutes: preferences.awakeStartMinutes,
                          awakeEndMinutes: preferences.awakeEndMinutes,
                          slotMinutes: preferences.timeSlotInterval.minutes,
                          onDragStarted: _beginTimeBoxDrag,
                          onDragUpdate: _handleTimeBoxDragUpdate,
                          onDragEnd: _endTimeBoxDrag,
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          key: const ValueKey('start_focus'),
                          onPressed: () async {
                            final nativeCopy = context.l10n.nativeTimerCopy;
                            FocusScope.of(context).unfocus();
                            HapticFeedback.mediumImpact();
                            await notifier.selectCurrentTimeBoxForNow();
                            final syncedPomodoro = ref.read(
                              pomodoroControllerProvider,
                            );
                            if (!syncedPomodoro.canStartFocus) {
                              if (context.mounted) {
                                showAppSnack(
                                  context,
                                  context.l10n.currentTimeBoxRequired,
                                );
                              }
                              return;
                            }
                            await notifier.start(nativeCopy);
                            if (context.mounted) {
                              widget.onOpenFocus();
                            }
                          },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(
                            context.l10n.startFocus,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFF6F3EC),
                            foregroundColor: const Color(0xFF080808),
                            minimumSize: const Size.fromHeight(54),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _TodaySummaryPanel(
                          pomodoro: pomodoro,
                          priorities: priorities,
                          now: now,
                          history: history.asData?.value ?? const [],
                          onOpenFocus: widget.onOpenFocus,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _TimeBoxTrashTarget(
            visible: isTimeBoxDragging,
            enabled: pomodoro.timeBoxes.isNotEmpty,
            onAccept: (id) {
              HapticFeedback.heavyImpact();
              unawaited(notifier.removeTimeBox(id));
              _endTimeBoxDrag();
            },
          ),
        ],
      ),
    );
  }

  void _handleTimeBoxDragUpdate(DragUpdateDetails details) {
    if (!_scrollController.hasClients) {
      return;
    }

    final screenHeight = MediaQuery.sizeOf(context).height;
    final topEdge = MediaQuery.paddingOf(context).top + 92;
    final bottomEdge = screenHeight - 150;
    final y = details.globalPosition.dy;

    if (y < topEdge) {
      final intensity = ((topEdge - y) / 96).clamp(0.0, 1.0);
      _dragAutoScrollDelta = -(2.5 + (intensity * 10));
      _startDragAutoScroll();
      return;
    }

    if (y > bottomEdge) {
      final intensity = ((y - bottomEdge) / 96).clamp(0.0, 1.0);
      _dragAutoScrollDelta = 2.5 + (intensity * 10);
      _startDragAutoScroll();
      return;
    }

    _stopDragAutoScroll();
  }

  void _beginTimeBoxDrag() {
    HapticFeedback.mediumImpact();
    ref.read(todayTimeBoxDragControllerProvider.notifier).begin();
  }

  void _beginDraftScheduleDrag() {
    HapticFeedback.selectionClick();
  }

  void _endTimeBoxDrag() {
    _stopDragAutoScroll();
    ref.read(todayTimeBoxDragControllerProvider.notifier).end();
  }

  void _endDraftScheduleDrag() {
    _stopDragAutoScroll();
  }

  void _startDragAutoScroll() {
    _dragAutoScrollTimer ??= Timer.periodic(
      const Duration(milliseconds: 16),
      (_) => _tickDragAutoScroll(),
    );
  }

  void _tickDragAutoScroll() {
    if (!_scrollController.hasClients || _dragAutoScrollDelta == 0) {
      _stopDragAutoScroll();
      return;
    }

    final position = _scrollController.position;
    final nextOffset = (position.pixels + _dragAutoScrollDelta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    if (nextOffset == position.pixels) {
      _stopDragAutoScroll();
      return;
    }
    _scrollController.jumpTo(nextOffset);
  }

  void _stopDragAutoScroll() {
    _dragAutoScrollDelta = 0;
    _dragAutoScrollTimer?.cancel();
    _dragAutoScrollTimer = null;
  }
}

class _TodayHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.48),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.todayTitle,
          style: TextStyle(
            color: Color(0xFFF6F3EC),
            fontSize: 38,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _TimeBoxTrashTarget extends StatelessWidget {
  final bool visible;
  final bool enabled;
  final ValueChanged<String> onAccept;

  const _TimeBoxTrashTarget({
    required this.visible,
    required this.enabled,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 18,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: !visible,
        child: Center(
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            offset: visible ? Offset.zero : const Offset(0, 0.35),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: visible ? 1 : 0,
              child: DragTarget<TimeBoxBoardDragPayload>(
                onWillAcceptWithDetails: (details) =>
                    enabled && details.data is ScheduledTimeBoxDragPayload,
                onAcceptWithDetails: (details) {
                  final payload = details.data;
                  if (payload is ScheduledTimeBoxDragPayload) {
                    onAccept(payload.id);
                  }
                },
                builder: (context, candidates, rejected) {
                  final targeted = candidates.isNotEmpty;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeOutCubic,
                    width: targeted ? 62 : 54,
                    height: targeted ? 62 : 54,
                    decoration: BoxDecoration(
                      color: targeted
                          ? const Color(0xFFF6F3EC)
                          : const Color(0xFF151515),
                      border: Border.all(
                        color: targeted
                            ? const Color(0xFFF6F3EC)
                            : Colors.white.withValues(alpha: 0.18),
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.34),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      enabled
                          ? Icons.delete_outline_rounded
                          : Icons.lock_outline_rounded,
                      color: targeted
                          ? const Color(0xFF080808)
                          : const Color(0xFFF6F3EC),
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrainDumpPanel extends StatelessWidget {
  final Pomodoro pomodoro;
  final PomodoroController notifier;
  final VoidCallback onDragStarted;
  final ValueChanged<DragUpdateDetails> onDragUpdate;
  final VoidCallback onDragEnd;

  const _BrainDumpPanel({
    required this.pomodoro,
    required this.notifier,
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return _DailyPlanDropTarget(
      category: DailyPlanItemCategory.brainDump,
      notifier: notifier,
      child: TodaySectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.brainDumpTitle,
                    style: TextStyle(
                      color: Color(0xFFF6F3EC),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Tooltip(
                  message: context.l10n.addBrainDumpTooltip,
                  child: IconButton(
                    onPressed: () => _openAddSheet(context),
                    icon: const Icon(Icons.add_rounded),
                    style: IconButton.styleFrom(
                      foregroundColor: const Color(0xFFF6F3EC),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
            if (pomodoro.brainDump.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...List.generate(pomodoro.brainDump.length, (index) {
                final item = pomodoro.brainDump[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == pomodoro.brainDump.length - 1 ? 0 : 8,
                  ),
                  child: DailyPlanReorderTarget(
                    category: DailyPlanItemCategory.brainDump,
                    rowIndex: index,
                    notifier: notifier,
                    child: _ScheduleSourceDraggable(
                      payload: DraftTimeBoxDragPayload(
                        source: DailyPlanItemCategory.brainDump,
                        index: index,
                        title: item,
                      ),
                      label: item,
                      onDragStarted: onDragStarted,
                      onDragUpdate: onDragUpdate,
                      onDragEnd: onDragEnd,
                      child: DailyPlanItemRow(
                        text: item,
                        onTap: () => showDailyPlanItemSheet(
                          context,
                          notifier: notifier,
                          category: DailyPlanItemCategory.brainDump,
                          index: index,
                          value: item,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ] else ...[
              const SizedBox(height: 8),
              DailyCarryOverButton(
                label: context.l10n.carryOverPreviousBrainDump,
                onPressed: () => showCarryOverPickerSheet(
                  context,
                  notifier: notifier,
                  section: CarryOverSection.brainDump,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openAddSheet(BuildContext context) {
    showDailyPlanTextSheet(
      context,
      title: context.l10n.addBrainDumpTitle,
      fieldLabel: context.l10n.captureLabel,
      onSave: (value) {
        notifier.addBrainDumpItem(value);
        HapticFeedback.lightImpact();
      },
    );
  }
}

class _ReminderPanel extends StatelessWidget {
  final Pomodoro pomodoro;
  final PomodoroController notifier;
  final VoidCallback onDragStarted;
  final ValueChanged<DragUpdateDetails> onDragUpdate;
  final VoidCallback onDragEnd;

  const _ReminderPanel({
    required this.pomodoro,
    required this.notifier,
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return _DailyPlanDropTarget(
      category: DailyPlanItemCategory.reminder,
      notifier: notifier,
      child: TodaySectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.keepInMindTitle,
                    style: TextStyle(
                      color: Color(0xFFF6F3EC),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Tooltip(
                  message: context.l10n.addReminderTooltip,
                  child: IconButton(
                    onPressed: () => _openAddSheet(context),
                    icon: const Icon(Icons.add_rounded),
                    style: IconButton.styleFrom(
                      foregroundColor: const Color(0xFFF6F3EC),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
            if (pomodoro.reminders.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...List.generate(pomodoro.reminders.length, (index) {
                final item = pomodoro.reminders[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == pomodoro.reminders.length - 1 ? 0 : 8,
                  ),
                  child: DailyPlanReorderTarget(
                    category: DailyPlanItemCategory.reminder,
                    rowIndex: index,
                    notifier: notifier,
                    child: _ScheduleSourceDraggable(
                      payload: DraftTimeBoxDragPayload(
                        source: DailyPlanItemCategory.reminder,
                        index: index,
                        title: item,
                      ),
                      label: item,
                      onDragStarted: onDragStarted,
                      onDragUpdate: onDragUpdate,
                      onDragEnd: onDragEnd,
                      child: DailyPlanItemRow(
                        text: item,
                        onTap: () => showDailyPlanItemSheet(
                          context,
                          notifier: notifier,
                          category: DailyPlanItemCategory.reminder,
                          index: index,
                          value: item,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ] else ...[
              const SizedBox(height: 8),
              DailyCarryOverButton(
                label: context.l10n.carryOverPreviousReminders,
                onPressed: () => showCarryOverPickerSheet(
                  context,
                  notifier: notifier,
                  section: CarryOverSection.reminder,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openAddSheet(BuildContext context) {
    showDailyPlanTextSheet(
      context,
      title: context.l10n.addReminderTitle,
      fieldLabel: context.l10n.reminderLabel,
      onSave: (value) {
        notifier.addReminder(value);
        HapticFeedback.lightImpact();
      },
    );
  }
}

class _ScheduleSourceDraggable extends StatelessWidget {
  final TimeBoxBoardDragPayload payload;
  final String label;
  final Widget child;
  final VoidCallback onDragStarted;
  final ValueChanged<DragUpdateDetails> onDragUpdate;
  final VoidCallback onDragEnd;

  const _ScheduleSourceDraggable({
    required this.payload,
    required this.label,
    required this.child,
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final feedbackWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - 48;
        return LongPressDraggable<TimeBoxBoardDragPayload>(
          data: payload,
          delay: const Duration(milliseconds: 160),
          dragAnchorStrategy: childDragAnchorStrategy,
          feedback: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: feedbackWidth,
              child: _ScheduleDragFeedback(label: label),
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.2, child: child),
          onDragStarted: onDragStarted,
          onDragUpdate: onDragUpdate,
          onDragEnd: (_) => onDragEnd(),
          onDragCompleted: onDragEnd,
          onDraggableCanceled: (_, _) => onDragEnd(),
          child: Tooltip(
            message: context.l10n.dragTimeBoxTooltip,
            child: child,
          ),
        );
      },
    );
  }
}

class _DailyPlanDropTarget extends StatelessWidget {
  final DailyPlanItemCategory category;
  final PomodoroController notifier;
  final Widget child;

  const _DailyPlanDropTarget({
    required this.category,
    required this.notifier,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<TimeBoxBoardDragPayload>(
      onWillAcceptWithDetails: (details) {
        return switch (details.data) {
          DraftTimeBoxDragPayload(:final source) =>
            notifier.canAcceptDailyPlanItem(category, source: source),
          ScheduledTimeBoxDragPayload() => notifier.canAcceptDailyPlanItem(
            category,
          ),
        };
      },
      onAcceptWithDetails: (details) {
        switch (details.data) {
          case DraftTimeBoxDragPayload(:final source, :final index):
            notifier.moveDailyPlanItem(
              source: source,
              index: index,
              target: category,
            );
          case ScheduledTimeBoxDragPayload(:final id):
            unawaited(notifier.moveTimeBoxToDailyPlanItem(id, category));
        }
        HapticFeedback.mediumImpact();
      },
      builder: (context, candidates, rejected) {
        // 같은 카테고리 안의 재정렬 드래그는 행 단위 타겟이 처리하므로,
        // 패널 레벨에서는 거부 표시(빨간 오버레이)를 그리지 않는다.
        final visibleRejected = rejected.where((payload) {
          return !(payload is DraftTimeBoxDragPayload &&
              payload.source == category);
        }).toList();
        return Stack(
          children: [
            child,
            if (candidates.isNotEmpty || visibleRejected.isNotEmpty)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    decoration: BoxDecoration(
                      color: candidates.isNotEmpty
                          ? const Color(0xFFF6F3EC).withValues(alpha: 0.08)
                          : const Color(0xFFFF8D8D).withValues(alpha: 0.05),
                      border: Border.all(
                        color: candidates.isNotEmpty
                            ? const Color(0xFFF6F3EC).withValues(alpha: 0.5)
                            : const Color(0xFFFF8D8D).withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ScheduleDragFeedback extends StatelessWidget {
  final String label;

  const _ScheduleDragFeedback({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3EC),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.36),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Text(
        label,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF080808),
          fontSize: 14,
          fontWeight: FontWeight.w900,
          height: 1.15,
        ),
      ),
    );
  }
}


class _TodaySummaryPanel extends StatelessWidget {
  final Pomodoro pomodoro;
  final List<String> priorities;
  final DateTime now;
  final List<DailyPlanSummary> history;
  final VoidCallback onOpenFocus;

  const _TodaySummaryPanel({
    required this.pomodoro,
    required this.priorities,
    required this.now,
    required this.history,
    required this.onOpenFocus,
  });

  @override
  Widget build(BuildContext context) {
    final plannedCount = priorities
        .where((priority) => priority.trim().isNotEmpty)
        .length;
    final plannedBoxes = pomodoro.timeBoxes.length;
    final completedBoxes = pomodoro.completedSessions
        .clamp(0, plannedBoxes)
        .toInt();
    final progress = plannedBoxes == 0 ? 0.0 : completedBoxes / plannedBoxes;

    return _TodaySummaryCard(
      progress: progress,
      priorityCount: plannedCount,
      plannedBoxes: plannedBoxes,
      completedBoxes: completedBoxes,
      activeBox: pomodoro.activeTimeBox,
      today: now,
      history: history,
      onOpenFocus: onOpenFocus,
      pomodoro: pomodoro,
    );
  }
}

class _TodaySummaryCard extends StatelessWidget {
  final double progress;
  final int priorityCount;
  final int plannedBoxes;
  final int completedBoxes;
  final TimeBox? activeBox;
  final DateTime today;
  final List<DailyPlanSummary> history;
  final VoidCallback onOpenFocus;
  final Pomodoro pomodoro;

  const _TodaySummaryCard({
    required this.progress,
    required this.priorityCount,
    required this.plannedBoxes,
    required this.completedBoxes,
    required this.activeBox,
    required this.today,
    required this.history,
    required this.onOpenFocus,
    required this.pomodoro,
  });

  @override
  Widget build(BuildContext context) {
    final box = activeBox;

    return TodaySectionCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showTodayReviewSheet(
            context,
            pomodoro: pomodoro,
            priorityCount: priorityCount,
            plannedBoxes: plannedBoxes,
            completedBoxes: completedBoxes,
            onOpenFocus: onOpenFocus,
          ),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.dailyProgressTitle,
                        style: TextStyle(
                          color: Color(0xFFF6F3EC),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.58),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white.withValues(alpha: 0.52),
                      size: 22,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFF6F3EC),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _TodaySummaryMetric(
                      label: context.l10n.planMetric,
                      value: '$priorityCount/3',
                    ),
                    const SizedBox(width: 8),
                    _TodaySummaryMetric(
                      label: context.l10n.timeBoxesMetric,
                      value: '$plannedBoxes',
                    ),
                    const SizedBox(width: 8),
                    _TodaySummaryMetric(
                      label: context.l10n.focusMetric,
                      value: '$completedBoxes/$plannedBoxes',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _NextTimeBoxSummary(box: box),
                const SizedBox(height: 12),
                _WeekHistoryStrip(
                  today: today,
                  history: history,
                  todaySummary: DailyPlanSummary(
                    dateKey: _TodayHistoryDateKey.format(today),
                    priorityCount: priorityCount,
                    plannedBoxCount: plannedBoxes,
                    completedBoxCount: completedBoxes,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekHistoryStrip extends StatelessWidget {
  final DateTime today;
  final List<DailyPlanSummary> history;
  final DailyPlanSummary todaySummary;

  const _WeekHistoryStrip({
    required this.today,
    required this.history,
    required this.todaySummary,
  });

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (index) {
      return DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: 6 - index));
    });
    final summaries = {
      for (final summary in history) summary.dateKey: summary,
      todaySummary.dateKey: todaySummary,
    };

    return Row(
      children: [
        for (var index = 0; index < days.length; index += 1)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == days.length - 1 ? 0 : 6),
              child: _HistoryCell(
                label: _WeekdayLabel.resolve(context, days[index].weekday),
                fill:
                    summaries[_TodayHistoryDateKey.format(days[index])]
                        ?.completionRatio ??
                    0,
                selected:
                    _TodayHistoryDateKey.format(days[index]) ==
                    todaySummary.dateKey,
                onTap: () => showDayHistorySheet(
                  context,
                  dateKey: _TodayHistoryDateKey.format(days[index]),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _HistoryCell extends StatelessWidget {
  final String label;
  final double fill;
  final bool selected;
  final VoidCallback onTap;

  const _HistoryCell({
    required this.label,
    required this.fill,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: 44,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: selected ? 0.08 : 0.035),
            border: Border.all(
              color: selected
                  ? const Color(0xFFF6F3EC)
                  : Colors.white.withValues(alpha: 0.08),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: fill.clamp(0.05, 1).toDouble(),
                widthFactor: 1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFF6F3EC,
                    ).withValues(alpha: fill <= 0 ? 0.08 : 0.78),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: selected
                  ? const Color(0xFFF6F3EC)
                  : Colors.white.withValues(alpha: 0.42),
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekdayLabel {
  static String resolve(BuildContext context, int weekday) {
    return switch (weekday) {
      DateTime.monday => context.l10n.weekdayMonNarrow,
      DateTime.tuesday => context.l10n.weekdayTueNarrow,
      DateTime.wednesday => context.l10n.weekdayWedNarrow,
      DateTime.thursday => context.l10n.weekdayThuNarrow,
      DateTime.friday => context.l10n.weekdayFriNarrow,
      DateTime.saturday => context.l10n.weekdaySatNarrow,
      _ => context.l10n.weekdaySunNarrow,
    };
  }
}

class _TodayHistoryDateKey {
  static String format(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

class _NextTimeBoxSummary extends StatelessWidget {
  final TimeBox? box;

  const _NextTimeBoxSummary({required this.box});

  @override
  Widget build(BuildContext context) {
    final currentBox = box;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule_rounded,
            color: Colors.white.withValues(alpha: 0.52),
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            context.l10n.nextTimeBoxLabel,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.46),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              currentBox == null
                  ? context.l10n.noActiveTimeBox
                  : displayTimeBoxTitle(currentBox),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFF6F3EC),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodaySummaryMetric extends StatelessWidget {
  final String label;
  final String value;

  const _TodaySummaryMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFF6F3EC),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showTodayReviewSheet(
  BuildContext context, {
  required Pomodoro pomodoro,
  required int priorityCount,
  required int plannedBoxes,
  required int completedBoxes,
  required VoidCallback onOpenFocus,
}) {
  HapticFeedback.selectionClick();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF101010),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (context) {
      return _TodayReviewSheet(
        pomodoro: pomodoro,
        priorityCount: priorityCount,
        plannedBoxes: plannedBoxes,
        completedBoxes: completedBoxes,
        onOpenFocus: onOpenFocus,
      );
    },
  );
}

class _TodayReviewSheet extends StatelessWidget {
  final Pomodoro pomodoro;
  final int priorityCount;
  final int plannedBoxes;
  final int completedBoxes;
  final VoidCallback onOpenFocus;

  const _TodayReviewSheet({
    required this.pomodoro,
    required this.priorityCount,
    required this.plannedBoxes,
    required this.completedBoxes,
    required this.onOpenFocus,
  });

  @override
  Widget build(BuildContext context) {
    final activeBox = pomodoro.activeTimeBox;
    final boxes = [...pomodoro.timeBoxes]
      ..sort((a, b) {
        final startA = a.startMinutes ?? (24 * 60);
        final startB = b.startMinutes ?? (24 * 60);
        return startA.compareTo(startB);
      });

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        minChildSize: 0.34,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.todayReviewTitle,
                        style: const TextStyle(
                          color: Color(0xFFF6F3EC),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
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
                const SizedBox(height: 8),
                _TodayReviewStats(
                  priorityCount: priorityCount,
                  plannedBoxes: plannedBoxes,
                  completedBoxes: completedBoxes,
                ),
                const SizedBox(height: 18),
                _TodayReviewTimeline(boxes: boxes, activeBox: activeBox),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onOpenFocus();
                  },
                  icon: const Icon(Icons.center_focus_strong_rounded),
                  label: Text(
                    context.l10n.openFocusAction,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF6F3EC),
                    foregroundColor: const Color(0xFF080808),
                    minimumSize: const Size.fromHeight(50),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TodayReviewStats extends StatelessWidget {
  final int priorityCount;
  final int plannedBoxes;
  final int completedBoxes;

  const _TodayReviewStats({
    required this.priorityCount,
    required this.plannedBoxes,
    required this.completedBoxes,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TodayReviewStatPill(
          label: context.l10n.planMetric,
          value: '$priorityCount/3',
        ),
        const SizedBox(width: 8),
        _TodayReviewStatPill(
          label: context.l10n.timeBoxesMetric,
          value: '$plannedBoxes',
        ),
        const SizedBox(width: 8),
        _TodayReviewStatPill(
          label: context.l10n.focusMetric,
          value: '$completedBoxes/$plannedBoxes',
        ),
      ],
    );
  }
}

class _TodayReviewStatPill extends StatelessWidget {
  final String label;
  final String value;

  const _TodayReviewStatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFF6F3EC),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.48),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayReviewTimeline extends StatelessWidget {
  final List<TimeBox> boxes;
  final TimeBox? activeBox;

  const _TodayReviewTimeline({required this.boxes, required this.activeBox});

  @override
  Widget build(BuildContext context) {
    if (boxes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Text(
          context.l10n.noTodayBoxesProgress,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.62),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var index = 0; index < boxes.length; index += 1)
          _TodayReviewTimelineEntry(
            box: boxes[index],
            active: boxes[index].id == activeBox?.id,
            first: index == 0,
            // 아래 종료 마커까지 연결선을 이어 그린다.
            last: false,
          ),
        // 마지막 박스의 종료 시각을 축에 명시적으로 찍는다.
        _TodayReviewTimelineEndMarker(box: boxes.last),
      ],
    );
  }
}

class _TodayReviewTimelineEndMarker extends StatelessWidget {
  final TimeBox box;

  const _TodayReviewTimelineEndMarker({required this.box});

  @override
  Widget build(BuildContext context) {
    final parts = box.timeRange.split('-');
    final endLabel = parts.length > 1 ? parts.last.trim() : '';
    if (endLabel.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 54,
          child: Text(
            endLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.44),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        SizedBox(
          width: 24,
          child: Column(
            children: [
              Container(
                width: 2,
                height: 10,
                color: Colors.white.withValues(alpha: 0.14),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.42),
                    width: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Expanded(child: SizedBox.shrink()),
      ],
    );
  }
}

class _TodayReviewTimelineEntry extends StatelessWidget {
  final TimeBox box;
  final bool active;
  final bool first;
  final bool last;

  const _TodayReviewTimelineEntry({
    required this.box,
    required this.active,
    required this.first,
    required this.last,
  });

  @override
  Widget build(BuildContext context) {
    final title = displayTimeBoxTitle(box);
    final dotColor = active
        ? const Color(0xFFF6F3EC)
        : Colors.white.withValues(alpha: 0.42);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 54,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              box.timeRange.split('-').first.trim(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: active
                    ? const Color(0xFFF6F3EC)
                    : Colors.white.withValues(alpha: 0.44),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 24,
          child: Column(
            children: [
              Container(
                width: 2,
                height: first ? 12 : 8,
                color: first
                    ? Colors.transparent
                    : Colors.white.withValues(alpha: 0.14),
              ),
              Container(
                width: active ? 12 : 8,
                height: active ? 12 : 8,
                decoration: BoxDecoration(
                  color: active ? const Color(0xFF080808) : dotColor,
                  shape: BoxShape.circle,
                  border: active
                      ? Border.all(color: const Color(0xFFF6F3EC), width: 2)
                      : null,
                ),
              ),
              Container(
                width: 2,
                height: last ? 18 : 42,
                color: last
                    ? Colors.transparent
                    : Colors.white.withValues(alpha: 0.14),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFFF6F3EC).withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: active
                      ? const Color(0xFFF6F3EC).withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFF6F3EC),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      height: 1.14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          box.timeRange,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.48),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (active) ...[
                        const SizedBox(width: 8),
                        _TodayReviewNowBadge(),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TodayReviewNowBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3EC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        context.l10n.nowLabel,
        style: const TextStyle(
          color: Color(0xFF080808),
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _TopPrioritiesPanel extends StatelessWidget {
  final List<String> priorities;
  final PomodoroController notifier;
  final VoidCallback onDragStarted;
  final ValueChanged<DragUpdateDetails> onDragUpdate;
  final VoidCallback onDragEnd;

  const _TopPrioritiesPanel({
    required this.priorities,
    required this.notifier,
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    final filledPriorities = <({int index, String value})>[
      for (var index = 0; index < priorities.length && index < 3; index += 1)
        if (priorities[index].trim().isNotEmpty)
          (index: index, value: priorities[index].trim()),
    ];

    return _DailyPlanDropTarget(
      category: DailyPlanItemCategory.topPriority,
      notifier: notifier,
      child: TodaySectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.topPrioritiesTitle,
                    style: TextStyle(
                      color: Color(0xFFF6F3EC),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Tooltip(
                  message: context.l10n.addPriorityTooltip,
                  child: IconButton(
                    onPressed: () => _openAddPriority(context),
                    icon: const Icon(Icons.add_rounded),
                    style: IconButton.styleFrom(
                      foregroundColor: const Color(0xFFF6F3EC),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
            if (filledPriorities.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                context.l10n.noPrioritiesYet,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.42),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              DailyCarryOverButton(
                label: context.l10n.carryOverPreviousPriorities,
                onPressed: () => showCarryOverPickerSheet(
                  context,
                  notifier: notifier,
                  section: CarryOverSection.topPriority,
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              ...filledPriorities.map((priority) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: priority == filledPriorities.last ? 0 : 8,
                  ),
                  child: DailyPlanReorderTarget(
                    category: DailyPlanItemCategory.topPriority,
                    rowIndex: priority.index,
                    notifier: notifier,
                    child: _ScheduleSourceDraggable(
                      payload: DraftTimeBoxDragPayload(
                        source: DailyPlanItemCategory.topPriority,
                        index: priority.index,
                        title: priority.value,
                      ),
                      label: priority.value,
                      onDragStarted: onDragStarted,
                      onDragUpdate: onDragUpdate,
                      onDragEnd: onDragEnd,
                      child: DailyPlanItemRow(
                        text: priority.value,
                        leadingIndex: priority.index,
                        onTap: () => showDailyPlanItemSheet(
                          context,
                          notifier: notifier,
                          category: DailyPlanItemCategory.topPriority,
                          index: priority.index,
                          value: priority.value,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  void _openAddPriority(BuildContext context) {
    final nextIndex = priorities.indexWhere(
      (priority) => priority.trim().isEmpty,
    );
    if (nextIndex == -1 || nextIndex >= 3) {
      showAppSnack(context, context.l10n.threePrioritiesAlreadySet);
      return;
    }

    showDailyPlanTextSheet(
      context,
      title: context.l10n.addPriorityTitle,
      fieldLabel: context.l10n.priorityLabel(nextIndex + 1),
      onSave: (value) {
        notifier.setTopPriority(nextIndex, value);
        HapticFeedback.lightImpact();
      },
    );
  }
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
