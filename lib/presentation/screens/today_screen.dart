import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/pomodoro.dart';
import '../providers/pomodoro_provider.dart';

class TodayScreen extends ConsumerStatefulWidget {
  final VoidCallback onOpenFocus;

  const TodayScreen({super.key, required this.onOpenFocus});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  int _priorityIndex = 0;
  List<String>? _draftPriorities;
  Timer? _prioritySaveTimer;
  Timer? _clockTimer;
  Timer? _dragAutoScrollTimer;
  double _dragAutoScrollDelta = 0;
  DateTime _now = DateTime.now();
  final _scrollController = ScrollController();
  final _priorityFocusNode = FocusNode();

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
    _priorityFocusNode.dispose();
    _prioritySaveTimer?.cancel();
    final priorities = _draftPriorities;
    if (priorities != null) {
      final notifier = ref.read(pomodoroProvider.notifier);
      for (var index = 0; index < priorities.length; index += 1) {
        notifier.setTopPriority(index, priorities[index]);
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pomodoro = ref.watch(pomodoroProvider);
    final notifier = ref.read(pomodoroProvider.notifier);
    final priorities = _draftPriorities ?? _normalizedPriorities(pomodoro);
    _draftPriorities ??= priorities;

    return SafeArea(
      child: ScrollConfiguration(
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
                    _BrainDumpPanel(pomodoro: pomodoro, notifier: notifier),
                    const SizedBox(height: 16),
                    _PriorityBuilder(
                      priorities: priorities,
                      priorityIndex: _priorityIndex,
                      focusNode: _priorityFocusNode,
                      onPriorityChanged: _setDraftPriority,
                      onPriorityIndexChanged: _setPriorityIndex,
                    ),
                    const SizedBox(height: 16),
                    _TimeBoxBoard(
                      pomodoro: pomodoro,
                      notifier: notifier,
                      now: _now,
                      onDragUpdate: _handleTimeBoxDragUpdate,
                      onDragEnd: _stopDragAutoScroll,
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () async {
                        _commitPriority(_priorityIndex);
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
    );
  }

  List<String> _normalizedPriorities(Pomodoro pomodoro) {
    final priorities = List<String>.from(pomodoro.topPriorities.take(3));
    while (priorities.length < 3) {
      priorities.add('');
    }
    return priorities;
  }

  void _setDraftPriority(String value) {
    final index = _priorityIndex;
    final priorities = List<String>.from(_draftPriorities ?? ['', '', '']);
    while (priorities.length < 3) {
      priorities.add('');
    }
    priorities[index] = value;

    setState(() => _draftPriorities = priorities.take(3).toList());

    _prioritySaveTimer?.cancel();
    _prioritySaveTimer = Timer(const Duration(milliseconds: 450), () {
      ref.read(pomodoroProvider.notifier).setTopPriority(index, value);
    });
  }

  void _setPriorityIndex(int index) {
    _commitPriority(_priorityIndex);
    HapticFeedback.selectionClick();
    setState(() => _priorityIndex = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _priorityFocusNode.requestFocus();
      }
    });
  }

  void _commitPriority(int index) {
    _prioritySaveTimer?.cancel();
    final priorities = _draftPriorities;
    if (priorities == null || index < 0 || index >= priorities.length) {
      return;
    }
    ref
        .read(pomodoroProvider.notifier)
        .setTopPriority(index, priorities[index]);
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

class _BrainDumpPanel extends StatefulWidget {
  final Pomodoro pomodoro;
  final PomodoroNotifier notifier;

  const _BrainDumpPanel({required this.pomodoro, required this.notifier});

  @override
  State<_BrainDumpPanel> createState() => _BrainDumpPanelState();
}

class _BrainDumpPanelState extends State<_BrainDumpPanel> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Brain dump',
            style: TextStyle(
              color: Color(0xFFF6F3EC),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  cursorColor: const Color(0xFFF6F3EC),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addItem(),
                  style: const TextStyle(
                    color: Color(0xFFF6F3EC),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: 'Capture',
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
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: 'Add brain dump',
                child: IconButton.filled(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF6F3EC),
                    foregroundColor: const Color(0xFF080808),
                    minimumSize: const Size.square(46),
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
                  onPromote: () {
                    HapticFeedback.selectionClick();
                    widget.notifier.promoteBrainDumpItem(index);
                  },
                  onDelete: () {
                    HapticFeedback.lightImpact();
                    widget.notifier.removeBrainDumpItem(index);
                  },
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  void _addItem() {
    final value = _controller.text;
    widget.notifier.addBrainDumpItem(value);
    if (value.trim().isNotEmpty) {
      HapticFeedback.lightImpact();
      _controller.clear();
    }
  }
}

class _BrainDumpRow extends StatelessWidget {
  final String item;
  final VoidCallback onPromote;
  final VoidCallback onDelete;

  const _BrainDumpRow({
    required this.item,
    required this.onPromote,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
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
          Tooltip(
            message: 'Promote to priority',
            child: IconButton(
              onPressed: onPromote,
              icon: const Icon(Icons.north_rounded),
              visualDensity: VisualDensity.compact,
              color: Colors.white.withValues(alpha: 0.62),
            ),
          ),
          Tooltip(
            message: 'Delete',
            child: IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.close_rounded),
              visualDensity: VisualDensity.compact,
              color: Colors.white.withValues(alpha: 0.48),
            ),
          ),
        ],
      ),
    );
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

class _PriorityBuilder extends StatelessWidget {
  final List<String> priorities;
  final int priorityIndex;
  final FocusNode focusNode;
  final ValueChanged<String> onPriorityChanged;
  final ValueChanged<int> onPriorityIndexChanged;

  const _PriorityBuilder({
    required this.priorities,
    required this.priorityIndex,
    required this.focusNode,
    required this.onPriorityChanged,
    required this.onPriorityIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final priority = _priorityAt(priorityIndex);

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Top priorities',
            style: TextStyle(
              color: Color(0xFFF6F3EC),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == 2 ? 0 : 8),
                  child: _PriorityStepButton(
                    index: index,
                    selected: index == priorityIndex,
                    filled: _priorityAt(index).trim().isNotEmpty,
                    onTap: () => onPriorityIndexChanged(index),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: TextFormField(
              key: ValueKey('priority-$priorityIndex'),
              focusNode: focusNode,
              initialValue: priority,
              onChanged: onPriorityChanged,
              textInputAction: priorityIndex < 2
                  ? TextInputAction.next
                  : TextInputAction.done,
              onFieldSubmitted: (_) {
                if (priorityIndex < 2) {
                  onPriorityIndexChanged(priorityIndex + 1);
                }
              },
              cursorColor: const Color(0xFFF6F3EC),
              style: const TextStyle(
                color: Color(0xFFF6F3EC),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                isDense: true,
                labelText: 'Priority ${priorityIndex + 1}',
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
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: priorityIndex == 0
                      ? null
                      : () => onPriorityIndexChanged(priorityIndex - 1),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF6F3EC),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: priorityIndex == 2
                      ? null
                      : () => onPriorityIndexChanged(priorityIndex + 1),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF6F3EC),
                    foregroundColor: const Color(0xFF080808),
                    disabledBackgroundColor: Colors.white.withValues(
                      alpha: 0.12,
                    ),
                    disabledForegroundColor: Colors.white.withValues(
                      alpha: 0.32,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _priorityAt(int index) {
    if (index >= priorities.length) {
      return '';
    }
    return priorities[index];
  }
}

class _PriorityStepButton extends StatelessWidget {
  final int index;
  final bool selected;
  final bool filled;
  final VoidCallback onTap;

  const _PriorityStepButton({
    required this.index,
    required this.selected,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFF6F3EC)
              : Colors.white.withValues(alpha: 0.045),
          border: Border.all(
            color: selected
                ? const Color(0xFFF6F3EC)
                : Colors.white.withValues(alpha: 0.12),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          filled ? '✓' : '${index + 1}',
          style: TextStyle(
            color: selected ? const Color(0xFF080808) : const Color(0xFFF6F3EC),
            fontSize: 16,
            fontWeight: FontWeight.w900,
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
  final ValueChanged<DragUpdateDetails> onDragUpdate;
  final VoidCallback onDragEnd;

  const _TimeBoxBoard({
    required this.pomodoro,
    required this.notifier,
    required this.now,
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
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Time boxes',
                  style: TextStyle(
                    color: Color(0xFFF6F3EC),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Tooltip(
                message: 'Add time box',
                child: IconButton.filled(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    notifier.addTimeBox();
                  },
                  icon: const Icon(Icons.add_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF6F3EC),
                    foregroundColor: const Color(0xFF080808),
                    minimumSize: const Size.square(36),
                  ),
                ),
              ),
            ],
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
                          return AnimatedContainer(
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
        canDelete: pomodoro.timeBoxes.length > 1,
        onDragUpdate: onDragUpdate,
        onDragEnd: onDragEnd,
        onTap: () {
          HapticFeedback.selectionClick();
          unawaited(notifier.selectTimeBox(box.id));
        },
        onEdit: () => _openTimeBoxEditor(context, box),
        onDelete: () {
          HapticFeedback.mediumImpact();
          unawaited(notifier.removeTimeBox(box.id));
        },
      ),
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
        return _TimeBoxEditorSheet(box: box, notifier: notifier);
      },
    );
  }

  int _dayStartMinutes() {
    var start = 8 * 60;
    final nowMinutes = _nowMinutes();
    if (nowMinutes >= 7 * 60 && nowMinutes <= 22 * 60) {
      start = nowMinutes - 60;
      if (start < 0) {
        start = 0;
      }
    }

    for (final box in pomodoro.timeBoxes) {
      final boxStart = box.startMinutes;
      if (boxStart != null && boxStart < start) {
        start = (boxStart ~/ 60) * 60;
      }
    }
    return (start ~/ _slotMinutes) * _slotMinutes;
  }

  int _dayEndMinutes(int dayStart) {
    var end = 18 * 60;
    final nowMinutes = _nowMinutes();
    if (nowMinutes >= 7 * 60 && nowMinutes <= 22 * 60) {
      end = nowMinutes + 90;
    }

    for (final box in pomodoro.timeBoxes) {
      final boxEnd = box.endMinutes;
      if (boxEnd != null && boxEnd > end) {
        end = ((((boxEnd + 60) + 29) ~/ 30) * 30);
      }
    }

    if (end <= dayStart) {
      return dayStart + (4 * 60);
    }
    return (((end + _slotMinutes - 1) ~/ _slotMinutes) * _slotMinutes);
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
}

class _TimeBoxBoardCard extends StatefulWidget {
  final TimeBox box;
  final bool selected;
  final bool current;
  final bool canDelete;
  final ValueChanged<DragUpdateDetails> onDragUpdate;
  final VoidCallback onDragEnd;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TimeBoxBoardCard({
    required this.box,
    required this.selected,
    required this.current,
    required this.canDelete,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_TimeBoxBoardCard> createState() => _TimeBoxBoardCardState();
}

class _TimeBoxBoardCardState extends State<_TimeBoxBoardCard> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 76,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _BoardActionButton(
                      icon: Icons.edit_rounded,
                      onPressed: () {
                        setState(() => _revealed = false);
                        widget.onEdit();
                      },
                    ),
                    const SizedBox(width: 4),
                    _BoardActionButton(
                      icon: Icons.delete_outline_rounded,
                      onPressed: widget.canDelete
                          ? () {
                              setState(() => _revealed = false);
                              widget.onDelete();
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              transform: Matrix4.translationValues(_revealed ? -84 : 0, 0, 0),
              child: LongPressDraggable<String>(
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
                onDragStarted: () {
                  HapticFeedback.mediumImpact();
                  setState(() => _revealed = false);
                },
                onDragUpdate: widget.onDragUpdate,
                onDragEnd: (_) => widget.onDragEnd(),
                onDragCompleted: widget.onDragEnd,
                onDraggableCanceled: (_, _) => widget.onDragEnd(),
                child: _cardGesture(child: _surface()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardGesture({required Widget child}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_revealed) {
          setState(() => _revealed = false);
          return;
        }
        widget.onTap();
      },
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx < -2) {
          setState(() => _revealed = true);
        } else if (details.delta.dx > 2) {
          setState(() => _revealed = false);
        }
      },
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < -180) {
          setState(() => _revealed = true);
        } else if (velocity > 180) {
          setState(() => _revealed = false);
        }
      },
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

class _BoardActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _BoardActionButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.12),
        foregroundColor: const Color(0xFFF6F3EC),
        disabledBackgroundColor: Colors.white.withValues(alpha: 0.06),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.24),
        fixedSize: const Size.square(34),
        minimumSize: const Size.square(34),
        padding: EdgeInsets.zero,
        iconSize: 18,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _TimeBoxEditorSheet extends StatefulWidget {
  final TimeBox box;
  final PomodoroNotifier notifier;

  const _TimeBoxEditorSheet({required this.box, required this.notifier});

  @override
  State<_TimeBoxEditorSheet> createState() => _TimeBoxEditorSheetState();
}

class _TimeBoxEditorSheetState extends State<_TimeBoxEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _rangeController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.box.title);
    _rangeController = TextEditingController(text: widget.box.timeRange);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _rangeController.dispose();
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
                const Expanded(
                  child: Text(
                    'Time box',
                    style: TextStyle(
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
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 10),
            _TimeBoxTextField(
              controller: _rangeController,
              label: 'Start time',
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(context),
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
    widget.notifier.updateTimeBox(
      widget.box.id,
      title: _titleController.text,
      timeRange: _rangeController.text,
    );
    Navigator.of(context).pop();
  }
}

class _TimeBoxTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _TimeBoxTextField({
    required this.controller,
    required this.label,
    required this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorColor: const Color(0xFFF6F3EC),
      textInputAction: textInputAction,
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
