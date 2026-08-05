import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_boxing_pomodoro/l10n/l10n.dart';

import '../../calendar/presentation/calendar_sync_screen.dart';
import '../../focus/application/pomodoro_controller.dart';
import '../../focus/domain/entities/pomodoro.dart';
import '../../focus/presentation/native_timer_copy_l10n.dart';
import '../../focus/presentation/timer_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../application/app_shell_controller.dart';
import '../../today/presentation/today_screen.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    ref
        .read(pomodoroControllerProvider.notifier)
        .updateNativeCopy(l10n.nativeTimerCopy);
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
      body: IndexedStack(
        index: index,
        children: [
          TodayScreen(onOpenFocus: () => _setIndex(ref, 1)),
          TimerScreen(onOpenToday: () => _setIndex(ref, 0)),
          const CalendarSyncScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: Icon(
          isBreak ? Icons.self_improvement_rounded : Icons.timer_rounded,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        content: Text(
          isBreak
              ? context.l10n.breakCompleteMessage
              : context.l10n.focusCompleteMessage,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          TextButton(
            onPressed: messenger.hideCurrentMaterialBanner,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
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
