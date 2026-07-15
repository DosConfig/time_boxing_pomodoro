import 'package:flutter/material.dart';

import 'settings_screen.dart';
import 'timer_screen.dart';
import 'today_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
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
}
