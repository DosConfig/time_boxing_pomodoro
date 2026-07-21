import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_boxing_pomodoro/l10n/l10n.dart';

import '../../settings/application/app_preferences_controller.dart';

class IntroOnboardingScreen extends ConsumerStatefulWidget {
  const IntroOnboardingScreen({super.key});

  @override
  ConsumerState<IntroOnboardingScreen> createState() =>
      _IntroOnboardingScreenState();
}

class _IntroOnboardingScreenState extends ConsumerState<IntroOnboardingScreen> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishIntro() async {
    HapticFeedback.mediumImpact();
    await ref.read(appPreferencesControllerProvider.notifier).completeIntro();
  }

  Future<void> _goNext(int lastIndex) async {
    HapticFeedback.selectionClick();
    if (_pageIndex >= lastIndex) {
      await _finishIntro();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final slides = [
      _IntroSlide(
        previewKind: _IntroPreviewKind.today,
        title: l10n.introBrainDumpTitle,
        body: l10n.introBrainDumpBody,
      ),
      _IntroSlide(
        previewKind: _IntroPreviewKind.priorities,
        title: l10n.introPrioritiesTitle,
        body: l10n.introPrioritiesBody,
      ),
      _IntroSlide(
        previewKind: _IntroPreviewKind.timeBoxes,
        title: l10n.introTimeBoxTitle,
        body: l10n.introTimeBoxBody,
      ),
      _IntroSlide(
        previewKind: _IntroPreviewKind.focus,
        title: l10n.introFocusTitle,
        body: l10n.introFocusBody,
      ),
    ];
    final lastIndex = slides.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _IntroTopBar(
                appName: l10n.appName,
                skipLabel: l10n.introSkipAction,
                onSkip: _finishIntro,
              ),
              const SizedBox(height: 14),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: slides.length,
                  onPageChanged: (index) => setState(() => _pageIndex = index),
                  itemBuilder: (context, index) {
                    return _IntroPage(slide: slides[index]);
                  },
                ),
              ),
              const SizedBox(height: 18),
              _IntroPagerDots(count: slides.length, selectedIndex: _pageIndex),
              const SizedBox(height: 18),
              _IntroPrimaryAction(
                key: const ValueKey('intro_next'),
                label: _pageIndex == lastIndex
                    ? l10n.introStartAction
                    : l10n.introNextAction,
                onPressed: () => _goNext(lastIndex),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _IntroPreviewKind { today, priorities, timeBoxes, focus }

class _IntroSlide {
  final _IntroPreviewKind previewKind;
  final String title;
  final String body;

  const _IntroSlide({
    required this.previewKind,
    required this.title,
    required this.body,
  });
}

class _IntroTopBar extends StatelessWidget {
  final String appName;
  final String skipLabel;
  final Future<void> Function() onSkip;

  const _IntroTopBar({
    required this.appName,
    required this.skipLabel,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            appName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFF6F3EC),
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
        TextButton(
          onPressed: onSkip,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white.withValues(alpha: 0.58),
            visualDensity: VisualDensity.compact,
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          child: Text(skipLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _IntroPage extends StatelessWidget {
  final _IntroSlide slide;

  const _IntroPage({required this.slide});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final previewHeight = math.min(
          390.0,
          math.max(250.0, constraints.maxHeight * 0.62),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: SizedBox(
                  height: previewHeight,
                  child: _IntroPhonePreview(kind: slide.previewKind),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              slide.title,
              style: const TextStyle(
                color: Color(0xFFF6F3EC),
                fontSize: 30,
                fontWeight: FontWeight.w900,
                height: 1.04,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              slide.body,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.62),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.34,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _IntroPhonePreview extends StatelessWidget {
  final _IntroPreviewKind kind;

  const _IntroPhonePreview({required this.kind});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.56,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF050505),
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          borderRadius: BorderRadius.circular(34),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.46),
              blurRadius: 30,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Container(
            color: const Color(0xFF080808),
            child: _IntroPreviewContent(kind: kind),
          ),
        ),
      ),
    );
  }
}

class _IntroPreviewContent extends StatelessWidget {
  final _IntroPreviewKind kind;

  const _IntroPreviewContent({required this.kind});

  @override
  Widget build(BuildContext context) {
    switch (kind) {
      case _IntroPreviewKind.today:
        return const _TodayPreviewScreen();
      case _IntroPreviewKind.priorities:
        return const _PrioritiesPreviewScreen();
      case _IntroPreviewKind.timeBoxes:
        return const _TimeBoxesPreviewScreen();
      case _IntroPreviewKind.focus:
        return const _FocusPreviewScreen();
    }
  }
}

class _PreviewScaffold extends StatelessWidget {
  final Widget child;

  const _PreviewScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 18, 15, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _PreviewStatusBar(),
          const SizedBox(height: 14),
          Expanded(child: child),
          const SizedBox(height: 10),
          const _PreviewNavBar(),
        ],
      ),
    );
  }
}

class _PreviewStatusBar extends StatelessWidget {
  const _PreviewStatusBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '09:41',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
            fontSize: 8,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        Container(
          width: 42,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const Spacer(),
        Icon(
          Icons.battery_full_rounded,
          color: Colors.white.withValues(alpha: 0.78),
          size: 10,
        ),
      ],
    );
  }
}

class _TodayPreviewScreen extends StatelessWidget {
  const _TodayPreviewScreen();

  @override
  Widget build(BuildContext context) {
    return _PreviewScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PreviewTitle(label: context.l10n.todayTitle),
          const SizedBox(height: 9),
          _PreviewPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PreviewPanelHeader(
                  label: context.l10n.brainDumpTitle,
                  icon: Icons.add_rounded,
                ),
                const SizedBox(height: 7),
                _PreviewTaskRow(label: context.l10n.captureLabel),
                const SizedBox(height: 5),
                _PreviewTaskRow(label: context.l10n.addReminderTitle),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _PreviewPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PreviewPanelHeader(
                  label: context.l10n.topPrioritiesTitle,
                  icon: Icons.flag_rounded,
                ),
                const SizedBox(height: 7),
                _PreviewPriorityPill(
                  label: context.l10n.introSampleTopPriority,
                ),
                const SizedBox(height: 5),
                _PreviewPriorityPill(label: context.l10n.introSampleDeepWork),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrioritiesPreviewScreen extends StatelessWidget {
  const _PrioritiesPreviewScreen();

  @override
  Widget build(BuildContext context) {
    return _PreviewScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PreviewTitle(label: context.l10n.topPrioritiesTitle),
          const SizedBox(height: 10),
          _PriorityCard(
            number: 1,
            label: context.l10n.introSampleTopPriority,
            selected: true,
          ),
          const SizedBox(height: 7),
          _PriorityCard(number: 2, label: context.l10n.introSampleDeepWork),
          const SizedBox(height: 7),
          _PriorityCard(number: 3, label: context.l10n.introSampleFollowUp),
          const SizedBox(height: 12),
          _PreviewPanel(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.dailyProgressTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFF6F3EC),
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const _MiniProgressDots(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeBoxesPreviewScreen extends StatelessWidget {
  const _TimeBoxesPreviewScreen();

  @override
  Widget build(BuildContext context) {
    return _PreviewScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PreviewTitle(label: context.l10n.timeBoxesTitle),
          const SizedBox(height: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  const _PreviewTimeSlot(top: 0, label: '09:00'),
                  const _PreviewTimeSlot(top: 42, label: '09:30'),
                  const _PreviewTimeSlot(top: 84, label: '10:00'),
                  const _PreviewTimeSlot(top: 126, label: '10:30'),
                  const _PreviewTimeSlot(top: 168, label: '11:00'),
                  _PreviewTimeBoxCard(
                    top: 8,
                    label: context.l10n.introSampleTopPriority,
                    selected: true,
                  ),
                  _PreviewTimeBoxCard(
                    top: 96,
                    label: context.l10n.introSampleDeepWork,
                  ),
                  const _PreviewNowLine(top: 52),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusPreviewScreen extends StatelessWidget {
  const _FocusPreviewScreen();

  @override
  Widget build(BuildContext context) {
    return _PreviewScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _PreviewTitle(label: context.l10n.focusTitle)),
              _PreviewStatusPill(label: context.l10n.runningLabel),
            ],
          ),
          const SizedBox(height: 10),
          _PreviewPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.nowLabel,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.48),
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.introSampleTopPriority,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF6F3EC),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '09:00-09:30',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.42),
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Expanded(child: Center(child: _PreviewTimerDial())),
          const SizedBox(height: 14),
          _PreviewPanel(
            child: Row(
              children: [
                Icon(
                  Icons.notifications_active_outlined,
                  color: Colors.white.withValues(alpha: 0.66),
                  size: 11,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    context.l10n.localAlerts,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFF6F3EC),
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
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

class _PreviewNavBar extends StatelessWidget {
  const _PreviewNavBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        _PreviewNavDot(selected: true),
        _PreviewNavDot(selected: false),
        _PreviewNavDot(selected: false),
        _PreviewNavDot(selected: false),
      ],
    );
  }
}

class _PreviewNavDot extends StatelessWidget {
  final bool selected;

  const _PreviewNavDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: selected ? 18 : 7,
      height: 7,
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFFF6F3EC)
            : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _PreviewTitle extends StatelessWidget {
  final String label;

  const _PreviewTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Color(0xFFF6F3EC),
        fontSize: 20,
        fontWeight: FontWeight.w900,
        height: 1,
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  final Widget child;

  const _PreviewPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class _PreviewPanelHeader extends StatelessWidget {
  final String label;
  final IconData icon;

  const _PreviewPanelHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFF6F3EC),
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Icon(icon, color: Colors.white.withValues(alpha: 0.72), size: 11),
      ],
    );
  }
}

class _PreviewTaskRow extends StatelessWidget {
  final String label;

  const _PreviewTaskRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFFF6F3EC),
          fontSize: 8,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PreviewPriorityPill extends StatelessWidget {
  final String label;

  const _PreviewPriorityPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFF6F3EC)),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Icon(
            Icons.check_rounded,
            color: const Color(0xFFF6F3EC),
            size: 8,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFF6F3EC),
              fontSize: 8,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _PriorityCard extends StatelessWidget {
  final int number;
  final String label;
  final bool selected;

  const _PriorityCard({
    required this.number,
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFFF6F3EC)
            : Colors.white.withValues(alpha: 0.055),
        border: Border.all(
          color: selected
              ? const Color(0xFFF6F3EC)
              : Colors.white.withValues(alpha: 0.1),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF080808)
                  : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$number',
              style: TextStyle(
                color: selected
                    ? const Color(0xFFF6F3EC)
                    : Colors.white.withValues(alpha: 0.72),
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected
                    ? const Color(0xFF080808)
                    : const Color(0xFFF6F3EC),
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniProgressDots extends StatelessWidget {
  const _MiniProgressDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        5,
        (index) => Container(
          width: index < 3 ? 13 : 6,
          height: 6,
          margin: const EdgeInsets.only(left: 3),
          decoration: BoxDecoration(
            color: index < 3
                ? const Color(0xFFF6F3EC)
                : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _PreviewTimeSlot extends StatelessWidget {
  final double top;
  final String label;

  const _PreviewTimeSlot({required this.top, required this.label});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      height: 42,
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 7,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewTimeBoxCard extends StatelessWidget {
  final double top;
  final String label;
  final bool selected;

  const _PreviewTimeBoxCard({
    required this.top,
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: 38,
      right: 0,
      height: 34,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFF6F3EC)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? const Color(0xFFF6F3EC)
                : Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selected ? const Color(0xFF080808) : const Color(0xFFF6F3EC),
            fontSize: 8,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _PreviewNowLine extends StatelessWidget {
  final double top;

  const _PreviewNowLine({required this.top});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: 31,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFFF6F3EC),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(child: Container(height: 2, color: const Color(0xFFF6F3EC))),
        ],
      ),
    );
  }
}

class _PreviewStatusPill extends StatelessWidget {
  final String label;

  const _PreviewStatusPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFF6F3EC),
          fontSize: 7,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PreviewTimerDial extends StatelessWidget {
  const _PreviewTimerDial();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 116,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.square(
            dimension: 116,
            child: CircularProgressIndicator(
              value: 0.42,
              strokeWidth: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              color: const Color(0xFFF6F3EC),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '17:24',
                style: TextStyle(
                  color: Color(0xFFF6F3EC),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                context.l10n.focusTitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.48),
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IntroPagerDots extends StatelessWidget {
  final int count;
  final int selectedIndex;

  const _IntroPagerDots({required this.count, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => _IntroPagerDot(selected: index == selectedIndex),
      ),
    );
  }
}

class _IntroPagerDot extends StatelessWidget {
  final bool selected;

  const _IntroPagerDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: selected ? 28 : 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFFF6F3EC)
            : Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _IntroPrimaryAction extends StatelessWidget {
  final String label;
  final Future<void> Function() onPressed;

  const _IntroPrimaryAction({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFF6F3EC),
        foregroundColor: const Color(0xFF080808),
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
      ),
    );
  }
}
