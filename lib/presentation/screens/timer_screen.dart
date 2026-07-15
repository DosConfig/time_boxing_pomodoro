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
              math.min(360.0, constraints.maxHeight * 0.39),
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
                          SizedBox(height: isCompactHeight ? 24 : 34),
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
                'Focus Mark',
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
