import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_boxing_pomodoro/l10n/generated/app_localizations.dart';
import 'package:time_boxing_pomodoro/l10n/l10n.dart';

import '../application/pomodoro_controller.dart';
import '../domain/entities/pomodoro.dart';
import 'native_timer_copy_l10n.dart';
import 'time_box_title_display.dart';
import 'widgets/focus_timer_dial.dart';

class TimerScreen extends ConsumerWidget {
  final VoidCallback? onOpenToday;

  const TimerScreen({super.key, this.onOpenToday});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomodoro = ref.watch(pomodoroControllerProvider);

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
              230.0,
              math.min(390.0, constraints.maxHeight * 0.46),
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
                          _FocusContent(
                            pomodoro: pomodoro,
                            dialSize: dialSize,
                            isCompactHeight: isCompactHeight,
                            onOpenToday: onOpenToday,
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

  static String _phaseLabel(AppLocalizations l10n, PomodoroPhase phase) {
    switch (phase) {
      case PomodoroPhase.focus:
        return l10n.focusTitle;
      case PomodoroPhase.shortBreak:
        return l10n.shortBreakLabel;
      case PomodoroPhase.longBreak:
        return l10n.longBreakLabel;
    }
  }
}

class _FocusContent extends ConsumerWidget {
  final Pomodoro pomodoro;
  final double dialSize;
  final bool isCompactHeight;
  final VoidCallback? onOpenToday;

  const _FocusContent({
    required this.pomodoro,
    required this.dialSize,
    required this.isCompactHeight,
    required this.onOpenToday,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasActiveFocus =
        pomodoro.canStartFocus ||
        pomodoro.status == PomodoroStatus.running ||
        pomodoro.status == PomodoroStatus.paused;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: hasActiveFocus
          ? _ActiveFocusContent(
              key: const ValueKey('active-focus'),
              pomodoro: pomodoro,
              notifier: ref.read(pomodoroControllerProvider.notifier),
              dialSize: dialSize,
              isCompactHeight: isCompactHeight,
              onOpenToday: onOpenToday,
            )
          : _EmptyFocusContent(
              key: const ValueKey('empty-focus'),
              pomodoro: pomodoro,
              notifier: ref.read(pomodoroControllerProvider.notifier),
              onOpenToday: onOpenToday,
              isCompactHeight: isCompactHeight,
            ),
    );
  }
}

class _ActiveFocusContent extends StatelessWidget {
  final Pomodoro pomodoro;
  final PomodoroController notifier;
  final double dialSize;
  final bool isCompactHeight;
  final VoidCallback? onOpenToday;

  const _ActiveFocusContent({
    super.key,
    required this.pomodoro,
    required this.notifier,
    required this.dialSize,
    required this.isCompactHeight,
    required this.onOpenToday,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ActiveTimeBox(pomodoro: pomodoro, onOpenToday: onOpenToday),
        SizedBox(height: isCompactHeight ? 22 : 30),
        Align(
          child: SizedBox(
            width: dialSize,
            child: FocusTimerDial(
              minutes: pomodoro.minutes,
              seconds: pomodoro.seconds,
              progress: pomodoro.progress,
              label: TimerScreen._phaseLabel(context.l10n, pomodoro.phase),
              pausedLabel: context.l10n.pausedLabel,
              isPaused: pomodoro.status == PomodoroStatus.paused,
            ),
          ),
        ),
        SizedBox(height: isCompactHeight ? 22 : 28),
        _SessionDots(pomodoro: pomodoro),
        SizedBox(height: isCompactHeight ? 22 : 26),
        _ScheduleTrackingControl(pomodoro: pomodoro, notifier: notifier),
      ],
    );
  }
}

class _EmptyFocusContent extends StatelessWidget {
  final Pomodoro pomodoro;
  final PomodoroController notifier;
  final VoidCallback? onOpenToday;
  final bool isCompactHeight;

  const _EmptyFocusContent({
    super.key,
    required this.pomodoro,
    required this.notifier,
    required this.onOpenToday,
    required this.isCompactHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _NoCurrentTimeBoxPanel(onOpenToday: onOpenToday),
        if (pomodoro.timeBoxes.isNotEmpty) ...[
          SizedBox(height: isCompactHeight ? 18 : 24),
          _SessionDots(pomodoro: pomodoro),
        ],
        SizedBox(height: isCompactHeight ? 18 : 24),
        _ScheduleTrackingControl(pomodoro: pomodoro, notifier: notifier),
      ],
    );
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
                context.l10n.focusTitle,
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

class _ActiveTimeBox extends StatelessWidget {
  final Pomodoro pomodoro;
  final VoidCallback? onOpenToday;

  const _ActiveTimeBox({required this.pomodoro, this.onOpenToday});

  @override
  Widget build(BuildContext context) {
    if (!pomodoro.canStartFocus &&
        pomodoro.status != PomodoroStatus.running &&
        pomodoro.status != PomodoroStatus.paused) {
      return _NoCurrentTimeBoxPanel(onOpenToday: onOpenToday);
    }

    final range = pomodoro.liveActivityTimeBoxRange;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.nowLabel,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.48),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            displayPomodoroTimeBoxTitle(pomodoro),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFF6F3EC),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (range.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              range,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.48),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NoCurrentTimeBoxPanel extends StatelessWidget {
  final VoidCallback? onOpenToday;

  const _NoCurrentTimeBoxPanel({this.onOpenToday});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.view_timeline_outlined,
              color: Colors.white.withValues(alpha: 0.7),
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.noCurrentTimeBoxTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF6F3EC),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.noCurrentTimeBoxBody,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          if (onOpenToday != null) ...[
            const SizedBox(width: 10),
            _PlanCurrentSlotButton(onPressed: onOpenToday),
          ],
        ],
      ),
    );
  }
}

class _PlanCurrentSlotButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _PlanCurrentSlotButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 134),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add_rounded, size: 18),
        label: Text(
          context.l10n.planCurrentSlotAction,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFF6F3EC),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Pomodoro pomodoro;

  const _StatusBadge({required this.pomodoro});

  @override
  Widget build(BuildContext context) {
    final label = switch (pomodoro.status) {
      PomodoroStatus.idle => context.l10n.readyLabel,
      PomodoroStatus.running => context.l10n.runningLabel,
      PomodoroStatus.paused => context.l10n.pausedLabel,
      PomodoroStatus.break_ => context.l10n.readyLabel,
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
    final totalBoxes = math.max(1, pomodoro.timeBoxes.length);
    final completedBoxes = math.min(pomodoro.completedSessions, totalBoxes);

    if (pomodoro.timeBoxes.isEmpty) {
      return Text(
        context.l10n.noTodayBoxesProgress,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    return Column(
      children: [
        Text(
          context.l10n.sessionProgress(
            completedBoxes,
            pomodoro.timeBoxes.length,
          ),
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
            totalBoxes,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: index < completedBoxes ? 28 : 9,
              height: 9,
              decoration: BoxDecoration(
                color: index < completedBoxes
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

class _ScheduleTrackingControl extends StatelessWidget {
  final Pomodoro pomodoro;
  final PomodoroController notifier;

  const _ScheduleTrackingControl({
    required this.pomodoro,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = pomodoro.autoStartFocus;
    return Material(
      color: Colors.white.withValues(alpha: 0.045),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => notifier.setScheduleTrackingEnabled(
          !enabled,
          context.l10n.nativeTimerCopy,
        ),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 13, 8, 13),
          child: Row(
            children: [
              Icon(
                enabled ? Icons.sensors_rounded : Icons.sensors_off_rounded,
                color: const Color(0xFFF6F3EC),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.liveTrackingTitle,
                      style: const TextStyle(
                        color: Color(0xFFF6F3EC),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      context.l10n.liveTrackingDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: enabled,
                onChanged: (value) => notifier.setScheduleTrackingEnabled(
                  value,
                  context.l10n.nativeTimerCopy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
