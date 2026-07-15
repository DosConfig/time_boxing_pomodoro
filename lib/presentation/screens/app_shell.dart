import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/pomodoro.dart';
import '../providers/pomodoro_provider.dart';
import 'settings_screen.dart';
import 'timer_screen.dart';
import 'today_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    ref.listen<Pomodoro>(pomodoroProvider, (previous, next) {
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
      _showCompletionBanner(previous);
    });

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: IndexedStack(
        index: _index,
        children: [
          TodayScreen(onOpenFocus: () => _setIndex(1)),
          const TimerScreen(),
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
          selectedIndex: _index,
          height: 68,
          onDestinationSelected: _setIndex,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.view_day_outlined),
              selectedIcon: Icon(Icons.view_day_rounded),
              label: 'Today',
            ),
            NavigationDestination(
              icon: Icon(Icons.timer_outlined),
              selectedIcon: Icon(Icons.timer_rounded),
              label: 'Focus',
            ),
            NavigationDestination(
              icon: Icon(Icons.tune_rounded),
              selectedIcon: Icon(Icons.tune_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  void _setIndex(int index) {
    setState(() => _index = index);
  }

  void _showCompletionBanner(Pomodoro previous) {
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
              ? 'Break complete. Next block is ready.'
              : 'Focus complete. Step away before the next block.',
          style: const TextStyle(
            color: Color(0xFF080808),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          TextButton(
            onPressed: messenger.hideCurrentMaterialBanner,
            child: const Text('OK'),
          ),
        ],
      ),
    );

    Future<void>.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      }
    });
  }
}
