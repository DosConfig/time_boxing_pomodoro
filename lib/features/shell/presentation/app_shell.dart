import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_method_channel/l10n/l10n.dart';

import '../../calendar/presentation/calendar_sync_screen.dart';
import '../../focus/application/pomodoro_controller.dart';
import '../../focus/domain/entities/pomodoro.dart';
import '../../focus/presentation/timer_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../application/app_shell_controller.dart';
import '../../today/presentation/today_screen.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final index = ref.watch(appShellControllerProvider);
    ref.listen<Pomodoro>(pomodoroControllerProvider, (previous, next) {
      if (previous == null || !previous.notificationsEnabled) {
        return;
      }
      final completedInForeground =
          previous.status == PomodoroStatus.running &&
          previous.remainingTime > 0 &&
          next.remainingTime == 0;
      if (!completedInForeground) {
        return;
      }
      _showCompletionBanner(context, previous);
    });

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: IndexedStack(
        index: index,
        children: [
          TodayScreen(onOpenFocus: () => _setIndex(ref, 1)),
          const TimerScreen(),
          const CalendarSyncScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFF101010),
          indicatorColor: const Color(0xFFF6F3EC),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              color: selected
                  ? const Color(0xFFF6F3EC)
                  : Colors.white.withValues(alpha: 0.48),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected
                  ? const Color(0xFF080808)
                  : Colors.white.withValues(alpha: 0.58),
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: index,
          height: 72,
          onDestinationSelected: (nextIndex) => _setIndex(ref, nextIndex),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.view_day_outlined),
              selectedIcon: const Icon(Icons.view_day_rounded),
              label: l10n.navToday,
            ),
            NavigationDestination(
              icon: const Icon(Icons.timer_outlined),
              selectedIcon: const Icon(Icons.timer_rounded),
              label: l10n.navFocus,
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              selectedIcon: const Icon(Icons.calendar_month_rounded),
              label: l10n.navCalendar,
            ),
            NavigationDestination(
              icon: const Icon(Icons.tune_rounded),
              selectedIcon: const Icon(Icons.tune_rounded),
              label: l10n.navSettings,
            ),
          ],
        ),
      ),
    );
  }

  void _setIndex(WidgetRef ref, int index) {
    if (index == 1) {
      ref.read(pomodoroControllerProvider.notifier).syncFocusWithClock();
    }
    ref.read(appShellControllerProvider.notifier).selectTab(index);
  }

  void _showCompletionBanner(BuildContext context, Pomodoro previous) {
    final isBreak = previous.isBreakPhase;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentMaterialBanner();
    messenger.showMaterialBanner(
      MaterialBanner(
        elevation: 0,
        backgroundColor: const Color(0xFFF6F3EC),
        leading: Icon(
          isBreak ? Icons.self_improvement_rounded : Icons.timer_rounded,
          color: const Color(0xFF080808),
        ),
        content: Text(
          isBreak
              ? context.l10n.breakCompleteMessage
              : context.l10n.focusCompleteMessage,
          style: const TextStyle(
            color: Color(0xFF080808),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          TextButton(
            onPressed: messenger.hideCurrentMaterialBanner,
            child: Text(context.l10n.ok),
          ),
        ],
      ),
    );

    Future<void>.delayed(const Duration(seconds: 4), () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      }
    });
  }
}
