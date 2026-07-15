import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/pomodoro.dart';
import '../providers/pomodoro_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomodoro = ref.watch(pomodoroProvider);
    final notifier = ref.read(pomodoroProvider.notifier);

    return SafeArea(
      child: ScrollConfiguration(
        behavior: const _SettingsScrollBehavior(),
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 32),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        color: Color(0xFFF6F3EC),
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Session design',
                            style: TextStyle(
                              color: Color(0xFFF6F3EC),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
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
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.16),
                                ),
                                labelStyle: TextStyle(
                                  color: selected
                                      ? const Color(0xFF0A0A0A)
                                      : const Color(0xFFF6F3EC),
                                  fontWeight: FontWeight.w800,
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Alerts',
                            style: TextStyle(
                              color: Color(0xFFF6F3EC),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
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

class _SettingsScrollBehavior extends MaterialScrollBehavior {
  const _SettingsScrollBehavior();

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
