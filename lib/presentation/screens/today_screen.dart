import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/pomodoro.dart';
import '../providers/app_preferences_provider.dart';
import '../providers/pomodoro_provider.dart';

class TodayScreen extends ConsumerStatefulWidget {
  final VoidCallback onOpenFocus;

  const TodayScreen({super.key, required this.onOpenFocus});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  Timer? _clockTimer;
  Timer? _dragAutoScrollTimer;
  double _dragAutoScrollDelta = 0;
  bool _isTimeBoxDragging = false;
  DateTime _now = DateTime.now();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _stopDragAutoScroll();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pomodoro = ref.watch(pomodoroProvider);
    final preferences = ref.watch(appPreferencesProvider);
    final notifier = ref.read(pomodoroProvider.notifier);
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
                        _TimeBoxBoard(
                          pomodoro: pomodoro,
                          notifier: notifier,
                          now: _now,
                          awakeStartMinutes: preferences.awakeStartMinutes,
                          awakeEndMinutes: preferences.awakeEndMinutes,
                          onDragStarted: _beginTimeBoxDrag,
                          onDragUpdate: _handleTimeBoxDragUpdate,
                          onDragEnd: _endTimeBoxDrag,
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            HapticFeedback.mediumImpact();
                            await notifier.selectCurrentTimeBoxForNow();
                            await notifier.start();
                            if (context.mounted) {
                              widget.onOpenFocus();
                            }
                          },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Start focus'),
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
                        _DailyProgressStrip(
                          pomodoro: pomodoro,
                          priorities: priorities,
                          now: _now,
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
            visible: _isTimeBoxDragging,
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
    if (mounted) {
      setState(() => _isTimeBoxDragging = true);
    }
  }

  void _endTimeBoxDrag() {
    _stopDragAutoScroll();
    if (mounted && _isTimeBoxDragging) {
      setState(() => _isTimeBoxDragging = false);
    }
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
        const Text(
          'Today',
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

class _BrainDumpPanel extends StatefulWidget {
  final Pomodoro pomodoro;
  final PomodoroNotifier notifier;

  const _BrainDumpPanel({required this.pomodoro, required this.notifier});

  @override
  State<_BrainDumpPanel> createState() => _BrainDumpPanelState();
}

class _BrainDumpPanelState extends State<_BrainDumpPanel> {
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Brain dump',
                  style: TextStyle(
                    color: Color(0xFFF6F3EC),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Tooltip(
                message: 'Add brain dump',
                child: IconButton(
                  onPressed: _openAddSheet,
                  icon: const Icon(Icons.add_rounded),
                  style: IconButton.styleFrom(
                    foregroundColor: const Color(0xFFF6F3EC),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ),
          if (widget.pomodoro.brainDump.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...List.generate(widget.pomodoro.brainDump.length, (index) {
              final item = widget.pomodoro.brainDump[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == widget.pomodoro.brainDump.length - 1 ? 0 : 8,
                ),
                child: _BrainDumpRow(
                  item: item,
                  onTap: () => _showBrainDumpActions(index),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  void _openAddSheet() {
    _showTextEntrySheet(
      context,
      title: 'Add brain dump',
      label: 'Capture',
      onSave: (value) {
        widget.notifier.addBrainDumpItem(value);
        HapticFeedback.lightImpact();
      },
    );
  }

  void _showBrainDumpActions(int index) {
    if (index < 0 || index >= widget.pomodoro.brainDump.length) {
      return;
    }

    final item = widget.pomodoro.brainDump[index];
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
                  label: 'Make priority',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.notifier.promoteBrainDumpItem(index);
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 8),
                _ActionSheetButton(
                  icon: Icons.event_note_rounded,
                  label: 'Move to reminder',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.notifier.moveBrainDumpItemToReminder(index);
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 8),
                _ActionSheetButton(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
                  destructive: true,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.notifier.removeBrainDumpItem(index);
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

class _ReminderPanel extends StatefulWidget {
  final Pomodoro pomodoro;
  final PomodoroNotifier notifier;

  const _ReminderPanel({required this.pomodoro, required this.notifier});

  @override
  State<_ReminderPanel> createState() => _ReminderPanelState();
}

class _ReminderPanelState extends State<_ReminderPanel> {
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Keep in mind',
                  style: TextStyle(
                    color: Color(0xFFF6F3EC),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Tooltip(
                message: 'Add reminder',
                child: IconButton(
                  onPressed: _openAddSheet,
                  icon: const Icon(Icons.add_rounded),
                  style: IconButton.styleFrom(
                    foregroundColor: const Color(0xFFF6F3EC),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ),
          if (widget.pomodoro.reminders.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...List.generate(widget.pomodoro.reminders.length, (index) {
              final item = widget.pomodoro.reminders[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == widget.pomodoro.reminders.length - 1 ? 0 : 8,
                ),
                child: _ReminderRow(
                  item: item,
                  onTap: () => _showReminderActions(index),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  void _openAddSheet() {
    _showTextEntrySheet(
      context,
      title: 'Add reminder',
      label: 'Reminder',
      onSave: (value) {
        widget.notifier.addReminder(value);
        HapticFeedback.lightImpact();
      },
    );
  }

  void _showReminderActions(int index) {
    if (index < 0 || index >= widget.pomodoro.reminders.length) {
      return;
    }

    final item = widget.pomodoro.reminders[index];
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
                  label: 'Delete',
                  destructive: true,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.notifier.removeReminder(index);
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
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 15,
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
              label: const Text('Save'),
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
                child: Text(widget.clearLabel!),
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
      _showSnack(context, 'Enter something first.');
      return;
    }

    widget.onSave(value);
    Navigator.of(context).pop();
  }
}

class _DailyProgressStrip extends StatelessWidget {
  final Pomodoro pomodoro;
  final List<String> priorities;
  final DateTime now;
  final VoidCallback onOpenFocus;

  const _DailyProgressStrip({
    required this.pomodoro,
    required this.priorities,
    required this.now,
    required this.onOpenFocus,
  });

  @override
  Widget build(BuildContext context) {
    final plannedCount = priorities
        .where((priority) => priority.trim().isNotEmpty)
        .length;
    final focusCount = pomodoro.completedSessions.clamp(0, 3).toInt();
    final progress = ((plannedCount + focusCount) / 6)
        .clamp(0.0, 1.0)
        .toDouble();
    final todayIndex = now.weekday - 1;

    return _DailyProgressCard(
      progress: progress,
      plannedCount: plannedCount,
      focusCount: focusCount,
      todayIndex: todayIndex,
      onOpenFocus: onOpenFocus,
    );
  }
}

class _DailyProgressCard extends StatefulWidget {
  final double progress;
  final int plannedCount;
  final int focusCount;
  final int todayIndex;
  final VoidCallback onOpenFocus;

  const _DailyProgressCard({
    required this.progress,
    required this.plannedCount,
    required this.focusCount,
    required this.todayIndex,
    required this.onOpenFocus,
  });

  @override
  State<_DailyProgressCard> createState() => _DailyProgressCardState();
}

class _DailyProgressCardState extends State<_DailyProgressCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _expanded = !_expanded);
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Daily progress',
                      style: TextStyle(
                        color: Color(0xFFF6F3EC),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Text(
                      '${(widget.progress * 100).round()}%',
                      key: ValueKey(widget.progress),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.54),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white.withValues(alpha: 0.52),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(7, (index) {
              final isToday = index == widget.todayIndex;
              final isPast = index < widget.todayIndex;
              final fill = isToday ? widget.progress : (isPast ? 0.16 : 0.06);

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == 6 ? 0 : 6),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _expanded = true);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: _DailyProgressCell(
                      label: _weekdayLabel(index),
                      fill: fill,
                      selected: isToday,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _DailyProgressMetric(
                label: 'Plan',
                value: '${widget.plannedCount}/3',
                onTap: () => setState(() => _expanded = true),
              ),
              const SizedBox(width: 10),
              _DailyProgressMetric(
                label: 'Focus',
                value: '${widget.focusCount}/3',
                onTap: widget.onOpenFocus,
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.045),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Plan fills as Top priorities are written. Focus fills when focus blocks finish.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.58),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
            firstCurve: Curves.easeOutCubic,
            secondCurve: Curves.easeOutCubic,
            sizeCurve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }

  String _weekdayLabel(int index) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return labels[index];
  }
}

class _DailyProgressCell extends StatelessWidget {
  final String label;
  final double fill;
  final bool selected;

  const _DailyProgressCell({
    required this.label,
    required this.fill,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      height: 58,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: selected ? 0.09 : 0.045),
        border: Border.all(
          color: selected
              ? const Color(0xFFF6F3EC)
              : Colors.white.withValues(alpha: 0.1),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: fill.clamp(0.08, 1.0),
                widthFactor: 1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFF6F3EC,
                    ).withValues(alpha: selected ? 0.92 : 0.28),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: selected
                  ? const Color(0xFFF6F3EC)
                  : Colors.white.withValues(alpha: 0.42),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyProgressMetric extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DailyProgressMetric({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.045),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFFF6F3EC),
                  fontSize: 13,
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

class _TopPrioritiesPanel extends StatelessWidget {
  final List<String> priorities;
  final PomodoroNotifier notifier;

  const _TopPrioritiesPanel({required this.priorities, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final filledPriorities = <({int index, String value})>[
      for (var index = 0; index < priorities.length && index < 3; index += 1)
        if (priorities[index].trim().isNotEmpty)
          (index: index, value: priorities[index].trim()),
    ];

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Top priorities',
                  style: TextStyle(
                    color: Color(0xFFF6F3EC),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Tooltip(
                message: 'Add priority',
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
              'No priorities yet',
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
      _showSnack(context, 'Three priorities are already set.');
      return;
    }

    _showTextEntrySheet(
      context,
      title: 'Add priority',
      label: 'Priority ${nextIndex + 1}',
      onSave: (value) {
        notifier.setTopPriority(nextIndex, value);
        HapticFeedback.lightImpact();
      },
    );
  }

  void _openEditPriority(BuildContext context, int index, String value) {
    _showTextEntrySheet(
      context,
      title: 'Edit priority',
      label: 'Priority ${index + 1}',
      initialValue: value,
      clearLabel: 'Clear priority',
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

class _TimeBoxBoard extends StatelessWidget {
  final Pomodoro pomodoro;
  final PomodoroNotifier notifier;
  final DateTime now;
  final int awakeStartMinutes;
  final int awakeEndMinutes;
  final VoidCallback onDragStarted;
  final ValueChanged<DragUpdateDetails> onDragUpdate;
  final VoidCallback onDragEnd;

  const _TimeBoxBoard({
    required this.pomodoro,
    required this.notifier,
    required this.now,
    required this.awakeStartMinutes,
    required this.awakeEndMinutes,
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  static const _slotMinutes = 30;
  static const _slotHeight = 70.0;
  static const _timelineWidth = 58.0;

  @override
  Widget build(BuildContext context) {
    final dayStart = _dayStartMinutes();
    final dayEnd = _dayEndMinutes(dayStart);
    final slotCount = ((dayEnd - dayStart) / _slotMinutes).ceil();
    final boardHeight = slotCount * _slotHeight;
    final nowMinutes = _nowMinutes();

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Time boxes',
            style: TextStyle(
              color: Color(0xFFF6F3EC),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap an empty slot to add. Tap a box to edit.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.42),
              fontSize: 12,
              fontWeight: FontWeight.w700,
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
                    final slotStart = dayStart + (index * _slotMinutes);
                    final isCurrentSlot =
                        nowMinutes >= slotStart &&
                        nowMinutes < slotStart + _slotMinutes;
                    final occupied = _slotOccupied(slotStart);

                    return Positioned(
                      top: index * _slotHeight,
                      left: 0,
                      right: 0,
                      height: _slotHeight,
                      child: DragTarget<String>(
                        onAcceptWithDetails: (details) {
                          HapticFeedback.mediumImpact();
                          notifier.moveTimeBoxToStart(details.data, slotStart);
                        },
                        builder: (context, candidates, rejected) {
                          final isTargeted = candidates.isNotEmpty;
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: occupied
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
                  ...pomodoro.timeBoxes.map(
                    (box) => _positionedTimeBox(
                      context: context,
                      box: box,
                      dayStart: dayStart,
                      dayEnd: dayEnd,
                    ),
                  ),
                  if (nowMinutes >= dayStart && nowMinutes <= dayEnd)
                    Positioned(
                      top:
                          ((nowMinutes - dayStart) / _slotMinutes) *
                          _slotHeight,
                      left: _timelineWidth - 4,
                      right: 0,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF6F3EC),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 2,
                              color: const Color(0xFFF6F3EC),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _positionedTimeBox({
    required BuildContext context,
    required TimeBox box,
    required int dayStart,
    required int dayEnd,
  }) {
    final start = box.startMinutes;
    final end = box.endMinutes;
    if (start == null || end == null || end <= dayStart || start >= dayEnd) {
      return const SizedBox.shrink();
    }

    final visibleStart = start < dayStart ? dayStart : start;
    final visibleEnd = end > dayEnd ? dayEnd : end;
    final top = ((visibleStart - dayStart) / _slotMinutes) * _slotHeight + 4;
    var height = ((visibleEnd - visibleStart) / _slotMinutes) * _slotHeight - 8;
    if (height < 58) {
      height = 58;
    }

    return Positioned(
      top: top,
      left: _timelineWidth,
      right: 0,
      height: height,
      child: _TimeBoxBoardCard(
        box: box,
        selected: box.id == pomodoro.activeTimeBox?.id,
        current: _containsNow(box),
        onDragStarted: onDragStarted,
        onDragUpdate: onDragUpdate,
        onDragEnd: onDragEnd,
        onTap: () {
          _openTimeBoxEditor(context, box);
        },
      ),
    );
  }

  void _openNewTimeBoxEditor(BuildContext context, int slotStart) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF101010),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return _TimeBoxEditorSheet(
          notifier: notifier,
          startMinutes: slotStart,
          timeRange: _formatTimeRange(slotStart),
        );
      },
    );
  }

  void _openTimeBoxEditor(BuildContext context, TimeBox box) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF101010),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return _TimeBoxEditorSheet(
          box: box,
          notifier: notifier,
          timeRange: box.timeRange,
        );
      },
    );
  }

  int _dayStartMinutes() {
    return (awakeStartMinutes ~/ _slotMinutes) * _slotMinutes;
  }

  int _dayEndMinutes(int dayStart) {
    final end =
        ((awakeEndMinutes + _slotMinutes - 1) ~/ _slotMinutes) * _slotMinutes;
    if (end <= dayStart) {
      return dayStart + (4 * 60);
    }
    return end.clamp(dayStart + _slotMinutes, 24 * 60);
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

  String _formatTimeRange(int startMinutes) {
    return '${_formatClock(startMinutes)}-${_formatClock(startMinutes + _slotMinutes)}';
  }

  bool _slotOccupied(int slotStart) {
    return pomodoro.timeBoxes.any((box) => box.startMinutes == slotStart);
  }
}

class _TimeBoxBoardCard extends StatefulWidget {
  final TimeBox box;
  final bool selected;
  final bool current;
  final VoidCallback onDragStarted;
  final ValueChanged<DragUpdateDetails> onDragUpdate;
  final VoidCallback onDragEnd;
  final VoidCallback onTap;

  const _TimeBoxBoardCard({
    required this.box,
    required this.selected,
    required this.current,
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onTap,
  });

  @override
  State<_TimeBoxBoardCard> createState() => _TimeBoxBoardCardState();
}

class _TimeBoxBoardCardState extends State<_TimeBoxBoardCard> {
  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<String>(
      data: widget.box.id,
      delay: const Duration(milliseconds: 220),
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width - 110,
          child: _surface(feedback: true),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.28,
        child: _cardGesture(child: _surface()),
      ),
      onDragStarted: widget.onDragStarted,
      onDragUpdate: widget.onDragUpdate,
      onDragEnd: (_) => widget.onDragEnd(),
      onDragCompleted: widget.onDragEnd,
      onDraggableCanceled: (_, _) => widget.onDragEnd(),
      child: _cardGesture(child: _surface()),
    );
  }

  Widget _cardGesture({required Widget child}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: child,
    );
  }

  Widget _surface({bool feedback = false}) {
    final selected = widget.selected;
    final current = widget.current;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.box.timeRange,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected
                  ? const Color(0xFF080808)
                  : Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (current && !selected) ...[
            const SizedBox(height: 3),
            Text(
              'Now',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.54),
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            widget.box.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected
                  ? const Color(0xFF080808)
                  : const Color(0xFFF6F3EC),
              fontSize: 15,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeBoxEditorSheet extends StatefulWidget {
  final TimeBox? box;
  final PomodoroNotifier notifier;
  final int? startMinutes;
  final String timeRange;

  const _TimeBoxEditorSheet({
    this.box,
    required this.notifier,
    this.startMinutes,
    required this.timeRange,
  });

  @override
  State<_TimeBoxEditorSheet> createState() => _TimeBoxEditorSheetState();
}

class _TimeBoxEditorSheetState extends State<_TimeBoxEditorSheet> {
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.box?.title ?? '');
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
                    widget.box == null ? 'New time box' : 'Edit time box',
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
              controller: _titleController,
              label: 'Title',
              textInputAction: TextInputAction.done,
              autofocus: true,
              onSubmitted: (_) => _save(context),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(
                'Time box ${widget.timeRange}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.52),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _save(context),
              icon: const Icon(Icons.check_rounded),
              label: const Text('Save'),
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
          title: _titleController.text,
        );
      }
    } else {
      widget.notifier.updateTimeBox(box.id, title: _titleController.text);
    }
    Navigator.of(context).pop();
  }
}

class _TimeBoxTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputAction textInputAction;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;

  const _TimeBoxTextField({
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

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
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
