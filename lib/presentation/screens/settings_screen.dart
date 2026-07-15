import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_preferences_provider.dart';
import '../providers/pomodoro_provider.dart';
import 'onboarding_screen.dart' show formatClock, normalizeAwakeRange;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomodoro = ref.watch(pomodoroProvider);
    final preferences = ref.watch(appPreferencesProvider);
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
                            'Awake window',
                            style: TextStyle(
                              color: Color(0xFFF6F3EC),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${formatClock(preferences.awakeStartMinutes)} - ${formatClock(preferences.awakeEndMinutes)}',
                                  style: const TextStyle(
                                    color: Color(0xFFF6F3EC),
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => _openAwakeWindowSheet(
                                  context,
                                  ref,
                                  preferences,
                                ),
                                child: const Text('Edit'),
                              ),
                            ],
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
                            'Execution',
                            style: TextStyle(
                              color: Color(0xFFF6F3EC),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _SettingsSwitch(
                            label: 'Auto-start next time box',
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

  void _openAwakeWindowSheet(
    BuildContext context,
    WidgetRef ref,
    AppPreferences preferences,
  ) {
    var range = RangeValues(
      preferences.awakeStartMinutes.toDouble(),
      preferences.awakeEndMinutes.toDouble(),
    );

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF101010),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Awake window',
                      style: TextStyle(
                        color: Color(0xFFF6F3EC),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${formatClock(range.start.round())} - ${formatClock(range.end.round())}',
                      style: const TextStyle(
                        color: Color(0xFFF6F3EC),
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RangeSlider(
                      values: range,
                      min: 0,
                      max: 24 * 60,
                      divisions: 48,
                      activeColor: const Color(0xFFF6F3EC),
                      inactiveColor: Colors.white.withValues(alpha: 0.16),
                      labels: RangeLabels(
                        formatClock(range.start.round()),
                        formatClock(range.end.round()),
                      ),
                      onChanged: (next) {
                        setModalState(() {
                          range = normalizeAwakeRange(next);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () async {
                        await ref
                            .read(appPreferencesProvider.notifier)
                            .saveAwakeWindow(
                              range.start.round(),
                              range.end.round(),
                            );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFF6F3EC),
                        foregroundColor: const Color(0xFF080808),
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
