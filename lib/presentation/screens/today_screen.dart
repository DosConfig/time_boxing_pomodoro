import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  Widget build(BuildContext context) {
    final pomodoro = ref.watch(pomodoroProvider);
    final notifier = ref.read(pomodoroProvider.notifier);

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
                    const SizedBox(height: 22),
                    _PriorityBuilder(
                      pomodoro: pomodoro,
                      notifier: notifier,
                      priorityIndex: _priorityIndex,
                      onPriorityIndexChanged: (index) {
                        setState(() => _priorityIndex = index);
                      },
                    ),
                    const SizedBox(height: 16),
                    _TimeBoxList(pomodoro: pomodoro, notifier: notifier),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () async {
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

class _PriorityBuilder extends StatelessWidget {
  final Pomodoro pomodoro;
  final PomodoroNotifier notifier;
  final int priorityIndex;
  final ValueChanged<int> onPriorityIndexChanged;

  const _PriorityBuilder({
    required this.pomodoro,
    required this.notifier,
    required this.priorityIndex,
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
          TextFormField(
            key: ValueKey('priority-$priorityIndex'),
            initialValue: priority,
            onChanged: (value) => notifier.setTopPriority(priorityIndex, value),
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
    if (index >= pomodoro.topPriorities.length) {
      return '';
    }
    return pomodoro.topPriorities[index];
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
          const Text(
            'Time boxes',
            style: TextStyle(
              color: Color(0xFFF6F3EC),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...pomodoro.timeBoxes.map(
            (box) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TimeBoxRow(
                box: box,
                selected: box.id == pomodoro.activeTimeBox?.id,
                onTap: () => notifier.selectTimeBox(box.id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeBoxRow extends StatelessWidget {
  final TimeBox box;
  final bool selected;
  final VoidCallback onTap;

  const _TimeBoxRow({
    required this.box,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(13),
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
            SizedBox(
              width: 86,
              child: Text(
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
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                box.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF080808)
                      : const Color(0xFFF6F3EC),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected
                  ? const Color(0xFF080808)
                  : Colors.white.withValues(alpha: 0.4),
              size: 20,
            ),
          ],
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
