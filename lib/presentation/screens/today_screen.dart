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

  @override
  void dispose() {
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
                    _MomentumStrip(pomodoro: pomodoro, priorities: priorities),
                    const SizedBox(height: 16),
                    _PriorityBuilder(
                      priorities: priorities,
                      priorityIndex: _priorityIndex,
                      onPriorityChanged: _setDraftPriority,
                      onPriorityIndexChanged: _setPriorityIndex,
                    ),
                    const SizedBox(height: 16),
                    _TimeBoxList(pomodoro: pomodoro, notifier: notifier),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () async {
                        _commitPriority(_priorityIndex);
                        FocusScope.of(context).unfocus();
                        HapticFeedback.mediumImpact();
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

class _MomentumStrip extends StatelessWidget {
  final Pomodoro pomodoro;
  final List<String> priorities;

  const _MomentumStrip({required this.pomodoro, required this.priorities});

  @override
  Widget build(BuildContext context) {
    final plannedCount = priorities
        .where((priority) => priority.trim().isNotEmpty)
        .length;
    final focusCount = pomodoro.completedSessions.clamp(0, 3).toInt();
    final progress = ((plannedCount + focusCount) / 6)
        .clamp(0.0, 1.0)
        .toDouble();
    final todayIndex = DateTime.now().weekday - 1;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Momentum',
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
                  '${(progress * 100).round()}%',
                  key: ValueKey(progress),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.54),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(7, (index) {
              final isToday = index == todayIndex;
              final isPast = index < todayIndex;
              final fill = isToday ? progress : (isPast ? 0.16 : 0.06);

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == 6 ? 0 : 6),
                  child: _MomentumCell(
                    label: _weekdayLabel(index),
                    fill: fill,
                    selected: isToday,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MomentumMetric(label: 'Plan', value: '$plannedCount/3'),
              const SizedBox(width: 10),
              _MomentumMetric(label: 'Focus', value: '$focusCount/3'),
            ],
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

class _MomentumCell extends StatelessWidget {
  final String label;
  final double fill;
  final bool selected;

  const _MomentumCell({
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

class _MomentumMetric extends StatelessWidget {
  final String label;
  final String value;

  const _MomentumMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
    );
  }
}

class _PriorityBuilder extends StatelessWidget {
  final List<String> priorities;
  final int priorityIndex;
  final ValueChanged<String> onPriorityChanged;
  final ValueChanged<int> onPriorityIndexChanged;

  const _PriorityBuilder({
    required this.priorities,
    required this.priorityIndex,
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
              initialValue: priority,
              onChanged: onPriorityChanged,
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

class _TimeBoxList extends StatelessWidget {
  final Pomodoro pomodoro;
  final PomodoroNotifier notifier;

  const _TimeBoxList({required this.pomodoro, required this.notifier});

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
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: pomodoro.timeBoxes.length,
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  final scale = 1 + (animation.value * 0.025);
                  return Transform.scale(
                    scale: scale,
                    child: Material(
                      color: Colors.transparent,
                      elevation: animation.value * 12,
                      borderRadius: BorderRadius.circular(8),
                      child: child,
                    ),
                  );
                },
                child: child,
              );
            },
            onReorderItem: (oldIndex, newIndex) {
              HapticFeedback.selectionClick();
              notifier.reorderTimeBox(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final box = pomodoro.timeBoxes[index];
              return Padding(
                key: ValueKey(box.id),
                padding: EdgeInsets.only(
                  bottom: index == pomodoro.timeBoxes.length - 1 ? 0 : 8,
                ),
                child: _TimeBoxRow(
                  box: box,
                  index: index,
                  selected: box.id == pomodoro.activeTimeBox?.id,
                  canDelete: pomodoro.timeBoxes.length > 1,
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
            },
          ),
        ],
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
}

class _TimeBoxRow extends StatelessWidget {
  final TimeBox box;
  final int index;
  final bool selected;
  final bool canDelete;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TimeBoxRow({
    required this.box,
    required this.index,
    required this.selected,
    required this.canDelete,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.fromLTRB(13, 12, 8, 12),
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    box.timeRange,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? const Color(0xFF080808)
                          : Colors.white.withValues(alpha: 0.48),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Tooltip(
                    message: box.title,
                    child: Text(
                      box.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected
                            ? const Color(0xFF080808)
                            : const Color(0xFFF6F3EC),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Tooltip(
              message: 'Edit time box',
              child: IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded),
                visualDensity: VisualDensity.compact,
                color: selected
                    ? const Color(0xFF080808)
                    : Colors.white.withValues(alpha: 0.56),
              ),
            ),
            Tooltip(
              message: 'Delete time box',
              child: IconButton(
                onPressed: canDelete ? onDelete : null,
                icon: const Icon(Icons.remove_circle_outline_rounded),
                visualDensity: VisualDensity.compact,
                color: selected
                    ? const Color(0xFF080808)
                    : Colors.white.withValues(alpha: 0.5),
                disabledColor: selected
                    ? const Color(0xFF080808).withValues(alpha: 0.22)
                    : Colors.white.withValues(alpha: 0.18),
              ),
            ),
            ReorderableDragStartListener(
              index: index,
              child: Tooltip(
                message: 'Move time box',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.drag_indicator_rounded,
                    color: selected
                        ? const Color(0xFF080808)
                        : Colors.white.withValues(alpha: 0.48),
                  ),
                ),
              ),
            ),
          ],
        ),
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
              label: 'Range',
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
