import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/pomodoro.dart';
import '../providers/pomodoro_provider.dart';
import '../widgets/focus_timer_dial.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomodoro = ref.watch(pomodoroProvider);
    final notifier = ref.read(pomodoroProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const horizontalPadding = 24.0;
            final contentWidth = math.max(
              0.0,
              constraints.maxWidth - (horizontalPadding * 2),
            );
            final preferredDialSize = math.max(
              220.0,
              math.min(330.0, constraints.maxHeight * 0.35),
            );
            final dialSize = math.min(contentWidth, preferredDialSize);
            final isCompactHeight = constraints.maxHeight < 720;

            return ScrollConfiguration(
              behavior: const _TimerScrollBehavior(),
              child: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      horizontalPadding,
                      22,
                      horizontalPadding,
                      32,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Header(pomodoro: pomodoro),
                          SizedBox(height: isCompactHeight ? 18 : 24),
                          _TodayPlanPanel(
                            pomodoro: pomodoro,
                            notifier: notifier,
                          ),
                          SizedBox(height: isCompactHeight ? 22 : 28),
                          Align(
                            child: SizedBox(
                              width: dialSize,
                              child: FocusTimerDial(
                                minutes: pomodoro.minutes,
                                seconds: pomodoro.seconds,
                                progress: pomodoro.progress,
                                label: _phaseLabel(pomodoro.phase),
                                isPaused:
                                    pomodoro.status == PomodoroStatus.paused,
                              ),
                            ),
                          ),
                          SizedBox(height: isCompactHeight ? 22 : 28),
                          _SessionDots(pomodoro: pomodoro),
                          SizedBox(height: isCompactHeight ? 22 : 26),
                          _Controls(pomodoro: pomodoro, notifier: notifier),
                          SizedBox(height: isCompactHeight ? 24 : 28),
                          _SettingsPanel(
                            pomodoro: pomodoro,
                            notifier: notifier,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static String _phaseLabel(PomodoroPhase phase) {
    switch (phase) {
      case PomodoroPhase.focus:
        return 'Focus';
      case PomodoroPhase.shortBreak:
        return 'Short break';
      case PomodoroPhase.longBreak:
        return 'Long break';
    }
  }
}

class _TimerScrollBehavior extends MaterialScrollBehavior {
  const _TimerScrollBehavior();

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

class _Header extends StatelessWidget {
  final Pomodoro pomodoro;

  const _Header({required this.pomodoro});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pomodoro.presetLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.48),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Timebox Mark',
                style: TextStyle(
                  color: Color(0xFFF6F3EC),
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        _StatusBadge(pomodoro: pomodoro),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Pomodoro pomodoro;

  const _StatusBadge({required this.pomodoro});

  @override
  Widget build(BuildContext context) {
    final label = switch (pomodoro.status) {
      PomodoroStatus.idle => 'Ready',
      PomodoroStatus.running => pomodoro.isBreakPhase ? 'Break' : 'Running',
      PomodoroStatus.paused => 'Paused',
      PomodoroStatus.break_ => 'Break',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFF6F3EC),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SessionDots extends StatelessWidget {
  final Pomodoro pomodoro;

  const _SessionDots({required this.pomodoro});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${pomodoro.completedSessions} of ${pomodoro.sessionsUntilLongBreak} focus blocks',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.58),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            pomodoro.sessionsUntilLongBreak,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: index < pomodoro.completedSessions ? 28 : 9,
              height: 9,
              decoration: BoxDecoration(
                color: index < pomodoro.completedSessions
                    ? const Color(0xFFF6F3EC)
                    : Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  final Pomodoro pomodoro;
  final PomodoroNotifier notifier;

  const _Controls({required this.pomodoro, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final isRunning = pomodoro.status == PomodoroStatus.running;
    final primaryIcon = isRunning
        ? Icons.pause_rounded
        : Icons.play_arrow_rounded;
    final primaryLabel = isRunning ? 'Pause' : 'Start';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RoundActionButton(
          icon: Icons.restart_alt_rounded,
          label: 'Reset',
          onTap: notifier.reset,
          isPrimary: false,
        ),
        const SizedBox(width: 18),
        _RoundActionButton(
          icon: primaryIcon,
          label: primaryLabel,
          onTap: isRunning ? notifier.pause : notifier.start,
          isPrimary: true,
        ),
      ],
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _RoundActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: isPrimary ? 82 : 62,
          height: isPrimary ? 82 : 62,
          decoration: BoxDecoration(
            color: isPrimary ? const Color(0xFFF6F3EC) : Colors.transparent,
            border: Border.all(
              color: Colors.white.withValues(alpha: isPrimary ? 0 : 0.18),
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: isPrimary ? 38 : 28,
            color: isPrimary
                ? const Color(0xFF0A0A0A)
                : const Color(0xFFF6F3EC),
          ),
        ),
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  final Pomodoro pomodoro;
  final PomodoroNotifier notifier;

  const _SettingsPanel({required this.pomodoro, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Session design',
            style: TextStyle(
              color: Color(0xFFF6F3EC),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PomodoroPreset.values.map((preset) {
              final selected = preset == pomodoro.preset;
              return ChoiceChip(
                label: Text(_presetLabel(preset)),
                selected: selected,
                onSelected: (_) => notifier.applyPreset(preset),
                backgroundColor: Colors.transparent,
                selectedColor: const Color(0xFFF6F3EC),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
                labelStyle: TextStyle(
                  color: selected
                      ? const Color(0xFF0A0A0A)
                      : const Color(0xFFF6F3EC),
                  fontWeight: FontWeight.w700,
                ),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _SettingsSwitch(
            label: 'Auto-start breaks',
            value: pomodoro.autoStartBreaks,
            onChanged: notifier.setAutoStartBreaks,
          ),
          _SettingsSwitch(
            label: 'Auto-start next focus',
            value: pomodoro.autoStartFocus,
            onChanged: notifier.setAutoStartFocus,
          ),
          Divider(height: 24, color: Colors.white.withValues(alpha: 0.1)),
          const Text(
            'Alerts',
            style: TextStyle(
              color: Color(0xFFF6F3EC),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          _SettingsSwitch(
            label: 'Local alerts',
            value: pomodoro.notificationsEnabled,
            onChanged: notifier.setNotificationsEnabled,
          ),
          _SettingsSwitch(
            label: 'Sound',
            value: pomodoro.soundEnabled,
            onChanged: pomodoro.notificationsEnabled
                ? notifier.setSoundEnabled
                : null,
          ),
        ],
      ),
    );
  }

  static String _presetLabel(PomodoroPreset preset) {
    switch (preset) {
      case PomodoroPreset.classic:
        return '25 / 5';
      case PomodoroPreset.deepWork:
        return '50 / 10';
      case PomodoroPreset.sprint:
        return '15 / 3';
    }
  }
}

class _TodayPlanPanel extends StatelessWidget {
  final Pomodoro pomodoro;
  final PomodoroNotifier notifier;

  const _TodayPlanPanel({required this.pomodoro, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _PlanContextSummary(
        pomodoro: pomodoro,
        onSelectTimeBox: (id) {
          unawaited(notifier.selectTimeBox(id));
        },
        onEdit: () => _openPlanEditor(context),
      ),
    );
  }

  void _openPlanEditor(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF101010),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return _PlanEditorSheet(pomodoro: pomodoro, notifier: notifier);
      },
    );
  }
}

class _PlanContextSummary extends StatelessWidget {
  final Pomodoro pomodoro;
  final ValueChanged<String> onSelectTimeBox;
  final VoidCallback onEdit;

  const _PlanContextSummary({
    required this.pomodoro,
    required this.onSelectTimeBox,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final priorities = pomodoro.visibleTopPriorities;
    final title = pomodoro.liveActivityTimeBoxTitle;
    final range = pomodoro.liveActivityTimeBoxRange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Today plan',
                style: TextStyle(
                  color: Color(0xFFF6F3EC),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Tooltip(
              message: 'Edit plan',
              child: IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_note_rounded),
                color: const Color(0xFFF6F3EC),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFF6F3EC),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (range.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            range,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.48),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (priorities.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...priorities.map(
            (priority) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  Icon(
                    Icons.check_box_outline_blank_rounded,
                    size: 15,
                    color: Colors.white.withValues(alpha: 0.48),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      priority,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (pomodoro.timeBoxes.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            'Time boxes',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.48),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              itemCount: pomodoro.timeBoxes.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final box = pomodoro.timeBoxes[index];
                return _TimeBoxPill(
                  box: box,
                  selected: box.id == pomodoro.activeTimeBox?.id,
                  onTap: () => onSelectTimeBox(box.id),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _TimeBoxPill extends StatelessWidget {
  final TimeBox box;
  final bool selected;
  final VoidCallback onTap;

  const _TimeBoxPill({
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
        width: 132,
        padding: const EdgeInsets.all(11),
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
                    ? const Color(0xFF0A0A0A)
                    : Colors.white.withValues(alpha: 0.48),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              box.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected
                    ? const Color(0xFF0A0A0A)
                    : const Color(0xFFF6F3EC),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanEditorSheet extends StatelessWidget {
  final Pomodoro pomodoro;
  final PomodoroNotifier notifier;

  const _PlanEditorSheet({required this.pomodoro, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 18, 20, bottomInset + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Plan context',
                    style: TextStyle(
                      color: Color(0xFFF6F3EC),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
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
            ...List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: index == 2 ? 0 : 8),
                child: _SettingsTextField(
                  initialValue: _priorityAt(index),
                  label: 'Top ${index + 1}',
                  onChanged: (value) => notifier.setTopPriority(index, value),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _SettingsTextField(
              initialValue: pomodoro.currentTimeBoxTitle,
              label: 'Current time box',
              onChanged: notifier.setCurrentTimeBoxTitle,
            ),
            const SizedBox(height: 8),
            _SettingsTextField(
              initialValue: pomodoro.currentTimeBoxTimeRange,
              label: 'Time range',
              onChanged: notifier.setCurrentTimeBoxTimeRange,
            ),
          ],
        ),
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

class _SettingsTextField extends StatelessWidget {
  final String initialValue;
  final String label;
  final ValueChanged<String> onChanged;

  const _SettingsTextField({
    required this.initialValue,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      minLines: 1,
      maxLines: 1,
      cursorColor: const Color(0xFFF6F3EC),
      style: const TextStyle(
        color: Color(0xFFF6F3EC),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.46),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
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

class _SettingsSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _SettingsSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        label,
        style: TextStyle(
          color: onChanged == null
              ? Colors.white.withValues(alpha: 0.34)
              : const Color(0xFFF6F3EC),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      value: value,
      activeTrackColor: const Color(0xFFF6F3EC),
      activeThumbColor: const Color(0xFF0A0A0A),
      inactiveTrackColor: Colors.white.withValues(alpha: 0.18),
      inactiveThumbColor: const Color(0xFFF6F3EC),
      onChanged: onChanged,
    );
  }
}
