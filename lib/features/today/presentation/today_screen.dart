import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:pomodoro_method_channel/l10n/l10n.dart';

import '../../focus/application/pomodoro_controller.dart';
import '../../focus/domain/entities/daily_plan_summary.dart';
import '../../focus/domain/entities/pomodoro.dart';
import '../../focus/presentation/native_timer_copy_l10n.dart';
import '../../focus/presentation/time_box_title_l10n.dart';
import '../../settings/application/app_preferences_controller.dart';
import '../application/today_ui_controller.dart';
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
    final notifier = ref.read(pomodoroControllerProvider.notifier);
    final priorities = _normalizedPriorities(pomodoro);

    return SafeArea(
      child: Stack(
        children: [
          ScrollConfiguration(
            behavior: const _AppScrollBehavior(),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
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
                        ),
                        const SizedBox(height: 16),
                        _BrainDumpPanel(pomodoro: pomodoro, notifier: notifier),
                        const SizedBox(height: 16),
                        _ReminderPanel(pomodoro: pomodoro, notifier: notifier),
                        const SizedBox(height: 16),
                        TimeBoxBoard(
                          pomodoro: pomodoro,
                          notifier: notifier,
                          now: now,
                          awakeStartMinutes: preferences.awakeStartMinutes,
                          awakeEndMinutes: preferences.awakeEndMinutes,
                          onDragStarted: _beginTimeBoxDrag,
                          onDragUpdate: _handleTimeBoxDragUpdate,
                          onDragEnd: _endTimeBoxDrag,
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: () async {
                            final nativeCopy = context.l10n.nativeTimerCopy;
                            FocusScope.of(context).unfocus();
                            HapticFeedback.mediumImpact();
                            await notifier.selectCurrentTimeBoxForNow();
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
            enabled: pomodoro.timeBoxes.length > 1,
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

  List<String> _normalizedPriorities(Pomodoro pomodoro) {
    final priorities = List<String>.from(pomodoro.topPriorities.take(3));
    while (priorities.length < 3) {
      priorities.add('');
    }
    return priorities;
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

  void _endTimeBoxDrag() {
    _stopDragAutoScroll();
    ref.read(todayTimeBoxDragControllerProvider.notifier).end();
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
              child: DragTarget<String>(
                onWillAcceptWithDetails: (_) => enabled,
                onAcceptWithDetails: (details) => onAccept(details.data),
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

  const _BrainDumpPanel({required this.pomodoro, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return TodaySectionCard(
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
                child: _BrainDumpRow(
                  item: item,
                  onTap: () => _showBrainDumpActions(context, index),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  void _openAddSheet(BuildContext context) {
    _showTextEntrySheet(
      context,
      title: context.l10n.addBrainDumpTitle,
      label: context.l10n.captureLabel,
      onSave: (value) {
        notifier.addBrainDumpItem(value);
        HapticFeedback.lightImpact();
      },
    );
  }

  void _showBrainDumpActions(BuildContext context, int index) {
    if (index < 0 || index >= pomodoro.brainDump.length) {
      return;
    }

    final item = pomodoro.brainDump[index];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF101010),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  item,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF6F3EC),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 14),
                _ActionSheetButton(
                  icon: Icons.flag_rounded,
                  label: context.l10n.makePriority,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    notifier.promoteBrainDumpItem(index);
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 8),
                _ActionSheetButton(
                  icon: Icons.event_note_rounded,
                  label: context.l10n.moveToReminder,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    notifier.moveBrainDumpItemToReminder(index);
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 8),
                _ActionSheetButton(
                  icon: Icons.delete_outline_rounded,
                  label: context.l10n.deleteAction,
                  destructive: true,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    notifier.removeBrainDumpItem(index);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BrainDumpRow extends StatelessWidget {
  final String item;
  final VoidCallback onTap;

  const _BrainDumpRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.045),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
          child: Text(
            item,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFF6F3EC),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.18,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReminderPanel extends StatelessWidget {
  final Pomodoro pomodoro;
  final PomodoroController notifier;

  const _ReminderPanel({required this.pomodoro, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return TodaySectionCard(
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
                child: _ReminderRow(
                  item: item,
                  onTap: () => _showReminderActions(context, index),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  void _openAddSheet(BuildContext context) {
    _showTextEntrySheet(
      context,
      title: context.l10n.addReminderTitle,
      label: context.l10n.reminderLabel,
      onSave: (value) {
        notifier.addReminder(value);
        HapticFeedback.lightImpact();
      },
    );
  }

  void _showReminderActions(BuildContext context, int index) {
    if (index < 0 || index >= pomodoro.reminders.length) {
      return;
    }

    final item = pomodoro.reminders[index];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF101010),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  item,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF6F3EC),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 14),
                _ActionSheetButton(
                  icon: Icons.delete_outline_rounded,
                  label: context.l10n.deleteAction,
                  destructive: true,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    notifier.removeReminder(index);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReminderRow extends StatelessWidget {
  final String item;
  final VoidCallback onTap;

  const _ReminderRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.035),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.white.withValues(alpha: 0.09)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
          child: Text(
            item,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.18,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionSheetButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  const _ActionSheetButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = destructive
        ? const Color(0xFFFF8D8D)
        : const Color(0xFFF6F3EC);

    return Material(
      color: Colors.white.withValues(alpha: 0.055),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: foreground, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showTextEntrySheet(
  BuildContext context, {
  required String title,
  required String label,
  required ValueChanged<String> onSave,
  String initialValue = '',
  String? clearLabel,
  VoidCallback? onClear,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF101010),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (context) {
      return _TextEntrySheet(
        title: title,
        label: label,
        initialValue: initialValue,
        clearLabel: clearLabel,
        onClear: onClear,
        onSave: onSave,
      );
    },
  );
}

void _showSnack(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 1600),
    ),
  );
}

class _TextEntrySheet extends StatefulWidget {
  final String title;
  final String label;
  final String initialValue;
  final String? clearLabel;
  final VoidCallback? onClear;
  final ValueChanged<String> onSave;

  const _TextEntrySheet({
    required this.title,
    required this.label,
    required this.initialValue,
    required this.onSave,
    this.clearLabel,
    this.onClear,
  });

  @override
  State<_TextEntrySheet> createState() => _TextEntrySheetState();
}

class _TextEntrySheetState extends State<_TextEntrySheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
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
                    widget.title,
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
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              cursorColor: const Color(0xFFF6F3EC),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
              maxLines: 1,
              style: const TextStyle(
                color: Color(0xFFF6F3EC),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                isDense: true,
                labelText: widget.label,
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
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFF6F3EC)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded),
              label: Text(
                context.l10n.saveAction,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF6F3EC),
                foregroundColor: const Color(0xFF080808),
                minimumSize: const Size.fromHeight(50),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            if (widget.onClear != null && widget.clearLabel != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  widget.onClear?.call();
                  Navigator.of(context).pop();
                },
                child: Text(
                  widget.clearLabel!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _save() {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      _showSnack(context, context.l10n.enterSomethingFirst);
      return;
    }

    widget.onSave(value);
    Navigator.of(context).pop();
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

  const _HistoryCell({
    required this.label,
    required this.fill,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
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
                  : '${currentBox.timeRange}  ${localizedTimeBoxTitle(context, currentBox)}',
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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            _TodayReviewRow(
              icon: Icons.flag_rounded,
              label: context.l10n.planMetric,
              value: '$priorityCount/3',
            ),
            const SizedBox(height: 8),
            _TodayReviewRow(
              icon: Icons.view_timeline_rounded,
              label: context.l10n.timeBoxesMetric,
              value: '$plannedBoxes',
            ),
            const SizedBox(height: 8),
            _TodayReviewRow(
              icon: Icons.check_circle_outline_rounded,
              label: context.l10n.focusMetric,
              value: '$completedBoxes/$plannedBoxes',
            ),
            const SizedBox(height: 8),
            _TodayReviewRow(
              icon: Icons.schedule_rounded,
              label: context.l10n.nextTimeBoxLabel,
              value: activeBox == null
                  ? context.l10n.noActiveTimeBox
                  : '${activeBox.timeRange}  ${localizedTimeBoxTitle(context, activeBox)}',
            ),
            const SizedBox(height: 16),
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
      ),
    );
  }
}

class _TodayReviewRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TodayReviewRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.56), size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Color(0xFFF6F3EC),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopPrioritiesPanel extends StatelessWidget {
  final List<String> priorities;
  final PomodoroController notifier;

  const _TopPrioritiesPanel({required this.priorities, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final filledPriorities = <({int index, String value})>[
      for (var index = 0; index < priorities.length && index < 3; index += 1)
        if (priorities[index].trim().isNotEmpty)
          (index: index, value: priorities[index].trim()),
    ];

    return TodaySectionCard(
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
          ] else ...[
            const SizedBox(height: 12),
            ...filledPriorities.map((priority) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: priority == filledPriorities.last ? 0 : 8,
                ),
                child: _PriorityRow(
                  index: priority.index,
                  value: priority.value,
                  onTap: () => _openEditPriority(
                    context,
                    priority.index,
                    priority.value,
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  void _openAddPriority(BuildContext context) {
    final nextIndex = priorities.indexWhere(
      (priority) => priority.trim().isEmpty,
    );
    if (nextIndex == -1 || nextIndex >= 3) {
      _showSnack(context, context.l10n.threePrioritiesAlreadySet);
      return;
    }

    _showTextEntrySheet(
      context,
      title: context.l10n.addPriorityTitle,
      label: context.l10n.priorityLabel(nextIndex + 1),
      onSave: (value) {
        notifier.setTopPriority(nextIndex, value);
        HapticFeedback.lightImpact();
      },
    );
  }

  void _openEditPriority(BuildContext context, int index, String value) {
    _showTextEntrySheet(
      context,
      title: context.l10n.editPriorityTitle,
      label: context.l10n.priorityLabel(index + 1),
      initialValue: value,
      clearLabel: context.l10n.clearPriority,
      onClear: () {
        notifier.setTopPriority(index, '');
        HapticFeedback.lightImpact();
      },
      onSave: (nextValue) {
        notifier.setTopPriority(index, nextValue);
        HapticFeedback.lightImpact();
      },
    );
  }
}

class _PriorityRow extends StatelessWidget {
  final int index;
  final String value;
  final VoidCallback onTap;

  const _PriorityRow({
    required this.index,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.045),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
          child: Row(
            children: [
              Text(
                '${index + 1}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.46),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF6F3EC),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
              ),
              Icon(
                Icons.edit_rounded,
                size: 17,
                color: Colors.white.withValues(alpha: 0.42),
              ),
            ],
          ),
        ),
      ),
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
